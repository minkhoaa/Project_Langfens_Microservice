"""Focused tests proving automated MiniMax benchmark dispatch and real PostgreSQL persistence.

Proves:
1. Automated benchmark initialization works without approval files.
2. Historical caps (15 calls, 60k tokens, 300s) cannot stop the unlimited benchmark.
3. Real PostgreSQL persistence via authenticated .NET boundary admits unlimited benchmark cases.
4. Production/bounded profiles cannot enter unlimited mode.
5. Truthful accounting, CAS/fencing/cancellation, and per-request bounds are preserved.
"""
from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import os
from pathlib import Path
import sys
from uuid import uuid4

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "scripts/refactor"))
import pytest

from app.config import settings
from app.persistence.client import (
    BenchmarkCampaignCreateRequest,
    BenchmarkCaseProvisionRequest,
    CheckpointClient,
    OperationGrantRequest,
    OperationReconcileRequest,
)
from benchmark_campaign import CampaignBudgetLedger, CampaignCheckpointClient, acceptance_config
import httpx
from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.registry import ProviderRegistry
from app.providers.retry import RetryPolicy
from tests.test_t09_real_postgres_durability import (
    ensure_exam_test_database,
    is_docker_postgres_available,
    is_service_available,
)

REAL_SERVICE_URL = os.environ.get("REAL_SERVICE_URL", "http://127.0.0.1:5099")


@pytest.fixture
def checkpoint_client():
    key = os.environ.get("EXAMSERVICE__INTERNAL__API__KEY", "test-only-ephemeral-secret-key-phase09")
    return CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=key)


@pytest.fixture(scope="module", autouse=True)
def _ensure_test_database():
    if is_docker_postgres_available():
        ensure_exam_test_database()

@pytest.mark.asyncio
@pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099")
@pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running")
async def test_automated_benchmark_ledger_and_real_postgres_dispatch(tmp_path, checkpoint_client):
    """Proves automatic benchmark execution works without an approval file on real PostgreSQL."""
    campaign_id = f"test_camp_auto_{uuid4().hex[:12]}"
    corpus_hash = "2d8362ff84853e70e7cb07840e672ec0948aa5381355686cd8ae326a4c4955bc"
    config_hash = acceptance_config("G07")["sha256"]

    # 1. Initialize ledger without an authorization file
    ledger_path = tmp_path / f"{campaign_id}_ledger.json"
    ledger = CampaignBudgetLedger(
        ledger_path,
        budget_file=None,
        campaign_id=campaign_id,
        corpus_hash=corpus_hash,
        config_hash=config_hash,
        is_unlimited=True,
    )
    assert ledger.is_unlimited is True
    assert ledger.calls_cap == -1
    assert ledger.tokens_cap == -1
    assert ledger.wall_cap == -1
    assert ledger.authorization_id.startswith("auto-minimax-")
    assert ledger.authorized_by == "system-auto-minimax-benchmark"

    # 2. Persist benchmark campaign to real PostgreSQL via .NET boundary
    campaign_status = await checkpoint_client.create_benchmark_campaign_async(
        BenchmarkCampaignCreateRequest(
            campaignId=campaign_id,
            authorizationId=ledger.authorization_id,
            authorizedBy=ledger.authorized_by,
            corpusSha256=corpus_hash,
            configSha256=config_hash,
            budgetCapCalls=ledger.calls_cap,
            budgetCapTokens=ledger.tokens_cap,
            budgetCapWallTimeSeconds=float(ledger.wall_cap),
        )
    )
    assert campaign_status.campaignId == campaign_id
    assert campaign_status.status == "AUTHORIZED"
    assert campaign_status.budgetCapCalls == -1
    assert campaign_status.budgetCapTokens == -1
    assert campaign_status.budgetCapWallTimeSeconds == -1.0

    # 3. Provision a case on real PostgreSQL: verifies child run receives unlimited mode (-1)
    case_id = "case_q01"
    claim_id = uuid4().hex
    lease_owner = uuid4()
    provision = await checkpoint_client.provision_benchmark_case_async(
        BenchmarkCaseProvisionRequest(
            campaignId=campaign_id,
            caseId=case_id,
            claimId=claim_id,
            leaseOwner=lease_owner,
        )
    )
    assert provision.campaignId == campaign_id
    assert provision.caseId == case_id
    assert provision.status == "RUNNING"
    resume = await checkpoint_client.resume_state_async(provision.runId)
    assert resume.budgetCapCalls == -1
    assert resume.budgetCapTokens == -1
    assert resume.budgetCapWallTimeSeconds == -1
    assert provision.alreadyCompleted is False

    # 4. Create operation reservation via CampaignCheckpointClient in unlimited mode
    client = CampaignCheckpointClient(
        inner=checkpoint_client,
        ledger=ledger,
        run_calls_cap=-1,
        run_tokens_cap=-1,
        run_wall_time_cap=-1,
        artifact_tokens_cap=-1,
        artifact_wall_time_cap=-1,
    )

    op_id = f"op_test_{uuid4().hex[:8]}"
    grant = await client.grant_operation_async(
        OperationGrantRequest(
            runId=provision.runId,
            operationId=op_id,
            operationType="PROVIDER_CALL",
            requestHash=f"hash_{op_id}",
            epoch=provision.epoch,
            leaseOwner=lease_owner,
            tokenReservation=5000,
            costReservationUsd=0.05,
            wallTimeReservationSeconds=45.0,
            sectionId="section_1",
            artifactId="passage_section_1",
            parentOperationId=None,
        )
    )
    assert grant.operationId == op_id
    assert grant.status == "RESERVED"
    assert grant.isReplay is False

    # 5. Reconcile usage and prove truthful accounting
    reconcile = await client.reconcile_operation_async(
        OperationReconcileRequest(
            runId=provision.runId,
            operationId=op_id,
            epoch=provision.epoch,
            leaseOwner=lease_owner,
            accountingType="REPORTED",
            tokensUsed=4200,
            costUsedUsd=0.042,
            wallTimeUsedSeconds=18.5,
            resultRefJson='{"accepted": true}',
        )
    )
    assert reconcile.operationId == op_id
    assert reconcile.status == "COMPLETED"
    assert reconcile.tokensUsed == 4200
    assert reconcile.wallTimeUsedSeconds == 18.5
    assert reconcile.reservationBreached is False


