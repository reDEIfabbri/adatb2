CREATE OR REPLACE PACKAGE pkg_my_package IS

  gv_increment NUMBER;

  FUNCTION next_number RETURN NUMBER;

END pkg_my_package;
/
CREATE OR REPLACE PACKAGE BODY pkg_my_package IS

  gv_number NUMBER;

  FUNCTION next_number RETURN NUMBER IS
  BEGIN
    gv_number := gv_number + gv_increment;
  
    RETURN gv_number;
  END next_number;

-- Initialization
BEGIN
  IF gv_increment IS NULL
  THEN
    dbms_output.put_line('Initializating gv_increment');
  
    gv_increment := 1;
  END IF;

  gv_number := 0;

END pkg_my_package;
/
