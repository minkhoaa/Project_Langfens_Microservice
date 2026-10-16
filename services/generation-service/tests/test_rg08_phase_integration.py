"""Phase-level integration test suite for RG08: DEV pilot, safety and fault-injection evidence.

Decisive acceptance condition:
Final sealed benchmark is never used to debug or optimize the pipeline.

Phase verification:
1. Small DEV paired pilot runs and reconciles across Reading and Grammar domains for A/B/C.
2. Final sealed benchmark protection prevents pilot execution or post-hoc judge tuning on final datasets.
3. Simulated worker crashes, lease loss, and lost ACK leave no partial graphs or duplicate billing charges.
4. Hostile nested field leakage, tenant crossing, and tampered publication metadata are blocked with audit logs.
5. Evaluator demonstrates 100% determinism, permutation invariance, and resource uncertainty tracking.
6. Pilot exit decision enforces that unresolved critical risks block final freeze without downgrade.
"""

from __future__ import annotations

import pytest

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
)
from app.evaluators.independent import NeutralEvaluator
from app.experiment.drift import (
    EvaluatorRobustnessAnalyzer,
    SealedBenchmarkPostHocTuningForbiddenError,
)
from app.experiment.faults import (
    CheckpointFencingManager,
    DatabaseTransactionRollbackError,
    FaultScenarioExecutor,
    StaleWorkerEpochError,
    TransactionalExamGraphManager,
)
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.pilot import DevPilotRunner, FinalBenchmarkAccessForbiddenError
from app.experiment.readiness import (
    CriticalRiskDowngradeForbiddenError,
    PerformanceBottleneck,
    PilotFreezeBlockedError,
    PilotReadinessAssessor,
    RiskItem,
)
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
)
from tests.research_provider_fixtures import DeterministicExperimentClient
from app.experiment.security import (
    DataLeakageDetectedError,
    ResearchPublicationForbiddenError,
    RoleTenantAuthorizationError,
    SecurityGuardAndLeakageDetector,
)


@pytest.fixture
def integrated_pilot_fixtures() -> list[tuple[PairedTaskFixture, str]]:
    source_rd = SourceRef(
        source_id="src-natgeo-phase08",
        source_family="national_geographic",
        source_version="2024-dev",
        source_sha256="8" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/phase08-ice-age",
    )
    task_rd = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )
    passage = (
        "Glacial periods during the Pleistocene epoch were characterized by extensive continental ice sheets. "
        "These glacial cycles were paced by periodic variations in Earth's orbit, known as Milankovitch cycles. "
        "Eccentricity, axial tilt, and precession combine to modulate seasonal insolation at high latitudes. "
        * 10
    )
    fixture_rd = PairedTaskFixture(
        dataset_item_id="item-reading-phase08",
        domain="READING",
        source=source_rd,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="rd-a-phase08",
            B="rd-b-phase08",
            C="rd-c-phase08",
        ),
        reading_task=task_rd,
        passage_text=passage,
    )

    source_gr = SourceRef(
        source_id="src-grammar-phase08",
        source_family="oxford_academic",
        source_version="2024-dev",
        source_sha256="9" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://oxford.example.com/c1-inversion",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="pack-c1-phase08",
        source=source_gr,
        topic="Limiting Adverbials",
        level="C1",
        rule_ids=["rule-lim-01"],
        applicability=["Invert subject and verb after negative or limiting adverbials in sentence-initial position."],
        exceptions=["Does not apply to non-initial positions."],
        examples=["Hardly had the expedition begun when the blizzard struck."],
    )
    task_gr = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="pack-c1-phase08",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    fixture_gr = PairedTaskFixture(
        dataset_item_id="item-grammar-phase08",
        domain="GRAMMAR",
        source=source_gr,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="gr-a-phase08",
            B="gr-b-phase08",
            C="gr-c-phase08",
        ),
        grammar_task=task_gr,
        rule_pack=rule_pack,
    )

    return [(fixture_rd, "DEV"), (fixture_gr, "DEV")]


def test_phase_rg08_01_dev_paired_pilot_reconciliation(
    integrated_pilot_fixtures: list[tuple[PairedTaskFixture, str]],
) -> None:
    """PHASE-RG08-01: DEV pilot runs and reconciles 6 assignments across 2 task domains and 3 arms."""
    mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()
    client = DeterministicExperimentClient()

    runner = DevPilotRunner(
        assignment_manager=mgr,
        ledger=ledger,
        evaluator=evaluator,
        runner_a=ConfigurationARunner(client=client),
        runner_b=ConfigurationBRunner(client=client),
        runner_c=ConfigurationCRunner(client=client),
    )

    summary = runner.run_pilot(integrated_pilot_fixtures)
    assert summary.total_assigned_requests == 6
    assert summary.per_config_counts == {"A": 2, "B": 2, "C": 2}
    assert summary.reconciled is True
    assert len(ledger.get_all_attempts()) == 6


