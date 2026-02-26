-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_searches
(
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    prompt_id INT NOT NULL REFERENCES menu_prompts(id) ON DELETE CASCADE,
    client_id INT NOT NULL,
    content_id INT NOT NULL,
    product_name_bm25 NUMERIC(10, 7) NOT NULL,
    product_id_bm25 NUMERIC(10, 7) NOT NULL,
    product_category_bm25 NUMERIC(10, 7) NOT NULL,
    total_bm25 NUMERIC(12, 7) NOT NULL,
    similarity NUMERIC(17,16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL,
    FOREIGN KEY (content_id, client_id) REFERENCES menu_contents(id, client_id)
);
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_searches;