# ZH2 Felkészítő – Teljes Tudásbázis 📚

## Séma: TERMEK_NYILVANTARTO (ZH2 séma)

```
BOLT (Bolt)
├── id          NUMBER       PK
├── nev         VARCHAR2(250)
└── cim         VARCHAR2(500)

TERMEK (Termék)
├── id          NUMBER       PK
├── megnevezes  VARCHAR2(250)
└── reszletek   VARCHAR2(2000)  (nullable)

BOLT_TERMEK (Bolt-Termék kapcsolat: készlet + ár)
├── id          NUMBER       PK
├── bolt_id     NUMBER       FK → BOLT.id
├── termek_id   NUMBER       FK → TERMEK.id
├── egysegar    NUMBER
└── keszlet     NUMBER
    UNIQUE(bolt_id, termek_id)
```

### Tesztadatok

| bolt.id | nev             | cim                      |
|---------|-----------------|--------------------------|
| 12300   | Szuper Diszkont  | Budapest, Fő utca 1.     |
| 12301   | Sarki Kisbolt    | Pécs, Alma utca 5.       |
| 12302   | Nagy ABC         | Debrecen, Piac utca 12.  |

| termek.id | megnevezes | reszletek                    |
|-----------|------------|------------------------------|
| 9000      | Tej        | 1.5% zsírtartalom, 1 liter   |
| 9001      | Kenyér     | Félbarna, szeletelt, 500g    |
| 9002      | Ásványvíz  | Szénsavmentes, 1.5 liter    |
| 9003      | Alma       | Jonagold, 1 kg               |

| bolt_termek.id | bolt_id | termek_id | egysegar | keszlet |
|----------------|---------|-----------|----------|---------|
| 10000          | 12300   | 9000      | 350      | 120     |
| 10001          | 12300   | 9001      | 550      | 45      |
| 10002          | 12301   | 9000      | 400      | 30      |
| 10003          | 12301   | 9002      | 150      | 200     |
| 10004          | 12302   | 9003      | 600      | 50      |

---

## 1. PL/SQL blokk szerkezete

```plsql
DECLARE
  -- Deklarációs rész (opcionális)
BEGIN
  -- Végrehajtható rész (kötelező)
EXCEPTION
  -- Kivételkezelő rész (opcionális)
END;
/
```

> **Fontos**: A `/` jel a blokk végén szükséges a PL/SQL Developer-ben és SQL*Plus-ban is a végrehajtáshoz.

---

## 2. Változók és típusok

### Alapvető deklarációk

```plsql
v_nev     VARCHAR2(100);          -- szöveges, NULL alapértékkel
v_szam    NUMBER := 0;             -- szám, alapértékkel
v_datum   DATE := SYSDATE;         -- aktuális dátum
b_ok      BOOLEAN := TRUE;         -- logikai (csak PL/SQL-ben!)
c_max     CONSTANT NUMBER := 100;  -- konstans
```

### %TYPE – oszlop típusának átvétele

```plsql
v_nev termek.megnevezes%TYPE;
-- A változó automatikusan ugyanolyan típusú lesz, mint termek.megnevezes
```

### %ROWTYPE – teljes sor típusának átvétele

```plsql
v_sor bolt%ROWTYPE;
-- Tartalmazza: v_sor.id, v_sor.nev, v_sor.cim
```

---

## 3. Vezérlési szerkezetek

### IF-THEN-ELSIF-ELSE

```plsql
IF v_keszlet = 0 THEN
  DBMS_OUTPUT.PUT_LINE('Elfogyott!');
ELSIF v_keszlet < 50 THEN
  DBMS_OUTPUT.PUT_LINE('Kevés van!');
ELSE
  DBMS_OUTPUT.PUT_LINE('Rendben.');
END IF;
```

### CASE (searched)

```plsql
v_eredmeny := CASE
  WHEN v_ar < 200 THEN 'Olcsó'
  WHEN v_ar < 500 THEN 'Közepes'
  ELSE 'Drága'
END;
```

### CASE (simple)

```plsql
v_szoveg := CASE v_kategoria
  WHEN 'A' THEN 'Első osztályú'
  WHEN 'B' THEN 'Másodosztályú'
  ELSE 'Ismeretlen'
END;
```

---

## 4. Ciklusok

### Alap LOOP

```plsql
LOOP
  EXIT WHEN v_szamlalo > 10;
  v_szamlalo := v_szamlalo + 1;
END LOOP;
```

### WHILE LOOP

```plsql
WHILE v_szamlalo <= 10 LOOP
  DBMS_OUTPUT.PUT_LINE(v_szamlalo);
  v_szamlalo := v_szamlalo + 1;
END LOOP;
```

### FOR LOOP

```plsql
FOR i IN 1..10 LOOP
  DBMS_OUTPUT.PUT_LINE('Szám: ' || i);
END LOOP;
```

### FOR LOOP visszafelé (REVERSE)

```plsql
FOR i IN REVERSE 1..10 LOOP
  DBMS_OUTPUT.PUT_LINE('Visszafelé: ' || i);
END LOOP;
```

---

## 5. Kurzorok

### Implicit kurzor (SELECT INTO)

```plsql
DECLARE
  v_nev termek.megnevezes%TYPE;
BEGIN
  SELECT megnevezes INTO v_nev FROM termek WHERE id = 9000;
  DBMS_OUTPUT.PUT_LINE(v_nev);  -- 'Tej'
END;
/
```

> Pontosan 1 sort kell visszaadnia. Ha 0 → `NO_DATA_FOUND`, ha több → `TOO_MANY_ROWS`.

### Explicit kurzor – OPEN/FETCH/CLOSE

```plsql
DECLARE
  CURSOR cur_boltok IS
    SELECT nev, cim FROM bolt ORDER BY nev;
  v_rec cur_boltok%ROWTYPE;
  v_count NUMBER := 0;
BEGIN
  OPEN cur_boltok;
  LOOP
    FETCH cur_boltok INTO v_rec;
    EXIT WHEN cur_boltok%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_rec.nev || ' – ' || v_rec.cim);
    v_count := v_count + 1;
  END LOOP;
  CLOSE cur_boltok;

  IF v_count = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nincs bolt!');
  END IF;
END;
/
```

