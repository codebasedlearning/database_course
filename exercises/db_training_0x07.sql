-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x07



-- insert, update and delete --

-- This unit needs schema ami_sport with your tables and data from tasks 5.1 and 5.2
-- (or see proposed_solutions/db_solution_0x05.sql).
SET SEARCH_PATH = ami_sport;

SELECT * FROM athlete;

START TRANSACTION;

-- insert

-- create data (if the data exists, delete first; see below).
INSERT INTO athlete (id, name, birthday, is_male)
VALUES (131, 'Pierre', '1991-12-24', true);
INSERT INTO athlete (id, name, birthday, is_male)
VALUES (132, 'Rob', '1991-12-24', true);
INSERT INTO athlete (id, name, birthday)
VALUES (133,'Pete',(CURRENT_DATE - INTERVAL '20 years')::timestamp);
SELECT * FROM athlete;

-- check value (one day after Pete)
SELECT s.name, s.birthday + INTERVAL '1 day' FROM athlete s
WHERE s.name = 'Pete';

-- generate attribute values from other data
INSERT INTO athlete (id, name, birthday)
VALUES (134,'Marc',
  (
    SELECT s.birthday + INTERVAL '1 day'
    FROM athlete s
    WHERE s.name = 'Pete'
  )
);


SELECT * FROM athlete where name='Pete' or name='Marc';

-- create multiple records at once
INSERT INTO athlete (id, name, birthday, prize_money) VALUES
  (135, 'Tick', '1992-02-21 15:00', 100.0),
  (136, 'Trick', '1992-02-21 15:01', 0.0),
  (137, 'Track', '1992-02-21 15:02', 200.0);

SELECT * FROM athlete;

-- check value (for Tick, Trick, Track)
SELECT S.id, S.name ,S.birthday
FROM athlete S WHERE S.name like '%ck%';

-- generate entire records from other records
INSERT INTO athlete (id, name, birthday)
    SELECT S.id+3,concat(S.name,' Double'),S.birthday
    FROM athlete S WHERE S.name like '%ck';

SELECT * FROM athlete;

-- update

-- which data should be changed
SELECT S.id, S.name ,S.prize_money, S.is_male
FROM athlete S WHERE S.id>=138;

UPDATE athlete SET prize_money=1000 WHERE id=138;

SELECT S.id, S.name ,S.prize_money, S.is_male
FROM athlete S WHERE S.id>=138;

-- change multiple attributes
UPDATE athlete
SET prize_money=prize_money+50, is_male=false
WHERE id>=138;

SELECT S.id, S.name ,S.prize_money, S.is_male
FROM athlete S WHERE S.id>=138;

-- modify records using subselects
SELECT id, name, prize_money, prize_money % 1234 FROM athlete;
SELECT max(prize_money % 1234) as max_prize_money FROM athlete;  -- 1050

UPDATE athlete
SET prize_money = (
    SELECT max(prize_money % 1234) as max_prize_money
    FROM athlete
) WHERE id=139;

SELECT id, name, prize_money, prize_money % 1234 FROM athlete;

-- delete data
DELETE FROM athlete WHERE id>130;

SELECT * FROM athlete;

-- unsafe, a DELETE without WHERE deletes everything... if it is allowed to:
-- here the foreign keys of attends and referees prevent it.
-- expect-error: violates foreign key constraint fk1 on table attends
DELETE FROM athlete;

-- the error aborted the transaction, only ROLLBACK is possible now

ROLLBACK;

SELECT * FROM athlete;

