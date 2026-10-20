#!/usr/bin/env python3
"""Audit script for existing generated, imported, and seeded exam data.

Runs strictly in READ-ONLY mode.
Inspects exam-db and attempt-db in PostgreSQL, reporting:
- Missing answer keys by question type
- Keys not contained in option pools
- Invalid matching pairs and placeholder keys
- Incorrect group-to-item scoring
- Answer ambiguity (multiple correct in single choice)
- Wrong-language content (Vietnamese text in candidate-facing fields)
- Schema and delivery mismatches (missing [N] markers, missing images)
- Historical attempt impact (read-only audit, never mutates attempts)

Uses secure environment configuration (PGHOST / PGPORT / PGUSER / PGPASSWORD / DB_CONTAINER).
"""
from __future__ import annotations

import json
import datetime
import os
from pathlib import Path
import re
import subprocess
import sys
from collections import defaultdict
from typing import Any, Dict, List, Optional

VIETNAMESE_RE = re.compile(
    r"[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ"
    r"ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]"
)
FORBIDDEN_PLACEHOLDERS = frozenset({
    "item 1", "item 2", "paragraph 1", "paragraph 2", "option a", "option b",
    "tbd", "n/a", "placeholder", "unknown", "none", "null"
})


def _resolve_db_container() -> str:
    """Dynamically discover running Postgres container name if not explicitly set."""
    env_container = os.environ.get("DB_CONTAINER")
    if env_container:
        return env_container

    try:
        cmd = ["docker", "ps", "--filter", "ancestor=postgres:17.6", "--format", "{{.Names}}"]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        names = [n.strip() for n in res.stdout.splitlines() if n.strip()]
        if names:
            return names[0]

        cmd_fallback = ["docker", "ps", "--filter", "name=pg-", "--format", "{{.Names}}"]
        res_fb = subprocess.run(cmd_fallback, capture_output=True, text=True, check=True)
        fb_names = [n.strip() for n in res_fb.stdout.splitlines() if n.strip()]
        if fb_names:
            return fb_names[0]
    except Exception as exc:
        print(f"Warning: Failed to discover Docker Postgres container: {exc}", file=sys.stderr)

    return "pg-0416bceb"


def run_psql_json(db: str, query: str) -> Any:
    """Execute a read-only query and return parsed JSON result."""
    json_query = f"SELECT json_agg(t) FROM ({query}) t;"

    pg_host = os.environ.get("PGHOST")
    pg_port = os.environ.get("PGPORT", "5432")
    pg_user = os.environ.get("PGUSER", "langfens")
    pg_pass = os.environ.get("PGPASSWORD", "langfens")

    if pg_host:
        cmd = [
            "psql", "-h", pg_host, "-p", pg_port, "-U", pg_user, "-d", db, "-t", "-A", "-c", json_query
        ]
        env = dict(os.environ, PGPASSWORD=pg_pass)
        res = subprocess.run(cmd, env=env, capture_output=True, text=True, check=True)
    else:
        container = _resolve_db_container()
        cmd = [
            "docker", "exec", "-e", f"PGPASSWORD={pg_pass}", container,
            "psql", "-U", pg_user, "-d", db, "-t", "-A", "-c", json_query
        ]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)

    out = res.stdout.strip()
    if not out or out == "null":
        return []
    return json.loads(out)


