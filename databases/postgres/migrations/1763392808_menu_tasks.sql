-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_tasks
(
    id SERIAL PRIMARY KEY,
    customer_id CHAR(36) NOT NULL REFERENCES clients(customer_id) ON DELETE CASCADE,
    task VARCHAR NOT NULL,
    status INT NOT NULL DEFAULT 0,  -- 0: pending, 1: running, 2: completed, 3: error, 4: canceled
    message VARCHAR NULL,   --If an error happens, the error message will be saved here.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_menu_tasks_customer_id ON menu_tasks(customer_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_menu_tasks_status ON menu_tasks(status) WHERE deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_tasks;