"""R03 — Settings caps reach the runtime; restart stays pinned; snapshotless runs fail closed.

Behavioral contract (Phase 06 caps hotfix):

* The active Settings profile is the only source of runtime caps. The removed
  `max_total_tokens=100000, max_wall_time_seconds=600.0` fallback in
  `QuestionCandidateLoop` widened the approved production budget
  (15 calls / 60000 tokens / 300 s) and must not return.
* `BoundedLoopRuntime` validates the run's authoritative budget profile on every
  restore, including the very first loop. A deployment change never re-profiles
  an in-flight run: the original run snapshot, the saved cursor policy and the
  persisted counters survive.
* A run whose persisted budget profile is missing or corrupt fails closed before
  any provider dispatch.

The durable store is `tests.test_t06_loop_runtime.DurableStore`, seeded with
`simulated_run_profile(...)` — the row exam-service writes when it creates a run,
before any loop cursor exists. Every profile used here sits at or below the
approved caps, so a pass can never mean "caps were relaxed".

No provider, network or live-campaign traffic; no shared service is restarted.
"""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path
from typing import List
from uuid import uuid4

import pytest

from app.config import cap_snapshot_json, cap_snapshot_sha256
from app.contracts.evaluation import EvaluationStatus
from app.contracts.loop import DecisionType, LoopReason, LoopState
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from tests.test_t06_loop_runtime import (
    DurableStore,
    Evaluator,
    Generator,
    Repairer,
    context,
    simulated_run_profile,
)

# Approved production run caps (deploy/envs/loop-caps.env). Never exceeded here.
APPROVED_CALL_CAP = 15
APPROVED_TOKEN_CAP = 60_000
APPROVED_WALL_CAP = 300

# The widened fallback that must not survive in QuestionCandidateLoop.
FORBIDDEN_TOKEN_CAP = 100_000
FORBIDDEN_WALL_CAP = 1800.0

QUESTION_EVALUATORS = ("eval_question_structure", "eval_answer_verbatim_length")


def _digest(snapshot: dict) -> str:
    """Canonical profile digest, identical to production and to .NET's serializer."""
    return cap_snapshot_sha256(snapshot)


def _store(tmp_path: Path, owner, name: str) -> DurableStore:
    return DurableStore(tmp_path / name, owner, run_profile=simulated_run_profile(
        LoopPolicy(required_evaluator_ids=("required",))))


# ─────────────────── Settings → policy → runtime receipt ───────────────────


@pytest.mark.asyncio
async def test_r03_configured_token_cap_bounds_admission(tmp_path):
    """A configured token cap is enforced at admission, reaching a terminal TOKEN_CAP.

    Behavioral receipt: the cap Settings/policy carry is the cap the runtime actually
    admits against, proven by a real terminal code. The widened 100000/600 fallback
    would have admitted the whole cycle instead of stopping at the configured cap.
    """
    from app.config import settings

    budget = 3_000
    policy = LoopPolicy.from_settings(
        max_total_tokens=budget,
        generate_token_reservation=1_000,
        evaluate_token_reservation=1_000,
        repair_token_reservation=1_000,
        required_evaluator_ids=("required",),
    )
    assert policy.max_total_tokens == budget
    policy.validate_cap_bounds()
    # The forbidden fallback would sit far above this configured budget.
    assert policy.max_total_tokens < FORBIDDEN_TOKEN_CAP
    assert policy.max_wall_time_seconds < FORBIDDEN_WALL_CAP

    owner = uuid4()
    store = DurableStore(tmp_path / "r03_token_admission.db", owner,
                         run_profile=simulated_run_profile(policy))
    runtime = BoundedLoopRuntime(
        context(owner), policy, Generator(), [Evaluator([EvaluationStatus.FAIL] * 20)],
        repairer=Repairer(["A", "B", "C", "D", "E"]), persistence_client=store,
    )
    result = await runtime.run()

    assert result.terminal_reason_code == LoopReason.TOKEN_CAP
    assert result.terminal_state == LoopState.FAILED
    assert result.tokens_consumed <= budget
    assert runtime.policy.max_total_tokens == budget
    # Production caps remain the deployment default this test did not touch.
    assert settings.loop_max_total_tokens == APPROVED_TOKEN_CAP
    assert settings.loop_max_wall_time_seconds == APPROVED_WALL_CAP


