-- +goose Up
-- +goose StatementBegin
DROP TYPE IF EXISTS tpRecordMenuEnrichment;
CREATE TYPE tpRecordMenuEnrichment AS (item VARCHAR, type INTEGER, synonyms VARCHAR);
-- +goose StatementEnd

-- +goose Down
DROP TYPE IF EXISTS tpRecordMenuEnrichment;