### Kurzor FOR LOOP (egyszerűsített – automatikus OPEN/FETCH/CLOSE)

```plsql
DECLARE
  CURSOR cur_termekek IS
    SELECT megnevezes, reszletek FROM termek ORDER BY megnevezes;
BEGIN
  FOR rec IN cur_termekek LOOP
    DBMS_OUTPUT.PUT_LINE(rec.megnevezes || ': ' || NVL(rec.reszletek, 'N/A'));
  END LOOP;
END;
/
```

### Kurzor FOR LOOP inline lekérdezéssel

```plsql
BEGIN
  FOR rec IN (SELECT nev FROM bolt ORDER BY nev) LOOP
    DBMS_OUTPUT.PUT_LINE(rec.nev);
  END LOOP;
END;
/
```

### Paraméteres kurzor

```plsql
DECLARE
  CURSOR cur_bolt_termekek(p_bolt_id NUMBER) IS
    SELECT t.megnevezes, bt.egysegar, bt.keszlet
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = p_bolt_id
     ORDER BY t.megnevezes;
BEGIN
  FOR rec IN cur_bolt_termekek(12300) LOOP
    DBMS_OUTPUT.PUT_LINE(rec.megnevezes || ' – Ár: ' || rec.egysegar || ' – Készlet: ' || rec.keszlet);
  END LOOP;
END;
/
```

### Kurzor attribútumok

| Attribútum   | Jelentés                        |
|-------------|--------------------------------|
| `%FOUND`    | Utolsó FETCH talált sort        |
| `%NOTFOUND` | Utolsó FETCH nem talált sort    |
| `%ROWCOUNT` | Eddig FETCH-elt sorok száma     |
| `%ISOPEN`   | Kurzor nyitva van-e             |

### Implicit SQL kurzor attribútumok (DML után)

| Attribútum      | Leírás                                   |
|-----------------|------------------------------------------|
| `SQL%FOUND`     | Az utolsó DML érintett legalább 1 sort   |
| `SQL%NOTFOUND`  | Az utolsó DML nem érintett sort          |
| `SQL%ROWCOUNT`  | Az utolsó DML által érintett sorok száma |

---

## 6. Kivételkezelés

```plsql
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nincs adat!');
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Túl sok sor!');
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Duplikált érték!');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Egyéb hiba: ' || SQLERRM);
END;
```

### Fontos beépített kivételek

| Kivétel              | Mikor váltódik ki                    |
|----------------------|--------------------------------------|
| `NO_DATA_FOUND`      | SELECT INTO nem talál sort           |
| `TOO_MANY_ROWS`      | SELECT INTO több sort ad vissza      |
| `ZERO_DIVIDE`        | Nullával való osztás                  |
| `VALUE_ERROR`        | Típus- vagy méretprobléma            |
| `INVALID_CURSOR`     | Nem nyitott kurzorra hivatkozás      |
| `DUP_VAL_ON_INDEX`   | UNIQUE/PK constraint sérülés         |

> **Fontos**: `COUNT(*)` és `MAX()` aggregáló függvények **mindig** pontosan 1 sort adnak vissza (NULL-t, ha nincs adat), ezért `NO_DATA_FOUND` **soha** nem dobódik aggregáló lekérdezéseknél! Ennek ellenére a feladatok gyakran kérik a kezelését.

---

## 7. DBMS_OUTPUT – Konzolra írás

```plsql
DBMS_OUTPUT.PUT_LINE('Teljes sor szöveggel');    -- kiír + új sor
DBMS_OUTPUT.PUT('Nincs sortörés');                -- kiír, nincs új sor
DBMS_OUTPUT.NEW_LINE;                             -- új sor kiírása
```

```plsql
-- NULL érték kiírása NVL-lel
DBMS_OUTPUT.PUT_LINE('Érték: ' || NVL(v_val, 'NULL'));

-- Dátum formázva
DBMS_OUTPUT.PUT_LINE('Dátum: ' || TO_CHAR(SYSDATE, 'YYYY.MM.DD HH24:MI:SS'));
```

> PL/SQL Developer-ben automatikusan engedélyezve van. SQL*Plus-ban: `SET SERVEROUTPUT ON;`

---

## 8. Tárolt eljárás (PROCEDURE)

```plsql
CREATE OR REPLACE PROCEDURE eljaras_nev (
  p_id   IN  NUMBER,
  p_nev  OUT VARCHAR2
)
IS
  -- lokális változók
BEGIN
  SELECT megnevezes INTO p_nev FROM termek WHERE id = p_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_nev := 'Ismeretlen';
END eljaras_nev;
/
```

### Paraméter módok

| Mód      | Leírás                          |
|----------|--------------------------------|
| `IN`     | Bemeneti (alapértelmezett)      |
| `OUT`    | Kimeneti                        |
| `IN OUT` | Be- és kimeneti                 |

### Eljárás hívása

```plsql
BEGIN
  eljaras_nev(9000, :v_output);
END;
/
```

### Tipikus ZH feladat: Eljárás kurzorral és kivételkezeléssel

```plsql
CREATE OR REPLACE PROCEDURE print_bolt_termekek(p_bolt_id IN NUMBER) IS
  v_bolt_nev bolt.nev%TYPE;
  CURSOR cur_termekek IS
    SELECT t.megnevezes, bt.egysegar, bt.keszlet
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = p_bolt_id;
BEGIN
  -- Bolt neve lekérdezése
  SELECT nev INTO v_bolt_nev FROM bolt WHERE id = p_bolt_id;
  DBMS_OUTPUT.PUT_LINE('Bolt: ' || v_bolt_nev);

  -- Termékek listázása kurzorral
  FOR rec IN cur_termekek LOOP
    DBMS_OUTPUT.PUT_LINE('  ' || rec.megnevezes || 
                         ' | Ár: ' || rec.egysegar || 
                         ' | Készlet: ' || rec.keszlet);
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nem található bolt!');
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Túl sok eredmény!');
END print_bolt_termekek;
/
```

