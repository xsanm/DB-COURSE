--insert into PERSON (FIRSTNAME, LASTNAME)
--values ('Ron', 'Lewis')


select *
from PERSON;

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
values ('Trip from past', 'Country1', TO_DATE('2021-03-01', 'YYYY-MM-DD'), 8);

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
values ('Trip 1', 'Country2', TO_DATE('2021-03-20', 'YYYY-MM-DD'), 2);

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
values ('Trip 2', 'Country3', TO_DATE('2021-03-25', 'YYYY-MM-DD'), 7);

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
values ('Trip 3', 'Country4', TO_DATE('2021-04-20', 'YYYY-MM-DD'), 12);

INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (1, 2, 'P');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (1, 3, 'C');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (3, 1, 'P');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (3, 2, 'P');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (3, 4, 'C');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (3, 5, 'N');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (2, 10, 'N');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (4, 8, 'N');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (4, 9, 'C');
INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
values (4, 3, 'P');

create view V_Reservations
as
select COUNTRY,
       TRIP_DATE,
       NAME,
       FIRSTNAME,
       LASTNAME,
       RESERVATION_ID,
       STATUS
from RESERVATION R
         join PERSON P on P.PERSON_ID = R.PERSON_ID
         join TRIP T on T.TRIP_ID = R.TRIP_ID;

create view V_AvailableTrips
as
select COUNTRY, TRIP_DATE, NAME, NO_PLACES, NO_AVAILABLE_PLACES
from V_TRIPS
    where NO_AVAILABLE_PLACES > 0 and TRIP_DATE >= CURRENT_DATE;

create or replace view V_TRIPS_2
as
select COUNTRY,
       TRIP_DATE,
       NAME,
       NO_PLACES,
       NO_AVAILABLE_PLACES
from TRIP;


select R.TRIP_ID, count(*)
from TRIP
         join RESERVATION R on TRIP.TRIP_ID = R.TRIP_ID
group by R.TRIP_ID;




create or replace function TripParticipants(tripID in INTEGER)
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

create or replace type PERSON_RESERVATION as object
(
    COUNTRY        varchar2(50),
    TRIP_DATE      date,
    FIRSTNAME      varchar2(50),
    LASTNAME       varchar2(50),
    RESERVATION_ID integer,
    STATUS         char(1)
);

create or replace type PERSON_RESERVATION_TABLE is table of PERSON_RESERVATION;

select * from TRIPPARTICIPANTS(1);
select * from TRIPPARTICIPANTS(2);
select * from TRIPPARTICIPANTS(3);
select * from TRIPPARTICIPANTS(4);

create or replace function PersonReservations(personID in INTEGER)
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

select * from PERSONRESERVATIONS(6);


create or replace function AvailableTrips(country in TRIP.COUNTRY%TYPE, date_from in date, date_to in date)
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

create type TRIP_OBJECT as object
(
    TRIP_ID   integer,
    NAME      varchar2(100),
    COUNTRY   varchar2(50),
    TRIP_DATE DATE,
    NO_PLACES integer
);

create type TRIPS is table of TRIP_OBJECT;

select * from AVAILABLETRIPS('Country3', current_date, to_date('2022-01-01', 'YYYY-MM-DD'));


create or replace procedure AddReservation_FINAL(tripID in integer, personID in integer)
AS
    if_person   integer;
    if_trip     integer;
    free_places integer;
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


    select NO_AVAILABLE_PLACES
    into
        free_places
    from TRIP
    where TRIP_ID = tripID;

    if free_places > 0 then
        raise_application_error(-20001, 'No places available');
    end if;

    INSERT INTO RESERVATION
        (TRIP_ID, PERSON_ID, STATUS)
    VALUES (tripID, personID, 'N');
end;


create or replace procedure ModifyReservationStatus_2(reservationID IN INTEGER, newStatus IN RESERVATION.STATUS%TYPE)
AS
    if_reservation integer;
    free_places    integer;
    tripID         integer;
    rStatus        RESERVATION.STATUS%TYPE;
