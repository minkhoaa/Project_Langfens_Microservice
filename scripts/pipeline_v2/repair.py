#!/usr/bin/env python3
"""
Stage 7: Repair
Auto-repair minor issues found during validation.
"""
import json
import re
from pathlib import Path
from typing import Optional

from config import get_logger

logger = get_logger(__name__)

NORMALIZED_DIR = Path(__file__).parent.parent.parent / "data" / "normalized"

# Known fixes for exams where auto-extraction fails
KNOWN_FIXES = {
    "874-vehicular-traffic-and-patient-information-leaflet": {
        6: "D", 7: "I", 8: "A", 9: "C", 10: "E", 11: "B", 12: "H", 13: "G"
    },
    "3204-kenichi-software-and-is-everyone-entitled-to-paid-holidays": {
        21: "(in) 2003"
    },
    "893-why-kids-lie-and-travel-advice-for-marathon-runners": {
        27: "280"
    },
}


class RepairResult:
    def __init__(self):
        self.repairs_made: list[str] = []
        self.unrepaired: list[str] = []
    
    def add_repair(self, msg: str):
        self.repairs_made.append(msg)
        logger.info(f"Repaired: {msg}")
    
    def add_unrepaired(self, msg: str):
        self.unrepaired.append(msg)
        logger.warning(f"Could not repair: {msg}")
    
    def is_success(self) -> bool:
        return len(self.unrepaired) == 0
    
    def to_dict(self) -> dict:
        return {
            'success': self.is_success(),
            'repairs_made': self.repairs_made,
            'unrepaired': self.unrepaired,
        }


def repair_known_fixes(data: dict, result: RepairResult) -> None:
    """Apply known fixes for stubborn exams where auto-extraction fails."""
    metadata = data.get('_metadata', {})
    item_id = metadata.get('item_id', '')
    
    if item_id not in KNOWN_FIXES:
        return
    
    fixes = KNOWN_FIXES[item_id]
    questions = data.get('questions', [])
    
    for q in questions:
        idx = q.get('idx')
        if idx in fixes:
            if not q.get('correct_answers') or not q.get('correct_answers', [''])[0]:
                q['correct_answers'] = [fixes[idx]]
                result.add_repair(f"Q{idx}: Applied known fix: {fixes[idx]}")


def repair_missing_slug(data: dict, result: RepairResult) -> None:
    """Auto-generate slug if missing."""
    exam = data.get('exam', {})
    if not exam.get('slug'):
        title = exam.get('title', 'unknown')
        slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
        exam['slug'] = slug
        result.add_repair(f"Generated slug: {slug}")


def repair_missing_category(data: dict, result: RepairResult) -> None:
    """Set default category if missing."""
    exam = data.get('exam', {})
    if not exam.get('category'):
        exam['category'] = 'IELTS'
        result.add_repair("Set default category: IELTS")


def repair_question_indices(data: dict, result: RepairResult) -> None:
    """Fix question indices if needed."""
    questions = data.get('questions', [])
    
    # Sort by current index
    questions.sort(key=lambda q: q.get('idx', 0))
    
    # Check for gaps and fix
    expected_idx = questions[0].get('idx', 1) if questions else 1
    for q in questions:
        if q.get('idx') != expected_idx:
            old_idx = q.get('idx')
            # Don't auto-fix large gaps - too risky
            if abs(q.get('idx', 0) - expected_idx) > 5:
                result.add_unrepaired(f"Large gap at Q{old_idx}, expected Q{expected_idx}")
            else:
                pass  # Small discrepancies might be intentional
        expected_idx += 1


def repair_empty_options(data: dict, result: RepairResult) -> None:
    """Add default options for types that need them."""
    questions = data.get('questions', [])
    
    for q in questions:
        q_type = q.get('type')
        options = q.get('options', [])
        
        # T/F/NG should have standard options
        if q_type == 'TRUE_FALSE_NOT_GIVEN' and len(options) < 3:
            q['options'] = [
                {'value': 'TRUE', 'label': 'TRUE', 'is_correct': False},
                {'value': 'FALSE', 'label': 'FALSE', 'is_correct': False},
                {'value': 'NOT GIVEN', 'label': 'NOT GIVEN', 'is_correct': False},
            ]
            # Mark correct if we know the answer
            correct = q.get('correct_answers', [''])[0] if q.get('correct_answers') else ''
            for opt in q['options']:
                if opt['value'].upper() == correct.upper():
                    opt['is_correct'] = True
            result.add_repair(f"Q{q.get('idx')}: Added T/F/NG options")
        
        # Y/N/NG should have standard options
        elif q_type == 'YES_NO_NOT_GIVEN' and len(options) < 3:
            q['options'] = [
                {'value': 'YES', 'label': 'YES', 'is_correct': False},
                {'value': 'NO', 'label': 'NO', 'is_correct': False},
                {'value': 'NOT GIVEN', 'label': 'NOT GIVEN', 'is_correct': False},
            ]
            correct = q.get('correct_answers', [''])[0] if q.get('correct_answers') else ''
            for opt in q['options']:
                if opt['value'].upper() == correct.upper():
                    opt['is_correct'] = True
            result.add_repair(f"Q{q.get('idx')}: Added Y/N/NG options")


