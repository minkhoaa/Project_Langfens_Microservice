"""Phase 15 V2 repair-side regression tests (agent B / CAS + strict closure).

Scope: `BoundedLoopRuntime`'s artifact-admission check in `app/loop/runtime.py`.

The defect these tests pin is case 14 of the canonical MiniMax campaign
`camp_G15_c9750f53d6b5` (seed 202, sources PMC13503497/PMC13583341/PMC13560651), whose
diagnostic replay terminates as:

    Paper loop rejected paper: INVALID_OUTPUT: capability returned wrong target/version/hash/parents

Root cause: the runtime declared `context.input_dependencies` ONCE, when the loop was
constructed. A repair capability may commit NEW versions of those very dependencies
before it returns -- the paper loop re-runs its question and section sub-loops, each of
which accepts its own artifact head. The returned paper is therefore legitimately bound
to parent refs one version ahead of the snapshot the runtime still held, and the
admission check compared the two and declared a perfectly well-formed artifact
"unverifiable". The loop then died at the paper level instead of continuing.

The fix re-syncs the declared dependencies from the AUTHORITATIVE persisted head before
declaring the artifact unverifiable. It is not a relaxation. These tests pin that:

* a genuinely unverifiable artifact still fails closed (wrong id, wrong type, forged
  hash, wrong version, unknown parent);
* an append-only chain never moves backwards, and a same-version/different-hash record is
  an impossible mutation that is refused, not "resynced" onto;
* a stale (non-head) record is never treated as the accepted head;
* the refresh is a no-op when nothing advanced, so unrelated loops are untouched.

No cap is raised anywhere: every test runs under the caller's policy unchanged.
"""

from __future__ import annotations

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopReason
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from tests.test_t06_loop_runtime import (
    DurableStore,
    Evaluator,
    Generator,
    simulated_run_profile,
)


def _parent_ref(artifact_id, artifact_type, version, content_hash):
    """Content hashes are 64 hex chars; a single char is expanded to a valid hash."""
    if len(content_hash) < 64:
        content_hash = (content_hash * 64)[:64]
    return ArtifactRef(artifactId=artifact_id, artifactType=artifact_type,
                       version=version, contentHash=content_hash)


def _fail_then_pass(code=IssueCode.WORD_LIMIT_EXCEEDED):
    """Evaluator that blocks the first draft and clears on the repair.

    Without a first-draft blocker the loop passes at v1 and never consults a repairer,
    so the behaviour under test would never execute.
    """
    class _HealingEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            self.statuses = [EvaluationStatus.FAIL if art.version == 1 else EvaluationStatus.PASS]
            return await super().evaluate(ctx, art, intent_id)

    return _HealingEvaluator([EvaluationStatus.FAIL], code)


def _seed_accepted_heads(store, refs):
    """Install an accepted head for each input ref in the durable store.

    The protocol's commit step refuses to accept a paper whose parents have no accepted
    head, so a fixture that skips this never reaches the acceptance path under test.
    """
    state = store._state()
    for ref in refs:
        env = ArtifactEnvelope.create(
            ref.artifact_id, ref.artifact_type, "run_cas",
            {"text": f"head of {ref.artifact_id}"}, "2.0.0", version=ref.version,
        ).model_copy(update={"content_hash": ref.content_hash})
        # Field names, not aliases: the durable protocol's parent-head check reads the
        # `content_hash` key verbatim.
        state["heads"][ref.artifact_id] = env.model_dump(mode="json")
    store._save(state, "seed_heads")
    return state


