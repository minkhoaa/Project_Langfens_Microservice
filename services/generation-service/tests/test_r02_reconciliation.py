"""R02: truthful reconciliation through authenticated .NET and real PostgreSQL.

No provider dispatch or paid campaign is used by these isolated local cases.
"""
from __future__ import annotations

import hashlib
from uuid import uuid4

import pytest

from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    BenchmarkCampaignCreateRequest, BenchmarkCaseProvisionRequest,
    OperationGrantRequest, OperationReconcileRequest, UnknownOutcomeRequest,
)
from tests.test_t09_real_postgres_durability import (
    REAL_API_KEY,
    REAL_SERVICE_URL,
    get_exam_db_container,
    is_docker_postgres_available,
    is_service_available,
    run_psql,
)


pytestmark = [
    pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099"),
    pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running"),
]

def _client():
    return CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)


async def _case(cap=1000):
    get_exam_db_container()
    client = _client()
    campaign_id = f"r02_local_{uuid4().hex}"
    await client.create_benchmark_campaign_async(BenchmarkCampaignCreateRequest(
        campaignId=campaign_id, authorizationId="r02-local-test-only",
        authorizedBy="pytest-no-provider-dispatch",
        corpusSha256=hashlib.sha256(b"r02-fixture").hexdigest(),
        configSha256=hashlib.sha256(b"r02-config").hexdigest(),
        budgetCapCalls=15, budgetCapTokens=cap, budgetCapWallTimeSeconds=300,
    ))
    owner = uuid4()
    case = await client.provision_benchmark_case_async(BenchmarkCaseProvisionRequest(
        campaignId=campaign_id, caseId="case-a", claimId="r02-local-claim", leaseOwner=owner,
    ))
    grant = OperationGrantRequest(
        runId=case.runId, epoch=case.epoch, leaseOwner=owner,
        operationId="observed", operationType="PROVIDER_CALL",
        requestHash=hashlib.sha256(b"r02-request").hexdigest(),
        tokenReservation=500, wallTimeReservationSeconds=20,
    )
    await client.grant_operation_async(grant)
    return client, campaign_id, grant


@pytest.mark.asyncio
@pytest.mark.parametrize("accounting", ["REPORTED", "ESTIMATED"])
async def test_r02_overrun_is_durable_idempotent_and_blocks_dispatch(accounting):
    client, campaign_id, grant = await _case()
    usage = OperationReconcileRequest(
        runId=grant.runId, epoch=grant.epoch, leaseOwner=grant.leaseOwner,
        operationId=grant.operationId, tokensUsed=1500, promptTokensUsed=1300,
        completionTokensUsed=200, reasoningTokensUsed=0, wallTimeUsedSeconds=3,
        accountingType=accounting, resultRefJson='{"answer":"local response"}',
    )
    result = await client.reconcile_operation_async(usage)
    assert result.tokensUsed == 1500
    assert result.reservationBreached and result.budgetBreachDetected
    restarted = _client()
    assert await restarted.reconcile_operation_async(usage) == result
    with pytest.raises(CheckpointApiError) as conflict:
        await restarted.reconcile_operation_async(usage.model_copy(update={"tokensUsed": 1499}))
    assert conflict.value.status_code == 409
    state = await restarted.resume_state_async(grant.runId)
    op = next(op for op in state.operations if op.operationId == grant.operationId)
    assert (op.tokensUsed, op.promptTokensUsed, op.completionTokensUsed, op.reasoningTokensUsed) == (1500, 1300, 200, 0)
    assert op.accountingType == accounting
    assert op.reservationBreached and state.budgetBreachDetected
    assert state.tokensUsed == 1500
    campaign = await restarted.get_benchmark_campaign_async(campaign_id)
    assert campaign.budgetUsedTokens == 1500 > campaign.budgetCapTokens
    assert campaign.budgetUsedCalls == state.callsUsed == 1
    assert campaign.budgetBreachDetected and campaign.budgetBreachReason
    # Verify the authoritative rows, not just response projections.
    assert run_psql(f'''SELECT "TokensUsed", "AccountingType", "ReservationBreached"
        FROM reading_paper_operations WHERE "RunId"='{grant.runId}'
        AND "OperationId"='{grant.operationId}';''') == f"1500|{accounting}|t"
    other = await restarted.provision_benchmark_case_async(BenchmarkCaseProvisionRequest(
        campaignId=campaign_id, caseId="case-b", claimId="r02-local-claim", leaseOwner=uuid4(),
    ))
    for run_id, epoch, owner in ((grant.runId, grant.epoch, grant.leaseOwner), (other.runId, other.epoch, other.leaseOwner)):
        with pytest.raises(CheckpointApiError) as blocked:
            await restarted.grant_operation_async(grant.model_copy(update={
                "runId": run_id, "epoch": epoch, "leaseOwner": owner,
                "operationId": "followup", "tokenReservation": 1,
            }))
        assert blocked.value.status_code == 422
    assert (await restarted.get_benchmark_campaign_async(campaign_id)).budgetUsedTokens == 1500
    assert all(op.operationId != "followup" for op in (await restarted.resume_state_async(grant.runId)).operations)


