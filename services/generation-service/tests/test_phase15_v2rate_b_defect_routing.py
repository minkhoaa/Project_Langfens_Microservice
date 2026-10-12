"""Phase 15 V2 repair-side regression tests (agent B / defect routing).

Scope: `app/repair/section.py` -- which item-level defect codes the section surgical
repairer is allowed to act on, and with what action.

The defect these tests pin was found on a live MiniMax preflight
(`bench_717ea80dcbf2a9d615224e01b04f6fc9`, case 1, seed 101 -- a case that passes in the
canonical campaign `camp_G15_c9750f53d6b5`), which failed three consecutive section-2
attempts with:

    Question group acceptance failed: NO_PROGRESS: identical repair output

with the same two issues recurring identically on all three attempts:

    AMBIGUOUS_ANSWER | QUESTION | OPEN | Question 20 prompt is ambiguous with conflicting interpretations
    AMBIGUOUS_ANSWER | QUESTION | OPEN | Question 21 prompt is ambiguous with conflicting interpretations

Root cause: `SectionRepairRouter.route_repair` classifies `AMBIGUOUS_ANSWER` as an item
issue and routes it to `ITEM_RESELECT`, and `SectionSurgicalRepairer` then handled it with
`rephrase_duplicate_prompt` -- a synonym-substitution rewriter written for
DUPLICATE_CONTENT. Ambiguity is a property of what the question ASKS, not of its word
choice, so the rewriter cannot resolve it. Worse, applying it repeatedly accreted
opener prefixes ("In particular, regarding this aspect, in particular, ...") instead of
converging, so the repair mutated accepted question text on every pass and resolved
nothing.

The loop's `NO_PROGRESS` verdict was TRUTHFUL and is preserved. The defect is upstream:
the repairer was handed a defect it structurally cannot fix. These tests pin the
correct routing as a general rule, with no case/seed/question-number special-casing:

* an answer-semantics defect is delegated to the question repairer, which requires
  passage-grounded evidence for a replacement answer;
* when no grounded replacement exists the correct outcome is fail-closed, NOT a
  synonym rewrite;
* the duplicate-stem rewriter runs on DUPLICATE_CONTENT only;
* a repair never touches the text of a question that is not defective.
"""

from __future__ import annotations

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.repair.base import RepairJustificationError
from app.repair.section import (
    ANSWER_SEMANTIC_ITEM_CODES,
    SectionSurgicalRepairer,
    rephrase_duplicate_prompt,
)


PASSAGE = (
    "Researchers noted that the samples were collected across a range of salinity "
    "gradients in the delta. The core profiles were gathered across three salinity "
    "gradients, and each carried a distinct sediment record. Researchers recorded the "
    "oxygen minimum depth for every core profile."
)

BP = ArtifactRef(artifactId="art_bp_1", artifactType=ArtifactType.EXAM_BLUEPRINT,
                 version=1, contentHash="a" * 64)
P = ArtifactRef(artifactId="art_passage_s2", artifactType=ArtifactType.PASSAGE,
                version=1, contentHash="b" * 64)

Q20_PROMPT = "Researchers noted that the samples were collected across a range of salinity gradients."
Q21_PROMPT = "The core profiles were gathered across three salinity gradients."
Q22_PROMPT = "Each core profile carried a distinct sediment record."


def _ambiguous(q_num):
    return Issue.create(
        issue_id=f"iss_amb_{q_num}",
        code=IssueCode.AMBIGUOUS_ANSWER,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message=f"Question {q_num} prompt is ambiguous with conflicting interpretations",
        affected_refs=[],
    )


def _duplicate(q_num):
    return Issue.create(
        issue_id=f"iss_dup_{q_num}",
        code=IssueCode.DUPLICATE_CONTENT,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message=f"Question {q_num} has identical normalized prompt to Question {q_num - 1}",
        affected_refs=[],
    )


