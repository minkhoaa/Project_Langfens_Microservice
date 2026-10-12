"""Phase 15 V2 repair-side regression tests (agent B / candidate salvage).

Scope: the SALVAGE path in `app/repair/question.py::QuestionItemRepairer`, i.e. the
case where a `SCHEMA_VIOLATION: Question N answer cannot be empty or missing` blocker is
repaired by substituting a candidate that is already persisted in the slot's candidate
pool rather than by minting new content.

The defect these tests pin: `_try_apply_candidate` gated candidates on verbatim grounding
and word count ONLY. It did not gate on anti-leakage or on group distinctness, so a
candidate that the engine had already rejected could be applied and returned as a
"successfully repaired" artifact. Consequences, both observed by execution:

* A candidate whose own answer appears verbatim in its own stem was applied. The next
  evaluation pass re-flagged the SAME slot as `ANSWER_LEAKAGE`, so the repair consumed a
  version and handed the loop back the same blocker -- a repair that costs budget and
  changes nothing.
* A candidate duplicating a sibling blank's answer in the same completion group was
  applied, violating the mutual-distinctness contract of a blank group.

The fix makes salvage consult the same invariants the generator consults. It does NOT
weaken any of them and it does NOT relax `RepairJustificationError` into a rubber stamp:
when the pool holds no compliant member, the repair still fails closed.

Every test asserts real behaviour against the real repairer. None of them reads source.
"""

from __future__ import annotations

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.evaluators.deterministic import AnswerVerbatimAndLengthEvaluator
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.repair.base import RepairJustificationError
from app.repair.question import QuestionItemRepairer


PASSAGE = (
    "The core profiles were gathered across three salinity gradients in the delta. "
    "Each core profile carried a distinct sediment record. "
    "Researchers recorded the oxygen minimum depth for every core profile."
)

BP = ArtifactRef(artifactId="art_bp_1", artifactType=ArtifactType.EXAM_BLUEPRINT,
                 version=1, contentHash="a" * 64)
P = ArtifactRef(artifactId="art_passage_s2", artifactType=ArtifactType.PASSAGE,
                version=1, contentHash="b" * 64)

EMPTY_ANSWER_ISSUE = Issue.create(
    issue_id="iss_empty_answer",
    code=IssueCode.SCHEMA_VIOLATION,
    severity=IssueSeverity.CRITICAL,
    scope=IssueScope.QUESTION,
    message="Question 20 answer cannot be empty or missing",
    affected_refs=[],
)


def _summary_section(pool, sibling_answers, shared_context="The study gathered [1] across [2] gradients."):
    """A section whose Q20 is starved and whose Q21/Q22 already hold real answers."""
    return {
        "sectionId": 2,
        "passage": PASSAGE,
        "groups": [{
            "groupId": "grp_sum_2",
            "questionType": "SummaryCompletion",
            "sharedContext": shared_context,
            "questions": [
                {
                    "questionNumber": 20,
                    "questionType": "SummaryCompletion",
                    "prompt": "The study gathered ____ across ____ gradients.",
                    "answer": "",
                    "candidates": pool,
                    "evidenceQuote": "The core profiles were gathered across three salinity gradients",
                },
                {"questionNumber": 21, "questionType": "SummaryCompletion",
                 "prompt": "A second blank resolved to ____ .",
                 "answer": sibling_answers[0]},
                {"questionNumber": 22, "questionType": "SummaryCompletion",
                 "prompt": "A third blank resolved to ____ .",
                 "answer": sibling_answers[1]},
            ],
        }],
    }


def _section_artifact(payload, version=1):
    return ArtifactEnvelope.create(
        "art_section_2", ArtifactType.SECTION, "run_salvage", payload, "2.0.0",
        version=version, section_id=2, parent_refs=[P, BP],
    )


