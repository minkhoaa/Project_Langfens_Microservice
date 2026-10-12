"""Phase 15 V2 recovery-side regression tests (agent B / RepairClosure).

Each test here FAILS on the pre-fix code and PASSES after. They pin the recovery-side
defects that caused the V2 valid-Draft rate to collapse to 11/18 on the canonical
MiniMax campaign `camp_G15_c9750f53d6b5`:

* Cases 8/13/14/16/18 -- three consecutive regenerations of slot Q20 burned the whole
  version budget and were reported as `MAX_VERSIONS: 3 unresolved blockers` instead of
  the truthful `NO_PROGRESS`. Covers the detector fingerprint and the controller's
  terminal attribution.
* Case 4 -- `Paper loop rejected paper: MAX_VERSIONS: 3 exact-target blockers` because
  the paper planner never produced the mutation payload the executor requires.
* Case 9 -- a passage loop consumed its entire combined generate+repair version budget
  on one generation, leaving zero room to retry.
* `test_t06_05_evaluator_timeout_fail_closed` -- a hanging evaluator under a 0.05 s
  operation wall reservation returned PASS instead of failing closed.
* `test_t11_*` -- the structural evaluator emitted coverage blockers it does not own.

No evaluator threshold, issue code, or severity is relaxed by any test in this file.
"""

from __future__ import annotations

import asyncio
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopReason
from app.evaluators.coverage import SectionCoverageEvaluator
from app.evaluators.section import SectionStructureEvaluator
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.detectors import (
    OscillationDetector,
    StagnationDetector,
    normalized_outcome_fingerprint,
)
from app.loop.policy import LoopPolicy
from app.repair.base import RepairJustificationError

from tests.test_t06_loop_runtime import (
    Evaluator,
    Generator,
    policy_for_profile,
    setup,
    simulated_run_profile,
)
from tests.test_t08_passage_loop import SQLiteCheckpointSimulation
from tests.test_t11_section_loop import (
    create_mock_passage_envelope,
    create_mock_question_envelopes,
)
from app.contracts.section import assemble_immutable_section


# ─────────────────────────────────────────────────────────────────────────────
# (A) Stagnation / oscillation must stop repeated no-progress regeneration
#     BEFORE the version cap is reached, and attribute it truthfully.
# ─────────────────────────────────────────────────────────────────────────────


def test_phase15_v2rate_b_stagnation_fingerprint_ignores_volatile_accounting_fields():
    """Two attempts differing only in token/timing accounting are NOT progress.

    Pre-fix, `StagnationDetector` compared the whole artifact content hash, which
    includes `tokensUsed` / `wallTimeUsedSeconds`. Three regenerations of the same
    defective slot therefore produced three different hashes and each looked like
    fresh progress, so `is_stagnated` never fired and the version cap was reached
    instead. Cases 8/13/14/16/18 are exactly this shape.
    """
    attempt_one = {"answer": "", "prompt": "", "tokensUsed": 1200, "wallTimeUsedSeconds": 4.1}
    attempt_two = {"answer": "", "prompt": "", "tokensUsed": 1180, "wallTimeUsedSeconds": 6.7}
    attempt_real_progress = {"answer": "hippocampus", "prompt": "Q20 ...", "tokensUsed": 1180,
                             "wallTimeUsedSeconds": 6.7}

    assert normalized_outcome_fingerprint(attempt_one, ["fp_a"]) == normalized_outcome_fingerprint(
        attempt_two, ["fp_a"]
    ), "volatile accounting fields must not defeat no-progress detection"
    assert normalized_outcome_fingerprint(attempt_one, ["fp_a"]) != normalized_outcome_fingerprint(
        attempt_real_progress, ["fp_a"]
    ), "genuinely different content must still count as progress"


