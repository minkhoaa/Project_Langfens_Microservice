"""Phase-level integration test suite for RG07: Paired configuration A/B/C runners.

Decisive acceptance condition:
Every assigned attempt including failures and partial results is reconciled.

Phase verification:
1. Common neutral input/output and independent evaluator for A direct, B sequential self-review, C multi-agent.
2. Independent evaluator is NOT contaminated by arm labels or internal PASS flags.
3. Total E2E denominator equals frozen assignments; retries linked explicitly without denominator inflation.
4. Usage confidence and failure accounting are truthful across all attempts.
"""

from __future__ import annotations

import json
from pathlib import Path
import jsonschema
import pytest

from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    ExperimentManifest,
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
from app.experiment.ledger import (
    AttemptRecord,
    ExperimentReplayLedger,
    ZeroBilledMissingTelemetryError,
)
from app.experiment.paired import PairedAssignmentManager
from app.experiment.runners import (
    AcceptedHeadAsQualityMetricForbiddenError,
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
    HiddenRepairForbiddenError,
    InternalScoreAsExternalVerdictForbiddenError,
)
from app.persistence.grammar_store import ResearchPublicationForbiddenError
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
def integrated_fixture():
    source = SourceRef(
        source_id="src-natgeo-phase07",
        source_family="national_geographic",
        source_version="2024-v3",
        source_sha256="7" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/aurora-borealis",
    )
    task = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )
    passage = (
        "The aurora borealis is a natural light display in Earth's sky, predominantly seen in high-latitude regions. "
        "Auroras are the result of disturbances in the magnetosphere caused by the solar wind. "
        "These disturbances alter the trajectories of charged particles in the magnetospheric plasma, "
        "precipitating them into the upper atmosphere where ionization and excitation of atmospheric constituents occur. "
        * 10
    )
    return PairedTaskFixture(
        dataset_item_id="item-phase07-aurora-01",
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
def integrated_grammar_fixture():
    source = SourceRef(
        source_id="src-cambridge-phase07",
        source_family="cambridge_advanced",
        source_version="2024-v3",
        source_sha256="8" * 64,
        license="CC-BY-SA-4.0",
        provenance_uri="https://cambridge.org/grammar/c1-inversion-participle",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-c1-inv-part",
        source=source,
        topic="Negative Inversion and Participle Clauses",
        level="C1",
        rule_ids=["rule-c1-inv-part-01"],
        applicability=["Use inversion after negative adverbials (Seldom, Rarely, Never)."],
        exceptions=["Do not invert when the negative word qualifies the subject."],
        examples=["Seldom have I seen such dedication.", "Never had she felt more excited."],
    )
    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="grp-c1-inv-part",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return PairedTaskFixture(
        dataset_item_id="item-phase07-grammar-01",
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


def test_phase_rg07_integrated_paired_abc_execution_and_external_scoring(integrated_fixture):
    """Test full paired A/B/C execution cycle with common inputs and downstream neutral scoring."""
    manager = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()
    schemas = load_schemas()

    # 1. Create and freeze paired assignments
    assignments = manager.create_paired_assignments(integrated_fixture, attempt_number=1)
    assert len(assignments) == 3
    ledger.freeze_assignments(assignments)

    # 2. Map identical requests for all three arms
    req_a = manager.map_arm_request(integrated_fixture, "A", run_id="run-phase-a-01")
    req_b = manager.map_arm_request(integrated_fixture, "B", run_id="run-phase-b-01")
    req_c = manager.map_arm_request(integrated_fixture, "C", run_id="run-phase-c-01")

    # 3. Execute Arm A (Direct Generator)
    runner_a = ConfigurationARunner(client=DeterministicExperimentClient())
    res_a, usage_a = runner_a.generate_reading(
        request=req_a,
        passage_text=integrated_fixture.passage_text,
        prompt_version=integrated_fixture.prompt_versions.A,
        foundation_model_id=integrated_fixture.foundation_model_id,
    )
    assert usage_a["call_count"] == 1
    assert usage_a["repair_count"] == 0
    assert res_a.execution_status == ExecutionStatus.COMPLETED

    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-phase-a-01",
            assignment_id=assignments[0].assignment_id,
            dataset_item_id=integrated_fixture.dataset_item_id,
            configuration_id="A",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=res_a.execution_status,
            output_availability=res_a.output_availability,
            usage_call_count=usage_a["call_count"],
            usage_total_tokens=usage_a["total_tokens"],
            usage_confidence=usage_a["confidence"],
            is_terminal=True,
        )
    )

    # 4. Execute Arm B (Sequential Self-Review)
    runner_b = ConfigurationBRunner(client=DeterministicExperimentClient())
    res_b, trace_b, usage_b = runner_b.generate_reading(
        request=req_b,
        passage_text=integrated_fixture.passage_text,
        prompt_version=integrated_fixture.prompt_versions.B,
        foundation_model_id=integrated_fixture.foundation_model_id,
        max_revisions=1,
    )
    assert usage_b["call_count"] == 3
    assert usage_b["repair_count"] == 1
    assert res_b.execution_status == ExecutionStatus.COMPLETED

    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-phase-b-01",
            assignment_id=assignments[1].assignment_id,
            dataset_item_id=integrated_fixture.dataset_item_id,
            configuration_id="B",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=res_b.execution_status,
            output_availability=res_b.output_availability,
            usage_call_count=usage_b["call_count"],
            usage_total_tokens=usage_b["total_tokens"],
            usage_confidence=usage_b["confidence"],
            is_terminal=True,
        )
    )

    # 5. Execute Arm C (Multi-Agent Runner)
    runner_c = ConfigurationCRunner(client=DeterministicExperimentClient())
    res_c, trace_c, usage_c = runner_c.generate_reading(
        request=req_c,
        passage_text=integrated_fixture.passage_text,
        prompt_version=integrated_fixture.prompt_versions.C,
        foundation_model_id=integrated_fixture.foundation_model_id,
    )
    assert usage_c["call_count"] == 4
    assert res_c.execution_status == ExecutionStatus.COMPLETED

    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-phase-c-01",
            assignment_id=assignments[2].assignment_id,
            dataset_item_id=integrated_fixture.dataset_item_id,
            configuration_id="C",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=res_c.execution_status,
            output_availability=res_c.output_availability,
            usage_call_count=usage_c["call_count"],
            usage_total_tokens=usage_c["total_tokens"],
            usage_confidence=usage_c["confidence"],
            is_terminal=True,
        )
    )

    # 6. Validate all 3 GenerationResults against JSON_SCHEMAS.json
    for r in (res_a, res_b, res_c):
        jsonschema.Draft202012Validator(
            {"$defs": schemas["$defs"], **schemas["$defs"]["GenerationResult"]}
        ).validate(r.model_dump())

    # 7. Evaluate all 3 outputs under independent NeutralEvaluator
    score_a = evaluator.evaluate_item(
        dataset_item_id=integrated_fixture.dataset_item_id,
        passage_text=integrated_fixture.passage_text,
        question_data=res_a.generated_content.questions[0].model_dump(),
    )
    score_b = evaluator.evaluate_item(
        dataset_item_id=integrated_fixture.dataset_item_id,
        passage_text=integrated_fixture.passage_text,
        question_data=res_b.generated_content.questions[0].model_dump(),
    )
    score_c = evaluator.evaluate_item(
        dataset_item_id=integrated_fixture.dataset_item_id,
        passage_text=integrated_fixture.passage_text,
        question_data=res_c.generated_content.questions[0].model_dump(),
    )

    # Invariant: independent scores computed for all 3 arms under same rubric
    assert score_a.dataset_item_id == integrated_fixture.dataset_item_id
    assert score_b.dataset_item_id == integrated_fixture.dataset_item_id
    assert score_c.dataset_item_id == integrated_fixture.dataset_item_id

    # 8. Decisive reconciliation proof: all 3 frozen assignments accounted for
    stats = ledger.get_reconciled_denominators()
    assert stats["total_frozen_assignments"] == 3
    assert stats["arm_denominators"]["A"] == 1
    assert stats["arm_denominators"]["B"] == 1
    assert stats["arm_denominators"]["C"] == 1
    assert stats["by_arm"]["A"]["completed"] == 1
    assert stats["by_arm"]["B"]["completed"] == 1
    assert stats["by_arm"]["C"]["completed"] == 1