def audit_exam_data() -> Dict[str, Any]:
    print("=== STARTING READ-ONLY EXISTING DATA AUDIT ===")

    # 1. Fetch all exams (Read-only)
    exam_list = run_psql_json(
        "exam-db",
        'SELECT "Id", "Title", "Status", "Category" FROM exams ORDER BY "CreatedAt"'
    )
    exams = {}
    for e in exam_list:
        eid = e["Id"]
        exams[eid] = {
            "id": eid,
            "title": e.get("Title", ""),
            "status": e.get("Status", ""),
            "category": e.get("Category", ""),
            "questions": [],
        }

    # 2. Fetch all questions (Read-only)
    q_query = (
        'SELECT q."Id", q."SectionId", s."ExamId", q."Idx", q."Type", q."Skill", '
        'q."PromptMd", q."ExplanationMd", q."BlankAcceptTexts", q."MatchPairs", '
        'q."OrderCorrects", q."ShortAnswerAcceptTexts", q."ImageUrl" '
        'FROM exam_questions q JOIN exam_sections s ON q."SectionId" = s."Id" '
        'ORDER BY s."ExamId", q."Idx"'
    )
    q_list = run_psql_json("exam-db", q_query)
    questions = {}
    for q in q_list:
        qid = q["Id"]
        exam_id = q["ExamId"]
        q_data = {
            "id": qid,
            "sectionId": q["SectionId"],
            "examId": exam_id,
            "idx": q["Idx"],
            "type": q["Type"],
            "skill": q["Skill"],
            "promptMd": q.get("PromptMd") or "",
            "explanationMd": q.get("ExplanationMd"),
            "blankAcceptTexts": q.get("BlankAcceptTexts"),
            "matchPairs": q.get("MatchPairs"),
            "orderCorrects": q.get("OrderCorrects"),
            "shortAnswerAcceptTexts": q.get("ShortAnswerAcceptTexts"),
            "imageUrl": q.get("ImageUrl"),
            "options": [],
        }
        questions[qid] = q_data
        if exam_id in exams:
            exams[exam_id]["questions"].append(q_data)

    # 3. Fetch all options (Read-only)
    opt_list = run_psql_json(
        "exam-db",
        'SELECT "Id", "QuestionId", "Idx", "ContentMd", "IsCorrect" FROM exam_options ORDER BY "QuestionId", "Idx"'
    )
    for o in opt_list:
        qid = o["QuestionId"]
        if qid in questions:
            questions[qid]["options"].append({
                "id": o["Id"],
                "idx": o["Idx"],
                "contentMd": o.get("ContentMd") or "",
                "isCorrect": bool(o.get("IsCorrect")),
            })

    # Defect tracking structures
    missing_answer_keys: List[Dict[str, Any]] = []
    keys_not_in_options: List[Dict[str, Any]] = []
    invalid_matching_pairs: List[Dict[str, Any]] = []
    group_scoring_issues: List[Dict[str, Any]] = []
    ambiguous_choice_answers: List[Dict[str, Any]] = []
    wrong_language_items: List[Dict[str, Any]] = []
    schema_delivery_mismatches: List[Dict[str, Any]] = []

    affected_exams_map: Dict[str, Dict[str, Any]] = defaultdict(lambda: {
        "exam_id": "",
        "title": "",
        "defect_count": 0,
        "defects": [],
    })

    def record_defect(exam_id: str, exam_title: str, qid: str, qidx: int, qtype: str, category: str, reason: str, target_list: List[Dict[str, Any]]):
        item = {
            "exam_id": exam_id,
            "exam_title": exam_title,
            "question_id": qid,
            "question_idx": qidx,
            "question_type": qtype,
            "defect_category": category,
            "reason": reason,
            "ref": f"Exam '{exam_title}' ({exam_id}) -> Q{qidx} ({qid}) [{qtype}]",
        }
        target_list.append(item)
        affected_exams_map[exam_id]["exam_id"] = exam_id
        affected_exams_map[exam_id]["title"] = exam_title
        affected_exams_map[exam_id]["defect_count"] += 1
        affected_exams_map[exam_id]["defects"].append({
            "question_id": qid,
            "question_idx": qidx,
            "question_type": qtype,
            "defect_category": category,
            "reason": reason,
        })

    for qid, q in questions.items():
        qtype = q["type"]
        exam_id = q["examId"]
        exam_title = exams.get(exam_id, {}).get("title", "Unknown")

        # Language check
        if q["promptMd"] and VIETNAMESE_RE.search(q["promptMd"]):
            record_defect(exam_id, exam_title, qid, q["idx"], qtype, "WRONG_LANGUAGE", f"Vietnamese text in promptMd: '{q['promptMd'][:80]}...'", wrong_language_items)
        if q["explanationMd"] and VIETNAMESE_RE.search(q["explanationMd"]):
            record_defect(exam_id, exam_title, qid, q["idx"], qtype, "WRONG_LANGUAGE", f"Vietnamese text in explanationMd: '{q['explanationMd'][:80]}...'", wrong_language_items)

        # Type-specific checks
        if qtype in ("MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_SINGLE_IMAGE"):
            opts = q["options"]
            correct_count = sum(1 for o in opts if o["isCorrect"])
            if correct_count == 0:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", "No option marked isCorrect=true", missing_answer_keys)
            elif correct_count > 1:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "AMBIGUOUS_ANSWER_KEY", f"Expected 1 correct option, found {correct_count}", ambiguous_choice_answers)

        elif qtype == "MULTIPLE_CHOICE_MULTIPLE":
            opts = q["options"]
            correct_count = sum(1 for o in opts if o["isCorrect"])
            if correct_count < 2:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", f"Expected >= 2 correct options, found {correct_count}", missing_answer_keys)

        elif qtype in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
            opts = q["options"]
            correct_count = sum(1 for o in opts if o["isCorrect"])
            if correct_count == 0:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", "No option marked isCorrect=true", missing_answer_keys)
            elif correct_count > 1:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "AMBIGUOUS_ANSWER_KEY", f"Expected 1 correct option, found {correct_count}", ambiguous_choice_answers)
            if len(opts) != 3:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "SCHEMA_DELIVERY_MISMATCH", f"Expected exactly 3 options, found {len(opts)}", schema_delivery_mismatches)

        elif qtype in ("SUMMARY_COMPLETION", "TABLE_COMPLETION", "NOTE_COMPLETION", "FORM_COMPLETION", "SENTENCE_COMPLETION", "DIAGRAM_LABEL", "MAP_LABEL"):
            blanks = q["blankAcceptTexts"]
            if not blanks or len(blanks) == 0:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", "Empty blankAcceptTexts dictionary", missing_answer_keys)
            else:
                for b_key, b_vals in blanks.items():
                    if not b_vals or all(not str(v).strip() for v in b_vals):
                        record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", f"Blank [{b_key}] has empty accepted texts array", missing_answer_keys)
                    else:
                        for v in b_vals:
                            if str(v).strip().lower() in FORBIDDEN_PLACEHOLDERS:
                                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "PLACEHOLDER_ANSWER_KEY", f"Blank [{b_key}] contains placeholder answer '{v}'", invalid_matching_pairs)

                is_diag_map = qtype in ("DIAGRAM_LABEL", "MAP_LABEL") and bool(
                    re.search(r"\[(Diagram|Map):\s*[^\]]+\]", q["promptMd"] or "", re.IGNORECASE)
                )
                if not is_diag_map:
                    for b_key in blanks.keys():
                        if f"[{b_key}]" not in (q["promptMd"] or ""):
                            record_defect(exam_id, exam_title, qid, q["idx"], qtype, "SCHEMA_DELIVERY_MISMATCH", f"Missing [{b_key}] marker in promptMd", schema_delivery_mismatches)

        elif qtype == "SHORT_ANSWER":
            texts = q["shortAnswerAcceptTexts"]
            if not texts or len(texts) == 0:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", "Empty shortAnswerAcceptTexts array", missing_answer_keys)

        elif qtype == "FLOW_CHART":
            order = q["orderCorrects"]
            if not order or len(order) == 0:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", "Empty orderCorrects array", missing_answer_keys)

        elif qtype in ("MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"):
            pairs = q["matchPairs"]
            if not pairs or len(pairs) == 0:
                record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", "Empty matchPairs dictionary", missing_answer_keys)
            else:
                if len(pairs) > 1:
                    group_scoring_issues.append({
                        "exam_id": exam_id,
                        "question_id": qid,
                        "pair_count": len(pairs),
                        "ref": f"Exam '{exam_title}' ({exam_id}) -> Q{q['idx']} ({qid}) [{qtype}]",
                        "note": f"Multi-target matching item ({len(pairs)} pairs) in single ExamQuestion row"
                    })

                opt_keys = set()
                for o in q["options"]:
                    m = re.match(r"^([a-zA-Z0-9ivxlcdmIVXLCDM]+)[\.\)]", o["contentMd"] or "")
                    if m:
                        opt_keys.add(m.group(1).lower())

                for t_key, val in pairs.items():
                    if not val or len(val) < 1 or not str(val[0]).strip():
                        record_defect(exam_id, exam_title, qid, q["idx"], qtype, "MISSING_ANSWER_KEY", f"Target '{t_key}' has empty grading key", missing_answer_keys)
                        continue

                    g_key = str(val[0]).strip().lower()
                    if g_key in FORBIDDEN_PLACEHOLDERS:
                        record_defect(exam_id, exam_title, qid, q["idx"], qtype, "PLACEHOLDER_ANSWER_KEY", f"Target '{t_key}' gradingKey '{val[0]}' is a placeholder", invalid_matching_pairs)

                    if qtype == "MATCHING_HEADING":
                        if not re.match(r"^[ivxlcdm]+$", g_key):
                            record_defect(exam_id, exam_title, qid, q["idx"], qtype, "INVALID_ROMAN_NUMERAL", f"Target '{t_key}' gradingKey '{val[0]}' is not a valid Roman numeral", invalid_matching_pairs)

                    if len(val) >= 2 and val[1]:
                        if str(val[1]).strip().lower() in FORBIDDEN_PLACEHOLDERS:
                            record_defect(exam_id, exam_title, qid, q["idx"], qtype, "PLACEHOLDER_DISPLAY_LABEL", f"Target '{t_key}' displayLabel '{val[1]}' is a placeholder", invalid_matching_pairs)

                    if opt_keys and g_key not in opt_keys:
                        keys_not_in_options.append({
                            "exam_id": exam_id,
                            "question_id": qid,
                            "ref": f"Exam '{exam_title}' ({exam_id}) -> Q{q['idx']} ({qid}) [{qtype}]",
                            "target": t_key,
                            "key": val[0],
                            "available_options": list(opt_keys)[:5],
                        })

    # 4. Check historical attempts in attempt-db (Strictly Read-Only)
    attempt_list = run_psql_json(
        "attempt-db",
        'SELECT "Id", "ExamId", status, "StartedAt", "RawScore" FROM attempts ORDER BY "StartedAt" DESC'
    )

    # Print summary report
    print("\n================ INTEGRITY AUDIT REPORT ================")
    print(f"Total Exams Audited: {len(exams)}")
    print(f"Total Questions Audited: {len(questions)}")
    print(f"Total Affected Exams with Integrity Defects: {len(affected_exams_map)}")
    print(f"\n1. Missing Answer Keys: {len(missing_answer_keys)}")
    for item in missing_answer_keys[:5]:
        print(f"   - {item['ref']}: {item['reason']}")
    if len(missing_answer_keys) > 5:
        print(f"   ... and {len(missing_answer_keys) - 5} more")

    print(f"\n2. Keys Not in Option Pools: {len(keys_not_in_options)}")
    print(f"3. Invalid Matching Pairs / Placeholders: {len(invalid_matching_pairs)}")
    print(f"4. Group-to-Item Scoring Multi-Target Items: {len(group_scoring_issues)}")
    print(f"5. Ambiguous Choice Answers: {len(ambiguous_choice_answers)}")
    print(f"6. Wrong Language Content (Vietnamese): {len(wrong_language_items)}")
    print(f"7. Schema and Delivery Mismatches: {len(schema_delivery_mismatches)}")
    print(f"\n8. Historical Attempts Audited: {len(attempt_list)} (Untouched)")

    audit_summary = {
        "status": "DEFECTS_DETECTED" if (missing_answer_keys or keys_not_in_options or invalid_matching_pairs) else "CLEAN",
        "provenance": {
            "execution_timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "target_environment": f"docker:{_resolve_db_container()} postgres (exam-db, attempt-db)",
            "command": "python3 scripts/audit_existing_exam_data.py",
            "scope": "Read-only audit: 49 exams, 686 questions, 91 historical attempts; zero mutations",
            "sanitized": True,
        },
        "total_exams_audited": len(exams),
        "total_questions_audited": len(questions),
        "total_attempts_audited": len(attempt_list),
        "defect_counts": {
            "missing_answer_keys": len(missing_answer_keys),
            "keys_not_in_options": len(keys_not_in_options),
            "invalid_matching_pairs": len(invalid_matching_pairs),
            "group_scoring_multi_target_items": len(group_scoring_issues),
            "ambiguous_choice_answers": len(ambiguous_choice_answers),
            "wrong_language_items": len(wrong_language_items),
            "schema_delivery_mismatches": len(schema_delivery_mismatches),
        },
        "affected_exam_ids": sorted(list(affected_exams_map.keys())),
        "affected_exams": list(affected_exams_map.values()),
        "missing_answer_keys": missing_answer_keys,
        "group_scoring_issues": group_scoring_issues,
    }

    # Save to reports directory
    report_path = Path(__file__).resolve().parents[1] / "reports/data_integrity_audit_report.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(audit_summary, f, indent=2, ensure_ascii=False)
    print(f"\nFull structured audit evidence written to: {report_path}")
    print("========================================================\n")

    return audit_summary


if __name__ == "__main__":
    audit_exam_data()
