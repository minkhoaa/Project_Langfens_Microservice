"""Final research campaign batch executor and orchestrator (RG10-S01, S02, S04).

Implements <=5 items/batch, bounded retries, no cherry-picking, paired A/B/C execution,
attempt lineage and usage accounting under the research execution contracts.

Invariants:
1. Batch cardinality: no individual research execution batch contains more than five frozen dataset items (up to 15 A/B/C arm assignments).
2. Resumable & bounded batches: attempts linked with explicit retry lineage; duplicate commits rejected.
3. No cherry-picking: failure/timeout/partial records retained; cannot omit failed batches or refill with replacement tasks.
4. Grammar rule ambiguity: ambiguous grammar rules cannot be silently fixed in FINAL inputs.
5. Inviolable research protection: research attempts are strictly forbidden from production publishing.
"""

from __future__ import annotations
from typing import Any, Dict, List, Literal, Optional, Set, Tuple

import copy
import hashlib
import json
import time
from pathlib import Path
from uuid import uuid4

from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    ExperimentManifest,
    GenerationResult,
    OutputAvailability,
    PairedTaskFixture,
    StandaloneGrammarRequest,
    StandaloneReadingRequest,
)
from app.experiment.ledger import AttemptRecord, ExperimentReplayLedger, StartedAttempt
from app.experiment.paired import PairedAssignmentManager
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
    DefaultRecordingExperimentClient,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import (
    CanonicalEvaluationResult,
    EvaluationVerdict,
    RubricProfile,
    compute_output_sha256,
)
from app.experiment.blind_review import (
    BlindReviewManager,
    GoldSmugglingForbiddenError,
    SealedGoldVault,
)
from app.persistence.grammar_store import ResearchPublicationForbiddenError
from app.experiment.scoring import CampaignEvaluationResult, score_campaign_output


class BatchCardinalityExceededError(ValueError):
    """Raised when an execution batch exceeds the maximum allowed cardinality of 5 dataset items."""


class ReplacementItemForbiddenError(RuntimeError):
    """Raised when a failed assignment item is replaced with a substitute item in final evaluation."""


class CherryPickForbiddenError(RuntimeError):
    """Raised when failed or missing batches are omitted from campaign accounting."""


class AmbiguousGrammarRuleError(RuntimeError):
    """Raised when a grammar rule in a task is ambiguous or ill-defined."""


class GrammarRuleAmbiguityFixedForbiddenError(RuntimeError):
    """Raised when an ambiguous grammar rule is silently modified or repaired in FINAL inputs."""

class DenominatorMismatchError(RuntimeError):
    """Raised when reconciled attempts count does not match total frozen assignments."""

class SnapshotTamperedError(RuntimeError):
    """Raised when sealed research snapshot hash does not match expected integrity hash."""


class ConcealedMissingRowsForbiddenError(RuntimeError):
    """Raised when an attempt is made to edit or conceal partial/missing rows in frozen manifest."""


class FalseProvenanceClaimError(RuntimeError):
    """Raised when a clean commit is falsely claimed on a dirty or uncommitted worktree."""


class SealedResearchSnapshot(CanonicalBaseModel):
    """Immutable, cryptographic record of the sealed final research campaign snapshot (RG10-S05)."""

    state: Literal["SEALED_RESEARCH_SNAPSHOT"] = "SEALED_RESEARCH_SNAPSHOT"
    snapshot_id: str
    experiment_id: str
    dataset_version: str
    split: Literal["FINAL_EVAL"] = "FINAL_EVAL"
    manifest_root_sha256: str
    results_ledger_sha256: str
    evaluations_ledger_sha256: str
    human_review_ledger_sha256: str
    rubric_version: str
    rubric_hash: str
    analysis_plan_hash: str
    code_commit_sha: str
    worktree_dirty: bool = True
    dirty_state: str = ""
    worktree_content_hashes: Dict[str, str] = Field(default_factory=dict)
    foundation_model_id: str
    snapshot_root_sha256: str
    reproducibility_metadata: Dict[str, Any] = Field(default_factory=dict)

SealedResearchSnapshot.model_rebuild()