def test_phase_rg07_integrated_grammar_abc_execution_and_external_scoring(integrated_grammar_fixture):
    """Test full paired A/B/C execution cycle for Grammar domain with downstream neutral scoring."""
    manager = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()
    schemas = load_schemas()

    assignments = manager.create_paired_assignments(integrated_grammar_fixture, attempt_number=1)
    assert len(assignments) == 3
    ledger.freeze_assignments(assignments)

    req_a = manager.map_arm_request(integrated_grammar_fixture, "A", run_id="run-gr-phase-a")
    req_b = manager.map_arm_request(integrated_grammar_fixture, "B", run_id="run-gr-phase-b")
    req_c = manager.map_arm_request(integrated_grammar_fixture, "C", run_id="run-gr-phase-c")

    runner_a = ConfigurationARunner(client=DeterministicExperimentClient())
    res_a, usage_a = runner_a.generate_grammar(
        request=req_a,
        prompt_version=integrated_grammar_fixture.prompt_versions.A,
        foundation_model_id=integrated_grammar_fixture.foundation_model_id,
    )
    assert usage_a["call_count"] == 1
    assert res_a.execution_status == ExecutionStatus.COMPLETED

    runner_b = ConfigurationBRunner(client=DeterministicExperimentClient())
    res_b, trace_b, usage_b = runner_b.generate_grammar(
        request=req_b,
        prompt_version=integrated_grammar_fixture.prompt_versions.B,
        foundation_model_id=integrated_grammar_fixture.foundation_model_id,
        max_revisions=1,
    )
    assert usage_b["call_count"] == 3
    assert res_b.execution_status == ExecutionStatus.COMPLETED

    runner_c = ConfigurationCRunner(client=DeterministicExperimentClient())
    res_c, trace_c, usage_c = runner_c.generate_grammar(
        request=req_c,
        prompt_version=integrated_grammar_fixture.prompt_versions.C,
        foundation_model_id=integrated_grammar_fixture.foundation_model_id,
    )
    assert usage_c["call_count"] == 4
    assert res_c.execution_status == ExecutionStatus.COMPLETED

    for r in (res_a, res_b, res_c):
        jsonschema.Draft202012Validator(
            {"$defs": schemas["$defs"], **schemas["$defs"]["GenerationResult"]}
        ).validate(r.model_dump())

    # Evaluate all three grammar outputs
    score_a = evaluator.evaluate_item(
        dataset_item_id=integrated_grammar_fixture.dataset_item_id,
        passage_text=f"Rule: {integrated_grammar_fixture.rule_pack.topic}",
        question_data=res_a.generated_content.questions[0].model_dump(),
    )
    score_b = evaluator.evaluate_item(
        dataset_item_id=integrated_grammar_fixture.dataset_item_id,
        passage_text=f"Rule: {integrated_grammar_fixture.rule_pack.topic}",
        question_data=res_b.generated_content.questions[0].model_dump(),
    )
    score_c = evaluator.evaluate_item(
        dataset_item_id=integrated_grammar_fixture.dataset_item_id,
        passage_text=f"Rule: {integrated_grammar_fixture.rule_pack.topic}",
        question_data=res_c.generated_content.questions[0].model_dump(),
    )
    assert score_a.dataset_item_id == integrated_grammar_fixture.dataset_item_id
    assert score_b.dataset_item_id == integrated_grammar_fixture.dataset_item_id
    assert score_c.dataset_item_id == integrated_grammar_fixture.dataset_item_id


