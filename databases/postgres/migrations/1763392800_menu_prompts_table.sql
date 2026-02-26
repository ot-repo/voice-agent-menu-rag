-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_prompts
(
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    client_id INT NOT NULL REFERENCES clients(id),
    embeddings BOOLEAN NOT NULL DEFAULT false,
    original_prompt VARCHAR NOT NULL,
    modified_prompt VARCHAR NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_prompts;