def _section_payload(pool=None):
    return {
        "sectionId": 2,
        "passage": PASSAGE,
        "groups": [{
            "groupId": "grp_s2_1",
            "questionType": "SummaryCompletion",
            "sharedContext": "The study examined the delta margin.",
            "questions": [
                {"questionNumber": 20, "questionType": "SummaryCompletion",
                 "prompt": Q20_PROMPT, "answer": "salinity gradients",
                 **({"candidates": pool} if pool is not None else {})},
                {"questionNumber": 21, "questionType": "SummaryCompletion",
                 "prompt": Q21_PROMPT, "answer": "core profiles"},
                {"questionNumber": 22, "questionType": "SummaryCompletion",
                 "prompt": Q22_PROMPT, "answer": "sediment record"},
            ],
        }],
    }


def _section_artifact(payload, version=1):
    return ArtifactEnvelope.create(
        "art_section_s2", ArtifactType.SECTION, "run_route", payload, "2.0.0",
        version=version, section_id=2, parent_refs=[P, BP],
    )


def _context():
    return LoopContext(
        runId="run_route",
        targetArtifactId="art_section_s2",
        targetArtifactType=ArtifactType.SECTION,
        scope=IssueScope.SECTION,
        sectionId=2,
        authority=AuthorityGrant(leaseOwner=__import__("uuid").uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
        inputDependencies=(P, BP),
    )


def _questions(envelope):
    return {q["questionNumber"]: q for q in envelope.payload["groups"][0]["questions"]}


# ─────────────────────────────────────────────────────────────────────────────
# (1) The routing rule itself.
# ─────────────────────────────────────────────────────────────────────────────


def test_phase15_v2rate_b_answer_semantics_codes_exclude_prompt_wording_codes():
    """The answer-semantics set is exactly the codes a stem rewrite cannot fix.

    Pins the routing boundary as a general rule: these codes describe the ANSWER, so
    they must never be handled by a vocabulary-level stem rewriter.
    """
    assert ANSWER_SEMANTIC_ITEM_CODES == frozenset({
        IssueCode.AMBIGUOUS_ANSWER,
        IssueCode.BAD_DISTRACTOR,
        IssueCode.WORD_LIMIT_EXCEEDED,
    })
    # Wording defects stay with the section repairer.
    assert IssueCode.DUPLICATE_CONTENT not in ANSWER_SEMANTIC_ITEM_CODES
    assert IssueCode.ANSWER_LEAKAGE not in ANSWER_SEMANTIC_ITEM_CODES


@pytest.mark.asyncio
async def test_phase15_v2rate_b_ambiguous_answer_is_not_resolved_by_a_synonym_rewrite():
    """AMBIGUOUS_ANSWER must not be "fixed" by rewriting the stem's vocabulary.

    This is the live preflight shape. With no passage-grounded replacement answer
    available for the flagged question, the correct outcome is the repairer's explicit,
    evidence-based refusal -- fail closed so the loop regenerates the slot. What must
    NOT happen is a silent rewrite of the accepted stem.
    """
    artifact = _section_artifact(_section_payload())

    with pytest.raises(RepairJustificationError) as excinfo:
        await SectionSurgicalRepairer()._repair_impl(
            _context(), artifact, [_ambiguous(20), _ambiguous(21)], "intent_route", 2,
        )
    assert "20" in str(excinfo.value), (
        "the refusal must name the question it could not justify"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_ambiguous_answer_recovers_from_a_grounded_pooled_candidate():
    """When a passage-grounded replacement answer DOES exist, the defect is recoverable.

    The delegation is not merely a refusal: a pooled candidate that is verbatim in the
    passage, within the word budget, non-leaking and distinct from its siblings is
    substituted, and the ambiguous stem is replaced with that candidate's own stem.
    This is the difference between "no valid repair exists" and "the right repairer was
    never consulted".
    """
    artifact = _section_artifact(_section_payload(pool=[
        {"answer": "oxygen minimum depth",
         "prompt": "Researchers recorded the ____ for every core profile.",
         "evidenceQuote": "Researchers recorded the oxygen minimum depth for every core profile"},
    ]))

    repaired = await SectionSurgicalRepairer()._repair_impl(
        _context(), artifact, [_ambiguous(20)], "intent_route", 2,
    )

    q20 = _questions(repaired)[20]
    assert q20["answer"] == "oxygen minimum depth", (
        "a passage-grounded pooled candidate must resolve the ambiguity"
    )
    assert q20["prompt"] == "Researchers recorded the ____ for every core profile."
    # The new version must be a real, verifiable immutable version.
    assert repaired.version == 2
    assert repaired.verify_integrity()
    assert tuple(repaired.parent_refs) == (P, BP)


@pytest.mark.asyncio
async def test_phase15_v2rate_b_unrelated_repair_cycle_preserves_accepted_question_text():
    """A repair must be surgical: non-defective questions keep byte-identical text.

    Live evidence showed the ambiguity path rewriting accepted stems on every attempt.
    This asserts the exact opposite for the questions that are NOT flagged, across a
    repair cycle that does touch one question.
    """
    artifact = _section_artifact(_section_payload(pool=[
        {"answer": "oxygen minimum depth",
         "prompt": "Researchers recorded the ____ for every core profile.",
         "evidenceQuote": "Researchers recorded the oxygen minimum depth for every core profile"},
    ]))

    before = {
        num: (q["prompt"], q["answer"])
        for num, q in _questions(artifact).items()
    }

    repaired = await SectionSurgicalRepairer()._repair_impl(
        _context(), artifact, [_ambiguous(20)], "intent_route", 2,
    )

    after = _questions(repaired)
    assert (after[21]["prompt"], after[21]["answer"]) == before[21], (
        "Question 21 was not defective and must be byte-identical after the repair"
    )
    assert (after[22]["prompt"], after[22]["answer"]) == before[22], (
        "Question 22 was not defective and must be byte-identical after the repair"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_duplicate_prompt_repair_still_rewrites_the_stem():
    """DUPLICATE_CONTENT remains the rewriter's job -- the fix must not disable it.

    Guards against "fix the routing" being implemented as "refuse everything", which
    would trade one stall for another on a genuinely repairable defect.
    """
    artifact = _section_artifact(_section_payload())

    repaired = await SectionSurgicalRepairer()._repair_impl(
        _context(), artifact, [_duplicate(20)], "intent_route", 2,
    )

    q20 = _questions(repaired)[20]
    assert q20["prompt"] != Q20_PROMPT, (
        "DUPLICATE_CONTENT must still be repaired by breaking the stem overlap"
    )
    # And it must not touch the questions that were not flagged.
    assert _questions(repaired)[21]["prompt"] == Q21_PROMPT


@pytest.mark.asyncio
async def test_phase15_v2rate_b_unrepairable_ambiguity_leaves_the_artifact_untouched():
    """A refused repair must not emit a mutated artifact alongside the refusal.

    The refusal is raised, so no version is ever produced -- but assert the source
    envelope is unchanged too, so a caller that catches the refusal and retries has a
    clean starting point rather than an already-mutated stem.
    """
    artifact = _section_artifact(_section_payload())
    original_hash = artifact.content_hash
    original_prompts = {n: q["prompt"] for n, q in _questions(artifact).items()}

    with pytest.raises(RepairJustificationError):
        await SectionSurgicalRepairer()._repair_impl(
            _context(), artifact, [_ambiguous(20), _ambiguous(21)], "intent_route", 2,
        )

    assert artifact.content_hash == original_hash
    assert {n: q["prompt"] for n, q in _questions(artifact).items()} == original_prompts


# ─────────────────────────────────────────────────────────────────────────────
# (2) The rewriter itself must converge rather than accrete filler.
# ─────────────────────────────────────────────────────────────────────────────


def test_phase15_v2rate_b_stem_rewriter_converges_instead_of_accreting_openers():
    """Repeated application must be a fixed point after the first pass.

    Pre-fix, each pass prefixed another opener ("In particular, regarding this aspect,
    in particular, ...") because the old guard only checked for the single literal
    "in particular,". That mutated an accepted stem on every attempt without ever
    changing the property the repairer was supposed to fix.
    """
    original = Q20_PROMPT

    once = rephrase_duplicate_prompt(original)
    assert once != original, "the first pass must still break the overlap"

    for _ in range(5):
        assert rephrase_duplicate_prompt(once) == once, (
            "the rewriter must converge: repeated application is a no-op, not an "
            "accretion of opener prefixes"
        )
    # No stacked filler crept in.
    assert once.casefold().count("in particular,") <= 1
    assert "regarding this aspect" not in once.casefold()