class CampaignCompletenessReport(CanonicalBaseModel):
    """Reconciled campaign completeness and accounting report (RG10-S04)."""

    total_frozen_assignments: int
    total_attempts: int
    total_reconciled: int
    unattempted_count: int = 0
    is_fully_reconciled: bool
    status_distribution: Dict[str, int] = Field(default_factory=dict)
    terminal_status_distribution: Dict[str, int] = Field(default_factory=dict)
    terminal_validation_failure_codes: Dict[str, int] = Field(default_factory=dict)
    confidence_distribution: Dict[str, int] = Field(default_factory=dict)
    token_usage_by_arm: Dict[str, Dict[str, Optional[int]]] = Field(default_factory=dict)
    cost_by_arm: Dict[str, Optional[float]] = Field(default_factory=dict)
    estimated_cost_by_arm: Dict[str, Optional[float]] = Field(default_factory=dict)
    confirmed_billing_by_arm: Dict[str, Optional[float]] = Field(default_factory=dict)
    latency_by_arm: Dict[str, Optional[float]] = Field(default_factory=dict)
    telemetry_provenance_distribution: Dict[str, int] = Field(default_factory=dict)
    started_attempt_count: int = 0
    linked_retry_count: int = 0
    terminal_attempt_count: int = 0
    in_progress_count: int = 0
    generated_output_count: int = 0
    evaluable_output_count: int = 0
    evaluated_output_count: int = 0
    completion_rate_by_arm: Dict[str, float] = Field(default_factory=dict)
    by_arm: Dict[str, Dict[str, int]] = Field(default_factory=dict)


class BatchExecutionState(CanonicalBaseModel):
    """State record of an executed bounded research batch."""

    batch_id: str
    domain: Literal["READING", "GRAMMAR"]
    batch_index: int
    dataset_item_ids: List[str] = Field(default_factory=list)
    assignment_ids: List[str] = Field(default_factory=list)
    status: Literal["PENDING", "IN_PROGRESS", "COMPLETED", "FAILED", "PARTIAL"] = "PENDING"
    attempts: List[AttemptRecord] = Field(default_factory=list)
    results: Dict[str, GenerationResult] = Field(default_factory=dict)
    attempt_results: Dict[str, GenerationResult] = Field(default_factory=dict)
    usage_summary: Dict[str, Any] = Field(default_factory=dict)
    fixture_hashes: Dict[str, str] = Field(default_factory=dict)


