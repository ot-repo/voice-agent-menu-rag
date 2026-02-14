package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"rag-ai/configs"
	databases "rag-ai/databases/postgres"
	"rag-ai/middlewares"
	"rag-ai/routes"
	"rag-ai/utils"
	"rag-ai/validations"
	"syscall"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/log"
	"github.com/gofiber/fiber/v3/middleware/compress"
	"github.com/gofiber/fiber/v3/middleware/cors"
	"github.com/gofiber/fiber/v3/middleware/helmet"
	"gorm.io/gorm"

	mcp "github.com/mark3labs/mcp-go/mcp"
	mcp_server "github.com/mark3labs/mcp-go/server"
	mcp_golang "github.com/metoro-io/mcp-golang"
	mcp_http "github.com/metoro-io/mcp-golang/transport/http"
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

	app := setupMcpFiberApp()
	db := setupMcpDatabase()
	defer closeMcpDatabase(db)
	setupMcpRoutes(app, db)

	mcpAddress := fmt.Sprintf("%s:%d", configs.AppHost, configs.McpPort)
	sseAddress := fmt.Sprintf("%s:%d", configs.AppHost, configs.SsePort)

	serverMcpErrors := make(chan error, 1)
	serverSseErrors := make(chan error, 1)
	go startMcpServer(db, mcpAddress, serverMcpErrors)
	go startSseServer(db, sseAddress, serverSseErrors)
	handleMcpGracefulShutdown(ctx, app, serverMcpErrors)
}

func setupMcpFiberApp() *fiber.App {
	app := fiber.New(configs.FiberConfig())

	app.Use(middlewares.LoggerConfig())
	app.Use(helmet.New())
	app.Use(compress.New())
	app.Use(cors.New())
	app.Use(middlewares.RecoverConfig())

	return app
}

func setupMcpDatabase() *gorm.DB {
	db := databases.Connect(configs.DataBaseUrl)
	return db
}

func setupMcpRoutes(app *fiber.App, db *gorm.DB) {
	routes.Routes(app, db)
	app.Use(utils.NotFoundHandler)
}

func startMcpServer(db *gorm.DB, address string, errs chan<- error) {
	transport := mcp_http.NewHTTPTransport("/mcp").WithAddr(address)
	server := mcp_golang.NewServer(
		transport,
		mcp_golang.WithName("mcp-knowledge-base-http"),
		mcp_golang.WithInstructions("Search and retrieve relevant context from a knowledge base, based on the user's query."),
		mcp_golang.WithVersion("0.0.1"),
	)

	// Register queryCorpus to tool for RAG
	err := server.RegisterTool("queryCorpus", "Food ingredients, cost, extra variations  content that can be used by the LLM to answer the query.", func(args *validations.SearchMenu) (*mcp_golang.ToolResponse, error) {
		return mcp_golang.NewToolResponse(mcp_golang.NewTextContent(utils.QueryCorpus(db, args.CustomerID, args.Prompt, "MCP"))), nil
	})

	// Register multiple prompts, we will retrive them from the DB and we can assign each client their own prompt later.
	// Then this feat would not be a prompt but a tool?
	greetings := map[string]string{"english": "Hi, I'm here to help you manage your order. What would you like to order today?", "german": "Hallo, ich helfe Ihnen gerne bei Ihrer Bestellung. Was möchten Sie heute bestellen?", "turkish": "Merhaba, siparişinizi yönetmenize yardımcı olmak için buradayım. Bugün ne sipariş etmek istersiniz?"}

	// No arguments so supplied empty struct for the the handler
	for key, value := range greetings {
		err = server.RegisterPrompt(key+"-greeting", "Greeting the customer in "+key, func(args validations.Language) (*mcp_golang.PromptResponse, error) {
			return mcp_golang.NewPromptResponse("Greeting the customer in "+key, mcp_golang.NewPromptMessage(mcp_golang.NewTextContent(value), mcp_golang.RoleUser)), nil
		})
		if err != nil {
			panic(err)
		}
	}

	if err != nil {
		errs <- fmt.Errorf("Error starting MCP server in HTTP mode: %w", err)
	}

	// Start the server
	fmt.Printf("Starting MCP server in HTTP mode on %s\n", address)
	server.Serve()
}

func startSseServer(db *gorm.DB, address string, errs chan<- error) {
	mcpServer := mcp_server.NewMCPServer("mcp-knowledge-sse", "1.0.0")
	// Register queryCorpus to tool for RAG
	queryCorpusTool := mcp.NewTool("queryCorpus",
		mcp.WithDescription("Food ingredients, cost, extra variations  content that can be used by the LLM to answer the query"),
		mcp.WithNumber("client_id",
			mcp.Required(),
			mcp.Description("The Client ID of the user requesting the query"),
		),
		mcp.WithString("prompt",
			mcp.Required(),
			mcp.Description("The prompt or query from the LLM"),
		),
	)
	mcpServer.AddTool(queryCorpusTool, func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		customer_id, err := req.RequireString("customer_id")
		if err != nil {
			return mcp.NewToolResultError(err.Error()), nil
		}
		prompt, err := req.RequireString("prompt")
		if err != nil {
			return mcp.NewToolResultError(err.Error()), nil
		}
		return mcp.NewToolResultText(utils.QueryCorpus(db, customer_id, prompt, "SSE")), nil
	})

	// Use a dynamic base path based on a path parameter (Go 1.22+)
	sseServer := mcp_server.NewSSEServer(
		mcpServer,
		mcp_server.WithBaseURL(address),
		mcp_server.WithUseFullURLForMessageEndpoint(true),
	)

	mux := http.NewServeMux()
	mux.Handle("/sse", sseServer.SSEHandler())
	mux.Handle("/message", sseServer.MessageHandler())

	fmt.Printf("Starting MCP server in SSE mode on %s\n", address)

	if err := http.ListenAndServe(address, mux); err != nil {
		errs <- fmt.Errorf("Error starting MCP server in SSE mode: %w", err)
	}

}

func closeMcpDatabase(db *gorm.DB) {
	sqlDB, errDB := db.DB()
	if errDB != nil {
		log.Errorf("Error getting MCP databases instance: %v", errDB)
		return
	}

	if err := sqlDB.Close(); err != nil {
		log.Errorf("Error closing MCP databases connection: %v", err)
	} else {
		log.Info("MCP databases connection closed successfully")
	}
}

func handleMcpGracefulShutdown(ctx context.Context, app *fiber.App, serverErrors <-chan error) {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-serverErrors:
		log.Fatalf("MCP Server error: %v", err)
	case <-quit:
		log.Info("Shutting down MCP server...")
		if err := app.Shutdown(); err != nil {
			log.Fatalf("Error during MCP server shutdown: %v", err)
		}
	case <-ctx.Done():
		log.Info("MCP Server exiting due to context cancellation")
	}

	log.Info("MCP Server exited")
}

func handleSseGracefulShutdown(ctx context.Context, app *fiber.App, serverErrors <-chan error) {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-serverErrors:
		log.Fatalf("SSE server error: %v", err)
	case <-quit:
		log.Info("Shutting down SSE server...")
		if err := app.Shutdown(); err != nil {
			log.Fatalf("Error during SSE server shutdown: %v", err)
		}
	case <-ctx.Done():
		log.Info("SSE Server exiting due to context cancellation")
	}

	log.Info("SSE Server exited")
}
