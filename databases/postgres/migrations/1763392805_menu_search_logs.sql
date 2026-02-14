-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_search_logs
(
    prompt_id INT NOT NULL REFERENCES menu_prompts(id),
    embeddings BOOLEAN NOT NULL DEFAULT false,
    match_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_menu_search_logs_prompt_id ON menu_search_logs(prompt_id) WHERE deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_search_logs;