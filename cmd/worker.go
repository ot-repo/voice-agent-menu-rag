package main

import (
	"context"
	"os"
	"os/signal"
	"rag-ai/configs"
	databases "rag-ai/databases/postgres"
	"rag-ai/models"
	"rag-ai/utils"
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

	// Start server and handle graceful shutdown
	workerErrors := make(chan error, 1)
	startWorker(db, ctx)
	handleWorkerGracefulShutdown(ctx, workerErrors)
}

func setupWorkerDatabase() *gorm.DB {
	db := databases.Connect(configs.DataBaseUrl)
	return db
}

func startWorker(db *gorm.DB, ctx context.Context) {
	log.Info("Worker started.......")
	for {
		processDatabaseQueue(db)
		time.Sleep(10 * time.Second)
	}
}

func processDatabaseQueue(db *gorm.DB) {
	pendingTasks := []models.MenuTask{}
	db.Find(&pendingTasks, "status=0 AND deleted_at IS NULL")

	for _, task := range pendingTasks {
		if task.Task == "import" {
			_, err := utils.DownLoadAndImportMenu(db, task.CustomerID)
			if err != nil {
				log.Errorf("Error in downloading and importing menu for customer %s: %s", task.CustomerID, err)
				db.Model(&task).Updates(map[string]interface{}{"status": 2, "message": err.Error()})
			} else {
				db.Model(&task).Updates(map[string]interface{}{"status": 1})
				// Import the menu content from the directory to the database.
				utils.ImportMenuContentFromDir(db, task.CustomerID, "data/menu_"+task.CustomerID)
				// After successful import, add a task to generate the content vectors for the customer.
				newTask := models.MenuTask{
					CustomerID: task.CustomerID,
					Task:       "vectors",
					Status:     0,
				}
				db.Create(&newTask)
			}
		}
		if task.Task == "vectors" {
			err := utils.GenerateAllCustomerContentVectors(db, task.CustomerID)
			if err != nil {
				log.Errorf("Error in generating content vectors for customer %s: %s", task.CustomerID, err)
				db.Model(&task).Updates(map[string]interface{}{"status": 2, "message": err.Error()})
			} else {
				db.Model(&task).Updates(map[string]interface{}{"status": 1})
			}
		}
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
