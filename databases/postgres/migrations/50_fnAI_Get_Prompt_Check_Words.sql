-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION fnAI_Get_Prompt_Check_Words(pcustomer_id CHAR(36), pprompt VARCHAR) RETURNS VARCHAR AS $PROC$
	DECLARE
		result VARCHAR := '';
		currentTerm VARCHAR := '';
		tmpTerm VARCHAR := '';
		maxIterations INT := 20;
		counter INT := 0;

	BEGIN

		IF NOT EXISTS(SELECT id FROM clients WHERE customer_id=pcustomer_id AND deleted_at IS NULL) THEN
			RETURN 'Invalid client supplied.';
		ELSE
			SELECT SPLIT_PART(pprompt, ' ', 1) INTO currentTerm;
			WHILE currentTerm != '' AND counter < maxIterations LOOP
				IF LENGTH(TRIM(currentTerm)) >= 4 THEN
					SELECT COALESCE(word, currentTerm) INTO tmpTerm
  					FROM menu_search_words
  					WHERE customer_id=pcustomer_id AND word % currentTerm
  					ORDER BY similarity(word, currentTerm) DESC LIMIT 1;

					--RAISE WARNING 'currentTerm% tmpTerm=%', currentTerm, tmpTerm;
					IF tmpTerm IS NOT NULL OR tmpTerm != '' THEN
						IF result = '' THEN
							result := tmpTerm; 
						ELSE
							result := result || ' ' || tmpTerm; 
						END IF;
					END IF;
				END IF;

				pprompt := TRIM(LTRIM(pprompt, currentTerm));
				SELECT SPLIT_PART(pprompt, ' ', 1) INTO currentTerm;
				counter := counter+1;
			END LOOP;
		END IF;
		-- Play safe and return the original prompt if something goes wrong or if the result is empty.
		IF result IS NULL THEN
			RETURN pprompt;
		ELSE
			RETURN result;
		END IF;
	END;
$PROC$ LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS fnAI_Get_Prompt_Check_Words;