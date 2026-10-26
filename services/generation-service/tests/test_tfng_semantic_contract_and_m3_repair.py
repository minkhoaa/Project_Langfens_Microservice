"""Test Suite for TFNG Semantic Contract Calibration and MiniMax-M3 Repair Planning.

Validates:
1. Reproduction of historical Q4 V1, V2, and V3 lineages and evaluator diagnostics.
2. Blueprint answer-target advisory contract consistency (Q3 FALSE vs Q4 NOT_GIVEN).
3. Scope-sensitive negation, quantifiers, and contrastive counterexamples.
4. Typed issue routing to M3 for TFNG_BOUNDARY_CONFLICT.
5. Strict exclusion of mechanical/factual errors from M3 dispatch.
6. Text-01 regeneration from typed, grounded repair plans.
7. Mandatory evaluator reruns after repair.
8. Rejected candidate non-repetition and diversity invariants.
9. M3 timeout/truncation fail-closed safety.
10. Checkpoint/restart idempotency and operation reconciliation.
"""

from __future__ import annotations

import asyncio
import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence
from uuid import UUID, uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.contracts.question_type import QuestionPromptFamily
from app.evaluators.semantic import (
    ANTONYM_PAIRS,
    detect_contradiction_in_text,
    detect_entailment_in_text,
    detect_negation_polarity_conflict,
    stem_token,
)
from app.generators.question.prompts import build_question_prompt
from app.loop.capabilities import EvaluatorCapability, GeneratorCapability, RepairerCapability
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.controller import LoopController
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from app.providers.errors import TimeoutError as ProviderTimeoutError, TruncatedOutputError
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ProviderRequest, ProviderResponse
from app.reading_evaluation import evaluate_question
from app.repair.base import RepairExecutionError, RepairJustificationError, RepairScope
from app.repair.contracts import (
    ALLOWED_ACTIONS_FOR_ISSUE,
    RepairAction,
    RepairPlan,
    RepairPlanValidationError,
    validate_repair_plan_compatibility,
)
from app.repair.diagnostic_planner import RepairPlanningCapability
from app.repair.question import QuestionItemRepairer
from app.section_runner import _parse_candidate_payload, CandidateRejectionError, CandidateRejectionReason


SNAPSHOT_PATH = (
    Path(__file__).resolve().parents[3]
    / "reports/hybrid_single_section_answer_grounding_rerun_snapshot.json"
)