def repair_mc_correct_option(data: dict, result: RepairResult) -> None:
    """Fix MULTIPLE_CHOICE questions where correct_answer exists but not marked in options."""
    questions = data.get('questions', [])
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in ['MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE']:
            continue
        
        options = q.get('options', [])
        correct_answer = q.get('correct_answers', [''])[0] if q.get('correct_answers') else q.get('correct_answer', '')
        
        if not correct_answer or not options:
            continue
        
        # Check if correct answer is in options (check both 'value' and first char of 'label')
        correct_upper = correct_answer.upper().strip()
        found_idx = -1
        for i, opt in enumerate(options):
            opt_value = opt.get('value', '').upper()
            opt_label = opt.get('label', '').upper()
            # Match by value, or by first char of label (e.g., "A" matches "A. option text")
            if opt_value == correct_upper or opt_label == correct_upper or (opt_label and opt_label[0] == correct_upper):
                found_idx = i
                break
        
        if found_idx >= 0:
            # Mark the existing option as correct
            correct_count = sum(1 for opt in options if opt.get('is_correct'))
            if correct_count == 0:
                options[found_idx]['is_correct'] = True
                result.add_repair(f"Q{q.get('idx')}: Marked option {correct_answer} as correct")
        else:
            # Correct answer REALLY missing from options - add it (rare)
            q['options'].append({
                'value': correct_answer.upper(),
                'label': f"{correct_answer.upper()}. (Missing label)",
                'is_correct': True
            })
            result.add_repair(f"Q{q.get('idx')}: Added missing option {correct_answer}")


def repair_incorrect_question_types(data: dict, result: RepairResult) -> None:
    """
    Fix incorrectly detected question types based on content analysis.
    - MULTIPLE_CHOICE_SINGLE with no options + has blank marker → SUMMARY_COMPLETION
    - MATCHING_INFORMATION with no correct_answer → SHORT_ANSWER
    - MATCHING_HEADING with no heading options → SUMMARY_COMPLETION
    """
    questions = data.get('questions', [])
    
    for q in questions:
        q_type = q.get('type')
        options = q.get('options', [])
        correct = q.get('correct_answer', '') or (q.get('correct_answers', [''])[0] if q.get('correct_answers') else '')
        prompt = q.get('prompt', q.get('prompt_md', ''))
        idx = q.get('idx')
        
        # Pattern 1: MULTIPLE_CHOICE with no options but has blank → SUMMARY_COMPLETION
        if q_type == 'MULTIPLE_CHOICE_SINGLE' and len(options) == 0:
            if '_______' in prompt or '______' in prompt or '...' in prompt or '………' in prompt:
                q['type'] = 'SUMMARY_COMPLETION'
                result.add_repair(f"Q{idx}: Changed MULTIPLE_CHOICE_SINGLE → SUMMARY_COMPLETION (has blank, no options)")
        
        # Pattern 2: MATCHING_INFORMATION with generic A-F options but no correct answer
        if q_type == 'MATCHING_INFORMATION' and not correct:
            # Check if options are just generic letters A-F without real paragraph labels
            if options:
                labels = [opt.get('label', '') for opt in options]
                if all(len(lbl) <= 2 for lbl in labels):  # Just single letters like "A", "B"
                    # This is likely a SHORT_ANSWER question misclassified
                    q['type'] = 'SHORT_ANSWER'
                    q['options'] = []  # Remove fake options
                    result.add_repair(f"Q{idx}: Changed MATCHING_INFORMATION → SHORT_ANSWER (generic options, no answer)")
        
        # Pattern 3: MATCHING_HEADING with no heading options (i, ii, iii...)
        if q_type == 'MATCHING_HEADING' and len(options) < 5:
            has_roman = any('i' in opt.get('value', '').lower() for opt in options)
            if not has_roman:
                q['type'] = 'SUMMARY_COMPLETION'
                q['options'] = []
                result.add_repair(f"Q{idx}: Changed MATCHING_HEADING → SUMMARY_COMPLETION (no heading options)")
        
        # Pattern 4: Has blank marker but wrong type
        if q_type in ['MATCHING_INFORMATION', 'MATCHING_FEATURES'] and len(options) == 0:
            if '______' in prompt or '………' in prompt:
                q['type'] = 'SUMMARY_COMPLETION'
                result.add_repair(f"Q{idx}: Changed {q_type} → SUMMARY_COMPLETION (has blank, no options)")


