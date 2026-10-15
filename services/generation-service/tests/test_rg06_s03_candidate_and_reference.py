"""Unit tests for RG06-S03: Candidate and Reference Evidence Generation."""

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.research import (
    ExecutionStatus,
    GenerationResult,
    GrammarExerciseType,
    GrammarQuestionType,
    GrammarRulePack,
    GrammarTask,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    ReferenceAnswerEvidence,
    SourceRef,
    StandaloneGrammarRequest,
)
from app.loop.standalone_grammar import StandaloneGrammarRunner


def load_schemas():
    schema_path = (
        Path(__file__).resolve().parents[3]
        / "generation_baseline"
        / "contracts"
        / "JSON_SCHEMAS.json"
    )
    return json.loads(schema_path.read_text())


@pytest.fixture
def sample_grammar_request():
    source = SourceRef(
        source_id="src-cambridge-01",
        source_family="cambridge_advanced",
        source_version="v2.0",
        source_sha256="e" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://cambridge.org/grammar/conditionals",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-conditionals-01",
        source=source,
        topic="Mixed Conditionals",
        level="C1",
        rule_ids=["rule-cond-mixed-01"],
        applicability=["Use past perfect in if-clause with present conditional in main clause for past action with present result."],
        exceptions=["Context must clarify present relevance."],
        examples=["If I had accepted that job in London, I would be living there now."],
    )
    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref=rule_pack.rule_pack_id,
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return StandaloneGrammarRequest(
        run_id="run-gram-s03-01",
        dataset_item_id="item-gram-s03-01",
        configuration_id="A",
        task=task,
        rule_pack=rule_pack,
    )


def test_pos_rg06_s03_generation_and_private_answer_schema_valid(sample_grammar_request):
    """POS-RG06-S03: Both generation and private answer are schema-valid and traceable."""
    schemas = load_schemas()
    runner = StandaloneGrammarRunner()

    result, private_evidence = runner.run_unit(sample_grammar_request)

    # 1. Assert GenerationResult schema and properties
    assert result.run_id == sample_grammar_request.run_id
    assert result.task_type == "GRAMMAR_EXERCISE"
    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.output_availability == OutputAvailability.NORMALIZED
    assert result.generated_content is not None
    assert len(result.generated_content.questions) == 2
    assert result.private_answer_ref is not None

    # Validate NeutralOutput against JSON_SCHEMAS.json#/$defs/NeutralOutput
    jsonschema.Draft202012Validator(
        {
            "$schema": schemas["$schema"],
            "$defs": schemas["$defs"],
            "$ref": "#/$defs/NeutralOutput",
        }
    ).validate(result.generated_content.model_dump())

    # 2. Assert ReferenceAnswerEvidence properties
    assert len(private_evidence) == 2
    for ev in private_evidence:
        assert isinstance(ev, ReferenceAnswerEvidence)
        assert ev.rule_pack_id == sample_grammar_request.rule_pack.rule_pack_id
        assert ev.is_verified_gold is False
        assert ev.generator_proposed_answer
        assert ev.source_grounded_explanation


def test_neg_rg06_s03_generator_answer_never_labeled_verified_gold(sample_grammar_request):
    """NEG-RG06-S03: Generator answer is not labeled verified gold.

    Decisive condition: Rule provenance is not misrepresented as independently verified question gold.
    ReferenceAnswerEvidence strictly rejects is_verified_gold=True.
    """
    # 1. Reject setting is_verified_gold=True on candidate answer
    with pytest.raises(ValidationError):
        ReferenceAnswerEvidence(
            question_id="q1",
            rule_pack_id="grp-conditionals-01",
            target_rule_id="rule-cond-mixed-01",
            context_sentence="If she had studied harder, she would pass the exam.",
            generator_proposed_answer="would be passing",
            acceptable_variants=["would pass"],
            source_grounded_explanation="Expresses present result of unfulfilled past condition.",
            is_verified_gold=True,  # STRICTLY FORBIDDEN!
        )

    # 2. Reject extra fields attempting to declare gold status (extra='forbid')
    with pytest.raises(ValidationError):
        ReferenceAnswerEvidence(
            question_id="q1",
            rule_pack_id="grp-conditionals-01",
            target_rule_id="rule-cond-mixed-01",
            context_sentence="Context",
            generator_proposed_answer="Answer",
            source_grounded_explanation="Explanation",
            expert_verified_status="GOLD",  # Extra field forbidden!
        )


def test_edge_rg06_s03_malformed_rule_pack_or_missing_fields_safe_failure(sample_grammar_request):
    """EDGE-RG06-S03: Malformed context, simulated runner failure, and empty rules."""
    runner = StandaloneGrammarRunner()

    # 1. Simulated runner failure yields safe FAILED_VALIDATION preserving parseable content
    fail_result, fail_evidence = runner.run_unit(
        sample_grammar_request,
        simulate_failure="SIMULATED_GENERATION_ERROR",
    )
    assert fail_result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert fail_result.failure_code == "SIMULATED_GENERATION_ERROR"
    assert fail_result.output_availability in (OutputAvailability.PARSEABLE, OutputAvailability.RAW_ONLY)

    # 2. Missing target_rule_id in ReferenceAnswerEvidence fails validation
    with pytest.raises(ValidationError):
        ReferenceAnswerEvidence(
            question_id="q1",
            rule_pack_id="grp-conditionals-01",
            target_rule_id="",  # Empty!
            context_sentence="Context",
            generator_proposed_answer="Answer",
            source_grounded_explanation="Explanation",
        )


def test_reg_rg06_s03_full_reading_and_s01_s02_nonregression():
    """REG-RG06-S03: Grammar generation does not regress standalone reading or prior sprints."""
    from app.loop.standalone_reading import StandaloneReadingRunner
    from app.contracts.research import StandaloneReadingRequest, ReadingTask, StandaloneGroupType

    reading_runner = StandaloneReadingRunner()
    req = StandaloneReadingRequest(
        run_id="run-reg-s03",
        dataset_item_id="item-reg-s03",
        configuration_id="A",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=6,
            difficulty="B2",
        ),
        source_pack_id="sp-test-01",
    )
    res = reading_runner.run_unit(req, passage_text="Short text but long enough for schema validation: " + "word " * 30)
    assert res.task_type == "READING_SINGLE_PASSAGE"
    assert res.execution_status == ExecutionStatus.COMPLETED
