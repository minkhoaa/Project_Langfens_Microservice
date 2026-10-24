"""Quality-First Post-Campaign Remediation Verification Suite (RG10 Remediation).

Tests covering:
1. Reading research input provenance and authoritative source excerpt binding without verbatim model echo.
2. Genuine generated questions remaining source-grounded and independently validated.
3. Independent evaluator validity: verified source spans (Reading) and verified GrammarRulePack (Grammar)
   without artificial score floors or fabricated evidence.
4. Arm C pipeline fixes: robust fenced/braced JSON parsing, canonical answer verification, 4-option MCQ enforcement.
5. Removal of arbitrary resource ceilings.
"""
from __future__ import annotations

import json
import pytest

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarQuestionType,
    GrammarRulePack,
    GrammarTask,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    ReadingTask,
    SourceRef,
    StandaloneGrammarRequest,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.contracts.solver import StudentVisibleOption
from app.evaluators.independent import NeutralEvaluator, NeutralEvaluatorV2
from app.evaluators.rubric import EvaluationVerdict, RubricDimension, RubricProfile
from app.experiment.parsing import (
    ParsedCandidate,
    SolverAnswer,
    SolverResponse,
    extract_fenced_or_braced_json,
    parse_candidate,
    response_object,
    solver_failure,
)
from app.experiment.providers import OpenAICompatibleExperimentClient
from app.experiment.runners import ConfigurationARunner, ConfigurationCRunner
from app.experiment.scoring import score_campaign_output, GenerationResult
from app.providers.adapters.openai_compatible import OpenAICompatibleProvider


PASSAGE = (
    "Controlled environment agriculture (CEA) has become one of the fastest-growing sectors of modern "
    "horticulture. Fully enclosed indoor facilities rely exclusively on artificial lighting to optimize plant "
    "growth and maximize crop yields. Light quality refers to wavelength composition, while light intensity "
    "governs the photosynthetic rate. Recent studies demonstrate that specific blue and red spectrum ratios "
    "enhance secondary metabolite production in leafy greens and medicinal crops."
)


def _reading_req() -> StandaloneReadingRequest:
    return StandaloneReadingRequest(
        run_id="run-rem-rd-01",
        dataset_item_id="item-rem-reading-01",
        configuration_id="A",
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=2,
            difficulty="B2",
        ),
        source_pack_id="src-pack-01",
    )


def _grammar_req(exercise_type: GrammarExerciseType = GrammarExerciseType.MCQ_SINGLE) -> StandaloneGrammarRequest:
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-inversion-01",
        source=SourceRef(source_id="src-01", source_family="fam-01", source_version="v1.0",
                         source_sha256="0" * 64, license="test", provenance_uri="https://test.internal"),
        topic="Negative and Limiting Adverbial Inversion",
        level="B2",
        rule_ids=["inv-neg-01"],
        applicability=["Academic IELTS"],
        exceptions=["Colloquial speech"],
        examples=["Seldom have researchers observed such pronounced discrepancies in field trials."],
    )
    return StandaloneGrammarRequest(
        run_id="run-rem-gr-01",
        dataset_item_id="item-rem-grammar-01",
        configuration_id="A",
        rule_pack=rule_pack,
        task=GrammarTask(
            grammar_rule_pack_ref=rule_pack.rule_pack_id,
            exercise_type=exercise_type,
            requested_question_count=1,
            difficulty="B2",
        ),
    )


# ── 1. Reading Authoritative Source Excerpt Binding ─────────────────────────


def test_reading_source_excerpt_bound_from_frozen_input():
    """Reading input provenance is preserved from frozen input without verbatim model echo."""
    req = _reading_req()
    # Model returns questions but emits truncated/partial context_text
    model_raw = json.dumps({
        "context_text": "Controlled environment agriculture (CEA) has become modern.",
        "question_groups": [{"group_id": "grp-1", "question_ids": ["q1", "q2"]}],
        "questions": [
            {"question_id": "q1", "question_type": "TFNG",
             "text": "Fully enclosed indoor facilities rely exclusively on artificial lighting.",
             "instructions": "Choose True, False or Not Given.", "options": [],
             "proposed_answer": "TRUE"},
            {"question_id": "q2", "question_type": "TFNG",
             "text": "Light quality refers to wavelength composition.",
             "instructions": "Choose True, False or Not Given.", "options": [],
             "proposed_answer": "TRUE"},
        ],
    })
    candidate = parse_candidate(model_raw, req, PASSAGE)
    assert candidate.failure_code is None
    assert candidate.availability == OutputAvailability.NORMALIZED
    assert candidate.content is not None
    # Authoritative passage is bound from frozen input, not model echo
    assert candidate.content.context_text == PASSAGE
    assert len(candidate.content.questions) == 2


