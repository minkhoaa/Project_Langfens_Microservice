"""Grammar Quality Correctness Gate Test Suite (RG10 Verification).

Covers:
1. Negative Inversion Structural Detection vs Full Grammaticality Validation
2. Negative Inversion triggers (Not only, Seldom, Rarely, Never, Hardly, Scarcely, Under no circumstances, Not until)
3. Modal + bare infinitive, do-support + base verb, have-aspect + participle, agreement
4. Illegal extra infinitive markers ('to')
5. Duplicate / misplaced auxiliaries ('do we should', 'did we should')
6. Missing subject in inverted clauses
7. Uninverted order and lexical verb inversion
8. Ambiguous MCQ distractor detection (multiple valid options)
9. Defective MCQ distractor detection (zero valid options)
10. Stem-answer constraint discord (e.g. stem requests 'do' but answer uses modal)
11. Content-aware novelty checking (rule pattern reuse vs carrier sentence copying)
12. Multi-family GrammarRulePack verification (inversion, clefts, subjunctive, conditionals, modals, passives)
13. Historical v2.5 vs v2.6 re-evaluation isolation on all 6 live DEV pilot MCQs
"""
from __future__ import annotations

import math
import pytest

from app.contracts.research import GrammarRulePack, SourceRef
from app.evaluators.independent import (
    NeutralEvaluatorV2_5,
    NeutralEvaluatorV2_6,
)
from app.evaluators.rubric import EvaluationVerdict
from app.evaluators.semantic import (
    check_content_aware_novelty,
    detect_negative_inversion_structural,
    detect_negative_inversion_syntax,
    extract_substantive_tokens,
    validate_negative_inversion_grammaticality,
)


# ── 1. Structural Inversion vs Full Grammaticality Validation ───────────────────

def test_structural_inversion_separation():
    """Structural inversion detection identifies Trigger + Aux + Subject regardless of verb phrase defects."""
    # A defective sentence with illicit 'to' after modal still exhibits structural inversion
    is_struct, info = detect_negative_inversion_structural("Under no circumstances should we to open the door.")
    assert is_struct is True
    assert info["trigger"].lower() == "under no circumstances"
    assert info["auxiliary"].lower() == "should"
    assert info["subject"].lower() == "we"

    # Full grammaticality validation correctly marks it as INVALID
    res = validate_negative_inversion_grammaticality("Under no circumstances should we to open the door.")
    assert res.is_structural_inversion is True
    assert res.is_grammatically_valid is False
    assert res.verdict == "INVALID"
    assert "Illegal extra infinitive marker 'to'" in (res.rejection_reason or "")


def test_uninversion_structural_rejection():
    """Uninverted sentences are rejected at the structural detection phase."""
    is_struct, info = detect_negative_inversion_structural("Under no circumstances we should open the door.")
    assert is_struct is False
    assert "Uninverted word order" in info["rejection_reason"]

    res = validate_negative_inversion_grammaticality("Under no circumstances we should open the door.")
    assert res.is_structural_inversion is False
    assert res.is_grammatically_valid is False
    assert res.verdict == "INVALID"


def test_lexical_verb_inversion_rejection():
    """Full lexical verb inversion (e.g. 'won she') is rejected."""
    is_struct, info = detect_negative_inversion_structural("Not only won she the award, but she broke the record.")
    assert is_struct is False
    assert "Illegal lexical verb 'won'" in info["rejection_reason"]

    res = validate_negative_inversion_grammaticality("Not only won she the award, but she broke the record.")
    assert res.is_structural_inversion is False
    assert res.is_grammatically_valid is False


# ── 2. Comprehensive Trigger Coverage ──────────────────────────────────────────

