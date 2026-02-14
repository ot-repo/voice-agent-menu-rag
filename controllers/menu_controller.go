package controllers

import (
	"rag-ai/responses"
	"rag-ai/services"
	"rag-ai/validations"

	"github.com/gofiber/fiber/v3"
)

type MenuController struct {
	MenuService services.MenuService
}

func NewMenuController(menuService services.MenuService) *MenuController {
	return &MenuController{
		MenuService: menuService,
	}
}

// @Tags         Menu
// @Summary      Get all documents
// @Description  Only admins can retrieve all documents.
// @Security BearerAuth
// @Produce      json
// @Param        page     query     int     false   "Page number"  default(1)
// @Param        limit    query     int     false   "Maximum number of documents"    default(10)
// @Param        search   query     string  false  "Search by title or subtitle or ISBN or publisher"
// @Router       /docs/search [post]
// @Success      200  {object}  example.GetAllUserResponse
// @Failure      401  {object}  example.Unauthorized  "Unauthorized"
// @Failure      403  {object}  example.Forbidden  "Forbidden"
func (m *MenuController) Search(c fiber.Ctx) error {
	//fmt.Printf("Request Body: %s\n", c.Body())
	//fmt.Printf("Content-Type: %s\n", c.Get("Content-Type"))
	req := new(validations.SearchMenu)

	if err := c.Bind().Body(req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid request body")
	}
	answer, err := m.MenuService.SearchMenu(c, req)
	if err != nil {
		return err
	}
	return c.Status(fiber.StatusOK).
		JSON(responses.Common{
			Code:    fiber.StatusOK,
			Status:  "success",
			Message: answer,
		})
}

// @Tags         Menu
// @Summary      Get all documents
// @Description  Only admins can retrieve all documents.
// @Security BearerAuth
// @Produce      json
// @Param        page     query     int     false   "Page number"  default(1)
// @Param        limit    query     int     false   "Maximum number of documents"    default(10)
// @Param        search   query     string  false  "Search by title or subtitle or ISBN or publisher"
// @Router       /docs/search [post]
// @Success      200  {object}  example.GetAllUserResponse
// @Failure      401  {object}  example.Unauthorized  "Unauthorized"
// @Failure      403  {object}  example.Forbidden  "Forbidden"
func (m *MenuController) Task(c fiber.Ctx) error {
	req := new(validations.TaskMenu)

	if err := c.Bind().Body(req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid request body")
	}
	answer, err := m.MenuService.TaskMenu(c, req)
	if err == nil {
		return c.Status(fiber.StatusOK).
			JSON(responses.Common{
				Code:    fiber.StatusOK,
				Status:  "success",
				Message: answer,
			})
	} else {
		return c.Status(fiber.StatusBadRequest).
			JSON(responses.Common{
				Code:    fiber.StatusOK,
				Status:  "error",
				Message: answer,
			})
	}

}

// @Tags         Menu
// @Summary      Get all documents
// @Description  Only admins can retrieve all documents.
// @Security BearerAuth
// @Produce      json
// @Param        page     query     int     false   "Page number"  default(1)
// @Param        limit    query     int     false   "Maximum number of documents"    default(10)
// @Param        search   query     string  false  "Search by title or subtitle or ISBN or publisher"
// @Router       /docs/search [post]
// @Success      200  {object}  example.GetAllUserResponse
// @Failure      401  {object}  example.Unauthorized  "Unauthorized"
// @Failure      403  {object}  example.Forbidden  "Forbidden"
func (m *MenuController) Enrich(c fiber.Ctx) error {
	req := new(validations.EnrichMenu)

	if err := c.Bind().Body(req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid request body")
	}
	answer, err := m.MenuService.EnrichMenu(c, req)
	if err != nil {
		return err
	}
	return c.Status(fiber.StatusOK).
		JSON(responses.Common{
			Code:    fiber.StatusOK,
			Status:  "success",
			Message: answer,
		})
}

// @Tags         Menus
// @Summary      Create a menu
// @Description  Only admins can create a document.
// @Security BearerAuth
// @Produce      json
// @Param        request  body  validations.CreateDocument  true  "Request body"
// @Router       /docs [post]
// @Success      201  {object}  example.CreateUserResponse
// @Failure      401  {object}  example.Unauthorized  "Unauthorized"
// @Failure      403  {object}  example.Forbidden  "Forbidden"
// @Failure      409  {object}  example.DuplicateEmail  "Email already taken"
func (m *MenuController) CreateMenu(c fiber.Ctx) error {
	req := new(validations.CreateMenuRecursive)

	if err := c.Bind().Body(req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid request body")
	}

	err := m.MenuService.CreateMenu(c, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).
			JSON(responses.ErrorDetails{
				Code:    fiber.StatusBadRequest,
				Status:  "failure",
				Message: "Menu canot be created",
				Errors:  err.Error(),
			})
	}

	return c.Status(fiber.StatusOK).
		JSON(responses.Common{
			Code:    fiber.StatusOK,
			Status:  "success",
			Message: "Menu created successfully, and embeddings are being generated in the background",
		})

	//return c.Render("partials/users/user-row", doc)

}
