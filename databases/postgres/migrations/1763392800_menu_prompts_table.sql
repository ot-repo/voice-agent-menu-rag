-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_prompts
(
    id SERIAL PRIMARY KEY,
    customer_id CHAR(36) NOT NULL REFERENCES clients(customer_id),
    embeddings BOOLEAN NOT NULL DEFAULT false,
    original_prompt VARCHAR NOT NULL,
    modified_prompt VARCHAR NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_prompts;