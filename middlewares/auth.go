package middlewares

import (
	"rag-ai/configs"
	"strings"

	"github.com/gofiber/fiber/v3"
)

func Auth() fiber.Handler {
	return func(c fiber.Ctx) error {
		authHeader := c.Get("X-API-ACCESS-KEY")
		apiKey := strings.TrimSpace(strings.TrimPrefix(authHeader, " "))

		if apiKey == "" && apiKey != configs.ApiAccessKey {
			return fiber.NewError(fiber.StatusUnauthorized, "Please authenticate")
		}

		return c.Next()
	}
}
