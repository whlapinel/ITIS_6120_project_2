-- DO NOT MAKE CHANGES DIRECTLY TO THIS FILE!  THIS IS SOURCED FROM CONSTITUENT FILES!

-- DO NOT MAKE CHANGES DIRECTLY TO THIS FILE!  THIS IS SOURCED FROM CONSTITUENT FILES!



DROP DATABASE IF EXISTS project_2;

-- Create the project_2 database if it doesn't exist
CREATE DATABASE IF NOT EXISTS project_2;

use project_2;

-- Create patients table
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    address TEXT NOT NULL,
    gender VARCHAR(255) NOT NULL,
    insurance_provider text not null,
    contact_number VARCHAR(255) NOT NULL
);

-- Create providers table
CREATE TABLE providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name TEXT NOT NULL,
    specialty VARCHAR(255) NOT NULL,
    contact_number VARCHAR(255) NOT NULL,
    room_number VARCHAR(255) NOT NULL
);

-- Create facilities table
CREATE TABLE facilities (
	facility_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_name VARCHAR(255) NOT NULL,
    address text NOT NULL
    );
    
-- Create appointments table
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    facility_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    foreign key (facility_id) references facilities(facility_id),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

-- Create visits table
CREATE TABLE visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    facility_id INT NOT NULL,
    visit_date DATE NOT NULL,
    visit_time TIME NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);


-- Create medical_records table
CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    visit_id INT NOT NULL,
    facility_id INT NOT NULL,
    discharge_date DATE NOT NULL, 
    symptoms TEXT,
    diagnosis VARCHAR(255),
    treatment_plan TEXT,
    foreign key (facility_id) references facilities(facility_id),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- Create prescriptions table
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    medication VARCHAR(255) NOT NULL,
    dosage VARCHAR(255) NOT NULL,
    instructions TEXT NOT NULL,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
);

-- Create vision_tests table
CREATE TABLE vision_tests (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    test_type VARCHAR(255) NOT NULL,
    test_date DATE NOT NULL,
    result VARCHAR(255) NOT NULL,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
);


-- Create equipment table
CREATE TABLE equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_name VARCHAR(255) NOT NULL,
    purchase_date DATE NOT NULL,
    room_number VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL,
    facility_id INT NOT NULL,
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

-- Create inventory table
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    reorder_level INT NOT NULL,
    last_ordered_date DATE NOT NULL
);

-- Create staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    contact_number VARCHAR(255) NOT NULL,
    schedule VARCHAR(255) NOT NULL
);

-- Create invoices table
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    customer_portion DECIMAL(10,2),
    paid_by_customer DECIMAL(10,2),
    insurance_portion DECIMAL(10,2),
    paid_by_insurance DECIMAL(10,2),
    date_issued DATE NOT NULL,
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- create audit table

CREATE TABLE audit_table (
    audit_id int primary key auto_increment,
    table_name text,
    item_id int,
    operation_type text,
    old_val text,
    new_val text,
    user text,
    time_date datetime
);


use project_2;

CREATE INDEX idx_appointment_date_facility_id ON appointments(appointment_date, facility_id);

CREATE INDEX idx_patient_facility ON medical_records(patient_id, facility_id);



use project_2;

DELIMITER //

DROP TRIGGER IF EXISTS audit_table_update_medical_records;

CREATE TRIGGER audit_table_update_medical_records
    AFTER UPDATE ON project_2.medical_records
    FOR EACH ROW
    BEGIN
        INSERT INTO audit_table (table_name, item_id, operation_type, old_val, new_val, user, time_date)
            VALUES (
                    'medical_records',
                    OLD.record_id,
                    'UPDATE',
                    CONCAT_WS(',', CONCAT('provider_id:', OLD.provider_id), CONCAT('facility_id:', OLD.facility_id),
                              OLD.symptoms, OLD.diagnosis, OLD.discharge_date, OLD.treatment_plan),
                    CONCAT_WS(',', CONCAT('provider_id:', NEW.provider_id), CONCAT('facility_id:', NEW.facility_id),
                              NEW.symptoms, NEW.diagnosis, NEW.discharge_date, NEW.treatment_plan),
                    USER(),
                    NOW()
                   );
    END //

    
