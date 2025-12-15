#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#python3 exam_json_folder_to_sql.py ./jsons --out ./sql \
#  --category IELTS --level B2 --status DRAFT --duration-min 20

"""
Convert a folder of exam JSON files into PostgreSQL seed .sql files.

Supports 2 input formats:
1) Import-schema format (matches exam-import.schema.json):
   {
     "schemaVersion": "...",
     "exams": [ { "id": "...", "slug": "...", "title": "...", "category": "...", ... } ]
   }

2) Mini-IELTS scraped format (like agriculture-and-tourism.exam.json):
   {
     "source": { "testUrl": "...", "solutionUrl": "..." },
     "passage": { "title": "...", "text": "..." },
     "questionGroups": [ ... ],
     "questions": [ ... ]
   }

Output:
- One .sql per exam, named by its slug.
- Optionally a single combined .sql.

Example:
  python exam_json_folder_to_sql.py /path/to/jsons --out ./out_sql --combined all.sql
"""

from __future__ import annotations
import argparse
import json
import os
import re
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

# ---------- helpers ----------

def slugify(s: str) -> str:
    s = (s or "").strip().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = re.sub(r"-{2,}", "-", s).strip("-")
    return s or "exam"

def pg_escape_literal(s: str) -> str:
    return (s or "").replace("'", "''")

def dollar_quote(s: Optional[str], tag_base: str = "md") -> str:
    if s is None:
        return "NULL"
    tag = tag_base
    i = 0
    while f"${tag}$" in s:
        i += 1
        tag = f"{tag_base}{i}"
    return f"${tag}$" + s + f"${tag}$"

def stable_uuid(ns: uuid.UUID, name: str) -> str:
    return str(uuid.uuid5(ns, name))

def make_accept_regexes(answer_text: str) -> List[str]:
    if not answer_text:
        return []
    parts = re.split(r"\s*/\s*|\s*\|\s*|\s*;\s*", answer_text.strip())
    regexes: List[str] = []
    for p in parts:
        p = p.strip().strip('"').strip("'")
        if not p:
            continue
        p = re.sub(r"\s+", " ", p.lower())
        tokens = re.findall(r"[a-z0-9]+", p)
        if not tokens:
            continue
        rx = ".*" + ".*".join(re.escape(t) for t in tokens) + ".*"
        if rx not in regexes:
            regexes.append(rx)
    return regexes

# ---------- parsers ----------

def infer_group_question_type(group_instructions_md: str, raw_q_type: str) -> str:
    ins = (group_instructions_md or "").lower()

    # TEXT -> completion/short answer
    if raw_q_type == "TEXT":
        if "notes" in ins or "note" in ins:
            return "NOTE_COMPLETION"
        if "table" in ins:
            return "TABLE_COMPLETION"
        if "summary" in ins:
            return "SUMMARY_COMPLETION"
        if "form" in ins:
            return "FORM_COMPLETION"
        if "sentence" in ins:
            return "SENTENCE_COMPLETION"
        return "SHORT_ANSWER"

    # SELECT -> IELTS-style mappings (still stored as options)
    if "which paragraph" in ins and "paragraph" in ins:
        return "MATCHING_INFORMATION"
    if "belongs to" in ins or "categories" in ins or "category" in ins:
        return "CLASSIFICATION"
    if "true" in ins and "not given" in ins:
        return "TRUE_FALSE_NOT_GIVEN"
    if "yes" in ins and "not given" in ins:
        return "YES_NO_NOT_GIVEN"
    if "heading" in ins and ("match" in ins or "choose" in ins):
        return "MATCHING_HEADING"

    return "MULTIPLE_CHOICE_SINGLE"

def infer_difficulty(question_idx: int) -> int:
    # simple default heuristic (1..5)
    if question_idx <= 4:
        return 2
    if question_idx <= 9:
        return 3
    return 4

