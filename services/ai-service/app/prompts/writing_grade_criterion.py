"""Writing grade prompt with per-criterion evidence block.

This is a parallel implementation of `writing_grade.build_grade_prompt`
that injects a <criterion_evidence> block containing 4 named sections
(ta, cc, lr, gr) and forces the LLM to emit `evidence_ids` per
sub-band score.
"""
from typing import Iterable

# Reuse the existing per-task examiner prompt bodies.
from app.prompts.writing_grade import (
    WRITING_GRADE_PROMPT_TASK1,
    WRITING_GRADE_PROMPT_TASK2,
)

CRITERION_HEADERS = {
    "ta": "## Task Response",
    "cc": "## Coherence & Cohesion",
    "lr": "## Lexical Resource",
    "gr": "## Grammatical Range & Accuracy",
}

def _render_ref(ref: dict) -> str:
    band = ref.get("band")
    band_suffix = f" (Band {band})" if band else ""
    text = (ref.get("text") or "").strip()[:600]
    return f"[{ref['id']}]{band_suffix} {text}"

def build_criterion_evidence_block(rag_by_criterion: dict) -> str:
    parts: list[str] = []
    for crit, header in CRITERION_HEADERS.items():
        refs = rag_by_criterion.get(crit) or []
        parts.append(header)
        if not refs:
            parts.append("No reference essays retrieved for this criterion.")
        else:
            parts.append("\n".join(_render_ref(r) for r in refs))
        parts.append("")  # blank line
    return "\n".join(parts).rstrip()

def build_grade_prompt_criterion(
    task: str,
    essay: str,
    word_count: int,
    rag_by_criterion: dict,
    task_type: str = "TASK_2",
    chart_description: str | None = None,
) -> str:
    evidence = build_criterion_evidence_block(rag_by_criterion)
    body = WRITING_GRADE_PROMPT_TASK1 if task_type == "TASK_1" else WRITING_GRADE_PROMPT_TASK2

    # Note: we intentionally REPLACE the <reference_context> block from
    # the original prompt with our <criterion_evidence> block. The
    # original body still asks for the JSON shape; we post-process by
    # augmenting the `c` field requirement to demand evidence_ids.
    augmented_body = body.replace(
        "Output ONLY one JSON object with EXACTLY this structure",
        "Output ONLY one JSON object with EXACTLY this structure (each criterion's object MUST include an `evidence_ids` array of reference ids that ground the score)",
    )

    if task_type == "TASK_1":
        cd = chart_description or "No chart description available."
        return f"""WC:{word_count}
T:{task}
CD:{cd}
E:{essay}

<criterion_evidence>
{evidence}
</criterion_evidence>

{augmented_body}"""

    return f"""WC:{word_count}
T:{task}
E:{essay}

<criterion_evidence>
{evidence}
</criterion_evidence>

{augmented_body}"""
