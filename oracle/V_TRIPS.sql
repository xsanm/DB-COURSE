create view V_TRIPS as
select COUNTRY,
       TRIP_DATE,
       NAME,
       NO_PLACES,
       NO_PLACES - (
           select count(*)
           from RESERVATION
           where RESERVATION.TRIP_ID = TRIP.TRIP_ID
       ) NO_AVAILABLE_PLACES
from TRIP
/

