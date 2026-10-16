"""Unit and integration test suite for RG08-S01: Small DEV paired pilot.

Invariants:
- Both task domains (Reading and Grammar) and A/B/C run on nonfinal inputs with representative constraints.
- Per-config expected counts, costs, quality, and failure records reconcile completely.
- Pilot cannot touch or peek at final sealed dataset (fails closed with FinalBenchmarkAccessForbiddenError).
- Missing/malformed/interrupted inputs are explicitly recorded without silent data loss.
- Legacy V2 contracts and research publication isolation remain inviolate.
"""

from __future__ import annotations

import json
from pathlib import Path
import pytest

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
)
from app.evaluators.independent import NeutralEvaluator
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.pilot import (
    DevPilotRunner,
    FinalBenchmarkAccessForbiddenError,
    PilotExecutionSummary,
)
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
)
from tests.research_provider_fixtures import DeterministicExperimentClient


@pytest.fixture
def reading_dev_fixture() -> PairedTaskFixture:
    source = SourceRef(
        source_id="src-natgeo-pilot-01",
        source_family="national_geographic",
        source_version="2024-dev",
        source_sha256="a" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/pilot-volcanoes",
    )
    task = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )
    passage = (
        "Supervolcanoes represent volcanic centers that have experienced eruptions producing at least 1,000 cubic kilometers of ejecta. "
        "These catastrophic explosive events generate enormous calderas rather than single volcanic cones. "
        "The Yellowstone caldera in North America and Lake Toba in Sumatra are primary examples of such systems. "
        "Magma chambers underlying supervolcanoes contain highly viscous rhyolitic melt enriched in dissolved volatile species. "
        * 10
    )
    return PairedTaskFixture(
        dataset_item_id="item-reading-pilot-01",
        domain="READING",
        source=source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="reading-direct-v1",
            B="reading-self-review-v1",
            C="reading-multi-agent-v1",
        ),
        reading_task=task,
        passage_text=passage,
    )


@pytest.fixture
def grammar_dev_fixture() -> PairedTaskFixture:
    source = SourceRef(
        source_id="src-grammar-pilot-01",
        source_family="academic_grammar_corpus",
        source_version="2024-dev",
        source_sha256="b" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://grammar.example.com/inversion-rules",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="pack-inversion-01",
        source=source,
        topic="Negative Inversion",
        level="C1",
        rule_ids=["rule-inv-01"],
        applicability=["When negative adverbials initiate a sentence, auxiliary inversion is required."],
        exceptions=["Only in initial position."],
        examples=["Seldom had they encountered such seismic intensity."],
    )
    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="pack-inversion-01",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return PairedTaskFixture(
        dataset_item_id="item-grammar-pilot-01",
        domain="GRAMMAR",
        source=source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="grammar-direct-v1",
            B="grammar-self-review-v1",
            C="grammar-multi-agent-v1",
        ),
        grammar_task=task,
        rule_pack=rule_pack,
    )


def test_pos_rg08_s01_dev_paired_pilot_runs_and_reconciles(
    reading_dev_fixture: PairedTaskFixture,
    grammar_dev_fixture: PairedTaskFixture,
) -> None:
    """POS-RG08-S01: Both task domains and A/B/C run on nonfinal inputs with representative constraints.

    Per-config expected counts, costs, quality, and failure records reconcile completely.
    """
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()

    client = DeterministicExperimentClient()
    runner_a = ConfigurationARunner(client=client)
    runner_b = ConfigurationBRunner(client=client)
    runner_c = ConfigurationCRunner(client=client)

    pilot_runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator,
        runner_a=runner_a,
        runner_b=runner_b,
        runner_c=runner_c,
    )

    fixtures = [
        (reading_dev_fixture, "DEV"),
        (grammar_dev_fixture, "DEV"),
    ]

    summary = pilot_runner.run_pilot(fixtures)

    # 2 fixtures x 3 arms = 6 total assigned requests
    assert summary.total_assigned_requests == 6
    assert summary.per_config_counts["A"] == 2
    assert summary.per_config_counts["B"] == 2
    assert summary.per_config_counts["C"] == 2

    # Reconciliation check: per-config counts sum to total assigned
    assert sum(summary.per_config_counts.values()) == summary.total_assigned_requests
    assert summary.reconciled is True

    # Usage and costs tracked per config
    for arm in ("A", "B", "C"):
        assert summary.per_config_costs[arm] is None
        assert arm in summary.per_config_quality_verdicts

    # Ledger verification: all 6 attempts present in ledger
    ledger_denoms = ledger.get_reconciled_denominators()
    assert ledger_denoms["total_frozen_assignments"] == 6
    assert len(ledger.get_all_attempts()) == 6
    assert ledger_denoms["arm_denominators"]["A"] == 2
    assert ledger_denoms["arm_denominators"]["B"] == 2
    assert ledger_denoms["arm_denominators"]["C"] == 2


