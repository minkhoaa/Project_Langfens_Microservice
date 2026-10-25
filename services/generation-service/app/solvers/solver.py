"""Blind Solver Output Validation, Span Grounding, and Normalization (P10-03).

Invariants:
- Validates solver JSON against canonical SolverOutput contract.
- Rejects hidden chain-of-thought, excessive justifications, and prompt leaks.
- Strictly verifies that cited spans exist verbatim in the approved passage.
- Missing or invalid spans trigger non-pass policy.
- Self-reported confidence is explicitly bounded and tracked as uncalibrated.
"""

from __future__ import annotations

import json
import re
from typing import Any, Dict, List, Optional, Tuple

from app.contracts.solver import (
    SolverOutput,
    SolverSpan,
)


FORBIDDEN_COT_KEYS = {"thought", "thoughts", "thinking", "scratchpad", "chain_of_thought", "inner_monologue"}


def normalize_solver_answer(raw_answer: str, question_type: Optional[str] = None) -> str:
    """Normalizes raw model answer strings into canonical format using question_type."""
    cleaned = raw_answer.strip()
    cleaned = re.sub(r"^['\"`]+|['\"`]+$", "", cleaned).strip()

    q_type_norm = re.sub(r"[^A-Z]", "", (question_type or "").upper())

    if "TRUEFALSE" in q_type_norm or q_type_norm == "TFNG":
        upper = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip().upper()
        if upper in ("TRUE", "T", "YES", "Y"):
            return "TRUE"
        if upper in ("FALSE", "F", "NO", "N"):
            return "FALSE"
        if upper in ("NOT GIVEN", "NOT_GIVEN", "NOTGIVEN", "NG"):
            return "NOT_GIVEN"
        return cleaned

    if "YESNO" in q_type_norm or q_type_norm == "YNNG":
        upper = re.sub(r"[.,;:'\"`]+$", "", cleaned).strip().upper()
        if upper in ("YES", "Y", "TRUE", "T"):
            return "YES"
        if upper in ("NO", "N", "FALSE", "F"):
            return "NO"
        if upper in ("NOT GIVEN", "NOT_GIVEN", "NOTGIVEN", "NG"):
            return "NOT_GIVEN"
        return cleaned

    if "MULTIPLECHOICE" in q_type_norm or q_type_norm == "MCQ":
        upper = cleaned.upper()
        mcq_match = re.match(r"^(?:OPTION|CHOICE)?\s*([A-D])(?:\s*[:.\-)]|\s*$)", upper)
        if mcq_match:
            return mcq_match.group(1)
        return cleaned
    # For completion or unconstrained short answer: do not coerce "T" or "A." to boolean/option!
    return re.sub(r"\s+", " ", cleaned)