class CampaignBatchExecutor:
    """Executes frozen paired Reading and Grammar assignments in bounded, resumable batches."""

    def __init__(
        self,
        assignment_manager: Optional[PairedAssignmentManager] = None,
        ledger: Optional[ExperimentReplayLedger] = None,
        client: Optional[DefaultRecordingExperimentClient] = None,
        runner_a: Optional[ConfigurationARunner] = None,
        runner_b: Optional[ConfigurationBRunner] = None,
        runner_c: Optional[ConfigurationCRunner] = None,
        manifest: Optional[ExperimentManifest] = None,
        raw_response_store: Optional[Any] = None,
    ) -> None:
        self.assignment_manager = assignment_manager or PairedAssignmentManager()
        self.ledger = ledger or ExperimentReplayLedger()
        self.client = client or DefaultRecordingExperimentClient()
        self.runner_a = runner_a or ConfigurationARunner(client=self.client)
        self.runner_b = runner_b or ConfigurationBRunner(client=self.client)
        self.runner_c = runner_c or ConfigurationCRunner(client=self.client)
        self.manifest = manifest.model_copy(deep=True) if manifest is not None else None
        self.raw_response_store = raw_response_store
        clients = [self.client, *(getattr(r, "client", None) for r in (self.runner_a, self.runner_b, self.runner_c))]
        if any(getattr(c, "is_live", False) for c in clients):
            if self.manifest is None or not self.ledger.is_durable:
                raise ValueError("Live campaigns require the complete frozen manifest and a durable research ledger")
            if self.raw_response_store is not None:
                for c in clients:
                    if hasattr(c, "raw_response_store") and getattr(c, "raw_response_store", None) is None:
                        c.raw_response_store = self.raw_response_store
        if self.manifest is not None:
            expected = {a.assignment_id for a in self.manifest.assignments}
            existing = {a.assignment_id for a in self.ledger.get_frozen_assignments()}
            if len(expected) != len(self.manifest.assignments) or not existing <= expected:
                raise ValueError("Ledger assignments differ from complete frozen manifest")
            self.ledger.bind_fixture("__campaign__", hashlib.sha256(self.manifest.model_dump_json().encode()).hexdigest())
            self.ledger.freeze_assignments(self.manifest.assignments)

    def partition_batches(
        self,
        fixtures: List[PairedTaskFixture],
        max_items_per_batch: int = 5,
    ) -> List[List[PairedTaskFixture]]:
        """Partitions fixtures into bounded batches of at most 5 frozen items."""
        if max_items_per_batch > 5 or max_items_per_batch < 1:
            raise BatchCardinalityExceededError(
                f"Batch cardinality ({max_items_per_batch}) cannot exceed 5 frozen items"
            )

        if not fixtures:
            return []

        batches: List[List[PairedTaskFixture]] = []
        for i in range(0, len(fixtures), max_items_per_batch):
            batches.append(fixtures[i : i + max_items_per_batch])
        return batches

    def validate_no_replacement(
        self,
        original_item_id: str,
        executed_item_id: str,
    ) -> None:
        """Validates that a frozen assignment item has not been replaced with another task."""
        if original_item_id != executed_item_id:
            raise ReplacementItemForbiddenError(
                f"Replacement of frozen assignment item '{original_item_id}' with '{executed_item_id}' "
                "is strictly forbidden. Failed items must be recorded honestly, never replaced."
            )

    def validate_batch_coverage(
        self,
        assigned_fixtures: List[PairedTaskFixture],
        batch_states: List[BatchExecutionState],
    ) -> None:
        """Enforces that all assigned fixtures are accounted for in batch executions (no cherry-picking)."""
        assigned_ids = {f.dataset_item_id for f in assigned_fixtures}
        executed_ids: Set[str] = set()
        for state in batch_states:
            executed_ids.update(state.dataset_item_ids)

        missing = assigned_ids - executed_ids
        if missing:
            raise CherryPickForbiddenError(
                f"Missing executed batches for items: {sorted(missing)}. "
                "Cherry-picking successful batches or omitting failed runs is strictly forbidden."
            )
    def validate_rule_immutability(
        self,
        original_rule: Any,
        executed_rule: Any,
    ) -> None:
        """Enforces that grammar rules in FINAL inputs cannot be silently mutated or repaired."""
        if original_rule != executed_rule:
            raise GrammarRuleAmbiguityFixedForbiddenError(
                "Grammar rule ambiguity cannot be silently repaired or mutated in frozen FINAL inputs."
            )
    def _extract_cost_usd(self, usage: Dict[str, Any]) -> Optional[float]:
        """Preserve supplied cost, including known zero; never invent a price."""
        cost = usage.get("cost_usd")
        return float(cost) if cost is not None else None

    def execute_reading_batch(
        self, batch_fixtures: List[PairedTaskFixture], batch_index: int,
        resume_state: Optional[BatchExecutionState] = None,
        allow_retries: bool = True, max_retries: int = 2,
    ) -> BatchExecutionState:
        return self._execute_batch("READING", batch_fixtures, batch_index, resume_state, allow_retries, max_retries)

    def execute_grammar_batch(
        self, batch_fixtures: List[PairedTaskFixture], batch_index: int,
        resume_state: Optional[BatchExecutionState] = None,
        allow_retries: bool = True, max_retries: int = 2,
    ) -> BatchExecutionState:
        return self._execute_batch("GRAMMAR", batch_fixtures, batch_index, resume_state, allow_retries, max_retries)

    def _execute_batch(self, domain, fixtures, batch_index, resume_state, allow_retries, max_retries):
        if not fixtures:
            raise ValueError(f"{domain.title()} batch requires at least one fixture to execute.")
        if len(fixtures) > 5:
            raise BatchCardinalityExceededError("Batch exceeds maximum allowed cardinality (5).")
        if max_retries < 0:
            raise ValueError("max_retries cannot be negative")
        ids = [f.dataset_item_id for f in fixtures]
        if len(set(ids)) != len(ids) or any(f.domain != domain for f in fixtures):
            raise ValueError("Batch fixtures must be unique and match the batch domain")
        if domain == "GRAMMAR":
            for f in fixtures:
                rule_pack = getattr(f, "rule_pack", None)
                if rule_pack is not None:
                    if not getattr(rule_pack, "rule_pack_id", None) or not getattr(rule_pack, "rule_ids", None):
                        raise AmbiguousGrammarRuleError(
                            f"Grammar fixture {f.dataset_item_id} has ambiguous rule without rule_pack_id or rule_ids."
                        )
        hashes = {f.dataset_item_id: hashlib.sha256(f.model_dump_json().encode()).hexdigest() for f in fixtures}
        assignments = [a for f in fixtures for a in self.assignment_manager.create_paired_assignments(f)]
        if self.manifest is not None:
            expected = {a.assignment_id: a for a in self.manifest.assignments}
            if any(a.assignment_id not in expected or expected[a.assignment_id] != a for a in assignments):
                raise ReplacementItemForbiddenError("Batch is not a subset of frozen manifest assignments")
            if any(f.foundation_model_id != self.manifest.foundation_model_id
                   or f.prompt_versions != self.manifest.prompt_versions
                   or f.rubric_version != self.manifest.rubric_version for f in fixtures):
                raise ValueError("Batch model/prompt/rubric differs from frozen manifest")
        if resume_state and (resume_state.domain != domain or resume_state.batch_index != batch_index
                             or resume_state.dataset_item_ids != ids or resume_state.fixture_hashes != hashes
                             or resume_state.assignment_ids != [a.assignment_id for a in assignments]):
            raise ValueError("Resume state differs from frozen batch identities")
        self.ledger.freeze_assignments(assignments)
        for item_id, digest in hashes.items():
            self.ledger.bind_fixture(item_id, digest)
        self._restore_batch(resume_state)
        for asg in assignments:
            if self.assignment_manager.get_assignment(asg.assignment_id) is None:
                self.assignment_manager.register_assignment(asg)
        for fixture in fixtures:
            for asg in self.assignment_manager.create_paired_assignments(fixture):
                self._execute_assignment(fixture, asg, allow_retries, max_retries)
        attempts = [att for asg in assignments for att in self.ledger.get_attempt_lineage(asg.assignment_id)]
        results = {}
        for asg in assignments:
            lineage = self.ledger.get_attempt_lineage(asg.assignment_id)
            if lineage:
                output = self.ledger.get_output(lineage[-1].attempt_id)
                if output is not None:
                    results[asg.assignment_id] = output
        completed = sum(r.execution_status == ExecutionStatus.COMPLETED for r in results.values())
        status = "COMPLETED" if completed == len(assignments) else ("PARTIAL" if completed else "FAILED")
        return BatchExecutionState(
            batch_id=resume_state.batch_id if resume_state else f"batch-{domain.lower()}-{batch_index:02d}-{uuid4().hex[:8]}",
            domain=domain, batch_index=batch_index, dataset_item_ids=ids,
            assignment_ids=[a.assignment_id for a in assignments], status=status,
            attempts=attempts, results=results, fixture_hashes=hashes,
            attempt_results={a.attempt_id: self.ledger.get_output(a.attempt_id) for a in attempts
                             if self.ledger.get_output(a.attempt_id) is not None},
            usage_summary={
                "total_tokens": self._nullable_sum([a.usage_total_tokens for a in attempts]),
                "total_calls": sum(a.usage_call_count for a in attempts),
                "confidence": self._combined_confidence(attempts),
            },
        )

    def _restore_batch(self, state):
        if state is None:
            return
        for att in state.attempts:
            existing = self.ledger.get_attempt(att.attempt_id)
            if existing is None:
                self.ledger.record_attempt(att)
            elif existing != att:
                raise ValueError("Resume attempt conflicts with ledger")
        for attempt_id, result in state.attempt_results.items():
            existing = self.ledger.get_output(attempt_id)
            if existing is None:
                self.ledger.record_output(attempt_id, result)
            elif existing != result:
                raise ValueError("Resume output conflicts with ledger")
        for assignment_id, result in state.results.items():
            lineage = self.ledger.get_attempt_lineage(assignment_id)
            if not lineage:
                raise ValueError("Resume output has no attempt")
            if self.ledger.get_output(lineage[-1].attempt_id) is None:
                self.ledger.record_output(lineage[-1].attempt_id, result)

    def _execute_assignment(self, fixture, asg, allow_retries, max_retries):
        lineage = self.ledger.get_attempt_lineage(asg.assignment_id)
        if lineage and lineage[-1].is_terminal:
            return
        limit = max_retries + 1 if allow_retries else 1
        for number in range(len(lineage) + 1, limit + 1):
            parent_id = lineage[-1].attempt_id if lineage else None
            attempt_id = f"att-{asg.assignment_id}-{number}"
            self.ledger.start_attempt(StartedAttempt(
                attempt_id=attempt_id, assignment_id=asg.assignment_id, dataset_item_id=asg.dataset_item_id,
                configuration_id=asg.configuration_id, attempt_number=number, parent_attempt_id=parent_id))
            req = self.assignment_manager.map_arm_request(fixture, asg.configuration_id, run_id=f"run-{asg.assignment_id}-{number}")
            started = time.perf_counter()
            runner = getattr(self, f"runner_{asg.configuration_id.lower()}", None)
            client = getattr(runner, "client", None)
            dispatches_before = len(getattr(client, "recorded_dispatches", []))
            try:
                kwargs = dict(arm=asg.configuration_id, req=req,
                              prompt_version=getattr(fixture.prompt_versions, asg.configuration_id),
                              model_id=fixture.foundation_model_id)
                if fixture.domain == "READING":
                    result, usage = self._dispatch_reading_arm(**kwargs, passage_text=fixture.passage_text)
                else:
                    result, usage = self._dispatch_grammar_arm(**kwargs)
            except Exception:
                # Preserve the attempt without leaking provider exceptions into artifacts.
                calls_made = 0
                if client is not None and hasattr(client, "recorded_dispatches"):
                    calls_made = max(0, len(client.recorded_dispatches) - dispatches_before)
                result = GenerationResult(
                    run_id=req.run_id, dataset_item_id=req.dataset_item_id, configuration_id=req.configuration_id,
                    task_type=req.task.task_type, execution_status=ExecutionStatus.FAILED_RUNTIME,
                    output_availability=OutputAvailability.NONE, failure_code="PROVIDER_RUNTIME_ERROR")
                usage = {"confidence": "UNKNOWN", "call_count": calls_made}
            elapsed = (time.perf_counter() - started) * 1000
            terminal = result.execution_status == ExecutionStatus.COMPLETED or number == limit
            att = AttemptRecord(
                attempt_id=attempt_id, assignment_id=asg.assignment_id, dataset_item_id=asg.dataset_item_id,
                configuration_id=asg.configuration_id, attempt_number=number, parent_attempt_id=parent_id,
                execution_status=result.execution_status, output_availability=result.output_availability,
                failure_code=result.failure_code, usage_call_count=usage.get("call_count", 1),
                usage_prompt_tokens=usage.get("prompt_tokens"), usage_completion_tokens=usage.get("completion_tokens"),
                usage_total_tokens=usage.get("total_tokens"), usage_confidence=usage.get("confidence", "UNKNOWN"),
                token_source=usage.get("token_source", "UNKNOWN"), cost_usd=self._extract_cost_usd(usage),
                cost_source=usage.get("cost_source", "UNKNOWN"), estimated_cost_usd=usage.get("estimated_cost_usd"),
                confirmed_billing_usd=usage.get("confirmed_billing_usd"), latency_ms=elapsed,
                provenance=usage.get("provenance", {}), is_terminal=terminal)
            self.ledger.record_attempt(att)
            self.ledger.record_output(attempt_id, result)
            lineage.append(att)
            if terminal:
                break

    @staticmethod
    def _nullable_sum(values):
        return sum(values) if values and all(v is not None for v in values) else None

    @staticmethod
    def _combined_confidence(attempts):
        values = {a.usage_confidence for a in attempts}
        if not values or "UNKNOWN" in values:
            return "UNKNOWN"
        return "ESTIMATED" if "ESTIMATED" in values else "EXACT"

    def attempt_to_publish_research_attempt(self, attempt: AttemptRecord) -> None:
        """Inviolable research protection: research attempts are strictly forbidden from production publishing."""
        self.ledger.publish_to_production(attempt.attempt_id, admin_user_id="unauthorized-admin")

    def _dispatch_reading_arm(
        self,
        arm: Literal["A", "B", "C"],
        req: StandaloneReadingRequest,
        passage_text: str,
        prompt_version: str,
        model_id: str,
    ) -> Tuple[GenerationResult, Any]:
        if arm == "A":
            return self.runner_a.generate_reading(req, passage_text, prompt_version, model_id)
        elif arm == "B":
            res, _trace, usage = self.runner_b.generate_reading(req, passage_text, prompt_version, model_id)
            return res, usage
        elif arm == "C":
            res, _trace, usage = self.runner_c.generate_reading(req, passage_text, prompt_version, model_id)
            return res, usage
        raise ValueError(f"Unknown configuration arm: {arm}")

    def _dispatch_grammar_arm(
        self,
        arm: Literal["A", "B", "C"],
        req: StandaloneGrammarRequest,
        prompt_version: str,
        model_id: str,
    ) -> Tuple[GenerationResult, Any]:
        if arm == "A":
            return self.runner_a.generate_grammar(req, prompt_version, model_id)
        elif arm == "B":
            res, _trace, usage = self.runner_b.generate_grammar(req, prompt_version, model_id)
            return res, usage
        elif arm == "C":
            res, _trace, usage = self.runner_c.generate_grammar(req, prompt_version, model_id)
            return res, usage
        raise ValueError(f"Unknown configuration arm: {arm}")

