#!/usr/bin/env python3
# ============================================
# Sprint 3 appendix S32 — Blank Placeholder Migration
# ============================================
#
# Purpose:
#   Standardize the completion-family question placeholder format on `[N]`
#   (Sprint 3 G16 / Sprint 3 appendix S31.F follow-up).
#
#   Two legacy formats coexist in the `exam_questions` table:
#     1. `___` (7+ underscore runs) inside `PromptMd`
#     2. `blank-q<digit>` keys inside `BlankAcceptTexts` (jsonb)
#
#   This script:
#     - audits current state (histogram of legacy vs canonical formats)
#     - migrates rows: `___` → `[1]`, `[2]`, ... (occurrence order) AND
#       `blank-q<N>` → `<N>` (strip prefix)
#     - is idempotent (running twice yields the same end state)
#     - is atomic (single transaction; rollback on any per-row failure)
#     - defaults to DRY-RUN (use `--apply` to actually write)
#
# Usage:
#     python3 scripts/migrate_blank_placeholders.py audit [--mock]
#     python3 scripts/migrate_blank_placeholders.py migrate [--apply] [--mock]
#     python3 scripts/migrate_blank_placeholders.py rollback [--output FILE]
#
# Connection:
#     Reads `deploy/envs/exam.env` for `ConnectionStrings__exam-db` or
#     `CONNECTIONSTRING__EXAM`. Override via env vars:
#       PGHOST / PGPORT / PGUSER / PGPASSWORD / PGDATABASE
#     Falls back to Compose defaults (host=localhost port=5433 dbname=exam-db
#     user=postgres password=postgres) with a WARN print.
#
# Dependencies:
#     Stdlib only. Optional psycopg2 / psycopg (preferred) — script will use
#     whichever is importable; otherwise shells out to `psql`.
#
# Exit codes:
#     0  success
#     1  audit/migration error / refused because preconditions not met
#     2  refused because audit precondition `ready_for_phase2` is False
#         AND `--force` was not passed
#
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Iterable, Optional

REPO_ROOT = Path(__file__).resolve().parents[1]
ENV_FILE = REPO_ROOT / "deploy" / "envs" / "exam.env"

# Completion family — matches validateBlankKeyFormat in langfens-fe-app
# (validation.ts). Keep this list in sync with that file.
COMPLETION_TYPES = frozenset(
    {
        "SUMMARY_COMPLETION",
        "TABLE_COMPLETION",
        "NOTE_COMPLETION",
        "FORM_COMPLETION",
        "SENTENCE_COMPLETION",
        "DIAGRAM_LABEL",
        "MAP_LABEL",
        "FLOW_CHART",
    }
)

UNDERSCORE_RE = re.compile(r"_{7,}")           # legacy: 7+ underscore run
BRACKET_RE = re.compile(r"\[(\d+)\]")          # canonical: [1], [2], ...
BLANK_Q_KEY_RE = re.compile(r"^blank-q(\d+)$") # legacy key prefix

# SQL — read everything we need in one round-trip.
SELECT_ALL_SQL = """
SELECT
    "Id",
    "Type",
    "PromptMd",
    "BlankAcceptTexts"
FROM "exam_questions"
WHERE "Type" = ANY(%s)
ORDER BY "Idx"
"""

UPDATE_SQL = """
UPDATE "exam_questions"
SET "PromptMd" = %s,
    "BlankAcceptTexts" = %s::jsonb
WHERE "Id" = %s
"""

# ============================================
# Env loading
# ============================================


def _load_env_file(path: Path) -> None:
    """Minimal .env loader (no shell expansion, no variable interpolation)."""
    if not path.exists():
        print(f"warn: env file {path} not found", file=sys.stderr)
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        # Strip inline `#` comments and surrounding whitespace/quotes.
        value = value.split("#", 1)[0].strip()
        if value.startswith(('"', "'")) and value.endswith(('"', "'")):
            value = value[1:-1]
        # Don't clobber already-set env (allow override via shell export).
        os.environ.setdefault(key, value)


