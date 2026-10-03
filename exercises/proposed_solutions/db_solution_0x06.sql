-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x06

-- default schema, i.e. unqualified table names refer to ami_sport
SET SEARCH_PATH = ami_sport;


-- tasks with date and time --

-- A6.1 born on a Monday
-- ISODOW: 1 = Monday, ..., 7 = Sunday (DOW would be 0 = Sunday, ..., 6 = Saturday)
SELECT s.*, EXTRACT(ISODOW FROM s.birthday) AS dayofweek, to_char(s.birthday, 'FMDay') AS dayname
FROM athlete s;

SELECT s.name, s.birthday::date AS birthday
FROM athlete s
WHERE EXTRACT(ISODOW FROM s.birthday) = 1;

-- A6.2 younger than 35

SELECT s.*, EXTRACT(YEAR FROM AGE(now(), s.birthday))::numeric AS age_years
FROM athlete s;

SELECT * FROM athlete s
WHERE EXTRACT(YEAR FROM AGE(now(), s.birthday)) < 35;

WITH ages AS (
  SELECT
    s.name,
    FLOOR(EXTRACT(YEAR FROM AGE(now(), s.birthday)))::int AS age
  FROM athlete s
)
SELECT * FROM ages a WHERE a.age < 35;


-- A6.3 highest average age of its competitors
select * from competition;
select * from attends;

SELECT s.id, r.competition_id, s.name,
       EXTRACT(YEAR FROM AGE(now(), s.birthday))::numeric AS age_years
FROM attends r
JOIN athlete s ON r.athlete_id = s.id;

SELECT r.competition_id,
       COUNT(*) AS n_competitors,
       AVG(EXTRACT(YEAR FROM AGE(now(), s.birthday))::numeric) AS avg_age_years
FROM attends r
JOIN athlete s ON r.athlete_id = s.id
GROUP BY r.competition_id;

-- competition with max average age
SELECT x.wk, x.x AS max_avg
FROM (
  SELECT r.competition_id AS wk,
         COUNT(*) AS n_competitors,
         AVG(EXTRACT(YEAR FROM AGE(now(), s.birthday))::numeric) AS x
  FROM attends r
  JOIN athlete s ON r.athlete_id = s.id
  GROUP BY r.competition_id
) x
ORDER BY x.x DESC
LIMIT 1;

-- description + max average
SELECT c.description, x.x AS max_avg
FROM (
  SELECT r.competition_id AS wk,
         COUNT(*) AS n_competitors,
         AVG(EXTRACT(YEAR FROM AGE(now(), s.birthday))::numeric) AS x
  FROM attends r
  JOIN athlete s ON r.athlete_id = s.id
  GROUP BY r.competition_id
) x
JOIN competition c ON x.wk = c.id
ORDER BY x.x DESC
LIMIT 1;

-- tasks with views --

SET SEARCH_PATH = ami_zone;

-- A6.4

-- overview
SELECT * FROM shop_product P;
SELECT * FROM shop_category W;

-- category 1
SELECT P.name,P.price FROM shop_product P WHERE P.category_id = 1;

-- category Frozen Goods
SELECT P.name,P.price FROM shop_product P WHERE P.category_id =
(SELECT id FROM shop_category WHERE name like 'Frozen%');

-- using with
WITH fg_id as (SELECT id FROM shop_category WHERE name like 'Frozen%')
SELECT P.name,P.price FROM shop_product P join fg_id on P.category_id = fg_id.id;

-- create view
CREATE OR REPLACE VIEW only_fg AS (
SELECT P.name,P.price FROM shop_product P WHERE P.category_id =
(SELECT id FROM shop_category WHERE name like 'Frozen%')
);

-- use and delete
SELECT * FROM only_fg;
DROP VIEW only_fg;


-- A6.5

-- overview
SELECT * FROM shop_order O;
SELECT * FROM shop_consists_of B;
SELECT * FROM shop_product P;
SELECT * FROM shop_customer;

-- sum up
SELECT B.order_id, sum(P.price*B.units) summe
        FROM shop_consists_of B INNER JOIN shop_product P ON B.product_id=P.id
GROUP BY order_id;

-- with names
SELECT o.id, o.delivery_time::date AS vom, k.brand, q.total
FROM shop_order o
JOIN (
  SELECT b.order_id, SUM(p.price * b.units) AS total
  FROM shop_consists_of b
  JOIN shop_product p ON b.product_id = p.id
  GROUP BY b.order_id
) q ON o.id = q.order_id
JOIN shop_customer k ON o.customer_id = k.id;

CREATE OR REPLACE VIEW all_orders AS
SELECT o.id, o.delivery_time::date AS vom, k.brand, q.total
FROM shop_order o
JOIN (
  SELECT
    b.order_id,
    SUM(p.price * b.units) AS total
  FROM shop_consists_of b
  JOIN shop_product p ON b.product_id = p.id
  GROUP BY b.order_id
) q ON o.id = q.order_id
JOIN shop_customer k ON o.customer_id = k.id;

-- use and delete
select * from all_orders;
DROP VIEW all_orders;

-- nested, compare original view 'all_orders'

-- inner view
CREATE OR REPLACE VIEW core_orders AS (
    SELECT B.order_id, sum(P.price*B.units) summe
        FROM shop_consists_of B INNER JOIN shop_product P ON B.product_id=P.id GROUP BY order_id
);
SELECT * FROM core_orders;

-- outer view
CREATE OR REPLACE VIEW all_orders2 AS
SELECT o.id, o.delivery_time::date AS vom, k.brand, q.summe
FROM shop_order o
JOIN core_orders q ON o.id = q.order_id
JOIN shop_customer k ON o.customer_id = k.id;

-- use it
-- select * from all_orders;
select * from all_orders2;

-- delete all
-- DROP VIEW all_orders;
DROP VIEW all_orders2;
DROP VIEW core_orders;

--

SET SEARCH_PATH = ami_sport;


select * from team;

START TRANSACTION;
INSERT INTO team (id,name) VALUES (24680,'Team GER');
select * from team;
ROLLBACK;  -- or COMMIT
select * from team;