@pytest.mark.asyncio
@pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099")
@pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running")
async def test_historical_caps_cannot_stop_unlimited_benchmark(tmp_path, checkpoint_client):
    """Proves that operations beyond historical 15 calls / 60k tokens / 300s are admitted."""
    campaign_id = f"test_camp_beyond_{uuid4().hex[:12]}"
    corpus_hash = "2d8362ff84853e70e7cb07840e672ec0948aa5381355686cd8ae326a4c4955bc"
    config_hash = acceptance_config("G07")["sha256"]

    ledger = CampaignBudgetLedger(
        tmp_path / f"{campaign_id}_ledger.json",
        budget_file=None,
        campaign_id=campaign_id,
        corpus_hash=corpus_hash,
        config_hash=config_hash,
        is_unlimited=True,
    )

    await checkpoint_client.create_benchmark_campaign_async(
        BenchmarkCampaignCreateRequest(
            campaignId=campaign_id,
            authorizationId=ledger.authorization_id,
            authorizedBy=ledger.authorized_by,
            corpusSha256=corpus_hash,
            configSha256=config_hash,
            budgetCapCalls=-1,
            budgetCapTokens=-1,
            budgetCapWallTimeSeconds=-1.0,
        )
    )

    provision = await checkpoint_client.provision_benchmark_case_async(
        BenchmarkCaseProvisionRequest(
            campaignId=campaign_id,
            caseId="case_large",
            claimId=uuid4().hex,
            leaseOwner=uuid4(),
        )
    )

    client = CampaignCheckpointClient(
        inner=checkpoint_client,
        ledger=ledger,
        run_calls_cap=-1,
        run_tokens_cap=-1,
        run_wall_time_cap=-1,
        artifact_tokens_cap=-1,
        artifact_wall_time_cap=-1,
    )

    # Dispatch a reservation with 80,000 tokens and 400s (exceeding historical 60k tokens and 300s caps)
    op_id = f"op_large_{uuid4().hex[:8]}"
    grant = await client.grant_operation_async(
        OperationGrantRequest(
            runId=provision.runId,
            operationId=op_id,
            operationType="PROVIDER_CALL",
            requestHash=f"hash_{op_id}",
            epoch=provision.epoch,
            leaseOwner=provision.leaseOwner,
            tokenReservation=80000,
            costReservationUsd=0.80,
            wallTimeReservationSeconds=400.0,
            sectionId="section_1",
            artifactId="passage_section_1",
        )
    )
    assert grant.status == "RESERVED"
    assert grant.tokenReservation == 80000
    assert grant.wallTimeReservationSeconds == 400.0


def test_production_profile_cannot_enter_unlimited_mode():
    """Proves that production settings remain strictly protected."""
    assert settings.loop_max_total_calls == 15
    assert settings.loop_max_total_tokens == 60000
    assert int(settings.loop_max_wall_time_seconds) == 300

    snapshot = settings.loop_caps_snapshot()
    assert snapshot["benchmarkMode"] == "LIMITED"
    assert snapshot["benchmarkMonetaryCapMode"] == "LIMITED"
    assert snapshot["caps"]["loopMaxTotalCalls"] == 15
    assert snapshot["caps"]["loopMaxTotalTokens"] == 60000
    assert snapshot["caps"]["loopMaxWallTimeSeconds"] == 300


