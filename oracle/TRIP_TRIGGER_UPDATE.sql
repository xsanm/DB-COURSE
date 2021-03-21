create trigger TRIP_TRIGGER_UPDATE
	after update of NO_PLACES
	on TRIP
	for each row
DECLARE
BEGIN
    if ((:OLD.NO_PLACES - :OLD.NO_AVAILABLE_PLACES) > :NEW.NO_PLACES) THEN
        raise_application_error(-20001, 'Cant change NO_PLACES');
    end if;

    UPDATE TRIP T
    SET T.NO_AVAILABLE_PLACES = :OLD.NO_AVAILABLE_PLACES - (:OLD.NO_PLACES - :NEW.NO_PLACES)
    WHERE T.TRIP_ID = :OLD.TRIP_ID;
end;
/

