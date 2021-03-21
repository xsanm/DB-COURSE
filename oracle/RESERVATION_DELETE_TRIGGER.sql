create trigger RESERVATION_DELETE_TRIGGER
	after delete
	on RESERVATION
	for each row
BEGIN
    raise_application_error(-20001, 'FORBIDDEN: You have to change status istead of deleting');
end;
/

