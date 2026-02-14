package middlewares

import (
	"rag-ai/responses"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/limiter"
)

func LimiterConfig() fiber.Handler {
	return limiter.New(limiter.Config{
		Max:        20,
		Expiration: 15 * time.Minute,
		LimitReached: func(c fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).
				JSON(responses.Common{
					Code:    fiber.StatusTooManyRequests,
					Status:  "error",
					Message: "Too many requests, please try again later",
				})
		},
		SkipSuccessfulRequests: true,
	})
}
