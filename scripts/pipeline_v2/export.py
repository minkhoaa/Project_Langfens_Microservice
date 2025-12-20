#!/usr/bin/env python3
"""
Stage 5: Export
Exports extracted data to SQL using OLD CRAWLER generate_sql() function.
"""
import json
import re
import importlib.util
from pathlib import Path
from typing import Optional

from config import SEEDS_DIR, OUTPUT_DIR, get_logger

logger = get_logger(__name__)

# Directory for normalized data (after repair)
NORMALIZED_DIR = Path(__file__).parent.parent.parent / "data" / "normalized"

# Import old crawler modules
def load_crawler_module(name: str, filename: str):
    """Load old crawler module dynamically."""
    try:
        spec = importlib.util.spec_from_file_location(
            name,
            Path(__file__).parent.parent / "crawler" / filename
        )
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module
    except Exception as e:
        logger.error(f"Failed to import {filename}: {e}")
        return None

crawler_ieltsmentor = load_crawler_module("crawler_ieltsmentor", "crawler-ieltsmentor.py")
crawler_ieltswriting = load_crawler_module("crawler_ieltswriting", "crawler-ieltswriting.py")

if crawler_ieltsmentor:
    logger.info("Successfully imported crawler-ieltsmentor.py")
if crawler_ieltswriting:
    logger.info("Successfully imported crawler-ieltswriting.py")


def load_normalized(source: str, item_id: str) -> Optional[dict]:
    """Load NORMALIZED data from disk (after validate/repair stages)."""
    source_dir = NORMALIZED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        logger.error(f"Normalized data not found: {data_path}")
        return None
    
    return json.loads(data_path.read_text(encoding='utf-8'))


def export_sql(source: str, item_id: str) -> Optional[Path]:
    """
    Export NORMALIZED data to SQL using OLD CRAWLER generate_sql().
    Uses data from normalize/repair stages, not raw extracted data.
    """
    data = load_normalized(source, item_id)
    if not data:
        return None
    
    logger.info(f"Exporting SQL: {source}/{item_id}")
    
    # Handle both old flat format and new normalized nested format
    # Normalized format: {exam: {...}, sections: [...], questions: [...]}
    # Flat format: {title, exam_id, passages, questions}
    
    if 'exam' in data:
        # Normalized format
        exam = data.get('exam', {})
        sections = data.get('sections', [])
        questions = data.get('questions', [])
        
        # Convert sections to passages format expected by old crawler
        passages = []
        for section in sections:
            passages.append({
                'text': section.get('passage_md', section.get('title', '')),
                'instruction_md': section.get('instruction_md', '')
            })
        
        # Convert questions from normalized format (prompt_md, correct_answers)
        # to old crawler format (prompt, correct_answer)
        converted_questions = []
        for q in questions:
            converted_q = {
                'idx': q.get('idx'),
                'type': q.get('type'),
                'prompt': q.get('prompt_md', q.get('prompt', '')),
                'correct_answer': q.get('correct_answers', [''])[0] if q.get('correct_answers') else q.get('correct_answer', ''),
                'options': q.get('options', []),
            }
            converted_questions.append(converted_q)
        
        sql_data = {
            'title': exam.get('title', 'IELTS Reading Test'),
            'exam_id': data.get('_metadata', {}).get('item_id', item_id),
            'passages': passages,
            'questions': converted_questions,
        }
    else:
        # Flat format (legacy)
        sql_data = {
            'title': data.get('title', 'IELTS Reading Test'),
            'exam_id': data.get('exam_id', item_id),
            'passages': data.get('passages', []),
            'questions': data.get('questions', []),
        }
    
    # Use OLD CRAWLER generate_sql function directly
    if source == 'ielts-mentor':
        sql = crawler_ieltsmentor.generate_sql(sql_data)
        title = sql_data['title']
        slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
        slug = f"ielts-mentor-{slug}"
    elif source == 'ielts-writing':
        sql = crawler_ieltswriting.generate_sql(sql_data)
        title = sql_data['title']
        slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
        slug = f"ielts-writing-{slug}"
    else:
        logger.error(f"Unknown source: {source}")
        return None
    
    # Save SQL to seeds directory
    sql_path = SEEDS_DIR / f"seed_exam_{slug}.sql"
    sql_path.write_text(sql, encoding='utf-8')
    
    # Also save final JSON to output directory
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
        print("Usage: python export.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    path = export_sql(source, item_id)
    if path:
        print(f"✓ Exported: {path}")
    else:
        print("✗ Export failed")
        sys.exit(1)
