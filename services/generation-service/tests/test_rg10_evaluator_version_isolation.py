"""Regression tests verifying evaluator version isolation (v2.0, v2.1, v2.2, v2.3).

Invariants:
- Evaluator versions use numeric parsing, preventing lexicographic version string bugs.
- Historical evaluator versions (v2.0, v2.1, v2.2) maintain their original behavior.
- v2.3 additions (NOT GIVEN contradiction, missing proposed answer defense, contrastive exclusion)
  are gated to v2.3+ and cannot alter historical version decisions.
"""
from __future__ import annotations

import pytest

from app.contracts.research import GrammarRulePack, SourceRef
from app.evaluators.independent import (
    NeutralEvaluator,
    NeutralEvaluatorV2,
    NeutralEvaluatorV2_2,
    NeutralEvaluatorV2_3,
    NeutralEvaluatorV2_4,
    NeutralEvaluatorV2_5,
    NeutralEvaluatorV2_6,
    parse_evaluator_version_tuple,
)
from app.evaluators.rubric import EvaluationVerdict, RubricDimension


def test_numeric_version_parsing():
    """Verify that version numbers parse numerically, not lexicographically."""
    assert parse_evaluator_version_tuple("neutral-eval-v2.0") == (2, 0)
    assert parse_evaluator_version_tuple("neutral-eval-v2.1") == (2, 1)
    assert parse_evaluator_version_tuple("neutral-eval-v2.2") == (2, 2)
    assert parse_evaluator_version_tuple("neutral-eval-v2.3") == (2, 3)
    assert parse_evaluator_version_tuple("neutral-eval-v2.4") == (2, 4)
    assert parse_evaluator_version_tuple("neutral-eval-v2.5") == (2, 5)
    assert parse_evaluator_version_tuple("neutral-eval-v2.6") == (2, 6)
    assert parse_evaluator_version_tuple("neutral-eval-v2.10") == (2, 10)
    assert parse_evaluator_version_tuple("v3.1") == (3, 1)
    assert parse_evaluator_version_tuple("invalid") == (2, 0)

    # In numeric comparison, (2, 10) > (2, 3), whereas in strings "2.10" < "2.3"
    assert parse_evaluator_version_tuple("neutral-eval-v2.10") > parse_evaluator_version_tuple("neutral-eval-v2.3")


def test_evaluator_feature_gates():
    """Verify that feature gates reflect explicit version thresholds."""
    ev_v2_0 = NeutralEvaluator(evaluator_version="neutral-eval-v2.0")
    assert not ev_v2_0.is_v2_1_plus
    assert not ev_v2_0.is_v2_2_plus
    assert not ev_v2_0.is_v2_3_plus

    ev_v2_1 = NeutralEvaluatorV2(evaluator_version="neutral-eval-v2.1")
    assert ev_v2_1.is_v2_1_plus
    assert not ev_v2_1.is_v2_2_plus
    assert not ev_v2_1.is_v2_3_plus

    ev_v2_2 = NeutralEvaluatorV2_2(evaluator_version="neutral-eval-v2.2")
    assert ev_v2_2.is_v2_1_plus
    assert ev_v2_2.is_v2_2_plus
    assert not ev_v2_2.is_v2_3_plus

    ev_v2_3 = NeutralEvaluatorV2_3(evaluator_version="neutral-eval-v2.3")
    assert ev_v2_3.is_v2_1_plus
    assert ev_v2_3.is_v2_2_plus
    assert ev_v2_3.is_v2_3_plus
    assert not ev_v2_3.is_v2_4_plus
    assert not ev_v2_3.is_v2_5_plus

    ev_v2_4 = NeutralEvaluatorV2_4(evaluator_version="neutral-eval-v2.4")
    assert ev_v2_4.is_v2_4_plus
    assert not ev_v2_4.is_v2_5_plus

    ev_v2_5 = NeutralEvaluatorV2_5(evaluator_version="neutral-eval-v2.5")
    assert ev_v2_5.is_v2_4_plus
    assert ev_v2_5.is_v2_5_plus
    assert not ev_v2_5.is_v2_6_plus

    ev_v2_6 = NeutralEvaluatorV2_6(evaluator_version="neutral-eval-v2.6")
    assert ev_v2_6.is_v2_5_plus
    assert ev_v2_6.is_v2_6_plus