def test_reading_source_excerpt_bound_when_model_omits_context():
    """When model obeys prompt instruction not to re-emit context_text, input passage is bound."""
    req = _reading_req()
    model_raw = json.dumps({
        "question_groups": [{"group_id": "grp-1", "question_ids": ["q1", "q2"]}],
        "questions": [
            {"question_id": "q1", "question_type": "TFNG",
             "text": "Photosynthetic rate is governed by light intensity.",
             "instructions": "Choose True, False or Not Given.", "options": [],
             "proposed_answer": "TRUE"},
            {"question_id": "q2", "question_type": "TFNG",
             "text": "Studies demonstrate that specific blue and red spectrum ratios enhance metabolites.",
             "instructions": "Choose True, False or Not Given.", "options": [],
             "proposed_answer": "TRUE"},
        ],
    })
    candidate = parse_candidate(model_raw, req, PASSAGE)
    assert candidate.failure_code is None
    assert candidate.content is not None
    assert candidate.content.context_text == PASSAGE


# ── 2. Independent Evaluator Validity: Reading & Grammar Grounding ───────────


def test_independent_evaluator_v2_reading_grounding_verified():
    """Verified source spans in passage yield >= 3.0 grounding without artificial <= 2.0 floor."""
    evaluator = NeutralEvaluatorV2()
    assert evaluator.evaluator_version == "neutral-eval-v2.1"
    assert evaluator.rubric.rubric_version == "rubric-qgeval-v2.1"

    q_data = {
        "question_id": "q1",
        "question_type": "TFNG",
        "text": "Fully enclosed indoor facilities rely exclusively on artificial lighting.",
        "instructions": "Choose True, False or Not Given.",
        "options": [],
        "proposed_answer": "TRUE",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="item-rem-reading-01",
        passage_text=PASSAGE,
        question_data=q_data,
    )
    assert res.evaluable is True
    # Grounding is evaluated against authentic passage spans and reaches PASS
    assert res.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0
    assert res.semantic_scores[RubricDimension.ANSWERABILITY.value] >= 3.0
    assert res.verdict == EvaluationVerdict.PASS
    assert len(res.evidence_refs) > 0


def test_independent_evaluator_v2_reading_ungrounded_question_fails():
    """Ungrounded question lacking passage support fails grounding check."""
    evaluator = NeutralEvaluatorV2()
    q_data = {
        "question_id": "q_ungrounded",
        "question_type": "TFNG",
        "text": "Quantum computers operate at absolute zero using superconducting qubits.",
        "instructions": "Choose True, False or Not Given.",
        "options": [],
        "proposed_answer": "TRUE",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="item-rem-reading-01",
        passage_text=PASSAGE,
        question_data=q_data,
    )
    assert res.evaluable is True
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert res.verdict == EvaluationVerdict.FAIL


def test_independent_evaluator_v2_grammar_grounding_verified_against_rule_pack():
    """Grammar question verified against GrammarRulePack passes without artificial floor."""
    evaluator = NeutralEvaluatorV2()
    rule_pack = _grammar_req().rule_pack

    q_data = {
        "question_id": "q_g1",
        "question_type": "GRAMMAR_MCQ",
        "text": "Seldom _____ researchers observed such pronounced discrepancies in field trials.",
        "instructions": "Choose the correct option.",
        "options": ["have", "did", "had", "would"],
        "proposed_answer": "have",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="item-rem-grammar-01",
        passage_text="Seldom have researchers observed such discrepancies.",
        question_data=q_data,
        context_metadata={"rule_pack": rule_pack},
    )
    assert res.evaluable is True
    assert res.semantic_scores[RubricDimension.GROUNDING.value] >= 3.0
    assert res.semantic_scores[RubricDimension.ANSWERABILITY.value] >= 3.0
    assert res.verdict == EvaluationVerdict.PASS
    assert any("rule_pack:grp-inversion-01" in ref for ref in res.evidence_refs)


def test_independent_evaluator_v2_grammar_unexercised_rule_pack_fails():
    """Grammar question not exercising the target rule pack fails grounding verification."""
    evaluator = NeutralEvaluatorV2()
    rule_pack = _grammar_req().rule_pack

    q_data = {
        "question_id": "q_g2",
        "question_type": "GRAMMAR_MCQ",
        "text": "The cat sat on the mat peacefully.",
        "instructions": "Choose the correct option.",
        "options": ["sat", "sits", "sitting", "seated"],
        "proposed_answer": "sat",
    }
    res = evaluator.evaluate_item(
        dataset_item_id="item-rem-grammar-01",
        passage_text="The cat sat on the mat peacefully throughout the entire quiet morning.",
        question_data=q_data,
        context_metadata={"rule_pack": rule_pack},
    )
    assert res.evaluable is True
    assert res.semantic_scores[RubricDimension.GROUNDING.value] <= 2.0
    assert res.verdict == EvaluationVerdict.FAIL


# ── 3. Arm C Defects: Robust Parsing & Canonical Verification ───────────────


