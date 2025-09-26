-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x05

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;

-- A5.1:

-- DROP SCHEMA ami_sport;
CREATE SCHEMA ami_sport;
SHOW SCHEMAS;
USE ami_sport;

-- A5.2:

CREATE TABLE IF NOT EXISTS athlete (
  id INT(11) NOT NULL,
  name VARCHAR(100) NOT NULL,
  birthday DATETIME NOT NULL,
  prize_money DECIMAL(12,2) NULL DEFAULT 0,
  is_male boolean default 1,
  PRIMARY KEY (id));

CREATE TABLE IF NOT EXISTS competition (
  id INT(11) NOT NULL,
  description VARCHAR(100) NOT NULL,
  for_male TINYINT(1),
  PRIMARY KEY (id));

CREATE TABLE IF NOT EXISTS team (
  id INT(11) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id));

CREATE TABLE IF NOT EXISTS attends (
  id INT(11) NOT NULL,
  athlete_id INT(11) NOT NULL,
  team_id INT(11) NULL DEFAULT NULL,
  competition_id INT(11) NOT NULL,
  place INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (id),
  INDEX fk1_idx (athlete_id ASC),
  INDEX fk2_idx (team_id ASC),
  INDEX fk3_idx (competition_id ASC),
  CONSTRAINT fk1 FOREIGN KEY (athlete_id) REFERENCES athlete (id),
  CONSTRAINT fk2 FOREIGN KEY (team_id) REFERENCES team (id),
  CONSTRAINT fk3 FOREIGN KEY (competition_id) REFERENCES competition (id));

CREATE TABLE IF NOT EXISTS referees (
  id INT(11) NOT NULL,
  athlete_id INT(11) NOT NULL,
  competition_id INT(11) NOT NULL,
  PRIMARY KEY (id),
  INDEX fk4_idx (athlete_id ASC),
  INDEX fk5_idx (competition_id ASC),
	CONSTRAINT fk4 FOREIGN KEY (athlete_id) REFERENCES athlete (id),
	CONSTRAINT fk5 FOREIGN KEY (competition_id) REFERENCES competition (id)
);

-- Data

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

-- Test

SELECT * FROM athlete;
SELECT * FROM competition;
SELECT * FROM team;
SELECT * FROM attends;
SELECT * FROM referees;

-- In case you want to rebuild the tables
-- DROP TABLE attends;
-- DROP TABLE referees;
-- DROP TABLE team;
-- DROP TABLE competition;
-- DROP TABLE athlete;

-- A5.3:

SELECT athlete_id,count(*) FROM attends
GROUP BY athlete_id HAVING count(*)>1;

SELECT S.id,S.name,count(*) FROM attends
JOIN athlete S ON athlete_id=S.id
GROUP BY athlete_id HAVING count(*)>1;

-- A5.4:

SELECT S.id,S.name FROM athlete S
WHERE NOT exists (SELECT * FROM referees P WHERE P.athlete_id=S.id);

-- A5.5:

SELECT T.name, W.description FROM attends N
INNER JOIN competition W ON N.competition_id=W.id
INNER JOIN team T ON N.team_id=T.id
WHERE N.team_id IS NOT NULL
GROUP BY N.competition_id, N.team_id ;

-- A5.6:

SELECT S.id,S.name, W.description,W.for_male FROM attends N
INNER JOIN athlete S ON N.athlete_id=S.id
INNER JOIN competition W ON N.competition_id=W.id
WHERE N.competition_id IN (
SELECT W.id FROM competition W WHERE W.description LIKE '%final%'
);