@pytest.mark.asyncio
async def test_phase15_v2rate_b_repeated_no_progress_regeneration_terminates_as_no_progress(tmp_path):
    """Three regenerations of the same defective slot must end NO_PROGRESS, not MAX_VERSIONS.

    Pre-fix this loop regenerated the byte-different-but-semantically-identical empty
    answer three times and reported `MAX_VERSIONS: 3 unresolved blockers`, which told
    diagnostic replay "ran out of versions" instead of the truth: "repair could not
    produce a compliant artifact and further attempts would not help".
    """
    calls = {"n": 0}

    class AlwaysEmptyAnswerGenerator:
        version = "fake-v1"
        name = "always_empty_answer"

        async def generate(self, ctx, intent_id, version):
            calls["n"] += 1
            return ArtifactEnvelope.create(
                ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
                # Vary only volatile accounting fields, exactly like a real provider
                # round-trip does, while the defective content stays identical.
                {"questionNumber": 20, "prompt": "", "answer": "",
                 "tokensUsed": 1000 + calls["n"], "wallTimeUsedSeconds": float(calls["n"])},
                "fake-v1", version=version,
                parent_refs=ctx.input_dependencies,
            )

    evaluator = Evaluator([EvaluationStatus.FAIL] * 6, IssueCode.SCHEMA_VIOLATION)
    # Rebuild the policy on a cap profile that actually declares these bounds: a raw
    # LoopPolicy would otherwise be rejected by the pinned-cap-profile validator.
    base = policy_for_profile(simulated_run_profile(LoopPolicy()))
    profile = dict(base.cap_profile_snapshot)
    # Give the run enough token headroom that the loop reaches the no-progress
    # detector rather than tripping the token cap first; this isolates exactly the
    # mechanism under test.
    profile["caps"] = {
        **profile["caps"],
        "loopMaxVersions": 6,
        "loopMaxGeneratedVersions": 6,
        "loopMaxTotalTokens": 600_000,
        "loopMaxTotalCalls": 200,
    }
    rt, store = setup(
        tmp_path,
        policy=policy_for_profile(
            profile,
            max_versions=6,
            max_generated_versions=6,
            max_consecutive_no_progress=2,
            max_total_tokens=600_000,
            max_total_calls=200,
            required_evaluator_ids=("required",),
        ),
        evaluator=evaluator,
        generator=AlwaysEmptyAnswerGenerator(),
    )
    result = await rt.run()

    assert result.decision == DecisionType.FAIL
    assert result.terminal_reason_code == LoopReason.NO_PROGRESS, (
        f"repeated no-progress work must be attributed truthfully, got "
        f"{result.terminal_reason_code}: {result.terminal_reason}"
    )
    # The budget must NOT have been silently consumed: with cap 2 the loop stops on
    # the second identical repeat, well before the 6-version ceiling.
    assert result.versions_count <= 3, f"version budget over-consumed: {result.versions_count}"
    assert "passage" not in store._state()["heads"], "fail-closed: nothing may be accepted"


def test_phase15_v2rate_b_oscillation_detector_catches_identical_consecutive_repeat():
    """Re-entering the identical (hash, issue-set) state IS a cycle.

    Pre-fix `OscillationDetector` only flagged A -> B -> A, because it required the
    following state to *differ*. Three identical regenerations of one slot (the exact
    campaign signature) were structurally invisible to it.
    """
    detector = OscillationDetector()
    issues = {"fp_schema_empty_answer"}

    assert detector.record_state("hash_a", issues) is False   # first sighting
    assert detector.record_state("hash_a", issues) is True    # identical repeat
    assert detector.is_oscillating(1)
    assert detector.consecutive_repeats == 1


def test_phase15_v2rate_b_stagnation_detector_tracks_outcomes_across_regeneration():
    """The detector itself counts identical outcomes; the runtime no longer clears it."""
    detector = StagnationDetector()
    fp = normalized_outcome_fingerprint({"answer": "", "tokensUsed": 1}, ["fp"])

    assert detector.record_outcome(fp) == 0
    assert not detector.is_stagnated(2)
    assert detector.record_outcome(fp) == 1
    assert not detector.is_stagnated(2), "one repeat is not yet the configured cap"
    assert detector.record_outcome(fp) == 2
    assert detector.is_stagnated(2), "two consecutive identical outcomes must stagnate"


