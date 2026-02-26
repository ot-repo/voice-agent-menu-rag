-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Save_Menu_Task(pclient_id INT, ptask VARCHAR) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		result tpRecordSaveResult;

	BEGIN
		IF NOT EXISTS(SELECT id FROM clients WHERE id=pclient_id AND deleted_at IS NULL) THEN
			SELECT 10, 'Invalid client supplied.' INTO result;
		ELSE
			--Do not allow the imports to accumulate if there is already pending one for the client.
			IF EXISTS(SELECT id FROM menu_tasks WHERE client_id=pclient_id AND status=0 AND task='import' AND EXTRACT(EPOCH FROM(CURRENT_TIMESTAMP-created_at)) < 30 AND deleted_at IS NULL) THEN
				UPDATE menu_tasks SET created_at = CURRENT_TIMESTAMP + INTERVAL '30 second' WHERE client_id=pclient_id AND status=0 AND ptask='import' AND deleted_at IS NULL;
				SELECT 1, 'There is already a pending import within 30 seconds.' INTO result;
			ELSE
				--In case an import task arrives, the running vectors tasks must be canceled.
				IF ptask = 'import' THEN
					UPDATE menu_tasks SET status=4, updated_at=CURRENT_TIMESTAMP WHERE client_id=pclient_id AND status=1 AND task='vectors' AND deleted_at IS NULL;
				END IF;
				INSERT INTO menu_tasks(client_id, task, status) VALUES(pclient_id, ptask, 0);
				SELECT 0, 'The task ''' || ptask || ''' is created.' INTO result;
			END IF;
		END IF;
		RETURN NEXT result;
	END;
$PROC$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Menu_Task;