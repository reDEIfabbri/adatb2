-- =============================================================
-- Próba ZH megoldás – TERMEK_NYILVANTARTO séma
-- Futtatás: PL/SQL Developer, TERMEK_NYILVANTARTO felhasználóval
-- =============================================================

-- =============================================================
-- 1. feladat: ty_termek_type típus
-- =============================================================

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

-- =============================================================
-- 2. feladat: get_termek_adatok függvény
-- =============================================================

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
    RETURN ty_termek_type();
  WHEN TOO_MANY_ROWS THEN
    RETURN NULL;
END get_termek_adatok;
/

-- =============================================================
-- 3. feladat: get_termek_nevek_by_bolt függvény
-- =============================================================

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

-- =============================================================
-- 4. feladat: pkg_raktar csomag
-- =============================================================

-- Csomag fejléc
CREATE OR REPLACE PACKAGE pkg_raktar AS
  gv_alap_keszlet NUMBER;

  FUNCTION  get_keszlet_ertek(p_bt_id IN NUMBER) RETURN NUMBER;
  PROCEDURE ar_kalkulacio(p_bt_id IN NUMBER);
  PROCEDURE print_termek_boltok(p_termek_id IN NUMBER);
END pkg_raktar;
/

-- Csomag törzs
CREATE OR REPLACE PACKAGE BODY pkg_raktar AS

  -- get_keszlet_ertek: készlet * egységár, vagy -1 / -2
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
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN TOO_MANY_ROWS THEN
      RETURN -2;
  END get_keszlet_ertek;

  -- ar_kalkulacio: ha készlet < gv_alap_keszlet, egységár +10%
  PROCEDURE ar_kalkulacio(p_bt_id IN NUMBER) IS
    v_keszlet NUMBER;
  BEGIN
    SELECT keszlet
      INTO v_keszlet
      FROM bolt_termek
     WHERE id = p_bt_id;

    IF v_keszlet < gv_alap_keszlet THEN
      UPDATE bolt_termek
         SET egysegar = egysegar * 1.1
       WHERE id = p_bt_id;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: nincs adat a megadott azonositoval.');
    WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: tul sok talalt.');
  END ar_kalkulacio;

  -- print_termek_boltok: termék neve + boltok listája
  PROCEDURE print_termek_boltok(p_termek_id IN NUMBER) IS
    v_nev VARCHAR2(250);
    CURSOR cur_boltok IS
      SELECT b.nev
        FROM bolt_termek bt
        JOIN bolt b ON b.id = bt.bolt_id
       WHERE bt.termek_id = p_termek_id;
  BEGIN
    SELECT megnevezes
      INTO v_nev
      FROM termek
     WHERE id = p_termek_id;

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

-- Inicializációs blokk
BEGIN
  gv_alap_keszlet := 100;
END pkg_raktar;
/
