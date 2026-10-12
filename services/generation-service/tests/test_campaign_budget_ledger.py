from __future__ import annotations
from datetime import datetime, timezone
import sys
from pathlib import Path
from uuid import uuid4

import pytest

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "refactor"))

from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    OperationGrantRequest,
    OperationGrantResult,
    OperationReconcileRequest,
    OperationResumeInfo,
)
from benchmark_campaign import (
    CampaignBudgetLedger,
    CampaignCheckpointClient,
    atomic_write_json,
)


def _authorized_budget(tmp_path: Path, *, calls: int, tokens: int, wall: int) -> Path:
    path = tmp_path / "authorization.json"
    atomic_write_json(path, {
        "authorizationStatus": "AUTHORIZED",
        "campaignId": "campaign-test",
        "authorizationId": "allocation-test",
        "authorizedBy": "test-operator",
        "binding": {"corpusSha256": "a" * 64, "configSha256": "b" * 64},
        "caps": {
            "gatewayOperations": calls,
            "accountedTokens": tokens,
            "wallTimeSeconds": wall,
        },
    })
    return path


def _request(operation_id: str, *, tokens: int = 800, wall: float = 20.0) -> OperationGrantRequest:
    return OperationGrantRequest(
        runId="child-run",
        epoch=1,
        leaseOwner=uuid4(),
        operationId=operation_id,
        operationType="PROVIDER_CALL",
        requestHash=(operation_id.encode().hex() * 32)[:64],
        tokenReservation=tokens,
        wallTimeReservationSeconds=wall,
    )


class RecordingCheckpointClient:
    def __init__(self) -> None:
        self.grants: list[OperationGrantRequest] = []

    async def grant_operation_async(self, request: OperationGrantRequest) -> OperationGrantResult:
        self.grants.append(request)
        return OperationGrantResult(
            operationId=request.operationId,
            runId=request.runId,
            status="RESERVED",
            tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=datetime.now(timezone.utc),
        )


@pytest.mark.asyncio
async def test_campaign_exhaustion_refuses_before_checkpoint_dispatch(tmp_path: Path) -> None:
    budget_file = _authorized_budget(tmp_path, calls=1, tokens=2_000, wall=60)
    ledger = CampaignBudgetLedger(
        tmp_path / "ledger.json",
        budget_file,
        campaign_id="campaign-test",
        corpus_hash="a" * 64,
        config_hash="b" * 64,
    )
    inner = RecordingCheckpointClient()
    client = CampaignCheckpointClient(
        inner,
        ledger,
        run_calls_cap=15,
        run_tokens_cap=60_000,
        run_wall_time_cap=300,
        artifact_tokens_cap=16_000,
        artifact_wall_time_cap=90,
    )

    await client.grant_operation_async(_request("op-1"))
    with pytest.raises(CheckpointApiError) as error:
        await client.grant_operation_async(_request("op-2"))

    assert error.value.status_code == 422
    assert [request.operationId for request in inner.grants] == ["op-1"]
    assert ledger.summary()["gatewayOperations"] == 1


@pytest.mark.asyncio
async def test_restart_reconciles_completed_usage_and_never_replays_operation(tmp_path: Path) -> None:
    budget_file = _authorized_budget(tmp_path, calls=2, tokens=2_000, wall=120)
    ledger_path = tmp_path / "ledger.json"
    request = _request("op-crash", tokens=900)
    ledger = CampaignBudgetLedger(
        ledger_path,
        budget_file,
        campaign_id="campaign-test",
        corpus_hash="a" * 64,
        config_hash="b" * 64,
    )
    ledger.reserve(request)

    resumed = CampaignBudgetLedger(
        ledger_path,
        budget_file,
        campaign_id="campaign-test",
        corpus_hash="a" * 64,
        config_hash="b" * 64,
    )
    recovery = resumed.recover_after_restart()
    assert recovery["recoveredReservations"] == 1
    assert recovery["gatewayOperations"] == 1
    assert recovery["accountedTokens"] == 900
    assert recovery["operationStatuses"] == {"UNKNOWN_OUTCOME": 1}

    resumed.sync_remote_operations("child-run", [
        OperationResumeInfo(
            operationId=request.operationId,
            operationType=request.operationType,
            status="COMPLETED",
            requestHash=request.requestHash,
            tokenReservation=request.tokenReservation,
            tokensUsed=700,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            wallTimeUsedSeconds=4.5,
        )
    ])
    summary = resumed.summary()
    assert summary["gatewayOperations"] == 1
    assert summary["accountedTokens"] == 700
    assert summary["operationStatuses"] == {"COMPLETED": 1}

    inner = RecordingCheckpointClient()
    client = CampaignCheckpointClient(
        inner,
        resumed,
        run_calls_cap=15,
        run_tokens_cap=60_000,
        run_wall_time_cap=300,
        artifact_tokens_cap=16_000,
        artifact_wall_time_cap=90,
    )
    with pytest.raises(CheckpointApiError) as error:
        await client.grant_operation_async(request)

    assert error.value.status_code == 409
    assert inner.grants == []
    assert resumed.summary()["accountedTokens"] == 700


def test_reconcile_marks_campaign_budget_breach_and_blocks_future_reservation(tmp_path: Path) -> None:
    budget_file = _authorized_budget(tmp_path, calls=2, tokens=1_000, wall=60)
    ledger = CampaignBudgetLedger(
        tmp_path / "ledger.json",
        budget_file,
        campaign_id="campaign-test",
        corpus_hash="a" * 64,
        config_hash="b" * 64,
    )
    request = _request("op-over-cap", tokens=900)
    ledger.reserve(request)

    result = ledger.reconcile(OperationReconcileRequest(
        runId=request.runId,
        epoch=request.epoch,
        leaseOwner=request.leaseOwner,
        operationId=request.operationId,
        tokensUsed=1_100,
        wallTimeUsedSeconds=1.0,
        accountingType="REPORTED",
    ))

    assert result.budgetBreachDetected is True
    summary = ledger.summary()
    assert summary["budgetBreachDetected"] is True
    assert summary["accountedTokens"] == 1_100

    with pytest.raises(CheckpointApiError) as error:
        ledger.reserve(_request("op-after-breach", tokens=1))
    assert error.value.status_code == 422


def test_checkpoint_client_uses_aspire_exam_endpoint_environment(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("EXAM_SERVICE_URL", raising=False)
    monkeypatch.setenv("EXAMSERVICE__EXAM__ADDRESS", "http://exam-service.local:5012/")
    monkeypatch.setenv("EXAMSERVICE__INTERNAL__API__KEY", "test-only")

    client = CheckpointClient()
    assert client.base_url == "http://exam-service.local:5012"

    monkeypatch.setenv("EXAM_SERVICE_URL", "http://explicit-exam.local:5013/")
    assert CheckpointClient().base_url == "http://explicit-exam.local:5013"
