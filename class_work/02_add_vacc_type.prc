CREATE OR REPLACE PROCEDURE add_vacc_type(p_vacc_type_id VARCHAR2
                                         ,p_vacc_name    VARCHAR2) IS
BEGIN
  INSERT INTO vacc_type
    (vacc_type_id
    ,vacc_name)
  VALUES
    (p_vacc_type_id
    ,p_vacc_name);
END;
/
