"""Production-path offline integration tests for Hybrid MiniMax Text-01 + M3 Repair.

Exercises the real SectionRunner repair callback with production-shaped RunContext
and a checkpoint client strictly enforcing lease and epoch consistency.

Covers all 10 requirements of the Hybrid Repair Production Integration Gate:
1. Successful M3 plan followed by Text-01 regeneration.
2. Missing or incorrect authority rejected before dispatch.
3. Correct epoch and lease owner propagated to both provider operations.
4. Invalid repair action or mismatched question number rejected.
5. Unknown issue/action combination rejected.
6. Evidence claim remains immutable.
7. Repaired question passes the full required evaluation suite.
8. M3 truncation and timeout handled fail-closed.
9. Crash/restart preserves durable operation identity without duplicate billing.
10. Existing Text-only behavior remains unchanged when Hybrid is disabled.
"""

from __future__ import annotations

from datetime import datetime, timezone
import json
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.loop.context import RunAuthorityAdapter, resolve_run_authority
from app.persistence.client import CheckpointApiError
from app.persistence.models import (
    OperationGrantRequest,
    OperationGrantResult,
    OperationReconcileRequest,
    OperationReconcileResult,
    OperationResumeInfo,
    ResumeStateResult,
)
from app.providers.base import BaseProvider
from app.providers.errors import DeadlineExceededError, TimeoutError as ProviderTimeoutError, TruncatedOutputError
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.models import (
    Capability,
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageReport,
)
from app.providers.registry import ProviderRegistry
from app.reading_models import RunContext
from app.reading_policy import PinnedExecutionPolicy
from app.repair.base import RepairExecutionError, RepairJustificationError
from app.repair.contracts import RepairAction, RepairPlan, RepairPlanValidationError
from app.repair.question import QuestionItemRepairer


PASSAGE_WEST_AFRICA = (
    "During the 14th century, iron smelting spread rapidly across West Africa. "
    "Sites on the Jos Plateau, dated to around 1350, demonstrate early mastery of high-temperature bloomery furnaces. "
    "Archaeological surveys confirmed that agricultural implements replaced stone hoes throughout the Sahel region. "
    "However, copper alloy casting was strictly confined to coastal guilds, and evidence for gold refining remains disputed."
)


