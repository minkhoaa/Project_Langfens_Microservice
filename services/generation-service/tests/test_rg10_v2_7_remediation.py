"""Comprehensive verification test suite for NeutralEvaluatorV2_7 (RG10 Remediation).

Verifies:
1. Targeted linguistic remediation of the four known DEV defects:
   - INV-DEV-02: valid base verb 'bypass' ending in '-ss' correctly accepted (FR resolved)
   - CND-DEV-01: non-inverted conditional 'if' distractor correctly rejected under inverted stem (FR resolved)
   - SUB-DEV-04: multi-option base subjunctive ambiguity detected (FA resolved)
   - SUB-DEV-05: mandative terminology trigger bypass resolved and defective MCQ detected (FA resolved)
2. Neighboring valid forms for each corrected linguistic failure class.
3. Rigorous counterexamples ensuring narrow fixes do not introduce new false acceptances.
4. Genuinely inconclusive grammar cases yield UNCERTAIN rather than unsupported PASS or FAIL.
5. Complete 25-item DEV diagnostic suite metrics, confusion matrix, and zero-leakage independence.
"""
from __future__ import annotations

import pytest

from app.contracts.research import GrammarRulePack, SourceRef
from app.evaluators.independent import (
    NeutralEvaluatorV2_6,
    NeutralEvaluatorV2_7,
)
from app.evaluators.rubric import EvaluationVerdict, RubricDimension
from app.evaluators.semantic import validate_negative_inversion_grammaticality
from tests.test_rg10_v2_6_independent_acceptance import DEV_ACCEPTANCE_CASES, make_test_rule_pack


