"""One fenced, durable stage protocol; provider dispatch belongs to ProviderGateway.

The cursor is a CAS claim, not a second persistence authority. Draft and acceptance
transactions carry its revision so a superseded writer cannot publish a result.
"""
from __future__ import annotations

import asyncio
import hashlib
import json
import logging
from collections.abc import Awaitable, Callable, Sequence
from dataclasses import asdict, dataclass, replace
from enum import Enum
from typing import Any, Protocol
from uuid import UUID, uuid4

from app.contracts.artifact import (
    ArtifactEnvelope, ArtifactRef, ArtifactType, canonical_json_dump,
)
from app.contracts.evaluation import EvaluationResult
from app.contracts.issue import IssueScope
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.persistence.client import (
    CheckpointApiError,
    CheckpointClient,
    canonicalize_artifact_id,
    get_artifact_aliases,
)
from app.persistence.models import (
    ArtifactResumeInfo, CheckpointCommitRequest, DraftCheckpointRequest,
    LoopCursorCheckpointRequest, OperationGrantRequest, ResumeStateResult,
)

PRODUCER_VERSION = "stage-executor/1.0.0"
PROTOCOL_VERSION = 1

logger = logging.getLogger(__name__)
STAGE_REQUIRED_EVALUATORS: dict[ArtifactType, tuple[str, ...]] = {
    ArtifactType.SOURCE_PACK: ("eval_source",),
    ArtifactType.EVIDENCE_GRAPH: ("eval_evidence_graph",),
    ArtifactType.EXAM_BLUEPRINT: ("eval_blueprint",),
    ArtifactType.PASSAGE: ("eval_passage_word_count", "eval_passage_fidelity", "eval_passage_semantic"),
    ArtifactType.QUESTION: (
        "eval_question_structure", "eval_answer_verbatim_length", "eval_evidence_offsets",
        "eval_question_uniqueness", "eval_question_semantic", "eval_blind_solver_adversary",
    ),
    ArtifactType.SECTION: ("eval_section_structure", "eval_section_editorial"),
    ArtifactType.READING_PAPER: (
        "eval_paper_structure", "eval_paper_cross_section", "eval_paper_leakage",
        "eval_paper_monotony", "eval_paper_closure",
    ),
}

class RunAuthority(Protocol):
    run_id: str
    job_id: UUID
    epoch: int
    lease_owner: UUID
    policy_hash: str


class ExecutionPolicy(Protocol):
    @property
    def hash(self) -> str: ...


class StageState(str, Enum):
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    EVALUATING = "EVALUATING"
    ACCEPTED = "ACCEPTED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
    UNKNOWN_OUTCOME = "UNKNOWN_OUTCOME"


class RecoveryKind(str, Enum):
    FRESH = "FRESH"
    RESUME_DRAFT = "RESUME_DRAFT"
    RESUME_EVALUATION = "RESUME_EVALUATION"
    BLOCKED_UNKNOWN = "BLOCKED_UNKNOWN"
    ACCEPTED = "ACCEPTED"


class StageExecutorError(RuntimeError):
    def __init__(self, artifact_id: str, reason: str):
        super().__init__(f"{artifact_id}: {reason}")
        self.artifact_id, self.reason = artifact_id, reason


class InvalidEpochError(StageExecutorError):
    """The authoritative fencing epoch changed."""


class RunNotActiveError(StageExecutorError):
    """The run is incompatible, cancelled, failed, or not running."""


class LeaseLostError(StageExecutorError):
    """A fenced persistence write refused the lease owner."""


class CursorConflictError(StageExecutorError):
    """A different writer advanced this exact stage scope."""


class PolicyHashMismatchError(StageExecutorError):
    """The request or durable cursor differs from the pinned run policy."""


class DependencyMissingError(StageExecutorError):
    """A declared dependency has no accepted authoritative head."""


class DependencyStaleError(StageExecutorError):
    """A dependency or any ancestor is not the exact current accepted head."""


class ArtifactReuseRejectedError(StageExecutorError):
    """A stored artifact lacks exact immutable integrity or PASS provenance."""


class InvalidTransitionError(StageExecutorError):
    """The requested stage transition is not safe."""


class StageFailedError(StageExecutorError):
    """A known capability failure was recorded without accepting its draft."""


class UnresolvedProviderOutcomeError(StageExecutorError):
    def __init__(self, artifact_id: str, operation_ids: tuple[str, ...]):
        super().__init__(artifact_id, f"unresolved provider operations: {operation_ids}")
        self.operation_ids = operation_ids


class EvaluationRejectedError(StageExecutorError):
    def __init__(self, artifact: ArtifactEnvelope, evaluations: tuple[EvaluationResult, ...], reason: str):
        super().__init__(artifact.artifact_id, reason)
        self.artifact, self.evaluations = artifact, evaluations


@dataclass(frozen=True)
class ExecutorStats:
    stages_started: int = 0
    stages_resumed: int = 0
    artifacts_reused: int = 0
    drafts_persisted: int = 0
    acceptances_committed: int = 0
    failures: int = 0
    cas_conflicts: int = 0
    unresolved_provider_outcomes: int = 0
    evaluation_rejections: int = 0
    stage_commit_tokens: int = 0

    def as_dict(self) -> dict[str, int]:
        return asdict(self)


