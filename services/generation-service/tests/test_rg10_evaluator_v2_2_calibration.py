"""Comprehensive Calibration & Validation Suite for NeutralEvaluator v2.2 (RG10 Remediation & Quality Readiness).

Validates:
1. Reading Grounding & Semantic Support:
   - Entailment (positive valid item).
   - Comparison inversion ('rather than' / 'instead of' reversed).
   - Negation polarity conflict (negated predicate vs affirmed text).
   - Unsupported entities / NOT GIVEN claimed as TRUE.
   - Contradiction between self-reported evidence quote and TRUE statement.
2. Grammar Semantic Grounding & Linguistic Validity:
   - Topic cue and example recognition across prompt AND options.
   - Ambiguous MCQ with multiple valid correct answers detected as distractor validity failure.
   - Correct single-answer inversion MCQ accepted.
   - Unexercised rule pack rejected.
3. Reliability and calibration on CALIBRATION_CORPUS with transparent denominators.
"""
from __future__ import annotations

import pytest

from app.contracts.research import (
    GrammarRulePack,
    SourceRef,
)
from app.evaluators.calibration import (
    CALIBRATION_CORPUS,
    measure_evaluator_reliability,
)
from app.evaluators.independent import (
    NeutralEvaluator,
    NeutralEvaluatorV2,
    NeutralEvaluatorV2_2,
    NeutralEvaluatorV2_3,
)
from app.evaluators.rubric import EvaluationVerdict, RubricDimension


VOLCANO_PASSAGE = (
    "Supervolcanoes represent volcanic centers that have experienced eruptions producing at least 1,000 "
    "cubic kilometers of ejecta. These catastrophic explosive events generate enormous calderas rather than "
    "single volcanic cones. The Yellowstone caldera in North America and Lake Toba in Sumatra are primary "
    "examples of such systems. Magma chambers underlying supervolcanoes contain highly viscous rhyolitic melt "
    "enriched in dissolved volatile species. Geological surveys confirm that continental crustal thickness "
    "substantially influences the magma accumulation rate prior to catastrophic decompression."
)


def _inversion_rule_pack() -> GrammarRulePack:
    return GrammarRulePack(
        rule_pack_id="pack-inversion-calib-01",
        source=SourceRef(
            source_id="src-grammar-01",
            source_family="fam-grammar-01",
            source_version="v1.0",
            source_sha256="0" * 64,
            license="test",
            provenance_uri="https://test.internal/grammar",
        ),
        topic="Negative and Limiting Inversion",
        level="B2",
        rule_ids=["rule-inv-01"],
        applicability=["Academic IELTS Reading and Writing"],
        exceptions=["Only in sentence-initial position."],
        examples=[
            "Seldom had they encountered such seismic intensity.",
            "Under no circumstances should samples be discarded.",
        ],
    )
def _cleft_rule_pack() -> GrammarRulePack:
    return GrammarRulePack(
        rule_pack_id="pack-cleft-calib-01",
        source=SourceRef(
            source_id="src-cleft-01",
            source_family="fam-cleft-01",
            source_version="v1.0",
            source_sha256="0" * 64,
            license="test",
            provenance_uri="https://test.internal/cleft",
        ),
        topic="Cleft Sentences and Information Packaging",
        level="B2",
        rule_ids=["rule-cleft-01"],
        applicability=["Academic IELTS Reading and Writing"],
        exceptions=["Plural noun phrases in focused position still take singular It is/was."],
        examples=[
            "It was the protocol that accelerated motor recovery.",
            "It is synaptic plasticity that underpins long-term memory formation.",
        ],
    )




# ── 1. Reading Semantic Calibration Tests ────────────────────────────────────


