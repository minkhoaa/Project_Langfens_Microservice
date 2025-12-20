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
                result.add_violation(f"Q{idx}: {q_type} should have 1 correct, found {correct_count}")


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
        
        if len(options) < 5:
            result.add_violation(f"Q{idx}: MATCHING_HEADING has {len(options)} options (need 5-12)")
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
    """Run all IELTS invariant checks."""
    result = InvariantResult()
    
    questions = data.get('questions', [])
    sections = data.get('sections', [])
    
    # Run all checks
    check_question_sequence(questions, result)
    check_single_choice_types(questions, result)
    check_multiple_choice_types(questions, result)
    check_matching_heading(questions, result)
    check_matching_types(questions, result)
    check_completion_types(questions, result)
    check_passage_length(sections, result)
    check_no_duplicate_prompts(questions, result)
    
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
