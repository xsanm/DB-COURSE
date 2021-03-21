create view V_AVAILABLETRIPS as
select COUNTRY, TRIP_DATE, NAME, NO_PLACES, NO_AVAILABLE_PLACES
from V_TRIPS
    where NO_AVAILABLE_PLACES > 0 and TRIP_DATE >= CURRENT_DATE
/