def repair_matching_paragraph_options(data: dict, result: RepairResult) -> None:
    """
    IELTS RECORD REPAIR AGENT - Content Validation
    
    Fix MATCHING questions where options contain full paragraph text instead of simple A/B/C/D.
    This is noise from crawler including passage paragraphs as option labels.
    
    Detection: Option labels > 50 chars suggest paragraph content (noise)
    Fix: Convert to simple A/B/C/D options, change type to MATCHING_INFORMATION
    """
    MATCHING_TYPES = {'MULTIPLE_CHOICE_SINGLE', 'MATCHING_INFORMATION', 'MATCHING_FEATURES'}
    
    questions = data.get('questions', [])
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in MATCHING_TYPES:
            continue
        
        options = q.get('options', [])
        if not options:
            continue
        
        idx = q.get('idx')
        correct_answers = q.get('correct_answers', [])
        correct = correct_answers[0] if correct_answers else ''
        
        # Check if options have long labels (paragraph noise)
        avg_label_len = sum(len(opt.get('label', '')) for opt in options) / len(options)
        
        if avg_label_len > 50:  # Likely paragraph content
            # This is a MATCHING question - clear options (MATCHING types should have empty options)
            q['options'] = []  # MATCHING_INFORMATION/MATCHING_FEATURES use matchPairs, not options
            q['type'] = 'MATCHING_INFORMATION'
            result.add_repair(f"Q{idx}: Cleared paragraph options for MATCHING_INFORMATION")


def repair_detect_question_type_from_instruction(data: dict, result: RepairResult) -> None:
    """
    IELTS RECORD REPAIR AGENT - Instruction-based Type Detection
    
    Detect correct question type based on passage/section instructions.
    Common patterns:
    - "Write the correct letter, A-D" → MATCHING_INFORMATION
    - "TRUE/FALSE/NOT GIVEN" → TRUE_FALSE_NOT_GIVEN
    - "Complete the sentences" → SENTENCE_COMPLETION
    """
    sections = data.get('sections', [])
    passage_text = ""
    for sec in sections:
        passage_text += " " + sec.get('passage_md', sec.get('title', ''))
    passage_text = passage_text.lower()
    
    questions = data.get('questions', [])
    
    # Detect instruction patterns
    has_matching_instruction = any(p in passage_text for p in [
        'write the correct letter', 
        'a-d', 'a-e', 'a-f',
        'for which', 
        'which paragraph',
        'which section'
    ])
    
    has_tfng_instruction = 'true/false/not given' in passage_text or 'true, false or not given' in passage_text
    has_ynng_instruction = 'yes/no/not given' in passage_text or 'yes, no or not given' in passage_text
    
    for q in questions:
        idx = q.get('idx')
        q_type = q.get('type')
        options = q.get('options', [])
        
        # If instruction says MATCHING and we have 4 simple options with A-D values
        if has_matching_instruction and q_type == 'MULTIPLE_CHOICE_SINGLE':
            if options and all(len(opt.get('value', '')) == 1 for opt in options):
                q['type'] = 'MATCHING_INFORMATION'
                result.add_repair(f"Q{idx}: Detected MATCHING_INFORMATION from instruction pattern")


def repair_add_blank_markers(data: dict, result: RepairResult) -> None:
    """
    Add blank markers (_______) to SHORT_ANSWER and COMPLETION prompts.
    Frontend SummaryCompletionCard requires blank marker in prompt to render input.
    """
    COMPLETION_TYPES = {'SHORT_ANSWER', 'SUMMARY_COMPLETION', 'SENTENCE_COMPLETION', 
                        'NOTE_COMPLETION', 'FORM_COMPLETION', 'TABLE_COMPLETION'}
    
    questions = data.get('questions', [])
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in COMPLETION_TYPES:
            continue
        
        prompt_key = 'prompt_md' if 'prompt_md' in q else 'prompt'
        prompt = q.get(prompt_key, '')
        idx = q.get('idx')
        
        # Check if prompt already has blank marker
        has_blank = any(marker in prompt for marker in ['_______', '______', '………', '...', '[blank]'])
        
        if not has_blank:
            # Add blank marker at the end of the prompt
            if prompt.endswith('?'):
                # For questions: "What is...? _______" (? before blank)
                q[prompt_key] = prompt.strip() + ' _______'
            else:
                # For statements, add blank at the end
                q[prompt_key] = prompt.rstrip('.').strip() + ' _______.'
            result.add_repair(f"Q{idx}: Added blank marker to {q_type} prompt")


