create function AvailableTrips(country in TRIP.COUNTRY%TYPE, date_from in date, date_to in date)
    return TRIPS
as
    result     TRIPS;
    if_country int;
begin

    select count(*) into if_country from TRIP where TRIP.COUNTRY = AvailableTrips.country;

    if if_country = 0 then
        raise_application_error(-20001, 'Country does not exist');
    end if;

    if date_from > date_to then
        raise_application_error(-20001, 'Wrong dates');
    end if;

    select TRIP_OBJECT(T.TRIP_ID, T.NAME, T.COUNTRY, T.TRIP_DATE, T.NO_PLACES)
        bulk collect
    into result
    from TRIP T
    where T.COUNTRY = AvailableTrips.country
      and T.TRIP_DATE >= date_from
      and T.TRIP_DATE <= date_to
      and T.NO_PLACES > 0;

    return result;
end;
/

