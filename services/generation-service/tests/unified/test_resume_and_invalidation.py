"""Resume, dependency invalidation, unknown outcome, and token isolation tests.

Verifies:
1. Resuming partially completed paper reuses accepted artifacts without regenerating
   them (0 provider calls for completed stages).
2. Invalidating a dependency triggers regeneration only of affected descendants;
   unaffected sibling artifacts remain preserved and are reused.
3. UNKNOWN_OUTCOME halts execution and refuses silent replay or auto-retry.
4. Token accounting isolation: reservations and actual usage are tracked accurately
   per operation and scope without cross-stage budget leakage.
"""

from __future__ import annotations

import asyncio
from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.persistence.client import CheckpointApiError
from app.persistence.models import (
    InvalidateDependencyRequest, OperationGrantRequest, UnknownOutcomeRequest,
)
from app.providers.errors import ProviderError
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.reading_models import PipelineRequest, RunContext
from app.reading_policy import PinnedExecutionPolicy
from app.stage_executor import (
    StageExecutor, UnresolvedProviderOutcomeError,
)

from tests.unified.mock_fixtures import (
    create_mock_environment,
    create_pipeline_request,
)


@pytest.mark.asyncio
async def test_resume_partially_completed_paper_zero_provider_calls() -> None:
    """Resuming a paper reuses already-accepted artifacts with 0 provider calls for completed sections."""
    run_id = f"resume-test-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock_provider")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # Phase 1: Generate only Section 1 and Section 2
    req_1_2 = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2),
        parallel=False,
        finalize=False,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )
    client.init_run(run_id=run_id, epoch=req_1_2.epoch, lease_owner=req_1_2.lease_owner, policy_hash=policy.hash, job_id=req_1_2.job_id)

    res_1_2 = await pipeline.execute(req_1_2)
    assert len(res_1_2.sections) == 2
    assert res_1_2.status == "ACCEPTED"

    # Capture provider calls made during Phase 1
    phase_1_calls = list(provider.requests)
    phase_1_ops = [req.operation_id for req in phase_1_calls]

    # Clear provider request recording before Phase 2
    provider.requests.clear()
    provider.call_log.clear()

    # Phase 2: Resume full pipeline for Sections 1, 2, and 3
    req_full = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
        job_id=req_1_2.job_id,
        lease_owner=req_1_2.lease_owner,
    )
    res_full = await pipeline.execute(req_full)

    assert res_full.status == "ACCEPTED"
    assert len(res_full.sections) == 3
    assert res_full.paper is not None

    # Check provider calls in Phase 2
    phase_2_calls = list(provider.requests)
    phase_2_section_ids = [req.section_id for req in phase_2_calls if req.section_id]

    # CRITICAL: ZERO provider calls for Section 1 or Section 2 in Phase 2!
    assert "1" not in phase_2_section_ids, "Provider was erroneously called for accepted Section 1"
    assert "2" not in phase_2_section_ids, "Provider was erroneously called for accepted Section 2"

    # Confirms artifacts were reused
    assert res_full.metrics["artifacts_reused"] >= 2


@pytest.mark.asyncio
async def test_dependency_invalidation_regenerates_only_affected_descendants() -> None:
    """Invalidating Section 2's source regenerates Section 2, but leaves Section 1 and 3 preserved."""
    run_id = f"inval-test-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # 1. Complete full 3-section run
    req = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )
    client.init_run(run_id=run_id, epoch=req.epoch, lease_owner=req.lease_owner, policy_hash=policy.hash, job_id=req.job_id)

    first_res = await pipeline.execute(req)
    assert first_res.status == "ACCEPTED"

    s1_sec_head = client.heads[(run_id, f"section:{run_id}:1")]
    s2_sec_head = client.heads[(run_id, f"section:{run_id}:2")]
    s3_sec_head = client.heads[(run_id, f"section:{run_id}:3")]

    # 2. Invalidate Section 2's source pack
    target_id = f"source:{run_id}:2"
    inval_req = InvalidateDependencyRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        targetArtifactId=target_id,
        reason="Erroneous source data requiring correction",
    )
    inval_res = client.invalidate_dependencies(inval_req)

    # Invalidate response verification
    assert target_id in inval_res.invalidatedArtifactIds
    # Section 2 descendants are invalidated
    assert f"evidence:{run_id}:2" in inval_res.invalidatedArtifactIds
    assert f"section:{run_id}:2" in inval_res.invalidatedArtifactIds
    assert f"paper:{run_id}" in inval_res.invalidatedArtifactIds

    # Section 1 and Section 3 artifacts are PRESERVED
    assert f"source:{run_id}:1" in inval_res.preservedArtifactIds
    assert f"section:{run_id}:1" in inval_res.preservedArtifactIds
    assert f"source:{run_id}:3" in inval_res.preservedArtifactIds
    assert f"section:{run_id}:3" in inval_res.preservedArtifactIds

    # 3. Re-run pipeline
    second_res = await pipeline.execute(req)
    assert second_res.status == "ACCEPTED"

    # Section 1 and Section 3 remained untouched (same version & content hash)
    assert client.heads[(run_id, f"section:{run_id}:1")].content_hash == s1_sec_head.content_hash
    assert client.heads[(run_id, f"section:{run_id}:3")].content_hash == s3_sec_head.content_hash

    # Section 2 was regenerated: new version
    new_s2_head = client.heads[(run_id, f"section:{run_id}:2")]
    assert new_s2_head.version > s2_sec_head.version


