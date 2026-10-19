PROMPT Creating table PERSON...

CREATE TABLE person(
  person_id         NUMBER         NOT NULL PRIMARY KEY
 ,first_name        VARCHAR2(40)   NOT NULL
 ,last_name         VARCHAR2(40)   NOT NULL
 ,birth_date        DATE
 ,birth_place_city  VARCHAR2(100)
 ,loc_country_code  VARCHAR2(2)
 ,loc_city          VARCHAR2(100)
 ,loc_address       VARCHAR2(100)
 ,email             VARCHAR2(100)
 ,tel               VARCHAR2(20)
 ,last_modified     DATE           DEFAULT SYSDATE NOT NULL
 ,created           DATE           DEFAULT SYSDATE NOT NULL
) 
TABLESPACE users;

PROMPT Done.

PROMPT Creating tables...

CREATE TABLE dog(
  dog_id                          NUMBER         NOT NULL PRIMARY KEY
 ,breed_code                      CHAR(3)
 ,dog_name                        VARCHAR2(40)   NOT NULL
 ,father_id                       NUMBER
 ,mother_id                       NUMBER
 ,registration_number             VARCHAR2(40)
 ,birth_date                      DATE NOT NULL 
 ,birth_weight                    NUMBER(5,2)
 ,owner_id                        NUMBER
 ,last_modified                   DATE           DEFAULT SYSDATE NOT NULL
 ,created                         DATE           DEFAULT SYSDATE NOT NULL
) 
TABLESPACE users;

CREATE TABLE vacc(
  vacc_id                         NUMBER         NOT NULL PRIMARY KEY
 ,dog_id                          NUMBER         NOT NULL
 ,doctor_id                       NUMBER         NOT NULL
 ,type_of_vacc                    VARCHAR2(40)   NOT NULL
 ,date_of_vacc                    DATE           DEFAULT SYSDATE NOT NULL
 ,location_of_vacc                VARCHAR2(100)
 ,created                         DATE           DEFAULT SYSDATE NOT NULL
) 
TABLESPACE users;

PROMPT Done.

PROMPT Loading tables...
ALTER SESSION SET CURRENT_SCHEMA=dog_manager;

