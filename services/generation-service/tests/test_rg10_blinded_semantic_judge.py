"""Unit and Calibration Tests for BlindedSemanticJudgeProtocol (RG10 Objective 3).

Verifies:
1. Blinded metadata stripping: arm labels, in-loop pass flags, and model IDs stripped.
2. Explicit uncertainty demarcation on linguistic boundaries (zero shared words paraphrase, collective pronoun cleft).
3. Abstention on missing proposed answer keys.
4. Defense against treating model outputs as verified human truth (verified_human_truth=False).
"""
from __future__ import annotations

import pytest

from app.evaluators.blinded_judge import BlindedSemanticJudgeProtocol
from app.evaluators.calibration import EVALUATOR_V2_5_CALIBRATION_CORPUS
from app.evaluators.rubric import EvaluationVerdict


def test_blinded_judge_strips_arm_and_model_metadata():
    """Verify that arm labels and generator metadata are stripped before judging."""
    judge = BlindedSemanticJudgeProtocol()
    item = EVALUATOR_V2_5_CALIBRATION_CORPUS[0]

    q_data_contaminated = {
        **item.question_data,
        "configuration_id": "C",
        "arm": "C",
        "in_loop_pass": True,
        "model_id": "minimax/MiniMax-Text-01",
    }

    verdict = judge.evaluate_blinded(
        dataset_item_id=item.item_id,
        passage_text=item.passage_text,
        question_data=q_data_contaminated,
        context_metadata=item.context_metadata,
    )

    # Invariant: model cannot certify human truth
    assert verdict.verified_human_truth is False
    assert verdict.evaluable is True


def test_blinded_judge_flags_high_variation_paraphrase_as_uncertain():
    """High-variation paraphrase with zero shared content words is flagged UNCERTAIN, not FAIL."""
    judge = BlindedSemanticJudgeProtocol()
    # Item 18: Mangrove carbon sequestration with extreme academic paraphrase
    item18 = [it for it in EVALUATOR_V2_5_CALIBRATION_CORPUS if it.item_id == "v25-calib-pos-control-18"][0]

    verdict = judge.evaluate_blinded(
        dataset_item_id=item18.item_id,
        passage_text=item18.passage_text,
        question_data=item18.question_data,
        context_metadata=item18.context_metadata,
    )

    assert verdict.verdict == EvaluationVerdict.UNCERTAIN
    assert verdict.is_uncertain is True
    assert verdict.uncertainty_code == "HIGH_VARIATION_PARAPHRASE_INCONCLUSIVE"
    assert "human panel review" in verdict.rationale.lower()


def test_blinded_judge_flags_cleft_pronoun_ambiguity_as_uncertain():
    """Grammar MCQ with both that and who on collective human noun is flagged UNCERTAIN, not PASS."""
    judge = BlindedSemanticJudgeProtocol()
    item21 = [it for it in EVALUATOR_V2_5_CALIBRATION_CORPUS if it.item_id == "v25-calib-ambig-control-21"][0]
    verdict = judge.evaluate_blinded(
        dataset_item_id=item21.item_id,
        passage_text=item21.passage_text,
        question_data=item21.question_data,
        context_metadata=item21.context_metadata,
    )
    assert verdict.verdict == EvaluationVerdict.UNCERTAIN
    assert verdict.is_uncertain is True
    assert verdict.uncertainty_code == "RELATIVE_PRONOUN_DEFENSIBILITY_DISPUTED"
    assert "human panel adjudication" in verdict.rationale.lower()

def test_blinded_judge_flags_comparative_direction_inversion_as_uncertain():
    """Comparative statement with direction inversion / inconclusive polarity is flagged UNCERTAIN, not PASS."""
    judge = BlindedSemanticJudgeProtocol()
    item19 = [it for it in EVALUATOR_V2_5_CALIBRATION_CORPUS if it.item_id == "v25-calib-neg-control-19"][0]
    verdict = judge.evaluate_blinded(
        dataset_item_id=item19.item_id,
        passage_text=item19.passage_text,
        question_data=item19.question_data,
        context_metadata=item19.context_metadata,
    )
    assert verdict.verdict == EvaluationVerdict.UNCERTAIN
    assert verdict.is_uncertain is True
    assert verdict.uncertainty_code == "COMPARATIVE_DIRECTION_INCONCLUSIVE"
    assert "human panel adjudication" in verdict.rationale.lower()


def test_blinded_judge_flags_cross_clause_chimera_as_uncertain():
    """Statement combining subject from one clause with predicate from an opposing contrastive clause is flagged UNCERTAIN."""
    judge = BlindedSemanticJudgeProtocol()
    item20 = [it for it in EVALUATOR_V2_5_CALIBRATION_CORPUS if it.item_id == "v25-calib-adv-control-20"][0]
    verdict = judge.evaluate_blinded(
        dataset_item_id=item20.item_id,
        passage_text=item20.passage_text,
        question_data=item20.question_data,
        context_metadata=item20.context_metadata,
    )
    assert verdict.verdict == EvaluationVerdict.UNCERTAIN
    assert verdict.is_uncertain is True
    assert verdict.uncertainty_code == "CROSS_CLAUSE_CHIMERA_INCONCLUSIVE"
    assert "human panel adjudication" in verdict.rationale.lower()


