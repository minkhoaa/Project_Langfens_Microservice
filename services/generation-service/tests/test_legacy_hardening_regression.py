"""Focused Regression Suite for Hardened Reading Generation Engine.

Verifies:
1. Correct accepted artifact resumes with 0 provider calls.
2. Corrupted hash/parent refs are rejected.
3. Missing checkpoint never creates fabricated accepted content.
4. Invalid MCQ answer/evidence is rejected.
5. Missing semantic/blind evaluation blocks acceptance.
6. Provider timeout and UNKNOWN_OUTCOME never trigger unsafe replay.
7. Fencing/CAS conflict prevents stale commits.
8. Legacy and unified contracts remain compatible.
"""
from __future__ import annotations

import json
from pathlib import Path
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.blueprint import QuestionType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import IssueScope
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.generators.question.context import OptionItem, QuestionCandidate, QuestionCandidatePool
from app.generators.question.generator import QuestionCandidateGenerator
from app.loop.capabilities import EvaluatorCapability, GeneratorCapability
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.passage import PassageLoop
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from app.persistence.client import CheckpointApiError
from app.persistence.models import LoopCursorCheckpointRequest
from app.reading_policy import (
    MAX_PROVIDER_CALL_SECONDS,
    MAX_SECTION_TOKEN_CAP,
    MAX_SECTION_WALL_SECONDS,
    PinnedExecutionPolicy,
)
from tests.test_t08_passage_loop import DurableStoreFake, FakePassageProvider


# ── Scenario 1: Correct accepted artifact resumes with 0 provider calls ──────