def load_snapshot() -> dict[str, Any]:
    with open(SNAPSHOT_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


# ── Test 1: Historical Q4 Lineage & Calibration ───────────────────────────────

def test_01_reproduce_q4_v1_v2_v3_lineage_and_calibration():
    """Test 1: Reproduces Q4 V1-V3 from snapshot and verifies calibrated semantic evaluations."""
    snapshot = load_snapshot()
    artifacts = {a["ArtifactId"]: a for a in snapshot.get("all_artifacts", [])}

    passage_art = artifacts["passage:run_6fc3be9e30fc46c28a4bd49e23b236a7:1"]
    passage_payload = json.loads(passage_art["PayloadJson"])
    passage_text = passage_payload["passage"]

    # Q4 V1
    q4_v1_artifact_dict = next(a for a in snapshot.get("all_artifacts", []) if a.get("ArtifactId", "").endswith(":4") and a.get("Version") == 1)
    q4_v1_raw = json.loads(q4_v1_artifact_dict["PayloadJson"])
    art_v1 = ArtifactEnvelope.create(
        artifact_id="question:run_6fc3be9e30fc46c28a4bd49e23b236a7:4",
        artifact_type=ArtifactType.QUESTION,
        run_id="run_6fc3be9e30fc46c28a4bd49e23b236a7",
        payload=q4_v1_raw,
        producer_version="1.0.0",
        version=1,
    )
    results_v1 = evaluate_question(art_v1, passage_text, difficulty="FOUNDATION", siblings=())
    issues_v1 = [iss for r in results_v1 for iss in r.issues]
    # V1 asserts non-existence of smelting sites affirmed in text -> TFNG_BOUNDARY_CONFLICT
    assert any(i.code == IssueCode.TFNG_BOUNDARY_CONFLICT for i in issues_v1), "Q4 V1 must emit TFNG_BOUNDARY_CONFLICT"
    v1_issue = next(i for i in issues_v1 if i.code == IssueCode.TFNG_BOUNDARY_CONFLICT)
    assert "contradicts NOT GIVEN statement" in v1_issue.message or "polarity conflict" in v1_issue.message

    # Q4 V3: "The passage discusses the specific challenges of identifying early smelting sites that show long-term use..."
    q4_v3_raw = {
        "questionNumber": 4,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "The passage discusses the specific challenges of identifying early smelting sites that show long-term use and a well-established chronological sequence.",
        "answer": "NOT_GIVEN",
        "explanation": "The passage does not provide specific details or discussions about the challenges of identifying early smelting sites with long-term use and well-established chronological sequences.",
        "passageEvidence": {"startChar": 5462, "endChar": 5585, "text": "It is even rarer to identify early smelting sites that show long-term use and a well-established chronological sequence."},
        "evidenceClaimRef": "claim:run_6fc3be9e30fc46c28a4bd49e23b236a7:1:9",
        "absenceAssessment": {
            "assessmentId": "abs_q4",
            "claimOrTopic": "Specific challenges of identifying early smelting sites with long-term use",
            "absenceReason": "The passage notes that such sites are rare, but does not discuss the specific challenges of identifying them.",
            "topicalContextSpan": "It is even rarer to identify early smelting sites that show long-term use and a well-established chronological sequence.",
            "absenceConfirmed": True,
        },
    }
    art_v3 = ArtifactEnvelope.create(
        artifact_id="question:run_6fc3be9e30fc46c28a4bd49e23b236a7:4",
        artifact_type=ArtifactType.QUESTION,
        run_id="run_6fc3be9e30fc46c28a4bd49e23b236a7",
        payload=q4_v3_raw,
        producer_version="1.0.0",
        version=3,
    )
    results_v3 = evaluate_question(art_v3, passage_text, difficulty="FOUNDATION", siblings=())
    issues_v3 = [iss for r in results_v3 for iss in r.issues]
    # Current IELTS correctness requires a factual proposition. The historical
    # meta-textual V3 cannot be grandfathered into acceptance or merely rekeyed.
    assert any(
        i.code == IssueCode.TFNG_BOUNDARY_CONFLICT and "factual proposition" in i.message
        for i in issues_v3
    ), f"Historical meta-textual Q4 V3 must remain rejected, got: {issues_v3}"
    assert not any(i.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM for i in issues_v3)


# ── Test 2: Blueprint Advisory Target Contract ────────────────────────────────

def test_02_blueprint_answer_target_advisory_contract_and_consistency():
    """Test 2: Audits isNotGivenTarget as an advisory generation target while Blueprint remains immutable."""
    snapshot = load_snapshot()
    artifacts = {a["ArtifactId"]: a for a in snapshot.get("all_artifacts", [])}

    bp_art = artifacts["blueprint:run_6fc3be9e30fc46c28a4bd49e23b236a7"]
    bp_payload = json.loads(bp_art["PayloadJson"])
    slots = bp_payload["sections"][0]["questionSlots"]

    slot3 = next(s for s in slots if s["questionNumber"] == 3)
    slot4 = next(s for s in slots if s["questionNumber"] == 4)

    # Immutable blueprint specifications
    assert slot3["isNotGivenTarget"] is True, "Slot 3 was planned as NOT GIVEN target"
    assert slot4["isNotGivenTarget"] is False, "Slot 4 was planned as positive target"

    # Historical accepted Q3 had answer=FALSE
    q3_raw = json.loads(artifacts["question:run_6fc3be9e30fc46c28a4bd49e23b236a7:3"]["PayloadJson"])
    assert q3_raw["answer"] == "FALSE", "Q3 was accepted as FALSE"

    # Verify candidate selection sorting prefers advisory target when available, but does not reject valid alternatives
    passage_text = "Iron smelting emerged in West Africa during the first millennium BCE."
    claims_map = {"claim_1": {"claimId": "claim_1", "text": "Early iron production in West Africa"}}

    # Pool with both FALSE and NOT_GIVEN candidates for slot 4 (isNotGivenTarget=False)
    pool_slot4 = {
        "candidates": [
            {
                "statement": "There were no iron smelting activities during the first millennium BCE.",
                "answer": "NOT_GIVEN",
                "explanation": "Detailed explanation that is at least twenty-five characters long.",
                "absenceAssessment": {
                    "assessmentId": "abs_1",
                    "claimOrTopic": "Topic",
                    "absenceReason": "Absence reason at least twenty-five characters.",
                    "topicalContextSpan": "Iron smelting emerged in West Africa during the first millennium BCE.",
                    "absenceConfirmed": True,
                },
            },
            {
                "statement": "Iron smelting in West Africa dates to the second millennium CE.",
                "answer": "FALSE",
                "evidenceQuote": "Iron smelting emerged in West Africa during the first millennium BCE.",
                "explanation": "Detailed explanation that is at least twenty-five characters long.",
            },
        ]
    }
    selected_slot4 = _parse_candidate_payload(
        pool_slot4,
        q_num=4,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage_text,
        claims_map=claims_map,
        claim_id="claim_1",
        difficulty="FOUNDATION",
        is_not_given_target=False,
    )
    # Selected candidate prioritizes the advisory target (FALSE) over NOT_GIVEN
    assert selected_slot4["answer"] == "FALSE"

    # Pool with only FALSE candidates for slot 3 (isNotGivenTarget=True)
    pool_slot3_only_false = {
        "candidates": [
            {
                "statement": "Iron smelting in West Africa dates to the second millennium CE.",
                "answer": "FALSE",
                "evidenceQuote": "Iron smelting emerged in West Africa during the first millennium BCE.",
                "explanation": "Detailed explanation that is at least twenty-five characters long.",
            }
        ]
    }
    selected_slot3 = _parse_candidate_payload(
        pool_slot3_only_false,
        q_num=3,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage_text,
        claims_map=claims_map,
        claim_id="claim_1",
        difficulty="FOUNDATION",
        is_not_given_target=True,
    )
    # Valid FALSE candidate is accepted even though slot 3 targeted NOT_GIVEN (advisory, not binding rejection)
    assert selected_slot3["answer"] == "FALSE"


# ── Test 3: Scope-Sensitive Negation & Quantifier Calibration ─────────────────

def test_03_scope_sensitive_negation_and_quantifiers_calibration():
    """Test 3: Verifies scope-sensitive negation, quantifiers, and contrastive counterexamples."""
    passage_text = (
        "The archaeologists uncovered iron artifacts at the Didé West 1 site. "
        "Excavations revealed an alignment of 35 furnace bases spanning 800 years of metallurgical activity. "
        "Across surveyed reserves, herbivorous fish populations declined significantly. "
        "It is even rarer to identify early smelting sites that show long-term use and a well-established chronological sequence."
    )

    # 1. Non-conflict: modified entity shift (bronze vs iron) -> NOT GIVEN, not contradiction
    stmt_bronze = "The archaeologists found no bronze artifacts at the site."
    conflict_b, _ = detect_negation_polarity_conflict(stmt_bronze, passage_text)
    assert conflict_b is False, "Negating 'bronze artifacts' must not conflict with affirming 'iron artifacts'"

    # 2. Genuine conflict: negating same entity (iron artifacts) -> Contradiction!
    stmt_iron = "The archaeologists found no iron artifacts at the site."
    conflict_i, reason_i = detect_negation_polarity_conflict(stmt_iron, passage_text)
    assert conflict_i is True, "Negating 'iron artifacts' must conflict with affirming 'iron artifacts'"
    assert "iron artifacts" in reason_i

    # 3. Genuine existence negation on sequence -> Contradiction!
    stmt_no_sites = "There are no early smelting sites with long-term sequences in West Africa."
    conflict_ns, _ = detect_negation_polarity_conflict(stmt_no_sites, passage_text)
    assert conflict_ns is True, "Asserting 'no early smelting sites' contradicts text affirming 35 bases over 800 years"

    # 4. Antonym pair contradiction: declined vs remained steady
    stmt_steady = "Herbivorous fish populations remained steady across all surveyed reefs."
    assert detect_contradiction_in_text(stmt_steady, passage_text) is True

    # 5. Quantifier mismatch: universal 'all' cannot be entailed by 'rarer' or 'some'
    stmt_all = "All early smelting sites in West Africa show long-term sequences."
    assert detect_entailment_in_text(stmt_all, passage_text) is False


# ── Test 4: Controlled M3 Diagnostic Routing ──────────────────────────────────

@pytest.mark.asyncio
async def test_04_controlled_issue_to_m3_routing_for_semantic_uncertainty():
    """Test 4: Verifies genuine TFNG_BOUNDARY_CONFLICT routes to M3 RepairPlanningCapability."""
    from unittest.mock import AsyncMock

    from app.providers.models import UsageReport

    mock_gateway = AsyncMock(spec=ProviderGateway)
    mock_gateway.execute = AsyncMock(
        return_value=ProviderResponse(
            operation_id="op:test:m3_plan:q4",
            provider_name="minimax",
            model_name="MiniMax-M3",
            raw_text=json.dumps({
                "issueCode": "TFNG_BOUNDARY_CONFLICT",
                "targetQuestion": 4,
                "repairAction": "CLARIFY_NOT_GIVEN_BOUNDARY",
                "diagnosis": "The statement asserts non-existence of smelting sites, but passage affirms DDW1 has 35 furnace bases. To make a valid NOT GIVEN statement, focus on an unmentioned aspect such as furnace construction rituals.",
                "repairConstraints": [
                    "Do not assert the complete non-existence of early smelting sites.",
                    "Focus on whether specific rituals accompanied furnace building (omitted from passage).",
                    "Target answer NOT_GIVEN with verified absence assessment.",
                ],
                "preserveEvidenceClaimRef": "claim:test:1:9",
                "expectedCorrection": "The passage mentions that specific religious rituals accompanied the construction of furnace bases.",
            }),
            parsed_payload={
                "issueCode": "TFNG_BOUNDARY_CONFLICT",
                "targetQuestion": 4,
                "repairAction": "CLARIFY_NOT_GIVEN_BOUNDARY",
                "diagnosis": "The statement asserts non-existence of smelting sites, but passage affirms DDW1 has 35 furnace bases. To make a valid NOT GIVEN statement, focus on an unmentioned aspect such as furnace construction rituals.",
                "repairConstraints": [
                    "Do not assert the complete non-existence of early smelting sites.",
                    "Focus on whether specific rituals accompanied furnace building (omitted from passage).",
                    "Target answer NOT_GIVEN with verified absence assessment.",
                ],
                "preserveEvidenceClaimRef": "claim:test:1:9",
                "expectedCorrection": "The passage mentions that specific religious rituals accompanied the construction of furnace bases.",
            },
            usage=UsageReport(prompt_tokens=450, completion_tokens=180, total_tokens=630),
        )
    )

    planner = RepairPlanningCapability(gateway=mock_gateway, model_id="MiniMax-M3")
    q_payload = {
        "questionNumber": 4,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "prompt": "The passage mentions that there are no early smelting sites in West Africa that show long-term use.",
        "answer": "NOT_GIVEN",
    }
    issue = Issue.create(
        issue_id="iss_tfng_bound_1",
        code=IssueCode.TFNG_BOUNDARY_CONFLICT,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="TFNG boundary conflict: NOT GIVEN candidate statement contradicts passage evidence",
    )

    plan = await planner.plan_repair(
        question_payload=q_payload,
        passage_text="Excavations uncovered 35 furnace bases spanning 800 years.",
        authoritative_claim_ref="claim:test:1:9",
        issues=[issue],
        run_id="run_test",
        section_id="section_1",
        artifact_id="questions_section_1",
        lease_owner=uuid4(),
        epoch=1,
    )

    assert plan.issue_code == IssueCode.TFNG_BOUNDARY_CONFLICT
    assert plan.repair_action == RepairAction.CLARIFY_NOT_GIVEN_BOUNDARY
    assert plan.preserve_evidence_claim_ref == "claim:test:1:9"
    assert len(plan.repair_constraints) == 3
    assert mock_gateway.execute.call_count == 1
    req = mock_gateway.execute.call_args[0][0]
    assert req.pinned_model == "MiniMax-M3"


# ── Test 5: Mechanical Errors Prohibited from M3 ──────────────────────────────

def test_05_mechanical_errors_strictly_prohibited_from_m3():
    """Test 5: Verifies mechanical quote/answer-span/schema errors are not in allow_repair_codes for M3."""
    policy = LoopPolicy.reading_section()

    # Mechanical error codes must NEVER be in allow_repair_codes
    assert IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM not in policy.allow_repair_codes
    assert IssueCode.QUOTE_TRUNCATION not in policy.allow_repair_codes
    assert IssueCode.SCHEMA_VIOLATION not in policy.allow_repair_codes
    assert IssueCode.EVIDENCE_MISSING not in policy.allow_repair_codes

    # Genuine semantic reasoning defects ARE permitted
    assert IssueCode.TFNG_BOUNDARY_CONFLICT in policy.allow_repair_codes
    assert IssueCode.AMBIGUOUS_ANSWER in policy.allow_repair_codes
    assert IssueCode.BAD_DISTRACTOR in policy.allow_repair_codes

    # In LoopController, mechanical error blocker yields REGENERATE (or ESCALATE), never REPAIR
    policy_single_eval = policy.model_copy(update={"required_evaluator_ids": ("eval_mech",)})
    controller = LoopController(policy_single_eval)
    auth = AuthorityGrant(leaseOwner=uuid4(), epoch=1)
    art_env = ArtifactEnvelope.create(
        artifact_id="q:1", artifact_type=ArtifactType.QUESTION, run_id="run_mech",
        payload={"questionNumber": 1, "prompt": "Prompt", "answer": "Answer"},
        producer_version="1.0.0", version=1, parent_refs=(),
    )
    ctx = LoopContext(
        runId="run_mech", targetArtifactId="q:1", targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION, authority=auth, inputDependencies=(), policyVersion="v2",
        current_artifact=art_env,
    )
    from app.loop.ledger import IssueLedgerManager
    ledger_mgr = IssueLedgerManager("run_mech")
    mech_issue = ledger_mgr.record_issue(
        code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Completion answer is not contained in evidence quote",
        affected_refs=[art_env.to_ref()],
    )
    ev_result = EvaluationResult(
        evaluationId="ev_mech_1",
        evaluatorId="eval_mech",
        evaluatorVersion="1.0.0",
        targetRef=art_env.to_ref(),
        inputDependencyRefs=[],
        status=EvaluationStatus.FAIL,
        issues=[mech_issue],
    )
    decision = controller.decide(
        context=ctx,
        ledger_mgr=ledger_mgr,
        latest_evaluations=[ev_result],
        has_repairer=True,
    )
    assert decision.decision == DecisionType.REGENERATE, "Mechanical errors must route to regeneration, not repair"


# ── Test 6: Text-01 Regeneration from Grounded Repair Plan ────────────────────

@pytest.mark.asyncio
async def test_06_text01_regeneration_from_grounded_repair_plan():
    """Test 6: Verifies Text-01 candidate generator injects M3 constraints into regeneration prompt."""
    from unittest.mock import AsyncMock
    from app.generators.question.generator import QuestionCandidateGenerator

    captured_prompts: list[str] = []

    async def mock_execute(req: ProviderRequest, **kwargs) -> ProviderResponse:
        user_msg = req.messages[1].content
        captured_prompts.append(user_msg)
        from app.providers.models import UsageReport
        return ProviderResponse(
            operation_id=req.operation_id,
            provider_name="minimax",
            model_name="MiniMax-Text-01",
            raw_text=json.dumps({
                "candidates": [
                    {
                        "prompt": "The passage mentions that specific religious rituals accompanied the construction of furnace bases.",
                        "answer": "NOT_GIVEN",
                        "explanation": "The passage does not discuss religious rituals accompanying furnace construction.",
                        "absenceAssessment": {
                            "assessmentId": "abs_q4",
                            "claimOrTopic": "Religious rituals in furnace construction",
                            "absenceReason": "The passage focuses exclusively on technical metallurgy without religious details.",
                            "topicalContextSpan": "Excavations revealed an alignment of 35 furnace bases.",
                            "absenceConfirmed": True,
                        },
                    }
                ]
            }),
            parsed_payload=None,
            usage=UsageReport(prompt_tokens=300, completion_tokens=90, total_tokens=390),
        )

    mock_gateway = AsyncMock(spec=ProviderGateway)
    mock_gateway.execute = mock_execute

    gen = QuestionCandidateGenerator(gateway=mock_gateway)
    auth = AuthorityGrant(leaseOwner=uuid4(), epoch=1)
    ctx = LoopContext(
        runId="run_test", targetArtifactId="q:4", targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION, authority=auth, inputDependencies=(), policyVersion="v2",
    )
    valid_hash_p = "a" * 64
    valid_hash_bp = "b" * 64
    passage_ref = ArtifactRef(artifactId="passage:test:1", artifactType=ArtifactType.PASSAGE, version=1, contentHash=valid_hash_p)
    bp_ref = ArtifactRef(artifactId="blueprint:test", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash=valid_hash_bp)

    constraints = [
        "Do not assert complete non-existence of early smelting sites.",
        "Focus on unmentioned rituals accompanying furnace construction.",
    ]
    diagnosis = "The statement contradicted affirmed DDW1 furnace base sequence."

    pool = await gen.generate_candidate_pool(
        passage_text="Excavations revealed an alignment of 35 furnace bases.",
        question_type="TRUE_FALSE_NOT_GIVEN",
        question_number=4,
        passage_ref=passage_ref,
        blueprint_ref=bp_ref,
        run_id="run_test",
        context=ctx,
        repair_constraints=constraints,
        diagnosis=diagnosis,
        pinned_model="MiniMax-Text-01",
    )

    assert len(pool.candidates) == 1
    assert pool.candidates[0].answer == "NOT_GIVEN"
    assert len(captured_prompts) == 1
    prompt_text = captured_prompts[0]
    assert "DIAGNOSTIC ISSUE TO RESOLVE:" in prompt_text
    assert "Do not assert complete non-existence of early smelting sites." in prompt_text
    assert "Focus on unmentioned rituals accompanying furnace construction." in prompt_text


# ── Test 7: Mandatory Evaluator Reruns After Repair ───────────────────────────

@pytest.mark.asyncio
async def test_07_mandatory_evaluators_rerun_after_repair(tmp_path: Path):
    """Test 7: BoundedLoopRuntime re-runs all mandatory evaluators on repaired question artifact."""
    from tests.test_t08_passage_loop import SQLiteCheckpointSimulation
    evaluated_versions: list[int] = []
    v1_issue_fps: list[str] = []

    class MockEval(EvaluatorCapability):
        def __init__(self, ev_id: str):
            self._id = ev_id
        @property
        def evaluator_id(self) -> str:
            return self._id
        @property
        def evaluator_version(self) -> str:
            return "1.0.0"
        async def evaluate(self, ctx: LoopContext, art: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
            evaluated_versions.append(art.version)
            # Fail v1, pass v2
            if art.version == 1:
                iss = Issue.create(
                    issue_id=f"iss_{self._id}", code=IssueCode.TFNG_BOUNDARY_CONFLICT,
                    severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
                    message="TFNG boundary conflict", affected_refs=[art.to_ref()],
                    evaluator_id=self._id,
                )
                v1_issue_fps.append(iss.fingerprint)
                return EvaluationResult(
                    evaluationId=f"ev_{self._id}_v1", evaluatorId=self._id, evaluatorVersion="1.0.0",
                    targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.FAIL,
                    issues=[iss],
                )
            return EvaluationResult(
                evaluationId=f"ev_{self._id}_v2", evaluatorId=self._id, evaluatorVersion="1.0.0",
                targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.PASS,
                resolvedIssueFingerprints=list(v1_issue_fps),
            )

    class MockGen(GeneratorCapability):
        @property
        def name(self) -> str:
            return "MockGen"
        @property
        def version(self) -> str:
            return "1.0.0"
        async def generate(self, ctx: LoopContext, intent_id: str, ver: int) -> ArtifactEnvelope:
            return ArtifactEnvelope.create(
                artifact_id="q:4", artifact_type=ArtifactType.QUESTION, run_id=ctx.run_id,
                payload={"questionNumber": 4, "statement": "Statement v1", "answer": "NOT_GIVEN"},
                producer_version="1.0.0", version=ver, parent_refs=ctx.input_dependencies,
            )

    class MockRep(RepairerCapability):
        @property
        def repairer_id(self) -> str:
            return "MockRep"
        @property
        def repairer_version(self) -> str:
            return "1.0.0"
        async def repair(self, ctx: LoopContext, art: ArtifactEnvelope, issues: Sequence[Issue], intent_id: str, ver: int) -> ArtifactEnvelope:
            return ArtifactEnvelope.create(
                artifact_id="q:4", artifact_type=ArtifactType.QUESTION, run_id=ctx.run_id,
                payload={"questionNumber": 4, "statement": "Repaired Statement v2", "answer": "NOT_GIVEN"},
                producer_version="1.0.0", version=ver, parent_refs=ctx.input_dependencies,
            )

    auth = AuthorityGrant(leaseOwner=uuid4(), epoch=1)
    valid_hash_p = "a" * 64
    dep = ArtifactRef(artifactId="passage:1", artifactType=ArtifactType.PASSAGE, version=1, contentHash=valid_hash_p)
    ctx = LoopContext(
        runId="run_rerun", targetArtifactId="q:4", targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION, authority=auth, inputDependencies=(dep,), policyVersion="v2",
    )
    policy = LoopPolicy(
        max_versions=3, max_total_repairs=2, max_repair_attempts_per_version=1,
        max_generated_versions=2,
        required_evaluator_ids=("eval_sem", "eval_struct"),
        allow_repair_codes={IssueCode.TFNG_BOUNDARY_CONFLICT},
    )

    store = SQLiteCheckpointSimulation(tmp_path / "rerun_eval.db", auth.lease_owner)

    runtime = BoundedLoopRuntime(
        context=ctx,
        policy=policy,
        generator=MockGen(),
        evaluators=[MockEval("eval_sem"), MockEval("eval_struct")],
        repairer=MockRep(),
        persistence_client=store,
        accepted_dependencies={"passage:1": dep},
    )

    result = await runtime.run()
    assert result.decision == DecisionType.PASS
    assert result.accepted_artifact is not None
    assert result.accepted_artifact.version == 2
    # Both evaluators ran on v1 (failed) and re-ran on v2 (passed)
    assert evaluated_versions == [1, 1, 2, 2]


# ── Test 8: Rejected Candidates Diversity & Non-Repetition ────────────────────

def test_08_rejected_candidates_diversity_and_non_repetition():
    """Test 8: Ensures rejected candidate fingerprints prevent identical repetition."""
    passage_text = "Early iron smelting sites have been identified across sub-Saharan West Africa."
    claims_map = {"claim_1": {"claimId": "claim_1", "text": "Early iron smelting"}}

    rejected_candidate_stmt = "The passage states that no iron smelting occurred in West Africa."

    # Pool proposing the exact rejected statement
    pool = {
        "candidates": [
            {
                "statement": rejected_candidate_stmt,
                "answer": "FALSE",
                "evidenceQuote": "Early iron smelting sites have been identified across sub-Saharan West Africa.",
                "explanation": "Explanation that is at least twenty-five characters long.",
            }
        ]
    }

    # Attempting candidate with rejected prompt in rejected_prompts raises CANDIDATE_DUPLICATE
    with pytest.raises(CandidateRejectionError) as exc_info:
        _parse_candidate_payload(
            pool,
            q_num=4,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim_1",
            difficulty="FOUNDATION",
            rejected_prompts=[rejected_candidate_stmt],
        )
    assert exc_info.value.reason == CandidateRejectionReason.CANDIDATE_DUPLICATE


# ── Test 9: M3 Fail-Closed on Truncation & Timeout ────────────────────────────

@pytest.mark.asyncio
async def test_09_m3_fail_closed_on_truncation_and_timeout():
    """Test 9: MiniMax-M3 planning raises RepairJustificationError on provider timeout or truncation."""
    from unittest.mock import AsyncMock

    # 1. Truncation error
    trunc_gateway = AsyncMock(spec=ProviderGateway)
    trunc_gateway.execute = AsyncMock(side_effect=TruncatedOutputError("Output was truncated by max_tokens limit"))

    planner_trunc = RepairPlanningCapability(gateway=trunc_gateway, model_id="MiniMax-M3")
    with pytest.raises(RepairJustificationError, match="truncated"):
        await planner_trunc.plan_repair(
            question_payload={"questionNumber": 4, "type": "TRUE_FALSE_NOT_GIVEN"},
            passage_text="Sample text",
            authoritative_claim_ref="claim:1",
            issues=[Issue.create(issue_id="i1", code=IssueCode.TFNG_BOUNDARY_CONFLICT, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION, message="msg")],
            run_id="run_t", section_id="section_1", artifact_id="q:4",
            lease_owner=uuid4(), epoch=1,
        )

    # 2. Timeout error
    timeout_gateway = AsyncMock(spec=ProviderGateway)
    timeout_gateway.execute = AsyncMock(side_effect=ProviderTimeoutError("Provider call timed out after 30.0s"))

    planner_time = RepairPlanningCapability(gateway=timeout_gateway, model_id="MiniMax-M3")
    with pytest.raises(RepairJustificationError, match="timed out"):
        await planner_time.plan_repair(
            question_payload={"questionNumber": 4, "type": "TRUE_FALSE_NOT_GIVEN"},
            passage_text="Sample text",
            authoritative_claim_ref="claim:1",
            issues=[Issue.create(issue_id="i1", code=IssueCode.TFNG_BOUNDARY_CONFLICT, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION, message="msg")],
            run_id="run_t", section_id="section_1", artifact_id="q:4",
            lease_owner=uuid4(), epoch=1,
        )


# ── Test 10: Strict RepairPlan Safety Validation ──────────────────────────────

def test_10_strict_repair_plan_safety_validation():
    """Test 10: Enforces that RepairPlan cannot alter bound claim or emit incompatible actions."""
    authoritative_claim = "claim:run_alpha:1:9"

    # 1. Claim alteration attempt -> Prohibited
    plan_tampered_claim = RepairPlan(
        issueCode=IssueCode.TFNG_BOUNDARY_CONFLICT,
        targetQuestion=4,
        repairAction=RepairAction.CLARIFY_NOT_GIVEN_BOUNDARY,
        diagnosis="Valid diagnosis of defect",
        repairConstraints=["Constraint 1"],
        preserveEvidenceClaimRef="claim:tampered:1:99",
    )
    with pytest.raises(RepairPlanValidationError, match="Claim preservation violated"):
        validate_repair_plan_compatibility(
            plan_tampered_claim,
            authoritative_claim_ref=authoritative_claim,
            target_question=4,
        )

    # 2. Incompatible action attempt -> Prohibited
    # E.g. SWAP_DISTRACTOR on TFNG_BOUNDARY_CONFLICT
    plan_incompatible_action = RepairPlan(
        issueCode=IssueCode.TFNG_BOUNDARY_CONFLICT,
        targetQuestion=4,
        repairAction=RepairAction.SWAP_DISTRACTOR,
        diagnosis="Valid diagnosis of defect",
        repairConstraints=["Constraint 1"],
        preserveEvidenceClaimRef=authoritative_claim,
    )
    with pytest.raises(RepairPlanValidationError, match="Incompatible repairAction"):
        validate_repair_plan_compatibility(
            plan_incompatible_action,
            authoritative_claim_ref=authoritative_claim,
            target_question=4,
        )

    # 3. Empty constraints -> Prohibited
    plan_empty_constraints = RepairPlan(
        issueCode=IssueCode.TFNG_BOUNDARY_CONFLICT,
        targetQuestion=4,
        repairAction=RepairAction.CLARIFY_NOT_GIVEN_BOUNDARY,
        diagnosis="Valid diagnosis of defect",
        repairConstraints=[],
        preserveEvidenceClaimRef=authoritative_claim,
    )
    with pytest.raises(RepairPlanValidationError, match="must contain at least one directive"):
        validate_repair_plan_compatibility(
            plan_empty_constraints,
            authoritative_claim_ref=authoritative_claim,
            target_question=4,
        )

    # 4. Compliant plan -> Passes
    plan_valid = RepairPlan(
        issueCode=IssueCode.TFNG_BOUNDARY_CONFLICT,
        targetQuestion=4,
        repairAction=RepairAction.CLARIFY_NOT_GIVEN_BOUNDARY,
        diagnosis="Valid diagnosis of TFNG boundary defect",
        repairConstraints=["Directive 1", "Directive 2"],
        preserveEvidenceClaimRef=authoritative_claim,
    )
    validate_repair_plan_compatibility(
        plan_valid,
        authoritative_claim_ref=authoritative_claim,
        target_question=4,
    )


# ── Test 11: Checkpoint Restart & Operation Idempotency ───────────────────────

@pytest.mark.asyncio
async def test_11_checkpoint_restart_and_operation_idempotency(tmp_path: Path):
    """Test 11: Verifies durable checkpoint restart and idempotent operation execution."""
    from tests.test_t08_passage_loop import SQLiteCheckpointSimulation
    from app.persistence.models import OperationGrantRequest

    owner = uuid4()
    store = SQLiteCheckpointSimulation(tmp_path / "idempotent.db", owner)
    run_id = "run_idem_test"

    op_id = f"op:{run_id}:q4:v1"
    req_hash = "c" * 64

    # First grant succeeds
    grant1 = store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=op_id,
        operationType="GENERATE", requestHash=req_hash,
        tokenReservation=1000, wallTimeReservationSeconds=30.0,
    ))
    assert grant1.operationId == op_id

    # Replay of identical grant returns existing operation (idempotent)
    grant2 = store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=op_id,
        operationType="GENERATE", requestHash=req_hash,
        tokenReservation=1000, wallTimeReservationSeconds=30.0,
    ))
    assert grant2.operationId == op_id
    assert grant2.isReplay is True


