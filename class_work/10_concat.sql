DECLARE
  v_list1 ty_vacc_type_l;
  v_list2 ty_vacc_type_l;

  v_result ty_vacc_type_l;
BEGIN
  SELECT ty_vacc_type(t.vacc_type_id, -- vacc_type_id
                      t.vacc_name -- vacc_name
                      )
    BULK COLLECT
    INTO v_list1
    FROM vacc_type t
   WHERE t.vacc_type_id LIKE '%B%';

  SELECT ty_vacc_type(t.vacc_type_id, -- vacc_type_id
                      t.vacc_name -- vacc_name
                      )
    BULK COLLECT
    INTO v_list2
    FROM vacc_type t
   WHERE t.vacc_type_id LIKE '%A%';

  v_result := v_list1 MULTISET UNION ALL v_list2;

  FOR i IN 1 .. v_result.count
  LOOP
    dbms_output.put_line('type id = ' || v_result(i).vacc_type_id ||
                         ', name = ' || v_result(i).vacc_name);
  END LOOP;
END;
