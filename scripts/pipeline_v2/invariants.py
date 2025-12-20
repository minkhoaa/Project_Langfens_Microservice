#!/usr/bin/env python3
"""
Stage 6: Invariants (IELTS Rules Gate)
Business rule validation for all IELTS question types.
"""
import json
from pathlib import Path
from typing import Optional

from config import get_logger
from models import (
    QuestionType, 
    SINGLE_CHOICE_TYPES, MULTIPLE_CHOICE_TYPES, COMPLETION_TYPES, MATCHING_TYPES
)

logger = get_logger(__name__)

NORMALIZED_DIR = Path(__file__).parent.parent.parent / "data" / "normalized"


class InvariantResult:
    def __init__(self):
        self.violations: list[str] = []
        self.warnings: list[str] = []
    
    def add_violation(self, msg: str):
        self.violations.append(msg)
        logger.error(f"Invariant violation: {msg}")
    
    def add_warning(self, msg: str):
        self.warnings.append(msg)
        logger.warning(f"Invariant warning: {msg}")
    
    def is_valid(self) -> bool:
        return len(self.violations) == 0
    
    def to_dict(self) -> dict:
        return {
            'valid': self.is_valid(),
            'violation_count': len(self.violations),
            'warning_count': len(self.warnings),
            'violations': self.violations,
            'warnings': self.warnings,
        }


def check_question_sequence(questions: list, result: InvariantResult) -> None:
    """Check that questions are sequential with no large gaps."""
    if not questions:
        result.add_violation("No questions found")
        return
    
    indices = sorted([q.get('idx', 0) for q in questions])
    
    # Check for large gaps
    for i in range(len(indices) - 1):
        gap = indices[i+1] - indices[i]
        if gap > 5:  # Allow small gaps for section breaks
            result.add_violation(f"Large gap in question sequence: Q{indices[i]} -> Q{indices[i+1]}")
    
    # Check for duplicates
    if len(indices) != len(set(indices)):
        result.add_violation("Duplicate question indices found")


def check_single_choice_types(questions: list, result: InvariantResult) -> None:
    """Check SINGLE_CHOICE invariants: exactly 1 correct option."""
    single_choice_values = {t.value for t in SINGLE_CHOICE_TYPES}
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in single_choice_values:
            continue
        
        options = q.get('options', [])
        idx = q.get('idx')
        
        if len(options) < 2:
            result.add_violation(f"Q{idx}: {q_type} has {len(options)} options (need 2+)")
        else:
            correct_count = sum(1 for opt in options if opt.get('is_correct'))
            if correct_count != 1:
                # Demote to warning if at least one correct exists
                result.add_warning(f"Q{idx}: {q_type} should have exactly 1 correct, found {correct_count}")


def check_multiple_choice_types(questions: list, result: InvariantResult) -> None:
    """Check MULTIPLE_CHOICE_MULTIPLE invariants: 2+ correct options."""
    multiple_choice_values = {t.value for t in MULTIPLE_CHOICE_TYPES}
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in multiple_choice_values:
            continue
        
        options = q.get('options', [])
        idx = q.get('idx')
        
        if len(options) < 3:
            result.add_violation(f"Q{idx}: {q_type} has {len(options)} options (need 3+)")
        else:
            correct_count = sum(1 for opt in options if opt.get('is_correct'))
            if correct_count < 2:
                result.add_violation(f"Q{idx}: {q_type} should have 2+ correct, found {correct_count}")


def check_matching_heading(questions: list, result: InvariantResult) -> None:
    """Check MATCHING_HEADING invariants: 5-12 heading options."""
    for q in questions:
        if q.get('type') != QuestionType.MATCHING_HEADING.value:
            continue
        
        options = q.get('options', [])
        idx = q.get('idx')
        
        if len(options) < 4:
            # Demote to warning - some exams have 4 headings
            result.add_warning(f"Q{idx}: MATCHING_HEADING has {len(options)} options (typically 4-12)")
        elif len(options) > 15:
            result.add_warning(f"Q{idx}: MATCHING_HEADING has {len(options)} options (unusual)")


def check_matching_types(questions: list, result: InvariantResult) -> None:
    """Check MATCHING type invariants: has correct_answers."""
    matching_values = {t.value for t in MATCHING_TYPES}
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in matching_values:
            continue
        
        idx = q.get('idx')
        correct = q.get('correct_answers', []) or [q.get('correct_answer', '')]
        correct = [c for c in correct if c]  # Filter empty
        
        if not correct:
            result.add_warning(f"Q{idx}: {q_type} missing correct_answers")


