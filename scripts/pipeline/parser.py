#!/usr/bin/env python3
"""
Stage 3: Parser
Parses cleaned text into rough JSON structure.
"""
import json
import re
from pathlib import Path
from typing import Optional, Any

from config import CLEANED_DIR, PARSED_DIR, QUESTION_TYPES, get_logger

logger = get_logger(__name__)


def load_cleaned(source: str, item_id: str) -> Optional[dict]:
    """Load cleaned text from disk."""
    source_dir = CLEANED_DIR / source
    text_path = source_dir / f"{item_id}.txt"
    meta_path = source_dir / f"{item_id}.meta.json"
    
    if not text_path.exists():
        logger.error(f"Cleaned text not found: {text_path}")
        return None
    
    text = text_path.read_text(encoding='utf-8')
    metadata = {}
    if meta_path.exists():
        metadata = json.loads(meta_path.read_text(encoding='utf-8'))
    
    return {'text': text, 'metadata': metadata}


def detect_question_type(text: str) -> str:
    """Detect question type from instruction text."""
    text_lower = text.lower()
    
    if 'true' in text_lower and 'false' in text_lower and 'not given' in text_lower:
        return 'TRUE_FALSE_NOT_GIVEN'
    
    if 'yes' in text_lower and 'no' in text_lower and 'not given' in text_lower:
        return 'YES_NO_NOT_GIVEN'
    
    if 'heading' in text_lower:
        return 'MATCHING_HEADING'
    
    if 'which paragraph' in text_lower or ('letter' in text_lower and 'a-' in text_lower):
        return 'MATCHING_INFORMATION'
    
    if 'match' in text_lower and ('features' in text_lower or 'classify' in text_lower):
        return 'MATCHING_FEATURES'
    
    # Check for MC options (A. B. C. D.)
    mc_pattern = re.findall(r'\n\s*[A-D]\.\s+\w+', text)
    if len(mc_pattern) >= 3:
        return 'MULTIPLE_CHOICE_SINGLE'
    
    if 'choose' in text_lower and ('correct' in text_lower or 'best' in text_lower):
        return 'MULTIPLE_CHOICE_SINGLE'
    
    if 'complete' in text_lower and ('sentence' in text_lower or 'notes' in text_lower or 'summary' in text_lower):
        return 'SUMMARY_COMPLETION'
    
    if '_______' in text or '...' in text:
        return 'SUMMARY_COMPLETION'
    
    return 'SUMMARY_COMPLETION'  # Default


def extract_sections(text: str) -> list[dict]:
    """Extract question sections from text."""
    sections = []
    
    # Pattern: "Questions 1-5" or "Question 1-5"
    pattern = r'Questions?\s+(\d+)\s*[-–]\s*(\d+)'
    matches = list(re.finditer(pattern, text, re.IGNORECASE))
    
    for i, match in enumerate(matches):
        start_q = int(match.group(1))
        end_q = int(match.group(2))
        
        # Get section text (until next section or end)
        start_pos = match.start()
        if i + 1 < len(matches):
            end_pos = matches[i + 1].start()
        else:
            end_pos = len(text)
        
        section_text = text[start_pos:end_pos]
        q_type = detect_question_type(section_text)
        
        sections.append({
            'start_q': start_q,
            'end_q': end_q,
            'type': q_type,
            'text': section_text.strip(),
        })
    
    return sections


def extract_passage(text: str) -> str:
    """Extract main passage from text."""
    # Try to find passage before questions
    first_q_match = re.search(r'Questions?\s+\d+', text, re.IGNORECASE)
    if first_q_match:
        passage_text = text[:first_q_match.start()]
    else:
        passage_text = text[:2000]  # Fallback: first 2000 chars
    
    # Clean passage
    # Remove "List of Headings" section if present
    headings_match = re.search(r'List of Headings.*?(?=\n[A-G]\s+[A-Z]|\nQuestions)', passage_text, re.DOTALL | re.IGNORECASE)
    if headings_match:
        passage_text = passage_text[:headings_match.start()] + passage_text[headings_match.end():]
    
    # Find paragraphs A-G if present
    para_pattern = r'(?:^|\n)\s*([A-G])\s+([A-Z][a-z])'
    if re.search(para_pattern, passage_text):
        # Format with paragraph markers
        passage_text = re.sub(para_pattern, r'\n\n**\1** \2', passage_text)
    
    return passage_text.strip()


