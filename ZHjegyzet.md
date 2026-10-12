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
    megszólitás VARCHAR2(100) CONSTRAINT nn_megszólitás NOT NULL,
    dátum DATE DEFAULT SYSDATE,
    CONSTRAINT pk_tábla_név PRIMARY KEY (azonosító),
    CONSTRAINT uq_megszólitás UNIQUE (megszólitás)
);
```

> **Tipp kényszerekhez:**
> - Oracle-ben a `NOT NULL`-t oszlopszinten szokás megadni (vagy táblaszinten: `CHECK (oszlop IS NOT NULL)`).
> - A kényszerneveknek az egész sémában egyedinek kell lenniük (nem lehet mindkét táblában ugyanaz a kényszernév)!

```sql
CREATE TABLE másik_tábla_név (
    azonosító NUMBER,
    megszólitás VARCHAR2(100) CONSTRAINT nn_masik_megszólitás NOT NULL,
    nem_nulla_szám NUMBER,
    kŐlső_kulcs_id NUMBER,
    CONSTRAINT pk_másik_tábla_név PRIMARY KEY (azonosító),
    CONSTRAINT uq_masik_megszólitás UNIQUE (megszólitás),
    CONSTRAINT ck_nem_nulla_szám CHECK (nem_nulla_szám > 0),
    CONSTRAINT fk_kŐlső_kulcs_id FOREIGN KEY (kŐlső_kulcs_id) REFERENCES tábla_név(azonosító)
);
```

## adatok beszurkálása

```sql
INSERT INTO tábla_név VALUES (
    1, 'Lökött Pista', TO_DATE('1994/12/16 12:00:00', 'yyyy/mm/dd hh:mi:ss')
);
```

```sql
-- Vesszővel elválasztott multi-row INSERT (Oracle 23ai-tól támogatott,
-- régebbi Oracle 11g-21c verziókban használj inkább INSERT ALL-t lásd lejjebb!):
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

 2. Idempotens adatfeltöltés MERGE utasítással: (remélem 😅)

```sql
MERGE INTO tábla_név_másolat target
USING tábla_név source
ON (target.azonosító = source.azonosító)
WHEN NOT MATCHED THEN
INSERT (azonosító, megszólitás, dátum)
VALUES (source.azonosító, source.megszólitás, source.dátum);
COMMIT;
```

### Válogatás új táblákba mező érték alapján (itten pölö dátum szerint)

1. Először isletrehozunk 2 táblát amibe nincs semmi, de rendelkeznek mindennel, ami kell, hogy az eredeti táblából áttuggyuk bele baszni a megfelelően válogatott sorokat!

```sql
CREATE TABLE regi_tábla_név AS
SELECT * FROM tábla_név WHERE 1 = 0;

CREATE TABLE új_tábla_név AS
SELECT * FROM tábla_név WHERE 1 = 0;
```

2. Most kéne válogatni valahogy...

```sql
INSERT FIRST
    WHEN dátum < ADD_MONTHS(SYSDATE, -6) THEN
        INTO regi_tábla_név (azonosító, megszólitás, dátum)
        VALUES (azonosító, megszólitás, dátum)
    ELSE
        INTO új_tábla_név (azonosító, megszólitás, dátum)
        VALUES (azonosító, megszólitás, dátum)
SELECT azonosító, megszólitás, dátum
FROM tábla_név;

COMMIT;
```

3. Ellenőrizni is érdemes:

```sql
SELECT 'Régi kölkök' AS azonosító, megszólitás, dátum FROM regi_tábla_név
UNION ALL
SELECT 'Új kölkök' AS azonosító, megszólitás, dátum FROM új_tábla_név;
```

Kicsitt késő tisztázni, de a tábla_név-ben gyerekek szerepelnek a példák szerint, a másik_tábla_név-ben pedig meg hozzájuk rendelt játékok vannak (gyerek:játék = 1:N)

## View-ok

### Csoportosító view

Hogy hívják azt az állóvizet amelyik legjobban összehozza az  embereket: Csoportosí-tó!

