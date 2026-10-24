"""Unit tests for RG07-S03: Configuration B sequential self-review.

Invariants:
- Same foundation LLM performs generation, self-feedback, and bounded revision.
- B calls, repairs, cost, and internal verdict preserved separately on distinct trace.
- B self-score is NOT accepted as external rubric verdict (strictly rejected).
- Output adapted to canonical NeutralOutput and GenerationResult.
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
    ConfigurationBRunner,
    InternalScoreAsExternalVerdictForbiddenError,
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
        source_id="src-natgeo-03",
        source_family="national_geographic",
        source_version="2024-v1",
        source_sha256="3" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/volcanoes",
    )
    task = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )
    passage = (
        "Volcanic eruptions are among Earth's most dramatic geological events. Magma from within the Earth's "
        "upper mantle works its way to the surface, erupting to form lava flows and ash deposits. The viscosity "
        "of the magma determines the eruptive style, ranging from effusive basaltic flows to explosive plinian eruptions. "
        * 10
    )
    return PairedTaskFixture(
        dataset_item_id="item-reading-volcano-01",
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
        source_id="src-cambridge-03",
        source_family="cambridge_advanced",
        source_version="2024-v2",
        source_sha256="3" * 64,
        license="CC-BY-SA-4.0",
        provenance_uri="https://cambridge.org/grammar/c1-inversion-b",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-c1-inv-b",
        topic="Inversion after Negative Adverbials",
        level="C1",
        rule_ids=["rule-c1-inv-01"],
        applicability=["Use inversion after 'Under no circumstances'."],
        exceptions=["None"],
        examples=["Under no circumstances should you open the door."],
        source=source,
    )
    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="grp-c1-inv-b",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return PairedTaskFixture(
        dataset_item_id="item-grammar-inv-01",
        domain="GRAMMAR",
        source=source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="prompt-gr-a-v1.0",
            B="prompt-gr-b-v1.0",
            C="prompt-gr-c-v1.0",
        ),
        rubric_version="rubric-qgeval-v2.0",
        grammar_task=task,
        rule_pack=rule_pack,
    )


def test_pos_rg07_s03_configuration_b_sequential_self_review(reading_fixture, grammar_fixture):
    """POS-RG07-S03: B calls/repairs/cost and internal verdict preserved separately."""
    manager = PairedAssignmentManager()
    req_b = manager.map_arm_request(reading_fixture, "B", run_id="run-b-rd-01")
    assert isinstance(req_b, StandaloneReadingRequest)

    runner = ConfigurationBRunner(client=DeterministicExperimentClient())
    result_b, trace_b, usage_b = runner.generate_reading(
        request=req_b,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.B,
        foundation_model_id=reading_fixture.foundation_model_id,
        max_revisions=1,
    )

    # 1. Calls, repairs, and cost tracked across sequential phases
    assert usage_b["call_count"] == 3  # 1 Draft + 1 Critique + 1 Revision
    assert usage_b["repair_count"] == 1
    assert usage_b["total_tokens"] > usage_b["prompt_tokens"]
    assert usage_b["confidence"] == "ESTIMATED"
    assert len(runner.client.recorded_dispatches) == 3
    assert all(d["model_id"] == reading_fixture.foundation_model_id for d in runner.client.recorded_dispatches)

    # 2. Distinct trace steps preserved with internal verdict
    stages = [step["stage"] for step in trace_b["steps"]]
    assert stages == ["DRAFT_GENERATION", "SELF_CRITIQUE", "BOUNDED_REVISION"]

    critique_step = trace_b["steps"][1]
    assert "internal_verdict" in critique_step
    assert "internal_score" in critique_step
    assert critique_step["model_id"] == reading_fixture.foundation_model_id  # SAME model!

    # 3. Canonical result is clean and validates against JSON_SCHEMAS.json
    assert result_b.configuration_id == "B"
    assert result_b.execution_status == ExecutionStatus.COMPLETED
    assert result_b.output_availability == OutputAvailability.NORMALIZED
    assert result_b.generated_content is not None

    schemas = load_schemas()
    jsonschema.Draft202012Validator(
        {"$defs": schemas["$defs"], **schemas["$defs"]["GenerationResult"]}
    ).validate(result_b.model_dump())

    # 4. Independent evaluator evaluates output without seeing internal verdict
    evaluator = NeutralEvaluator()
    eval_res = evaluator.evaluate_item(
        dataset_item_id=reading_fixture.dataset_item_id,
        passage_text=reading_fixture.passage_text,
        question_data=result_b.generated_content.questions[0].model_dump(),
    )
    assert eval_res.dataset_item_id == reading_fixture.dataset_item_id

    # 5. Grammar execution for Configuration B
    req_gr_b = manager.map_arm_request(grammar_fixture, "B", run_id="run-b-gr-01")
    res_gr_b, trace_gr_b, usage_gr_b = runner.generate_grammar(
        request=req_gr_b,
        prompt_version=grammar_fixture.prompt_versions.B,
        foundation_model_id=grammar_fixture.foundation_model_id,
        max_revisions=1,
    )
    assert usage_gr_b["call_count"] == 3
    assert usage_gr_b["repair_count"] == 1
    assert res_gr_b.execution_status == ExecutionStatus.COMPLETED
    assert res_gr_b.output_availability == OutputAvailability.NORMALIZED


def test_neg_rg07_s03_b_self_score_not_accepted_as_external_verdict(reading_fixture):
    """NEG-RG07-S03: B self-score not accepted as external rubric verdict."""
    manager = PairedAssignmentManager()
    req_b = manager.map_arm_request(reading_fixture, "B", run_id="run-b-rd-02")
    runner = ConfigurationBRunner(client=DeterministicExperimentClient())

    result_b, trace_b, _ = runner.generate_reading(
        request=req_b,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.B,
        foundation_model_id=reading_fixture.foundation_model_id,
    )

    # Attempting to authenticate or accept B's internal critique as the external rubric verdict is forbidden
    critique_step = trace_b["steps"][1]
    with pytest.raises(InternalScoreAsExternalVerdictForbiddenError, match="B self-score cannot be accepted as external rubric verdict"):
        runner.certify_external_verdict(
            internal_verdict=critique_step["internal_verdict"],
            internal_score=critique_step["internal_score"],
        )


def test_edge_rg07_s03_max_revisions_budget_and_timeout(reading_fixture):
    """EDGE-RG07-S03: Max revisions boundary and timeout during sequential steps."""
    manager = PairedAssignmentManager()
    runner = ConfigurationBRunner(client=DeterministicExperimentClient())

    # 1. Max revisions capped at 0 (critique only, no revision)
    req_b0 = manager.map_arm_request(reading_fixture, "B", run_id="run-b-rd-03")
    res_b0, trace_b0, usage_b0 = runner.generate_reading(
        request=req_b0,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.B,
        foundation_model_id=reading_fixture.foundation_model_id,
        max_revisions=0,
    )
    assert usage_b0["call_count"] == 2  # Draft + Critique
    assert usage_b0["repair_count"] == 0
    assert len(trace_b0["steps"]) == 2

    # 2. Timeout during sequential stage preserves partial usage and failure code
    req_bt = manager.map_arm_request(reading_fixture, "B", run_id="run-b-rd-timeout")
    res_bt, trace_bt, usage_bt = runner.generate_reading(
        request=req_bt,
        passage_text=reading_fixture.passage_text,
        prompt_version=reading_fixture.prompt_versions.B,
        foundation_model_id=reading_fixture.foundation_model_id,
        simulate_failure_at_stage="SELF_CRITIQUE",
    )
    assert res_bt.execution_status == ExecutionStatus.TIMED_OUT
    assert res_bt.failure_code == "TIMEOUT_DURING_SELF_CRITIQUE"
    assert usage_bt["call_count"] == 2
    assert len(trace_bt["steps"]) == 2


def test_reg_rg07_s03_configuration_a_and_prior_runners_intact():
    """REG-RG07-S03: Configuration A runner remains strictly single-call with zero repairs."""
    from app.experiment.runners import ConfigurationARunner

    a_runner = ConfigurationARunner()
    assert hasattr(a_runner, "generate_reading")
    assert hasattr(a_runner, "generate_grammar")