drop user if exists 'provider'@'%';

create user 'provider'@'%' identified by 'password';

grant select, insert, update, delete on project_2.* to 'provider'@'%';

drop user if exists 'receptionist'@'%';

create user 'receptionist'@'%' identified by 'password';

grant select, insert, update, delete on project_2.appointments to 'receptionist'@'%';

grant select on project_2.prescriptions to 'receptionist'@'%';

flush privileges;


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


drop view if exists upcoming_appointments;

create view upcoming_appointments AS
select a.appointment_date, a.appointment_time, f.facility_name, p.full_name from appointments a
Join patients  p ON a.patient_id = p.patient_id
JOIN facilities f ON a.facility_id = f.facility_id
WHERE appointment_date >= CURDATE()
ORDER BY appointment_date;




use project_2;

DELIMITER //

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
END //

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
END //

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
END //

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
END //

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
END //



USE project_2;

-- Insert into patients
INSERT INTO patients (full_name, date_of_birth, address, gender, insurance_provider, contact_number)
VALUES 
('John Doe', '1980-04-12', '123 Elm St, Springfield', 'Male', 'HealthCarePlus', '555-0101'),
('Jane Smith', '1992-08-25', '456 Maple Ave, Springfield', 'Female', 'BestLife', '555-0102'),
('Emily Johnson', '1975-02-09', '789 Pine St, Springfield', 'Female', 'WellnessIns', '555-0103'),
('Michael Brown', '1988-05-17', '101 Oak Rd, Springfield', 'Male', 'SecureHealth', '555-0104'),
('Chloe Davis', '2000-12-30', '234 Cedar Ln, Springfield', 'Female', 'MediCare', '555-0105'),
('Lucas Miller', '1995-07-21', '567 Birch Pl, Springfield', 'Male', 'HealthCarePlus', '555-0106'),
('Madison Wilson', '1983-03-14', '890 Spruce Way, Springfield', 'Female', 'BestLife', '555-0107'),
('Ethan Moore', '2003-09-05', '321 Aspen Cir, Springfield', 'Male', 'WellnessIns', '555-0108'),
('Sophia Taylor', '1969-11-13', '654 Redwood Blvd, Springfield', 'Female', 'SecureHealth', '555-0109'),
('Aiden Martinez', '2001-06-24', '987 Willow Dr, Springfield', 'Male', 'MediCare', '555-0110');

-- Insert into providers
INSERT INTO providers (full_name, specialty, contact_number, room_number)
VALUES 
('Dr. Alice Henderson', 'Optometrist', '555-0201', '101'),
('Dr. Bob Jackson', 'Ophthalmologist', '555-0202', '102'),
('Dr. Caroline King', 'Optometrist', '555-0203', '103'),
('Dr. David Lee', 'Ophthalmologist', '555-0204', '104'),
('Dr. Emma Harris', 'Optometrist', '555-0205', '105'),
('Dr. Frank Clark', 'Ophthalmologist', '555-0206', '106'),
('Dr. Georgia Lewis', 'Optometrist', '555-0207', '107'),
('Dr. Henry Walker', 'Ophthalmologist', '555-0208', '108'),
('Dr. Isabella Scott', 'Optometrist', '555-0209', '109'),
('Dr. James Adams', 'Ophthalmologist', '555-0210', '110');

