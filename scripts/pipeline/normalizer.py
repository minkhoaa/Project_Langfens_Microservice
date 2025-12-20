#!/usr/bin/env python3
"""
Stage 4: Normalizer
Transforms parsed rough JSON into normalized exam-import.schema.json format.
Uses rule-based approach (no AI).
"""
import json
import re
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional, Any

from config import PARSED_DIR, NORMALIZED_DIR, get_logger

logger = get_logger(__name__)


def load_parsed(source: str, item_id: str) -> Optional[dict]:
    """Load parsed JSON from disk."""
    source_dir = PARSED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        logger.error(f"Parsed data not found: {data_path}")
        return None
    
    content = json.loads(data_path.read_text(encoding='utf-8'))
    return content.get('data') or content


def generate_slug(source: str, item_id: str, title: str = '') -> str:
    """Generate URL-friendly slug."""
    base = title or item_id
    slug = re.sub(r'[^a-z0-9]+', '-', base.lower()).strip('-')
    return f"{source}-{slug}"[:100]


def extract_title(data: dict) -> str:
    """Extract title from parsed data."""
    # Try to find title in passage or sections
    passage_text = data.get('passage', {}).get('text', '')
    
    # Look for title pattern
    title_match = re.match(r'^([A-Z][^\n]{10,50})', passage_text)
    if title_match:
        return title_match.group(1).strip()
    
    return f"IELTS Reading - {data.get('item_id', 'Unknown')}"


def normalize_passage(data: dict) -> str:
    """Normalize passage text to markdown."""
    passage = data.get('passage', {}).get('text', '')
    
    # Clean up
    passage = re.sub(r'\n{3,}', '\n\n', passage)
    
    # Format paragraph markers
    passage = re.sub(r'(?:^|\n)\s*([A-G])\s+([A-Z])', r'\n\n**\1** \2', passage)
    
    return passage.strip()


def normalize_options(options: list[dict], correct_answer: str) -> list[dict]:
    """Normalize options with correct answer marked."""
    normalized = []
    for opt in options:
        value = opt.get('value', '')
        label = opt.get('label', value)
        is_correct = value.lower() == correct_answer.lower() if correct_answer else False
        
        normalized.append({
            'value': value,
            'label': label,
            'is_correct': is_correct,
        })
    return normalized


def normalize_question(q_data: dict, section_data: dict, answers: dict, heading_options: list) -> dict:
    """Normalize a single question."""
    q_num = q_data.get('idx') or q_data.get('q_num')
    q_type = q_data.get('type', 'SUMMARY_COMPLETION')
    prompt = q_data.get('prompt', q_data.get('text', f'Question {q_num}'))
    answer = answers.get(q_num, answers.get(str(q_num), ''))
    
    # Clean prompt
    prompt = re.sub(r'\s+', ' ', prompt).strip()
    
    # Build question
    question = {
        'id': str(uuid.uuid4()),
        'idx': q_num,
        'type': q_type,
        'prompt_md': f"{q_num}. {prompt}" if not prompt.startswith(str(q_num)) else prompt,
        'options': [],
        'correct_answers': [],
    }
    
    # Type-specific processing
    if q_type == 'MATCHING_HEADING':
        # Use heading options
        question['options'] = normalize_options(heading_options, answer)
        question['correct_answers'] = [answer] if answer else []
    
    elif q_type in ['MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE']:
        # Extract MC options from section text
        section_text = section_data.get('text', '')
        options = extract_mc_options(section_text, q_num, answer)
        question['options'] = options
        question['correct_answers'] = [answer] if answer else []
    
    elif q_type in ['TRUE_FALSE_NOT_GIVEN', 'YES_NO_NOT_GIVEN']:
        # Standard T/F/NG options
        if q_type == 'TRUE_FALSE_NOT_GIVEN':
            opts = ['TRUE', 'FALSE', 'NOT GIVEN']
        else:
            opts = ['YES', 'NO', 'NOT GIVEN']
        
        question['options'] = [
            {'value': opt, 'label': opt, 'is_correct': opt.upper() == answer.upper()}
            for opt in opts
        ]
        question['correct_answers'] = [answer] if answer else []
    
    elif q_type == 'SUMMARY_COMPLETION':
        # Just store correct answer
        question['correct_answers'] = [answer] if answer else []
    
    elif q_type in ['MATCHING_INFORMATION', 'MATCHING_FEATURES']:
        # Store correct answer
        question['correct_answers'] = [answer] if answer else []
    
    return question


