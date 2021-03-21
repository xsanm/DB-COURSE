create PROCEDURE PRZELICZ
AS
BEGIN
    UPDATE TRIP T
    SET T.NO_AVAILABLE_PLACES =(
        T.NO_PLACES -
    (
        SELECT count(*)
        FROM RESERVATION R
        WHERE R.TRIP_ID = T.TRIP_ID
        AND R.STATUS <> 'C'
    ))
    where 1 = 1;
END;
/