prompt Loading PERSON...
insert into PERSON (PERSON_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE, BIRTH_PLACE_CITY, LOC_COUNTRY_CODE, LOC_CITY, LOC_ADDRESS, EMAIL, TEL, LAST_MODIFIED, CREATED)
values (10, 'László', 'Tóth', to_date('23-10-1956', 'dd-mm-yyyy'), 'Karakószörcsök', 'HU', 'Veszprém', 'Vasút u. 21.', 'laszlo.toth@tot.hu', '0678123456', to_date('21-09-2016 15:03:53', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:03:53', 'dd-mm-yyyy hh24:mi:ss'));
insert into PERSON (PERSON_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE, BIRTH_PLACE_CITY, LOC_COUNTRY_CODE, LOC_CITY, LOC_ADDRESS, EMAIL, TEL, LAST_MODIFIED, CREATED)
values (2, 'István', 'Kovács', to_date('19-12-1991', 'dd-mm-yyyy'), 'Budapest XXII.', 'HU', 'Pécs', 'Gül Baba tér 19.', 'istvan.kovacs91@ggmmaaiill.com', '06317654321', to_date('21-09-2016 15:09:45', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:09:45', 'dd-mm-yyyy hh24:mi:ss'));
insert into PERSON (PERSON_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE, BIRTH_PLACE_CITY, LOC_COUNTRY_CODE, LOC_CITY, LOC_ADDRESS, EMAIL, TEL, LAST_MODIFIED, CREATED)
values (3, 'Nóra', 'Szabó-Eszterházy', to_date('10-01-2009', 'dd-mm-yyyy'), 'Pécs', 'EN', 'Brighton', null, 'norika2009@enternet.hu', '+4477987654321', to_date('21-09-2016 15:09:45', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:09:45', 'dd-mm-yyyy hh24:mi:ss'));
insert into PERSON (PERSON_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE, BIRTH_PLACE_CITY, LOC_COUNTRY_CODE, LOC_CITY, LOC_ADDRESS, EMAIL, TEL, LAST_MODIFIED, CREATED)
values (5, 'John', 'Smith', to_date('07-07-1967', 'dd-mm-yyyy'), 'Mencseszter sziti', 'HU', 'Mohács', 'Béke tér 1.', 'johny@smith.eu', '06307777777', to_date('21-09-2016 15:11:39', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:11:39', 'dd-mm-yyyy hh24:mi:ss'));

prompt Loading DOG...
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (3, 'PUL', 'Kócos', null, 3, 'tehgb255gre5', to_date('10-10-2010', 'dd-mm-yyyy'), 1, 2, to_date('21-09-2016 15:13:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:13:35', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (5, 'PUL', 'Bleky', null, 3, 'fdfvksf425kn543', to_date('25-01-2015', 'dd-mm-yyyy'), .99, 2, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (7, 'PUL', 'Jimmy', null, 3, 'fdfvksf425kn544', to_date('25-01-2015', 'dd-mm-yyyy'), 1.03, 2, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (9, 'PUL', 'Jane', null, 3, 'fdfvksf425kn545', to_date('25-01-2015', 'dd-mm-yyyy'), 1.11, 2, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (11, 'GRT', 'Harap', null, 11, 'asd1234', to_date('12-01-2012', 'dd-mm-yyyy'), null, 10, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (13, 'GRT', 'Frici', null, 11, 'z123', to_date('20-02-2161', 'dd-mm-yyyy'), null, 3, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (14, 'GRT', 'Frakk', null, 11, 'z12345', to_date('20-02-2161', 'dd-mm-yyyy'), null, 3, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (15, 'GRT', 'Poci', null, 11, 'z124', to_date('20-02-2161', 'dd-mm-yyyy'), null, 3, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (17, 'GRT', 'Pici', null, 11, 'z125987', to_date('20-02-2161', 'dd-mm-yyyy'), null, 2, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));
insert into DOG (DOG_ID, BREED_CODE, DOG_NAME, FATHER_ID, MOTHER_ID, REGISTRATION_NUMBER, BIRTH_DATE, BIRTH_WEIGHT, OWNER_ID, LAST_MODIFIED, CREATED)
values (18, 'PUL', 'Janet', null, 3, 'fdfvksf425kn545', to_date('25-01-2015', 'dd-mm-yyyy'), 1.11, 2, to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-09-2016 15:19:36', 'dd-mm-yyyy hh24:mi:ss'));


prompt Loading VACC...
insert into VACC (VACC_ID, DOG_ID, DOCTOR_ID, TYPE_OF_VACC, DATE_OF_VACC, LOCATION_OF_VACC, CREATED)
values (1, 3, 5, 'A01', to_date('20-01-2016', 'dd-mm-yyyy'), 'Pécs', to_date('21-09-2016 15:22:49', 'dd-mm-yyyy hh24:mi:ss'));
insert into VACC (VACC_ID, DOG_ID, DOCTOR_ID, TYPE_OF_VACC, DATE_OF_VACC, LOCATION_OF_VACC, CREATED)
values (2, 3, 5, 'B01', to_date('20-08-2016', 'dd-mm-yyyy'), 'Pécs', to_date('21-09-2016 15:22:49', 'dd-mm-yyyy hh24:mi:ss'));
insert into VACC (VACC_ID, DOG_ID, DOCTOR_ID, TYPE_OF_VACC, DATE_OF_VACC, LOCATION_OF_VACC, CREATED)
values (3, 7, 10, 'A01', to_date('11-01-2010', 'dd-mm-yyyy'), 'Budapest', to_date('21-09-2016 15:22:49', 'dd-mm-yyyy hh24:mi:ss'));
insert into VACC (VACC_ID, DOG_ID, DOCTOR_ID, TYPE_OF_VACC, DATE_OF_VACC, LOCATION_OF_VACC, CREATED)
values (4, 11, 10, 'B01', to_date('09-09-2009', 'dd-mm-yyyy'), 'Veszprém', to_date('21-09-2016 15:22:49', 'dd-mm-yyyy hh24:mi:ss'));
insert into VACC (VACC_ID, DOG_ID, DOCTOR_ID, TYPE_OF_VACC, DATE_OF_VACC, LOCATION_OF_VACC, CREATED)
values (5, 13, 10, 'C01', to_date('29-02-2012', 'dd-mm-yyyy'), 'Mohács', to_date('21-09-2016 15:22:49', 'dd-mm-yyyy hh24:mi:ss'));
insert into VACC (VACC_ID, DOG_ID, DOCTOR_ID, TYPE_OF_VACC, DATE_OF_VACC, LOCATION_OF_VACC, CREATED)
values (6, 14, 10, 'C01', to_date('29-02-2012', 'dd-mm-yyyy'), 'Mohács', to_date('21-09-2016 15:28:14', 'dd-mm-yyyy hh24:mi:ss'));

prompt Done.

ALTER TABLE vacc
  RENAME COLUMN type_of_vacc TO vacc_type_id;

-- / #13 / -------------------------------------------------------------
-- Létrehozzuk az oltástípusok tábláját
------------------------------------------------------------------------
CREATE TABLE vacc_type
(
  vacc_type_id VARCHAR2(40) NOT NULL,
  vacc_name    VARCHAR2(200)
);

COMMENT ON TABLE vacc_type IS 'Oltások típusai';
COMMENT ON COLUMN vacc_type.vacc_type_id IS 'Oltás típuskódja';
COMMENT ON COLUMN vacc_type.vacc_name IS 'Oltás megnevezése';

-- PL/SQL Developerben húzzuk az egeret a tábla begépelt neve fölé
-- és jobb kattintással válasszuk ki a "Describe" menûpontot.
-- Itt meg tudjuk nézni egy tábla szerkezetét és a kommenteket.


-- / #14 / -------------------------------------------------------------
-- Létrehozunk egy elsõdleges kulcsot
ALTER TABLE vacc_type
  ADD CONSTRAINT vacc_type_pk PRIMARY KEY (vacc_type_id);


-- / #15 / -------------------------------------------------------------
-- Majd az egyedi értékekkel feltöltjük a táblát a meglévõ oltásokból
INSERT INTO vacc_type
(
  vacc_type_id
)
SELECT DISTINCT t.vacc_type_id
FROM   vacc t;

PROMPT Loading tables...

UPDATE vacc_type t
SET    t.vacc_name = 'Veszettség elleni oltás'
WHERE  t.vacc_type_id = 'A01';

UPDATE vacc_type t
SET    t.vacc_name = 'Lyme-kór elleni oltás'
WHERE  t.vacc_type_id = 'B01';

UPDATE vacc_type t
SET    t.vacc_name = 'Kombinált oltás'
WHERE  t.vacc_type_id = 'C01';

UPDATE vacc_type t
SET    t.vacc_name = 'Parovírus elleni oltás'
WHERE  t.vacc_type_id = 'D01';


PROMPT Done.

ALTER TABLE vacc
  ADD CONSTRAINT vacc_type_fk FOREIGN KEY (vacc_type_id) REFERENCES vacc_type(vacc_type_id);

CREATE OR REPLACE VIEW vw_dog_vacc AS
SELECT d.dog_id
      ,d.dog_name
      ,d.registration_number      
      ,v.date_of_vacc
      ,vt.vacc_name
      ,'Dr.' || p.first_name || ' ' || p.last_name AS doctor_name
FROM   dog d
       JOIN vacc v
         ON d.dog_id = v.dog_id
       JOIN vacc_type vt
         ON v.vacc_type_id = vt.vacc_type_id
       JOIN person p
         ON v.doctor_id = p.person_id
WHERE  v.date_of_vacc >= DATE '2016-01-01'
ORDER BY d.dog_id, v.date_of_vacc
;

CREATE OR REPLACE VIEW vw_dogs_with_owners AS
 SELECT p.first_name
      ,p.last_name
      ,d.dog_name
      ,COUNT(*) over(PARTITION BY p.person_id) AS dog_cnt_by_person
      ,row_number() over(PARTITION BY p.person_id ORDER BY d.dog_name DESC) AS dog_rn_by_name_desc
--      ,COUNT(*) over(PARTITION BY p.person_id ORDER BY d.dog_name DESC range between unbounded preceding and unbounded following) as cnt_with_order
  FROM person p
  JOIN dog d
    ON p.person_id = d.owner_id;


CREATE OR REPLACE FUNCTION get_prev_date(p_n NUMBER DEFAULT 1) RETURN DATE IS
BEGIN
  RETURN SYSDATE - p_n;
END;
/
