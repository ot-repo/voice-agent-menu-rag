package configs

import (
	"errors"
	"rag-ai/responses"
	"rag-ai/validations"

	"github.com/bytedance/sonic"
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/template/html/v2"
)

func FiberConfig() fiber.Config {
	engine := html.New("./web/template", ".html")
	if !IsProd {
		engine.Reload(true)
	}

	return fiber.Config{
		CaseSensitive: true,
		ServerHeader:  "Fiber",
		AppName:       "Fiber API",
		ErrorHandler:  ErrorHandler,
		JSONEncoder:   sonic.Marshal,
		JSONDecoder:   sonic.Unmarshal,
		Views:         engine,
	}
}

func ErrorHandler(c fiber.Ctx, err error) error {
	if errorsMap := validations.CustomErrorMessages(err); len(errorsMap) > 0 {
		return responses.Error(c, fiber.StatusBadRequest, "Bad Request", errorsMap)
	}

	var fiberErr *fiber.Error
	if errors.As(err, &fiberErr) {
		return responses.Error(c, fiberErr.Code, fiberErr.Message, nil)
	}

	return responses.Error(c, fiber.StatusInternalServerError, "Internal Server Error", nil)
}

func NotFoundHandler(c fiber.Ctx) error {
	return responses.Error(c, fiber.StatusNotFound, "Endpoint Not Found", nil)
}