class IndependentCampaignScorer:
    """Manages independent, blinded evaluation of campaign generation results (RG10-S03)."""

    def __init__(
        self,
        evaluator: Optional[NeutralEvaluator] = None,
        blind_manager: Optional[BlindReviewManager] = None,
        rubric_version: Optional[str] = None,
    ) -> None:
        if evaluator is not None:
            if rubric_version is not None and evaluator.rubric.rubric_version != rubric_version:
                raise ValueError("Configured rubric does not match the injected evaluator rubric")
            self.evaluator = evaluator
        else:
            rubric = RubricProfile(rubric_version=rubric_version or "rubric-qgeval-v2.0")
            self.evaluator = NeutralEvaluator(rubric=rubric)
        self.blind_manager = blind_manager or BlindReviewManager()

    def assert_no_gold_leak(self, payload: Any, context_label: str = "Input") -> None:
        """Recursively asserts that no gold answers or reference labels are embedded in solver view."""
        self.blind_manager.assert_no_gold_in_input(payload, context_label=context_label)

    def score_generation_result(
        self,
        result: GenerationResult,
        assignment: ExperimentAssignment,
        rubric_version: Optional[str] = None,
    ) -> CampaignEvaluationResult:
        """Assess every eligible question without conflating quality and completion."""
        if result.dataset_item_id != assignment.dataset_item_id:
            raise ValueError("Generation result dataset does not match its assignment dataset")
        if result.configuration_id != assignment.configuration_id:
            raise ValueError("Generation result configuration does not match its assignment")
        if rubric_version is not None and rubric_version != self.evaluator.rubric.rubric_version:
            raise ValueError("Requested rubric does not match the configured evaluator rubric")
        if result.generated_content is not None:
            self.assert_no_gold_leak(result.generated_content.model_dump(mode="json"), context_label="GeneratedContent")
            for question in result.generated_content.questions:
                self.assert_no_gold_leak(question.model_dump(mode="json"), context_label="GeneratedQuestion")
        return score_campaign_output(result, self.evaluator)

    def publish_evaluation_to_production(self, evaluation_id: str, admin_user_id: str) -> None:
        """Inviolable research protection: evaluation artifacts cannot be published to production."""
        raise ResearchPublicationForbiddenError(
            f"RESEARCH_PUBLICATION_FORBIDDEN: Evaluation {evaluation_id} is in research mode and cannot be published."
        )

