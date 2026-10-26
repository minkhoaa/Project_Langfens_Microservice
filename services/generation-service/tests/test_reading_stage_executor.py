"""Stage protocol tests: no provider transport or database is contacted."""
from __future__ import annotations

import asyncio
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType, canonical_json_dump
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.persistence.client import CheckpointApiError
from app.persistence.models import (
    ArtifactResumeInfo, CheckpointAck, LoopCursorCheckpoint, OperationGrantResult,
    OperationResumeInfo, ResumeStateResult,
)
from app.stage_executor import (
    ArtifactReuseRejectedError, CursorConflictError, DependencyMissingError,
    DependencyStaleError, EvaluationRejectedError, InvalidEpochError, LeaseLostError,
    PolicyHashMismatchError, RecoveryKind, RunNotActiveError, StageExecutor,
    StageState, UnresolvedProviderOutcomeError,
)

NOW = datetime.now(timezone.utc)


class Crash(BaseException):
    """An abrupt process death, not an ordinary capability failure."""


@dataclass(frozen=True)
class Context:
    run_id: str = "stage-test"
    job_id: object = None
    epoch: int = 1
    lease_owner: object = None
    policy_hash: str = "a" * 64


def evaluation(artifact, status=EvaluationStatus.PASS, evaluator_id="required"):
    return EvaluationResult(
        evaluationId=f"evaluation:{artifact.artifact_id}:{artifact.version}:{status.value}",
        evaluatorId=evaluator_id, evaluatorVersion="1.0.0", targetRef=artifact.to_ref(),
        inputDependencyRefs=list(artifact.parent_refs), status=status,
    )


async def passed(artifact):
    return [evaluation(artifact)]