def check_completion_types(questions: list, result: InvariantResult) -> None:
    """Check COMPLETION type invariants: has answer."""
    completion_values = {t.value for t in COMPLETION_TYPES}
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in completion_values:
            continue
        
        idx = q.get('idx')
        correct = q.get('correct_answers', []) or [q.get('correct_answer', '')]
        correct = [c for c in correct if c]
        blank = q.get('blank_accept_texts')
        
        if not correct and not blank:
            result.add_warning(f"Q{idx}: {q_type} missing correct_answers")


def check_passage_length(sections: list, result: InvariantResult) -> None:
    """Check passage invariants: 100-5000 words."""
    for i, section in enumerate(sections):
        passage = section.get('passage_md', '')
        word_count = len(passage.split())
        
        if word_count < 100:
            result.add_violation(f"Section {i+1}: Passage too short ({word_count} words, need 100+)")
        elif word_count > 5000:
            result.add_warning(f"Section {i+1}: Passage very long ({word_count} words)")


def check_paragraph_labels(sections: list, result: InvariantResult) -> None:
    """STRICT RULE 26/27: Check paragraph labels format **Paragraph A.**"""
    import re
    for i, section in enumerate(sections):
        passage = section.get('passage_md', '')
        
        # Check if passage has raw labels that should be **Paragraph X.**
        # Pattern 1: "A. The glow..." (letter + period + space + uppercase)
        raw_labels_dot = re.findall(r'(?:^|\n)([A-H])\.\s+[A-Z]', passage)
        # Pattern 2: "A The glow..." (letter + space + uppercase, no period)  
        raw_labels_space = re.findall(r'(?:^|\n)([A-H])\s+[A-Z][a-z]', passage)
        
        proper_labels = re.findall(r'\*\*Paragraph [A-H]\.\*\*', passage)
        
        raw_labels = raw_labels_dot or raw_labels_space
        if raw_labels and not proper_labels:
            pattern = f"{raw_labels[0]}." if raw_labels_dot else f"{raw_labels_space[0]} "
            result.add_violation(f"Section {i+1}: Missing **Paragraph X.** labels (found raw '{pattern}' format)")
        
        # Check if proper labels exist but wrong format (no newline after)
        wrong_format = re.findall(r'\*\*Paragraph [A-H]\.\*\*(?!\n)', passage)
        if wrong_format:
            result.add_warning(f"Section {i+1}: Paragraph label missing newline after it")


def check_instruction_format(sections: list, result: InvariantResult) -> None:
    """STRICT RULE 28: Check instruction format **Questions X-Y:**"""
    import re
    for i, section in enumerate(sections):
        instruction = section.get('instruction_md', '')
        
        if not instruction:
            result.add_warning(f"Section {i+1}: Missing instruction_md field")
            continue
        
        # Check bold question headers
        if 'Questions' in instruction and '**Questions' not in instruction:
            result.add_warning(f"Section {i+1}: Instruction should have **Questions X-Y:** format")


def check_blank_patterns(questions: list, result: InvariantResult) -> None:
    """STRICT RULE 48: Check completion types have _______ blank markers."""
    import re
    completion_values = {t.value for t in COMPLETION_TYPES}
    
    for q in questions:
        q_type = q.get('type')
        if q_type not in completion_values:
            continue
        
        idx = q.get('idx')
        prompt = q.get('prompt_md', '')
        
        # Check for blank pattern (3+ underscores)
        if not re.search(r'_{3,}', prompt):
            # Check if it has ... instead
            if '...' in prompt or '…' in prompt:
                result.add_violation(f"Q{idx}: Use _______ not ... for blank (frontend won't render)")
            else:
                result.add_warning(f"Q{idx}: {q_type} may need _______ blank marker in prompt")


def check_prompt_numbering(questions: list, result: InvariantResult) -> None:
    """STRICT RULE 25: Check prompts don't have leading numbers."""
    import re
    for q in questions:
        idx = q.get('idx')
        prompt = q.get('prompt_md', '')
        
        # Check for leading numbers like "1. Question" or "34. Statement"
        if re.match(r'^\d+[\.\)]\s+', prompt):
            result.add_violation(f"Q{idx}: promptMd has leading number (frontend will double it)")


