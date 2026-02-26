package configs

import (
	"github.com/gofiber/fiber/v3/log"
	"github.com/spf13/viper"
)

var (
	IsProd                 bool
	AppHost                string
	AppPort                int
	McpPort                int
	SsePort                int
	NatsUrl                string
	NatsCustomerMenuPrefix string
	ApiAccessKey           string

	DataBaseUrl       string
	MaxDbOpenConns    int
	MaxDbOpenConnsTtl int
	MaxDbIdleConns    int
	MaxDbIdleConnsTtl int

	OllamaKeepAlive       int
	OllamaApiUrl          string
	OllamaEmbeddingsModel string

	TeiApiUrl string

	EmbeddingsProvider string
	EmbeddingsFallback bool

	SmartKasseApiAuthToken       string
	SmartKasseApiMenuDownloadUrl string
)

func init() {
	loadConfig()

	// server configuration
	IsProd = viper.GetString("APP_ENV") == "prod"
	AppHost = viper.GetString("APP_HOST")
	AppPort = viper.GetInt("APP_PORT")
	McpPort = viper.GetInt("MCP_PORT")
	SsePort = viper.GetInt("SSE_PORT")

	// database configuration
	DataBaseUrl = viper.GetString("DATABASE_URL")

	MaxDbOpenConns = viper.GetInt("MAX_DB_OPEN_CONNS")
	MaxDbOpenConnsTtl = viper.GetInt("MAX_DB_OPEN_CONNS_TTL")
	MaxDbIdleConns = viper.GetInt("MAX_DB_IDLE_CONNS")
	MaxDbIdleConnsTtl = viper.GetInt("MAX_DB_IDLE_CONNS_TTL")

	// Nats configuration
	NatsUrl = viper.GetString("NATS_URL")
	NatsCustomerMenuPrefix = viper.GetString("NATS_CUSTOMER_MENU_PREFIX")

	ApiAccessKey = viper.GetString("API_ACCESS_KEY")

	//Ollama configuration
	OllamaKeepAlive = viper.GetInt("OLLAMA_KEEP_ALIVE")
	OllamaApiUrl = viper.GetString("OLLAMA_API_URL")
	OllamaEmbeddingsModel = viper.GetString("OLLAMA_EMBEDDINGS_MODEL")

	TeiApiUrl = viper.GetString("TEI_API_URL")

	EmbeddingsProvider = viper.GetString("EMBEDDINGS_PROVIDER")
	EmbeddingsFallback = viper.GetBool("EMBEDDINGS_FALLBACK")

	SmartKasseApiAuthToken = viper.GetString("SK_API_AUTH_TOKEN")
	SmartKasseApiMenuDownloadUrl = viper.GetString("SK_API_MENU_DOWNLOAD_URL")
}

func loadConfig() {
	configPaths := []string{
		"./",     // For app
		"../../", // For test folder
	}

	for _, path := range configPaths {
		viper.SetConfigFile(path + ".env")

		if err := viper.ReadInConfig(); err == nil {
			log.Infof("Config file loaded from %s", path)
			return
		}
	}

	log.Error("Failed to load any config file")
}
