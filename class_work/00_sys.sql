PROMPT Creating user DOG_MANAGER...

----------------------------------
-- 1. Create user, add grants   --
----------------------------------
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_users t WHERE t.username='DOG_MANAGER';
  IF v_count = 1 THEN 
    EXECUTE IMMEDIATE 'DROP USER dog_manager CASCADE';
  END IF;
END;
/
CREATE USER dog_manager 
  IDENTIFIED BY "12345678" 
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users
;

GRANT CREATE SESSION TO dog_manager;
GRANT CREATE TABLE TO dog_manager;
GRANT CREATE VIEW TO dog_manager;
GRANT CREATE SEQUENCE TO dog_manager;
GRANT CREATE PROCEDURE TO dog_manager;

PROMPT Done.
