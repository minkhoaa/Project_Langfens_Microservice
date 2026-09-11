#!/usr/bin/env python3
"""
Sprint 3 — Shift 0-indexed numeric jsonb keys +1 in completion-family rows.

Connection parameters (all overridable via env var; defaults shown match
the Docker Compose ports documented in repo root CLAUDE.md):

  exam-db (postgres):
    host     = DB_HOST              (default: localhost)
    port     = EXAM_DB_PORT         (default: 5433  — compose; live = 32779)
    user     = EXAM_DB_USER         (default: exam)
    password = EXAM_DB_PASSWORD     (default: exam)
    dbname   = EXAM_DB_NAME         (default: exam-db)

  attempt-db (postgres):
    host     = DB_HOST              (default: localhost)
    port     = ATTEMPT_DB_PORT      (default: 5435  — compose; live = 32780)
    user     = ATTEMPT_DB_USER      (default: attempt)
    password = ATTEMPT_DB_PASSWORD  (default: attempt)
    dbname   = ATTEMPT_DB_NAME      (default: attempt-db)

Run against the live Docker containers:

    EXAM_DB_PORT=32779 ATTEMPT_DB_PORT=32780 \\
        python3 scripts/migrate_blank_keys_to_1_indexed.py

Run against compose (default ports already match):

    python3 scripts/migrate_blank_keys_to_1_indexed.py

This script is one-shot and idempotent: it only shifts rows that ACTUALLY
contain the literal jsonb key "0" (true 0-indexed). Rows already on 1+ are
left alone. Verified against the live DB: exam-db and attempt-db currently
have ZERO rows containing key "0", so both migrations are no-ops today.
The script remains useful for any future state where 0-idx rows are
introduced (e.g. re-seeded legacy fixtures).
"""
import os
import sys
import psycopg2


def _conn_params(defaults: dict) -> dict:
    return {
        "host":     os.environ.get("DB_HOST", defaults["host"]),
        "port":     int(os.environ.get(defaults["port_env"], defaults["port"])),
        "user":     os.environ.get(defaults["user_env"], defaults["user"]),
        "password": os.environ.get(defaults["password_env"], defaults["password"]),
        "dbname":   os.environ.get(defaults["dbname_env"], defaults["dbname"]),
    }


