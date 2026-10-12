"""Phase 15 V2 loop-recovery: the shared version budget between repair and
generation, pinned at paper and passage scope.

FINDING (applies to BOTH cases 4 and 9)
---------------------------------------
`LoopPolicy.max_versions` is ONE immutable-version budget shared by generation and
repair, while `max_generated_versions` separately bounds generations. With the
production values (`max_versions=3`, `max_generated_versions=3`,
`max_repair_attempts_per_version=2`) a loop that has a repairer spends its budget
as: v1 generate, v2 repair, v3 repair. `max_generated_versions` is therefore never
approached -- the loop performs exactly ONE generation.

That is precisely the asymmetry the campaign recorded:

* Case 9 -- `Passage generation failed in section 3: MAX_VERSIONS: 1 exact-target
  blockers` -- the section-3 passage had ONE generation attempt, so the
  "1 exact-target blocker" was literally all the content it ever produced.
* Case 4 -- `Paper loop rejected paper: MAX_VERSIONS: 3 exact-target blockers` --
  the same accounting at paper scope.

The blocker set was unchanged after each repair, so those repairs had already been
shown not to resolve it; spending the last version on another repair is strictly
worse than spending it on a fresh generation.

The fix redirects ONLY the final version slot, and only when the detectors are not
already reporting repeats (so NO_PROGRESS/OSCILLATION attribution is preserved).
`max_versions`, `max_generated_versions`, `max_repair_attempts_per_version`, the
fail-closed invariant, and every evaluator threshold are unchanged. No cap is raised.

SCOPE NOTE ON CASE 4
--------------------
Production `PaperLoop` installs `PaperRepairerAdapter`, which builds its own
directive and injects a generic `patch_payload` when it has no question patch. It
therefore never reaches `PaperSurgicalRepairer`'s empty-directive gate, and case 4
is NOT an empty-directive refusal. `test_..._production_adapter_bypasses_the_
empty_directive_gate` pins that fact so case 4 is not mis-attributed again. The
paper-scope budget test below is a regression guard on the live adapter, not proof
that case 4 is cleared.

No evaluator threshold, issue code, or severity is relaxed by any test here.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import Any, Dict, List
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopReason, LoopState
from app.contracts.section import assemble_immutable_section
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.controller import LoopController
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy
from app.repair.base import RepairJustificationError
from app.repair.paper import PaperSurgicalRepairer

from tests.test_t06_loop_runtime import (
    artifact,
    context,
    policy_for_profile,
    setup,
    simulated_run_profile,
)
from tests.test_t11_section_loop import (
    create_mock_passage_envelope,
    create_mock_question_envelopes,
)


def _roomy_policy(**overrides) -> LoopPolicy:
    """Policy with resource headroom so the version cap is actually reached.

    Only token/call headroom is widened; the version caps under test are the
    production values unless a caller overrides them explicitly.
    """
    base = policy_for_profile(simulated_run_profile(LoopPolicy()))
    profile = dict(base.cap_profile_snapshot)
    profile["caps"] = {
        **profile["caps"],
        "loopMaxTotalTokens": 5_000_000,
        "loopMaxTotalCalls": 500,
    }
    return policy_for_profile(profile, required_evaluator_ids=("required",), **overrides)


# ─────────────────────────────────────────────────────────────────────────────
# The shared-budget defect, proven at the controller.
# ─────────────────────────────────────────────────────────────────────────────


def test_phase15_v2rate_d_final_slot_is_redirected_from_repair_to_regeneration():
    """The last version must buy a fresh generation, not a third repair.

    Pre-fix the controller chose REPAIR whenever `repair_attempts_this_version <
    max_repair_attempts_per_version`, so at version 2 of 3 it spent the final slot
    on a repair of an artifact already shown to be unrepairable, and never
    regenerated again.
    """
    policy = LoopPolicy(
        required_evaluator_ids=("required",),
        max_versions=3,
        max_generated_versions=3,
        max_repair_attempts_per_version=2,
    )
    controller = LoopController(policy)

    def decide(version: int, repair_attempts: int, generated: int, stagnation=0):
        ctx = context()
        art = artifact(ctx, version, f"artifact v{version}")
        ctx.current_artifact = art
        ledger = IssueLedgerManager(f"run_d_{version}_{repair_attempts}_{generated}_{stagnation}")
        ledger.record_issue(
            IssueCode.OVERSTATED_CERTAINTY, IssueSeverity.CRITICAL,
            ctx.scope, "defect", [art.to_ref()],
        )
        ev = EvaluationResult(
            evaluationId=f"eval_{version}", evaluatorId="required", evaluatorVersion="1",
            targetRef=art.to_ref(), status=EvaluationStatus.FAIL,
            issues=ledger.get_open_issues(),
        )
        detector = StagnationDetector()
        for _ in range(stagnation):
            detector.record_outcome("same-fingerprint")
        return controller.decide(
            ctx, ledger, [ev], detector, OscillationDetector(),
            dependencies_fresh=True, repair_attempts_this_version=repair_attempts,
            generated_versions=generated, has_repairer=True,
        )

    # Not the final slot: the surgical repair path is preserved.
    assert decide(1, repair_attempts=0, generated=1).decision == DecisionType.REPAIR
    assert decide(1, repair_attempts=1, generated=1).decision == DecisionType.REPAIR

    # Final slot, generation budget still available: redirect to regeneration.
    final = decide(2, repair_attempts=1, generated=1)
    assert final.decision == DecisionType.REGENERATE
    assert final.next_state == LoopState.DRAFTING
    assert "final version slot redirected" in final.reason

    # The redirect must NOT mask the detectors' truthful attribution: once the
    # loop is already stagnating, NO_PROGRESS is the honest terminal reason and a
    # regeneration would hide it behind MAX_VERSIONS. Two repeats are required
    # before `is_stagnated` fires at the default cap of 2.
    stagnating = decide(2, repair_attempts=1, generated=1, stagnation=3)
    assert stagnating.decision == DecisionType.FAIL
    assert stagnating.reason_code == LoopReason.NO_PROGRESS
    assert "final version slot redirected" not in stagnating.reason


def test_phase15_v2rate_d_no_version_cap_was_raised():
    """Anti-regression: neither fix may be "make it pass by raising the budget"."""
    default = LoopPolicy()
    assert default.max_versions == 3
    assert default.max_generated_versions == 3
    assert default.max_repair_attempts_per_version == 2
    assert default.max_total_repairs == 5
    for is_benchmark in (False, True):
        scoped = LoopPolicy.from_settings(is_benchmark=is_benchmark)
        assert scoped.max_versions == 3, f"is_benchmark={is_benchmark}"
        assert scoped.max_generated_versions == 3, f"is_benchmark={is_benchmark}"
    passage_scoped = LoopPolicy.from_settings(
        is_benchmark=False, generate_reservation_cap="passageGenerateTokenReservation"
    )
    assert passage_scoped.max_versions == 3
    assert passage_scoped.max_generated_versions == 3


# ─────────────────────────────────────────────────────────────────────────────
# Case 9, passage scope: the loop must actually reach a second generation.
# ─────────────────────────────────────────────────────────────────────────────


class _PassageGenerator:
    """Fresh passage draft per generation, distinguishable from a repair."""

    version = "fake-passage"
    name = "fake-passage"

    def __init__(self) -> None:
        self.calls = 0

    async def generate(self, ctx, intent_id, version):
        self.calls += 1
        return artifact(ctx, version, f"fresh passage draft {version}")


class _MechanicalPassageRepairer:
    """Succeeds mechanically but never resolves the blocker set.

    Mirrors the campaign shape: a repairer that is *available* yet *ineffective*
    (e.g. `PassageSentenceRepairer` returning a compliant new version that still
    fails the grounding evaluator) is what consumed the version budget.
    """

    repairer_id = "mechanical_passage_repairer"
    repairer_version = "fake-v1"
    name = "mechanical_passage_repairer"

    def __init__(self) -> None:
        self.calls: List[int] = []

    async def repair(self, ctx, art, issues, intent_id, version):
        self.calls.append(version)
        payload = dict(art.payload)
        payload["text"] = f"{payload.get('text', '')} [softened {version}]"
        return art.create_next_version(new_payload=payload, producer_version="fake-v1")


class _HealsOnFreshGenerationEvaluator:
    """Blocks every repaired version; heals only on a fresh generation.

    Isolates the mechanism: if the loop spends its whole version budget on repairs
    it never reaches the generation that would pass.
    """

    evaluator_id = "required"
    evaluator_version = "fake-v1"

    def __init__(self, heal_at_version: int = 3) -> None:
        self.heal_at_version = heal_at_version
        self.calls = 0
        self._reported: List[str] = []

    async def evaluate(self, ctx, art, intent_id):
        self.calls += 1
        is_fresh = str(art.payload.get("text", "")).startswith("fresh passage draft")
        if art.version >= self.heal_at_version and is_fresh:
            return EvaluationResult(
                evaluationId=f"eval_{art.version}",
                evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version,
                targetRef=art.to_ref(),
                inputDependencyRefs=list(art.parent_refs),
                status=EvaluationStatus.PASS,
                issues=[],
                resolvedIssueFingerprints=list(self._reported),
                score=1.0,
            )
        issue = Issue.create(
            issue_id=f"iss_{art.version}_{self.calls}",
            code=IssueCode.OVERSTATED_CERTAINTY,
            severity=IssueSeverity.CRITICAL,
            scope=IssueScope.PASSAGE,
            message="passage asserts certainty not supported by the source",
            affected_refs=[art.to_ref()],
            evidence="proves",
        )
        self._reported.append(issue.fingerprint)
        return EvaluationResult(
            evaluationId=f"eval_{art.version}_{self.calls}",
            evaluatorId=self.evaluator_id,
            evaluatorVersion=self.evaluator_version,
            targetRef=art.to_ref(),
            inputDependencyRefs=list(art.parent_refs),
            status=EvaluationStatus.FAIL,
            issues=[issue],
            resolvedIssueFingerprints=[],
            score=0.0,
        )


@pytest.mark.asyncio
async def test_phase15_v2rate_d_case9_passage_loop_recovers_within_its_version_budget(tmp_path):
    """Case 9: the passage loop must reach a second generation and recover.

    Pre-fix the budget was spent as generate + 2 repairs, so the passage had ONE
    attempt and the campaign recorded `MAX_VERSIONS: 1 exact-target blockers`.
    Here the evaluator passes on a fresh v3, so a loop with real generation room
    must reach it.
    """
    generator = _PassageGenerator()
    repairer = _MechanicalPassageRepairer()
    rt, store = setup(
        tmp_path,
        policy=_roomy_policy(),
        evaluator=_HealsOnFreshGenerationEvaluator(heal_at_version=3),
        generator=generator,
        repairer=repairer,
    )
    result = await rt.run()

    assert generator.calls >= 2, (
        f"passage loop must reach a second generation; "
        f"generations={generator.calls}, repairs={repairer.calls}"
    )
    assert result.decision == DecisionType.PASS, (
        f"a fresh generation must be able to satisfy the evaluator; got "
        f"{result.decision} {result.terminal_reason_code}: {result.terminal_reason}"
    )
    assert result.terminal_reason_code == LoopReason.ACCEPTED
    assert result.accepted_artifact is not None
    assert result.accepted_artifact.verify_integrity()

    # The bound is unchanged: never more versions than the immutable cap.
    assert result.versions_count <= 3, (
        f"version bound must not be relaxed, versions_count={result.versions_count}"
    )
    assert store._state()["heads"]["passage"]["version"] == result.versions_count


@pytest.mark.asyncio
async def test_phase15_v2rate_d_case9_final_slot_redirect_keeps_repair_bounded(tmp_path):
    """The redirect applies to the final slot only; earlier slots still repair.

    Pins that the fix improves the odds rather than discarding the repair path,
    and that bounded retry and fail-closed behaviour are intact.
    """
    repairer = _MechanicalPassageRepairer()
    rt, store = setup(
        tmp_path,
        policy=_roomy_policy(),
        evaluator=_HealsOnFreshGenerationEvaluator(heal_at_version=99),
        generator=_PassageGenerator(),
        repairer=repairer,
    )
    result = await rt.run()

    assert result.decision == DecisionType.FAIL
    # v1 generate, v2 repair, v3 regenerate: exactly one repair, then the redirect.
    assert repairer.calls == [2], f"expected one repair then redirect, got {repairer.calls}"
    assert result.versions_count == 3
    assert result.terminal_reason_code == LoopReason.MAX_VERSIONS, (
        "with the evaluator never satisfied the cap is still the truthful reason"
    )
    assert "final version slot redirected" in result.terminal_reason
    assert "passage" not in store._state()["heads"], "fail-closed: nothing may be accepted"


# ─────────────────────────────────────────────────────────────────────────────
# Paper scope: the live adapter path, and the case-4 attribution guard.
# ─────────────────────────────────────────────────────────────────────────────


def _paper_with_leaky_question(run_id: str = "run_case04") -> ArtifactEnvelope:
    """A valid 3-section paper whose S1 Q5 prompt leaks its own answer."""
    bp = ArtifactRef(
        artifactId="art_blueprint_case04",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )
    section_payloads: List[Dict[str, Any]] = []
    for sec_idx, word_count in ((1, 800), (2, 820), (3, 850)):
        sec = assemble_immutable_section(
            sec_idx,
            f"Section {sec_idx}",
            create_mock_passage_envelope(sec_idx, word_count, run_id=run_id),
            bp,
            create_mock_question_envelopes(sec_idx, run_id=run_id),
            run_id=run_id,
        )
        groups = []
        for grp in sec.payload["groups"]:
            qs = []
            for q in grp["questions"]:
                q = dict(q)
                if sec_idx == 1 and q.get("questionNumber") == 5:
                    q["prompt"] = "The study found effects in the hippocampus."
                    q["statement"] = q["prompt"]
                qs.append(q)
            groups.append({**dict(grp), "questions": qs})
        payload = {**dict(sec.payload), "groups": groups}
        payload["__ref__"] = sec.to_ref()
        section_payloads.append(payload)

    return ArtifactEnvelope.create(
        artifact_id="art_paper_case04",
        artifact_type=ArtifactType.READING_PAPER,
        run_id=run_id,
        payload={
            "paperId": "paper_case04",
            "title": "Reading Paper Case 04",
            "sections": [
                {k: v for k, v in s.items() if k != "__ref__"} for s in section_payloads
            ],
            "sectionRefs": [s["__ref__"] for s in section_payloads],
            "passageRefs": [ArtifactRef.model_validate(s["passageRef"]) for s in section_payloads],
            "blueprintRef": bp,
            "questionRefs": [r for s in section_payloads for r in s["questionRefs"]],
        },
        producer_version="2.0.0",
        version=1,
        parent_refs=[bp],
    )


def _ungrounded_issue() -> Issue:
    return Issue.create(
        issue_id="iss_ungrounded_5",
        code=IssueCode.ANSWER_LEAKAGE,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 5 has some leakage with no evidence-grounded proposal",
        affected_refs=[],
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_d_case4_production_adapter_bypasses_the_empty_directive_gate():
    """Case 4 attribution guard: the live paper path never hits the gate.

    `PaperLoop` installs `PaperRepairerAdapter`, which builds its own directive and
    injects a generic `patch_payload` when it has no question patch. It therefore
    never hands `repair_paper` an empty directive, so case 4 is NOT an
    empty-directive refusal. This pins that fact so case 4 is not mis-attributed
    to the gate again.
    """
    from app.loop.paper import PaperRepairerAdapter
    from app.repair.paper import PaperRepairRouter

    paper = _paper_with_leaky_question()
    adapter = PaperRepairerAdapter(
        repairer=PaperSurgicalRepairer(),
        router=PaperRepairRouter(),
        persistence_client=None,
        accepted_dependencies=None,
    )
    ctx = LoopContext(
        runId=paper.run_id,
        scope=IssueScope.PAPER,
        targetArtifactId=paper.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    repaired = await adapter.repair(ctx, paper, [_ungrounded_issue()], "intent_repair", 2)
    assert repaired.version == paper.version + 1
    assert repaired.verify_integrity()


@pytest.mark.asyncio
async def test_phase15_v2rate_d_case4_empty_directive_gate_still_fails_closed():
    """The direct gate remains fail-closed: no grounded mutation, no repair."""
    paper = _paper_with_leaky_question()
    ctx = LoopContext(
        runId=paper.run_id,
        scope=IssueScope.PAPER,
        targetArtifactId=paper.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    with pytest.raises(RepairJustificationError) as excinfo:
        await PaperSurgicalRepairer().repair(ctx, paper, [_ungrounded_issue()], "intent_repair", 2)

    assert "forbidden by exact closure invariant" in str(excinfo.value)


@pytest.mark.asyncio
async def test_phase15_v2rate_d_case4_grounded_proposal_repairs_locally():
    """A grounded paper defect still repairs surgically, with strict locality.

    Supplies the before/after evidence the repair-locality rubric requires
    (validation-matrix section 7): exactly one question changes; every other
    question is preserved bit-for-bit with its answer untouched.
    """
    paper = _paper_with_leaky_question()
    before = _question_hashes(paper)

    grounded = Issue.create(
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
        runId=paper.run_id,
        scope=IssueScope.PAPER,
        targetArtifactId=paper.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    repaired = await PaperSurgicalRepairer().repair(ctx, paper, [grounded], "intent_repair", 2)

    assert repaired.version == paper.version + 1
    assert repaired.verify_integrity()

    after = _question_hashes(repaired)
    changed = sorted(q for q in after if before.get(q) != after[q])
    assert changed == [5], f"repair must be local to Q5, changed={changed}"
    assert all(before[q] == after[q] for q in before if q != 5), (
        "all unaffected questions must retain their exact original content"
    )
    q5_before = _question_by_number(paper, 5)
    q5_after = _question_by_number(repaired, 5)
    assert "hippocampus" not in q5_after["prompt"].lower(), "leakage must be eliminated"
    assert q5_after["answer"] == q5_before["answer"], (
        "an answer-leakage repair must not mutate the answer itself"
    )


class _PaperGenerator:
    """Generates a distinct artifact per version so the version cap is reachable."""

    version = "fake-paper"
    name = "fake-paper"

    def __init__(self) -> None:
        self.calls = 0

    async def generate(self, ctx, intent_id, version):
        self.calls += 1
        return artifact(ctx, version, f"paper draft {version} attempt {self.calls}")


class _AlwaysFailPaperEvaluator:
    """Reports the same deterministic blocker on every evaluation."""

    evaluator_id = "required"
    evaluator_version = "fake-v1"

    def __init__(self, code: IssueCode) -> None:
        self.code = code
        self.calls = 0

    async def evaluate(self, ctx, art, intent_id):
        self.calls += 1
        issues = [
            Issue.create(
                issue_id=f"iss_{art.version}_{self.calls}",
                code=self.code,
                severity=IssueSeverity.CRITICAL,
                scope=ctx.scope,
                message="Question 5 has some leakage with no evidence-grounded proposal",
                affected_refs=[art.to_ref()],
            )
        ]
        return EvaluationResult(
            evaluationId=f"eval_{art.version}_{self.calls}",
            evaluatorId=self.evaluator_id,
            evaluatorVersion=self.evaluator_version,
            targetRef=art.to_ref(),
            inputDependencyRefs=list(art.parent_refs),
            status=EvaluationStatus.FAIL,
            issues=issues,
            resolvedIssueFingerprints=[],
            score=0.0,
        )


@pytest.mark.asyncio
async def test_phase15_v2rate_d_case4_paper_loop_stays_inside_its_bound(tmp_path):
    """Paper-scope regression guard on the live adapter path.

    SCOPE LIMIT, stated plainly: this passes with and without the controller fix,
    because this synthetic harness drives the paper into regeneration rather than
    the repair branch. It guards the production adapter's bounds and fail-closed
    behaviour; it is NOT evidence that case 4 is cleared.
    """
    from app.loop.paper import PaperRepairerAdapter
    from app.repair.paper import PaperRepairRouter

    paper = _paper_with_leaky_question()
    adapter = PaperRepairerAdapter(
        repairer=PaperSurgicalRepairer(),
        router=PaperRepairRouter(),
        persistence_client=None,
        accepted_dependencies=None,
    )
    generator = _PaperGenerator()
    rt, store = setup(
        tmp_path,
        policy=_roomy_policy(),
        evaluator=_AlwaysFailPaperEvaluator(IssueCode.ANSWER_LEAKAGE),
        repairer=adapter,
        generator=generator,
    )
    rt.context.current_artifact = paper
    rt.context.accepted_artifact = None

    result = await rt.run()

    assert generator.calls <= 3, f"generation bound exceeded: {generator.calls}"
    assert result.versions_count <= 3, f"version bound relaxed: {result.versions_count}"
    assert result.decision == DecisionType.FAIL
    assert result.accepted_artifact is None, "fail-closed: nothing may be accepted"
    assert "passage" not in store._state()["heads"]


def _question_by_number(env: ArtifactEnvelope, q_num: int) -> dict:
    for sec in env.payload["sections"]:
        for grp in sec.get("groups", []):
            for q in grp.get("questions", []):
                if q.get("questionNumber") == q_num:
                    return q
    raise AssertionError(f"question {q_num} not found")


def _question_hashes(env: ArtifactEnvelope) -> Dict[int, str]:
    import hashlib
    import json

    def _plain(value):
        # Artifact payloads are frozen: nested entries are MappingProxyType.
        if isinstance(value, Mapping):
            return {k: _plain(v) for k, v in value.items()}
        if isinstance(value, (list, tuple)):
            return [_plain(v) for v in value]
        return value

    out: Dict[int, str] = {}
    for sec in env.payload["sections"]:
        for grp in sec.get("groups", []):
            for q in grp.get("questions", []):
                canonical = json.dumps(_plain(q), sort_keys=True)
                out[int(q["questionNumber"])] = hashlib.sha256(canonical.encode()).hexdigest()
    return out


def test_phase15_v2rate_d_section_three_distribution_is_unchanged():
    """Section 3 remains the Short Answer / YNNG section (Q27-Q40)."""
    from app.contracts.policies import SECTION_GROUP_TYPES, SECTION_QUESTION_COUNTS

    assert SECTION_QUESTION_COUNTS[3] == 14
    types_3 = [t.value for t in SECTION_GROUP_TYPES[3]]
    assert "YES_NO_NOT_GIVEN" in types_3
    assert "SHORT_ANSWER" in types_3