@dataclass(frozen=True)
class RecoveryDecision:
    kind: RecoveryKind
    draft_version: int | None = None
    accepted_version: int | None = None
    reason: str = ""
    blocking_operation_ids: tuple[str, ...] = ()


@dataclass(frozen=True)
class StageSnapshot:
    artifact_id: str
    revision: int = 0
    state: StageState = StageState.PENDING
    policy_hash: str = ""
    request_hash: str = ""
    target_version: int = 0
    target_hash: str | None = None
    accepted_hash: str | None = None
    expected_head_version: int | None = None
    expected_head_hash: str | None = None
    attempts: int = 0
    invocation_id: str = ""
    evaluations: tuple[EvaluationResult, ...] = ()
    reason: str = ""

    def serialized(self) -> str:
        return canonical_json_dump({
            "protocolVersion": PROTOCOL_VERSION, "state": self.state.value,
            "policyHash": self.policy_hash, "requestHash": self.request_hash,
            "targetVersion": self.target_version, "targetHash": self.target_hash,
            "acceptedHash": self.accepted_hash,
            "expectedHeadVersion": self.expected_head_version,
            "expectedHeadHash": self.expected_head_hash, "attempts": self.attempts,
            "invocationId": self.invocation_id, "reason": self.reason,
            "evaluations": [e.model_dump(mode="json", by_alias=True) for e in self.evaluations],
        })


Generate = Callable[[int], Awaitable[Any]]
Evaluate = Callable[[ArtifactEnvelope], Awaitable[list[EvaluationResult]]]