-- Insert into facilities
INSERT INTO facilities (facility_name, address)
VALUES 
('Springfield Eye Center', '123 Health St, Springfield'),
('Vision Plus Clinic', '456 Vision Rd, Springfield'),
('Optima Eye Care', '789 Sight Ln, Springfield'),
('Premier Eye Hospital', '101 Gaze Ave, Springfield'),
('Focus Eye Clinic', '234 Lookout Blvd, Springfield'),
('Insight Eye Care', '567 Observer Rd, Springfield'),
('Eagle Eye Clinic', '890 Hawk St, Springfield'),
('Horizon Eye Care', '321 Vista Cir, Springfield'),
('Sightline Eye Center', '654 Viewpoint Dr, Springfield'),
('Clarity Eye Hospital', '987 Perspective Pl, Springfield');

-- Dummy data for appointments, medical_records, prescriptions, vision_tests, equipment, inventory, staff, visits, invoices will follow a similar pattern:
-- For example, appointments:
INSERT INTO appointments (patient_id, provider_id, facility_id, appointment_date, appointment_time)
VALUES
(1, 1, 1, '2024-03-25', '09:00:00'),
(2, 2, 2, '2024-03-26', '10:00:00'),
(3, 3, 3, '2024-03-27', '11:00:00'),
(4, 4, 4, '2024-03-28', '12:00:00'),
(5, 5, 5, '2024-03-29', '14:00:00'),
(6, 6, 6, '2024-03-30', '15:00:00'),
(7, 7, 7, '2024-03-31', '16:00:00'),
(8, 8, 8, '2024-04-01', '09:00:00'),
(9, 9, 9, '2024-04-02', '10:00:00'),
(10, 10, 10, '2024-04-03', '11:00:00'),
(1, 1, 1, '2024-05-25', '09:00:00'),
(2, 2, 2, '2024-06-26', '10:00:00'),
(3, 3, 3, '2024-07-27', '11:00:00');




-- Insert into visits
-- Assuming each patient has a visit corresponding to their appointment for simplicity
INSERT INTO visits (patient_id, provider_id, facility_id, visit_date, visit_time)
VALUES 
(1, 1, 1, '2024-03-25', '09:00:00'),
(2, 2, 2, '2024-03-26', '10:00:00'),
(3, 3, 3, '2024-03-27', '11:00:00'),
(4, 4, 4, '2024-03-28', '12:00:00'),
(5, 5, 5, '2024-03-29', '14:00:00'),
(6, 6, 6, '2024-03-30', '15:00:00'),
(7, 7, 7, '2024-03-31', '16:00:00'),
(8, 8, 8, '2024-04-01', '09:00:00'),
(9, 9, 9, '2024-04-02', '10:00:00'),
(10, 10, 10, '2024-04-03', '11:00:00');

-- Insert into medical_records
INSERT INTO medical_records (patient_id, provider_id, visit_id, facility_id, discharge_date, symptoms, diagnosis, treatment_plan)
VALUES 
(1, 1, 1, 1, '2024-03-25', 'Blurry vision', 'Myopia', 'Prescribed corrective lenses.'),
(2, 2, 2, 2, '2024-03-26', 'Eye irritation', 'Dry Eye Syndrome', 'Prescribed eye drops.'),
(3, 3, 3, 3, '2024-03-27', 'Difficulty reading', 'Hyperopia', 'Prescribed reading glasses.'),
(4, 4, 4, 4, '2024-03-28', 'Headaches and eye strain', 'Astigmatism', 'Corrective lenses recommended.'),
(5, 5, 5, 5, '2024-03-29', 'Red eyes', 'Conjunctivitis', 'Antibiotic eye drops prescribed.'),
(6, 6, 6, 6, '2024-03-30', 'Sudden vision loss', 'Retinal detachment', 'Urgent surgical intervention recommended.'),
(7, 7, 7, 7, '2024-03-31', 'Cloudy vision', 'Cataract', 'Cataract surgery suggested.'),
(8, 8, 8, 8, '2024-04-01', 'Floaters in vision', 'Vitreous detachment', 'Monitoring and possible laser treatment.'),
(9, 9, 9, 9, '2024-04-02', 'Glare and halos around lights', 'Cataracts', 'Cataract surgery.'),
(10, 10, 10, 10, '2024-04-03', 'Eye pain and nausea', 'Acute angle-closure glaucoma', 'Immediate medical treatment required.');

