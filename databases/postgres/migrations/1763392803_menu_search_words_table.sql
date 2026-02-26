-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_search_words
(
    client_id INT NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    word VARCHAR NOT NULL
);

CREATE INDEX menu_search_client_id_word_idx ON menu_search_words USING GIN (client_id, word gin_trgm_ops);
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_search_words;