
-- PROJECT 1 SUPPORTING QUERIES:

-- SPEC A: Should allow users to enter:

-- Patient demographic information (including address and insurance)

-- SUPPORTING QUERY 1: Insert patient demographic information
INSERT INTO patients (full_name, date_of_birth, address, gender, insurance_provider, contact_number)
VALUES ('Alice Johnson', '1990-05-15', '123 Main St, Springfield', 'female', 'HealthPlus Insurances', '555-0201');

-- SPEC B: Provider information (including specialty)

-- SUPPORTING QUERY 2: Insert provider information
INSERT INTO providers (full_name, specialty, contact_number, room_number)
VALUES ('Dr. Sarah Lee', 'Oncology', '555-0301', '201');

-- SPEC C: Visit information (including time and facility)

-- SUPPORTING QUERY 3: Record an appointment
INSERT INTO appointments (patient_id, provider_id, facility_id, appointment_date, appointment_time)
VALUES (1, 1, 1, '2024-03-01', '09:00:00');

-- SUPPORTING QUERY 4: Record a visit (regardless of whether patient had an appointment)
INSERT INTO medical_records (patient_id, provider_id, visit_id, facility_id, discharge_date, symptoms, diagnosis, treatment_plan)
VALUES (1, 3, 2, 1, '2024-03-02', 'Cough and fever', 'Common Cold', 'Rest');

-- SPEC D: Clinical  care  information  (including  recording  of  signs  and  symptoms,  discharge diagnosis and prescriptions, and orders and results of exams, tests, and procedures)

-- SUPPORTING QUERY: Record care information for a patient visit (satisfied by above query for recording a visit, please refer to query above) 

-- SPEC E: Other pertinent information depending on scenarios, for example, clinics will need to manage  appointments  and  exam  rooms,  emergency  department  will  need  to  manage information about beds. All clinics will also need to manage supplies and billing

-- SUPPORTING QUERY 5: Record a prescription
INSERT INTO prescriptions (record_id, medication, dosage, instructions)
VALUES (1, 'Tylenol', '500mg', 'Take with food once a day');

-- SUPPORTING QUERY 6: Record results of a vision test
INSERT INTO vision_tests (record_id, test_type, test_date, result)
VALUES (1, 'Visual Acuity', '2024-03-02', '20/20');

-- SUPPORTING QUERY 7: Record an invoice
INSERT INTO invoices (visit_id, total_amount, customer_portion, paid_by_customer, insurance_portion, paid_by_insurance, date_issued)
VALUES (1, 100.00, 50.00, 50.00, 50.00, 50.00, '2024-03-02');

-- SUPPORTING QUERY 8: Update quantity of inventory item
UPDATE inventory
SET quantity = 10
WHERE inventory_id = 1;

-- SPEC F: Your database should support editing of existing records to correct data entry mistakes or legitimate changes of information (e.g. change of address or insurance).

-- SUPPORTING QUERY 9: Update patient demographic information
UPDATE patients 
SET address = '456 Elm St, Springfield' 
WHERE patient_id = 2;

-- SPEC G: searching of patient records based on name, ID, and possibly other information such as visit dates.

-- SUPPORTING QUERY 10: Search for patients based on name
SELECT * 
FROM patients 
WHERE full_name = 'John Doe';

-- SUPPORTING QUERY 11: Search for patients based on ID
SELECT * 
FROM patients 
WHERE patient_id = 2;

-- SUPPORTING QUERY 12: search for records based on visit date:
SELECT * 
FROM patients 
JOIN medical_records ON patients.patient_id = medical_records.patient_id
JOIN visits ON medical_records.visit_id = visits.visit_id
WHERE visits.visit_date = '2024-03-25';

-- SPEC H: Your database should support reporting functions such as listing of all patients who satisfy certain  selection  criteria,  such  as  those  who  have  been  given  certain  diagnosis,  or  who visited on certain days, or who have been seen by certain doctor, or combinations of these such  as,  the  diagnoses  of  patients  who  visited  the  clinic  twice  within  the  shortest  time interval.

-- SUPPORTING QUERY 13: List all patients who have been given a certain diagnosis
SELECT *
FROM patients
JOIN medical_records ON patients.patient_id = medical_records.patient_id
WHERE medical_records.diagnosis = 'Myopia';

-- SUPPORTING QUERY 14: List all patients who visited on certain days
SELECT *
FROM patients
JOIN medical_records ON patients.patient_id = medical_records.patient_id
JOIN visits on medical_records.visit_id = visits.visit_id
WHERE visits.visit_date = '2024-03-25';

-- SUPPORTING QUERY 15: List all patients who have been seen by a certain doctor
SELECT *
FROM patients
JOIN medical_records ON patients.patient_id = medical_records.patient_id
JOIN providers ON medical_records.provider_id = providers.provider_id
WHERE providers.full_name = 'Dr. Alice Henderson';

-- SUPPORTING QUERY 16: List all patients who have visited the clinic twice within the shortest time interval

SELECT medical_records.diagnosis AS 'Diagnosis', COUNT(*) AS 'Count'
FROM medical_records
JOIN visits ON medical_records.visit_id = visits.visit_id
GROUP BY medical_records.diagnosis
ORDER BY COUNT(*) DESC

