use project_2;
# test audit_table_update: update medical record trigger
UPDATE medical_records SET symptoms = 'test change' where record_id = 1;
UPDATE medical_records SET symptoms = 'Blurry vision' where record_id = 1;
SELECT * FROM audit_table;




