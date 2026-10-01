"""Prompt builders for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
"""
from __future__ import annotations

from app.prompts.autogen_data import GLOBAL_CONSTRAINTS
from app.prompts.autogen_templates import (
    STRICT_JSON_SUFFIX,
    SYSTEM_PREFIX,
    build_user_prompt_template,
)


def build_system_prompt(qtype: str, json_shape: str, constraints: list[str]) -> str:
    """Build the system prompt for a given question type.

    Args:
        qtype: QuestionType enum value.
        json_shape: The canonical JSON shape string from autogen_data.py.
        constraints: List of constraint strings for this type.

    Returns:
        Complete system prompt (prefix + jsonShape + suffix).
    """
    combined_constraints: list[str] = list(GLOBAL_CONSTRAINTS) + [
        c for c in constraints if c not in GLOBAL_CONSTRAINTS
    ]
    return (
        SYSTEM_PREFIX
        .replace("{type}", qtype)
        .replace("{constraints}", "\n- ".join(combined_constraints))
        .replace("{jsonShape}", json_shape)
        + STRICT_JSON_SUFFIX
    )


def build_user_prompt(
    qtype: str,
    passage: str,
    count: int,
    difficulty: int,
    extra: str = "",
    skill: str = "READING",
) -> str:
    """Build the user prompt for a given question type.

    Args:
        qtype: QuestionType enum value.
        passage: Source passage / material.
        count: Number of questions to generate (1-10).
        difficulty: Difficulty 1-5.
        extra: Optional extra context.
        skill: Skill name (READING, LISTENING, etc.). Default "READING".

    Returns:
        Formatted user prompt string.
    """
    template = build_user_prompt_template(qtype)
    extra_line: str = f"\nExtra context: {extra}\n" if extra else ""
    return (
        template
        .replace("{passage}", passage)
        .replace("{count}", str(count))
        .replace("{difficulty}", str(difficulty))
        .replace("{skill}", skill)
        .replace("{extra_line}", extra_line)
    )
