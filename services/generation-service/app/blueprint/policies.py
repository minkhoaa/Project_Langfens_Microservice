"""Blueprint Policies and Rules for Langfens Loop Engine V2."""

from __future__ import annotations

from typing import Dict, List, Tuple
from app.contracts.blueprint import QuestionType

BLUEPRINT_POLICY_VERSION = "v2.0.0"
BLUEPRINT_SCHEMA_VERSION = "v2.0.0"

# Word count boundaries
SECTION_MIN_WORDS = 720
SECTION_MAX_WORDS = 915
PAPER_MIN_WORDS = 2150
PAPER_MAX_WORDS = 2750

# Question counts per section
SECTION_QUESTION_COUNTS: Dict[int, int] = {
    1: 13,
    2: 13,
    3: 14,
}
TOTAL_PAPER_QUESTIONS = 40

# Section structure configuration
# Section 1: TFNG 7 + sentence completion 6, Q1–13.
# Section 2: MCQ single 6 + summary completion 7, Q14–26.
# Section 3: YNNG 7 + short answer 7, Q27–40.
SECTION_CONFIGURATIONS = {
    1: {
        "start_question": 1,
        "end_question": 13,
        "total_questions": 13,
        "style": "Descriptive, factual, clear chronological or logical sequence",
        "groups": [
            {
                "group_index": 0,
                "question_type": QuestionType.TRUE_FALSE_NOT_GIVEN,
                "count": 7,
                "start_question_number": 1,
                "end_question_number": 7,
            },
            {
                "group_index": 1,
                "question_type": QuestionType.SENTENCE_COMPLETION,
                "count": 6,
                "start_question_number": 8,
                "end_question_number": 13,
            },
        ],
        "suitability_rules": {
            "min_distinct_claims": 6,
            "min_entities": 4,
            "requires_mechanisms": False,
            "requires_opinions": False,
        },
    },
    2: {
        "start_question": 14,
        "end_question": 26,
        "total_questions": 13,
        "style": "Analytical, mechanisms, processes, causal relationships",
        "groups": [
            {
                "group_index": 0,
                "question_type": QuestionType.MULTIPLE_CHOICE_SINGLE,
                "count": 6,
                "start_question_number": 14,
                "end_question_number": 19,
            },
            {
                "group_index": 1,
                "question_type": QuestionType.SUMMARY_COMPLETION,
                "count": 7,
                "start_question_number": 20,
                "end_question_number": 26,
            },
        ],
        "suitability_rules": {
            "min_distinct_claims": 6,
            "min_entities": 3,
            "requires_mechanisms": True,
            "requires_opinions": False,
        },
    },
    3: {
        "start_question": 27,
        "end_question": 40,
        "total_questions": 14,
        "style": "Argumentative, hypotheses, opinions, perspectives, debate",
        "groups": [
            {
                "group_index": 0,
                "question_type": QuestionType.YES_NO_NOT_GIVEN,
                "count": 7,
                "start_question_number": 27,
                "end_question_number": 33,
            },
            {
                "group_index": 1,
                "question_type": QuestionType.SHORT_ANSWER,
                "count": 7,
                "start_question_number": 34,
                "end_question_number": 40,
            },
        ],
        "suitability_rules": {
            "min_distinct_claims": 6,
            "min_entities": 2,
            "requires_mechanisms": False,
            "requires_opinions": True,
        },
    },
}

# Budget allocation defaults
DEFAULT_MAX_CANDIDATES_PER_SLOT = 1
DEFAULT_REPAIR_HEADROOM_CALLS = 2
DEFAULT_MAX_TOKENS_PER_SECTION = 15000
MAX_CANDIDATES_PER_SLOT_CAP = 3