---

## 9. Tárolt függvény (FUNCTION)

```plsql
CREATE OR REPLACE FUNCTION fuggveny_nev(p_id IN NUMBER)
  RETURN VARCHAR2
IS
  v_nev VARCHAR2(250);
BEGIN
  SELECT megnevezes INTO v_nev FROM termek WHERE id = p_id;
  RETURN v_nev;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN TOO_MANY_ROWS THEN
    RETURN NULL;
END fuggveny_nev;
/
```

> **Különbség**: Függvénynek mindig van `RETURN` értéke. SQL-ből is hívható: `SELECT fuggveny_nev(9000) FROM dual;`

### Tipikus ZH feladat: Függvény típussal visszatérve

```plsql
CREATE OR REPLACE FUNCTION get_termek_adatok(p_termek_id IN NUMBER)
  RETURN ty_termek_type
IS
  v_id   NUMBER;
  v_nev  VARCHAR2(250);
BEGIN
  SELECT id, megnevezes
    INTO v_id, v_nev
    FROM termek
   WHERE id = p_termek_id;

  RETURN ty_termek_type(v_id, v_nev);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ty_termek_type();        -- paraméter nélküli konstruktor
  WHEN TOO_MANY_ROWS THEN
    RETURN NULL;
END get_termek_adatok;
/
```

### Tipikus ZH feladat: Függvény COUNT + elágazás + LISTAGG

```plsql
CREATE OR REPLACE FUNCTION get_termek_nevek_by_bolt(p_bolt_id IN NUMBER)
  RETURN VARCHAR2
IS
  v_count  NUMBER;
  v_result VARCHAR2(4000);
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM bolt_termek bt
    JOIN termek t ON t.id = bt.termek_id
   WHERE bt.bolt_id = p_bolt_id;

  IF v_count = 0 THEN
    RETURN 'Nincs termek!';
  ELSIF v_count = 1 THEN
    SELECT t.megnevezes
      INTO v_result
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = p_bolt_id;
    RETURN v_result;
  ELSE
    SELECT LISTAGG(t.megnevezes, ',') WITHIN GROUP (ORDER BY t.megnevezes)
      INTO v_result
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = p_bolt_id;
    RETURN v_result;
  END IF;
END get_termek_nevek_by_bolt;
/
```

---

## 10. Csomag (PACKAGE)

### Fejléc (specifikáció) – publikus interfész

```plsql
CREATE OR REPLACE PACKAGE pkg_nev AS
  gv_valtozo NUMBER;    -- csomagszintű változó (publikus)

  FUNCTION  fuggveny_nev(p_id IN NUMBER) RETURN NUMBER;
  PROCEDURE eljaras_nev(p_id IN NUMBER);
END pkg_nev;
/
```

### Törzs (body) – implementáció

```plsql
CREATE OR REPLACE PACKAGE BODY pkg_nev AS

  FUNCTION fuggveny_nev(p_id IN NUMBER) RETURN NUMBER IS
    v_ertek NUMBER;
  BEGIN
    SELECT keszlet * egysegar INTO v_ertek FROM bolt_termek WHERE id = p_id;
    RETURN v_ertek;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN -1;
    WHEN TOO_MANY_ROWS THEN RETURN -2;
  END fuggveny_nev;

  PROCEDURE eljaras_nev(p_id IN NUMBER) IS
  BEGIN
    -- implementáció
    NULL;
  END eljaras_nev;

-- Inicializációs blokk (egyszer fut, a csomag első használatakor)
BEGIN
  gv_valtozo := 100;
END pkg_nev;
/
```

### Hívás

```plsql
-- Csomagszintű változó
DBMS_OUTPUT.PUT_LINE(pkg_nev.gv_valtozo);

-- Függvény
SELECT pkg_nev.fuggveny_nev(10000) FROM dual;

-- Eljárás
BEGIN
  pkg_nev.eljaras_nev(10000);
END;
/
```

### Teljes ZH-típusú csomag példa (TERMEK_NYILVANTARTO sémára)

```plsql
-- Fejléc
CREATE OR REPLACE PACKAGE pkg_raktar AS
  gv_alap_keszlet NUMBER;

  FUNCTION  get_keszlet_ertek(p_bt_id IN NUMBER) RETURN NUMBER;
  PROCEDURE ar_kalkulacio(p_bt_id IN NUMBER);
  PROCEDURE print_termek_boltok(p_termek_id IN NUMBER);
END pkg_raktar;
/

-- Törzs
CREATE OR REPLACE PACKAGE BODY pkg_raktar AS

  FUNCTION get_keszlet_ertek(p_bt_id IN NUMBER) RETURN NUMBER IS
    v_keszlet  NUMBER;
    v_egysegar NUMBER;
  BEGIN
    SELECT keszlet, egysegar
      INTO v_keszlet, v_egysegar
      FROM bolt_termek
     WHERE id = p_bt_id;
    RETURN v_keszlet * v_egysegar;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN -1;
    WHEN TOO_MANY_ROWS THEN RETURN -2;
  END get_keszlet_ertek;

  PROCEDURE ar_kalkulacio(p_bt_id IN NUMBER) IS
    v_keszlet NUMBER;
  BEGIN
    SELECT keszlet INTO v_keszlet FROM bolt_termek WHERE id = p_bt_id;

    IF v_keszlet < gv_alap_keszlet THEN
      UPDATE bolt_termek SET egysegar = egysegar * 1.1 WHERE id = p_bt_id;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: nincs adat a megadott azonositoval.');
    WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: tul sok talalt.');
  END ar_kalkulacio;

  PROCEDURE print_termek_boltok(p_termek_id IN NUMBER) IS
    v_nev VARCHAR2(250);
    CURSOR cur_boltok IS
      SELECT b.nev
        FROM bolt_termek bt
        JOIN bolt b ON b.id = bt.bolt_id
       WHERE bt.termek_id = p_termek_id;
  BEGIN
    SELECT megnevezes INTO v_nev FROM termek WHERE id = p_termek_id;
    DBMS_OUTPUT.PUT_LINE('Termek neve: ' || v_nev);

    FOR rec IN cur_boltok LOOP
      DBMS_OUTPUT.PUT_LINE('Bolt: ' || rec.nev);
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: nem talalhato termek.');
    WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: tul sok eredmeny.');
  END print_termek_boltok;

BEGIN
  gv_alap_keszlet := 100;
END pkg_raktar;
/
```

