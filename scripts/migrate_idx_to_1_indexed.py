#!/usr/bin/env python3
"""
Sprint 6 — Migrate exam_sections, exam_questions, and exam_options from 0-indexed to 1-indexed Idx.

Target:
  exam-db (PostgreSQL)

Connection parameters (all overridable via env vars):
  PGHOST / DB_HOST: host (default: localhost)
  EXAM_DB_PORT / PGPORT: port (default: 32779 for live Aspire container, fallback 5433 for compose)
  PGUSER / EXAM_DB_USER: user (default: exam)
  PGPASSWORD / EXAM_DB_PASSWORD: password (default: exam)
  PGDATABASE / EXAM_DB_NAME: database name (default: exam-db)

Modes:
  1. Direct PostgreSQL connection via psycopg2 (default).
  2. --docker mode: executes commands via `docker exec <container> psql`.

Usage:
  python3 scripts/migrate_idx_to_1_indexed.py
  python3 scripts/migrate_idx_to_1_indexed.py --docker
"""

import argparse
import os
import subprocess
import sys

try:
    import psycopg2
except ImportError:
    psycopg2 = None

DOCKER_CONTAINER_DEFAULT = "exam-db-server-7c03dc93"


def get_db_config():
    pghost = os.getenv("PGHOST", os.getenv("DB_HOST", "localhost"))
    pgport = int(os.getenv("EXAM_DB_PORT", os.getenv("PGPORT", 32779)))
    pguser = os.getenv("PGUSER", os.getenv("EXAM_DB_USER", "exam"))
    pgpassword = os.getenv("PGPASSWORD", os.getenv("EXAM_DB_PASSWORD", "exam"))
    pgdatabase = os.getenv("PGDATABASE", os.getenv("EXAM_DB_NAME", "exam-db"))
    return {
        "host": pghost,
        "port": pgport,
        "user": pguser,
        "password": pgpassword,
        "database": pgdatabase,
    }


SQL_MUTATION = """
BEGIN;

-- 1. Shift Sections where the exam's sections start at 0
UPDATE exam_sections s
SET "Idx" = s."Idx" + 1
FROM (
    SELECT "ExamId"
    FROM exam_sections
    GROUP BY "ExamId"
    HAVING MIN("Idx") = 0
) zero_exams
WHERE s."ExamId" = zero_exams."ExamId";

-- 2. Shift Questions where the section's questions start at 0
UPDATE exam_questions q
SET "Idx" = q."Idx" + 1
FROM (
    SELECT "SectionId"
    FROM exam_questions
    GROUP BY "SectionId"
    HAVING MIN("Idx") = 0
) zero_sections
WHERE q."SectionId" = zero_sections."SectionId";

-- 3. Shift Options where the question's options start at 0
UPDATE exam_options o
SET "Idx" = o."Idx" + 1
FROM (
    SELECT "QuestionId"
    FROM exam_options
    GROUP BY "QuestionId"
    HAVING MIN("Idx") = 0
) zero_questions
WHERE o."QuestionId" = zero_questions."QuestionId";

COMMIT;
"""


