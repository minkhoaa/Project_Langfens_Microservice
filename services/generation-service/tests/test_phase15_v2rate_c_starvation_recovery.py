"""Phase 15 starvation recovery: a starved SummaryCompletion slot must be SERVED.

End-to-end through the slot runtime (`SlotCandidateGeneratorAdapter`), not just the
generator boundary. Companion to `test_phase15_v2rate_b_starvation_recovery.py`,
which pins the generator behavior; this file pins the slot-runtime wiring that
turns that generator behavior into a real served slot.

Canonical failure shape (camp_G15_c9750f53d6b5, cases 8/13/14/16/18):

  * Primary dispatch for slot Q20 (SummaryCompletion, group_start_number=20,
    blank_count=7) returns a `blanks`-shape payload whose Q20 blank has an empty
    answer while siblings are valid. The primary pool for Q20 therefore has no
    usable candidate.
  * The slot runtime's starvation fallback fires and asks for ONE plain cloze
    for Q20 (`question_type=SentenceCompletion`, no group range).
  * Pre-fix the fallback passed `group_start_number=20, blank_count=7`, so the
    prompt widened to "questions 20 to 26" and the model answered in `blanks`
    shape; the generator zeroes `raw_candidates` whenever a `blanks` key is
    present, so the fallback returned an empty pool and silently no-opped.
  * Three `gen_qpool_20_*` dispatches, termination, Q21-Q26 never attempted.

This file drives the exact same shape through the slot runtime and asserts:

  1. With the post-fix single-cloze fallback, the slot is SERVED with a real,
     grounded answer that survives every correctness gate (length, verbatim
     passage membership, anti-leakage, group-distinctness).
  2. With no defensible answer at any layer, the slot still fails closed: the
     answer is empty, not invented.
  3. If the model defensively replies in `blanks` shape to the single-cloze
     fallback, the slot runtime does not silently zero out -- the fallback is
     robust to that shape because the generator's blanks branch looks up the
     slot's own blank in the payload before declaring nothing usable.
  4. Static guard: the fallback block in `app/loop/question.py` literally
     passes `group_start_number=None` and `blank_count=None`.

No generator file is modified and no other test file is touched.
"""

from __future__ import annotations

import ast
import inspect
import json as _json
from pathlib import Path
from typing import Any, Dict, List, Tuple
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.policies import (
    match_verbatim_in_passage,
    validate_answer_length,
)
from app.loop import question as question_module
from app.loop.context import AuthorityGrant, LoopContext
from app.providers.models import UsageReport


# ---------------------------------------------------------------------------
# Fixture passage: a Cambridge-style cohort study with a known 1-3 word span the
# model could legitimately supply as the answer for slot 20.
# ---------------------------------------------------------------------------

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
CLOZE_PROMPT = "The longitudinal investigation at Cambridge University spanned a duration of"


# ---------------------------------------------------------------------------
# Lifted SlotCandidateGeneratorAdapter.
#
# The class is a closure inside `QuestionCandidateLoop.run`, so we lift it via
# AST + exec so the test exercises the exact production source. The lift is
# deliberately minimal: we re-exec the class block at top level after stripping
# four leading spaces, with the closure's free variables injected by name.
# ---------------------------------------------------------------------------

