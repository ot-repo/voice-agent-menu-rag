package middlewares

import (
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/logger"
)

func LoggerConfig() fiber.Handler {
	return logger.New(logger.Config{
		Format:     "${time} ${method} ${status} ${path} in ${latency}\n",
		TimeFormat: "15:04:05.00",
	})
}
