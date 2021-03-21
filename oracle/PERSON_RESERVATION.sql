create type PERSON_RESERVATION as object
(
    COUNTRY        varchar2(50),
    TRIP_DATE      date,
    FIRSTNAME      varchar2(50),
    LASTNAME       varchar2(50),
    RESERVATION_ID integer,
    STATUS         char(1)
)
/