def _section_context():
    return LoopContext(
        runId="run_salvage",
        targetArtifactId="art_section_2",
        targetArtifactType=ArtifactType.SECTION,
        scope=IssueScope.SECTION,
        authority=AuthorityGrant(leaseOwner=__import__("uuid").uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
        inputDependencies=(P, BP),
    )


async def _repair(payload, issues=(EMPTY_ANSWER_ISSUE,)):
    artifact = _section_artifact(payload)
    return await QuestionItemRepairer(gateway=None)._repair_impl(
        _section_context(), artifact, list(issues), "intent_salvage", 2,
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_serves_compliant_pooled_candidate():
    """A starved slot with a compliant pooled candidate is SERVED by repair, not regenerated.

    This is the positive case the whole recovery depends on: the candidate already
    exists in the persisted pool, it is verbatim in the passage, it is within the word
    budget, and it neither leaks nor duplicates a sibling. The repair must therefore
    succeed, produce a NEW immutable version with correct parent linkage, and leave the
    sibling blanks untouched.
    """
    payload = _summary_section(
        [{"answer": "core profiles",
          "prompt": "The study gathered ____ across ____ gradients.",
          "evidenceQuote": "The core profiles were gathered across three salinity gradients"}],
        ["salinity gradients", "delta"],
    )
    before_siblings = [dict(payload["groups"][0]["questions"][1]),
                       dict(payload["groups"][0]["questions"][2])]

    repaired = await _repair(payload)

    questions = repaired.payload["groups"][0]["questions"]
    assert questions[0]["answer"] == "core profiles", \
        "a compliant pooled candidate must be substituted for the starved slot"
    # Sibling blanks must be untouched -- the repair is surgical.
    assert [q["answer"] for q in questions[1:]] == ["salinity gradients", "delta"]
    for original, after in zip(before_siblings, questions[1:]):
        assert after["answer"] == original["answer"]
    # New immutable version with correct parent linkage and a verifying hash.
    assert repaired.version == 2
    assert repaired.artifact_id == "art_section_2"
    assert tuple(repaired.parent_refs) == (P, BP)
    assert repaired.verify_integrity(), "the repaired envelope must hash its own payload and parents"


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_rejects_leaking_pooled_candidate_and_uses_next():
    """A candidate whose own answer appears in its own stem must be SKIPPED, not applied.

    Pre-fix this was applied and returned as a successful repair; the next evaluation
    pass re-flagged the identical slot as ANSWER_LEAKAGE, so the repair burned a version
    and produced no progress. The compliant candidate that follows it in the pool must
    now be served instead.
    """
    payload = _summary_section(
        [
            # Leaks: 'core profiles' is verbatim inside this candidate's own stem.
            {"answer": "core profiles",
             "prompt": "core profiles were gathered across ____ gradients."},
            # Compliant.
            {"answer": "salinity gradients",
             "prompt": "The study gathered ____ across ____ gradients."},
        ],
        ["delta", "core profiles"],
    )

    repaired = await _repair(payload)

    q20 = repaired.payload["groups"][0]["questions"][0]
    assert q20["answer"] == "salinity gradients", \
        "the leaking candidate must be skipped in favour of the compliant one"
    assert q20["prompt"] == "The study gathered ____ across ____ gradients."

    # And the served answer genuinely survives the deterministic anti-leakage gate.
    verdict = await AnswerVerbatimAndLengthEvaluator(required=True).evaluate(
        _section_context(), repaired, "intent_verify",
    )
    leakage = [i for i in verdict.issues if i.code == IssueCode.ANSWER_LEAKAGE]
    assert not leakage, (
        "the repaired artifact must not still leak; a repair that returns a leaking "
        f"artifact is not a repair: {[i.message for i in leakage]}"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_rejects_candidate_leaking_through_shared_stem():
    """A summary group shares one stem; an answer leaking in that stem is leaked here too.

    The per-blank prompt is `'____'`, so a candidate whose answer appears in the group's
    `sharedContext` passes a prompt-only check while still handing the student the answer.
    Group-level anti-leakage is an invariant of the group, so salvage must enforce it.
    """
    payload = _summary_section(
        [{"answer": "salinity gradients",
          "prompt": "The study gathered ____ across ____ gradients."}],
        ["delta", "oxygen minimum depth"],
        shared_context="The study gathered [1] across the salinity gradients below.",
    )

    with pytest.raises(RepairJustificationError) as excinfo:
        await _repair(payload)
    assert "no valid candidate available in pool" in str(excinfo.value)


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_rejects_sibling_duplicate_answer():
    """A candidate duplicating a sibling blank's answer violates group distinctness.

    Two blanks of one completion group must not carry the same answer. Nothing local to
    the starved slot objects to the duplicate, so the gate has to read the sibling blanks
    out of the same artifact. With no compliant member left in the pool the repair must
    fail closed rather than serve the duplicate.
    """
    payload = _summary_section(
        [{"answer": "delta", "prompt": "The study gathered ____ across ____ gradients."}],
        ["salinity gradients", "delta"],
    )

    with pytest.raises(RepairJustificationError) as excinfo:
        await _repair(payload)
    assert "no valid candidate available in pool" in str(excinfo.value), (
        "a sibling-duplicating candidate must not be served: "
        f"{excinfo.value}"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_still_fails_closed_when_no_member_is_grounded():
    """No compliant pool member => the explicit, evidence-based refusal stands.

    This is the case that must NOT be converted into a pass. The repairer's refusal --
    `RepairJustificationError` -- is correct here, so the fix must leave it exactly as
    fail-closed, and must not invent text to fill the blank.
    """
    payload = _summary_section(
        [{"answer": "invented phrase not in passage",
          "prompt": "The study gathered ____ across ____ gradients."}],
        ["salinity gradients", "delta"],
    )

    with pytest.raises(RepairJustificationError) as excinfo:
        await _repair(payload)
    message = str(excinfo.value)
    assert "no valid candidate available in pool" in message
    # Nothing was synthesised: the refusal names regeneration as the only correct path.
    assert "must regenerate via gateway" in message


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_rejects_over_length_and_ungrounded_pool_members():
    """The pre-existing grounding and length gates must still hold after the salvage fix.

    Guards against a regression where the new leakage/distinctness gates accidentally
    replaced -- rather than added to -- the original verbatim and word-count gates.
    """
    over_length = _summary_section(
        [{"answer": "across three salinity gradients in",
          "prompt": "The study gathered ____ across ____ gradients."}],
        ["delta", "core profiles"],
    )
    with pytest.raises(RepairJustificationError):
        await _repair(over_length)

    ungrounded = _summary_section(
        [{"answer": "photosynthetic capacity",
          "prompt": "The study gathered ____ across ____ gradients."}],
        ["delta", "core profiles"],
    )
    with pytest.raises(RepairJustificationError):
        await _repair(ungrounded)


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_is_idempotent_across_repeated_runs():
    """Re-running the same repair converges and never double-applies.

    Idempotency under CAS: applying the salvage twice must produce the same content hash
    and the same payload. A repair that mutated cumulatively (appending, incrementing a
    counter, appending candidates) would produce a different hash on the second run and
    corrupt the chain.
    """
    payload = _summary_section(
        [{"answer": "core profiles",
          "prompt": "The study gathered ____ across ____ gradients."}],
        ["salinity gradients", "delta"],
    )
    first = await _repair(payload)
    second = await _repair(payload)

    assert first.content_hash == second.content_hash, (
        "a repeated salvage must converge on the same content, not mutate cumulatively"
    )
    assert first.payload == second.payload
    assert len(second.payload["groups"][0]["questions"]) == 3, (
        "no question may be appended or duplicated by a repeated repair"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_salvage_preserves_unaffected_artifact_hashes():
    """Only the intended artifact chain may change; parents keep their exact hashes.

    The repair replaces the section in place as a new version. The passage and blueprint
    artifacts it depends on are not part of this repair, so their refs must be carried
    through byte-identically -- a repair that re-derived or reordered parents would
    silently rewrite lineage for artifacts it never touched.
    """
    payload = _summary_section(
        [{"answer": "core profiles",
          "prompt": "The study gathered ____ across ____ gradients."}],
        ["salinity gradients", "delta"],
    )
    repaired = await _repair(payload)

    assert repaired.parent_refs == (P, BP)
    assert P.content_hash == "b" * 64 and P.version == 1
    assert BP.content_hash == "a" * 64 and BP.version == 1
    # The new version hashes its own payload against those untouched parents.
    assert repaired.content_hash != _section_artifact(payload).content_hash
    assert repaired.verify_integrity()