-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x04

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
SET SEARCH_PATH = ami_zone;

-- search Mia or id of Mia -> id=5
SELECT E.id, E.name FROM hr_employee E
WHERE E.name like 'Mia';

-- employees with Mia as their boss (ugly solution)
SELECT E.id, E.name FROM hr_employee E
WHERE E.employee_id = 5;

-- subselect (better)
SELECT E.id, E.name FROM hr_employee E
WHERE E.employee_id = (
    SELECT id FROM hr_employee WHERE name='Mia'
);

-- using 'with' is also a way to organizing queries but technically
-- a Common Table Expressions (CTEs) is not considered a subselect or subquery
with Ids as (SELECT id mia FROM hr_employee WHERE name='Mia')
SELECT E.id, E.name FROM hr_employee E, Ids
WHERE E.employee_id = Ids.mia;

-- subselect
SELECT E.id, E.name FROM hr_employee E
WHERE E.salary > (
    SELECT salary FROM hr_employee WHERE name='Jonas'
);

-- combined
SELECT E.id, E.name FROM hr_employee E
WHERE E.salary > (
    SELECT salary FROM hr_employee WHERE name='Jonas'
) and E.employee_id = (
    SELECT id FROM hr_employee WHERE name='Mia'
);

-- with group-functions
SELECT E.id,E.name,E.salary FROM hr_employee E
WHERE E.salary = (
  SELECT min(salary) FROM hr_employee
  WHERE salary>0
);

with Stats as (
    SELECT min(salary) as min FROM hr_employee
    WHERE salary>0
)
SELECT E.id,E.name,E.salary FROM hr_employee E, Stats
WHERE E.salary = Stats.min;

-- IN
SELECT E.name, E.salary FROM hr_employee E
WHERE E.salary IN (5000,12000,18000);

-- group-functions with IN
SELECT E.name, E.salary FROM hr_employee E
WHERE E.salary IN (
    SELECT min(salary) FROM hr_employee
    GROUP BY employee_id
);

-- ANY

-- all products from category 4 (milk products)
SELECT name, price FROM shop_product WHERE category_id=4;

-- all (non-milk) products less than any milk product
SELECT P.name, P.price, P.category_id
FROM shop_product P WHERE P.price < ANY (
    SELECT price FROM shop_product WHERE category_id=4
) AND P.category_id <> 4;

-- all (non-milk) products less than max milk product
with Stats as (
    SELECT max(price) max FROM shop_product WHERE category_id=4
)
SELECT P.name, P.price, P.category_id
FROM shop_product P, Stats S WHERE P.price < S.max
    AND P.category_id <> 4;

-- ALL
SELECT P.name, P.price, P.category_id
FROM shop_product P WHERE P.price < ALL (
    SELECT price FROM shop_product WHERE category_id=4
) AND P.category_id <> 4;

-- multiple arguments in IN
SELECT P.name, P.unit, P.price, P.category_id FROM shop_product P
WHERE (unit, price) in (
    SELECT unit, price FROM shop_product
    WHERE category_id=1
) and category_id <> 1;

-- Inline Views
SELECT C.*, Q.A FROM shop_category C, (
    SELECT P.category_id, avg(P.price) A
    FROM shop_product P GROUP BY category_id
) Q
WHERE C.id=Q.category_id;

-- correlated subselects
SELECT P.name, P.price, P.category_id
FROM shop_product P WHERE P.price > (
    SELECT avg(price) FROM shop_product
    WHERE category_id=P.category_id
);

-- exists
SELECT E.id, E.name FROM hr_employee E
WHERE EXISTS (
    SELECT id FROM hr_employee
    WHERE hr_employee.employee_id=E.id
);
