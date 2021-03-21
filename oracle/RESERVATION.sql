create table RESERVATION
(
	RESERVATION_ID NUMBER generated as identity,
	TRIP_ID NUMBER,
	PERSON_ID NUMBER,
	STATUS CHAR,
	constraint RESERVATION_PK
		primary key (RESERVATION_ID),
	constraint RESERVATION_FK1
		foreign key (PERSON_ID) references PERSON,
	constraint RESERVATION_FK2
		foreign key (TRIP_ID) references TRIP
)
/

alter table RESERVATION
	add constraint RESERVATION_CHK1
		check (status IN ('N','P','C'))
/