![ROLF COPTER](https://commons.wikimedia.org/wiki/File:Roflcopter.gif#/media/File:Roflcopter.gif)

```sql
CREATE OR REPLACE VIEW v_tábla_név_másik_tábla_név_osszesito AS
SELECT
    k.azonosító                                                AS tábla_név_id,
    k.megszólitás                                        AS tábla_név_nev,
    COUNT(t.id)                                         AS másik_tábla_név_szama,
    LISTAGG(t.megszólitás, '|') WITHIN GROUP (ORDER BY t.megszólitás)   AS másik_tábla_név_nevei
FROM kategoria k
INNER JOIN termek t ON k.azonosító = t.tábla_név_id
GROUP BY k.azonosító, k.megszólitás;
```

#### ****Ellenőrizés:****

```sql
SELECT * FROM v_tábla_név_másik_tábla_név_osszesito;
```

## a legutóbbi zh utolsó feladatának a megoldása remélhetőleg helyesen

```sql
-- 8. Feladat: Utolsó 'A' betűs kategória és termékei (LEFT OUTER JOIN)
-- ============================================================================
WITH kivalasztott_kategoria AS (
    SELECT *
    FROM (
        SELECT id, megnevezes, leiras
        FROM kategoria
        WHERE UPPER(megnevezes) LIKE '%A%'
        ORDER BY megnevezes DESC
    )
    WHERE ROWNUM = 1
)
SELECT
    k.id            AS kategoria_id,
    k.megnevezes    AS kategoria_nev,
    k.leiras        AS kategoria_leiras,
    t.id            AS termek_id,
    t.nev           AS termek_nev,
    t.ar            AS termek_ar,
    t.reg_datum     AS termek_reg_datum
FROM kivalasztott_kategoria k
LEFT JOIN termek t ON k.id = t.kategoria_id;
```
## Táblamódosítások (ALTER TABLE) - Ha elcseszted a táblát és nem akarod elölről kezdeni

Mert a `CREATE TABLE` után az ember rájön, hogy lehagyott ezt-azt, vagy túl szűk lett egy mező. Nem kell rögtön pánikba esni meg mindent letörölni!

### Új oszlop hozzáadása
```sql
-- Egy új oszlop hozzáadása:
ALTER TABLE tábla_név ADD (új_oszlop VARCHAR2(100));

-- Egyszerre több új oszlop, akár default értékkel:
ALTER TABLE tábla_név ADD (
    ár NUMBER DEFAULT 0,
    leírás VARCHAR2(500)
);
```

### Oszlop módosítása (típus, méret, kötelezőség)
```sql
-- Méret növelése (csökkenteni csak akkor enged az Oracle, ha a meglévő adatok beleférnek):
ALTER TABLE tábla_név MODIFY (megszólitás VARCHAR2(250));

-- Kötelezővé tétel (NOT NULL) - csak akkor sikerül, ha most sincs benne egyetlen NULL érték sem!:
ALTER TABLE tábla_név MODIFY (megszólitás NOT NULL);

-- Kötelezőség eltörlése (újra lehet benne NULL):
ALTER TABLE tábla_név MODIFY (megszólitás NULL);

-- Alapértelmezett érték megváltoztatása (a meglévő sorokat nem írja át, csak az újakra vonatkozik):
ALTER TABLE tábla_név MODIFY (dátum DEFAULT SYSDATE);
```

### Oszlop átnevezése és eldobása
```sql
-- Oszlop átnevezése:
ALTER TABLE tábla_név RENAME COLUMN megszólitás TO teljes_nev;

-- Oszlop kidobása a kukába:
ALTER TABLE tábla_név DROP COLUMN új_oszlop;
```

### Kényszerek (Constraints) utólagos buherálása
```sql
-- Új CHECK kényszer hozzáadása utólag:
ALTER TABLE tábla_név ADD CONSTRAINT ck_dátum CHECK (dátum >= DATE '1990-01-01');

-- Idegen kulcs hozzáadása kaszkádolt törléssel (ha a szülőt törlöd, a kölke is automatikusan repül):
ALTER TABLE másik_tábla_név 
ADD CONSTRAINT fk_masik_tabla_szulo 
FOREIGN KEY (kŐlső_kulcs_id) REFERENCES tábla_név(azonosító) 
ON DELETE CASCADE;

-- VAGY ON DELETE SET NULL (a gyerek megmarad, de a kulcsa NULL-ra vált):
-- FOREIGN KEY (kŐlső_kulcs_id) REFERENCES tábla_név(azonosító) ON DELETE SET NULL;

-- Kényszer ideiglenes KIKAPCSOLÁSA (életmentő, ha ömlesztve akarsz adatot betölteni):
ALTER TABLE tábla_név DISABLE CONSTRAINT ck_dátum;

-- Kényszer visszakapcsolása:
ALTER TABLE tábla_név ENABLE CONSTRAINT ck_dátum;

-- Kényszer végleges törlése:
ALTER TABLE tábla_név DROP CONSTRAINT ck_dátum;
```

### Tábla átnevezése, ürítése és eldobása
```sql
-- Tábla átnevezése:
RENAME régi_tábla_név TO orokolt_tábla_név;

-- TRUNCATE: azonnal kipucolja az összes sort, visszavonhatatlan (nincs ROLLBACK!), de sokkal gyorsabb mint a DELETE:
TRUNCATE TABLE regi_tábla_név;

-- DROP TABLE: a tábla megsemmisítése.
-- Ha idegen kulcs hivatkozik rá, CASCADE CONSTRAINTS kell, a PURGE meg kikerüli a lomtárat (Recycle Bin):
DROP TABLE regi_tábla_név CASCADE CONSTRAINTS PURGE;
```

## DML alapok: UPDATE és DELETE (Mert hibázni emberi dolog)

> **ARANYSZABÁLY:** Mindig legyen `WHERE` feltétel, különben az összes létező sorodat átírod vagy letörlöd a fenébe! És utána `COMMIT;`!

### UPDATE (Módosítás)
```sql
-- Egy vagy több mező frissítése adott sornál:
UPDATE tábla_név
SET megszólitás = 'Nagyon Lökött Pista', dátum = SYSDATE
WHERE azonosító = 1;

-- Feltételes módosítás másik tábla adatai alapján (korrelált subquery):
UPDATE másik_tábla_név
SET nem_nulla_szám = nem_nulla_szám * 1.1 -- 10%-os emelés
WHERE kŐlső_kulcs_id IN (SELECT azonosító FROM tábla_név WHERE dátum < DATE '2000-01-01');

COMMIT;
```

### DELETE (Törlés)
```sql
-- Csak a kiválasztott sorok törlése:
DELETE FROM másik_tábla_név 
WHERE azonosító = 67;

-- Törlés alkérdezés alapján (pl. töröljük azokat a játékokat, amiknek a gazdája 2000 előtt született):
DELETE FROM másik_tábla_név
WHERE kŐlső_kulcs_id IN (SELECT azonosító FROM tábla_név WHERE dátum < DATE '2000-01-01');

COMMIT;
```

## Lekérdezések Mesterfokon (SELECT Nagyágyú)

A ZH-k java része ebből áll. Ha ezeket a mintákat felismered, nyert ügyed van.

### A SELECT végrehajtási sorrendje (MERT FONTOS!)
Az adatbázis motor **NEM** olyan sorrendben hajtja végre a SELECT-et, ahogy leírod:
1. `FROM` és `JOIN` (összekapcsolja a forrásokat)
2. `WHERE` (soronként szűr még csoportosítás előtt)
3. `GROUP BY` (csoportokba rendezi a sorokat)
4. `HAVING` (csoportokra szűr az aggregált értékek alapján)
5. `SELECT` (kiszámítja a kifejezéseket, oszlopokat és aliasokat)
6. `DISTINCT` (kiszűri a duplikált sorokat)
7. `ORDER BY` (sorba rendezi az eredményt)
8. `FETCH FIRST / ROWNUM` (elvágja a sorok darabszámát)

> **Miért lényeges ez?**
> Mert a SELECT-ben megadott oszlopálnevet (aliast) NEM használhatod sem a `WHERE`-ben, sem a `GROUP BY`-ban! A WHERE ugyanis hamarabb lefut, mint hogy az álnév egyáltalán megszületne.

### Szűrési trükkök a WHERE záradékban
```sql
-- Szöveges keresés kis/nagybetű függetlenül (UPPER vagy LOWER használatával):
SELECT * FROM tábla_név WHERE UPPER(megszólitás) LIKE '%PISTA%';

-- LIKE helyettesítő karakterek:
-- %  = tetszőleges számú (0 vagy több) karakter
-- _  = pontosan 1 darab tetszőleges karakter
SELECT * FROM tábla_név WHERE megszólitás LIKE '_éni%'; -- Néni, Béni, Péni...

-- Ha konkrétan az aláhúzást vagy a % jelet akarod keresni, ESCAPE kell:
SELECT * FROM tábla_név WHERE megszólitás LIKE '%\_%' ESCAPE '\';

-- Halmazvizsgálat (IN) és intervallum (BETWEEN):
SELECT * FROM tábla_név WHERE azonosító IN (1, 2, 3);
SELECT * FROM tábla_név WHERE dátum BETWEEN TO_DATE('1990/01/01', 'yyyy/mm/dd') AND SYSDATE;

-- NULL ellenőrzés (CSAPDA: soha ne írj olyat, hogy oszlop = NULL! Mindig IS NULL vagy IS NOT NULL):
SELECT * FROM tábla_név WHERE megszólitás IS NOT NULL;

-- ☠️ HALÁLOS CSAPDA: NOT IN és a NULL! ☠️
-- Ha az alkérdezés akár egyetlen NULL-t is tartalmaz, a NOT IN SOHA SEMMIT nem ad vissza!
-- EZÉRT MINDIG tegyél bele WHERE oszlop IS NOT NULL szűrést:
SELECT * FROM tábla_név 
WHERE azonosító NOT IN (
    SELECT kŐlső_kulcs_id 
    FROM másik_tábla_név 
    WHERE kŐlső_kulcs_id IS NOT NULL
);
```

### JOIN Kisokos (Ki kivel van összekötve?)

Tegyük fel: `tábla_név` = gyerekek, `másik_tábla_név` = játékok.

```sql
-- 1. INNER JOIN (Belső illesztés):
-- Csak azok a gyerekek, akiknek VAN játékuk, és csak azok a játékok, amiknek VAN gazdájuk:
SELECT gy.azonosító, gy.megszólitás, j.megszólitás AS jatek_nev
FROM tábla_név gy
INNER JOIN másik_tábla_név j ON gy.azonosító = j.kŐlső_kulcs_id;

-- 2. LEFT (OUTER) JOIN (Bal oldali külső illesztés):
-- MINDEN gyerek szerepel a listában! Akinek nincs játéka, annál a játék oszlopai NULL-ok lesznek:
SELECT gy.azonosító, gy.megszólitás, j.megszólitás AS jatek_nev
FROM tábla_név gy
LEFT JOIN másik_tábla_név j ON gy.azonosító = j.kŐlső_kulcs_id;

-- ⭐ ZH KEDVENC: Kik azok a gyerekek, akiknek EGYÁLTALÁN NINCS játékuk?
SELECT gy.azonosító, gy.megszólitás
FROM tábla_név gy
LEFT JOIN másik_tábla_név j ON gy.azonosító = j.kŐlső_kulcs_id
WHERE j.azonosító IS NULL;

-- 3. RIGHT (OUTER) JOIN:
-- MINDEN játék szerepel, még ha nincs is hozzárendelve gyerekhez:
SELECT gy.megszólitás AS gyerek_nev, j.megszólitás AS jatek_nev
FROM tábla_név gy
RIGHT JOIN másik_tábla_név j ON gy.azonosító = j.kŐlső_kulcs_id;

-- 4. FULL (OUTER) JOIN:
-- MINDEN gyerek és MINDEN játék szerepel, hiányzó párok helyén NULL-lal:
SELECT gy.megszólitás AS gyerek_nev, j.megszólitás AS jatek_nev
FROM tábla_név gy
FULL OUTER JOIN másik_tábla_név j ON gy.azonosító = j.kŐlső_kulcs_id;

-- 5. CROSS JOIN (Descartes-szorzat):
-- Minden gyerek minden létező játékkal össze van párosítva (méret = N * M):
SELECT gy.megszólitás, j.megszólitás
FROM tábla_név gy
CROSS JOIN másik_tábla_név j;

-- Régi Oracle stílusú (+) jelölés (ha régebbi feladatsorban látod):
-- Ez pontosan a LEFT JOIN megfelelője (a hiányos oldal mezője mellé kerül a plusz):
SELECT gy.megszólitás, j.megszólitás
FROM tábla_név gy, másik_tábla_név j
WHERE gy.azonosító = j.kŐlső_kulcs_id(+);
```

### Csoportosítás (GROUP BY & HAVING)

> **Szabály:** Bármilyen oszlop szerepel a `SELECT`-ben, amit **nem raktál bele aggregáló függvénybe** (mint a `SUM`, `AVG`, `COUNT`, `MIN`, `MAX`), annak **KÖTELEZŐ** szerepelnie a `GROUP BY`-ban!

```sql
SELECT 
    kŐlső_kulcs_id                          AS gyerek_id,
    COUNT(*)                                AS jatekok_szama,
    SUM(nem_nulla_szám)                     AS pontszamok_osszege,
    ROUND(AVG(nem_nulla_szám), 2)           AS pontszamok_atlaga,
    MIN(nem_nulla_szám)                     AS legkisebb_pont,
    MAX(nem_nulla_szám)                     AS legnagyobb_pont
FROM másik_tábla_név
WHERE nem_nulla_szám > 0               -- WHERE: sorokat szűr még a csoportosítás ELŐTT
GROUP BY kŐlső_kulcs_id
HAVING COUNT(*) >= 2;                  -- HAVING: csoportokat szűr aggregált érték alapján UTÁNA
```

### Halmazműveletek (UNION, INTERSECT, MINUS)
Szabály: Mindegyik lekérdezésben az oszlopok számának és típusának kompatibilisnek kell lennie!

```sql
-- UNION: Egyesíti az eredményeket és kiszűri a duplikátumokat (lassabb a rendezés miatt):
SELECT megszólitás FROM tábla_név
UNION
SELECT megszólitás FROM másik_tábla_név;

-- UNION ALL: Egyesíti a sorokat duplikátum-szűrés NÉLKÜL (sokkal gyorsabb!):
SELECT megszólitás FROM tábla_név
UNION ALL
SELECT megszólitás FROM másik_tábla_név;

-- INTERSECT: Metszet (csak azok, amik mindkét halmazban szerepelnek):
SELECT megszólitás FROM tábla_név
INTERSECT
SELECT megszólitás FROM másik_tábla_név;

-- MINUS: Halmazkülönbség (az elsőből kivonja a másodikat):
-- ZH KEDVENC: Mely gyerekeknek NINCS játékuk (MINUS-szal megoldva):
SELECT azonosító FROM tábla_név
MINUS
SELECT kŐlső_kulcs_id FROM másik_tábla_név WHERE kŐlső_kulcs_id IS NOT NULL;
```

### Top-N sorok kiválasztása (A legelső N darab rekord)

```sql
-- 1. Modern módszer (Oracle 12c+):
SELECT *
FROM tábla_név
ORDER BY dátum DESC
FETCH FIRST 3 ROWS ONLY;

-- Lapozás (pl. 3 sor kihagyása után a következő 3 sor):
SELECT *
FROM tábla_név
ORDER BY dátum DESC
OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;

-- 2. Régi klasszikus módszer ROWNUM-mal:
-- VIGYÁZAT: Mindig belső almappában (subquery-ben) kell rendezni!
-- Ha simán kiadnád: WHERE ROWNUM <= 3 ORDER BY ..., akkor előbb levesz 3 random sort, és csak azt rendezi!
SELECT *
FROM (
    SELECT *
    FROM tábla_név
    ORDER BY dátum DESC
)
WHERE ROWNUM <= 3;
```

### CTE (Common Table Expression - A WITH záradék)
Mert az egymásba ágyazott al-lekérdezések átláthatatlan spagettivé válnak:

```sql
WITH atlag_pontok AS (
    SELECT AVG(nem_nulla_szám) AS atlag
    FROM másik_tábla_név
),
kiemelt_jatekok AS (
    SELECT *
    FROM másik_tábla_név
    WHERE nem_nulla_szám > (SELECT atlag FROM atlag_pontok)
)
SELECT * 
FROM kiemelt_jatekok;
```

## Neat Tricks & Életmentő Oracle Függvények (ZH Túlélőcsomag)

### 1. NULL kezelő mesterhármas
```sql
-- NVL(kifejezés, helyettesítő): ha NULL, a másodikat adja vissza
SELECT NVL(leiras, 'Nincs megadva leírás') FROM kategoria;

-- NVL2(kifejezés, ha_nem_null, ha_null): ternáris operátor
SELECT NVL2(leiras, 'Kitöltött', 'Hiányzik') FROM kategoria;

-- COALESCE(e1, e2, e3, ...): az első nem-NULL értéket adja vissza a felsorolásból
SELECT COALESCE(becenév, megszólitás, 'Névtelen') FROM tábla_név;

-- NULLIF(a, b): ha a = b, akkor NULL, különben az 'a' értéke
SELECT NULLIF(nem_nulla_szám, 0) FROM másik_tábla_név;
```

### 2. Feltételes logika a SELECT-ben (CASE és DECODE)
```sql
-- CASE WHEN (bárhol használható, szabványos és olvasható):
SELECT megszólitás,
    CASE 
        WHEN dátum < DATE '2000-01-01' THEN 'Régi motoros'
        WHEN dátum < DATE '2015-01-01' THEN 'Fiatal'
        ELSE 'Mai csirke'
    END AS korcsoport
FROM tábla_név;

-- DECODE (Oracle kompakt beépített switch-case):
-- Szintaxis: DECODE(érték, mikor_1, akkor_1, mikor_2, akkor_2, ..., egyébként)
SELECT azonosító,
    DECODE(kŐlső_kulcs_id, 
        1, 'Pista tulajdona', 
        2, 'Gábor tulajdona', 
        'Ismeretlen gazda') AS tulajdonos
FROM másik_tábla_név;
```

### 3. Dátumvarázslás és Időműveletek
```sql
-- Aktuális időpont:
SELECT SYSDATE FROM dual;                    -- dátum és idő másodperc pontossággal
SELECT CURRENT_TIMESTAMP FROM dual;          -- mikromásodperc és időzóna

-- Dátum aritmetika napokban (szám hozzáadása = napok száma):
SELECT SYSDATE + 1 FROM dual;                -- holnap ilyenkor (+1 nap)
SELECT SYSDATE - 7 FROM dual;                -- egy héttel ezelőtt
SELECT SYSDATE + (1/24) FROM dual;           -- 1 óra múlva
SELECT SYSDATE + (15/1440) FROM dual;        -- 15 perc múlva (mert egy napban 1440 perc van)

-- Hónapok kezelése (a tanárok kedvence a ZH-n!):
SELECT ADD_MONTHS(SYSDATE, 3) FROM dual;     -- 3 hónap múlva
SELECT ADD_MONTHS(SYSDATE, -6) FROM dual;    -- félévvel ezelőtt
SELECT MONTHS_BETWEEN(SYSDATE, DATE '2024-01-01') FROM dual; -- hány hónap telt el

-- Speciális dátumok:
SELECT LAST_DAY(SYSDATE) FROM dual;          -- az aktuális hónap utolsó napja
SELECT NEXT_DAY(SYSDATE, 'HÉTFŐ') FROM dual; -- következő hétfő

-- TRUNC dátumra (levágja az időt éjfélre vagy adott egységre csonkít):
SELECT TRUNC(SYSDATE) FROM dual;             -- ma 00:00:00 (idő rész nullázva!)
SELECT TRUNC(SYSDATE, 'MM') FROM dual;       -- az aktuális hónap 1. napja
SELECT TRUNC(SYSDATE, 'YYYY') FROM dual;     -- az aktuális év 1. napja

-- Rész kinyerése:
SELECT EXTRACT(YEAR FROM SYSDATE) AS idei_ev FROM dual;
SELECT EXTRACT(MONTH FROM SYSDATE) AS idei_ho FROM dual;

-- Dátum formázás és beolvasás:
SELECT TO_CHAR(SYSDATE, 'YYYY.MM.DD HH24:MI:SS') FROM dual;
SELECT TO_DATE('2026-10-13 14:30', 'YYYY-MM-DD HH24:MI') FROM dual;
```

### 4. Szövegkezelő függvények (String manipuláció)
```sql
SELECT UPPER('kisbetű') FROM dual;           -- KISBETŰ
SELECT LOWER('NAGYBETŰ') FROM dual;          -- nagybetű
SELECT INITCAP('kovács jános') FROM dual;    -- Kovács János

-- Részsztring kinyerése (FIGYELEM: 1-től indexel, NEM 0-tól!):
SELECT SUBSTR('Oracle SQL', 1, 6) FROM dual; -- 'Oracle' (1. karaktertől 6 db hosszú)
SELECT SUBSTR('Oracle SQL', -3) FROM dual;   -- 'SQL' (hátulról a 3. karaktertől végig)

-- Hossz és keresés:
SELECT LENGTH('Almafa') FROM dual;           -- 6
SELECT INSTR('Kecskesajt', 'sajt') FROM dual;-- 7 (hányadik karakternél kezdődik a 'sajt')

-- Kitöltés és levágás (kiváló kódok vagy számlák formázásához):
SELECT LPAD('42', 6, '0') FROM dual;         -- '000042' (balról kitöltve 6 hosszúra)
SELECT RPAD('Tétel', 10, '.') FROM dual;     -- 'Tétel.....'
SELECT TRIM('   felesleges szóköz   ') FROM dual;

-- Csere és összefűzés:
SELECT REPLACE('szép nap', 'nap', 'este') FROM dual; -- 'szép este'
SELECT 'Kovács' || ' ' || 'Péter' FROM dual;         -- összefűzés || operátorral
```

### 5. Számkezelő függvények
```sql
SELECT ROUND(123.456, 2) FROM dual; -- 123.46 (kerekítés)
SELECT TRUNC(123.456, 2) FROM dual; -- 123.45 (levágás csonkítással, nem kerekít!)
SELECT MOD(10, 3) FROM dual;        -- 1 (maradékos osztás)
SELECT CEIL(4.1) FROM dual;         -- 5 (felső egészrész)
SELECT FLOOR(4.9) FROM dual;        -- 4 (alsó egészrész)
SELECT ABS(-42) FROM dual;          -- 42 (abszolút érték)
SELECT SIGN(-15) FROM dual;         -- -1 (előjel: negatív = -1, nulla = 0, pozitív = 1)
```

### 6. Analitikus (Ablak-) Függvények (Amikor a GROUP BY már kevés)
Ha úgy akarsz csoportosítani és rangsorolni, hogy közben **nem veszted el az egyedi sorokat**:

```sql
-- Sorszámozás és rangsorolás csoportonként:
SELECT 
    kategoria_id, nev, ar,
    -- Simán megszámozza a sorokat 1-től N-ig csoporton belül:
    ROW_NUMBER() OVER (PARTITION BY kategoria_id ORDER BY ar DESC) AS sorszam,
    -- Rangsor holtversennyel és ugrással (1, 2, 2, 4):
    RANK() OVER (PARTITION BY kategoria_id ORDER BY ar DESC) AS rang,
    -- Rangsor holtversennyel de ugrás NÉLKÜL (1, 2, 2, 3):
    DENSE_RANK() OVER (PARTITION BY kategoria_id ORDER BY ar DESC) AS suru_rang
FROM termek;

-- ⭐ ZH KLASSZIKUS: Minden kategóriából a LEGDRÁGÁBB termék kiválasztása:
WITH rangsorolt AS (
    SELECT 
        kategoria_id, nev, ar,
        ROW_NUMBER() OVER (PARTITION BY kategoria_id ORDER BY ar DESC) AS rn
    FROM termek
)
SELECT kategoria_id, nev, ar
FROM rangsorolt
WHERE rn = 1;
```

## Szekvenciák (Sequences) - Automatikus azonosító számlálók

Mivel régebbi Oracle-ben nem létezett `AUTO_INCREMENT`, szekvenciát kellett létrehozni (ZH-n még ma is kérik!):

```sql
-- Szekvencia készítése:
CREATE SEQUENCE seq_tábla_azonosító
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Használata új sor beszúrásakor (.NEXTVAL lekéri a következő számot):
INSERT INTO tábla_név (azonosító, megszólitás, dátum)
VALUES (seq_tábla_azonosító.NEXTVAL, 'Új Jövevény', SYSDATE);

-- Az aktuális (legutóbb kiadott) érték lekérdezése a munkamenetben:
SELECT seq_tábla_azonosító.CURRVAL FROM dual;

-- Szekvencia törlése:
DROP SEQUENCE seq_tábla_azonosító;
```

*(Oracle 12c-től már létezik közvetlen Identity oszlop is: `azonosító NUMBER GENERATED ALWAYS AS IDENTITY`)*

## Indexek (Ha száguldani kell a WHERE-ben)

```sql
-- Sima B-fa index létrehozása oszlopra:
CREATE INDEX idx_termek_nev ON termek(nev);

-- Egyedi index (nem enged azonos értékeket):
CREATE UNIQUE INDEX uq_idx_termek_nev ON termek(nev);

-- Összetett index több oszlopra:
CREATE INDEX idx_termek_kat_ar ON termek(kategoria_id, ar);

-- Index kidobása:
DROP INDEX idx_termek_nev;
```

## Tranzakciókezelés: COMMIT, ROLLBACK és Mentési Pontok

```sql
-- Módosítunk valamit:
UPDATE tábla_név SET megszólitás = 'Próba Név' WHERE azonosító = 1;

-- Mentési pont létrehozása (időbélyeg a tranzakcióban):
SAVEPOINT mentes_1;

-- Csinálunk valami hülyeséget véletlenül:
DELETE FROM tábla_név WHERE azonosító = 1;

-- Visszagörgetünk a mentési pontig (a DELETE visszavonódik, de a korábbi UPDATE megmarad!):
ROLLBACK TO mentes_1;

-- Véglegesítjük a tranzakciót (innentől a változások beégnek az adatbázisba):
COMMIT;

-- Ha mindent vissza akarsz vonni a legutolsó COMMIT óta:
-- ROLLBACK;
```

> **Figyelem:** Minden DDL utasítás (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`) előtt és után az Oracle **AUTOMATIKUSAN COMMIT-ot hajt végre**! Ezért egy `CREATE TABLE` után már nem tudsz `ROLLBACK`-et nyomni a korábbi adataidra!

## Adatszótár Puskák (Data Dictionary Cheat Sheet)

Amikor a ZH közben nem emlékszel a táblád, oszlopod vagy kényszered pontos nevére, ezeket futtasd le:

```sql
-- 1. Milyen tábláim vannak a sémámban?
SELECT table_name, num_rows FROM user_tables ORDER BY table_name;

-- 2. Milyen oszlopai és adattípusai vannak a táblámnak?
SELECT column_name, data_type, data_length, nullable, data_default
FROM user_tab_columns
WHERE table_name = 'TERMEK'   -- FONTOS: csupa nagybetűvel írd a nevet!
ORDER BY column_id;

-- 3. Milyen kényszerek vannak beállítva a táblán?
SELECT constraint_name, constraint_type, search_condition, status
FROM user_constraints
WHERE table_name = 'TERMEK';
-- Kényszertípusok:
--   P = Primary Key
--   R = Referential (Foreign Key)
--   U = Unique
--   C = Check (vagy Not Null)

-- 4. Melyik oszlophoz tartozik a kényszer?
SELECT constraint_name, column_name, position
FROM user_cons_columns
WHERE table_name = 'TERMEK';

-- 5. Milyen nézeteim (VIEW) vannak és mi a forráskódjuk?
SELECT view_name, text FROM user_views;

-- 6. Milyen szekvenciáim vannak és hol áll a számláló?
SELECT sequence_name, last_number, increment_by FROM user_sequences;

-- 7. Milyen indexeim vannak?
SELECT index_name, table_name, uniqueness FROM user_indexes;
```

## A Leggyakoribb Oracle Hibák és Megoldásuk (Pánikgomb)

Ha pirossal dobja a hibát az SQL Developer, nézd meg itt:

| Hibakód | Hibaüzenet | Mi történt és mi a megoldás? |
| :--- | :--- | :--- |
| **ORA-65096** | `invalid common user name` | A gyökér konténerhez (CDB) kapcsolódtál a PDB helyett! Futtasd: `ALTER SESSION SET CONTAINER = XEPDB1;` |
| **ORA-00942** | `table or view does not exist` | Elgépelted a tábla nevét, vagy nem a megfelelő felhasználói kapcsolathoz tartozó munkalapon vagy. |
| **ORA-00001** | `unique constraint (...) violated` | Olyan értéket akarsz beszúrni, ami az elsődleges kulcsban (`PK`) vagy egyedi (`UNIQUE`) mezőben már létezik. |
| **ORA-02291** | `integrity constraint (...) violated - parent key not found` | Külső kulcs (`FK`) hiba: olyan szülő ID-re hivatkozol beszúráskor, ami nem létezik a hivatkozott táblában! |
| **ORA-02292** | `integrity constraint (...) violated - child record found` | Törölni akarsz a szülő táblából egy sort, amire a gyerek táblában még mutat külső kulcs! Töröld előbb a gyereket vagy használj `ON DELETE CASCADE`-et. |
| **ORA-01400** | `cannot insert NULL into (...)` | Nem adtál meg értéket egy olyan mezőnél, amire `NOT NULL` kényszer van érvényben. |
| **ORA-01722** | `invalid number` | Szám típusú mezőbe nem konvertálható szöveget próbálsz beletuszkolni. |
| **ORA-00937** | `not a single-group group function` | A SELECT-ben van aggregáló függvény (`COUNT`, `SUM` stb.) és sima oszlop is, de a sima oszlopot elfelejtetted felvenni a `GROUP BY`-ba! |
| **ORA-00918** | `column ambiguously defined` | Két összekapcsolt táblában azonos nevű oszlop szerepel, és a SELECT-ben nem írtad elé a tábla nevét/aliasát (pl. `id` helyett `k.id` vagy `t.id`). |
| **ORA-00933** | `SQL command not properly ended` | Szintaktikai hiba: felesleges vagy hiányzó vessző, rossz helyre tett kulcsszó vagy pontosvessző alkérdezés belsejében. |
| **ORA-00054** | `resource busy and acquire with NOWAIT specified` | Egy másik session vagy tranzakció zárolta a sort/táblát (elfelejtett `COMMIT` miatti lock). Menj a másik munkalapra és adj ki egy `COMMIT;`-ot! |