---

## 11. Object típus (TYPE ... AS OBJECT)

### Típus létrehozása

```plsql
CREATE OR REPLACE TYPE ty_termek_type AS OBJECT (
  termek_id   NUMBER,
  megnevezes  VARCHAR2(250)
);
/
```

### Paraméter nélküli konstruktor

```plsql
CREATE OR REPLACE TYPE ty_termek_type AS OBJECT (
  termek_id   NUMBER,
  megnevezes  VARCHAR2(250),
  CONSTRUCTOR FUNCTION ty_termek_type RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY ty_termek_type AS
  CONSTRUCTOR FUNCTION ty_termek_type RETURN SELF AS RESULT IS
  BEGIN
    SELF.termek_id  := NULL;
    SELF.megnevezes := NULL;
    RETURN;
  END;
END;
/
```

### Használat

```plsql
DECLARE
  v_t ty_termek_type;
BEGIN
  -- Paraméter nélküli konstruktor → NULL attribútumok
  v_t := ty_termek_type();
  DBMS_OUTPUT.PUT_LINE('ID: ' || NVL(TO_CHAR(v_t.termek_id), 'NULL'));

  -- Teljes konstruktor (automatikusan generált)
  v_t := ty_termek_type(9000, 'Tej');
  DBMS_OUTPUT.PUT_LINE('ID: ' || v_t.termek_id || ', Név: ' || v_t.megnevezes);
END;
/
```

### Object típus használata SELECT-ben

```plsql
DECLARE
  v_t ty_termek_type;
BEGIN
  SELECT ty_termek_type(id, megnevezes)
    INTO v_t
    FROM termek
   WHERE id = 9000;
  DBMS_OUTPUT.PUT_LINE(v_t.termek_id || ': ' || v_t.megnevezes);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_t := ty_termek_type();
    DBMS_OUTPUT.PUT_LINE('Nem található.');
END;
/
```

> **Jogosultság**: `GRANT CREATE TYPE TO séma_nev;` szükséges (SYSDBA-ként futtatandó).

---

## 12. Kollekciók

### Nested Table (TYPE ... IS TABLE OF)

```plsql
-- Séma szintű típus (SQL-ben is használható)
CREATE OR REPLACE TYPE ty_termek_list IS TABLE OF ty_termek_type;
/
```

```plsql
DECLARE
  v_list ty_termek_list := ty_termek_list();
BEGIN
  v_list.EXTEND;
  v_list(1) := ty_termek_type(9000, 'Tej');

  v_list.EXTEND;
  v_list(2) := ty_termek_type(9001, 'Kenyér');

  FOR i IN 1..v_list.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(v_list(i).termek_id || ': ' || v_list(i).megnevezes);
  END LOOP;
END;
/
```

### Nested Table BULK COLLECT-tel

```plsql
DECLARE
  v_list ty_termek_list := ty_termek_list();
BEGIN
  SELECT ty_termek_type(id, megnevezes)
    BULK COLLECT INTO v_list
    FROM termek
   ORDER BY id;

  FOR i IN 1..v_list.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(v_list(i).termek_id || ': ' || v_list(i).megnevezes);
  END LOOP;
END;
/
```

### Asszociatív tömb (INDEX BY) – csak PL/SQL-ben

```plsql
DECLARE
  TYPE t_termek_map IS TABLE OF termek.megnevezes%TYPE INDEX BY PLS_INTEGER;
  v_map t_termek_map;
  v_idx PLS_INTEGER;
BEGIN
  -- Feltöltés kurzorból
  FOR rec IN (SELECT id, megnevezes FROM termek ORDER BY id) LOOP
    v_map(rec.id) := rec.megnevezes;
  END LOOP;

  -- Iterálás FIRST/NEXT-tel (kulcsok nem feltétlenül folytonosak!)
  v_idx := v_map.FIRST;
  WHILE v_idx IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_idx || ' → ' || v_map(v_idx));
    v_idx := v_map.NEXT(v_idx);
  END LOOP;
END;
/
```

#### VARCHAR2 kulccsal

```plsql
DECLARE
  TYPE t_ar_map IS TABLE OF NUMBER INDEX BY VARCHAR2(250);
  v_arak t_ar_map;
  v_key  VARCHAR2(250);
BEGIN
  FOR rec IN (SELECT t.megnevezes, bt.egysegar FROM bolt_termek bt JOIN termek t ON t.id = bt.termek_id) LOOP
    IF v_arak.EXISTS(rec.megnevezes) THEN
      v_arak(rec.megnevezes) := v_arak(rec.megnevezes) + rec.egysegar;
    ELSE
      v_arak(rec.megnevezes) := rec.egysegar;
    END IF;
  END LOOP;

  v_key := v_arak.FIRST;
  WHILE v_key IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(v_key || ': ' || v_arak(v_key));
    v_key := v_arak.NEXT(v_key);
  END LOOP;
END;
/
```

### Kollekció metódusok