class Authority:
    """In-memory implementation of actual CheckpointClient requests and CAS semantics."""

    def __init__(self):
        self.context = Context(job_id=uuid4(), lease_owner=uuid4())
        self.epoch = 1
        self.status = "RUNNING"
        self.policy_hash = self.context.policy_hash
        self.revoked = False
        self.cursors = {}
        self.heads = {}
        self.drafts = {}
        self.operations = {}
        self.evaluations = []
        self.stale = set()
        self.grants = []
        self.commits = []
        self.before_cursor = None
        self.crash_commit = False
        self.crash_after_draft = False

    def fence(self, request):
        if request.epoch != self.epoch:
            raise CheckpointApiError(409, "epoch fenced")
        if self.revoked or request.leaseOwner != self.context.lease_owner:
            raise CheckpointApiError(403, "lease lost")
        if self.status != "RUNNING":
            raise CheckpointApiError(409, "run inactive")

    def info(self, artifact):
        return ArtifactResumeInfo(
            artifactId=artifact.artifact_id, artifactType=artifact.artifact_type.value,
            acceptedVersion=artifact.version, acceptedHash=artifact.content_hash,
            payloadJson=canonical_json_dump(artifact.payload), parentRefs=list(artifact.parent_refs),
            isStale=artifact.artifact_id in self.stale,
            envelopeJson=artifact.model_dump_json(by_alias=True),
        )

    def resume_state(self, run_id):
        from app.config import cap_snapshot_json, cap_snapshot_sha256
        from app.loop.policy import LoopPolicy

        profile = LoopPolicy.from_pinned_execution_policy(
            SimpleNamespace(hash=self.policy_hash),
        ).cap_profile_snapshot
        profile_json = cap_snapshot_json(profile)
        return ResumeStateResult(
            runId=run_id, jobId=self.context.job_id, epoch=self.epoch, status=self.status,
            engineVersion="unified-v1", schemaVersion="1.0.0", policyVersion="v1",
            policyHash=self.policy_hash,
            budgetProfileJson=profile_json,
            budgetProfileSha256=cap_snapshot_sha256(profile),
            budgetProfileVersion=profile["profileVersion"],
            budgetProfileSource=profile["profileSource"],
            artifacts=[self.info(a) for a in self.heads.values()],
            draftArtifacts=[self.info(a) for a in self.drafts.values()],
            loopCursors=list(self.cursors.values()), evaluations=list(self.evaluations),
            operations=list(self.operations.values()),
        )

    async def resume_state_async(self, run_id):
        return self.resume_state(run_id)

    def save_loop_cursor(self, request):
        self.fence(request)
        if self.before_cursor:
            hook, self.before_cursor = self.before_cursor, None
            hook(request)
        old = self.cursors.get(request.artifactId)
        if (old.revision if old else 0) != request.expectedRevision:
            raise CheckpointApiError(409, "cursor CAS mismatch")
        ack = LoopCursorCheckpoint(
            artifactId=request.artifactId, revision=request.expectedRevision + 1,
            stateJson=request.stateJson, lastOperationId=request.lastOperationId,
        )
        self.cursors = {**self.cursors, request.artifactId: ack}
        return ack

    def grant_operation(self, request):
        self.fence(request)
        old = self.operations.get(request.operationId)
        if old and old.requestHash != request.requestHash:
            raise CheckpointApiError(409, "operation hash mismatch")
        if not old:
            op = OperationResumeInfo(
                operationId=request.operationId, operationType=request.operationType,
                status="RESERVED", artifactId=request.artifactId, requestHash=request.requestHash,
                tokenReservation=request.tokenReservation, tokensUsed=0,
                wallTimeReservationSeconds=request.wallTimeReservationSeconds, wallTimeUsedSeconds=0,
                parentOperationId=request.parentOperationId, sectionId=request.sectionId,
            )
            self.operations = {**self.operations, op.operationId: op}
        self.grants = [*self.grants, request]
        return OperationGrantResult(
            operationId=request.operationId, runId=request.runId,
            status=old.status if old else "RESERVED", tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=NOW, isReplay=old is not None,
        )

    async def grant_operation_async(self, request):
        return self.grant_operation(request)

    def reconcile_operation(self, request):
        self.fence(request)
        operation = self.operations.get(request.operationId)
        if operation is None:
            raise CheckpointApiError(404, "operation not found")
        self.operations = {**self.operations, operation.operationId: operation.model_copy(update={
            "status": "COMPLETED", "tokensUsed": request.tokensUsed,
            "wallTimeUsedSeconds": request.wallTimeUsedSeconds,
            "resultRefJson": request.resultRefJson,
            "promptTokensUsed": request.promptTokensUsed,
            "completionTokensUsed": request.completionTokensUsed,
            "reasoningTokensUsed": request.reasoningTokensUsed,
            "accountingType": request.accountingType,
        })}
        return SimpleNamespace(status="COMPLETED", reservationBreached=False, budgetBreachDetected=False)

    async def reconcile_operation_async(self, request):
        return self.reconcile_operation(request)

    def ack(self, request):
        artifact = request.artifact
        op = self.operations[request.operationId]
        self.operations = {**self.operations, op.operationId: op.model_copy(update={
            "status": "COMPLETED", "tokensUsed": request.tokensUsed,
            "resultRefJson": artifact.to_ref().model_dump_json(by_alias=True),
        })}
        return CheckpointAck(
            runId=request.runId, epoch=request.epoch, artifactId=artifact.artifact_id,
            version=artifact.version, contentHash=artifact.content_hash, serverTimestampUtc=NOW,
        )

    def save_draft_checkpoint(self, request):
        self.fence(request)
        key = (request.artifact.artifact_id, request.artifact.version)
        old = self.drafts.get(key)
        if old and old != request.artifact:
            raise CheckpointApiError(409, "immutable draft conflict")
        self.drafts = {**self.drafts, key: request.artifact}
        ack = self.ack(request)
        if self.crash_after_draft:
            self.crash_after_draft = False
            raise Crash()
        return ack

    async def save_draft_checkpoint_async(self, request):
        return self.save_draft_checkpoint(request)

    def commit_checkpoint(self, request):
        self.fence(request)
        if self.crash_commit:
            self.crash_commit = False
            raise Crash()
        old = self.heads.get(request.artifact.artifact_id)
        if request.expectedHeadVersion != (old.version if old else None):
            raise CheckpointApiError(409, "head CAS mismatch")
        if request.expectedHeadHash != (old.content_hash if old else None):
            raise CheckpointApiError(409, "head hash CAS mismatch")
        for parent in request.artifact.parent_refs:
            current = self.heads.get(parent.artifact_id)
            if current is None or current.to_ref() != parent or parent.artifact_id in self.stale:
                raise CheckpointApiError(409, "stale dependency")
        self.heads = {**self.heads, request.artifact.artifact_id: request.artifact}
        self.stale = self.stale - {request.artifact.artifact_id}
        self.evaluations = [*self.evaluations, *request.evaluations]
        self.commits = [*self.commits, request]
        return self.ack(request)

    async def commit_checkpoint_async(self, request):
        return self.commit_checkpoint(request)

    def state(self, artifact_id="passage"):
        payload = json.loads(self.cursors[artifact_id].stateJson)
        if "state" in payload:
            return payload["state"]
        return payload["cursor"]["currentState"]

    def executor(self):
        return StageExecutor(self, self.context, SimpleNamespace(hash=self.policy_hash),
                             required_evaluator_ids=("required",))


