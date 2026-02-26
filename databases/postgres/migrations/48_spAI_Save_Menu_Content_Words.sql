-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION spAI_Save_Menu_Content_Words(pclient_id INT) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		result tpRecordSaveResult;

	BEGIN
		SELECT 0, 'Success' INTO result;
		IF NOT EXISTS(SELECT id FROM clients WHERE id=pclient_id AND deleted_at IS NULL) THEN
			SELECT 1, 'Invalid client supplied.' INTO result;
		ELSE
			--Clean up the current words
			DELETE FROM menu_search_words WHERE client_id=pclient_id;

			CREATE TEMP TABLE temp_words AS
			SELECT word 
			FROM ts_stat('SELECT to_tsvector(''simple'', content) FROM menu_contents WHERE client_id=' || pclient_id || '');

			--Use only the words with minimum length of 4 and only alphanumeric
			INSERT INTO menu_search_words(client_id, word)
    		SELECT pclient_id, word
    		FROM temp_words
    		WHERE word ~ '^[a-zA-Züößä]{4,100}$';

			DROP TABLE temp_words;
		END IF;
		RETURN NEXT result;
	END;
$PROC$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Menu_Content_Words;