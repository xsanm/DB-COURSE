create procedure ModifyNoPlaces(tripID in integer, noPlaces in integer)
AS
    if_trip         integer;
    reserved_places integer;
begin
    select count(*)
    into if_trip
    from TRIP
    where TRIP_ID = tripID;

    if if_trip = 0 then
        raise_application_error(-20001, 'Trip does not exist or is from past');
    end if;


    select count(*)
    into reserved_places
    from RESERVATION R
    where R.TRIP_ID = tripID
      and STATUS <> 'C';

    if reserved_places > noPlaces then
        raise_application_error(-20001, 'More reserved places');
    end if;

    update TRIP
    set NO_PLACES = noPlaces
    WHERE TRIP_ID = tripID;

end;
/

