CREATE PROCEDURE make_appt (
    IN p_date DATE,
    IN p_patient_id int,
    IN p_provider_id int,
    IN p_facility_id int,
    IN p_time time
)
BEGIN
    DECLARE appointment_id int;
    INSERT INTO appointments (patient_id, provider_id, facility_id, appointment_date, appointment_time)
    VALUES (p_patient_id, p_provider_id, p_facility_id, p_date, p_time);

    -- Get the auto-generated appointment_id
    SELECT LAST_INSERT_ID() INTO appointment_id;

    -- Output the appointment_id
    SELECT appointment_id AS new_appointment_id;
end;

CREATE PROCEDURE record_visit (
    IN p_patient_id int,
    IN p_provider_id int,
    IN p_facility_id int,
    IN p_date date,
    IN p_time time
)
BEGIN
    DECLARE visit_id int;
    INSERT into visits (patient_id, provider_id, facility_id, visit_date, visit_time)
    VALUES (p_patient_id, p_provider_id, p_facility_id, p_date, p_time);

    SELECT LAST_INSERT_ID() INTO visit_id;

    SELECT visit_id as new_visit_id;
end;

# record exam results
CREATE PROCEDURE record_test_results (
    IN p_record_id int,
    IN p_test_type varchar(255),
    IN p_test_date date,
    IN p_result varchar(255)
)
BEGIN
    DECLARE v_test_id int;
    INSERT into vision_tests (record_id, test_type, test_date, result)
        VALUES (p_record_id, p_test_type, p_test_date, p_result);

    SELECT LAST_INSERT_ID() INTO v_test_id;

    SELECT v_test_id as new_test_id;
end;

# create patient
CREATE PROCEDURE create_patient (
    IN p_full_name text,
    IN p_dob date,
    IN p_address text,
    IN p_gender varchar(255),
    IN p_insurance text,
    IN p_contact_no varchar(255)
)
BEGIN
    DECLARE v_patient_id int;
    INSERT into patients (full_name, date_of_birth, address, gender, insurance_provider, contact_number)
    VALUES (p_full_name, p_dob, p_address, p_gender, p_insurance, p_contact_no);

    SELECT LAST_INSERT_ID() INTO v_patient_id;

    SELECT v_patient_id as new_patient_id;
end;

CREATE PROCEDURE create_prescription (
    IN p_record_id int,
    IN p_medication varchar(255),
    IN p_dosage varchar(255),
    IN p_instructions text
)
BEGIN
    DECLARE v_prescription_id int;
    INSERT into prescriptions (record_id, medication, dosage, instructions)
        VALUES (p_record_id, p_medication, p_dosage, p_instructions);
    SELECT LAST_INSERT_ID() INTO v_prescription_id;
    SELECT v_prescription_id as new_prescription_id;
end;