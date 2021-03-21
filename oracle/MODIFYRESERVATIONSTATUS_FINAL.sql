create procedure ModifyReservationStatus_FINAL(reservationID IN INTEGER, newStatus IN RESERVATION.STATUS%TYPE)
AS
    if_reservation integer;
    free_places    integer;
    tripID         integer;
    rStatus        RESERVATION.STATUS%TYPE;
begin

    select count(*)
    into if_reservation
    from RESERVATION
    where RESERVATION_ID = reservationID;

    if if_reservation = 0 then
        raise_application_error(-20001, 'Reservation does not exist');
    end if;

    select TRIP_ID
    into tripID
    from RESERVATION
    where RESERVATION_ID = reservationID;

    select NO_AVAILABLE_PLACES
    into
        free_places
    from TRIP
    where TRIP_ID = tripID;

    select STATUS
    into rStatus
    from RESERVATION
    where RESERVATION_ID = reservationID;

    if rStatus = 'C' and free_places = 0 then
        raise_application_error(-20001, 'No free places anymore');
    end if;

    UPDATE RESERVATION
    SET STATUS = newStatus
    WHERE RESERVATION_ID = reservationID;
end;
/

