BEGIN
  dbms_output.put_line('for loop: 1 .. 3');
  FOR i IN 1 .. 3
  LOOP
    dbms_output.put_line(i);
  END LOOP;

  dbms_output.put_line('for loop: 3 .. 1');
  FOR i IN REVERSE 1 .. 3
  LOOP
    dbms_output.put_line(i);
  END LOOP;
  
    dbms_output.put_line('for loop: 3 .. 3');
  FOR i IN REVERSE 3 .. 3
  LOOP
    dbms_output.put_line(i);
  END LOOP;
END;