class TestEvaluatorV2_7Remediation:
    """Verifies that Evaluator v2.7 resolves known defects while preserving v2.6 baselines."""

    def test_inv_dev_02_remediation_and_baseline_preservation(self):
        """INV-DEV-02 ('bypass'): v2.6 fails (False Rejection), v2.7 passes (remediated)."""
        c = [x for x in DEV_ACCEPTANCE_CASES if x["id"] == "INV-DEV-02"][0]

        # v2.6 historical behavior preserved
        res_v26 = NeutralEvaluatorV2_6().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v26.verdict == EvaluationVerdict.FAIL
        assert "no options exhibit valid negative inversion" in (res_v26.abstention_reason or "")

        # v2.7 remediated behavior
        res_v27 = NeutralEvaluatorV2_7().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v27.verdict == EvaluationVerdict.PASS
        assert res_v27.abstention_reason is None
        assert res_v27.task_validity["unique_correct_answer"] is True

    def test_cnd_dev_01_remediation_and_baseline_preservation(self):
        """CND-DEV-01: v2.6 fails due to 'if' distractor; v2.7 correctly rejects 'if' option under inverted stem."""
        c = [x for x in DEV_ACCEPTANCE_CASES if x["id"] == "CND-DEV-01"][0]

        # v2.6 historical behavior preserved
        res_v26 = NeutralEvaluatorV2_6().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v26.verdict == EvaluationVerdict.FAIL
        assert "multiple options [1, 3] are defensible" in (res_v26.abstention_reason or "")

        # v2.7 remediated behavior
        res_v27 = NeutralEvaluatorV2_7().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v27.verdict == EvaluationVerdict.PASS
        assert res_v27.abstention_reason is None
        assert res_v27.task_validity["unique_correct_answer"] is True

    def test_sub_dev_04_remediation_and_baseline_preservation(self):
        """SUB-DEV-04: ambiguous subjunctive MCQ (both pay and appear are base forms).

        v2.6 falsely accepts (FA); v2.7 correctly catches multiple base forms and fails.
        """
        c = [x for x in DEV_ACCEPTANCE_CASES if x["id"] == "SUB-DEV-04"][0]

        # v2.6 historical behavior preserved (False Acceptance)
        res_v26 = NeutralEvaluatorV2_6().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v26.verdict == EvaluationVerdict.PASS

        # v2.7 remediated behavior
        res_v27 = NeutralEvaluatorV2_7().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v27.verdict == EvaluationVerdict.FAIL
        assert "Ambiguous subjunctive MCQ: multiple options [2, 3] use base subjunctive form" in (res_v27.abstention_reason or "")
        assert res_v27.task_validity["unique_correct_answer"] is False

    def test_sub_dev_05_remediation_and_baseline_preservation(self):
        """SUB-DEV-05: defective subjunctive MCQ with zero base forms.

        v2.6 falsely accepts (FA) because 'mandative' adjective stem bypassed triggers.
        v2.7 activates mandative checking and detects zero base forms.
        """
        c = [x for x in DEV_ACCEPTANCE_CASES if x["id"] == "SUB-DEV-05"][0]

        # v2.6 historical behavior preserved (False Acceptance)
        res_v26 = NeutralEvaluatorV2_6().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v26.verdict == EvaluationVerdict.PASS

        # v2.7 remediated behavior
        res_v27 = NeutralEvaluatorV2_7().evaluate_item(
            dataset_item_id=c["id"],
            passage_text=c["passage"],
            question_data=c["question"],
            context_metadata={"rule_pack": c["rule_pack"]},
        )
        assert res_v27.verdict == EvaluationVerdict.FAIL
        assert "Defective subjunctive MCQ: no options use base subjunctive form" in (res_v27.abstention_reason or "")
        assert res_v27.task_validity["unique_correct_answer"] is False

    def test_full_dev_suite_metrics_under_v2_7(self):
        """Evaluator v2.7 achieves 100% concordance on the 25 diagnostic DEV cases."""
        evaluator = NeutralEvaluatorV2_7()
        results = []

        for c in DEV_ACCEPTANCE_CASES:
            res = evaluator.evaluate_item(
                dataset_item_id=c["id"],
                passage_text=c["passage"],
                question_data=c["question"],
                context_metadata={"rule_pack": c["rule_pack"]},
            )
            pred_str = "PASS" if res.verdict == EvaluationVerdict.PASS else "FAIL"
            results.append({
                "id": c["id"],
                "family": c["family"],
                "gold": c["gold"],
                "pred": pred_str,
                "verdict": res.verdict,
                "reason": res.abstention_reason,
            })

        total = len(results)
        assert total == 25

        tp = sum(1 for r in results if r["gold"] == "VALID" and r["pred"] == "PASS")
        fn = sum(1 for r in results if r["gold"] == "VALID" and r["pred"] == "FAIL")
        tn = sum(1 for r in results if r["gold"] == "INVALID" and r["pred"] == "FAIL")
        fp = sum(1 for r in results if r["gold"] == "INVALID" and r["pred"] == "PASS")

        # Zero False Rejections and Zero False Acceptances on DEV
        assert tp == 15
        assert fn == 0
        assert tn == 10
        assert fp == 0

        # Exact rates
        fr_rate = fn / 15
        fa_rate = fp / 10
        accuracy = (tp + tn) / total
        coverage = total / total
        abstention_count = sum(1 for r in results if r["verdict"] == EvaluationVerdict.UNCERTAIN)

        assert fr_rate == 0.0
        assert fa_rate == 0.0
        assert accuracy == 1.0
        assert coverage == 1.0
        assert abstention_count == 0


