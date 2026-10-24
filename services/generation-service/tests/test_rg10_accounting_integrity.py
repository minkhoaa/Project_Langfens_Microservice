"""Behavioral regressions for honest RG10 attempt and output accounting."""
from __future__ import annotations

import pytest

from app.contracts.research import (
    ExecutionStatus, ExperimentAssignment, GenerationResult, OutputAvailability,
)
from app.experiment.campaign_runner import CampaignBatchExecutor, CampaignReconciliationManager
from app.experiment.final_dataset import FinalDatasetRegistry
from app.experiment.ledger import AttemptRecord, ExperimentReplayLedger


def assignment(arm="A"):
    return ExperimentAssignment(assignment_id=f"item-{arm}", dataset_item_id="item", configuration_id=arm)


def attempt(asg, **changes):
    values = dict(attempt_id=f"att-{asg.assignment_id}", assignment_id=asg.assignment_id,
                  dataset_item_id=asg.dataset_item_id, configuration_id=asg.configuration_id,
                  execution_status=ExecutionStatus.FAILED_RUNTIME, output_availability=OutputAvailability.NONE)
    return AttemptRecord(**{**values, **changes})


def test_missing_telemetry_stays_unknown_in_attempt_and_report():
    ledger = ExperimentReplayLedger()
    asg = assignment()
    ledger.freeze_assignments([asg])
    att = attempt(asg)
    assert att.usage_total_tokens is None
    assert att.cost_usd is None
    assert att.usage_confidence == "UNKNOWN"
    ledger.record_attempt(att)
    report = CampaignReconciliationManager().reconcile_campaign_completeness(ledger)
    assert report.token_usage_by_arm["A"]["total"] is None
    assert report.cost_by_arm["A"] is None


@pytest.mark.parametrize("changes", [
    {"assignment_id": "unassigned"}, {"dataset_item_id": "wrong"}, {"configuration_id": "B"},
])
def test_attempt_cannot_escape_frozen_assignment(changes):
    ledger = ExperimentReplayLedger()
    asg = assignment()
    ledger.freeze_assignments([asg])
    with pytest.raises(ValueError):
        ledger.record_attempt(attempt(asg, **changes))


def test_retry_cannot_link_another_assignment_or_branch():
    ledger = ExperimentReplayLedger()
    a, b = assignment(), assignment("B")
    ledger.freeze_assignments([a, b])
    first = attempt(a, is_terminal=False)
    ledger.record_attempt(first)
    with pytest.raises(ValueError):
        ledger.record_attempt(attempt(b, attempt_number=2, parent_attempt_id=first.attempt_id))
    second = attempt(a, attempt_id="second", attempt_number=2, parent_attempt_id=first.attempt_id)
    ledger.record_attempt(second)
    with pytest.raises(ValueError):
        ledger.record_attempt(attempt(a, attempt_id="branch", attempt_number=2, parent_attempt_id=first.attempt_id))


def test_unknown_cost_is_not_derived_using_unfrozen_prices():
    executor = CampaignBatchExecutor()
    assert executor._extract_cost_usd({"prompt_tokens": 123, "completion_tokens": 456}) is None
    assert executor._extract_cost_usd({"cost_usd": 0.0}) == 0.0


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_failed_retries_retain_output_state_and_stop_at_bound(domain):
    registry = FinalDatasetRegistry()
    fixtures = (registry.build_reading_final_tasks() if domain == "READING"
                else registry.build_grammar_final_tasks())[:1]
    executor = CampaignBatchExecutor()
    calls = []
    def fail(**kwargs):
        req = kwargs["req"]
        calls.append(req.configuration_id)
        return GenerationResult(run_id=req.run_id, dataset_item_id=req.dataset_item_id,
                                configuration_id=req.configuration_id, task_type=req.task.task_type,
                                execution_status=ExecutionStatus.FAILED_RUNTIME,
                                output_availability=OutputAvailability.RAW_ONLY,
                                failure_code="PROVIDER_ERROR"), {"call_count": 1, "confidence": "UNKNOWN"}
    setattr(executor, "_dispatch_reading_arm" if domain == "READING" else "_dispatch_grammar_arm", fail)
    execute = executor.execute_reading_batch if domain == "READING" else executor.execute_grammar_batch
    state = execute(fixtures, batch_index=1, max_retries=1)
    assert calls == ["A", "A", "B", "B", "C", "C"]
    assert state.status == "FAILED"
    assert len(state.attempts) == 6
    for arm in ("A", "B", "C"):
        lineage = [att for att in state.attempts if att.configuration_id == arm]
        assert lineage[1].parent_attempt_id == lineage[0].attempt_id
        assert lineage[1].output_availability == OutputAvailability.RAW_ONLY
        assert lineage[1].failure_code == "PROVIDER_ERROR"
        assert lineage[1].is_terminal
        assert lineage[1].cost_usd is None
    assert state.usage_summary["total_tokens"] is None
    before = len(calls)
    resumed = execute(fixtures, batch_index=1, resume_state=state, max_retries=1)
    assert len(calls) == before
    assert resumed.attempts == state.attempts