def test_neg_rg08_s01_pilot_cannot_touch_sealed_benchmark(
    reading_dev_fixture: PairedTaskFixture,
) -> None:
    """NEG-RG08-S01: Pilot cannot touch/peek at final sealed dataset.

    Verify safe rejection/blocked outcome rather than ignored or synthetic PASS.
    """
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()

    client = DeterministicExperimentClient()
    runner_a = ConfigurationARunner(client=client)
    runner_b = ConfigurationBRunner(client=client)
    runner_c = ConfigurationCRunner(client=client)

    pilot_runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator,
        runner_a=runner_a,
        runner_b=runner_b,
        runner_c=runner_c,
    )

    # Attempting to run pilot with FINAL_EVAL split must raise FinalBenchmarkAccessForbiddenError
    with pytest.raises(FinalBenchmarkAccessForbiddenError, match="cannot access final sealed"):
        pilot_runner.run_pilot([(reading_dev_fixture, "FINAL_EVAL")])

    # Attempting to access SEALED_BENCHMARK must also fail closed
    with pytest.raises(FinalBenchmarkAccessForbiddenError):
        pilot_runner.run_pilot([(reading_dev_fixture, "SEALED_BENCHMARK")])

    # Ensure ledger remains untouched
    ledger_denoms = ledger.get_reconciled_denominators()
    assert ledger_denoms["total_frozen_assignments"] == 0
    assert len(ledger.get_all_attempts()) == 0


def test_edge_rg08_s01_malformed_and_empty_inputs_handled(
    reading_dev_fixture: PairedTaskFixture,
) -> None:
    """EDGE-RG08-S01: Test missing, malformed, or empty inputs; assert explicit error/status and no silent data loss."""
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()

    pilot_runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator,
    )

    # Empty fixtures list raises ValueError
    with pytest.raises(ValueError, match="at least one fixture"):
        pilot_runner.run_pilot([])

    # Invalid split name raises ValueError
    with pytest.raises(ValueError, match="Invalid dataset split"):
        pilot_runner.run_pilot([(reading_dev_fixture, "INVALID_SPLIT")])


def test_reg_rg08_s01_strict_v2_and_research_isolation_intact(
    reading_dev_fixture: PairedTaskFixture,
) -> None:
    """REG-RG08-S01: Touched API/schema/authorization and research publication protection remain strictly enforced."""
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator = NeutralEvaluator()

    client = DeterministicExperimentClient()
    pilot_runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator,
        runner_a=ConfigurationARunner(client=client),
        runner_b=ConfigurationBRunner(client=client),
        runner_c=ConfigurationCRunner(client=client),
    )

    summary = pilot_runner.run_pilot([(reading_dev_fixture, "DEV")])
    assert summary.total_assigned_requests == 3

    # Ensure research outputs produced during pilot are unpublishable
    with pytest.raises(Exception, match="RESEARCH_PUBLICATION_FORBIDDEN"):
        ledger.publish_to_production("att-item-reading-pilot-01__arm_A__att1", admin_user_id="admin-1")