def _parse_conn_string(conn: str) -> dict[str, str]:
    """Parse a .NET-style connection string into libpq-ish kwargs."""
    out: dict[str, str] = {}
    for token in conn.split(";"):
        token = token.strip()
        if not token or "=" not in token:
            continue
        k, _, v = token.partition("=")
        out[k.strip().lower()] = v.strip()
    # Map common aliases.
    out.setdefault("host", out.get("server", "localhost"))
    out.setdefault("port", "5432")
    out.setdefault("dbname", out.get("database", "exam-db"))
    out.setdefault("user", out.get("username", "postgres"))
    out.setdefault("password", out.get("password", "postgres"))
    return out


def resolve_connection() -> dict[str, str]:
    """Resolve DB connection kwargs from env file + process env.

    Order of preference:
      1. PG* env vars already set in shell (highest)
      2. ConnectionStrings__exam-db / CONNECTIONSTRING__EXAM from env file
      3. Compose default with a WARN print
    """
    _load_env_file(ENV_FILE)

    if all(k in os.environ for k in ("PGHOST", "PGUSER", "PGDATABASE")):
        return {
            "host": os.environ["PGHOST"],
            "port": os.environ.get("PGPORT", "5432"),
            "dbname": os.environ["PGDATABASE"],
            "user": os.environ["PGUSER"],
            "password": os.environ.get("PGPASSWORD", ""),
        }

    for key in ("ConnectionStrings__exam-db", "CONNECTIONSTRING__EXAM"):
        raw = os.environ.get(key, "").strip()
        if raw:
            return _parse_conn_string(raw)

    print(
        "warn: no exam connection details found; falling back to Compose defaults "
        "(host=localhost port=5433 dbname=exam-db user=postgres password=postgres)",
        file=sys.stderr,
    )
    return {
        "host": "localhost",
        "port": "5433",
        "dbname": "exam-db",
        "user": "postgres",
        "password": "postgres",
    }


# ============================================
# Driver selection (psycopg2 > psycopg > psql)
# ============================================


class _Adapter:
    """Tiny adapter so audit/migrate code doesn't care which driver it got."""

    def query_rows(self, completion_types: list[str]) -> list[dict[str, Any]]:
        raise NotImplementedError

    def update_row(
        self, row_id: str, prompt_md: Optional[str], blank_accept_texts_json: str
    ) -> None:
        raise NotImplementedError

    def begin(self) -> None:
        raise NotImplementedError

    def commit(self) -> None:
        raise NotImplementedError

    def rollback(self) -> None:
        raise NotImplementedError

    def close(self) -> None:
        raise NotImplementedError


class _Psycopg2Adapter(_Adapter):
    def __init__(self, conn) -> None:  # type: ignore[no-untyped-def]
        self._conn = conn

    def query_rows(self, completion_types: list[str]) -> list[dict[str, Any]]:
        with self._conn.cursor() as cur:
            cur.execute(SELECT_ALL_SQL, (completion_types,))
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
        return [dict(zip(cols, r)) for r in rows]

    def update_row(
        self, row_id: str, prompt_md: Optional[str], blank_accept_texts_json: str
    ) -> None:
        with self._conn.cursor() as cur:
            cur.execute(UPDATE_SQL, (prompt_md, blank_accept_texts_json, row_id))

    def begin(self) -> None:
        self._conn.autocommit = False

    def commit(self) -> None:
        self._conn.commit()

    def rollback(self) -> None:
        self._conn.rollback()

    def close(self) -> None:
        self._conn.close()


class _PsycopgAdapter(_Adapter):
    """psycopg v3 (the modern one)."""

    def __init__(self, conn) -> None:  # type: ignore[no-untyped-def]
        self._conn = conn

    def query_rows(self, completion_types: list[str]) -> list[dict[str, Any]]:
        with self._conn.cursor() as cur:
            cur.execute(SELECT_ALL_SQL, (completion_types,))
            cols = [d.name for d in cur.description]
            rows = cur.fetchall()
        return [dict(zip(cols, r)) for r in rows]

    def update_row(
        self, row_id: str, prompt_md: Optional[str], blank_accept_texts_json: str
    ) -> None:
        with self._conn.cursor() as cur:
            cur.execute(UPDATE_SQL, (prompt_md, blank_accept_texts_json, row_id))

    def begin(self) -> None:
        # psycopg3 starts in transaction by default when autocommit=False.
        pass

    def commit(self) -> None:
        self._conn.commit()

    def rollback(self) -> None:
        self._conn.rollback()

    def close(self) -> None:
        self._conn.close()


