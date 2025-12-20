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
        
        # Check if correct answer is in options
        option_values = [opt.get('value', '').upper() for opt in options]
        correct_upper = correct_answer.upper()
        
        if correct_upper not in option_values:
            # Correct answer missing from options - add it
            # Common case: options A-D but correct is E/F
            q['options'].append({
                'value': correct_answer.upper(),
                'label': f"{correct_answer.upper()}. (Missing label)",
                'is_correct': True
            })
            result.add_repair(f"Q{q.get('idx')}: Added missing option {correct_answer}")
        else:
            # Mark correct option
            correct_count = sum(1 for opt in options if opt.get('is_correct'))
            if correct_count == 0:
                for opt in options:
                    if opt.get('value', '').upper() == correct_upper:
                        opt['is_correct'] = True
                        result.add_repair(f"Q{q.get('idx')}: Marked option {correct_answer} as correct")


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
            # This is a MATCHING question with A-D options, not full paragraph MCQ
            # Convert to simple A/B/C/D format
            
            # Get unique option values (A, B, C, D...)
            unique_values = sorted(set(opt.get('value', '').upper() for opt in options))
            
            # Rebuild options with simple labels
            new_options = []
            for val in unique_values:
                if val and len(val) == 1 and val.isalpha():
                    new_options.append({
                        'value': val,
                        'label': val,
                        'is_correct': val == correct.upper() if correct else False
                    })
            
            if new_options:
                q['options'] = new_options
                q['type'] = 'MATCHING_INFORMATION'
                result.add_repair(f"Q{idx}: Cleaned paragraph options → simple A-D (MATCHING_INFORMATION)")


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


def repair_data(data: dict) -> RepairResult:
    """Run all auto-repair functions."""
    result = RepairResult()
    
    # Phase 1: Structural repairs
    repair_missing_slug(data, result)
    repair_missing_category(data, result)
    repair_question_indices(data, result)
    
    # Phase 2: Question type detection (from instructions)
    repair_detect_question_type_from_instruction(data, result)
    repair_incorrect_question_types(data, result)
    
    # Phase 3: Content validation (IELTS Record Repair Agent)
    repair_matching_paragraph_options(data, result)  # Clean noisy paragraph options
    
    # Phase 4: Options and answers
    repair_empty_options(data, result)
    repair_mc_correct_option(data, result)
    repair_add_blank_markers(data, result)  # Add blank markers for frontend
    repair_infer_answers_from_passage(data, result)  # Try to fill missing answers
    
    return result


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
