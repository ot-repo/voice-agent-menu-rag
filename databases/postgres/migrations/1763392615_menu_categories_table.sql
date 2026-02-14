-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_categories
(
    category_id CHAR(36) UNIQUE NOT NULL,
    customer_id CHAR(36) NOT NULL REFERENCES clients(customer_id),
    name VARCHAR(255) NOT NULL,
    label VARCHAR NULL,
    category_merged VARCHAR GENERATED ALWAYS AS (name || ' ' || COALESCE(label, '') ) STORED,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

-- Add other indexes here
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_categories_customer_id_category_id_deleted_at ON menu_categories(customer_id, category_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_menu_categories_name_bm25 ON menu_categories USING bm25(name) WITH (text_config='german');
CREATE INDEX IF NOT EXISTS idx_menu_categories_label_bm25 ON menu_categories USING bm25(label) WITH (text_config='german');

--INSERT INTO menu_categories(category_id, customer_id, name) VALUES('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'Metadata');
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_categories;