def run_via_docker(container_name: str, cfg: dict):
    print(f"[Mode: Docker Exec] Container: {container_name}")

    def exec_sql(sql: str) -> str:
        cmd = [
            "docker", "exec", "-i",
            "-e", f"PGPASSWORD={cfg['password']}",
            container_name,
            "psql", "-U", cfg["user"], "-d", cfg["database"], "-t", "-A", "-c", sql
        ]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return res.stdout.strip()

    # Pre-counts: groups starting at 0
    pre_sec_zero_groups = int(exec_sql("SELECT COUNT(*) FROM (SELECT \"ExamId\" FROM exam_sections GROUP BY \"ExamId\" HAVING MIN(\"Idx\") = 0) t;") or "0")
    pre_q_zero_groups = int(exec_sql("SELECT COUNT(*) FROM (SELECT \"SectionId\" FROM exam_questions GROUP BY \"SectionId\" HAVING MIN(\"Idx\") = 0) t;") or "0")
    pre_opt_zero_groups = int(exec_sql("SELECT COUNT(*) FROM (SELECT \"QuestionId\" FROM exam_options GROUP BY \"QuestionId\" HAVING MIN(\"Idx\") = 0) t;") or "0")

    # Pre-counts: individual rows with Idx = 0
    pre_sec_zeros = int(exec_sql("SELECT COUNT(*) FROM exam_sections WHERE \"Idx\" = 0;") or "0")
    pre_q_zeros = int(exec_sql("SELECT COUNT(*) FROM exam_questions WHERE \"Idx\" = 0;") or "0")
    pre_opt_zeros = int(exec_sql("SELECT COUNT(*) FROM exam_options WHERE \"Idx\" = 0;") or "0")

    # Pre total counts
    pre_sec_total = int(exec_sql("SELECT COUNT(*) FROM exam_sections;") or "0")
    pre_q_total = int(exec_sql("SELECT COUNT(*) FROM exam_questions;") or "0")
    pre_opt_total = int(exec_sql("SELECT COUNT(*) FROM exam_options;") or "0")

    print(f"Pre-migration verification:")
    print(f"  Sections : {pre_sec_total} total, {pre_sec_zeros} with Idx=0, {pre_sec_zero_groups} exams with MIN(Idx)=0")
    print(f"  Questions: {pre_q_total} total, {pre_q_zeros} with Idx=0, {pre_q_zero_groups} sections with MIN(Idx)=0")
    print(f"  Options  : {pre_opt_total} total, {pre_opt_zeros} with Idx=0, {pre_opt_zero_groups} questions with MIN(Idx)=0")

    print("\nExecuting idempotent migration SQL...")
    cmd_mutate = [
        "docker", "exec", "-i",
        "-e", f"PGPASSWORD={cfg['password']}",
        container_name,
        "psql", "-U", cfg["user"], "-d", cfg["database"], "-c", SQL_MUTATION
    ]
    sub_res = subprocess.run(cmd_mutate, capture_output=True, text=True, check=True)
    print(sub_res.stdout.strip())

    # Post checks
    post_sec_zeros = int(exec_sql("SELECT COUNT(*) FROM exam_sections WHERE \"Idx\" = 0;") or "0")
    post_q_zeros = int(exec_sql("SELECT COUNT(*) FROM exam_questions WHERE \"Idx\" = 0;") or "0")
    post_opt_zeros = int(exec_sql("SELECT COUNT(*) FROM exam_options WHERE \"Idx\" = 0;") or "0")

    min_sec = int(exec_sql("SELECT COALESCE(MIN(\"Idx\"), 1) FROM exam_sections;") or "1")
    min_q = int(exec_sql("SELECT COALESCE(MIN(\"Idx\"), 1) FROM exam_questions;") or "1")
    min_opt = int(exec_sql("SELECT COALESCE(MIN(\"Idx\"), 1) FROM exam_options;") or "1")

    post_sec_total = int(exec_sql("SELECT COUNT(*) FROM exam_sections;") or "0")
    post_q_total = int(exec_sql("SELECT COUNT(*) FROM exam_questions;") or "0")
    post_opt_total = int(exec_sql("SELECT COUNT(*) FROM exam_options;") or "0")

    assert post_sec_zeros == 0, f"Expected 0 sections with Idx=0, got {post_sec_zeros}"
    assert post_q_zeros == 0, f"Expected 0 questions with Idx=0, got {post_q_zeros}"
    assert post_opt_zeros == 0, f"Expected 0 options with Idx=0, got {post_opt_zeros}"
    assert min_sec >= 1, f"Expected MIN(Idx) >= 1 for sections, got {min_sec}"
    assert min_q >= 1, f"Expected MIN(Idx) >= 1 for questions, got {min_q}"
    assert min_opt >= 1, f"Expected MIN(Idx) >= 1 for options, got {min_opt}"
    assert post_sec_total == pre_sec_total, f"Sections total changed: {pre_sec_total} -> {post_sec_total}"
    assert post_q_total == pre_q_total, f"Questions total changed: {pre_q_total} -> {post_q_total}"
    assert post_opt_total == pre_opt_total, f"Options total changed: {pre_opt_total} -> {post_opt_total}"

    print("\nPost-migration verification PASSED:")
    print(f"  Sections : {post_sec_total} total, {post_sec_zeros} with Idx=0, MIN(Idx)={min_sec}")
    print(f"  Questions: {post_q_total} total, {post_q_zeros} with Idx=0, MIN(Idx)={min_q}")
    print(f"  Options  : {post_opt_total} total, {post_opt_zeros} with Idx=0, MIN(Idx)={min_opt}")
    print("\nDatabase migration completed successfully!")