@pytest.mark.asyncio
async def test_r03_question_loop_default_policy_bounds_admission(tmp_path):
    """The QuestionCandidateLoop default policy bounds a real runtime's admission.

    `policy=None` composes a policy that a runtime then admits against; the removed
    100000/600 fallback would have admitted ~3x the approved budget.
    """
    from app.config import settings
    from app.loop.question import QuestionCandidateLoop

    class StubGenerator:
        name = "stub"
        version = "fake-v1"

    owner = uuid4()
    question_loop = QuestionCandidateLoop(
        generator=StubGenerator(),
        persistence_client=_store(tmp_path, owner, "r03_question.db"),
        policy=None,
    )
    default_policy = question_loop.policy
    assert default_policy.max_total_tokens != FORBIDDEN_TOKEN_CAP
    assert default_policy.max_wall_time_seconds != FORBIDDEN_WALL_CAP
    assert default_policy.max_total_tokens == settings.loop_max_total_tokens

    store = DurableStore(tmp_path / "r03_question_admit.db", owner,
                         run_profile=simulated_run_profile(default_policy))
    runtime = BoundedLoopRuntime(
        context(owner), default_policy, Generator(),
        [Evaluator([EvaluationStatus.FAIL] * 20)], repairer=Repairer(["A", "B", "C", "D", "E"]),
        persistence_client=store,
    )
    result = await runtime.run()
    assert result.decision == DecisionType.FAIL
    assert result.tokens_consumed <= default_policy.max_total_tokens
    assert runtime.policy.max_total_tokens == settings.loop_max_total_tokens


@pytest.mark.asyncio
async def test_r03_explicit_policy_override_bounds_admission(tmp_path):
    """A caller-supplied policy is what the runtime admits against, terminal code included."""
    from app.loop.question import QuestionCandidateLoop

    class StubGenerator:
        name = "stub"
        version = "fake-v1"

    owner = uuid4()
    explicit = LoopPolicy.from_settings(
        max_total_tokens=2_000, max_total_calls=APPROVED_CALL_CAP, max_wall_time_seconds=120,
        generate_token_reservation=1_000, evaluate_token_reservation=1_000,
        repair_token_reservation=1_000, operation_wall_reservation_seconds=10,
        required_evaluator_ids=("required",),
    )
    question_loop = QuestionCandidateLoop(
        generator=StubGenerator(),
        persistence_client=_store(tmp_path, owner, "r03_override.db"),
        policy=explicit,
    )
    assert question_loop.policy.max_total_tokens == 2_000

    store = DurableStore(tmp_path / "r03_override_admit.db", owner,
                         run_profile=simulated_run_profile(explicit))
    runtime = BoundedLoopRuntime(
        context(owner), question_loop.policy, Generator(),
        [Evaluator([EvaluationStatus.FAIL] * 20)], repairer=Repairer(["A", "B", "C", "D", "E"]),
        persistence_client=store,
    )
    result = await runtime.run()
    # The tighter caller cap terminates the run; the wider deployment cap would not.
    assert result.terminal_reason_code == LoopReason.TOKEN_CAP
    assert result.tokens_consumed <= 2_000
    assert runtime.policy.max_total_tokens == 2_000


def test_r03_passage_loop_uses_passage_generate_reservation(tmp_path):
    """PassageLoop selects the passage reservation cap from the pinned profile."""
    from app.config import settings
    from app.loop.passage import PassageLoop

    policy = LoopPolicy.from_cap_snapshot(
        settings.loop_caps_snapshot(),
        generate_reservation_cap="passageGenerateTokenReservation",
    )
    expected = settings.loop_caps_snapshot()["caps"]["passageGenerateTokenReservation"]
    assert policy.generate_token_reservation == expected
    assert policy.generate_token_reservation != settings.loop_caps_snapshot()["caps"]["generateTokenReservation"]
    policy.validate_cap_bounds()


