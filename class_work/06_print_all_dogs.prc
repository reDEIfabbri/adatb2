CREATE OR REPLACE PROCEDURE print_all_dogs IS
  CURSOR cur IS
    SELECT * FROM dog d;

  v_dog_row cur%ROWTYPE;

  PROCEDURE print_isopen IS
  BEGIN
    IF cur%ISOPEN
    THEN
      dbms_output.put_line('cursor is opened');
    ELSE
      dbms_output.put_line('cursor is NOT opened');
    END IF;
  END print_isopen;
BEGIN
  print_isopen();
  OPEN cur;
  print_isopen();

  LOOP
    FETCH cur
      INTO v_dog_row;
  
    EXIT WHEN cur%NOTFOUND;
  
    dbms_output.put_line(v_dog_row.dog_name);
  END LOOP;

  print_isopen();
  CLOSE cur;
  print_isopen();
END print_all_dogs;
/
