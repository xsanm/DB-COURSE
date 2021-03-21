create procedure ModifyNoPlaces_FINAL(tripID in integer, noPlaces in integer)
AS
    if_trip         integer;
begin
    select count(*)
    into if_trip
    from TRIP
    where TRIP_ID = tripID;

    if if_trip = 0 then
        raise_application_error(-20001, 'Trip does not exist or is from past');
    end if;


    update TRIP
    set NO_PLACES = noPlaces
    WHERE TRIP_ID = tripID;

end;
/