| Metódus         | Leírás                                  |
|----------------|-----------------------------------------|
| `.COUNT`       | Elemek száma                             |
| `.FIRST`       | Első index                               |
| `.LAST`        | Utolsó index                             |
| `.NEXT(i)`     | `i` utáni következő index               |
| `.PRIOR(i)`    | `i` előtti index                         |
| `.EXISTS(i)`   | Létezik-e elem az `i` indexen            |
| `.EXTEND`      | Új elem hozzáadása (nested table/varray) |
| `.EXTEND(n)`   | `n` új elem hozzáadása                   |
| `.DELETE`      | Összes elem törlése                      |
| `.DELETE(i)`   | `i` indexű elem törlése                  |

---

## 13. BULK COLLECT

### Egyszerű BULK COLLECT

```plsql
DECLARE
  TYPE t_nev_tab IS TABLE OF termek.megnevezes%TYPE;
  v_nevek t_nev_tab;
BEGIN
  SELECT megnevezes BULK COLLECT INTO v_nevek FROM termek ORDER BY megnevezes;

  IF v_nevek.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nincs termék.');
  ELSE
    FOR i IN 1..v_nevek.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(i || '. ' || v_nevek(i));
    END LOOP;
  END IF;
END;
/
```

### BULK COLLECT LIMIT-tel (batch feldolgozás)

```plsql
DECLARE
  CURSOR cur IS SELECT megnevezes FROM termek ORDER BY megnevezes;
  TYPE t_tab IS TABLE OF termek.megnevezes%TYPE;
  v_batch t_tab;
  v_total NUMBER := 0;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur BULK COLLECT INTO v_batch LIMIT 2;
    EXIT WHEN v_batch.COUNT = 0;

    DBMS_OUTPUT.PUT_LINE('--- Batch ---');
    FOR i IN 1..v_batch.COUNT LOOP
      v_total := v_total + 1;
      DBMS_OUTPUT.PUT_LINE(v_total || '. ' || v_batch(i));
    END LOOP;
  END LOOP;
  CLOSE cur;
END;
/
```

### BULK COLLECT %ROWTYPE-pal

```plsql
DECLARE
  TYPE t_bolt_tab IS TABLE OF bolt%ROWTYPE;
  v_boltok t_bolt_tab;
BEGIN
  SELECT * BULK COLLECT INTO v_boltok FROM bolt;

  FOR i IN 1..v_boltok.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(v_boltok(i).nev || ' – ' || v_boltok(i).cim);
  END LOOP;
END;
/
```

---

## 14. String művelet: LISTAGG

```plsql
-- SQL-ben: boltok termékeinek összefűzése
SELECT b.nev AS bolt_nev,
       LISTAGG(t.megnevezes, ', ') WITHIN GROUP (ORDER BY t.megnevezes) AS termekek
  FROM bolt b
  JOIN bolt_termek bt ON b.id = bt.bolt_id
  JOIN termek t ON t.id = bt.termek_id
 GROUP BY b.nev
 ORDER BY b.nev;
```

### PL/SQL-ben kézi összefűzés

```plsql
DECLARE
  v_result VARCHAR2(4000) := '';
  v_first  BOOLEAN := TRUE;
  CURSOR cur IS
    SELECT t.megnevezes
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = 12300
     ORDER BY t.megnevezes;
BEGIN
  FOR rec IN cur LOOP
    IF v_first THEN
      v_first := FALSE;
    ELSE
      v_result := v_result || ', ';
    END IF;
    v_result := v_result || rec.megnevezes;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Termékek: ' || v_result);
END;
/
```

---

## 15. Szekvenciák

```plsql
CREATE SEQUENCE seq_bolt_termek_id
  START WITH 20000
  INCREMENT BY 1
  NOCACHE;
```

```plsql
INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet)
VALUES (seq_bolt_termek_id.NEXTVAL, 12302, 9000, 380, 60);

-- Aktuális érték lekérdezése
SELECT seq_bolt_termek_id.CURRVAL FROM dual;
```

---

## 16. Dinamikus SQL (EXECUTE IMMEDIATE)

```plsql
DECLARE
  v_sql VARCHAR2(200);
  v_nev VARCHAR2(250);
BEGIN
  v_sql := 'SELECT megnevezes FROM termek WHERE id = :1';
  EXECUTE IMMEDIATE v_sql INTO v_nev USING 9000;
  DBMS_OUTPUT.PUT_LINE(v_nev);
END;
/
```

### DDL utasítás dinamikusan

```plsql
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE temp_tabla (id NUMBER)';
END;
/
```

> DDL-nél nem lehet bind változókat (`:1`) használni.

---

## 17. Hasznos függvények

### String függvények

| Függvény                       | Leírás                    | Példa                               |
|-------------------------------|---------------------------|--------------------------------------|
| `LENGTH(s)`                   | Szöveg hossza             | `LENGTH('alma')` → 4               |
| `SUBSTR(s, pos, len)`         | Részsztring               | `SUBSTR('alma', 2, 3)` → `'lma'`   |
| `INSTR(s, keresett)`          | Pozíció keresés           | `INSTR('alma', 'l')` → 2           |
| `UPPER(s)` / `LOWER(s)`      | Nagy/kisbetűs             |                                      |
| `TRIM(s)`                     | Szóközök levágása         |                                      |
| `REPLACE(s, mit, mire)`       | Csere                     |                                      |
| `LPAD(s, n, kar)` / `RPAD`   | Bal/jobb kiegészítés      |                                      |

### NULL kezelés

| Függvény                | Leírás                              |
|------------------------|--------------------------------------|
| `NVL(a, b)`            | Ha `a` NULL → `b`                   |
| `NVL2(a, b, c)`        | Ha `a` nem NULL → `b`, különben `c` |
| `COALESCE(a, b, c)`    | Első nem NULL érték                  |

### Konverziók

| Függvény                        | Leírás             | Példa                                  |
|--------------------------------|--------------------|-----------------------------------------|
| `TO_CHAR(datum, formátum)`     | Dátum → szöveg     | `TO_CHAR(SYSDATE, 'YYYY.MM.DD')`       |
| `TO_DATE(s, formátum)`         | Szöveg → dátum     | `TO_DATE('2024.01.15', 'YYYY.MM.DD')`  |
| `TO_NUMBER(s)`                 | Szöveg → szám      | `TO_NUMBER('42')`                       |

