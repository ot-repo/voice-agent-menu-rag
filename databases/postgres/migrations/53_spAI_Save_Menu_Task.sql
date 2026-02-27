-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Save_Menu_Task(pcustomer_id VARCHAR, ptask VARCHAR) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		client tpRecordSaveResult;
		result tpRecordSaveResult;
		pclient_id INT;

	BEGIN

		--Check the client and if the task is import and we don't have one, create it.
		IF NOT EXISTS(SELECT id FROM clients WHERE customer_id=pcustomer_id AND deleted_at IS NULL) THEN
			IF ptask = 'import' THEN
				SELECT * FROM spAI_Save_Client(pcustomer_id) INTO result;
				IF result.value > 0 THEN
					RETURN NEXT result;
				END IF;
			ELSE
				SELECT 10, 'Invalid client supplied.' INTO result;
				RETURN NEXT result;
			END IF;
		END IF;
		
		SELECT id INTO pclient_id FROM clients WHERE customer_id=pcustomer_id AND deleted_at IS NULL;
		--Do not allow the imports to accumulate if there is already pending one for the client.
		IF EXISTS(SELECT id FROM menu_tasks WHERE client_id=pclient_id AND status=0 AND task='import' AND EXTRACT(EPOCH FROM(CURRENT_TIMESTAMP-created_at)) < 65 AND deleted_at IS NULL) THEN
			UPDATE menu_tasks SET created_at = CURRENT_TIMESTAMP + INTERVAL '65 second' WHERE client_id=pclient_id AND status=0 AND ptask='import' AND deleted_at IS NULL;
			SELECT 1, 'There is already a pending import within 65 seconds.' INTO result;
		ELSE
			--In case an import task arrives, the running vectors tasks must be canceled.
			IF ptask = 'import' THEN
				UPDATE menu_tasks SET status=4, updated_at=CURRENT_TIMESTAMP WHERE client_id=pclient_id AND status=1 AND task='vectors' AND deleted_at IS NULL;
			END IF;
			INSERT INTO menu_tasks(client_id, task, status) VALUES(pclient_id, ptask, 0);
			SELECT 0, 'The task ''' || ptask || ''' is created.' INTO result;
		END IF;
		RETURN NEXT result;
	END;
$PROC$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Menu_Task;