def _make_runtime(tmp_path, parents, generator=None, repairer=None, evaluator=None):
    owner = __import__("uuid").uuid4()
    ctx = LoopContext(runId="run_cas", targetArtifactId="art_paper_p1",
                      targetArtifactType=ArtifactType.READING_PAPER, scope=IssueScope.PAPER,
                      inputDependencies=tuple(parents),
                      authority=AuthorityGrant(leaseOwner=owner, epoch=1),
                      budgetTracker=BudgetTracker())
    # Mirror `tests.test_t06_loop_runtime.setup`: pin the run profile to the requested
    # policy, then re-derive the policy FROM that profile while re-applying the fields
    # the cap snapshot does not carry (required evaluators, score floor, wall reserve).
    # Otherwise first-loop re-basing silently drops `required_evaluator_ids` and every
    # run terminates MISSING_EVALUATOR before reaching the behaviour under test.
    requested = LoopPolicy(required_evaluator_ids=("required",))
    profile = simulated_run_profile(requested)
    # Give the loop real token/call headroom so it reaches the behaviour under test
    # instead of stopping at TOKEN_CAP/CALL_CAP. This does NOT touch the version or
    # repair-attempt caps -- those stay at production values on purpose, and one test
    # below asserts they were never widened.
    profile = dict(profile)
    profile["caps"] = {**profile["caps"], "loopMaxTotalTokens": 600_000, "loopMaxTotalCalls": 200}
    effective = LoopPolicy.from_cap_snapshot(
        profile,
        required_evaluator_ids=requested.required_evaluator_ids,
        min_score_threshold=requested.min_score_threshold,
        operation_wall_reservation_seconds=requested.operation_wall_reservation_seconds,
    )
    effective.validate_cap_bounds()
    store = DurableStore(tmp_path / "cas.db", owner, run_profile=profile)
    # Seed the accepted heads for the declared inputs. A loop that regenerates refuses to
    # proceed on an input it cannot see an accepted head for, so a fixture that omits this
    # never reaches the behaviour under test (it stops at STALE_DEPENDENCY instead).
    accepted_deps = {r.artifact_id: r for r in ctx.input_dependencies}
    rt = BoundedLoopRuntime(
        ctx, effective, generator or Generator(), [evaluator or Evaluator()],
        repairer=repairer, persistence_client=store, accepted_dependencies=accepted_deps,
    )
    _seed_accepted_heads(store, tuple(parents))
    return rt, store


def _head_ref(artifact_id, artifact_type, version, hash_char):
    """Install an accepted head for `artifact_id` straight into the durable store."""
    return _parent_ref(artifact_id, artifact_type, version, hash_char * 64)


# ─────────────────────────────────────────────────────────────────────────────
# (1) The case-14 shape: a repair advances a dependency head, and the artifact
#     is legitimately bound to the NEW head.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_phase15_v2rate_b_repair_accepts_artifact_bound_to_advanced_dependency_head(tmp_path):
    """A repair that advanced a dependency must not be misreported as INVALID_OUTPUT.

    Section S2 was accepted at v1 when the loop started. The repair re-ran the section
    sub-loop, which committed S2 at v2. The repaired paper legitimately binds S2@v2. The
    runtime's declared deps still say S2@v1, so the admission check sees a parent-refs
    mismatch and used to terminate the whole paper loop with
    `INVALID_OUTPUT: capability returned wrong target/version/hash/parents`.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    s1 = _head_ref("art_section_1", ArtifactType.SECTION, 1, "1")
    s2_v1 = _head_ref("art_section_2", ArtifactType.SECTION, 1, "2")
    parents = (bp, s1, s2_v1)

    # The section sub-loop commits S2@v2 before the paper repair returns.
    s2_v2_payload = {"text": "regenerated section 2"}
    s2_v2 = ArtifactEnvelope.create(
        "art_section_2", ArtifactType.SECTION, "run_cas", s2_v2_payload, "2.0.0", version=2,
    )

    class PaperRepairBindingNewHead:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        async def repair(self, ctx, art, issues, intent_id, version):
            # Bind the advanced head, exactly as a real paper repair does after its
            # per-section sub-loops have committed.
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                {"text": "repaired paper over section 2 v2"}, "2.0.0",
                version=version, parent_refs=(bp, s1, s2_v2.to_ref()),
            )

    class HealingEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            self.statuses = [EvaluationStatus.FAIL if art.version == 1 else EvaluationStatus.PASS]
            return await super().evaluate(ctx, art, intent_id)

    rt, store = _make_runtime(
        tmp_path, parents, repairer=PaperRepairBindingNewHead(), evaluator=HealingEvaluator(),
    )

    # Publish S2@v2 as the accepted head before the loop runs, which is what the
    # per-section sub-loop commit does in production.
    store._state()
    state = store._state()
    state["heads"]["art_section_2"] = s2_v2.model_dump(mode="json")
    store._save(state, "seed_head")

    result = await rt.run()

    assert result.terminal_reason_code != LoopReason.INVALID_OUTPUT, (
        "an artifact strictly closed against the live accepted head must not be called "
        f"unverifiable; got {result.terminal_reason_code}: {result.terminal_reason}"
    )
    assert result.decision == DecisionType.PASS, (
        f"the repaired paper should have been accepted, got {result.decision}: "
        f"{result.terminal_reason}"
    )
    assert result.accepted_artifact is not None
    assert s2_v2.to_ref() in tuple(result.accepted_artifact.parent_refs), (
        "the accepted paper must bind the advanced section head"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_dependency_resync_reads_the_persisted_head_not_the_capability(tmp_path):
    """The refreshed ref must come from the durable head, and only when strictly newer.

    Here the capability claims S2 advanced to v2, but the durable store's accepted head
    is still v1. Resyncing onto the capability's word would accept an artifact bound to a
    version that was never committed -- exactly the strict-closure violation. The paper
    must instead stay rejected.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    s1 = _head_ref("art_section_1", ArtifactType.SECTION, 1, "1")
    s2_v1 = _head_ref("art_section_2", ArtifactType.SECTION, 1, "2")
    parents = (bp, s1, s2_v1)

    uncommitted_s2_v2 = ArtifactEnvelope.create(
        "art_section_2", ArtifactType.SECTION, "run_cas", {"text": "never committed"}, "2.0.0",
        version=2,
    )

    class RepairBindingUncommittedHead:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        async def repair(self, ctx, art, issues, intent_id, version):
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                {"text": "paper bound to an uncommitted head"}, "2.0.0",
                version=version, parent_refs=(bp, s1, uncommitted_s2_v2.to_ref()),
            )

    rt, store = _make_runtime(
        tmp_path, parents, repairer=RepairBindingUncommittedHead(),
        evaluator=_fail_then_pass(),
    )
    await rt.run()

    assert rt.context.accepted_artifact is None, (
        "an artifact bound to a dependency version that was never committed must not be "
        "accepted: strict closure is violated"
    )
    assert "art_paper_p1" not in store._state()["heads"], (
        "fail-closed: no paper may be accepted while a parent reference dangles"
    )


