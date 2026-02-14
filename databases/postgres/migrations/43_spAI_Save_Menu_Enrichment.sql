-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION spAI_Save_Menu_Enrichment(pcustomer_id CHAR(36), ptype VARCHAR, pgroup VARCHAR) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		datarow tpRecordMenuEnrichment;
		result tpRecordSaveResult;
		ltype VARCHAR;
		lgroup VARCHAR;
		lsynonyms VARCHAR;
		lword VARCHAR;
		llabels VARCHAR;
		lproductId INTEGER;
		lcategoryId INTEGER;

	BEGIN
		IF NOT EXISTS(SELECT id FROM clients WHERE customer_id=pcustomer_id AND deleted_at IS NULL) THEN
			SELECT 10, 'Invalid client supplied.' INTO result;
			RETURN NEXT result;
		ELSE
			IF ptype = 'category' THEN
				ltype := '2';
			ELSIF ptype = 'product' THEN
				ltype := '1';
			ELSIF ptype = 'all' THEN
				ltype := '1,2';
			ELSE
				SELECT 20, 'Invalid type supplied.' INTO result;
				RETURN NEXT result;
			END IF;

			IF pgroup = 'common' THEN
				lgroup := '0';
			ELSIF pgroup = 'self' THEN
				lgroup := pcustomer_id;
			ELSIF pgroup = 'all' THEN
				lgroup := '0,' || pcustomer_id;
			ELSE
				SELECT 30, 'Invalid group supplied.' INTO result;
				RETURN NEXT result;
			END IF;
			
			FOR datarow IN EXECUTE ('SELECT item, type, synonyms FROM menu_enrichments WHERE customer_id IN (''' || lgroup || ''') AND type IN (' || ltype || ') AND synonyms IS NOT NULL AND deleted_at IS NULL') LOOP
				IF datarow.type = 2 THEN
					SELECT category_id, COALESCE(label, '') INTO lcategoryId, llabels FROM menu_categories WHERE customer_id=pcustomer_id AND name=datarow.item AND deleted_at IS NULL;
					IF llabels = '' THEN
						UPDATE menu_categories SET label = datarow.synonyms WHERE category_id=lcategoryId;
					ELSE
						SELECT STRING_AGG(aa.common, ', ') INTO llabels FROM
						(
							SELECT UNNEST(STRING_TO_ARRAY(REPLACE(COALESCE(label, ''), ', ', ','), ',')) AS common FROM menu_categories WHERE category_id=lcategoryId
							UNION
							SELECT UNNEST(STRING_TO_ARRAY(REPLACE(COALESCE(datarow.synonyms, ''), ', ', ','), ',')) AS common
						) AS aa;
						
						UPDATE menu_categories SET label = llabels WHERE category_id=lcategoryId AND llabels != '';
					END IF;
				ELSE
					RAISE WARNING 'item: %', datarow.item;
					SELECT content.id, COALESCE(content.label, '') INTO lproductId, llabels FROM menu_contents AS content
					INNER JOIN menu_categories as category ON (content.category_id=category.category_id) 
					WHERE category.customer_id=pcustomer_id AND content.name=datarow.item AND content.deleted_at IS NULL AND category.deleted_at IS NULL;

					IF llabels = '' THEN
						UPDATE menu_contents SET label = datarow.synonyms WHERE id=lproductId;
					ELSE
						SELECT STRING_AGG(aa.common, ', ') INTO llabels FROM
						(
							SELECT UNNEST(STRING_TO_ARRAY(REPLACE(COALESCE(label, ''), ', ', ','), ',')) AS common FROM menu_contents WHERE id=lproductId
							UNION
							SELECT UNNEST(STRING_TO_ARRAY(REPLACE(COALESCE(datarow.synonyms, ''), ', ', ','), ',')) AS common
						) AS aa;
						
						UPDATE menu_contents SET label = llabels WHERE id=lproductId AND llabels != '';
					END IF;
				END IF;
			END LOOP;
			SELECT 0, 'Enrichment applied.' INTO result;
			RETURN NEXT result;
		END IF;
	END;
$PROC$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Menu_Enrichment;