@pytest.mark.parametrize("sentence", [
    "Not only did she win the race, but she also broke the record.",
    "Seldom have researchers observed such pronounced discrepancies in field trials.",
    "Rarely has the scientific committee witnessed such unanimous consensus among peer reviewers.",
    "Never before had the laboratory encountered such extreme pressure anomalies.",
    "Hardly had the experiment begun when the secondary generator failed.",
    "Scarcely had she finished the presentation when the panel raised objections.",
    "Under no circumstances should the pressurized autoclave be opened prior to temperature stabilization.",
    "Not until the meeting ended did the manager speak to the press.",
    "At no time did the telemetry indicate a containment breach.",
    "On no account should untreated effluent be discharged into the drainage system.",
    "In no way does the preliminary report justify terminating the trial.",
    "Little did the technicians suspect what the calibration drift indicated.",
    "Only after the alarm sounded did they realize the danger.",
])
def test_valid_inversion_triggers(sentence: str):
    """All standard negative and limiting adverbial triggers pass full grammaticality validation."""
    res = validate_negative_inversion_grammaticality(sentence)
    assert res.is_structural_inversion is True, f"Failed structural: {sentence} -> {res.rejection_reason}"
    assert res.is_grammatically_valid is True, f"Failed validity: {sentence} -> {res.rejection_reason}"
    assert res.verdict == "VALID"


# ── 3. Verb Phrase Grammar Defects (Distractor Validation) ─────────────────────

def test_modal_double_auxiliary_defect():
    """Illicit do-support alongside a modal auxiliary is rejected."""
    res1 = validate_negative_inversion_grammaticality("Under no circumstances do we should open the door.")
    assert res1.is_grammatically_valid is False
    assert "Illegal duplicate or misplaced auxiliary/modal 'should'" in (res1.rejection_reason or "")

    res2 = validate_negative_inversion_grammaticality("Under no circumstances did we should leave the building.")
    assert res2.is_grammatically_valid is False
    assert "Illegal duplicate or misplaced auxiliary/modal 'should'" in (res2.rejection_reason or "")


def test_modal_inflected_verb_defect():
    """Modal auxiliary followed by -ing, -s, or past tense is rejected."""
    # Participle -ing
    res_ing = validate_negative_inversion_grammaticality("Under no circumstances should we opening the door.")
    assert res_ing.is_grammatically_valid is False
    assert "cannot be followed directly by present participle" in (res_ing.rejection_reason or "")

    # 3rd-person -s
    res_s = validate_negative_inversion_grammaticality("Under no circumstances should he opens the door.")
    assert res_s.is_grammatically_valid is False
    assert "requires bare infinitive" in (res_s.rejection_reason or "")

    # Past tense
    res_past = validate_negative_inversion_grammaticality("Under no circumstances should we opened the door.")
    assert res_past.is_grammatically_valid is False
    assert "requires bare infinitive" in (res_past.rejection_reason or "")


def test_do_support_inflected_verb_defect():
    """Do-support auxiliary followed by -s or past tense is rejected."""
    res_s = validate_negative_inversion_grammaticality("Seldom did he knows what was happening.")
    assert res_s.is_grammatically_valid is False
    assert "requires base verb form" in (res_s.rejection_reason or "")

    res_past = validate_negative_inversion_grammaticality("Seldom did he knew what was happening.")
    assert res_past.is_grammatically_valid is False
    assert "requires base verb form" in (res_past.rejection_reason or "")


def test_missing_subject_defect():
    """Inverted auxiliary directly followed by verb without a subject is rejected."""
    res = validate_negative_inversion_grammaticality("Under no circumstances should open the door before inspection.")
    assert res.is_grammatically_valid is False
    assert "Missing subject in inverted clause" in (res.rejection_reason or "")


# ── 4. Content-Aware Novelty Checking ──────────────────────────────────────────

def test_content_aware_novelty_preserves_compulsory_patterns():
    """Rule triggers such as 'Under no circumstances should' do not trigger false copy detection."""
    examples = [
        "Rarely has the scientific committee witnessed such unanimous consensus among peer reviewers.",
        "Under no circumstances should the pressurized autoclave be opened prior to temperature stabilization."
    ]

    # Valid novel carrier using the rule's mandatory trigger
    item1 = "Under no circumstances should we open the door."
    score1, status1, _ = check_content_aware_novelty("", [{"text": item1}], examples)
    assert score1 == 1.0
    assert status1 == "NOVEL"

    item2 = "Under no circumstances should we leave the building."
    score2, status2, _ = check_content_aware_novelty("", [{"text": item2}], examples)
    assert score2 == 1.0
    assert status2 == "NOVEL"


