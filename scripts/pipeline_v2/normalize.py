#!/usr/bin/env python3
"""
Stage 4: Normalize (AI)
Uses Gemini Flash Lite to normalize extracted data to JSON schema.
Falls back to rule-based normalization if AI fails.
"""
import json
import os
import re
from pathlib import Path
from typing import Optional

from config import EXTRACTED_DIR, get_logger

logger = get_logger(__name__)

# Directory for normalized output
NORMALIZED_DIR = Path(__file__).parent.parent.parent / "data" / "normalized"
NORMALIZED_DIR.mkdir(parents=True, exist_ok=True)

# Load environment variables
def load_env():
    """Load environment variables from .env file."""
    env_file = Path(__file__).parent / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if '=' in line and not line.startswith('#'):
                key, value = line.split('=', 1)
                os.environ[key.strip()] = value.strip()

load_env()

# Gemini API setup
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'gemini-2.0-flash-lite')  # Use 2.0 Flash Lite for better quality

# Target JSON Schema for IELTS exam
IELTS_SCHEMA = """
{
  "exam": {
    "title": "string - exam title",
    "slug": "string - URL-friendly slug",
    "category": "IELTS",
    "level": "B2",
    "duration_min": 20
  },
  "sections": [
    {
      "idx": 1,
      "title": "string - section title",
      "passage_md": "string - passage text in markdown"
    }
  ],
  "questions": [
    {
      "idx": "integer - question number 1-40",
      "type": "TRUE_FALSE_NOT_GIVEN | YES_NO_NOT_GIVEN | MULTIPLE_CHOICE_SINGLE | MATCHING_HEADING | MATCHING_INFORMATION | MATCHING_FEATURES | SUMMARY_COMPLETION",
      "prompt_md": "string - question prompt",
      "options": [{"value": "A", "label": "A. option text", "is_correct": false}],
      "correct_answers": ["string - correct answer(s)"]
    }
  ]
}
"""


