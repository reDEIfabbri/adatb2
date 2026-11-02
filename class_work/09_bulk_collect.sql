DECLARE
  v_list ty_vacc_type_l;
BEGIN
  SELECT ty_vacc_type(t.vacc_type_id, -- vacc_type_id
                      t.vacc_name -- vacc_name
                      )
    BULK COLLECT
    INTO v_list
    FROM vacc_type t;

  FOR i IN 1 .. v_list.count
  LOOP
    dbms_output.put_line('type id = ' || v_list(i).vacc_type_id ||
                         ', name = ' || v_list(i).vacc_name);
  END LOOP;
END;
