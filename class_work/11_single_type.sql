DECLARE
  v_vacc ty_vacc_type;
BEGIN
  SELECT ty_vacc_type(t.vacc_type_id, -- vacc_type_id
                      t.vacc_name -- vacc_name
                      )
    INTO v_vacc
    FROM vacc_type t
   WHERE t.vacc_type_id = 'A01';

  dbms_output.put_line('type id = ' || v_vacc.vacc_type_id || ', name = ' ||
                       v_vacc.vacc_name);
END;
