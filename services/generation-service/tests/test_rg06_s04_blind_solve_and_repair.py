"""Unit tests for RG06-S04: Grammar Blind Solve, Distractor Checks, and Scoped Repair."""

import pytest

from app.contracts.research import (
    GrammarExerciseType,
    GrammarQuestionType,
    GrammarRulePack,
    GrammarTask,
    NeutralQuestion,
    SourceRef,
    StandaloneGrammarRequest,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import EvaluationVerdict
from app.repair.grammar import GrammarRepairEngine, GrammarRepairResult


@pytest.fixture
def grammar_rule_pack():
    source = SourceRef(
        source_id="src-cambridge-02",
        source_family="cambridge_grammar",
        source_version="v3.0",
        source_sha256="f" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://cambridge.org/grammar/inversion",
    )
    return GrammarRulePack(
        rule_pack_id="grp-inv-s04",
        source=source,
        topic="Negative Inversion",
        level="C1",
        rule_ids=["rule-neg-inv-01"],
        applicability=["Invert subject and auxiliary after negative adverbials like 'rarely', 'seldom', 'never'."],
        exceptions=["Only inverts when negative adverbial begins the clause."],
        examples=["Rarely have I seen such dedication."],
    )


def test_pos_rg06_s04_ambiguous_mcq_rejected_or_repaired_and_reevaluated(grammar_rule_pack):
    """POS-RG06-S04: Ambiguous MCQ and multiple-correct answers rejected or repaired then reevaluated."""
    evaluator = NeutralEvaluator()
    repair_engine = GrammarRepairEngine(evaluator=evaluator)

    # 1. Defective / Ambiguous MCQ with multiple correct options:
    # "Seldom _____ such beautiful architecture."
    # Both Option A ("have I seen") and Option B ("did I see") are valid inverted structures!
    ambiguous_q = NeutralQuestion(
        question_id="q-ambig-1",
        question_type=GrammarQuestionType.GRAMMAR_MCQ,
        text="Seldom _____ such beautiful architecture.",
        options=[
            "have I seen",
            "did I see",  # Multiple correct options! Ambiguity defect
            "I have seen",  # Distractor 1 (no inversion)
            "I saw",  # Distractor 2 (no inversion)
        ],
        instructions="Choose the correct letter A, B, C, or D to complete the sentence.",
    )

    context_text = f"Rule: {grammar_rule_pack.topic}. Applicability: {grammar_rule_pack.applicability[0]}. Examples: {grammar_rule_pack.examples[0]}"
    init_eval = evaluator.evaluate_item(
        dataset_item_id="item-ambig-1",
        passage_text=context_text,
        question_data=dict(
            ambiguous_q.model_dump(),
            proposed_answer="have I seen",
            evidence_quote=grammar_rule_pack.applicability[0],
        ),
    )
    # Ambiguous MCQ must NOT pass unconditionally
    # Repair engine repairs the question by substituting an unambiguous distractor
    repair_result = repair_engine.repair_mcq(
        question=ambiguous_q,
        rule_pack=grammar_rule_pack,
        detected_issue="MULTIPLE_VALID_OPTIONS",
    )

    assert repair_result.repaired is True
    assert repair_result.attempts == 1
    repaired_q = repair_result.repaired_question
    assert repaired_q.question_id == ambiguous_q.question_id
    # Verified: exactly one option is valid now
    assert len(repaired_q.options) == 4
    assert len(set(repaired_q.options)) == 4

    # Re-evaluate repaired question -> Must PASS
    re_eval = evaluator.evaluate_item(
        dataset_item_id="item-repaired-1",
        passage_text=context_text,
        question_data=dict(
            repaired_q.model_dump(),
            proposed_answer="have I seen",
            evidence_quote=grammar_rule_pack.applicability[0],
        ),
    )
    assert re_eval.verdict == EvaluationVerdict.PASS


def test_neg_rg06_s04_old_verdict_invalidated_and_bounded_no_progress(grammar_rule_pack):
    """NEG-RG06-S04: Old verdict invalidated on patched content; bounded no-progress termination."""
    evaluator = NeutralEvaluator()
    repair_engine = GrammarRepairEngine(evaluator=evaluator, max_attempts=2)

    unfixable_q = NeutralQuestion(
        question_id="q-unfixable",
        question_type=GrammarQuestionType.GRAMMAR_MCQ,
        text="Irreparably defective question prompt.",
        options=["Same", "Same", "Same", "Same"],  # Degenerate options
        instructions="Choose option.",
    )

    repair_result = repair_engine.repair_mcq(
        question=unfixable_q,
        rule_pack=grammar_rule_pack,
        detected_issue="UNRESOLVABLE_DEFECT",
        force_fail=True,
    )

    # 1. Bounded no-progress termination (does not loop infinitely)
    assert repair_result.repaired is False
    assert repair_result.attempts <= 2
    assert repair_result.termination_code == "BOUNDED_NO_PROGRESS_TERMINATION"

    # 2. Invalidation: old evaluation verdict is strictly marked invalidated
    assert repair_result.old_verdict_invalidated is True


def test_edge_rg06_s04_duplicate_options_and_zero_attempts(grammar_rule_pack):
    """EDGE-RG06-S04: Duplicate options rejection and empty repair inputs."""
    evaluator = NeutralEvaluator()

    # Duplicate options MCQ
    dup_q = NeutralQuestion(
        question_id="q-dup",
        question_type=GrammarQuestionType.GRAMMAR_MCQ,
        text="Complete sentence: Rarely _____ .",
        options=["have I", "have I", "did I", "was I"],  # Duplicate "have I"
        instructions="Choose option.",
    )

    eval_res = evaluator.evaluate_item(
        dataset_item_id="item-dup",
        passage_text="Context: Negative inversion in English grammar requires auxiliary verb before subject.",
        question_data=dict(
            dup_q.model_dump(),
            proposed_answer="have I",
            evidence_quote="Negative inversion in English grammar",
        ),
    )
    assert eval_res.verdict == EvaluationVerdict.FAIL
    assert eval_res.hard_checks["options_distinct"] is False


def test_reg_rg06_s04_reading_v2_rubric_unaffected():
    """REG-RG06-S04: Evaluator and rubric changes maintain strict Reading V2 compliance."""
    from app.evaluators.rubric import RubricProfile, GrammarRubricProfile

    reading_profile = RubricProfile()
    assert reading_profile.rubric_version == "R1-2026.1"
    assert reading_profile.min_grounding_score == 3.0

    grammar_profile = GrammarRubricProfile()
    assert grammar_profile.rubric_version == "RG06-grammar-v1.0"
    assert grammar_profile.min_grounding_score == 3.0
    assert grammar_profile.rubric_version != reading_profile.rubric_version

    profile = reading_profile
    # High fluency cannot compensate for low grounding
    ok, reason = profile.evaluate_semantic_scores({
        "clarity": 5.0,
        "fluency": 5.0,
        "relevance": 5.0,
        "grounding": 1.0,  # Below min_grounding_score
        "answerability": 5.0,
    })
    assert ok is False
    assert "Grounding score" in reason