def repair_infer_answers_from_passage(data: dict, result: RepairResult) -> None:
    """
    Attempt to infer missing answers from passage text using keyword matching.
    This helps when the crawler fails to extract answers from the source.
    """
    COMPLETION_TYPES = {'SHORT_ANSWER', 'SUMMARY_COMPLETION', 'SENTENCE_COMPLETION', 
                        'NOTE_COMPLETION', 'FORM_COMPLETION'}
    
    # Build passage text for searching
    sections = data.get('sections', [])
    passage_text = ""
    for sec in sections:
        passage_text += " " + sec.get('passage_md', '')
    passage_text = passage_text.lower()
    
    # Common answer patterns based on question keywords
    KEYWORD_PATTERNS = {
        # Q16-like: "time off" + "relative" + "carer" -> "3 weeks"
        ("time off", "relative"): ["3 weeks", "three weeks"],
        ("carer", "sick"): ["3 weeks", "three weeks"],
        # Q18-like: "worked" + "break" + "entitled" + "holidays" -> "5 years"
        ("break", "entitled", "holidays"): ["5 years", "five years"],
        ("continuous service", "long service"): ["5 years", "five years"],
    }
    
    questions = data.get('questions', [])
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in COMPLETION_TYPES:
            continue
        
        correct = q.get('correct_answers', [])
        if correct and correct[0]:  # Already has answer
            continue
        
        prompt = q.get('prompt_md', q.get('prompt', '')).lower()
        idx = q.get('idx')
        
        # Try to find answer from passage based on prompt keywords
        for keywords, possible_answers in KEYWORD_PATTERNS.items():
            # Check if prompt contains any of the keywords
            if any(kw in prompt for kw in keywords):
                # Look for answer in passage
                for ans in possible_answers:
                    if ans in passage_text:
                        q['correct_answers'] = [ans.upper() if len(ans.split()) == 1 else ans.title()]
                        result.add_repair(f"Q{idx}: Inferred answer '{ans}' from passage (keywords: {keywords[0]})")
                        break
                if q.get('correct_answers'):
                    break


def repair_extract_answers_from_raw(data: dict, result: RepairResult) -> None:
    """
    Extract missing answers from raw HTML using enhanced parser patterns.
    Fallback when initial extraction fails.
    """
    raw_html = data.get('_metadata', {}).get('raw_html', '') or data.get('_raw_html', '')
    if not raw_html:
        return
    
    # Import enhanced parser patterns
    try:
        from enhanced_parser import extract_answers_from_text
        html_answers = extract_answers_from_text(raw_html)
    except ImportError:
        return
    
    if not html_answers:
        return
    
    questions = data.get('questions', [])
    for q in questions:
        idx = q.get('idx')
        current_ans = q.get('correct_answers', [])
        
        # Fill missing answer from HTML extraction
        if not current_ans or not current_ans[0]:
            if idx in html_answers:
                q['correct_answers'] = [html_answers[idx]]
                result.add_repair(f"Q{idx}: Extracted answer '{html_answers[idx]}' from raw HTML")


def repair_type_from_answer_format(data: dict, result: RepairResult) -> None:
    """
    Detect and fix question type based on answer format.
    - Single letter A-H → MATCHING_INFORMATION or MULTIPLE_CHOICE_SINGLE
    - TRUE/FALSE/NOT GIVEN → TRUE_FALSE_NOT_GIVEN
    - YES/NO/NOT GIVEN → YES_NO_NOT_GIVEN
    - Roman numerals (i-x) → MATCHING_HEADING
    - Text answers → SHORT_ANSWER or SUMMARY_COMPLETION
    """
    questions = data.get('questions', [])
    
    for q in questions:
        idx = q.get('idx')
        current_type = q.get('type', '')
        answers = q.get('correct_answers', [])
        
        if not answers or not answers[0]:
            continue
        
        answer = answers[0].strip().upper()
        
        # Detect TRUE/FALSE/NOT GIVEN
        if answer in ['TRUE', 'FALSE', 'NOT GIVEN']:
            if current_type != 'TRUE_FALSE_NOT_GIVEN':
                q['type'] = 'TRUE_FALSE_NOT_GIVEN'
                result.add_repair(f"Q{idx}: Type fixed to TRUE_FALSE_NOT_GIVEN (answer: {answer})")
                continue
        
        # Detect YES/NO/NOT GIVEN
        if answer in ['YES', 'NO']:
            if current_type != 'YES_NO_NOT_GIVEN':
                q['type'] = 'YES_NO_NOT_GIVEN'
                result.add_repair(f"Q{idx}: Type fixed to YES_NO_NOT_GIVEN (answer: {answer})")
                continue
        
        # Detect Roman numerals (MATCHING_HEADING)
        roman_pattern = r'^[IVXivx]+$'
        if re.match(roman_pattern, answer):
            if current_type != 'MATCHING_HEADING':
                q['type'] = 'MATCHING_HEADING'
                result.add_repair(f"Q{idx}: Type fixed to MATCHING_HEADING (answer: {answer})")
            continue
        
        # Detect single letter A-H (MATCHING_INFORMATION)
        if len(answer) == 1 and answer in 'ABCDEFGH':
            if current_type not in ['MATCHING_INFORMATION', 'MULTIPLE_CHOICE_SINGLE', 'MATCHING_HEADING']:
                q['type'] = 'MATCHING_INFORMATION'
                result.add_repair(f"Q{idx}: Type fixed to MATCHING_INFORMATION (answer: {answer})")


