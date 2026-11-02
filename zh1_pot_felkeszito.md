# Oracle XE & PL/SQL Developer: Átfogó Felkészítő és Megoldókulcs a 1. ZH Póthoz ([zh1_pot.pdf](file:///home/ikolym/gits/adatb2/zh1_pot.pdf))

Ez az útmutató lépésről lépésre, feladatszámozás szerint dolgozza fel a **2024/25-ös Adatbázisok 2 – 1. ZH pót** feladatsorát ([zh1_pot.pdf](file:///home/ikolym/gits/adatb2/zh1_pot.pdf)). A feladatok megoldása és szintaxisa a helyi **Oracle Database Express Edition (XE)** és **Oracle PL/SQL Developer** környezetre, valamint a tantárgy órai anyagaihoz ([`class_work/00_sys.sql`](file:///home/ikolym/gits/adatb2/class_work/00_sys.sql), [`class_work/01_dog_manager.sql`](file:///home/ikolym/gits/adatb2/class_work/01_dog_manager.sql)) igazodik.

---

### Környezet és munkamenet (Oracle XE + PL/SQL Developer)

1. **Adatbázis Kapcsolat (CDB / PDB)**:
   - A modern Oracle XE (18c, 21c) multitenant felépítésű, az alapértelmezett beépülő adatbázis (PDB) neve általában `XEPDB1`.
   - A **0. feladatot** rendszergazdai jogosultsággal kell futtatni (`SYS as SYSDBA` vagy `SYSTEM`).
   - Ha a gyökér konténerbe (`CDB$ROOT`) jelentkeztél be, a felhasználó létrehozása előtt válts át a PDB-re:
     ```sql
     ALTER SESSION SET CONTAINER = XEPDB1;
     ```
2. **PL/SQL Developer beállítások**:
   - Kapcsolódj a `localhost:1521/XEPDB1` szolgáltatáshoz.
   - Használj **SQL Window**-t (`F8` billentyűvel futtatható a teljes ablak vagy a kijelölt blokk).
   - A ZH auditáló programja (`auditalo.exe`) megköveteli, hogy minden feladat megoldását egy-egy különálló `.sql` fájlba mentsük a `zh/` mappán belül (pl. `0.sql`, `1.sql`, ..., `6.sql`).

---

## 0. Feladat: KONYVTAR séma létrehozása és feljogosítása (Beugró)

```sql
-- Rendszergazdaként (SYS / SYSTEM) futtatandó!
-- Oracle XE 18c/21c esetén váltás a PDB-re:
ALTER SESSION SET CONTAINER = XEPDB1;

-- Idempontens felhasználó-törlés: csak akkor dobd el, ha már létezik
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count 
  FROM all_users 
  WHERE username = 'KONYVTAR';

  IF v_count = 1 THEN 
    EXECUTE IMMEDIATE 'DROP USER konyvtar CASCADE';
  END IF;
END;
/

-- Felhasználó (schema) létrehozása
CREATE USER konyvtar 
  IDENTIFIED BY konyvtarJelszo
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

-- Megfelelő fejlesztői jogosultságok kiosztása
GRANT CREATE SESSION TO konyvtar;
GRANT CREATE TABLE TO konyvtar;
GRANT CREATE VIEW TO konyvtar;
GRANT CREATE SEQUENCE TO konyvtar;
GRANT CREATE PROCEDURE TO konyvtar;

-- Munkamenet átállítása az új sémára (vagy jelentkezz be közvetlenül KONYVTAR-ként)
ALTER SESSION SET CURRENT_SCHEMA = konyvtar;
```

### Magyarázat
- **Biztonságos újrafuttatás (Idempotencia)**: A sima `DROP USER` hibaüzenetet ad, ha a séma még nem létezik, a sima `CREATE USER` pedig elhasal (`ORA-01920: user name conflicts with another user name`), ha a séma már bent van. Az órai mintát ([`class_work/00_sys.sql`](file:///home/ikolym/gits/adatb2/class_work/00_sys.sql#L6-L14)) követő dinamikus PL/SQL blokk csak akkor hajtja végre a `CASCADE` törlést, ha az `all_users` táblában szerepel a felhasználó.
- **Táblatér és kvóta**: A `DEFAULT TABLESPACE users` és `QUOTA UNLIMITED ON users` elengedhetetlen, különben az új táblák beszúrásakor `ORA-01950: no privileges on tablespace 'USERS'` hibát kapnánk.
- **Jogok**: A beugróhoz a fejlesztéshez szükséges alapjogok (`CREATE SESSION`, `CREATE TABLE`, `CREATE VIEW`, `CREATE SEQUENCE`, `CREATE PROCEDURE`) elegendőek.
- **Séma váltás**: Az `ALTER SESSION SET CURRENT_SCHEMA = konyvtar;` utasítás után nem kell minden táblát `konyvtar.konyv`-ként megcímezni, vagy a PL/SQL Developerben egyszerűen váltsunk át a `konyvtar` / `konyvtarJelszo` felhasználóra.

---

## 1. Feladat: KONYV és KOLCSONZES táblák létrehozása (1 pont)

```sql
-- KONYVTAR sémaként futtatandó!

-- 1. KONYV tábla
CREATE TABLE konyv (
    id         NUMBER,
    cim        VARCHAR2(200) NOT NULL,
    kategoria  VARCHAR2(100),
    ar         NUMBER
)
TABLESPACE users;

-- 2. KOLCSONZES tábla
CREATE TABLE kolcsonzes (
    id              NUMBER,
    konyv_id        NUMBER        NOT NULL,
    olvaso_neve     VARCHAR2(150) NOT NULL,
    kivetel_datuma  DATE,
    lejarat_datuma  DATE
)
TABLESPACE users;
```

### Magyarázat
- **Feladatok elválasztása**: A ZH-n az 1. feladat pontozása magukra a táblaszerkezetekre és a megjelölt kötelező (`NOT NULL`) oszlopokra vonatkozik, míg a részletes kényszerek a 2. feladatban kerülnek kifejtésre.
- **Kötelező mezők (`NOT NULL`)**:
  - A `konyv` táblában a leírás szerint a címet kötelező megadni: `cim VARCHAR2(200) NOT NULL`.
  - A `kolcsonzes` táblában a könyv azonosítóját és az olvasó nevét is kötelező kitölteni: `konyv_id NUMBER NOT NULL`, `olvaso_neve VARCHAR2(150) NOT NULL`.
- **Tárolás**: A `TABLESPACE users` megadása megegyezik a tanórákon alkalmazott gyakorlattal ([`class_work/01_dog_manager.sql`](file:///home/ikolym/gits/adatb2/class_work/01_dog_manager.sql#L17)).

---

## 2. Feladat: Megszorítások létrehozása értelmes elnevezéssel (1 pont)

```sql
-- KONYVTAR sémaként futtatandó!

-- Elsődleges kulcsok (Primary Keys)
ALTER TABLE konyv
  ADD CONSTRAINT pk_konyv_id PRIMARY KEY (id);

ALTER TABLE kolcsonzes
  ADD CONSTRAINT pk_kolcsonzes_id PRIMARY KEY (id);

-- Külső kulcs (Foreign Key): A kölcsönzés a könyv azonosítójára hivatkozik
ALTER TABLE kolcsonzes
  ADD CONSTRAINT fk_kolcsonzes_konyv_id FOREIGN KEY (konyv_id) 
    REFERENCES konyv (id);

-- Egyediségi megszorítás (Unique): A könyv címének egyedinek kell lennie
ALTER TABLE konyv
  ADD CONSTRAINT uq_konyv_cim UNIQUE (cim);

-- Értékkészlet / Hossz ellenőrzés (Check): Olvasó neve legalább 10 karakter hosszú
ALTER TABLE kolcsonzes
  ADD CONSTRAINT ck_kolcsonzes_olvaso_neve_len CHECK (LENGTH(olvaso_neve) >= 10);
```

### Magyarázat
- **Értelmes kényszernevek (Naming Convention)**: A feladatlap külön kihangsúlyozza, hogy a megszorítás neve mutassa meg az objektumot (tábla), az oszlopot és a megszorítás típusát:
  - `pk_konyv_id`: **P**rimary **K**ey a `konyv` tábla `id` oszlopán.
  - `pk_kolcsonzes_id`: **P**rimary **K**ey a `kolcsonzes` tábla `id` oszlopán.
  - `fk_kolcsonzes_konyv_id`: **F**oreign **K**ey a `kolcsonzes` tábla `konyv_id` oszlopán, hivatkozva a szülő `konyv` táblára.
  - `uq_konyv_cim`: **U**ni**q**ue megszorítás a `konyv` tábla `cim` mezőjén.
  - `ck_kolcsonzes_olvaso_neve_len`: **C**hec**k** megszorítás a `kolcsonzes` tábla `olvaso_neve` hosszára.
- **Szöveghossz kényszer**: A `LENGTH(olvaso_neve) >= 10` feltétel garantálja, hogy 10 karakternél rövidebb olvasónévvel ne lehessen sort beszúrni.
- **ALTER TABLE stratégia**: A kényszerek utólagos `ALTER TABLE ... ADD CONSTRAINT` formában történő megadása megfelel a kurzus kódolási mintájának ([`class_work/01_dog_manager.sql`](file:///home/ikolym/gits/adatb2/class_work/01_dog_manager.sql#L126-L127)), és külön `.sql` állományként tisztán beadható.

---

## 3. Feladat: Adatfeltöltés egyetlen utasítással (1 pont)

```sql
-- KONYVTAR sémaként futtatandó!

INSERT ALL
    -- Legalább 3 könyv feltöltése (különböző kategóriák és árak):
    INTO konyv (id, cim, kategoria, ar) VALUES (1, 'Alapítvány', 'Sci-fi', 4000)
    INTO konyv (id, cim, kategoria, ar) VALUES (2, 'Dűne', 'Sci-fi', 4500)
    INTO konyv (id, cim, kategoria, ar) VALUES (3, 'A Gyűrűk Ura', 'Fantasy', 6000)
    INTO konyv (id, cim, kategoria, ar) VALUES (4, 'Harry Potter és a Bölcsek Köve', 'Fantasy', 5200)
    INTO konyv (id, cim, kategoria, ar) VALUES (5, 'Tiszta Kód', 'Informatika', 8000)

    -- Legalább 3 kölcsönzés feltöltése:
    -- 1-es könyv ('Alapítvány'): 3 alkalommal kikölcsönözve (teszteli a HAVING < 3 feltételt a 6. feladatban)
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (101, 1, 'Kovács Jánoska', TRUNC(SYSDATE), TRUNC(SYSDATE) + 14)
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (102, 1, 'Tóth László Béla', TRUNC(SYSDATE), TRUNC(SYSDATE) + 21)
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (103, 1, 'Nagy Károly Gábor', TRUNC(SYSDATE), TRUNC(SYSDATE) + 28)

    -- 2-es könyv ('Dűne'): 1 kölcsönzés (címében nincs 'a'; teszi a WHERE szűrőt)
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (104, 2, 'Szabó Éva Katalin', TRUNC(SYSDATE), TRUNC(SYSDATE) + 14)

    -- 3-as könyv ('A Gyűrűk Ura'): 1 kölcsönzés
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (105, 3, 'Varga Péter Tamás', TRUNC(SYSDATE), TRUNC(SYSDATE) + 14)

    -- 5-ös könyv ('Tiszta Kód'): 2 kölcsönzés
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (106, 5, 'Kiss István András', TRUNC(SYSDATE), TRUNC(SYSDATE) + 30)
    INTO kolcsonzes (id, konyv_id, olvaso_neve, kivetel_datuma, lejarat_datuma)
        VALUES (107, 5, 'Fekete Zoltán Béla', TRUNC(SYSDATE), TRUNC(SYSDATE) + 14)

    -- Megjegyzés: A 4-es könyv ('Harry Potter') szándékosan 0-szor szerepel,
    -- hogy a 6. feladatban tesztelhető legyen a 0-s kölcsönzés (LEFT JOIN)!
SELECT * FROM dual;

COMMIT;
```

### Magyarázat
- **Egyetlen beszúró utasítás**: Oracle SQL-ben több tábla egyidejű feltöltése egyetlen utasítással kizárólag az `INSERT ALL INTO ... INTO ... SELECT * FROM dual;` szerkezettel oldható meg érvényesen.
- **Dátumcsapda elkerülése (`TRUNC`)**:
  - A feladat szigorúan előírja: *„óra, perc és másodperc nélkül”*.
  - A sima `SYSDATE` tartalmazza a pontos másodpercet is.
  - A `TRUNC(SYSDATE)` levágja az időkomponenst `00:00:00`-ra.
  - A jövőbeli lejárat tiszta dátuma egyszerű naphozzáadással képződik: `TRUNC(SYSDATE) + 14`.
- **Feladathoz igazított tesztadatok**:
  - Mindkét táblában garantáltan több mint 3 sor található.
  - Minden olvasónév hossza eléri vagy meghaladja a 10 karaktert, így a `ck_kolcsonzes_olvaso_neve_len` kényszer nem dob hibát.
  - Van olyan könyv, amit sosem vittek ki (4-es könyv), van amiben nincs 'a' betű (2-es könyv), és van amit legalább 3-szor kivettek (1-es könyv), így a 4., 5. és 6. feladat szűrői és ablakfüggvényei valós eredményt fognak adni.
- **Tranzakció lezárása**: A `COMMIT;` parancs rögzíti az adatokat a diszken.

---

## 4. Feladat: 20%-os áremelés a már kikölcsönzött könyvekre (2 pont)

```sql
-- KONYVTAR sémaként futtatandó!

UPDATE konyv
SET ar = ar * 1.2
WHERE id IN (
    SELECT konyv_id 
    FROM kolcsonzes 
    WHERE konyv_id IS NOT NULL
);

COMMIT;
```

### Magyarázat
- **Áremelés képlete**: Az `ar = ar * 1.2` a meglévő értéket pontosan 20%-kal növeli meg.
- **Allekérdezés (`IN`)**: A `WHERE id IN (SELECT konyv_id FROM kolcsonzes)` feltétel pontosan azokat a könyveket választja ki, amelyekhez létezik bejegyzés a `kolcsonzes` táblában.
- **Érintetlen rekordok**: Azok a könyvek, amelyeket még soha nem kölcsönöztek ki (pl. 4-es könyv), nem kerülnek be a halmazba, így az áruk változatlan marad.
- **Alternatív megoldás (`EXISTS`)**:
  ```sql
  UPDATE konyv k
  SET k.ar = k.ar * 1.2
  WHERE EXISTS (SELECT 1 FROM kolcsonzes kl WHERE kl.konyv_id = k.id);
  ```
- **Mentés**: A módosításokat a `COMMIT;` utasítás érvényesíti.

---

## 5. Feladat: Könyvek listája, kategória összeg és sorszám ár szerint (2 pont)

```sql
-- KONYVTAR sémaként futtatandó!

SELECT
    cim,
    kategoria,
    ar,
    -- Az adott kategóriába tartozó könyvek árainak összege:
    SUM(ar) OVER (
        PARTITION BY kategoria
    ) AS kategoria_ar_osszeg,
    -- Kategóriánkénti sorszám az ár szerinti csökkenő sorrendben:
    ROW_NUMBER() OVER (
        PARTITION BY kategoria 
        ORDER BY ar DESC
    ) AS sorszam_kategorian_belul
FROM konyv
ORDER BY kategoria ASC, sorszam_kategorian_belul ASC;
```

### Magyarázat
- **Miért analitikus ablakfüggvény (`OVER PARTITION BY`)?**: A feladat kifejezetten kéri az **összes könyv** kilistázását egyedi soraival (`cim`, `kategoria`, `ar`), és *ezek mellé* kéri a csoportosított összeget és sorszámot. A hagyományos `GROUP BY` összevonná a sorokat, ezért kötelező az analitikus `OVER (...)` klauzula használata.
- **`SUM(ar) OVER (PARTITION BY kategoria)`**: Kategóriánként particionálja a sorokat, összegzi az árakat, és minden egyes könyv sora mellett megjeleníti az adott kategória teljes összegét.
- **`ROW_NUMBER() OVER (PARTITION BY kategoria ORDER BY ar DESC)`**: Kategóriánként újrainduló sorszámot képez (1, 2, 3...), a legdrágább könyvtől a legolcsóbbig haladva.
- **Összecsengés az órai anyaggal**: Ugyanez az analitikus ablakozási elv található meg a [`class_work/01_dog_manager.sql`](file:///home/ikolym/gits/adatb2/class_work/01_dog_manager.sql#L185-L186) fájlban (`COUNT(*) OVER(PARTITION BY ...)` és `ROW_NUMBER() OVER(PARTITION BY ... ORDER BY ... DESC)`).

---

## 6. Feladat: Kölcsönzési statisztika és szűrések (3 pont)

```sql
-- KONYVTAR sémaként futtatandó!

SELECT
    k.cim,
    k.kategoria,
    COUNT(kl.id) AS kolcsonzesek_szama
FROM konyv k
LEFT JOIN kolcsonzes kl 
    ON k.id = kl.konyv_id
WHERE UPPER(k.cim) LIKE '%A%'
GROUP BY k.id, k.cim, k.kategoria
HAVING COUNT(kl.id) < 3
ORDER BY kolcsonzesek_szama DESC, k.cim ASC;
```

### Magyarázat
- **Külső illesztés (`LEFT JOIN`)**: Azért szükséges, mert a feladat szerint a soha ki nem kölcsönzött könyveknek is meg kell jelenniük 0 darabszámmal. A sima `INNER JOIN` ezeket kidobná.
- **A `COUNT(kl.id)` vs `COUNT(*)` csapda**:
  - Amikor egy könyvet még nem kölcsönöztek ki, a `LEFT JOIN` jobb oldalán lévő oszlopok `NULL` értékűek lesznek.
  - A `COUNT(*)` magát a sort számolná meg, és tévesen `1`-et adna vissza a 0 helyett!
  - A `COUNT(kl.id)` az oszlop kitöltöttségét vizsgálja: mivel a `NULL` értékeket figyelmen kívül hagyja, pontosan `0`-t ad eredményül.
- **Kis- és nagybetű független szűrés**: Az `UPPER(k.cim) LIKE '%A%'` (vagy `LOWER(k.cim) LIKE '%a%'`) szűrés még a csoportosítás előtt kiszűri azokat a könyveket, amelyek címében nincs 'a' vagy 'A' betű (pl. a *Dűne* kiesik).
- **Csoportosítás (`GROUP BY`)**: Csoportosítunk az elsődleges kulcs (`k.id`), valamint a kiíratott `k.cim` és `k.kategoria` szerint.
- **Csoportszűrés (`HAVING COUNT(kl.id) < 3`)**: Csak azok a csoportok jelennek meg, ahol a kölcsönzések száma szigorúan kisebb mint 3 (a 3-szor kikölcsönzött *Alapítvány* emiatt kiszűrődik).
- **Rendezés**: A leggyakrabban kikölcsönzött könyvektől halad a legritkábbak felé, azonos darabszám esetén cím szerint ábécérendben.

---

### Gyors Ellenőrzőlista a beadáshoz (PL/SQL Developer)

| Feladat | Generált állomány | Futtató felhasználó | Fő SQL eszközök |
| :--- | :--- | :--- | :--- |
| **0. Séma és jogok** | `0.sql` | `SYS as SYSDBA` | PL/SQL blokk, `DROP USER CASCADE`, `CREATE USER`, `GRANT` |
| **1. Táblák** | `1.sql` | `KONYVTAR` | `CREATE TABLE`, `NOT NULL`, `TABLESPACE users` |
| **2. Kényszerek** | `2.sql` | `KONYVTAR` | `ALTER TABLE ADD CONSTRAINT`, `PK`, `FK`, `UQ`, `CHECK (LENGTH >= 10)` |
| **3. Adatfeltöltés** | `3.sql` | `KONYVTAR` | `INSERT ALL INTO ... SELECT * FROM dual;`, `TRUNC(SYSDATE)`, `COMMIT` |
| **4. Áremelés** | `4.sql` | `KONYVTAR` | `UPDATE ... SET ar = ar * 1.2 WHERE id IN (...)`, `COMMIT` |
| **5. Rangsorolás** | `5.sql` | `KONYVTAR` | Analitikus függvények: `SUM() OVER (...)`, `ROW_NUMBER() OVER (...)` |
| **6. Statisztika** | `6.sql` | `KONYVTAR` | `LEFT JOIN`, `COUNT(kl.id)`, `UPPER() LIKE '%A%'`, `HAVING COUNT < 3` |
