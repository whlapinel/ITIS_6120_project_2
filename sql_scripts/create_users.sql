

use project_2;

drop user if exists 'provider'@'%';

create user 'provider'@'%' identified by 'password';

grant select, insert, update, delete on project_2.* to 'provider'@'%';

drop user if exists 'receptionist'@'%';

create user 'receptionist'@'%' identified by 'password';

grant select, insert, update, delete on project_2.appointments to 'receptionist'@'%';

grant select on project_2.prescriptions to 'receptionist'@'%';

flush privileges;