# ─────────────── restart is pinned to the run's original profile ───────────


@pytest.mark.asyncio
async def test_r03_restart_reuses_original_caps_and_counters(tmp_path):
    """A wider deployment policy must not re-profile an in-flight run."""
    from app.config import settings

    pinned_snapshot = settings.loop_caps_snapshot()
    # The run is pinned to a SMALLER cap than the deployment, so a redeploy widening
    # the deployment profile must not lift this run's own limits.
    pinned_policy = LoopPolicy.from_settings(
        max_total_calls=APPROVED_CALL_CAP - 1,
        max_total_tokens=APPROVED_TOKEN_CAP - 1_000,
        max_wall_time_seconds=APPROVED_WALL_CAP - 1,
        required_evaluator_ids=("required",),
    )
    pinned_policy.validate_cap_bounds()
    run_profile = simulated_run_profile(pinned_policy)
    run_sha = _digest(run_profile)

    owner = uuid4()
    store = _store(tmp_path, owner, "r03_restart.db")
    store.run_profile = simulated_run_profile(pinned_policy)

    first = BoundedLoopRuntime(
        context(owner), pinned_policy, Generator(), [Evaluator()], persistence_client=store,
    )
    assert (await first.run()).decision == DecisionType.PASS
    counters = first.context.budget_tracker.model_dump(mode="json", by_alias=True)
    assert counters["tokensUsed"] > 0 and counters["callsUsed"] > 0

    # The run's authoritative profile is what a restart reads back.
    resume = store.resume_state("run_t06")
    assert resume.budgetProfileSha256 == run_sha
    assert resume.budgetProfileVersion == run_profile["profileVersion"]
    assert resume.budgetProfileSource == run_profile["profileSource"]
    assert json.loads(resume.budgetProfileJson) == run_profile
    # The first loop re-based onto exactly that run authority.
    assert first.policy.cap_profile_sha256 == run_sha
    assert first.policy.cap_profile_snapshot == run_profile

    # Restart with a genuinely DIFFERENT, wider profile, as a redeploy would supply.
    # Every cap changes, so the assertion below cannot pass on identity alone. The
    # redeployed profile still stays at or below the approved production caps.
    wider_calls = APPROVED_CALL_CAP
    wider_tokens = APPROVED_TOKEN_CAP
    wider_wall = APPROVED_WALL_CAP
    assert wider_calls > run_profile["caps"]["loopMaxTotalCalls"]
    assert wider_tokens > run_profile["caps"]["loopMaxTotalTokens"]
    assert wider_wall > run_profile["caps"]["loopMaxWallTimeSeconds"]
    redeployed_snapshot = json.loads(json.dumps(run_profile))
    redeployed_snapshot["profileVersion"] = "r03-redeploy"
    redeployed_snapshot["caps"] = {
        **run_profile["caps"],
        "loopMaxTotalCalls": wider_calls,
        "loopMaxTotalTokens": wider_tokens,
        "loopMaxWallTimeSeconds": wider_wall,
    }
    redeployed_policy = LoopPolicy.from_cap_snapshot(
        redeployed_snapshot, required_evaluator_ids=("required",))
    assert redeployed_policy.cap_profile_sha256 != run_sha
    assert redeployed_policy.max_total_calls == wider_calls

    reopened = DurableStore(tmp_path / "r03_restart.db", owner, run_profile=run_profile)
    second = BoundedLoopRuntime(
        context(owner), redeployed_policy, Generator(), [Evaluator()], persistence_client=reopened,
    )
    assert (await second.run()).decision == DecisionType.PASS

    # The run keeps its ORIGINAL profile, not the redeployed one.
    assert second.policy.cap_profile_sha256 == run_sha
    assert second.policy.cap_profile_snapshot == run_profile
    assert second.policy.max_total_tokens == run_profile["caps"]["loopMaxTotalTokens"]
    assert second.policy.max_wall_time_seconds == run_profile["caps"]["loopMaxWallTimeSeconds"]
    assert second.policy.max_total_calls == run_profile["caps"]["loopMaxTotalCalls"]
    assert second.controller.policy is second.policy

    after = second.context.budget_tracker.model_dump(mode="json", by_alias=True)
    assert after["tokensUsed"] >= counters["tokensUsed"]
    assert after["callsUsed"] >= counters["callsUsed"]
    assert after["wallTimeUsedSeconds"] >= counters["wallTimeUsedSeconds"]