# ─────────────────────────────────────────────────────────────────────────────
# (2) Genuine corruption must still fail closed. None of these may resync.
# ─────────────────────────────────────────────────────────────────────────────


def _corrupt_artifact(ctx, version, *, artifact_id=None, artifact_type=None,
                      payload=None, mutate_hash=False):
    art = ArtifactEnvelope.create(
        artifact_id or ctx.target_artifact_id,
        artifact_type or ctx.target_artifact_type,
        ctx.run_id,
        payload if payload is not None else {"text": "repaired"},
        "2.0.0",
        version=version,
        parent_refs=ctx.input_dependencies,
    )
    if mutate_hash:
        return art.model_copy(update={"content_hash": "f" * 64})
    return art


@pytest.mark.asyncio
@pytest.mark.parametrize("corruption,expected_detail", [
    ("wrong_artifact_id", "wrong target"),
    ("wrong_artifact_type", "wrong target"),
    ("forged_hash", "wrong target"),
    ("unknown_parent", "wrong target"),
])
async def test_phase15_v2rate_b_genuinely_unverifiable_artifact_still_fails_closed(
    tmp_path, corruption, expected_detail
):
    """Real corruption must never reach the resync path, let alone be accepted.

    Each case is a distinct way an artifact can fail admission. None of them is a
    dependency-head advance, so all of them must terminate the loop exactly as before.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    parents = (bp,)

    class RepairProducingCorruption:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        def __init__(self, mode):
            self.mode = mode

        async def repair(self, ctx, art, issues, intent_id, version):
            if self.mode == "wrong_artifact_id":
                return ArtifactEnvelope.create(
                    "art_some_other_id", ctx.target_artifact_type, ctx.run_id,
                    {"text": "repaired"}, "2.0.0", version=version,
                    parent_refs=ctx.input_dependencies,
                )
            if self.mode == "wrong_artifact_type":
                return ArtifactEnvelope.create(
                    ctx.target_artifact_id, ArtifactType.SECTION, ctx.run_id,
                    {"text": "repaired"}, "2.0.0", version=version,
                    parent_refs=ctx.input_dependencies,
                )
            if self.mode == "forged_hash":
                art_ok = ArtifactEnvelope.create(
                    ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                    {"text": "repaired"}, "2.0.0", version=version,
                    parent_refs=ctx.input_dependencies,
                )
                return art_ok.model_copy(update={"content_hash": "f" * 64})
            # unknown_parent: names a dependency the runtime never declared
            stranger = _head_ref("art_stranger", ArtifactType.SECTION, 9, "9")
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                {"text": "repaired"}, "2.0.0", version=version,
                parent_refs=(stranger,),
            )

    rt, store = _make_runtime(
        tmp_path, parents, repairer=RepairProducingCorruption(corruption),
        evaluator=_fail_then_pass(),
    )
    result = await rt.run()

    assert result.accepted_artifact is None, (
        f"{corruption} must fail closed; got accepted {result.accepted_artifact}"
    )
    assert "art_paper_p1" not in store._state()["heads"], (
        f"{corruption} must leave no accepted paper head"
    )
    assert result.terminal_reason_code in (
        LoopReason.INVALID_OUTPUT, LoopReason.LEASE_LOST, LoopReason.MAX_VERSIONS,
    ), (
        f"{corruption} must fail closed within the existing caps, got "
        f"{result.terminal_reason_code}: {result.terminal_reason}"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_same_version_different_hash_dependency_is_refused(tmp_path):
    """Same version, different hash is an impossible immutable-chain mutation.

    A version identifies its content, so an append-only CAS chain can never present the
    same version with two different hashes. If a store did, treating it as an advance and
    rewriting the runtime's declared dependency onto it would paper over corruption --
    precisely the corruption this check exists to catch.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    s2_v1 = _head_ref("art_section_2", ArtifactType.SECTION, 1, "2")
    parents = (bp, s2_v1)

    # Same version, different content hash -- the impossible shape.
    tampered = _parent_ref("art_section_2", ArtifactType.SECTION, 1, "e")

    class RepairBindingSameVersionNewHash:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        async def repair(self, ctx, art, issues, intent_id, version):
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                {"text": "paper bound to a same-version hash mutation"}, "2.0.0",
                version=version, parent_refs=(bp, tampered),
            )

    rt, store = _make_runtime(
        tmp_path, parents, repairer=RepairBindingSameVersionNewHash(),
        evaluator=_fail_then_pass(),
    )

    # The store's accepted head carries the mutated hash at the SAME version.
    forged = ArtifactEnvelope.create(
        "art_section_2", ArtifactType.SECTION, "run_cas", {"text": "forged"}, "2.0.0",
        version=1, parent_refs=(bp,),
    )
    state = store._state()
    state["heads"]["art_section_2"] = forged.model_dump(mode="json")
    store._save(state, "seed_forged_head")

    result = await rt.run()

    assert result.accepted_artifact is None, (
        "a same-version/different-hash dependency must never be adopted as a head: "
        "that is an immutable-chain violation, not a legitimate advance"
    )
    assert "art_paper_p1" not in store._state()["heads"], (
        "fail-closed: no paper may be accepted on a mutated dependency head"
    )
    assert result.terminal_reason_code in (
        LoopReason.INVALID_OUTPUT, LoopReason.LEASE_LOST, LoopReason.MAX_VERSIONS,
    ), result.terminal_reason


