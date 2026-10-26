"""Generic bounded generate/evaluate/decide/repair runtime; no domain or provider logic."""
from __future__ import annotations

import asyncio
import hashlib
import json
import time
from datetime import datetime, timezone
import logging
from collections.abc import Mapping, Sequence
from typing import Any

logger = logging.getLogger(__name__)
from uuid import uuid4

from pydantic import Field

from app.config import cap_snapshot_sha256
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import IssueCode, IssueLedger, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.loop.capabilities import EvaluatorCapability, GeneratorCapability, RepairerCapability
from app.loop.context import BudgetTracker, LoopContext, ResumeCursor
from app.loop.controller import LoopController
from app.loop.dependencies import DependencyValidator
from app.loop.detectors import (
    OscillationDetector,
    StagnationDetector,
    normalized_outcome_fingerprint,
    semantic_issue_identities,
)
from app.loop.journal import JournalEntry, OperationIntent, StepJournal
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy
from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    ArtifactResumeInfo, CheckpointCommitRequest, DraftCheckpointRequest,
    InvalidateDependencyRequest, LoopCursorCheckpointRequest,
    OperationGrantRequest, OperationReconcileRequest,
    OperationResumeInfo, ResumeStateResult,
)


class LoopResult(CanonicalBaseModel):
    run_id: str = Field(..., alias="runId")
    decision: DecisionType
    terminal_state: LoopState = Field(..., alias="terminalState")
    accepted_artifact: ArtifactEnvelope | None = Field(default=None, alias="acceptedArtifact")
    terminal_reason: str = Field(..., alias="terminalReason")
    terminal_reason_code: LoopReason = Field(..., alias="terminalReasonCode")
    total_iterations: int = Field(default=0, alias="totalIterations")
    versions_count: int = Field(default=0, alias="versionsCount")
    repairs_count: int = Field(default=0, alias="repairsCount")
    calls_count: int = Field(default=0, alias="callsCount")
    tokens_consumed: int = Field(default=0, alias="tokensConsumed")
    wall_time_seconds: float = Field(default=0.0, alias="wallTimeSeconds")
    ledger: IssueLedger
    latest_decision: LoopDecision | None = Field(default=None, alias="latestDecision")


