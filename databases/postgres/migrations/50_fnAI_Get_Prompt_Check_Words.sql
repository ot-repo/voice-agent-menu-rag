-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION fnAI_Get_Prompt_Check_Words(pclient_id INTEGER, pprompt VARCHAR) RETURNS VARCHAR AS $PROC$
	DECLARE
		result VARCHAR := '';
		lowerPrompt VARCHAR := '';
		currentTerm VARCHAR := '';
		tmpTerm VARCHAR := '';
		noSpace VARCHAR := '';
		maxIterations INT := 20;
		counter INT := 0;

	BEGIN
		
		IF NOT EXISTS (SELECT id FROM clients WHERE id=pclient_id AND deleted_at IS NULL) THEN
			RETURN 'Invalid client supplied.';
		ELSE
			--The words less than 4 characters must be trimmed.
			--The terms are saved in lowercase.
			--Wurst mit Zwiebeln => Wurst Zwiebeln 
			SELECT LOWER(STRING_AGG(word, ' ')) INTO lowerPrompt
			FROM unnest(string_to_array(pprompt, ' ')) AS word
			WHERE length(word) >= 4;

			
			--In German the words are conjugated, so if there are 2 words like AAA BBB, try AAABBB first.
			SELECT REPLACE(lowerPrompt, ' ', '') INTO noSpace;
			-- Only 1 space
			IF LENGTH(lowerPrompt) - LENGTH(noSpace) = 1 THEN
				SELECT COALESCE(word, noSpace) INTO currentTerm
				FROM menu_search_words
  				WHERE client_id=pclient_id 
				--AND word=noSpace 
				AND similarity(word, noSpace) > 0.65 
				ORDER BY similarity(word, noSpace) DESC LIMIT 1;
				IF currentTerm != '' THEN
					RETURN currentTerm;
				ELSE
					--Swap the words and look for the compound word.
					SELECT SPLIT_PART(lowerPrompt, ' ', 2) || SPLIT_PART(lowerPrompt, ' ', 1) INTO noSpace;
					SELECT COALESCE(word, noSpace) INTO currentTerm
					FROM menu_search_words
  					WHERE client_id=pclient_id 
					--AND word=noSpace LIMIT 1
					AND similarity(word, noSpace) > 0.65 
					ORDER BY similarity(word, noSpace) DESC LIMIT 1;
					IF currentTerm != '' THEN
						RETURN currentTerm;
					END IF;
				END IF;
			END IF;
			SELECT SPLIT_PART(lowerPrompt, ' ', 1) INTO currentTerm;
			WHILE currentTerm != '' AND counter < maxIterations LOOP
				IF LENGTH(TRIM(currentTerm)) >= 4 THEN
					SELECT COALESCE(word, currentTerm) INTO tmpTerm
  					FROM menu_search_words
  					WHERE client_id=pclient_id AND word % currentTerm
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

				lowerPrompt := TRIM(LTRIM(lowerPrompt, currentTerm));
				SELECT SPLIT_PART(lowerPrompt, ' ', 1) INTO currentTerm;
				counter := counter+1;
			END LOOP;
		END IF;
		-- Play safe and return the original prompt if something goes wrong or if the result is empty.
		IF result ='' OR result IS NULL THEN
			RETURN pprompt;
		ELSE
			RETURN result;
		END IF;
	END;
$PROC$ LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS fnAI_Get_Prompt_Check_Words;