def test_content_aware_novelty_detects_substantive_near_duplicates():
    """Substantive example reuse (autoclave + pressurized + opened) is detected as 0.0 copy."""
    examples = [
        "Under no circumstances should the pressurized autoclave be opened prior to temperature stabilization."
    ]

    # Exact verbatim copy
    exact = "Under no circumstances should the pressurized autoclave be opened prior to temperature stabilization."
    score_ex, status_ex, _ = check_content_aware_novelty("", [{"text": exact}], examples)
    assert score_ex == 0.0
    assert status_ex == "EXACT_COPY"

    # Near duplicate copying the autoclave scenario
    near_dup = "Under no circumstances should the pressurized autoclave be opened by technicians."
    score_nd, status_nd, _ = check_content_aware_novelty("", [{"text": near_dup}], examples)
    assert score_nd == 0.0
    assert status_nd == "SUBSTANTIVE_NEAR_DUPLICATE"


def test_content_aware_novelty_missing_examples_returns_unknown():
    """When rule pack has no examples, novelty reports UNKNOWN rather than pretending 100% novel."""
    score, status, meta = check_content_aware_novelty("Prompt", [{"text": "Option A"}], None)
    assert math.isnan(score)
    assert status == "UNKNOWN"

    score_empty, status_empty, _ = check_content_aware_novelty("Prompt", [{"text": "Option A"}], [])
    assert math.isnan(score_empty)
    assert status_empty == "UNKNOWN"


# ── 5. Evaluator v2.5 vs v2.6 Historical Isolation on 6 Pilot Questions ───────

@pytest.fixture
def inversion_rule_pack() -> GrammarRulePack:
    return GrammarRulePack(
        rule_pack_id="pack-inversion-dev-05",
        source=SourceRef(
            source_id="src-syntax-dev-05",
            source_family="fam-syntax-inversion-05",
            source_version="2026-dev-v3",
            source_sha256="b" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://syntax.example.com/negative-inversion",
        ),
        topic="Negative and Restrictive Adverbial Inversion",
        level="C1",
        rule_ids=["rule-inversion-01"],
        applicability=[
            "When an initial negative or restrictive adverbial (such as Rarely, Seldom, Not only, Scarcely, Under no circumstances) opens a sentence, subject-auxiliary inversion is mandatory."
        ],
        exceptions=[
            "When no auxiliary verb is present in the declarative sentence, an appropriate form of do/does/did must be inserted."
        ],
        examples=[
            "Rarely has the scientific committee witnessed such unanimous consensus among peer reviewers.",
            "Under no circumstances should the pressurized autoclave be opened prior to temperature stabilization."
        ],
    )


def test_historical_pilot_q1_re_evaluation(inversion_rule_pack: GrammarRulePack):
    """Q1 (Arm A): 'Not only did she win...'
    v2.5: FAIL (Not only cue missing from cue list)
    v2.6: PASS (clean negative inversion with unique correct answer A)
    """
    passage_txt = " ".join(inversion_rule_pack.examples) + " Long context for test evaluation."
    ctx = {"rule_pack": inversion_rule_pack}
    q_dict = {
        "question_id": "1",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which of the following sentences correctly uses subject-auxiliary inversion with a negative adverbial?",
        "options": [
            "A) Not only did she win the race, but she also broke the record.",
            "B) Not only she won the race, but she also broke the record.",
            "C) Not only she did win the race, but she also broke the record.",
            "D) Not only she wins the race, but she also broke the record."
        ],
        "proposed_answer": "A"
    }
    r25 = NeutralEvaluatorV2_5().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)
    r26 = NeutralEvaluatorV2_6().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)

    assert r25.verdict == EvaluationVerdict.FAIL
    assert "no options exhibit valid negative inversion" in (r25.abstention_reason or "")
    assert r26.verdict == EvaluationVerdict.PASS


