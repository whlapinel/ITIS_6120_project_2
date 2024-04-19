use project_2;

create user 'provider'@'localhost' identified by 'password';

grant select, insert, update, delete on project_2.* to 'provider'@'localhost';

create user 'receptionist'@'localhost' identified by 'password';

grant select, insert, update, delete on project_2.appointments to 'receptionist'@'localhost';

flush privileges;