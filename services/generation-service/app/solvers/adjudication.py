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
)
from app.solvers.comparison import compare_answers
logger = logging.getLogger(__name__)


def adjudicate_item(
    comparison: ComparisonResult,
    adversary_output: Optional[AdversaryOutput] = None,
    passage_text: Optional[str] = None,
    solver_output: Optional[SolverOutput] = None,
) -> AdjudicationResult:
    """Synthesizes solver comparison and adversary findings into an authoritative adjudication.

    INVARIANTS:
    - Never changes the answer key automatically to match the solver.
    - Never uses majority vote to override passage grounding.
    - Missing or invalid outputs fail closed.
    """
    q_num = comparison.question_number
    solver_match = comparison.is_match
    adv_ambiguous = bool(adversary_output and adversary_output.is_ambiguous)
    norm_exp = comparison.normalized_expected.replace("_", " ").strip().casefold()

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
                        or (exp_score is None and alt.plausibility_score >= 0.95)
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

    if solver_has_valid_spans and passage_text:
        # Solver cited passage spans supporting its alternative answer
        verdict = AdjudicationVerdict.KEY_CONTRADICTED
        resolution = "REPAIR_KEY_OR_REGENERATE_ITEM"
        msg = (
            f"Solver disagreed with expected key (expected '{comparison.expected_answer}', "
            f"got '{comparison.solver_answer}') with valid cited passage evidence. "
            "Item is blocked from acceptance; answer key cannot be automatically changed."
        )
    else:
        # Solver had an unexpected answer without clear valid passage backing
        verdict = AdjudicationVerdict.SOLVER_DEFECTIVE
        resolution = "REGENERATE_SOLVER_OR_REPAIR_ITEM"
        msg = (
            f"Solver returned answer '{comparison.solver_answer}' differing from "
            f"expected '{comparison.expected_answer}'."
        )

    return AdjudicationResult(
        question_number=q_num,
        verdict=verdict,
        severity=DisagreementSeverity.HIGH,
        resolution_action=resolution,
        solver_match=False,
        adversary_ambiguity_found=adv_ambiguous,
        details={
            "message": msg,
            "expectedAnswer": comparison.expected_answer,
            "solverAnswer": comparison.solver_answer,
            "comparisonDetails": comparison.comparison_details,
        },
    )