def test_historical_pilot_q2_re_evaluation(inversion_rule_pack: GrammarRulePack):
    """Q2 (Arm A): 'Under no circumstances should we open the door'
    v2.5: FAIL (falsely accepted distractor C 'do we should' as valid inversion)
    v2.6: PASS (distractor C correctly rejected for double auxiliary, leaving unique answer A)
    """
    passage_txt = " ".join(inversion_rule_pack.examples) + " Long context for test evaluation."
    ctx = {"rule_pack": inversion_rule_pack}
    q_dict = {
        "question_id": "2",
        "question_type": "GRAMMAR_MCQ",
        "text": "What is the correct way to rewrite the sentence 'Under no circumstances we should open the door' to follow the rule of subject-auxiliary inversion?",
        "options": [
            "A) Under no circumstances should we open the door.",
            "B) Under no circumstances we should open the door.",
            "C) Under no circumstances do we should open the door.",
            "D) Under no circumstances we do should open the door."
        ],
        "proposed_answer": "A"
    }
    r25 = NeutralEvaluatorV2_5().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)
    r26 = NeutralEvaluatorV2_6().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)

    assert r25.verdict == EvaluationVerdict.FAIL
    assert "multiple options [1, 3]" in (r25.abstention_reason or "")
    assert r26.verdict == EvaluationVerdict.PASS


def test_historical_pilot_q3_re_evaluation(inversion_rule_pack: GrammarRulePack):
    """Q3 (Arm B Q1): 'Not only did she win the award...'
    v2.5: FAIL
    v2.6: PASS
    """
    passage_txt = " ".join(inversion_rule_pack.examples) + " Long context for test evaluation."
    ctx = {"rule_pack": inversion_rule_pack}
    q_dict = {
        "question_id": "1",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which of the following sentences correctly uses negative inversion?",
        "options": [
            "A) Not only did she win the award, but she also broke the record.",
            "B) Not only she won the award, but she also broke the record.",
            "C) Not only she did win the award, but she also broke the record.",
            "D) Not only won she the award, but she also broke the record."
        ],
        "proposed_answer": "A"
    }
    r25 = NeutralEvaluatorV2_5().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)
    r26 = NeutralEvaluatorV2_6().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)

    assert r25.verdict == EvaluationVerdict.FAIL
    assert r26.verdict == EvaluationVerdict.PASS


def test_historical_pilot_q4_re_evaluation(inversion_rule_pack: GrammarRulePack):
    """Q4 (Arm B Q2): 'Under no circumstances should we leave the building'
    v2.5: FAIL (distractor C 'did we should' falsely accepted)
    v2.6: PASS (distractor C correctly rejected for double auxiliary, unique answer A)
    """
    passage_txt = " ".join(inversion_rule_pack.examples) + " Long context for test evaluation."
    ctx = {"rule_pack": inversion_rule_pack}
    q_dict = {
        "question_id": "2",
        "question_type": "GRAMMAR_MCQ",
        "text": "What is the correct way to rewrite the sentence 'Under no circumstances we should leave the building' using proper inversion?",
        "options": [
            "A) Under no circumstances should we leave the building.",
            "B) Under no circumstances we should leave the building.",
            "C) Under no circumstances did we should leave the building.",
            "D) Under no circumstances we should not leave the building."
        ],
        "proposed_answer": "A"
    }
    r25 = NeutralEvaluatorV2_5().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)
    r26 = NeutralEvaluatorV2_6().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)

    assert r25.verdict == EvaluationVerdict.FAIL
    assert "multiple options [1, 3]" in (r25.abstention_reason or "")
    assert r26.verdict == EvaluationVerdict.PASS


def test_historical_pilot_q6_re_evaluation(inversion_rule_pack: GrammarRulePack):
    """Q6 (Arm C Q2): Stem asks for 'uses do', but option C uses 'should'.
    v2.5: PASS (blind to stem constraint mismatch)
    v2.6: FAIL (catches stem-answer constraint conflict)
    """
    passage_txt = " ".join(inversion_rule_pack.examples) + " Long context for test evaluation."
    ctx = {"rule_pack": inversion_rule_pack}
    q_dict = {
        "question_id": "Q2",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly uses 'do' to form subject-auxiliary inversion when there is no auxiliary verb?",
        "options": [
            "A) Under no circumstances open the door before checking the credentials.",
            "B) Under no circumstances you should open the door before checking the credentials.",
            "C) Under no circumstances should you open the door before checking the credentials.",
            "D) Under no circumstances should open the door before checking the credentials."
        ],
        "proposed_answer": "C"
    }
    r25 = NeutralEvaluatorV2_5().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)
    r26 = NeutralEvaluatorV2_6().evaluate_item("dev-grammar-inversion-05", passage_txt, q_dict, context_metadata=ctx)

    assert r25.verdict == EvaluationVerdict.PASS
    assert r26.verdict == EvaluationVerdict.FAIL
    assert "Stem-answer constraint conflict" in (r26.abstention_reason or "")


