-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION spAI_Get_Menu_Tasks(pstatus INTEGER) RETURNS SETOF tpRecordMenuTask AS $PROC$
	DECLARE
		datarow tpRecordMenuTask;
		lclient_id INT;

	BEGIN
		--Get tasks with the given status
		FOR datarow IN EXECUTE ('SELECT id, client_id, task, status, message FROM menu_tasks WHERE EXTRACT(EPOCH FROM(CURRENT_TIMESTAMP-created_at)) > 65 AND status=' || pstatus ) LOOP
			RETURN NEXT datarow;
		END LOOP;
	END;
$PROC$ LANGUAGE plpgsql;

-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Get_Menu_Tasks;