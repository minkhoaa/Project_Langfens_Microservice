"""Regression tests for 2026-10-21 S01 corrective patch.

Task 1: Policy Bridge & Snapshot Generation Fix (P0-A).

LoopPolicy.from_pinned_execution_policy must:
- Produce a 32-bit positive-integer cap snapshot (.NET-compatible).
- Set cap_profile_sha256 = SHA-256 of that JSON snapshot (not policy.hash).
- Preserve policy.hash as a separate field on LoopPolicy.
- Include .NET MatchesRunBudget keys in the snapshot.
"""

from __future__ import annotations

import pytest

from app.loop.policy import LoopPolicy, cap_snapshot_sha256
from app.reading_policy import (
    PinnedExecutionPolicy,
    MAX_PROVIDER_CALL_SECONDS,
    MAX_SECTION_TOKEN_CAP,
    MAX_SECTION_WALL_SECONDS,
)


def test_scenario_01_policy_bridge_snapshot_and_hash():
    """P0-A: LoopPolicy.from_pinned_execution_policy must produce valid 32-bit int snapshot and separate policy.hash."""
    unified_policy = PinnedExecutionPolicy(provider="minimax")
    sec_policy = LoopPolicy.from_pinned_execution_policy(unified_policy, scope="SECTION")

    # 1. Finite ceilings enforced
    assert not sec_policy.is_unlimited
    assert sec_policy.max_wall_time_seconds <= MAX_SECTION_WALL_SECONDS
    assert sec_policy.max_total_tokens <= MAX_SECTION_TOKEN_CAP
    assert sec_policy.operation_wall_reservation_seconds <= MAX_PROVIDER_CALL_SECONDS

    # 2. Hash separation: cap_profile_sha256 matches snapshot SHA-256, while policy_hash matches unified_policy.hash
    snapshot = sec_policy.cap_profile_snapshot
    expected_snapshot_sha = cap_snapshot_sha256(snapshot)
    assert sec_policy.cap_profile_sha256 == expected_snapshot_sha
    assert sec_policy.cap_profile_sha256 != unified_policy.hash
    assert getattr(sec_policy, "policy_hash", None) == unified_policy.hash

    # 3. .NET CheckpointService MatchesRunBudget keys present and typed as positive 32-bit integers
    caps = snapshot["caps"]
    for k in (
        "standaloneRunBudgetCapCalls",
        "standaloneRunBudgetCapTokens",
        "standaloneRunBudgetCapWallTimeSeconds",
        "loopOperationWallReservationSeconds",
    ):
        assert k in caps
        assert isinstance(caps[k], int)
        assert 0 < caps[k] <= 2_147_483_647

    # 4. LoopPolicy.from_cap_snapshot round-trip and validation both succeed
    restored_policy = LoopPolicy.from_cap_snapshot(snapshot)
    assert restored_policy.cap_profile_sha256 == expected_snapshot_sha
    restored_policy.validate_cap_bounds()


from app.generators.question.generator import QuestionCandidateGenerator
from app.contracts.artifact import ArtifactRef, ArtifactType


def test_scenario_04_short_evidence_quote_rejected():
    """P1-C: Evidence quote not in passage must be rejected even if under 15 characters."""
    gen = QuestionCandidateGenerator(gateway=None)
    passage_text = "The solar system contains eight planets orbiting the central star."
    raw = [{
        "prompt": "How many planets orbit the central star?",
        "answer": "eight",
        "evidenceQuote": "nine planets",  # 12 chars: under 15 chars, not in passage
    }]
    p_ref = ArtifactRef(artifactId="art_p1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a"*64)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b"*64)
    pool = gen.build_pool_from_raw_candidates("slot_1", 1, "ShortAnswer", raw, passage_text, p_ref, bp_ref)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert cand.rejected is True
    assert any("unsupported by passage" in r.lower() for r in cand.rejection_reasons)


def test_scenario_05_missing_prompt_rejected():
    """P1-C: Missing prompt must not trigger fabricated prompt fallback."""
    gen = QuestionCandidateGenerator(gateway=None)
    passage_text = "The solar system contains eight planets orbiting the central star."
    raw = [{
        "prompt": "",  # Empty prompt
        "answer": "eight",
        "evidenceQuote": "eight planets",
    }]
    p_ref = ArtifactRef(artifactId="art_p1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a"*64)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b"*64)
    pool = gen.build_pool_from_raw_candidates("slot_1", 1, "ShortAnswer", raw, passage_text, p_ref, bp_ref)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert cand.rejected is True
    assert "Question 1 prompt." not in cand.prompt
    assert any("missing prompt" in r.lower() for r in cand.rejection_reasons)