# ─────────────────────────────────────────────────────────────────────────────
# (B) Evaluator timeout must fail closed under a tight wall reservation.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_phase15_v2rate_b_hanging_evaluator_fails_closed_under_wall_reservation(tmp_path):
    """A hanging evaluator under a tight operation wall reservation must not PASS.

    Pre-fix the effective timeout was `max(operation_wall_reservation, evaluator
    metadata timeout, semantic timeout)`, so the operation reservation was silently
    widened to the 30 s semantic default and a hanging evaluator returned PASS.

    The reservation is 1 s (the smallest value the pinned cap profile can carry --
    caps are positive 32-bit integers, matching .NET `RequiredInt`) against a 2 s
    hang. The semantic default stays at its 30 s untouched, so `min` must select the
    1 s operation reservation to time out, while the pre-fix `max` would have
    admitted the whole 2 s hang. The wall reservation is therefore the sole binding
    constraint here.
    """
    class HangingEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            await asyncio.sleep(2.0)
            return await super().evaluate(ctx, art, intent_id)

    policy = LoopPolicy(required_evaluator_ids=("required",), operation_wall_reservation_seconds=1)
    rt, store = setup(tmp_path, evaluator=HangingEvaluator(), policy=policy)
    result = await rt.run()

    assert result.decision == DecisionType.FAIL
    assert result.terminal_reason_code == LoopReason.EVALUATOR_ERROR
    assert "passage" not in store._state()["heads"]
    assert any(
        i.code == IssueCode.EVALUATOR_UNAVAILABLE
        and i.severity == IssueSeverity.CRITICAL
        and "TimeoutError" in i.message
        for i in result.ledger.issues
    ), "a timeout must be recorded as fail-closed with TimeoutError evidence"


# ─────────────────────────────────────────────────────────────────────────────
# (C) Coverage enforcement moves to its owning evaluator -- never deleted.
# ─────────────────────────────────────────────────────────────────────────────


def _bp_ref() -> ArtifactRef:
    return ArtifactRef(
        artifactId="art_bp", version=1,
        artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="0" * 64,
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_coverage_enforcement_moved_not_deleted():
    """Structural evaluator owns shape; coverage evaluator owns coverage. Both fail closed.

    Pre-fix `SectionStructureEvaluator` demanded an `evaluationsSummary` for its shape
    invariants, so a structurally perfect section could never pass. The coverage
    guarantee was neither deleted nor relaxed -- it now has its own owner that still
    emits the identical CRITICAL `FRESH_EVALUATION_MISSING` / `STALE_DEPENDENCY`
    blockers under the identical conditions.
    """
    sec = assemble_immutable_section(
        1, "Section 1", create_mock_passage_envelope(1, 800), _bp_ref(),
        create_mock_question_envelopes(1),
    )
    ctx = LoopContext(
        runId="run_p15_b", scope=IssueScope.SECTION, targetArtifactId=sec.artifact_id,
        targetArtifactType=ArtifactType.SECTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    structural = SectionStructureEvaluator()
    coverage = SectionCoverageEvaluator()

    # 1. Structure: a well-formed section passes regardless of coverage binding.
    struct_ok = await structural.evaluate(ctx, sec, "int_struct_ok")
    assert struct_ok.status == EvaluationStatus.PASS
    assert not any(
        i.code in (IssueCode.FRESH_EVALUATION_MISSING, IssueCode.STALE_DEPENDENCY)
        for i in struct_ok.issues
    ), "structural invariants must not be coupled to coverage binding"

    # 2. Coverage: absent summary STILL fails closed, on the owning evaluator.
    cov_missing = await coverage.evaluate(ctx, sec, "int_cov_missing")
    assert cov_missing.status == EvaluationStatus.FAIL
    assert any(
        i.code == IssueCode.FRESH_EVALUATION_MISSING and i.severity == IssueSeverity.CRITICAL
        for i in cov_missing.issues
    )

    # 3. Coverage: explicit missing solver coverage still fails closed.
    no_solver = _with_summary(sec, {"solverCovered": False, "adversaryCovered": True})
    cov_no_solver = await coverage.evaluate(ctx, no_solver, "int_cov_no_solver")
    assert cov_no_solver.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.FRESH_EVALUATION_MISSING for i in cov_no_solver.issues)

    # 4. Coverage: explicit missing adversary coverage still fails closed.
    no_adv = _with_summary(sec, {"solverCovered": True, "adversaryCovered": False})
    cov_no_adv = await coverage.evaluate(ctx, no_adv, "int_cov_no_adv")
    assert cov_no_adv.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.FRESH_EVALUATION_MISSING for i in cov_no_adv.issues)

    # 5. Coverage: stale dependencies still fail closed.
    stale = _with_summary(
        sec,
        {"freshEvaluations": True, "solverCovered": True, "adversaryCovered": True,
         "acceptedEvaluationRefs": ["eval_1"], "hasStaleDependencies": True},
    )
    cov_stale = await coverage.evaluate(ctx, stale, "int_cov_stale")
    assert cov_stale.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.STALE_DEPENDENCY for i in cov_stale.issues)

    # 6. Coverage: fully satisfied coverage passes. No threshold was relaxed.
    good = _with_summary(
        sec,
        {"freshEvaluations": True, "solverCovered": True, "adversaryCovered": True,
         "acceptedEvaluationRefs": ["eval_1"], "hasStaleDependencies": False},
    )
    cov_good = await coverage.evaluate(ctx, good, "int_cov_good")
    assert cov_good.status == EvaluationStatus.PASS


