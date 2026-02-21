-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Save_Menu_Task(pcustomer_id CHAR(36), ptask VARCHAR) RETURNS SETOF tpRecordSaveResult AS $PROC$
	DECLARE
		result tpRecordSaveResult;

	BEGIN
		IF NOT EXISTS(SELECT id FROM clients WHERE customer_id=pcustomer_id AND deleted_at IS NULL) THEN
			SELECT 10, 'Invalid client supplied.' INTO result;
		ELSE
			--Do not allow the imports to accumulate if there is already pending one for the client.
			IF EXISTS(SELECT id FROM menu_tasks WHERE customer_id=pcustomer_id AND status=0 AND task='import' AND EXTRACT(EPOCH FROM(CURRENT_TIMESTAMP-created_at)) < 30 AND deleted_at IS NULL) THEN
				UPDATE menu_tasks SET created_at = CURRENT_TIMESTAMP + INTERVAL '30 second' WHERE customer_id=pcustomer_id AND status=0 AND ptask='import' AND deleted_at IS NULL;
				SELECT 1, 'There is already a pending import within 30 seconds.' INTO result;
			ELSE
				INSERT INTO menu_tasks(customer_id, task, status) VALUES(pcustomer_id, ptask, 0);
				SELECT 0, 'The task ''' || ptask || ''' is created.' INTO result;
			END IF;
		END IF;
		RETURN NEXT result;
	END;
$PROC$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Save_Menu_Task;