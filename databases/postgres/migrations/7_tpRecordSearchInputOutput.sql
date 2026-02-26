-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordSearchInputOutput;
CREATE TYPE tpRecordSearchInputOutput AS (counter INTEGER, content VARCHAR, answer VARCHAR);
-- +goose StatementEnd

-- +goose Down
DROP TYPE IF EXISTS tpRecordSearchInputOutput;