DECLARE
  TYPE ty_test_type IS TABLE OF VARCHAR2(200) INDEX BY VARCHAR2(40);

  v_var ty_test_type;
  v_idx VARCHAR2(40);
BEGIN
  FOR i IN (SELECT * FROM vacc_type)
  LOOP
    v_var(i.vacc_type_id) := i.vacc_name;
  END LOOP;

  v_idx := v_var.first;
  WHILE (v_idx IS NOT NULL)
  LOOP
    dbms_output.put_line(v_idx || ', name = ' || v_var(v_idx));
  
    v_idx := v_var.next(v_idx);
  END LOOP;
END;
