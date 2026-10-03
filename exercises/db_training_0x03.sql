-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x03

-- default schema, i.e. unqualified table names refer to ami_zone
SET SEARCH_PATH = ami_zone;

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

-- Every column in SELECT must either be in GROUP BY or be inside a group function,
-- otherwise: which of the 5 names of category 1 should be shown?
-- PostgreSQL rejects this; MySQL/MariaDB (without ONLY_FULL_GROUP_BY) silently
-- return an arbitrary row per group, which is worse.
-- expect-error: name, price, unit are neither grouped nor aggregated
SELECT name, category_id, price, unit FROM shop_product
GROUP BY category_id;

-- Use Group Functions with alias.
-- An alias (here S) may be used in ORDER BY, but not in WHERE, GROUP BY or HAVING,
-- because these clauses are evaluated before SELECT; repeat the expression instead.
SELECT count(price),category_id,min(price) S FROM shop_product
WHERE category_id IN (1,2,4)
GROUP BY category_id HAVING 3*min(price)>1
ORDER BY S;

-- Use group by with multiple attributes.
SELECT count(*) FROM shop_product WHERE unit='KG' AND VAT=0.07;  --  4
SELECT count(*) FROM shop_product WHERE unit='PK' AND VAT=0.07;  -- 14
SELECT count(*) FROM shop_product WHERE unit='PC' AND VAT=0.07;  -- 16

SELECT count(id) FROM shop_product WHERE unit='PC' AND VAT=0.19; --  6

SELECT count(VAT),VAT,count(unit),unit,min(price),max(price)
FROM shop_product GROUP BY VAT, unit ORDER BY VAT;

-- Use Group Functions with Joins.
-- Note: LIKE is case-sensitive in PostgreSQL ('%drinks' finds nothing, the
-- categories are 'Cold Drinks' and 'Hot Drinks'); ILIKE ignores the case.
SELECT P.category_id, P.price, C.name FROM shop_product P
INNER JOIN shop_category C ON P.category_id= C.id
WHERE C.name LIKE '%drinks';

SELECT P.category_id, P.price, C.name FROM shop_product P
INNER JOIN shop_category C ON P.category_id= C.id
WHERE C.name ILIKE '%drinks';

-- C.name must be grouped as well (P.category_id alone is not enough for PostgreSQL)
SELECT count(P.price),P.category_id,avg(P.price),C.name FROM shop_product P
INNER JOIN shop_category C ON P.category_id=C.id
WHERE C.name ILIKE '%drinks' GROUP BY P.category_id, C.name;
