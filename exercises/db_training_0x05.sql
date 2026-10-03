-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x05

-- default schema, i.e. unqualified table names refer to ami_zone
SET SEARCH_PATH = ami_zone;

-- Query schemas
SELECT schema_name
FROM information_schema.schemata;

-- Create schema, list, delete
CREATE SCHEMA ami_test;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'ami_test';

DROP SCHEMA ami_test;

-- Query tables in a schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'ami_zone' AND table_name LIKE 'shop%';

-- Query table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'ami_zone' AND table_name = 'div_department'
ORDER BY ordinal_position;

--

-- Create schema for the table commands (if it is left over from a previous run, delete it first)
DROP SCHEMA IF EXISTS ami_example CASCADE;
CREATE SCHEMA ami_example;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name LIKE 'ami_%';

SET SEARCH_PATH = ami_example;

-- Schema is still empty
SELECT table_name
FROM information_schema.tables
WHERE table_schema = current_schema();

--

-- Create 'objects' table
CREATE TABLE objects (
  id int primary key,
  name varchar(10) unique not null,
  comment varchar(255),
  number int,
  floating decimal(8,3) default 0.0,
  created timestamp default now(),
  important boolean not null default true
);
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = current_schema() AND table_name = 'objects'
ORDER BY ordinal_position;

-- Create sample data
INSERT INTO objects (id,name) VALUES (1,'mueller');
INSERT INTO objects (id,name,number) VALUES (2,'meier',3);
SELECT * FROM objects;

-- Change table, add attributes
ALTER TABLE objects
  ADD COLUMN image bytea,
  ADD COLUMN eps double precision DEFAULT 0.01;

SELECT * FROM objects;

-- Change type and default value
ALTER TABLE objects
  ALTER COLUMN eps TYPE real,
  ALTER COLUMN eps SET DEFAULT 0.002;

SELECT * FROM objects;

-- Change name and default value
ALTER TABLE objects
  RENAME COLUMN eps TO feps;

ALTER TABLE objects
  ALTER COLUMN feps SET DEFAULT 0.003;

SELECT * FROM objects;

-- Delete attributes
ALTER TABLE objects DROP COLUMN feps;
ALTER TABLE objects DROP COLUMN image;
SELECT * FROM objects;

-- Rename table
ALTER TABLE objects RENAME TO elements;
SELECT * FROM elements;

-- Remove all elements
TRUNCATE TABLE elements;
SELECT * FROM elements;

-- Remove table itself
DROP TABLE elements;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = current_schema();

--

-- Create tables with table constraints
CREATE TABLE person (
  person_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  PRIMARY KEY (person_id)
);

-- Some data
INSERT INTO person (person_id,name) VALUES (11,'MIA');
INSERT INTO person (person_id,name) VALUES (12,'LEA');
SELECT * FROM person;

-- Create table with foreign key, check constraint and index.
-- The column itself would allow 50 characters, the CHECK constraint only 10.
CREATE TABLE pet (
  pet_id    INT PRIMARY KEY,
  name      VARCHAR(50) NOT NULL,
  person_id INT NULL,
  CONSTRAINT name_length_check CHECK (char_length(name) <= 10),
  CONSTRAINT fk_person
    FOREIGN KEY (person_id) REFERENCES person (person_id)
);

-- PostgreSQL does not create an index for a foreign key automatically (MySQL does)
CREATE INDEX person_idx ON pet (person_id); -- ASC is the default sort order

-- Some data and a join
INSERT INTO pet (pet_id,name,person_id) VALUES (1,'Wuff',11);
INSERT INTO pet (pet_id,name) VALUES (2,'Bello');
SELECT * FROM pet M LEFT OUTER JOIN person F ON M.person_id=F.person_id;

-- insert with check that succeeds ('Mr. Rob' has 7 characters)
INSERT INTO pet (pet_id,name,person_id) VALUES (3,'Mr. Rob',11);

-- expect-error: 'Mr. Robinson' has 12 characters, violates name_length_check
INSERT INTO pet (pet_id,name,person_id) VALUES (4,'Mr. Robinson',11);

-- expect-error: person 99 does not exist, violates fk_person
INSERT INTO pet (pet_id,name,person_id) VALUES (5,'Mini',99);

SELECT * FROM pet M;

-- Clean-up: we keep schema ami_example with person and pet for unit 0x06.
-- DROP SCHEMA ami_example CASCADE;

SET SEARCH_PATH = ami_zone;


-- Data for ami_sport (task 5.2) - adapt the column names to your own tables

/*
INSERT INTO athlete (id, name, birthday, is_male) VALUES
  (101, 'Anna',  '1990-02-01', false),
  (102, 'Olga',  '1991-03-01', false);

INSERT INTO athlete (id, name, birthday, prize_money, is_male) VALUES
  (111, 'Enie',  '1992-04-01',  100, false),
  (112, 'Antje', '1993-05-01',  200, false),
  (121, 'Boris', '1990-06-01', 3000, true),
  (122, 'Ivan',  '1991-07-01', 4000, true);

INSERT INTO team (id, name) VALUES
  (12345, 'Team NL'),
  (98765, 'Team PL');

INSERT INTO competition (id, description, for_male) VALUES
  (56, 'Tennis Preliminary Round - Doubles', false),
  (98, 'Tennis Final - Singles', true),
  (99, 'Tennis Final - Singles', false);

INSERT INTO attends (id, athlete_id, team_id, competition_id) VALUES
  (1, 101, 98765, 56),
  (2, 102, 98765, 56),
  (3, 111, 12345, 56),
  (4, 112, 12345, 56);

INSERT INTO attends (id, athlete_id, competition_id) VALUES
  (5, 101, 99),
  (6, 111, 99),
  (7, 121, 98),
  (8, 122, 98);

INSERT INTO referees (id, athlete_id, competition_id) VALUES
  (1, 121, 56),
  (2, 122, 99),
  (3, 101, 98);
*/
