from __future__ import annotations

import json
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
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
from app.repair.question import QuestionItemRepairer
from tests.test_t03_providers import MockCheckpointClient, seed_repair_parent


class RecordingHybridTransportProvider(BaseProvider):
    def __init__(self, name: str = "minimax"):
        super().__init__(
            name=name,
            base_url="https://api.test",
            models={"large": "MiniMax-Text-01", "medium": "MiniMax-Text-01", "small": "MiniMax-Text-01"},
        )
        self.dispatched_requests: list[ProviderRequest] = []
        self.m3_fault = None
        self.m3_claim_override = None

    async def check_health(self, api_key: str | None = None) -> bool:
        return True

    def conservative_token_reservation(self, request: ProviderRequest) -> int:
        return 1500

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.dispatched_requests.append(request)

        # Route by pinned_model or capability
        if request.pinned_model == "MiniMax-M3" or request.capability == Capability.PLAN_REPAIR:
            if self.m3_fault:
                raise self.m3_fault
            claim_ref = self.m3_claim_override or "claim_s1_fact_01"
            m3_plan = {
                "issueCode": "AMBIGUOUS_ANSWER",
                "targetQuestion": 2,
                "repairAction": "REPHRASE_STEM",
                "diagnosis": "The stem lacks a time anchor, making multiple answers defensible.",
                "repairConstraints": [
                    "Anchor the stem to the 14th century",
                    "Target the verbatim answer 'iron smelting'",
                ],
                "preserveEvidenceClaimRef": claim_ref,
                "expectedCorrection": "Which metallurgical process spread across West Africa in the 14th century?",
            }
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name=self.name,
                model_name="MiniMax-M3",
                raw_text=json.dumps(m3_plan),
                parsed_payload=m3_plan,
                finish_reason=FinishReason.STOP,
                usage=UsageReport(prompt_tokens=200, completion_tokens=100, total_tokens=300, reasoning_tokens=80),
            )

        # Default Text-01 candidate generation
        text_response = {
            "candidates": [
                {
                    "candidateId": "cand_regen_q2_1",
                    "questionNumber": 2,
                    "questionType": "ShortAnswer",
                    "prompt": "Which metallurgical process spread across West Africa in the 14th century?",
                    "answer": "iron smelting",
                    "evidenceQuote": "During the 14th century, iron smelting spread rapidly across West Africa.",
                    "explanation": "Explicitly anchored to 14th century.",
                    "score": 0.95,
                }
            ]
        }
        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name="MiniMax-Text-01",
            raw_text=json.dumps(text_response),
            parsed_payload=text_response,
            finish_reason=FinishReason.STOP,
            usage=UsageReport(prompt_tokens=350, completion_tokens=80, total_tokens=430),
        )