def extract_mc_options(section_text: str, q_num: int, correct_answer: str) -> list[dict]:
    """Extract MC options for specific question."""
    options = []
    
    # Find text for this specific question
    next_q = q_num + 1
    q_pattern = rf'{q_num}\.\s*(.*?)(?={next_q}\.|Questions?\s+\d|$)'
    q_match = re.search(q_pattern, section_text, re.DOTALL)
    
    if q_match:
        q_text = q_match.group(1)
        # Extract A. B. C. D. options
        opt_pattern = r'(?:^|\n)\s*([A-D])\.\s+([^\n]+?)(?=\n\s*[A-D]\.|$)'
        matches = re.findall(opt_pattern, q_text, re.MULTILINE | re.DOTALL)
        
        for letter, text in matches:
            options.append({
                'value': letter.upper(),
                'label': f"{letter.upper()}. {text.strip()}",
                'is_correct': letter.upper() == correct_answer.upper() if correct_answer else False,
            })
    
    return options


def normalize_data(data: dict) -> dict:
    """Transform parsed data to normalized format."""
    source = data.get('source', 'unknown')
    item_id = data.get('item_id', 'unknown')
    title = extract_title(data)
    slug = generate_slug(source, item_id, title)
    
    passage_md = normalize_passage(data)
    answers = data.get('answers', {})
    # Convert string keys to int
    answers = {int(k) if isinstance(k, str) and k.isdigit() else k: v for k, v in answers.items()}
    
    heading_options = data.get('heading_options', [])
    sections_data = data.get('sections', [])
    
    # Build questions from sections
    questions = []
    for section in sections_data:
        start_q = section.get('start_q', 1)
        end_q = section.get('end_q', start_q)
        q_type = section.get('type', 'SUMMARY_COMPLETION')
        
        for q_num in range(start_q, end_q + 1):
            answer = answers.get(q_num, '')
            
            q_data = {
                'idx': q_num,
                'type': q_type,
                'text': '',
            }
            
            question = normalize_question(q_data, section, answers, heading_options)
            questions.append(question)
    
    # Build normalized output
    normalized = {
        'exam': {
            'id': str(uuid.uuid4()),
            'title': title,
            'slug': slug,
            'category': 'IELTS',
            'level': 'B2',
            'status': 'DRAFT',
            'duration_min': 20,
        },
        'sections': [
            {
                'id': str(uuid.uuid4()),
                'idx': 1,
                'title': f'Reading Passage - {title}',
                'passage_md': passage_md,
            }
        ],
        'questions': questions,
        'metadata': {
            'source': source,
            'item_id': item_id,
            'normalized_at': datetime.now().isoformat(),
        }
    }
    
    return normalized


def normalize_and_save(source: str, item_id: str) -> Optional[Path]:
    """Normalize parsed data and save result."""
    parsed = load_parsed(source, item_id)
    if not parsed:
        return None
    
    logger.info(f"Normalizing: {source}/{item_id}")
    
    normalized = normalize_data(parsed)
    
    # Save
    source_dir = NORMALIZED_DIR / source
    source_dir.mkdir(parents=True, exist_ok=True)
    
    output_path = source_dir / f"{item_id}.json"
    output_path.write_text(json.dumps(normalized, indent=2, ensure_ascii=False), encoding='utf-8')
    
    logger.info(f"Saved normalized: {output_path}")
    return output_path


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python normalizer.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    path = normalize_and_save(source, item_id)
    if path:
        print(f"✓ Saved to: {path}")
    else:
        print("✗ Normalize failed")
        sys.exit(1)