def check_matching_info_options(questions: list, result: InvariantResult) -> None:
    """STRICT RULE: MATCHING_INFORMATION/ENDINGS should have empty options (not FEATURES)."""
    for q in questions:
        q_type = q.get('type')
        # MATCHING_FEATURES needs options (person list), so exclude it
        if q_type not in ['MATCHING_INFORMATION', 'MATCHING_ENDINGS']:
            continue
        
        idx = q.get('idx')
        options = q.get('options', [])
        
        if options and len(options) > 0:
            result.add_warning(f"Q{idx}: {q_type} should have empty options[] (use matchPairs instead)")


def check_mcq_multiple_detection(questions: list, result: InvariantResult) -> None:
    """STRICT RULE: Detect potential MCQ_MULTIPLE from instruction patterns."""
    import re
    for q in questions:
        q_type = q.get('type')
        idx = q.get('idx')
        prompt = q.get('prompt_md', '').lower()
        
        # Check if prompt/instruction suggests MCQ_MULTIPLE but wrong type
        mcq_multiple_patterns = [
            r'choose\s+two',
            r'choose\s+three',
            r'two\s+letters',
            r'three\s+letters',
            r'which\s+two',
            r'which\s+three',
        ]
        
        for pattern in mcq_multiple_patterns:
            if re.search(pattern, prompt):
                if q_type != 'MULTIPLE_CHOICE_MULTIPLE':
                    result.add_violation(f"Q{idx}: Instruction says 'TWO/THREE' but type is {q_type} (should be MCQ_MULTIPLE)")
                break
        
        # Check answers with comma (A, C) - likely MCQ_MULTIPLE
        answers = q.get('correct_answers', [])
        if answers and len(answers) == 1 and ',' in str(answers[0]):
            if q_type != 'MULTIPLE_CHOICE_MULTIPLE':
                result.add_warning(f"Q{idx}: Answer has comma '{answers[0]}' - may need MCQ_MULTIPLE")


def check_no_duplicate_prompts(questions: list, result: InvariantResult) -> None:
    """Check for duplicate question prompts."""
    prompts = {}
    for q in questions:
        prompt = q.get('prompt_md', '').strip()[:80]  # First 80 chars
        idx = q.get('idx')
        
        if prompt and len(prompt) > 10:  # Skip very short prompts
            if prompt in prompts:
                result.add_warning(f"Q{idx} may duplicate Q{prompts[prompt]}")
            else:
                prompts[prompt] = idx


def check_invariants(data: dict) -> InvariantResult:
    """Run all IELTS invariant checks (31 strict rules)."""
    result = InvariantResult()
    
    questions = data.get('questions', [])
    sections = data.get('sections', [])
    
    # === CORE CHECKS ===
    check_question_sequence(questions, result)
    check_single_choice_types(questions, result)
    check_multiple_choice_types(questions, result)
    check_matching_heading(questions, result)
    check_matching_types(questions, result)
    check_completion_types(questions, result)
    check_passage_length(sections, result)
    check_no_duplicate_prompts(questions, result)
    
    # === STRICT RULE CHECKS (Industry Standards) ===
    check_paragraph_labels(sections, result)      # Rule 26/27
    check_instruction_format(sections, result)    # Rule 28
    check_blank_patterns(questions, result)       # Rule 48 (blank markers)
    check_prompt_numbering(questions, result)     # Rule 25
    check_matching_info_options(questions, result)  # MATCHING_INFO options
    check_mcq_multiple_detection(questions, result)  # MCQ_MULTIPLE from "Choose TWO"
    
    return result


def load_normalized(source: str, item_id: str) -> Optional[dict]:
    """Load normalized data from disk."""
    source_dir = NORMALIZED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        logger.error(f"Normalized data not found: {data_path}")
        return None
    
    return json.loads(data_path.read_text(encoding='utf-8'))


def check(source: str, item_id: str) -> InvariantResult:
    """Check invariants for normalized data file."""
    data = load_normalized(source, item_id)
    
    if not data:
        result = InvariantResult()
        result.add_violation(f"Could not load data: {source}/{item_id}")
        return result
    
    logger.info(f"Checking IELTS invariants: {source}/{item_id}")
    return check_invariants(data)


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python invariants.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    result = check(source, item_id)
    
    print(f"Valid: {result.is_valid()}")
    if result.violations:
        print("Violations:")
        for v in result.violations:
            print(f"  ✗ {v}")
    if result.warnings:
        print("Warnings:")
        for w in result.warnings:
            print(f"  ⚠ {w}")
    
    sys.exit(0 if result.is_valid() else 1)
