-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION spAI_Get_Clients() RETURNS SETOF tpRecordClientItem AS $PROC$
	DECLARE
		datarow tpRecordClientItem;

	BEGIN			
		FOR datarow IN EXECUTE ('SELECT id, customer_id FROM clients WHERE id> 0 AND deleted_at IS NULL') LOOP
			RETURN NEXT datarow;
		END LOOP;
	END;
$PROC$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION IF EXISTS spAI_Get_Clients;