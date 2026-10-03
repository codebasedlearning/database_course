-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x06

-- default schema, i.e. unqualified table names refer to ami_zone
SET SEARCH_PATH = ami_zone;


-- working with date and time --

-- time zone of the session: server / local time zone
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

-- view and convert current date and time
SELECT
  now()                AS "N",      -- timestamp with time zone (timestamptz)
  now()::date          AS "D",
  now()::time          AS "T",
  now()::timestamp     AS "TS";     -- timestamp without time zone

-- the same with the standard notation instead of ::
SELECT cast(now() AS date) AS "D", cast(now() AS time) AS "T";

-- add a period to a date/time
SELECT (now()::date + INTERVAL '2 years')::date;
SELECT (now() + INTERVAL '2 years')::date;
SELECT (now()::time - INTERVAL '2 hours')::time;

-- time difference in days (date - date = integer)
SELECT ((now() + INTERVAL '1 year')::date - now()::date) AS days_diff;

-- difference of two timestamps is an interval
SELECT age(now(), timestamp '2000-01-01') AS since_2000;

-- offset of the current time zone
SELECT
  EXTRACT(timezone FROM now()) AS offset_seconds,
  (EXTRACT(timezone FROM now()) / 3600) AS offset_hours;

-- convert string / format date
SELECT to_date('13.10.2014', 'DD.MM.YYYY') AS d;
SELECT to_char(date '2014-10-13', 'DD.MM.YYYY') AS eur;
SELECT to_char(date '2014-10-13', 'FMDay FMMonth YYYY') AS long_text;


-- working with views --

-- all pizzas from products as view 'pizzas'
SELECT P.name, P.price AS price
    FROM shop_product P where P.name like '%Pizza%';

-- create or replace view 'pizzas'
CREATE OR REPLACE VIEW pizzas AS
    SELECT P.name, P.price AS price
    FROM ami_zone.shop_product P where P.name like '%Pizza%';

-- use it
SELECT * FROM pizzas;

-- delete view
DROP VIEW pizzas;


-- working with transactions --

-- We need the tables person and pet from db_training_0x05.sql in schema ami_example.
-- If they do not exist (anymore), they are created here.

CREATE SCHEMA IF NOT EXISTS ami_example;
SET SEARCH_PATH = ami_example;

CREATE TABLE IF NOT EXISTS person (
  person_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  PRIMARY KEY (person_id)
);
CREATE TABLE IF NOT EXISTS pet (
  pet_id    INT PRIMARY KEY,
  name      VARCHAR(50) NOT NULL,
  person_id INT NULL,
  CONSTRAINT name_length_check CHECK (char_length(name) <= 10),
  CONSTRAINT fk_person
    FOREIGN KEY (person_id) REFERENCES person (person_id)
);
INSERT INTO person (person_id,name) VALUES (11,'MIA'), (12,'LEA') ON CONFLICT DO NOTHING;
INSERT INTO pet (pet_id,name,person_id) VALUES (1,'Wuff',11) ON CONFLICT DO NOTHING;
INSERT INTO pet (pet_id,name) VALUES (2,'Bello') ON CONFLICT DO NOTHING;

-- check, if everything is ok
SELECT * FROM person;
SELECT * FROM pet;
SELECT * FROM pet M
    LEFT OUTER JOIN person F ON M.person_id = F.person_id;

-- Note: PostgreSQL works in autocommit mode, i.e. every single command is its own
-- transaction - unless a transaction is started explicitly with BEGIN.
-- Caution: Tools like DataGrip have their own setting (Tx: Auto / Manual), which
-- overrides what you do in SQL.

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
-- expect-error: violates foreign key constraint fk_person
INSERT INTO pet (pet_id, name, person_id) VALUES (5, 'Mini', 22);

-- In PostgreSQL the whole transaction is now aborted, every further command
-- fails until ROLLBACK (MySQL/MariaDB would only discard the failed command).
-- expect-error: current transaction is aborted
SELECT * FROM person;

ROLLBACK;
SELECT * FROM person;
SELECT * FROM pet;

-- example 4

BEGIN;

-- attention: the person_id 21 is still to come, therefore error
-- expect-error: violates foreign key constraint fk_person
INSERT INTO pet (pet_id, name, person_id) VALUES (5, 'Mini', 21);
-- expect-error: current transaction is aborted (see example 3)
INSERT INTO person (person_id, name) VALUES (21, 'Max');
ROLLBACK;

-- Solution: check the foreign key only at the end of the transaction (COMMIT).
-- The constraint must be declared DEFERRABLE, then it can be deferred.
ALTER TABLE pet ALTER CONSTRAINT fk_person DEFERRABLE INITIALLY IMMEDIATE;

BEGIN;
SET CONSTRAINTS fk_person DEFERRED;
INSERT INTO pet (pet_id, name, person_id) VALUES (5, 'Mini', 21);   -- no error yet
INSERT INTO person (person_id, name) VALUES (21, 'Max');
COMMIT;                                                              -- checked here, ok

-- the check really happens at COMMIT: here the person is missing
BEGIN;
SET CONSTRAINTS fk_person DEFERRED;
INSERT INTO pet (pet_id, name, person_id) VALUES (6, 'Maxi', 22);   -- no error yet
-- expect-error: violates foreign key constraint fk_person, the commit becomes a rollback
COMMIT;

-- restore data
SELECT * FROM person;
SELECT * FROM pet;
SELECT * FROM pet M
    LEFT OUTER JOIN person F ON M.person_id = F.person_id;
DELETE FROM pet WHERE pet_id = 5;
DELETE FROM person WHERE person_id = 21;
SELECT * FROM person;
SELECT * FROM pet;

-- example 5

-- An open transaction (BEGIN without COMMIT/ROLLBACK) behaves like 'autocommit off':
-- the changes are only visible in this session.
BEGIN;
INSERT INTO person (person_id, name) VALUES (21, 'Max');
-- check table in another session
SELECT * FROM person;
ROLLBACK;
SELECT * FROM person;

-- Clean-up
SET SEARCH_PATH = ami_zone;
DROP SCHEMA ami_example CASCADE;