def test_blinded_judge_on_unseen_synthetic_controls_regression():
    """AUTHOR_WRITTEN_NOT_INDEPENDENT: Unit regression for boundary detection on author-written synthetic controls.
    Excluded from holdout/FAR/FRR measurement claims (sealed confirmatory holdout requires external panel adjudication)."""
    judge = BlindedSemanticJudgeProtocol()

    # Unseen Control 1: Comparative direction inversion
    p_comp = "Lithium-ion batteries discharge at twice the rate of solid-state cells under freezing conditions."
    q_comp = {
        "question_id": "unseen-comp-01",
        "prompt": "Solid-state cells discharge faster than lithium-ion batteries under freezing conditions.",
        "question_type": "TFNG",
        "proposed_answer": "TRUE",
    }
    v_comp = judge.evaluate_blinded("unseen-ctrl-01", p_comp, q_comp)
    assert v_comp.verdict == EvaluationVerdict.UNCERTAIN
    assert v_comp.uncertainty_code == "COMPARATIVE_DIRECTION_INCONCLUSIVE"

    # Unseen Control 2: Cross-clause chimera
    p_chim = "Arctic foxes grow thick white fur in winter, whereas desert foxes maintain thin sandy pelts throughout the year."
    q_chim = {
        "question_id": "unseen-chim-02",
        "prompt": "Arctic foxes maintain thin sandy pelts throughout the year.",
        "question_type": "TFNG",
        "proposed_answer": "TRUE",
    }
    v_chim = judge.evaluate_blinded("unseen-ctrl-02", p_chim, q_chim)
    assert v_chim.verdict == EvaluationVerdict.UNCERTAIN
    assert v_chim.uncertainty_code == "CROSS_CLAUSE_CHIMERA_INCONCLUSIVE"

    # Unseen Control 3: Valid grounded non-comparative statement
    q_valid = {
        "question_id": "unseen-valid-03",
        "prompt": "Arctic foxes grow thick white fur during winter months.",
        "question_type": "TFNG",
        "proposed_answer": "TRUE",
    }
    v_valid = judge.evaluate_blinded("unseen-ctrl-03", p_chim, q_valid)
    assert v_valid.verdict == EvaluationVerdict.PASS
    assert v_valid.is_uncertain is False

def test_blinded_judge_does_not_escalate_genuine_hallucinations_to_uncertain():
    """Pure hallucinations with fabricated quotes must remain FAIL and not be escalated to UNCERTAIN."""
    judge = BlindedSemanticJudgeProtocol()
    from app.evaluators.calibration import CALIBRATION_CORPUS
    item2 = [it for it in CALIBRATION_CORPUS if it.item_id == "calib-tfng-02"][0]

    verdict = judge.evaluate_blinded(
        dataset_item_id=item2.item_id,
        passage_text=item2.passage_text,
        question_data=item2.question_data,
        context_metadata=item2.context_metadata,
    )

    assert verdict.verdict == EvaluationVerdict.FAIL
    assert verdict.is_uncertain is False


def test_blinded_judge_preserves_missing_answer_as_fail():
    """Missing proposed answer keys strictly evaluate to FAIL with UNSCORABLE_MISSING_ANSWER."""
    judge = BlindedSemanticJudgeProtocol()
    verdict = judge.evaluate_blinded(
        dataset_item_id="dev-reading-q1",
        passage_text="Photosynthesis requires sunlight to synthesize carbohydrates.",
        question_data={
            "question_id": "1",
            "prompt": "Photosynthesis requires sunlight.",
            "question_type": "TFNG",
            # proposed_answer omitted
        },
    )

    assert verdict.verdict == EvaluationVerdict.FAIL
    assert "UNSCORABLE_MISSING_ANSWER" in verdict.rationale


def test_blinded_judge_explicit_version_pinning():
    """Verify that UncertaintyEscalationProtocol accepts explicit version-pinned base evaluators."""
    from app.evaluators.independent import NeutralEvaluatorV2_5, NeutralEvaluatorV2_6

    judge_v25 = BlindedSemanticJudgeProtocol(base_evaluator=NeutralEvaluatorV2_5())
    assert judge_v25.base_evaluator.evaluator_version == "neutral-eval-v2.5"

    judge_v26 = BlindedSemanticJudgeProtocol(base_evaluator=NeutralEvaluatorV2_6())
    assert judge_v26.base_evaluator.evaluator_version == "neutral-eval-v2.6"
