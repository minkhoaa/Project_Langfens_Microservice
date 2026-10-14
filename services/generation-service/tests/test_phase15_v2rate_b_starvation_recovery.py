"""Phase 15 starvation recovery: a starved SummaryCompletion slot must be SERVED.

Primary evidence for the Q20 group (cases 8/13/14/16/18). Deliberately NOT satisfied by
"terminates with a better reason" -- the assertion is that a real, grounded answer is
produced for the starved slot.

Canonical failure shape (camp_G15_c9750f53d6b5): the SummaryCompletion group Q20-Q26
returns with slot 20 unusable. The slot runtime then requests a fallback candidate.
Pre-fix that fallback carried `group_start_number=20, blank_count=7`, widening the
prompt to "questions 20 to 26" and inviting a `blanks`-shaped reply. In
`app/generators/question/generator.py` any `blanks`-shaped payload zeroes
`raw_candidates`, so the fallback returned an empty pool and silently no-opped:
three `gen_qpool_20_*` dispatches, termination, Q21-Q26 never attempted.

The fix is in `app/loop/question.py` (the starvation fallback now omits the
group-range arguments so it requests ONE plain cloze). These tests pin the generator
boundary that makes that fix effective, using a deterministic fake gateway so the
exact blank-only reply shape is exercised. No generator file is modified.
"""

from __future__ import annotations

from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.policies import match_verbatim_in_passage


PASSAGE_TEXT = (
    "Researchers at Cambridge University conducted a seven-year longitudinal cohort "
    "study involving more than eight hundred bilingual subjects. "
    "The experimental framework deployed advanced functional neuroimaging techniques. "
    "Primary analytical findings revealed that early acquisition of a secondary "
    "language reinforces prefrontal cortical connectivity."
)

ANSWER = "seven-year"
QUOTE = (
    "conducted a seven-year longitudinal cohort study involving more than eight "
    "hundred bilingual subjects"
)
PROMPT = "The longitudinal investigation at Cambridge University spanned a duration of"


def _p_ref() -> ArtifactRef:
    return ArtifactRef(
        artifactId="art_passage_s2", artifactType=ArtifactType.PASSAGE,
        version=1, contentHash="a" * 64,
    )


def _bp_ref() -> ArtifactRef:
    return ArtifactRef(
        artifactId="art_blueprint_01", artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1, contentHash="b" * 64,
    )


class _FakeUsage:
    total_tokens = 0
    prompt_tokens = 0
    completion_tokens = 0


class _FakeResponse:
    provider_name = "minimax"
    model_name = "MiniMax-Text-01"

    def __init__(self, parsed_payload):
        self.parsed_payload = parsed_payload
        self.raw_text = "{}"
        self.usage = _FakeUsage()
        self.wall_time_seconds = 0.0


class _FakeGateway:
    """Deterministic gateway: replays a fixed parsed payload for every call."""

    def __init__(self, parsed_payload):
        self.parsed_payload = parsed_payload
        self.calls: list[dict] = []

    async def execute(self, req, epoch=None, lease_owner=None):
        self.calls.append({"req": req})
        return _FakeResponse(self.parsed_payload)


async def _generate(gateway, *, question_type, question_number,
                    group_start_number=None, blank_count=None):
    from app.generators.question.generator import QuestionCandidateGenerator
    from app.loop.context import AuthorityGrant, LoopContext

    # A real LoopContext is required: passing None makes generate_candidate_pool take
    # its offline mock path and ignore the gateway entirely.
    ctx = LoopContext(
        runId="run_starvation",
        targetArtifactId="art_q_slot_20",
        targetArtifactType=ArtifactType.QUESTION,
        scope="QUESTION",
        sectionId=2,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        inputDependencies=(_p_ref(), _bp_ref()),
    )
    gen = QuestionCandidateGenerator(gateway=gateway)
    return await gen.generate_candidate_pool(
        passage_text=PASSAGE_TEXT,
        question_type=question_type,
        question_number=question_number,
        passage_ref=_p_ref(),
        blueprint_ref=_bp_ref(),
        run_id="run_starvation",
        section_id="2",
        context=ctx,
        parent_operation_id="intent_fallback",
        group_start_number=group_start_number,
        blank_count=blank_count,
    )


# The exact reply shape that starved slot 20 in the canonical campaign: a summary
# group payload whose slot-20 blank is unusable/absent.
BLANK_ONLY_REPLY = {
    "summaryText": "The Cambridge cohort work examined bilingual subjects over time.",
    "summaryTitle": "The Cambridge cohort study",
    "blanks": [
        {"index": 1, "answer": "seven-year", "evidenceQuote": QUOTE},
        {"index": 2, "answer": "neuroimaging", "evidenceQuote": "advanced functional neuroimaging techniques"},
        {"index": 3, "answer": "hippocampus", "evidenceQuote": "prefrontal cortical connectivity"},
    ],
}