def run_via_psycopg2(cfg: dict):
    print(f"[Mode: psycopg2] Connecting to {cfg['host']}:{cfg['port']} db={cfg['database']} user={cfg['user']}")
    conn = psycopg2.connect(
        host=cfg["host"],
        port=cfg["port"],
        user=cfg["user"],
        password=cfg["password"],
        dbname=cfg["database"],
    )
    conn.autocommit = False
    cur = conn.cursor()

    try:
        # Pre-counts: groups starting at 0
        cur.execute("SELECT COUNT(*) FROM (SELECT \"ExamId\" FROM exam_sections GROUP BY \"ExamId\" HAVING MIN(\"Idx\") = 0) t;")
        pre_sec_zero_groups = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM (SELECT \"SectionId\" FROM exam_questions GROUP BY \"SectionId\" HAVING MIN(\"Idx\") = 0) t;")
        pre_q_zero_groups = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM (SELECT \"QuestionId\" FROM exam_options GROUP BY \"QuestionId\" HAVING MIN(\"Idx\") = 0) t;")
        pre_opt_zero_groups = cur.fetchone()[0]

        # Pre-counts: individual rows with Idx = 0
        cur.execute("SELECT COUNT(*) FROM exam_sections WHERE \"Idx\" = 0;")
        pre_sec_zeros = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_questions WHERE \"Idx\" = 0;")
        pre_q_zeros = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_options WHERE \"Idx\" = 0;")
        pre_opt_zeros = cur.fetchone()[0]

        # Total counts
        cur.execute("SELECT COUNT(*) FROM exam_sections;")
        pre_sec_total = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_questions;")
        pre_q_total = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_options;")
        pre_opt_total = cur.fetchone()[0]

        print("Pre-migration verification:")
        print(f"  Sections : {pre_sec_total} total, {pre_sec_zeros} with Idx=0, {pre_sec_zero_groups} exams with MIN(Idx)=0")
        print(f"  Questions: {pre_q_total} total, {pre_q_zeros} with Idx=0, {pre_q_zero_groups} sections with MIN(Idx)=0")
        print(f"  Options  : {pre_opt_total} total, {pre_opt_zeros} with Idx=0, {pre_opt_zero_groups} questions with MIN(Idx)=0")

        print("\nExecuting idempotent migration SQL...")
        cur.execute(SQL_MUTATION)

        # Post checks
        cur.execute("SELECT COUNT(*) FROM exam_sections WHERE \"Idx\" = 0;")
        post_sec_zeros = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_questions WHERE \"Idx\" = 0;")
        post_q_zeros = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_options WHERE \"Idx\" = 0;")
        post_opt_zeros = cur.fetchone()[0]

        cur.execute("SELECT COALESCE(MIN(\"Idx\"), 1) FROM exam_sections;")
        min_sec = cur.fetchone()[0]

        cur.execute("SELECT COALESCE(MIN(\"Idx\"), 1) FROM exam_questions;")
        min_q = cur.fetchone()[0]

        cur.execute("SELECT COALESCE(MIN(\"Idx\"), 1) FROM exam_options;")
        min_opt = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_sections;")
        post_sec_total = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_questions;")
        post_q_total = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM exam_options;")
        post_opt_total = cur.fetchone()[0]

        assert post_sec_zeros == 0, f"Expected 0 sections with Idx=0, got {post_sec_zeros}"
        assert post_q_zeros == 0, f"Expected 0 questions with Idx=0, got {post_q_zeros}"
        assert post_opt_zeros == 0, f"Expected 0 options with Idx=0, got {post_opt_zeros}"
        assert min_sec >= 1, f"Expected MIN(Idx) >= 1 for sections, got {min_sec}"
        assert min_q >= 1, f"Expected MIN(Idx) >= 1 for questions, got {min_q}"
        assert min_opt >= 1, f"Expected MIN(Idx) >= 1 for options, got {min_opt}"
        assert post_sec_total == pre_sec_total, f"Sections total changed: {pre_sec_total} -> {post_sec_total}"
        assert post_q_total == pre_q_total, f"Questions total changed: {pre_q_total} -> {post_q_total}"
        assert post_opt_total == pre_opt_total, f"Options total changed: {pre_opt_total} -> {post_opt_total}"

        print("\nPost-migration verification PASSED:")
        print(f"  Sections : {post_sec_total} total, {post_sec_zeros} with Idx=0, MIN(Idx)={min_sec}")
        print(f"  Questions: {post_q_total} total, {post_q_zeros} with Idx=0, MIN(Idx)={min_q}")
        print(f"  Options  : {post_opt_total} total, {post_opt_zeros} with Idx=0, MIN(Idx)={min_opt}")
        print("\nDatabase migration completed successfully!")

    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


def main():
    parser = argparse.ArgumentParser(description="Shift Idx from 0-indexed to 1-indexed for sections, questions, and options.")
    parser.add_argument("--docker", action="store_true", help="Run via docker exec instead of direct psycopg2 connection")
    parser.add_argument("--container", default=os.getenv("EXAM_DB_CONTAINER", DOCKER_CONTAINER_DEFAULT), help="Docker container name")
    args = parser.parse_args()

    cfg = get_db_config()

    if args.docker or psycopg2 is None:
        run_via_docker(args.container, cfg)
    else:
        try:
            run_via_psycopg2(cfg)
        except Exception as err:
            print(f"psycopg2 connection/execution failed: {err}")
            print("Falling back to Docker exec mode...")
            run_via_docker(args.container, cfg)


if __name__ == "__main__":
    main()