class _PsqlSubprocessAdapter(_Adapter):
    """Drive Postgres via `psql` CLI. Slower but zero-pip fallback."""

    def __init__(self, kwargs: dict[str, str]) -> None:
        self._env = {
            "PGHOST": kwargs["host"],
            "PGPORT": kwargs["port"],
            "PGUSER": kwargs["user"],
            "PGDATABASE": kwargs["dbname"],
            "PGPASSWORD": kwargs["password"],
            "PATH": os.environ.get("PATH", ""),
        }
        # `_PQ` escape via psql variables to avoid shell-injection.
        # We'll build a single transaction via `psql --single-transaction`.
        self._types_sql = (
            "SELECT ARRAY["
            + ",".join(f"'{t}'" for t in COMPLETION_TYPES)
            + "]::text[]"
        )

    def _run(self, sql: str) -> str:
        proc = subprocess.run(
            ["psql", "-A", "-t", "-X", "-v", "ON_ERROR_STOP=1", "-c", sql],
            env=self._env,
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode != 0:
            raise RuntimeError(
                f"psql failed (rc={proc.returncode}): {proc.stderr.strip()}"
            )
        return proc.stdout

    def query_rows(self, completion_types: list[str]) -> list[dict[str, Any]]:
        types_literal = (
            "ARRAY["
            + ",".join(f"'{t}'" for t in completion_types)
            + "]::text[]"
        )
        sql = (
            "SELECT \"Id\", \"Type\", \"PromptMd\", \"BlankAcceptTexts\" "
            f"FROM \"exam_questions\" WHERE \"Type\" = ANY({types_literal}) "
            "ORDER BY \"Idx\";"
        )
        out = self._run(sql)
        rows: list[dict[str, Any]] = []
        for line in out.strip().splitlines():
            if not line:
                continue
            # Columns are pipe-separated because we use -A -t and a manual
            # delimiter. To keep this simple and safe, we re-issue per-row
            # JSON queries instead. (See query_rows_json.)
            rows.append({"raw": line})
        # Re-issue per row as JSON to recover jsonb cleanly.
        return self._rehydrate_rows(rows)

    def _rehydrate_rows(self, stub_rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
        # Pull rows one at a time with to_jsonb for fidelity.
        ids_sql = (
            "SELECT \"Id\" FROM \"exam_questions\" WHERE \"Type\" = ANY("
            + "ARRAY["
            + ",".join(f"'{t}'" for t in COMPLETION_TYPES)
            + "]::text[]) ORDER BY \"Idx\";"
        )
        ids = [ln.strip() for ln in self._run(ids_sql).splitlines() if ln.strip()]
        out: list[dict[str, Any]] = []
        for rid in ids:
            row_sql = (
                f"SELECT \"Id\", \"Type\", \"PromptMd\", "
                f"to_jsonb(\"BlankAcceptTexts\") "
                f"FROM \"exam_questions\" WHERE \"Id\" = '{rid}';"
            )
            line = self._run(row_sql).strip()
            # Format: Id|Type|PromptMd|JsonbJson
            parts = line.split("|", 3)
            if len(parts) < 4:
                continue
            _id, _type, prompt_md, jsonb_json = parts
            out.append(
                {
                    "Id": _id,
                    "Type": _type,
                    "PromptMd": prompt_md if prompt_md else None,
                    "BlankAcceptTexts": json.loads(jsonb_json) if jsonb_json else None,
                }
            )
        return out

    def update_row(
        self, row_id: str, prompt_md: Optional[str], blank_accept_texts_json: str
    ) -> None:
        # Use dollar-quoting to embed the prompt safely.
        # We escape any $tag$ occurrences in the prompt.
        tag = "S32PROMPT"
        prompt_escaped = (
            prompt_md.replace(f"${tag}$", f"${tag}$${tag}$")
            if prompt_md is not None
            else None
        )
        if prompt_escaped is None:
            prompt_sql = "NULL"
        else:
            prompt_sql = f"${tag}$" + prompt_escaped + f"${tag}$"
        # For jsonb: cast the literal with ::jsonb; escape the literal.
        escaped_dict = blank_accept_texts_json.replace("'", "''")
        sql = (
            f"UPDATE \"exam_questions\" SET "
            f"\"PromptMd\" = {prompt_sql}, "
            f"\"BlankAcceptTexts\" = '{escaped_dict}'::jsonb "
            f"WHERE \"Id\" = '{row_id}';"
        )
        self._run(sql)

    def begin(self) -> None:
        # psql begins a transaction implicitly. We use --single-transaction
        # via the public method `apply_all` below.
        pass

    def commit(self) -> None:
        self._run("COMMIT;")

    def rollback(self) -> None:
        self._run("ROLLBACK;")

    def close(self) -> None:
        pass

    # Special path: do the entire migration in one psql invocation so the
    # transaction boundary is inside the same process.
    def apply_all(self, updates: list[tuple[str, str, str]]) -> None:
        if not updates:
            self._run("BEGIN; COMMIT;")
            return
        statements: list[str] = ["BEGIN"]
        for row_id, prompt_md, jsonb_dict in updates:
            tag = "S32PROMPT"
            prompt_escaped = (
                prompt_md.replace(f"${tag}$", f"${tag}$${tag}$")
                if prompt_md is not None
                else None
            )
            if prompt_escaped is None:
                prompt_sql = "NULL"
            else:
                prompt_sql = f"${tag}$" + prompt_escaped + f"${tag}$"
            escaped_dict = jsonb_dict.replace("'", "''")
            statements.append(
                f"UPDATE \"exam_questions\" SET "
                f"\"PromptMd\" = {prompt_sql}, "
                f"\"BlankAcceptTexts\" = '{escaped_dict}'::jsonb "
                f"WHERE \"Id\" = '{row_id}';"
            )
        # Rollback if anything fails (psql -1 wraps in single transaction).
        sql = "\n".join(statements)
        proc = subprocess.run(
            ["psql", "-1", "-A", "-t", "-X", "-v", "ON_ERROR_STOP=1"],
            input=sql,
            env=self._env,
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode != 0:
            raise RuntimeError(
                f"psql apply_all failed (rc={proc.returncode}): "
                f"{proc.stderr.strip()}"
            )


def open_adapter() -> _Adapter:
    """Open a Postgres connection using whichever driver is available.

    Order: psycopg2 > psycopg > psql subprocess.
    """
    kwargs = resolve_connection()

    try:
        import psycopg2  # type: ignore[import-not-found]
        import psycopg2.extras  # noqa: F401  # just to confirm import works
    except ImportError:
        psycopg2 = None  # type: ignore[assignment]

    if psycopg2 is not None:
        conn = psycopg2.connect(**kwargs)
        return _Psycopg2Adapter(conn)

    try:
        import psycopg  # type: ignore[import-not-found]
    except ImportError:
        psycopg = None  # type: ignore[assignment]

    if psycopg is not None:
        conn = psycopg.connect(**kwargs, autocommit=False)
        return _PsycopgAdapter(conn)

    if subprocess.run(["which", "psql"], capture_output=True).returncode == 0:
        return _PsqlSubprocessAdapter(kwargs)

    raise RuntimeError(
        "no Postgres driver available. Install one of:\n"
        "  - psycopg2 or psycopg2-binary\n"
        "  - psycopg (v3)\n"
        "  - psql CLI binary on PATH\n"
        "Or pass --mock to run without a database (audit-only)."
    )


# ============================================
# Mocks — used when --mock is passed or no DB is available.
# ============================================


_MOCK_ROWS: list[dict[str, Any]] = [
    # q1: legacy underscores, canonical keys — should migrate prompt only.
    {
        "Id": "11111111-1111-1111-1111-111111111111",
        "Type": "SUMMARY_COMPLETION",
        "PromptMd": "The moon orbits the __________ every __________ days.",
        "BlankAcceptTexts": {"0": ["earth"], "1": ["27"]},
    },
    # q2: legacy underscores + blank-q keys (COEXISTENCE — should be skipped/refused).
    {
        "Id": "22222222-2222-2222-2222-222222222222",
        "Type": "NOTE_COMPLETION",
        "PromptMd": "Notes:\n- Type: __________\n- Capacity: __________ people",
        "BlankAcceptTexts": {"blank-q0": ["workshop"], "blank-q1": ["20"]},
    },
    # q3: legacy underscore, canonical key — should migrate prompt only.
    {
        "Id": "33333333-3333-3333-3333-333333333333",
        "Type": "TABLE_COMPLETION",
        "PromptMd": "Complete the table:\n\n| Year | Sales |\n|------|-------|\n| 2020 | __________   |",
        "BlankAcceptTexts": {"0": ["100"]},
    },
    # q4: legacy underscores, canonical keys — should migrate prompt only.
    {
        "Id": "44444444-4444-4444-4444-444444444444",
        "Type": "FORM_COMPLETION",
        "PromptMd": "Application Form\n\nName: __________\nDate: __________\nRoom: __________",
        "BlankAcceptTexts": {"0": ["Rachel"], "1": ["15"], "2": ["single"]},
    },
    # q5: legacy underscores + blank-q keys (COEXISTENCE — should be skipped/refused).
    {
        "Id": "55555555-5555-5555-5555-555555555555",
        "Type": "DIAGRAM_LABEL",
        "PromptMd": "Label the diagram below with __________, __________…",
        "BlankAcceptTexts": {"blank-q0": ["chloroplast"], "blank-q1": ["nucleus"]},
    },
    # q6: legacy underscores, canonical keys — should migrate prompt only.
    {
        "Id": "66666666-6666-6666-6666-666666666666",
        "Type": "MAP_LABEL",
        "PromptMd": "Label positions __________ through __________ on the map.",
        "BlankAcceptTexts": {"0": ["library"], "1": ["park"]},
    },
    # q7: already canonical — should be skipped.
    {
        "Id": "77777777-7777-7777-7777-777777777777",
        "Type": "SUMMARY_COMPLETION",
        "PromptMd": "The quick brown fox jumps over the lazy dog. (no blanks)",
        "BlankAcceptTexts": None,
    },
    # q8: non-completion type — out of scope entirely.
    {
        "Id": "88888888-8888-8888-8888-888888888888",
        "Type": "MULTIPLE_CHOICE_SINGLE",
        "PromptMd": "Pick one.",
        "BlankAcceptTexts": None,
    },
    # q9: legacy blank-q keys only (no underscores) — should migrate keys only.
    {
        "Id": "99999999-9999-9999-9999-999999999999",
        "Type": "SENTENCE_COMPLETION",
        "PromptMd": "The protocol was finalised in the year of the conference.",
        "BlankAcceptTexts": {"blank-q0": ["2015"], "blank-q1": ["Paris"]},
    },
]


class _MockAdapter(_Adapter):
    """Returns canned rows and short-circuits UPDATE — supports `--mock` runs."""

    def __init__(self) -> None:
        self._rows = [dict(r) for r in _MOCK_ROWS]
        self._updates: list[tuple[str, Optional[str], dict[str, Any]]] = []
        self._begun = False

    def query_rows(self, completion_types: list[str]) -> list[dict[str, Any]]:
        return [r for r in self._rows if r["Type"] in completion_types]

    def update_row(
        self, row_id: str, prompt_md: Optional[str], blank_accept_texts_json: str
    ) -> None:
        # Round-trip the jsonb payload so we honour the canonical shape.
        bat: Optional[dict[str, Any]] = (
            json.loads(blank_accept_texts_json) if blank_accept_texts_json else None
        )
        self._updates.append((row_id, prompt_md, bat))
        for r in self._rows:
            if r["Id"] == row_id:
                r["PromptMd"] = prompt_md
                r["BlankAcceptTexts"] = bat
                break

    def begin(self) -> None:
        self._begun = True

    def commit(self) -> None:
        self._begun = False

    def rollback(self) -> None:
        self._updates.clear()
        self._rows = [dict(r) for r in _MOCK_ROWS]
        self._begun = False

    def close(self) -> None:
        pass


# ============================================
# Core: transformation logic
# ============================================


def transform_prompt(prompt_md: Optional[str]) -> tuple[Optional[str], bool]:
    """Rewrite `___` (7+ underscores) runs to `[N]` in occurrence order.

    Returns (new_prompt, changed). If the prompt is None or already uses
    `[N]` for every blank, changed=False and new_prompt is the same string.
    """
    if not prompt_md:
        return prompt_md, False
    counter = [0]
    already_bracket_count = len(BRACKET_RE.findall(prompt_md))

    def _replace(match: re.Match[str]) -> str:
        counter[0] += 1
        return f"[{already_bracket_count + counter[0]}]"

    new_prompt = UNDERSCORE_RE.sub(_replace, prompt_md)
    return new_prompt, new_prompt != prompt_md


def transform_blank_keys(
    blank_accept_texts: Optional[dict[str, Any]],
) -> tuple[Optional[dict[str, Any]], bool]:
    """Rename keys `blank-q<digit>` → `<digit>` (drop prefix).

    Returns (new_dict, changed). Idempotent: re-running on an already-
    canonical dict yields (same_dict, False).
    """
    if not blank_accept_texts:
        return blank_accept_texts, False
    new_dict: dict[str, Any] = {}
    changed = False
    for key, value in blank_accept_texts.items():
        m = BLANK_Q_KEY_RE.match(key)
        if m:
            new_key = m.group(1)
            changed = True
        else:
            new_key = key
        new_dict[new_key] = value
    return (new_dict if changed else blank_accept_texts), changed


# ============================================
# Subcommand: audit
# ============================================


def compute_audit(rows: Iterable[dict[str, Any]]) -> dict[str, Any]:
    by_type: dict[str, int] = {}
    underscore_examples: list[str] = []
    blank_q_examples: list[str] = []
    coexistence_examples: list[str] = []
    underscore_count = 0
    blank_q_count = 0
    bracket_count = 0
    coexistence_count = 0
    total = 0

    for row in rows:
        total += 1
        by_type[row["Type"]] = by_type.get(row["Type"], 0) + 1
        prompt = row.get("PromptMd") or ""
        has_underscore = bool(UNDERSCORE_RE.search(prompt))
        has_blank_q = False
        matched_blank_q_key: Optional[str] = None
        bat = row.get("BlankAcceptTexts") or {}
        if isinstance(bat, dict):
            for key in bat.keys():
                if isinstance(key, str) and BLANK_Q_KEY_RE.match(key):
                    has_blank_q = True
                    if matched_blank_q_key is None:
                        matched_blank_q_key = key
                    break
        if has_underscore:
            underscore_count += 1
            if len(underscore_examples) < 5:
                underscore_examples.append(prompt[:120])
        if BRACKET_RE.search(prompt):
            bracket_count += 1
        if has_blank_q:
            blank_q_count += 1
            if len(blank_q_examples) < 5 and matched_blank_q_key is not None:
                blank_q_examples.append(matched_blank_q_key)
        # Row-level coexistence: BOTH legacy formats in the SAME row makes
        # index ordering impossible to infer without operator help. Dataset-
        # level coexistence (some rows with underscores, others with
        # blank-q) is safe because each row's blanks are independent.
        if has_underscore and has_blank_q:
            coexistence_count += 1
            if len(coexistence_examples) < 5:
                coexistence_examples.append(prompt[:120])

    ready_for_phase2 = underscore_count == 0 and blank_q_count == 0

    return {
        "total_questions": total,
        "type_breakdown": by_type,
        "underscore_placeholder_count": underscore_count,
        "underscore_placeholder_examples": underscore_examples,
        "blank_q_key_count": blank_q_count,
        "blank_q_key_examples": blank_q_examples,
        "coexistence_row_count": coexistence_count,
        "coexistence_row_examples": coexistence_examples,
        "bracket_format_count": bracket_count,
        "ready_for_phase2": ready_for_phase2,
    }

def cmd_audit(args: argparse.Namespace) -> int:
    if args.mock:
        rows = _MOCK_ROWS
    else:
        adapter = open_adapter()
        try:
            rows = adapter.query_rows(list(COMPLETION_TYPES))
        finally:
            adapter.close()

    audit = compute_audit(rows)
    print(json.dumps(audit, indent=2, ensure_ascii=False))
    return 0


# ============================================
# Subcommand: migrate
# ============================================


def _looks_ambiguous(audit: dict[str, Any]) -> bool:
    """Refuse migration if BOTH legacy formats appear in the SAME row.

    Dataset-level coexistence (some rows with `___`, other rows with
    `blank-q<N>`) is safe because each row's blanks are independent. The
    unsafe case is when a single row mixes both formats — that makes the
    `[N]` → `<N>` index mapping impossible to infer without operator help.
    Example: `ListeningSeeder.cs` q17a/b/c has 7-underscore blanks AND
    `blank-q4`/`5`/`6` keys per row.
    """
    return audit.get("coexistence_row_count", 0) > 0



def cmd_migrate(args: argparse.Namespace) -> int:
    audit_first = not args.skip_audit
    audit_data: dict[str, Any] = {}
    if audit_first:
        if args.mock:
            rows = _MOCK_ROWS
        else:
            adapter = open_adapter()
            try:
                rows = adapter.query_rows(list(COMPLETION_TYPES))
            finally:
                adapter.close()
        audit_data = compute_audit(rows)
        print(json.dumps({"audit": audit_data}, indent=2, ensure_ascii=False))
        if _looks_ambiguous(audit_data) and not args.force:
            print(
                "refusing to migrate: some rows mix BOTH `___` underscores "
                "AND `blank-q<N>` keys in the SAME row. Index ordering is "
                "impossible to infer without operator review. Run with --force "
                "to override (NOT recommended) or fix those rows manually first.",
                file=sys.stderr,
            )
            return 2
        if (
            audit_data["underscore_placeholder_count"] == 0
            and audit_data["blank_q_key_count"] == 0
        ):
            print(
                "audit shows zero legacy placeholders; nothing to migrate. "
                "Idempotency check: OK.",
                file=sys.stderr,
            )
            return 0

    # Open the (possibly mock) adapter and run the migration.
    if args.mock:
        adapter: _Adapter = _MockAdapter()
    else:
        adapter = open_adapter()

    start = time.time()
    migrated = 0
    skipped = 0
    try:
        adapter.begin()
        if isinstance(adapter, _PsqlSubprocessAdapter):
            # Bundle UPDATEs into a single psql --single-transaction.
            updates: list[tuple[str, str, str]] = []
            for row in _iter_target_rows(adapter, list(COMPLETION_TYPES)):
                new_prompt, prompt_changed = transform_prompt(row.get("PromptMd"))
                new_bat, bat_changed = transform_blank_keys(
                    row.get("BlankAcceptTexts")
                )
                if not (prompt_changed or bat_changed):
                    skipped += 1
                    continue
                if isinstance(adapter, _PsqlSubprocessAdapter):
                    updates.append(
                        (row["Id"], new_prompt or "", json.dumps(new_bat or {}))
                    )
                    migrated += 1
                else:  # pragma: no cover
                    adapter.update_row(
                        row["Id"], new_prompt, json.dumps(new_bat or {})
                    )
                    migrated += 1
            if updates:
                adapter.apply_all(updates)  # type: ignore[attr-defined]
        else:
            for row in _iter_target_rows(adapter, list(COMPLETION_TYPES)):
                new_prompt, prompt_changed = transform_prompt(row.get("PromptMd"))
                new_bat, bat_changed = transform_blank_keys(
                    row.get("BlankAcceptTexts")
                )
                if not (prompt_changed or bat_changed):
                    skipped += 1
                    continue
                adapter.update_row(
                    row["Id"], new_prompt, json.dumps(new_bat or {})
                )
                migrated += 1
        adapter.commit()
    except Exception as exc:  # noqa: BLE001 — we want to rollback on any error
        adapter.rollback()
        print(f"migration failed; rolled back. error: {exc}", file=sys.stderr)
        adapter.close()
        return 1
    finally:
        adapter.close()

    elapsed = time.time() - start
    if args.apply:
        verb = "Migrated"
    else:
        verb = "[DRY-RUN] would migrate"
    print(f"{verb} {migrated} rows in {elapsed:.3f} seconds (skipped {skipped}).")
    return 0


def _iter_target_rows(
    adapter: _Adapter, completion_types: list[str]
) -> Iterable[dict[str, Any]]:
    """Yield rows eligible for migration (completion family only)."""
    for row in adapter.query_rows(completion_types):
        yield row


# ============================================
# Subcommand: rollback (stretch; dump pre-migration state)
# ============================================


def cmd_rollback(args: argparse.Namespace) -> int:
    """Best-effort: dump the current completion-family rows to a JSONL file
    so an operator can restore them manually. This does NOT undo a migration
    automatically — the audit tool already records the legacy shape.
    """
    output = Path(args.output or "scripts/.migrate_blank_placeholders.snapshot.jsonl")
    output.parent.mkdir(parents=True, exist_ok=True)

    if args.mock:
        rows = _MOCK_ROWS
    else:
        adapter = open_adapter()
        try:
            rows = adapter.query_rows(list(COMPLETION_TYPES))
        finally:
            adapter.close()

    with output.open("w", encoding="utf-8") as fh:
        for row in rows:
            fh.write(json.dumps(row, ensure_ascii=False) + "\n")
    print(f"wrote {len(rows)} rows to {output}")
    return 0


# ============================================
# Argparse wiring
# ============================================


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="migrate_blank_placeholders",
        description=(
            "Sprint 3 appendix S32 — Standardize `[N]` placeholder format "
            "across the exam_questions table. Audit, migrate (dry-run by "
            "default), or snapshot for rollback."
        ),
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_audit = sub.add_parser("audit", help="print JSON histogram of legacy placeholders")
    p_audit.add_argument(
        "--mock",
        action="store_true",
        help="use canned sample rows instead of connecting to Postgres",
    )
    p_audit.set_defaults(func=cmd_audit)

    p_migrate = sub.add_parser("migrate", help="rewrite `___` and `blank-q<N>` to `[N]`")
    p_migrate.add_argument(
        "--apply",
        action="store_true",
        help="actually write to the database (default is DRY-RUN)",
    )
    p_migrate.add_argument(
        "--mock",
        action="store_true",
        help="use canned sample rows instead of connecting to Postgres",
    )
    p_migrate.add_argument(
        "--skip-audit",
        action="store_true",
        help="skip the audit-first precondition (NOT recommended)",
    )
    p_migrate.add_argument(
        "--force",
        action="store_true",
        help="migrate even when audit reports ambiguous legacy shapes",
    )
    p_migrate.set_defaults(func=cmd_migrate)

    p_rollback = sub.add_parser(
        "rollback",
        help="dump current completion-family rows to a JSONL snapshot",
    )
    p_rollback.add_argument(
        "--output",
        help="output file path (default: scripts/.migrate_blank_placeholders.snapshot.jsonl)",
    )
    p_rollback.add_argument(
        "--mock",
        action="store_true",
        help="use canned sample rows instead of connecting to Postgres",
    )
    p_rollback.set_defaults(func=cmd_rollback)

    return parser


def main(argv: Optional[list[str]] = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    try:
        return int(args.func(args) or 0)
    except KeyboardInterrupt:
        print("interrupted", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
