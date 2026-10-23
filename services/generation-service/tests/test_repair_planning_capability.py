from __future__ import annotations

import json
from uuid import uuid4
import pytest

from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.providers.base import BaseProvider
from app.providers.errors import TimeoutError as ProviderTimeoutError, TruncatedOutputError
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.models import (
    Capability,
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageReport,
)
from app.providers.registry import ProviderRegistry
from app.repair.base import RepairJustificationError
from app.repair.contracts import RepairAction, RepairPlan
from app.repair.diagnostic_planner import RepairPlanningCapability
from tests.test_t03_providers import MockCheckpointClient


class MockM3TransportProvider(BaseProvider):
    def __init__(self, name: str = "minimax"):
        super().__init__(name=name, base_url="https://api.test", models={"large": "MiniMax-Text-01"})
        self.dispatched_requests: list[ProviderRequest] = []
        self.response_payload = None
        self.fault_to_raise = None

    async def check_health(self, api_key: str | None = None) -> bool:
        return True

    def conservative_token_reservation(self, request: ProviderRequest) -> int:
        return 1500

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.dispatched_requests.append(request)
        if self.fault_to_raise:
            raise self.fault_to_raise

        payload = self.response_payload or {
            "issueCode": "AMBIGUOUS_ANSWER",
            "targetQuestion": 2,
            "repairAction": "REPHRASE_STEM",
            "diagnosis": "The stem uses ambiguous phrasing that allows multiple valid answers.",
            "repairConstraints": [
                "Disambiguate the historical era to the 14th century",
                "Preserve exact answer span 'iron smelting'",
            ],
            "preserveEvidenceClaimRef": "claim_s1_fact_01",
            "expectedCorrection": "Which technology was adopted in West Africa during the 14th century?",
        }

        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name="MiniMax-M3",
            raw_text=json.dumps(payload),
            parsed_payload=payload,
            finish_reason=FinishReason.STOP,
            usage=UsageReport(prompt_tokens=200, completion_tokens=100, total_tokens=300, reasoning_tokens=80),
        )


@pytest.fixture
def test_setup():
    registry = ProviderRegistry()
    mock_prov = MockM3TransportProvider(name="minimax")
    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    planner = RepairPlanningCapability(gateway=gateway, model_id="MiniMax-M3")
    return planner, mock_prov, client


@pytest.mark.asyncio
async def test_repair_planning_capability_dispatches_to_m3_with_pinned_model(test_setup):
    planner, mock_prov, _ = test_setup
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question 2 answer is ambiguous: multiple candidates match",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )
    question = {
        "questionNumber": 2,
        "questionType": "ShortAnswer",
        "prompt": "What technology spread across West Africa?",
        "answer": "iron smelting",
        "evidenceQuote": "During the 14th century, iron smelting spread rapidly across West Africa.",
    }

    plan = await planner.plan_repair(
        question_payload=question,
        passage_text="During the 14th century, iron smelting spread rapidly across West Africa.",
        authoritative_claim_ref="claim_s1_fact_01",
        issues=[issue],
        run_id="run_hybrid_test",
        section_id="section_1",
        artifact_id="questions_section_1",
        lease_owner=uuid4(),
        epoch=1,
    )

    assert isinstance(plan, RepairPlan)
    assert plan.repair_action == RepairAction.REPHRASE_STEM
    assert plan.target_question == 2
    assert plan.preserve_evidence_claim_ref == "claim_s1_fact_01"

    # Verify transport dispatch parameters
    dispatched = mock_prov.dispatched_requests[-1]
    assert dispatched.pinned_model == "MiniMax-M3"
    assert dispatched.capability == Capability.PLAN_REPAIR
    assert dispatched.max_tokens <= 2048


@pytest.mark.asyncio
async def test_repair_planning_fails_closed_on_claim_tampering(test_setup):
    planner, mock_prov, _ = test_setup
    # Mock M3 returning a plan with a mutated claim ref
    mock_prov.response_payload = {
        "issueCode": "AMBIGUOUS_ANSWER",
        "targetQuestion": 2,
        "repairAction": "REPHRASE_STEM",
        "diagnosis": "Ambiguous stem wording",
        "repairConstraints": ["Add timeframe"],
        "preserveEvidenceClaimRef": "unauthorized_claim_mutated",
    }
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Ambiguity detected",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    with pytest.raises(RepairJustificationError, match="Claim preservation violated"):
        await planner.plan_repair(
            question_payload={"questionNumber": 2, "prompt": "Q", "answer": "A"},
            passage_text="Passage text here.",
            authoritative_claim_ref="claim_s1_fact_01",
            issues=[issue],
            run_id="run_hybrid_test",
            section_id="section_1",
            artifact_id="questions_section_1",
            lease_owner=uuid4(),
            epoch=1,
        )


@pytest.mark.asyncio
async def test_repair_planning_fails_closed_on_incompatible_action(test_setup):
    planner, mock_prov, _ = test_setup
    mock_prov.response_payload = {
        "issueCode": "WORD_LIMIT_EXCEEDED",
        "targetQuestion": 1,
        "repairAction": "SWAP_DISTRACTOR",  # Incompatible for WORD_LIMIT_EXCEEDED
        "diagnosis": "Word limit exceeded",
        "repairConstraints": ["Trim words"],
        "preserveEvidenceClaimRef": "claim_s1_fact_01",
    }
    issue = Issue(
        code=IssueCode.WORD_LIMIT_EXCEEDED,
        message="Answer exceeds 3 words",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    with pytest.raises(RepairJustificationError, match="Incompatible repairAction"):
        await planner.plan_repair(
            question_payload={"questionNumber": 1, "prompt": "Q", "answer": "one two three four five"},
            passage_text="Passage text.",
            authoritative_claim_ref="claim_s1_fact_01",
            issues=[issue],
            run_id="run_hybrid_test",
            section_id="section_1",
            artifact_id="questions_section_1",
            lease_owner=uuid4(),
            epoch=1,
        )


@pytest.mark.asyncio
async def test_repair_planning_fails_closed_on_timeout(test_setup):
    planner, mock_prov, _ = test_setup
    mock_prov.fault_to_raise = ProviderTimeoutError("M3 timed out", provider_name="minimax", operation_id="op_m3")
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    with pytest.raises(RepairJustificationError, match="timed out"):
        await planner.plan_repair(
            question_payload={"questionNumber": 2, "prompt": "Q", "answer": "A"},
            passage_text="Passage text.",
            authoritative_claim_ref="claim_s1_fact_01",
            issues=[issue],
            run_id="run_hybrid_test",
            section_id="section_1",
            artifact_id="questions_section_1",
            lease_owner=uuid4(),
            epoch=1,
        )