def clean_passage_text(text: str) -> str:
    """
    Remove embedded questions and metadata garbage from passage text.
    Patterns to remove:
    - Navigation: "|", "Section 1", "Section 2", etc.
    - Metadata: "20", "28-40", "minutes on", etc.
    - "15. Which employees may choose..." (numbered questions)
    - "21. You and your employer will need to sign a ………………… before training starts."
    """
    # === METADATA CLEANUP (navigation, section markers) ===
    # Remove lines that are just pipes/bars
    text = re.sub(r'^[\|\s]+$', '', text, flags=re.MULTILINE)
    
    # Remove common metadata patterns (full line patterns)
    metadata_line_patterns = [
        r'^GT Reading (?:Mock )?Test \d+.*$',  # GT Reading Test 6 Section 3 - Talking Point
        r'^Section \d+.*$',  # Section 1 or Section 1: ...
        r'^Details\s*$',  # Details
        r'^Last Updated:.*$',  # Last Updated: Wednesday...
        r'^Written by.*$',  # Written by IELTS Mentor
        r'^Hits:.*$',  # Hits: 186294
        r'^You should spend about.*$',  # You should spend about 20 minutes
        r'^\d{1,3}\s*$',  # Just "20" or "1485"
        r'^\d+-\s*\d+\s*$',  # 28- 40 or 28-40
        r'^minutes on.*$',  # minutes on Questions
        r'^GT Reading Sample:?.*$',  # GT Reading Sample:
        r'^Read the text.*$',  # Read the text below and answer
        r'^Questions?\s+\d+.*$',  # Questions 28-40
        r'^\*\s*Maori:.*',  # * Maori: footnote
        r'^[A-Za-z]+\s+Point\s*$',  # Talking Point (on its own line)
        r'^\.$',  # Just a period
        r'^[A-E]\s*$',  # Just a single letter
        r'^List of People\s*$',  # List of People header
        r'^NB\s*$',  # NB
    ]
    
    for pattern in metadata_line_patterns:
        text = re.sub(pattern, '', text, flags=re.MULTILINE | re.IGNORECASE)
    
    # Remove everything before the title line (if passage starts with garbage)
    # Find first line that starts with uppercase word followed by actual content
    lines = text.split('\n')
    clean_lines = []
    found_content = False
    
    for line in lines:
        stripped = line.strip()
        # Skip empty lines until we find content
        if not stripped:
            if found_content:
                clean_lines.append('')
            continue
        
        # Skip very short lines (likely garbage)
        if len(stripped) < 5 and not found_content:
            continue
        
        # Start collecting when we find a real sentence (15+ chars, contains words)
        if not found_content:
            if len(stripped) > 15 and re.search(r'[a-z]+\s+[a-z]+', stripped.lower()):
                found_content = True
                clean_lines.append(line)
        else:
            clean_lines.append(line)
    
    text = '\n'.join(clean_lines)
    
    # === PARAGRAPH LABEL FORMATTING ===
    # Convert "A The glow..." to "**Paragraph A.**\nThe glow..."
    # Match letter at start of line followed by space and uppercase word
    text = re.sub(r'^([A-H])\s+([A-Z])', r'**Paragraph \1.**\n\2', text, flags=re.MULTILINE)
    
    # Also handle inline paragraph markers (within text)
    # "...caves. B The fireflies..." → "...caves.\n\n**Paragraph B.**\nThe fireflies..."
    text = re.sub(r'([.!?])\s+([A-H])\s+([A-Z][a-z])', r'\1\n\n**Paragraph \2.**\n\3', text)
    
    # === QUESTION CLEANUP ===
    # Remove TFNG/YNNG instruction blocks that got embedded in passage
    tfng_patterns = [
        r'TRUE if the statement agrees with the information.*?NOT GIVEN if there is no information on this',
        r'YES if the statement agrees with.*?NOT GIVEN if there is no information on this',
        r'TRUE\s+FALSE\s+NOT GIVEN',
        r'YES\s+NO\s+NOT GIVEN',
    ]
    for pattern in tfng_patterns:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE | re.DOTALL)
    
    # Pattern 1: Question with blanks (………………… or _______)
    text = re.sub(r'\b(1[5-9]|2[0-9]|3[0-9]|40)\.\s+[^.]*[…_]{3,}[^.]*\.?\s*', '', text)
    
    # Pattern 2: Questions ending with ? (all forms)
    text = re.sub(r'\b(1[5-9]|2[0-9]|3[0-9]|40)\.\s+[^?]+\?\s*', '', text)
    
    # Pattern 3: Numbered questions/statements (35. The first fireflies...)
    text = re.sub(r'\b(2[89]|3[0-9]|40)\.\s+[A-Z][^.]*\.', '', text)
    
    # Pattern 4: Cleanup orphaned blank patterns
    text = re.sub(r'[…_]{3,}', '', text)
    
    # Pattern 5: Remove orphaned sentences that look like incomplete questions
    text = re.sub(r'\n\s*[A-Z][^.!?\n]*\bthe\s+(?:during|before|after|for|and|or)\b[^.!?\n]*\.\s*', '\n', text)
    
    # Pattern 6: Remove any sentence with "of the the" weirdness
    text = re.sub(r'\n\s*[^.\n]*\bof the\s+(?:during|before|after|and|or|for|by)\b[^.\n]*\.\s*', '\n', text)
    
    # === FINAL CLEANUP ===
    text = re.sub(r'\n\s*\n\s*\n+', '\n\n', text)
    text = re.sub(r'  +', ' ', text)
    text = re.sub(r'\n +', '\n', text)
    
    return text.strip()




def call_gemini(prompt: str) -> Optional[str]:
    """Call Gemini Flash Lite API."""
    if not GEMINI_API_KEY:
        logger.warning("GEMINI_API_KEY not set, skipping AI normalize")
        return None
    
    try:
        import google.generativeai as genai
        
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel(GEMINI_MODEL)
        
        logger.info(f"Using model: {GEMINI_MODEL}")
        response = model.generate_content(prompt)
        return response.text
        
    except ImportError:
        logger.error("google-generativeai package not installed. Run: pip install google-generativeai")
        return None
    except Exception as e:
        logger.error(f"Gemini API error: {e}")
        return None


