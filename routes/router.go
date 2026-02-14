package routes

import (
	service "rag-ai/services"
	validation "rag-ai/validations"

	"github.com/gofiber/fiber/v3"
	"gorm.io/gorm"
)

func Routes(app *fiber.App, db *gorm.DB) {
	validate := validation.Validator()

	healthCheckService := service.NewHealthCheckService(db)
	menuService := service.NewMenuService(db, validate)

	v1 := app.Group("/v1")

	HealthCheckRoutes(v1, healthCheckService)
	MenuRoutes(v1, menuService)

}
