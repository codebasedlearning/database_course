-- (C) 2025 A.Voß, a.voss@fh-aachen.de, db@codebasedlearning.dev


-- -- ami_algebra -- --


-- Be careful: this script (re)creates the schema, i.e. the schema and
-- all data it contains (including your own tables in it) are deleted first.
-- This makes the script safe to run again and again.

drop schema if exists ami_algebra cascade;
create schema ami_algebra;

create table ami_algebra.R
(
    Rid int         not null,
    A   varchar(10) null,
    B   varchar(10) null,
    C   varchar(10) null,
    primary key (Rid),
    unique (B)                  -- target of the foreign key S.FB
);

insert into ami_algebra.R (Rid, A, B, C)
values  (1, 'a1', 'b1', 'c1'),
        (2, 'a2', 'b2', 'c2'),
        (3, 'a3', 'b3', 'c3'),
        (4, 'a4', 'b4', null);

create table ami_algebra.S
(
    Sid int         not null,
    C   varchar(10) null,
    D   varchar(10) null,
    E   varchar(10) null,
    FB  varchar(10) null,
    primary key (Sid),
    constraint s_fb_fk foreign key (FB) references ami_algebra.R (B)
);

insert into ami_algebra.S (Sid, C, D, E, FB)
values  (11, 'c1', 'd1', 'e1', 'b1'),
        (13, 'c3', 'd3', 'e3', 'b3'),
        (14, 'c4', 'd4', 'e4', 'b4');

-- -- ami_algebra done -- --