begin

    select count(*)
    into if_reservation
    from RESERVATION
    where RESERVATION_ID = reservationID;

    if if_reservation = 0 then
        raise_application_error(-20001, 'Reservation does not exist');
    end if;

    select TRIP_ID
    into tripID
    from RESERVATION
    where RESERVATION_ID = reservationID;

    select NO_AVAILABLE_PLACES
    into
        free_places
    from TRIP
    where TRIP_ID = tripID;

    select STATUS
    into rStatus
    from RESERVATION
    where RESERVATION_ID = reservationID;

    if rStatus = 'C' and free_places = 0 then
        raise_application_error(-20001, 'No free places anymore');
    end if;

    UPDATE RESERVATION
    SET STATUS = newStatus
    WHERE RESERVATION_ID = reservationID;

    INSERT INTO RESERVATION_LOG(RESERVATION_ID, CHANGE_DATE, STAUS)
    VALUES (reservationID, current_date, newStatus);

end;


create or replace procedure ModifyNoPlaces_FINAL(tripID in integer, noPlaces in integer)
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


create table RESERVATION_LOG
(
    ID             int generated always as identity not null,
    RESERVATION_ID int,
    CHANGE_DATE    date,
    STAUS          char,
    constraint RESERVATION_LOG_PK PRIMARY KEY
    (
        ID
    )
);

ALTER TABLE TRIP
ADD NO_AVAILABLE_PLACES INT ;


CREATE OR REPLACE PROCEDURE PRZELICZ
AS
BEGIN
    UPDATE TRIP T
    SET T.NO_AVAILABLE_PLACES =(
        T.NO_PLACES -
    (
        SELECT count(*)
        FROM RESERVATION R
        WHERE R.TRIP_ID = T.TRIP_ID
        AND R.STATUS <> 'C'
    ))
    where 1 = 1;
END;



create or replace trigger RESERVATION_ADD_TRIGGER
    after insert
    on RESERVATION
    for each row
BEGIN
    INSERT INTO RESERVATION_LOG
        (RESERVATION_ID, CHANGE_DATE, STAUS)
    VALUES (:NEW.RESERVATION_ID, CURRENT_DATE, :NEW.STATUS);
    UPDATE TRIP
    SET TRIP.NO_AVAILABLE_PLACES = TRIP.NO_AVAILABLE_PLACES - 1
    WHERE TRIP.TRIP_ID = :NEW.TRIP_ID;
end;

create trigger RESERVATION_DELETE_TRIGGER
    after delete
    on RESERVATION
    for each row
BEGIN
    raise_application_error(-20001, 'FORBIDDEN: You have to change status istead of deleting');
end;

create trigger RESERVATION_UPDATE_TRIGGER
    after update
    on RESERVATION
    for each row
DECLARE
    places_diff INTEGER;
BEGIN
    INSERT INTO RESERVATION_LOG
        (RESERVATION_ID, CHANGE_DATE, STAUS)
    VALUES (:OLD.RESERVATION_ID, CURRENT_DATE, :NEW.STATUS);
    CASE
        WHEN (:OLD.STATUS = 'C' AND :NEW.STATUS <> 'C') THEN
            places_diff := -1;
        WHEN (:OLD.STATUS <> 'C' AND :NEW.STATUS = 'C') THEN
            places_diff := 1;
        ELSE
            places_diff := 0;
        END CASE;
    UPDATE TRIP T
    SET T.NO_AVAILABLE_PLACES = T.NO_AVAILABLE_PLACES + places_diff
    WHERE T.TRIP_ID = :NEW.TRIP_ID;
end;

create trigger TRIP_TRIGGER_UPDATE
    after update of NO_PLACES
    on TRIP
    for each row
DECLARE
BEGIN
    if ((:OLD.NO_PLACES - :OLD.NO_AVAILABLE_PLACES) > :NEW.NO_PLACES) THEN
        raise_application_error(-20001, 'Cant change NO_PLACES');
    end if;

    UPDATE TRIP T
    SET T.NO_AVAILABLE_PLACES = :OLD.NO_AVAILABLE_PLACES - (:OLD.NO_PLACES - :NEW.NO_PLACES)
    WHERE T.TRIP_ID = :OLD.TRIP_ID;
end;

BEGIN
    AddReservation_FINAL(4, 4);
end;

BEGIN
    PRZELICZ();
end;

BEGIN
    MODIFYRESERVATIONSTATUS_FINAL(22, 'P');
end;

BEGIN
    MODIFYRESERVATIONSTATUS_FINAL(22, 'C');
end;