class CampaignReconciliationManager:
    """Manages full reconciliation of assignment ledgers, attempts, retries, and costs (RG10-S04)."""

    def reconcile_campaign_completeness(
        self,
        ledger: ExperimentReplayLedger,
    ) -> CampaignCompletenessReport:
        denom = ledger.get_reconciled_denominators()
        attempts = ledger.get_all_attempts()
        starts = ledger.get_started_attempts()
        status_dist: Dict[str, int] = {}
        conf_dist: Dict[str, int] = {}
        provenance_dist: Dict[str, int] = {}
        terminal_status_dist: Dict[str, int] = {}
        terminal_failure_codes: Dict[str, int] = {}
        for att in attempts:
            status = att.execution_status.value
            status_dist[status] = status_dist.get(status, 0) + 1
            if att.is_terminal:
                terminal_status_dist[status] = terminal_status_dist.get(status, 0) + 1
                if att.failure_code:
                    terminal_failure_codes[att.failure_code] = terminal_failure_codes.get(att.failure_code, 0) + 1
            conf_dist[att.usage_confidence] = conf_dist.get(att.usage_confidence, 0) + 1
            source = f"tokens:{att.token_source}/cost:{att.cost_source}"
            provenance_dist[source] = provenance_dist.get(source, 0) + 1
        finished_ids = {a.attempt_id for a in attempts}
        unresolved = [s for s in starts if s.attempt_id not in finished_ids]
        if unresolved:
            status_dist["IN_PROGRESS"] = len(unresolved)
            conf_dist["UNKNOWN"] = conf_dist.get("UNKNOWN", 0) + len(unresolved)
        token_usage = {}
        costs, estimates, billing, latency, rates = {}, {}, {}, {}, {}
        for arm in ("A", "B", "C"):
            rows = [a for a in attempts if a.configuration_id == arm]
            interrupted = any(s.configuration_id == arm for s in unresolved)
            def total(field):
                values = [getattr(a, field) for a in rows]
                return None if interrupted else CampaignBatchExecutor._nullable_sum(values)
            token_usage[arm] = {
                "prompt": total("usage_prompt_tokens"), "completion": total("usage_completion_tokens"),
                "total": total("usage_total_tokens"),
            }
            costs[arm], estimates[arm] = total("cost_usd"), total("estimated_cost_usd")
            billing[arm], latency[arm] = total("confirmed_billing_usd"), total("latency_ms")
            assigned = denom["by_arm"][arm]["assigned"]
            rates[arm] = round(denom["by_arm"][arm]["completed"] / assigned, 4) if assigned else 0.0
        counts = denom["by_arm"]
        return CampaignCompletenessReport(
            total_frozen_assignments=denom["total_frozen_assignments"], total_attempts=len(starts),
            total_reconciled=denom["total_reconciled"], unattempted_count=denom["total_unattempted"],
            is_fully_reconciled=denom["is_fully_reconciled"], status_distribution=status_dist,
            terminal_status_distribution=terminal_status_dist,
            terminal_validation_failure_codes=terminal_failure_codes,
            confidence_distribution=conf_dist, token_usage_by_arm=token_usage, cost_by_arm=costs,
            estimated_cost_by_arm=estimates, confirmed_billing_by_arm=billing, latency_by_arm=latency,
            telemetry_provenance_distribution=provenance_dist,
            started_attempt_count=len(starts), linked_retry_count=sum(s.attempt_number > 1 for s in starts),
            terminal_attempt_count=sum(1 for a in attempts if a.is_terminal), in_progress_count=sum(c["in_progress"] for c in counts.values()),
            generated_output_count=sum(c["generated"] for c in counts.values()),
            evaluable_output_count=sum(c["evaluable"] for c in counts.values()),
            evaluated_output_count=sum(c["evaluated"] for c in counts.values()),
            completion_rate_by_arm=rates, by_arm=counts,
        )

    def assert_no_unattempted_assignments(self, report: CampaignCompletenessReport) -> None:
        """Enforces that zero frozen assignments were omitted or dropped from execution."""
        if report.unattempted_count > 0:
            raise DenominatorMismatchError(
                f"Unattempted assignments remaining: {report.unattempted_count} out of {report.total_frozen_assignments}. "
                "All frozen assignments must be executed and accounted for."
            )