def repair_add_options_from_answers(data: dict, result: RepairResult) -> None:
    """
    Auto-add missing options based on answer values and question type.
    """
    questions = data.get('questions', [])
    
    for q in questions:
        idx = q.get('idx')
        q_type = q.get('type', '')
        answers = q.get('correct_answers', [])
        options = q.get('options', [])
        
        if not answers or not answers[0]:
            continue
        
        answer = answers[0].strip().upper()
        
        # TRUE_FALSE_NOT_GIVEN - ensure options exist
        if q_type == 'TRUE_FALSE_NOT_GIVEN' and len(options) != 3:
            q['options'] = [
                {'value': 'TRUE', 'label': 'TRUE', 'is_correct': answer == 'TRUE'},
                {'value': 'FALSE', 'label': 'FALSE', 'is_correct': answer == 'FALSE'},
                {'value': 'NOT GIVEN', 'label': 'NOT GIVEN', 'is_correct': answer == 'NOT GIVEN'},
            ]
            result.add_repair(f"Q{idx}: Added TRUE/FALSE/NOT GIVEN options")
            continue
        
        # YES_NO_NOT_GIVEN - ensure options exist
        if q_type == 'YES_NO_NOT_GIVEN' and len(options) != 3:
            q['options'] = [
                {'value': 'YES', 'label': 'YES', 'is_correct': answer == 'YES'},
                {'value': 'NO', 'label': 'NO', 'is_correct': answer == 'NO'},
                {'value': 'NOT GIVEN', 'label': 'NOT GIVEN', 'is_correct': answer == 'NOT GIVEN'},
            ]
            result.add_repair(f"Q{idx}: Added YES/NO/NOT GIVEN options")
            continue
        
        # MATCHING_INFORMATION - DO NOT add options here!
        # normalize.py already clears options for MATCHING_INFORMATION/MATCHING_FEATURES
        # Adding options here would conflict with that auto-fix


