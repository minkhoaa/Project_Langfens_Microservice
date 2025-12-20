#!/usr/bin/env python3
"""
Stage 8: Exporter
Exports normalized JSON to SQL seed files.
"""
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Optional

from config import NORMALIZED_DIR, OUTPUT_DIR, SEEDS_DIR, get_logger

logger = get_logger(__name__)


def escape_sql(text: str) -> str:
    """Escape text for SQL strings."""
    if not text:
        return ''
    return text.replace("'", "''").replace("\\", "\\\\")


def load_normalized(source: str, item_id: str) -> Optional[dict]:
    """Load normalized JSON from disk."""
    source_dir = NORMALIZED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        logger.error(f"Normalized data not found: {data_path}")
        return None
    
    return json.loads(data_path.read_text(encoding='utf-8'))


def generate_sql(data: dict) -> str:
    """Generate SQL insert statements from normalized data."""
    exam = data.get('exam', {})
    sections = data.get('sections', [])
    questions = data.get('questions', [])
    
    title = exam.get('title', 'IELTS Reading Test')
    slug = exam.get('slug', 'ielts-reading-test')
    
    sql_lines = [
        "-- ============================================",
        f"-- IELTS Exam Data Import SQL",
        f"-- Generated: {datetime.now().isoformat()}",
        f"-- Pipeline: v2.0",
        f"-- Title: {title}",
        "-- ============================================",
        "",
        "BEGIN;",
        "CREATE EXTENSION IF NOT EXISTS pgcrypto;",
        "",
        f"-- Cleanup existing data for slug: {slug}",
        f"DELETE FROM exam_options WHERE \"QuestionId\" IN (",
        f"  SELECT q.\"Id\" FROM exam_questions q",
        f"  JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\"",
        f"  JOIN exams e ON e.\"Id\" = s.\"ExamId\"",
        f"  WHERE e.\"Slug\" = '{slug}'",
        ");",
        f"DELETE FROM exam_questions USING exam_sections s, exams e",
        f"WHERE exam_questions.\"SectionId\" = s.\"Id\"",
        f"  AND s.\"ExamId\" = e.\"Id\"",
        f"  AND e.\"Slug\" = '{slug}';",
        f"DELETE FROM exam_sections USING exams e",
        f"WHERE exam_sections.\"ExamId\" = e.\"Id\"",
        f"  AND e.\"Slug\" = '{slug}';",
        f"DELETE FROM exams WHERE \"Slug\" = '{slug}';",
        "",
        "DO $$",
        "DECLARE",
        "  exam_id uuid := gen_random_uuid();",
        "  sec1 uuid := gen_random_uuid();",
        "  qid uuid;",
        "BEGIN",
        "",
    ]
    
    # Insert exam
    sql_lines.extend([
        f"  INSERT INTO exams (\"Id\",\"Slug\",\"Title\",\"DescriptionMd\",\"Category\",\"Level\",\"Status\",\"DurationMin\",\"UpdatedAt\")",
        "  VALUES (",
        f"    exam_id,",
        f"    '{slug}',",
        f"    '{escape_sql(title)}',",
        f"    'IELTS Reading Practice Test',",
        f"    'IELTS',",
        f"    'B2',",
        f"    'PUBLISHED',",
        f"    20,",
        f"    now()",
        "  );",
        "",
    ])
    
    # Insert section
    if sections:
        section = sections[0]
        passage = escape_sql(section.get('passage_md', '')[:8000])
        sql_lines.extend([
            f"  INSERT INTO exam_sections (\"Id\",\"ExamId\",\"Idx\",\"Title\",\"InstructionsMd\")",
            "  VALUES (",
            f"    sec1,",
            f"    exam_id,",
            f"    1,",
            f"    '{escape_sql(section.get('title', 'Reading Passage'))}',",
            f"    E'# Passage\\n\\n{passage}'",
            "  );",
            "",
        ])
    
    # Insert questions
    for q in questions:
        q_type = q.get('type', 'SUMMARY_COMPLETION')
        q_prompt = escape_sql(q.get('prompt_md', ''))
        q_idx = q.get('idx', 1)
        options = q.get('options', [])
        correct_answers = q.get('correct_answers', [])
        
        # Build type-specific fields
        match_pairs_sql = 'NULL'
        blank_accepts_sql = 'NULL'
        
        if q_type in ['MATCHING_INFORMATION', 'MATCHING_HEADING', 'MATCHING_FEATURES']:
            if correct_answers:
                correct = correct_answers[0]
                key = f"match-q{q_idx}"
                match_pairs_sql = f"'{{\"{key}\": [\"{escape_sql(correct)}\"]}}'"
        
        if q_type == 'SUMMARY_COMPLETION':
            if correct_answers:
                blank_key = f"blank-q{q_idx}"
                blank_dict = {blank_key: correct_answers}
                blank_accepts_sql = f"'{json.dumps(blank_dict)}'::jsonb"
            
            sql_lines.extend([
                f"  qid := gen_random_uuid();",
                f"  INSERT INTO exam_questions (\"Id\",\"SectionId\",\"Idx\",\"Type\",\"Skill\",\"Difficulty\",\"PromptMd\",\"ExplanationMd\",\"BlankAcceptTexts\")",
                f"  VALUES (",
                f"    qid,",
                f"    sec1,",
                f"    {q_idx},",
                f"    '{q_type}',",
                f"    'READING',",
                f"    2,",
                f"    '{q_prompt}',",
                f"    'Complete the blank.',",
                f"    {blank_accepts_sql}",
                f"  );",
                "",
            ])
        else:
            sql_lines.extend([
                f"  qid := gen_random_uuid();",
                f"  INSERT INTO exam_questions (\"Id\",\"SectionId\",\"Idx\",\"Type\",\"Skill\",\"Difficulty\",\"PromptMd\",\"ExplanationMd\",\"MatchPairs\")",
                f"  VALUES (",
                f"    qid,",
                f"    sec1,",
                f"    {q_idx},",
                f"    '{q_type}',",
                f"    'READING',",
                f"    2,",
                f"    '{q_prompt}',",
                f"    'Choose the correct answer.',",
                f"    {match_pairs_sql}",
                f"  );",
            ])
            
            # Insert options
            for i, opt in enumerate(options):
                is_correct = 'true' if opt.get('is_correct') else 'false'
                opt_label = escape_sql(opt.get('label', opt.get('value', '')))
                sql_lines.append(
                    f"  INSERT INTO exam_options (\"Id\",\"QuestionId\",\"Idx\",\"ContentMd\",\"IsCorrect\") VALUES "
                    f"(gen_random_uuid(), qid, {i+1}, '{opt_label}', {is_correct});"
                )
            sql_lines.append("")
    
    sql_lines.extend([
        "",
        "END$$;",
        "",
        "COMMIT;",
    ])
    
    return '\n'.join(sql_lines)


def export_to_sql(source: str, item_id: str) -> Optional[Path]:
    """Export normalized JSON to SQL seed file."""
    data = load_normalized(source, item_id)
    if not data:
        return None
    
    logger.info(f"Exporting: {source}/{item_id}")
    
    sql = generate_sql(data)
    
    # Save to seeds directory
    slug = data.get('exam', {}).get('slug', f'{source}-{item_id}')
    sql_path = SEEDS_DIR / f"seed_exam_{slug}.sql"
    sql_path.write_text(sql, encoding='utf-8')
    
    # Also save to output directory
    output_dir = OUTPUT_DIR / source
    output_dir.mkdir(parents=True, exist_ok=True)
    
    json_path = output_dir / f"{item_id}.json"
    json_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    
    logger.info(f"Saved SQL: {sql_path}")
    logger.info(f"Saved JSON: {json_path}")
    
    return sql_path


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python exporter.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    path = export_to_sql(source, item_id)
    if path:
        print(f"✓ Saved to: {path}")
    else:
        print("✗ Export failed")
        sys.exit(1)