def _lift_slot_adapter():
    """Extract `SlotCandidateGeneratorAdapter` from `app/loop/question.py`.

    Returns the original class object, re-bound to a top-level module so it can
    be subclassed and instantiated from a test. All closure fields (Generator
    capability interface, QuestionCandidatePool, LoopContext, etc.) are injected
    by name into the exec namespace.
    """
    src_path = Path(question_module.__file__)
    src = src_path.read_text()
    tree = ast.parse(src)

    class _Visitor(ast.NodeVisitor):
        def visit_ClassDef(self, node):
            if node.name == "SlotCandidateGeneratorAdapter":
                self.cls = node
            self.generic_visit(node)

    visitor = _Visitor()
    visitor.visit(tree)
    assert visitor.cls is not None, "SlotCandidateGeneratorAdapter not found in question.py"

    block = ast.get_source_segment(src, visitor.cls)
    # Strip 4 leading spaces from each non-empty line so the class is at top level.
    lines = block.split("\n")
    rebased = [line[4:] if line.startswith("    ") else line for line in lines]
    code = "\n".join(rebased)

    from app.contracts.artifact import ArtifactEnvelope as _Envelope, ArtifactType as _Type
    from app.generators.question.context import (
        QuestionCandidate as _Candidate,
        QuestionCandidatePool as _Pool,
    )
    from app.generators.question.prompts import (
        QUESTION_PROMPT_VERSION as _QPV,
        QuestionPromptFamily as _Family,
    )

    namespace: Dict[str, Any] = {
        "GeneratorCapability": question_module.GeneratorCapability,
        "QuestionCandidatePool": _Pool,
        "QuestionCandidate": _Candidate,
        "QuestionPromptFamily": _Family,
        "QUESTION_PROMPT_VERSION": _QPV,
        "uuid4": uuid4,
        "ArtifactEnvelope": _Envelope,
        "ArtifactType": _Type,
        "get_pool_limit_for_type": question_module.get_pool_limit_for_type,
        "LoopContext": LoopContext,
    }
    exec(code, namespace)
    return namespace["SlotCandidateGeneratorAdapter"]


SlotCandidateGeneratorAdapter = _lift_slot_adapter()


# ---------------------------------------------------------------------------
# A recording subclass that captures every kwarg dict passed into
# `_call_generate_pool` so tests can assert exactly which request shape the slot
# runtime issued (e.g. whether the starvation fallback passed group args).
# ---------------------------------------------------------------------------

