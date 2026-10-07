# Check

## Checking the scripts

`tests/check_sql.py` runs all scripts in course order and reports unexpected errors. Statements that are
supposed to fail (to demonstrate an error) are marked with a `-- expect-error` comment. The check also runs
on GitHub for every push.

```bash
PGHOST=localhost PGPORT=5438 PGUSER=root PGPASSWORD=root PGDATABASE=postgres python3 tests/check_sql.py
```

Caution: this re-creates the sample schemas in your database.
