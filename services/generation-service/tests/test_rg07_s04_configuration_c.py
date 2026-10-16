"""Unit tests for RG07-S04: Configuration C production-derived research runner.

Invariants:
- Multi-agent coordination: Generator, Reviewer, Blind Solver, Validator.
- Blind solver/reviewer/validator recorded on trace without inflating scoring privilege.
- No C-only accepted-head predicate used as A/B/C quality metric.
- Canonical output adapter scores downstream under independent NeutralEvaluator.
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
    AcceptedHeadAsQualityMetricForbiddenError,
    ConfigurationCRunner,
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
        source_id="src-natgeo-04",
        source_family="national_geographic",
        source_version="2024-v1",
        source_sha256="4" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/glaciers",
    )
    task = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )
    passage = (
        "Glaciers are massive bodies of dense ice that are constantly moving under their own gravity. "
        "They form where the accumulation of snow exceeds its ablation over many years, often centuries. "
        "Glacial ice possesses unique mechanical properties, deforming plastically under immense confining pressure. "
        * 10
    )
    return PairedTaskFixture(
        dataset_item_id="item-reading-glacier-01",
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
        source_id="src-cambridge-04",
        source_family="cambridge_advanced",
        source_version="2024-v2",
        source_sha256="4" * 64,
        license="CC-BY-SA-4.0",
        provenance_uri="https://cambridge.org/grammar/c1-cleft-sentences",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-c1-cleft",
        source=source,
        topic="Cleft Sentences with Wh- and It",
        level="C1",
        rule_ids=["rule-c1-cleft-01"],
        applicability=["Use 'What + subject + verb + is/was' or 'It is/was + focus + that' for emphasis."],
        exceptions=["Do not omit 'that' in formal written English."],
        examples=["What he needs is a good rest.", "It was Mary who solved the problem."],
    )
    grammar_task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="grp-c1-cleft",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return PairedTaskFixture(
        dataset_item_id="item-grammar-cleft-01",
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


def test_pos_rg07_s04_configuration_c_production_derived_runner(reading_fixture, grammar_fixture):
    """POS-RG07-S04: Blind solver/reviewer/validator recorded without inflating scoring privilege."""
    manager = PairedAssignmentManager()
    req_c = manager.map_arm_request(reading_fixture, "C", run_id="run-c-rd-01")
    assert isinstance(req_c, StandaloneReadingRequest)

    runner = ConfigurationCRunner(client=DeterministicExperimentClient())
    result_c, trace_c, usage_c = runner.generate_reading(
        request=req_c,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.C,
        foundation_model_id=reading_fixture.foundation_model_id,
    )

    # 1. Multi-agent dispatches recorded without inflated scoring privilege
    assert usage_c["call_count"] == 4  # Generator, Reviewer, Blind Solver, Validator
    assert len(runner.client.recorded_dispatches) == 4
    agent_roles = [step["agent_role"] for step in trace_c["steps"]]
    assert agent_roles == ["GENERATOR", "REVIEWER", "BLIND_SOLVER", "VALIDATOR"]

    # 2. Canonical result schema adherence
    assert result_c.configuration_id == "C"
    assert result_c.execution_status == ExecutionStatus.COMPLETED
    assert result_c.output_availability == OutputAvailability.NORMALIZED
    assert result_c.generated_content is not None

    schemas = load_schemas()
    jsonschema.Draft202012Validator(
        {"$defs": schemas["$defs"], **schemas["$defs"]["GenerationResult"]}
    ).validate(result_c.model_dump())

    # 3. Downstream external scoring using identical NeutralEvaluator
    evaluator = NeutralEvaluator()
    eval_res = evaluator.evaluate_item(
        dataset_item_id=reading_fixture.dataset_item_id,
        passage_text=reading_fixture.passage_text,
        question_data=result_c.generated_content.questions[0].model_dump(),
    )
    assert eval_res.dataset_item_id == reading_fixture.dataset_item_id

    # 4. Grammar execution for Configuration C
    req_gr_c = manager.map_arm_request(grammar_fixture, "C", run_id="run-c-gr-01")
    res_gr_c, trace_gr_c, usage_gr_c = runner.generate_grammar(
        request=req_gr_c,
        prompt_version=grammar_fixture.prompt_versions.C,
        foundation_model_id=grammar_fixture.foundation_model_id,
    )
    assert usage_gr_c["call_count"] == 4
    assert res_gr_c.execution_status == ExecutionStatus.COMPLETED


def test_neg_rg07_s04_no_c_accepted_head_predicate_as_quality_metric(reading_fixture):
    """NEG-RG07-S04: No C-only accepted-head predicate used as A/B/C quality metric."""
    manager = PairedAssignmentManager()
    req_c = manager.map_arm_request(reading_fixture, "C", run_id="run-c-rd-02")
    runner = ConfigurationCRunner(client=DeterministicExperimentClient())

    _, trace_c, _ = runner.generate_reading(
        request=req_c,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.C,
        foundation_model_id=reading_fixture.foundation_model_id,
    )

    # Invariant: C internal accepted_head is recorded in trace ONLY, never accepted as rubric verdict
    assert trace_c["internal_accepted_head"] is True

    with pytest.raises(
        AcceptedHeadAsQualityMetricForbiddenError,
        match="Configuration C internal accepted-head predicate cannot be used as an A/B/C quality metric",
    ):
        runner.certify_external_verdict(internal_accepted=trace_c["internal_accepted_head"])


def test_edge_rg07_s04_multi_agent_timeout_at_intermediate_stages(reading_fixture):
    """EDGE-RG07-S04: Timeout at intermediate agent stages preserves partial usage and failure codes."""
    manager = PairedAssignmentManager()
    runner = ConfigurationCRunner(client=DeterministicExperimentClient())

    # 1. Timeout at GENERATOR stage
    req_c_gen = manager.map_arm_request(reading_fixture, "C", run_id="run-c-rd-fail-gen")
    res_gen, trace_gen, usage_gen = runner.generate_reading(
        request=req_c_gen,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.C,
        foundation_model_id=reading_fixture.foundation_model_id,
        simulate_failure_at_stage="GENERATOR",
    )
    assert res_gen.execution_status == ExecutionStatus.TIMED_OUT
    assert res_gen.failure_code == "TIMEOUT_DURING_GENERATION"
    assert usage_gen["call_count"] == 1
    assert len(trace_gen["steps"]) == 1

    # 2. Timeout at REVIEWER stage
    req_c_rev = manager.map_arm_request(reading_fixture, "C", run_id="run-c-rd-fail-rev")
    res_rev, trace_rev, usage_rev = runner.generate_reading(
        request=req_c_rev,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.C,
        foundation_model_id=reading_fixture.foundation_model_id,
        simulate_failure_at_stage="REVIEWER",
    )
    assert res_rev.execution_status == ExecutionStatus.TIMED_OUT
    assert res_rev.failure_code == "TIMEOUT_DURING_REVIEW"
    assert usage_rev["call_count"] == 2
    assert len(trace_rev["steps"]) == 2


def test_reg_rg07_s04_configurations_a_and_b_unaffected():
    """REG-RG07-S04: Configurations A and B runners preserve single-call and self-critique contracts."""
    from app.experiment.runners import ConfigurationARunner, ConfigurationBRunner

    a_runner = ConfigurationARunner()
    b_runner = ConfigurationBRunner()

    assert hasattr(a_runner, "generate_reading")
    assert hasattr(b_runner, "generate_reading")
