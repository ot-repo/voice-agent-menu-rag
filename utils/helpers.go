package utils

import (
	"archive/zip"
	"bufio"
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path"
	"strconv"
	"strings"
	"time"

	"rag-ai/configs"
	"rag-ai/models"

	"github.com/gofiber/fiber/v3/log"
	"github.com/nats-io/nats.go"
	"gorm.io/gorm"

	"github.com/ollama/ollama/api"
	ollama "github.com/ollama/ollama/api"
)

func StringToUint(s string) uint {
	i, _ := strconv.Atoi(s)
	return uint(i)
}

func Addslashes(str string) string {
	var buf bytes.Buffer
	for _, char := range str {
		switch char {
		case '\'', '"', '\\':
			buf.WriteRune('\\')
		}
		buf.WriteRune(char)
	}
	return buf.String()
}

func GetEmbeddingsVector(ctx context.Context, client *api.Client, doc string) ([]float64, error) {

	req := &ollama.EmbeddingRequest{
		Model:     configs.OllamaEmbeddingsModel,
		Prompt:    doc,
		KeepAlive: &ollama.Duration{Duration: time.Duration(configs.OllamaKeepAlive) * time.Second},
	}
	// get embeddings
	resp, err := client.Embeddings(ctx, req)
	if err != nil {
		log.Info("😡:", err)
		return nil, err
	}
	return resp.Embedding, nil
}

func GenerateAllCustomerContentVectors(db *gorm.DB, customerId string) error {

	type Content struct {
		Id      int    `db:"id"`
		Content string `db:"content"`
	}

	log.Infof("Called GenerateAllCustomerContentVectors for customer: %s", customerId)
	ctx := context.Background()
	ollamaApiUrl, _ := url.Parse(configs.OllamaApiUrl)
	client := ollama.NewClient(ollamaApiUrl, http.DefaultClient)

	contents := []Content{}
	db.Raw("SELECT id, content FROM menu_contents WHERE customer_id = ?", customerId).Scan(&contents)
	for _, content := range contents {
		embeddingForContent, err := GetEmbeddingsVector(ctx, client, content.Content)
		if err != nil {
			log.Errorf("Error in creating the embeddings for content id %d: %s", content.Id, err)
			continue
		}
		vectorString := fmt.Sprintf("[%s]", strings.Trim(strings.Replace(fmt.Sprint(embeddingForContent), " ", ",", -1), "[]"))
		db.Exec("UPDATE menu_contents SET content_vector = ?, updated_at=NOW() WHERE id = ?", vectorString, content.Id)
	}
	return nil
}

func ImportMenuContentFromDir(db *gorm.DB, customerId string, dirPath string) error {

	var productName string
	var productId string
	var productCategory string
	//var sqlQuery string
	var contentMenus []*models.MenuContent

	// Walk through the directory
	files, err := os.ReadDir(dirPath)
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
			fileContents, err := os.ReadFile(dirPath + "/" + v.Name())
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
			contentMenus = append(contentMenus, &models.MenuContent{
				CustomerID:      customerId,
				FileName:        v.Name(),
				ProductName:     productName,
				ProductID:       productId,
				ProductCategory: productCategory,
				Content:         string(fileContents),
			})
			//sqlQuery += fmt.Sprintf(`INSERT INTO menu_contents(customer_id, file_name, product_name, product_id, product_category, content) VALUES('%s', '%s', '%s', '%s', '%s', '%s');`, customerId, v.Name(), productName, productId, productCategory, string(fileContents))
		}
	}
	if len(contentMenus) > 0 {
		db.Exec("DELETE FROM menu_prompts WHERE customer_id = ?", customerId)
		db.Exec("DELETE FROM menu_contents WHERE customer_id = ?", customerId)
		result := db.Create(contentMenus)
		if result.Error != nil {
			log.Errorf("Error in inserting menu content for customer %s: %s", customerId, result.Error)
			return result.Error
		} else {
			// Update the words table
			db.Exec("SELECT * FROM spAI_Save_Menu_Content_Words(?);", customerId)
		}
	}
	return nil
}
func DownLoadAndImportMenu(db *gorm.DB, customerId string) (string, error) {

	// Download menu
	menuUrl := fmt.Sprintf(configs.SmartKasseApiMenuDownloadUrl, customerId)
	req, err := http.NewRequest("GET", menuUrl, nil)
	if err != nil {
		log.Errorf("Error creating request to download menu for customer %s: %s", customerId, err)
		return "", err
	}

	req.Header.Add("Authorization", "Bearer "+configs.SmartKasseApiAuthToken)
	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil {
		log.Errorf("Error downloading menu for customer %s: %s", customerId, err)
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Errorf("Non-OK HTTP status when downloading menu for customer %s: %s", customerId, resp.Status)
		return "", errors.New("Failed to download menu, status: " + resp.Status)
	}

	menuData, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Errorf("Error reading menu response body for customer %s: %s", customerId, err)
		return "", err
	}

	// Create the file
	zipFile := "data/menu_" + customerId + ".zip"
	out, err := os.Create(zipFile)
	if err != nil {
		return "", err
	}
	defer out.Close()

	// Write menu data to the file
	_, err = out.Write(menuData)
	if err != nil {
		return "", err
	}

	err = unzip(zipFile, "data/menu_"+customerId)
	if err != nil {
		log.Errorf("Error unzipping menu for customer %s: %s", customerId, err)
		return "", err
	}
	os.Remove(zipFile)
	return "Menu downloaded and imported successfully", nil
}

