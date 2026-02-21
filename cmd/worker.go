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
	"gorm.io/gorm"
)

func main() {
	log.Info("Worker started.......")
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	db := setupWorkerDatabase()
	defer closeWorkerDatabase(db)

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
			pendingTasks := []models.MenuTask{}
			condition := fmt.Sprintf(`EXTRACT(EPOCH FROM(CURRENT_TIMESTAMP-created_at)) > 30 AND status=%d`, configs.TaskPending)
			db.Debug().Find(&pendingTasks, condition)

			log.Infof("pending tasks=%+v", pendingTasks)
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

	log.Info("Import menu task started...")

	_, err := utils.DownLoadAndImportMenu(db, task.CustomerID)
	if err != nil {
		log.Errorf("Error in downloading and importing menu for customer %s: %s", task.CustomerID, err)
		db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskError, "message": err.Error()})
	} else {
		db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskRunning})
		// Import the menu content from the directory to the database.
		err = utils.ImportMenuContentFromDir(db, task.CustomerID, "data/menu_"+task.CustomerID)
		if err == nil {
			db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskCompleted})
			// After successful import, add a task to generate the content vectors for the customer.
			// If there is an ongoing vector job, cancel it first.
			db.Debug().Model(models.MenuTask{}).Where("customer_id=? and status=? and task='vectors'", task.CustomerID, configs.TaskRunning).Updates(map[string]interface{}{"status": configs.TaskCanceled})
			newTask := models.MenuTask{
				CustomerID: task.CustomerID,
				Task:       "vectors",
				Status:     configs.TaskPending,
			}
			db.Create(&newTask)

			err = os.Remove("data/menu_" + task.CustomerID + ".zip")
			if err != nil {
				log.Errorf("Error deleting the zip file: %s", err.Error())
			}
			err = os.RemoveAll("data/menu_" + task.CustomerID)
			if err != nil {
				log.Errorf("Error deleting the directory: %s", err.Error())
			}
		} else {
			log.Infof("ImportMenuContentFromDir error: %+v", err)
		}
	}

	log.Info("Import menu task finished.")
}

func (w *Worker) generateVectors(db *gorm.DB, task models.MenuTask) {
	defer w.wg.Done() // Decrement counter when function exits

	log.Info("Generate vectors task started...")

	db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskRunning})
	err := utils.GenerateAllCustomerContentVectors(db, task.CustomerID)
	if err != nil {
		log.Errorf("Error in generating content vectors for customer %s: %s", task.CustomerID, err)
		db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskError, "message": err.Error()})
	} else {
		db.Model(&task).Updates(map[string]interface{}{"status": configs.TaskCompleted})
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
