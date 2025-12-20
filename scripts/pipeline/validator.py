#!/usr/bin/env python3
"""
Stage 5: Validator
JSON Schema validation for normalized exam data.
"""
import json
from pathlib import Path
from typing import Optional

from config import NORMALIZED_DIR, get_logger

logger = get_logger(__name__)

# Inline schema (subset of exam-import.schema.json)
EXAM_SCHEMA = {
    "required": ["exam", "sections", "questions"],
    "exam_required": ["title", "slug", "category"],
    "section_required": ["idx", "title", "passage_md"],
    "question_required": ["idx", "type", "prompt_md"],
    "valid_types": [
        "TRUE_FALSE_NOT_GIVEN",
        "YES_NO_NOT_GIVEN", 
        "MULTIPLE_CHOICE_SINGLE",
        "MULTIPLE_CHOICE_MULTIPLE",
        "MATCHING_HEADING",
        "MATCHING_INFORMATION",
        "MATCHING_FEATURES",
        "SUMMARY_COMPLETION",
        "SHORT_ANSWER",
        "SENTENCE_COMPLETION",
    ]
}


class ValidationResult:
    def __init__(self):
        self.errors: list[str] = []
        self.warnings: list[str] = []
    
    def add_error(self, msg: str):
        self.errors.append(msg)
    
    def add_warning(self, msg: str):
        self.warnings.append(msg)
    
    def is_valid(self) -> bool:
        return len(self.errors) == 0
    
    def to_dict(self) -> dict:
        return {
            'valid': self.is_valid(),
            'errors': self.errors,
            'warnings': self.warnings,
        }


def validate_structure(data: dict) -> ValidationResult:
    """Validate basic structure of normalized data."""
    result = ValidationResult()
    
    # Check required top-level keys
    for key in EXAM_SCHEMA['required']:
        if key not in data:
            result.add_error(f"Missing required key: {key}")
    
    if not result.is_valid():
        return result
    
    # Validate exam
    exam = data.get('exam', {})
    for key in EXAM_SCHEMA['exam_required']:
        if key not in exam or not exam[key]:
            result.add_error(f"exam.{key} is required")
    
    # Validate sections
    sections = data.get('sections', [])
    if not sections:
        result.add_error("At least one section is required")
    
    for i, section in enumerate(sections):
        for key in EXAM_SCHEMA['section_required']:
            if key not in section:
                result.add_error(f"sections[{i}].{key} is required")
        
        if section.get('passage_md') and len(section['passage_md']) < 100:
            result.add_warning(f"sections[{i}].passage_md seems too short")
    
    # Validate questions
    questions = data.get('questions', [])
    if not questions:
        result.add_error("At least one question is required")
    
    for i, q in enumerate(questions):
        for key in EXAM_SCHEMA['question_required']:
            if key not in q:
                result.add_error(f"questions[{i}].{key} is required")
        
        q_type = q.get('type')
        if q_type and q_type not in EXAM_SCHEMA['valid_types']:
            result.add_error(f"questions[{i}].type '{q_type}' is invalid")
        
        # Type-specific validation
        if q_type in ['MULTIPLE_CHOICE_SINGLE', 'MULTIPLE_CHOICE_MULTIPLE', 'MATCHING_HEADING']:
            if not q.get('options') or len(q.get('options', [])) < 2:
                result.add_error(f"questions[{i}] ({q_type}) requires options")
        
        if q_type == 'SUMMARY_COMPLETION':
            if not q.get('correct_answers'):
                result.add_warning(f"questions[{i}] (SUMMARY_COMPLETION) missing correct_answers")
    
    return result


def validate_file(source: str, item_id: str) -> ValidationResult:
    """Validate a normalized JSON file."""
    source_dir = NORMALIZED_DIR / source
    data_path = source_dir / f"{item_id}.json"
    
    if not data_path.exists():
        result = ValidationResult()
        result.add_error(f"File not found: {data_path}")
        return result
    
    try:
        data = json.loads(data_path.read_text(encoding='utf-8'))
    except json.JSONDecodeError as e:
        result = ValidationResult()
        result.add_error(f"Invalid JSON: {e}")
        return result
    
    return validate_structure(data)


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python validator.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    result = validate_file(source, item_id)
    
    print(f"Valid: {result.is_valid()}")
    if result.errors:
        print("Errors:")
        for e in result.errors:
            print(f"  ✗ {e}")
    if result.warnings:
        print("Warnings:")
        for w in result.warnings:
            print(f"  ⚠ {w}")
