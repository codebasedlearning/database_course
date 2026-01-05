-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x06

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
SET SEARCH_PATH = ami_zone;


-- working with date and time --

/* MySQL / MariaDB

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
*/

    -- =========================================
-- Zeitzone pro Session (PostgreSQL)
-- =========================================

-- "SYSTEM" (MySQL) ≈ Server-/lokale Zeitzone in PG:
SET TIME ZONE 'localtime';
SELECT current_setting('TimeZone') AS session_tz, now() AS now_timestamptz;

-- Germany
SET TIME ZONE 'Europe/Berlin';
SELECT current_setting('TimeZone') AS session_tz, now() AS now_timestamptz;

-- with offset (+02:00)
SET TIME ZONE INTERVAL '+02:00' HOUR TO MINUTE;
SELECT current_setting('TimeZone') AS session_tz, now() AS now_timestamptz;

-- back to Germany
SET TIME ZONE 'Europe/Berlin';

-- =========================================
-- view and convert current date and time
-- =========================================
SELECT
  now()                AS "N",      -- timestamptz
  now()::date          AS "D",
  now()::time          AS "T",
  now()::timestamp     AS "TS";     -- "datetime" in MySQL ≈ timestamp in PG

-- =========================================
-- add a period to a date/time
-- =========================================
SELECT (now()::date + INTERVAL '2 years')::date;

SELECT ((now() + INTERVAL '2 years')::date);

SELECT (now()::time - INTERVAL '2 hours')::time;

-- =========================================
-- time difference in days or hours
-- =========================================

-- Difference (as integer):
SELECT ((now() + INTERVAL '1 year')::date - now()::date) AS days_diff;

SELECT
  EXTRACT(timezone FROM now()) AS offset_seconds,
  (EXTRACT(timezone FROM now()) / 3600) AS offset_hours;

-- =========================================
-- convert string / format date
-- =========================================

SELECT to_date('13.10.2014', 'DD.MM.YYYY') AS d;
SELECT to_char(date '2014-10-13', 'DD.MM.YYYY') AS eur;
SELECT to_char(date '2014-10-13', 'FMDay FMMonth YYYY') AS long_text;


-- working with views --

-- USE ami_zone;
SET SEARCH_PATH = ami_zone;

-- all pizzas from products as view 'pizzas'
SELECT P.name, P.price AS price
    FROM shop_product P where P.name like '%Pizza%';

-- create or replace view 'pizzas'
CREATE OR REPLACE VIEW pizzas AS (
    SELECT P.name, P.price AS price
    FROM ami_zone.shop_product P where P.name like '%Pizza%'
);

-- use it
SELECT * FROM pizzas;

-- delete view
DROP VIEW pizzas;


-- working with transactions --

-- we need tables person and pet from db_training_0x05.sql

-- CREATE SCHEMA ami_example;
SET SEARCH_PATH = ami_example;

/*
-- copy from db_training_0x05
CREATE TABLE person (
person_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
PRIMARY KEY (person_id)
);
INSERT INTO person (person_id,name) VALUES ('11','MIA');
INSERT INTO person (person_id,name) VALUES ('12','LEA');
SELECT * FROM person;

drop table pet;
CREATE TABLE pet (
  pet_id   INT PRIMARY KEY,
  name     VARCHAR(10) NOT NULL CHECK (char_length(name) <= 10),
  person_id INT NULL,
  CONSTRAINT fk_person
    FOREIGN KEY (person_id) REFERENCES person (person_id)
);
INSERT INTO pet (pet_id,name,person_id) VALUES ('1','Wuff','11');
INSERT INTO pet (pet_id,name) VALUES ('2','Bello');
SELECT * FROM pet M;
SELECT * FROM pet M LEFT OUTER JOIN person F ON M.person_id=F.person_id;
*/

-- check, if everything is ok
SELECT * FROM person;
SELECT * FROM pet;
SELECT * FROM pet M
    LEFT OUTER JOIN person F ON M.person_id = F.person_id;

-- PostgreSQL uses autocommit by default (no need to set explicitly)
-- SET autocommit=1; -- not needed in PostgreSQL

-- example 1

BEGIN; -- or START TRANSACTION;
INSERT INTO person (person_id, name) VALUES (21, 'Max');
SELECT * FROM person;

-- in another session/console: select * from person;

ROLLBACK;
SELECT * FROM person;

-- example 2

BEGIN;
INSERT INTO person (person_id, name) VALUES (21, 'Max');
SELECT * FROM person;

-- in another session/console: select * from person;

COMMIT;
SELECT * FROM person;

-- in another session/console: select * from person;

DELETE FROM person WHERE person_id = 21;
SELECT * FROM person;

-- example 3

BEGIN;
INSERT INTO person (person_id, name) VALUES (21, 'Max');

-- attention: person_id 22 is not existing
INSERT INTO pet (pet_id, name, person_id) VALUES (5, 'Mini', 22);

ROLLBACK;
SELECT * FROM person;
SELECT * FROM pet;

-- example 4

BEGIN;

-- attention: the person_id 21 is still to come, therefore error
INSERT INTO pet (pet_id, name, person_id) VALUES (5, 'Mini', 21);
INSERT INTO person (person_id, name) VALUES (21, 'Max');
ROLLBACK;

-- switch off the check for referential integrity for a 'short' moment
SET session_replication_role = replica; -- disables FK checks
BEGIN;
INSERT INTO pet (pet_id, name, person_id) VALUES (5, 'Mini', 21);
INSERT INTO person (person_id, name) VALUES (21, 'Max');
COMMIT;

-- restore data and setting
SET session_replication_role = DEFAULT; -- re-enables FK checks

SELECT * FROM person;
SELECT * FROM pet;
SELECT * FROM pet M
    LEFT OUTER JOIN person F ON M.person_id = F.person_id;
DELETE FROM pet WHERE pet_id = 5;
DELETE FROM person WHERE person_id = 21;
SELECT * FROM person;
SELECT * FROM pet;

-- example 5

-- PostgreSQL always uses autocommit=on by default in psql
-- To simulate autocommit=off, explicitly use BEGIN without COMMIT
BEGIN;
-- without explicit COMMIT, the transaction remains open
INSERT INTO person (person_id, name) VALUES (21, 'Max');
-- check table in another session
SELECT * FROM person;
ROLLBACK;
SELECT * FROM person;
-- back to normal (autocommit on by default)