def build_normalize_prompt(data: dict) -> str:
    """Build COMPACT prompt for Gemini - optimized for minimal tokens."""
    # Truncation but keep enough passage for answer extraction
    passages_text = ""
    for p in data.get('passages', [])[:1]:  # Only 1st passage
        text = p.get('text', '')[:2500]  # Increase to 2500 for answer extraction
        passages_text += text
    
    # Compact question format - only essential fields
    questions_compact = []
    for q in data.get('questions', [])[:20]:
        questions_compact.append({
            'idx': q.get('idx'),
            'type': q.get('type'),
            'prompt': q.get('prompt', '')[:100],  # Truncate prompts
            'answer': q.get('correct_answer', ''),
            'opts': len(q.get('options', [])),  # Just count, not full options
        })
    
    questions_text = json.dumps(questions_compact, ensure_ascii=False)
    
    # COMPACT PROMPT - ~300 tokens instead of ~800
    prompt = f"""IELTS exam normalizer. Output valid JSON only.

SCHEMA: {{exam:{{title,slug,category:"IELTS",level:"B2",duration_min:20}},sections:[{{idx,title,passage_md}}],questions:[{{idx,type,prompt_md,options:[{{value,label,is_correct}}],correct_answers:[]}}]}}

TYPES: TRUE_FALSE_NOT_GIVEN,YES_NO_NOT_GIVEN,MULTIPLE_CHOICE_SINGLE,MATCHING_HEADING,MATCHING_INFORMATION,MATCHING_FEATURES,SUMMARY_COMPLETION,TABLE_COMPLETION,NOTE_COMPLETION,SENTENCE_COMPLETION,SHORT_ANSWER

DATA:
Title: {data.get('title', '')[:80]}
Passage: {passages_text[:1500]}...

Questions: {questions_text}

RULES:
1. Fix question types based on content
2. MULTIPLE_CHOICE: options A-F with is_correct=true for correct one
3. MATCHING_HEADING: options i,ii,iii... 
4. COMPLETION/SHORT_ANSWER: correct_answers=["answer"] - EXTRACT FROM PASSAGE
5. IMPORTANT: If answer is empty but question is COMPLETION type, FIND ANSWER IN PASSAGE
6. Add ai_review:{{issues_found:[],fixes_applied:[],quality_score:1-10}}

JSON:"""
    return prompt


