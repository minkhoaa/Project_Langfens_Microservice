"""Listening auto-gen prompt builders.

Generates 4 sections (form completion, matching, MCQ, note completion)
matching IELTS Listening academic module conventions.
"""
from __future__ import annotations


def build_section1_prompt(topic: str, level: int, count: int) -> str:
    """Section 1: form completion (social context, 2 speakers).

    Args:
        topic: Topic for the listening passage (e.g. "hotel booking").
        level: IELTS band level 1-9.
        count: Number of questions in this section (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\n"
        f"Level: band {level}\n\n"
        f"Generate Section 1 of an IELTS Listening test (form completion).\n\n"
        f"Section 1 must:\n"
        f"- Be a social context (e.g. hotel, travel, library, shop).\n"
        f"- Have exactly 2 speakers with a transactional conversation.\n"
        f"- Include a form with blanks (e.g. hotel registration, booking form).\n"
        f"- Have {count} questions.\n\n"
        f"Output ONLY the JSON object with this shape:\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\n\n'
        f"Constraints:\n"
        f"- audio_script: 800-1500 tokens of spoken dialogue.\n"
        f"- questions: FORM_COMPLETION type, blankAcceptTexts keys are 1-indexed (e.g. '1', '2').\n"
        f"- promptMd must use [N] placeholders (e.g. [1], [2]) matching blankAcceptTexts keys.\n"
        f"- Each blank value can be string[] (multiple acceptable spellings)."
    )


def build_section2_prompt(topic: str, level: int, count: int) -> str:
    """Section 2: matching (monologue, e.g. tour guide, library intro).

    Args:
        topic: Topic for the listening passage.
        level: IELTS band level 1-9.
        count: Number of questions (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\n"
        f"Level: band {level}\n\n"
        f"Generate Section 2 of an IELTS Listening test (matching).\n\n"
        f"Section 2 must:\n"
        f"- Be a monologue (1 speaker).\n"
        f"- Have {count} questions matching items to options.\n"
        f"- Use MATCHING_FEATURES type.\n\n"
        f"Output ONLY the JSON object with this shape:\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\n\n'
        f"Constraints:\n"
        f"- audio_script: 1000-1500 tokens.\n"
        f"- questions: MATCHING_FEATURES type, matchPairs values must be [acceptedKey, displayLabel].\n"
        f"- matchPairs keys must be 1-indexed string numbers ('1', '2', ...).\n"
        f"- promptMd must contain numbered items (e.g. '1. First item\\n2. Second item') matching matchPairs keys.\n"
        f"- 4-8 options in the matching pool (e.g. A-H)."
    )


def build_section3_prompt(topic: str, level: int, count: int) -> str:
    """Section 3: MCQ (academic discussion, 2-4 speakers).

    Args:
        topic: Topic for the listening passage.
        level: IELTS band level 1-9.
        count: Number of questions (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\n"
        f"Level: band {level}\n\n"
        f"Generate Section 3 of an IELTS Listening test (MCQ).\n\n"
        f"Section 3 must:\n"
        f"- Be an academic discussion (2-4 speakers, e.g. students + tutor).\n"
        f"- Have {count} multiple choice questions.\n"
        f"- Mix MULTIPLE_CHOICE_SINGLE and MULTIPLE_CHOICE_MULTIPLE types.\n\n"
        f"Output ONLY the JSON object with this shape:\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\n\n'
        f"Constraints:\n"
        f"- audio_script: 1000-1500 tokens.\n"
        f"- questions: MULTIPLE_CHOICE_SINGLE or MULTIPLE_CHOICE_MULTIPLE type.\n"
        f"- options[].contentMd follows 'A. text' convention.\n"
        f"- options[].isCorrect must be boolean (exactly 1 true for MULTIPLE_CHOICE_SINGLE, multiple true for MULTIPLE_CHOICE_MULTIPLE).\n"
        f"- 4 options for single, 5-8 options for multiple."
    )


def build_section4_prompt(topic: str, level: int, count: int) -> str:
    """Section 4: note completion (academic lecture monologue).

    Args:
        topic: Topic for the listening passage.
        level: IELTS band level 1-9.
        count: Number of questions (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\n"
        f"Level: band {level}\n\n"
        f"Generate Section 4 of an IELTS Listening test (note completion).\n\n"
        f"Section 4 must:\n"
        f"- Be an academic monologue (1 speaker, lecture style).\n"
        f"- Have {count} questions completing notes.\n"
        f"- Use NOTE_COMPLETION type.\n\n"
        f"Output ONLY the JSON object with this shape:\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\n\n'
        f"Constraints:\n"
        f"- audio_script: 1200-1500 tokens (academic lecture).\n"
        f"- questions: NOTE_COMPLETION type, blankAcceptTexts keys 1-indexed (e.g. '1', '2').\n"
        f"- promptMd uses [N] placeholders (e.g. [1], [2]) matching dict keys."
    )


SECTION_BUILDERS = (
    build_section1_prompt,
    build_section2_prompt,
    build_section3_prompt,
    build_section4_prompt,
)
