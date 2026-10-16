"""Unit tests for RG07-S02: Configuration A direct generator.

Invariants:
- Direct LLM generation with exactly declared generation path (call_count=1, repairs=0).
- A stays free of generation-time self-review while scored externally.
- No hidden validator/retry repair performed and reported as single call.
- Canonical output/failure accounting: partial/unparseable outputs preserve usage and failure codes.
"""

from __future__ import annotations

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.research import (
    ExecutionStatus,
    GenerationResult,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    NeutralOutput,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGrammarRequest,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.evaluators.independent import NeutralEvaluator
from app.experiment.paired import PairedAssignmentManager
from app.experiment.runners import (
    ConfigurationARunner,
    HiddenRepairForbiddenError,
)
from tests.research_provider_fixtures import DeterministicExperimentClient


def load_schemas():
    schema_path = (
        Path(__file__).resolve().parents[3]
        / "generation_baseline"
        / "contracts"
        / "JSON_SCHEMAS.json"
    )
    return json.loads(schema_path.read_text())


@pytest.fixture
def reading_fixture():
    source = SourceRef(
        source_id="src-natgeo-02",
        source_family="national_geographic",
        source_version="2024-v1",
        source_sha256="1" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/coral-reefs",
    )
    task = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )
    passage = (
        "Coral reefs are diverse underwater ecosystems held together by calcium carbonate structures "
        "secreted by corals. They occupy less than 0.1% of the world's ocean area, yet they provide a home "
        "for at least 25% of all marine species. Reefs grow best in warm, shallow, clear, sunny and agitated water. "
        * 10
    )
    return PairedTaskFixture(
        dataset_item_id="item-reading-coral-01",
        domain="READING",
        source=source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="prompt-rd-a-v1.0",
            B="prompt-rd-b-v1.0",
            C="prompt-rd-c-v1.0",
        ),
        rubric_version="rubric-qgeval-v2.0",
        reading_task=task,
        passage_text=passage,
    )


@pytest.fixture
def grammar_fixture():
    source = SourceRef(
        source_id="src-cambridge-02",
        source_family="cambridge_advanced",
        source_version="2024-v2",
        source_sha256="2" * 64,
        license="CC-BY-SA-4.0",
        provenance_uri="https://cambridge.org/grammar/c1-conditionals",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-c1-cond",
        source=source,
        topic="Mixed Conditionals",
        level="C1",
        rule_ids=["rule-c1-cond-01"],
        applicability=["Use Past Perfect in if-clause and 'would + verb' in result clause for past action with present result."],
        exceptions=["Do not use 'would' in the if-clause."],
        examples=["If I had taken that job, I would be living in London now."],
    )
    grammar_task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="grp-c1-cond",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return PairedTaskFixture(
        dataset_item_id="item-grammar-cond-01",
        domain="GRAMMAR",
        source=source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="prompt-gr-a-v1.0",
            B="prompt-gr-b-v1.0",
            C="prompt-gr-c-v1.0",
        ),
        rubric_version="rubric-qgeval-v2.0",
        grammar_task=grammar_task,
        rule_pack=rule_pack,
    )


def test_pos_rg07_s02_configuration_a_direct_generation(reading_fixture, grammar_fixture):
    """POS-RG07-S02: A stays free of generation-time self review while scored externally."""
    manager = PairedAssignmentManager()
    runner = ConfigurationARunner(client=DeterministicExperimentClient())

    # 1. Reading request execution for Arm A
    req_a = manager.map_arm_request(reading_fixture, "A", run_id="run-a-rd-01")
    assert isinstance(req_a, StandaloneReadingRequest)

    result_a, usage_a = runner.generate_reading(
        request=req_a,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.A,
        foundation_model_id=reading_fixture.foundation_model_id,
    )

    # Invariant: single call, zero repairs, no self-review
    assert usage_a["call_count"] == 1
    assert usage_a["repair_count"] == 0
    assert len(runner.client.recorded_dispatches) == 1
    assert runner.client.recorded_dispatches[0]["model_id"] == reading_fixture.foundation_model_id
    assert result_a.execution_status == ExecutionStatus.COMPLETED
    assert result_a.output_availability == OutputAvailability.NORMALIZED
    assert result_a.configuration_id == "A"
    assert result_a.generated_content is not None
    assert len(result_a.generated_content.questions) > 0

    # Validate against JSON_SCHEMAS.json
    schemas = load_schemas()
    jsonschema.Draft202012Validator(
        {"$defs": schemas["$defs"], **schemas["$defs"]["GenerationResult"]}
    ).validate(result_a.model_dump())

    # 2. Downstream external evaluation (unaware of Arm A)
    evaluator = NeutralEvaluator()
    eval_res = evaluator.evaluate_item(
        dataset_item_id=reading_fixture.dataset_item_id,
        passage_text=reading_fixture.passage_text,
        question_data=result_a.generated_content.questions[0].model_dump(),
    )
    assert eval_res.dataset_item_id == reading_fixture.dataset_item_id
    assert eval_res.rubric_version == "R1-2026.1"

    # 3. Grammar request execution for Arm A
    req_gr_a = manager.map_arm_request(grammar_fixture, "A", run_id="run-a-gr-01")
    assert isinstance(req_gr_a, StandaloneGrammarRequest)

    res_gr_a, usage_gr_a = runner.generate_grammar(
        request=req_gr_a,
        prompt_version=grammar_fixture.prompt_versions.A,
        foundation_model_id=grammar_fixture.foundation_model_id,
    )
    assert usage_gr_a["call_count"] == 1
    assert usage_gr_a["repair_count"] == 0
    assert res_gr_a.output_availability == OutputAvailability.NORMALIZED
    assert len(runner.client.recorded_dispatches) == 2

