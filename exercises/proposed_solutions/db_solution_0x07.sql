-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x07



-- 7.1 ER-Model, no SQL

-- 7.2

CREATE SCHEMA ami_experiment;
SET SEARCH_PATH = ami_experiment;

-- create tables first
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

-- 7.4 update date (search the id, do not hardcode it)

-- looking for the id
SELECT id from experiment where description like 'Cold Fusion';

-- update with subselect
update experiment set last_edited='2014-11-05 18:09:10'
where id=(SELECT id from experiment where description like 'Cold Fusion');

-- confirm
select * from experiment;

-- note: in an exam, the id should never be specified explicitly, but always searched for using subselect
-- (this also applies to the following tasks)

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
where R.experiment_id=(SELECT id from experiment where description = 'Cold Fusion')
  and D.data_type=2;

select * from data where id>44;

-- 7.7

-- what data to insert
select R.id,R.experiment_id,R.data_id from belongs_to R join data D on R.data_id=D.id
where R.experiment_id=(SELECT id from experiment where description = 'Cold Fusion')
  and D.data_type=2;

insert into belongs_to (id,experiment_id,data_id)
select R.id+5,R.experiment_id,R.data_id+3 from belongs_to R join data D on R.data_id=D.id
where R.experiment_id=(SELECT id from experiment where description = 'Cold Fusion')
  and D.data_type=2;

select * from belongs_to R where id>=8;

-- 7.8 output

select D.id,D.file_path,D.configuration from belongs_to R
join data D on R.data_id=D.id
join experiment E on R.experiment_id=E.id
where E.description = 'Cold Fusion';

-- 7.9 delete

-- Caution, the obvious order does not work:
--   delete from belongs_to where experiment_id=...;
--   delete from data where id in (select data_id from belongs_to where experiment_id=...);
-- after the first command the subselect is empty, i.e. no data is deleted at all.
-- Also, data 34 is used by experiment 16 as well and must not be deleted.

-- first the data that belongs to 'Cold Fusion' only ...
-- expect-error: still referenced by belongs_to, the links must go first
delete from data D
where D.id in (select data_id from belongs_to
               where experiment_id=(SELECT id from experiment where description = 'Cold Fusion'))
  and not exists (select 1 from belongs_to B
                  where B.data_id=D.id
                    and B.experiment_id<>(SELECT id from experiment where description = 'Cold Fusion'));

-- ... so the order is: remember the data ids, delete the links, then the data.
-- In PostgreSQL this can be done in one statement (data-modifying CTE):
with cold as (select id from experiment where description = 'Cold Fusion'),
     gone as (delete from belongs_to where experiment_id = (select id from cold)
              returning data_id)
delete from data D
where D.id in (select data_id from gone)
  and not exists (select 1 from belongs_to B          -- sees the state before the CTE
                  where B.data_id = D.id
                    and B.experiment_id <> (select id from cold));

select * from data;
select * from belongs_to;

-- 7.10 remove the schema

drop schema ami_experiment cascade;

