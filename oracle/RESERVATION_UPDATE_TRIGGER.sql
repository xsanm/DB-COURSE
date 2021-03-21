create trigger RESERVATION_UPDATE_TRIGGER
	after update
	on RESERVATION
	for each row
DECLARE
    places_diff INTEGER;
BEGIN
    INSERT INTO RESERVATION_LOG
        (RESERVATION_ID, CHANGE_DATE, STAUS)
    VALUES (:OLD.RESERVATION_ID, CURRENT_DATE, :NEW.STATUS);
    CASE
        WHEN (:OLD.STATUS = 'C' AND :NEW.STATUS <> 'C') THEN
            places_diff := -1;
        WHEN (:OLD.STATUS <> 'C' AND :NEW.STATUS = 'C') THEN
            places_diff := 1;
        ELSE
            places_diff := 0;
        END CASE;
    UPDATE TRIP T
    SET T.NO_AVAILABLE_PLACES = T.NO_AVAILABLE_PLACES + places_diff
    WHERE T.TRIP_ID = :NEW.TRIP_ID;
end;
/

