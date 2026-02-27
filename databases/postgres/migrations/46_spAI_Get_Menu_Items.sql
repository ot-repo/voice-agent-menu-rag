-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Get_Menu_Items(pclient_id INT, pprompt VARCHAR, pembeddings VARCHAR) RETURNS SETOF tpRecordSearchInputOutput AS $PROC$
	DECLARE
		datarow tpRecordMenuItem;
		result tpRecordSearchInputOutput;
		firstIter BOOLEAN := true;
		prevSimiliarity NUMERIC(17,16) := 1.0;
		firstSimiliarity NUMERIC(17,16) := 1.0;
		prevContent VARCHAR;
		modifiedPrompt VARCHAR;
		lowerCasePrompt VARCHAR;
		promptId INTEGER;
		promptFirstAsk BOOLEAN := false;
		withEmbeddings BOOLEAN := true;

	BEGIN
		IF NOT EXISTS(SELECT id FROM clients WHERE id=pclient_id AND deleted_at IS NULL) THEN
			SELECT 0, 'Invalid client supplied.', '' INTO result;
		ELSE
			IF pembeddings = '[]' THEN
				withEmbeddings := false;
			END IF;

			----------SELECT id, modified_prompt INTO promptId, modifiedPrompt FROM menu_prompts WHERE client_id=pclient_id AND embeddings=withEmbeddings AND original_prompt=pprompt AND deleted_at IS NULL;
			IF promptId = 0 OR promptId IS NULL THEN
				--Make sure the prompt has no typos
				SELECT fnAI_Get_Prompt_Check_Words(pclient_id, pprompt) INTO modifiedPrompt;
				INSERT INTO menu_prompts(client_id, embeddings, original_prompt, modified_prompt) VALUES(pclient_id, withEmbeddings, pprompt, modifiedPrompt) RETURNING id INTO promptId;	
				promptFirstAsk := true;
			END IF;

			SELECT LOWER(pprompt) INTO lowerCasePrompt;

			IF lowerCasePrompt IN ('all categories and products','alle kategorien und produkte','alle produkte','all products') THEN
				SELECT 1, content, '' INTO result
				FROM menu_contents
				WHERE client_id=pclient_id AND file_name='categories_products.md' AND deleted_at IS NULL;
				-- Logs the results.
				INSERT INTO menu_search_logs(prompt_id, embeddings, match_count)
				VALUES(promptId, false, 1);
			ELSE
				SELECT id INTO promptId FROM menu_prompts WHERE client_id=pclient_id AND embeddings=withEmbeddings AND original_prompt=pprompt AND deleted_at IS NULL;
				--RAISE WARNING 'promptFirstAsk:%', promptFirstAsk;
				IF promptFirstAsk=true OR promptFirstAsk='t' THEN
					pprompt := modifiedPrompt;
					INSERT INTO menu_searches(prompt_id, client_id, content_id, product_name_bm25, product_id_bm25, product_category_bm25, total_bm25, similarity)
					SELECT promptId, pclient_id, id, COALESCE(product_name <@> to_bm25query(pprompt,'idx_menu_contents_product_name_bm25'), 0),
					COALESCE(product_id <@> to_bm25query(pprompt,'idx_menu_contents_product_id_bm25'), 0),
					COALESCE(product_category <@> to_bm25query(pprompt,'idx_menu_contents_product_category_bm25'), 0),
					0 AS total_bm25, CASE pembeddings WHEN '[]' THEN 1 ELSE COALESCE(content_vector <=> pembeddings::VECTOR, 1) END AS similarity
					FROM menu_contents
					WHERE client_id=pclient_id AND deleted_at IS NULL
					AND file_name != 'categories_products.md';

					--Apply different weights if prompt matches product name/category
					UPDATE menu_searches SET total_bm25=(-3 * product_name_bm25 + -10 * product_id_bm25 + -1.2*product_category_bm25)
					FROM menu_contents 
					WHERE menu_searches.content_id=menu_contents.id AND prompt_id=promptId AND lowerCasePrompt=LOWER(product_name);

					UPDATE menu_searches SET total_bm25=(-1.2 * product_name_bm25 + -10 * product_id_bm25 + -3*product_category_bm25)
					FROM menu_contents 
					WHERE menu_searches.content_id=menu_contents.id AND prompt_id=promptId AND lowerCasePrompt=LOWER(product_category);

					UPDATE menu_searches SET total_bm25=(-1.6 * product_name_bm25 + -10 * product_id_bm25 + -1.2*product_category_bm25)
					FROM menu_contents 
					WHERE menu_searches.content_id=menu_contents.id AND prompt_id=promptId AND lowerCasePrompt != LOWER(product_name) AND lowerCasePrompt != LOWER(product_category);


					UPDATE menu_searches SET similarity=similarity/total_bm25
					WHERE prompt_id=promptId AND total_bm25 > 0;

				END IF;

				-- No result with bm25, retrun and give a chance to the embeddings vector
				IF pembeddings = '[]' AND NOT EXISTS(SELECT prompt_id FROM menu_searches WHERE prompt_id=promptId AND total_bm25 > 0) THEN
					SELECT 0, 'No results with BM25 only search', '' INTO result;
					INSERT INTO menu_search_logs(prompt_id, embeddings, match_count)
					VALUES(promptId, false, result.counter);
				ELSE
					--Initialize the result
					SELECT 0, '', '' INTO result;
					
					FOR datarow IN EXECUTE ('SELECT ms.similarity, mc.content FROM menu_searches AS ms INNER JOIN menu_contents AS mc ON (ms.content_id=mc.id) WHERE ms.prompt_id=' || promptId || ' AND mc.deleted_at IS NULL ORDER BY ms.similarity LIMIT 10') LOOP
						--Store the first similarity
						IF firstIter THEN
							firstSimiliarity := datarow.similarity;
							firstIter := false;
						END IF;

						--Tresholds Ollama : 0.55, TEI: 0.74
						IF firstSimiliarity > 0.74 OR (datarow.similarity/prevSimiliarity > 1.5) OR (datarow.similarity/firstSimiliarity >= 2) THEN
							--RAISE WARNING 'firstSimiliarity: % datarow.similarity: % prevSimiliarity: %', firstSimiliarity, datarow.similarity, prevSimiliarity;
							--result.content := result.content || e'\n---\n' || prevContent;
							EXIT;
						ELSE
							result.content := result.content || e'\n---\n' || datarow.content;
						END IF;
						
						prevSimiliarity := datarow.similarity;
						prevContent := datarow.content;
						result.counter := result.counter + 1;
						--RAISE WARNING 'prevSimiliarity: %', prevSimiliarity;
					END LOOP;
				END IF;
				-- Logs the results.
				INSERT INTO menu_search_logs(prompt_id, embeddings, match_count)
				VALUES(promptId, withEmbeddings, result.counter);
			END IF;
		END IF;
		RETURN NEXT result;
	END;
$PROC$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Get_Menu_Items;