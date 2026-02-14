-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS clients
(
    id SERIAL PRIMARY KEY,
    customer_id CHAR(36) UNIQUE NOT NULL,
    title VARCHAR(255) UNIQUE NOT NULL,
    sso_settings JSONB NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP DEFAULT NULL
);

-- Add other indexes here
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_customer_id_deleted_at ON clients(customer_id) WHERE deleted_at IS NULL;

INSERT INTO clients(customer_id, title) VALUES('00000000-0000-0000-0000-000000000000','E-book company');
INSERT INTO clients(customer_id, title) VALUES('ee11ca2c-e9b5-4eeb-960c-fa334e0f06c1', 'Ferhat Restaurant');
INSERT INTO clients(customer_id, title) VALUES('d16b339d-dfc1-430a-9424-b30aedc20685', 'Sinan Restaurant');
INSERT INTO clients(customer_id, title) VALUES('67bd05ae-c462-4e22-883a-d851d552f965', 'Arslan Restaurant');

-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS clients;