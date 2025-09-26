-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


-- -- ami_rel_model -- --


-- Be careful here, because if you delete the schema,
-- all the data it contains will also be deleted.

-- mariadb (implicit cascade)
-- drop schema ami_rel_model;
-- postgres
-- drop schema ami_rel_model CASCADE;

create schema if not exists ami_rel_model;


-- Variant 'a'

create table if not exists ami_rel_model.rel_a_do_not_do_this_without_a_very_good_reason
(
    id           int          null,
    model        varchar(100) null,
    name         varchar(100) null,
    employee_ids varchar(100) null,
    car_ids      varchar(100) null
);

insert into ami_rel_model.rel_a_do_not_do_this_without_a_very_good_reason (id, model, name, employee_ids, car_ids)
values  (12, 'VW-Up', null, '23,24,25', null),
        (14, 'BWM-i9', null, '24,25', null),
        (23, null, 'Jens', null, '12'),
        (24, null, 'Mary', null, '12,14'),
        (25, null, 'Alice', null, '12,14');


-- Variant 'b'

create table if not exists ami_rel_model.rel_b_nxm_car
(
    id    int          null,
    model varchar(100) null
);
create table if not exists ami_rel_model.rel_b_nxm_employee
(
    id   int          null,
    name varchar(100) null
);
-- Here choose an extra id or combine both ids to make a valid primary key.
create table if not exists ami_rel_model.rel_b_nxm_driven_by_always_works
(
    employee_id int null,
    car_id      int null
);

insert into ami_rel_model.rel_b_nxm_car (id, model)
values  (12, 'VW-Up'),
        (14, 'BMW-i9');
insert into ami_rel_model.rel_b_nxm_employee (id, name)
values  (23, 'Jens'),
        (24, 'Mary'),
        (25, 'Alice');
insert into ami_rel_model.rel_b_nxm_driven_by_always_works (employee_id, car_id)
values  (25, 12),
        (25, 14),
        (23, 12),
        (24, 12),
        (24, 14);
-- This is a preview of a 'view'.
create view if not exists ami_rel_model.rel_b_show_me_who_drives_what as
    select E.name, C.model from ami_rel_model.rel_b_nxm_driven_by_always_works R
    join ami_rel_model.rel_b_nxm_employee E on R.employee_id=E.id
    join ami_rel_model.rel_b_nxm_car C on R.car_id=C.id;


-- Variant 'c'

create table if not exists ami_rel_model.rel_c_1xn_car
(
    id    int          null,
    model varchar(100) null
);
create table if not exists ami_rel_model.rel_c_1xn_employee
(
    id               int          null,
    name             varchar(100) null,
    car_id_driven_by int          null
);

insert into ami_rel_model.rel_c_1xn_car (id, model)
values  (12, 'VW-Up'),
        (14, 'BMW-i9');
insert into ami_rel_model.rel_c_1xn_employee (id, name, car_id_driven_by)
values  (23, 'Jens', 12),
        (24, 'Mary', 12),
        (25, 'Alice', 14);


-- Variant 'd'

create table if not exists ami_rel_model.rel_d_1x1_car_employee_combined
(
    id    int          null,
    name  varchar(100) null,
    model varchar(100) null
);

insert into ami_rel_model.rel_d_1x1_car_employee_combined (id, name, model)
values  (1, 'Jens', 'VW-Up'),
        (2, 'Alice', 'BMW-i9');

