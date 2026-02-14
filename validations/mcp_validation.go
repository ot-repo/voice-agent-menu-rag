package validations

type Language struct {
	Language string `json:"language" jsonschema:"description=The English name of the language" example:"German"`
}
