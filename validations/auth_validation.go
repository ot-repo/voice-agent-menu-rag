package validations

type Register struct {
	CustomerID string `json:"customer_id" validate:"required,max=10" example:"123"`
	FirstName  string `json:"first_name" validate:"required,max=100" example:"fake first name"`
	LastName   string `json:"last_name" validate:"required,max=100" example:"fake last name"`
	Email      string `json:"email" validate:"required,email,max=255" example:"fake@example.com"`
	Password   string `json:"password" validate:"required,min=12,max=36,password" example:"password1"`
}

type Login struct {
	Email    string `json:"email" validate:"required,email,max=50" example:"fake@example.com"`
	Password string `json:"password" validate:"required,min=8,max=20,password" example:"password1"`
}

type GoogleLogin struct {
	Name          string `json:"name" validate:"required,max=50"`
	Email         string `json:"email" validate:"required,email,max=50"`
	VerifiedEmail bool   `json:"verified_email" validate:"required"`
}

type Logout struct {
	RefreshToken string `json:"refresh_token" validate:"required,max=255"`
}

type RefreshToken struct {
	RefreshToken string `json:"refresh_token" validate:"required,max=255"`
}

type ForgotPassword struct {
	Email string `json:"email" validate:"required,email,max=50" example:"fake@example.com"`
}

type Token struct {
	Token string `json:"token" validate:"required,max=255"`
}
