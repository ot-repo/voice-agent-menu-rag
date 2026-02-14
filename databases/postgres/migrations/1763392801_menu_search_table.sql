-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_searches
(
    id SERIAL PRIMARY KEY,
    prompt_id INT NOT NULL REFERENCES menu_prompts(id) ON DELETE CASCADE,
    content_id INT NOT NULL REFERENCES menu_contents(id) ON DELETE CASCADE,
    product_name_bm25 NUMERIC(10, 7) NOT NULL,
    product_id_bm25 NUMERIC(10, 7) NOT NULL,
    product_category_bm25 NUMERIC(10, 7) NOT NULL,
    total_bm25 NUMERIC(12, 7) NOT NULL,
    similarity NUMERIC(17,16) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_searches;