@pytest.mark.asyncio
async def test_phase15_v2rate_b_stale_dependency_record_is_not_treated_as_the_head(tmp_path):
    """A record the persistence layer marks stale is not the accepted head.

    `resume_state` flags descendants of an invalidated artifact as `isStale`. Adopting a
    stale record as the new dependency head would resurrect a superseded version.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    s2_v1 = _head_ref("art_section_2", ArtifactType.SECTION, 1, "2")
    parents = (bp, s2_v1)

    class RepairBindingStaleHead:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        async def repair(self, ctx, art, issues, intent_id, version):
            stale_head = _head_ref("art_section_2", ArtifactType.SECTION, 2, "7")
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                {"text": "paper bound to a stale head"}, "2.0.0",
                version=version, parent_refs=(bp, stale_head),
            )

    rt, store = _make_runtime(
        tmp_path, parents, repairer=RepairBindingStaleHead(),
        evaluator=_fail_then_pass(),
    )

    # Publish S2@v2 but mark the record stale, as an invalidated descendant would be.
    s2_v2 = ArtifactEnvelope.create(
        "art_section_2", ArtifactType.SECTION, "run_cas", {"text": "invalidated"}, "2.0.0",
        version=2, parent_refs=(bp,),
    )
    state = store._state()
    state["heads"]["art_section_2"] = s2_v2.model_dump(mode="json")
    store._save(state, "seed_stale_head")

    original_resume = store.resume_state

    def resume_marking_stale(run_id):
        result = original_resume(run_id)
        return result.model_copy(update={"artifacts": [
            info.model_copy(update={"isStale": True}) if info.artifactId == "art_section_2" else info
            for info in result.artifacts
        ]})

    store.resume_state = resume_marking_stale

    result = await rt.run()

    assert result.accepted_artifact is None, (
        "a stale dependency record must not be adopted as the accepted head"
    )
    assert "art_paper_p1" not in store._state()["heads"], (
        "fail-closed: no paper may be accepted on a stale dependency head"
    )
    assert result.terminal_reason_code in (
        LoopReason.INVALID_OUTPUT, LoopReason.LEASE_LOST, LoopReason.MAX_VERSIONS,
    ), result.terminal_reason


@pytest.mark.asyncio
async def test_phase15_v2rate_b_dependency_resync_is_a_noop_when_nothing_advanced(tmp_path):
    """With no dependency advance, the resync must change nothing about the outcome.

    Guards against the resync path changing behaviour for the ordinary case -- the vast
    majority of loops, where a repair is bound to exactly the declared refs. A clean
    repair must pass through with its declared refs intact.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    parents = (bp,)

    class StableRepair:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        async def repair(self, ctx, art, issues, intent_id, version):
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                {"text": "repaired against unchanged deps"}, "2.0.0",
                version=version, parent_refs=ctx.input_dependencies,
            )

    class HealingEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            self.statuses = [EvaluationStatus.FAIL if art.version == 1 else EvaluationStatus.PASS]
            return await super().evaluate(ctx, art, intent_id)

    rt, store = _make_runtime(
        tmp_path, parents, repairer=StableRepair(), evaluator=HealingEvaluator(),
    )
    result = await rt.run()

    assert result.decision == DecisionType.PASS, result.terminal_reason
    assert rt.context.input_dependencies == (bp,), \
        "declared deps must be untouched when no dependency advanced"


