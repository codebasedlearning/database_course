-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x02

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
SET SEARCH_PATH = ami_zone;

-- all data
SELECT P.id,P.name,P.category_id
    FROM shop_product P;

SELECT C.id,C.name
    FROM shop_category C;

-- goal
SELECT P.id,P.name,C.name FROM shop_product P
    JOIN shop_category C on C.id = P.category_id;

-- motivation: cross
SELECT P.id,P.name,P.category_id,C.id,C.name
    FROM shop_product P, shop_category C;

-- motivation: explicit join
SELECT P.id,P.name,P.category_id,C.id,C.name
    FROM shop_product P, shop_category C
    WHERE P.category_id=C.id;

-- motivation: only the desired attributes
SELECT P.id,P.name,C.name
    FROM shop_product P, shop_category C
    WHERE P.category_id=C.id;

-- motivation: join by command
SELECT P.id,P.name,C.name
    FROM shop_product P
    JOIN shop_category C ON P.category_id=C.id;

-- cross join implicitly and explicitly
SELECT P.id, P.name, P.category_id, C.id, C.name
    FROM shop_product P,shop_category C;

SELECT P.id, P.name, P.category_id, C.id, C.name
    FROM shop_product P CROSS JOIN shop_category C;

-- inner join (old, but this is the formal definition)
SELECT P.id, P.name, P.category_id, C.id, C.name
    FROM shop_product P,shop_category C
    WHERE P.category_id=C.id;
-- inner join, use this
SELECT P.id, P.name, P.category_id, C.id, C.name
    FROM shop_product P INNER JOIN shop_category C
    ON P.category_id=C.id;

-- example 1, inner join
SELECT O.id, O.customer_id, C.id, C.brand
    FROM shop_order O
    INNER JOIN shop_customer C ON O.customer_id=C.id;

-- example 2, self-join
SELECT E.id,E.name,E.employee_id,EE.id,EE.name "Boss"
    FROM hr_employee E
    INNER JOIN hr_employee EE on E.employee_id=EE.id;

-- example 3, multiple inner joins
SELECT D.id,D.name FROM div_department D;
SELECT L.id,L.place FROM div_location L;
SELECT LI.department_id, LI.location_id
    FROM div_located_in LI;

SELECT LI.department_id, D.name, LI.location_id, L.place
    FROM div_located_in LI
    JOIN div_department D ON LI.department_id=D.id
    JOIN div_location L ON LI.location_id=L.id;

-- example 4
SELECT W.* FROM hr_works_in_at W;

SELECT E.name,D.name,T.name,W.hours_per_week
    FROM hr_works_in_at W
    JOIN hr_employee E on E.id = W.employee_id
    JOIN div_department D on D.id = W.department_id
    JOIN hr_task T on T.id = W.task_id;

-- example 5
SELECT C.* FROM hr_cat C;
SELECT C.id,C.name, E.id, E.name
    FROM hr_cat C JOIN hr_employee E
    ON E.id = C.employee_id;

-- outer join (left) vs inner join
SELECT C.id,C.name, E.id, E.name
    FROM hr_cat C LEFT OUTER JOIN hr_employee E
    ON E.id = C.employee_id;

SELECT C.id,C.name, E.id, E.name
    FROM hr_cat C RIGHT OUTER JOIN hr_employee E
    ON E.id = C.employee_id;

-- outer join (full)
SELECT C.id,C.name, E.id, E.name
    FROM hr_cat C LEFT OUTER JOIN hr_employee E
    ON E.id = C.employee_id
union
SELECT C.id,C.name, E.id, E.name
    FROM hr_cat C RIGHT OUTER JOIN hr_employee E
    ON E.id = C.employee_id;

-- exchange sides and type, left and right in join
SELECT C.id,C.name, E.id, E.name
    FROM hr_cat C LEFT OUTER JOIN hr_employee E
    ON E.id = C.employee_id;

SELECT C.id,C.name, E.id, E.name
    FROM hr_employee E RIGHT OUTER JOIN hr_cat C
    ON E.id = C.employee_id;


-- more examples

SELECT O.id, O.customer_id, C.id, C.brand
    FROM shop_order O INNER JOIN shop_customer C
    ON O.customer_id= C.id;

SELECT O.id, O.customer_id, C.id, C.brand
    FROM shop_order O RIGHT OUTER JOIN shop_customer C
    ON O.customer_id=C.id;

/*
-- switch to ami_kemper
use ami_kemper;
-- SET SEARCH_PATH = ami_kemper;

-- natural join
SELECT R.* FROM hoeren R;
SELECT S.* FROM studenten S;
SELECT V.* FROM Vorlesungen V;

SELECT S.Name,V.Titel
    FROM Studenten S
    NATURAL JOIN hoeren R
    NATURAL JOIN Vorlesungen V;

SELECT S.Name,V.Titel
    FROM Studenten S
    JOIN hoeren R ON S.MatrNr = R.MatrNr
    JOIN Vorlesungen V ON R.VorlNr = V.VorlNr;
*/
