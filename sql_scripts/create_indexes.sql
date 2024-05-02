
use project_2;

CREATE INDEX idx_appointment_date_facility_id ON appointments(appointment_date, facility_id);

CREATE INDEX idx_patient_facility ON medical_records(patient_id, facility_id);