func unzip(source, dest string) error {
	read, err := zip.OpenReader(source)
	if err != nil {
		return err
	}
	defer read.Close()

	for _, file := range read.File {
		// Skip directories explicitly if they are in the zip manifest
		// Note: We usually rely on MkdirAll for the structure, but checking here prevents double work.
		if file.Mode().IsDir() {
			// You can create the directory here as well to respect zip folder permissions
			name := path.Join(dest, file.Name)
			os.MkdirAll(name, file.Mode())
			continue
		}

		open, err := file.Open()
		if err != nil {
			return err
		}

		name := path.Join(dest, file.Name)

		// FIX: Use 0755 (or your preferred permission) instead of os.ModeDir
		// Ensure the parent directory exists
		if err := os.MkdirAll(path.Dir(name), 0755); err != nil {
			open.Close()
			return err
		}

		// Use OpenFile instead of Create to preserve the executable/file permissions from the zip
		create, err := os.OpenFile(name, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, file.Mode())
		if err != nil {
			open.Close()
			return err
		}

		// Copy the content
		_, err = io.Copy(create, open)

		// Close resources immediately inside the loop.
		// Deferring inside a loop causes resource leaks until the function ends.
		create.Close()
		open.Close()

		if err != nil {
			return err
		}
	}
	return nil
}

func QueryCorpus(db *gorm.DB, customerId string, query string, serverType string) string {

	var result models.PromptResult
	startTime := time.Now()

	log.Infof("%s Menu search started at %s", serverType, startTime.Format(time.RFC3339))

	// Perform a BM25 search first, and if no results then fallback to the mebeddings.
	sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Get_Menu_Items('%s','%s','%s')", customerId, strings.Replace(query, `'`, `''`, -1), "[]")
	log.Info(sqlQuery)
	log.Infof("Procedure took took %s", time.Since(startTime))
	db.Raw(sqlQuery).Scan(&result)
	log.Infof("%+v", result)
	if result.Counter > 0 {
		return result.Content
	} else {

		ctx := context.Background()

		ollamaApiUrl, _ := url.Parse(configs.OllamaApiUrl)
		client := ollama.NewClient(ollamaApiUrl, http.DefaultClient)

		embeddingForContent, err := GetEmbeddingsVector(ctx, client, query)
		if err != nil {
			log.Errorf("Error in creating the embeddings: %s", err)
		}
		vectorString := fmt.Sprintf("[%s]", strings.Trim(strings.Replace(fmt.Sprint(embeddingForContent), " ", ",", -1), "[]"))
		log.Infof("Ollama embeddings creation took %s", time.Since(startTime))
		startTime = time.Now()
		sqlQuery := fmt.Sprintf("SELECT * FROM spAI_Get_Menu_Items('%s','%s','%s')", customerId, strings.Replace(query, `'`, `''`, -1), vectorString)
		log.Info(sqlQuery)
		log.Infof("Procedure took took %s", time.Since(startTime))
		db.Raw(sqlQuery).Scan(&result)
		log.Infof("%+v", result)
		return result.Content
	}
}

func PublishNatsMessage(subject, data string) error {
	nc, err := nats.Connect(configs.NatsUrl)
	if err != nil {
		log.Fatalf("Error connecting to NATS for publishing: %v", err)
	}
	defer nc.Close()
	log.Infof("Connected to NATS server for publishing: %s", configs.NatsUrl)

	// Publish message to NATS
	if err := nc.Publish(subject, []byte(data)); err != nil {
		return errors.New("Failed to publish to the subject: " + subject)
	}
	return nil
}
