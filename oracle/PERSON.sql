create table PERSON
(
	PERSON_ID NUMBER generated as identity,
	FIRSTNAME VARCHAR2(50),
	LASTNAME VARCHAR2(50),
	constraint PERSON_PK
		primary key (PERSON_ID)
)
/

