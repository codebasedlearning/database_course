-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Commands Unit 0x08

-- default schema, i.e. unqualified table names refer to ami_zone
SET SEARCH_PATH = ami_zone;

-- stored procedures and triggers --

/*
 Notes:
  - A FUNCTION returns a value or rows and is used inside a query: SELECT * FROM f();
  - A PROCEDURE returns nothing (except OUT parameters), is started with CALL and,
    unlike a function, may contain COMMIT/ROLLBACK.
  - Trigger logic is written as a trigger function (here in PL/pgSQL),
    the trigger itself only says when to call it.
  - The body is a string, $$ ... $$ is just a convenient quote (no DELIMITER needed).
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

-- a procedure: no result rows, started with CALL

CREATE OR REPLACE PROCEDURE raise_price(p_id int, p_percent numeric)
LANGUAGE sql
AS $$
  UPDATE shop_product SET price = round(price * (1 + p_percent/100), 2)
  WHERE id = p_id;
$$;

SELECT id, name, price FROM shop_product WHERE id = 11;
BEGIN;
CALL raise_price(11, 10);
SELECT id, name, price FROM shop_product WHERE id = 11;
ROLLBACK;   -- we do not really want to change the price

-- clean up
DROP PROCEDURE raise_price(int, numeric);

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
