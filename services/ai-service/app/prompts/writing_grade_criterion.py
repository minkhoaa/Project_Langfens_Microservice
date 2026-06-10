"""Writing grade prompt with per-criterion evidence block.

This is a parallel implementation of `writing_grade.build_grade_prompt`
that injects a <criterion_evidence> block containing 4 named sections
(ta, cc, lr, gr) and forces the LLM to emit `evidence_ids` per
sub-band score.

The `gr` section additionally includes a "Grammar rules" subsection
grounded on the `grammar_knowledge` Qdrant collection. These explicit
rules anchor the LLM's grammar judgment on real IELTS-typical rules
(subject-verb agreement, article use, conditionals, etc.) instead of
purely on essay-exemplar similarity. Rules are populated by
`per_criterion_rag.retrieve()` and passed in via the `grammar_rules`
key of `rag_by_criterion`.
"""
from typing import Iterable

# Reuse the existing per-task examiner prompt bodies.
from app.prompts.writing_grade import (
    WRITING_GRADE_PROMPT_TASK1,
    WRITING_GRADE_PROMPT_TASK2,
)
from app.services.grammar_service import format_grammar_rules_for_gr_evidence

CRITERION_HEADERS = {
    "ta": "## Task Response",
    "cc": "## Coherence & Cohesion",
    "lr": "## Lexical Resource",
    "gr": "## Grammatical Range & Accuracy",
}

def _render_ref(ref) -> str:
    """Render a single reference. Accepts both Pydantic models (ReassembledEssay)
    and plain dicts so the prompt builder works against the production objects
    (`grade_service` passes `ReassembledEssay`) and the unit tests (which pass
    dicts) without crashing on `.get()`.
    """
    def _get(key, default=None):
        if isinstance(ref, dict):
            return ref.get(key, default)
        return getattr(ref, key, default)

    band = _get("band")
    band_suffix = f" (Band {band})" if band else ""
    text = (_get("text") or "").strip()[:600]
    rid = _get("id") or _get("parent_id") or "?"
    return f"[{rid}]{band_suffix} {text}"

def _render_gr_block(refs: list, grammar_rules) -> str:
    """Render the `gr` evidence block: essay refs + grammar rules subsection.

    Essay refs are first-class evidence (the LLM cites them via
    `evidence_ids`). Grammar rules are secondary context that the LLM
    can use to make the `c` field more rule-specific (e.g. name the
    rule being violated) without being required to cite them.
    """
    parts: list[str] = []
    if not refs:
        parts.append("No reference essays retrieved for this criterion.")
    else:
        parts.append("\n".join(_render_ref(r) for r in refs))

    parts.append("")  # blank line before the rules subsection
    parts.append("### Grammar rules (ground the `c` field on these)")
    parts.append(format_grammar_rules_for_gr_evidence(grammar_rules or []))

    return "\n".join(parts).rstrip()

def build_criterion_evidence_block(rag_by_criterion: dict) -> str:
    parts: list[str] = []
    grammar_rules = rag_by_criterion.get("grammar_rules") or []
    for crit, header in CRITERION_HEADERS.items():
        refs = rag_by_criterion.get(crit) or []
        parts.append(header)
        if crit == "gr":
            parts.append(_render_gr_block(refs, grammar_rules))
        else:
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

    # Strip the original <reference_context>...{rag_context}...</reference_context>
    # block from the body. We replace it with our <criterion_evidence> block, but
    # if the literal {rag_context} template variable remains in the prompt, the
    # LLM tries to fill it in and emits malformed JSON (Groq responds 400
    # `json_validate_failed`).
    import re
    body = re.sub(
        r"<reference_context>.*?</reference_context>\s*",
        "",
        body,
        flags=re.DOTALL,
    )

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
