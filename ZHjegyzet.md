# creating a schema

Igen furcsa mód az oracle-nel a séma és az userek ugyanazok(?) vagy legalábbis annak tűnnek nekem...

## táblaterek

```sql
CREATE TABLESPACE táblatér_név
DATAFILE 'táblatér_név.dbf'
SIZE 10M AUTOEXTEND on;
```

```sql
CREATE TEMPORARY TABLESPACE ideiglenes_táblatér_név
tempfile 'ideiglenes_táblatér_név.dat'
SIZE 10M AUTOEXTEND on;
```

## userses

```sql
CREATE USER felhasználónév IDENTIFIED BY jelszo 
DEFAULT TABLESPACE táblatér_név
TEMPORARY TABLESPACE ideiglenes_táblatér_név;

GRANT CREATE SESSION TO felhasználónév;
GRANT CONNECT, RESOURCE TO felhasználónév;
GRANT CREATE TABLE TO felhasználónév;
GRANT CREATE VIEW TO felhasználónév;
GRANT UNLIMITED TABLESPACE TO felhasználónév;
```

## táblákok

```sql
CREATE TABLE tábla_név (
    azonosító NUMBER,
    megszólitás VARCHAR2(maxkarakterszám),
    dátum DATE DEFAULT SYSDATE,
    CONSTRAINT pk_tábla_név PRIMARY KEY (azonosító),
    CONSTRAINT uq_megszólitás UNIQUE (megszólitás),
    CONSTRAINT nn_megszólitás NOT NULL (megszólitás),
);
```

```sql
CREATE TABLE másik_tábla_név (
    azonosító NUMBER,
    megszólitás VARCHAR2(maxkarakterszám),
    nem_nulla_szám NUMBER,
    kŐlső_kulcs_id NUMBER,
    CONSTRAINT pk_másik_tábla_név PRIMARY KEY (azonosító),
    CONSTRAINT uq_megszólitás UNIQUE (megszólitás),
    CONSTRAINT nn_megszólitás NOT NULL (megszólitás),
    CONSTRAINT ck_nem_nulla_szám CHECK (nem_nulla_szám > 0),
    CONSTRAINT fk_kŐlső_kulcs_id FOREIGN KEY (kŐlső_kulcs_id) REFERENCES tábla_név(id)
);
```

## adatok beszurkálása

```sql
INSERT INTO tábla_név VALUES (
    1, 'Lökött Pista' TO_DATE('1994/12/16 12:00:00', 'yyyy/mm/dd hh:mi:ss')
);
```

```sql
INSERT INTO másik_tábla_név (azonosító, megszólitás, kŐlső_kulcs_id)
VALUES 
    (67, 'gumi kaki játék', 1),
    (69, 'építő kockák', 1);
```

```sql
INSERT ALL
    INTO tábla_név VALUES (2, 'Lökött Gábor', TO_DATE('1997/12/16 12:00:00', 'yyyy/mm/dd hh:mi:ss'))
    INTO tábla_név VALUES (3, 'Néni Babi', TO_DATE('2026/09/30 12:00:00', 'yyyy/mm/dd hh:mi:ss'))
SELECT * FROM dual;
COMMIT;
```

### Másolat tábla és idempotens MERGE beszúrás

 1. Üres másolat tábla létrehozása manuális oszlopfelsorolás nélkül (talán)

```sql
CREATE TABLE tábla_név_másolat AS
SELECT *
FROM tábla_név
WHERE 1 = 0;
```

 1. Idempotens adatfeltöltés MERGE utasítással: (remélem 😅)

```sql
MERGE INTO tábla_név_másolat target
USING tábla_név source
ON (target.azonosító = source.azonosító)
WHEN NOT MATCHED THEN
INSERT (azonosító, megszólitás, dátum)
VALUES (source.azonosító, source.megszólitás, source.dátum);
COMMIT;
```
