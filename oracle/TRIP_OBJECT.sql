create type TRIP_OBJECT as object
(
    TRIP_ID   integer,
    NAME      varchar2(100),
    COUNTRY   varchar2(50),
    TRIP_DATE DATE,
    NO_PLACES integer
)
/

