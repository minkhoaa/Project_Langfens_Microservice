"""Shared prompt template constants for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
Keep in sync manually OR via codegen (future Sprint 9).
"""
from __future__ import annotations

SYSTEM_PREFIX: str = """You are an IELTS content author. Generate {type} questions following the canonical IELTS specification.

CRITICAL LANGUAGE AND INTEGRITY INVARIANTS:
- All question content, instructions, prompts, options, headings, explanations, and answers MUST be strictly in English only. Never output Vietnamese or any non-English text.
- Every question MUST have a valid, non-empty, assessable answer key. Placeholder text ('Item 1', 'Paragraph 1', 'Option A', 'TBD', 'N/A') is strictly forbidden as an answer key.
- Ground all answers and evidence strictly in the provided passage.

Constraints (per type):
- {constraints}

Required JSON shape:
```
{jsonShape}
```
"""

STRICT_JSON_SUFFIX: str = """
Strict JSON mode:
- Output ONLY a single JSON object of the form: {"questions": [...]}.
- No prose, no markdown fences outside the JSON block, no explanation.
- Each item in the "questions" array MUST match the jsonShape above exactly.
- difficulty MUST be an integer in [1, 5].
- All candidate-facing text MUST be in English only.
- If the JSON cannot be produced, output {"error": "reason"} instead."""


def build_user_prompt_template(qtype: str) -> str:
    """Build the user prompt template for a given question type.

    Args:
        qtype: QuestionType enum value (e.g. "MULTIPLE_CHOICE_SINGLE").

    Returns:
        The user prompt template with {passage}, {count}, {difficulty},
        {skill}, {extra_line} placeholders.
    """
    return (
        "Source passage:\n\"\"\"\n{passage}\n\"\"\"\n\n"
        f"Generate {{count}} {qtype} question(s) for skill {{skill}} at difficulty {{difficulty}}.{{extra_line}}\n\n"
        "Output: a JSON object with a \"questions\" array containing {count} item(s)."
    )