def parse_mini_ielts_file(obj: Dict[str, Any], defaults: Dict[str, Any]) -> List[Dict[str, Any]]:
    test_url = (obj.get("source") or {}).get("testUrl") or ""
    solution_url = (obj.get("source") or {}).get("solutionUrl") or ""

    m = re.search(r"/(\d+)/(reading|listening|writing|speaking)/([a-z0-9\-]+)", test_url)
    if m:
        exam_no, skill, topic = m.group(1), m.group(2), m.group(3)
        slug = f"ielts-{skill}-{topic}-{exam_no}"
    else:
        slug = f"ielts-reading-{slugify((obj.get('passage') or {}).get('title') or 'exam')}"

    title = (obj.get("passage") or {}).get("title") or defaults["title_fallback"]
    passage_text = (obj.get("passage") or {}).get("text") or ""

    # description markdown
    desc_lines = [f"## {title}", ""]
    if test_url:
        desc_lines += ["Nguồn:", f"- Test: {test_url}"]
        if solution_url:
            desc_lines.append(f"- Solution: {solution_url}")
        desc_lines.append("")
    description_md = "\n".join(desc_lines).strip()

    questions = obj.get("questions") or []
    q_groups = obj.get("questionGroups") or []

    # map qid -> group
    qid_to_group: Dict[str, Dict[str, Any]] = {}
    for g in q_groups:
        for q in (g.get("questions") or []):
            qid = q.get("id")
            if qid:
                qid_to_group[qid] = g

    n_questions = len(questions)
    section = {
        "idx": 1,
        "title": f"Reading — {title}",
        "instructionsMd": (
            f"Read the passage and answer questions **1–{n_questions}**.\n\n"
            f"### Passage: {title}\n\n{passage_text}"
        ).strip(),
        "audioUrl": None,
        "transcriptMd": None,
        "questions": [],
    }

    for q in questions:
        q_idx = int(q.get("idx"))
        g = qid_to_group.get(q.get("id") or "", {})
        g_title = g.get("title") or ""
        g_ins = g.get("instructionsMd") or ""
        q_prompt = q.get("prompt") or ""

        q_type = infer_group_question_type(g_ins, q.get("type") or "")
        prompt_md = "\n\n".join(
            [
                f"### Question {q_idx}",
                (f"{g_title}\n{g_ins}".strip() if (g_title or g_ins) else "").strip(),
                q_prompt.strip(),
            ]
        ).strip()

        q_out: Dict[str, Any] = {
            "idx": q_idx,
            "type": q_type,
            "skill": defaults.get("skill", "READING"),
            "difficulty": infer_difficulty(q_idx),
            "promptMd": prompt_md,
            "explanationMd": None,
            "options": [],
            "shortAnswerAcceptRegex": [],
        }

        if (q.get("type") or "") == "SELECT":
            for opt in (q.get("options") or []):
                q_out["options"].append(
                    {
                        "idx": len(q_out["options"]) + 1,
                        "contentMd": opt.get("text") if opt.get("text") is not None else opt.get("id"),
                        "isCorrect": (opt.get("id") == q.get("correctAnswerId")),
                    }
                )

        elif (q.get("type") or "") == "TEXT":
            ans = q.get("correctAnswerText") or ""
            q_out["shortAnswerAcceptRegex"] = make_accept_regexes(ans)

        section["questions"].append(q_out)

    exam = {
        "slug": slug,
        "title": title,
        "descriptionMd": description_md,
        "category": defaults["category"],
        "level": defaults["level"],
        "status": defaults["status"],
        "durationMin": defaults["durationMin"],
        "sections": [section],
    }
    return [exam]

def parse_schema_import_file(obj: Dict[str, Any], defaults: Dict[str, Any]) -> List[Dict[str, Any]]:
    # Expect {"schemaVersion": "...", "exams": [ ... ]}
    exams = obj.get("exams") or []
    out: List[Dict[str, Any]] = []
    for e in exams:
        out.append(
            {
                "id": e.get("id"),
                "slug": e["slug"],
                "title": e["title"],
                "descriptionMd": e.get("descriptionMd") or "",
                "category": e.get("category") or defaults["category"],
                "level": e.get("level") or defaults["level"],
                "status": e.get("status") or defaults["status"],
                "durationMin": int(e.get("durationMin") or defaults["durationMin"]),
                "sections": [
                    {
                        "id": s.get("id"),
                        "idx": int(s["idx"]),
                        "title": s["title"],
                        "instructionsMd": s.get("instructionsMd") or "",
                        "audioUrl": s.get("audioUrl"),
                        "transcriptMd": s.get("transcriptMd"),
                        "questions": [
                            {
                                "id": q.get("id"),
                                "idx": int(q["idx"]),
                                "type": q["type"],
                                "skill": q.get("skill") or defaults.get("skill", "READING"),
                                "difficulty": int(q.get("difficulty") or 3),
                                "promptMd": q.get("promptMd") or "",
                                "explanationMd": q.get("explanationMd"),
                                "options": [
                                    {
                                        "id": o.get("id"),
                                        "idx": int(o["idx"]),
                                        "contentMd": o.get("contentMd") or "",
                                        "isCorrect": bool(o.get("isCorrect")),
                                    }
                                    for o in (q.get("options") or [])
                                ],
                                "shortAnswerAcceptRegex": list(q.get("shortAnswerAcceptRegex") or []),
                            }
                            for q in (s.get("questions") or [])
                        ],
                    }
                    for s in (e.get("sections") or [])
                ],
            }
        )
    return out