def test_robust_json_parsing_with_markdown_fences_and_postamble():
    """Fenced code blocks with trailing explanations parse cleanly without UNPARSEABLE error."""
    raw = (
        "```json\n"
        "{\n"
        '  "answers": [\n'
        '    {"question_id": "q1", "answer": "TRUE", "ambiguous": false},\n'
        '    {"question_id": "q2", "answer": "FALSE", "ambiguous": false}\n'
        "  ]\n"
        "}\n"
        "```\n\n"
        "### Explanation:\n"
        "Question 1 is clearly True based on paragraph 1.\n"
        "Question 2 is False based on paragraph 2."
    )
    parsed = response_object(raw)
    assert parsed is not None
    assert "answers" in parsed
    assert len(parsed["answers"]) == 2


def test_robust_json_parsing_braced_object_with_preamble():
    """Conversational preambles before JSON parse cleanly without failure."""
    raw = (
        "Here is the requested evaluation result in raw JSON format:\n\n"
        "{\n"
        '  "status": "APPROVED",\n'
        '  "issues": []\n'
        "}\n\n"
        "Hope this helps!"
    )
    parsed = response_object(raw)
    assert parsed is not None
    assert parsed["status"] == "APPROVED"


def test_solver_failure_canonical_answer_matching():
    """MCQ option text matching and TFNG canonicalization succeed without false disagreement."""
    candidate = ParsedCandidate(
        content=NeutralOutput(
            context_text=PASSAGE,
            question_groups=[NeutralQuestionGroup(group_id="g1", question_ids=["q1", "q2"])],
            questions=[
                NeutralQuestion(question_id="q1", question_type="MCQ_SINGLE",
                                text="What governs the photosynthetic rate?",
                                instructions="Select one option.",
                                options=["wavelength composition", "light intensity", "temperature", "humidity"]),
                NeutralQuestion(question_id="q2", question_type="TFNG",
                                text="Light quality refers to wavelength composition.",
                                instructions="Select True, False or Not Given.",
                                options=[]),
            ],
        ),
        availability=OutputAvailability.NORMALIZED,
        failure_code=None,
        proposed_answers=(("q1", "B"), ("q2", "TRUE")),
    )

    # Solver emits "light intensity" (option B text) and "True." (with period)
    solved = SolverResponse(
        answers=(
            SolverAnswer(question_id="q1", answer="light intensity", ambiguous=False),
            SolverAnswer(question_id="q2", answer="True.", ambiguous=False),
        )
    )
    fail = solver_failure(solved, candidate)
    assert fail is None, f"Expected canonical match, got: {fail}"


def test_solver_failure_genuine_disagreement_detected():
    """Genuine disagreement between solver and proposed answer is strictly detected."""
    candidate = ParsedCandidate(
        content=NeutralOutput(
            context_text=PASSAGE,
            question_groups=[NeutralQuestionGroup(group_id="g1", question_ids=["q1"])],
            questions=[
                NeutralQuestion(question_id="q1", question_type="TFNG",
                                text="CEA systems operate without artificial lighting.",
                                instructions="Select True, False or Not Given.",
                                options=[]),
            ],
        ),
        availability=OutputAvailability.NORMALIZED,
        failure_code=None,
        proposed_answers=(("q1", "TRUE"),),
    )
    solved = SolverResponse(
        answers=(
            SolverAnswer(question_id="q1", answer="FALSE", ambiguous=False),
        )
    )
    fail = solver_failure(solved, candidate)
    assert fail == "ANSWER_VERIFICATION_DISAGREEMENT"


def test_mcq_strict_four_options_enforced():
    """MCQ questions with fewer than 4 options fail as QUESTION_OPTIONS_INVALID (distractor defect)."""
    req = _grammar_req()
    raw = json.dumps({
        "context_text": "Seldom have researchers observed discrepancies in field trials.",
        "question_groups": [{"group_id": "g1", "question_ids": ["q1"]}],
        "questions": [
            {"question_id": "q1", "question_type": "GRAMMAR_MCQ",
             "text": "Seldom _____ researchers observed discrepancies.",
             "instructions": "Choose option.",
             "options": ["have", "did", "had"],  # Only 3 options
             "proposed_answer": "have"},
        ],
    })
    cand = parse_candidate(raw, req, None)
    assert cand.failure_code == "QUESTION_OPTIONS_INVALID"


# ── 4. Resource Ceilings ────────────────────────────────────────────────────


def test_resource_spending_limit_unbounded_by_default():
    """max_spending_limit_usd is None by default, preventing artificial resource blockers."""
    provider = OpenAICompatibleProvider("test", "https://test.internal/v1", models={"large": "test-model"})
    client = OpenAICompatibleExperimentClient(provider=provider, api_key="test-key")
    assert client.max_spending_limit_usd is None
    # Client does not halt dispatches on arbitrary $10 ceiling
    assert client.cumulative_spent_usd == 0.0
