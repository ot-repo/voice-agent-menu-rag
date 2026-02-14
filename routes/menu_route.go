package routes

import (
	controller "rag-ai/controllers"
	"rag-ai/services"

	"github.com/gofiber/fiber/v3"
)

func MenuRoutes(v1 fiber.Router, d services.MenuService) {
	menuController := controller.NewMenuController(d)

	doc := v1.Group("/menus")

	doc.Post("/", menuController.CreateMenu)
	doc.Post("/search", menuController.Search)
	doc.Post("/enrich", menuController.Enrich)
	doc.Post("/task", menuController.Task)

}
