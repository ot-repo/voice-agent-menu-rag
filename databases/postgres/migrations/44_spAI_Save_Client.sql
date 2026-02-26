-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Save_Client(pcustomer_id CHAR(36), ptitle VARCHAR(255)) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		lclient_id INTEGER;
		reccount INTEGER;
		datarow tpRecordSaveResult;
		contentsPartition VARCHAR;
	
	BEGIN
		IF EXISTS(SELECT id FROM clients WHERE customer_id = pcustomer_id AND deleted_at IS NULL) THEN
			UPDATE admins SET title=ptitle, updated_at=CURRENT_TIMESTAMP WHERE customer_id = pcustomer_id AND deleted_at IS NULL;
			GET DIAGNOSTICS reccount = ROW_COUNT;
			IF reccount = 1 THEN
				SELECT 'Client title has been updated', 0 INTO datarow;
			ELSE
				SELECT 'Client title could not be updated', 0 INTO datarow;
			END IF;
		ELSE
			INSERT INTO clients(customer_id, title) 
			VALUES(pcustomer_id, ptitle) RETURNING id INTO lclient_id;
			GET DIAGNOSTICS reccount = ROW_COUNT;

			contentsPartition := 'CREATE TABLE menu_contents2_p' || lclient_id || ' PARTITION OF menu_contents2 FOR VALUES IN (' || lclient_id | ')';
			EXECUTE contentsPartition;

			--Create an import task
			INSERT INTO menu_tasks(client_id, task, status) VALUES(lclient_id, 'import', 0);

			IF reccount = 1 THEN
				SELECT 'Client has been created', 0 INTO datarow;
			ELSE
				SELECT 'Client could not be created', 0 INTO datarow;
			END IF;

		END IF;
		
		RETURN NEXT datarow;
	END;

$PROC$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Client;