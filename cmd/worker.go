package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"rag-ai/configs"
	databases "rag-ai/databases/postgres"
	"rag-ai/models"
	"rag-ai/utils"
	"sync"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v3/log"
	"github.com/robfig/cron/v3"
	"gorm.io/gorm"
)

func init() {
	// Set the default timezone to UTC for the entire application
	//time.Local = time.UTC
}

func main() {
	log.Info("Worker started.......")
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	db := setupWorkerDatabase()
	defer closeWorkerDatabase(db)

	//Register the cronjob to get the clients every minute
	getClients(db)
	c := cron.New()
	c.AddFunc("@every 1m", func() { getClients(db) })
	c.Start()

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	worker := &Worker{}
	go worker.run(db, ctx)

	// Wait for a signal
	sig := <-sigChan
	log.Infof("\nReceived signal: %v. Initiating graceful shutdown...\n", sig)

	// Cancel the context to tell the run loop to stop accepting new work
	cancel()

	// Wait for all spawned goroutines to finish
	worker.wg.Wait()
	log.Infof("All tasks completed. Worker stopped.")
}

func getClients(db *gorm.DB) {
	sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Get_Clients()")
	db.Raw(sqlQuery).Scan(&utils.RagClients)
}

type Worker struct {
	wg sync.WaitGroup
}

func setupWorkerDatabase() *gorm.DB {
	db := databases.Connect(configs.DataBaseUrl)
	return db
}

// run contains the main loop and the branching logic
func (w *Worker) run(db *gorm.DB, ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			// Context was canceled (shutdown signal received)
			log.Info("Worker loop stopped.")
			return
		case <-ticker.C:
			sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Get_Menu_Tasks(%d)", configs.TaskPending)
			log.Info(sqlQuery)
			pendingTasks := []models.MenuTask{}
			result := db.Raw(sqlQuery).Scan(&pendingTasks)
			// Check for errors
			if result.Error != nil {
				log.Errorf("Database query failed: %v", result.Error)
			}

			log.Infof("Rows affected: %d", result.RowsAffected)
			log.Infof("pendingTasks=%+v", pendingTasks)

			for _, task := range pendingTasks {
				if task.Task == "import" {
					w.wg.Add(1)
					go w.importMenu(db, task)
				} else {
					w.wg.Add(1)
					go w.generateVectors(db, task)
				}
			}
		}
	}
}

func (w *Worker) importMenu(db *gorm.DB, task models.MenuTask) {
	defer w.wg.Done() // Decrement counter when function exits

	var result models.SaveResult

	zipFile := fmt.Sprintf("data/menu_%d.zip", task.ClientID)
	zipFolder := fmt.Sprintf("data/menu_%d", task.ClientID)

	log.Infof("Import menu task finstartedished for client: %d", task.ClientID)

	_, err := utils.DownLoadAndImportMenu(db, task.ClientID)
	if err != nil {
		log.Errorf("Error in downloading and importing menu for client %d: %s", task.ClientID, err)
		db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskError, "message": err.Error()})
	} else {
		task.Status = configs.TaskRunning
		db.Save(&task)
		// Import the menu content from the directory to the database.
		err = utils.ImportMenuContentFromDir(db, task.ClientID, zipFolder)
		if err == nil {
			db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskCompleted})
			// After successful import, add a task to generate the content vectors for the customer.
			customer_id := utils.GetCustomerId(task.ClientID)
			sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Save_Menu_Task('%s', '%s')", customer_id, "vectors")
			db.Raw(sqlQuery).Scan(&result)

			err = os.Remove(zipFile)
			if err != nil {
				log.Errorf("Error deleting the zip file: %s", err.Error())
			}

			err = os.RemoveAll(zipFolder)
			if err != nil {
				log.Errorf("Error deleting the directory: %s", err.Error())
			}
		} else {
			log.Infof("ImportMenuContentFromDir error: %+v", err)
		}
	}

	log.Infof("Import menu task finished for client: %d", task.ClientID)
}

func (w *Worker) generateVectors(db *gorm.DB, task models.MenuTask) {
	defer w.wg.Done() // Decrement counter when function exits

	log.Infof("Generate vectors task started for client: %d", task.ClientID)

	db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskRunning})
	err := utils.GenerateAllCustomerContentVectors(db, task.ClientID, task.ID)
	if err != nil {
		if err.Error() != "Task canceled." {
			log.Errorf("Error in generating content vectors for client %d: %s", task.ClientID, err)
			db.Model(&task).Where("status=?", configs.TaskRunning).Updates(map[string]interface{}{"status": configs.TaskError, "message": err.Error()})
		}
	} else {
		db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskCompleted})
		log.Infof("Generate vectors task finished for client: %d", task.ClientID)
	}
}

func closeWorkerDatabase(db *gorm.DB) {
	sqlDB, errDB := db.DB()
	if errDB != nil {
		log.Errorf("Error getting worker databases instance: %v", errDB)
		return
	}

	if err := sqlDB.Close(); err != nil {
		log.Errorf("Error closing worker databases connection: %v", err)
	} else {
		log.Info("Worker databases connection closed successfully")
	}
}

func handleWorkerGracefulShutdown(ctx context.Context, workerErrors <-chan error) {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-workerErrors:
		log.Fatalf("Worker error: %v", err)
	case <-quit:
		log.Info("Shutting down worker...")
	case <-ctx.Done():
		log.Info("Worker exiting due to context cancellation")
	}

	log.Info("Worker exited")
}