@pytest.mark.asyncio
async def test_r03_first_loop_of_new_target_stays_on_run_profile(tmp_path):
    """A new target's first loop under a redeployed profile still uses the run's profile.

    The T06 store pins a single cursor per file, so the second target runs against
    its own store seeded with the SAME run profile; the point under test is that a
    first loop re-bases to the run's authority rather than the caller's policy.
    """
    from app.config import settings

    pinned = LoopPolicy.from_settings(
        max_total_tokens=APPROVED_TOKEN_CAP - 1_000,
        required_evaluator_ids=("required",),
    )
    pinned.validate_cap_bounds()
    run_profile = simulated_run_profile(pinned)
    run_sha = _digest(run_profile)
    owner = uuid4()

    store = _store(tmp_path, owner, "r03_target_a.db")
    store.run_profile = run_profile
    first = BoundedLoopRuntime(
        context(owner, target="passage_1"), pinned, Generator(), [Evaluator()],
        persistence_client=store,
    )
    assert (await first.run()).decision == DecisionType.PASS
    assert first.policy.cap_profile_sha256 == run_sha

    # A redeployment offers a genuinely different profile for the same run.
    wider_tokens = APPROVED_TOKEN_CAP
    assert wider_tokens > run_profile["caps"]["loopMaxTotalTokens"]
    redeployed_snapshot = json.loads(json.dumps(run_profile))
    redeployed_snapshot["profileVersion"] = "r03-redeploy-target"
    redeployed_snapshot["caps"] = {
        **run_profile["caps"],
        "loopMaxTotalTokens": wider_tokens,
    }
    redeployed = LoopPolicy.from_cap_snapshot(
        redeployed_snapshot, required_evaluator_ids=("required",))
    assert redeployed.cap_profile_sha256 != run_sha
    assert redeployed.max_total_tokens == wider_tokens

    store_b = _store(tmp_path, owner, "r03_target_b.db")
    store_b.run_profile = run_profile
    second = BoundedLoopRuntime(
        context(owner, target="passage_2"), redeployed, Generator(), [Evaluator()],
        persistence_client=store_b,
    )
    assert (await second.run()).decision == DecisionType.PASS

    # First loop re-bases to the run's profile, not the redeployed one.
    assert second.policy.cap_profile_sha256 == run_sha
    assert second.policy.max_total_tokens == run_profile["caps"]["loopMaxTotalTokens"]
    assert store_b.resume_state("run_t06").budgetProfileSha256 == run_sha


@pytest.mark.asyncio
async def test_r03_call_cap_admission_uses_run_profile(tmp_path):
    """A wider deployment policy cannot lift a run's pinned call cap at admission."""
    from app.config import settings

    # A run pinned to ONE call: the deployed policy would allow far more.
    pinned = LoopPolicy.from_cap_snapshot(
        {**settings.loop_caps_snapshot(), "profileVersion": "r03-call-cap"},
        max_total_calls=1, required_evaluator_ids=("required",),
    )
    assert pinned.max_total_calls == 1
    assert settings.loop_max_total_calls > 1, "deployment must be wider for this to bite"

    owner = uuid4()
    run_profile = simulated_run_profile(pinned)
    store = DurableStore(tmp_path / "r03_admission.db", owner, run_profile=run_profile)
    generator = Generator()
    runtime = BoundedLoopRuntime(
        context(owner), pinned, generator, [Evaluator()], persistence_client=store,
    )
    result = await runtime.run()

    # Admission stopped at the run's own cap, and the policy re-based onto it.
    assert runtime.policy.max_total_calls == 1
    assert result.terminal_reason_code == LoopReason.CALL_CAP
    assert result.calls_count == 1
    assert generator.calls == 1


