-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- SQL-Solutions Unit 0x08

-- select default schema in MariaDB (comment out for PostgreSQL):
USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
-- SET SEARCH_PATH = ami_zone;


-- stored procedures --

-- 8.1 define a stored procedure

-- if necessary
-- DROP PROCEDURE Hello;

DELIMITER //
CREATE PROCEDURE Hello(IN name varchar(50))
BEGIN
  SELECT CONCAT('Hello ', name) as 'message';
END //
DELIMITER ;

CALL Hello('World!');

DROP PROCEDURE Hello;
