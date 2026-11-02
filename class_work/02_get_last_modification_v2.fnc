CREATE OR REPLACE FUNCTION get_last_modification(p_table_code IN NUMBER)
  RETURN DATE IS
  v_max_mod_date DATE;
BEGIN
  CASE
    WHEN p_table_code = 1 THEN
      SELECT MAX(p.last_modfiied) INTO v_max_mod_date FROM person p;
    WHEN p_table_code = 2 OR p_table_code < 0 THEN
      SELECT MAX(d.last_modfiied) INTO v_max_mod_date FROM dog d;
    WHEN p_table_code = 3 THEN
      SELECT MAX(v.created) INTO v_max_mod_date FROM vacc v;
    ELSE
      v_max_mod_date := NULL; -- redundant
  END CASE;

  RETURN v_max_mod_date;
END get_last_modification;
/