@pytest.mark.asyncio
async def test_r03_facade_receipt_reaches_runtime_admission(tmp_path):
    """End-to-end receipt: facade → QuestionCandidateLoop → the loop's real inner runtimes.

    Runs `GenerationFacade.generate_questions_v2` and captures the policies the loop
    actually passes into its per-slot and per-candidate BoundedLoopRuntimes. Those
    policies must be the live Settings profile, bounded by the run's pinned profile —
    not a widened 100000/600 fallback.
    """
    from app.config import settings
    from app.contracts.artifact import ArtifactEnvelope, ArtifactType
    from app.facade import GenerationFacade
    from app.generators.question.context import QuestionCandidate, QuestionCandidatePool
    from app.generators.question.generator import QuestionCandidateGenerator
    from app.selection.selector import SelectionInfeasibleError

    owner = uuid4()
    run_id = "run_t06"  # the shared simulation store's single run row
    pinned = LoopPolicy.from_settings(required_evaluator_ids=("required",))
    store = DurableStore(tmp_path / "r03_facade.db", owner,
                         run_profile=simulated_run_profile(pinned))
    # The question loop writes its own committed heads into this shared row; start clean.
    with sqlite3.connect(store.path) as db:
        db.execute("UPDATE state SET value=? WHERE id=1", (json.dumps({
            "ops": {}, "drafts": {}, "heads": {}, "cursor": None,
            "evaluations": {}, "descendants": {},
        }),))

    # Deterministic local candidates: no provider, no network, no paid campaign.
    class LocalCandidateGenerator(QuestionCandidateGenerator):
        def __init__(self, gateway):
            super().__init__(gateway=gateway)

        async def generate_candidate_pool(self, **kwargs):
            question_number = kwargs.get("question_number", 1)
            pool = QuestionCandidatePool(
                slotId=f"slot_q{question_number}",
                questionNumber=question_number,
                questionType=kwargs.get("question_type", "TrueFalseNotGiven"),
                poolLimit=1,
            )
            pool.add_candidate(QuestionCandidate(
                candidateId=f"cand_{question_number}_{uuid4().hex[:6]}",
                slotId=f"slot_q{question_number}",
                passageRef=kwargs["passage_ref"],
                blueprintRef=kwargs["blueprint_ref"],
                questionNumber=question_number,
                questionType=kwargs.get("question_type", "TrueFalseNotGiven"),
                prompt=f"Statement {question_number} ______.",
                answer="TRUE",
                evidenceQuote="Archaeological excavations documented ancient architecture.",
            ))
            return pool

    passage = ArtifactEnvelope.create(
        artifact_id=f"art_passage_{uuid4().hex[:6]}", artifact_type=ArtifactType.PASSAGE,
        version=1, run_id=run_id, producer_version="2.0.0",
        payload={"text": "Archaeological excavations documented ancient architecture. "
                         "Further studies confirmed pottery."},
    )
    blueprint = ArtifactEnvelope.create(
        artifact_id=f"art_bp_{uuid4().hex[:6]}", artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1, run_id=run_id, producer_version="2.0.0", payload={"title": "Blueprint"},
    )
    store.run_profile = simulated_run_profile(pinned)

    facade = GenerationFacade(persistence_client=store)
    observed: List[BoundedLoopRuntime] = []
    original = BoundedLoopRuntime.__init__

    def spy(self, *args, **kwargs):
        original(self, *args, **kwargs)
        observed.append(self)

    BoundedLoopRuntime.__init__ = spy  # type: ignore[method-assign]
    try:
        from app.loop.question import QuestionCandidateLoop
        question_loop = QuestionCandidateLoop(
            generator=LocalCandidateGenerator(facade.gateway),
            persistence_client=facade.get_persistence_client(),
            policy=None,
        )
        try:
            await question_loop.run(
                passage_artifact=passage,
                blueprint_ref=blueprint.to_ref(),
                question_slots=[{"number": 1, "type": "TrueFakeNotGiven"}],
                run_id=run_id, lease_owner=owner, epoch=1,
            )
        except Exception:
            pass  # only the inner runtimes' admission profile is under test
    finally:
        BoundedLoopRuntime.__init__ = original  # type: ignore[method-assign]

    # The loop really built runtimes, and every one of them carried the Settings
    # profile bounded by the run's pinned caps — never the widened fallback.
    assert observed, "the question loop never constructed a BoundedLoopRuntime"
    # After each inner runtime restored, its policy is the run's pinned authority.
    run_sha = _digest(simulated_run_profile(pinned))
    for runtime in observed:
        policy = runtime.policy
        assert policy.max_total_tokens != FORBIDDEN_TOKEN_CAP
        assert policy.max_wall_time_seconds != FORBIDDEN_WALL_CAP
        assert policy.max_total_tokens <= APPROVED_TOKEN_CAP
        assert policy.max_wall_time_seconds <= APPROVED_WALL_CAP
        assert policy.cap_profile_sha256 == run_sha, (
            "an inner runtime did not re-base onto the run's pinned cap profile"
        )
        policy.validate_cap_bounds()


