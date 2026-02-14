-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordMenuItem;
CREATE TYPE tpRecordMenuItem AS (similarity NUMERIC(17, 16), content VARCHAR);
-- +goose StatementEnd

-- +goose Down
DROP TYPE IF EXISTS tpRecordMenuItem;