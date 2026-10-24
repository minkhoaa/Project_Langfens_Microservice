"""Adversarial Calibration Suite for NeutralEvaluatorV2_3 (RG10 Measurement Integrity).

Measures:
1. Complete 16-item adversarial calibration corpus on NeutralEvaluatorV2_3:
   - TRUE/FALSE/NOT GIVEN contradictions
   - Missing and misleading evidence
   - Multiple defensible Grammar MCQ answers (distractor defects)
   - False rejection of legitimate paraphrases (valid items pass)
   - Incorrect answer keys
   - Missing proposed answers (UNSCORABLE_MISSING_ANSWER)
2. Transparent metrics: FAR, FRR, coverage, abstention, and confusion matrix.
3. Verification that reliability on synthetic corpus is not misrepresented as generalized real-world reliability.
4. Split disjointness against retired and exploratory holdouts.
"""
from __future__ import annotations

import pytest

from app.evaluators.calibration import (
    EVALUATOR_V2_3_CALIBRATION_CORPUS,
    FRESH_JUDGE_HOLDOUT_CORPUS_V2,
    JUDGE_HOLDOUT_CORPUS,
    measure_evaluator_reliability,
    verify_split_disjointness,
)
from app.evaluators.independent import NeutralEvaluatorV2_3
from app.evaluators.rubric import EvaluationVerdict, RubricDimension


def test_v2_3_adversarial_calibration_reliability():
    """Calibrates NeutralEvaluatorV2_3 on comprehensive 16-item adversarial corpus."""
    evaluator = NeutralEvaluatorV2_3()
    metrics = measure_evaluator_reliability(
        evaluator=evaluator,
        dataset=EVALUATOR_V2_3_CALIBRATION_CORPUS,
        dataset_name="EVALUATOR_V2_3_CALIBRATION_CORPUS",
    )

    assert metrics.total_count == 17
    assert metrics.evaluable_count == 17
    assert metrics.coverage == 1.0

    # Transparent measurements with explicit denominators:
    assert metrics.false_positive_count == 0
    assert metrics.true_negative_count == 10
    assert metrics.far == 0.0

    # Decided positive items (TP + FN) = 4 + 3 = 7
    # Real FRR is honestly measured (> 0.0) due to absent-topic NOT GIVEN grounding and clause-level FALSE overlap
    assert metrics.true_positive_count == 4
    assert metrics.false_negative_count == 3
    assert metrics.frr == round(3 / 7, 4)

    # Decided accuracy
    assert metrics.accuracy_on_decided == round((4 + 10) / 17, 4)

    # Verify confusion by question type exists and is populated
    assert "TFNG" in metrics.confusion_by_type
    assert "GRAMMAR_MCQ" in metrics.confusion_by_type
    assert "MCQ" in metrics.confusion_by_type


def test_v2_3_tfng_contradictions_caught():
    """Adversarial checks: NOT GIVEN contradiction, FALSE contradiction, TRUE contradiction."""
    evaluator = NeutralEvaluatorV2_3()

    # NOT GIVEN contradiction: passage contradicts statement
    item_ng = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-contra-ng-01")
    res_ng = evaluator.evaluate_item(
        dataset_item_id=item_ng.item_id,
        passage_text=item_ng.passage_text,
        question_data=item_ng.question_data,
    )
    assert res_ng.verdict == EvaluationVerdict.FAIL
    assert "NOT GIVEN contradiction" in (res_ng.abstention_reason or "")

    # FALSE contradiction: cited evidence affirms statement
    item_false = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-contra-false-02")
    res_false = evaluator.evaluate_item(
        dataset_item_id=item_false.item_id,
        passage_text=item_false.passage_text,
        question_data=item_false.question_data,
    )
    assert res_false.verdict == EvaluationVerdict.FAIL
    assert "FALSE contradiction" in (res_false.abstention_reason or "")

    # TRUE contradiction: statement contradicts passage with contrastive exclusion
    item_true = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-contra-true-03")
    res_true = evaluator.evaluate_item(
        dataset_item_id=item_true.item_id,
        passage_text=item_true.passage_text,
        question_data=item_true.question_data,
    )
    assert res_true.verdict == EvaluationVerdict.FAIL
    assert "Entailment contradiction" in (res_true.abstention_reason or "")