@pytest.mark.asyncio
@pytest.mark.parametrize("source", ["deploy/envs/loop-caps.env", "deploy/envs/địa-phương.env"])
async def test_r03_profile_digest_is_source_encoding_independent(tmp_path, source):
    """The pinned digest must survive a non-ASCII profileSource, as .NET requires.

    .NET writes the snapshot with an unescaped UTF-8 serializer, so a non-ASCII
    `profileSource` must round-trip to the same digest Python computes.
    """
    owner = uuid4()
    requested = LoopPolicy.from_cap_snapshot(
        {
            "caps": {
                "loopMaxVersions": 3, "loopMaxGeneratedVersions": 3,
                "loopMaxRepairAttemptsPerVersion": 2, "loopMaxTotalRepairs": 5,
                "loopMaxConsecutiveNoProgress": 2, "loopMaxOscillationCycles": 2,
                "loopMaxTotalCalls": APPROVED_CALL_CAP,
                "loopMaxTotalTokens": APPROVED_TOKEN_CAP,
                "loopMaxWallTimeSeconds": APPROVED_WALL_CAP,
                "generateTokenReservation": 15_000,
                "evaluateTokenReservation": 10_000,
                "repairTokenReservation": 15_000,
                "loopOperationWallReservationSeconds": 30,
                "loopMaxResponseBytes": 500_000,
            },
            "profileVersion": "r03-unicode",
            "profileSource": source,
        },
        required_evaluator_ids=("required",),
    )
    run_profile = simulated_run_profile(requested)
    run_profile["profileSource"] = source
    run_sha = cap_snapshot_sha256(run_profile)

    store = DurableStore(tmp_path / f"r03_unicode_{abs(hash(source))}.db", owner,
                         run_profile=run_profile)
    first = BoundedLoopRuntime(
        context(owner), requested, Generator(), [Evaluator()], persistence_client=store,
    )
    assert (await first.run()).decision == DecisionType.PASS

    resume = store.resume_state("run_t06")
    assert resume.budgetProfileJson == cap_snapshot_json(run_profile)
    assert resume.budgetProfileSha256 == run_sha
    assert resume.budgetProfileSource == source
    assert first.policy.cap_profile_sha256 == run_sha

    # Restart under the same run profile still validates, non-ASCII source included.
    reopened = DurableStore(store.path, owner, run_profile=run_profile)
    second = BoundedLoopRuntime(
        context(owner), LoopPolicy.from_cap_snapshot(run_profile, required_evaluator_ids=("required",)),
        Generator(), [Evaluator()], persistence_client=reopened,
    )
    await second.run()
    assert second.policy.cap_profile_sha256 == run_sha
    assert second.policy.cap_profile_source == source


