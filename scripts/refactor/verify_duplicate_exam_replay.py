#!/usr/bin/env python3
"""Real-PostgreSQL Duplicate-Exam Replay Verification.

Proves that the canonical 'DuplicateExam' abort trigger has a real precondition:
two INSERTs into the `exams` table with the same Slug produce exactly one row.

Aborts are wired to 'TriggerAbort(runId, CanaryAbortReason.DuplicateExam, ...)' in
exam-service. The trigger condition under test is the IX_exams_Slug UNIQUE index.

Output: artifacts/refactor/phase-15/canary/duplicate-exam-replay.json
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
OUTPUT_DIR = ROOT / "artifacts" / "refactor" / "phase-15" / "canary"
OUTPUT_FILE = OUTPUT_DIR / "duplicate-exam-replay.json"

DB_HOST = os.environ.get("PGHOST", "localhost")
DB_PORT = os.environ.get("PGPORT", "5433")
DB_USER = os.environ.get("PGUSER", "exam")
DB_PASS = os.environ.get("PGPASSWORD", "exam")
DB_NAME = os.environ.get("PGDATABASE", "exam_test_phase14_lineage")


def run_psql(sql: str, db: str = DB_NAME) -> str:
    cmd = [
        "psql", "-h", DB_HOST, "-p", DB_PORT, "-U", DB_USER, "-d", db,
        "-t", "-A", "-c", sql,
    ]
    env = {**os.environ, "PGPASSWORD": DB_PASS}
    proc = subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"psql error ({proc.returncode}): {proc.stderr}\nSQL was: {sql}")
    return proc.stdout.strip()


def run_psql_raw(sql: str, db: str = DB_NAME) -> subprocess.CompletedProcess:
    cmd = [
        "psql", "-h", DB_HOST, "-p", DB_PORT, "-U", DB_USER, "-d", db,
        "-c", sql,
    ]
    env = {**os.environ, "PGPASSWORD": DB_PASS}
    return subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def verify_duplicate_exam_replay() -> dict:
    # Confirm IX_exams_Slug exists (the precondition for the abort)
    indexes = run_psql(
        "SELECT indexname FROM pg_indexes WHERE tablename = 'exams' AND indexname = 'IX_exams_Slug';"
    )
    slug_index_present = indexes == "IX_exams_Slug"

    slug = f"dup-exam-abort-{uuid.uuid4().hex[:12]}"
    exam_id_1 = str(uuid.uuid4())
    exam_id_2 = str(uuid.uuid4())

    insert_first = f"""
    INSERT INTO exams (
        "Id", "Slug", "Title", "DescriptionMd", "Category", "Level",
        "Status", "DurationMin", "ImageUrl"
    ) VALUES (
        '{exam_id_1}', '{slug}',
        'Phase 15 Duplicate Exam Replay (1)', 'First submit',
        'READING', 'B2', 'DRAFT', 60, ''
    );
    """
    res_first = run_psql_raw(insert_first)
    first_insert_ok = res_first.returncode == 0
    assert first_insert_ok, f"first insert must succeed; got: {res_first.stderr}"

    # Replay identical Slug (different Id, parallel attempt):
    insert_replay = f"""
    INSERT INTO exams (
        "Id", "Slug", "Title", "DescriptionMd", "Category", "Level",
        "Status", "DurationMin", "ImageUrl"
    ) VALUES (
        '{exam_id_2}', '{slug}',
        'Phase 15 Duplicate Exam Replay (2)', 'Replay submit',
        'READING', 'B2', 'DRAFT', 60, ''
    );
    """
    res_replay = run_psql_raw(insert_replay)
    replay_rejected = res_replay.returncode != 0
    replay_stderr = res_replay.stderr
    constraint_in_error = (
        "IX_exams_Slug" in replay_stderr
        or "duplicate key value" in replay_stderr
    )

    # Count rows bearing the test Slug (must be exactly 1)
    duplicate_row_count = run_psql(
        f"SELECT count(*) FROM exams WHERE \"Slug\" = '{slug}';"
    )
    duplicate_row_count = int(duplicate_row_count)

    # Rows by Id (must be exactly 1)
    row_id_1 = run_psql(
        f"SELECT \"Title\" FROM exams WHERE \"Id\" = '{exam_id_1}';"
    )
    row_id_2 = run_psql(
        f"SELECT \"Title\" FROM exams WHERE \"Id\" = '{exam_id_2}';"
    )

    # Cleanup
    run_psql(f"DELETE FROM exams WHERE \"Slug\" = '{slug}';")

    report = {
        "controlUnderTest": "DuplicateExam",
        "databaseTarget": f"{DB_USER}@{DB_HOST}:{DB_PORT}/{DB_NAME}",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "preconditions": {
            "slugUniqueIndexPresent": slug_index_present,
            "slugUniqueIndexName": "IX_exams_Slug",
        },
        "test": {
            "firstInsert": {
                "examId": exam_id_1,
                "slug": slug,
                "returncode": res_first.returncode,
                "ok": first_insert_ok,
            },
            "replayInsert": {
                "examId": exam_id_2,
                "slug": slug,
                "returncode": res_replay.returncode,
                "rejectedByConstraint": replay_rejected and constraint_in_error,
                "constraintNameInError": constraint_in_error,
            },
        },
        "postConditions": {
            "rowsWithTestSlug": duplicate_row_count,
            "rowByFirstExamId": row_id_1,
            "rowByReplayExamId": row_id_2,
            "zeroDuplicateExamsVerified": duplicate_row_count == 1 and row_id_2 == "",
        },
        "verdict": (
            "DUPLICATE_EXAM_REJECTED_BY_IX_exams_Slug"
            if (replay_rejected and constraint_in_error and duplicate_row_count == 1 and row_id_2 == "")
            else "FAILED"
        ),
    }

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    return report


if __name__ == "__main__":
    r = verify_duplicate_exam_replay()
    print(json.dumps(r, indent=2))
    print(f"\nVerdict: {r['verdict']}")
    print(f"Report:  {OUTPUT_FILE}")
    if r["verdict"] != "DUPLICATE_EXAM_REJECTED_BY_IX_exams_Slug":
        sys.exit(1)
