PROMPT Creating user TERMEK_NYILVANTARTO...

----------------------------------
-- 1. Create user, add grants   --
----------------------------------
DECLARE
  CURSOR cur IS
    SELECT 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || '''' AS command
      FROM v$session
     WHERE username = 'TERMEK_NYILVANTARTO';
BEGIN
  FOR c IN cur LOOP
    EXECUTE IMMEDIATE c.command;
  END LOOP;
END;
/

DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_users t WHERE t.username='TERMEK_NYILVANTARTO';
  IF v_count = 1 THEN 
    EXECUTE IMMEDIATE 'DROP USER TERMEK_NYILVANTARTO CASCADE';
  END IF;
END;
/

CREATE USER TERMEK_NYILVANTARTO 
  IDENTIFIED BY "12345678" 
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO TERMEK_NYILVANTARTO;
GRANT CREATE TABLE TO TERMEK_NYILVANTARTO;
GRANT CREATE VIEW TO TERMEK_NYILVANTARTO;
GRANT CREATE SEQUENCE TO TERMEK_NYILVANTARTO;
GRANT CREATE PROCEDURE TO TERMEK_NYILVANTARTO;
GRANT CREATE TYPE TO TERMEK_NYILVANTARTO;

ALTER SESSION SET CURRENT_SCHEMA=TERMEK_NYILVANTARTO;

PROMPT Done.

PROMPT Done.

PROMPT Creating tables...

CREATE TABLE bolt(
  id  NUMBER        NOT NULL,
  nev VARCHAR2(250) NOT NULL,
  cim VARCHAR2(500) NOT NULL
) TABLESPACE users;

ALTER TABLE bolt
  ADD CONSTRAINT bolt_pk PRIMARY KEY (id);

CREATE TABLE termek(
  id         NUMBER         NOT NULL,
  megnevezes VARCHAR2(250)  NOT NULL,
  reszletek  VARCHAR2(2000)
) TABLESPACE users;

ALTER TABLE termek
  ADD CONSTRAINT termek_pk PRIMARY KEY (id);

CREATE TABLE bolt_termek(
  id        NUMBER NOT NULL,
  bolt_id   NUMBER NOT NULL,
  termek_id NUMBER NOT NULL,
  egysegar  NUMBER NOT NULL,
  keszlet   NUMBER NOT NULL
) TABLESPACE users;

ALTER TABLE bolt_termek
  ADD CONSTRAINT bolt_termek_pk PRIMARY KEY (id);

ALTER TABLE bolt_termek
  ADD CONSTRAINT bt_bolt_fk FOREIGN KEY (bolt_id) REFERENCES bolt(id);

ALTER TABLE bolt_termek
  ADD CONSTRAINT bt_termek_fk FOREIGN KEY (termek_id) REFERENCES termek(id);

ALTER TABLE bolt_termek
  ADD CONSTRAINT bt_uk UNIQUE (bolt_id, termek_id);

PROMPT Done.

PROMPT Loading tables with test data...

-- Boltok (12300-tól)
INSERT INTO bolt(id, nev, cim) VALUES (12300, 'Szuper Diszkont', 'Budapest, Fő utca 1.');
INSERT INTO bolt(id, nev, cim) VALUES (12301, 'Sarki Kisbolt', 'Pécs, Alma utca 5.');
INSERT INTO bolt(id, nev, cim) VALUES (12302, 'Nagy ABC', 'Debrecen, Piac utca 12.');

-- Termékek (9000-től)
INSERT INTO termek(id, megnevezes, reszletek) VALUES (9000, 'Tej', '1.5% zsírtartalom, 1 liter');
INSERT INTO termek(id, megnevezes, reszletek) VALUES (9001, 'Kenyér', 'Félbarna, szeletelt, 500g');
INSERT INTO termek(id, megnevezes, reszletek) VALUES (9002, 'Ásványvíz', 'Szénsavmentes, 1.5 liter');
INSERT INTO termek(id, megnevezes, reszletek) VALUES (9003, 'Alma', 'Jonagold, 1 kg');

-- Készlet / Árak (10000-től)
INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet) 
VALUES (10000, 12300, 9000, 350, 120);

INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet) 
VALUES (10001, 12300, 9001, 550, 45);

INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet) 
VALUES (10002, 12301, 9000, 400, 30);

INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet) 
VALUES (10003, 12301, 9002, 150, 200);

INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet) 
VALUES (10004, 12302, 9003, 600, 50);

COMMIT;

PROMPT Done.