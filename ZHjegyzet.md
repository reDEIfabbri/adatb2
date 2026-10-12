# creating a schema:

Igen furcsa mód az oracle-nel a séma és az userek ugyanazok(?) vagy legalábbis annak tűnnek nekem...

## táblaterek:
```
CREATE TABLESPACE táblatér_név
DATAFILE 'táblatér_név.dbf'
SIZE 10M AUTOEXTEND on;
```

```
CREATE TEMPORARY TABLESPACE ideiglenes_táblatér_név
tempfile 'ideiglenes_táblatér_név.dat'
SIZE 10M AUTOEXTEND on;
```

## user:
```
CREATE USER felhasználónév IDENTIFIED BY jelszo 
DEFAULT TABLESPACE táblatér_név
TEMPORARY TABLESPACE ideiglenes_táblatér_név;

GRANT CREATE SESSION TO felhasználónév;
GRANT CONNECT, RESOURCE TO felhasználónév;
GRANT CREATE TABLE TO felhasználónév;
GRANT CREATE VIEW TO felhasználónév;
GRANT UNLIMITED TABLESPACE TO felhasználónév;
```

## táblák:
