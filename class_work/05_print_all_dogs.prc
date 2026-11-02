CREATE OR REPLACE PROCEDURE print_all_dogs IS
  CURSOR cur IS
    SELECT d.dog_name FROM dog d;
BEGIN
  FOR i IN cur
  LOOP
    dbms_output.put_line(i.dog_name);
  END LOOP;
END print_all_dogs;
/
