-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS menu_tasks
(
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    client_id INT NOT NULL REFERENCES clients(id),
    task VARCHAR NOT NULL,
    status INT NOT NULL DEFAULT 0,  -- 0: pending, 1: running, 2: completed, 3: error, 4: cancel
    message VARCHAR NULL,   --If an error happens, the error message will be saved here.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_menu_tasks_client_id ON menu_tasks(client_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_menu_tasks_status ON menu_tasks(status) WHERE deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS menu_tasks;