class _RecordingAdapter(SlotCandidateGeneratorAdapter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.call_kwargs: List[Dict[str, Any]] = []

    async def _call_generate_pool(self, **kwargs):
        self.call_kwargs.append(dict(kwargs))
        return await super()._call_generate_pool(**kwargs)


# ---------------------------------------------------------------------------
# Fake gateway: returns a queued payload per call, capturing each call so
# tests can correlate requests and responses. Mirrors the shape used by
# `test_phase15_v2rate_b_starvation_recovery.py` but exposes a queue so a test
# can stage: "first call returns X, second call returns Y".
# ---------------------------------------------------------------------------

class _FakeResponse:
    def __init__(self, parsed_payload):
        self.parsed_payload = parsed_payload
        self.raw_text = _json.dumps(parsed_payload)
        self.provider_name = "fake"
        self.model_name = "fake-llm"
        self.usage = UsageReport(prompt_tokens=10, completion_tokens=10, total_tokens=20)
        self.duration_seconds = 0.0
        self.wall_time_seconds = 0.0


class _FakeGateway:
    def __init__(self, *queued_payloads):
        self._queue: List[Any] = list(queued_payloads)
        self.calls: List[Any] = []

    async def execute(self, req, epoch=None, lease_owner=None):
        self.calls.append(req)
        if not self._queue:
            return _FakeResponse({})
        payload = self._queue.pop(0)
        return _FakeResponse(payload)


# ---------------------------------------------------------------------------
# Test fixtures: refs + LoopContext.
# ---------------------------------------------------------------------------

def _p_ref() -> ArtifactRef:
    return ArtifactRef(
        artifactId="art_passage_s2",
        artifactType=ArtifactType.PASSAGE,
        version=1,
        contentHash="a" * 64,
    )


def _bp_ref() -> ArtifactRef:
    return ArtifactRef(
        artifactId="art_blueprint_01",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="b" * 64,
    )


def _loop_context(run_id: str = "run_phase15_v2rate_c") -> LoopContext:
    return LoopContext(
        runId=run_id,
        targetArtifactId="art_q_slot_20",
        targetArtifactType=ArtifactType.QUESTION,
        scope="QUESTION",
        sectionId=2,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        inputDependencies=(_p_ref(), _bp_ref()),
    )


def _generator(gateway):
    from app.generators.question.generator import QuestionCandidateGenerator
    return QuestionCandidateGenerator(gateway=gateway)


# ---------------------------------------------------------------------------
# Real starvation payloads.
#
# STARVED_PRIMARY_REPLY: the SummaryCompletion primary dispatch returns a
# `blanks`-shape payload whose Q20 blank has an empty answer, while siblings
# 21..23 are valid. This is exactly what the campaign produced.
#
# CANDIDATE_FALLBACK_REPLY: the starvation fallback (SentenceCompletion, no
# group args) returns a `candidates`-shape payload with a single grounded
# answer for slot 20.
# ---------------------------------------------------------------------------

STARVED_PRIMARY_REPLY = {
    "summaryText": "The Cambridge cohort work examined bilingual subjects over time.",
    "summaryTitle": "The Cambridge cohort study",
    "blanks": [
        {"index": 1, "answer": "", "evidenceQuote": ""},  # Q20 starved
        {"index": 2, "answer": "neuroimaging", "evidenceQuote": "advanced functional neuroimaging techniques"},
        {"index": 3, "answer": "hippocampus", "evidenceQuote": "prefrontal cortical connectivity"},
    ],
}

CANDIDATE_FALLBACK_REPLY = {
    "candidates": [
        {
            "prompt": CLOZE_PROMPT,
            "answer": ANSWER,
            "evidenceQuote": QUOTE,
            "explanation": "The study spanned seven years.",
        }
    ],
}


def _run_slot(
    *,
    primary_reply: Dict[str, Any],
    fallback_reply: Dict[str, Any],
    group_start_num: int = 20,
    blank_count: int = 7,
) -> Tuple[_RecordingAdapter, _FakeGateway]:
    gateway = _FakeGateway(primary_reply, fallback_reply)
    adapter = _RecordingAdapter(
        slot_generator=_generator(gateway),
        q_num=20,
        q_type="SummaryCompletion",
        passage_text=PASSAGE_TEXT,
        p_ref=_p_ref(),
        bp_ref=_bp_ref(),
        group_start_num=group_start_num,
        blank_count=blank_count,
        group_cache={},
    )
    return adapter, gateway


# ---------------------------------------------------------------------------
# THE FIX: drives the real starvation shape through the slot runtime and
# asserts the slot is SERVED with a real, grounded candidate.
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_phase15_v2rate_c_slot_runtime_recovers_starved_q20_via_single_cloze_fallback():
    """End-to-end through the slot runtime: starved Q20 is SERVED.

    The primary SummaryCompletion call returns the canonical starved `blanks`
    payload (Q20 empty, siblings valid). The slot's primary pool therefore has
    no usable candidate for Q20. The slot runtime MUST fire its starvation
    fallback, which:

      * requests a single cloze for slot 20 (`question_type=SentenceCompletion`),
      * passes `group_start_number=None` and `blank_count=None` (no group
        widening -- this is the proven attack on the defect),
      * accepts the model's `candidates`-shape reply and SERVES the slot with
        the grounded answer.

    Asserting "call count == 2" pins that the fallback actually fired (the
    pre-fix silent no-op produced three identical failed primary dispatches
    and never reached the fallback's serving path).
    """
    adapter, gateway = _run_slot(
        primary_reply=STARVED_PRIMARY_REPLY,
        fallback_reply=CANDIDATE_FALLBACK_REPLY,
    )
    env: ArtifactEnvelope = await adapter.generate(_loop_context(), "intent_fallback", version=1)

    # 1. The fallback actually fired (call count: 1 primary + 1 fallback = 2).
    assert len(gateway.calls) == 2, (
        f"expected primary + starvation-fallback (2 calls), got {len(gateway.calls)} "
        "-- the fallback must fire when the SummaryCompletion pool is starved"
    )

    # 2. The primary dispatch was a SummaryCompletion request WITH the group range.
    primary_kwargs = adapter.call_kwargs[0]
    assert primary_kwargs["question_type"] == "SummaryCompletion"
    assert primary_kwargs["group_start_number"] == 20
    assert primary_kwargs["blank_count"] == 7

    # 3. The starvation fallback dropped the group range and asked for ONE cloze.
    fallback_kwargs = adapter.call_kwargs[1]
    assert fallback_kwargs["question_type"] == "SentenceCompletion", (
        "the starvation fallback must ask for a single SentenceCompletion, not a group"
    )
    assert fallback_kwargs.get("group_start_number") is None, (
        "the starvation fallback must omit group_start_number to avoid widening the prompt"
    )
    assert fallback_kwargs.get("blank_count") is None, (
        "the starvation fallback must omit blank_count to avoid widening the prompt"
    )

    # 4. The slot is SERVED with the model's grounded answer (not empty).
    payload = env.payload
    assert str(payload["answer"]).strip() == ANSWER, (
        f"the starved slot must receive the model's grounded answer, got "
        f"answer={payload['answer']!r}"
    )

    # 5. Every correctness gate the recovery must still satisfy.
    assert str(payload["prompt"]).strip(), "served candidate must carry a prompt"
    assert validate_answer_length(ANSWER), "answer must respect the 3-word limit"
    assert match_verbatim_in_passage(ANSWER, PASSAGE_TEXT), (
        "recovered answer must be verbatim-grounded in the passage"
    )
    assert ANSWER.lower() not in str(payload["prompt"]).lower(), (
        "recovered answer must not leak into its own prompt"
    )

    # 6. Slot identity preserved (no sibling-slot borrow).
    assert payload["questionNumber"] == 20
    assert payload["questionType"] == "SummaryCompletion"
    served_answers = [
        str(c.get("answer") or "").strip()
        for c in (payload.get("candidates") or [])
    ]
    assert ANSWER in served_answers
    assert "neuroimaging" not in served_answers, (
        "the starvation fallback must not borrow a sibling slot's answer"
    )


# ---------------------------------------------------------------------------
# Fail-closed companion: with nothing defensible, the slot stays empty rather
# than inventing an answer. The pre-fix silent no-op also returned an empty
# pool -- but it did so by mis-parsing a `blanks`-shape reply, not by failing
# closed. The post-fix path must still fail closed when the fallback itself
# yields nothing usable.
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_phase15_v2rate_c_slot_runtime_fails_closed_when_fallback_has_no_defensible_answer():
    """No defensible answer at any layer -> answer is empty, not invented."""
    adapter, gateway = _run_slot(
        primary_reply=STARVED_PRIMARY_REPLY,
        fallback_reply={"candidates": []},
    )
    env: ArtifactEnvelope = await adapter.generate(_loop_context(), "intent_fallback", version=1)

    # The fallback fired (call count == 2), but with no usable answer.
    assert len(gateway.calls) == 2
    assert adapter.call_kwargs[1]["question_type"] == "SentenceCompletion"

    payload = env.payload
    assert str(payload["answer"]).strip() == "", (
        f"with no defensible answer the slot must stay empty and fail closed; "
        f"got answer={payload['answer']!r}"
    )

    # No fabricated candidates either.
    served_answers = [
        str(c.get("answer") or "").strip()
        for c in (payload.get("candidates") or [])
    ]
    assert all(not a for a in served_answers), (
        f"no candidate may carry a non-empty answer; got {served_answers}"
    )


# ---------------------------------------------------------------------------
# Defensive guard from option (b): if the model STILL answers in `blanks`
# shape to the SentenceCompletion fallback (a defensive response from the LLM
# to the summary context), the slot runtime must not silently zero out. The
# generator's blanks branch looks up the slot's own blank via `_orig_index`
# matching; if the slot's blank is present and usable, it is served; if not,
# the slot fails closed -- it is never silently empty.
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_phase15_v2rate_c_fallback_handles_blanks_shaped_reply_without_silent_zeroing():
    """A blanks-shape reply to the SentenceCompletion fallback must not be silently zeroed.

    Option (a) stops the prompt from *inviting* a `blanks`-shaped reply. It cannot
    guarantee the model complies: an LLM asked for one cloze inside a summary
    context can still answer in group shape. Option (b) is the second line of
    defence -- the fallback must not be silently zeroed when the reply does carry
    a defensible blank for this exact slot.

    Here the model answers the per-slot fallback in `blanks` shape with a slot-20
    blank whose answer ("seven-year") is a valid 1-word verbatim passage span,
    non-leaking, and distinct from the answers the group already accepted. That
    blank was supplied by the model AS the answer for this slot, so it is a
    legitimate recovery source. The slot must be SERVED with it rather than
    silently emptied.
    """
    blanks_fallback_reply = {
        "summaryText": "The Cambridge cohort work examined bilingual subjects over time.",
        "summaryTitle": "The Cambridge cohort study",
        "blanks": [
            {
                "number": 20,
                "placeholder": "[1]",
                "answer": ANSWER,
                "evidenceQuote": QUOTE,
            },
        ],
    }
    adapter, gateway = _run_slot(
        primary_reply=STARVED_PRIMARY_REPLY,
        fallback_reply=blanks_fallback_reply,
    )
    env: ArtifactEnvelope = await adapter.generate(_loop_context(), "intent_fallback", version=1)

    # The fallback fired.
    assert len(gateway.calls) == 2
    assert adapter.call_kwargs[1]["question_type"] == "SentenceCompletion"

    # NOT silently zeroed: the slot is served with the model's own blank answer.
    payload = env.payload
    assert str(payload["answer"]).strip() == ANSWER, (
        "a blanks-shape reply carrying a defensible blank for this slot must be "
        f"honoured, not silently zeroed; got answer={payload['answer']!r}"
    )
    assert validate_answer_length(ANSWER)
    assert match_verbatim_in_passage(ANSWER, PASSAGE_TEXT)
    assert ANSWER.lower() not in str(payload["prompt"]).lower()


@pytest.mark.asyncio
async def test_phase15_v2rate_c_recovered_answer_must_be_distinct_from_sibling_blanks():
    """Group distinctness is a correctness gate the recovery must still satisfy.

    The starved slot's fallback is a PER-SLOT request: the model never saw its
    siblings, so a recovered answer can collide with an answer this same group
    already accepted. Two blanks of one summary carrying the same answer is a
    real defect, so the recovery must drop the colliding candidate and fail
    closed rather than serve a duplicate.

    Pre-fix this served `neuroimaging` for Q20 while Q21 in the same group had
    already been given `neuroimaging`.
    """
    adapter, gateway = _run_slot(
        primary_reply=STARVED_PRIMARY_REPLY,
        fallback_reply={
            "candidates": [
                {
                    "prompt": "The experimental framework deployed advanced",
                    "answer": "neuroimaging",  # duplicates sibling Q21's kept answer
                    "evidenceQuote": "The experimental framework deployed advanced functional neuroimaging techniques.",
                    "explanation": "The framework used neuroimaging to study the cohort.",
                }
            ]
        },
    )
    env: ArtifactEnvelope = await adapter.generate(_loop_context(), "intent_fallback", version=1)

    # The sibling blank survived the primary dispatch, so the distinctness budget
    # is real: Q21 holds "neuroimaging".
    kept = [
        str(b.get("answer") or "").strip()
        for b in (adapter._group_cache.get("summary_parsed") or {}).get("blanks", [])
    ]
    assert kept == ["neuroimaging"], f"expected the sibling blank to survive, got {kept}"

    # The colliding recovery must NOT be served.
    payload = env.payload
    assert str(payload["answer"]).strip() == "", (
        "a recovered answer duplicating a sibling blank must be rejected, not "
        f"served; got answer={payload['answer']!r}"
    )
    served_answers = [
        str(c.get("answer") or "").strip() for c in (payload.get("candidates") or [])
    ]
    assert all(not a for a in served_answers), (
        f"no candidate may carry a group-duplicate answer; got {served_answers}"
    )


@pytest.mark.asyncio
async def test_phase15_v2rate_c_recovery_never_invents_an_answer_from_evidence_text():
    """The starved blank's evidenceQuote must never be mined for an answer.

    This is the explicit constraint on this work: the evidenceQuote identifies the
    source SENTENCE, not which words fill that cloze. A mined span satisfies every
    mechanical gate (verbatim, 1-3 words, non-leaking, distinct) and is still
    semantically wrong. Recovery must come only from text the model supplied AS
    the answer, or a properly regenerated single-cloze answer.

    Driven through the slot runtime: a starved blank whose evidenceQuote is a long
    verbatim passage sentence, with the fallback offering nothing usable.
    """
    starved_with_quotable_sentence = {
        "summaryText": "The Cambridge cohort work examined bilingual subjects over time.",
        "summaryTitle": "The Cambridge cohort study",
        "blanks": [
            {
                "index": 1,
                "answer": "",
                # A long, quotable, fully-verbatim sentence: the ideal source for a
                # fabricated span. Mining it must not happen.
                "evidenceQuote": (
                    "conducted a seven-year longitudinal cohort study involving "
                    "more than eight hundred bilingual subjects"
                ),
            },
            {"index": 2, "answer": "neuroimaging", "evidenceQuote": "advanced functional neuroimaging techniques"},
        ],
    }
    adapter, gateway = _run_slot(
        primary_reply=starved_with_quotable_sentence,
        fallback_reply={"candidates": []},
    )
    env: ArtifactEnvelope = await adapter.generate(_loop_context(), "intent_fallback", version=1)

    payload = env.payload
    assert str(payload["answer"]).strip() == "", (
        "no answer may be synthesised from evidence text; got "
        f"answer={payload['answer']!r}"
    )
    # Explicitly: nothing pulled out of the quoted sentence.
    for mined in ("seven-year", "longitudinal", "cohort study", "bilingual subjects"):
        assert str(payload["answer"]).strip() != mined
        served_answers = [
            str(c.get("answer") or "").strip() for c in (payload.get("candidates") or [])
        ]
        assert mined not in served_answers


@pytest.mark.asyncio
async def test_phase15_v2rate_c_distinctness_gate_does_not_fire_without_group_evidence():
    """The distinctness gate must not manufacture a constraint it cannot support.

    The gate reads the answers this group has already accepted. If no sibling
    blank survived the primary dispatch, the group cache is empty and there is no
    evidence for a collision -- the recovered answer must be served, not rejected
    on a constraint the loop cannot justify. A gate that over-rejects would
    convert the starvation defect into a permanent failure for the first slot of
    a group whose siblings were all dropped.
    """
    all_siblings_dropped = {
        "summaryText": "The Cambridge cohort work examined bilingual subjects over time.",
        "summaryTitle": "The Cambridge cohort study",
        "blanks": [
            {"index": 1, "answer": "", "evidenceQuote": ""},  # Q20 starved
            {"index": 2, "answer": "", "evidenceQuote": ""},  # Q21 also dropped
            {"index": 3, "answer": "", "evidenceQuote": ""},  # Q22 also dropped
        ],
    }
    adapter, gateway = _run_slot(
        primary_reply=all_siblings_dropped,
        fallback_reply=CANDIDATE_FALLBACK_REPLY,
    )
    env: ArtifactEnvelope = await adapter.generate(_loop_context(), "intent_fallback", version=1)

    # No sibling evidence -> the gate must not reject the recovered answer.
    assert adapter._group_answers_already_used() == set(), (
        "with no surviving sibling blanks there is no distinctness budget"
    )
    assert str(env.payload["answer"]).strip() == ANSWER, (
        "the gate must not over-reject a defensible recovered answer; got "
        f"answer={env.payload['answer']!r}"
    )


# ---------------------------------------------------------------------------
# Static guard: the starvation fallback in `app/loop/question.py` literally
# passes `group_start_number=None` and `blank_count=None`. Keeps the fix from
# silently regressing back to the group-range request shape.
# ---------------------------------------------------------------------------

def test_phase15_v2rate_c_fallback_source_omits_group_range():
    """Static guard: the starvation fallback source must omit group args."""
    src = inspect.getsource(question_module)
    anchor = "fallback_pool = await self._call_generate_pool("
    assert anchor in src, "expected the starvation fallback call site to exist"
    start = src.index(anchor)
    window = src[start : start + 2400]
    assert 'question_type="SentenceCompletion"' in window, (
        "the starvation fallback must request a single SentenceCompletion, "
        "not a SummaryCompletion group"
    )
    assert "group_start_number=None" in window, (
        "the starvation fallback must pass `group_start_number=None` so the "
        "prompt is a single cloze, not a group range"
    )
    assert "blank_count=None" in window, (
        "the starvation fallback must pass `blank_count=None` so the prompt "
        "is a single cloze, not a group range"
    )
    # The provenance comment must stay attached so the mechanism is not re-broken.
    assert "P15 starvation recovery" in window