package validations

type NatsMessage struct {
	Subject string `validate:"required,min=51" example:"customer-menus:e1e1e1e1-a1a1-b1b1-f9f9-abcdef987654"`
	Data    string `validate:"required,min:3" example:"Generate vectors"`
}