def test_scenario_06_mcq_answer_not_in_options_rejected():
    """P1-C: MCQ answer key not resolving to options A-D must be rejected."""
    gen = QuestionCandidateGenerator(gateway=None)
    passage_text = "Mars is known as the red planet due to iron oxide."
    raw = [{
        "prompt": "Why is Mars known as the red planet?",
        "options": [
            {"key": "A", "text": "Water oceans"},
            {"key": "B", "text": "Iron oxide"},
            {"key": "C", "text": "Methane gas"},
            {"key": "D", "text": "Volcanic dust"},
        ],
        "answer": "E",  # Not in options A-D
        "evidenceQuote": "iron oxide",
    }]
    p_ref = ArtifactRef(artifactId="art_p1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="a"*64)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="b"*64)
    pool = gen.build_pool_from_raw_candidates("slot_1", 1, "MultipleChoiceSingle", raw, passage_text, p_ref, bp_ref)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert cand.rejected is True
    assert any("not found in options" in r.lower() for r in cand.rejection_reasons)


from uuid import uuid4

from app.loop.context import AuthorityGrant, LoopContext
from app.contracts.issue import IssueScope
from app.loop.runtime import BoundedLoopRuntime
from tests.test_t08_passage_loop import DurableStoreFake


class _SectionIdAwareStoreFake(DurableStoreFake):
    """Fake store that persists ``sectionId`` on granted operations.

    ``DurableStoreFake`` drops it, so a resume projection built on top of it
    can never carry the parent operation's SectionId format. The real
    exam-service persists and projects it, so the regression tests must too.
    """

    def grant_operation(self, req):
        grant = super().grant_operation(req)
        state = self._state()
        op = state["ops"].get(req.operationId)
        if op is not None:
            op["sectionId"] = getattr(req, "sectionId", None)
            self._save(state)
        return grant


@pytest.mark.asyncio
async def test_scenario_07_workflow_recovery_section_isolated(tmp_path):
    """P1-D: QuestionCandidateLoop must not adopt a reserved workflow belonging to another section."""
    from app.loop.question import QuestionCandidateLoop
    from app.persistence.models import OperationGrantRequest

    owner = uuid4()
    run_id = f"run_wf_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "wf.db", owner=owner, epoch=1)

    # Seed an existing reserved workflow for Section 1
    s1_wf_op = f"op_workflow_qcand_s1_{run_id[:8]}"
    store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=s1_wf_op,
        operationType="WORKFLOW", requestHash=f"wf:s1:{run_id}",
        tokenReservation=10000, wallTimeReservationSeconds=100.0,
        sectionId="1", artifactId=None,
    ))

    # When QuestionCandidateLoop runs for Section 2, it MUST NOT pick s1_wf_op
    stored_state = store.resume_state(run_id)

    # Determine workflow ID for Section 2
    expected_s2_op = f"op_workflow_qcand_s2_{run_id[:8]}"
    matching = [
        o for o in (stored_state.operations or [])
        if o.operationType == "WORKFLOW" and o.status == "RESERVED" and o.operationId == expected_s2_op
    ]
    # S1 workflow is not adopted for S2
    assert s1_wf_op not in [m.operationId for m in matching]

    # Deterministic workflow selection on QuestionCandidateLoop
    q_loop = QuestionCandidateLoop(generator=None, persistence_client=store)
    res_s2 = q_loop._select_reserved_workflow_operation(stored_state, 2, run_id)
    assert res_s2 is None, "Must not adopt S1 workflow for Section 2"

    # When S2 workflow is seeded, deterministic selection recovers it
    store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=expected_s2_op,
        operationType="WORKFLOW", requestHash=f"wf:s2:{run_id}",
        tokenReservation=10000, wallTimeReservationSeconds=100.0,
        sectionId="2", artifactId=None,
    ))
    res_s2_found = q_loop._select_reserved_workflow_operation(store.resume_state(run_id), 2, run_id)
    assert res_s2_found is not None
    assert res_s2_found.operationId == expected_s2_op