CANDIDATE_REPLY = {
    "candidates": [
        {
            "prompt": PROMPT,
            "answer": ANSWER,
            "evidenceQuote": QUOTE,
            "explanation": "The study spanned seven years.",
        }
    ]
}


# The true starvation shape for slot 20: Q20's own blank is unusable (empty answer)
# while the sibling blanks of the same group are perfectly valid. This is what the
# canonical campaign produced for cases 8/13/14/16/18.
STARVED_SLOT_REPLY = {
    "summaryText": "The Cambridge cohort work examined bilingual subjects over time.",
    "summaryTitle": "The Cambridge cohort study",
    "blanks": [
        {"index": 1, "answer": "", "evidenceQuote": ""},          # Q20 starved
        {"index": 2, "answer": "neuroimaging", "evidenceQuote": "advanced functional neuroimaging techniques"},
        {"index": 3, "answer": "hippocampus", "evidenceQuote": "prefrontal cortical connectivity"},
    ],
}


@pytest.mark.asyncio
async def test_phase15_v2rate_b_starved_blank_yields_no_slot_candidate_and_recovers_via_single_cloze():
    """REGRESSION + FIX on the exact starvation shape, end to end through the generator.

    Step 1 (the defect): with the group-range request the fallback used pre-fix, the
    starved Q20 blank produces NO usable candidate for slot 20 -- the silent no-op that
    produced three `gen_qpool_20_*` dispatches and left Q21-Q26 unattempted.

    Step 2 (the fix): the same starved group, requested as a single plain cloze, is
    served a real grounded candidate, so the slot is SERVED rather than empty.
    """
    starved_gateway = _FakeGateway(STARVED_SLOT_REPLY)
    starved_pool = await _generate(
        starved_gateway,
        question_type="SentenceCompletion",
        question_number=20,
        group_start_number=20,   # pre-fix fallback request
        blank_count=7,
    )
    starved_answers = [str(c.answer or "").strip() for c in starved_pool.candidates]
    assert not starved_answers, (
        "expected the group-range request on a starved slot to yield no usable "
        f"candidate (this is the defect), got {starved_answers}"
    )

    # Step 2: the post-fix request shape must recover the slot.
    cloze_gateway = _FakeGateway(CANDIDATE_REPLY)
    cloze_pool = await _generate(
        cloze_gateway,
        question_type="SentenceCompletion",
        question_number=20,
        group_start_number=None,  # post-fix fallback request
        blank_count=None,
    )
    served = [str(c.answer or "").strip() for c in cloze_pool.candidates]
    assert served, "the starved slot must receive a usable candidate"
    assert ANSWER in served, f"expected the grounded answer, got {served}"


@pytest.mark.asyncio
async def test_phase15_v2rate_b_single_cloze_request_serves_the_starved_slot():
    """THE FIX: without the group range, the same reply shape serves slot 20.

    A candidates-shaped reply for a single cloze produces a real, grounded answer --
    the starved slot is SERVED rather than left empty.
    """
    gateway = _FakeGateway(CANDIDATE_REPLY)
    pool = await _generate(
        gateway,
        question_type="SentenceCompletion",
        question_number=20,
        group_start_number=None,  # post-fix fallback behaviour
        blank_count=None,
    )
    answers = [str(c.answer or "").strip() for c in pool.candidates]
    assert answers, "the starved slot must receive a usable candidate"
    assert ANSWER in answers, f"expected the grounded answer, got {answers}"

    served = next(c for c in pool.candidates if str(c.answer).strip() == ANSWER)
    # Every correctness gate the recovery must still satisfy.
    assert served.prompt, "served candidate must carry a prompt"
    assert len(ANSWER.split()) <= 3, "answer must respect the 3-word limit"
    assert match_verbatim_in_passage(ANSWER, PASSAGE_TEXT), (
        "recovered answer must still be verbatim-grounded in the passage"
    )
    assert ANSWER.lower() not in served.prompt.lower(), (
        "recovered answer must not leak into its own prompt"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_b_starvation_recovery_still_fails_closed_without_a_defensible_answer():
    """Recovery is not a licence to invent. With nothing usable, no answer is served."""
    gateway = _FakeGateway({"candidates": []})
    pool = await _generate(
        gateway,
        question_type="SentenceCompletion",
        question_number=20,
        group_start_number=None,
        blank_count=None,
    )
    assert not [c for c in pool.candidates if str(c.answer or "").strip()], (
        "with no defensible answer the slot must stay empty and fail closed"
    )


def test_phase15_v2rate_b_starvation_fallback_source_omits_group_range():
    """Static guard: the starvation fallback in the loop must not pass group args.

    Keeps the fix from silently regressing back to the group-range request.
    """
    import inspect

    from app.loop import question as q

    src = inspect.getsource(q)
    start = src.index("P15 starvation recovery")
    window = src[start : start + 1200]
    assert "group_start_number=None" in window, (
        "the starvation fallback must request a single cloze, not a group range"
    )
    assert "blank_count=None" in window, (
        "the starvation fallback must not request a multi-blank group"
    )