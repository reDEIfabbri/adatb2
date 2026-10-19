DECLARE
  v_min NUMBER;
  v_max NUMBER;
  v_avg NUMBER;
BEGIN
  -- Call the procedure
  all_dog_details(p_min_weight => v_min,
                  p_max_weight => v_max,
                  p_avg_weight => v_avg);

  dbms_output.put_line('min: ' || v_min || chr(10) || 'max: ' || v_max ||
                       chr(10) || 'avg: ' || v_avg);
END;
