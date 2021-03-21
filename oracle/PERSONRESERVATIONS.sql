create function PersonReservations(personID in INTEGER)
    return PERSON_RESERVATION_TABLE
as
    result  PERSON_RESERVATION_TABLE;
    if_person int;
begin

    select count(*) into if_person from PERSON where PERSON_ID = personID;

    if if_person = 0 then
        raise_application_error(-200001, 'Person with this id does not exist');
    end if;

    select PERSON_RESERVATION(T.COUNTRY, T.TRIP_DATE, P.FIRSTNAME, P.LASTNAME, R.RESERVATION_ID, R.STATUS)
        bulk collect
    into result
    from RESERVATION R
             join TRIP T on T.TRIP_ID = R.TRIP_ID
             join PERSON P on P.PERSON_ID = R.PERSON_ID
    where R.PERSON_ID = personID;

    return result;
end;
/