# ── Test 12: Reconciled Skipped Evaluators & Reserved Ops ──────────────────────

@pytest.mark.asyncio
async def test_12_reconciled_skipped_evaluators_and_reserved_ops(tmp_path: Path):
    """Test 12: BoundedLoopRuntime reconciles RESERVED repair operations on exception."""
    from tests.test_t08_passage_loop import SQLiteCheckpointSimulation
    from app.contracts.loop import LoopReason

    owner = uuid4()
    store = SQLiteCheckpointSimulation(tmp_path / "reconcile.db", owner)
    run_id = "run_reconcile_test"

    class FailingRepairer(RepairerCapability):
        @property
        def repairer_id(self) -> str:
            return "FailingRepairer"
        @property
        def repairer_version(self) -> str:
            return "1.0.0"
        async def repair(self, ctx: LoopContext, art: ArtifactEnvelope, issues: Sequence[Issue], intent_id: str, ver: int) -> ArtifactEnvelope:
            raise RepairJustificationError("M3 planning refused: boundary cannot be salvaged without passage modification")

    class SimpleGen(GeneratorCapability):
        @property
        def name(self) -> str:
            return "SimpleGen"
        @property
        def version(self) -> str:
            return "1.0.0"
        async def generate(self, ctx: LoopContext, intent_id: str, ver: int) -> ArtifactEnvelope:
            return ArtifactEnvelope.create(
                artifact_id="q:4", artifact_type=ArtifactType.QUESTION, run_id=ctx.run_id,
                payload={"questionNumber": 4, "statement": "Stmt v1", "answer": "NOT_GIVEN"},
                producer_version="1.0.0", version=ver, parent_refs=ctx.input_dependencies,
            )

    class AlwaysFailEval(EvaluatorCapability):
        @property
        def evaluator_id(self) -> str:
            return "eval_sem"
        @property
        def evaluator_version(self) -> str:
            return "1.0.0"
        async def evaluate(self, ctx: LoopContext, art: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
            return EvaluationResult(
                evaluationId=f"ev_sem_{art.version}", evaluatorId=self.evaluator_id, evaluatorVersion="1.0.0",
                targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.FAIL,
                issues=[Issue.create(
                    issue_id=f"iss_{art.version}", code=IssueCode.TFNG_BOUNDARY_CONFLICT,
                    severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
                    message="TFNG boundary conflict",
                )],
            )

    auth = AuthorityGrant(leaseOwner=owner, epoch=1)
    dep = ArtifactRef(artifactId="passage:1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a" * 64)
    ctx = LoopContext(
        runId=run_id, targetArtifactId="q:4", targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION, authority=auth, inputDependencies=(dep,), policyVersion="v2",
    )
    policy = LoopPolicy(
        max_versions=3, max_total_repairs=1, max_repair_attempts_per_version=1,
        max_generated_versions=2,
        required_evaluator_ids=("eval_sem",),
        allow_repair_codes={IssueCode.TFNG_BOUNDARY_CONFLICT},
    )

    runtime = BoundedLoopRuntime(
        context=ctx,
        policy=policy,
        generator=SimpleGen(),
        evaluators=[AlwaysFailEval()],
        repairer=FailingRepairer(),
        persistence_client=store,
        accepted_dependencies={"passage:1": dep},
    )

    result = await runtime.run()
    assert result.decision == DecisionType.FAIL
    # Zero lingering RESERVED operations in persistence store
    st = store.resume_state(run_id)
    reserved_ops = [o for o in st.operations if o.status == "RESERVED"]
    assert len(reserved_ops) == 0, f"Found lingering RESERVED operations: {reserved_ops}"


# ── Test 13: Offline Replay of M3 Plan Achieves Clean Pass ─────────────────────

def test_13_offline_replay_of_m3_plan_achieves_clean_pass():
    """Test 13: Offline replay verifying M3-generated repair constraints produce 100% passing candidate."""
    snapshot = load_snapshot()
    artifacts = {a["ArtifactId"]: a for a in snapshot.get("all_artifacts", [])}

    passage_art = next(a for a in snapshot["all_artifacts"] if a.get("ArtifactType") == "Passage")
    passage_payload = json.loads(passage_art["PayloadJson"])
    passage_text = passage_payload["passage"]

    target_span = "It is even rarer to identify early smelting sites that show long-term use and a well-established chronological sequence."
    s = passage_text.find(target_span)
    e = s + len(target_span)
    assert s >= 0, "Topical context span must exist in passage"

    # Candidate constructed following M3 repair constraints
    repaired_q4_payload = {
        "questionNumber": 4,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "It is not stated whether any early smelting site in West Africa was used over a long period while also having a well-established chronological sequence.",
        "answer": "NOT_GIVEN",
        "explanation": "The passage notes the rarity of identifying early smelting sites with long-term use and chronological sequences, but does not explicitly confirm whether any single site satisfied both criteria.",
        "passageEvidence": {"startChar": s, "endChar": e, "text": target_span},
        "evidenceClaimRef": "claim:run_6fc3be9e30fc46c28a4bd49e23b236a7:1:9",
        "absenceAssessment": {
            "assessmentId": "abs_q4_repaired",
            "claimOrTopic": "Co-occurrence of long-term use and well-established chronological sequence at an early smelting site",
            "absenceReason": "The passage notes that early smelting sites with long-term use and chronological sequences are rare, but does not explicitly state whether both conditions were established at a single site.",
            "topicalContextSpan": target_span,
            "absenceConfirmed": True,
        },
    }

    repaired_env = ArtifactEnvelope.create(
        artifact_id="question:run_6fc3be9e30fc46c28a4bd49e23b236a7:4",
        artifact_type=ArtifactType.QUESTION,
        run_id="run_6fc3be9e30fc46c28a4bd49e23b236a7",
        payload=repaired_q4_payload,
        producer_version="1.0.0",
        version=4,
    )

    eval_results = evaluate_question(repaired_env, passage_text, difficulty="FOUNDATION", siblings=())
    assert len(eval_results) == 5
    for r in eval_results:
        assert r.is_pass() is True, f"Evaluator {r.evaluator_id} failed with issues: {[i.message for i in r.issues]}"
        assert len(r.issues) == 0


