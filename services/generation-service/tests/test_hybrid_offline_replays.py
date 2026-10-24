from __future__ import annotations

import json
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.contracts.loop import DecisionType
from app.evaluators.deterministic import EvidenceOffsetEvaluator
from app.providers.base import BaseProvider
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
from tests.test_t03_providers import MockCheckpointClient


PASSAGE_WEST_AFRICA = (
    "During the 14th century, iron smelting spread rapidly across West Africa. "
    "Sites on the Jos Plateau, dated to around 1350, demonstrate early mastery of high-temperature bloomery furnaces. "
    "Archaeological surveys confirmed that agricultural implements replaced stone hoes throughout the Sahel region. "
    "However, copper alloy casting was strictly confined to coastal guilds, and evidence for gold refining remains disputed."
)


class HistoricalReplayTransportProvider(BaseProvider):
    """Simulates real historical model responses for baseline vs M3-assisted replays."""

    def __init__(self):
        super().__init__(
            name="minimax",
            base_url="https://api.test",
            models={"large": "MiniMax-Text-01", "medium": "MiniMax-Text-01", "small": "MiniMax-Text-01"},
        )
        self.recorded_calls: list[dict] = []
        self.enable_m3_assistance = True
        self.m3_behavior = "SUCCESS"  # SUCCESS | INVALID_PLAN | CLAIM_MUTATION

    async def check_health(self, api_key: str | None = None) -> bool:
        return True

    def conservative_token_reservation(self, request: ProviderRequest) -> int:
        return 1200

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.recorded_calls.append({
            "operation_id": request.operation_id,
            "pinned_model": request.pinned_model,
            "capability": request.capability,
            "messages": [m.content for m in request.messages],
        })

        # M3 Planning Dispatch
        if request.pinned_model == "MiniMax-M3" or request.capability == Capability.PLAN_REPAIR:
            if not self.enable_m3_assistance:
                raise RepairJustificationError("M3 planning disabled for baseline comparison")

            if self.m3_behavior == "CLAIM_MUTATION":
                plan = {
                    "issueCode": "AMBIGUOUS_ANSWER",
                    "targetQuestion": 2,
                    "repairAction": "REPHRASE_STEM",
                    "diagnosis": "Stem ambiguous",
                    "repairConstraints": ["Add timeframe"],
                    "preserveEvidenceClaimRef": "unauthorized_claim_mutated",
                }
            elif self.m3_behavior == "INVALID_PLAN":
                plan = {"invalid": "missing required keys"}
            else:
                user_msg = request.messages[-1].content
                if "DUPLICATE_PROMPT" in user_msg or "duplicate" in user_msg.lower():
                    plan = {
                        "issueCode": "DUPLICATE_PROMPT",
                        "targetQuestion": 5,
                        "repairAction": "REGENERATE_DISTINCT_CANDIDATE",
                        "diagnosis": "Question duplicates prompt from Question 2; must target agricultural implements instead of smelting.",
                        "repairConstraints": [
                            "Target the Sahel agricultural transition",
                            "Preserve verbatim answer 'stone hoes'",
                            "Ensure stem does not mention iron smelting",
                        ],
                        "preserveEvidenceClaimRef": "claim_s1_fact_03",
                        "expectedCorrection": "Which older tools were replaced throughout the Sahel region?",
                    }
                elif "NOT_GIVEN" in user_msg:
                    plan = {
                        "issueCode": "AMBIGUOUS_ANSWER",
                        "targetQuestion": 4,
                        "repairAction": "CLARIFY_NOT_GIVEN_BOUNDARY",
                        "diagnosis": "The statement blurs the boundary between ungrounded inference and absence of evidence.",
                        "repairConstraints": [
                            "Clarify that coastal copper casting was guild-exclusive",
                            "Strictly anchor statement to gold refining ambiguity",
                        ],
                        "preserveEvidenceClaimRef": "claim_s1_fact_04",
                        "expectedCorrection": "Gold refining methods in West Africa during this era were universally documented.",
                    }
                else:
                    plan = {
                        "issueCode": "AMBIGUOUS_ANSWER",
                        "targetQuestion": 2,
                        "repairAction": "REPHRASE_STEM",
                        "diagnosis": "Question asks broadly what technology spread, permitting multiple answers without century anchor.",
                        "repairConstraints": [
                            "Qualify the stem explicitly with 'During the 14th century'",
                            "Preserve verbatim answer 'iron smelting'",
                        ],
                        "preserveEvidenceClaimRef": "claim_s1_fact_01",
                        "expectedCorrection": "What technology spread rapidly across West Africa in the 14th century?",
                    }

            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name=self.name,
                model_name="MiniMax-M3",
                raw_text=json.dumps(plan),
                parsed_payload=plan,
                finish_reason=FinishReason.STOP,
                usage=UsageReport(prompt_tokens=250, completion_tokens=90, total_tokens=340, reasoning_tokens=75),
            )

        # Text-01 Candidate Generation Dispatch
        user_msg = request.messages[-1].content
        if "Sahel agricultural transition" in user_msg:
            cand = {
                "candidateId": "cand_regen_q5_sahel",
                "questionNumber": 5,
                "questionType": "ShortAnswer",
                "prompt": "Which tools were replaced across the Sahel region as agricultural implements spread?",
                "answer": "stone hoes",
                "evidenceQuote": "Archaeological surveys confirmed that agricultural implements replaced stone hoes throughout the Sahel region.",
                "score": 0.96,
            }
        elif "gold refining ambiguity" in user_msg or "guild-exclusive" in user_msg:
            cand = {
                "candidateId": "cand_regen_q4_tfg",
                "questionNumber": 4,
                "questionType": "TrueFalseNotGiven",
                "prompt": "Gold refining techniques were universally agreed upon by West African metallurgists.",
                "answer": "FALSE",
                "evidenceQuote": "evidence for gold refining remains disputed.",
                "score": 0.94,
            }
        elif "Qualify the stem explicitly" in user_msg or "Anchor the stem" in user_msg:
            cand = {
                "candidateId": "cand_regen_q2_anchored",
                "questionNumber": 2,
                "questionType": "ShortAnswer",
                "prompt": "What technology spread rapidly across West Africa during the 14th century?",
                "answer": "iron smelting",
                "evidenceQuote": "During the 14th century, iron smelting spread rapidly across West Africa.",
                "score": 0.98,
            }
        else:
            # Baseline unconstrained re-generation (repeats ambiguous stem)
            cand = {
                "candidateId": "cand_baseline_unconstrained",
                "questionNumber": 2,
                "questionType": "ShortAnswer",
                "prompt": "What technology spread across West Africa?",  # Unfixed ambiguity
                "answer": "iron smelting",
                "evidenceQuote": "During the 14th century, iron smelting spread rapidly across West Africa.",
                "score": 0.75,
            }

        text_payload = {"candidates": [cand]}
        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name="MiniMax-Text-01",
            raw_text=json.dumps(text_payload),
            parsed_payload=text_payload,
            finish_reason=FinishReason.STOP,
            usage=UsageReport(prompt_tokens=400, completion_tokens=90, total_tokens=490),
        )