def test_interrupted_dispatch_records_started_and_unattempted_slots():
    fixtures = FinalDatasetRegistry().build_reading_final_tasks()[:2]
    executor = CampaignBatchExecutor()
    def interrupt(**kwargs):
        raise KeyboardInterrupt()
    executor._dispatch_reading_arm = interrupt
    with pytest.raises(KeyboardInterrupt):
        executor.execute_reading_batch(fixtures, batch_index=1)
    report = CampaignReconciliationManager().reconcile_campaign_completeness(executor.ledger)
    assert report.total_frozen_assignments == 6
    assert report.started_attempt_count == 1
    assert report.in_progress_count == 1
    assert report.unattempted_count == 5
    assert report.total_reconciled == 6


def test_terminal_runtime_exception_is_archived_not_raised_or_zero_billed():
    fixtures = FinalDatasetRegistry().build_reading_final_tasks()[:1]
    executor = CampaignBatchExecutor()
    def fail(**kwargs):
        raise ConnectionError("private-provider-context")
    executor._dispatch_reading_arm = fail
    state = executor.execute_reading_batch(fixtures, batch_index=1, max_retries=0)
    assert state.status == "FAILED"
    assert len(state.attempts) == 3
    assert all(att.is_terminal and att.cost_usd is None for att in state.attempts)
    assert all(att.failure_code == "PROVIDER_RUNTIME_ERROR" for att in state.attempts)
    assert all(att.usage_call_count == 0 for att in state.attempts)
    assert "private-provider-context" not in state.model_dump_json()


def test_snapshot_hash_binds_all_attempt_telemetry_and_assignments():
    from app.experiment.campaign_runner import FinalResearchSnapshotSealer
    a = assignment()
    ledger = ExperimentReplayLedger()
    ledger.freeze_assignments([a])
    ledger.record_attempt(attempt(a, usage_total_tokens=50, usage_confidence="ESTIMATED"))
    before = FinalResearchSnapshotSealer().compute_results_ledger_hash(ledger)
    other = ExperimentReplayLedger()
    other.freeze_assignments([a])
    other.record_attempt(attempt(a, usage_total_tokens=50, usage_confidence="UNKNOWN"))
    assert FinalResearchSnapshotSealer().compute_results_ledger_hash(other) != before


def test_pilot_consumer_preserves_missing_telemetry():
    from app.experiment.paired import PairedAssignmentManager
    from app.experiment.pilot import DevPilotRunner
    fixture = FinalDatasetRegistry().build_reading_final_tasks()[0]
    class EmptyRunner:
        def generate_reading(self, req, *args):
            result = GenerationResult(
                run_id=req.run_id, dataset_item_id=req.dataset_item_id, configuration_id=req.configuration_id,
                task_type=req.task.task_type, execution_status=ExecutionStatus.FAILED_RUNTIME,
                output_availability=OutputAvailability.NONE)
            usage = {"cost_usd": None, "total_tokens": None, "confidence": "UNKNOWN"}
            return (result, usage) if req.configuration_id == "A" else (result, {}, usage)
    runner = EmptyRunner()
    pilot = DevPilotRunner(PairedAssignmentManager(), ExperimentReplayLedger(),
                           runner_a=runner, runner_b=runner, runner_c=runner)
    summary = pilot.run_pilot([(fixture, "DEV")])
    assert summary.per_config_costs == {"A": None, "B": None, "C": None}
    assert all(att.cost_usd is None and att.usage_total_tokens is None for att in pilot.ledger.get_all_attempts())


def test_resume_rejects_changed_prompt_model_or_source_before_dispatch():
    fixture = FinalDatasetRegistry().build_reading_final_tasks()[0]
    executor = CampaignBatchExecutor()
    state = executor.execute_reading_batch([fixture], batch_index=1, max_retries=0)
    changed = fixture.model_copy(update={"foundation_model_id": "different-model"})
    with pytest.raises(ValueError):
        executor.execute_reading_batch([changed], batch_index=1, resume_state=state)
    with pytest.raises(ValueError):
        executor.execute_reading_batch([changed], batch_index=1)


