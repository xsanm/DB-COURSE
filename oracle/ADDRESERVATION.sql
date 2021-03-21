create procedure AddReservation(tripID in integer, personID in integer)
AS
    if_person     integer;
    if_trip       integer;
    free_places   integer;
begin
    select count(*)
    into if_trip
    from TRIP
    where TRIP_ID = tripID
      and TRIP_DATE >= current_date;

    select count(*)
    into if_person
    FROM PERSON
    WHERE PERSON_ID = personID;

    if if_trip = 0 then
        raise_application_error(-20001, 'Trip does not exist or is from past');
    end if;

    if if_person = 0 then
        raise_application_error(-20001, 'Person does not exist');
    end if;


    select NO_PLACES -
           (
               select count(*)
               from RESERVATION R
               where R.TRIP_ID = tripID
                 and STATUS <> 'C'
            )
    into
    free_places from TRIP
    where TRIP_ID = tripID;

    if free_places > 0 then
        raise_application_error(-20001, 'No places available');
    end if;

    INSERT INTO RESERVATION
        (TRIP_ID, PERSON_ID, STATUS)
    VALUES (tripID, personID, 'N');

    INSERT INTO RESERVATION_LOG(RESERVATION_ID, CHANGE_DATE, STAUS)
    VALUES ((select max(RESERVATION_ID) from RESERVATION), current_date ,'N');

end;
/

