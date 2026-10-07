-- (C) A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x01

-- all data
SELECT * FROM ami_zone.shop_product;

-- default schema, i.e. unqualified table names refer to ami_zone
SET SEARCH_PATH = ami_zone;

-- projection example
SELECT name, price FROM shop_product;

-- selection example
SELECT * FROM shop_product WHERE price>2;

-- all columns and all rows with SEARCH_PATH in effect
SELECT * FROM shop_product;

-- tables with alias
SELECT P.* FROM shop_product P;

-- attributes with alias
SELECT P.name, P.price FROM shop_product P WHERE price>2;

-- note column names (aliases): unquoted names are folded to lower case
-- (Product -> product),
-- double quotes keep case and allow blanks; single quotes are string literals,
-- not names
SELECT id as "IDX",
  name Product,
  price "Price [€]"
FROM shop_product;

-- calculated values
SELECT
    id "ID ",
    concat(name,' [',unit,']') "Product",
    price "Price [€]",
    round(price/(1.0+vat),2) "excl. VAT",
    round(price/(1.0+vat)*vat,2) "VAT "
FROM shop_product;

-- select * from shop_customer;

-- calculated values involving NULL
SELECT
    brand,
    risk_of_loss_percent,
    risk_of_loss_percent is NULL "NULL?",
   coalesce(100-risk_of_loss_percent,100.00) "Fulfilment"
FROM shop_customer;

-- distinct values
SELECT category_id, name FROM shop_product;
SELECT distinct category_id FROM shop_product;

select * from shop_customer;

-- count number of lines, with or without NULLs
select count(*) from shop_customer;
select count(discount_percent) from shop_customer;
select count(distinct discount_percent) from shop_customer;
select count(risk_of_loss_percent) from shop_customer;

-- select * from shop_product;

-- selection with WHERE
SELECT name, price FROM shop_product
    WHERE price=1.99;

-- string comparison with like including wildcards % and _
SELECT name, price FROM shop_product
    WHERE name like '%Pizza';
SELECT name, price FROM shop_product
    WHERE name like '%Pizza' and
    not name like '%Spinach%';

-- between and in
SELECT name, price FROM shop_product
    WHERE price between 1.00 and 2.00;
SELECT name, price FROM shop_product
    WHERE price in (0.99, 1.99, 2.99);

-- case
SELECT name, price,
       case
            when price <= 2.00 then 'cheap'
            when price <= 5.00 then 'ok'
            else 'expensive'
       end as affordable
    FROM shop_product
    WHERE price between 1.00 and 10.00;

-- different clauses
SELECT name, price FROM shop_product
    WHERE (price<1.00 or price>5.00)
        and category_id=11;
SELECT brand, risk_of_loss_percent FROM shop_customer
    WHERE risk_of_loss_percent is not null;

-- order by, asc, desc
SELECT name, price FROM shop_product
    WHERE category_id in (1,3,4) ORDER BY price; -- asc
SELECT name, price FROM shop_product
    WHERE category_id in (1,3,4) ORDER BY price, name desc;

-- interactive usage, a SELECT does not need a FROM clause in PostgreSQL
-- (Oracle needs 'FROM dual' here, PostgreSQL does not know DUAL)
select now(), 1+2*3, random();


-- tables in ami_zone

-- Divisions (div_)
select * from div_department;
select * from div_location;
select * from div_located_in;
select * from div_room;
-- HR (hr_)
select * from hr_employee;
select * from hr_team;
select * from hr_task;
select * from hr_works_in_at;
select * from hr_part_of;
select * from hr_cat;
-- Shop (shop_)
select * from shop_category;
select * from shop_product;
select * from shop_customer;
select * from shop_order;
select * from shop_connected_to;
select * from shop_consists_of;
-- Assets (asset_)
select * from asset_catalogue;
select * from asset_inventory;
select * from asset_inventory_furniture;
select * from asset_inventory_mobile;
