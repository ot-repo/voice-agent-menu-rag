-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION spAI_Save_Menu_Content_Words(pcustomer_id CHAR(36)) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		result tpRecordSaveResult;

	BEGIN
		SELECT 0, 'Success' INTO result;
		IF NOT EXISTS(SELECT id FROM clients WHERE customer_id=pcustomer_id AND deleted_at IS NULL) THEN
			SELECT 1, 'Invalid client supplied.' INTO result;
		ELSE
			IF EXISTS(SELECT customer_id FROM menu_search_words WHERE customer_id=pcustomer_id LIMIT 1) THEN
				--Clean up the current words
				DELETE FROM menu_search_words WHERE customer_id=pcustomer_id;
			END IF;

			CREATE TEMP TABLE temp_words AS
    		SELECT word 
			FROM ts_stat('SELECT to_tsvector(''simple'', content) FROM menu_contents WHERE customer_id=''' || pcustomer_id || '''');

			--Use only the words with minimum length of 4 and only alphanumeric
			INSERT INTO menu_search_words(customer_id, word)
    		SELECT pcustomer_id AS customer_id, word
    		FROM temp_words
    		WHERE word ~ '^[a-zA-Z]{4,100}$';

			DROP TABLE temp_words;
		END IF;
		RETURN NEXT result;
	END;
$PROC$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Menu_Content_Words;