@pytest.mark.asyncio
async def test_regression_01_correct_accepted_artifact_resumes_zero_provider_calls(tmp_path: Path):
    """1. Correct accepted artifact resumes with 0 provider calls."""
    owner = uuid4()
    run_id = f"run_reg01_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "reg01.db", owner=owner, epoch=1)

    # Seed upstream dependencies into store
    bp_art = ArtifactEnvelope.create("art_bp", ArtifactType.EXAM_BLUEPRINT, run_id, {"title": "BP"}, "2.0.0", version=1)
    eg_art = ArtifactEnvelope.create("art_eg", ArtifactType.EVIDENCE_GRAPH, run_id, {"title": "EG"}, "2.0.0", version=1)
    bp_ref = bp_art.to_ref()
    eg_ref = eg_art.to_ref()
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": bp_art, "evaluations": [], "operationId": "op_bp"})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": eg_art, "evaluations": [], "operationId": "op_eg"})())

    # Create and commit an accepted passage artifact
    p_env = ArtifactEnvelope.create(
        "art_passage_s1",
        ArtifactType.PASSAGE,
        run_id,
        {"text": "Ancient coral ecosystems exhibited significant biological diversity across millennia. " * 20, "wordCount": 800},
        "2.0.0",
        version=1,
        parent_refs=[bp_ref, eg_ref],
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    generator = PassageGenerator(gateway=None)
    passage_loop = PassageLoop(generator=generator, persistence_client=store)

    p_ctx = PassageGenerationContext(
        topic="Ancient Corals",
        section_index=1,
        source_text="Ancient coral ecosystems exhibited significant biological diversity across millennia. " * 5,
        blueprint_ref=bp_ref,
        evidence_graph_ref=eg_ref,
    )

    res = await passage_loop.run(
        passage_context=p_ctx,
        run_id=run_id,
        lease_owner=owner,
        epoch=1,
    )

    assert res.decision == DecisionType.PASS
    assert res.terminal_state == LoopState.COMPLETED
    assert res.accepted_artifact is not None
    assert res.accepted_artifact.content_hash == p_env.content_hash
    assert res.calls_count == 0
    assert res.tokens_consumed == 0


# ── Scenario 2: Corrupted hash/parent refs are rejected ───────────────────────

@pytest.mark.asyncio
async def test_regression_02_corrupted_hash_rejected(tmp_path: Path):
    """2a. Corrupted accepted hash in checkpoint is rejected fail-closed."""
    owner = uuid4()
    run_id = f"run_reg02_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "reg02.db", owner=owner, epoch=1)

    bp_art = ArtifactEnvelope.create("art_bp", ArtifactType.EXAM_BLUEPRINT, run_id, {"title": "BP"}, "2.0.0", version=1)
    eg_art = ArtifactEnvelope.create("art_eg", ArtifactType.EVIDENCE_GRAPH, run_id, {"title": "EG"}, "2.0.0", version=1)
    bp_ref = bp_art.to_ref()
    eg_ref = eg_art.to_ref()
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": bp_art, "evaluations": [], "operationId": "op_bp"})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": eg_art, "evaluations": [], "operationId": "op_eg"})())

    p_env = ArtifactEnvelope.create(
        "art_passage_s1",
        ArtifactType.PASSAGE,
        run_id,
        {"text": "Sample passage content. " * 50, "wordCount": 800},
        "2.0.0",
        version=1,
        parent_refs=[bp_ref, eg_ref],
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    # Corrupt the accepted hash in the durable store state
    state = store._state()
    head_dict = state["heads"]["art_passage_s1"]
    head_dict["contentHash"] = "0" * 64
    head_dict.pop("content_hash", None)
    store._save(state)

    generator = PassageGenerator(gateway=None)
    passage_loop = PassageLoop(generator=generator, persistence_client=store)
    p_ctx = PassageGenerationContext(
        topic="Corrupted Hash Test",
        section_index=1,
        source_text="Sample passage content source facts text for testing. " * 5,
        blueprint_ref=bp_ref,
        evidence_graph_ref=eg_ref,
    )

    with pytest.raises(ValueError, match="Corrupt checkpoint for art_passage_s1"):
        await passage_loop.run(passage_context=p_ctx, run_id=run_id, lease_owner=owner, epoch=1)


# ── Scenario 3: Missing checkpoint never creates fabricated accepted content ─

@pytest.mark.asyncio
async def test_regression_03_missing_checkpoint_fails_closed(tmp_path: Path):
    """3. Missing checkpoint envelopeJson fails closed without fabricating content."""
    owner = uuid4()
    run_id = f"run_reg03_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "reg03.db", owner=owner, epoch=1)

    bp_art = ArtifactEnvelope.create("art_bp", ArtifactType.EXAM_BLUEPRINT, run_id, {"title": "BP"}, "2.0.0", version=1)
    eg_art = ArtifactEnvelope.create("art_eg", ArtifactType.EVIDENCE_GRAPH, run_id, {"title": "EG"}, "2.0.0", version=1)
    bp_ref = bp_art.to_ref()
    eg_ref = eg_art.to_ref()
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": bp_art, "evaluations": [], "operationId": "op_bp"})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": eg_art, "evaluations": [], "operationId": "op_eg"})())

    p_env = ArtifactEnvelope.create(
        "art_passage_s1",
        ArtifactType.PASSAGE,
        run_id,
        {"text": "Sample passage text. " * 50, "wordCount": 800},
        "2.0.0",
        version=1,
        parent_refs=[bp_ref, eg_ref],
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner, "artifact": p_env, "evaluations": [], "operationId": "op_p"})())

    # Strip envelopeJson to simulate corrupt / legacy headless entry
    orig_resume = store.resume_state
    def resume_without_envelope(r_id: str):
        st = orig_resume(r_id)
        for a in st.artifacts:
            if a.artifactId == "art_passage_s1":
                object.__setattr__(a, "envelopeJson", None)
        return st
    store.resume_state = resume_without_envelope

    generator = PassageGenerator(gateway=None)
    passage_loop = PassageLoop(generator=generator, persistence_client=store)
    p_ctx = PassageGenerationContext(
        topic="Missing Checkpoint Test",
        section_index=1,
        source_text="Sample passage text source facts text for testing. " * 5,
        blueprint_ref=bp_ref,
        evidence_graph_ref=eg_ref,
    )

    with pytest.raises(ValueError, match="Corrupt checkpoint for art_passage_s1: missing envelopeJson"):
        await passage_loop.run(passage_context=p_ctx, run_id=run_id, lease_owner=owner, epoch=1)


# ── Scenario 4: Invalid MCQ answer/evidence is rejected ───────────────────────

