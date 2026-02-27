package services

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"rag-ai/models"
	"rag-ai/utils"
	"rag-ai/validations"
	"strings"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/log"

	"gorm.io/gorm"
)

var (
	FALSE = false
	TRUE  = true
)

type MenuService interface {
	SearchMenu(c fiber.Ctx, params *validations.SearchMenu) (string, error)
	TaskMenu(c fiber.Ctx, params *validations.TaskMenu) (string, error)
	EnrichMenu(c fiber.Ctx, params *validations.EnrichMenu) (string, error)
	CreateMenu(c fiber.Ctx, req *validations.CreateMenuRecursive) error
}

type menuService struct {
	DB       *gorm.DB
	Validate *validator.Validate
}

func NewMenuService(db *gorm.DB, validate *validator.Validate) MenuService {
	return &menuService{
		DB:       db,
		Validate: validate,
	}
}

func (s *menuService) CreateMenu(c fiber.Ctx, params *validations.CreateMenuRecursive) error {

	var productName string
	var productId string
	var productCategory string
	if err := s.Validate.Struct(params); err != nil {
		return err
	}

	client_id := utils.GetClientId(params.CustomerID)
	// Walk through the directory
	files, err := os.ReadDir(params.DirPath)
	if err != nil {
		log.Error(err.Error())
		return err
	}

	for _, v := range files {
		if v.IsDir() {
			continue
		}

		// Check if the file is a markdown file
		if strings.HasSuffix(v.Name(), ".md") {
			fileContents, err := os.ReadFile(params.DirPath + "/" + v.Name())
			if err != nil {
				return err
			}
			scanner := bufio.NewScanner(strings.NewReader(string(fileContents)))
			i := 0

			for scanner.Scan() {
				if i > 3 {
					break
				}
				if i == 0 {
					productName = strings.TrimLeft(scanner.Text(), "# ")
				} else if i == 1 {
					productId = strings.TrimLeft(scanner.Text(), "ProductId: ")
				} else if i == 2 {
					productCategory = strings.TrimLeft(scanner.Text(), "Category: ")
				}
				i++
			}
			s.DB.Exec("INSERT INTO menu_contents(client_id, file_name, product_name, product_id, product_category, content) VALUES(?, ?, ?, ?, ?, ?);", client_id, v.Name(), productName, productId, productCategory, string(fileContents))
		}
	}
	// Update the words table
	s.DB.Exec("SELECT * FROM spAI_Save_Menu_Content_Words(?);", client_id)
	// err = utils.PublishNatsMessage(configs.NatsCustomerMenuPrefix+"."+params.CustomerID, "GenerateAllCustomerContentVectors")
	// if err != nil {
	// 	log.Errorf("Cannnot publish to the subject: %s", configs.NatsCustomerMenuPrefix+"."+params.CustomerID)
	// }

	return nil
}

func (s *menuService) TaskMenu(c fiber.Ctx, params *validations.TaskMenu) (string, error) {
	var result models.SaveResult

	if err := s.Validate.Struct(params); err != nil {
		return "", err
	}
	sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Save_Menu_Task('%s','%s')", params.CustomerID, params.Task)
	s.DB.Raw(sqlQuery).Scan(&result)

	if result.Code == 0 {
		return result.Message, nil
	} else {
		return result.Message, errors.New("Task could not be created")
	}
}

func (s *menuService) SearchMenu(c fiber.Ctx, params *validations.SearchMenu) (string, error) {

	if err := s.Validate.Struct(params); err != nil {
		return "", err
	}
	client_id := utils.GetClientId(params.CustomerID)
	return utils.QueryCorpus(s.DB, client_id, params.Prompt, "API"), nil
}

func (s *menuService) EnrichMenu(c fiber.Ctx, params *validations.EnrichMenu) (string, error) {
	var result models.SaveResult

	if err := s.Validate.Struct(params); err != nil {
		return "", err
	}
	client_id := utils.GetClientId(params.CustomerID)
	sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Save_Menu_Enrichment(%d,'%s','%s')", client_id, params.Type, params.Group)
	log.Info(sqlQuery)
	s.DB.Raw(sqlQuery).Scan(&result)
	log.Infof("%+v", result)

	return result.Message, nil

}