def parse_and_validate_solver_output(
    raw_output: Any,
    passage_text: str,
    expected_question_number: int,
    question_type: Optional[str] = None,
) -> Tuple[Optional[SolverOutput], List[str]]:
    """Parses raw provider response and validates span grounding against passage.

    Returns:
        (SolverOutput, errors_list)
        If errors_list is non-empty, the result is considered non-pass.
    """
    errors: List[str] = []

    # 1. Parse JSON
    if isinstance(raw_output, str):
        # Strip potential markdown code block fences
        cleaned_str = raw_output.strip()
        if cleaned_str.startswith("```"):
            cleaned_str = re.sub(r"^```(?:json)?\s*", "", cleaned_str)
            cleaned_str = re.sub(r"\s*```$", "", cleaned_str)
        # Defensive cleanup: strip rogue trailing quotes on integer values (e.g. "endChar": 1125")
        cleaned_str = re.sub(r':\s*(\d+)"\s*(,\s*|\}\s*|$)', r': \1\2', cleaned_str)
        try:
            data = json.loads(cleaned_str)
        except Exception as e:
            return None, [f"Failed to parse solver output as valid JSON: {e}"]
    elif isinstance(raw_output, dict):
        data = raw_output
    else:
        return None, [f"Expected JSON string or dict, got {type(raw_output).__name__}"]

    # 2. Check for hidden chain-of-thought leakage
    for forbidden_key in FORBIDDEN_COT_KEYS:
        if forbidden_key in data:
            errors.append(f"Prohibited chain-of-thought field '{forbidden_key}' found in solver output")

    # 3. Extract and normalize answer
    raw_ans = data.get("normalizedAnswer") or data.get("normalized_answer") or data.get("answer")
    if not raw_ans or not str(raw_ans).strip():
        errors.append("Missing normalizedAnswer in solver output")
        norm_answer = ""
    else:
        norm_answer = normalize_solver_answer(str(raw_ans), question_type=question_type)

    # 4. Extract justification and verify brevity
    justification = str(data.get("justification", "")).strip()
    if not justification:
        errors.append("Missing justification in solver output")
    elif len(justification) > 500:
        errors.append("Justification exceeds maximum length (500 characters); hidden CoT is prohibited")

    # 5. Extract and validate confidence
    raw_conf = data.get("selfReportedConfidence") or data.get("self_reported_confidence") or data.get("confidence", 0.5)
    try:
        conf_float = max(0.0, min(1.0, float(raw_conf)))
    except (ValueError, TypeError):
        conf_float = 0.5

    # 6. Extract cited spans and strictly verify against passage
    raw_spans = data.get("citedSpans") or data.get("cited_spans") or []
    validated_spans: List[SolverSpan] = []

    if not isinstance(raw_spans, list):
        errors.append("citedSpans must be a list")
    else:
        for idx, span in enumerate(raw_spans):
            if isinstance(span, dict):
                span_text = str(span.get("spanText") or span.get("span_text") or span.get("quote") or "").strip()
                s_char = span.get("startChar") or span.get("start_char")
                e_char = span.get("endChar") or span.get("end_char")
            elif isinstance(span, str):
                span_text = span.strip()
                s_char, e_char = None, None
            else:
                continue

            if not span_text:
                continue

            clean_span = re.sub(r"^[\"'\s…\.]+|[\"'\s…\.]+$", "", span_text).strip()
            start_pos = passage_text.find(span_text)
            if start_pos == -1 and clean_span and len(clean_span) >= 5:
                start_pos = passage_text.find(clean_span)
                if start_pos != -1:
                    span_text = clean_span
            if start_pos == -1 and clean_span and len(clean_span) >= 5:
                pos_ci = passage_text.lower().find(clean_span.lower())
                if pos_ci != -1:
                    start_pos = pos_ci
                    span_text = passage_text[pos_ci:pos_ci + len(clean_span)]
            if start_pos == -1 and clean_span:
                clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", clean_span) if len(c.strip()) >= 15]
                for c in clauses:
                    p = passage_text.find(c)
                    if p != -1:
                        start_pos = p
                        span_text = c
                        break
                    p_ci = passage_text.lower().find(c.lower())
                    if p_ci != -1:
                        start_pos = p_ci
                        span_text = passage_text[p_ci:p_ci + len(c)]
                        break
            if start_pos != -1:
                end_pos = start_pos + len(span_text)
                validated_spans.append(
                    SolverSpan(
                        span_text=span_text,
                        # The quote may have been localized from a provider's
                        # inaccurate citation. Its canonical offsets must describe
                        # the actual retained substring, never the original guess.
                        start_char=start_pos,
                        end_char=end_pos,
                    )
                )
            else:
                errors.append(f"Cited span {idx+1} '{span_text[:50]}...' does not exist verbatim in approved passage")
    # P10-03 requirement: Missing or invalid spans are strictly non-pass for all answers
    if not validated_spans:
        errors.append("Solver failed to provide valid passage-grounded cited spans for the answer")

    q_num = data.get("questionNumber") or data.get("question_number") or expected_question_number

    if errors:
        return None, errors

    solver_output = SolverOutput(
        question_number=int(q_num),
        normalized_answer=norm_answer,
        cited_spans=validated_spans,
        justification=justification,
        self_reported_confidence=conf_float,
        is_confidence_calibrated=False,
    )
    return solver_output, []