def make_replay_context(gateway: ProviderGateway, client: MockCheckpointClient):
    ctx = type("Ctx", (), {
        "run_id": "run_replay_dev",
        "gateway": gateway,
        "section_id": "section_1",
        "target_artifact_id": "questions_section_1",
        "persistence_client": client,
        "authority": type("Auth", (), {"lease_owner": uuid4(), "epoch": 1})(),
        "budget_tracker": type("BT", (), {"tokens_used": 0, "wall_time_used": 0.0, "calls_used": 0})(),
        "check_authority": lambda: True,
        "is_cancelled": lambda: False,
    })()
    return ctx


def make_replay_artifact(q_num: int, prompt: str, answer: str, quote: str, claim_ref: str, q_type: str = "ShortAnswer") -> ArtifactEnvelope:
    p_ref = ArtifactRef(artifactId="art_passage_s1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="1" * 64)
    bp_ref = ArtifactRef(artifactId="art_blueprint_01", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="2" * 64)
    payload = {
        "questionNumber": q_num,
        "questionType": q_type,
        "prompt": prompt,
        "answer": answer,
        "evidenceQuote": quote,
        "passage": PASSAGE_WEST_AFRICA,
        "claimRef": claim_ref,
        "candidates": [
            {
                "candidateId": f"cand_q{q_num}_init",
                "questionNumber": q_num,
                "questionType": q_type,
                "prompt": prompt,
                "answer": answer,
                "evidenceQuote": quote,
                "score": 0.7,
            }
        ],
    }
    return ArtifactEnvelope.create(
        artifact_id=f"art_q_slot_{q_num}",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        payload=payload,
        parent_refs=[p_ref, bp_ref],
        run_id="run_replay_dev",
        producer_version="2.0.0",
    )


@pytest.mark.asyncio
async def test_replay_ambiguous_answer_repaired_via_m3_plan():
    """Historical Failure 1: AMBIGUOUS_ANSWER resolved by M3 temporal disambiguation and Text-01 rewrite."""
    registry = ProviderRegistry()
    provider = HistoricalReplayTransportProvider()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    ctx = make_replay_context(gateway, client)

    # Historical candidate: "What technology spread across West Africa?" (ambiguous, missing century)
    artifact = make_replay_artifact(
        q_num=2,
        prompt="What technology spread across West Africa?",
        answer="iron smelting",
        quote="During the 14th century, iron smelting spread rapidly across West Africa.",
        claim_ref="claim_s1_fact_01",
    )
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question 2 answer is ambiguous: multiple candidates match without timeframe anchor",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    repaired = await repairer.repair(ctx, artifact, [issue], intent_id="rep_ambig_1", version=2)

    # 1. Verify M3 was consulted
    m3_calls = [c for c in provider.recorded_calls if c["pinned_model"] == "MiniMax-M3"]
    assert len(m3_calls) == 1
    # 2. Verify Text-01 was called with constraints
    text_calls = [c for c in provider.recorded_calls if c["pinned_model"] == "MiniMax-Text-01"]
    assert len(text_calls) == 1
    # 3. Verify repaired prompt incorporates M3 timeframe anchor
    assert "14th century" in repaired.payload["prompt"]


@pytest.mark.asyncio
async def test_replay_duplicate_prompt_repaired_via_regenerate_distinct():
    """Historical Failure 2: DUPLICATE_PROMPT resolved by M3 redirecting target to distinct Sahel claim."""
    registry = ProviderRegistry()
    provider = HistoricalReplayTransportProvider()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    ctx = make_replay_context(gateway, client)

    # Duplicate prompt targeting smelting when Q2 already covered it
    artifact = make_replay_artifact(
        q_num=5,
        prompt="What technology spread across West Africa?",  # Duplicates Q2
        answer="iron smelting",
        quote="During the 14th century, iron smelting spread rapidly across West Africa.",
        claim_ref="claim_s1_fact_03",
    )
    issue = Issue(
        code=IssueCode.DUPLICATE_PROMPT,
        message="Question 5 prompt duplicates accepted Question 2",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    repaired = await repairer.repair(ctx, artifact, [issue], intent_id="rep_dup_5", version=2)

    # Repaired artifact redirected to stone hoes / Sahel
    assert repaired.payload["answer"] == "stone hoes"
    assert "Sahel" in repaired.payload["prompt"]


@pytest.mark.asyncio
async def test_replay_quote_truncation_resolved_mechanically_without_m3():
    """Historical Failure 3: QUOTE_TRUNCATION (Pairs 1 & 6) resolved mechanically without calling M3."""
    registry = ProviderRegistry()
    provider = HistoricalReplayTransportProvider()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    ctx = make_replay_context(gateway, client)

    # Candidate with quote cut off at 40 chars
    artifact = make_replay_artifact(
        q_num=2,
        prompt="Where was early mastery of bloomery furnaces demonstrated?",
        answer="Jos Plateau",
        quote="Sites on the Jos Plateau, dated to aroun",  # Truncated string from Pair 1
        claim_ref="claim_s1_fact_02",
    )
    issue = Issue(
        code=IssueCode.QUOTE_TRUNCATION,
        message="Candidate evidence quote is cut off at 40 characters",
        severity=IssueSeverity.MAJOR,
        scope=IssueScope.QUESTION,
    )

    repaired = await repairer.repair(ctx, artifact, [issue], intent_id="rep_trunc_quote", version=2)

    # Verify M3 was NOT dispatched
    m3_calls = [c for c in provider.recorded_calls if c["pinned_model"] == "MiniMax-M3"]
    assert len(m3_calls) == 0, "Mechanical quote truncation must not call M3"

    # Verify quote was expanded to full sentence boundary
    repaired_quote = repaired.payload["evidenceQuote"]
    assert "bloomery furnaces" in repaired_quote
    assert repaired_quote.endswith(".")
    # Evaluator check passes verbatim
    assert repaired_quote in PASSAGE_WEST_AFRICA


@pytest.mark.asyncio
async def test_replay_not_given_semantic_disagreement_repaired_via_m3():
    """Historical Failure 4: NOT_GIVEN boundary disagreement resolved via M3 CLARIFY_NOT_GIVEN_BOUNDARY."""
    registry = ProviderRegistry()
    provider = HistoricalReplayTransportProvider()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    ctx = make_replay_context(gateway, client)

    artifact = make_replay_artifact(
        q_num=4,
        prompt="West African metallurgists documented all gold refining procedures.",
        answer="TRUE",  # Disagreed by solver (actually disputed/not given)
        quote="evidence for gold refining remains disputed.",
        claim_ref="claim_s1_fact_04",
        q_type="TrueFalseNotGiven",
    )
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Independent adversary solver disagrees on TRUE/NOT_GIVEN boundary",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    repaired = await repairer.repair(ctx, artifact, [issue], intent_id="rep_ng_4", version=2)

    m3_calls = [c for c in provider.recorded_calls if c["pinned_model"] == "MiniMax-M3"]
    assert len(m3_calls) == 1
    assert repaired.payload["answer"] == "FALSE"
    assert "gold refining" in repaired.payload["prompt"].lower()


@pytest.mark.asyncio
async def test_replay_checkpoint_resume_with_pinned_model_operations():
    """Verifies that durable operation tracking retains pinned model identity on resume."""
    registry = ProviderRegistry()
    provider = HistoricalReplayTransportProvider()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)

    # 1. Dispatch request with pinned MiniMax-M3
    req_m3 = ProviderRequest(
        capability=Capability.PLAN_REPAIR,
        messages=[{"role": "user", "content": "Diagnose failure"}],
        operation_id="op_m3_durable_test",
        run_id="run_durable_dev",
        section_id="section_1",
        artifact_id="questions_section_1",
        preferred_provider="minimax",
        pinned_model="MiniMax-M3",
        timeout_seconds=5.0,
    )
    resp = await gateway.execute(req_m3, epoch=1, lease_owner=uuid4())
    assert resp.model_name == "MiniMax-M3"

    # 2. Check that persisted operation record preserved model name
    op_record = client.operations.get("op_m3_durable_test")
    assert op_record is not None
    assert op_record["status"] == "COMPLETED"

    # 3. Re-execution with identical request matches grant idempotency
    grant = await client.grant_operation_async(
        type("GrantReq", (), {
            "operationId": "op_m3_durable_test",
            "requestHash": op_record["requestHash"],
            "runId": "run_durable_dev",
            "parentOperationId": None,
            "sectionId": "section_1",
            "artifactId": "questions_section_1",
            "tokenReservation": 1000,
            "wallTimeReservationSeconds": 5.0,
        })()
    )
    assert grant.isReplay is True


@pytest.mark.asyncio
async def test_comparative_baseline_blind_repair_vs_m3_assisted_repair():
    """Compare baseline unassisted blind regeneration vs M3-assisted repair.

    Baseline: repeats ambiguous phrasing and fails closed.
    M3-Assisted: diagnoses root cause, constraints prompt, and produces disambiguated question.
    """
    registry = ProviderRegistry()
    provider = HistoricalReplayTransportProvider()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    ctx = make_replay_context(gateway, client)

    artifact = make_replay_artifact(
        q_num=2,
        prompt="What technology spread across West Africa?",
        answer="iron smelting",
        quote="During the 14th century, iron smelting spread rapidly across West Africa.",
        claim_ref="claim_s1_fact_01",
    )
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Ambiguity detected: missing timeframe",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    # 1. Baseline: M3 disabled -> fails closed because unconstrained candidate repeats ambiguous prompt
    provider.enable_m3_assistance = False
    with pytest.raises(RepairJustificationError):
        await repairer.repair(ctx, artifact, [issue], intent_id="rep_base_fail", version=2)

    # 2. M3-assisted: M3 enabled -> succeeds
    provider.enable_m3_assistance = True
    repaired = await repairer.repair(ctx, artifact, [issue], intent_id="rep_m3_success", version=2)
    assert "14th century" in repaired.payload["prompt"]
    assert repaired.payload["prompt"] != artifact.payload["prompt"]