class BoundedLoopRuntime:
    """One state machine. CheckpointClient is mandatory: local journal is never authority.

    Capabilities must make one bounded attempt per invocation, use the granted operation ID
    as their parentOperationId for any provider transport requests, and never mutate artifacts.
    An unacknowledged external operation is UNKNOWN_OUTCOME, not free replay.
    """

    def __init__(
        self, context: LoopContext, policy: LoopPolicy, generator: GeneratorCapability,
        evaluators: Sequence[EvaluatorCapability], repairer: RepairerCapability | None = None,
        persistence_client: CheckpointClient | None = None,
        accepted_dependencies: dict[str, ArtifactRef] | None = None,
        ledger_mgr: IssueLedgerManager | None = None, journal: StepJournal | None = None,
        accept_head: bool = True,
    ):
        if persistence_client is None:
            raise ValueError("LoopRuntime requires an authoritative durable CheckpointClient")
        ids = [ev.evaluator_id for ev in evaluators]
        if len(ids) != len(set(ids)):
            raise ValueError("Duplicate evaluator IDs")
        self.context, self.policy = context, policy
        self.generator, self.evaluators, self.repairer = generator, list(evaluators), repairer
        self.persistence_client = persistence_client
        self.accepted_dependencies = accepted_dependencies if accepted_dependencies is not None else {}
        self.ledger_mgr = ledger_mgr or IssueLedgerManager(context.run_id)
        self.journal = journal or StepJournal(context.run_id)
        self.accept_head = accept_head
        self.controller = LoopController(policy)
        self.stagnation_detector = StagnationDetector()
        self.oscillation_detector = OscillationDetector()
        self._latest_evaluations: list[EvaluationResult] = []
        self._latest_decision: LoopDecision | None = None
        self._repair_attempts_this_generation = 0
        self._generated_versions = 0
        self._expected_head_version: int | None = None
        self._expected_head_hash: str | None = None
        self._total_iterations = 0
        self._operations: dict[str, OperationResumeInfo] = {}
        self._recovery_responses: dict[str, frozenset[str]] = {}
        self._drafts: dict[int, ArtifactEnvelope] = {}
        self._stored_evaluations: dict[tuple[str, int], EvaluationResult] = {}
        self._accepted_head: ArtifactEnvelope | None = None
        self._capability_failures: list[str] = []

    def _envelope(self, info: ArtifactResumeInfo) -> ArtifactEnvelope:
        if not info.envelopeJson:
            raise ValueError("Resume artifact lacks exact immutable envelope")
        art = ArtifactEnvelope.model_validate_json(info.envelopeJson)
        if (art.run_id != self.context.run_id or art.artifact_id != info.artifactId or
            art.version != info.acceptedVersion or art.content_hash != info.acceptedHash or
            not art.verify_integrity()):
            raise ValueError("Corrupt or mismatched durable artifact envelope")
        return art
    def _run_cap_snapshot(self, state: ResumeStateResult) -> dict[str, Any]:
        if not state.budgetProfileJson or not state.budgetProfileSha256:
            raise ValueError("Run lacks a pinned cap profile; pause/migrate before resuming")
        snapshot = json.loads(state.budgetProfileJson)
        digest = hashlib.sha256(state.budgetProfileJson.encode("utf-8")).hexdigest()
        if (digest != state.budgetProfileSha256
            or snapshot.get("profileVersion") != state.budgetProfileVersion
            or snapshot.get("profileSource") != state.budgetProfileSource):
            raise ValueError("Run has an invalid pinned cap profile")
        return snapshot

    def _initialize_policy(self, snapshot: dict[str, Any]) -> None:
        original = LoopPolicy.from_cap_snapshot(snapshot)
        if self.policy.cap_profile_sha256 != original.cap_profile_sha256:
            cap_fields = set(LoopPolicy.RESOURCE_CAP_FIELDS) | {
                "generate_token_reservation", "cap_profile_version", "cap_profile_source",
                "cap_profile_sha256", "cap_profile_snapshot",
            }
            self.policy = LoopPolicy.from_cap_snapshot(
                snapshot, **self.policy.model_dump(exclude=cap_fields),
            )
        elif self.policy.cap_profile_snapshot != snapshot:
            raise ValueError("Runtime policy does not match the pinned run cap profile")
        self.policy.validate_cap_bounds()
        self.controller = LoopController(self.policy)


    def _restore(self) -> None:
        state: ResumeStateResult = self.persistence_client.resume_state(self.context.run_id)
        if not state.isCompatible or state.epoch != self.context.authority.epoch:
            raise ValueError(f"Incompatible or stale run authority: {state.incompatibilityReason}")
        if state.status.upper() not in ("RUNNING", "COMPLETED"):
            raise ValueError(f"Run is not active: {state.status}")
        run_profile = self._run_cap_snapshot(state)
        self._operations = {op.operationId: op for op in state.operations or []}
        target_id = self.context.target_artifact_id
        from app.persistence.client import get_artifact_aliases
        aliases = set(get_artifact_aliases(target_id, self.context.run_id))
        aliases.add(target_id)

        self._drafts = {i.acceptedVersion: self._envelope(i) for i in state.draftArtifacts or []
                        if i.artifactId in aliases}
        accepted = next((i for i in state.artifacts if i.artifactId in aliases), None)
        self._accepted_head = self._envelope(accepted) if accepted else None
        self._stored_evaluations = {
            (ev.evaluator_id, ev.target_ref.version): ev for ev in state.evaluations or []
            if ev.target_ref.artifact_id in aliases
        }
        caller_input_deps = tuple(self.context.input_dependencies)
        caller_current_artifact = self.context.current_artifact
        checkpoints = [c for c in state.loopCursors or [] if c.artifactId in aliases]
        if len(checkpoints) > 1:
            raise ValueError("Duplicate durable loop cursors")
        if checkpoints:
            checkpoint = checkpoints[0]
            payload = json.loads(checkpoint.stateJson)
            if "policy" in payload:
                pinned_policy = LoopPolicy.model_validate(payload["policy"])
                if (payload.get("targetArtifactId") not in aliases or
                    payload.get("scope") != self.context.scope.value or
                    payload.get("policyVersion") != self.context.policy_version):
                    raise ValueError("Pinned loop target, scope, or policy version changed during resume")
                snapshot = pinned_policy.cap_profile_snapshot
                snapshot_hash = cap_snapshot_sha256(snapshot)
                pinned_policy.validate_cap_bounds()
                if (not snapshot or snapshot_hash != pinned_policy.cap_profile_sha256 or
                    pinned_policy.cap_profile_version != snapshot.get("profileVersion") or
                    pinned_policy.cap_profile_source != snapshot.get("profileSource") or
                    (run_profile and run_profile != snapshot) or
                    (state.budgetProfileVersion and state.budgetProfileVersion != pinned_policy.cap_profile_version) or
                    (state.budgetProfileSha256 and state.budgetProfileSha256 != pinned_policy.cap_profile_sha256) or
                    (state.budgetProfileSource and state.budgetProfileSource != pinned_policy.cap_profile_source)):
                    raise ValueError("Run and cursor do not share a valid pinned cap profile")
                self.policy = pinned_policy
                self.controller = LoopController(pinned_policy)
                self.context.cursor = ResumeCursor.model_validate(payload["cursor"])
                if self.context.cursor.revision != checkpoint.revision:
                    raise ValueError("Cursor revision does not match durable CAS revision")
                self.context.budget_tracker = BudgetTracker.model_validate(payload["budget"])
                self.ledger_mgr = IssueLedgerManager.from_dict(payload["ledger"])
                self.stagnation_detector = StagnationDetector.model_validate(payload["stagnation"])
                self.oscillation_detector = OscillationDetector.model_validate(payload["oscillation"])
                self._repair_attempts_this_generation = payload.get("repairsSinceGeneration", 0)
                self._generated_versions = payload.get("generatedVersions", 0)
                self._expected_head_version = payload.get("expectedHeadVersion")
                self._expected_head_hash = payload.get("expectedHeadHash")
                if (
                    self._expected_head_hash is None
                    and self._accepted_head is not None
                    and self._accepted_head.version == self._expected_head_version
                ):
                    self._expected_head_hash = self._accepted_head.content_hash
                self._latest_evaluations = [EvaluationResult.model_validate(e) for e in payload.get("evaluations", [])]
                self._latest_decision = (LoopDecision.model_validate(payload["decision"])
                                         if payload.get("decision") else None)
                ref = ArtifactRef.model_validate(payload["currentRef"]) if payload.get("currentRef") else None
                if ref:
                    self.context.current_artifact = self._drafts.get(ref.version) or self._accepted_head
                    if not self.context.current_artifact or self.context.current_artifact.to_ref() != ref:
                        raise ValueError("Cursor points to missing or mismatched durable artifact")
                self.context.input_dependencies = tuple(ArtifactRef.model_validate(r) for r in payload.get("inputDependencies", ()))
                if "journal" in payload:
                    entries = [JournalEntry.model_validate(e) for e in payload["journal"]]
                    self.journal = StepJournal.from_entries(
                        self.context.run_id,
                        entries,
                        persistence_client=self.persistence_client,
                        authority=self.context.authority,
                    )
            else:
                # StageExecutor cursors use their own protocol payload, but share this
                # durable CAS revision. Preserve it before writing a loop-format cursor.
                self.context.cursor.revision = checkpoint.revision
                self.context.cursor.last_operation_id = checkpoint.lastOperationId
                # Legacy / StageExecutor cursor payload (protocolVersion, state, etc.)
                if self._accepted_head is not None:
                    stored_evals_for_head = [
                        ev for ev in self._stored_evaluations.values()
                        if ev.target_ref == self._accepted_head.to_ref() and ev.status == EvaluationStatus.PASS
                        and bool(str(getattr(ev, "evaluator_version", "") or "").strip())
                    ]
                    eval_ids = {ev.evaluator_id for ev in stored_evals_for_head}
                    has_required_evals = (
                        not self.policy.required_evaluator_ids
                        or set(self.policy.required_evaluator_ids).issubset(eval_ids)
                    )
                    self.context.current_artifact = self._accepted_head
                    if has_required_evals and not self.ledger_mgr.has_unresolved_blockers():
                        self.context.accepted_artifact = self._accepted_head
                        self.context.cursor.current_state = LoopState.COMPLETED
                    else:
                        self.context.accepted_artifact = None
                        self.context.cursor.current_state = LoopState.EVALUATING
                elif self._drafts:
                    latest_draft_ver = max(self._drafts.keys())
                    self.context.current_artifact = self._drafts[latest_draft_ver]
                    self.context.cursor.current_state = LoopState.EVALUATING
                else:
                    self.context.cursor.current_state = LoopState.DRAFTING
        elif caller_current_artifact is not None or self._accepted_head is not None or self._drafts:
            prior_head = self._accepted_head or (
                caller_current_artifact
                if (caller_current_artifact and caller_current_artifact.artifact_id in aliases and caller_current_artifact.version in [a.acceptedVersion for a in state.artifacts if a.artifactId in aliases])
                else None
            )
            stored_evals_for_head = [
                ev for ev in self._stored_evaluations.values()
                if prior_head and ev.target_ref == prior_head.to_ref() and ev.status == EvaluationStatus.PASS
                and bool(str(getattr(ev, "evaluator_version", "") or "").strip())
            ]
            eval_ids = {ev.evaluator_id for ev in stored_evals_for_head}
            has_required_evals = (
                not self.policy.required_evaluator_ids
                or set(self.policy.required_evaluator_ids).issubset(eval_ids)
            )
            if prior_head is not None and not self.ledger_mgr.has_unresolved_blockers() and has_required_evals:
                self._accepted_head = prior_head
                self.context.current_artifact = prior_head
                self.context.accepted_artifact = prior_head
                self._expected_head_version = prior_head.version
                self._expected_head_hash = prior_head.content_hash
                self._generated_versions = prior_head.version
                self.context.budget_tracker.versions_used = max(
                    self.context.budget_tracker.versions_used, prior_head.version
                )
                self.context.cursor.current_state = LoopState.COMPLETED
            elif prior_head is not None and (not has_required_evals or self.ledger_mgr.has_unresolved_blockers()):
                self._accepted_head = prior_head
                self.context.current_artifact = prior_head
                self.context.accepted_artifact = None
                self._expected_head_version = prior_head.version
                self._expected_head_hash = prior_head.content_hash
                self._generated_versions = prior_head.version
                self.context.budget_tracker.versions_used = max(
                    self.context.budget_tracker.versions_used, prior_head.version
                )
                if self.ledger_mgr.has_unresolved_blockers() and self.repairer is not None:
                    self.context.cursor.current_state = LoopState.REPAIRING
                else:
                    self.context.cursor.current_state = LoopState.EVALUATING
                self._accepted_head = prior_head
                self.context.current_artifact = prior_head
                self.context.accepted_artifact = None
                self._expected_head_version = prior_head.version
                self._expected_head_hash = prior_head.content_hash
                self._generated_versions = prior_head.version
                self.context.budget_tracker.versions_used = max(
                    self.context.budget_tracker.versions_used, prior_head.version
                )
                self.context.cursor.current_state = LoopState.REPAIRING
            elif self._drafts:
                latest_draft_ver = max(self._drafts.keys())
                draft_art = self._drafts[latest_draft_ver]
                self.context.current_artifact = draft_art
                self.context.accepted_artifact = None
                self._expected_head_version = self._accepted_head.version if self._accepted_head else None
                self._expected_head_hash = self._accepted_head.content_hash if self._accepted_head else None
                self._generated_versions = latest_draft_ver
                self.context.budget_tracker.versions_used = max(
                    self.context.budget_tracker.versions_used, latest_draft_ver
                )
                self.context.cursor.current_state = LoopState.EVALUATING
            elif caller_current_artifact is not None:
                prior_head = caller_current_artifact
                self.context.current_artifact = prior_head
                self.context.accepted_artifact = None
                self._expected_head_version = prior_head.version
                self._expected_head_hash = prior_head.content_hash
                self._generated_versions = prior_head.version
                self.context.budget_tracker.versions_used = max(
                    self.context.budget_tracker.versions_used, prior_head.version
                )
                if self.ledger_mgr.has_unresolved_blockers() and self.repairer is not None:
                    self.context.cursor.current_state = LoopState.REPAIRING
                else:
                    self.context.cursor.current_state = LoopState.DRAFTING
            else:
                self.context.cursor.current_state = LoopState.DRAFTING
        elif any(
            op.artifactId in aliases
            or any(op.operationId.startswith(f"loop:{self.context.run_id}:{a}:") for a in aliases)
            for op in self._operations.values()
        ):
            self.context.cursor.current_state = LoopState.DRAFTING
        # Reservations, including UNKNOWN_OUTCOME, are not refunded by restart.
        b = self.context.budget_tracker
        this_artifact_op_ids = {
            op.operationId for op in (state.operations or [])
            if op.artifactId == self.context.target_artifact_id
        }
        target_ops = [
            op for op in (state.operations or [])
            if op.artifactId == self.context.target_artifact_id
            or (op.artifactId is None and op.parentOperationId in this_artifact_op_ids)
        ]
        if target_ops:
            provider_types = ("PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE")
            loop_calls = len([op for op in target_ops if op.operationType in provider_types])
            has_provider_calls = any(op.operationType in provider_types for op in target_ops)
            loop_tokens = 0
            for op in target_ops:
                is_provider = op.operationType in provider_types
                status = getattr(op, "status", "").upper()
                accounting = str(getattr(op, "accountingType", "") or "").upper()
                used = getattr(op, "tokensUsed", 0) or 0
                reservation = max(0, getattr(op, "tokenReservation", 0) or 0)
                if has_provider_calls and not is_provider:
                    child_ops = [c for c in target_ops if c.parentOperationId == op.operationId]
                    if not child_ops and status in ("RESERVED", "UNKNOWN_OUTCOME"):
                        loop_tokens += reservation
                    continue
                if status == "COMPLETED" and (accounting in ("REPORTED", "RECONCILED", "ESTIMATED") or used > 0):
                    loop_tokens += used
                elif status in ("RESERVED", "UNKNOWN_OUTCOME"):
                    loop_tokens += reservation
                else:
                    loop_tokens += max(used, reservation)
            loop_wall = sum(
                (getattr(op, "wallTimeUsedSeconds", 0.0) or 0.0)
                if (getattr(op, "status", "").upper() == "COMPLETED")
                else max(0.0, float(getattr(op, "wallTimeReservationSeconds", 0.0) or 0.0))
                for op in target_ops
            )
            b.calls_used = max(b.calls_used, loop_calls)
            b.tokens_used = max(b.tokens_used, loop_tokens)
            # Rebuild provider-backed scopes from durable outcomes, rather than
            # retaining a cursor's stale parent reservations forever.
            if not self._refresh_provider_token_accounting(state):
                b.wall_time_used_seconds = max(b.wall_time_used_seconds, loop_wall)
        elif not self.context.parent_operation_id and not state.artifacts:
            b.calls_used = max(b.calls_used, state.callsUsed)
            b.tokens_used = max(b.tokens_used, state.tokensUsed)
            b.wall_time_used_seconds = max(b.wall_time_used_seconds, state.wallTimeUsedSeconds)
        if self._accepted_head and self.context.cursor.current_state == LoopState.COMPLETED:
            if caller_input_deps and caller_input_deps != tuple(self._accepted_head.parent_refs):
                self.context.input_dependencies = caller_input_deps
            fresh, _ = DependencyValidator.validate_dependency_freshness(self._accepted_head, self.accepted_dependencies)
            if (
                not fresh
                or self.context.input_dependencies != tuple(self._accepted_head.parent_refs)
                or any(i.isStale for i in state.artifacts if i.artifactId == self.context.target_artifact_id)
            ):
                self.context.current_artifact = self._accepted_head
                self.context.accepted_artifact = None
                self._expected_head_version = self._accepted_head.version
                self._expected_head_hash = self._accepted_head.content_hash
                self.context.cursor.current_state = (
                    LoopState.DRAFTING
                    if (self.context.input_dependencies != tuple(self._accepted_head.parent_refs)
                        or any(i.isStale for i in state.artifacts if i.artifactId == self.context.target_artifact_id))
                    else LoopState.EVALUATING
                )
                if checkpoints:
                    self._checkpoint()
            elif checkpoints and (
                self._latest_decision is None or self._latest_decision.decision != DecisionType.PASS or
                self.ledger_mgr.has_unresolved_blockers() or not self.policy.required_evaluator_ids or
                set(self.policy.required_evaluator_ids) - {e.evaluator_id for e in self._latest_evaluations} or
                any(e.status != EvaluationStatus.PASS or e.target_ref != self._accepted_head.to_ref()
                    for e in self._latest_evaluations)
            ):
                raise ValueError("Accepted resume cursor lacks required fresh PASS evidence")
            else:
                self.context.accepted_artifact = self._accepted_head
                if self._latest_decision is None:
                    self._latest_decision = LoopDecision(
                        decisionId=f"dec_resumed_{uuid4().hex[:8]}",
                        runId=self.context.run_id,
                        decision=DecisionType.PASS,
                        currentState=LoopState.COMPLETED,
                        nextState=LoopState.COMPLETED,
                        reason=LoopReason.ACCEPTED,
                        targetScope=self.context.scope,
                        targetArtifactId=self.context.target_artifact_id,
                        expectedVersion=self._accepted_head.version,
                    )
        if not checkpoints:
            self._initialize_policy(run_profile)
        if not checkpoints:
            self._checkpoint()

    def _refresh_provider_token_accounting(self, state: ResumeStateResult | None = None) -> bool:
        """Rebuild this artifact's charge from durable operations, once per tree.

        SectionRunner callbacks can dispatch standalone provider operations. Their
        usage is authoritative even without parentOperationId; completed loop
        reservations are not additional paid work. Unknown/unreconciled provider
        outcomes always retain their full reservation. No durable grant is changed.
        """
        state = state or self.persistence_client.resume_state(self.context.run_id)
        all_ops = {op.operationId: op for op in (state.operations or [])}
        selected = {op.operationId for op in all_ops.values()
                    if op.artifactId == self.context.target_artifact_id}
        while True:
            descendants = {op.operationId for op in all_ops.values() if op.parentOperationId in selected}
            if descendants <= selected:
                break
            selected |= descendants
        provider_types = {"PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE"}
        if not any(all_ops[oid].operationType in provider_types for oid in selected):
            return False
        children: dict[str, list[str]] = {}
        for oid in selected:
            parent = all_ops[oid].parentOperationId
            if parent in selected:
                children.setdefault(parent, []).append(oid)
        def charge(oid: str, path: frozenset[str] = frozenset()) -> int:
            if oid in path:
                raise ValueError("Durable operation accounting cycle")
            op = all_ops[oid]
            used = max(0, op.tokensUsed or 0)
            reservation = max(0, op.tokenReservation or 0)
            accounting = str(op.accountingType or "").upper()
            # Match PostgreSQL refund authority: an estimate (even nonzero)
            # cannot release the unused portion of a provider reservation.
            known = (op.status.upper() == "COMPLETED" and accounting != "UNKNOWN" and
                     (accounting in {"REPORTED", "RECONCILED"}
                      or op.operationType not in provider_types))
            own = used if known else max(used, reservation)
            child_total = sum(charge(cid, path | {oid}) for cid in children.get(oid, []))
            return max(own, child_total)
        def wall_charge(oid: str, path: frozenset[str] = frozenset()) -> float:
            if oid in path:
                raise ValueError("Durable operation accounting cycle")
            op = all_ops[oid]
            own = max(0.0, op.wallTimeUsedSeconds if op.status.upper() == "COMPLETED"
                      else op.wallTimeReservationSeconds)
            return max(own, sum(wall_charge(cid, path | {oid}) for cid in children.get(oid, [])))
        roots = [oid for oid in selected if all_ops[oid].parentOperationId not in selected]
        self.context.budget_tracker.wall_time_used_seconds = max(
            sum(wall_charge(oid) for oid in roots),
            (datetime.now(timezone.utc) - self.context.budget_tracker.started_at).total_seconds(),
        )
        self.context.budget_tracker.tokens_used = sum(charge(oid) for oid in roots)
        self.context.budget_tracker.calls_used = sum(
            all_ops[oid].operationType in provider_types for oid in selected
        )
        return True

    def _block_unresolved_provider_operations(self) -> bool:
        """Recheck durable outcomes at callback boundaries, not only on restart.

        A callback can return or raise after an unknown transport outcome. Neither
        a returned artifact nor a caught exception authorizes another paid attempt
        or acceptance while that provider reservation is unresolved.
        """
        state = self.persistence_client.resume_state(self.context.run_id)
        from app.persistence.client import get_artifact_aliases
        aliases = set(get_artifact_aliases(self.context.target_artifact_id, self.context.run_id))
        aliases.add(self.context.target_artifact_id)
        operations = {op.operationId: op for op in (state.operations or [])}
        selected = {oid for oid, op in operations.items() if op.artifactId in aliases}
        while True:
            descendants = {oid for oid, op in operations.items() if op.parentOperationId in selected}
            if descendants <= selected:
                break
            selected |= descendants
        unknown = sorted(oid for oid in selected
                         if operations[oid].operationType in {"PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE"}
                         and operations[oid].status.upper() != "COMPLETED")
        if not unknown:
            return False
        self._refresh_provider_token_accounting(state)
        self._finish(LoopReason.UNKNOWN_OUTCOME,
                     f"unresolved provider operations require reconciliation: {unknown}")
        return True

    def _checkpoint(self, last_operation_id: str | None = None) -> None:
        cursor = self.context.cursor
        revision = cursor.revision
        cursor.revision += 1
        payload = {
            "targetArtifactId": self.context.target_artifact_id,
            "scope": self.context.scope.value, "policyVersion": self.context.policy_version,
            "policy": self.policy.model_dump(mode="json", by_alias=True),
            "inputDependencies": [r.model_dump(mode="json", by_alias=True) for r in self.context.input_dependencies],
            "cursor": cursor.model_dump(mode="json", by_alias=True),
            "budget": self.context.budget_tracker.model_dump(mode="json", by_alias=True),
            "ledger": self.ledger_mgr.to_dict(),
            "stagnation": self.stagnation_detector.model_dump(mode="json", by_alias=True),
            "oscillation": self.oscillation_detector.model_dump(mode="json", by_alias=True),
            "repairsSinceGeneration": self._repair_attempts_this_generation,
            "generatedVersions": self._generated_versions,
            "expectedHeadVersion": self._expected_head_version,
            "expectedHeadHash": self._expected_head_hash,
            "evaluations": [e.model_dump(mode="json", by_alias=True) for e in self._latest_evaluations],
            "decision": self._latest_decision.model_dump(mode="json", by_alias=True) if self._latest_decision else None,
            "journal": [e.model_dump(mode="json", by_alias=True) for e in self.journal.entries[-20:]],
            "currentRef": (self.context.current_artifact.to_ref().model_dump(mode="json", by_alias=True)
                           if self.context.current_artifact else None),
        }
        state_json = json.dumps(payload, sort_keys=True, separators=(",", ":"))
        logger.info("Saving cursor checkpoint: artifactId=%s, expectedRevision=%d, stateJsonLen=%d", self.context.target_artifact_id, revision, len(state_json))
        request = LoopCursorCheckpointRequest(
            runId=self.context.run_id, epoch=self.context.authority.epoch,
            leaseOwner=self.context.authority.lease_owner,
            artifactId=self.context.target_artifact_id, expectedRevision=revision,
            stateJson=state_json,
            lastOperationId=last_operation_id,
        )
        try:
            ack = self.persistence_client.save_loop_cursor(request)
            if ack.revision != cursor.revision or ack.stateJson != request.stateJson:
                raise ValueError("Cursor acknowledgement mismatch")
        except CheckpointApiError as error:
            cursor.revision = revision
            if error.status_code in (409, 403):
                self._finish(LoopReason.LEASE_LOST, f"CAS_CONFLICT: {error.message}", aborted=True)
                return
            raise
        except BaseException:
            cursor.revision = revision
            raise

    def _decision(self, kind: DecisionType, code: LoopReason, detail: str,
                  next_state: LoopState) -> LoopDecision:
        return LoopDecision(
            decisionId=f"dec_{uuid4().hex}", runId=self.context.run_id,
            decision=kind, currentState=self.context.cursor.current_state,
            nextState=next_state, reason=f"{code.value}: {detail}", reasonCode=code,
            targetScope=self.context.scope, targetArtifactId=self.context.target_artifact_id,
            expectedVersion=self.context.current_artifact.version if self.context.current_artifact else 0,
        )

    def _finish(self, code: LoopReason, detail: str, aborted: bool = False) -> None:
        next_state = LoopState.ABORTED if aborted else LoopState.FAILED
        self._latest_decision = self._decision(DecisionType.FAIL, code, detail, next_state)
        self.context.cursor.advance(next_state)
        # A revoked writer cannot persist a terminal state; authoritative server fences all writes.
        if not aborted:
            self._checkpoint()

    def _authority(self) -> bool:
        if self.context.is_cancelled():
            self._finish(LoopReason.CANCELLED, "cancellation observed", aborted=True)
            return False
        if not self.context.check_authority():
            self._finish(LoopReason.LEASE_LOST, "local authority revoked", aborted=True)
            return False
        return True

    def _intent(self, kind: str, version: int, tokens: int, identity: str, extra: Any) -> OperationIntent:
        op_id = f"loop:{self.context.run_id}:{self.context.target_artifact_id}:{kind}:{version}:{identity}"
        return OperationIntent.create(
            operation_id=op_id, operation_type=kind, run_id=self.context.run_id,
            target_artifact_id=self.context.target_artifact_id, expected_version=version,
            token_reservation=tokens,
            wall_time_reservation_seconds=(
                (
                    # Account for at most 3 bounded passage calls (initial + quantity guard + word-count guard)
                    # at up to 180s per call, while respecting finite run cap if configured.
                    min(
                        3 * min(self.policy.operation_wall_reservation_seconds, 180.0),
                        float(self.policy.max_wall_time_seconds),
                    )
                    if (not self.policy.is_unlimited and self.policy.max_wall_time_seconds > 0)
                    else 3 * min(self.policy.operation_wall_reservation_seconds, 180.0)
                )
                if (
                    kind == "GENERATE"
                    and (
                        getattr(self.context, "target_artifact_type", None) in (ArtifactType.PASSAGE, "PASSAGE")
                        or str(getattr(self.context, "target_artifact_id", "")).startswith("art_passage")
                        or str(getattr(self.context, "scope", "")).upper() == "PASSAGE"
                    )
                )
                else (
                    # Mirror child ceiling: up to 120s for Question Candidate GENERATE
                    # bounded by policy wall reservation and finite run cap.
                    min(
                        min(self.policy.operation_wall_reservation_seconds, 120.0),
                        float(self.policy.max_wall_time_seconds),
                    )
                    if (not self.policy.is_unlimited and self.policy.max_wall_time_seconds > 0)
                    else min(self.policy.operation_wall_reservation_seconds, 120.0)
                )
                if (
                    kind == "GENERATE"
                    and (
                        getattr(self.context, "target_artifact_type", None) in (ArtifactType.QUESTION, "QUESTION")
                        or str(getattr(self.context, "target_artifact_id", "")).startswith("art_q")
                        or str(getattr(self.context, "scope", "")).upper() == "QUESTION"
                    )
                )
                else min(self.policy.operation_wall_reservation_seconds, 60.0)
                if kind in ("GENERATE", "REPAIR", "EVALUATE")
                else 0.0
            ),
            payload_for_hash=json.dumps(extra, sort_keys=True, default=str),
        )

    def _reserve(self, intent: OperationIntent) -> bool:
        if self._block_unresolved_provider_operations():
            return False
        op = self._operations.get(intent.operation_id)
        if op:
            if op.requestHash != intent.request_hash or op.artifactId != intent.target_artifact_id:
                raise ValueError("Operation replay hash or target mismatch")
            if op.status != "COMPLETED":
                # A CHECKPOINT_COMMIT reservation that never reached commit_checkpoint
                # (process died mid-accept) leaves a RESERVED operation whose work is
                # fully durable and whose retry is idempotent. The reservation already
                # exists server-side, so go straight to the commit: re-granting would
                # return isReplay and abort the accept, and re-journalling would double
                # count an intent that was recorded before the crash. Any other
                # operation type is an external side effect we cannot prove either ran
                # or didn't, so it stays fail-closed.
                if intent.operation_type == "CHECKPOINT_COMMIT" and op.status == "RESERVED":
                    # The journal is process-local, so the pre-crash intent is gone:
                    # re-record it so the ack below has an entry to close.
                    self.journal.record_intent(intent, self.context.cursor.current_state)
                    self.journal.mark_execution_started(intent.operation_id)
                    return True
                from app.providers.replay import known_wrapper_responses
                known = known_wrapper_responses(tuple(self._operations.values()), intent.operation_id)
                if known is not None:
                    self._recovery_responses[intent.operation_id] = known
                    self.journal.record_intent(intent, self.context.cursor.current_state)
                    self.journal.mark_execution_started(intent.operation_id)
                    return True
                self._finish(LoopReason.UNKNOWN_OUTCOME, f"unacknowledged operation {intent.operation_id}")
                return False
            return True
        if not self._authority():
            return False
        b = self.context.budget_tracker
        parent_op = getattr(self.context, "parent_operation_id", None)
        if intent.operation_type != "CHECKPOINT_COMMIT":
            is_llm_call = intent.operation_type in ("GENERATE", "REPAIR") or (intent.operation_type == "EVALUATE" and intent.token_reservation > 0)
            if not parent_op and is_llm_call:
                if not self.policy.is_unlimited and self.policy.max_total_calls > 0 and b.calls_used + 1 > self.policy.max_total_calls:
                    self._finish(LoopReason.CALL_CAP, "next operation exceeds shared call cap")
                    return False
            if not self.policy.is_unlimited and self.policy.max_total_tokens > 0 and b.tokens_used + intent.token_reservation > self.policy.max_total_tokens:
                self.ledger_mgr.record_issue(
                    code=IssueCode.BUDGET_EXHAUSTED,
                    severity=IssueSeverity.CRITICAL,
                    scope=self.context.scope,
                    message=f"Budget exhausted: next reservation ({intent.token_reservation}) exceeds token cap (remaining: {max(0, self.policy.max_total_tokens - b.tokens_used)} of {self.policy.max_total_tokens})",
                    reported_by="BoundedLoopRuntime",
                )
                self._finish(LoopReason.TOKEN_CAP, "next reservation exceeds token cap")
                return False
            now_utc = datetime.now(timezone.utc)
            actual_elapsed = (now_utc - b.started_at).total_seconds()
            if not self.policy.is_unlimited and self.policy.max_wall_time_seconds > 0 and actual_elapsed + intent.wall_time_reservation_seconds > self.policy.max_wall_time_seconds:
                self._finish(LoopReason.WALL_TIME_CAP, "next reservation exceeds deadline")
                return False
        self.journal.record_intent(intent, self.context.cursor.current_state)
        parent_sec_id = None
        if parent_op:
            p_record = self._operations.get(parent_op) if hasattr(self, "_operations") and isinstance(self._operations, dict) else None
            if p_record is None and hasattr(self.context, "operations"):
                p_record = next((o for o in (getattr(self.context, "operations", []) or []) if getattr(o, "operationId", None) == parent_op), None)
            if p_record is None and hasattr(self.persistence_client, "resume_state"):
                try:
                    r_state = self.persistence_client.resume_state(self.context.run_id)
                    p_record = next((o for o in (getattr(r_state, "operations", []) or []) if getattr(o, "operationId", None) == parent_op), None)
                except Exception as ex:
                    logger.warning("Could not resolve parent operation %s from persistence: %s", parent_op, ex)
            if p_record and getattr(p_record, "sectionId", None):
                parent_sec_id = p_record.sectionId

        sec_id = parent_sec_id or (
            str(self.context.section_id)
            if getattr(self.context, "section_id", None) is not None
            else None
        )
        art_id = self.context.target_artifact_id
        try:
            grant = self.persistence_client.grant_operation(OperationGrantRequest(
                runId=self.context.run_id, epoch=self.context.authority.epoch,
                leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                operationType=intent.operation_type, requestHash=intent.request_hash,
                tokenReservation=intent.token_reservation,
                wallTimeReservationSeconds=intent.wall_time_reservation_seconds,
                sectionId=sec_id,
                artifactId=art_id,
                parentOperationId=parent_op,
            ))
        except CheckpointApiError as error:
            if error.status_code in (409, 403):
                self._finish(LoopReason.LEASE_LOST, error.message, aborted=True)
                return False
            if error.status_code == 422:
                msg = (error.message or "").lower()
                if "call" in msg:
                    self._finish(LoopReason.CALL_CAP, error.message)
                elif "wall" in msg:
                    self._finish(LoopReason.WALL_TIME_CAP, error.message)
                else:
                    self._finish(LoopReason.TOKEN_CAP, error.message)
                return False
            else:
                raise
        if grant.operationId != intent.operation_id or grant.tokenReservation != intent.token_reservation:
            raise ValueError("Operation grant acknowledgement mismatch")
        if grant.isReplay:
            # A grant replay is not proof that the external operation never executed.
            self._finish(LoopReason.UNKNOWN_OUTCOME, "grant replay without committed outcome")
            return False
        if intent.operation_type != "CHECKPOINT_COMMIT":
            is_llm_call = intent.operation_type in ("GENERATE", "REPAIR") or (intent.operation_type == "EVALUATE" and intent.token_reservation > 0)
            if not parent_op and is_llm_call:
                b.calls_used += 1
            b.tokens_used += intent.token_reservation
            now_utc = datetime.now(timezone.utc)
            b.wall_time_used_seconds = max(b.wall_time_used_seconds, (now_utc - b.started_at).total_seconds())
        self.journal.mark_execution_started(intent.operation_id)
        return True

    def _record_capability_failure(
        self, error: BaseException, repair: bool, version: int
    ) -> str:
        """Records a generator/repairer failure for truthful attribution. Never swallows it.

        `RepairJustificationError` is the repairer's explicit, evidence-based refusal:
        no passage-grounded span justifies the change. That is a semantically correct
        rejection that must stay fail-closed, but it must also be *distinguishable*
        from an implementation crash and from a genuine version-cap exhaustion. It is
        recorded as an annotated capability-failure record (diagnostic only -- no new
        ledger issue code and no new blocker, so escalation/escalate-code behaviour is
        unchanged) and folded into the terminal reason by `_finish`.
        """
        from app.repair.base import RepairJustificationError

        art = self.context.current_artifact
        stage = "REPAIR" if repair else "GENERATE"
        if isinstance(error, RepairJustificationError):
            reason = (
                "REPAIR_INFEASIBLE (fail-closed evidence-justification refusal, not an "
                f"implementation failure): {error}"
            )
        else:
            reason = f"CAPABILITY_FAILURE ({type(error).__name__}): {error}"
        record = f"{stage}@{version}: {reason}"
        self._capability_failures.append(record)
        logger.warning("Capability failure recorded: %s", record)
        return record

    def _artifact_valid(self, artifact: Any, version: int) -> bool:
        return (isinstance(artifact, ArtifactEnvelope) and artifact.run_id == self.context.run_id and
                artifact.artifact_id == self.context.target_artifact_id and
                artifact.artifact_type == self.context.target_artifact_type and
                artifact.version == version and artifact.verify_integrity() and
                tuple(artifact.parent_refs) == tuple(self.context.input_dependencies))

    def _refresh_input_dependencies_from_res_state(self) -> bool:
        """Align ``context.input_dependencies`` with the persisted chain heads.

        A repair capability may accept downstream artifacts (e.g. the paper loop
        accepting regenerated V2 sections via per-question / per-section subloops)
        whose chain heads advance BETWEEN when the runtime's ``input_dependencies``
        was declared at construction time and when the capability returns the
        artifact. Without re-syncing, the artifact's ``parent_refs`` would point at
        the chain heads but the runtime would still compare against the V1 refs,
        producing a spurious ``INVALID_OUTPUT`` even though the artifact is
        strictly closed against the live chain.

        Strict-closure still applies. A ref is only ever refreshed from the
        AUTHORITATIVE ACCEPTED HEAD reported by ``resume_state`` for that exact
        ``artifact_id``, and only when that head is NOT stale and its version is
        STRICTLY HIGHER than the version this runtime declared. Two shapes are
        therefore refused outright and never rewritten:

        * a record the persistence layer marks stale -- it is not the accepted head;
        * an accepted head whose version is not greater than the declared one. In an
          append-only immutable chain a version identifies its content, so a
          same-version record carrying a different hash is an impossible mutation,
          not a legitimate advance, and rewriting the declaration to match it would
          paper over exactly the corruption this check exists to catch.

        The refreshed declaration is then re-validated against the artifact's own
        parent refs by the caller, so nothing is trusted on the capability's word.

        Returns ``True`` when at least one dep was refreshed, ``False`` otherwise.
        Cheap (single ``resume_state`` read); safe to call before each draft.
        """
        if self.persistence_client is None:
            return False
        try:
            state: ResumeStateResult = self.persistence_client.resume_state(self.context.run_id)
        except Exception:
            logger.debug("input-dep refresh: res_state unavailable; continuing with declared deps", exc_info=True)
            return False
        res_artifacts = {
            getattr(a, "artifactId", getattr(a, "artifact_id", "")): a
            for a in (getattr(state, "artifacts", None) or [])
        }
        current = tuple(self.context.input_dependencies)
        new_deps = []
        changed = False
        for dep in current:
            latest = res_artifacts.get(dep.artifact_id)
            if latest is None:
                new_deps.append(dep)
                continue
            latest_version = int(getattr(latest, "acceptedVersion", dep.version) or dep.version)
            latest_hash = str(getattr(latest, "acceptedHash", dep.content_hash) or dep.content_hash)
            if latest_version > dep.version and not bool(getattr(latest, "isStale", False)):
                refreshed = ArtifactRef(
                    artifact_id=dep.artifact_id,
                    artifact_type=dep.artifact_type,
                    version=latest_version,
                    content_hash=latest_hash,
                )
                new_deps.append(refreshed)
                self.accepted_dependencies[dep.artifact_id] = refreshed
                changed = True
            else:
                new_deps.append(dep)
        if changed:
            self.context.input_dependencies = tuple(new_deps)
        return changed

    def _deps_resyncable_only(self, artifact: Any, version: int) -> bool:
        """True when the ONLY reason the artifact failed validation is dependency refs.

        This is the fail-closed guard on the resync path above. It answers a single
        question: is this artifact itself internally sound, and did it only move
        *forward* in its dependency lineage?

        The envelope's identity (`run_id`, `artifact_id`, `artifact_type`), its
        version, and its content hash must ALL verify, and its `parent_refs` must
        name exactly the same set of artifact ids the runtime declared as inputs.
        Every parent ref that differs from the declared ref must carry a STRICTLY
        HIGHER version. A ref that keeps the same version but carries a different
        `content_hash` is an impossible mutation of an immutable chain -- a version
        identifies its content, so that shape is rejected outright rather than
        "resynced". Once this predicate accepts, the caller still re-validates the
        artifact against the deps read back from the authoritative persisted head,
        so no ref is trusted on the capability's word alone.

        Anything else -- a wrong artifact id, a forged content hash, an unknown
        parent id, a same-version hash mutation, a regressed version -- returns
        False, so the resync is never reached and the artifact is rejected.
        """
        if not isinstance(artifact, ArtifactEnvelope):
            return False
        if (artifact.run_id != self.context.run_id
                or artifact.artifact_id != self.context.target_artifact_id
                or artifact.artifact_type != self.context.target_artifact_type
                or artifact.version != version
                or not artifact.verify_integrity()):
            return False
        declared = {r.artifact_id for r in self.context.input_dependencies}
        produced = {r.artifact_id for r in artifact.parent_refs}
        if declared != produced:
            return False
        by_id = {r.artifact_id: r for r in self.context.input_dependencies}
        for ref in artifact.parent_refs:
            prev = by_id[ref.artifact_id]
            same_version = ref.version == prev.version
            if same_version and ref.content_hash.lower() != prev.content_hash.lower():
                # Immutable chain violation: same version, different content.
                return False
            if ref.version < prev.version:
                # A dependency never moves backwards in an append-only chain.
                return False
        return True

    async def _draft(self, repair: bool) -> None:
        old = self.context.current_artifact
        if repair and (old is None or self.repairer is None):
            self._finish(LoopReason.INVALID_OUTPUT, "repair has no exact target/capability")
            return
        if not repair and old is not None and self._generated_versions >= self.policy.max_generated_versions:
            self._finish(LoopReason.MAX_VERSIONS, "generation cap reached")
            return
        version = old.version + 1 if old else 1
        if version > self.policy.max_versions:
            self._finish(LoopReason.MAX_VERSIONS, "immutable artifact version cap reached")
            return
        if old and not repair:
            refs = []
            for ref in self.context.input_dependencies:
                accepted = self.accepted_dependencies.get(ref.artifact_id)
                if accepted is None:
                    self._finish(LoopReason.STALE_DEPENDENCY, "missing accepted input for regeneration")
                    return
                refs.append(accepted)
            self.context.input_dependencies = tuple(refs)
        issues = self.ledger_mgr.get_unresolved_blockers() if repair else []
        intent = self._intent("REPAIR" if repair else "GENERATE", version,
                              self.policy.repair_token_reservation if repair else self.policy.generate_token_reservation,
                              self.repairer.repairer_version if repair else self.generator.version,
                              {"parents": [r.model_dump(mode="json") for r in self.context.input_dependencies],
                               "previous": old.content_hash if old else None,
                               "issues": [i.fingerprint for i in issues], "policy": self.context.policy_version})
        if not self._reserve(intent):
            return
        op = self._operations.get(intent.operation_id)
        if op and op.status == "COMPLETED":
            outcome = json.loads(op.resultRefJson) if op.resultRefJson else None
            if isinstance(outcome, dict) and outcome.get("kind") == "CAPABILITY_FAILURE_V1":
                if (outcome.get("operationId") != intent.operation_id
                        or outcome.get("requestHash") != intent.request_hash
                        or outcome.get("targetVersion") != version
                        or outcome.get("artifactId") != self.context.target_artifact_id
                        or not isinstance(outcome.get("reason"), str) or not outcome["reason"]):
                    raise ValueError("Completed failure outcome does not bind exact operation")
                self._capability_failures.append(outcome["reason"])
                self.journal.record_intent(intent, self.context.cursor.current_state)
                self.journal.record_ack(intent.operation_id, "CAPABILITY_FAILURE_V1")
                if repair and self._generated_versions < self.policy.max_generated_versions:
                    self.context.cursor.advance(LoopState.DRAFTING)
                    self._checkpoint()
                else:
                    self._finish(LoopReason.INVALID_OUTPUT, outcome["reason"])
                return
            art = self._drafts.get(version)
            if art is None or not self._artifact_valid(art, version):
                raise ValueError("Completed draft operation lacks exact durable artifact")
            self.journal.record_intent(intent, self.context.cursor.current_state)
        else:
            t_draft_start = time.perf_counter()
            try:
                from app.providers.replay import provider_replay_only
                with provider_replay_only(self._recovery_responses.get(intent.operation_id)) as replay:
                    art = (await self.repairer.repair(self.context, old, issues, intent.operation_id, version)
                           if repair else await self.generator.generate(self.context, intent.operation_id, version))
                if replay is not None and replay.failure:
                    self._finish(LoopReason.UNKNOWN_OUTCOME, replay.failure)
                    return
                if repair:
                    for dep_ref in self.context.input_dependencies:
                        existing_dep = self.accepted_dependencies.get(dep_ref.artifact_id)
                        if existing_dep is not None and dep_ref.version > existing_dep.version:
                            self.accepted_dependencies[dep_ref.artifact_id] = dep_ref
            except asyncio.CancelledError:
                raise
            except Exception as error:
                if intent.operation_id in self._recovery_responses:
                    self._finish(LoopReason.UNKNOWN_OUTCOME, f"read-only capability recovery requires reconciliation: {error}")
                    return
                # P15: never swallow a repair failure. A repairer raising means the
                # surgical path could not produce a compliant artifact for a *known*
                # reason (e.g. RepairJustificationError: no passage-grounded span
                # exists, so the rules are correct and tight). Recording that reason in
                # the ledger keeps the terminal attribution truthful: falling back to
                # regeneration without a record made every repair-infeasible defect look
                # like a generic MAX_VERSIONS version-cap exhaustion.
                failure_reason = self._record_capability_failure(error, repair=repair, version=version)
                if self._block_unresolved_provider_operations():
                    return
                if self.persistence_client is not None:
                    try:
                        draft_wall_time = round(time.perf_counter() - t_draft_start, 4)
                        self.persistence_client.reconcile_operation(OperationReconcileRequest(
                            runId=self.context.run_id, epoch=self.context.authority.epoch,
                            leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                            tokensUsed=0, accountingType="REPORTED", wallTimeUsedSeconds=draft_wall_time,
                            resultRefJson=json.dumps({
                                "kind": "CAPABILITY_FAILURE_V1", "operationId": intent.operation_id,
                                "requestHash": intent.request_hash, "targetVersion": version,
                                "artifactId": self.context.target_artifact_id, "reason": failure_reason,
                            }, sort_keys=True),
                        ))
                        if not self._refresh_provider_token_accounting():
                            self.context.budget_tracker.tokens_used = max(
                                0, self.context.budget_tracker.tokens_used - intent.token_reservation
                            )
                    except Exception as rec_ex:
                        logger.warning("Could not reconcile failed %s operation %s: %s", intent.operation_type, intent.operation_id, rec_ex)
                if repair and self._generated_versions < self.policy.max_generated_versions:
                    self.context.cursor.advance(LoopState.DRAFTING)
                    self._checkpoint()
                    return
                self._finish(LoopReason.INVALID_OUTPUT, f"capability failed: {type(error).__name__}: {error}")
                return
            if self._block_unresolved_provider_operations():
                return
            if not self._artifact_valid(art, version) and not (
                # P15 case-14: a repair may have accepted NEW versions of this
                # artifact's dependencies (the paper loop re-runs the question and
                # section sub-loops, each of which commits its own artifact head).
                # The capability therefore legitimately binds parent_refs that are one
                # version ahead of the `input_dependencies` snapshot the runtime
                # declared when the loop started. Re-syncing the declared deps from
                # the durable chain BEFORE declaring the artifact unverifiable is what
                # distinguishes a genuine unverifiable artifact from a stale-deps
                # false positive. This does NOT relax the check: the refreshed deps
                # still have to match the artifact's parent_refs exactly, and any
                # artifact whose refs do not verify against the live chain head still
                # fails closed below.
                self._deps_resyncable_only(art, version)
                and self._refresh_input_dependencies_from_res_state()
                and self._artifact_valid(art, version)
            ):
                logger.error(
                    "Artifact validation failed: is_env=%s, run_id_match=%s (art=%s, ctx=%s), id_match=%s (art=%s, ctx=%s), type_match=%s (art=%s, ctx=%s), ver_match=%s (art=%s, exp=%s), integrity=%s, parent_match=%s (art_parents=%d, ctx_deps=%d)",
                    isinstance(art, ArtifactEnvelope),
                    getattr(art, "run_id", None) == self.context.run_id, getattr(art, "run_id", None), self.context.run_id,
                    getattr(art, "artifact_id", None) == self.context.target_artifact_id, getattr(art, "artifact_id", None), self.context.target_artifact_id,
                    getattr(art, "artifact_type", None) == self.context.target_artifact_type, getattr(art, "artifact_type", None), self.context.target_artifact_type,
                    getattr(art, "version", None) == version, getattr(art, "version", None), version,
                    art.verify_integrity() if hasattr(art, "verify_integrity") else False,
                    tuple(getattr(art, "parent_refs", ())) == tuple(self.context.input_dependencies),
                    len(getattr(art, "parent_refs", ())), len(self.context.input_dependencies),
                )
                if self.persistence_client is not None:
                    try:
                        draft_wall_time = round(time.perf_counter() - t_draft_start, 4)
                        self.persistence_client.reconcile_operation(OperationReconcileRequest(
                            runId=self.context.run_id, epoch=self.context.authority.epoch,
                            leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                            tokensUsed=0, accountingType="REPORTED", wallTimeUsedSeconds=draft_wall_time,
                        ))
                    except Exception:
                        pass
                self._finish(LoopReason.INVALID_OUTPUT, "capability returned wrong target/version/hash/parents")
                return
            draft_wall_time = round(time.perf_counter() - t_draft_start, 4)
            has_reported_usage = False
            draft_tokens = 0
            if isinstance(art.payload, Mapping) and "tokensUsed" in art.payload and art.payload["tokensUsed"] is not None:
                has_reported_usage = True
                draft_tokens = int(art.payload["tokensUsed"])
            elif self.persistence_client is not None:
                try:
                    state_res = self.persistence_client.resume_state(self.context.run_id)
                    child_ops = [
                        c_op for c_op in (state_res.operations or [])
                        if c_op.parentOperationId == intent.operation_id and getattr(c_op, "status", "").upper() == "COMPLETED"
                    ]
                    if child_ops:
                        has_reported_usage = True
                        draft_tokens = sum(int(getattr(c_op, "tokensUsed", 0) or 0) for c_op in child_ops)
                except Exception:
                    pass
            if has_reported_usage:
                self.context.budget_tracker.tokens_used = max(
                    0, self.context.budget_tracker.tokens_used - intent.token_reservation + draft_tokens
                )
            try:
                ack = self.persistence_client.save_draft_checkpoint(DraftCheckpointRequest(
                    runId=self.context.run_id, epoch=self.context.authority.epoch,
                    leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                    requestHash=intent.request_hash, artifact=art,
                    tokensUsed=int(draft_tokens),
                    wallTimeUsedSeconds=float(draft_wall_time),
                ))
            except CheckpointApiError as error:
                if error.status_code == 409:
                    self._finish(LoopReason.LEASE_LOST, error.message, aborted=True)
                    return
                raise
            if (ack.artifactId, ack.version, ack.contentHash) != (art.artifact_id, art.version, art.content_hash):
                raise ValueError("Durable draft acknowledgement mismatch")
            self._refresh_provider_token_accounting()
        self.journal.record_ack(intent.operation_id, art.content_hash)
        self._drafts[version] = art
        self.context.current_artifact = art
        self.context.budget_tracker.versions_used = max(self.context.budget_tracker.versions_used, version)
        if repair:
            self.context.budget_tracker.repairs_used += 1
            self._repair_attempts_this_generation += 1
            self.stagnation_detector.record_repair(art.content_hash)
        else:
            self._generated_versions += 1
            self._repair_attempts_this_generation = 0
            # P15: Do NOT clear the stagnation signal here. Previously the
            # consecutive-identical counter was reset on every generation, so a slot
            # that regenerated the same defective artifact three times looked like
            # three independent attempts and the version cap reported MAX_VERSIONS
            # instead of the truthful NO_PROGRESS. The last_content_hash stays in
            # place for the repair-identity comparison; `record_outcome` (called from
            # `_evaluate` once the evaluation outcome is known) carries the semantic
            # no-progress signal across regenerations.
            self.stagnation_detector.last_content_hash = art.content_hash
            self.stagnation_detector.consecutive_identical_count = 0
        self._latest_evaluations = []
        self.context.cursor.advance(LoopState.EVALUATING, intent.operation_id, art.content_hash,
                                    version, art.content_hash)
        self._checkpoint(intent.operation_id)

    def _error_evaluation(self, evaluator: EvaluatorCapability, art: ArtifactEnvelope,
                          intent: OperationIntent, detail: str) -> EvaluationResult:
        return EvaluationResult.create_error(
            evaluation_id=f"error_{hashlib.sha256(intent.operation_id.encode()).hexdigest()[:20]}",
            evaluator_id=evaluator.evaluator_id, evaluator_version=evaluator.evaluator_version,
            target_ref=art.to_ref(), error_message=detail,
        ).model_copy(update={"issues": [self.ledger_mgr.record_issue(
            code=IssueCode.EVALUATOR_UNAVAILABLE, severity=IssueSeverity.CRITICAL,
            scope=self.context.scope, message=detail, affected_refs=[art.to_ref()],
            reported_by=evaluator.evaluator_id,
        )]})

    async def _evaluate(self) -> None:
        art = self.context.current_artifact
        if art is None:
            self._finish(LoopReason.INVALID_OUTPUT, "evaluation has no durable artifact")
            return
        if not self.evaluators or set(self.policy.required_evaluator_ids) - {e.evaluator_id for e in self.evaluators}:
            missing = set(self.policy.required_evaluator_ids) - {e.evaluator_id for e in self.evaluators}
            self.ledger_mgr.record_issue(IssueCode.EVALUATOR_UNAVAILABLE, IssueSeverity.CRITICAL,
                                         self.context.scope, f"Required evaluators missing: {sorted(missing)}",
                                         [art.to_ref()])
            self._finish(LoopReason.MISSING_EVALUATOR, "required evaluators unavailable")
            return
        if not self._authority():
            return
        self.context.open_issues = tuple(self.ledger_mgr.get_open_issues())
        self._latest_evaluations = []
        for evaluator in self.evaluators:
            meta = getattr(evaluator, "metadata", None)
            if meta is not None:
                is_expensive = getattr(meta, "is_expensive", False) or getattr(evaluator, "is_expensive", False)
                est_tokens = getattr(meta, "estimated_tokens", 0)
                if not is_expensive or est_tokens == 0:
                    eval_token_res = 0
                else:
                    eval_token_res = min(self.policy.evaluate_token_reservation, est_tokens) if est_tokens > 0 else self.policy.evaluate_token_reservation
            else:
                is_expensive = getattr(evaluator, "is_expensive", False)
                est_tokens = getattr(evaluator, "estimated_tokens", 0)
                if not is_expensive or est_tokens == 0:
                    eval_token_res = 0
                else:
                    eval_token_res = min(self.policy.evaluate_token_reservation, est_tokens) if est_tokens > 0 else self.policy.evaluate_token_reservation
            intent = self._intent("EVALUATE", art.version, eval_token_res,
                                  f"{evaluator.evaluator_id}:{evaluator.evaluator_version}",
                                  {"ref": art.to_ref().model_dump(mode="json"),
                                   "parents": [r.model_dump(mode="json") for r in art.parent_refs]})
            if not self._reserve(intent):
                return
            op = self._operations.get(intent.operation_id)
            if op and op.status == "COMPLETED":
                result = self._stored_evaluations.get((evaluator.evaluator_id, art.version))
                if not op.resultRefJson:
                    raise ValueError("Completed evaluation operation lacks durable result JSON")
                try:
                    durable_result = EvaluationResult.model_validate_json(op.resultRefJson)
                except Exception as error:
                    raise ValueError("Completed evaluation operation has invalid durable result JSON") from error
                if result is not None and result != durable_result:
                    raise ValueError("Completed evaluation operation conflicts with the stored evaluation")
                result = result or durable_result
                if (
                    result.evaluator_id != evaluator.evaluator_id
                    or result.evaluator_version != evaluator.evaluator_version
                    or result.target_ref != art.to_ref()
                    or set(result.input_dependency_refs) != set(art.parent_refs)
                ):
                    raise ValueError("Completed evaluation operation result does not bind the exact target")
                self._stored_evaluations[(evaluator.evaluator_id, art.version)] = result
                self.journal.record_intent(intent, self.context.cursor.current_state)
            else:
                t_eval_start = time.perf_counter()
                try:
                    ev_meta_timeout = float(
                        getattr(getattr(evaluator, "metadata", None), "timeout_seconds", 0.0) or 0.0
                    )
                    # P06-05 fail-closed contract: the bounded wall reservation of a
                    # single EVALUATE operation is the *minimum* of all declared caps
                    # (operation budget, semantic-stage budget, and evaluator-declared
                    # metadata timeout). Using `max` would relax the bound and let a
                    # hanging evaluator pass through; the test demands the strictest
                    # bound wins so a runaway evaluator is killed and recorded as a
                    # fail-closed EVALUATOR_ERROR with TimeoutError evidence.
                    eval_timeout_candidates = [
                        self.policy.operation_wall_reservation_seconds,
                        self.policy.evaluator_semantic_timeout_seconds,
                    ]
                    if ev_meta_timeout > 0:
                        eval_timeout_candidates.append(ev_meta_timeout)
                    eval_timeout = min(eval_timeout_candidates)
                    remaining_wall = (
                        max(
                            0.001,
                            self.policy.max_wall_time_seconds - self.context.budget_tracker.get_elapsed_seconds(),
                        )
                        if not self.policy.is_unlimited
                        else 900.0
                    )
                    effective_timeout = (
                        eval_timeout if self.policy.is_unlimited else min(eval_timeout, remaining_wall)
                    )
                    from app.providers.replay import provider_replay_only
                    with provider_replay_only(self._recovery_responses.get(intent.operation_id)) as replay:
                        result = await asyncio.wait_for(
                            evaluator.evaluate(self.context, art, intent.operation_id),
                            timeout=effective_timeout,
                        )
                    if replay is not None and replay.failure:
                        self._finish(LoopReason.UNKNOWN_OUTCOME, replay.failure)
                        return
                    if not isinstance(result, EvaluationResult) or result.evaluator_id != evaluator.evaluator_id or \
                       result.evaluator_version != evaluator.evaluator_version or result.target_ref != art.to_ref() or \
                       set(result.input_dependency_refs) != set(art.parent_refs):
                        logger.error(
                            "Evaluator %s mismatch: is_instance=%s, id_match=(%s vs %s), ver_match=(%s vs %s), target_match=(%s vs %s), dep_match=(%d vs %d, set_diff=%s)",
                            evaluator.evaluator_id,
                            isinstance(result, EvaluationResult),
                            getattr(result, "evaluator_id", None), evaluator.evaluator_id,
                            getattr(result, "evaluator_version", None), evaluator.evaluator_version,
                            getattr(result, "target_ref", None), art.to_ref(),
                            len(getattr(result, "input_dependency_refs", [])), len(art.parent_refs),
                            set(getattr(result, "input_dependency_refs", [])) ^ set(art.parent_refs),
                        )
                        raise ValueError(f"Evaluator result does not bind exact target/parents/version: {evaluator.evaluator_id}")
                except asyncio.CancelledError:
                    raise
                except Exception as error:
                    if intent.operation_id in self._recovery_responses:
                        self._finish(LoopReason.UNKNOWN_OUTCOME, f"read-only evaluator recovery requires reconciliation: {error}")
                        return
                    logger.error("Evaluator %s failed: %s: %s", evaluator.evaluator_id, type(error).__name__, error, exc_info=True)
                    result = self._error_evaluation(evaluator, art, intent,
                                                    f"Evaluator {evaluator.evaluator_id} error: {type(error).__name__}: {error}")
                if self._block_unresolved_provider_operations():
                    return
                try:
                    self.persistence_client.reconcile_operation(OperationReconcileRequest(
                        runId=self.context.run_id, epoch=self.context.authority.epoch,
                        leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                        tokensUsed=0,
                        accountingType="REPORTED",
                        wallTimeUsedSeconds=round(time.perf_counter() - t_eval_start, 4),
                        resultRefJson=result.model_dump_json(by_alias=True),
                        resolvedFingerprints=list(result.resolved_issue_fingerprints or []),
                    ))
                except CheckpointApiError as error:
                    if error.status_code == 409:
                        self._finish(LoopReason.LEASE_LOST, error.message, aborted=True)
                        return
                    raise
                actual_eval_tokens = result.usage.total_tokens if (result.usage and result.usage.total_tokens is not None) else 0
                self.context.budget_tracker.tokens_used = max(0, self.context.budget_tracker.tokens_used - intent.token_reservation + actual_eval_tokens)
                self._refresh_provider_token_accounting()
                self._stored_evaluations[(evaluator.evaluator_id, art.version)] = result
            self.journal.record_ack(intent.operation_id, result.evaluation_id)
            self.ledger_mgr.reconcile_evaluation(result)
            self._latest_evaluations.append(result)
            self._checkpoint(intent.operation_id)
        for er in self._latest_evaluations:
            if er.issues:
                logger.info("Evaluator %s reported %d issues: %s", er.evaluator_id, len(er.issues), [(i.code.value, i.severity.value, i.message[:60]) for i in er.issues[:5]])
            self._checkpoint(intent.operation_id)
        fresh, stale = DependencyValidator.validate_dependency_freshness(art, self.accepted_dependencies)
        self.oscillation_detector.record_state(art.content_hash, self.ledger_mgr.get_open_fingerprints())
        # P15: Record the semantic, volatile-field-immune outcome fingerprint BEFORE
        # deciding, so three regenerations of the same defective artifact surface as
        # NO_PROGRESS on the second repeat instead of exhausting the version budget and
        # being misattributed to MAX_VERSIONS.
        self.stagnation_detector.record_outcome(
            normalized_outcome_fingerprint(
                art.payload, set(semantic_issue_identities(self.ledger_mgr.get_open_issues()))
            )
        )
        decision = self.controller.decide(
            self.context, self.ledger_mgr, self._latest_evaluations,
            self.stagnation_detector, self.oscillation_detector, fresh, stale,
            self._repair_attempts_this_generation, self._generated_versions,
            self.repairer is not None,
        )
        self._latest_decision = decision
        if decision.decision == DecisionType.PASS:
            if self.accept_head:
                if self._accepted_head and self._accepted_head.version != art.version:
                    self._expected_head_version = self._accepted_head.version
                    self._expected_head_hash = self._accepted_head.content_hash
                self._checkpoint()
                await self._accept(art)
                return
            else:
                self.context.accepted_artifact = art
                self.context.cursor.advance(LoopState.COMPLETED)
                self._checkpoint()
                return
        self.context.cursor.advance(decision.next_state)
        self._checkpoint()

    async def _accept(self, art: ArtifactEnvelope) -> None:
        if not self._authority():
            return
        fresh, _ = DependencyValidator.validate_dependency_freshness(art, self.accepted_dependencies)
        again = self.controller.decide(
            self.context, self.ledger_mgr, self._latest_evaluations,
            self.stagnation_detector, self.oscillation_detector, fresh,
            repair_attempts_this_version=self._repair_attempts_this_generation,
            generated_versions=self._generated_versions, has_repairer=self.repairer is not None,
        )
        if again.decision != DecisionType.PASS:
            self._latest_decision = again
            self.context.cursor.advance(again.next_state)
            self._checkpoint()
            return

        # Pre-acceptance validation: coverage, version/refs fresh check, and no non-pass
        eval_ids = {e.evaluator_id for e in self._latest_evaluations}
        missing_req = set(self.policy.required_evaluator_ids) - eval_ids
        if missing_req:
            self._finish(LoopReason.MISSING_EVALUATOR, f"Cannot accept: missing required evaluations {sorted(missing_req)}")
            return
        for ev in self._latest_evaluations:
            if ev.status != EvaluationStatus.PASS:
                self._finish(LoopReason.EVALUATOR_ERROR, f"Cannot accept: evaluation {ev.evaluator_id} has non-passing status {ev.status.value}")
                return
            if ev.target_ref != art.to_ref() or set(ev.input_dependency_refs) != set(art.parent_refs):
                self._finish(LoopReason.STALE_DEPENDENCY, f"Cannot accept: evaluation {ev.evaluator_id} target/parent refs do not match artifact")
                return
            if not getattr(ev, "evaluator_version", None) or not str(ev.evaluator_version).strip():
                self._finish(LoopReason.EVALUATOR_ERROR, f"Cannot accept: evaluation {ev.evaluator_id} missing evaluator_version")
                return
        intent = self._intent("CHECKPOINT_COMMIT", art.version, 0, art.content_hash,
                              {"evaluations": [e.evaluation_id for e in self._latest_evaluations],
                               "head": self._expected_head_version,
                               "headHash": self._expected_head_hash})
        if not self._reserve(intent):
            return
        op = self._operations.get(intent.operation_id)
        # Only a durably COMPLETED operation is safe to skip committing for: that is
        # the idempotent-replay case where a previous run already persisted this exact
        # head. Any other op record (absent, or a RESERVED commit left behind by a
        # crash mid-accept) still has to go through commit_checkpoint, otherwise the
        # operation is stranded RESERVED and the cursor save below would reference a
        # lastOperationId that is not COMPLETED.
        if op is not None and op.status == "COMPLETED":
            if self._accepted_head is None or self._accepted_head.to_ref() != art.to_ref():
                raise ValueError("Completed accept operation has no matching accepted head")
            # _reserve returns early for an existing operation without journalling it.
            self.journal.record_intent(intent, self.context.cursor.current_state)
        else:
            try:
                ack = self.persistence_client.commit_checkpoint(CheckpointCommitRequest(
                    runId=self.context.run_id, epoch=self.context.authority.epoch,
                    leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                    requestHash=intent.request_hash, artifact=art,
                    evaluations=self._latest_evaluations, decision=self._latest_decision,
                    expectedHeadVersion=self._expected_head_version,
                    expectedHeadHash=self._expected_head_hash,
                ))
            except CheckpointApiError as error:
                if error.status_code == 409:
                    self._finish(LoopReason.LEASE_LOST, f"FENCED_COMMIT_REJECTED: {error.message}", aborted=True)
                    return
                raise
            if (ack.artifactId, ack.version, ack.contentHash) != (art.artifact_id, art.version, art.content_hash):
                raise ValueError("Accepted head acknowledgement mismatch")
        self.journal.record_ack(intent.operation_id, art.content_hash)
        self.context.accepted_artifact = art
        for v in range(1, art.version):
            if prev_art := self._drafts.get(v):
                self.ledger_mgr.supersede_replaced_version(prev_art.to_ref(), art.to_ref())
        self._accepted_head = art
        self._expected_head_version = art.version
        self._expected_head_hash = art.content_hash
        self.context.cursor.advance(LoopState.COMPLETED, intent.operation_id, art.content_hash,
                                    art.version, art.content_hash)
        self._checkpoint(intent.operation_id)

    async def run(self) -> LoopResult:
        self._restore()
        while self.context.cursor.current_state not in (LoopState.COMPLETED, LoopState.FAILED, LoopState.ABORTED):
            self._total_iterations += 1
            if not self._authority():
                break
            state = self.context.cursor.current_state
            if state in (LoopState.INITIALIZED, LoopState.DRAFTING):
                await self._draft(repair=False)
            elif state == LoopState.REPAIRING:
                await self._draft(repair=True)
            elif state == LoopState.EVALUATING:
                await self._evaluate()
            else:
                self._finish(LoopReason.INVALID_OUTPUT, f"Unsupported runtime state {state.value}")
        if self._latest_decision is None:
            raise ValueError("Terminal state has no durable decision")
        b = self.context.budget_tracker
        return LoopResult(
            runId=self.context.run_id, decision=self._latest_decision.decision,
            terminalState=self.context.cursor.current_state,
            acceptedArtifact=self.context.accepted_artifact,
            terminalReason=self._latest_decision.reason,
            terminalReasonCode=self._latest_decision.reason_code or LoopReason.INVALID_OUTPUT,
            totalIterations=self._total_iterations, versionsCount=b.versions_used,
            repairsCount=b.repairs_used, callsCount=b.calls_used,
            tokensConsumed=b.tokens_used, wallTimeSeconds=b.get_elapsed_seconds(),
            ledger=self.ledger_mgr.to_ledger(), latestDecision=self._latest_decision,
        )
