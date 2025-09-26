-- (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


-- -- ami_kemper -- --


-- Be careful here, because if you delete the schema,
-- all the data it contains will also be deleted.

-- mariadb (implicit cascade)
-- drop schema ami_kemper;
-- postgres
-- drop schema ami_kemper CASCADE;

create schema if not exists ami_kemper;

create table if not exists ami_kemper.Professoren
(
    PersNr   int         not null,
    Name     varchar(30) not null,
    Rang     varchar(10) not null,
    Standort varchar(20) not null,
    Raum     int         null
);

create table if not exists ami_kemper.Studenten
(
    MatrNr   int         not null,
    Name     varchar(30) not null,
    Semester int         not null
);

create table if not exists ami_kemper.Vorlesungen
(
    VorlNr     int         not null,
    Titel      varchar(30) not null,
    SWS        int         not null,
    gelesenVon int         null,
    primary key (VorlNr)
);

create table if not exists ami_kemper.Assistenten
(
    PersNr     int         not null,
    Name       varchar(30) not null,
    Fachgebiet varchar(30) not null,
    Boss       int         null,
    primary key (PersNr)
);

create table if not exists ami_kemper.hoeren
(
    MatrNr int      not null,
    VorlNr int      not null,
    primary key (MatrNr, VorlNr)
);

create table if not exists ami_kemper.pruefen
(
    MatrNr int           not null,
    VorlNr int           not null,
    PersNr int           not null,
    Note   decimal(2, 1) null,
    primary key (MatrNr, VorlNr, PersNr)
);

create table if not exists ami_kemper.voraussetzen
(
    Vorgaenger int      not null,
    Nachfolger int      not null,
    primary key (Vorgaenger, Nachfolger)
);

insert into ami_kemper.Professoren (PersNr, Name, Rang, Standort, Raum)
values  (2125, 'Sokrates', 'C4', 'Jülich', 226),
        (2126, 'Russel', 'C4', 'Jülich', 232),
        (2127, 'Kopernikus', 'C3', 'Aachen', 310),
        (2133, 'Popper', 'C3', 'Aachen', 52),
        (2134, 'Augustinus', 'C3', 'Aachen', 309),
        (2136, 'Curie', 'C4', 'Jülich', 36),
        (2137, 'Kant', 'C4', 'Jülich', 7);

insert into ami_kemper.Studenten (MatrNr, Name, Semester)
values  (24002, 'Xenokrates', 18),
        (25403, 'Jonas', 12),
        (26120, 'Fichte', 10),
        (26830, 'Aristoxenos', 8),
        (27550, 'Schopenhauer', 6),
        (28106, 'Carnap', 3),
        (29120, 'Theophrastos', 2),
        (29555, 'Feuerbach', 2);

insert into ami_kemper.Vorlesungen (VorlNr, Titel, SWS, gelesenVon)
values  (4052, 'Logik', 4, 2125),
        (4630, 'Die 3 Kritiken', 4, 2137),
        (5001, 'Grundzuege', 4, 2125),
        (5022, 'Glaube und Wissen', 2, 2134),
        (5041, 'Ethik', 4, 2125),
        (5043, 'Erkenntnistheorie', 3, 2126),
        (5049, 'Maeeutik', 2, 2125),
        (5052, 'Wissenschaftstheorie', 3, 2126),
        (5216, 'Bioethik', 2, 2126),
        (5259, 'Der Wiener Kreis', 2, 2133);

insert into ami_kemper.Assistenten (PersNr, Name, Fachgebiet, Boss)
values  (3002, 'Platon', 'Ideenlehre', 2125),
        (3003, 'Aristoteles', 'Syllogistik', 2125),
        (3004, 'Wittgenstein', 'Sprachtheorie', 2126),
        (3005, 'Rhetikus', 'Planetenbewegung', 2127),
        (3006, 'Newton', 'Keplersche Gesetze', 2127),
        (3007, 'Spinoza', 'Gott und Natur', 2134);

insert into ami_kemper.hoeren (MatrNr, VorlNr)
values  (25403, 5022),
        (26120, 5001),
        (27550, 4052),
        (27550, 5001),
        (28106, 5041),
        (28106, 5052),
        (28106, 5216),
        (28106, 5259),
        (29120, 4052),
        (29120, 4630),
        (29120, 5001),
        (29120, 5041),
        (29120, 5049),
        (29555, 5001),
        (29555, 5022);

insert into ami_kemper.pruefen (MatrNr, VorlNr, PersNr, Note)
values  (24002, 5041, 2125, 3.0),
        (25403, 5041, 2125, 2.0),
        (27550, 4630, 2137, 2.0),
        (28106, 5001, 2126, 1.0),
        (29555, 5041, 2125, 4.0);

insert into ami_kemper.voraussetzen (Vorgaenger, Nachfolger)
values  (5001, 5041),
        (5001, 5043),
        (5001, 5049),
        (5041, 5052),
        (5041, 5216),
        (5043, 5052),
        (5052, 5259);

-- -- ami_kemper done -- --
