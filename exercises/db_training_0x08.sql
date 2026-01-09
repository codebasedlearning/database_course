-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x08

-- select default schema in MariaDB (comment out for PostgreSQL):
-- USE ami_zone;
-- select default schema in PostgreSQL (comment out for MariaDB):
SET SEARCH_PATH = ami_zone;

-- stored procedures and triggers --

/*
 Differences MySQL and PostgreSQL:
  – No DELIMITER in Postgres.
  – Use functions to “return rows” from SELECT.
  – Trigger functions are written in PL/pgSQL and triggers call them.
  – AUTO_INCREMENT → GENERATED ... AS IDENTITY
  – DATETIME → timestamp (usually timestamp without time zone)
  – NOW() exists (also CURRENT_TIMESTAMP).
 */

-- if necessary
-- DROP FUNCTION IF EXISTS show_products();

CREATE OR REPLACE FUNCTION show_products()
RETURNS SETOF shop_product
LANGUAGE sql
AS $$
  SELECT p.* FROM shop_product p;
$$;

-- call
SELECT * FROM show_products();

-- clean up
DROP FUNCTION show_products();

-- with parameter

-- if necessary
-- DROP FUNCTION IF EXISTS show_one_product(int);

CREATE OR REPLACE FUNCTION show_one_product(p_id int)
RETURNS SETOF shop_product
LANGUAGE sql
AS $$
  SELECT p.* FROM shop_product p
  WHERE p.id = p_id;
$$;

-- call
SELECT * FROM show_one_product(11);  -- 'Meatballs'

-- clean up
DROP FUNCTION show_one_product(int);

-- create a log

CREATE TABLE IF NOT EXISTS log_update (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  table_name varchar(250),
  last_text varchar(250),
  new_text varchar(250),
  last_update timestamp
);

-- if necessary
-- DROP TRIGGER IF EXISTS before_product_update ON shop_product;
-- DROP FUNCTION IF EXISTS trg_before_product_update();

CREATE OR REPLACE FUNCTION trg_before_product_update()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO log_update (table_name, last_text, new_text, last_update)
  VALUES ('shop_product', OLD.name, NEW.name, now());

  RETURN NEW; -- important for BEFORE UPDATE triggers
END;
$$;

CREATE TRIGGER before_product_update
BEFORE UPDATE ON shop_product
FOR EACH ROW
EXECUTE FUNCTION trg_before_product_update();

-- show log before updates
SELECT * FROM log_update;

-- update some data
UPDATE shop_product SET name = 'Buletten' WHERE id = 11;
SELECT * FROM shop_product WHERE id = 11;

-- and restore
UPDATE shop_product SET name = 'Meatballs' WHERE id = 11;
SELECT * FROM shop_product WHERE id = 11;

-- see results
SELECT * FROM log_update;

-- clean up
DROP TRIGGER before_product_update ON shop_product;
DROP FUNCTION trg_before_product_update();
DROP TABLE log_update;


/*
 MySQL


-- if necessary
-- DROP PROCEDURE ShowProducts;

-- Attention: the _whole block_ must be marked and executed, so that the command delimiters
-- are set correctly, i.e. from "DELIMITER //" to "DELIMITER ;".
-- This also applies to the other procedures and triggers.

DELIMITER //
CREATE PROCEDURE ShowProducts()
BEGIN
  SELECT P.* FROM shop_product P;
END //
DELIMITER ;

CALL ShowProducts();

DROP PROCEDURE ShowProducts;

-- with parameter

-- if necessary
-- DROP PROCEDURE ShowOneProduct;

DELIMITER //
CREATE PROCEDURE ShowOneProduct(IN id int)
BEGIN
  SELECT P.* FROM shop_product P where P.id=id;
END //
DELIMITER ;

CALL ShowOneProduct(11); -- 'Meatballs'

DROP PROCEDURE ShowOneProduct;

-- create a log

CREATE TABLE IF NOT EXISTS log_update (
  id INT(11) NOT NULL AUTO_INCREMENT,
  table_name VARCHAR(250) NULL DEFAULT NULL,
  last_text VARCHAR(250) NULL DEFAULT NULL,
  new_text VARCHAR(250) NULL DEFAULT NULL,
  last_update DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

-- if necessary
-- DROP TRIGGER before_product_update;

DELIMITER $$
CREATE TRIGGER before_product_update BEFORE UPDATE ON shop_product
FOR EACH ROW BEGIN
    INSERT INTO log_update (table_name,last_text,new_text,last_update)
    VALUES ('shop_product',OLD.name,NEW.name,NOW());
END$$
DELIMITER ;

-- show log before updates
SELECT * FROM log_update;

-- update some data
UPDATE shop_product set name='Buletten' where id=11;
SELECT * from shop_product where id=11;
-- and restore
UPDATE shop_product set name='Meatballs' where id=11;
SELECT * from shop_product where id=11;

-- see results
SELECT * FROM log_update;

-- clean up

DROP TRIGGER before_product_update;
DROP TABLE log_update;
*/