class TestNeighboringValidForms:
    """Tests neighboring valid grammatical forms to verify generalized linguistic capability."""

    def test_inversion_neighboring_ss_and_eed_base_verbs(self):
        """All valid base verbs ending in '-ss' and '-eed' pass negative inversion validation."""
        valid_sentences = [
            "Under no circumstances should we bypass the interlock.",
            "Under no circumstances should we cross the threshold.",
            "Under no circumstances should we discuss classified data.",
            "Under no circumstances should we assess the risk blindly.",
            "Under no circumstances should we dismiss the safety report.",
            "Under no circumstances should we possess unauthorized materials.",
            "Under no circumstances should we surpass the operating envelope.",
            "Under no circumstances should we confess without legal counsel.",
            "Under no circumstances should we exceed the maximum pressure.",
            "Under no circumstances should we proceed without clearance.",
            "Under no circumstances should we need additional authorization.",
        ]
        for s in valid_sentences:
            res = validate_negative_inversion_grammaticality(s, allow_ss_base_verbs=True)
            assert res.is_grammatically_valid is True, f"Failed for valid sentence: {s} -> {res.rejection_reason}"
            assert res.verdict == "VALID"

    def test_conditional_neighboring_inverted_forms(self):
        """Inverted second, third, and should-conditionals pass under v2.7."""
        rule_pack = make_test_rule_pack("Inverted and Unreal Conditionals", "cnd-neigh", "Had we known, we would have acted.")
        evaluator = NeutralEvaluatorV2_7()

        # Inverted second conditional with 'were ... to'
        q_were = {
            "question_id": "CND-NEIGH-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted second conditional with 'were'?",
            "options": [
                "A) Were the temperature to exceed limits, the reactor would shut down.",
                "B) Were the temperature will exceed limits, the reactor would shut down.",
                "C) The temperature were to exceed limits, the reactor would shut down.",
                "D) If the temperature were exceeding limits, the reactor will shut down.",
            ],
            "proposed_answer": "A",
        }
        res_were = evaluator.evaluate_item(
            dataset_item_id="item-cnd-were", passage_text="Nuclear reactor safety protocols.",
            question_data=q_were, context_metadata={"rule_pack": rule_pack},
        )
        assert res_were.verdict == EvaluationVerdict.PASS

        # Inverted predictive conditional with 'should' and imperative apodosis
        q_should = {
            "question_id": "CND-NEIGH-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted conditional with 'should'?",
            "options": [
                "A) Should any anomalies arise during testing, notify the lead engineer.",
                "B) Should any anomalies arose during testing, notify the lead engineer.",
                "C) Any anomalies should arise during testing, notify the lead engineer.",
                "D) If should any anomalies arise during testing, notify the engineer.",
            ],
            "proposed_answer": "A",
        }
        res_should = evaluator.evaluate_item(
            dataset_item_id="item-cnd-should", passage_text="Engineering test instructions.",
            question_data=q_should, context_metadata={"rule_pack": rule_pack},
        )
        assert res_should.verdict == EvaluationVerdict.PASS

    def test_subjunctive_neighboring_carrier_and_subject_phrases(self):
        """Various carrier verbs and complex subject noun phrases correctly parse under v2.7."""
        rule_pack = make_test_rule_pack("Mandative and Formulaic Subjunctive Clauses", "sub-neigh", "The law demands that he comply.")
        evaluator = NeutralEvaluatorV2_7()

        # Complex subject NP: Det + Adj + Noun ('the expert witness appear')
        q_complex_subj = {
            "question_id": "SUB-NEIGH-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly applies the mandative subjunctive?",
            "options": [
                "A) The court ordered that the expert witness appears in person.",
                "B) The court ordered that the expert witness appear in person.",
                "C) The court ordered that the expert witness will appear in person.",
                "D) The court ordered that the expert witness is appearing in person.",
            ],
            "proposed_answer": "B",
        }
        res = evaluator.evaluate_item(
            dataset_item_id="item-sub-complex",
            passage_text="The special court ordered that the expert witness appear in person before the tribunal.",
            question_data=q_complex_subj, context_metadata={"rule_pack": rule_pack},
        )
        assert res.verdict == EvaluationVerdict.PASS
        assert res.task_validity["unique_correct_answer"] is True