def test_regression_04_invalid_mcq_answer_evidence_rejected():
    """4. Invalid MCQ answer key and unsupported evidence are rejected."""
    passage_text = (
        "The Amazon rainforest is the largest tropical rainforest in the world. "
        "It covers more than five and a half million square kilometers. "
        "Deforestation rates increased due to agricultural expansion and road construction."
    )
    p_ref = ArtifactRef(artifactId="art_p", version=1, artifactType=ArtifactType.PASSAGE, contentHash="a" * 64)
    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="b" * 64)

    generator = QuestionCandidateGenerator(gateway=None)

    # A. Missing answer key: must NOT default to 'A', must be marked rejected
    raw_missing_ans = [{
        "prompt": "What is the primary driver of deforestation?",
        "options": [
            {"key": "A", "text": "Agricultural expansion"},
            {"key": "B", "text": "Urban migration"},
            {"key": "C", "text": "Glacial erosion"},
            {"key": "D", "text": "Ocean currents"},
        ],
        "evidenceQuote": "Deforestation rates increased due to agricultural expansion and road construction.",
    }]
    pool_missing = generator.build_pool_from_raw_candidates(
        raw_candidates=raw_missing_ans,
        passage_text=passage_text,
        question_type="MultipleChoiceSingle",
        question_number=1,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        pool_limit=1,
        slot_id="slot_q1",
    )
    cand_missing = pool_missing.candidates[0]
    assert not cand_missing.is_eligible()
    assert any("Missing answer key" in r or "placeholder" in r for r in cand_missing.rejection_reasons)

    # B. Unsupported evidence quote: quote not in passage must be rejected
    raw_unsupported_ev = [{
        "prompt": "What is the primary driver of deforestation?",
        "answer": "A",
        "options": [
            {"key": "A", "text": "Agricultural expansion"},
            {"key": "B", "text": "Urban migration"},
            {"key": "C", "text": "Glacial erosion"},
            {"key": "D", "text": "Ocean currents"},
        ],
        "evidenceQuote": "This fabricated sentence is completely absent from the actual passage text.",
    }]
    pool_unsupported = generator.build_pool_from_raw_candidates(
        raw_candidates=raw_unsupported_ev,
        passage_text=passage_text,
        question_type="MultipleChoiceSingle",
        question_number=1,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        pool_limit=1,
        slot_id="slot_q1",
    )
    cand_unsupported = pool_unsupported.candidates[0]
    assert not cand_unsupported.is_eligible()
    assert any("unsupported by passage" in r for r in cand_unsupported.rejection_reasons)

    # C. Preserve valid MCQ options without manufacturing distractors
    raw_valid = [{
        "prompt": "What is the primary driver of deforestation?",
        "answer": "B",
        "options": [
            {"key": "A", "text": "Glacial erosion"},
            {"key": "B", "text": "Agricultural expansion"},
            {"key": "C", "text": "Urban migration"},
            {"key": "D", "text": "Ocean currents"},
        ],
        "evidenceQuote": "Deforestation rates increased due to agricultural expansion and road construction.",
    }]
    pool_valid = generator.build_pool_from_raw_candidates(
        raw_candidates=raw_valid,
        passage_text=passage_text,
        question_type="MultipleChoiceSingle",
        question_number=1,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        pool_limit=1,
        slot_id="slot_q1",
    )
    cand_valid = pool_valid.candidates[0]
    assert cand_valid.is_eligible()
    assert cand_valid.answer == "B"
    assert len(cand_valid.options) == 4
    # Option mapping preserved exactly without fake distractors
    assert [o.text for o in cand_valid.options] == [
        "Glacial erosion", "Agricultural expansion", "Urban migration", "Ocean currents"
    ]


# ── Scenario 5: Missing semantic/blind evaluation blocks acceptance ──────────

