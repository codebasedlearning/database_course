#!/usr/bin/env python3
# (C) A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev
"""
Runs all course scripts against a PostgreSQL server, in course order, and checks that

  - no statement fails unexpectedly, and
  - every statement marked with a '-- expect-error' comment really fails
    (so a demo of an error does not silently stop demonstrating it).

A marker applies to the next statement, e.g.

    -- expect-error: name is too long
    INSERT INTO pet ... ;

Connection: the usual libpq environment variables (PGHOST, PGPORT, PGUSER,
PGPASSWORD, PGDATABASE), e.g. for the course container:

    PGHOST=localhost PGPORT=5438 PGUSER=root PGPASSWORD=root PGDATABASE=postgres python3 tests/check_sql.py

Caution: the preparation scripts re-create the ami_* schemas, i.e. your own
changes in these schemas are lost.
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# order matters: later units build on schemas created by earlier ones
FILES = [
    "preparation/db_create_ami_algebra.sql",
    "preparation/db_create_ami_kemper.sql",
    "preparation/db_create_ami_rel_model.sql",
    "preparation/db_create_ami_zone.sql",
    "exercises/db_explain_algebra.sql",
    "exercises/db_training_0x01.sql",
    "exercises/proposed_solutions/db_solution_0x01.sql",
    "exercises/db_training_0x02.sql",
    "exercises/proposed_solutions/db_solution_0x02.sql",
    "exercises/db_training_0x03.sql",
    "exercises/proposed_solutions/db_solution_0x03.sql",
    "exercises/db_training_0x04.sql",
    "exercises/proposed_solutions/db_solution_0x04.sql",
    "exercises/db_training_0x05.sql",
    "exercises/proposed_solutions/db_solution_0x05.sql",   # creates ami_sport
    "exercises/db_training_0x06.sql",
    "exercises/proposed_solutions/db_solution_0x06.sql",
    "exercises/db_training_0x07.sql",
    "exercises/proposed_solutions/db_solution_0x07.sql",
    "exercises/db_training_0x08.sql",
    "exercises/proposed_solutions/db_solution_0x08.sql",
]

MARKER = "-- expect-error"
ERROR_RE = re.compile(r"^psql:(?P<file>.+?):(?P<line>\d+): ERROR:\s+(?P<msg>.*)$")


def statements(path: Path):
    """Yield (first_line, last_line, expects_error) for each statement (1-based lines).

    A small scanner, good enough for the course scripts: it knows line and block
    comments, string literals and $$ bodies, so semicolons inside them are ignored.
    """
    start = None
    expects = False
    in_block = in_dollar = in_string = False
    for no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if line.strip().startswith(MARKER) and not in_block:
            expects = True
        i, code = 0, False
        while i < len(line):
            two = line[i:i + 2]
            ch = line[i]
            if in_block:
                if two == "*/":
                    in_block, i = False, i + 2
                    continue
            elif in_dollar:
                code = True
                if two == "$$":
                    in_dollar, i = False, i + 2
                    continue
            elif in_string:
                code = True
                if ch == "'":
                    in_string = False
            elif two == "--":
                break
            elif two == "/*":
                in_block, i = True, i + 2
                continue
            elif two == "$$":
                in_dollar, code, i = True, True, i + 2
                continue
            elif ch == "'":
                in_string = code = True
            elif ch == ";":
                if start is None:
                    start = no
                yield start, no, expects
                start, expects, code = None, False, False
            elif not ch.isspace():
                code = True
            i += 1
        if code and start is None:
            start = no


def check(rel: str) -> list[str]:
    path = ROOT / rel
    stmts = list(statements(path))
    proc = subprocess.run(
        ["psql", "-X", "-q", "-v", "ON_ERROR_STOP=0", "-f", rel],
        cwd=ROOT, capture_output=True, text=True,
    )
    failed = {}
    for line in proc.stderr.splitlines():
        m = ERROR_RE.match(line)
        if m:
            failed[int(m["line"])] = m["msg"]
    if proc.returncode not in (0, 3):     # 3 = script error, handled below
        return [f"{rel}: psql failed ({proc.returncode}): {proc.stderr.strip()[:300]}"]

    problems = []
    ends = {end: (first, expects) for first, end, expects in stmts}
    for line, msg in sorted(failed.items()):
        first, expects = ends.get(line, (line, False))
        if not expects:
            problems.append(f"{rel}:{first}-{line}: unexpected error: {msg}")
    for first, end, expects in stmts:
        if expects and end not in failed:
            problems.append(f"{rel}:{first}-{end}: marked '{MARKER}' but succeeded")
    return problems


def main() -> int:
    problems = []
    for rel in FILES:
        found = check(rel)
        print(f"{'ok  ' if not found else 'FAIL'} {rel}")
        problems += found
    if problems:
        print("\n" + "\n".join(problems))
        return 1
    print("\nall scripts ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