@pytest.fixture
def hybrid_env():
    registry = ProviderRegistry()
    mock_prov = RecordingHybridTransportProvider(name="minimax")
    registry.register_provider(mock_prov, keys=["key_1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    return repairer, mock_prov, gateway, client


def make_question_artifact(
    q_num: int = 2,
    prompt: str = "What technology spread across West Africa?",
    answer: str = "iron smelting",
    evidence_quote: str = "During the 14th century, iron smelting spread rapidly across West Africa.",
    claim_ref: str = "claim_s1_fact_01",
) -> ArtifactEnvelope:
    p_ref = ArtifactRef(artifactId="art_passage_s1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a" * 64)
    bp_ref = ArtifactRef(artifactId="art_blueprint_01", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b" * 64)
    passage_text = "During the 14th century, iron smelting spread rapidly across West Africa. Sites on the Jos Plateau demonstrate early mastery."
    payload = {
        "questionNumber": q_num,
        "questionType": "ShortAnswer",
        "prompt": prompt,
        "answer": answer,
        "evidenceQuote": evidence_quote,
        "passage": passage_text,
        "claimRef": claim_ref,
        "candidates": [
            {
                "candidateId": f"cand_q{q_num}_init",
                "questionNumber": q_num,
                "questionType": "ShortAnswer",
                "prompt": prompt,
                "answer": answer,
                "evidenceQuote": evidence_quote,
                "score": 0.8,
            }
        ],
    }
    return ArtifactEnvelope.create(
        artifact_id=f"art_q_slot_{q_num}",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        payload=payload,
        parent_refs=[p_ref, bp_ref],
        run_id="run_hybrid_test",
        producer_version="2.0.0",
    )


class DummyLoopContext:
    def __init__(self, gateway: ProviderGateway, client: MockCheckpointClient):
        self.run_id = "run_hybrid_test"
        self.gateway = gateway
        self.section_id = "section_1"
        self.target_artifact_id = "art_q_slot_2"
        self.persistence_client = client
        self.authority = type("Auth", (), {"lease_owner": uuid4(), "epoch": 1})()
        self.budget_tracker = type("BT", (), {"tokens_used": 0, "wall_time_used": 0.0, "calls_used": 0})()

    def check_authority(self):
        return True

    def is_cancelled(self):
        return False


@pytest.mark.asyncio
async def test_mechanical_issue_quote_truncation_bypasses_m3(hybrid_env):
    """Purely mechanical quote truncation must be resolved locally/deterministically without invoking M3."""
    repairer, mock_prov, gateway, client = hybrid_env
    ctx = DummyLoopContext(gateway, client)

    # Candidate with truncated quote (e.g. truncated at 25 chars)
    artifact = make_question_artifact(
        q_num=2,
        evidence_quote="During the 14th century",  # Truncated, but appears in passage
    )
    issue = Issue(
        code=IssueCode.QUOTE_TRUNCATION,
        message="Question 2 evidence quote is truncated",
        severity=IssueSeverity.MAJOR,
        scope=IssueScope.QUESTION,
    )

    repaired = await repairer.repair(
        context=ctx,
        artifact=artifact,
        issues=[issue],
        intent_id="intent_rep_quote",
        version=2,
    )

    # Verify M3 was NOT invoked
    m3_calls = [r for r in mock_prov.dispatched_requests if r.pinned_model == "MiniMax-M3"]
    assert len(m3_calls) == 0, "Mechanical quote repair must NOT call M3"


@pytest.mark.asyncio
async def test_semantic_adversary_issue_invokes_m3_and_regenerates_with_text01(hybrid_env):
    """Eligible semantic/adversarial failure must invoke M3 for a RepairPlan, then Text-01 for regeneration."""
    repairer, mock_prov, gateway, client = hybrid_env
    ctx = DummyLoopContext(gateway, client)

    artifact = make_question_artifact(q_num=2)
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question 2 answer is ambiguous: multiple candidates match without timeframe",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    await seed_repair_parent(
        client, run_id=ctx.run_id, operation_id="intent_rep_ambiguous", artifact_id=artifact.artifact_id,
        section_id=ctx.section_id, lease_owner=ctx.authority.lease_owner,
    )
    repaired = await repairer.repair(
        context=ctx,
        artifact=artifact,
        issues=[issue],
        intent_id="intent_rep_ambiguous",
        version=2,
    )

    assert repaired.version == 2
    # Verify M3 was dispatched
    m3_calls = [r for r in mock_prov.dispatched_requests if r.pinned_model == "MiniMax-M3"]
    assert len(m3_calls) == 1, "M3 must be invoked exactly once for repair planning"

    # Verify Text-01 was dispatched for regeneration with M3 constraints
    text_calls = [r for r in mock_prov.dispatched_requests if r.pinned_model == "MiniMax-Text-01" or r.pinned_model is None]
    assert len(text_calls) == 1, "Text-01 must be invoked for constrained regeneration"
    last_text_call = text_calls[-1]
    prompt_sent = last_text_call.messages[-1].content
    assert "Anchor the stem to the 14th century" in prompt_sent, "M3 constraints must be fed to Text-01"

    # Verify artifact has the repaired prompt
    payload = repaired.payload
    assert "14th century" in payload["prompt"]


@pytest.mark.asyncio
async def test_m3_planning_failure_fails_closed_without_uncontrolled_retries(hybrid_env):
    """If M3 planning fails (claim mutation, truncation, or timeout), repair fails closed."""
    repairer, mock_prov, gateway, client = hybrid_env
    ctx = DummyLoopContext(gateway, client)

    # M3 mutates the claim
    mock_prov.m3_claim_override = "claim_mutated_unauthorized"

    artifact = make_question_artifact(q_num=2, claim_ref="claim_s1_fact_01")
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Ambiguous phrasing",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    await seed_repair_parent(
        client, run_id=ctx.run_id, operation_id="intent_rep_fail_closed", artifact_id=artifact.artifact_id,
        section_id=ctx.section_id, lease_owner=ctx.authority.lease_owner,
    )
    with pytest.raises(RepairJustificationError, match="Claim preservation violated"):
        await repairer.repair(
            context=ctx,
            artifact=artifact,
            issues=[issue],
            intent_id="intent_rep_fail_closed",
            version=2,
        )

    # Text-01 regeneration must NOT have been called after M3 failed
    text_calls = [r for r in mock_prov.dispatched_requests if r.pinned_model != "MiniMax-M3"]
    assert len(text_calls) == 0, "Text-01 must not be dispatched when M3 planning fails closed"