def test_neg_rg07_s02_hidden_repair_and_self_review_forbidden(reading_fixture):
    """NEG-RG07-S02: No hidden validator/retry repair performed and reported as single call."""
    manager = PairedAssignmentManager()
    req_a = manager.map_arm_request(reading_fixture, "A", run_id="run-a-rd-02")
    runner = ConfigurationARunner()

    # 1. Reject hidden repair attempts
    with pytest.raises(HiddenRepairForbiddenError, match="Hidden repair or self-review is forbidden for Configuration A"):
        runner.generate_reading(
            request=req_a,
            passage_text=reading_fixture.passage_text,
            prompt_version=reading_fixture.prompt_versions.A,
            foundation_model_id=reading_fixture.foundation_model_id,
            attempt_repair=True,  # Forbidden in Arm A
        )

    # 2. Reject hidden max_repairs > 0
    with pytest.raises(HiddenRepairForbiddenError, match="Hidden repair or self-review is forbidden for Configuration A"):
        runner.generate_reading(
            request=req_a,
            passage_text=reading_fixture.passage_text,
            prompt_version=reading_fixture.prompt_versions.A,
            foundation_model_id=reading_fixture.foundation_model_id,
            max_repairs=2,  # Forbidden in Arm A
        )


def test_edge_rg07_s02_unparseable_output_and_timeout_accounting(reading_fixture):
    """EDGE-RG07-S02: Malformed or timed-out generation preserves failure codes and usage."""
    manager = PairedAssignmentManager()
    req_a = manager.map_arm_request(reading_fixture, "A", run_id="run-a-rd-edge")
    runner = ConfigurationARunner()

    # 1. Unparseable raw output handling
    result_malformed, usage_malformed = runner.generate_reading(
        request=req_a,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.A,
        foundation_model_id=reading_fixture.foundation_model_id,
        raw_output_override="Not a valid JSON output from direct model call",
    )
    assert result_malformed.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result_malformed.output_availability == OutputAvailability.RAW_ONLY
    assert result_malformed.failure_code == "RAW_OUTPUT_UNPARSEABLE"
    assert usage_malformed["call_count"] == 1  # Call happened, must be accounted for!
    assert usage_malformed["repair_count"] == 0

    # 2. Simulated timeout handling
    result_timeout, usage_timeout = runner.generate_reading(
        request=req_a,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.A,
        foundation_model_id=reading_fixture.foundation_model_id,
        simulate_failure="TIMEOUT",
    )
    assert result_timeout.execution_status == ExecutionStatus.TIMED_OUT
    assert result_timeout.output_availability == OutputAvailability.NONE
    assert result_timeout.failure_code == "PROVIDER_TIMEOUT"
    assert usage_timeout["call_count"] == 1


def test_reg_rg07_s02_standalone_reading_and_grammar_runners_unaffected():
    """REG-RG07-S02: Adding ConfigurationARunner does not affect existing Standalone runners."""
    from app.loop.standalone_reading import StandaloneReadingRunner
    from app.loop.standalone_grammar import StandaloneGrammarRunner

    reading_runner = StandaloneReadingRunner()
    grammar_runner = StandaloneGrammarRunner()
    assert hasattr(reading_runner, "run_unit")
    assert hasattr(grammar_runner, "run_unit")
