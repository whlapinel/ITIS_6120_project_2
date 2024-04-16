use project_1;

DROP TRIGGER IF EXISTS audit_table_update_medical_records;

CREATE TRIGGER audit_table_update_medical_records
    AFTER UPDATE ON project_1.medical_records
    FOR EACH ROW
    BEGIN
        INSERT INTO audit_table (table_name, item_id, operation_type, old_val, new_val, user, time_date)
            VALUES (
                    'medical_records',
                    OLD.record_id,
                    'UPDATE',
                    CONCAT_WS(',', CONCAT('provider_id:', OLD.provider_id), CONCAT('facility_id:', OLD.facility_id), OLD.symptoms, OLD.diagnosis, OLD.discharge_date, OLD.treatment_plan),
                    CONCAT_WS(',', CONCAT('provider_id:', NEW.provider_id), CONCAT('facility_id:', NEW.facility_id), NEW.symptoms, NEW.diagnosis, NEW.discharge_date, NEW.treatment_plan),
                    USER(),
                    NOW()
                   );
    end;