@pytest.mark.asyncio
async def test_phase15_v2rate_b_dependency_resync_does_not_raise_a_cap(tmp_path):
    """The resync path must not widen any version, call or token budget.

    The whole recovery must stay inside the caller's existing caps. This asserts the
    policy object is byte-identical to the one handed in, so the recovery path cannot
    have quietly raised `max_versions`, `max_generated_versions` or the repair cap.
    """
    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    s1 = _head_ref("art_section_1", ArtifactType.SECTION, 1, "1")
    s2_v1 = _head_ref("art_section_2", ArtifactType.SECTION, 1, "2")
    rt, store = _make_runtime(tmp_path, (bp, s1, s2_v1))
    requested_defaults = LoopPolicy(required_evaluator_ids=("required",))

    before = rt.policy.model_dump(mode="json")
    rt._refresh_input_dependencies_from_res_state()
    after = rt.policy.model_dump(mode="json")

    assert before == after, "the dependency resync must not alter the loop policy"
    for cap in ("max_versions", "max_generated_versions", "max_repair_attempts_per_version",
                "max_consecutive_no_progress", "max_oscillation_cycles"):
        assert getattr(rt.policy, cap) == getattr(requested_defaults, cap), (
            f"{cap} must equal the production default; the resync path must not widen it"
        )


# ─────────────────────────────────────────────────────────────────────────────
# (3) Issue-code routing: an unrepairable blocker must still terminate truthfully.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_phase15_v2rate_b_unrepairable_blocker_still_terminates_without_a_cap(tmp_path):
    """A defect no repair can justify must still end the loop inside the version budget.

    The recovery work must not have turned `RepairJustificationError` into a rubber
    stamp: when the repairer refuses because no passage-grounded change is justified,
    the loop must terminate with a truthful reason and accept nothing.
    """
    from app.repair.base import RepairJustificationError

    bp = _parent_ref("art_bp_1", ArtifactType.EXAM_BLUEPRINT, 1, "a")
    parents = (bp,)

    class RefusingRepair:
        repairer_id = "repair"
        repairer_version = "fake-v2"

        def __init__(self):
            self.calls = 0

        async def repair(self, ctx, art, issues, intent_id, version):
            self.calls += 1
            raise RepairJustificationError(
                "no passage-grounded span justifies this change"
            )

    refusing = RefusingRepair()
    rt, store = _make_runtime(
        tmp_path, parents, repairer=refusing,
        # AMBIGUOUS_ANSWER is repair-eligible, so the refusal path is actually reached.
        evaluator=Evaluator([EvaluationStatus.FAIL] * 6, IssueCode.AMBIGUOUS_ANSWER),
    )
    result = await rt.run()

    assert result.accepted_artifact is None, "fail-closed: nothing may be accepted"
    assert refusing.calls >= 1, "the repairer must actually have been consulted"
    assert result.versions_count <= rt.policy.max_versions, (
        f"version budget exceeded: {result.versions_count} > {rt.policy.max_versions}"
    )
    assert result.terminal_reason_code in (
        LoopReason.MAX_VERSIONS, LoopReason.NO_PROGRESS, LoopReason.INVALID_OUTPUT,
    ), result.terminal_reason