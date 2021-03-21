create table RESERVATION_LOG
(
	ID NUMBER generated as identity,
	RESERVATION_ID NUMBER,
	CHANGE_DATE DATE,
	STAUS CHAR,
	constraint RESERVATION_LOG_PK
		primary key (ID)
)
/

