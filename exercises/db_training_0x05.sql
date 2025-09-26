-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x05

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;

-- Query schemas
SHOW SCHEMAS;
SHOW DATABASES;

-- Have a look at the engines
select * from information_schema.ENGINES;

-- Create schema, list, set as default, delete
CREATE SCHEMA ami_test;
SHOW SCHEMAS LIKE 'ami_%';
USE ami_test;
DROP SCHEMA ami_test;
SHOW SCHEMAS;

-- Query tables in schema, adjust schema name if necessary
SHOW TABLES FROM ami_zone;
SHOW TABLES FROM ami_zone like 'shop%';
SHOW TABLES FROM ami_zone like 'div%';

-- Query table structure
SHOW COLUMNS FROM ami_zone.div_department;
DESCRIBE ami_zone.div_department;

-- Create schema for the table commands
CREATE SCHEMA ami_example;
SHOW SCHEMAS LIKE 'ami_%';
USE ami_example;

-- Schema is still empty
SHOW TABLES FROM ami_example;

-- Create 'objects' table
CREATE TABLE objects (
  id int primary key,
  name char(10) unique not null,
  comment varchar(255),
  number int(5),
  floating decimal(8,3) default 0.0,
  created datetime default now(),
  important boolean not null default true
);
SHOW COLUMNS FROM objects;

-- Create sample data
INSERT INTO objects (id,name) VALUES ('1','mueller');
INSERT INTO objects (id,name,number) VALUES ('2','meier','3');
SELECT * FROM objects;

# Change table, add attributes
ALTER TABLE objects ADD (
  image blob,
  eps double default 0.01
);
SELECT * FROM objects;
SHOW COLUMNS FROM objects;

-- Change default value
ALTER TABLE objects MODIFY eps float default 0.002;
SHOW COLUMNS FROM objects;
SELECT * FROM objects;

-- Change name and default value
ALTER TABLE objects CHANGE eps feps float default 0.003;
SHOW COLUMNS FROM objects;
SELECT * FROM objects;

-- Delete attributes
ALTER TABLE objects DROP feps;
ALTER TABLE objects DROP image;
SHOW COLUMNS FROM objects;
SELECT * FROM objects;

-- Rename table
ALTER TABLE objects RENAME TO elements;
SELECT * FROM elements;

-- Remove all elements
TRUNCATE TABLE elements;
SELECT * FROM elements;

-- Remove table itself
DROP TABLE elements;
SHOW TABLES FROM ami_example;

--

-- Create tables with table constraints
CREATE TABLE person (
person_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
PRIMARY KEY (person_id)
);

-- Some data
INSERT INTO person (person_id,name) VALUES ('11','MIA');
INSERT INTO person (person_id,name) VALUES ('12','LEA');
SELECT * FROM person;

-- Create table with foreign key and index
CREATE TABLE pet (
pet_id INT NOT NULL,
name VARCHAR(10) NOT NULL CHECK (LENGTH(name) <= 10),  -- first version 50, checked version 10
person_id INT NULL,
PRIMARY KEY (pet_id),
INDEX person_idx (person_id ASC),
CONSTRAINT fk_person FOREIGN KEY
(person_id) REFERENCES person (person_id) );

-- Some data and a join
INSERT INTO pet (pet_id,name,person_id) VALUES ('1','Wuff','11');
INSERT INTO pet (pet_id,name) VALUES ('2','Bello');
SELECT * FROM pet M LEFT OUTER JOIN person F ON M.person_id=F.person_id;

-- insert with check that fails
INSERT INTO pet (pet_id,name,person_id) VALUES ('3','Mr. Robinson','11');
SELECT * FROM pet M;

/*
CREATE TABLE pet2 (
pet_id INT NOT NULL,
name VARCHAR(10) NOT NULL,
person_id INT NULL,
PRIMARY KEY (pet_id),
INDEX person_idx (person_id ASC),
CONSTRAINT nameLengthCheck CHECK (LENGTH(name) <= 10),
CONSTRAINT fk_person2 FOREIGN KEY
(person_id) REFERENCES person (person_id) );

INSERT INTO pet2 (pet_id,name,person_id) VALUES ('3','Mr. Robinson','11');
*/

-- Clean-up
DROP SCHEMA ami_example;
SHOW SCHEMAS;


-- Database for ami_sport - you may need to adapt the data to your tables

/*

INSERT INTO `athlete` (`id`, `name`, `birthday`, `is_male`) VALUES ('101', 'Anna', '1990-2-1', '0');
INSERT INTO `athlete` (`id`, `name`, `birthday`, `is_male`) VALUES ('102', 'Olga', '1991-3-1', '0');
INSERT INTO `athlete` (`id`, `name`, `birthday`, `prize_money`, `is_male`) VALUES ('111', 'Enie', '1992-4-1', '100', '0');
INSERT INTO `athlete` (`id`, `name`, `birthday`, `prize_money`, `is_male`) VALUES ('112', 'Antje', '1993-5-1', '200', '0');
INSERT INTO `athlete` (`id`, `name`, `birthday`, `prize_money`, `is_male`) VALUES ('121', 'Boris', '1990-6-1', '3000', '1');
INSERT INTO `athlete` (`id`, `name`, `birthday`, `prize_money`, `is_male`) VALUES ('122', 'Ivan', '1991-7-1', '4000', '1');

INSERT INTO `team` (`id`, `name`) VALUES ('12345', 'Team NL');
INSERT INTO `team` (`id`, `name`) VALUES ('98765', 'Team PL');

INSERT INTO `competition` (`id`, `description`, `for_male`) VALUES ('56', 'Tennis Preliminary Round - Doubles', '0');
INSERT INTO `competition` (`id`, `description`, `for_male`) VALUES ('98', 'Tennis Final - Singles', '1');
INSERT INTO `competition` (`id`, `description`, `for_male`) VALUES ('99', 'Tennis Final - Singles', '0');

INSERT INTO `attends` (`id`, `athlete_id`, `team_id`, `competition_id`) VALUES ('1', '101', '98765', '56');
INSERT INTO `attends` (`id`, `athlete_id`, `team_id`, `competition_id`) VALUES ('2', '102', '98765', '56');
INSERT INTO `attends` (`id`, `athlete_id`, `team_id`, `competition_id`) VALUES ('3', '111', '12345', '56');
INSERT INTO `attends` (`id`, `athlete_id`, `team_id`, `competition_id`) VALUES ('4', '112', '12345', '56');
INSERT INTO `attends` (`id`, `athlete_id`, `competition_id`) VALUES ('5', '101', '99');
INSERT INTO `attends` (`id`, `athlete_id`, `competition_id`) VALUES ('6', '111', '99');
INSERT INTO `attends` (`id`, `athlete_id`, `competition_id`) VALUES ('7', '121', '98');
INSERT INTO `attends` (`id`, `athlete_id`, `competition_id`) VALUES ('8', '122', '98');

INSERT INTO `referees` (`id`, `athlete_id`, `competition_id`) VALUES ('1', '121', '56');
INSERT INTO `referees` (`id`, `athlete_id`, `competition_id`) VALUES ('2', '122', '99');
INSERT INTO `referees` (`id`, `athlete_id`, `competition_id`) VALUES ('3', '101', '98');

*/