def normalize_with_ai(data: dict) -> Optional[dict]:
    """
    Normalize data using Gemini AI with type-safe parsing.
    Uses Pydantic models for validation and better error messages.
    """
    from models import parse_normalized_exam, validate_for_render
    
    prompt = build_normalize_prompt(data)
    
    logger.info("Calling Gemini AI for normalization...")
    response = call_gemini(prompt)
    
    if not response:
        return None
    
    # Parse JSON from response
    try:
        # Try to extract JSON from response
        json_match = re.search(r'\{[\s\S]*\}', response)
        if not json_match:
            logger.error("No JSON found in AI response")
            return None
        
        raw_json = json.loads(json_match.group())
        
        # Type-safe parsing with Pydantic
        parsed_exam, parse_errors = parse_normalized_exam(raw_json)
        
        if parse_errors:
            logger.warning("Pydantic validation errors (attempting to continue):")
            for err in parse_errors[:5]:  # Show first 5 errors
                logger.warning(f"  - {err}")
            # Return raw JSON if Pydantic fails but JSON is valid
            logger.info("Falling back to raw JSON (Pydantic validation failed)")
            return raw_json
        
        # Additional render validation
        render_warnings = validate_for_render(parsed_exam)
        if render_warnings:
            logger.info("Render validation warnings:")
            for warn in render_warnings[:5]:
                logger.info(f"  ⚠ {warn}")
        
        logger.info("AI normalization successful with type-safe parsing")
        return parsed_exam.model_dump()
        
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse AI response as JSON: {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error during AI normalization: {e}")
        return None


def normalize_rule_based(data: dict) -> dict:
    """Enhanced rule-based normalization with auto-detection."""
    logger.info("Using enhanced rule-based normalization")
    
    # Import enhanced parser
    try:
        from enhanced_parser import (
            detect_question_type, 
            extract_question_range, 
            extract_answers_from_text,
            build_options
        )
        use_enhanced = True
    except ImportError:
        logger.warning("Enhanced parser not available, using basic mode")
        use_enhanced = False
    
    title = data.get('title', 'IELTS Reading Test')
    slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
    
    # Build passage markdown - CLEAN embedded questions
    passage_md = ""
    for p in data.get('passages', []):
        text = p.get('text', '')
        text = clean_passage_text(text)
        if p.get('letter'):
            passage_md += f"\n\n**{p['letter']}** {text}"
        else:
            passage_md += f"\n\n{text}"
    
    # Get raw text for enhanced parsing
    raw_text = data.get('_raw_text', '')
    raw_html = data.get('_raw_html', '')
    
    # Try to extract answers from raw text first, then HTML as fallback
    answers_map = {}
    if use_enhanced:
        if raw_text:
            answers_map = extract_answers_from_text(raw_text)
        # If few answers found, try extracting from HTML
        if len(answers_map) < 5 and raw_html:
            html_answers = extract_answers_from_text(raw_html)
            # Merge, preferring HTML answers
            for idx, ans in html_answers.items():
                if idx not in answers_map:
                    answers_map[idx] = ans
        logger.info(f"Auto-extracted {len(answers_map)} answers from source")
    
    # Build questions with enhanced detection
    questions = []
    for q in data.get('questions', []):
        idx = q.get('idx', 0)
        original_type = q.get('type', 'SUMMARY_COMPLETION')
        prompt = q.get('prompt', f"Question {idx}")
        
        # Auto-detect type from instruction if available
        detected_type = original_type
        instruction = q.get('instruction', '')
        if use_enhanced and instruction:
            detected_type = detect_question_type(instruction)
            if detected_type != original_type:
                logger.info(f"Q{idx}: Type corrected {original_type} -> {detected_type}")
        
        # Get answer from auto-extraction or original
        correct_answer = ''
        if idx in answers_map:
            correct_answer = answers_map[idx]
        elif q.get('correct_answer'):
            correct_answer = q.get('correct_answer')
        
        # Build options based on type
        options = q.get('options', [])
        if use_enhanced and not options and detected_type:
            options = build_options(detected_type, correct_answer)
        
        questions.append({
            'idx': idx,
            'type': detected_type,
            'prompt_md': prompt,
            'options': options,
            'correct_answers': [correct_answer] if correct_answer else [],
        })
    
    return {
        'exam': {
            'title': title,
            'slug': slug,
            'category': 'IELTS',
            'level': 'B2',
            'duration_min': 20,
        },
        'sections': [
            {
                'idx': 1,
                'title': title,
                'passage_md': passage_md.strip(),
            }
        ],
        'questions': questions,
    }



def load_extracted(source: str, item_id: str) -> Optional[dict]:
    """Load extracted data from disk."""
    source_dir = EXTRACTED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        logger.error(f"Extracted data not found: {data_path}")
        return None
    
    return json.loads(data_path.read_text(encoding='utf-8'))


def normalize(source: str, item_id: str, use_ai: bool = True) -> Optional[dict]:
    """
    Normalize extracted data to target JSON schema.
    Uses AI if available, falls back to rule-based.
    """
    data = load_extracted(source, item_id)
    if not data:
        return None
    
    logger.info(f"Normalizing: {source}/{item_id}")
    
    normalized = None
    
    # Try AI normalization first
    if use_ai and GEMINI_API_KEY:
        normalized = normalize_with_ai(data)
    
    # Fallback to rule-based
    if not normalized:
        normalized = normalize_rule_based(data)
    
    # Add metadata
    normalized['_metadata'] = {
        'source': source,
        'item_id': item_id,
        'url': data.get('url', ''),
        'normalized_by': 'ai' if (use_ai and GEMINI_API_KEY and normalized) else 'rule-based',
    }
    
    return normalized


def save_normalized(data: dict, source: str, item_id: str) -> Optional[Path]:
    """Save normalized data to disk."""
    source_dir = NORMALIZED_DIR / source
    source_dir.mkdir(parents=True, exist_ok=True)
    
    output_path = source_dir / f"{item_id}.json"
    output_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    
    logger.info(f"Saved normalized: {output_path}")
    return output_path


def normalize_and_save(source: str, item_id: str, use_ai: bool = True) -> Optional[dict]:
    """Normalize data and save. Returns normalized data."""
    data = normalize(source, item_id, use_ai)
    if data:
        save_normalized(data, source, item_id)
    return data


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python normalize.py <source> <item_id> [--no-ai]")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    use_ai = '--no-ai' not in sys.argv
    
    result = normalize_and_save(source, item_id, use_ai)
    if result:
        method = result.get('_metadata', {}).get('normalized_by', 'unknown')
        print(f"✓ Normalized ({method}): {len(result.get('questions', []))} questions")
    else:
        print("✗ Normalize failed")
        sys.exit(1)
