# Database Module

SQL lab of the Databases module, FH Aachen. All scripts are written for **PostgreSQL 18**.

## Quickstart

```bash
git clone https://github.com/codebasedlearning/database_course.git
cd database_course
docker compose -f docker/compose.yml up -d      # or: podman compose ...
```

On the first start the sample schemas from [preparation](./preparation) are loaded automatically.
Then connect with DataGrip (or any other client, e.g. pgAdmin or psql):

| Host      | Port | User | Password | Database |
|-----------|------|------|----------|----------|
| localhost | 5438 | root | root     | postgres |

Stop the DBMS with `docker compose -f docker/compose.yml down`; your data stays in the folder `postgres_data`.
To start from scratch, stop the DBMS and delete `postgres_data`, or simply run a preparation script again
(each one re-creates its schema).

Details: [installation guide](./docs/datenbanken_wise202526_installation_dbms.pdf).

## Content

- Sample data in [preparation](./preparation)
  - `ami_zone` – the main example, a small company with HR, assets and a shop
  - `ami_kemper` – the university example from Kemper/Eickler, Datenbanksysteme (used in exams)
  - `ami_algebra` – two minimal relations R and S for the relational algebra
  - `ami_rel_model` – variants of modelling relationships (1:1, 1:n, n:m)
- SQL training per unit in [exercises](./exercises), slides in the [SQL training](./docs/datenbanken_wise202526_sql_training.pdf)
- Proposed solutions in [proposed_solutions](./exercises/proposed_solutions)

| Unit | Topic                             | Schema                   |
|------|-----------------------------------|--------------------------|
| 0x01 | Selection & projection            | ami_zone                 |
| 0x02 | Joins                             | ami_zone, ami_kemper     |
| 0x03 | Group functions                   | ami_zone                 |
| 0x04 | Subselects                        | ami_zone                 |
| 0x05 | Schemas and tables                | ami_example, ami_sport   |
| 0x06 | Date/time, views, transactions    | ami_zone, ami_example    |
| 0x07 | Insert, update, delete            | ami_sport (from 0x05)    |
| 0x08 | Functions, procedures, triggers   | ami_zone                 |

Units 0x06 and 0x07 build on schemas created in unit 0x05 (`ami_sport` is created in task 5.1/5.2).

## Checking the scripts

`tests/check_sql.py` runs all scripts in course order and reports unexpected errors. Statements that are
supposed to fail (to demonstrate an error) are marked with a `-- expect-error` comment. The check also runs
on GitHub for every push.

```bash
PGHOST=localhost PGPORT=5438 PGUSER=root PGPASSWORD=root PGDATABASE=postgres python3 tests/check_sql.py
```

Caution: this re-creates the sample schemas in your database.

## Comments

Please feel free to send constructive comments and additions to [me](mailto:info@codebasedlearning.dev).
