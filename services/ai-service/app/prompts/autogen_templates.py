"""Shared prompt template constants for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
Keep in sync manually OR via codegen (future Sprint 9).
"""
from __future__ import annotations

SYSTEM_PREFIX: str = """You are an IELTS content author. Generate {type} questions following the D5 spec.

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