async def generate(version):
    return {"text": f"draft {version}"}


async def execute(authority, **overrides):
    args = dict(artifact_id="passage", artifact_type=ArtifactType.PASSAGE,
                parents=(), generate=generate, evaluate=passed)
    return await authority.executor().execute(**(args | overrides))


@pytest.mark.asyncio
async def test_accepts_draft_and_charges_no_provider_tokens_for_stage_operations():
    store = Authority()
    artifact = await execute(store)
    assert artifact.version == 1
    assert store.state() == "COMPLETED"
    assert store.drafts[("passage", 1)] == artifact
    commit_grants = [g for g in store.grants if g.operationType == "CHECKPOINT_COMMIT"]
    assert commit_grants and all(g.tokenReservation == 0 for g in commit_grants)
    assert not any(g.operationType == "PROVIDER_CALL" for g in store.grants)
    assert all(c.tokensUsed == 0 for c in store.commits)


@pytest.mark.asyncio
@pytest.mark.parametrize("results", [None, [], "", "fail"])
async def test_empty_or_malformed_evaluations_never_pass(results):
    store = Authority()

    async def invalid(artifact):
        return results

    with pytest.raises(EvaluationRejectedError):
        await execute(store, evaluate=invalid)
    assert store.state() == "FAILED"
    assert not store.commits
    assert ("passage", 1) in store.drafts


@pytest.mark.asyncio
async def test_rejected_evaluation_is_durable_across_bounded_generation_retries():
    store = Authority()

    async def fail(artifact):
        return [evaluation(artifact, EvaluationStatus.FAIL)]

    with pytest.raises(EvaluationRejectedError) as rejected:
        await execute(store, evaluate=fail)
    assert rejected.value.artifact.version == 3
    assert rejected.value.evaluations[0].status == EvaluationStatus.FAIL
    assert json.loads(store.cursors["passage"].stateJson)["evaluations"][0]["status"] == "FAIL"
    assert store.state() == "FAILED"
    assert sorted(v for _, v in store.drafts) == [1, 2, 3]
    assert not store.commits


@pytest.mark.asyncio
async def test_accepted_reuse_requires_prior_exact_pass_and_performs_no_writes():
    store = Authority()
    artifact = await execute(store)
    before = (len(store.grants), len(store.commits), store.cursors["passage"].revision)

    async def forbidden(version):
        pytest.fail("accepted reuse dispatched generation")

    assert await execute(store, generate=forbidden) == artifact
    assert before == (len(store.grants), len(store.commits), store.cursors["passage"].revision)
    assert await store.executor().get_accepted("passage") == artifact


@pytest.mark.asyncio
async def test_missing_or_stale_dependency_rejects_before_generation():
    store = Authority()
    parent = ArtifactEnvelope.create("source", ArtifactType.SOURCE_PACK, store.context.run_id,
                                     {"text": "source"}, "test")
    with pytest.raises(DependencyMissingError):
        await execute(store, parents=(parent.to_ref(),))
    store.heads = {"source": parent}
    store.stale = {"source"}
    with pytest.raises(DependencyStaleError):
        await execute(store, parents=(parent.to_ref(),))
    assert not store.grants


@pytest.mark.asyncio
async def test_dependency_closure_is_checked_transitively():
    store = Authority()
    root = ArtifactEnvelope.create("root", ArtifactType.SOURCE_PACK, store.context.run_id, {}, "test")
    child = ArtifactEnvelope.create("child", ArtifactType.EVIDENCE_GRAPH, store.context.run_id,
                                    {}, "test", parent_refs=(root.to_ref(),))
    store.heads = {"child": child}
    with pytest.raises(DependencyMissingError):
        await execute(store, parents=(child.to_ref(),))
    assert not store.grants