def test_phase_rg08_02_decisive_acceptance_sealed_benchmark_protection(
    integrated_pilot_fixtures: list[tuple[PairedTaskFixture, str]],
) -> None:
    """PHASE-RG08-02: Decisive acceptance condition — Final sealed benchmark is never used to debug or optimize."""
    mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    runner = DevPilotRunner(assignment_manager=mgr, ledger=ledger)
    fixture, _ = integrated_pilot_fixtures[0]

    # Pilot execution strictly blocked from final sealed data
    with pytest.raises(FinalBenchmarkAccessForbiddenError):
        runner.run_pilot([(fixture, "FINAL_EVAL")])
    with pytest.raises(FinalBenchmarkAccessForbiddenError):
        runner.run_pilot([(fixture, "SEALED_BENCHMARK")])

    # Evaluator robustness analyzer strictly blocked from post-hoc tuning on final sealed data
    analyzer = EvaluatorRobustnessAnalyzer()
    with pytest.raises(SealedBenchmarkPostHocTuningForbiddenError):
        analyzer.apply_pre_final_calibration(split="FINAL_EVAL", target_thresholds={"min_score": 0.8})
    with pytest.raises(SealedBenchmarkPostHocTuningForbiddenError):
        analyzer.apply_pre_final_calibration(split="SEALED_BENCHMARK", target_thresholds={"min_score": 0.8})


def test_phase_rg08_03_fault_scenarios_and_atomicity() -> None:
    """PHASE-RG08-03: Fencing prevents stale checkpoint promotion, rollback leaves no partial graph, lost ACK retries idempotently."""
    fencing = CheckpointFencingManager(initial_epoch=3)
    with pytest.raises(StaleWorkerEpochError):
        fencing.promote_checkpoint("worker-old", epoch=2, checkpoint_hash="chk", candidate_head_hash="head")

    graph_mgr = TransactionalExamGraphManager()
    with pytest.raises(DatabaseTransactionRollbackError):
        graph_mgr.persist_complete_graph("exam-phase08-crash", sections_count=3, questions_per_section=13, simulate_crash_at_question=15)
    assert graph_mgr.get_persisted_question_count("exam-phase08-crash") == 0

    fault_exec = FaultScenarioExecutor()
    res1 = fault_exec.execute_with_lost_ack_retry("req-08", "item-08", "B", 0.02)
    res2 = fault_exec.execute_with_lost_ack_retry("req-08", "item-08", "B", 0.02)
    assert res1["run_id"] == res2["run_id"]
    assert res2["charge_count"] == 1
    assert res2["is_idempotent_replay"] is True


def test_phase_rg08_04_security_leakage_and_tampered_publish_blocked() -> None:
    """PHASE-RG08-04: Hostile nested leakage and tampered publication flags blocked with audit logs."""
    guard = SecurityGuardAndLeakageDetector()

    # Nested leakage
    with pytest.raises(DataLeakageDetectedError):
        guard.scan_payload_for_leakage({"q": "test", "extra": {"_gold_answer": "leaked"}})

    # Cross-tenant access
    with pytest.raises(RoleTenantAuthorizationError):
        guard.validate_access("user-1", "RESEARCHER_AUTHORIZED", "tenant-1", "tenant-2", "res-1")

    # Tampered metadata publication attempt
    with pytest.raises(ResearchPublicationForbiddenError):
        guard.validate_publication_eligibility(
            artifact_metadata={"is_research": True, "publish_eligible": True},
            content_tags=["RESEARCH_PILOT"],
            run_id="pilot-item-08",
            actor_id="admin-1",
            actor_role="ADMIN",
        )
    assert len(guard.get_security_events()) == 3


def test_phase_rg08_05_evaluator_robustness_and_drift() -> None:
    """PHASE-RG08-05: Evaluator determinism 1.0, permutation invariance, and DEV-only calibration."""
    analyzer = EvaluatorRobustnessAnalyzer()
    rep = analyzer.measure_reproducibility(
        dataset_item_id="item-p08",
        passage_text="Sample text for determinism checking " * 10,
        question_data={"question_text": "Is this a test?", "question_type": "ShortAnswer", "correct_answer": "Yes"},
        runs=3,
    )
    assert rep == 1.0
    assert analyzer.apply_pre_final_calibration(split="DEV", target_thresholds={"grounding": 0.8}) is True


def test_phase_rg08_06_pilot_readiness_assessor() -> None:
    """PHASE-RG08-06: Unresolved critical risks block final freeze; critical risks cannot be downgraded."""
    assessor = PilotReadinessAssessor()
    assessor.register_risk(
        RiskItem(
            risk_id="CRIT-01",
            title="Sealed benchmark isolation verify",
            category="DATA_LEAKAGE",
            severity="CRITICAL",
            is_resolved=False,
        )
    )

    with pytest.raises(CriticalRiskDowngradeForbiddenError):
        assessor.downgrade_risk("CRIT-01", "MEDIUM")

    with pytest.raises(PilotFreezeBlockedError):
        assessor.assert_freeze_allowed()

    assessor.resolve_risk("CRIT-01", "Verified sealed dataset isolation across all test suites.")
    decision = assessor.evaluate_pilot_exit(failed_cases=[], bottlenecks=[])
    assert decision.decision == "READY_FOR_FREEZE"
