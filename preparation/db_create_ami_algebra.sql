-- (C) 2025 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev


-- -- ami_algebra -- --


-- Be careful here, because if you delete the schema,
-- all the data it contains will also be deleted.

-- mariadb (implicit cascade)
-- drop schema ami_algebra;
-- postgres
-- drop schema ami_algebra CASCADE;

create schema if not exists ami_algebra;

create table if not exists ami_algebra.R
(
    Rid int         not null,
    A   varchar(10) null,
    B   varchar(10) null,
    C   varchar(10) null
);

insert into ami_algebra.R (Rid, A, B, C)
values  (1, 'a1', 'b1', 'c1'),
        (2, 'a2', 'b2', 'c2'),
        (3, 'a3', 'b3', 'c3'),
        (4, 'a4', 'b4', null);

create table if not exists ami_algebra.S
(
    Sid int         null,
    C   varchar(10) null,
    D   varchar(10) null,
    E   varchar(10) null,
    FB  varchar(10) null
);

insert into ami_algebra.S (Sid, C, D, E, FB)
values  (11, 'c1', 'd1', 'e1', 'b1'),
        (13, 'c3', 'd3', 'e3', 'b3'),
        (14, 'c4', 'd4', 'e4', 'b4');