def test_v2_2_reading_valid_entailment_passes():
    """Positive control: Well-grounded entailment passes with grounding >= 3.0."""
    evaluator = NeutralEvaluatorV2_2()
    q_data = {
        "question_id": "val1",
        "question_type": "TFNG",
        "text": "Supervolcanoes produce eruptions with at least 1,000 cubic kilometers of ejecta.",
        "proposed_answer": "TRUE",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-volcano-01",
        passage_text=VOLCANO_PASSAGE,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.PASS
    assert res.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0


def test_v2_2_reading_comparison_inversion_detected_as_fail():
    """Adversarial case: Inverted comparison ('rather than') is caught as contradiction."""
    evaluator = NeutralEvaluatorV2_2()
    q_data = {
        "question_id": "adv_comp",
        "question_type": "TFNG",
        "text": "Supervolcanoes generate single volcanic cones rather than enormous calderas.",
        "proposed_answer": "TRUE",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-volcano-01",
        passage_text=VOLCANO_PASSAGE,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Comparison inversion contradiction" in (res.abstention_reason or "")


def test_v2_2_reading_unsupported_entity_not_given_detected_as_fail():
    """Adversarial case: Proposing TRUE for a statement with unsupported entities fails grounding."""
    evaluator = NeutralEvaluatorV2_2()
    q_data = {
        "question_id": "adv_unsupported",
        "question_type": "TFNG",
        "text": "Supervolcanoes and calderas are frequently triggered by gravitational pulls of the moon.",
        "proposed_answer": "TRUE",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-volcano-01",
        passage_text=VOLCANO_PASSAGE,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Ungrounded claim" in (res.abstention_reason or "")


def test_v2_2_reading_contradiction_with_quoted_evidence_fails():
    """Adversarial case: Self-reported evidence quote that contradicts TRUE statement is caught."""
    evaluator = NeutralEvaluatorV2_2()
    q_data = {
        "question_id": "adv_quote_contra",
        "question_type": "TFNG",
        "text": "Supervolcanoes produce less than 50 cubic kilometers of ejecta.",
        "proposed_answer": "TRUE",
        "evidence_quote": "at least 1,000 cubic kilometers of ejecta",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-volcano-01",
        passage_text=VOLCANO_PASSAGE,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "contradicts TRUE statement" in (res.abstention_reason or "")


def test_v2_2_reading_negation_polarity_conflict_detected():
    """Adversarial case: Statement negates predicate that is affirmed in passage."""
    evaluator = NeutralEvaluatorV2_2()
    passage = "Supervolcanic eruptions produce immense calderas exceeding dozens of kilometers in diameter."
    q_data = {
        "question_id": "adv_neg_polar",
        "question_type": "TFNG",
        "text": "Supervolcano calderas never exceed dozens of kilometers across.",
        "proposed_answer": "TRUE",
        "evidence_quote": "produce immense calderas exceeding dozens of kilometers in diameter",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-volcano-01",
        passage_text=passage,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0

def test_v2_2_reading_unsupported_generalization_detected_as_fail():
    """Adversarial case: Statement introduces broad generalization ('various stimuli') not affirmed in passage."""
    evaluator = NeutralEvaluatorV2_2()
    passage = (
        "Cognitive rehabilitation protocols strategically exploit adaptive cellular mechanisms "
        "through repetitive task-specific motor training following focal cortical lesions."
    )
    q_data = {
        "question_id": "adv_gen",
        "question_type": "TFNG",
        "text": "Cellular adaptation occurs in response to various stimuli across all activities.",
        "proposed_answer": "TRUE",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-neuro-01",
        passage_text=passage,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Unsupported generalization" in (res.abstention_reason or "")


def test_v2_2_reading_irrelevant_evidence_quote_detected_as_fail():
    """Adversarial case: Cited evidence quote is present in passage but shares no content with question prompt."""
    evaluator = NeutralEvaluatorV2_2()
    passage = (
        "Controlled environment agriculture relies on artificial lighting in urban warehouses. "
        "Photosynthetic efficiency determines crop yield in rural greenhouses."
    )
    q_data = {
        "question_id": "adv_irrel_quote",
        "question_type": "TFNG",
        "text": "Artificial lighting operates inside urban warehouses.",
        "proposed_answer": "TRUE",
        "evidence_quote": "Photosynthetic efficiency determines crop yield in rural greenhouses.",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-cea-01",
        passage_text=passage,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert "Irrelevant evidence citation" in (res.abstention_reason or "")


def test_v2_2_reading_not_given_when_contradicted_by_passage_fails():
    """Adversarial case: Statement directly contradicted by passage is incorrectly labeled NOT GIVEN."""
    evaluator = NeutralEvaluatorV2_2()
    passage = "Supervolcanoes produce catastrophic explosive events that generate enormous calderas rather than single volcanic cones."
    q_data = {
        "question_id": "adv_ng_contradicted",
        "question_type": "TFNG",
        "text": "Supervolcano eruptions produce single volcanic cones.",
        "proposed_answer": "NOT GIVEN",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-volcano-01",
        passage_text=passage,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert "NOT GIVEN contradiction: passage explicitly contradicts the proposition" in (res.abstention_reason or "")


def test_v2_2_reading_false_when_cited_evidence_affirms_fails():
    """Adversarial case: Statement affirmed by cited evidence is incorrectly labeled FALSE."""
    evaluator = NeutralEvaluatorV2_2()
    passage = "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth."
    q_data = {
        "question_id": "adv_false_affirmed",
        "question_type": "TFNG",
        "text": "The Antarctic ice sheet contains over half of Earth's fresh water.",
        "proposed_answer": "FALSE",
        "evidence_quote": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-reading-antarctica-01",
        passage_text=passage,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert "FALSE contradiction: cited evidence affirms statement" in (res.abstention_reason or "")


# ── 2. Grammar Semantic Calibration Tests ────────────────────────────────────


def test_v2_2_grammar_cues_in_options_recognized_as_pass():
    """Stem has generic prompt ('Which sentence correctly uses...'), options carry target rule."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _inversion_rule_pack()
    q_data = {
        "question_id": "g_opt_cues",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which of the following sentences correctly uses negative inversion?",
        "options": [
            "Not until the storm ended could they leave the shelter.",
            "Not until the storm ended they could leave the shelter.",
            "Not until the storm ended they leave the shelter.",
            "Not until the storm ended could they leaving the shelter.",
        ],
        "proposed_answer": "Not until the storm ended could they leave the shelter.",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-calib-01",
        passage_text="When negative adverbials initiate a sentence, auxiliary inversion is required.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.PASS
    assert res.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0
    assert any("rule_pack:pack-inversion-calib-01" in r for r in res.evidence_refs)


def test_v2_2_grammar_ambiguous_mcq_multiple_valid_answers_fails():
    """Adversarial case: MCQ where multiple options correctly apply rule (distractor defect) fails."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _inversion_rule_pack()
    q_data = {
        "question_id": "g_ambig_mcq",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly demonstrates negative inversion with 'under no circumstances'?",
        "options": [
            "Under no circumstances we should compromise our principles.",
            "Under no circumstances should we compromise our principles.",
            "Under no circumstances we should be compromising our principles.",
            "Under no circumstances should we be compromising our principles.",
        ],
        "proposed_answer": "Under no circumstances should we compromise our principles.",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-calib-01",
        passage_text="When negative adverbials initiate a sentence, auxiliary inversion is required.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Ambiguous MCQ: multiple options" in (res.abstention_reason or "")


def test_v2_2_grammar_unexercised_rule_pack_fails():
    """Grammar item not exercising target rule pack fails closed."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _inversion_rule_pack()
    q_data = {
        "question_id": "g_unexercised",
        "question_type": "GRAMMAR_MCQ",
        "text": "The cat sat on the mat peacefully.",
        "options": ["sat", "sits", "sitting", "seated"],
        "proposed_answer": "sat",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-calib-01",
        passage_text="The cat sat on the mat peacefully throughout the quiet morning.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0

def test_v2_2_grammar_it_cleft_that_which_distractor_ambiguity_fails():
    """Adversarial case: Cleft MCQ has both 'that' and 'which' options for non-human focus (distractor ambiguity)."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _cleft_rule_pack()
    q_data = {
        "question_id": "g_cleft_ambig",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly uses an it-cleft to emphasize 'synaptic plasticity'?",
        "options": [
            "A) It is synaptic plasticity that underpins long-term memory formation.",
            "B) What underpins long-term memory formation is synaptic plasticity.",
            "C) Synaptic plasticity underpins long-term memory formation.",
            "D) It is synaptic plasticity which underpins long-term memory formation.",
        ],
        "proposed_answer": "A",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-cleft-01",
        passage_text="When emphasizing a noun phrase, cleft sentences package information.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Ambiguous MCQ: multiple options exhibit valid it-cleft syntax" in (res.abstention_reason or "")


def test_v2_2_grammar_cleft_tense_discord_fails():
    """Adversarial case: Cleft construction clashes present copula 'is' with past relative verb 'accelerated'."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _cleft_rule_pack()
    q_data = {
        "question_id": "g_cleft_tense_discord",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly demonstrates an it-cleft construction?",
        "options": [
            "A) It is the rehabilitation protocol that accelerated motor recovery.",
            "B) The rehabilitation protocol accelerated motor recovery.",
            "C) What accelerated motor recovery was the protocol.",
            "D) The protocol was accelerating motor recovery.",
        ],
        "proposed_answer": "A",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-cleft-01",
        passage_text="When emphasizing a noun phrase, cleft sentences package information.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Tense agreement discord" in (res.abstention_reason or "")


def test_v2_2_grammar_contracted_negative_inversion_distractor_fails():
    """Adversarial case: Option D uses contracted inversion ('shouldn't we'), creating distractor contestation."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _inversion_rule_pack()
    q_data = {
        "question_id": "g_contracted_inv_distractor",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which of the following sentences correctly uses negative inversion?",
        "options": [
            "A) Under no circumstances we should ignore safety protocols.",
            "B) Under no circumstances should we ignore safety protocols.",
            "C) Under no circumstances we shouldn't ignore safety protocols.",
            "D) Under no circumstances shouldn't we ignore safety protocols.",
        ],
        "proposed_answer": "B",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-inv-01",
        passage_text="When negative adverbials initiate a sentence, auxiliary inversion is required.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.FAIL
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert "Contested MCQ: option" in (res.abstention_reason or "")


def test_v2_2_grammar_valid_single_key_cleft_passes():
    """Positive control: Well-formed it-cleft MCQ with single valid answer passes under v2.2."""
    evaluator = NeutralEvaluatorV2_2()
    rp = _cleft_rule_pack()
    q_data = {
        "question_id": "g_cleft_valid",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly uses an it-cleft to emphasize 'synaptic plasticity'?",
        "options": [
            "A) Synaptic plasticity underpins long-term memory formation.",
            "B) It is synaptic plasticity that underpins long-term memory formation.",
            "C) Synaptic plasticity that underpins long-term memory formation is crucial.",
            "D) Underpinning long-term memory formation is synaptic plasticity.",
        ],
        "proposed_answer": "B",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="dev-grammar-cleft-01",
        passage_text="When emphasizing a noun phrase, cleft sentences package information.",
        question_data=q_data,
        context_metadata={"rule_pack": rp},
    )
    assert res.evaluable is True
    assert res.verdict == EvaluationVerdict.PASS
    assert res.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0


# ── 3. Reliability & Calibration Suite Check ─────────────────────────────────


def test_v2_2_calibration_corpus_zero_false_accepts():
    """Measures evaluator performance on CALIBRATION_CORPUS (n=6)."""
    evaluator = NeutralEvaluatorV2_2()
    metrics = measure_evaluator_reliability(evaluator, CALIBRATION_CORPUS, "CALIBRATION_CORPUS")
    assert metrics.evaluable_count == len(CALIBRATION_CORPUS)
    assert metrics.false_positive_count == 0, f"Expected 0 false accepts, got {metrics.false_positive_count}"
    assert metrics.false_negative_count == 0, f"Expected 0 false rejects, got {metrics.false_negative_count}"
    assert metrics.accuracy_on_decided == 1.0


def test_evaluator_versioning_isolation():
    """Confirms version strings and distinct profile identities."""
    ev_base = NeutralEvaluator()
    ev_v2 = NeutralEvaluatorV2()
    ev_v2_2 = NeutralEvaluatorV2_2()
    ev_v2_3 = NeutralEvaluatorV2_3()

    assert ev_base.evaluator_version == "neutral-eval-v2.0"
    assert ev_base.rubric.rubric_version == "R1-2026.1"

    assert ev_v2.evaluator_version == "neutral-eval-v2.1"
    assert ev_v2.rubric.rubric_version == "rubric-qgeval-v2.1"

    assert ev_v2_2.evaluator_version == "neutral-eval-v2.2"
    assert ev_v2_2.rubric.rubric_version == "rubric-qgeval-v2.2"

    assert ev_v2_3.evaluator_version == "neutral-eval-v2.3"
    assert ev_v2_3.rubric.rubric_version == "rubric-qgeval-v2.3"
def test_fresh_judge_holdout_v2_provenance_disjointness():
    """Confirms that FRESH_JUDGE_HOLDOUT_CORPUS_V2 has zero overlap with calibration or DEV families."""
    from app.evaluators.calibration import (
        FRESH_JUDGE_HOLDOUT_CORPUS_V2,
        JUDGE_HOLDOUT_CORPUS,
        verify_split_disjointness,
    )
    # DEV families from pilot fixtures
    dev_families = {
        "fam-neuroscience-03",
        "fam-linguistics-cleft-03",
        "national_geographic",
        "academic_grammar_corpus",
        "fam-volcanology-02",
        "fam-marine-02",
        "fam-robotics-02",
    }

    is_disjoint, violations = verify_split_disjointness(
        calibration_items=CALIBRATION_CORPUS,
        holdout_items=FRESH_JUDGE_HOLDOUT_CORPUS_V2,
        excluded_families=dev_families,
    )
    assert is_disjoint is True, f"Split disjointness violations: {violations}"
    assert len(violations) == 0