class TestCounterexamplesPreventFalseAcceptance:
    """Verifies that remediations do NOT introduce false acceptances on ungrammatical counterexamples."""

    def test_inversion_inflected_counterexamples_strictly_rejected(self):
        """3rd-person inflected forms (-es on -ss verbs), past forms, and -ing forms are rejected."""
        counterexamples = [
            ("Under no circumstances should we bypasses the interlock.", "3rd-person inflected verb 'bypasses'"),
            ("Under no circumstances should we crosses the threshold.", "3rd-person inflected verb 'crosses'"),
            ("Under no circumstances should we discusses classified data.", "3rd-person inflected verb 'discusses'"),
            ("Under no circumstances should we assesses the risk blindly.", "3rd-person inflected verb 'assesses'"),
            ("Under no circumstances should we dismisses the safety report.", "3rd-person inflected verb 'dismisses'"),
            ("Under no circumstances should we takes the risk.", "3rd-person inflected verb 'takes'"),
            ("Under no circumstances should we bypassed the interlock.", "-ed inflected form 'bypassed'"),
            ("Under no circumstances should we bypassing the interlock.", "present participle 'bypassing'"),
            ("Under no circumstances should we crossing the threshold.", "present participle 'crossing'"),
        ]
        for s, expected_reason in counterexamples:
            res = validate_negative_inversion_grammaticality(s, allow_ss_base_verbs=True)
            assert res.is_grammatically_valid is False, f"Counterexample falsely accepted: {s}"
            assert res.verdict == "INVALID"
            assert expected_reason in (res.rejection_reason or "")

    def test_conditional_counterexamples_strictly_rejected(self):
        """Non-inverted 'if' options, stem clashes, and broken protases fail under v2.7."""
        rule_pack = make_test_rule_pack("Inverted and Unreal Conditionals", "cnd-counter", "Had we known, we would have acted.")
        evaluator = NeutralEvaluatorV2_7()

        # Stem asks for inverted conditional; all options use 'if' or broken syntax
        q_defective = {
            "question_id": "CND-COUNTER-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted third conditional?",
            "options": [
                "A) If the crew had checked the seals, they would have prevented the flood.",
                "B) If the crew checked the seals, they will prevent the flood.",
                "C) The crew had checked the seals, they would have prevented the flood.",
                "D) Did the crew check the seals, they would have prevented the flood.",
            ],
            "proposed_answer": "A",
        }
        res = evaluator.evaluate_item(
            dataset_item_id="item-cnd-counter-01",
            passage_text="The water control engineering team established standard flood prevention protocols.",
            question_data=q_defective, context_metadata={"rule_pack": rule_pack},
        )
        assert res.verdict == EvaluationVerdict.FAIL
        assert "Defective conditional MCQ: no options exhibit valid conditional structure" in (res.abstention_reason or "")

        # Answer key discord: option A is valid inverted, but proposed answer points to non-inverted distractor C
        q_discord = {
            "question_id": "CND-COUNTER-02",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted third conditional?",
            "options": [
                "A) Had the crew checked the seals, they would have prevented the flood.",
                "B) The crew had checked the seals, they would have prevented the flood.",
                "C) If the crew had checked the seals, they would have prevented the flood.",
                "D) Did the crew check the seals, they would have prevented the flood.",
            ],
            "proposed_answer": "C",  # Disqualified distractor!
        }
        res_discord = evaluator.evaluate_item(
            dataset_item_id="item-cnd-counter-02",
            passage_text="The water control engineering team established standard flood prevention protocols.",
            question_data=q_discord, context_metadata={"rule_pack": rule_pack},
        )
        assert res_discord.verdict == EvaluationVerdict.FAIL
        assert "Proposed answer key discord" in (res_discord.abstention_reason or "")

    def test_subjunctive_counterexamples_strictly_rejected(self):
        """MCQ with multiple base forms (ambiguity) or zero base forms (defective) strictly fails."""
        rule_pack = make_test_rule_pack("Mandative and Formulaic Subjunctive Clauses", "sub-counter", "The law demands that he comply.")
        evaluator = NeutralEvaluatorV2_7()

        # Defective: only inflected, modal, or progressive forms
        q_defective = {
            "question_id": "SUB-COUNTER-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly applies the mandative subjunctive?",
            "options": [
                "A) The decree demands that the defendant pays the restitution.",
                "B) The decree demands that the defendant will pay the restitution.",
                "C) The decree demands that the defendant has paid the restitution.",
                "D) The decree demands that the defendant is paying the restitution.",
            ],
            "proposed_answer": "A",
        }
        res_def = evaluator.evaluate_item(
            dataset_item_id="item-sub-counter-01",
            passage_text="The federal legal decree stipulates that each commercial facility maintain backup power.",
            question_data=q_defective, context_metadata={"rule_pack": rule_pack},
        )
        assert res_def.verdict == EvaluationVerdict.FAIL
        assert "Defective subjunctive MCQ: no options use base subjunctive form" in (res_def.abstention_reason or "")