def test_phase_rg07_decisive_acceptance_all_failures_reconciled():
    """Prove decisive acceptance condition: every assigned attempt including failures and partials is reconciled."""
    ledger = ExperimentReplayLedger()

    assignments = [
        ExperimentAssignment(
            assignment_id="item-fail-01__arm_A__att1",
            dataset_item_id="item-fail-01",
            configuration_id="A",
            attempt_number=1,
            run_id="run-f-a",
            result_ref=None,
        ),
        ExperimentAssignment(
            assignment_id="item-fail-01__arm_B__att1",
            dataset_item_id="item-fail-01",
            configuration_id="B",
            attempt_number=1,
            run_id="run-f-b",
            result_ref=None,
        ),
        ExperimentAssignment(
            assignment_id="item-fail-01__arm_C__att1",
            dataset_item_id="item-fail-01",
            configuration_id="C",
            attempt_number=1,
            run_id="run-f-c",
            result_ref=None,
        ),
    ]
    ledger.freeze_assignments(assignments)

    # A: Timed out attempt (truthful usage)
    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-fail-a-01",
            assignment_id="item-fail-01__arm_A__att1",
            dataset_item_id="item-fail-01",
            configuration_id="A",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=ExecutionStatus.TIMED_OUT,
            output_availability=OutputAvailability.NONE,
            failure_code="PROVIDER_TIMEOUT",
            usage_call_count=1,
            usage_total_tokens=500,
            usage_confidence="EXACT",
            is_terminal=True,
        )
    )

    # B: Cancelled attempt with UNKNOWN confidence (truthful non-zero/unknown telemetry)
    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-fail-b-01",
            assignment_id="item-fail-01__arm_B__att1",
            dataset_item_id="item-fail-01",
            configuration_id="B",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=ExecutionStatus.CANCELLED,
            output_availability=OutputAvailability.NONE,
            failure_code="REQUEST_CANCELLED",
            usage_call_count=1,
            usage_total_tokens=0,
            usage_confidence="UNKNOWN",
            is_terminal=True,
        )
    )

    # C: Failed validation attempt with partial output
    ledger.record_attempt(
        AttemptRecord(
            attempt_id="att-fail-c-01",
            assignment_id="item-fail-01__arm_C__att1",
            dataset_item_id="item-fail-01",
            configuration_id="C",
            attempt_number=1,
            parent_attempt_id=None,
            execution_status=ExecutionStatus.FAILED_VALIDATION,
            output_availability=OutputAvailability.RAW_ONLY,
            failure_code="UNGROUNDED_PROPOSAL",
            usage_call_count=2,
            usage_total_tokens=1400,
            usage_confidence="EXACT",
            is_terminal=True,
        )
    )

    stats = ledger.get_reconciled_denominators()
    # Decisive condition: Denominator remains 3, none dropped!
    assert stats["total_frozen_assignments"] == 3
    assert stats["by_arm"]["A"]["timed_out"] == 1
    assert stats["by_arm"]["B"]["cancelled"] == 1
    assert stats["by_arm"]["C"]["failed_validation"] == 1