def load_exams_from_json(path: Path, defaults: Dict[str, Any]) -> List[Dict[str, Any]]:
    obj = json.loads(path.read_text(encoding="utf-8"))

    # 1) import-schema format
    if isinstance(obj, dict) and "schemaVersion" in obj and "exams" in obj:
        return parse_schema_import_file(obj, defaults)

    # 2) mini-ielts format
    if isinstance(obj, dict) and "passage" in obj and "questionGroups" in obj and "questions" in obj:
        return parse_mini_ielts_file(obj, defaults)

    # 3) single exam already in schema "exam" shape
    if isinstance(obj, dict) and "slug" in obj and "sections" in obj and "category" in obj:
        return parse_schema_import_file({"schemaVersion": "direct", "exams": [obj]}, defaults)

    raise ValueError(f"Unsupported JSON format: {path.name}")

# ---------- SQL generator ----------

def generate_sql_for_exam(exam: Dict[str, Any], ns_uuid: uuid.UUID) -> str:
    slug = exam["slug"]
    exam_id = exam.get("id") or stable_uuid(ns_uuid, f"exam:{slug}")
    now_fn = "now()"

    out: List[str] = []
    out += ["BEGIN;", "CREATE EXTENSION IF NOT EXISTS pgcrypto;", ""]

    # cleanup by slug
    out += [
        'DELETE FROM exam_options WHERE "QuestionId" IN (',
        '  SELECT q."Id" FROM exam_questions q',
        '  JOIN exam_sections s ON s."Id" = q."SectionId"',
        '  JOIN exams e ON e."Id" = s."ExamId"',
        f"  WHERE e.\"Slug\" = '{pg_escape_literal(slug)}'",
        ");",
        'DELETE FROM exam_questions USING exam_sections s, exams e',
        'WHERE exam_questions."SectionId" = s."Id"',
        '  AND s."ExamId" = e."Id"',
        f"  AND e.\"Slug\" = '{pg_escape_literal(slug)}';",
        'DELETE FROM exam_sections USING exams e',
        'WHERE exam_sections."ExamId" = e."Id"',
        f"  AND e.\"Slug\" = '{pg_escape_literal(slug)}';",
        f"DELETE FROM exams WHERE \"Slug\" = '{pg_escape_literal(slug)}';",
        "",
    ]

    # exams
    out += [
        'INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")',
        "VALUES ("
        + ", ".join(
            [
                f"'{exam_id}'",
                f"'{pg_escape_literal(slug)}'",
                dollar_quote(exam["title"], "t"),
                dollar_quote(exam.get("descriptionMd") or "", "md"),
                f"'{exam['category']}'",
                f"'{exam['level']}'",
                f"'{exam.get('status') or 'DRAFT'}'",
                str(int(exam.get("durationMin") or 30)),
                now_fn,
            ]
        )
        + ");",
        "",
    ]

    # sections + questions + options
    for sec in exam.get("sections") or []:
        sec_idx = int(sec["idx"])
        sec_id = sec.get("id") or stable_uuid(ns_uuid, f"section:{slug}:{sec_idx}")
        audio = sec.get("audioUrl")
        trans = sec.get("transcriptMd")

        out += [
            'INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")',
            "VALUES ("
            + ", ".join(
                [
                    f"'{sec_id}'",
                    f"'{exam_id}'",
                    str(sec_idx),
                    dollar_quote(sec["title"], "t"),
                    dollar_quote(sec.get("instructionsMd") or "", "md"),
                    ("NULL" if not audio else f"'{pg_escape_literal(audio)}'"),
                    ("NULL" if not trans else dollar_quote(trans, "md")),
                ]
            )
            + ");",
            "",
        ]

        for q in sec.get("questions") or []:
            q_idx = int(q["idx"])
            q_id = q.get("id") or stable_uuid(ns_uuid, f"question:{slug}:{sec_idx}:{q_idx}")

            cols = [
                '"Id"',
                '"SectionId"',
                '"Idx"',
                '"Type"',
                '"Skill"',
                '"Difficulty"',
                '"PromptMd"',
                '"ExplanationMd"',
            ]
            vals = [
                f"'{q_id}'",
                f"'{sec_id}'",
                str(q_idx),
                f"'{q['type']}'",
                f"'{q.get('skill') or 'READING'}'",
                str(int(q.get("difficulty") or 3)),
                dollar_quote(q.get("promptMd") or "", "md"),
                ("NULL" if q.get("explanationMd") is None else dollar_quote(q.get("explanationMd"), "md")),
            ]

            sar = q.get("shortAnswerAcceptRegex") or []
            if sar:
                cols.append('"ShortAnswerAcceptRegex"')
                arr = "ARRAY[" + ",".join(f"'{pg_escape_literal(r)}'" for r in sar) + "]"
                vals.append(arr)

            out += [
                f"INSERT INTO exam_questions ({','.join(cols)})",
                f"VALUES ({', '.join(vals)});",
            ]

            for opt in q.get("options") or []:
                opt_idx = int(opt["idx"])
                opt_id = opt.get("id") or stable_uuid(ns_uuid, f"option:{slug}:{sec_idx}:{q_idx}:{opt_idx}")
                out += [
                    'INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")',
                    "VALUES ("
                    + ", ".join(
                        [
                            f"'{opt_id}'",
                            f"'{q_id}'",
                            str(opt_idx),
                            dollar_quote(opt.get("contentMd") or "", "md"),
                            ("true" if opt.get("isCorrect") else "false"),
                        ]
                    )
                    + ");",
                ]

            out.append("")

    out += ["COMMIT;", ""]
    return "\n".join(out)

