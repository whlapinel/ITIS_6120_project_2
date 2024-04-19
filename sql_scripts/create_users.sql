

use project_2;

create user 'provider'@'172.17.176.1' identified by 'password';

grant select, insert, update, delete on project_2.* to 'provider'@'172.17.176.1';

create user 'receptionist'@'172.17.176.1' identified by 'password';

grant select, insert, update, delete on project_2.appointments to 'receptionist'@'172.17.176.1';

flush privileges;