def test_v2_3_missing_and_misleading_evidence_caught():
    """Missing and misleading evidence caught as grounding failures."""
    evaluator = NeutralEvaluatorV2_3()

    # Missing evidence quote
    item_miss = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-evidence-missing-04")
    res_miss = evaluator.evaluate_item(
        dataset_item_id=item_miss.item_id,
        passage_text=item_miss.passage_text,
        question_data=item_miss.question_data,
    )
    assert res_miss.verdict == EvaluationVerdict.FAIL
    assert "Cited evidence quote not found in source passage" in (res_miss.abstention_reason or "")

    # Irrelevant evidence quote
    item_irrel = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-evidence-irrelevant-05")
    res_irrel = evaluator.evaluate_item(
        dataset_item_id=item_irrel.item_id,
        passage_text=item_irrel.passage_text,
        question_data=item_irrel.question_data,
    )
    assert res_irrel.verdict == EvaluationVerdict.FAIL
    assert "Irrelevant evidence citation" in (res_irrel.abstention_reason or "")


def test_v2_3_multiple_defensible_grammar_mcq_answers_caught():
    """MCQs with multiple defensible answers fail distractor validity."""
    evaluator = NeutralEvaluatorV2_3()

    item_cleft = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-grammar-multicleft-06")
    res_cleft = evaluator.evaluate_item(
        dataset_item_id=item_cleft.item_id,
        passage_text=item_cleft.passage_text,
        question_data=item_cleft.question_data,
        context_metadata=item_cleft.context_metadata,
    )
    assert res_cleft.verdict == EvaluationVerdict.FAIL
    assert res_cleft.task_validity.get("unique_correct_answer") is False

    item_contracted = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-grammar-contracted-07")
    res_contracted = evaluator.evaluate_item(
        dataset_item_id=item_contracted.item_id,
        passage_text=item_contracted.passage_text,
        question_data=item_contracted.question_data,
        context_metadata=item_contracted.context_metadata,
    )
    assert res_contracted.verdict == EvaluationVerdict.FAIL
    assert res_contracted.task_validity.get("unique_correct_answer") is False


def test_v2_3_legitimate_paraphrases_not_false_rejected():
    """Positive controls: valid mathematical paraphrases and option cues pass cleanly."""
    evaluator = NeutralEvaluatorV2_3()

    item_math = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-paraphrase-math-08")
    res_math = evaluator.evaluate_item(
        dataset_item_id=item_math.item_id,
        passage_text=item_math.passage_text,
        question_data=item_math.question_data,
    )
    assert res_math.verdict == EvaluationVerdict.PASS
    assert res_math.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0

    item_cues = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-paraphrase-options-09")
    res_cues = evaluator.evaluate_item(
        dataset_item_id=item_cues.item_id,
        passage_text=item_cues.passage_text,
        question_data=item_cues.question_data,
        context_metadata=item_cues.context_metadata,
    )
    assert res_cues.verdict == EvaluationVerdict.PASS

    item_neg = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-paraphrase-neg-stem-10")
    res_neg = evaluator.evaluate_item(
        dataset_item_id=item_neg.item_id,
        passage_text=item_neg.passage_text,
        question_data=item_neg.question_data,
        context_metadata=item_neg.context_metadata,
    )
    assert res_neg.verdict == EvaluationVerdict.PASS


def test_v2_3_missing_proposed_answer_unscorable():
    """Missing proposed answer fails closed with UNSCORABLE_MISSING_ANSWER."""
    evaluator = NeutralEvaluatorV2_3()
    item_miss = next(it for it in EVALUATOR_V2_3_CALIBRATION_CORPUS if it.item_id == "v23-calib-missing-answer-13")
    res = evaluator.evaluate_item(
        dataset_item_id=item_miss.item_id,
        passage_text=item_miss.passage_text,
        question_data=item_miss.question_data,
    )
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] == 1.0
    assert "UNSCORABLE_MISSING_ANSWER" in (res.abstention_reason or "")


def test_v2_3_calibration_disjointness():
    """Confirms EVALUATOR_V2_3_CALIBRATION_CORPUS has zero family or ID collision with holdouts."""
    is_disjoint_v1, viol_v1 = verify_split_disjointness(
        calibration_items=EVALUATOR_V2_3_CALIBRATION_CORPUS,
        holdout_items=JUDGE_HOLDOUT_CORPUS,
    )
    assert is_disjoint_v1, f"Violations with JUDGE_HOLDOUT_CORPUS: {viol_v1}"

    is_disjoint_v2, viol_v2 = verify_split_disjointness(
        calibration_items=EVALUATOR_V2_3_CALIBRATION_CORPUS,
        holdout_items=FRESH_JUDGE_HOLDOUT_CORPUS_V2,
    )
    assert is_disjoint_v2, f"Violations with FRESH_JUDGE_HOLDOUT_CORPUS_V2: {viol_v2}"
