-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_contents
(
    id SERIAL PRIMARY KEY,
    customer_id CHAR(36) NOT NULL REFERENCES clients(customer_id) ON DELETE CASCADE,
    file_name VARCHAR NOT NULL,
    product_name VARCHAR NOT NULL,
    product_id VARCHAR NOT NULL,
    product_category VARCHAR NOT NULL,
    content VARCHAR NOT NULL,
    --896 for qwen2.5:0.5b; 2560 for qwen3:4b, 768 for embeddinggemma & nomic-embed-text & snowflake-arctic-embed:137m;
    --384 for snowflake-arctic-embed:33m; 1024 for snowflake-arctic-embed:335m
    content_vector VECTOR(768) NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);
-- We cannot create an index on the vectors and customer_id becuase BTREE, HNSW, and IVFFlat do not work on both
-- customer_id and content_vectors. The only viable solution is to create a partition for each customer bot this
-- will create its own issue like thousands of tables. We will rely on the index on customer_id only
CREATE INDEX IF NOT EXISTS menu_contents_customer_id_file_name ON menu_contents USING BTREE(customer_id, file_name) WHERE deleted_at IS NULL;

-- The BM25 indexes.
CREATE INDEX IF NOT EXISTS idx_menu_contents_product_name_bm25 ON menu_contents USING bm25(product_name) WITH (text_config='german', k1=1.2, b=0.75);
CREATE INDEX IF NOT EXISTS idx_menu_contents_product_id_bm25 ON menu_contents USING bm25(product_id) WITH (text_config='german', k1=1.2, b=0.75);
CREATE INDEX IF NOT EXISTS idx_menu_contents_product_category_bm25 ON menu_contents USING bm25(product_category) WITH (text_config='german', k1=1.2, b=0.75);

-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_contents;