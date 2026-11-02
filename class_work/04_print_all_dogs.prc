CREATE OR REPLACE PROCEDURE print_all_dogs IS
BEGIN
  FOR i IN (SELECT d.dog_name FROM dog d)
  LOOP
    dbms_output.put_line(i.dog_name);
  END LOOP;
END print_all_dogs;
/
