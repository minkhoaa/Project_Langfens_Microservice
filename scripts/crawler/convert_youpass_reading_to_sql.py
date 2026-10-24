#!/usr/bin/env python3
"""
Convert selected 5 clean, native Q1-indexed YouPass IELTS Reading Practice tests to Langfens PostgreSQL seed SQL.
Strictly append-only: uses unique slugs (youpass-reading-practice-*) and IF EXISTS RETURN logic.
Zero destructive operations (NO DELETE / DROP).
Native source order is already Q1..QN, perfectly aligned with UI numbering.
"""

import json
import re
import uuid
import sys
import os
from pathlib import Path

NS_LANGFENS = uuid.uuid5(uuid.NAMESPACE_DNS, "langfens.com")

def deterministic_uuid(name: str) -> str:
    return str(uuid.uuid5(NS_LANGFENS, name))

def escape_sql(text: str) -> str:
    if not text:
        return ""
    return text.replace("'", "''").replace("\\", "\\\\")

def normalize_blank_prompt(prompt: str, q_idx: int) -> str:
    if not prompt or not prompt.strip():
        return f"Question [{q_idx}]"
    
    pattern = r'\[\s*\(\s*\d+\s*\)\s*_{2,}\s*\]|\[\s*_{2,}\s*\]|_{3,}|\.{3,}'
    if re.search(pattern, prompt):
        return re.sub(pattern, f"[{q_idx}]", prompt, count=1).strip()
    if f"[{q_idx}]" not in prompt:
        return f"{prompt.strip()} [{q_idx}]"
    return prompt.strip()

