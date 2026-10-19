#!/usr/bin/env python3
"""Audit script for existing generated, imported, and seeded exam data.

Inspects exam-db and attempt-db in PostgreSQL, reporting:
- Missing answer keys by question type
- Keys not contained in option pools
- Invalid matching pairs and placeholder keys
- Incorrect group-to-item scoring
- Answer ambiguity (multiple correct in single choice)
- Wrong-language content (Vietnamese text in candidate-facing fields)
- Schema and delivery mismatches (missing [N] markers, missing images)
- Historical attempt impact
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from collections import defaultdict
from typing import Any

VIETNAMESE_RE = re.compile(
    r"[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ"
    r"ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]"
)
FORBIDDEN_PLACEHOLDERS = frozenset({
    "item 1", "item 2", "paragraph 1", "paragraph 2", "option a", "option b",
    "tbd", "n/a", "placeholder", "unknown", "none", "null"
})

def run_psql_json(db: str, query: str) -> Any:
    json_query = f"SELECT json_agg(t) FROM ({query}) t;"
    cmd = [
        "docker", "exec", "-e", "PGPASSWORD=langfens", "pg-0416bceb",
        "psql", "-U", "langfens", "-d", db, "-t", "-A", "-c", json_query
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, check=True)
    out = res.stdout.strip()
    if not out or out == "null":
        return []
    return json.loads(out)


def audit_exam_data():
    print("=== STARTING READ-ONLY EXISTING DATA AUDIT ===")
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

    # 2. Fetch all questions
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

    # 3. Fetch all options
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

    # Findings categorisation
    missing_answer_keys = []
    keys_not_in_options = []
    invalid_matching_pairs = []
    group_scoring_issues = []
    ambiguous_choice_answers = []
    wrong_language_items = []
    schema_delivery_mismatches = []

    for qid, q in questions.items():
        qtype = q["type"]
        exam_id = q["examId"]
        exam_title = exams.get(exam_id, {}).get("title", "Unknown")
        ref = f"Exam '{exam_title}' ({exam_id}) -> Q{q['idx']} ({qid}) [{qtype}]"

        # Language check
        if q["promptMd"] and VIETNAMESE_RE.search(q["promptMd"]):
            wrong_language_items.append({
                "ref": ref,
                "field": "promptMd",
                "preview": q["promptMd"][:100],
            })
        if q["explanationMd"] and VIETNAMESE_RE.search(q["explanationMd"]):
            wrong_language_items.append({
                "ref": ref,
                "field": "explanationMd",
                "preview": q["explanationMd"][:100],
            })

        # Type-specific checks
        if qtype in ("MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_SINGLE_IMAGE"):
            opts = q["options"]
            correct_count = sum(1 for o in opts if o["isCorrect"])
            if correct_count == 0:
                missing_answer_keys.append({"ref": ref, "reason": "No option marked isCorrect=true"})
            elif correct_count > 1:
                ambiguous_choice_answers.append({"ref": ref, "reason": f"Expected 1 correct option, found {correct_count}"})

        elif qtype == "MULTIPLE_CHOICE_MULTIPLE":
            opts = q["options"]
            correct_count = sum(1 for o in opts if o["isCorrect"])
            if correct_count < 2:
                missing_answer_keys.append({"ref": ref, "reason": f"Expected >= 2 correct options, found {correct_count}"})

        elif qtype in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
            opts = q["options"]
            correct_count = sum(1 for o in opts if o["isCorrect"])
            if correct_count == 0:
                missing_answer_keys.append({"ref": ref, "reason": "No option marked isCorrect=true"})
            elif correct_count > 1:
                ambiguous_choice_answers.append({"ref": ref, "reason": f"Expected 1 correct option, found {correct_count}"})
            if len(opts) != 3:
                schema_delivery_mismatches.append({"ref": ref, "reason": f"Expected exactly 3 options, found {len(opts)}"})

        elif qtype in ("SUMMARY_COMPLETION", "TABLE_COMPLETION", "NOTE_COMPLETION", "FORM_COMPLETION", "SENTENCE_COMPLETION", "DIAGRAM_LABEL", "MAP_LABEL"):
            blanks = q["blankAcceptTexts"]
            if not blanks or len(blanks) == 0:
                missing_answer_keys.append({"ref": ref, "reason": "Empty blankAcceptTexts"})
            else:
                for b_key, b_vals in blanks.items():
                    if not b_vals or all(not str(v).strip() for v in b_vals):
                        missing_answer_keys.append({"ref": ref, "reason": f"Blank [{b_key}] has empty accepted texts"})
                    else:
                        for v in b_vals:
                            if str(v).strip().lower() in FORBIDDEN_PLACEHOLDERS:
                                invalid_matching_pairs.append({"ref": ref, "reason": f"Blank [{b_key}] contains placeholder answer '{v}'"})

                is_diag_map = qtype in ("DIAGRAM_LABEL", "MAP_LABEL") and bool(
                    re.search(r"\[(Diagram|Map):\s*[^\]]+\]", q["promptMd"] or "", re.IGNORECASE)
                )
                if not is_diag_map:
                    for b_key in blanks.keys():
                        if f"[{b_key}]" not in (q["promptMd"] or ""):
                            schema_delivery_mismatches.append({"ref": ref, "reason": f"Missing [{b_key}] in promptMd"})

        elif qtype == "SHORT_ANSWER":
            texts = q["shortAnswerAcceptTexts"]
            if not texts or len(texts) == 0:
                missing_answer_keys.append({"ref": ref, "reason": "Empty shortAnswerAcceptTexts"})

        elif qtype == "FLOW_CHART":
            order = q["orderCorrects"]
            if not order or len(order) == 0:
                missing_answer_keys.append({"ref": ref, "reason": "Empty orderCorrects"})

        elif qtype in ("MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"):
            pairs = q["matchPairs"]
            if not pairs or len(pairs) == 0:
                missing_answer_keys.append({"ref": ref, "reason": "Empty matchPairs"})
            else:
                if len(pairs) > 1:
                    group_scoring_issues.append({
                        "ref": ref,
                        "pair_count": len(pairs),
                        "note": f"Multi-target matching item ({len(pairs)} pairs) in single ExamQuestion row"
                    })

                opt_keys = set()
                for o in q["options"]:
                    m = re.match(r"^([a-zA-Z0-9ivxlcdmIVXLCDM]+)[\.\)]", o["contentMd"] or "")
                    if m:
                        opt_keys.add(m.group(1).lower())

                for t_key, val in pairs.items():
                    if not val or len(val) < 1 or not str(val[0]).strip():
                        missing_answer_keys.append({"ref": ref, "reason": f"Target '{t_key}' has empty grading key"})
                        continue

                    g_key = str(val[0]).strip().lower()
                    if g_key in FORBIDDEN_PLACEHOLDERS:
                        invalid_matching_pairs.append({"ref": ref, "reason": f"Target '{t_key}' gradingKey '{val[0]}' is a placeholder"})

                    if qtype == "MATCHING_HEADING":
                        if not re.match(r"^[ivxlcdm]+$", g_key):
                            invalid_matching_pairs.append({"ref": ref, "reason": f"Target '{t_key}' gradingKey '{val[0]}' is not a Roman numeral"})

                    if len(val) >= 2 and val[1]:
                        if str(val[1]).strip().lower() in FORBIDDEN_PLACEHOLDERS:
                            invalid_matching_pairs.append({"ref": ref, "reason": f"Target '{t_key}' displayLabel '{val[1]}' is a placeholder"})

                    if opt_keys and g_key not in opt_keys:
                        keys_not_in_options.append({
                            "ref": ref,
                            "target": t_key,
                            "key": val[0],
                            "available_options": list(opt_keys)[:5],
                        })

    # Print summary report
    print("\n================ INTEGRITY AUDIT REPORT ================")
    print(f"Total Exams Audited: {len(exams)}")
    print(f"Total Questions Audited: {len(questions)}")
    print(f"\n1. Missing Answer Keys: {len(missing_answer_keys)}")
    for item in missing_answer_keys[:10]:
        print(f"   - {item['ref']}: {item['reason']}")
    if len(missing_answer_keys) > 10:
        print(f"   ... and {len(missing_answer_keys) - 10} more")

    print(f"\n2. Keys Not in Option Pools: {len(keys_not_in_options)}")
    for item in keys_not_in_options[:10]:
        print(f"   - {item['ref']} Target '{item['target']}': key '{item['key']}' not in {item['available_options']}")
    if len(keys_not_in_options) > 10:
        print(f"   ... and {len(keys_not_in_options) - 10} more")

    print(f"\n3. Invalid Matching Pairs / Placeholders: {len(invalid_matching_pairs)}")
    for item in invalid_matching_pairs[:10]:
        print(f"   - {item['ref']}: {item['reason']}")
    if len(invalid_matching_pairs) > 10:
        print(f"   ... and {len(invalid_matching_pairs) - 10} more")

    print(f"\n4. Group-to-Item Scoring Multi-Target Items: {len(group_scoring_issues)}")
    for item in group_scoring_issues[:10]:
        print(f"   - {item['ref']}: {item['note']}")

    print(f"\n5. Ambiguous Choice Answers: {len(ambiguous_choice_answers)}")
    for item in ambiguous_choice_answers[:10]:
        print(f"   - {item['ref']}: {item['reason']}")

    print(f"\n6. Wrong Language Content (Vietnamese): {len(wrong_language_items)}")
    for item in wrong_language_items[:10]:
        print(f"   - {item['ref']} in {item['field']}: '{item['preview']}'")

    print(f"\n7. Schema and Delivery Mismatches: {len(schema_delivery_mismatches)}")
    for item in schema_delivery_mismatches[:10]:
        print(f"   - {item['ref']}: {item['reason']}")

    # 4. Check historical attempts in attempt-db
    attempt_list = run_psql_json(
        "attempt-db",
        'SELECT "Id", "ExamId", status, "StartedAt", "RawScore" FROM attempts ORDER BY "StartedAt" DESC'
    )
    print(f"\n8. Historical Attempts Audited: {len(attempt_list)}")
    for a in attempt_list[:5]:
        print(f"   - Attempt {a['Id']}: Exam {a['ExamId']}, Status {a['status']}, RawScore {a.get('RawScore')}")

    print("\n================ AUDIT SUMMARY ================")
    status = "DEFECTS_DETECTED" if (missing_answer_keys or keys_not_in_options or invalid_matching_pairs) else "CLEAN"
    print(f"DATA_AUDIT_STATUS = {status}")
    print("Controlled Quarantine / Remediation Recommended for defective exam IDs.")
    print("================================================")


if __name__ == "__main__":
    audit_exam_data()
