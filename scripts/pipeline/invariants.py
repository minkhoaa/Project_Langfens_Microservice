#!/usr/bin/env python3
"""
Stage 6: IELTS Invariants
Business rule validation for IELTS exams.
"""
import json
from pathlib import Path
from typing import Optional

from config import NORMALIZED_DIR, get_logger

logger = get_logger(__name__)


class InvariantResult:
    def __init__(self):
        self.violations: list[str] = []
        self.warnings: list[str] = []
    
    def add_violation(self, msg: str):
        self.violations.append(msg)
    
    def add_warning(self, msg: str):
        self.warnings.append(msg)
    
    def is_valid(self) -> bool:
        return len(self.violations) == 0
    
    def to_dict(self) -> dict:
        return {
            'valid': self.is_valid(),
            'violations': self.violations,
            'warnings': self.warnings,
        }


def check_question_sequence(questions: list[dict]) -> list[str]:
    """Check that questions are sequential with no gaps."""
    violations = []
    
    if not questions:
        violations.append("No questions found")
        return violations
    
    indices = sorted([q.get('idx', 0) for q in questions])
    
    # Check for gaps
    for i in range(len(indices) - 1):
        if indices[i+1] - indices[i] > 1:
            violations.append(f"Gap in question sequence: Q{indices[i]} -> Q{indices[i+1]}")
    
    # Check for duplicates
    if len(indices) != len(set(indices)):
        violations.append("Duplicate question indices found")
    
    return violations


def check_matching_heading(questions: list[dict]) -> list[str]:
    """Check MATCHING_HEADING invariants."""
    violations = []
    
    mh_questions = [q for q in questions if q.get('type') == 'MATCHING_HEADING']
    
    for q in mh_questions:
        options = q.get('options', [])
        
        # Should have 7-10 heading options
        if len(options) < 7:
            violations.append(f"Q{q.get('idx')}: MATCHING_HEADING has only {len(options)} options (expected 7-10)")
        elif len(options) > 12:
            violations.append(f"Q{q.get('idx')}: MATCHING_HEADING has {len(options)} options (too many)")
        
        # Options should be roman numerals
        for opt in options:
            value = opt.get('value', '')
            if not value or not all(c in 'ivx' for c in value.lower()):
                violations.append(f"Q{q.get('idx')}: Option '{value}' is not a roman numeral")
                break
    
    return violations


def check_multiple_choice(questions: list[dict]) -> list[str]:
    """Check MULTIPLE_CHOICE invariants."""
    violations = []
    
    mc_questions = [q for q in questions if q.get('type') in ['MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE']]
    
    for q in mc_questions:
        options = q.get('options', [])
        
        # Should have 3-5 options
        if len(options) < 3:
            violations.append(f"Q{q.get('idx')}: MULTIPLE_CHOICE has only {len(options)} options (expected 3-5)")
        elif len(options) > 6:
            violations.append(f"Q{q.get('idx')}: MULTIPLE_CHOICE has {len(options)} options (too many)")
        
        # Check exactly one correct answer for SINGLE
        if q.get('type') == 'MULTIPLE_CHOICE_SINGLE':
            correct_count = sum(1 for opt in options if opt.get('is_correct'))
            if correct_count != 1:
                violations.append(f"Q{q.get('idx')}: MULTIPLE_CHOICE_SINGLE should have exactly 1 correct answer, found {correct_count}")
    
    return violations


def check_summary_completion(questions: list[dict]) -> list[str]:
    """Check SUMMARY_COMPLETION invariants."""
    violations = []
    
    sc_questions = [q for q in questions if q.get('type') == 'SUMMARY_COMPLETION']
    
    for q in sc_questions:
        prompt = q.get('prompt_md', '')
        
        # Should have blank marker
        if '_______' not in prompt and '...' not in prompt and '………' not in prompt:
            violations.append(f"Q{q.get('idx')}: SUMMARY_COMPLETION missing blank marker in prompt")
        
        # Should have correct answer
        if not q.get('correct_answers'):
            violations.append(f"Q{q.get('idx')}: SUMMARY_COMPLETION missing correct_answers")
    
    return violations


def check_passage(sections: list[dict]) -> list[str]:
    """Check passage invariants."""
    violations = []
    
    for i, section in enumerate(sections):
        passage = section.get('passage_md', '')
        word_count = len(passage.split())
        
        if word_count < 200:
            violations.append(f"Section {i+1}: Passage too short ({word_count} words, expected 200-3000)")
        elif word_count > 3000:
            violations.append(f"Section {i+1}: Passage too long ({word_count} words, expected 200-3000)")
    
    return violations


def check_no_duplicates(questions: list[dict]) -> list[str]:
    """Check for duplicate question prompts."""
    warnings = []
    
    prompts = {}
    for q in questions:
        prompt = q.get('prompt_md', '').strip()
        if prompt in prompts:
            warnings.append(f"Q{q.get('idx')} has same prompt as Q{prompts[prompt]}")
        else:
            prompts[prompt] = q.get('idx')
    
    return warnings


def validate_invariants(data: dict) -> InvariantResult:
    """Run all IELTS invariant checks."""
    result = InvariantResult()
    
    questions = data.get('questions', [])
    sections = data.get('sections', [])
    
    # Run all checks
    for v in check_question_sequence(questions):
        result.add_violation(v)
    
    for v in check_matching_heading(questions):
        result.add_violation(v)
    
    for v in check_multiple_choice(questions):
        result.add_violation(v)
    
    for v in check_summary_completion(questions):
        result.add_violation(v)
    
    for v in check_passage(sections):
        result.add_violation(v)
    
    for w in check_no_duplicates(questions):
        result.add_warning(w)
    
    return result


def validate_file(source: str, item_id: str) -> InvariantResult:
    """Validate invariants for a normalized JSON file."""
    source_dir = NORMALIZED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        result = InvariantResult()
        result.add_violation(f"File not found: {data_path}")
        return result
    
    data = json.loads(data_path.read_text(encoding='utf-8'))
    return validate_invariants(data)


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python invariants.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    result = validate_file(source, item_id)
    
    print(f"Valid: {result.is_valid()}")
    if result.violations:
        print("Violations:")
        for v in result.violations:
            print(f"  ✗ {v}")
    if result.warnings:
        print("Warnings:")
        for w in result.warnings:
            print(f"  ⚠ {w}")