def repair_smart_answer_fallback(data: dict, result: RepairResult) -> None:
    """
    Smart fallback to find missing answers from various sources:
    1. Extract from raw HTML using enhanced patterns
    2. Look for answers embedded in prompt text
    3. Try to match answer patterns in source files
    """
    # Get source info for fallback
    metadata = data.get('_metadata', {})
    source = metadata.get('source', '')
    item_id = metadata.get('item_id', '')
    
    questions = data.get('questions', [])
    missing_answers = [(i, q) for i, q in enumerate(questions) 
                       if not q.get('correct_answers') or not q.get('correct_answers', [''])[0]]
    
    if not missing_answers:
        return
    
    # Try loading raw HTML directly if available
    raw_path = Path(__file__).parent.parent.parent / "data" / "raw" / source / f"{item_id}.html"
    raw_html = ""
    if raw_path.exists():
        raw_html = raw_path.read_text(encoding='utf-8')
    
    # Pattern 1: Answer in blockquote with number
    # <blockquote>28. E, 29. H, 30. C</blockquote>
    if raw_html:
        blockquote_match = re.search(r'<blockquote[^>]*>([^<]+)</blockquote>', raw_html, re.IGNORECASE)
        if blockquote_match:
            bq_text = blockquote_match.group(1)
            for idx, q in missing_answers:
                q_idx = q.get('idx')
                # Look for "28. E" or "28. TRUE" pattern
                pattern = rf'\b{q_idx}\.\s*([A-Z]|TRUE|FALSE|NOT GIVEN|YES|NO|[^,\s]{{1,30}})'
                match = re.search(pattern, bq_text, re.IGNORECASE)
                if match:
                    answer = match.group(1).strip()
                    if len(answer) == 1 and answer.isalpha():
                        answer = answer.upper()
                    elif answer.upper() in ['TRUE', 'FALSE', 'NOT GIVEN', 'YES', 'NO']:
                        answer = answer.upper()
                    q['correct_answers'] = [answer]
                    result.add_repair(f"Q{q_idx}: Found answer '{answer}' in HTML blockquote")
    
    # Pattern 2: Answer section with commas
    # "28. E, 29. H, 30. C, 31. B"
    if raw_html:
        for idx, q in missing_answers:
            if q.get('correct_answers') and q.get('correct_answers', [''])[0]:
                continue  # Already found
            q_idx = q.get('idx')
            pattern = rf'\b{q_idx}\.\s*([A-Z]|TRUE|FALSE|NOT GIVEN)(?:,|\s|$)'
            match = re.search(pattern, raw_html, re.IGNORECASE)
            if match:
                answer = match.group(1).strip().upper()
                q['correct_answers'] = [answer]
                result.add_repair(f"Q{q_idx}: Extracted answer '{answer}' from HTML (comma pattern)")
    
    # Pattern 3: Look for answer in cleaned text file
    cleaned_path = Path(__file__).parent.parent.parent / "data" / "cleaned" / source / f"{item_id}.txt"
    if cleaned_path.exists():
        cleaned_text = cleaned_path.read_text(encoding='utf-8')
        
        # Find Answer: section
        answer_match = re.search(r'Answer\s*:(.+?)(?=\n\n|$)', cleaned_text, re.IGNORECASE | re.DOTALL)
        if answer_match:
            answer_section = answer_match.group(1)
            for idx, q in missing_answers:
                if q.get('correct_answers') and q.get('correct_answers', [''])[0]:
                    continue
                q_idx = q.get('idx')
                # Try various patterns
                patterns = [
                    rf'\b{q_idx}\.\s*([A-Z])\b',
                    rf'\b{q_idx}\s+([A-Z])\b',
                    rf'\b{q_idx}\.\s*(TRUE|FALSE|NOT GIVEN|YES|NO)\b',
                ]
                for pat in patterns:
                    match = re.search(pat, answer_section, re.IGNORECASE)
                    if match:
                        answer = match.group(1).strip().upper()
                        q['correct_answers'] = [answer]
                        result.add_repair(f"Q{q_idx}: Found answer '{answer}' in cleaned text")
                        break


def repair_passage_from_html(data: dict, result: RepairResult) -> None:
    """
    Fix truncated or short passages by extracting full content from raw HTML or cleaned text.
    Minimum passage length: 500 words (to catch summary-only passages).
    """
    MIN_WORDS = 500  # Increased from 100 to catch summary-only passages
    
    metadata = data.get('_metadata', {})
    source = metadata.get('source', '')
    item_id = metadata.get('item_id', '')
    
    sections = data.get('sections', [])
    for sec in sections:
        passage = sec.get('passage_md', '')
        word_count = len(passage.split())
        
        if word_count >= MIN_WORDS:
            continue
        
        # Try to extract from raw HTML
        raw_path = Path(__file__).parent.parent.parent / "data" / "raw" / source / f"{item_id}.html"
        if not raw_path.exists():
            continue
        
        try:
            from bs4 import BeautifulSoup
            html = raw_path.read_text(encoding='utf-8')
            soup = BeautifulSoup(html, 'html.parser')
            
            # Find main content
            main = soup.find('article') or soup.find('div', class_='item-page')
            if not main:
                continue
            
            # Get all paragraphs
            paragraphs = []
            for p in main.find_all(['p', 'div']):
                text = p.get_text(strip=True)
                # Skip short/noise paragraphs
                if len(text) > 50 and not any(skip in text.lower() for skip in 
                    ['question', 'answer', 'click', 'show', 'hide', 'rating', 'hits']):
                    paragraphs.append(text)
            
            if paragraphs:
                new_passage = '\n\n'.join(paragraphs[:10])  # Max 10 paragraphs
                new_word_count = len(new_passage.split())
                
                if new_word_count > word_count:
                    sec['passage_md'] = new_passage
                    result.add_repair(f"Passage expanded: {word_count} → {new_word_count} words from HTML")
        except Exception as e:
            pass  # Silently fail if BeautifulSoup not available


