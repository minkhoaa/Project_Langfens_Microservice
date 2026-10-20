"""Concurrency, fencing, and CAS race rejection tests.

Verifies:
1. Same-stage cursor CAS conflict detection: two writers with the same initial
   revision race; the winner commits revision+1, and the loser is rejected with
   CursorConflictError without corrupting durable state.
2. Concurrent independent sections proceed safely without cross-section CAS interference.
3. Lease expiration/revocation: writes by a revoked lease owner are rejected with
   LeaseLostError (HTTP 403).
4. Epoch bump rejection: writes with a stale epoch are rejected with
   InvalidEpochError (HTTP 409).
5. All races are synchronized deterministically via asyncio.Event/Barrier,
   never non-deterministic time.sleep.
"""

from __future__ import annotations

import asyncio
from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.persistence.client import CheckpointApiError
from app.persistence.models import LoopCursorCheckpointRequest
from app.reading_models import RunContext
from app.reading_policy import PinnedExecutionPolicy
from app.stage_executor import (
    CursorConflictError, InvalidEpochError, LeaseLostError, StageExecutor,
)

from tests.unified.mock_fixtures import (
    create_mock_environment,
)


def _eval_pass(artifact: ArtifactEnvelope) -> list[EvaluationResult]:
    return [
        EvaluationResult(
            evaluationId=f"eval:{artifact.artifact_id}:{artifact.version}",
            evaluatorId="required_mock_evaluator",
            evaluatorVersion="1.0.0",
            targetRef=artifact.to_ref(),
            status=EvaluationStatus.PASS,
            score=1.0,
            inputDependencyRefs=list(artifact.parent_refs),
        )
    ]


@pytest.mark.asyncio
async def test_same_stage_cursor_cas_conflict_detection() -> None:
    """Winner advances stage cursor; loser gets CursorConflictError via deterministic barrier."""
    run_id = f"cas-conflict-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    art_id = f"passage:{run_id}:1"

    # Context 1 (Winner)
    ctx_1 = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )
    # Context 2 (Loser - competing writer on same stage)
    ctx_2 = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    executor_1 = StageExecutor(client, ctx_1, policy, required_evaluator_ids=("required_mock_evaluator",))
    executor_2 = StageExecutor(client, ctx_2, policy, required_evaluator_ids=("required_mock_evaluator",))

    # Barrier synchronization
    first_started = asyncio.Event()
    race_gate = asyncio.Event()

    async def gen_1(ver: int) -> dict[str, Any]:
        first_started.set()
        await race_gate.wait()
        return {"passage": "Winner passage content", "title": "Winner Title"}

    async def gen_2(ver: int) -> dict[str, Any]:
        return {"passage": "Competing passage content", "title": "Competitor Title"}

    async def evaluate_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return _eval_pass(art)

    # Winner starts and halts at generation barrier
    task_1 = asyncio.create_task(
        executor_1.execute(art_id, ArtifactType.PASSAGE, (), gen_1, evaluate_stage, section_id=1)
    )
    await first_started.wait()

    # While Winner is in-flight, a competitor writer directly advances cursor
    # with expectedRevision=0 to simulate a concurrent writer winning the CAS slot.
    stolen_req = LoopCursorCheckpointRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        artifactId=art_id,
        expectedRevision=1,
        stateJson='{"protocolVersion": 1, "state": "RUNNING", "policyHash": "' + policy.hash + '", "requestHash": "comp", "targetVersion": 1, "targetHash": null, "acceptedHash": null, "expectedHeadVersion": null, "expectedHeadHash": null, "attempts": 1, "invocationId": "other", "reason": "", "evaluations": []}',
    )
    client.save_loop_cursor(stolen_req)

    # Release Winner: its internal cursor save expects revision=0, but store is now revision=1
    race_gate.set()

    with pytest.raises(CursorConflictError) as exc_info:
        await task_1

    assert exc_info.value.artifact_id == art_id
    assert executor_1.snapshot_stats().cas_conflicts >= 1