@pytest.mark.asyncio
@pytest.mark.parametrize("accounting,observed,charged", [
    ("REPORTED", 100, 100), ("ESTIMATED", 100, 500), ("UNKNOWN", 0, 500),
])
async def test_r02_usage_distinctions_do_not_refund_uncertain_tokens(accounting, observed, charged):
    client, campaign_id, grant = await _case()
    await client.reconcile_operation_async(OperationReconcileRequest(
        runId=grant.runId, epoch=grant.epoch, leaseOwner=grant.leaseOwner,
        operationId=grant.operationId, tokensUsed=observed,
        wallTimeUsedSeconds=3, accountingType=accounting,
    ))
    restarted = _client()
    state = await restarted.resume_state_async(grant.runId)
    op = next(op for op in state.operations if op.operationId == grant.operationId)
    assert op.tokensUsed == observed and op.accountingType == accounting
    assert op.promptTokensUsed is None and op.completionTokensUsed is None
    assert state.tokensUsed == charged
    assert (await restarted.get_benchmark_campaign_async(campaign_id)).budgetUsedTokens == charged
    assert not state.budgetBreachDetected and not op.reservationBreached


@pytest.mark.asyncio
async def test_r02_unresolved_reservation_survives_restart_and_replay():
    client, campaign_id, grant = await _case(cap=500)
    await client.record_unknown_outcome_async(UnknownOutcomeRequest(
        runId=grant.runId, epoch=grant.epoch, leaseOwner=grant.leaseOwner,
        operationId=grant.operationId, errorMessage="local lost provider acknowledgement",
    ))
    restarted = _client()
    replay = await restarted.grant_operation_async(grant)
    assert replay.isReplay and replay.status == "UNKNOWN_OUTCOME"
    state = await restarted.resume_state_async(grant.runId)
    op = next(op for op in state.operations if op.operationId == grant.operationId)
    assert (op.status, op.tokenReservation, op.wallTimeReservationSeconds) == ("UNKNOWN_OUTCOME", 500, 20)
    assert op.tokensUsed == 0 and op.accountingType == "UNKNOWN"
    assert state.tokensUsed == 500 and state.callsUsed == 1
    campaign = await restarted.get_benchmark_campaign_async(campaign_id)
    assert (campaign.budgetUsedTokens, campaign.budgetUsedCalls, campaign.budgetUsedWallTimeSeconds) == (500, 1, 20)
    with pytest.raises(CheckpointApiError) as blocked:
        await restarted.grant_operation_async(grant.model_copy(update={"operationId": "retry", "tokenReservation": 1}))
    assert blocked.value.status_code == 422