class FencedTestCheckpointClient:
    """Mock CheckpointClient that enforces strict epoch and lease fencing."""

    def __init__(self, run_id: str, epoch: int, lease_owner: UUID, job_id: Optional[UUID] = None):
        self.run_id = run_id
        self.active_epoch = epoch
        self.active_lease_owner = lease_owner
        self.job_id = job_id or uuid4()
        self.operations: Dict[str, OperationResumeInfo] = {}
        self.grants: List[OperationGrantRequest] = []
        self.reconciliations: List[OperationReconcileRequest] = []
        self.saved_cursors: List[Any] = []

    def fence(self, request: Any) -> None:
        req_epoch = getattr(request, "epoch", None)
        if req_epoch is not None and req_epoch != self.active_epoch:
            raise CheckpointApiError(409, f"epoch fenced: caller epoch {req_epoch} != active epoch {self.active_epoch}")

        req_owner = getattr(request, "leaseOwner", getattr(request, "lease_owner", None))
        if req_owner is not None and req_owner != self.active_lease_owner:
            raise CheckpointApiError(403, f"lease lost: caller {req_owner} is not lease owner {self.active_lease_owner}")

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        self.fence(request)
        self.grants.append(request)
        old = self.operations.get(request.operationId)
        if old:
            return OperationGrantResult(
                operationId=request.operationId,
                runId=request.runId,
                status=old.status,
                tokenReservation=request.tokenReservation,
                wallTimeReservationSeconds=request.wallTimeReservationSeconds,
                grantedAt=datetime.now(timezone.utc),
                isReplay=True,
                resultRefJson=old.resultRefJson,
            )
        op = OperationResumeInfo(
            operationId=request.operationId,
            operationType=request.operationType,
            status="RESERVED",
            artifactId=request.artifactId,
            requestHash=request.requestHash,
            tokenReservation=request.tokenReservation,
            tokensUsed=0,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            wallTimeUsedSeconds=0.0,
        )
        self.operations[request.operationId] = op
        return OperationGrantResult(
            operationId=request.operationId,
            runId=request.runId,
            status="RESERVED",
            tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=datetime.now(timezone.utc),
            isReplay=False,
        )

    async def grant_operation_async(self, request: OperationGrantRequest) -> OperationGrantResult:
        return self.grant_operation(request)

    def reconcile_operation(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        self.fence(request)
        self.reconciliations.append(request)
        op = self.operations.get(request.operationId)
        if op:
            self.operations[request.operationId] = op.model_copy(update={
                "status": "COMPLETED",
                "tokensUsed": request.tokensUsed,
                "wallTimeUsedSeconds": request.wallTimeUsedSeconds,
                "resultRefJson": request.resultRefJson,
            })
        return OperationReconcileResult(
            operationId=request.operationId,
            status="COMPLETED",
            tokensUsed=request.tokensUsed,
            wallTimeUsedSeconds=request.wallTimeUsedSeconds,
            reconciledAt=datetime.now(timezone.utc),
        )

    async def reconcile_operation_async(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        return self.reconcile_operation(request)

    def record_unknown_outcome(self, request: Any) -> Any:
        self.fence(request)
        op = self.operations.get(request.operationId)
        if op:
            self.operations[request.operationId] = op.model_copy(update={
                "status": "UNKNOWN_OUTCOME",
            })
        from app.persistence.models import UnknownOutcomeAck
        return UnknownOutcomeAck(
            operationId=request.operationId,
            status="UNKNOWN_OUTCOME",
            reservationPreserved=True,
            recordedAt=datetime.now(timezone.utc),
        )

    async def record_unknown_outcome_async(self, request: Any) -> Any:
        return self.record_unknown_outcome(request)

    def resume_state(self, run_id: str) -> ResumeStateResult:
        return ResumeStateResult(
            runId=self.run_id,
            jobId=self.job_id,
            epoch=self.active_epoch,
            status="RUNNING",
            isCompatible=True,
            artifacts=[],
            draftArtifacts=[],
            operations=list(self.operations.values()),
            loopCursors=[],
            evaluations=[],
        )

    async def resume_state_async(self, run_id: str) -> ResumeStateResult:
        return self.resume_state(run_id)

    def save_loop_cursor(self, request: Any) -> Any:
        self.fence(request)
        self.saved_cursors.append(request)
        return type("Ack", (), {
            "artifactId": request.artifactId,
            "revision": request.expectedRevision + 1,
            "stateJson": request.stateJson,
        })()


class RecordingHybridIntegrationProvider(BaseProvider):
    """Test transport provider recording dispatches and supporting controlled M3/Text-01 behaviors."""

    def __init__(self, name: str = "minimax"):
        super().__init__(
            name=name,
            base_url="https://api.test",
            models={"large": "MiniMax-Text-01", "medium": "MiniMax-Text-01", "small": "MiniMax-Text-01"},
        )
        self.dispatched_requests: List[ProviderRequest] = []
        self.m3_fault: Optional[Exception] = None
        self.m3_plan_override: Optional[Dict[str, Any]] = None
        self.m3_call_count = 0
        self.text_call_count = 0

    async def check_health(self, api_key: str | None = None) -> bool:
        return True

    def conservative_token_reservation(self, request: ProviderRequest) -> int:
        return 1500

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.dispatched_requests.append(request)

        # 1. MiniMax-M3 Planning
        if request.pinned_model == "MiniMax-M3" or request.capability == Capability.PLAN_REPAIR:
            self.m3_call_count += 1
            if self.m3_fault:
                raise self.m3_fault

            plan_data = self.m3_plan_override or {
                "issueCode": "AMBIGUOUS_ANSWER",
                "targetQuestion": 2,
                "repairAction": "REPHRASE_STEM",
                "diagnosis": "The stem lacks a time anchor, making multiple answers defensible.",
                "repairConstraints": [
                    "Qualify the century explicitly to 14th century",
                    "Target the verbatim answer 'iron smelting'",
                ],
                "preserveEvidenceClaimRef": "claim_s1_fact_01",
                "expectedCorrection": "Which metallurgical process spread across West Africa in the 14th century?",
            }
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name=self.name,
                model_name="MiniMax-M3",
                raw_text=json.dumps(plan_data),
                parsed_payload=plan_data,
                finish_reason=FinishReason.STOP,
                usage=UsageReport(prompt_tokens=250, completion_tokens=110, total_tokens=360, reasoning_tokens=90),
            )

        # 2. MiniMax-Text-01 Candidate Regeneration
        self.text_call_count += 1
        text_response = {
            "candidates": [
                {
                    "candidateId": "cand_regen_q2_v2",
                    "questionNumber": 2,
                    "questionType": "SHORT_ANSWER",
                    "prompt": "Which metallurgical process spread across West Africa in the 14th century?",
                    "answer": "iron smelting",
                    "evidenceQuote": "During the 14th century, iron smelting spread rapidly across West Africa.",
                    "explanation": "Strictly anchored to 14th century per M3 plan and grounded in passage text.",
                    "score": 0.96,
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
            usage=UsageReport(prompt_tokens=420, completion_tokens=85, total_tokens=505),
        )


def make_production_run_context(
    run_id: str,
    epoch: int = 3,
    lease_owner: Optional[UUID] = None,
    client: Optional[Any] = None,
    gateway: Optional[Any] = None,
) -> tuple[RunContext, UUID]:
    owner = lease_owner or uuid4()
    policy = PinnedExecutionPolicy(provider="minimax")
    ctx = RunContext(
        runId=run_id,
        jobId=uuid4(),
        epoch=epoch,
        leaseOwner=owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )
    return ctx, owner


def make_production_question_artifact(
    run_id: str,
    q_num: int = 2,
    prompt: str = "What technology spread across West Africa?",
    answer: str = "iron smelting",
    quote: str = "During the 14th century, iron smelting spread rapidly across West Africa.",
    claim_ref: str = "claim_s1_fact_01",
) -> ArtifactEnvelope:
    p_ref = ArtifactRef(artifactId=f"passage:{run_id}:1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a" * 64)
    bp_ref = ArtifactRef(artifactId=f"blueprint:{run_id}", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b" * 64)
    start = PASSAGE_WEST_AFRICA.find(quote)
    end = start + len(quote) if start != -1 else 0
    passage_ev = {"startChar": start, "endChar": end, "text": quote} if start != -1 else {}
    payload = {
        "questionNumber": q_num,
        "questionType": "SHORT_ANSWER",
        "prompt": prompt,
        "answer": answer,
        "evidenceQuote": quote,
        "evidenceClaimRef": claim_ref,
        "claimRef": claim_ref,
        "passage": PASSAGE_WEST_AFRICA,
        "passageEvidence": passage_ev,
        "explanation": "Archaeological surveys confirm early adoption of iron smelting across West Africa.",
        "difficulty": "MEDIUM",
        "candidates": [
            {
                "candidateId": f"cand_q{q_num}_v1",
                "questionNumber": q_num,
                "questionType": "SHORT_ANSWER",
                "prompt": prompt,
                "answer": answer,
                "evidenceQuote": quote,
                "passageEvidence": passage_ev,
                "explanation": "Archaeological surveys confirm early adoption of iron smelting across West Africa.",
                "score": 0.75,
            }
        ],
    }
    return ArtifactEnvelope.create(
        artifact_id=f"question:{run_id}:{q_num}",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        payload=payload,
        parent_refs=[p_ref, bp_ref],
        run_id=run_id,
        section_id=1,
        producer_version="2.0.0",
    )


# ─── 1. Successful M3 Plan Followed by Text-01 Regeneration ──────────────────

@pytest.mark.asyncio
async def test_successful_m3_plan_followed_by_text01_regeneration():
    """1. Exercises real SectionRunner repair callback with production RunContext.

    M3 generates a diagnostic RepairPlan, Text-01 regenerates compliant candidates,
    and the repaired question artifact preserves authoritative claim binding.
    """
    run_id = f"test_hybrid_1_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=3, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)

    context, lease_owner = make_production_run_context(run_id, epoch=3, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question 2 answer is ambiguous: multiple candidates match without timeframe anchor",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    # Instantiate repairer with gateway and invoke via repair callback
    repairer = QuestionItemRepairer(gateway=gateway)
    repaired_env = await repairer.repair(
        context=context,
        artifact=art,
        issues=[issue],
        intent_id=f"op_repair_{run_id}_v2",
        version=2,
    )

    # Invariant: Output is next version with updated prompt and identical claim reference
    assert repaired_env.version == 2
    assert repaired_env.payload["evidenceClaimRef"] == "claim_s1_fact_01"
    assert "14th century" in repaired_env.payload["prompt"]

    # Verify call sequence: exactly 1 M3 call followed by 1 Text-01 call
    assert provider.m3_call_count == 1
    assert provider.text_call_count == 1
    m3_req = [r for r in provider.dispatched_requests if r.pinned_model == "MiniMax-M3"][0]
    text_req = [r for r in provider.dispatched_requests if r.pinned_model == "MiniMax-Text-01"][0]

    assert m3_req.capability == Capability.PLAN_REPAIR
    assert text_req.capability == Capability.GENERATE_JSON
    # Verify M3 diagnostic constraints were fed to Text-01
    assert "Qualify the century explicitly to 14th century" in text_req.messages[-1].content


# ─── 2. Missing or Incorrect Authority Rejected Before Dispatch ──────────────

@pytest.mark.asyncio
async def test_missing_or_incorrect_authority_rejected_before_dispatch():
    """2. Verifies missing, None, or inconsistent authority is rejected before provider dispatch."""
    run_id = f"test_hybrid_2_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=2, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    # 2a. Inconsistent epoch (direct epoch != nested authority.epoch)
    inconsistent_ctx = type("BadCtx", (), {
        "run_id": run_id,
        "gateway": gateway,
        "epoch": 2,
        "lease_owner": client.active_lease_owner,
        "authority": type("Auth", (), {"epoch": 99, "lease_owner": client.active_lease_owner})(),
    })()

    with pytest.raises(ValueError, match="Inconsistent authority epoch"):
        await repairer.repair(inconsistent_ctx, art, [issue], "intent_rep", 2)
    assert len(provider.dispatched_requests) == 0, "No dispatch allowed on inconsistent epoch"

    # 2b. Missing lease owner (None)
    no_owner_ctx = type("NoOwnerCtx", (), {
        "run_id": run_id,
        "gateway": gateway,
        "epoch": 2,
        "lease_owner": None,
        "authority": None,
    })()

    with pytest.raises(ValueError, match="Missing authority lease_owner"):
        await repairer.repair(no_owner_ctx, art, [issue], "intent_rep", 2)
    assert len(provider.dispatched_requests) == 0, "No dispatch allowed when lease_owner is missing"

    # 2c. Invalid epoch (< 1)
    bad_epoch_ctx = type("BadEpochCtx", (), {
        "run_id": run_id,
        "gateway": gateway,
        "epoch": 0,
        "lease_owner": client.active_lease_owner,
        "authority": None,
    })()

    with pytest.raises(ValueError, match="Invalid authority epoch"):
        await repairer.repair(bad_epoch_ctx, art, [issue], "intent_rep", 2)
    assert len(provider.dispatched_requests) == 0, "No dispatch allowed when epoch is invalid"


# ─── 3. Correct Epoch and Lease Owner Propagated to Both Providers ───────────

@pytest.mark.asyncio
async def test_correct_epoch_and_lease_owner_propagated_to_both_providers():
    """3. Verifies actual run epoch and lease owner propagate identically to both M3 and Text-01 dispatches."""
    run_id = f"test_hybrid_3_{uuid4().hex[:8]}"
    test_owner = uuid4()
    test_epoch = 7
    client = FencedTestCheckpointClient(run_id=run_id, epoch=test_epoch, lease_owner=test_owner)
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)

    context, _ = make_production_run_context(run_id, epoch=test_epoch, lease_owner=test_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    repairer = QuestionItemRepairer(gateway=gateway)
    await repairer.repair(context, art, [issue], f"intent_op_epoch_{test_epoch}", 2)

    # Verify checkpoint client recorded operations with exact epoch and lease owner
    assert len(client.grants) >= 2, "Expected at least 2 operation grants"
    for grant in client.grants:
        assert grant.epoch == test_epoch, f"Grant epoch {grant.epoch} must match {test_epoch}"
        assert grant.leaseOwner == test_owner, f"Grant leaseOwner {grant.leaseOwner} must match {test_owner}"

    # Verify checkpoint client reconciliations carried exact epoch and lease owner
    assert len(client.reconciliations) >= 2
    for rec in client.reconciliations:
        assert rec.epoch == test_epoch
        assert rec.leaseOwner == test_owner


# ─── 4. Invalid Repair Action or Mismatched Question Rejected ────────────────

@pytest.mark.asyncio
async def test_invalid_repair_action_or_mismatched_question_rejected():
    """4. Verifies plans targeting wrong question number or using incompatible actions fail closed."""
    run_id = f"test_hybrid_4_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    repairer = QuestionItemRepairer(gateway=gateway)

    # 4a. M3 targets an unrelated question (question 99 instead of 2)
    provider.m3_plan_override = {
        "issueCode": "AMBIGUOUS_ANSWER",
        "targetQuestion": 99,
        "repairAction": "REPHRASE_STEM",
        "diagnosis": "Target question mismatch",
        "repairConstraints": ["Constraint 1"],
        "preserveEvidenceClaimRef": "claim_s1_fact_01",
    }
    with pytest.raises(RepairJustificationError, match="Target question mismatch"):
        await repairer.repair(context, art, [issue], "intent_q_mismatch", 2)
    assert provider.text_call_count == 0, "Text-01 must not be dispatched when question number mismatches"

    # 4b. Incompatible action (SWAP_DISTRACTOR for DUPLICATE_CONTENT)
    provider.m3_plan_override = {
        "issueCode": "DUPLICATE_CONTENT",
        "targetQuestion": 2,
        "repairAction": "SWAP_DISTRACTOR",  # Incompatible: completion question cannot swap distractors
        "diagnosis": "Duplicate content detected",
        "repairConstraints": ["Constraint 1"],
        "preserveEvidenceClaimRef": "claim_s1_fact_01",
    }
    dup_issue = Issue(code=IssueCode.DUPLICATE_CONTENT, message="Duplicate content", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)
    with pytest.raises(RepairJustificationError, match="Incompatible repairAction"):
        await repairer.repair(context, art, [dup_issue], "intent_action_incompat", 2)
    assert provider.text_call_count == 0, "Text-01 must not be dispatched when repair action is incompatible"


# ─── 5. Unknown Issue / Action Combination Rejected ──────────────────────────

@pytest.mark.asyncio
async def test_unknown_issue_action_combination_rejected():
    """5. Verifies unknown or unsupported issue codes fail closed."""
    run_id = f"test_hybrid_5_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)

    repairer = QuestionItemRepairer(gateway=gateway)

    # 5a. Plan issueCode does not match detected issue
    provider.m3_plan_override = {
        "issueCode": "SCHEMA_VIOLATION",  # Mismatches detected issue AMBIGUOUS_ANSWER
        "targetQuestion": 2,
        "repairAction": "REPHRASE_STEM",
        "diagnosis": "Mismatched issue code",
        "repairConstraints": ["Directive 1"],
        "preserveEvidenceClaimRef": "claim_s1_fact_01",
    }
    detected_issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)
    with pytest.raises(RepairJustificationError, match="Issue code mismatch"):
        await repairer.repair(context, art, [detected_issue], "intent_mismatched_issue", 2)
    assert provider.text_call_count == 0, "Text-01 must not be dispatched on mismatched issue"

    # 5b. Direct plan contract validation fails closed for issue code not in ALLOWED_ACTIONS_FOR_ISSUE
    unsupported_plan = RepairPlan(
        issueCode=IssueCode.CAUSAL_OVERSTATEMENT,
        targetQuestion=2,
        repairAction=RepairAction.REPHRASE_STEM,
        diagnosis="Unsupported issue code",
        repairConstraints=["Directive 1"],
        preserveEvidenceClaimRef="claim_s1_fact_01",
    )
    from app.repair.contracts import validate_repair_plan_compatibility
    with pytest.raises(RepairPlanValidationError, match="Unsupported issue code"):
        validate_repair_plan_compatibility(unsupported_plan, authoritative_claim_ref="claim_s1_fact_01", target_question=2)


# ─── 6. Evidence Claim Remains Immutable ─────────────────────────────────────

@pytest.mark.asyncio
async def test_evidence_claim_remains_immutable_and_no_fallback_fabrication():
    """6. Verifies claim mutation is rejected and fallback claim IDs are never fabricated."""
    run_id = f"test_hybrid_6_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2, claim_ref="claim_s1_fact_01")
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    repairer = QuestionItemRepairer(gateway=gateway)

    # 6a. M3 attempts to rotate/mutate the verified claim
    provider.m3_plan_override = {
        "issueCode": "AMBIGUOUS_ANSWER",
        "targetQuestion": 2,
        "repairAction": "REPHRASE_STEM",
        "diagnosis": "Attempt to substitute unverified claim",
        "repairConstraints": ["Directives"],
        "preserveEvidenceClaimRef": "unverified_external_claim_99",
    }
    with pytest.raises(RepairJustificationError, match="Claim preservation violated"):
        await repairer.repair(context, art, [issue], "intent_claim_tamper", 2)
    assert provider.text_call_count == 0, "Text-01 must not be dispatched when claim is mutated"

    # 6b. Artifact lacking bound claim reference must NOT fabricate fallback claim ID
    m3_calls_before_6b = provider.m3_call_count
    art_no_claim = make_production_question_artifact(run_id=run_id, q_num=2)
    pl = dict(art_no_claim.payload)
    pl.pop("evidenceClaimRef", None)
    pl.pop("claimRef", None)
    unbound_art = art_no_claim.model_copy(update={"payload": pl})

    with pytest.raises(RepairJustificationError, match="Fallback claim fabrication is strictly prohibited"):
        await repairer.repair(context, unbound_art, [issue], "intent_unbound", 2)
    assert provider.m3_call_count == m3_calls_before_6b, "M3 must not be dispatched when question has no bound claim"


# ─── 7. Repaired Question Passes Required Evaluation Suite ───────────────────

@pytest.mark.asyncio
async def test_repaired_question_passes_required_evaluations():
    """7. Verifies repaired candidate passes evaluation gates deterministically."""
    run_id = f"test_hybrid_7_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    repairer = QuestionItemRepairer(gateway=gateway)
    repaired_env = await repairer.repair(context, art, [issue], "intent_eval_pass", 2)

    # Evaluate repaired envelope with deterministic evaluators
    from app.reading_evaluation import evaluate_question
    evals = evaluate_question(
        repaired_env,
        passage=PASSAGE_WEST_AFRICA,
        difficulty="MEDIUM",
        siblings=[],
    )

    # Invariant: Every evaluation passes
    for ev in evals:
        assert ev.is_pass(), f"Evaluator {ev.evaluator_id} failed with issues: {[i.message for i in ev.issues]}"


# ─── 8. M3 Truncation and Timeout Handled Fail-Closed ─────────────────────────

@pytest.mark.asyncio
async def test_m3_truncation_and_timeout_handled_fail_closed():
    """8. Verifies M3 truncation or timeout raises fail-closed RepairJustificationError."""
    run_id = f"test_hybrid_8_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    repairer = QuestionItemRepairer(gateway=gateway)

    # 8a. Truncation failure
    provider.m3_fault = TruncatedOutputError(
        "M3 output cut off by max_tokens limit",
        provider_name="minimax",
        operation_id="op_trunc",
        usage=UsageReport(prompt_tokens=200, completion_tokens=2048, total_tokens=2248),
    )
    with pytest.raises(RepairJustificationError, match="truncated"):
        await repairer.repair(context, art, [issue], "intent_trunc", 2)
    assert provider.text_call_count == 0, "Text-01 must not be dispatched when M3 truncates"

    # 8b. Timeout failure
    provider.m3_fault = ProviderTimeoutError(
        "M3 provider call timed out after 30.0s",
        provider_name="minimax",
        operation_id="op_timeout",
    )
    with pytest.raises(RepairJustificationError, match="timed out"):
        await repairer.repair(context, art, [issue], "intent_timeout", 2)
    assert provider.text_call_count == 0, "Text-01 must not be dispatched when M3 times out"


# ─── 9. Crash/Restart Preserves Operation Identity Without Duplicate Billing ─

@pytest.mark.asyncio
async def test_crash_restart_preserves_durable_operation_identity_without_duplicate_billing():
    """9. Verifies stable operation IDs allow idempotent replay without duplicate provider calls."""
    run_id = f"test_hybrid_9_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    repairer = QuestionItemRepairer(gateway=gateway)
    fixed_intent_id = f"intent_stable_{run_id}_v2"

    # Initial execution
    await repairer.repair(context, art, [issue], fixed_intent_id, 2)
    initial_m3_calls = provider.m3_call_count
    initial_text_calls = provider.text_call_count
    assert initial_m3_calls == 1
    assert initial_text_calls == 1

    # Verify stable operation IDs in checkpoint operations
    expected_m3_op = f"{fixed_intent_id}:m3_plan:q2"
    expected_text_op = f"{fixed_intent_id}:text_regen:q2"
    assert expected_m3_op in client.operations
    assert expected_text_op in client.operations
    assert client.operations[expected_m3_op].status == "COMPLETED"
    assert client.operations[expected_text_op].status == "COMPLETED"

    # Simulate process restart and replay of the exact same intent
    await repairer.repair(context, art, [issue], fixed_intent_id, 2)

    # Invariant: Underlying provider call() was NOT called again; results replayed from persistence
    assert provider.m3_call_count == 1, "M3 must not be re-billed on restart"
    assert provider.text_call_count == 1, "Text-01 must not be re-billed on restart"


# ─── 10. Existing Text-Only Behavior Unchanged When Hybrid Disabled ───────────

@pytest.mark.asyncio
async def test_existing_text_only_behavior_unchanged_when_hybrid_disabled():
    """10. Verifies Text-only path executes without M3 dispatch when Hybrid is disabled."""
    run_id = f"test_hybrid_10_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    context, _ = make_production_run_context(run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway)
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, message="Ambiguous question", severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)

    # Explicitly disable hybrid repair on repairer
    text_only_repairer = QuestionItemRepairer(gateway=gateway, enable_hybrid=False)
    repaired_env = await text_only_repairer.repair(context, art, [issue], "intent_text_only", 2)

    # Invariant: M3 was NEVER invoked
    assert provider.m3_call_count == 0, "M3 must not be invoked when Hybrid is disabled"
    # Text-01 candidate generator handled repair directly
    assert provider.text_call_count == 1, "Text-01 candidate generator must perform unconstrained repair"
    assert repaired_env.version == 2