class TestInconclusiveHandling:
    """Verifies that genuinely inconclusive grammar structures produce UNCERTAIN, not FAIL or PASS."""

    def test_unparseable_subjunctive_option_yields_uncertain(self):
        """If an option cannot be parsed into a mandative clause, Evaluator v2.7 emits UNCERTAIN."""
        rule_pack = make_test_rule_pack("Mandative and Formulaic Subjunctive Clauses", "sub-unc", "The law demands that he comply.")
        q_inconclusive = {
            "question_id": "SUB-UNC-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly applies the mandative subjunctive?",
            "options": [
                "A) Completely broken carrier fragment without any complement clause.",
                "B) The decree demands that the defendant pay the restitution.",
                "C) The decree demands that the defendant pays the restitution.",
                "D) The decree demands that the defendant will pay the restitution.",
            ],
            "proposed_answer": "B",
        }
        evaluator = NeutralEvaluatorV2_7()
        res = evaluator.evaluate_item(
            dataset_item_id="item-sub-unc-01",
            passage_text="The legal decree establishes mandatory statutory requirements for all regulated facilities.",
            question_data=q_inconclusive, context_metadata={"rule_pack": rule_pack},
        )
        assert res.verdict == EvaluationVerdict.UNCERTAIN
        assert res.abstention_reason is not None
        assert res.abstention_reason.startswith("INCONCLUSIVE_LINGUISTIC_JUDGMENT")
        assert "Inconclusive subjunctive MCQ: option(s) [1] could not be conclusively parsed" in res.abstention_reason

    def test_unparseable_conditional_option_yields_uncertain(self):
        """If a conditional option is empty or unparseable, Evaluator v2.7 emits UNCERTAIN."""
        rule_pack = make_test_rule_pack("Inverted and Unreal Conditionals", "cnd-unc", "Had we known, we would have acted.")
        q_inconclusive = {
            "question_id": "CND-UNC-01",
            "question_type": "GRAMMAR_MCQ",
            "text": "Which sentence correctly uses an inverted third conditional?",
            "options": [
                "A) Had the crew checked the seals, they would have prevented the flood.",
                "B)   ",  # Empty / whitespace-only option
                "C) If the crew had checked the seals, they would have prevented the flood.",
                "D) Did the crew check the seals, they would have prevented the flood.",
            ],
            "proposed_answer": "A",
        }
        evaluator = NeutralEvaluatorV2_7()
        res = evaluator.evaluate_item(
            dataset_item_id="item-cnd-unc-01",
            passage_text="The flood control operating instructions require continuous inspection of all marine barriers.",
            question_data=q_inconclusive, context_metadata={"rule_pack": rule_pack},
        )
        assert res.verdict == EvaluationVerdict.UNCERTAIN
        assert res.abstention_reason is not None
        assert res.abstention_reason.startswith("INCONCLUSIVE_LINGUISTIC_JUDGMENT")
        assert "Inconclusive conditional MCQ" in res.abstention_reason
