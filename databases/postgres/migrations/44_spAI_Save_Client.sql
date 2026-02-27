-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Save_Client(pcustomer_id CHAR(36)) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		lclient_id INTEGER;
		reccount INTEGER;
		datarow tpRecordSaveResult;
		--contentsPartition VARCHAR;
	
	BEGIN
		IF EXISTS(SELECT id FROM clients WHERE customer_id = pcustomer_id AND deleted_at IS NULL) THEN
			SELECT 0, 'Client already saved' INTO datarow;
		ELSE
			INSERT INTO clients(customer_id) 
			VALUES(pcustomer_id) RETURNING id INTO lclient_id;
			GET DIAGNOSTICS reccount = ROW_COUNT;

			IF reccount = 1 THEN
				SELECT 0, 'Client and an import task have been created' INTO datarow;
				--Create an import task
				INSERT INTO menu_tasks(client_id, task, status) VALUES(lclient_id, 'import', 0);
			ELSE
				SELECT 1, 'Client could not be created' INTO datarow;
			END IF;

			--contentsPartition := 'CREATE TABLE menu_contents2_p' || lclient_id || ' PARTITION OF menu_contents2 FOR VALUES IN (' || lclient_id | ')';
			--EXECUTE contentsPartition;
		END IF;
		
		RETURN NEXT datarow;
	END;

$PROC$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Client;