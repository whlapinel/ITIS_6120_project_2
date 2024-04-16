use project_1;

DROP TABLE IF EXISTS audit_table;

CREATE TABLE audit_table (
    audit_id int primary key auto_increment,
    table_name text,
    item_id int,
    operation_type text,
    old_val text,
    new_val text,
    user text,
    time_date datetime
)