@pytest.mark.asyncio
async def test_scenario_08_section_id_inheritance(tmp_path):
    """P1-D: Child operation must inherit parent operation SectionId format."""
    from app.persistence.models import OperationGrantRequest

    owner = uuid4()
    run_id = f"run_sec_inherit_{uuid4().hex[:8]}"
    store = _SectionIdAwareStoreFake(tmp_path / "sec_inherit.db", owner=owner, epoch=1)

    parent_op_id = f"parent_op_{uuid4().hex[:8]}"
    # Parent operation was granted with sectionId="section_1"
    store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner, operationId=parent_op_id,
        operationType="WORKFLOW", requestHash=f"req:parent:{run_id}",
        tokenReservation=20000, wallTimeReservationSeconds=200.0,
        sectionId="section_1", artifactId=None,
    ))

    # Child runtime initialized with context.section_id = 1
    ctx = LoopContext(
        runId=run_id, targetArtifactId="art_q_1", targetArtifactType=ArtifactType.QUESTION,
        sectionId=1, scope=IssueScope.QUESTION, authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        parent_operation_id=parent_op_id,
    )
    runtime = BoundedLoopRuntime(
        context=ctx, policy=LoopPolicy.from_settings(), generator=None, evaluators=[],
        persistence_client=store,
    )
    intent = runtime._intent("GENERATE", 1, 1000, "1.0.0", {"test": True})

    # Execute reservation
    res = runtime._reserve(intent)
    assert res is True
    # The granted child operation in store must have inherited "section_1"
    child_op = store.resume_state(run_id).operations[-1]
    assert child_op.sectionId == "section_1"


from app.contracts.artifact import ArtifactEnvelope, ArtifactType, ArtifactRef
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.loop import DecisionType, LoopState
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.loop.passage import PassageLoop
from tests.test_t08_passage_loop import DurableStoreFake


@pytest.mark.asyncio
async def test_scenario_02_zero_call_resume_requires_evaluations(tmp_path):
    """P0-B: Zero-call resume must reject PASS if accepted artifact lacks required evaluations."""
    owner = uuid4()
    run_id = f"run_no_eval_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "no_eval.db", owner=owner, epoch=1)

    bp_art = ArtifactEnvelope.create("art_bp", ArtifactType.EXAM_BLUEPRINT, run_id, {"title": "BP"}, "2.0.0", version=1)
    eg_art = ArtifactEnvelope.create("art_eg", ArtifactType.EVIDENCE_GRAPH, run_id, {"title": "EG"}, "2.0.0", version=1)
    p_env = ArtifactEnvelope.create(
        "art_passage_s1", ArtifactType.PASSAGE, run_id,
        {"text": "Sample passage content. " * 50, "wordCount": 800}, "2.0.0", version=1,
        parent_refs=[bp_art.to_ref(), eg_art.to_ref()],
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": bp_art, "evaluations": [], "operationId": "op_bp"})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": eg_art, "evaluations": [], "operationId": "op_eg"})())
    # Commit passage with evaluations=[] (missing required evaluations)
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    passage_loop = PassageLoop(generator=PassageGenerator(gateway=None), persistence_client=store)
    p_ctx = PassageGenerationContext(
        topic="Topic", section_index=1, source_text="Source " * 20,
        blueprint_ref=bp_art.to_ref(), evidence_graph_ref=eg_art.to_ref(),
    )

    # Because evaluations are missing, zero-call resume must NOT award PASS early
    res = await passage_loop.run(passage_context=p_ctx, run_id=run_id, lease_owner=owner, epoch=1)
    # It must not be a zero-call completed resume without evaluations
    assert not (res.decision == DecisionType.PASS and res.calls_count == 0)


@pytest.mark.asyncio
async def test_scenario_03_missing_parent_ref_rejected(tmp_path):
    """P0-B: Missing parent ref in store_accepted_heads must fail closed (loophole closed)."""
    owner = uuid4()
    run_id = f"run_missing_p_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "missing_p.db", owner=owner, epoch=1)

    bp_ref = ArtifactRef(artifactId="art_bp_missing", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="a"*64)
    p_env = ArtifactEnvelope.create(
        "art_passage_s1", ArtifactType.PASSAGE, run_id,
        {"text": "Sample passage content. " * 50, "wordCount": 800}, "2.0.0", version=1,
        parent_refs=[bp_ref],
    )
    # art_bp_missing is NOT in store
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    passage_loop = PassageLoop(generator=PassageGenerator(gateway=None), persistence_client=store)
    p_ctx = PassageGenerationContext(
        topic="Topic", section_index=1, source_text="Source " * 20,
        blueprint_ref=bp_ref, evidence_graph_ref=ArtifactRef(artifactId="art_eg", artifactType=ArtifactType.EVIDENCE_GRAPH, version=1, contentHash="b"*64),
    )
    # Must not resume with zero calls
    res = await passage_loop.run(passage_context=p_ctx, run_id=run_id, lease_owner=owner, epoch=1)
    assert res.calls_count != 0 or res.decision != DecisionType.PASS
