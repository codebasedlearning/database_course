-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- SQL-Solutions Unit 0x02

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;

-- A2.1:
SELECT * FROM shop_order;
SELECT * FROM shop_customer;
SELECT * FROM hr_employee;

-- a)
SELECT O.delivery_time "Delivery", C.brand "Customer"
    FROM shop_order O,shop_customer C
    WHERE O.customer_id = C.id;
-- b)
SELECT O.delivery_time "Delivery", C.brand "Customer"
    FROM shop_order O
    INNER JOIN shop_customer C on O.customer_id = C.id;
-- c)
SELECT O.delivery_time "Delivery", C.brand "Customer", E.name "Agent"
    FROM shop_order O
    INNER JOIN shop_customer C on O.customer_id = C.id
    INNER JOIN hr_employee E on O.employee_id = E.id;

-- A2.2:
SELECT * FROM div_department;
SELECT * FROM div_location;
SELECT * FROM div_located_in;
-- a)
SELECT D.name, S.place
    FROM div_department D
    JOIN div_located_in LI on D.id = LI.department_id
    JOIN div_location S on LI.location_id = S.id;
-- b)
SELECT D.name, L.place
    FROM div_department D
    LEFT OUTER JOIN div_located_in LI on D.id = LI.department_id
    LEFT OUTER JOIN div_location L on LI.location_id = L.id;
-- c)
SELECT D.name, L.place
    FROM div_location L
    RIGHT OUTER JOIN div_located_in LI on LI.location_id = L.id
    RIGHT OUTER JOIN div_department D on D.id = LI.department_id;
-- d)
SELECT D.name, L.place
    FROM div_department D
    LEFT OUTER JOIN div_located_in LI on D.id = LI.department_id
    LEFT OUTER JOIN div_location L on LI.location_id = L.id
    WHERE L.place is null;
--    WHERE isnull(L.place);

-- A2.3:
SELECT * FROM hr_employee;
SELECT * FROM hr_works_in_at;
-- a)
SELECT E1.name, E2.name "Manager"
    FROM hr_employee E1
    JOIN hr_employee E2 on E1.employee_id = E2.id
    WHERE E2.name like 'Mia';
-- b)
SELECT E1.name, D.name, T.name, W.hours_per_week, E2.name "Manager"
    FROM hr_employee E1
    JOIN hr_works_in_at W on E1.id = W.employee_id
    JOIN div_department D on D.id = W.department_id
    JOIN hr_task T on W.task_id = T.id
    JOIN hr_employee E2 on E1.employee_id = E2.id;

-- A2.4:
SELECT * FROM shop_customer;
SELECT * FROM shop_connected_to;
-- a)
SELECT C1.brand, C2.brand
    FROM shop_customer C1
             JOIN shop_connected_to CT on C1.id = CT.customer_a_id
             JOIN shop_customer C2 on C2.id = CT.customer_b_id
WHERE C1.brand like '%bank%' or C1.brand like '%kasse%';
-- b)
SELECT C.brand
    FROM shop_customer C
    LEFT OUTER JOIN shop_connected_to CT on C.id = CT.customer_a_id
    WHERE CT.customer_b_id is null;
--    WHERE isnull(CT.customer_b_id);
