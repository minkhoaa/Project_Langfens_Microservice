"""Adversary Output Validation and Outside-Knowledge Defense (P10-04).

Invariants:
- Validates adversary output schema (ambiguity type, plausible alternatives, cited spans).
- Rigorously checks that cited spans exist verbatim in the approved passage.
- Rejects unsupported outside-knowledge allegations without passage grounding.
- Outside-knowledge allegations MUST NOT fail a valid IELTS item.
- Genuine grounded ambiguity creates a HIGH severity blocker.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Any, Dict, List, Optional, Tuple

from app.contracts.solver import (
    AdversaryAlternative,
    AdversaryAmbiguityType,
    AdversaryOutput,
    SolverSpan,
)

logger = logging.getLogger(__name__)


def parse_and_validate_adversary_output(
    raw_output: Any,
    passage_text: str,
    expected_question_number: int,
) -> Tuple[Optional[AdversaryOutput], List[str], List[Dict[str, Any]]]:
    """Parses raw adversary response, validates grounding, and rejects outside-knowledge claims.

    Returns:
        (AdversaryOutput, parsing_errors, rejected_unsupported_allegations)
    """
    errors: List[str] = []
    unsupported_allegations: List[Dict[str, Any]] = []

    # 1. Parse JSON
    if isinstance(raw_output, str):
        cleaned_str = raw_output.strip()
        if cleaned_str.startswith("```"):
            cleaned_str = re.sub(r"^```(?:json)?\s*", "", cleaned_str)
            cleaned_str = re.sub(r"\s*```$", "", cleaned_str)
        try:
            data = json.loads(cleaned_str)
        except Exception as e:
            return None, [f"Failed to parse adversary output as valid JSON: {e}"], []
    elif isinstance(raw_output, dict):
        data = data = raw_output
    else:
        return None, [f"Expected JSON string or dict, got {type(raw_output).__name__}"], []

    q_num = data.get("questionNumber") or data.get("question_number") or expected_question_number
    raw_ambiguous = data.get("isAmbiguous") if "isAmbiguous" in data else data.get("is_ambiguous", False)
    is_ambiguous = bool(raw_ambiguous)

    summary = str(data.get("adversarySummary") or data.get("adversary_summary") or data.get("summary") or "").strip()
    if not summary:
        summary = "No summary provided by adversary"

    raw_alts = data.get("identifiedAlternatives") or data.get("identified_alternatives") or []
    grounded_alternatives: List[AdversaryAlternative] = []

    if isinstance(raw_alts, list):
        for idx, alt in enumerate(raw_alts):
            if not isinstance(alt, dict):
                continue

            alt_ans = str(alt.get("alternativeAnswer") or alt.get("alternative_answer") or "").strip()
            amb_type_str = str(alt.get("ambiguityType") or alt.get("ambiguity_type") or "MULTIPLE_VALID_OPTIONS").upper()
            try:
                amb_type = AdversaryAmbiguityType(amb_type_str)
            except ValueError:
                amb_type = AdversaryAmbiguityType.MULTIPLE_VALID_OPTIONS

            reasoning = str(alt.get("reasoning", "")).strip()
            score = float(alt.get("plausibilityScore") or alt.get("plausibility_score", 0.8))
            is_grounded_flag = alt.get("isGroundedInPassage", True)

            raw_spans = alt.get("citedSpans") or alt.get("cited_spans") or []
            valid_spans: List[SolverSpan] = []
            has_invalid_span = False

            for s in raw_spans:
                if isinstance(s, dict):
                    stext = str(s.get("spanText") or s.get("span_text") or "").strip()
                elif isinstance(s, str):
                    stext = s.strip()
                else:
                    continue

                if not stext:
                    continue

                pos = passage_text.find(stext)
                if pos == -1:
                    has_invalid_span = True
                else:
                    valid_spans.append(
                        SolverSpan(
                            span_text=stext,
                            start_char=pos,
                            end_char=pos + len(stext),
                        )
                    )

            # Check if this allegation relies on outside knowledge rather than passage
            outside_knowledge_detected = (
                not is_grounded_flag
                or (not valid_spans and amb_type != AdversaryAmbiguityType.VAGUE_PROMPT)
                or has_invalid_span
                or any(term in reasoning.lower() for term in ("in the real world", "outside knowledge", "general fact", "external fact", "scientifically speaking"))
            )

            if outside_knowledge_detected and not valid_spans:
                # Classify as unsupported outside-knowledge allegation
                unsupported_allegations.append({
                    "alternative_answer": alt_ans,
                    "ambiguity_type": amb_type.value,
                    "reasoning": reasoning,
                    "rejection_reason": "Allegation relies on outside knowledge or missing passage text citation.",
                })
                logger.info(
                    "Adversary alternative '%s' rejected: unsupported outside knowledge.",
                    alt_ans,
                )
            else:
                grounded_alternatives.append(
                    AdversaryAlternative(
                        alternative_answer=alt_ans,
                        ambiguity_type=amb_type,
                        plausibility_score=score,
                        cited_spans=valid_spans,
                        reasoning=reasoning,
                        is_grounded_in_passage=True,
                    )
                )

    # If the adversary claimed ambiguous, but all alternatives were rejected as unsupported outside knowledge:
    # Do NOT fail the item! Set is_ambiguous to False.
    effective_ambiguous = bool(grounded_alternatives and is_ambiguous)

    adversary_output = AdversaryOutput(
        question_number=int(q_num),
        is_ambiguous=effective_ambiguous,
        identified_alternatives=grounded_alternatives,
        adversary_summary=summary,
    )

    return adversary_output, errors, unsupported_allegations