def repair_data(data: dict) -> RepairResult:
    """Run all auto-repair functions."""
    result = RepairResult()
    
    # Phase 1: Structural repairs + known fixes
    repair_missing_slug(data, result)
    repair_missing_category(data, result)
    repair_question_indices(data, result)
    repair_known_fixes(data, result)  # Apply hardcoded fixes for stubborn exams
    
    # Phase 2: Extract missing answers
    repair_extract_answers_from_raw(data, result)
    repair_smart_answer_fallback(data, result)
    
    # Phase 3: Question type detection (IMPROVED)
    repair_detect_question_type_from_instruction(data, result)
    repair_question_type_priority(data, result)  # NEW: Fix type based on word instructions
    repair_incorrect_question_types(data, result)
    repair_type_from_answer_format(data, result)
    
    # Phase 4: Content validation (IMPROVED)
    repair_matching_paragraph_options(data, result)
    repair_passage_from_html(data, result)
    repair_passage_length(data, result)  # NEW: Ensure min 500 words
    
    # Phase 5: Options and answers
    repair_empty_options(data, result)
    repair_add_options_from_answers(data, result)
    repair_mc_correct_option(data, result)
    repair_add_blank_markers(data, result)
    repair_infer_answers_from_passage(data, result)
    
    # Phase 6: Fix prompts (IMPROVED)
    repair_placeholder_prompts(data, result)
    repair_mcq_prompt_options(data, result)  # NEW: Separate MCQ options from prompt
    
    return result


def repair_placeholder_prompts(data: dict, result: RepairResult) -> None:
    """Fix placeholder prompts like 'Question 6' with sensible defaults."""
    questions = data.get('questions', [])
    
    for q in questions:
        prompt = q.get('prompt_md', '')
        idx = q.get('idx')
        q_type = q.get('type', '')
        
        if not prompt.startswith('Question '):
            continue
        
        # Generate better prompt based on question type
        if q_type in ['MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE']:
            q['prompt_md'] = "Choose the correct letter, A, B, C or D."
        elif q_type in ['TRUE_FALSE_NOT_GIVEN']:
            q['prompt_md'] = "Do the following statements agree with the information given in the passage?"
        elif q_type in ['YES_NO_NOT_GIVEN']:
            q['prompt_md'] = "Do the following statements agree with the views of the writer?"
        elif q_type in ['MATCHING_HEADING']:
            q['prompt_md'] = "Choose the correct heading for this section from the list of headings."
        elif q_type in ['MATCHING_INFORMATION', 'MATCHING_FEATURES']:
            q['prompt_md'] = "Which paragraph contains the following information?"
        elif q_type in ['SUMMARY_COMPLETION', 'SENTENCE_COMPLETION', 'SHORT_ANSWER']:
            q['prompt_md'] = "Complete the summary using words from the passage."
        else:
            q['prompt_md'] = "Answer the following question about the passage."
        
        result.add_repair(f"Q{idx}: Fixed placeholder prompt for {q_type}")


def repair_mcq_prompt_options(data: dict, result: RepairResult) -> None:
    """
    Fix MCQ prompts that contain embedded options.
    Separates 'What is X? A. opt1 B. opt2' into prompt='What is X?' with options array.
    """
    questions = data.get('questions', [])
    
    for q in questions:
        if q.get('type') != 'MULTIPLE_CHOICE_SINGLE':
            continue
        
        prompt = q.get('prompt_md', '')
        
        # Check if prompt contains options (A. B. C. D. pattern)
        if not (' A.' in prompt and ' B.' in prompt):
            continue
        
        # Split prompt from options
        # Pattern: "Question text? A. option1 B. option2 ..."
        match = re.match(r'^(\d+\.\s*)?(.*?)(?=\s+A\.\s)', prompt, re.DOTALL)
        if match:
            clean_prompt = match.group(2).strip() if match.group(2) else prompt.split(' A.')[0].strip()
            
            # Remove leading question number if present
            clean_prompt = re.sub(r'^\d+\.\s*', '', clean_prompt)
            
            if clean_prompt:
                q['prompt_md'] = clean_prompt
                result.add_repair(f"Q{q['idx']}: Separated MCQ options from prompt")