-- Insert into prescriptions
INSERT INTO prescriptions (record_id, medication, dosage, instructions)
VALUES 
(1, 'Corrective Lenses', 'N/A', 'Wear as needed.'),
(2, 'Artificial Tears', 'Two drops', 'Apply every 4 hours.'),
(3, 'Reading Glasses', 'N/A', 'Use for reading and close work.'),
(4, 'Corrective Lenses', 'N/A', 'Wear constantly.'),
(5, 'Antibiotic Eye Drops', 'One drop', 'Apply every 6 hours for 7 days.'),
(6, 'N/A', 'N/A', 'Immediate surgery, no medications prescribed.'),
(7, 'N/A', 'N/A', 'Post-surgery, follow up for medication.'),
(8, 'N/A', 'N/A', 'No medication, monitoring recommended.'),
(9, 'N/A', 'N/A', 'Post-surgery, follow up for medication.'),
(10, 'Antiglaucoma Medication', 'As per label', 'Take as prescribed until surgery.');

-- Insert into vision_tests
INSERT INTO vision_tests (record_id, test_type, test_date, result)
VALUES 
(1, 'Visual Acuity Test', '2024-03-25', '20/40'),
(2, 'Tear Film Evaluation', '2024-03-26', 'Normal'),
(3, 'Refraction Test', '2024-03-27', '+2.00 in both eyes'),
(4, 'Visual Acuity Test', '2024-03-28', '20/30 with correction'),
(5, 'Slit Lamp Examination', '2024-03-29', 'Mild Conjunctivitis'),
(6, 'Ultrasound Imaging', '2024-03-30', 'Retinal Detachment Confirmed'),
(7, 'Cataract Detection', '2024-03-31', 'Moderate Cataract'),
(8, 'Floaters Assessment', '2024-04-01', 'Mild floaters'),
(9, 'Glare Testing', '2024-04-02', 'Significant impairment'),
(10, 'Intraocular Pressure Test', '2024-04-03', 'Elevated pressure');

-- Insert into equipment
INSERT INTO equipment (equipment_name, purchase_date, room_number, status, facility_id)
VALUES 
('Phoropter', '2020-05-15', '101', 'Operational', 1),
('Slit Lamp', '2019-11-30', '102', 'Operational', 2),
('Tonometer', '2021-01-20', '103', 'Operational', 3),
('Ophthalmoscope', '2022-02-25', '104', 'Operational', 4),
('Retinoscope', '2020-07-09', '105', 'Operational', 5),
('Autorefractor', '2021-09-15', '106', 'Operational', 6),
('Visual Field Tester', '2019-12-05', '107', 'Operational', 7),
('Fundus Camera', '2023-01-10', '108', 'Operational', 8),
('Specular Microscope', '2020-03-22', '109', 'Operational', 9),
('LASIK Equipment', '2022-06-18', '110', 'Operational', 10);

-- Insert into inventory
INSERT INTO inventory (item_name, quantity, reorder_level, last_ordered_date)
VALUES 
('Contact Lens Solution', 50, 10, '2024-03-01'),
('Eyeglass Frames', 100, 20, '2024-02-15'),
('Disposable Contact Lenses', 200, 50, '2024-01-25'),
('Eye Drops', 150, 30, '2024-03-10'),
('Surgical Kits', 25, 5, '2023-12-20'),
('Antibiotic Eye Drops', 45, 10, '2024-02-28'),
('Sterile Gloves', 500, 100, '2024-03-05'),
('Lens Cleaner', 75, 15, '2024-02-20'),
('Sunglasses', 60, 12, '2024-03-15'),
('Reading Glasses', 80, 16, '2024-02-10');

