-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- SQL-Solutions Unit 0x04

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;

-- A4.1:
SELECT * FROM shop_product WHERE name like 'Chips';
SELECT * FROM shop_product P WHERE P.price=1.99;
-- same as 'Chips' for 1.99
SELECT P.name,P.price FROM shop_product P WHERE P.price = (
    SELECT price FROM shop_product WHERE name like 'Chips'
) and P.name<>'Chips';

-- A4.2
SELECT count(*) FROM shop_product WHERE category_id=2;
SELECT P.category_id,C.name,count(*)
    FROM shop_product P join shop_category C on P.category_id = C.id
    GROUP BY P.category_id;
-- same number of products as in category 2
SELECT P.category_id, C.name,count(*) as 'count'
    FROM shop_product P join shop_category C on P.category_id = C.id
GROUP BY P.category_id, C.name
HAVING count(*) = (
    SELECT count(*) FROM shop_product WHERE category_id = 2
);

-- A4.3
SELECT * FROM shop_product;
-- same price within a product group
SELECT P.category_id,P.name,P.price FROM shop_product P
WHERE EXISTS(
    SELECT 'X' FROM shop_product
    WHERE price=P.price and category_id=P.category_id and id<>P.id
) ORDER BY P.category_id, P.price;

-- A4.4
SELECT * FROM hr_employee;
SELECT * FROM hr_works_in_at;
SELECT * FROM div_department WHERE name like 'Finance';
SELECT * FROM hr_task WHERE name like '% XCoin';
-- who works on something like XCoin in finance
SELECT E.* FROM hr_works_in_at W JOIN hr_employee E on W.employee_id = E.id
WHERE W.department_id = (
    SELECT id FROM div_department WHERE name like 'Finance'
) and W.task_id = (
    SELECT id FROM hr_task WHERE name like '% XCoin'
);

-- A4.5
SELECT * FROM hr_works_in_at;
SELECT avg(hours_per_week) FROM hr_works_in_at group by employee_id;
-- average of 20 hours across departments
SELECT R.employee_id,E.name,E.salary,avg(R.hours_per_week) as 'avg'
FROM hr_works_in_at R JOIN hr_employee E on R.employee_id = E.id
        GROUP BY R.employee_id HAVING avg(R.hours_per_week)=20;

# A4.6
SELECT * FROM shop_order B;
-- employees have already placed an order
SELECT M.name,B.id 'for order' FROM shop_order B
    JOIN hr_employee M on B.employee_id = M.id;

-- A4.7
SELECT * FROM shop_consists_of B;
-- products not yet been ordered
SELECT * FROM shop_product P WHERE NOT EXISTS(
    SELECT 'X' FROM shop_consists_of R WHERE R.product_id=P.id
);
-- or, not correlated
select * from shop_product P
where P.id not in (select product_id from shop_consists_of);

-- A4.8
SELECT B.id 'order',B.customer_id,C.brand,Q.sum FROM shop_order B JOIN (
    SELECT R.order_id,sum(R.units*P.price) as 'sum'
    FROM shop_consists_of R JOIN shop_product P on P.id = R.product_id
    GROUP BY R.order_id
) Q on B.id=Q.order_id JOIN shop_customer C on B.customer_id = C.id;
