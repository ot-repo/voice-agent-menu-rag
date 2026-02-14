package responses

import (
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/log"
)

func Error(c fiber.Ctx, statusCode int, message string, details interface{}) error {
	var errRes error
	if details != nil {
		errRes = c.Status(statusCode).JSON(ErrorDetails{
			Code:    statusCode,
			Status:  "error",
			Message: message,
			Errors:  details,
		})
	} else {
		errRes = c.Status(statusCode).JSON(Common{
			Code:    statusCode,
			Status:  "error",
			Message: message,
		})
	}

	if errRes != nil {
		log.Errorf("Failed to send error response : %+v", errRes)
	}

	return errRes
}
