-- (C) 2023 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev

-- Relational algebra and the corresponding SQL commands

-- The relations R and S are reduced to the essentials;
-- the entities consist of artificial attributes of the
-- form [a1,b1,c1].

-- default schema, i.e. unqualified table names refer to ami_algebra
SET SEARCH_PATH = ami_algebra;

-- Special feature of R: a null entry in C of the entity Rid=4
SELECT * from R;
-- Rid  A  B  C
--   1 a1 b1 c1
--   2 a2 b2 c2
--   3 a3 b3 c3
--   4 a4 b4 <null>

-- Special feature of S: column FB is a foreign key to R.B
SELECT * from S;
-- Sid  C  D  E FB
--  11 c1 d1 e1 b1
--  13 c3 d3 e3 b3
--  14 c4 d4 e4 b4


-- Operations of the relational algebra and their SQL counterparts --


-- Selection, i.e. choosing rows with WHERE
-- (here all entities/rows with Rid<=2)
SELECT * FROM R WHERE Rid<=2;

-- Projection, i.e. choosing attributes in SELECT
-- (here the columns A and C)
SELECT A,C FROM R;

-- Cross join, cross product, Cartesian product, i.e. all
-- entities of R combined with all of S;
-- note the structure of the result, all columns are present
SELECT * FROM R,S;

-- Inner join with condition, here an equi-join on an attribute
-- (the C attributes shall be equal)
SELECT * FROM R,S WHERE R.C=S.C;

-- as above, inner join with the join command
-- Preferred variant!
SELECT * FROM R JOIN S ON R.C = S.C;

-- and another inner join; here the relationship between
-- equi-join and natural join can be seen, one column less
SELECT * FROM R JOIN S USING (C);

-- Natural join, also without the duplicate column,
-- compare with the variant above
SELECT * FROM R NATURAL JOIN S;

-- Inner join with a condition on the foreign key FB
-- (attribute B shall be equal to attribute FB)
SELECT * FROM R,S WHERE R.B=S.FB;

-- as before, inner join with the join command
-- Preferred variant!
SELECT * FROM R JOIN S ON R.B = S.FB;

-- Semi join, i.e. all entities of R that have a join partner in S,
-- only with the attributes of R and each entity of R at most once
SELECT R.* FROM R
WHERE EXISTS (SELECT 1 FROM S WHERE S.C = R.C);

-- Note: 'SELECT R.* FROM R NATURAL JOIN S' gives the same result here, but
-- in general it is NOT a semi join: if an entity of R has several partners
-- in S, it appears several times.

-- Anti semi join, i.e. all entities of R that do not have a join partner
-- in S, again only the attributes of R
SELECT R.* FROM R
WHERE NOT EXISTS (SELECT 1 FROM S WHERE S.C = R.C);

-- the same with an outer join, the null element marks the missing partner
SELECT R.* FROM R LEFT OUTER JOIN S ON R.C = S.C
WHERE S.C is null;

-- Left outer join, i.e. all entities of R and, if an associated
-- entity exists, the attributes of S, otherwise null
SELECT * FROM R LEFT OUTER JOIN S ON R.C = S.C;

-- Right outer join, i.e. like the left outer join, but
-- this time all entities of S are included
SELECT * FROM R RIGHT OUTER JOIN S ON R.C = S.C;

-- Full outer join, i.e. all entities of R and all of S,
-- each with its partner or null
SELECT * FROM R FULL OUTER JOIN S ON R.C = S.C;

-- with example, i.e. first a temporary relation RR is
-- determined and can then be used under this name and with
-- the renamed attributes, e.g. in the SELECT
-- (column names in double quotes keep their case, single quotes are strings)
WITH
     RR as (select Rid as id, A as "AA" from R where Rid<4)
SELECT * from RR;

-- Minus: first build the subset A1 with Rid<4 (i.e. 1,2,3) and
-- the subset A2 with Rid>1 (i.e. 2,3,4); then the outer join
-- with the key Rid gives a null element in A2 exactly when the
-- entity is in A1 but not in A2 -> that is the minus (Rid=1 remains)
WITH
     A1 as (select * from R where Rid<4),
     A2 as (select * from R where Rid>1)
SELECT A1.* FROM A1 LEFT OUTER JOIN A2 USING (Rid)
WHERE A2.Rid is null;

SELECT * FROM R WHERE Rid<4
EXCEPT
SELECT * FROM R WHERE Rid>1;

-- Intersection: same subsets A1 and A2 as before, then the inner
-- join gives exactly the elements that are in both sets
WITH
     A1 as (select * from R where Rid<4),
     A2 as (select * from R where Rid>1)
SELECT A1.* FROM A1 JOIN A2 USING (Rid);

SELECT * FROM R WHERE Rid<4
INTERSECT
SELECT * FROM R WHERE Rid>1;

-- Union: the SQL command union combines the two subsets A1
-- (here Rid 1) and A2 (here Rid 1 and 4), duplicates are removed
WITH
     A1 as (select * from R where Rid=1),
     A2 as (select * from R where Rid=4 or Rid=1)
SELECT * FROM A1
UNION
SELECT * FROM A2;

SELECT * FROM R WHERE Rid=1
UNION
SELECT * FROM R WHERE Rid=4 or Rid=1;

-- Union: the SQL command union all combines as before,
-- but duplicate elements remain (Rid 1)
WITH
     A1 as (select * from R where Rid=1),
     A2 as (select * from R where Rid=4 or Rid=1)
SELECT * FROM A1
UNION ALL
SELECT * FROM A2;

-- count: there is a null element in column C, therefore
-- count(*)=4 but count(C) only 3
SELECT count(*),count(C) FROM R;

-- sum: sums up the string lengths of B... only to demonstrate sum
SELECT sum(length(B)) FROM R;

-- preparation for group: substr gives the number 1-4
SELECT *,substr(A,2) as no FROM R;

-- group: grouped by remainder div 2, and the sum of
-- these numbers is calculated (1+3 and 2+4)
WITH
     A1 as (SELECT cast(substr(A,2) as int) as no FROM R)
SELECT sum(no) FROM A1
GROUP BY no%2=1;

-- group+having: grouping as above, but with a condition on
-- the result of the grouping
WITH
     A1 as (SELECT cast(substr(A,2) as int) as no FROM R)
SELECT sum(no) as S FROM A1
GROUP BY no%2=1 HAVING sum(no)>4;
