-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

-- SQL-Solutions Unit 0x08

-- default schema, i.e. unqualified table names refer to ami_zone
SET SEARCH_PATH = ami_zone;


-- stored procedures --

-- 8.1 define a stored procedure

-- if necessary
-- DROP FUNCTION IF EXISTS hello(varchar);

CREATE OR REPLACE FUNCTION hello(p_name varchar(50))
RETURNS TABLE (message text)
LANGUAGE sql
AS $$
  SELECT 'Hello ' || p_name AS message;
$$;

-- call it
SELECT * FROM hello('World!');

-- clean up
DROP FUNCTION hello(varchar);