def test_grammar_option_cues_isolation():
    """Option cues: v2.0 fails (no handler), v2.1 fails (stem cue blindspot), v2.2+ passes."""
    rule_pack = GrammarRulePack(
        rule_pack_id="pack-inv-iso-01",
        source=SourceRef(
            source_id="src-inv", source_family="fam-inv", source_version="v1.0",
            source_sha256="0" * 64, license="test", provenance_uri="https://test.internal",
        ),
        topic="Negative and Limiting Inversion",
        level="B2",
        rule_ids=["rule-inv-01"],
        applicability=["Academic"],
        examples=["Seldom had they encountered such intensity."],
    )
    # Stem has NO topic cue words; cue is in options ("Not until the storm ended...")
    q_data = {
        "question_id": "q_iso_opt_cues",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which of the following sentences correctly demonstrates inversion?",
        "options": [
            "Not until the storm ended could they leave the shelter.",
            "Not until the storm ended they could leave the shelter.",
            "Not until the storm ended they leave the shelter.",
            "Not until the storm ended could they leaving the shelter.",
        ],
        "proposed_answer": "Not until the storm ended could they leave the shelter.",
    }
    context_meta = {"rule_pack": rule_pack}
    passage = "When negative adverbials initiate a sentence, auxiliary inversion is required."

    # v2.0: Fails (grounding 1.0) because v2.0 had no rule pack handler
    res_v2_0 = NeutralEvaluator().evaluate_item(
        dataset_item_id="item-iso-01", passage_text=passage,
        question_data=q_data, context_metadata=context_meta,
    )
    assert res_v2_0.verdict == EvaluationVerdict.FAIL
    assert res_v2_0.semantic_scores[RubricDimension.GROUNDING.value] == 1.0

    # v2.1: Fails (grounding 2.0) because rule cue was checked only in stem, not options
    res_v2_1 = NeutralEvaluatorV2().evaluate_item(
        dataset_item_id="item-iso-01", passage_text=passage,
        question_data=q_data, context_metadata=context_meta,
    )
    assert res_v2_1.verdict == EvaluationVerdict.FAIL
    assert res_v2_1.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "does not exercise GrammarRulePack" in (res_v2_1.abstention_reason or "")
    # v2.2: Passes (grounding 4.0) because options are inspected for topic cues
    res_v2_2 = NeutralEvaluatorV2_2().evaluate_item(
        dataset_item_id="item-iso-01", passage_text=passage,
        question_data=q_data, context_metadata=context_meta,
    )
    assert res_v2_2.verdict == EvaluationVerdict.PASS
    assert res_v2_2.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0

    # v2.3: Also passes (grounding 4.0)
    res_v2_3 = NeutralEvaluatorV2_3().evaluate_item(
        dataset_item_id="item-iso-01", passage_text=passage,
        question_data=q_data, context_metadata=context_meta,
    )
    assert res_v2_3.verdict == EvaluationVerdict.PASS
    assert res_v2_3.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0


def test_not_given_contradiction_version_isolation():
    """NOT GIVEN contradiction: v2.0-v2.2 do NOT catch it; v2.3 strictly catches it."""
    passage = "Supervolcanoes produce catastrophic explosive events that generate enormous calderas rather than single volcanic cones."
    q_data = {
        "question_id": "q_iso_ng_contra",
        "question_type": "TFNG",
        "text": "Supervolcano eruptions produce single volcanic cones.",
        "proposed_answer": "NOT GIVEN",
    }

    # v2.2: Did NOT check contradiction in NOT GIVEN branch -> flagged entailment or passed
    # Under v2.2, detect_contradiction_in_text with enable_contrastive_exclusion is False
    res_v2_2 = NeutralEvaluatorV2_2().evaluate_item(
        dataset_item_id="item-iso-02", passage_text=passage, question_data=q_data,
    )
    # v2.2 either passed or gave entailment flag, but did NOT give "NOT GIVEN contradiction: passage explicitly contradicts"
    assert "NOT GIVEN contradiction: passage explicitly contradicts the proposition (should be FALSE)" not in (res_v2_2.abstention_reason or "")

    # v2.3: Strictly catches NOT GIVEN contradiction with contrastive exclusion
    res_v2_3 = NeutralEvaluatorV2_3().evaluate_item(
        dataset_item_id="item-iso-02", passage_text=passage, question_data=q_data,
    )
    assert res_v2_3.verdict == EvaluationVerdict.FAIL
    assert "NOT GIVEN contradiction: passage explicitly contradicts the proposition (should be FALSE)" in (res_v2_3.abstention_reason or "")


def test_missing_proposed_answer_fails_in_v2_3():
    """Missing proposed answer: v2.3 strictly marks UNSCORABLE_MISSING_ANSWER."""
    passage = "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth."
    q_data = {
        "question_id": "q_iso_missing_ans",
        "question_type": "TFNG",
        "text": "The Antarctic ice sheet contains over half of Earth's fresh water.",
        "proposed_answer": "",  # Missing proposed answer!
    }

    res_v2_3 = NeutralEvaluatorV2_3().evaluate_item(
        dataset_item_id="item-iso-03", passage_text=passage, question_data=q_data,
    )
    assert res_v2_3.verdict == EvaluationVerdict.FAIL
    assert res_v2_3.semantic_scores[RubricDimension.GROUNDING.value] == 1.0
    assert "UNSCORABLE_MISSING_ANSWER" in (res_v2_3.abstention_reason or "")
