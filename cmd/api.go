package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"rag-ai/configs"
	databases "rag-ai/databases/postgres"
	"rag-ai/middlewares"
	"rag-ai/routes"
	"rag-ai/utils"
	"syscall"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/log"
	"github.com/gofiber/fiber/v3/middleware/compress"
	"github.com/gofiber/fiber/v3/middleware/cors"
	"github.com/gofiber/fiber/v3/middleware/helmet"
	"github.com/robfig/cron/v3"
	"gorm.io/gorm"
)

// @title go-fiber-boilerplate API documentation
// @version 1.0.0
// @license.name MIT
// @license.url https://github.com/indrayyana/go-fiber-boilerplate/blob/main/LICENSE
// @host localhost:3000
// @BasePath /v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Example Value: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	app := setupAPIFiberApp()
	db := setupAPIDatabase()
	defer closeAPIDatabase(db)
	setupAPIRoutes(app, db)

	//Register the cronjob to get the clients every minute
	getClients(db)
	c := cron.New()
	c.AddFunc("@every 1m", func() { getClients(db) })
	c.Start()

	apiAddress := fmt.Sprintf("%s:%d", configs.AppHost, configs.AppPort)

	// Start server and handle graceful shutdown
	serverErrors := make(chan error, 1)
	go startAPIServer(app, apiAddress, serverErrors)
	handleAPIGracefulShutdown(ctx, app, serverErrors)
}

func getClients(db *gorm.DB) {
	sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Get_Clients()")
	db.Raw(sqlQuery).Scan(&utils.RagClients)
}

func setupAPIFiberApp() *fiber.App {
	app := fiber.New(configs.FiberConfig())

	// middlewares setup
	app.Use(middlewares.Auth())
	app.Use(middlewares.LoggerConfig())
	app.Use(helmet.New())
	app.Use(compress.New())
	app.Use(cors.New())
	app.Use(middlewares.RecoverConfig())

	return app
}

func setupAPIDatabase() *gorm.DB {
	db := databases.Connect(configs.DataBaseUrl)
	return db
}

func setupAPIRoutes(app *fiber.App, db *gorm.DB) {
	routes.Routes(app, db)
	app.Use(utils.NotFoundHandler)
}

func startAPIServer(app *fiber.App, address string, errs chan<- error) {
	fmt.Printf("Starting API server on %s\n", address)
	if err := app.Listen(address, fiber.ListenConfig{EnablePrefork: configs.IsProd}); err != nil {
		errs <- fmt.Errorf("Error starting HTTP server: %w", err)
	}
}

func closeAPIDatabase(db *gorm.DB) {
	sqlDB, errDB := db.DB()
	if errDB != nil {
		log.Errorf("Error getting databases instance: %v", errDB)
		return
	}

	if err := sqlDB.Close(); err != nil {
		log.Errorf("Error closing databases connection: %v", err)
	} else {
		log.Info("databases connection closed successfully")
	}
}

func handleAPIGracefulShutdown(ctx context.Context, app *fiber.App, serverErrors <-chan error) {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-serverErrors:
		log.Fatalf("API Server error: %v", err)
	case <-quit:
		log.Info("Shutting down API server...")
		if err := app.Shutdown(); err != nil {
			log.Fatalf("Error during API server shutdown: %v", err)
		}
	case <-ctx.Done():
		log.Info("API Server exiting due to context cancellation")
	}

	log.Info("API Server exited")
}