def convert_test(json_path: str, unique_slug: str) -> list[str]:
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    raw_title = data.get("title", "Untitled Exam")
    display_title = re.sub(r'^\[.*?\]\s*-\s*', '', raw_title).strip()
    display_title = f"IELTS Reading: {display_title}"
    
    exam_id = deterministic_uuid(f"exam:{unique_slug}")
    duration = data.get("time_minutes", 20)
    category = "IELTS"
    level = "B2"
    status = "PUBLISHED"
    description = escape_sql(f"IELTS Academic Reading Practice: {display_title}")
    title = escape_sql(display_title)

    lines = []
    lines.append(f"-- ============================================================")
    lines.append(f"-- Exam: {display_title}")
    lines.append(f"-- Slug: {unique_slug}")
    lines.append(f"-- Source: {os.path.basename(json_path)}")
    lines.append(f"-- ============================================================")
    lines.append(f"DO $$")
    lines.append(f"BEGIN")
    lines.append(f"  -- Check if exam already exists (strictly append-only)")
    lines.append(f"  IF EXISTS (SELECT 1 FROM exams WHERE \"Slug\" = '{unique_slug}') THEN")
    lines.append(f"    RAISE NOTICE 'Exam with slug % already exists, skipping.', '{unique_slug}';")
    lines.append(f"    RETURN;")
    lines.append(f"  END IF;")
    lines.append("")
    lines.append(f"  -- Insert Exam")
    lines.append(f"  INSERT INTO exams (\"Id\", \"Slug\", \"Title\", \"DescriptionMd\", \"Category\", \"Level\", \"Status\", \"DurationMin\", \"CreatedAt\", \"UpdatedAt\")")
    lines.append(f"  VALUES ('{exam_id}', '{unique_slug}', E'{title}', E'{description}', '{category}', '{level}', '{status}', {duration}, now(), now());")
    lines.append("")

    q_idx_counter = 0

    for part_idx, part in enumerate(data.get("parts", []), 1):
        sec_id = deterministic_uuid(f"section:{unique_slug}:{part_idx}")
        sec_title = escape_sql(part.get("title") or f"Reading Passage")
        passage = escape_sql(part.get("passage_or_transcript") or "")

        lines.append(f"  -- Insert Section {part_idx}")
        lines.append(f"  INSERT INTO exam_sections (\"Id\", \"ExamId\", \"Idx\", \"Title\", \"PassageMd\", \"InstructionsMd\")")
        lines.append(f"  VALUES ('{sec_id}', '{exam_id}', {part_idx}, E'{sec_title}', E'{passage}', E'Read the passage and answer the questions.');")
        lines.append("")

        qsets = part.get("question_sets", [])
        for qs_idx, qs in enumerate(qsets, 1):
            raw_questions = qs.get("questions", [])
            if not raw_questions:
                continue

            start_q_idx = q_idx_counter + 1
            end_q_idx = q_idx_counter + len(raw_questions)

            qs_title = f"Questions {start_q_idx}–{end_q_idx}"
            qs_desc = qs.get("description") or ""
            qs_desc_clean = re.sub(r'Questions\s+\d+\s*[-–—]\s*\d+', f'Questions {start_q_idx}–{end_q_idx}', qs_desc)
            qs_desc_clean = re.sub(r'boxes\s+\d+\s*[-–—]\s*\d+', f'boxes {start_q_idx}–{end_q_idx}', qs_desc_clean, flags=re.I)
            
            options_pool = qs.get("options_pool") or []

            instruction_parts = [f"### {qs_title}"]
            if qs_desc_clean:
                instruction_parts.append(qs_desc_clean)
            
            if options_pool and any(q.get("question_type") == "MATCHING_HEADING" for q in raw_questions):
                instruction_parts.append("**List of Headings:**\n" + "\n".join(f"- {opt}" for opt in options_pool))
            elif options_pool and any(q.get("question_type") in ["MATCHING_NAMES", "MATCHING_FEATURES"] for q in raw_questions):
                instruction_parts.append("**List of Options:**\n" + "\n".join(f"- {opt}" for opt in options_pool))
            elif options_pool and any(q.get("question_type") in ["MATCHING", "MATCHING_ENDINGS"] for q in raw_questions):
                instruction_parts.append("**List of Endings:**\n" + "\n".join(f"- {opt}" for opt in options_pool))

            instruction_md = escape_sql("\n\n".join(instruction_parts))

            group_id = deterministic_uuid(f"group:{unique_slug}:{part_idx}:{qs_idx}")
            lines.append(f"  -- Insert Question Group {qs_idx}")
            lines.append(f"  INSERT INTO exam_question_groups (\"Id\", \"SectionId\", \"Idx\", \"StartIdx\", \"EndIdx\", \"InstructionMd\")")
            lines.append(f"  VALUES ('{group_id}', '{sec_id}', {qs_idx}, {start_q_idx}, {end_q_idx}, E'{instruction_md}');")
            lines.append("")

            for q in raw_questions:
                q_idx_counter += 1
                q_idx = q_idx_counter
                qid = deterministic_uuid(f"question:{unique_slug}:{q_idx}")

                q_type_raw = q.get("question_type") or "MULTIPLE_CHOICE_ONE"
                raw_ans = q.get("correct_answer")
                prompt_raw = q.get("text") or ""
                explanation_raw = q.get("explanation") or ""

                options = list(q.get("options") or [])
                if not options and options_pool:
                    options = list(options_pool)

                blank_accept_json = "NULL"
                match_pairs_json = "NULL"
                short_answer_array = "NULL"

                if q_type_raw == "TRUE_FALSE":
                    canonical_type = "TRUE_FALSE_NOT_GIVEN"
                    prompt = prompt_raw or f"Statement {q_idx}"
                    options = ["TRUE", "FALSE", "NOT GIVEN"]
                    correct_norm = str(raw_ans).strip().upper()

                elif q_type_raw == "YES_NO":
                    canonical_type = "YES_NO_NOT_GIVEN"
                    prompt = prompt_raw or f"Statement {q_idx}"
                    options = ["YES", "NO", "NOT GIVEN"]
                    correct_norm = str(raw_ans).strip().upper()

                elif q_type_raw in ["SUMMARY_COMPLETION", "SENTENCE_COMPLETION", "FILL_BLANK"]:
                    canonical_type = "SENTENCE_COMPLETION" if q_type_raw == "SENTENCE_COMPLETION" else "SUMMARY_COMPLETION"
                    prompt = normalize_blank_prompt(prompt_raw, q_idx)
                    accept_list = raw_ans if isinstance(raw_ans, list) else [str(raw_ans)]
                    blank_map = {str(q_idx): accept_list}
                    blank_accept_json = f"'{escape_sql(json.dumps(blank_map))}'::jsonb"
                    options = []
                    correct_norm = None

                elif q_type_raw in ["MATCHING_HEADING", "MATCHING_INFO", "MATCHING", "MATCHING_NAMES", "MATCHING_ENDINGS", "MATCHING_FEATURES"]:
                    if q_type_raw == "MATCHING_HEADING":
                        canonical_type = "MATCHING_HEADING"
                    elif q_type_raw == "MATCHING_INFO":
                        canonical_type = "MATCHING_INFORMATION"
                    elif q_type_raw in ["MATCHING_NAMES", "MATCHING_FEATURES"]:
                        canonical_type = "MATCHING_FEATURES"
                    else:
                        canonical_type = "MATCHING_ENDINGS"

                    prompt = prompt_raw or f"Item {q_idx}"
                    correct_val = str(raw_ans).strip()
                    display_text = correct_val
                    for opt in options:
                        if opt.strip().startswith(correct_val):
                            display_text = opt.strip()
                            break
                    pair_map = {str(q_idx): [correct_val, display_text]}
                    match_pairs_json = f"'{escape_sql(json.dumps(pair_map))}'::jsonb"
                    correct_norm = correct_val

                else:
                    canonical_type = "MULTIPLE_CHOICE_SINGLE"
                    prompt = prompt_raw or f"Question {q_idx}"
                    correct_norm = str(raw_ans).strip().upper()

                prompt_esc = escape_sql(prompt)
                exp_esc = escape_sql(explanation_raw)

                lines.append(f"  -- Question {q_idx} ({canonical_type})")
                lines.append(f"  INSERT INTO exam_questions (\"Id\", \"SectionId\", \"GroupId\", \"Idx\", \"Type\", \"Skill\", \"Difficulty\", \"PromptMd\", \"ExplanationMd\", \"BlankAcceptTexts\", \"MatchPairs\", \"ShortAnswerAcceptTexts\")")
                lines.append(f"  VALUES ('{qid}', '{sec_id}', '{group_id}', {q_idx}, '{canonical_type}', 'READING', 2, E'{prompt_esc}', E'{exp_esc}', {blank_accept_json}, {match_pairs_json}, {short_answer_array});")

                for opt_idx, opt_text in enumerate(options, 1):
                    opt_id = deterministic_uuid(f"opt:{qid}:{opt_idx}")
                    opt_str = str(opt_text).strip()
                    opt_esc = escape_sql(opt_str)

                    is_correct = False
                    if canonical_type in ["TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"]:
                        is_correct = (opt_str.upper() == str(correct_norm).upper())
                    elif canonical_type == "MULTIPLE_CHOICE_SINGLE":
                        c_let = str(correct_norm).strip().upper()
                        if opt_str.upper().startswith(f"{c_let}.") or opt_str.upper().startswith(f"{c_let} ") or opt_str.upper() == c_let:
                            is_correct = True
                        elif opt_str.lower() == str(correct_norm).lower():
                            is_correct = True
                    elif canonical_type in ["MATCHING_HEADING", "MATCHING_FEATURES", "MATCHING_ENDINGS", "MATCHING_INFORMATION"]:
                        c_let = str(correct_norm).strip().upper()
                        if opt_str.upper().startswith(f"{c_let}.") or opt_str.upper().startswith(f"{c_let} ") or opt_str.upper() == c_let:
                            is_correct = True

                    is_correct_sql = "true" if is_correct else "false"
                    lines.append(f"  INSERT INTO exam_options (\"Id\", \"QuestionId\", \"Idx\", \"ContentMd\", \"IsCorrect\")")
                    lines.append(f"  VALUES ('{opt_id}', '{qid}', {opt_idx}, E'{opt_esc}', {is_correct_sql});")

                lines.append("")

    lines.append(f"  RAISE NOTICE 'Successfully seeded exam % with % questions.', '{unique_slug}', {q_idx_counter};")
    lines.append(f"END$$;")
    lines.append("")
    return lines