# ── 6. Multi-Family Grammar Rule Packs Coverage ────────────────────────────────

def test_subjunctive_distractor_validation():
    """Mandative subjunctive MCQ requires base verb form in correct option and flags inflected distractors."""
    rule_pack = GrammarRulePack(
        rule_pack_id="pack-subj-01",
        source=SourceRef(
            source_id="src-subj", source_family="fam-subj", source_version="v1.0",
            source_sha256="0" * 64, license="test", provenance_uri="internal://subj"
        ),
        topic="Mandative and Formulaic Subjunctive Clauses",
        level="B2",
        rule_ids=["subj-mand-01"],
        applicability=["The mandative subjunctive mandates base form verb."],
        examples=["The safety guidelines mandate that every researcher wear protective gear."],
    )
    passage_txt = "The safety guidelines mandate that every researcher wear protective gear at all times."
    ctx = {"rule_pack": rule_pack}

    # Valid MCQ: only Option B has base form 'wear', others have 'wears', 'wore', 'wearing'
    q_valid = {
        "question_id": "1",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly applies the mandative subjunctive?",
        "options": [
            "A) The protocol mandates that every technician wears gloves.",
            "B) The protocol mandates that every technician wear gloves.",
            "C) The protocol mandates that every technician wore gloves.",
            "D) The protocol mandates that every technician wearing gloves."
        ],
        "proposed_answer": "B"
    }
    r_valid = NeutralEvaluatorV2_6().evaluate_item("item-subj", passage_txt, q_valid, context_metadata=ctx)
    assert r_valid.verdict == EvaluationVerdict.PASS
    assert r_valid.task_validity["unique_correct_answer"] is True

    # Ambiguous MCQ: options B and C both use base form
    q_ambig = {
        "question_id": "2",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly applies the mandative subjunctive?",
        "options": [
            "A) The protocol mandates that every technician wears gloves.",
            "B) The protocol mandates that every technician wear gloves.",
            "C) The protocol mandates that each student wear goggles.",
            "D) The protocol mandates that every technician wore gloves."
        ],
        "proposed_answer": "B"
    }
    r_ambig = NeutralEvaluatorV2_6().evaluate_item("item-subj", passage_txt, q_ambig, context_metadata=ctx)
    assert r_ambig.verdict == EvaluationVerdict.FAIL
    assert "Ambiguous subjunctive MCQ" in (r_ambig.abstention_reason or "")


def test_bare_plural_subject_negative_inversion():
    """Bare plural subject noun phrases ('atmospheric scientists', 'deep-sea explorers') are parsed correctly."""
    res1 = validate_negative_inversion_grammaticality("Rarely have atmospheric scientists recorded such intense drops.")
    assert res1.is_structural_inversion is True
    assert res1.is_grammatically_valid is True
    assert res1.subject == "atmospheric scientists"
    assert "recorded" in (res1.verb_phrase or "")

    res2 = validate_negative_inversion_grammaticality("Seldom do deep-sea explorers encounter such benthic fauna.")
    assert res2.is_structural_inversion is True
    assert res2.is_grammatically_valid is True
    assert res2.subject == "deep-sea explorers"
    assert "encounter" in (res2.verb_phrase or "")


def test_intervening_adverb_negative_inversion():
    """Intervening adverbs (e.g. 'actually', 'fully', 'previously') between subject and verb are supported."""
    res1 = validate_negative_inversion_grammaticality("Seldom have researchers actually observed such discrepancies.")
    assert res1.is_structural_inversion is True
    assert res1.is_grammatically_valid is True

    res2 = validate_negative_inversion_grammaticality("Rarely do scientists fully understand the mechanism.")
    assert res2.is_structural_inversion is True
    assert res2.is_grammatically_valid is True

    # Grammatical defect after adverb is properly flagged
    res_bad = validate_negative_inversion_grammaticality("Rarely do scientists fully understood the mechanism.")
    assert res_bad.is_grammatically_valid is False
    assert "requires base verb form" in (res_bad.rejection_reason or "")


