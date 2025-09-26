-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- SQL-Commands Unit 0x03

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;

-- Use Group Functions
SELECT P.name,P.price FROM shop_product P;
SELECT min(price), max(price), sum(price), count(price),
       sum(price)/count(price), avg(price), stddev_pop(price),
       sqrt(var_pop(price)) FROM shop_product;

-- Use Group Functions on selections.
SELECT * FROM shop_product WHERE category_id=1;

SELECT count(*), avg(price) FROM shop_product WHERE category_id=1;
SELECT count(price), avg(price) FROM shop_product WHERE category_id=1;
SELECT count(distinct price), avg(distinct price) FROM shop_product WHERE category_id=1;

-- Use Group Functions on grouped data.
SELECT count(price),category_id,min(price),max(price),avg(price) FROM shop_product
GROUP BY category_id;

-- Use Group Functions on grouped data of a selection.
SELECT count(price),category_id,min(price),max(price),avg(price) FROM shop_product
WHERE category_id IN (1,2,4) GROUP BY category_id;

-- Use Group Functions on grouped data with condition.
SELECT count(price),category_id,min(price),max(price),avg(price) FROM shop_product
WHERE category_id IN (1,2,4) GROUP BY category_id HAVING min(price)>1;

-- Use Group Functions correctly.
SELECT name, category_id, price, unit FROM shop_product;

SELECT name, category_id, price, unit FROM shop_product
GROUP BY category_id;

-- Use Group Functions with alias.
SELECT count(price),category_id,min(price) S FROM shop_product
WHERE category_id IN (1,2,4)
GROUP BY category_id HAVING 3*S>1
ORDER BY S;

-- Use group by with multiple attributes.
SELECT count(*) FROM shop_product WHERE unit='KG' AND VAT=0.07;  --  4
SELECT count(*) FROM shop_product WHERE unit='PK' AND VAT=0.07;  -- 14
SELECT count(*) FROM shop_product WHERE unit='PC' AND VAT=0.07;  -- 16

SELECT count(id) FROM shop_product WHERE unit='PC' AND VAT=0.19; --  6

SELECT count(VAT),VAT,count(unit),unit,min(price),max(price)
FROM shop_product GROUP BY VAT, unit ORDER BY VAT;

-- Use Group Functions with Joins.
SELECT P.category_id, P.price, C.name FROM shop_product P
INNER JOIN shop_category C ON P.category_id= C.id
WHERE C.name LIKE '%drinks';

SELECT count(P.price),P.category_id,avg(P.price),C.name FROM shop_product P
INNER JOIN shop_category C ON P.category_id=C.id
WHERE C.name LIKE '%drinks' GROUP BY category_id;
