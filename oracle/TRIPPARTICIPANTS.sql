create function TripParticipants(tripID in INTEGER)
    return PERSON_RESERVATION_TABLE
as
    result  PERSON_RESERVATION_TABLE;
    if_trip int;
begin

    select count(*) into if_trip from TRIP where TRIP_ID = tripID;

    if if_trip = 0 then
        raise_application_error(-200100, 'Trip with this id does not exist');
    end if;

    select PERSON_RESERVATION(T.COUNTRY, T.TRIP_DATE, P.FIRSTNAME, P.LASTNAME, R.RESERVATION_ID, R.STATUS)
        bulk collect
    into result
    from RESERVATION R
             join TRIP T on T.TRIP_ID = R.TRIP_ID
             join PERSON P on P.PERSON_ID = R.PERSON_ID
    where R.TRIP_ID = tripID;

    return result;
end;
/