class FinalResearchSnapshotSealer:
    """Seals and verifies the immutable research campaign snapshot with cryptographic integrity hashes (RG10-S05)."""

    def compute_results_ledger_hash(self, ledger: ExperimentReplayLedger) -> str:
        """Bind assignments, dispatches, every attempt/output/evaluation and telemetry."""
        payload = json.dumps(ledger.snapshot_payload(), sort_keys=True, separators=(",", ":"))
        return hashlib.sha256(payload.encode("utf-8")).hexdigest()

    def compute_snapshot_root_hash(self, snapshot: SealedResearchSnapshot) -> str:
        """Computes deterministic composite SHA256 across all snapshot metadata, worktree hashes, and ledgers."""
        content_hash_lines = sorted([f"{k}:{v}" for k, v in snapshot.worktree_content_hashes.items()])
        content_digest = hashlib.sha256(":".join(content_hash_lines).encode("utf-8")).hexdigest()

        canonical_str = (
            f"{snapshot.snapshot_id}:{snapshot.experiment_id}:{snapshot.dataset_version}:"
            f"{snapshot.split}:{snapshot.manifest_root_sha256}:{snapshot.results_ledger_sha256}:"
            f"{snapshot.evaluations_ledger_sha256}:{snapshot.human_review_ledger_sha256}:"
            f"{snapshot.rubric_version}:{snapshot.rubric_hash}:{snapshot.analysis_plan_hash}:"
            f"{snapshot.code_commit_sha}:{snapshot.worktree_dirty}:{snapshot.dirty_state}:"
            f"{content_digest}:{snapshot.foundation_model_id}"
        )
        return hashlib.sha256(canonical_str.encode("utf-8")).hexdigest()

    def verify_snapshot_integrity(self, snapshot: SealedResearchSnapshot, expected_root_hash: str) -> None:
        """Verifies that the snapshot has not been modified or tampered with in-place."""
        computed_hash = self.compute_snapshot_root_hash(snapshot)
        if computed_hash != expected_root_hash:
            raise SnapshotTamperedError(
                f"Snapshot root SHA256 mismatch. Expected '{expected_root_hash}', computed '{computed_hash}'"
            )

    def validate_provenance_honesty(
        self,
        code_commit_sha: str,
        worktree_dirty: bool,
        dirty_state: str,
        worktree_content_hashes: Dict[str, str],
    ) -> None:
        """Guarantees provenance truthfulness: prevents claiming a clean commit on a dirty worktree."""
        if not code_commit_sha:
            raise ValueError("code_commit_sha is required and cannot be empty")

        if not worktree_dirty and dirty_state.strip():
            raise FalseProvenanceClaimError(
                f"False provenance claim: worktree_dirty=False claimed but dirty_state lists uncommitted files: '{dirty_state}'"
            )

        if worktree_dirty and not worktree_content_hashes:
            raise FalseProvenanceClaimError(
                "False provenance claim: worktree_dirty=True requires non-empty worktree_content_hashes "
                "to record exact uncommitted source state."
            )

    def enforce_no_concealed_missing_rows(self, accounted_count: int, expected_total_count: int) -> None:
        """Enforces that no missing rows are concealed in the final snapshot."""
        if accounted_count < expected_total_count:
            raise ConcealedMissingRowsForbiddenError(
                f"Cannot seal snapshot with concealed or missing assignment rows. "
                f"Accounted count ({accounted_count}) is less than expected total ({expected_total_count})."
            )

    def compute_file_sha256(self, file_path: str | Path) -> str:
        """Computes real SHA-256 hash from file bytes on disk, failing closed if file is missing."""
        p = Path(file_path)
        if not p.is_file():
            raise FileNotFoundError(f"Source file not found for provenance hashing: {file_path}")
        return hashlib.sha256(p.read_bytes()).hexdigest()

    def compute_worktree_hashes(self, file_paths: List[str | Path]) -> Dict[str, str]:
        """Computes real SHA-256 hashes of actual files on disk."""
        if not file_paths:
            raise ValueError("file_paths cannot be empty when computing worktree hashes")
        return {str(fp): self.compute_file_sha256(fp) for fp in file_paths}

    def seal_snapshot(
        self,
        manifest: Any,
        ledger: ExperimentReplayLedger,
        evaluations_ledger_sha256: str,
        human_review_ledger_sha256: str,
        code_commit_sha: str,
        worktree_dirty: bool,
        dirty_state: str,
        worktree_content_hashes: Dict[str, str],
        reproducibility_metadata: Optional[Dict[str, Any]] = None,
    ) -> SealedResearchSnapshot:
        """Constructs and seals the final immutable research snapshot with real, non-fabricated provenance."""
        if not evaluations_ledger_sha256 or len(evaluations_ledger_sha256) != 64:
            raise ValueError("Invalid evaluation ledger hash: must be 64-char SHA256")
        if not human_review_ledger_sha256 or len(human_review_ledger_sha256) != 64:
            raise ValueError("Invalid human review ledger hash: must be 64-char SHA256")

        # Fails closed on missing or invalid manifest_root_sha256
        manifest_root = getattr(manifest, "manifest_root_sha256", None)
        if not manifest_root or len(manifest_root) != 64:
            raise ValueError(
                f"manifest_root_sha256 is required and must be a valid 64-char SHA256 hash (got: {manifest_root})"
            )

        # Validate rubric_hash if explicitly provided on manifest
        manifest_rubric_hash = getattr(manifest, "rubric_hash", None)
        if manifest_rubric_hash is not None:
            if len(manifest_rubric_hash) != 64 or not all(c in "0123456789abcdefABCDEF" for c in manifest_rubric_hash):
                raise ValueError(
                    f"rubric_hash on manifest is invalid: must be 64-char SHA256 (got: {manifest_rubric_hash})"
                )
            rubric_hash = manifest_rubric_hash
        else:
            rubric_hash = hashlib.sha256(manifest.rubric_version.encode("utf-8")).hexdigest()
        # Validate honest provenance before sealing
        self.validate_provenance_honesty(
            code_commit_sha=code_commit_sha,
            worktree_dirty=worktree_dirty,
            dirty_state=dirty_state,
            worktree_content_hashes=worktree_content_hashes,
        )

        snapshot_id = f"snap-rq2-{manifest.experiment_id}-{uuid4().hex[:8]}"
        results_hash = self.compute_results_ledger_hash(ledger)

        preliminary = SealedResearchSnapshot(
            snapshot_id=snapshot_id,
            experiment_id=manifest.experiment_id,
            dataset_version=manifest.dataset_version,
            split="FINAL_EVAL",
            manifest_root_sha256=manifest_root,
            results_ledger_sha256=results_hash,
            evaluations_ledger_sha256=evaluations_ledger_sha256,
            human_review_ledger_sha256=human_review_ledger_sha256,
            rubric_version=manifest.rubric_version,
            rubric_hash=rubric_hash,
            analysis_plan_hash=manifest.analysis_plan_sha256,
            code_commit_sha=code_commit_sha,
            worktree_dirty=worktree_dirty,
            dirty_state=dirty_state,
            worktree_content_hashes=worktree_content_hashes,
            foundation_model_id=manifest.foundation_model_id,
            snapshot_root_sha256="0" * 64,
            reproducibility_metadata=reproducibility_metadata or {
                "environment": "offline_research_campaign",
                "sealing_policy": "generation_baseline/AGENTS.md",
            },
        )
        root_hash = self.compute_snapshot_root_hash(preliminary)
        return preliminary.model_copy(update={"snapshot_root_sha256": root_hash})
    def publish_snapshot_to_production(self, snapshot_id: str, admin_user_id: str) -> None:
        """Inviolable research protection: research snapshots cannot be published to production."""
        raise ResearchPublicationForbiddenError(
            f"RESEARCH_PUBLICATION_FORBIDDEN: Snapshot {snapshot_id} is in research mode and cannot be published."
        )
