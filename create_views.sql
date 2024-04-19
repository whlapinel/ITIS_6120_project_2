use project_2;

select i.*, p.*
from invoices i
left join visits v
on i.visit_id = v.visit_id
left join patients p
on v.patient_id = p.patient_id;

select a.appointment_date, a.appointment_time, f.facility_name, p.full_name from appointments a
Join patients  p ON a.patient_id = p.patient_id
JOIN facilities f ON a.facility_id = f.facility_id
ORDER BY appointment_date desc;

