-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x06

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;


-- working with date and time --

-- UTC
SET SESSION time_zone = 'SYSTEM';
SELECT @@session.time_zone, now();

-- Germany
SET SESSION time_zone = 'Europe/Berlin';
SELECT @@session.time_zone, now();

-- with offset
SET SESSION time_zone = '+02:00';
SELECT @@session.time_zone, now();

-- @@global.time_zone' is the constant for the global setting.
-- Preferences can also be in the my.cnf file
-- SELECT @@global.time_zone, @@session.time_zone, now();

-- back to Germany
SET SESSION time_zone = 'Europe/Berlin';

-- view and convert current date and time
SELECT now() 'N',
       cast(now() AS date) 'D',
       cast(now() AS time) 'T',
       cast(now() AS datetime) 'DT';

-- add a period to a date
SELECT cast(now() AS date) + interval 2 year;
SELECT cast(date_add(now(), interval 2 year) as date);
SELECT cast(now() AS time) - interval 2 hour;

-- time difference in days or hours
SELECT datediff(date_add(now(), interval 1 year),now());
SELECT timediff(NOW(), UTC_TIMESTAMP);

-- convert string
SELECT str_to_date('13.10.2014',get_format(date,'EUR'));
SELECT date_format('2014-10-13',get_format(date,'EUR'));
SELECT date_format('2014-10-13','%W %M %Y');


-- working with views --

USE ami_zone;

-- all pizzas from products as view 'pizzas'
SELECT P.name, P.price AS 'price'
    FROM shop_product P where P.name like '%pizza%';

-- create or replace view 'pizzas'
CREATE OR REPLACE VIEW pizzas AS (
    SELECT P.name, P.price AS 'price'
    FROM ami_zone.shop_product P where P.name like '%pizza%'
);

-- use it
SELECT * FROM pizzas;

-- delete view
DROP VIEW pizzas;


-- working with transactions --

use ami_example;

-- check, if everything is ok
SELECT * FROM person;
SELECT * FROM pet;
SELECT * FROM pet M LEFT OUTER JOIN person F ON M.person_id=F.person_id;

-- set on true
SET autocommit=1;

-- example 1

START TRANSACTION;
INSERT INTO person (person_id,name) VALUES (21,'Max');
SELECT * FROM person;

-- in another session/console: select * from person;

ROLLBACK;
SELECT * FROM person;

-- example 2

START TRANSACTION;
INSERT INTO person (person_id,name) VALUES (21,'Max');
SELECT * FROM person;

-- in another session/console: select * from person;

COMMIT;
SELECT * FROM person;

-- in another session/console: select * from person;

DELETE FROM person WHERE person_id=21;
SELECT * FROM person;

-- example 3

START TRANSACTION;
INSERT INTO person (person_id,name) VALUES (21,'Max');

-- attention: person_id 22 is not existing
INSERT INTO pet (pet_id,name,person_id) VALUES (5,'Mini',22);

ROLLBACK;
SELECT * FROM person;
SELECT * FROM pet;

-- example 4

START TRANSACTION;

-- attention: the person_id 21 is still to come, therefore error
INSERT INTO pet (pet_id,name,person_id) VALUES (5,'Mini',21);
INSERT INTO person (person_id,name) VALUES (21,'Max');
ROLLBACK;

-- switch off the check for referential integrity for a 'short' moment
SET foreign_key_checks = 0;
START TRANSACTION;
INSERT INTO pet (pet_id,name,person_id) VALUES (5,'Mini',21);
INSERT INTO person (person_id,name) VALUES (21,'Max');
COMMIT;

-- restore data and setting
SET foreign_key_checks = 1;

SELECT * FROM person;
SELECT * FROM pet;
SELECT * FROM pet M LEFT OUTER JOIN person F ON M.person_id=F.person_id;
DELETE FROM pet WHERE pet_id=5;
DELETE FROM person WHERE person_id=21;
SELECT * FROM person;
SELECT * FROM pet;

-- example 4

SET autocommit=0;
-- without autocommit, the transaction is still open.
INSERT INTO person (person_id,name) VALUES (21,'Max');
-- check table in another session
SELECT * FROM person;
ROLLBACK;
SELECT * FROM person;
SET autocommit=1;

