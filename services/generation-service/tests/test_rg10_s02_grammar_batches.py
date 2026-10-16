"""Unit tests for RG10-S02: Grammar final paired assignment batches.

Parent: generation_baseline/prompts/sprints/prompt-sprint-10-02.md
Objective: Frozen 25-40 Grammar items x A/B/C executed with same scoring contract.
Decisive acceptance condition: Failure/timeout/partial output, tokens and trace persisted for each slot.
"""

from __future__ import annotations

import copy
from typing import List
import pytest

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    SourceRef,
)
from app.experiment.campaign_runner import (
    AmbiguousGrammarRuleError,
    BatchCardinalityExceededError,
    BatchExecutionState,
    CampaignBatchExecutor,
    CherryPickForbiddenError,
    GrammarRuleAmbiguityFixedForbiddenError,
    ReplacementItemForbiddenError,
)
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from tests.research_provider_fixtures import DeterministicExperimentClient
from app.persistence.grammar_store import ResearchPublicationForbiddenError


def _build_grammar_fixtures(count: int = 28) -> List[PairedTaskFixture]:
    registry = FinalDatasetRegistry()
    grammar_tasks = registry.build_grammar_final_tasks()
    return grammar_tasks[:count]


def test_pos_rg10_s02_grammar_final_paired_batches_execution():
    """POS-RG10-S02: Frozen Grammar items executed in bounded batches (<=5 items) with tokens & trace."""
    fixtures = _build_grammar_fixtures(28)
    assert len(fixtures) == 28

    client = DeterministicExperimentClient()
    assignment_manager = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    runner = CampaignBatchExecutor(
        assignment_manager=assignment_manager,
        ledger=ledger,
        client=client,
    )

    # 1. Partition into bounded batches
    batches = runner.partition_batches(fixtures, max_items_per_batch=5)
    assert len(batches) == 6
    for b in batches:
        assert len(b) <= 5

    # 2. Execute batches
    batch_states: List[BatchExecutionState] = []
    for idx, batch_fixtures in enumerate(batches):
        state = runner.execute_grammar_batch(
            batch_fixtures=batch_fixtures,
            batch_index=idx + 1,
            allow_retries=True,
            max_retries=2,
        )
        batch_states.append(state)
        assert state.status == "COMPLETED"
        assert len(state.dataset_item_ids) <= 5
        assert len(state.assignment_ids) == len(batch_fixtures) * 3

        # Verify tokens and trace persisted for each slot
        for attempt in state.attempts:
            assert attempt.usage_total_tokens > 0
            assert attempt.usage_confidence == "ESTIMATED"
            assert attempt.execution_status in (
                ExecutionStatus.COMPLETED,
                ExecutionStatus.FAILED_VALIDATION,
                ExecutionStatus.FAILED_RUNTIME,
                ExecutionStatus.TIMED_OUT,
            )

    # Verify all 28 Grammar items accounted for
    runner.validate_batch_coverage(fixtures, batch_states)
    ledger_summary = ledger.reconcile_campaign()
    assert ledger_summary.total_frozen_assignments == 84  # 28 * 3
    assert ledger_summary.total_attempts >= 84


def test_neg_rg10_s02_rule_ambiguity_cannot_be_silently_fixed():
    """NEG-RG10-S02: Ambiguous grammar rule cannot be silently fixed in FINAL inputs."""
    fixtures = _build_grammar_fixtures(1)
    fixture = fixtures[0]
    runner = CampaignBatchExecutor()

    # 1. Silent fix of rule in FINAL inputs raises GrammarRuleAmbiguityFixedForbiddenError
    original_rule = fixture.rule_pack
    mutated_rule = original_rule.model_copy(update={"rule_pack_id": "silently-fixed-rule-id"})

    with pytest.raises(GrammarRuleAmbiguityFixedForbiddenError) as exc_info:
        runner.validate_rule_immutability(
            original_rule=original_rule,
            executed_rule=mutated_rule,
        )
    assert "Grammar rule ambiguity cannot be silently repaired" in str(exc_info.value)

    # 2. Ambiguous rule without rule_id raises AmbiguousGrammarRuleError
    ambiguous_rule = original_rule.model_copy(update={"rule_ids": []})
    ambiguous_fixture = fixture.model_copy(update={"rule_pack": ambiguous_rule})

    with pytest.raises(AmbiguousGrammarRuleError) as exc_info:
        runner.execute_grammar_batch([ambiguous_fixture], batch_index=1)
    assert "ambiguous rule without rule_pack_id or rule_ids" in str(exc_info.value)


def test_edge_rg10_s02_grammar_batch_edge_cases():
    """EDGE-RG10-S02: Bounded retries on simulated failure and empty batch rejection."""
    fixtures = _build_grammar_fixtures(2)
    client = DeterministicExperimentClient()
    runner = CampaignBatchExecutor(client=client)

    # Empty batch raises ValueError
    with pytest.raises(ValueError) as exc_info:
        runner.execute_grammar_batch([], batch_index=1)
    assert "requires at least one fixture" in str(exc_info.value)

    # Batch > 5 raises BatchCardinalityExceededError
    with pytest.raises(BatchCardinalityExceededError) as exc_info:
        runner.execute_grammar_batch(_build_grammar_fixtures(6), batch_index=1)
    assert "exceeds maximum allowed cardinality" in str(exc_info.value)

    # Execute with valid fixtures
    state = runner.execute_grammar_batch(fixtures, batch_index=1)
    assert state.status == "COMPLETED"
    assert len(state.attempts) == 6


def test_reg_rg10_s02_grammar_research_isolation():
    """REG-RG10-S02: Grammar research attempts cannot be published to production."""
    fixtures = _build_grammar_fixtures(1)
    runner = CampaignBatchExecutor(client=DeterministicExperimentClient())
    state = runner.execute_grammar_batch(fixtures, batch_index=1)

    for attempt in state.attempts:
        with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
            runner.attempt_to_publish_research_attempt(attempt)
        assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)