### Egyéb

| Függvény           | Leírás                |
|-------------------|-----------------------|
| `SYSDATE`         | Aktuális dátum+idő    |
| `SYSTIMESTAMP`     | Aktuális timestamp    |
| `USER`            | Aktuális felhasználó  |
| `ROUND(szám, n)`  | Kerekítés             |
| `MOD(a, b)`       | Maradékos osztás      |
| `ABS(n)`          | Abszolút érték        |

---

## 18. Tranzakciókezelés

```plsql
COMMIT;            -- Véglegesítés
ROLLBACK;          -- Visszavonás
SAVEPOINT sp1;     -- Mentési pont
ROLLBACK TO sp1;   -- Visszavonás mentési pontig
```

---

# Lehetséges ZH feladatok és megoldások

Az alábbi feladatok a TERMEK_NYILVANTARTO sémára épülnek, és lefedik az összes tanult témát.

---

## F1. Object típus létrehozása paraméter nélküli konstruktorral

**Feladat**: Hozz létre egy `ty_bolt_type` típust `bolt_id` (NUMBER) és `bolt_nev` (VARCHAR2(250)) attribútumokkal, és paraméter nélküli konstruktorral.

```plsql
CREATE OR REPLACE TYPE ty_bolt_type AS OBJECT (
  bolt_id   NUMBER,
  bolt_nev  VARCHAR2(250),
  CONSTRUCTOR FUNCTION ty_bolt_type RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY ty_bolt_type AS
  CONSTRUCTOR FUNCTION ty_bolt_type RETURN SELF AS RESULT IS
  BEGIN
    SELF.bolt_id  := NULL;
    SELF.bolt_nev := NULL;
    RETURN;
  END;
END;
/
```

---

## F2. Függvény: adatok lekérdezése, visszatérés típussal

**Feladat**: Készíts egy `get_bolt_info` függvényt, amely bolt ID alapján visszaad egy `ty_bolt_type` objektumot. Ha nincs adat → paraméter nélküli konstruktor. Ha túl sok → NULL.

```plsql
CREATE OR REPLACE FUNCTION get_bolt_info(p_bolt_id IN NUMBER)
  RETURN ty_bolt_type
IS
  v_id  NUMBER;
  v_nev VARCHAR2(250);
BEGIN
  SELECT id, nev INTO v_id, v_nev FROM bolt WHERE id = p_bolt_id;
  RETURN ty_bolt_type(v_id, v_nev);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ty_bolt_type();
  WHEN TOO_MANY_ROWS THEN
    RETURN NULL;
END get_bolt_info;
/
```

---

## F3. Függvény: COUNT + elágazás + összefűzés

**Feladat**: Készíts egy `get_bolt_nevek_by_termek` függvényt, amely egy termék ID-t kap, és visszaadja azon boltok neveit, ahol a termék kapható. 0 db → `'Nincs bolt!'`, 1 db → az a boltnév, >1 db → vesszővel összefűzve, név szerint rendezve.

```plsql
CREATE OR REPLACE FUNCTION get_bolt_nevek_by_termek(p_termek_id IN NUMBER)
  RETURN VARCHAR2
IS
  v_count  NUMBER;
  v_result VARCHAR2(4000);
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM bolt_termek bt
    JOIN bolt b ON b.id = bt.bolt_id
   WHERE bt.termek_id = p_termek_id;

  IF v_count = 0 THEN
    RETURN 'Nincs bolt!';
  ELSIF v_count = 1 THEN
    SELECT b.nev
      INTO v_result
      FROM bolt_termek bt
      JOIN bolt b ON b.id = bt.bolt_id
     WHERE bt.termek_id = p_termek_id;
    RETURN v_result;
  ELSE
    SELECT LISTAGG(b.nev, ',') WITHIN GROUP (ORDER BY b.nev)
      INTO v_result
      FROM bolt_termek bt
      JOIN bolt b ON b.id = bt.bolt_id
     WHERE bt.termek_id = p_termek_id;
    RETURN v_result;
  END IF;
END get_bolt_nevek_by_termek;
/
```

---

## F4. Eljárás: UPDATE + kivételkezelés

**Feladat**: Készíts egy `keszlet_modositas` eljárást, amely egy `bolt_termek` ID-t és egy mennyiséget kap. Csökkentse a készletet a megadott mennyiséggel. Ha a készlet negatívba menne, ne módosítson és írja ki, hogy "Nincs elegendő készlet!". Kezelje az adathiányt.

```plsql
CREATE OR REPLACE PROCEDURE keszlet_modositas(
  p_bt_id      IN NUMBER,
  p_mennyiseg  IN NUMBER
)
IS
  v_keszlet NUMBER;
BEGIN
  SELECT keszlet INTO v_keszlet FROM bolt_termek WHERE id = p_bt_id;

  IF v_keszlet - p_mennyiseg < 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nincs elegendo keszlet! Jelenlegi: ' || v_keszlet);
  ELSE
    UPDATE bolt_termek
       SET keszlet = keszlet - p_mennyiseg
     WHERE id = p_bt_id;
    DBMS_OUTPUT.PUT_LINE('Keszlet csokkentve. Uj ertek: ' || (v_keszlet - p_mennyiseg));
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Hiba: nem talalhato bolt_termek rekord.');
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Hiba: tul sok eredmeny.');
END keszlet_modositas;
/
```

---

## F5. Eljárás: egymásba ágyazott kurzorok

**Feladat**: Készíts egy `print_osszes_bolt_reszletek` eljárást, ami boltokra iterál, és mindegyikhez kiírja a benne kapható termékeket oltásadatokkal.