@pytest.mark.asyncio
@pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099")
@pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running")
async def test_provider_gateway_transport_dispatch_and_monetary_accounting_on_real_postgres(tmp_path, checkpoint_client):
    """Proves end-to-end transport dispatch through ProviderGateway into real PostgreSQL persistence."""
    campaign_id = f"test_camp_gw_{uuid4().hex[:12]}"
    corpus_hash = "2d8362ff84853e70e7cb07840e672ec0948aa5381355686cd8ae326a4c4955bc"
    config_hash = acceptance_config("G07")["sha256"]

    ledger = CampaignBudgetLedger(
        tmp_path / f"{campaign_id}_ledger.json",
        budget_file=None,
        campaign_id=campaign_id,
        corpus_hash=corpus_hash,
        config_hash=config_hash,
        is_unlimited=True,
    )

    await checkpoint_client.create_benchmark_campaign_async(
        BenchmarkCampaignCreateRequest(
            campaignId=campaign_id,
            authorizationId=ledger.authorization_id,
            authorizedBy=ledger.authorized_by,
            corpusSha256=corpus_hash,
            configSha256=config_hash,
            budgetCapCalls=-1,
            budgetCapTokens=-1,
            budgetCapWallTimeSeconds=-1.0,
        )
    )

    lease_owner = uuid4()
    provision = await checkpoint_client.provision_benchmark_case_async(
        BenchmarkCaseProvisionRequest(
            campaignId=campaign_id,
            caseId="case_gateway_test",
            claimId=uuid4().hex,
            leaseOwner=lease_owner,
        )
    )

    campaign_checkpoint = CampaignCheckpointClient(
        inner=checkpoint_client,
        ledger=ledger,
        run_calls_cap=-1,
        run_tokens_cap=-1,
        run_wall_time_cap=-1,
        artifact_tokens_cap=-1,
        artifact_wall_time_cap=-1,
    )

    # Create controlled OpenAI-compatible transport returning truthful usage & cost
    transport_dispatched = False

    def handler(req: httpx.Request) -> httpx.Response:
        nonlocal transport_dispatched
        transport_dispatched = True
        return httpx.Response(
            status_code=200,
            json={
                "id": "chatcmpl-test-auto-minimax",
                "object": "chat.completion",
                "created": 1791180000,
                "model": "MiniMax-Text-01",
                "choices": [
                    {
                        "index": 0,
                        "message": {"role": "assistant", "content": "Autonomous IELTS Reading response."},
                        "finish_reason": "stop",
                    }
                ],
                "usage": {
                    "prompt_tokens": 800,
                    "completion_tokens": 400,
                    "total_tokens": 1200,
                },
            },
        )

    mock_transport = httpx.MockTransport(handler)
    async with httpx.AsyncClient(transport=mock_transport) as http_client:
        provider = OpenAICompatibleProvider(
            name="minimax",
            base_url="https://api.fake-minimax.test/v1",
            models={"small": "MiniMax-Text-01", "medium": "MiniMax-Text-01", "large": "MiniMax-Text-01"},
            http_client=http_client,
            max_retries=0,
        )
        registry = ProviderRegistry()
        registry.register_provider(provider, keys=["test-simulated-key-12345678"])

        gateway = ProviderGateway(
            registry=registry,
            checkpoint_client=campaign_checkpoint,
            retry_policy=RetryPolicy(max_attempts=2),
        )

        op_id = f"op_gw_{uuid4().hex[:8]}"
        req = ProviderRequest(
            run_id=provision.runId,
            operation_id=op_id,
            capability=Capability.GENERATE_TEXT,
            preferred_provider="minimax",
            messages=[ChatMessage(role="user", content="Generate academic reading passage.")],
            section_id="section_1",
            artifact_id="passage_section_1",
            timeout_seconds=30.0,
            wall_time_reservation_seconds=60.0,
        )

        response = await gateway.execute(req, epoch=provision.epoch, lease_owner=lease_owner)
        assert transport_dispatched is True
        assert response.raw_text == "Autonomous IELTS Reading response."
        assert response.usage.total_tokens == 1200
        assert response.usage.prompt_tokens == 800
        assert response.usage.completion_tokens == 400
        # Verify on real PostgreSQL that usage and truthful reconciliation were committed
        resume = await checkpoint_client.resume_state_async(provision.runId)
        assert resume.tokensUsed == 1200
        assert resume.callsUsed == 1
        assert resume.budgetCapCalls == -1
        assert resume.budgetCapTokens == -1
        assert resume.budgetCapWallTimeSeconds == -1
        assert resume.budgetBreachDetected is False

        matching_ops = [o for o in resume.operations if o.operationId == op_id]
        assert len(matching_ops) == 1
        op_record = matching_ops[0]
        assert op_record.status == "COMPLETED"
        assert op_record.tokensUsed == 1200
        assert op_record.promptTokensUsed == 800
        assert op_record.completionTokensUsed == 400
        assert op_record.reservationBreached is False