class StageExecutor:
    def __init__(self, client: CheckpointClient, context: RunAuthority, policy: ExecutionPolicy,
                 *, required_evaluator_ids: tuple[str, ...] = ()):
        if len(set(required_evaluator_ids)) != len(required_evaluator_ids):
            raise ValueError("Duplicate required evaluator IDs")
        self.client, self.context, self.policy = client, context, policy
        self.required_evaluator_ids = tuple(required_evaluator_ids)
        self._stats = ExecutorStats()

    def snapshot_stats(self) -> ExecutorStats:
        return self._stats

    def _count(self, counter: str) -> None:
        self._stats = replace(self._stats, **{counter: getattr(self._stats, counter) + 1})

    async def _restore(self, artifact_id: str) -> ResumeStateResult:
        state = await self.client.resume_state_async(self.context.run_id)
        if state.runId != self.context.run_id or state.jobId != self.context.job_id:
            raise RunNotActiveError(artifact_id, "resume identity differs from request")
        if state.epoch != self.context.epoch:
            raise InvalidEpochError(artifact_id, f"epoch {self.context.epoch} fenced by {state.epoch}")
        if not state.isCompatible or state.status.upper() != "RUNNING":
            raise RunNotActiveError(artifact_id, f"run not active/compatible: {state.status}")
        if not state.policyHash or state.policyHash != self.context.policy_hash or self.policy.hash != state.policyHash:
            raise PolicyHashMismatchError(artifact_id, "request does not match authoritative pinned policy")
        return state

    def _snapshot(self, state: ResumeStateResult, artifact_id: str) -> StageSnapshot:
        cursors = [c for c in state.loopCursors or () if c.artifactId == artifact_id]
        if not cursors:
            return StageSnapshot(artifact_id=artifact_id, policy_hash=self.context.policy_hash)
        if len(cursors) != 1:
            raise ArtifactReuseRejectedError(artifact_id, "duplicate durable cursors")
        cursor = cursors[0]
        try:
            body = json.loads(cursor.stateJson)
            if "protocolVersion" in body:
                if body["protocolVersion"] != PROTOCOL_VERSION:
                    raise ValueError("unsupported protocol")
                snapshot = StageSnapshot(
                    artifact_id=artifact_id, revision=cursor.revision, state=StageState(body["state"]),
                    policy_hash=body["policyHash"], request_hash=body["requestHash"],
                    target_version=body["targetVersion"], target_hash=body["targetHash"],
                    accepted_hash=body["acceptedHash"], expected_head_version=body["expectedHeadVersion"],
                    expected_head_hash=body["expectedHeadHash"], attempts=body["attempts"],
                    invocation_id=body["invocationId"], reason=body["reason"],
                    evaluations=tuple(EvaluationResult.model_validate(e) for e in body["evaluations"]),
                )
                if snapshot.policy_hash != self.context.policy_hash:
                    raise PolicyHashMismatchError(artifact_id, "durable cursor policy hash differs")
            else:
                head = self._head(state, artifact_id)
                cur_state = StageState.ACCEPTED if head else StageState.RUNNING
                stored_evals = tuple(e for e in state.evaluations or () if e.target_ref.artifact_id == artifact_id)
                snapshot = StageSnapshot(
                    artifact_id=artifact_id,
                    revision=cursor.revision,
                    state=cur_state,
                    policy_hash=self.context.policy_hash,
                    request_hash="",
                    target_version=head.acceptedVersion if head else 1,
                    target_hash=head.acceptedHash if head else None,
                    accepted_hash=head.acceptedHash if head else None,
                    expected_head_version=None,
                    expected_head_hash=None,
                    attempts=1,
                    invocation_id="",
                    reason="",
                    evaluations=stored_evals,
                )
        except (ValueError, TypeError, KeyError) as error:
            raise ArtifactReuseRejectedError(artifact_id, "invalid stage cursor") from error
        return snapshot

    @staticmethod
    def _head(state: ResumeStateResult, artifact_id: str) -> ArtifactResumeInfo | None:
        heads = [a for a in state.artifacts if a.artifactId == artifact_id]
        if len(heads) > 1:
            raise ArtifactReuseRejectedError(artifact_id, "multiple accepted heads")
        return heads[0] if heads else None

    def _envelope(self, info: ArtifactResumeInfo) -> ArtifactEnvelope:
        try:
            if not info.envelopeJson:
                raise ValueError("exact envelope missing")
            art = ArtifactEnvelope.model_validate_json(info.envelopeJson)
            if (art.run_id != self.context.run_id or art.to_ref() != info.to_ref()
                    or tuple(art.parent_refs) != tuple(info.parentRefs) or not art.verify_integrity()):
                raise ValueError("immutable envelope identity/hash mismatch")
            return art
        except (ValueError, TypeError) as error:
            raise ArtifactReuseRejectedError(info.artifactId, "invalid authoritative envelope") from error

    def _closure(self, state: ResumeStateResult, parents: Sequence[ArtifactRef],
                 path: frozenset[str] = frozenset()) -> None:
        for ref in parents:
            if ref.artifact_id in path:
                raise DependencyStaleError(ref.artifact_id, "dependency cycle")
            head = self._head(state, ref.artifact_id)
            if head is None:
                raise DependencyMissingError(ref.artifact_id, "accepted dependency missing")
            if head.isStale or head.to_ref() != ref:
                raise DependencyStaleError(ref.artifact_id, "dependency is not exact current accepted head")
            art = self._envelope(head)
            self._closure(state, art.parent_refs, path | {ref.artifact_id})

    @staticmethod
    def _unknowns(state: ResumeStateResult, artifact_id: str) -> tuple[str, ...]:
        return tuple(op.operationId for op in state.operations or ()
                     if op.artifactId == artifact_id
                     and op.status.upper() not in ("COMPLETED", "FAILED", "CANCELLED")
                     and not (op.operationType == "CHECKPOINT_COMMIT" and op.status.upper() == "RESERVED"))

    async def _api(self, artifact_id: str, action: Callable[[], Awaitable[Any]]) -> Any:
        try:
            return await action()
        except CheckpointApiError as error:
            if error.status_code == 403:
                raise LeaseLostError(artifact_id, error.message) from error
            if error.status_code == 409:
                await self._restore(artifact_id)  # Disambiguates epoch/policy/run fencing first.
                self._count("cas_conflicts")
                raise CursorConflictError(artifact_id, error.message) from error
            raise

    async def _save(self, snapshot: StageSnapshot, **changes: Any) -> StageSnapshot:
        next_snapshot = replace(snapshot, **changes)
        request = LoopCursorCheckpointRequest(
            runId=self.context.run_id, epoch=self.context.epoch, leaseOwner=self.context.lease_owner,
            artifactId=snapshot.artifact_id, expectedRevision=snapshot.revision,
            stateJson=next_snapshot.serialized(),
        )
        ack = await self._api(snapshot.artifact_id,
                              lambda: asyncio.to_thread(self.client.save_loop_cursor, request))
        if (ack.artifactId != snapshot.artifact_id or ack.revision != snapshot.revision + 1
                or ack.stateJson != request.stateJson):
            raise CursorConflictError(snapshot.artifact_id, "cursor acknowledgement mismatch")
        return replace(next_snapshot, revision=ack.revision)

    async def _owned(self, snapshot: StageSnapshot, parents: tuple[ArtifactRef, ...]) -> ResumeStateResult:
        state = await self._restore(snapshot.artifact_id)
        latest = self._snapshot(state, snapshot.artifact_id)
        if latest.revision != snapshot.revision or latest.invocation_id != snapshot.invocation_id:
            self._count("cas_conflicts")
            raise CursorConflictError(snapshot.artifact_id, "stage claimed by another writer")
        self._closure(state, parents)
        return state

    def _draft(self, state: ResumeStateResult, snapshot: StageSnapshot) -> ArtifactEnvelope | None:
        drafts = [self._envelope(a) for a in state.draftArtifacts or ()
                  if a.artifactId == snapshot.artifact_id and a.acceptedVersion == snapshot.target_version]
        if len(drafts) > 1:
            raise ArtifactReuseRejectedError(snapshot.artifact_id, "duplicate immutable draft versions")
        if not drafts:
            return None
        art = drafts[0]
        if snapshot.target_hash is not None and snapshot.target_hash != art.content_hash:
            raise ArtifactReuseRejectedError(snapshot.artifact_id, "cursor/draft hash mismatch")
        return art

    def _validate_evaluations(self, artifact: ArtifactEnvelope, results: Any,
                              required: tuple[str, ...] | None = None) -> tuple[EvaluationResult, ...]:
        required = (
            self.required_evaluator_ids
            if self.required_evaluator_ids
            else (required if required is not None else STAGE_REQUIRED_EVALUATORS.get(artifact.artifact_type, ()))
        )
        if not isinstance(results, (tuple, list)) or not results or not all(
                isinstance(e, EvaluationResult) for e in results):
            raise EvaluationRejectedError(artifact, (), "required evaluations missing or malformed")
        evaluations = tuple(results)
        ids = [e.evaluator_id for e in evaluations]
        missing = set(required) - set(ids)
        invalid = (len(ids) != len(set(ids)) or bool(missing)
                   or any(not e.is_pass() or e.target_ref != artifact.to_ref()
                          or self._refs(e.input_dependency_refs) != self._refs(artifact.parent_refs)
                          for e in evaluations))
        if invalid:
            failed_evals = [f"{e.evaluator_id}:{e.status}:{[i.message for i in e.issues]}" for e in evaluations if not e.is_pass()]
            ref_mismatches = [f"{e.evaluator_id}:target={e.target_ref != artifact.to_ref()}:deps={self._refs(e.input_dependency_refs) != self._refs(artifact.parent_refs)}" for e in evaluations if e.target_ref != artifact.to_ref() or self._refs(e.input_dependency_refs) != self._refs(artifact.parent_refs)]
            logger.warning("Stage %s evaluation rejection: missing=%s, failed=%s, ref_mismatch=%s", artifact.artifact_id, sorted(missing), failed_evals, ref_mismatches)
            reason = f"missing required evaluations: {sorted(missing)}" if missing else f"evaluations rejected: failed={failed_evals}, ref_mismatches={ref_mismatches}"
            raise EvaluationRejectedError(artifact, evaluations, reason)
        return evaluations

    @staticmethod
    def _refs(refs: Sequence[ArtifactRef]) -> tuple[str, ...]:
        return tuple(sorted(canonical_json_dump(r) for r in refs))

    def _prior_pass(self, state: ResumeStateResult, snapshot: StageSnapshot,
                    artifact: ArtifactEnvelope) -> None:
        stored = tuple(e for e in state.evaluations or () if e.target_ref == artifact.to_ref())
        # The commit transaction owns evaluations; cursor evidence survives post-commit cursor crashes.
        records = stored or snapshot.evaluations
        try:
            self._validate_evaluations(artifact, records)
        except EvaluationRejectedError as error:
            raise ArtifactReuseRejectedError(artifact.artifact_id, error.reason) from error
        if snapshot.state == StageState.ACCEPTED and snapshot.accepted_hash != artifact.content_hash:
            raise ArtifactReuseRejectedError(artifact.artifact_id, "accepted cursor/head hash mismatch")

    async def get_accepted(self, artifact_id: str) -> ArtifactEnvelope | None:
        state = await self._restore(artifact_id)
        head = self._head(state, artifact_id)
        if head is None or head.isStale:
            return None
        unknown = self._unknowns(state, artifact_id)
        if unknown:
            raise UnresolvedProviderOutcomeError(artifact_id, unknown)
        artifact = self._envelope(head)
        self._closure(state, artifact.parent_refs)
        self._prior_pass(state, self._snapshot(state, artifact_id), artifact)
        return artifact

    async def classify_recovery(self, artifact_id: str) -> RecoveryDecision:
        state = await self._restore(artifact_id)
        snapshot = self._snapshot(state, artifact_id)
        unknown = self._unknowns(state, artifact_id)
        if unknown:
            return RecoveryDecision(RecoveryKind.BLOCKED_UNKNOWN, blocking_operation_ids=unknown)
        head = self._head(state, artifact_id)
        if head and not head.isStale:
            return RecoveryDecision(RecoveryKind.ACCEPTED, accepted_version=head.acceptedVersion)
        draft = self._draft(state, snapshot)
        if draft and snapshot.state in (StageState.RUNNING, StageState.EVALUATING, StageState.UNKNOWN_OUTCOME):
            return RecoveryDecision(RecoveryKind.RESUME_EVALUATION, draft_version=draft.version)
        return RecoveryDecision(RecoveryKind.RESUME_DRAFT if snapshot.revision else RecoveryKind.FRESH)

    async def _block_unknown(self, snapshot: StageSnapshot, unknown: tuple[str, ...]) -> None:
        self._count("unresolved_provider_outcomes")
        if snapshot.state != StageState.UNKNOWN_OUTCOME:
            await self._save(snapshot, state=StageState.UNKNOWN_OUTCOME, reason=f"Unresolved operations: {unknown}")
        raise UnresolvedProviderOutcomeError(snapshot.artifact_id, unknown)

    def _request_hash(self, artifact_id: str, artifact_type: ArtifactType,
                      parents: tuple[ArtifactRef, ...], section_id: int | None) -> str:
        required = self.required_evaluator_ids or STAGE_REQUIRED_EVALUATORS.get(artifact_type, ())
        return hashlib.sha256(canonical_json_dump({
            "artifactId": artifact_id, "artifactType": artifact_type.value,
            "parents": self._refs(parents), "policyHash": self.context.policy_hash,
            "sectionId": section_id, "requiredEvaluators": required,
        }).encode()).hexdigest()

    async def execute(
        self,
        artifact_id: str,
        artifact_type: ArtifactType,
        parents: tuple[ArtifactRef, ...],
        generate: Generate,
        evaluate: Evaluate,
        section_id: int | None = None,
        repair: Optional[Callable[..., Any]] = None,
    ) -> ArtifactEnvelope:
        artifact_id = canonicalize_artifact_id(artifact_id, self.context.run_id)
        parents = tuple(
            ArtifactRef(
                artifactId=canonicalize_artifact_id(p.artifact_id, self.context.run_id),
                artifactType=p.artifact_type,
                version=p.version,
                contentHash=p.content_hash,
            )
            for p in parents
        )
        if len({p.artifact_id for p in parents}) != len(parents) or any(p.artifact_id == artifact_id for p in parents):
            raise DependencyStaleError(artifact_id, "duplicate or self dependency")
        state = await self._restore(artifact_id)
        snapshot = self._snapshot(state, artifact_id)
        self._closure(state, parents)
        unknown = self._unknowns(state, artifact_id)
        if unknown:
            await self._block_unknown(snapshot, unknown)
        if snapshot.state == StageState.CANCELLED:
            raise InvalidTransitionError(artifact_id, "stage cancelled")
        request_hash = self._request_hash(artifact_id, artifact_type, parents, section_id)
        head = self._head(state, artifact_id)
        if head and not head.isStale and self._refs(head.parentRefs) == self._refs(parents):
            artifact = self._envelope(head)
            if artifact.artifact_type != artifact_type or artifact.section_id != section_id:
                raise ArtifactReuseRejectedError(artifact_id, "accepted artifact scope/type mismatch")
            self._prior_pass(state, snapshot, artifact)
            self._count("artifacts_reused")
            return artifact
        if snapshot.state == StageState.ACCEPTED and head is None:
            raise ArtifactReuseRejectedError(artifact_id, "accepted cursor lacks authoritative head")
        draft = self._draft(state, snapshot) if snapshot.request_hash == request_hash and snapshot.state in (
            StageState.RUNNING, StageState.EVALUATING, StageState.UNKNOWN_OUTCOME) else None
        if draft is not None and (self._refs(draft.parent_refs) != self._refs(parents)
                                  or draft.artifact_type != artifact_type or draft.section_id != section_id):
            raise ArtifactReuseRejectedError(artifact_id, "draft scope/dependency mismatch")
        # BoundedLoopRuntime is the single execution authority for all stages
        return await self._execute_bounded_loop(
            artifact_id=artifact_id,
            artifact_type=artifact_type,
            parents=parents,
            generate=generate,
            evaluate=evaluate,
            section_id=section_id,
            repair=repair,
            state=state,
        )
    async def _execute_bounded_loop(
        self,
        artifact_id: str,
        artifact_type: ArtifactType,
        parents: tuple[ArtifactRef, ...],
        generate: Generate,
        evaluate: Evaluate,
        section_id: int | None,
        repair: Optional[Callable[..., Any]],
        state: ResumeStateResult,
    ) -> ArtifactEnvelope:
        from app.loop.runtime import BoundedLoopRuntime
        from app.loop.context import LoopContext, AuthorityGrant
        from app.loop.policy import LoopPolicy
        from app.contracts.issue import IssueScope, Issue
        from app.contracts.evaluation import EvaluationStatus, EvaluationResult
        from app.loop.capabilities import GeneratorCapability, EvaluatorCapability, RepairerCapability
        from app.repair.question import QuestionItemRepairer

        # 1. Determine scope
        if artifact_type == ArtifactType.QUESTION:
            scope = IssueScope.QUESTION
        elif artifact_type == ArtifactType.PASSAGE:
            scope = IssueScope.PASSAGE
        elif artifact_type == ArtifactType.READING_PAPER:
            scope = IssueScope.PAPER
        else:
            scope = IssueScope.SECTION

        # 2. Build LoopContext
        head = self._head(state, artifact_id)
        prior_artifact = self._envelope(head) if head is not None else None
        parent_workflow_op = getattr(self.context, "parent_operation_id", None)
        if parent_workflow_op and (not state.operations or not any(o.operationId == parent_workflow_op for o in state.operations)):
            parent_workflow_op = None
        loop_ctx = LoopContext(
            runId=self.context.run_id,
            targetArtifactId=artifact_id,
            targetArtifactType=artifact_type,
            sectionId=section_id,
            scope=scope,
            authority=AuthorityGrant(leaseOwner=self.context.lease_owner, epoch=self.context.epoch),
            inputDependencies=parents,
            policyVersion=getattr(self.policy, "version", "v2"),
            current_artifact=prior_artifact,
            parent_operation_id=parent_workflow_op,
        )
        if prior_artifact is not None:
            loop_ctx.cursor.current_state = LoopState.DRAFTING
            loop_ctx.accepted_artifact = None
        # 3. Build LoopPolicy matching the pinned run profile
        required_evals = self.required_evaluator_ids or STAGE_REQUIRED_EVALUATORS.get(artifact_type, ())
        if not required_evals:
            required_evals = (f"eval_{artifact_type.value.lower()}",)

        if getattr(state, "budgetProfileJson", None):
            run_profile = json.loads(state.budgetProfileJson)
            loop_policy = LoopPolicy.from_cap_snapshot(
                run_profile,
                required_evaluator_ids=required_evals,
            )
        else:
            loop_policy = LoopPolicy.from_pinned_execution_policy(
                self.policy,
                scope=scope,
                section_index=section_id,
                required_evaluator_ids=required_evals,
            )
        # 4. Generator capability
        outer_self = self
        class StageGenAdapter(GeneratorCapability):
            @property
            def name(self) -> str:
                return f"StageGen_{artifact_type.value}"
            @property
            def version(self) -> str:
                return "1.0.0"
            async def generate(inner_self, ctx: LoopContext, intent_id: str, ver: int) -> ArtifactEnvelope:
                res = await generate(ver)
                if isinstance(res, ArtifactEnvelope):
                    return res
                return ArtifactEnvelope.create(
                    artifact_id=ctx.target_artifact_id,
                    artifact_type=artifact_type,
                    run_id=outer_self.context.run_id,
                    payload=res,
                    producer_version=PRODUCER_VERSION,
                    version=ver,
                    section_id=section_id,
                    parent_refs=parents,
                )

        # 5. Multi-evaluator adapter caching evaluation output per draft
        eval_cache: dict[str, list[EvaluationResult]] = {}
        last_eval_rejected_error: list[EvaluationRejectedError] = []
        async def run_all_evaluations(art: ArtifactEnvelope) -> list[EvaluationResult]:
            cache_key = f"{art.artifact_id}:{art.version}:{art.content_hash}"
            if cache_key not in eval_cache:
                raw = await evaluate(art)
                eval_cache[cache_key] = list(raw) if isinstance(raw, (list, tuple)) else [raw]
            return eval_cache[cache_key]

        from app.reading_evaluation import EVALUATION_CATALOG
        EXPENSIVE_EVALUATORS = {"eval_blind_solver_adversary", "eval_passage_semantic", "eval_section_editorial", "eval_paper_monotony"}
        class StageEvalSingleAdapter(EvaluatorCapability):
            def __init__(inner_self, ev_id: str):
                inner_self._ev_id = ev_id
                inner_self._ev_version = EVALUATION_CATALOG.get(ev_id, "1.0.0")
                inner_self.is_expensive = ev_id in EXPENSIVE_EVALUATORS
                inner_self.estimated_tokens = 4000 if inner_self.is_expensive else 0
            @property
            def evaluator_id(inner_self) -> str:
                return inner_self._ev_id
            @property
            def evaluator_version(inner_self) -> str:
                return inner_self._ev_version
            async def evaluate(inner_self, ctx: LoopContext, art: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
                results = await run_all_evaluations(art)
                matched = next((e for e in results if e.evaluator_id == inner_self._ev_id), None)
                if matched is None:
                    missing = [inner_self._ev_id]
                    err = EvaluationRejectedError(
                        art,
                        tuple(results),
                        f"missing required evaluations: {sorted(missing)}",
                    )
                    last_eval_rejected_error.append(err)
                    raise err
                updates: dict[str, Any] = {}
                if matched.evaluator_id != inner_self._ev_id:
                    raise ValueError(f"Evaluator ID mismatch: expected {inner_self._ev_id}, got {matched.evaluator_id}")
                if matched.evaluator_version and inner_self._ev_version and matched.evaluator_version != inner_self._ev_version:
                    raise ValueError(f"Evaluator version mismatch for {inner_self._ev_id}: expected {inner_self._ev_version}, got {matched.evaluator_version}")
                if not matched.evaluator_version:
                    raise ValueError(f"Evaluator {inner_self._ev_id} returned empty evaluatorVersion")
                if matched.target_ref != art.to_ref():
                    raise ValueError(f"Evaluator {inner_self._ev_id} target_ref mismatch: expected {art.to_ref()}, got {matched.target_ref}")
                if set(matched.input_dependency_refs) != set(art.parent_refs):
                    raise ValueError(f"Evaluator {inner_self._ev_id} input_dependency_refs mismatch: expected {art.parent_refs}, got {matched.input_dependency_refs}")
                res = matched
                if res.status == EvaluationStatus.PASS and getattr(ctx, "open_issues", None):
                    resolved_fps = list(res.resolved_issue_fingerprints or [])
                    for oi in ctx.open_issues:
                        if oi.evaluator_id == inner_self._ev_id and any(r.artifact_id == art.artifact_id for r in oi.affected_refs):
                            if oi.fingerprint not in resolved_fps:
                                resolved_fps.append(oi.fingerprint)
                    if resolved_fps != (res.resolved_issue_fingerprints or []):
                        res = res.model_copy(update={"resolved_issue_fingerprints": resolved_fps})

                return res
        eval_adapters = [StageEvalSingleAdapter(ev_id) for ev_id in required_evals]
        # 6. Repairer capability
        fallback_rep = QuestionItemRepairer(gateway=getattr(self.context, "gateway", None)) if artifact_type == ArtifactType.QUESTION else None
        class StageRepAdapter(RepairerCapability):
            @property
            def repairer_id(self) -> str:
                return f"repair_{artifact_type.value.lower()}"
            @property
            def repairer_version(self) -> str:
                return "1.0.0"
            async def repair(inner_self, ctx: LoopContext, art: ArtifactEnvelope, issues: Sequence[Issue], intent_id: str, ver: int) -> ArtifactEnvelope:
                if repair is not None:
                    try:
                        res = await repair(art, issues, ver, intent_id=intent_id)
                    except TypeError:
                        res = await repair(art, issues, ver)
                    if isinstance(res, ArtifactEnvelope):
                        return res
                    return art.create_next_version(new_payload=res, producer_version=PRODUCER_VERSION)
                if fallback_rep is not None:
                    return await fallback_rep.repair(ctx, art, issues, intent_id, ver)
                return art.create_next_version(new_payload=dict(art.payload), producer_version=PRODUCER_VERSION)

        # 7. Construct and execute BoundedLoopRuntime
        accepted_deps = {p.artifact_id: p for p in parents}
        runtime = BoundedLoopRuntime(
            context=loop_ctx,
            policy=loop_policy,
            generator=StageGenAdapter(),
            evaluators=eval_adapters,
            repairer=StageRepAdapter() if (repair is not None or fallback_rep is not None) else None,
            persistence_client=self.client,
            accepted_dependencies=accepted_deps,
        )

        try:
            result = await runtime.run()
        except CheckpointApiError as error:
            if error.status_code == 403:
                raise LeaseLostError(artifact_id, error.message) from error
            if error.status_code == 409:
                if "epoch" in error.message.lower() and "fenced" in error.message.lower():
                    raise InvalidEpochError(artifact_id, error.message) from error
                self._count("cas_conflicts")
                raise CursorConflictError(artifact_id, error.message) from error
            raise

        if result.decision == DecisionType.PASS and result.accepted_artifact:
            self._count("acceptances_committed")
            for _ in range(max(1, result.versions_count + result.repairs_count)):
                self._count("drafts_persisted")
            return result.accepted_artifact

        self._count("failures")
        if last_eval_rejected_error:
            raise last_eval_rejected_error[0]
        msg = result.terminal_reason or f"BoundedLoopRuntime terminated with decision {result.decision.value}"
        if "epoch" in msg.lower() and "fenced" in msg.lower():
            raise InvalidEpochError(artifact_id, msg)
        if "not lease owner" in msg.lower() or "lease lost" in msg.lower():
            raise LeaseLostError(artifact_id, msg)
        if "cas conflict" in msg.lower() or "cursor cas" in msg.lower():
            self._count("cas_conflicts")
            raise CursorConflictError(artifact_id, msg)
        eval_records = tuple(e for evs in eval_cache.values() for e in evs) or tuple(runtime._latest_evaluations) or tuple(runtime._stored_evaluations.values())
        if (result.decision == DecisionType.FAIL and eval_records) or "EVALUATOR_ERROR" in msg or "evaluator error" in msg.lower() or "UNREPAIRABLE_DEFECTS" in msg or "REPAIRABLE_DEFECTS" in msg:
            raise EvaluationRejectedError(
                result.accepted_artifact or ArtifactEnvelope.create(
                    artifact_id=artifact_id,
                    artifact_type=artifact_type,
                    run_id=self.context.run_id,
                    payload={},
                    producer_version=PRODUCER_VERSION,
                    version=result.versions_count or 1,
                    section_id=section_id,
                    parent_refs=parents,
                ),
                eval_records,
                msg,
            )
        raise StageFailedError(artifact_id, msg)

    async def _generate(self, snapshot: StageSnapshot, artifact_type: ArtifactType,
                        parents: tuple[ArtifactRef, ...], generate: Generate,
                        section_id: int | None) -> ArtifactEnvelope:
        try:
            payload = await generate(snapshot.target_version)
        except asyncio.CancelledError:
            state = await self._owned(snapshot, parents)
            unknown = self._unknowns(state, snapshot.artifact_id)
            if unknown:
                await self._block_unknown(snapshot, unknown)
            await self._save(snapshot, state=StageState.CANCELLED, reason="generation cancelled")
            raise
        except Exception as error:
            await self._capability_failed(snapshot, parents, error)
            raise StageFailedError(snapshot.artifact_id, f"generation failed: {error}") from error
        state = await self._owned(snapshot, parents)
        unknown = self._unknowns(state, snapshot.artifact_id)
        if unknown:
            await self._block_unknown(snapshot, unknown)
        artifact = ArtifactEnvelope.create(snapshot.artifact_id, artifact_type, self.context.run_id,
                                           payload, PRODUCER_VERSION, version=snapshot.target_version,
                                           section_id=section_id, parent_refs=parents)
        operation_id, request_hash = await self._grant(snapshot, artifact, "draft")
        request = DraftCheckpointRequest(
            runId=self.context.run_id, epoch=self.context.epoch, leaseOwner=self.context.lease_owner,
            operationId=operation_id, requestHash=request_hash, artifact=artifact,
            expectedCursorRevision=snapshot.revision, tokensUsed=0,
        )
        ack = await self._api(snapshot.artifact_id, lambda: self.client.save_draft_checkpoint_async(request))
        self._verify_ack(artifact, ack)
        self._count("drafts_persisted")
        return artifact

    async def _capability_failed(self, snapshot: StageSnapshot, parents: tuple[ArtifactRef, ...], error: Exception) -> None:
        state = await self._owned(snapshot, parents)
        unknown = self._unknowns(state, snapshot.artifact_id)
        if unknown:
            await self._block_unknown(snapshot, unknown)
        await self._save(snapshot, state=StageState.FAILED, reason=f"{type(error).__name__}: {error}")
        self._count("failures")

    async def _evaluate_and_accept(self, snapshot: StageSnapshot, artifact: ArtifactEnvelope,
                                   evaluate: Evaluate) -> ArtifactEnvelope:
        await self._owned(snapshot, artifact.parent_refs)
        snapshot = await self._save(snapshot, state=StageState.EVALUATING, target_hash=artifact.content_hash)
        try:
            results = await evaluate(artifact)
        except asyncio.CancelledError:
            state = await self._owned(snapshot, artifact.parent_refs)
            unknown = self._unknowns(state, artifact.artifact_id)
            if unknown:
                await self._block_unknown(snapshot, unknown)
            await self._save(snapshot, state=StageState.CANCELLED, reason="evaluation cancelled")
            raise
        except Exception as error:
            await self._capability_failed(snapshot, artifact.parent_refs, error)
            raise StageFailedError(artifact.artifact_id, f"evaluation failed: {error}") from error
        state = await self._owned(snapshot, artifact.parent_refs)
        unknown = self._unknowns(state, artifact.artifact_id)
        if unknown:
            await self._block_unknown(snapshot, unknown)
        try:
            evaluations = self._validate_evaluations(artifact, results)
        except EvaluationRejectedError as error:
            await self._save(snapshot, state=StageState.FAILED, evaluations=error.evaluations, reason=error.reason)
            self._count("evaluation_rejections")
            self._count("failures")
            raise
        # Persist PASS evidence before the transaction: a commit crash resumes this exact draft.
        snapshot = await self._save(snapshot, evaluations=evaluations)
        await self._owned(snapshot, artifact.parent_refs)
        operation_id, request_hash = await self._grant(snapshot, artifact, "accept")
        decision = LoopDecision(
            decisionId=f"decision:{operation_id}", runId=self.context.run_id,
            decision=DecisionType.PASS, currentState=LoopState.EVALUATING, nextState=LoopState.COMPLETED,
            reason="All required evaluations passed on exact current dependencies", reasonCode=LoopReason.ACCEPTED,
            targetScope=IssueScope.SECTION, targetArtifactId=artifact.artifact_id,
            evaluationRef=evaluations[0].evaluation_id, expectedVersion=artifact.version,
        )
        request = CheckpointCommitRequest(
            runId=self.context.run_id, epoch=self.context.epoch, leaseOwner=self.context.lease_owner,
            operationId=operation_id, requestHash=request_hash, artifact=artifact,
            evaluations=list(evaluations), requiredEvaluatorIds=list(self.required_evaluator_ids or STAGE_REQUIRED_EVALUATORS.get(
                artifact.artifact_type, ()) or tuple(e.evaluator_id for e in evaluations)), decision=decision,
            expectedHeadVersion=snapshot.expected_head_version, expectedHeadHash=snapshot.expected_head_hash,
            expectedCursorRevision=snapshot.revision, tokensUsed=0,
        )
        ack = await self._api(artifact.artifact_id, lambda: self.client.commit_checkpoint_async(request))
        self._verify_ack(artifact, ack)
        await self._save(snapshot, state=StageState.ACCEPTED, accepted_hash=artifact.content_hash)
        self._count("acceptances_committed")
        return artifact

    async def _grant(self, snapshot: StageSnapshot, artifact: ArtifactEnvelope, phase: str) -> tuple[str, str]:
        request_hash = hashlib.sha256(canonical_json_dump({
            "request": snapshot.request_hash, "phase": phase, "artifact": artifact.to_ref(),
            "expectedHeadVersion": snapshot.expected_head_version, "expectedHeadHash": snapshot.expected_head_hash,
        }).encode()).hexdigest()
        operation_id = f"stage:{self.context.run_id}:{artifact.artifact_id}:{phase}:{artifact.version}:{request_hash}"
        request = OperationGrantRequest(
            runId=self.context.run_id, epoch=self.context.epoch, leaseOwner=self.context.lease_owner,
            operationId=operation_id, operationType="CHECKPOINT_COMMIT", requestHash=request_hash,
            tokenReservation=0, wallTimeReservationSeconds=0, sectionId=str(artifact.section_id) if artifact.section_id else None,
            artifactId=artifact.artifact_id,
        )
        grant = await self._api(artifact.artifact_id, lambda: self.client.grant_operation_async(request))
        if (grant.operationId != operation_id or grant.runId != self.context.run_id or grant.tokenReservation != 0
                or grant.status not in ("RESERVED", "COMPLETED")):
            raise ArtifactReuseRejectedError(artifact.artifact_id, "invalid stage grant acknowledgement")
        return operation_id, request_hash

    def _verify_ack(self, artifact: ArtifactEnvelope, ack: Any) -> None:
        if ((ack.runId, ack.epoch, ack.artifactId, ack.version, ack.contentHash)
                != (self.context.run_id, self.context.epoch, artifact.artifact_id, artifact.version, artifact.content_hash)):
            raise ArtifactReuseRejectedError(artifact.artifact_id, "checkpoint acknowledgement mismatch")

    async def resume(self, artifact_id: str, artifact_type: ArtifactType, parents: tuple[ArtifactRef, ...],
                     evaluate: Evaluate, section_id: int | None = None) -> ArtifactEnvelope:
        async def refuse_generation(version: int) -> Any:
            raise InvalidTransitionError(artifact_id, "no durable draft; use execute to generate")
        return await self.execute(artifact_id, artifact_type, parents, refuse_generation, evaluate, section_id)

    async def cancel(self, artifact_id: str, reason: str) -> StageSnapshot:
        state = await self._restore(artifact_id)
        snapshot = self._snapshot(state, artifact_id)
        unknown = self._unknowns(state, artifact_id)
        if unknown:
            await self._block_unknown(snapshot, unknown)
        if snapshot.state == StageState.ACCEPTED:
            raise InvalidTransitionError(artifact_id, "cannot cancel accepted artifact")
        if snapshot.state == StageState.CANCELLED:
            return snapshot
        return await self._save(snapshot, state=StageState.CANCELLED, reason=reason)