# ────────────────────────── fails-closed paths ──────────────────────────


@pytest.mark.asyncio
async def test_r03_missing_run_profile_fails_closed_before_dispatch(tmp_path):
    """No persisted run profile ⇒ refuse before any capability runs."""
    from app.config import settings

    owner = uuid4()
    store = _store(tmp_path, owner, "r03_missing.db")
    store.run_profile = None  # a legacy snapshotless run
    assert store.resume_state("run_t06").budgetProfileJson is None

    generator = Generator()
    runtime = BoundedLoopRuntime(
        context(owner), LoopPolicy.from_settings(), generator, [Evaluator()],
        persistence_client=store,
    )
    with pytest.raises(ValueError, match=r"(?i)(lacks a pinned cap profile|invalid pinned cap profile)"):
        await runtime.run()
    assert generator.calls == 0, "must fail closed before dispatching a generation"
    assert store.trace == [], "a snapshotless run must not write durable state"


@pytest.mark.asyncio
async def test_r03_corrupt_run_profile_fails_closed(tmp_path):
    """A run profile whose digest does not match its JSON is refused."""
    from app.config import settings

    policy = LoopPolicy.from_settings()
    owner = uuid4()
    store = _store(tmp_path, owner, "r03_corrupt.db")
    store.run_profile = simulated_run_profile(policy)

    # Corrupt the stored JSON while keeping the recorded digest.
    class Corrupt(DurableStore):
        def resume_state(self, run_id):
            result = super().resume_state(run_id)
            payload = json.loads(result.budgetProfileJson)
            payload["caps"]["loopMaxTotalCalls"] = APPROVED_CALL_CAP + 100
            return result.model_copy(update={
                "budgetProfileJson": cap_snapshot_json(payload),
            })

    corrupt = Corrupt(tmp_path / "r03_corrupt.db", owner,
                      run_profile=simulated_run_profile(policy))
    generator = Generator()
    runtime = BoundedLoopRuntime(
        context(owner), policy, generator, [Evaluator()], persistence_client=corrupt,
    )
    with pytest.raises(ValueError, match=r"(?i)(invalid pinned cap profile|lacks a pinned cap profile)"):
        await runtime.run()
    assert generator.calls == 0


@pytest.mark.asyncio
async def test_r03_unknown_outcome_reservation_survives_restart(tmp_path):
    """A RESERVED (UNKNOWN_OUTCOME) operation keeps consuming budget after restart."""
    from app.config import settings

    policy = LoopPolicy.from_settings()
    owner = uuid4()
    store = _store(tmp_path, owner, "r03_unknown.db")
    store.run_profile = simulated_run_profile(policy)

    first = BoundedLoopRuntime(
        context(owner), policy, Generator(), [Evaluator()], persistence_client=store,
    )
    store.fault = "grant"
    with pytest.raises(OSError, match="simulated process death"):
        await first.run()

    reserved = [o for o in store._state()["ops"].values() if o["status"] == "RESERVED"]
    assert reserved, "crash must leave a RESERVED (UNKNOWN_OUTCOME) operation"
    before = store.resume_state("run_t06")
    assert before.callsUsed >= 1 and before.tokensUsed > 0

    reopened = DurableStore(tmp_path / "r03_unknown.db", owner,
                            run_profile=simulated_run_profile(policy))
    second_generator = Generator()
    second = BoundedLoopRuntime(
        context(owner), LoopPolicy.from_settings(), second_generator, [Evaluator()],
        persistence_client=reopened,
    )
    await second.run()

    after = reopened.resume_state("run_t06")
    # Uncertain usage is never refunded: counters can only grow.
    assert after.callsUsed >= before.callsUsed
    assert after.tokensUsed >= before.tokensUsed
    assert after.wallTimeUsedSeconds >= before.wallTimeUsedSeconds
    assert second.context.budget_tracker.tokens_used >= before.tokensUsed