def test_phase_rg07_inviolable_cross_cutting_protections():
    """Prove invariants: research publication forbidden, hidden review forbidden, internal score inflation blocked."""
    runner_a = ConfigurationARunner()
    runner_b = ConfigurationBRunner()
    runner_c = ConfigurationCRunner()
    ledger = ExperimentReplayLedger()

    # 1. No hidden review/repair in Arm A
    with pytest.raises(HiddenRepairForbiddenError):
        runner_a.generate_reading(
            request=StandaloneReadingRequest(
                run_id="run-p-01",
                dataset_item_id="item-p-01",
                configuration_id="A",
                task=ReadingTask(
                    task_type="READING_SINGLE_PASSAGE",
                    requested_groups=[StandaloneGroupType.TFNG],
                    requested_question_count=5,
                    difficulty="C1",
                ),
                source_pack_id="src-01",
            ),
            passage_text="Short passage text for testing...",
            prompt_version="v1",
            foundation_model_id="m1",
            attempt_repair=True,
        )

    # 2. No B internal score as external verdict
    with pytest.raises(InternalScoreAsExternalVerdictForbiddenError):
        runner_b.certify_external_verdict(internal_verdict="PASS", internal_score=4.9)

    # 3. No C accepted-head predicate as external score
    with pytest.raises(AcceptedHeadAsQualityMetricForbiddenError):
        runner_c.certify_external_verdict(internal_accepted=True)

    # 4. No research publication to production
    with pytest.raises(ResearchPublicationForbiddenError):
        ledger.publish_to_production("att-01", "admin-01")