def test_correlative_conjunction_discord():
    """Scarcely/hardly paired with 'than' instead of 'when' is rejected."""
    res_bad = validate_negative_inversion_grammaticality("Scarcely had the meeting started than the fire alarm rang.")
    assert res_bad.is_grammatically_valid is False
    assert "Correlative conjunction discord" in (res_bad.rejection_reason or "")

    res_good = validate_negative_inversion_grammaticality("Scarcely had the meeting started when the fire alarm rang.")
    assert res_good.is_grammatically_valid is True


def test_distractor_defects_inversion():
    """Distractors with double negatives, misplaced subjects, or missing subjects are rejected."""
    # Double negative
    res_dn = validate_negative_inversion_grammaticality("Under no circumstances will we not compromise on safety.")
    assert res_dn.is_grammatically_valid is False
    assert "double negative" in (res_dn.rejection_reason or "").lower()

    # Misplaced subject: 'should ignore we'
    res_ms = validate_negative_inversion_grammaticality("Under no circumstances should ignore we the safety protocols.")
    assert res_ms.is_grammatically_valid is False

    # Missing subject with participle: 'should left'
    res_mis = validate_negative_inversion_grammaticality("Under no circumstances should left the equipment unattended.")
    assert res_mis.is_grammatically_valid is False
    assert "Missing subject" in (res_mis.rejection_reason or "")


def test_subjunctive_multi_word_subject_and_negative_polarity():
    """Mandative subjunctive verifies multi-word subject phrases and handles negative-polarity questions."""
    rule_pack = GrammarRulePack(
        rule_pack_id="pack-subj-02",
        source=SourceRef(
            source_id="src-subj", source_family="fam-subj", source_version="v1.0",
            source_sha256="0" * 64, license="test", provenance_uri="internal://subj"
        ),
        topic="Mandative and Formulaic Subjunctive Clauses",
        level="B2",
        rule_ids=["subj-mand-01"],
        applicability=["The mandative subjunctive mandates base form verb."],
        examples=["The contract stipulates that the supplier provide an itemized invoice."],
    )
    ctx = {"rule_pack": rule_pack}
    passage_txt = "The contract stipulates that the supplier provide an itemized invoice."

    # Multi-word subject: 'the supplier'
    q_supplier = {
        "question_id": "1",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence correctly uses the mandative subjunctive?",
        "options": [
            "A) The contract stipulates that the supplier provides a detailed invoice.",
            "B) The contract stipulates that the supplier provide a detailed invoice.",
            "C) The contract stipulates that the supplier will provide a detailed invoice.",
            "D) The contract stipulates that the supplier has to provide a detailed invoice."
        ],
        "proposed_answer": "B"
    }
    res_supp = NeutralEvaluatorV2_6().evaluate_item("item-subj", passage_txt, q_supplier, context_metadata=ctx)
    assert res_supp.verdict == EvaluationVerdict.PASS
    assert res_supp.task_validity["unique_correct_answer"] is True

    # Negative polarity question: 'Which sentence demonstrates incorrect use...?'
    q_neg = {
        "question_id": "2",
        "question_type": "GRAMMAR_MCQ",
        "text": "Which sentence demonstrates incorrect use of the mandative subjunctive?",
        "options": [
            "A) It is crucial that she submit the report by Friday.",
            "B) It is crucial that she submits the report by Friday.",
            "C) It is crucial that she must submit the report by Friday.",
            "D) It is crucial that she should submit the report by Friday."
        ],
        "proposed_answer": "B"
    }
    res_neg = NeutralEvaluatorV2_6().evaluate_item("item-subj", passage_txt, q_neg, context_metadata=ctx)
    assert res_neg.verdict == EvaluationVerdict.PASS
    assert res_neg.task_validity["unique_correct_answer"] is True
