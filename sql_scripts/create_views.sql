-- convert these statements to views

use project_2;

drop view if exists outstanding_invoices;

create view outstanding_invoices AS
select v.visit_date, i.customer_portion, i.paid_by_customer, i.insurance_portion, i.paid_by_insurance, p.full_name, p.contact_number, p.insurance_provider, (total_amount - (paid_by_insurance + paid_by_customer)) as outstanding_balance
from invoices i
left join visits v
on i.visit_id = v.visit_id
left join patients p
on v.patient_id = p.patient_id
where (total_amount - (paid_by_insurance + paid_by_customer)) > 0
order by visit_date;

-- test view
select * from outstanding_invoices;

drop view if exists upcoming_appointments;

create view upcoming_appointments AS
select a.appointment_date, a.appointment_time, f.facility_name, p.full_name from appointments a
Join patients  p ON a.patient_id = p.patient_id
JOIN facilities f ON a.facility_id = f.facility_id
WHERE appointment_date >= CURDATE()
ORDER BY appointment_date;

select * from upcoming_appointments;