@pytest.mark.asyncio
async def test_regression_05_missing_evaluation_blocks_acceptance(tmp_path: Path):
    """5. Missing required evaluation blocks acceptance fail-closed."""
    owner = uuid4()
    run_id = f"run_reg05_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "reg05.db", owner=owner, epoch=1)

    ctx = LoopContext(
        runId=run_id,
        targetArtifactId="art_q_1",
        targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )
    policy = LoopPolicy.from_settings().model_copy(update={
        "required_evaluator_ids": ("eval_question_structure", "eval_blind_solver_adversary"),
    })

    class SimpleQuestionGenerator(GeneratorCapability):
        @property
        def name(self) -> str: return "Gen"
        @property
        def version(self) -> str: return "1.0.0"
        async def generate(self, c: LoopContext, intent_id: str, ver: int) -> ArtifactEnvelope:
            return ArtifactEnvelope.create("art_q_1", ArtifactType.QUESTION, c.run_id, {"q": 1}, "1.0.0", version=ver)

    class OnlyStructureEvaluator(EvaluatorCapability):
        evaluator_id = "eval_question_structure"
        evaluator_version = "1.0.0"
        async def evaluate(self, c: LoopContext, art: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
            return EvaluationResult.create_pass(
                evaluation_id=f"ev_{uuid4().hex[:8]}",
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=art.to_ref(),
            )

    runtime = BoundedLoopRuntime(
        context=ctx,
        policy=policy,
        generator=SimpleQuestionGenerator(),
        evaluators=[OnlyStructureEvaluator()],
        persistence_client=store,
    )

    res = await runtime.run()
    assert res.decision == DecisionType.FAIL
    assert res.terminal_state == LoopState.FAILED
    assert res.terminal_reason_code == LoopReason.MISSING_EVALUATOR


# ── Scenario 6: Provider timeout and UNKNOWN_OUTCOME never trigger replay ─────

@pytest.mark.asyncio
async def test_regression_06_unknown_outcome_never_unsafe_replay(tmp_path: Path):
    """6. Operations with UNKNOWN_OUTCOME status are never replayed."""
    owner = uuid4()
    run_id = f"run_reg06_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "reg06.db", owner=owner, epoch=1)

    ctx = LoopContext(
        runId=run_id,
        targetArtifactId="art_test_06",
        targetArtifactType=ArtifactType.PASSAGE,
        scope=IssueScope.PASSAGE,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )
    policy = LoopPolicy.from_settings()

    provider_call_count = 0

    class TrackingGenerator(GeneratorCapability):
        @property
        def name(self) -> str: return "TrackGen"
        @property
        def version(self) -> str: return "1.0.0"
        async def generate(self, c: LoopContext, intent_id: str, ver: int) -> ArtifactEnvelope:
            nonlocal provider_call_count
            provider_call_count += 1
            return ArtifactEnvelope.create("art_test_06", ArtifactType.PASSAGE, c.run_id, {"text": "hello"}, "1.0.0", version=ver)

    rt_probe = BoundedLoopRuntime(context=ctx, policy=policy, generator=TrackingGenerator(), evaluators=[], persistence_client=store)
    intent = rt_probe._intent("GENERATE", 1, 1000, "1.0.0", {"parents": [], "previous": None, "issues": [], "policy": ctx.policy_version})

    # Save a valid durable cursor matching this run state
    cursor_payload = {
        "runId": run_id,
        "targetArtifactId": "art_test_06",
        "scope": IssueScope.PASSAGE.value,
        "policyVersion": ctx.policy_version,
        "policy": policy.model_dump(mode="json", by_alias=True),
        "inputDependencies": [],
        "cursor": ResumeCursor(currentState=LoopState.DRAFTING, stepIndex=1, revision=1).model_dump(mode="json", by_alias=True),
        "budget": BudgetTracker().model_dump(mode="json", by_alias=True),
        "ledger": {"ledgerId": f"led_{run_id}", "runId": run_id, "issues": []},
        "stagnation": StagnationDetector().model_dump(mode="json", by_alias=True),
        "oscillation": OscillationDetector().model_dump(mode="json", by_alias=True),
        "repairsSinceGeneration": 0,
        "generatedVersions": 0,
        "expectedHeadVersion": None,
        "evaluations": [],
        "decision": None,
        "journal": [],
        "currentRef": None,
    }
    store.save_loop_cursor(LoopCursorCheckpointRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=owner,
        artifactId="art_test_06",
        expectedRevision=0,
        stateJson=json.dumps(cursor_payload, sort_keys=True, separators=(",", ":")),
        lastOperationId=None,
    ))

    # Pre-record the intent operation as UNKNOWN_OUTCOME in store
    state = store._state()
    state["ops"][intent.operation_id] = {
        "operationId": intent.operation_id,
        "operationType": "GENERATE",
        "status": "UNKNOWN_OUTCOME",
        "artifactId": "art_test_06",
        "requestHash": intent.request_hash,
        "tokenReservation": 1000,
        "tokensUsed": 1000,
        "wallTimeReservationSeconds": 60.0,
        "wallTimeUsedSeconds": 60.0,
        "resultRefJson": None,
        "_runId": run_id,
    }
    store._save(state)

    runtime = BoundedLoopRuntime(
        context=ctx,
        policy=policy,
        generator=TrackingGenerator(),
        evaluators=[],
        persistence_client=store,
    )

    res = await runtime.run()
    assert res.decision == DecisionType.FAIL
    assert res.terminal_state == LoopState.FAILED
    assert res.terminal_reason_code == LoopReason.UNKNOWN_OUTCOME
    # Crucial: Provider was NEVER invoked
    assert provider_call_count == 0


