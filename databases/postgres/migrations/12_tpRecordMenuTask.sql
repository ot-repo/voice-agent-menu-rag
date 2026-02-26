-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordMenuTask;
CREATE TYPE tpRecordMenuTask AS (id INTEGER, client_id INTEGER, task VARCHAR, status INTEGER, message VARCHAR);
-- +goose StatementEnd

-- +goose Down
DROP TYPE IF EXISTS tpRecordMenuTask;