```plsql
CREATE OR REPLACE PROCEDURE print_osszes_bolt_reszletek IS
  CURSOR cur_boltok IS
    SELECT id, nev, cim FROM bolt ORDER BY nev;

  CURSOR cur_termekek(p_bolt_id NUMBER) IS
    SELECT t.megnevezes, bt.egysegar, bt.keszlet
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = p_bolt_id
     ORDER BY t.megnevezes;

  v_van_termek BOOLEAN;
BEGIN
  FOR bolt_rec IN cur_boltok LOOP
    DBMS_OUTPUT.PUT_LINE('=== ' || bolt_rec.nev || ' (' || bolt_rec.cim || ') ===');

    v_van_termek := FALSE;
    FOR termek_rec IN cur_termekek(bolt_rec.id) LOOP
      v_van_termek := TRUE;
      DBMS_OUTPUT.PUT_LINE('  ' || termek_rec.megnevezes ||
                           ' | Ar: ' || termek_rec.egysegar ||
                           ' | Keszlet: ' || termek_rec.keszlet);
    END LOOP;

    IF NOT v_van_termek THEN
      DBMS_OUTPUT.PUT_LINE('  Nincs termek ebben a boltban.');
    END IF;
  END LOOP;
END print_osszes_bolt_reszletek;
/
```

---

## F6. Csomag: változóval, függvénnyel, eljárással

**Feladat**: Készíts egy `pkg_bolt` csomagot. Legyen benne egy `gv_min_ar` változó (inicializálva 100-ra). Egy `get_bolt_osszar` függvény, ami bolt ID alapján visszaadja az összes termékének készletértékét (`SUM(egysegar * keszlet)`). Egy `dragulas` eljárás, amely bolt ID-t kap, és ha egy termékének ára kisebb, mint `gv_min_ar`, emeli 20%-kal.

```plsql
CREATE OR REPLACE PACKAGE pkg_bolt AS
  gv_min_ar NUMBER;

  FUNCTION  get_bolt_osszar(p_bolt_id IN NUMBER) RETURN NUMBER;
  PROCEDURE dragulas(p_bolt_id IN NUMBER);
END pkg_bolt;
/

CREATE OR REPLACE PACKAGE BODY pkg_bolt AS

  FUNCTION get_bolt_osszar(p_bolt_id IN NUMBER) RETURN NUMBER IS
    v_ossz NUMBER;
  BEGIN
    SELECT NVL(SUM(egysegar * keszlet), 0)
      INTO v_ossz
      FROM bolt_termek
     WHERE bolt_id = p_bolt_id;
    RETURN v_ossz;
  END get_bolt_osszar;

  PROCEDURE dragulas(p_bolt_id IN NUMBER) IS
    CURSOR cur IS
      SELECT id, egysegar FROM bolt_termek WHERE bolt_id = p_bolt_id;
  BEGIN
    FOR rec IN cur LOOP
      IF rec.egysegar < gv_min_ar THEN
        UPDATE bolt_termek
           SET egysegar = egysegar * 1.2
         WHERE id = rec.id;
        DBMS_OUTPUT.PUT_LINE('Ar emelve (ID: ' || rec.id || '): ' ||
                             rec.egysegar || ' -> ' || ROUND(rec.egysegar * 1.2));
      END IF;
    END LOOP;
  END dragulas;

BEGIN
  gv_min_ar := 100;
END pkg_bolt;
/
```

---

## F7. Nested Table: típuslista és BULK COLLECT

**Feladat**: Hozz létre egy `ty_bolt_list` Nested Table típust `ty_bolt_type` elemekből. Kérdezd le az összes boltot BULK COLLECT-tel, és írd ki a nevüket.

```plsql
CREATE OR REPLACE TYPE ty_bolt_list IS TABLE OF ty_bolt_type;
/
```

```plsql
DECLARE
  v_boltok ty_bolt_list;
BEGIN
  SELECT ty_bolt_type(id, nev)
    BULK COLLECT INTO v_boltok
    FROM bolt
   ORDER BY nev;

  FOR i IN 1..v_boltok.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(v_boltok(i).bolt_id || ': ' || v_boltok(i).bolt_nev);
  END LOOP;
END;
/
```

---

## F8. Függvény: legolcsóbb bolt keresése

**Feladat**: Készíts egy `get_legolcsobb_bolt` függvényt, amely termék ID-t kap, és visszaadja annak a boltnak a nevét, ahol a legolcsóbb az adott termék. Ha nem kapható sehol → `'Nem kapható'`.

```plsql
CREATE OR REPLACE FUNCTION get_legolcsobb_bolt(p_termek_id IN NUMBER)
  RETURN VARCHAR2
IS
  v_bolt_nev VARCHAR2(250);
BEGIN
  SELECT b.nev
    INTO v_bolt_nev
    FROM bolt_termek bt
    JOIN bolt b ON b.id = bt.bolt_id
   WHERE bt.termek_id = p_termek_id
     AND bt.egysegar = (SELECT MIN(bt2.egysegar) FROM bolt_termek bt2 WHERE bt2.termek_id = p_termek_id)
     AND ROWNUM = 1;
  RETURN v_bolt_nev;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'Nem kaphato';
END get_legolcsobb_bolt;
/
```

---

## F9. Eljárás: INSERT + szekvencia + DUP_VAL_ON_INDEX

**Feladat**: Készíts egy `uj_bolt_termek` eljárást, amely bolt ID-t, termék ID-t, árat és készletet kap. Szúrd be a `bolt_termek` táblába szekvenciával generált ID-vel. Kezeld a duplikált kulcs hibát.

```plsql
CREATE SEQUENCE seq_bolt_termek_id START WITH 20000 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE PROCEDURE uj_bolt_termek(
  p_bolt_id   IN NUMBER,
  p_termek_id IN NUMBER,
  p_egysegar  IN NUMBER,
  p_keszlet   IN NUMBER
)
IS
BEGIN
  INSERT INTO bolt_termek(id, bolt_id, termek_id, egysegar, keszlet)
  VALUES (seq_bolt_termek_id.NEXTVAL, p_bolt_id, p_termek_id, p_egysegar, p_keszlet);
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Hiba: ez a bolt-termek kapcsolat mar letezik!');
END uj_bolt_termek;
/
```

