-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x07

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;


-- 7.1 ER-Model, no SQL

-- 7.2

CREATE SCHEMA ami_experiment;
-- USE ami_experiment;
SET SEARCH_PATH = ami_experiment;

-- create tables first
/*
CREATE TABLE IF NOT EXISTS experiment (
  id INT(11) NOT NULL,
  description VARCHAR(100) NULL DEFAULT NULL,
  last_edited DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS data (
  id INT(11) NOT NULL,
  file_path VARCHAR(250) NULL DEFAULT NULL,
  configuration VARCHAR(250) NULL DEFAULT NULL,
  data_type INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS belongs_to (
  id INT(11) NOT NULL,
  experiment_id INT(11) NOT NULL,
  data_id INT(11) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_is_used_in1
    FOREIGN KEY (experiment_id)
    REFERENCES experiment (id),
  CONSTRAINT fk_is_used_in2
    FOREIGN KEY (data_id)
    REFERENCES data (id)
);
*/
CREATE TABLE IF NOT EXISTS experiment (
  id          integer PRIMARY KEY,
  description varchar(100),
  last_edited timestamp
);

CREATE TABLE IF NOT EXISTS data (
  id            integer PRIMARY KEY,
  file_path     varchar(250),
  configuration varchar(250),
  data_type     integer NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS belongs_to (
  id            integer PRIMARY KEY,
  experiment_id integer NOT NULL REFERENCES experiment(id),
  data_id       integer NOT NULL REFERENCES data(id)
);

-- 7.3 insert data

-- remove all data
-- drop table belongs_to;
-- drop table experiment;
-- drop table data;

insert into experiment (id,description,last_edited) values
(15,'Cold Fusion', '2014-11-01 12:02:03'),
(16,'Hot Fusion', '2014-11-02 14:05:06'),
(17,'Explosive Gas','2014-10-03 17:08:09');

insert into data (id,file_path,configuration,data_type) values
(33, 'c:/params/P1', '{T=1.3e8, P=1.4e6}', 1),
(34, 'c:/params/P2', '{v=0.5c}', 1),
(35, 'c:/params/P3', '{T=1.6e8, P=1.2e6}', 1),
(42, 'c:/daten/D1a', '{1/2}', 2),
(43, 'c:/daten/D1b', '{2/2}', 2),
(44, 'c:/daten/D2', '{1/1}', 2);

insert into belongs_to (id, experiment_id, data_id) values
(1,15,33),(2,15,34),(3,15,42),(4,15,43),
(5,16,34),(6,16,35),(7,16,44);

select * from experiment;
select * from data;
select * from belongs_to;

-- 7.4 update date

-- looking for the id
SELECT id from experiment where description like 'Cold Fusion';

-- update with subselect
update experiment set last_edited='2014-11-05 18:09:10'
where id=(SELECT id from experiment where description like 'Cold Fusion');

-- confirm
select * from experiment;

-- note: in an exam, the id should never be specified explicitly, but always searched for using subselect

-- 7.5

select D.id,D.file_path,D.configuration,D.data_type
from belongs_to R join data D on R.data_id=D.id
where R.experiment_id=(SELECT id from experiment where description like 'Cold Fusion')
  and D.data_type=2;

-- 7.6

select * from data;

insert into data (id,file_path,configuration,data_type)
    select D.id+3,concat(D.file_path,'_V2'),D.configuration,D.data_type
    from belongs_to R join data D on R.data_id=D.id
where R.experiment_id=15 and D.data_type=2;

select * from data where id>44;

-- 7.7

-- what data to insert
select R.id,R.experiment_id,R.data_id from belongs_to R join data D on R.data_id=D.id
where R.experiment_id=15 and D.data_type=2;

insert into belongs_to (id,experiment_id,data_id)
select R.id+5,R.experiment_id,R.data_id+3 from belongs_to R join data D on R.data_id=D.id
where R.experiment_id=15 and D.data_type=2;

select * from belongs_to R where id>=8;

-- 7.8 output

select D.id,D.file_path,D.configuration from belongs_to R
join data D on R.data_id=D.id
join experiment E on R.experiment_id=E.id
where E.id=15;

-- 7.9 delete

delete from belongs_to where experiment_id=15;
delete from data where id in (select data_id from belongs_to where experiment_id=15);

-- 7.10 remove the schema

drop schema ami_experiment cascade;