def extract_answers(text: str) -> dict[int, str]:
    """Extract answers from text."""
    answers = {}
    
    # Look for spoiler/answer div
    answer_section = re.search(r'(?:Answer|Spoiler|Key).*?(?:\n|$)([\s\S]+?)(?:$|\n\n)', text, re.IGNORECASE)
    
    if answer_section:
        answer_text = answer_section.group(1)
    else:
        # Look for "1. answer" pattern
        answer_text = text
    
    # Pattern: "1. ANSWER" or "1 - ANSWER" or "1: ANSWER"
    pattern = r'(?:^|\n)\s*(\d+)[\.\-:\)]\s*([A-Za-z]+[^0-9\n]*?)(?=\n\s*\d+[\.\-:\)]|\n\n|$)'
    matches = re.findall(pattern, answer_text)
    
    for num_str, answer in matches:
        q_num = int(num_str)
        answer = answer.strip()
        if answer and len(answer) < 100:  # Sanity check
            answers[q_num] = answer
    
    return answers


def extract_heading_options(text: str) -> list[dict]:
    """Extract heading options (i. ii. iii. etc.)"""
    options = []
    
    heading_match = re.search(r'List of Headings(.+?)(?=\d+\.\s*(?:Section|Paragraph)|Questions?\s+\d+)', text, re.DOTALL | re.IGNORECASE)
    
    if heading_match:
        headings_text = heading_match.group(1)
        lines = [l.strip() for l in headings_text.split('\n') if l.strip()]
        
        for line in lines:
            # Match roman numeral
            m = re.match(r'^(i{1,3}|iv|v|vi{1,3}|vii{1,2}|ix|x)\.\s*(.+)', line, re.IGNORECASE)
            if m:
                numeral = m.group(1).lower().strip()
                text_val = m.group(2).strip()
                if text_val and len(text_val) > 3:
                    options.append({
                        'value': numeral,
                        'label': f"{numeral}. {text_val}",
                    })
    
    return options


def parse_text(source: str, item_id: str) -> Optional[dict]:
    """
    Parse cleaned text into rough JSON structure.
    
    Returns dict with:
        - success: bool
        - data: dict (parsed structure)
        - metadata: dict
    """
    cleaned = load_cleaned(source, item_id)
    if not cleaned:
        return {'success': False, 'error': 'Cleaned data not found'}
    
    text = cleaned['text']
    logger.info(f"Parsing: {source}/{item_id}")
    
    # Extract components
    passage = extract_passage(text)
    sections = extract_sections(text)
    answers = extract_answers(text)
    heading_options = extract_heading_options(text)
    
    # Build rough structure
    data = {
        'source': source,
        'item_id': item_id,
        'passage': {
            'text': passage,
            'word_count': len(passage.split()),
        },
        'sections': sections,
        'answers': answers,
        'heading_options': heading_options,
        'question_count': max(answers.keys()) if answers else 0,
    }
    
    metadata = cleaned['metadata'].copy()
    metadata['parsed_at'] = __import__('datetime').datetime.now().isoformat()
    
    return {
        'success': True,
        'data': data,
        'metadata': metadata
    }


def save_parsed(result: dict) -> Optional[Path]:
    """Save parsed data to disk."""
    if not result['success']:
        return None
    
    metadata = result['metadata']
    source = metadata['source']
    item_id = metadata['item_id']
    
    source_dir = PARSED_DIR / source
    source_dir.mkdir(parents=True, exist_ok=True)
    
    # Save data
    data_path = source_dir / f"{item_id}.json"
    output = {
        'data': result['data'],
        'metadata': metadata
    }
    data_path.write_text(json.dumps(output, indent=2, ensure_ascii=False), encoding='utf-8')
    
    logger.info(f"Saved parsed: {data_path}")
    return data_path


def parse_and_save(source: str, item_id: str) -> Optional[Path]:
    """Parse cleaned text and save result."""
    result = parse_text(source, item_id)
    return save_parsed(result)


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python parser.py <source> <item_id>")
        print("Example: python parser.py ielts-mentor 3721-marine-ecosystems")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    path = parse_and_save(source, item_id)
    if path:
        print(f"✓ Saved to: {path}")
    else:
        print("✗ Parse failed")
        sys.exit(1)