---

## F10. Asszociatív tömb: termékek bolt szerinti csoportosítása

**Feladat**: Asszociatív tömb segítségével számold meg, hogy boltonként hány termék van, és írd ki.

```plsql
DECLARE
  TYPE t_bolt_count IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  v_counts t_bolt_count;
  v_idx    PLS_INTEGER;
BEGIN
  FOR rec IN (SELECT bolt_id FROM bolt_termek) LOOP
    IF v_counts.EXISTS(rec.bolt_id) THEN
      v_counts(rec.bolt_id) := v_counts(rec.bolt_id) + 1;
    ELSE
      v_counts(rec.bolt_id) := 1;
    END IF;
  END LOOP;

  v_idx := v_counts.FIRST;
  WHILE v_idx IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('Bolt ID ' || v_idx || ': ' || v_counts(v_idx) || ' termek');
    v_idx := v_counts.NEXT(v_idx);
  END LOOP;
END;
/
```

---

## F11. Függvény: átlagár számítás

**Feladat**: Készíts egy `get_atlag_ar` függvényt, amely egy termék ID-t kap és visszaadja az átlagos egységárat az összes bolt alapján. Ha nem kapható → −1.

```plsql
CREATE OR REPLACE FUNCTION get_atlag_ar(p_termek_id IN NUMBER)
  RETURN NUMBER
IS
  v_atlag NUMBER;
BEGIN
  SELECT AVG(egysegar) INTO v_atlag FROM bolt_termek WHERE termek_id = p_termek_id;

  IF v_atlag IS NULL THEN
    RETURN -1;
  END IF;

  RETURN ROUND(v_atlag, 2);
END get_atlag_ar;
/
```

> Megjegyzés: `AVG()` aggregáló, így nem dob `NO_DATA_FOUND`-ot, hanem NULL-t ad ha nincs sor.

---

## F12. Eljárás: feltételes UPDATE kurzorral

**Feladat**: Készíts egy `akcios_arak` eljárást, amely bolt ID-t kap. Minden terméknél, ahol a készlet > 100, csökkentse az árat 15%-kal, és írja ki a változást.

```plsql
CREATE OR REPLACE PROCEDURE akcios_arak(p_bolt_id IN NUMBER) IS
  CURSOR cur IS
    SELECT bt.id, t.megnevezes, bt.egysegar, bt.keszlet
      FROM bolt_termek bt
      JOIN termek t ON t.id = bt.termek_id
     WHERE bt.bolt_id = p_bolt_id;
  v_count NUMBER := 0;
BEGIN
  FOR rec IN cur LOOP
    IF rec.keszlet > 100 THEN
      UPDATE bolt_termek
         SET egysegar = ROUND(egysegar * 0.85)
       WHERE id = rec.id;
      DBMS_OUTPUT.PUT_LINE('Akciozva: ' || rec.megnevezes ||
                           ' | Regi ar: ' || rec.egysegar ||
                           ' | Uj ar: ' || ROUND(rec.egysegar * 0.85));
      v_count := v_count + 1;
    END IF;
  END LOOP;

  IF v_count = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nincs akciozando termek.');
  END IF;
END akcios_arak;
/
```

---

## Összefoglaló – ZH-n szükséges minták

| # | Téma | Kulcs szintaxis |
|---|------|----------------|
| 1 | PL/SQL blokk | `DECLARE ... BEGIN ... EXCEPTION ... END; /` |
| 2 | Változók | `v_x típus := érték;`, `%TYPE`, `%ROWTYPE` |
| 3 | Vezérlés | `IF/ELSIF/ELSE/END IF;`, `CASE WHEN ... END;` |
| 4 | Ciklusok | `LOOP/EXIT WHEN`, `WHILE`, `FOR i IN 1..n`, `FOR REVERSE` |
| 5 | Implicit kurzor | `SELECT ... INTO v_x FROM ... WHERE ...;` |
| 6 | Explicit kurzor | `CURSOR cur IS SELECT ...;` + OPEN/FETCH/CLOSE vagy FOR LOOP |
| 7 | Paraméteres kurzor | `CURSOR cur(p NUMBER) IS SELECT ... WHERE col = p;` |
| 8 | Kivételkezelés | `EXCEPTION WHEN NO_DATA_FOUND THEN ...` |
| 9 | DBMS_OUTPUT | `DBMS_OUTPUT.PUT_LINE('...');` |
| 10 | Eljárás | `CREATE OR REPLACE PROCEDURE nev(p IN típus) IS BEGIN ... END;` |
| 11 | Függvény | `CREATE OR REPLACE FUNCTION nev(p IN típus) RETURN típus IS BEGIN RETURN ...; END;` |
| 12 | Csomag fejléc | `CREATE OR REPLACE PACKAGE nev AS ... END nev;` |
| 13 | Csomag törzs | `CREATE OR REPLACE PACKAGE BODY nev AS ... BEGIN init; END nev;` |
| 14 | Object típus | `CREATE OR REPLACE TYPE ty_x AS OBJECT (...);` |
| 15 | Konstruktor | `CONSTRUCTOR FUNCTION ty_x RETURN SELF AS RESULT` |
| 16 | Nested Table | `CREATE OR REPLACE TYPE ty_x_l IS TABLE OF ty_x;` |
| 17 | Asszociatív tömb | `TYPE t IS TABLE OF típus INDEX BY PLS_INTEGER;` + FIRST/NEXT |
| 18 | BULK COLLECT | `SELECT ... BULK COLLECT INTO v_tab FROM ...;` |
| 19 | LISTAGG | `LISTAGG(col, ',') WITHIN GROUP (ORDER BY col)` |
| 20 | Szekvencia | `seq.NEXTVAL`, `seq.CURRVAL` |
| 21 | Dinamikus SQL | `EXECUTE IMMEDIATE '...' INTO v USING p;` |
| 22 | DUP_VAL_ON_INDEX | INSERT utáni UNIQUE/PK constraint hiba kezelése |