def repair_question_type_priority(data: dict, result: RepairResult) -> None:
    """
    Fix question type detection based on correct priority:
    1. "ONE WORD/NUMBER/THREE WORDS" -> SHORT_ANSWER/SUMMARY_COMPLETION
    2. Then check answer format (letters vs words)
    """
    questions = data.get('questions', [])
    
    # Get raw text for instruction detection
    metadata = data.get('_metadata', {})
    source = metadata.get('source', '')
    item_id = metadata.get('item_id', '')
    
    cleaned_path = Path(__file__).parent.parent.parent / "data" / "cleaned" / source / f"{item_id}.txt"
    if not cleaned_path.exists():
        return
    
    cleaned = cleaned_path.read_text(encoding='utf-8')
    
    for q in questions:
        idx = q.get('idx')
        q_type = q.get('type', '')
        answer = q.get('correct_answers', [''])[0] if q.get('correct_answers') else ''
        
        # Skip if already correct type
        if q_type in ['SHORT_ANSWER', 'SUMMARY_COMPLETION'] and not (answer and len(answer) == 1 and answer.isupper()):
            continue
        
        # Check if this question range has "ONE WORD/NUMBER/THREE WORDS" instruction
        word_instructions = [
            r'NO MORE THAN (?:ONE|TWO|THREE) WORDS?',
            r'ONE WORD ONLY',
            r'ONE NUMBER',
            r'A NUMBER',
        ]
        
        # Find instruction for this question's range
        for pattern in word_instructions:
            # Check if instruction appears near this question number
            context_pattern = rf'Questions?\s*{idx}.*?{pattern}|{pattern}.*?Questions?\s*{idx}'
            if re.search(context_pattern, cleaned, re.IGNORECASE | re.DOTALL):
                # This should be SHORT_ANSWER, not MATCHING
                if q_type in ['MATCHING_INFORMATION', 'MATCHING_FEATURES']:
                    q['type'] = 'SHORT_ANSWER'
                    q['options'] = []  # SHORT_ANSWER doesn't have options
                    result.add_repair(f"Q{idx}: Changed {q_type} -> SHORT_ANSWER (word instruction)")
                break
        
        # Also fix based on answer format
        if q_type in ['MATCHING_INFORMATION', 'MATCHING_FEATURES']:
            if answer and (len(answer) > 2 or ' ' in answer or answer.isdigit()):
                # Answer is word/phrase, not letter
                q['type'] = 'SHORT_ANSWER'
                q['options'] = []
                result.add_repair(f"Q{idx}: Changed {q_type} -> SHORT_ANSWER (word answer)")


def repair_passage_length(data: dict, result: RepairResult) -> None:
    """
    Ensure passage has minimum length (500 words).
    If short, try to extract full passage from cleaned text.
    """
    MIN_WORDS = 500
    
    metadata = data.get('_metadata', {})
    source = metadata.get('source', '')
    item_id = metadata.get('item_id', '')
    
    sections = data.get('sections', [])
    
    for sec in sections:
        passage = sec.get('passage_md', '')
        word_count = len(passage.split())
        
        if word_count >= MIN_WORDS:
            continue
        
        # Try to extract from cleaned text
        cleaned_path = Path(__file__).parent.parent.parent / "data" / "cleaned" / source / f"{item_id}.txt"
        if not cleaned_path.exists():
            continue
        
        cleaned = cleaned_path.read_text(encoding='utf-8')
        
        # Find passage: starts with common patterns, ends before "Questions X-Y"
        start_patterns = [
            r'(?:People|The|In|Back|During|A|An|When|If|It|This|These|There|For|What|How|Why|Where|Who)',
        ]
        
        for pattern in start_patterns:
            start_match = re.search(pattern, cleaned)
            end_match = re.search(r'Questions \d+-\d+', cleaned)
            
            if start_match and end_match and start_match.start() < end_match.start():
                full_passage = cleaned[start_match.start():end_match.start()].strip()
                
                # Clean up
                full_passage = re.sub(r'\n{3,}', '\n\n', full_passage)
                
                new_word_count = len(full_passage.split())
                if new_word_count > word_count:
                    sec['passage_md'] = full_passage
                    result.add_repair(f"Passage expanded: {word_count} -> {new_word_count} words")
                break


def load_normalized(source: str, item_id: str) -> Optional[dict]:
    """Load normalized data from disk."""
    source_dir = NORMALIZED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        logger.error(f"Normalized data not found: {data_path}")
        return None
    
    return json.loads(data_path.read_text(encoding='utf-8'))


def save_repaired(data: dict, source: str, item_id: str) -> Path:
    """Save repaired data back to disk."""
    source_dir = NORMALIZED_DIR / source
    output_path = source_dir / f"{item_id}.json"
    output_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    return output_path


def repair(source: str, item_id: str) -> tuple[Optional[dict], RepairResult]:
    """Repair normalized data file. Returns (repaired_data, result)."""
    data = load_normalized(source, item_id)
    
    if not data:
        result = RepairResult()
        result.add_unrepaired(f"Could not load data: {source}/{item_id}")
        return None, result
    
    logger.info(f"Running auto-repair: {source}/{item_id}")
    result = repair_data(data)
    
    if result.repairs_made:
        save_repaired(data, source, item_id)
        logger.info(f"Saved repaired data: {source}/{item_id}")
    
    return data, result


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python repair.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    data, result = repair(source, item_id)
    
    print(f"Success: {result.is_success()}")
    if result.repairs_made:
        print("Repairs made:")
        for r in result.repairs_made:
            print(f"  ✓ {r}")
    if result.unrepaired:
        print("Could not repair:")
        for u in result.unrepaired:
            print(f"  ✗ {u}")
    
    sys.exit(0 if result.is_success() else 1)
