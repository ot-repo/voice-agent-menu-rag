-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordSaveResult;
CREATE TYPE tpRecordSaveResult AS (value int4, message varchar);
-- +goose StatementEnd

-- +goose Down
DROP TYPE tpRecordSaveResult;