-- Insert into staff
INSERT INTO staff (full_name, role, contact_number, schedule)
VALUES 
('Liam Neeson', 'Receptionist', '555-0301', 'Weekdays 9am-5pm'),
('Olivia Wilde', 'Nurse', '555-0302', 'Weekdays 9am-5pm'),
('Noah Centineo', 'Technician', '555-0303', 'Weekdays 9am-5pm'),
('Emma Stone', 'Billing Specialist', '555-0304', 'Weekdays 9am-5pm'),
('Mason Mount', 'Optician', '555-0305', 'Weekdays 9am-5pm'),
('Ava DuVernay', 'Administrative Assistant', '555-0306', 'Weekdays 9am-5pm'),
('James Franco', 'Facility Manager', '555-0307', 'Weekdays 9am-5pm'),
('Isabella Rossellini', 'Ophthalmic Nurse', '555-0308', 'Weekdays 9am-5pm'),
('Ethan Hawke', 'Optometrist Assistant', '555-0309', 'Weekdays 9am-5pm'),
('Sophia Loren', 'Customer Service Rep', '555-0310', 'Weekdays 9am-5pm');



-- Insert into invoices
-- Assuming a simple cost structure for demonstration
INSERT INTO invoices (visit_id, total_amount, customer_portion, paid_by_customer, insurance_portion, paid_by_insurance, date_issued)
VALUES 
(1, 200.00, 20.00, 20.00, 180.00, 100.00, '2024-03-25'),
(2, 150.00, 15.00, 15.00, 135.00, 135.00, '2024-03-26'),
(3, 180.00, 18.00, 00.00, 162.00, 162.00, '2024-03-27'),
(4, 220.00, 22.00, 22.00, 198.00, 198.00, '2024-03-28'),
(5, 250.00, 25.00, 25.00, 225.00, 100.00, '2024-03-29'),
(6, 300.00, 30.00, 30.00, 270.00, 270.00, '2024-03-30'),
(7, 350.00, 35.00, 35.00, 315.00, 315.00, '2024-03-31'),
(8, 400.00, 40.00, 40.00, 360.00, 360.00, '2024-04-01'),
(9, 450.00, 45.00, 40.00, 405.00, 405.00, '2024-04-02'),
(10, 500.00, 50.00, 50.00, 450.00, 450.00, '2024-04-03');

# make_appt
-- call the procedure
CALL make_appt(DATE(NOW()), 1, 1, 1, TIME(NOW()));
-- verify the row is correct
SELECT * from appointments where appointment_id = LAST_INSERT_ID();
-- cleanup
DELETE from appointments where appointment_id = LAST_INSERT_ID();

# record_visit
-- call the procedure
CALL record_visit(1, 1, 1, DATE(NOW()), TIME(NOW()));
-- verify the row is correct
SELECT * from visits where visit_id = LAST_INSERT_ID();
-- cleanup
DELETE from visits where visit_id = LAST_INSERT_ID();

# record test results
-- call the procedure
CALL record_test_results(1, 'eye exam', DATE(NOW()), '20/20' );
-- verify the row is correct
SELECT * from vision_tests where test_id = LAST_INSERT_ID();
-- cleanup
DELETE from vision_tests where test_id = LAST_INSERT_ID();

# create patient
-- call the procedure
CALL create_patient('Hal Leonard', '2003-01-20', '123 Main Street', 'Male', 'Blue Shield', '555-555-5555');
-- verify the row is correct
SELECT * from patients where patient_id = LAST_INSERT_ID();
-- cleanup
DELETE from patients where patient_id = LAST_INSERT_ID();

# test audit_table_update: update medical record trigger
UPDATE medical_records SET symptoms = 'test change' where record_id = 1;
UPDATE medical_records SET symptoms = 'Blurry vision' where record_id = 1;
SELECT * FROM audit_table;



use project_2;

select * from outstanding_invoices;

select * from upcoming_appointments;



