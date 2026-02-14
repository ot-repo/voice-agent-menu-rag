package tests

import (
	database "rag-ai/databases/postgres"
	router "rag-ai/routes"
	"rag-ai/utils"

	"github.com/gofiber/fiber/v3"
	"gorm.io/gorm"
)

var App = fiber.New(fiber.Config{
	CaseSensitive: true,
	ErrorHandler:  utils.ErrorHandler,
})
var DB *gorm.DB

func init() {
	// TODO: You can modify host and database configuration for tests
	DB = database.Connect("localhost", "testdb")
	router.Routes(App, DB)
	App.Use(utils.NotFoundHandler)
}
