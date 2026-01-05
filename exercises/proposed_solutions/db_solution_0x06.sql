-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x06

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
SET SEARCH_PATH = ami_sport;


-- tasks with date and time --

-- use ami_sport;

-- A6.1 born on a Monday
-- MySQL: 1 = Sunday, 2 = Monday, …, 7 = Saturday
-- SELECT S.*,dayofweek(S.birthday) FROM athlete S;
-- Postgres 0-based
SELECT s.*, (EXTRACT(DOW FROM s.birthday) + 1) AS dayofweek
FROM athlete s;

--SELECT S.name,date(S.birthday) birthday FROM athlete S where dayofweek(S.birthday)=2;
SELECT s.name, s.birthday::date AS birthday
FROM athlete s
WHERE (EXTRACT(DOW FROM s.birthday) + 1) = 2;

-- A6.2 younger than 35

-- SELECT S.*, datediff(now(), S.birthday)/365.0 FROM athlete S;
-- SELECT * FROM athlete S where datediff(now(), S.birthday)/365.0<35 ;
-- WITH ages as (SELECT S.name, floor(datediff(now(), S.birthday)/365.0) as age from athlete S )
-- select * from ages A where age<35;

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

/*
select S.id,R.competition_id, S.name,(datediff(now(), S.birthday)/365)
from attends R join athlete s on R.athlete_id=S.id;

select R.competition_id,count(*),avg(datediff(now(), S.birthday)/365)
from attends R join athlete s
on R.athlete_id=S.id
group by R.competition_id;

select X.wk,X.x max from (
select R.competition_id wk,count(*),avg(datediff(now(), S.birthday)/365) x
from attends R join athlete s
on R.athlete_id=S.id
group by wk
) X
order by X.x desc limit 1;

select C.description, X.x max_avg from (
select R.competition_id wk,count(*),avg(datediff(now(), S.birthday)/365) x
from attends R join athlete s
on R.athlete_id=S.id
group by wk
) X
join competition C on x.wk=C.id
order by X.x desc limit 1;
*/
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

-- use ami_zone;
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

-- create viw
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
/*
SELECT O.id, date(O.delivery_time) vom, K.brand, Q.sum FROM shop_order O INNER JOIN (
    SELECT B.order_id, sum(P.price*B.units) sum
        FROM shop_consists_of B INNER JOIN shop_product P ON B.product_id=P.id GROUP BY order_id
) Q ON O.id=Q.order_id INNER JOIN shop_customer K on O.customer_id=K.id;

-- create view; maybe this leads to an error, see below
CREATE OR REPLACE VIEW all_orders AS (
SELECT O.id, date(O.delivery_time) vom, K.brand, Q.sum FROM shop_order O INNER JOIN (
    SELECT B.order_id, sum(P.price*B.units) sum
        FROM shop_consists_of B INNER JOIN shop_product P ON B.product_id=P.id GROUP BY order_id
) Q ON O.id=Q.order_id INNER JOIN shop_customer K on O.customer_id=K.id
);
*/
SELECT o.id, o.delivery_time AS vom, k.brand, q.total
FROM shop_order o
JOIN (
  SELECT b.order_id, SUM(p.price * b.units) AS total
  FROM shop_consists_of b
  JOIN shop_product p ON b.product_id = p.id
  GROUP BY b.order_id
) q ON o.id = q.order_id
JOIN shop_customer k ON o.customer_id = k.id;

CREATE OR REPLACE VIEW all_orders AS
SELECT o.id, o.delivery_time AS vom, k.brand, q.total
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
/*
CREATE OR REPLACE VIEW all_orders2 AS (
SELECT O.id, date(O.delivery_time) vom, K.brand, Q.summe FROM shop_order O
    INNER JOIN core_orders Q ON O.id = Q.order_id INNER JOIN shop_customer K on O.customer_id = K.id
);
*/
CREATE OR REPLACE VIEW all_orders2 AS
SELECT o.id, (CURRENT_DATE + o.delivery_time) AS vom, k.brand, q.summe
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

-- use ami_sport;
SET SEARCH_PATH = ami_sport;


select * from team;

START TRANSACTION;
INSERT INTO team (id,name) VALUES (24680,'Team GER');
select * from team;
ROLLBACK;  -- or COMMIT
select * from team;

