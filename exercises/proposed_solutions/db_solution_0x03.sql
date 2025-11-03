-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x03

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
SET SEARCH_PATH = ami_zone;

-- A3.1:
SELECT * FROM hr_employee;

SELECT E.id, E.name, E.salary, E.employee_id, B.name as Boss
FROM hr_employee E JOIN hr_employee B on E.employee_id = B.id
WHERE E.salary>0 ORDER BY E.employee_id;

-- (a)
SELECT V.name, count(M.employee_id), min(M.salary), max(M.salary)
FROM hr_employee M JOIN hr_employee V on M.employee_id = V.id
WHERE M.salary>0
GROUP BY M.employee_id, V.name;

-- (b)
SELECT V.name, count(M.employee_id), min(M.salary), max(M.salary),
       avg(M.salary) as avg
FROM hr_employee M JOIN hr_employee V on M.employee_id = V.id
WHERE M.salary>0
GROUP BY M.employee_id, V.name HAVING avg(M.salary)>50000;

-- A3.2:
SELECT * FROM shop_product;
SELECT * FROM shop_product WHERE name like '%pizza%';

-- (a)
SELECT count(id) as pizza, avg(price) as avg
FROM shop_product WHERE name like '%pizza%';

-- (b)
SELECT * FROM shop_product WHERE category_id IN (1,2);

SELECT C.name, count(P.id)
FROM shop_product P JOIN shop_category C on C.id = P.category_id
WHERE P.category_id IN (1,2) GROUP BY P.category_id, C.name;

-- (c)
SELECT C.name, count(P.id), min(P.price) as min
FROM shop_product P JOIN shop_category C on C.id = P.category_id
GROUP BY P.category_id, C.name HAVING min(P.price)>2;

-- (d)
SELECT * FROM shop_product P
WHERE P.price>=1 and P.price<=2;

SELECT count(P.VAT),P.VAT FROM shop_product P
WHERE P.price>=1 and P.price<=2
GROUP BY P.VAT;

-- A3.3:
SELECT * FROM hr_works_in_at;
SELECT M.name, A.name, L.name FROM hr_employee M
    JOIN hr_works_in_at R on M.id = R.employee_id
JOIN div_department A on A.id = R.department_id
JOIN hr_task L on L.id = R.task_id
ORDER BY M.name,A.id;

SELECT M.name,A.name,count(L.id) FROM hr_employee M
    JOIN hr_works_in_at R on M.id = R.employee_id
    JOIN div_department A on A.id = R.department_id
    JOIN hr_task L on L.id = R.task_id
GROUP BY M.id,A.id;

SELECT M.name,A.name,count(L.id) as rollen FROM hr_employee M
    JOIN hr_works_in_at R on M.id = R.employee_id
    JOIN div_department A on A.id = R.department_id
    JOIN hr_task L on L.id = R.task_id
GROUP BY M.id,A.id HAVING count(L.id)>2;

-- precisely:

SELECT M.id,A.id,count(L.id) as tasks FROM hr_employee M
    JOIN hr_works_in_at R on M.id = R.employee_id
    JOIN div_department A on A.id = R.department_id
    JOIN hr_task L on L.id = R.task_id
GROUP BY M.id,A.id HAVING count(L.id)>1;

SELECT A.name,M.name,Q.tasks FROM (
    SELECT M.id as mid,A.id as aid,count(L.id) as tasks FROM hr_employee M
        JOIN hr_works_in_at R on M.id = R.employee_id
        JOIN div_department A on A.id = R.department_id
        JOIN hr_task L on L.id = R.task_id
    GROUP BY M.id,A.id
) Q
JOIN div_department A on A.id = Q.aid JOIN hr_employee M on M.id=Q.mid
WHERE Q.tasks>1;

