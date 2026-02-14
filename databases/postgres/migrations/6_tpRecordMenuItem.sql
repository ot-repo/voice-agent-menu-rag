-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordMenuItem;
CREATE TYPE tpRecordMenuItem AS (similarity_brief NUMERIC(17, 16), similarity_full NUMERIC(17, 16), content_brief VARCHAR, content_full VARCHAR);
-- +goose StatementEnd

-- +goose Down
DROP TYPE IF EXISTS tpRecordMenuItem;