@pytest.mark.asyncio
async def test_unknown_outcome_halts_execution_and_refuses_silent_replay() -> None:
    """An operation marked UNKNOWN_OUTCOME halts stage execution and refuses silent replay."""
    run_id = f"unknown-halt-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    art_id = f"passage:{run_id}:1"
    op_id = f"op:{run_id}:passage:1:1"

    # Pre-record an unresolved UNKNOWN_OUTCOME operation in the client
    grant_req = OperationGrantRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        operationId=op_id,
        operationType="PROVIDER_CALL",
        requestHash="hash-unknown",
        tokenReservation=500,
        sectionId="1",
        artifactId=art_id,
    )
    client.grant_operation(grant_req)

    # Mark operation as UNKNOWN_OUTCOME
    client.record_unknown_outcome(
        UnknownOutcomeRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=client.default_lease_owner,
            operationId=op_id,
            errorMessage="Gateway timed out contacting physical provider",
        )
    )

    ctx = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    executor = StageExecutor(client, ctx, policy)

    async def dummy_gen(ver: int) -> dict[str, Any]:
        return {"passage": "Should not be called"}

    async def dummy_eval(art: ArtifactEnvelope) -> list[Any]:
        return []

    # 1. StageExecutor halts immediately when encountering UNKNOWN_OUTCOME
    with pytest.raises(UnresolvedProviderOutcomeError) as exc_info:
        await executor.execute(art_id, ArtifactType.PASSAGE, (), dummy_gen, dummy_eval, section_id=1)

    assert exc_info.value.artifact_id == art_id
    assert op_id in exc_info.value.operation_ids

    # 2. ProviderGateway refuses silent replay on UNKNOWN_OUTCOME operations
    req = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[ChatMessage(role="user", content="test")],
        operation_id=op_id,
        run_id=run_id,
        timeout_seconds=10.0,
        wall_time_reservation_seconds=10.0,
    )
    with pytest.raises(ProviderError) as gw_exc:
        await gateway.execute(req, epoch=1, lease_owner=client.default_lease_owner)

    assert "reconcil" in str(gw_exc.value).lower() or "halts" in str(gw_exc.value).lower() or "conflict" in str(gw_exc.value).lower() or "mismatch" in str(gw_exc.value).lower()


@pytest.mark.asyncio
async def test_token_accounting_isolation_across_operations() -> None:
    """Verifies reservations and actual usage are ledgered accurately without cross-stage bleeding."""
    run_id = f"token-iso-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # Operation 1: Section 1
    op_1 = f"op:{run_id}:sec1:eval"
    grant_1 = OperationGrantRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        operationId=op_1,
        operationType="PROVIDER_CALL",
        requestHash="hash1",
        tokenReservation=1200,
        sectionId="1",
    )
    client.grant_operation(grant_1)

    # Operation 2: Section 2
    op_2 = f"op:{run_id}:sec2:eval"
    grant_2 = OperationGrantRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        operationId=op_2,
        operationType="PROVIDER_CALL",
        requestHash="hash2",
        tokenReservation=3500,
        sectionId="2",
    )
    client.grant_operation(grant_2)

    # Verify reservations are isolated
    assert client.reservations[op_1] == 1200
    assert client.reservations[op_2] == 3500

    # Reconcile Section 1 with 450 tokens
    from app.persistence.models import OperationReconcileRequest
    client.reconcile_operation(
        OperationReconcileRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=client.default_lease_owner,
            operationId=op_1,
            tokensUsed=450,
            wallTimeUsedSeconds=1.2,
        )
    )

    # Reconcile Section 2 with 3100 tokens
    client.reconcile_operation(
        OperationReconcileRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=client.default_lease_owner,
            operationId=op_2,
            tokensUsed=3100,
            wallTimeUsedSeconds=4.5,
        )
    )

    # Actuals ledgered cleanly
    assert client.actuals[op_1] == 450
    assert client.actuals[op_2] == 3100

    # Operations in resume_state reflect exact reconciled tokens
    state = client.resume_state(run_id)
    op1_info = next(o for o in state.operations if o.operationId == op_1)
    op2_info = next(o for o in state.operations if o.operationId == op_2)
    assert op1_info.tokensUsed == 450
    assert op1_info.tokenReservation == 1200
    assert op2_info.tokensUsed == 3100
    assert op2_info.tokenReservation == 3500