def run_exam_db():
    conn = psycopg2.connect(**_conn_params({
        "host":         "localhost",
        "port":         5433,
        "port_env":     "EXAM_DB_PORT",
        "user":         "exam",
        "user_env":     "EXAM_DB_USER",
        "password":      "exam",
        "password_env": "EXAM_DB_PASSWORD",
        "dbname":       "exam-db",
        "dbname_env":   "EXAM_DB_NAME",
    }))
    conn.autocommit = False
    cur = conn.cursor()
    try:
        # ---- Pre-count ----
        cur.execute("""
            SELECT COUNT(*) FROM exam_questions
            WHERE "BlankAcceptTexts" IS NOT NULL
              AND jsonb_typeof("BlankAcceptTexts") = 'object'
              AND "BlankAcceptTexts" ? '0';
        """)
        pre_texts = cur.fetchone()[0]
        cur.execute("""
            SELECT COUNT(*) FROM exam_questions
            WHERE "BlankAcceptRegex" IS NOT NULL
              AND jsonb_typeof("BlankAcceptRegex") = 'object'
              AND "BlankAcceptRegex" ? '0';
        """)
        pre_regex = cur.fetchone()[0]

        # ---- Pre-sample ----
        cur.execute("""
            SELECT "Id", "Type", "BlankAcceptTexts"
            FROM exam_questions
            WHERE "BlankAcceptTexts" IS NOT NULL
              AND jsonb_typeof("BlankAcceptTexts") = 'object'
              AND "BlankAcceptTexts" ? '0'
            LIMIT 3;
        """)
        pre_samples = cur.fetchall()

        # ---- Update BlankAcceptTexts ----
        cur.execute("""
            UPDATE exam_questions
            SET "BlankAcceptTexts" =
              (SELECT jsonb_object_agg((key::int + 1)::text, value)
               FROM jsonb_each("BlankAcceptTexts"))
            WHERE "BlankAcceptTexts" IS NOT NULL
              AND jsonb_typeof("BlankAcceptTexts") = 'object'
              AND "BlankAcceptTexts" ? '0';
        """)

        # ---- Update BlankAcceptRegex ----
        cur.execute("""
            UPDATE exam_questions
            SET "BlankAcceptRegex" =
              (SELECT jsonb_object_agg((key::int + 1)::text, value)
               FROM jsonb_each("BlankAcceptRegex"))
            WHERE "BlankAcceptRegex" IS NOT NULL
              AND jsonb_typeof("BlankAcceptRegex") = 'object'
              AND "BlankAcceptRegex" ? '0';
        """)

        # ---- Post-count ----
        cur.execute("""
            SELECT COUNT(*) FROM exam_questions
            WHERE "BlankAcceptTexts" IS NOT NULL
              AND jsonb_typeof("BlankAcceptTexts") = 'object'
              AND "BlankAcceptTexts" ? '0';
        """)
        post_texts = cur.fetchone()[0]
        cur.execute("""
            SELECT COUNT(*) FROM exam_questions
            WHERE "BlankAcceptRegex" IS NOT NULL
              AND jsonb_typeof("BlankAcceptRegex") = 'object'
              AND "BlankAcceptRegex" ? '0';
        """)
        post_regex = cur.fetchone()[0]

        conn.commit()
        print("=== exam-db BlankAcceptTexts / BlankAcceptRegex ===")
        print(f"pre_texts_with_key_0: {pre_texts}")
        print(f"pre_regex_with_key_0: {pre_regex}")
        print(f"post_texts_with_key_0: {post_texts}")
        print(f"post_regex_with_key_0: {post_regex}")
        if pre_samples:
            print("pre_sample (rows containing key 0):")
            for r in pre_samples:
                print(f"  id={r[0]} type={r[1]} BlankAcceptTexts={r[2]}")
        else:
            print("pre_sample: <no rows containing key '0'>")
    except Exception as e:
        conn.rollback()
        print(f"exam-db FAILED: {e}", file=sys.stderr)
        raise
    finally:
        cur.close()
        conn.close()


def run_attempt_db():
    conn = psycopg2.connect(**_conn_params({
        "host":         "localhost",
        "port":         5435,
        "port_env":     "ATTEMPT_DB_PORT",
        "user":         "attempt",
        "user_env":     "ATTEMPT_DB_USER",
        "password":      "attempt",
        "password_env": "ATTEMPT_DB_PASSWORD",
        "dbname":       "attempt-db",
        "dbname_env":   "ATTEMPT_DB_NAME",
    }))
    conn.autocommit = False
    cur = conn.cursor()
    try:
        # Only target rows whose TextAnswer JSON contains literal key "0".
        cur.execute("""
            SELECT COUNT(*) FROM attempt_answer
            WHERE "TextAnswer" LIKE '{%}%'
              AND "TextAnswer"::jsonb ? '0';
        """)
        pre = cur.fetchone()[0]

        cur.execute("""
            UPDATE attempt_answer
            SET "TextAnswer" =
              (SELECT jsonb_object_agg((key::int + 1)::text, value)
               FROM jsonb_each("TextAnswer"::jsonb))::text
            WHERE "TextAnswer" LIKE '{%}%'
              AND "TextAnswer"::jsonb ? '0';
        """)

        cur.execute("""
            SELECT COUNT(*) FROM attempt_answer
            WHERE "TextAnswer" LIKE '{%}%'
              AND "TextAnswer"::jsonb ? '0';
        """)
        post = cur.fetchone()[0]

        conn.commit()
        print("=== attempt-db attempt_answer.TextAnswer ===")
        print(f"pre_with_key_0: {pre}")
        print(f"post_with_key_0: {post}")
    except Exception as e:
        conn.rollback()
        print(f"attempt-db FAILED: {e}", file=sys.stderr)
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    run_exam_db()
    run_attempt_db()
    print("OK")
