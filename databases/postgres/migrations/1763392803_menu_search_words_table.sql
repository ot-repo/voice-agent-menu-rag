-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_search_words
(
    customer_id CHAR(36) NOT NULL REFERENCES clients(customer_id) ON DELETE CASCADE,
    word VARCHAR NOT NULL
);

CREATE INDEX menu_search_customer_id_word_idx ON menu_search_words USING GIN (customer_id, word gin_trgm_ops);
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_search_words;