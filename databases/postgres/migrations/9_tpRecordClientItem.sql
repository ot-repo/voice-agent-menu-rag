-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordClientItem;
CREATE TYPE tpRecordClientItem AS (id INTEGER, customer_id VARCHAR);
-- +goose StatementEnd

-- +goose Down
DROP TYPE IF EXISTS tpRecordClientItem;