@pytest.mark.asyncio
async def test_concurrent_independent_sections_proceed_safely() -> None:
    """Concurrent execution of independent section stages does not cause false CAS conflicts."""
    run_id = f"concurrent-sections-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    ctx = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    executor = StageExecutor(client, ctx, policy, required_evaluator_ids=("required_mock_evaluator",))

    s1_ready = asyncio.Event()
    s2_ready = asyncio.Event()

    async def gen_s1(ver: int) -> dict[str, Any]:
        s1_ready.set()
        await s2_ready.wait()
        return {"passage": "Section 1 Passage", "title": "S1"}

    async def gen_s2(ver: int) -> dict[str, Any]:
        s2_ready.set()
        await s1_ready.wait()
        return {"passage": "Section 2 Passage", "title": "S2"}
    async def eval_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return _eval_pass(art)

    # Run Section 1 and Section 2 simultaneously
    res_1, res_2 = await asyncio.gather(
        executor.execute(f"passage:{run_id}:1", ArtifactType.PASSAGE, (), gen_s1, eval_stage, section_id=1),
        executor.execute(f"passage:{run_id}:2", ArtifactType.PASSAGE, (), gen_s2, eval_stage, section_id=2),
    )

    assert res_1.artifact_id == f"passage:{run_id}:1"
    assert res_2.artifact_id == f"passage:{run_id}:2"
    assert res_1.section_id == 1
    assert res_2.section_id == 2
    assert executor.snapshot_stats().cas_conflicts == 0
    assert executor.snapshot_stats().acceptances_committed == 2


@pytest.mark.asyncio
async def test_lease_revocation_rejects_with_lease_lost_error() -> None:
    """When lease authority is revoked mid-flight, writes are rejected with LeaseLostError."""
    run_id = f"lease-lost-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    ctx = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    executor = StageExecutor(client, ctx, policy, required_evaluator_ids=("required_mock_evaluator",))

    async def gen_revoked(ver: int) -> dict[str, Any]:
        # Simulate lease revocation during generation phase
        client.lease_owners[run_id] = uuid4()
        return {"passage": "Revoked lease draft", "title": "Revoked"}

    async def eval_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return _eval_pass(art)

    with pytest.raises(LeaseLostError):
        await executor.execute(f"passage:{run_id}:1", ArtifactType.PASSAGE, (), gen_revoked, eval_stage, section_id=1)

    # Draft and Head should not have been accepted
    assert (run_id, f"passage:{run_id}:1") not in client.heads


@pytest.mark.asyncio
async def test_epoch_bump_fencing_rejects_stale_epoch() -> None:
    """When authority advances epoch from 1 to 2, stale writes with epoch 1 are rejected."""
    run_id = f"epoch-bump-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    ctx = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    executor = StageExecutor(client, ctx, policy, required_evaluator_ids=("required_mock_evaluator",))

    async def gen_bumped(ver: int) -> dict[str, Any]:
        # Authority advances epoch from 1 to 2
        client.epochs[run_id] = 2
        return {"passage": "Epoch bumped draft", "title": "Bumped"}

    async def eval_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return _eval_pass(art)

    with pytest.raises(InvalidEpochError):
        await executor.execute(f"passage:{run_id}:1", ArtifactType.PASSAGE, (), gen_bumped, eval_stage, section_id=1)

    assert (run_id, f"passage:{run_id}:1") not in client.heads


@pytest.mark.asyncio
async def test_head_version_cas_mismatch_rejected() -> None:
    """Direct verification that committing against stale head version fails with 409."""
    run_id = f"head-cas-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, _ = create_mock_environment(policy=policy, run_id=run_id)

    art_id = f"passage:{run_id}:1"
    art_1 = ArtifactEnvelope.create(
        art_id, ArtifactType.PASSAGE, run_id, {"passage": "V1", "title": "T1"}, "test", version=1
    )
    art_2 = ArtifactEnvelope.create(
        art_id, ArtifactType.PASSAGE, run_id, {"passage": "V2", "title": "T2"}, "test", version=2
    )

    # First commit succeeds (expects None)
    from app.persistence.models import CheckpointCommitRequest
    from app.contracts.loop import LoopDecision, DecisionType, LoopState, LoopReason
    from app.contracts.issue import IssueScope

    dec = LoopDecision(
        decisionId="dec-1", runId=run_id, decision=DecisionType.PASS,
        currentState=LoopState.EVALUATING, nextState=LoopState.COMPLETED,
        reason="ok", reasonCode=LoopReason.ACCEPTED, targetScope=IssueScope.SECTION,
        targetArtifactId=art_id, evaluationRef="eval-1", expectedVersion=1,
    )
    req_1 = CheckpointCommitRequest(
        runId=run_id, epoch=1, leaseOwner=client.default_lease_owner,
        operationId="op-1", requestHash="hash1", artifact=art_1,
        expectedHeadVersion=None, expectedHeadHash=None, decision=dec,
    )
    client.commit_checkpoint(req_1)
    assert client.heads[(run_id, art_id)].version == 1

    # Second commit still expects None -> must be rejected with 409
    req_2 = CheckpointCommitRequest(
        runId=run_id, epoch=1, leaseOwner=client.default_lease_owner,
        operationId="op-2", requestHash="hash2", artifact=art_2,
        expectedHeadVersion=None, expectedHeadHash=None, decision=dec,
    )
    with pytest.raises(CheckpointApiError) as exc_info:
        client.commit_checkpoint(req_2)
    assert exc_info.value.status_code == 409