# ---------- main ----------

def main() -> int:
    ap = argparse.ArgumentParser(description="Convert exam JSON files in a folder to PostgreSQL seed .sql files.")
    ap.add_argument("input_dir", help="Folder containing .json files")
    ap.add_argument("--out", default="out_sql", help="Output folder for .sql files (default: out_sql)")
    ap.add_argument("--combined", default=None, help="Also write one combined SQL file (e.g. all.sql)")
    ap.add_argument("--category", default="IELTS", choices=["IELTS", "TOEIC", "VSTEP", "PLACEMENT"])
    ap.add_argument("--level", default="B2", choices=["A1", "A2", "B1", "B2", "C1", "C2"])
    ap.add_argument("--status", default="DRAFT", choices=["DRAFT", "PUBLISHED", "ARCHIVED"])
    ap.add_argument("--duration-min", type=int, default=20)
    ap.add_argument("--namespace-uuid", default="12345678-1234-5678-1234-567812345678",
                    help="UUID namespace for deterministic IDs (default is a fixed demo uuid). "
                         "Change this ONCE in your project for stable IDs across runs.")
    ap.add_argument("--include", default=None,
                    help="Regex for filenames to include (e.g. '.*\\.exam\\.json$'). If omitted, includes all .json.")
    ap.add_argument("--exclude", default=r".*exam-import\.schema\.json$",
                    help="Regex for filenames to exclude (default excludes exam-import.schema.json).")
    args = ap.parse_args()

    in_dir = Path(args.input_dir)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    inc_re = re.compile(args.include) if args.include else None
    exc_re = re.compile(args.exclude) if args.exclude else None

    defaults = {
        "category": args.category,
        "level": args.level,
        "status": args.status,
        "durationMin": args.duration_min,
        "skill": "READING",
        "title_fallback": "Exam",
    }

    ns_uuid = uuid.UUID(args.namespace_uuid)

    combined_chunks: List[str] = []

    json_files = sorted([p for p in in_dir.glob("*.json") if p.is_file()])
    if inc_re:
        json_files = [p for p in json_files if inc_re.search(p.name)]
    if exc_re:
        json_files = [p for p in json_files if not exc_re.search(p.name)]

    if not json_files:
        raise SystemExit(f"No JSON files found in {in_dir.resolve()} matching filters.")

    for p in json_files:
        try:
            exams = load_exams_from_json(p, defaults)
        except Exception as e:
            print(f"[SKIP] {p.name}: {e}")
            continue

        for exam in exams:
            sql = generate_sql_for_exam(exam, ns_uuid)
            out_path = out_dir / f"{exam['slug']}.sql"
            out_path.write_text(sql, encoding="utf-8")
            print(f"[OK] {p.name} -> {out_path.name}")

            if args.combined:
                combined_chunks.append(sql)

    if args.combined and combined_chunks:
        combined_path = out_dir / args.combined
        # write as-is (each exam already has BEGIN/COMMIT like your sample)
        combined_path.write_text("\n\n".join(combined_chunks), encoding="utf-8")
        print(f"[OK] Combined -> {combined_path.name}")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
