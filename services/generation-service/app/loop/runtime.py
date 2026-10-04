"""Generic bounded generate/evaluate/decide/repair runtime; no domain or provider logic."""
from __future__ import annotations

import asyncio
import hashlib
import json
import time
from datetime import datetime, timezone
from collections.abc import Sequence
from typing import Any
from uuid import uuid4

from pydantic import Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import IssueCode, IssueLedger, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.loop.capabilities import EvaluatorCapability, GeneratorCapability, RepairerCapability
from app.loop.context import BudgetTracker, LoopContext, ResumeCursor
from app.loop.controller import LoopController
from app.loop.dependencies import DependencyValidator
from app.loop.detectors import OscillationDetector, StagnationDetector
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
        self._total_iterations = 0
        self._operations: dict[str, OperationResumeInfo] = {}
        self._drafts: dict[int, ArtifactEnvelope] = {}
        self._stored_evaluations: dict[tuple[str, int], EvaluationResult] = {}
        self._accepted_head: ArtifactEnvelope | None = None

    def _envelope(self, info: ArtifactResumeInfo) -> ArtifactEnvelope:
        if not info.envelopeJson:
            raise ValueError("Resume artifact lacks exact immutable envelope")
        art = ArtifactEnvelope.model_validate_json(info.envelopeJson)
        if (art.run_id != self.context.run_id or art.artifact_id != info.artifactId or
            art.version != info.acceptedVersion or art.content_hash != info.acceptedHash or
            not art.verify_integrity()):
            raise ValueError("Corrupt or mismatched durable artifact envelope")
        return art

    def _restore(self) -> None:
        state: ResumeStateResult = self.persistence_client.resume_state(self.context.run_id)
        if not state.isCompatible or state.epoch != self.context.authority.epoch:
            raise ValueError(f"Incompatible or stale run authority: {state.incompatibilityReason}")
        if state.status.upper() not in ("RUNNING", "COMPLETED"):
            raise ValueError(f"Run is not active: {state.status}")
        self._operations = {op.operationId: op for op in state.operations or []}
        self._drafts = {i.acceptedVersion: self._envelope(i) for i in state.draftArtifacts or []
                        if i.artifactId == self.context.target_artifact_id}
        accepted = next((i for i in state.artifacts if i.artifactId == self.context.target_artifact_id), None)
        self._accepted_head = self._envelope(accepted) if accepted else None
        self._stored_evaluations = {
            (ev.evaluator_id, ev.target_ref.version): ev for ev in state.evaluations or []
            if ev.target_ref.artifact_id == self.context.target_artifact_id
        }
        checkpoints = [c for c in state.loopCursors or [] if c.artifactId == self.context.target_artifact_id]
        if len(checkpoints) > 1:
            raise ValueError("Duplicate durable loop cursors")
        if checkpoints:
            checkpoint = checkpoints[0]
            payload = json.loads(checkpoint.stateJson)
            if (LoopPolicy.model_validate(payload["policy"]) != self.policy or
                payload["targetArtifactId"] != self.context.target_artifact_id or
                payload["scope"] != self.context.scope.value or
                payload["policyVersion"] != self.context.policy_version):
                raise ValueError("Pinned loop policy or target changed during resume")
            self.context.cursor = ResumeCursor.model_validate(payload["cursor"])
            if self.context.cursor.revision != checkpoint.revision:
                raise ValueError("Cursor revision does not match durable CAS revision")
            self.context.budget_tracker = BudgetTracker.model_validate(payload["budget"])
            self.ledger_mgr = IssueLedgerManager.from_dict(payload["ledger"])
            self.stagnation_detector = StagnationDetector.model_validate(payload["stagnation"])
            self.oscillation_detector = OscillationDetector.model_validate(payload["oscillation"])
            self._repair_attempts_this_generation = payload["repairsSinceGeneration"]
            self._generated_versions = payload["generatedVersions"]
            self._expected_head_version = payload.get("expectedHeadVersion")
            self._latest_evaluations = [EvaluationResult.model_validate(e) for e in payload["evaluations"]]
            self._latest_decision = (LoopDecision.model_validate(payload["decision"])
                                     if payload.get("decision") else None)
            ref = ArtifactRef.model_validate(payload["currentRef"]) if payload.get("currentRef") else None
            if ref:
                self.context.current_artifact = self._drafts.get(ref.version) or self._accepted_head
                if not self.context.current_artifact or self.context.current_artifact.to_ref() != ref:
                    raise ValueError("Cursor points to missing or mismatched durable artifact")
            self.context.input_dependencies = tuple(ArtifactRef.model_validate(r) for r in payload["inputDependencies"])
            if "journal" in payload:
                entries = [JournalEntry.model_validate(e) for e in payload["journal"]]
                self.journal = StepJournal.from_entries(
                    self.context.run_id,
                    entries,
                    persistence_client=self.persistence_client,
                    authority=self.context.authority,
                )
        elif (
            any(
                op.artifactId == self.context.target_artifact_id
                or op.operationId.startswith(f"loop:{self.context.run_id}:{self.context.target_artifact_id}:")
                for op in self._operations.values()
            )
            or self._drafts
            or self._accepted_head
        ):
            raise ValueError("Durable work exists without a pinned loop cursor")
        # Reservations, including UNKNOWN_OUTCOME, are not refunded by restart.
        b = self.context.budget_tracker
        b.calls_used = max(b.calls_used, state.callsUsed)
        b.tokens_used = max(b.tokens_used, state.tokensUsed)
        b.wall_time_used_seconds = max(b.wall_time_used_seconds, state.wallTimeUsedSeconds)
        if self._accepted_head and self.context.cursor.current_state == LoopState.COMPLETED:
            fresh, _ = DependencyValidator.validate_dependency_freshness(self._accepted_head, self.accepted_dependencies)
            if not fresh or any(i.isStale for i in state.artifacts if i.artifactId == self.context.target_artifact_id):
                self.context.current_artifact = self._accepted_head
                self.context.accepted_artifact = None
                self.context.cursor.current_state = LoopState.EVALUATING
            elif (self._latest_decision is None or self._latest_decision.decision != DecisionType.PASS or
                  self.ledger_mgr.has_unresolved_blockers() or not self.policy.required_evaluator_ids or
                  set(self.policy.required_evaluator_ids) - {e.evaluator_id for e in self._latest_evaluations} or
                  any(e.status != EvaluationStatus.PASS or e.target_ref != self._accepted_head.to_ref()
                      for e in self._latest_evaluations)):
                raise ValueError("Accepted resume cursor lacks required fresh PASS evidence")
            else:
                self.context.accepted_artifact = self._accepted_head
        if not checkpoints:
            self._checkpoint()

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
            "evaluations": [e.model_dump(mode="json", by_alias=True) for e in self._latest_evaluations],
            "decision": self._latest_decision.model_dump(mode="json", by_alias=True) if self._latest_decision else None,
            "journal": [e.model_dump(mode="json", by_alias=True) for e in self.journal.entries],
            "currentRef": (self.context.current_artifact.to_ref().model_dump(mode="json", by_alias=True)
                           if self.context.current_artifact else None),
        }
        request = LoopCursorCheckpointRequest(
            runId=self.context.run_id, epoch=self.context.authority.epoch,
            leaseOwner=self.context.authority.lease_owner,
            artifactId=self.context.target_artifact_id, expectedRevision=revision,
            stateJson=json.dumps(payload, sort_keys=True, separators=(",", ":")),
            lastOperationId=last_operation_id,
        )
        try:
            ack = self.persistence_client.save_loop_cursor(request)
            if ack.revision != cursor.revision or ack.stateJson != request.stateJson:
                raise ValueError("Cursor acknowledgement mismatch")
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
                self.policy.operation_wall_reservation_seconds
                if kind in ("GENERATE", "REPAIR")
                else (15.0 if kind == "EVALUATE" else 0.0)
            ),
            payload_for_hash=json.dumps(extra, sort_keys=True, default=str),
        )

    def _reserve(self, intent: OperationIntent) -> bool:
        op = self._operations.get(intent.operation_id)
        if op:
            if op.requestHash != intent.request_hash or op.artifactId != intent.target_artifact_id:
                raise ValueError("Operation replay hash or target mismatch")
            if op.status != "COMPLETED":
                self._finish(LoopReason.UNKNOWN_OUTCOME, f"unacknowledged operation {intent.operation_id}")
                return False
            return True
        if not self._authority():
            return False
        b = self.context.budget_tracker
        parent_op = getattr(self.context, "parent_operation_id", None)
        if intent.operation_type != "CHECKPOINT_COMMIT":
            if not parent_op:
                if b.calls_used + 1 > self.policy.max_total_calls:
                    self._finish(LoopReason.CALL_CAP, "next operation exceeds shared call cap")
                    return False
            if b.tokens_used + intent.token_reservation > self.policy.max_total_tokens:
                self._finish(LoopReason.TOKEN_CAP, "next reservation exceeds token cap")
                return False
            now_utc = datetime.now(timezone.utc)
            actual_elapsed = (now_utc - b.started_at).total_seconds()
            if actual_elapsed + intent.wall_time_reservation_seconds > self.policy.max_wall_time_seconds:
                self._finish(LoopReason.WALL_TIME_CAP, "next reservation exceeds deadline")
                return False
        self.journal.record_intent(intent, self.context.cursor.current_state)
        sec_id = None
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
                self._finish(LoopReason.TOKEN_CAP, error.message)
                return False
            raise
        if grant.operationId != intent.operation_id or grant.tokenReservation != intent.token_reservation:
            raise ValueError("Operation grant acknowledgement mismatch")
        if grant.isReplay:
            # A grant replay is not proof that the external operation never executed.
            self._finish(LoopReason.UNKNOWN_OUTCOME, "grant replay without committed outcome")
            return False
        if intent.operation_type != "CHECKPOINT_COMMIT":
            if not parent_op:
                b.calls_used += 1
            b.tokens_used += intent.token_reservation
            now_utc = datetime.now(timezone.utc)
            b.wall_time_used_seconds = max(b.wall_time_used_seconds, (now_utc - b.started_at).total_seconds())
        self.journal.mark_execution_started(intent.operation_id)
        return True

    def _artifact_valid(self, artifact: Any, version: int) -> bool:
        return (isinstance(artifact, ArtifactEnvelope) and artifact.run_id == self.context.run_id and
                artifact.artifact_id == self.context.target_artifact_id and
                artifact.artifact_type == self.context.target_artifact_type and
                artifact.version == version and artifact.verify_integrity() and
                tuple(artifact.parent_refs) == tuple(self.context.input_dependencies))

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
        if op:
            art = self._drafts.get(version)
            if art is None or not self._artifact_valid(art, version):
                raise ValueError("Completed draft operation lacks exact durable artifact")
            self.journal.record_intent(intent, self.context.cursor.current_state)
        else:
            try:
                art = (await self.repairer.repair(self.context, old, issues, intent.operation_id, version)
                       if repair else await self.generator.generate(self.context, intent.operation_id, version))
            except asyncio.CancelledError:
                raise
            except Exception as error:
                if repair and self._generated_versions < self.policy.max_generated_versions:
                    self.context.cursor.advance(LoopState.DRAFTING)
                    self._checkpoint()
                    return
                self._finish(LoopReason.INVALID_OUTPUT, f"capability failed: {type(error).__name__}: {error}")
                return
            if not self._artifact_valid(art, version):
                self._finish(LoopReason.INVALID_OUTPUT, "capability returned wrong target/version/hash/parents")
                return
            try:
                ack = self.persistence_client.save_draft_checkpoint(DraftCheckpointRequest(
                    runId=self.context.run_id, epoch=self.context.authority.epoch,
                    leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                    requestHash=intent.request_hash, artifact=art,
                    tokensUsed=intent.token_reservation,
                    wallTimeUsedSeconds=intent.wall_time_reservation_seconds,
                ))
            except CheckpointApiError as error:
                if error.status_code == 409:
                    self._finish(LoopReason.LEASE_LOST, error.message, aborted=True)
                    return
                raise
            if (ack.artifactId, ack.version, ack.contentHash) != (art.artifact_id, art.version, art.content_hash):
                raise ValueError("Durable draft acknowledgement mismatch")
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
            intent = self._intent("EVALUATE", art.version, self.policy.evaluate_token_reservation,
                                  f"{evaluator.evaluator_id}:{evaluator.evaluator_version}",
                                  {"ref": art.to_ref().model_dump(mode="json"),
                                   "parents": [r.model_dump(mode="json") for r in art.parent_refs]})
            if not self._reserve(intent):
                return
            op = self._operations.get(intent.operation_id)
            if op:
                result = self._stored_evaluations.get((evaluator.evaluator_id, art.version))
                if result is None or result.evaluation_id not in (op.resultRefJson or ""):
                    raise ValueError("Completed evaluation operation lacks matching durable result")
                self.journal.record_intent(intent, self.context.cursor.current_state)
            else:
                t_eval_start = time.perf_counter()
                try:
                    result = await asyncio.wait_for(
                        evaluator.evaluate(self.context, art, intent.operation_id),
                        timeout=min(self.policy.operation_wall_reservation_seconds,
                                    max(0.001, self.policy.max_wall_time_seconds -
                                        self.context.budget_tracker.get_elapsed_seconds())),
                    )
                    if not isinstance(result, EvaluationResult) or result.evaluator_id != evaluator.evaluator_id or \
                       result.evaluator_version != evaluator.evaluator_version or result.target_ref != art.to_ref() or \
                       set(result.input_dependency_refs) != set(art.parent_refs):
                        raise ValueError("Evaluator result does not bind exact target/parents/version")
                except asyncio.CancelledError:
                    raise
                except Exception as error:
                    result = self._error_evaluation(evaluator, art, intent,
                                                    f"Evaluator {evaluator.evaluator_id} error: {type(error).__name__}")
                if result.status == EvaluationStatus.ERROR and not result.issues:
                    result = self._error_evaluation(evaluator, art, intent, "Evaluator returned ERROR without evidence")
                try:
                    self.persistence_client.reconcile_operation(OperationReconcileRequest(
                        runId=self.context.run_id, epoch=self.context.authority.epoch,
                        leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                        tokensUsed=intent.token_reservation,
                        wallTimeUsedSeconds=round(time.perf_counter() - t_eval_start, 4),
                        resultRefJson=result.model_dump_json(by_alias=True),
                        resolvedFingerprints=list(result.resolved_issue_fingerprints or []),
                    ))
                except CheckpointApiError as error:
                    if error.status_code == 409:
                        self._finish(LoopReason.LEASE_LOST, error.message, aborted=True)
                        return
                    raise
                self._stored_evaluations[(evaluator.evaluator_id, art.version)] = result
            self.journal.record_ack(intent.operation_id, result.evaluation_id)
            self.ledger_mgr.reconcile_evaluation(result)
            self._latest_evaluations.append(result)
            self.context.cursor.advance(LoopState.EVALUATING, intent.operation_id, result.evaluation_id,
                                        art.version, art.content_hash)
            self._checkpoint(intent.operation_id)
        fresh, stale = DependencyValidator.validate_dependency_freshness(art, self.accepted_dependencies)
        self.oscillation_detector.record_state(art.content_hash, self.ledger_mgr.get_open_fingerprints())
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
        intent = self._intent("CHECKPOINT_COMMIT", art.version, 0, art.content_hash,
                              {"evaluations": [e.evaluation_id for e in self._latest_evaluations],
                               "head": self._expected_head_version})
        if not self._reserve(intent):
            return
        op = self._operations.get(intent.operation_id)
        if op:
            if self._accepted_head is None or self._accepted_head.to_ref() != art.to_ref():
                raise ValueError("Completed accept operation has no matching accepted head")
            self.journal.record_intent(intent, self.context.cursor.current_state)
        else:
            try:
                ack = self.persistence_client.commit_checkpoint(CheckpointCommitRequest(
                    runId=self.context.run_id, epoch=self.context.authority.epoch,
                    leaseOwner=self.context.authority.lease_owner, operationId=intent.operation_id,
                    requestHash=intent.request_hash, artifact=art,
                    evaluations=self._latest_evaluations, decision=self._latest_decision,
                    expectedHeadVersion=self._expected_head_version,
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