# ── Scenario 7: Fencing/CAS conflict prevents stale commits ───────────────────

@pytest.mark.asyncio
async def test_regression_07_fencing_cas_conflict_prevents_stale_commit(tmp_path: Path):
    """7. Fencing/CAS conflict rejects stale commits fail-closed."""
    owner = uuid4()
    run_id = f"run_reg07_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "reg07.db", owner=owner, epoch=1)

    ctx = LoopContext(
        runId=run_id,
        targetArtifactId="art_test_07",
        targetArtifactType=ArtifactType.PASSAGE,
        scope=IssueScope.PASSAGE,
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )
    policy = LoopPolicy.from_settings()

    class DummyGenerator(GeneratorCapability):
        @property
        def name(self) -> str: return "Dummy"
        @property
        def version(self) -> str: return "1.0.0"
        async def generate(self, c: LoopContext, intent_id: str, ver: int) -> ArtifactEnvelope:
            return ArtifactEnvelope.create("art_test_07", ArtifactType.PASSAGE, c.run_id, {"text": "dummy"}, "1.0.0", version=ver)

    class FencingEvaluator(EvaluatorCapability):
        evaluator_id = "eval_dummy"
        evaluator_version = "1.0.0"
        async def evaluate(self, c: LoopContext, art: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
            # Stale writer scenario: server epoch advances while writer was evaluating
            store.epoch += 1
            return EvaluationResult.create_pass(
                evaluation_id=f"ev_{uuid4().hex[:8]}",
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=art.to_ref(),
            )

    runtime = BoundedLoopRuntime(
        context=ctx,
        policy=policy,
        generator=DummyGenerator(),
        evaluators=[FencingEvaluator()],
        persistence_client=store,
    )

    res = await runtime.run()
    assert res.decision == DecisionType.FAIL
    assert res.terminal_state == LoopState.ABORTED
    assert res.terminal_reason_code == LoopReason.LEASE_LOST


# ── Scenario 8: Legacy and unified contracts remain compatible ────────────────

def test_regression_08_legacy_and_unified_contracts_remain_compatible():
    """8. PinnedExecutionPolicy adapts to LoopPolicy respecting all finite limits."""
    unified_policy = PinnedExecutionPolicy(provider="minimax")

    # Section conversion
    sec_loop_policy = unified_policy.to_loop_policy(scope="SECTION")
    assert not sec_loop_policy.is_unlimited
    assert sec_loop_policy.max_wall_time_seconds <= MAX_SECTION_WALL_SECONDS
    assert sec_loop_policy.max_total_tokens <= MAX_SECTION_TOKEN_CAP
    assert sec_loop_policy.operation_wall_reservation_seconds <= MAX_PROVIDER_CALL_SECONDS
    assert sec_loop_policy.cap_profile_sha256 == unified_policy.hash
    assert sec_loop_policy.cap_profile_version == "pinned-execution-v2"
    # Cap bounds validation passes
    sec_loop_policy.validate_cap_bounds()

    # Paper conversion
    paper_loop_policy = unified_policy.to_loop_policy(scope="PAPER")
    assert not paper_loop_policy.is_unlimited
    assert paper_loop_policy.max_wall_time_seconds <= MAX_SECTION_WALL_SECONDS * 3
    assert paper_loop_policy.max_total_tokens <= MAX_SECTION_TOKEN_CAP * 3
    assert paper_loop_policy.cap_profile_sha256 == unified_policy.hash
    paper_loop_policy.validate_cap_bounds()
