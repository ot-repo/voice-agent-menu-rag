package routes

import (
	controller "rag-ai/controllers"
	service "rag-ai/services"

	"github.com/gofiber/fiber/v3"
)

func HealthCheckRoutes(v1 fiber.Router, h service.HealthCheckService) {
	healthCheckController := controller.NewHealthCheckController(h)

	healthCheck := v1.Group("/health-check")
	healthCheck.Get("/", healthCheckController.Check)
}
