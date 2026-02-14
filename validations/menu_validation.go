package validations

type CreateMenu struct {
	CustomerID string `json:"customer_id" validate:"required,min=36,max=36" example:"e1e1e1e1-a1a1-b1b1-f9f9-abcdef987654"`
	FilePath   string `json:"file_path" validate:"required,max=255" example:"fake title"`
}

type CreateMenuRecursive struct {
	CustomerID string `json:"customer_id" validate:"required,min=36,max=36" example:"e1e1e1e1-a1a1-b1b1-f9f9-abcdef987654"`
	DirPath    string `json:"dir_path" validate:"required,max=255" example:"fake title"`
}

type SearchMenu struct {
	CustomerID string `json:"customer_id" validate:"required,min=36,max=36" jsonschema:"description=The customer id that owns the knowledge base."`
	Prompt     string `json:"prompt" validate:"required,min=3,max=500" jsonschema:"description=The search query supplied by the user"`
}

type EnrichMenu struct {
	CustomerID string `json:"customer_id" validate:"required,min=36,max=36"`
	Type       string `json:"type" validate:"required,oneof=category product all,max=10"`
	Group      string `json:"group" validate:"required,oneof=common self all,max=10"`
}

type TaskMenu struct {
	CustomerID string `json:"customer_id" validate:"required,min=36,max=36"`
	Task       string `json:"task" validate:"required,oneof=import delete,max=10"`
}
