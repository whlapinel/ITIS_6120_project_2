use project_1;

create user 'provider'@'localhost' identified by 'password';

grant select, insert, update, delete on project_1.* to 'provider'@'localhost';

create user 'receptionist'@'localhost' identified by 'password';

grant select, insert, update, delete on project_1.appointments to 'receptionist'@'localhost';

flush privileges;