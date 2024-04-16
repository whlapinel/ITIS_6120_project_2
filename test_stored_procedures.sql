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

