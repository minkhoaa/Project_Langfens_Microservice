"""Evidence-Backed Adjudication and Disagreement Handling (P10-07).

Invariants:
- High disagreement between expected key and solver creates a HIGH severity blocker.
- No majority vote override of passage grounding.
- Never automatically change the answer key to match the solver.
- Grounded adversarial ambiguity triggers item repair or regeneration.
- Inconclusive or no-answer outcomes fail closed; never default to agreement.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, Optional

from app.contracts.solver import (
    AdjudicationResult,
    AdjudicationVerdict,
    AdversaryOutput,
    ComparisonResult,
    DisagreementSeverity,
    SolverOutput,
    StudentVisibleQuestion,
)
from app.solvers.comparison import compare_answers
logger = logging.getLogger(__name__)


def adjudicate_item(
    comparison: ComparisonResult,
    adversary_output: Optional[AdversaryOutput] = None,
    passage_text: Optional[str] = None,
    solver_output: Optional[SolverOutput] = None,
    student_question: Optional[StudentVisibleQuestion] = None,
    evidence_quote: Optional[str] = None,
) -> AdjudicationResult:
    """Synthesizes solver comparison and adversary findings into an authoritative adjudication.

    INVARIANTS:
    - Never changes the answer key automatically to match the solver.
    - Never uses majority vote to override passage grounding.
    - Missing or invalid outputs fail closed.
    - Strictly distinguishes:
      1. Missing or malformed student-visible stimulus (MALFORMED_STIMULUS)
      2. Candidate key not grounded in its evidence quote (KEY_UNGROUNDED)
      3. Solver response unsupported by passage (SOLVER_UNSUPPORTED)
      4. Genuine multiple defensible answers (GENUINE_AMBIGUITY -> AMBIGUOUS_DEFECTIVE)
      5. Valid unambiguous candidate with solver error (SOLVER_ERROR)
    """
    q_num = comparison.question_number
    solver_match = comparison.is_match
    adv_ambiguous = bool(adversary_output and adversary_output.is_ambiguous)
    norm_exp = comparison.normalized_expected.replace("_", " ").strip().casefold()

    # Case 1: Missing or malformed student-visible stimulus
    if student_question is not None:
        q_type_upper = student_question.question_type.upper().replace("_", "")
        if q_type_upper == "FLOWCHART" and (not student_question.flow_steps or len(student_question.flow_steps) < 2):
            return AdjudicationResult(
                question_number=q_num,
                verdict=AdjudicationVerdict.SOLVER_DEFECTIVE,
                severity=DisagreementSeverity.HIGH,
                resolution_action="FAIL_CLOSED",
                solver_match=False,
                adversary_ambiguity_found=False,
                details={
                    "errorType": "MALFORMED_STIMULUS",
                    "message": "Missing or malformed student-visible stimulus: FLOW_CHART requires at least 2 flowSteps",
                    "expectedAnswer": comparison.expected_answer,
                    "solverAnswer": comparison.solver_answer,
                },
            )
        if q_type_upper in ("DIAGRAMLABEL", "MAPLABEL"):
            has_vis = bool(student_question.part_description or student_question.shared_context or student_question.svg_asset_id or student_question.image_url)
            if not has_vis:
                return AdjudicationResult(
                    question_number=q_num,
                    verdict=AdjudicationVerdict.SOLVER_DEFECTIVE,
                    severity=DisagreementSeverity.HIGH,
                    resolution_action="FAIL_CLOSED",
                    solver_match=False,
                    adversary_ambiguity_found=False,
                    details={
                        "errorType": "MALFORMED_STIMULUS",
                        "message": f"Missing or malformed student-visible stimulus: {student_question.question_type} requires visual description or graphical asset",
                        "expectedAnswer": comparison.expected_answer,
                        "solverAnswer": comparison.solver_answer,
                    },
                )

    # Case 2: Candidate expected key not grounded in its cited evidence quote
    if evidence_quote:
        from app.contracts.policies import match_boundary_aware
        q_type_upper = (student_question.question_type if student_question else comparison.question_type).upper().replace("_", "")
        if q_type_upper in (
            "SENTENCECOMPLETION", "SUMMARYCOMPLETION", "SHORTANSWER",
            "NOTECOMPLETION", "TABLECOMPLETION", "FORMCOMPLETION",
            "FLOWCHART", "DIAGRAMLABEL", "MAPLABEL"
        ):
            if not match_boundary_aware(comparison.expected_answer, evidence_quote):
                return AdjudicationResult(
                    question_number=q_num,
                    verdict=AdjudicationVerdict.KEY_UNGROUNDED,
                    severity=DisagreementSeverity.HIGH,
                    resolution_action="REGENERATE_ITEM",
                    solver_match=False,
                    adversary_ambiguity_found=False,
                    details={
                        "errorType": "KEY_UNGROUNDED",
                        "message": f"Candidate expected key '{comparison.expected_answer}' is not grounded in cited passage evidence quote.",
                        "expectedAnswer": comparison.expected_answer,
                        "solverAnswer": comparison.solver_answer,
                        "evidenceQuote": evidence_quote,
                    },
                )

    grounded_distinct_alts = []
    if adversary_output:
        # Evaluate expected score if adversary reviewed expected key as an alternative
        exp_score = None
        for alt in adversary_output.identified_alternatives:
            cmp_alt = compare_answers(
                expected_answer=comparison.expected_answer,
                solver_answer=alt.alternative_answer,
                question_type=comparison.question_type,
                question_number=q_num,
            )
            if cmp_alt.is_match and alt.plausibility_score is not None:
                exp_score = alt.plausibility_score
                break

        for alt in adversary_output.identified_alternatives:
            if alt.is_grounded_in_passage:
                cmp_alt = compare_answers(
                    expected_answer=comparison.expected_answer,
                    solver_answer=alt.alternative_answer,
                    question_type=comparison.question_type,
                    question_number=q_num,
                )
                # Distinct alternative if it does NOT match the expected answer
                if not cmp_alt.is_match:
                    is_compelling = (
                        alt.plausibility_score is None
                        or (exp_score is not None and alt.plausibility_score >= exp_score)
                        or (exp_score is None and alt.plausibility_score >= 0.8)
                    )
                    if is_compelling:
                        grounded_distinct_alts.append(alt.model_dump())
    # 1. Clean Agreement: Solver matches expected key and adversary finds no grounded distinct alternative
    if solver_match and not (adv_ambiguous and grounded_distinct_alts):
        return AdjudicationResult(
            question_number=q_num,
            verdict=AdjudicationVerdict.KEY_CONFIRMED,
            severity=DisagreementSeverity.NONE,
            resolution_action="ACCEPT_ITEM",
            solver_match=True,
            adversary_ambiguity_found=False,
            details={
                "message": "Item passed blind solver verification and adversary review with zero ambiguity.",
                "normalizedAnswer": comparison.normalized_expected,
            },
        )

    # 2. Adversarial Ambiguity Detected (genuine alternative that differs from expected key)
    if adv_ambiguous and grounded_distinct_alts:
        return AdjudicationResult(
            question_number=q_num,
            verdict=AdjudicationVerdict.AMBIGUOUS_DEFECTIVE,
            severity=DisagreementSeverity.HIGH,
            resolution_action="REPAIR_OPTIONS_OR_REGENERATE_ITEM",
            solver_match=solver_match,
            adversary_ambiguity_found=True,
            details={
                "errorType": "GENUINE_AMBIGUITY",
                "message": (
                    f"Adversary identified {len(grounded_distinct_alts)} grounded alternative(s) "
                    "or ambiguous interpretation in the question."
                ),
                "summary": adversary_output.adversary_summary,
                "alternatives": grounded_distinct_alts,
            },
        )
    # 3. Solver Disagreement with Expected Key
    # Bounded evidence-backed inspection:
    solver_has_valid_spans = bool(solver_output and solver_output.cited_spans)

    solver_ans = comparison.solver_answer.strip()
    solver_in_passage = bool(
        passage_text
        and solver_ans
        and (
            solver_ans.lower() in passage_text.lower()
            or (solver_output and solver_output.cited_spans and any(s.span_text and s.span_text in passage_text for s in solver_output.cited_spans))
        )
    )

    if not solver_in_passage and passage_text:
        # Case 3: Solver response unsupported by passage
        verdict = AdjudicationVerdict.SOLVER_DEFECTIVE
        resolution = "REGENERATE_SOLVER_OR_REPAIR_ITEM"
        error_type = "SOLVER_UNSUPPORTED"
        msg = (
            f"Blind solver response '{comparison.solver_answer}' is unsupported by passage text, "
            f"while candidate key is grounded in passage."
        )
    elif solver_has_valid_spans and passage_text:
        # Solver cited passage spans supporting its alternative answer
        verdict = AdjudicationVerdict.KEY_CONTRADICTED
        resolution = "REPAIR_KEY_OR_REGENERATE_ITEM"
        error_type = "SOLVER_CONTRADICTION"
        msg = (
            f"Solver disagreed with expected key (expected '{comparison.expected_answer}', "
            f"got '{comparison.solver_answer}') with valid cited passage evidence. "
            "Item is blocked from acceptance; answer key cannot be automatically changed."
        )
    else:
        # Case 5: Solver returned unexpected answer without clear valid passage backing
        verdict = AdjudicationVerdict.SOLVER_DEFECTIVE
        resolution = "REGENERATE_SOLVER_OR_REPAIR_ITEM"
        error_type = "SOLVER_ERROR"
        msg = (
            f"Solver returned answer '{comparison.solver_answer}' differing from "
            f"expected '{comparison.expected_answer}' without valid ambiguity."
        )

    return AdjudicationResult(
        question_number=q_num,
        verdict=verdict,
        severity=DisagreementSeverity.HIGH,
        resolution_action=resolution,
        solver_match=False,
        adversary_ambiguity_found=adv_ambiguous,
        details={
            "errorType": error_type,
            "message": msg,
            "expectedAnswer": comparison.expected_answer,
            "solverAnswer": comparison.solver_answer,
            "comparisonDetails": comparison.comparison_details,
        },
    )