def _with_summary(sec: ArtifactEnvelope, summary: dict) -> ArtifactEnvelope:
    payload = dict(sec.payload)
    payload["evaluationsSummary"] = summary
    return ArtifactEnvelope.create(
        artifact_id=sec.artifact_id, artifact_type=sec.artifact_type, run_id=sec.run_id,
        payload=payload, producer_version="2.0.0", version=sec.version,
        section_id=sec.section_id, parent_refs=list(sec.parent_refs),
    )


# ─────────────────────────────────────────────────────────────────────────────
# (D) Case 4: the paper planner must produce the patch payload the executor needs.
# ─────────────────────────────────────────────────────────────────────────────


def _paper_with_leaky_question():
    """Builds a valid 3-section paper whose S1 Q5 prompt leaks its own answer."""
    bp = _bp_ref()
    section_payloads = []
    for sec_idx, word_count in ((1, 800), (2, 820), (3, 850)):
        sec = assemble_immutable_section(
            sec_idx, f"Section {sec_idx}",
            create_mock_passage_envelope(sec_idx, word_count), bp,
            create_mock_question_envelopes(sec_idx),
        )
        groups = []
        for grp in sec.payload["groups"]:
            qs = []
            for q in grp["questions"]:
                q = dict(q)
                if sec_idx == 1 and q.get("questionNumber") == 5:
                    # The prompt literally contains its own answer -> ANSWER_LEAKAGE.
                    q["prompt"] = "The study found effects in the hippocampus."
                    q["statement"] = q["prompt"]
                qs.append(q)
            groups.append({**dict(grp), "questions": qs})
        section_payloads.append({**dict(sec.payload), "groups": groups})
        section_payloads[-1]["__ref__"] = sec.to_ref()

    return ArtifactEnvelope.create(
        artifact_id="art_paper_1", artifact_type=ArtifactType.READING_PAPER,
        run_id=sec.run_id,
        payload={
            "paperId": "paper_1", "title": "Reading Paper 1",
            "sections": [{k: v for k, v in s.items() if k != "__ref__"} for s in section_payloads],
            "sectionRefs": [s["__ref__"] for s in section_payloads],
            "passageRefs": [
                ArtifactRef.model_validate(s["passageRef"]) for s in section_payloads
            ],
            "blueprintRef": bp,
            "questionRefs": [r for s in section_payloads for r in s["questionRefs"]],
        },
        producer_version="2.0.0", version=1, parent_refs=[bp],
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_paper_repair_applies_grounded_patch_and_preserves_locality():
    """Case 4: a grounded paper-level issue is repaired surgically, not aborted.

    Pre-fix `PaperSurgicalRepairer._repair_impl` always built a directive with an empty
    `patch_payload`/`question_patches`, so `repair_paper` raised `RepairJustificationError`
    on every attempt and all three versions were burned on the empty-directive gate.
    """
    from app.repair.paper import PaperSurgicalRepairer

    paper = _paper_with_leaky_question()
    before_hashes = _question_hashes(paper)

    leakage = Issue.create(
        issue_id="iss_leak_5",
        code=IssueCode.ANSWER_LEAKAGE,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 5 prompt leaks its own answer 'hippocampus'",
        affected_refs=[],
        evidence="hippocampus",
        proposed_repair="hippocampus",
    )
    ctx = LoopContext(
        runId=paper.run_id, scope=IssueScope.PAPER, targetArtifactId=paper.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    repaired = await PaperSurgicalRepairer().repair(ctx, paper, [leakage], "intent_repair", 2)

    assert repaired.version == paper.version + 1, "repair must produce a strictly new version"
    assert repaired.verify_integrity()

    after_hashes = _question_hashes(repaired)
    # Locality: exactly the leaked question changed; every sibling is bit-for-bit intact.
    changed = [q for q in after_hashes if before_hashes.get(q) != after_hashes[q]]
    assert changed == [5], f"repair must be local to Q5, changed={changed}"
    assert [q for q in before_hashes if before_hashes[q] == after_hashes[q]] == sorted(
        q for q in before_hashes if q != 5
    ), "all unaffected questions must retain their exact original content"

    q5 = _question_by_number(repaired, 5)
    assert "hippocampus" not in q5["prompt"].lower(), "leakage must be eliminated"
    # Locality means the *answer* is untouched: only the leaking prompt changes.
    assert q5["answer"] == _question_by_number(paper, 5)["answer"], (
        "an answer-leakage repair must not mutate the answer itself"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_paper_repair_still_fails_closed_without_grounded_proposal():
    """The empty-directive gate must survive: an ungrounded defect still fails closed.

    Guards against "fix case 4" being implemented by simply removing the
    `RepairJustificationError` gate.
    """
    from app.repair.paper import PaperSurgicalRepairer

    paper = _paper_with_leaky_question()
    ungrounded = Issue.create(
        issue_id="iss_ungrounded_5",
        code=IssueCode.ANSWER_LEAKAGE,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 5 has some leakage with no evidence-grounded proposal",
        affected_refs=[],
    )
    ctx = LoopContext(
        runId=paper.run_id, scope=IssueScope.PAPER, targetArtifactId=paper.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    with pytest.raises(RepairJustificationError):
        await PaperSurgicalRepairer().repair(ctx, paper, [ungrounded], "intent_repair", 2)


def _question_by_number(env: ArtifactEnvelope, q_num: int) -> dict:
    for sec in env.payload["sections"]:
        for grp in sec["groups"]:
            for q in grp["questions"]:
                if int(q.get("questionNumber")) == q_num:
                    return q
    raise AssertionError(f"question {q_num} not found")


def _question_hashes(env: ArtifactEnvelope) -> dict:
    import json

    out = {}
    for sec in env.payload["sections"]:
        for grp in sec["groups"]:
            for q in grp["questions"]:
                out[int(q["questionNumber"])] = json.dumps(q, sort_keys=True, default=str)
    return out


# ─────────────────────────────────────────────────────────────────────────────
# (E) Repair failure attribution: never swallowed, always distinguishable.
# ─────────────────────────────────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_phase15_v2rate_b_repair_refusal_is_recorded_and_not_swallowed(tmp_path):
    """`RepairJustificationError` must be visible as a truthful terminal reason.

    Pre-fix the runtime caught every repairer exception and silently advanced the
    cursor to DRAFTING, so a fail-closed refusal was indistinguishable from an
    implementation crash and from ordinary regeneration.
    """
    class FailingRepairer:
        repairer_id = "always_refuses"
        repairer_version = "fake-v1"
        name = "always_refuses"

        async def repair(self, ctx, artifact, issues, intent_id, version):
            raise RepairJustificationError(
                "no passage-grounded span exists for this answer; refusing blind mutation"
            )

    evaluator = Evaluator([EvaluationStatus.FAIL] * 4, IssueCode.ANSWER_LEAKAGE)
    base = policy_for_profile(simulated_run_profile(LoopPolicy()))
    rt, store = setup(
        tmp_path,
        policy=policy_for_profile(
            base.cap_profile_snapshot,
            required_evaluator_ids=("required",),
            max_versions=3,
            max_generated_versions=3,
        ),
        evaluator=evaluator,
        repairer=FailingRepairer(),
    )
    result = await rt.run()

    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"], "a refused repair must not accept anything"
    assert rt._capability_failures, "the repair refusal must be recorded, never swallowed"
    assert any("REPAIR_INFEASIBLE" in rec for rec in rt._capability_failures), (
        f"refusal must be attributed as repair-infeasible, got {rt._capability_failures}"
    )