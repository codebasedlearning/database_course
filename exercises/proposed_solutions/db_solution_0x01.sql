-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- SQL-Solutions Unit 0x01

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;

-- A1.1:
select * from div_department;
select * from shop_customer;
select * from hr_employee;
select * from shop_product;
select * from hr_team;
select * from shop_category;

-- A1.2
select distinct vat from shop_product;
select count(distinct vat) from shop_product;

-- A1.3
select brand, discount_percent from shop_customer
    where brand like '%bank%' or brand like '%Bank%' or brand like '%Sparkasse%';

-- A1.4
select * from hr_employee
    where name='Mia' or name='Ben';
-- -> id=5 or id=6
select name, round(hr_employee.salary/12.0,0) AS "Monthly salary" from hr_employee
    where employee_id in (5,6);

-- A1.5
select * from hr_employee
    where name like 'M%';
select count(*) from hr_employee
    where name like 'M%';
select * from hr_employee
    where name like '%m%';
select count(*) from hr_employee
    where name like '%m%';
