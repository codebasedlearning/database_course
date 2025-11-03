-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- use ami_algebra;

-- diese Relationen R und S sind auf das Wesentliche reduziert;
-- die Entitäten bestehen aus künstlichen Attributen der
-- Form [a1,b1,c1];

-- postgres
SET SEARCH_PATH = ami_algebra;

-- Besonderheiten R: ein Null-Eintrag in C der Entität Rid=4
SELECT * from R;
-- Rid  A  B  C
--   1 a1 b1 c1
--   2 a2 b2 c2
--   3 a3 b3 c3
--   4 a4 b4 <null>

-- Besonderheiten S: Spalte FB Fremdschlüssel zu R.B
SELECT * from S;
-- Sid  C  D  E FB
--  11 c1 d1 e1 b1
--  13 c3 d3 e3 b3
--  14 c4 d4 e4 b4


-- Operationen der relationalen Algebra und die SQL-Entsprechung --


-- Selektion, d.h. Auswahl einzelner Zeilen mit WHERE
-- (hier alle Enttäten/Zeilen mit Rid<=2)
SELECT * FROM R WHERE Rid<=2;

-- Projektion, d.h. Auswahl einzelner Attribute in SELECT
-- (hier der Spalten A und C)
SELECT A,C FROM R;

-- Cross-Join, Kreuzprodukt, kartesisches Produkt, d.h. alle
-- Entitäten aus R mit allen aus S;
-- man beachte die Struktur des Ergebnisses, alle Spalten vorhanden
SELECT * FROM R,S;

-- Inner Join mit Bedingung bzw. Equi-Join auf Attribut
-- (hier sollen C-Attribute gleich sein)
SELECT * FROM R,S WHERE R.C=S.C;

-- wie oben auch Inner Join über join-Befehl
-- Bevorzugte Variante!
SELECT * FROM R JOIN S ON R.C = S.C;

-- und noch ein Inner Join, hier ist Verwandschaft zu
-- Equi-Join und Natural Join erkennbar, eine Spalte weniger
SELECT * FROM R JOIN S USING (C);

-- Natural Join, ebenfalls ohne doppelte Spalte
-- vergleiche mit Variante
SELECT * FROM R NATURAL JOIN S;

-- Inner Join mit Bedingung auf Fremdschlüssel FB
-- (hier soll B-Attribute mit FB-Attribut gleich sein)
SELECT * FROM R,S WHERE R.B=S.FB;

-- wie zuvor Inner Join über join-Befehl
-- Bevorzugte Variante!
SELECT * FROM R JOIN S ON R.B = S.FB;

-- Semi Join, d.h. Natural Join aber nur
-- mit Attributen aus R
SELECT R.* FROM R NATURAL JOIN S;

-- Anti-Semi-Join, d.h. alle Entitäten, die
-- nicht im Join vorkommen, und davon nur die
-- Attribute aus R
SELECT R.* FROM R LEFT OUTER JOIN S ON R.C = S.C
WHERE S.C is null;

-- Left Outer Join, d.h. alle Entitäten aus R und
-- ggf. mit Attributen aus S, wenn assoziierte Entität
-- vorhanden, sonst null
SELECT * FROM R LEFT OUTER JOIN S ON R.C = S.C;

-- Right Outer Join, d.h. wie Left Outer Join, nur
-- diesmal sind alle Entitäten aus S dabei
SELECT * FROM R RIGHT OUTER JOIN S ON R.C = S.C;

-- Full Outer Join, d.h. alle Entitäten aus R
-- und alle aus S, jeweils mit Partner oder null
SELECT * FROM R LEFT OUTER JOIN S ON R.C = S.C
UNION
SELECT * FROM R RIGHT OUTER JOIN S ON R.C = S.C;

-- with-Beispiel, d.h. zuerst wird temp. Relation RR
-- bestimmt und unter diesem Namen mit den umbenannten
-- Attributen kann dann weitergearbeitet werden, z.B.
-- im SELECT
WITH
     RR as (select Rid as 'id', A as 'AA' from R where Rid<4)
SELECT * from RR;

-- Minus: zuerst Teilmenge A1 mit Rid<4 (also 1,2,3) und
-- Teilmenge A2 mit Rid>1 (also 2,3,4) bilden, und dann
-- ergibt der outer join mit dem Schlüssel Rid immer dann
-- ein null-Element in A2, wenn die Entität in A1 aber
-- nicht in A2 ist -> das ist genau das Minus (übrig Rid=1)
WITH
     A1 as (select * from R where Rid<4),
     A2 as (select * from R where Rid>1)
SELECT A1.* FROM A1 LEFT OUTER JOIN A2 USING (Rid)
WHERE A2.Rid is null;

-- Durchschnitt/Intersect: gleiche Teilmengen A1 und A2
-- wie zuvor, dann ergibt der inner join genau die Elemente,
-- die in beiden Mengen sind -> Durchschnitt
WITH
     A1 as (select * from R where Rid<4),
     A2 as (select * from R where Rid>1)
SELECT A1.* FROM A1 JOIN A2 USING (Rid);

-- Vereinigung/Union: der SQL-Befehl union vereinigt die beiden
-- Teilmengen A1 (hier Rid 1) und A2 (hier Rid 1 und 4), aber
-- doppelte fehlen
WITH
     A1 as (select * from R where Rid=1),
     A2 as (select * from R where Rid=4 or Rid=1)
SELECT * FROM A1
UNION
SELECT * FROM A2;

-- Vereinigung/Union: der SQL-Befehl union all vereinigt
-- wie zuvor, aber doppelte Elemente bleiben (Rid 1)
WITH
     A1 as (select * from R where Rid=1),
     A2 as (select * from R where Rid=4 or Rid=1)
SELECT * FROM A1
UNION ALL
SELECT * FROM A2;

-- count: In der C-Spalte existiert ein null-Element, deswegen
-- ergibt count(*)=4 aber count(C) nur 3
SELECT count(*),count(C) FROM R;

-- sum: summiert über die String-Längen von B... soll nur sum
-- demonstriere
SELECT sum(length(B)) FROM R;

-- group-Vorbereitung: der substr. ergibt die Nummer 1-4
SELECT *,substr(A,2) as no FROM R;

-- group: es wird nach Rest div 2 gruppiert und die Summe über
-- diese No gebildet (1+3 und 2+4)
WITH
     A1 as (SELECT substr(A,2)::int as no FROM R)
SELECT sum(no) FROM A1
GROUP BY no%2=1;

-- group+having: Gruppierung wie oben, aber mit Bedingung an
-- das Ergebnis der Gruppierung unter einem Alias (S)
WITH
     A1 as (SELECT substr(A,2)::int as no FROM R)
SELECT sum(no) as S FROM A1
GROUP BY no%2=1 HAVING sum(no)>4;