def main():
    test_configs = [
        ("youpass_ielts/data/reading/practice/json/10009_youpass-collect-the-impact-of-the-potato.json", "youpass-reading-practice-impact-of-the-potato"),
        ("youpass_ielts/data/reading/practice/json/10011_youpass-collect-caral-an-ancient-south-american-city.json", "youpass-reading-practice-caral-ancient-city"),
        ("youpass_ielts/data/reading/practice/json/10425_youpass-collect-reading-in-a-whole-new-way.json", "youpass-reading-practice-reading-in-a-whole-new-way"),
        ("youpass_ielts/data/reading/practice/json/10282_youpass-collect-western-immigration-of-canada.json", "youpass-reading-practice-western-immigration-of-canada"),
        ("youpass_ielts/data/reading/practice/json/8033_actual-test-the-legend-of-tea.json", "youpass-reading-practice-the-legend-of-tea"),
    ]

    out_file = Path("deploy/seeds/seed_youpass_reading_5_exams.sql")
    all_lines = [
        "-- ============================================================",
        "-- Langfens IELTS: YouPass Reading 5-Exam Seed Pack",
        "-- Strictly append-only: checks slug existence before insert",
        "-- Zero destructive operations (NO DELETE / DROP)",
        "-- Native source order starting at Q1..QN",
        "-- ============================================================",
        "",
        "BEGIN;",
        "CREATE EXTENSION IF NOT EXISTS pgcrypto;",
        "",
    ]

    for fpath, slug in test_configs:
        if not os.path.exists(fpath):
            print(f"Error: {fpath} does not exist", file=sys.stderr)
            sys.exit(1)
        all_lines.extend(convert_test(fpath, slug))

    all_lines.append("COMMIT;")
    all_lines.append("")

    out_file.parent.mkdir(parents=True, exist_ok=True)
    with open(out_file, "w", encoding="utf-8") as f:
        f.write("\n".join(all_lines))

    print(f"Successfully generated seed file: {out_file} ({out_file.stat().st_size:,} bytes)")

if __name__ == "__main__":
    main()