def test_recorded_outputs_are_copies_and_cannot_be_replaced():
    from app.contracts.research import NeutralOutput, NeutralQuestion
    ledger = ExperimentReplayLedger()
    asg = assignment()
    ledger.freeze_assignments([asg])
    att = attempt(asg, execution_status=ExecutionStatus.FAILED_VALIDATION,
                  output_availability=OutputAvailability.PARSEABLE)
    ledger.record_attempt(att)
    output = GenerationResult(
        run_id="run", dataset_item_id="item", configuration_id="A", task_type="READING_SINGLE_PASSAGE",
        execution_status=att.execution_status, output_availability=att.output_availability,
        generated_content=NeutralOutput(context_text="Context.", question_groups=[], questions=[
            NeutralQuestion(question_id="q", question_type="TFNG", text="Question?", instructions="Select TRUE, FALSE, or NOT GIVEN.")
        ]))
    ledger.record_output(att.attempt_id, output)
    output.generated_content.questions[0].text = "Tampered caller object"
    assert ledger.get_output(att.attempt_id).generated_content.questions[0].text == "Question?"
    with pytest.raises(RuntimeError):
        ledger.record_output(att.attempt_id, output)
    report = CampaignReconciliationManager().reconcile_campaign_completeness(ledger)
    assert report.generated_output_count == 1
    assert report.evaluable_output_count == 1
    assert report.evaluated_output_count == 0
    assert report.completion_rate_by_arm["A"] == 0


def test_serialized_resume_preserves_every_failed_retry_output():
    from app.experiment.campaign_runner import BatchExecutionState
    fixtures = FinalDatasetRegistry().build_reading_final_tasks()[:1]
    executor = CampaignBatchExecutor()
    state = executor.execute_reading_batch(fixtures, batch_index=1, max_retries=1)
    saved = BatchExecutionState.model_validate_json(state.model_dump_json())
    assert len(saved.attempt_results) == len(saved.attempts)
    restored = CampaignBatchExecutor()
    restored.execute_reading_batch(fixtures, batch_index=1, resume_state=saved, max_retries=1)
    for att in saved.attempts:
        assert restored.ledger.get_output(att.attempt_id) == executor.ledger.get_output(att.attempt_id)


def test_interrupted_provider_dispatch_is_durable_and_cannot_be_redispatched(tmp_path):
    path = tmp_path / "ledger.json"
    ledger = ExperimentReplayLedger(checkpoint_path=path)
    fixtures = FinalDatasetRegistry().build_reading_final_tasks()[:1]
    executor = CampaignBatchExecutor(ledger=ledger)
    def interrupt(**kwargs):
        raise KeyboardInterrupt()
    executor._dispatch_reading_arm = interrupt
    with pytest.raises(KeyboardInterrupt):
        executor.execute_reading_batch(fixtures, batch_index=1)
    ledger.close()  # Simulate process teardown releasing the single-writer lock.
    restored = ExperimentReplayLedger(checkpoint_path=path)
    report = CampaignReconciliationManager().reconcile_campaign_completeness(restored)
    assert report.started_attempt_count == 1
    assert report.in_progress_count == 1
    assert report.unattempted_count == 2
    resumed = CampaignBatchExecutor(ledger=restored)
    resumed._dispatch_reading_arm = lambda **kwargs: pytest.fail("Unresolved dispatch must not be replayed")
    with pytest.raises((ValueError, RuntimeError)):
        resumed.execute_reading_batch(fixtures, batch_index=1)
    restored.close()


def test_live_executor_requires_complete_manifest_and_durable_ledger():
    class LiveClient:
        is_live = True
    with pytest.raises(ValueError):
        CampaignBatchExecutor(client=LiveClient())


def test_frozen_full_manifest_keeps_unstarted_batches_in_denominator():
    from app.contracts.research import ExperimentManifest
    from app.experiment.paired import PairedAssignmentManager
    fixtures = FinalDatasetRegistry().build_reading_final_tasks()[:3]
    manifest = ExperimentManifest(
        experiment_id="frozen", dataset_version="version", source_sha256="a" * 64,
        code_commit_sha="source", foundation_model_id=fixtures[0].foundation_model_id,
        prompt_versions=fixtures[0].prompt_versions, rubric_version=fixtures[0].rubric_version,
        assignments=[a for f in fixtures for a in PairedAssignmentManager().create_paired_assignments(f)],
        primary_endpoint="all-assigned", analysis_plan_sha256="b" * 64)
    executor = CampaignBatchExecutor(manifest=manifest)
    executor.execute_reading_batch(fixtures[:1], batch_index=1, max_retries=0)
    report = CampaignReconciliationManager().reconcile_campaign_completeness(executor.ledger)
    assert report.total_frozen_assignments == 9
    assert report.unattempted_count == 6