@pytest.mark.asyncio
async def test_authoritative_invalidation_allows_new_revision_without_mutating_old_draft():
    store = Authority()
    first = await execute(store)
    store.stale = {"passage"}
    second = await execute(store)
    assert second.version == 2
    assert store.drafts[("passage", 1)] == first
    assert store.heads["passage"] == second


@pytest.mark.asyncio
@pytest.mark.parametrize("crash_point", ["crash_after_draft", "crash_commit"])
async def test_crash_after_draft_resumes_evaluation_without_regeneration(crash_point):
    store = Authority()
    setattr(store, crash_point, True)
    calls = []

    async def counted(version):
        calls.append(version)
        return await generate(version)

    with pytest.raises(Crash):
        await execute(store, generate=counted)
    assert (await store.executor().classify_recovery("passage")).kind == RecoveryKind.RESUME_EVALUATION
    if crash_point == "crash_commit":
        evaluation_ops = [op for op in store.operations.values() if op.operationType == "EVALUATE"]
        assert evaluation_ops and all(op.status == "COMPLETED" and op.resultRefJson for op in evaluation_ops)
        assert not store.evaluations  # evaluations are durable on the operation before head commit
    artifact = await execute(store, generate=counted)
    assert artifact.version == 1
    assert calls == [1]
    assert store.state() == "COMPLETED"


@pytest.mark.asyncio
async def test_same_stage_writer_conflicts_before_generate():
    store = Authority()

    def race(request):
        store.cursors = {request.artifactId: LoopCursorCheckpoint(
            artifactId=request.artifactId, revision=1, stateJson=request.stateJson)}

    store.before_cursor = race
    with pytest.raises(CursorConflictError):
        await execute(store)
    assert not store.drafts


@pytest.mark.asyncio
async def test_different_scopes_do_not_contend():
    store = Authority()
    results = await asyncio.gather(execute(store, artifact_id="one"), execute(store, artifact_id="two"))
    assert {a.artifact_id for a in results} == {"one", "two"}
    assert store.state("one") == store.state("two") == "COMPLETED"


@pytest.mark.asyncio
async def test_epoch_change_during_generation_fences_draft():
    store = Authority()

    async def stale(version):
        store.epoch = 2
        return await generate(version)

    with pytest.raises(InvalidEpochError):
        await execute(store, generate=stale)
    assert not store.heads
    assert not store.drafts


@pytest.mark.asyncio
async def test_lease_loss_during_generation_fences_draft():
    store = Authority()

    async def stale(version):
        store.revoked = True
        return await generate(version)

    with pytest.raises(LeaseLostError):
        await execute(store, generate=stale)
    assert not store.heads


@pytest.mark.asyncio
async def test_unknown_provider_operation_never_replays_and_can_resume_after_reconciliation():
    store = Authority()
    op = OperationResumeInfo(operationId="provider:1", operationType="LLM_GENERATE",
                             status="UNKNOWN_OUTCOME", artifactId="passage", requestHash="b" * 64,
                             tokenReservation=100, tokensUsed=0, wallTimeReservationSeconds=10,
                             wallTimeUsedSeconds=0)
    store.operations = {op.operationId: op}
    for _ in range(2):
        with pytest.raises(UnresolvedProviderOutcomeError):
            await execute(store)
    assert store.state() == "UNKNOWN_OUTCOME"
    assert not store.drafts
    store.operations = {op.operationId: op.model_copy(update={"status": "COMPLETED", "tokensUsed": 50})}
    assert (await execute(store)).version == 1


@pytest.mark.asyncio
async def test_run_policy_and_nonactive_state_fail_closed():
    store = Authority()
    store.policy_hash = "b" * 64
    with pytest.raises(PolicyHashMismatchError):
        await execute(store)
    store.policy_hash = store.context.policy_hash
    store.status = "CANCELLED"
    with pytest.raises(RunNotActiveError):
        await execute(store)


@pytest.mark.asyncio
async def test_accepted_cursor_hash_corruption_is_not_reused():
    store = Authority()
    await execute(store)
    cursor = store.cursors["passage"]
    state = json.loads(cursor.stateJson)
    state["currentRef"] = state["currentRef"] | {"contentHash": "b" * 64}
    store.cursors = {"passage": cursor.model_copy(update={"stateJson": json.dumps(state)})}

    async def forbidden(version):
        pytest.fail("a corrupt durable cursor must block generation")

    with pytest.raises(ArtifactReuseRejectedError, match="completed loop cursor"):
        await execute(store, generate=forbidden)
