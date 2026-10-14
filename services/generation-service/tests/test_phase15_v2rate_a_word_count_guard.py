"""Behavioural regression tests for the passage word-count guard (Agent A, case 15).

Case 15 (`camp_G15_dde0f9bd38d4` / `bench_b434b376a12e4439e3a9e6a19f3133a2`,
seed 303) terminated with:

    MAX_VERSIONS: 1 exact-target blockers; final version slot redirected from
    repair to regeneration because repair has not resolved the blocker set;
    immutable version cap reached

Its issue ledger records four SECTION_WORD_COUNT_OUT_OF_BOUNDS entries: 921
(over by 6), 660 (under by 60), 682 (under by 38), and a final 682 (under by 38)
that closed the case. Two prior repairs had already resolved two earlier
out-of-band drafts in the same paper, so the remaining immutable version slot
landed on a single OPEN word-count blocker that one more re-ask could not have
fixed inside the cap.

The *implementation* defect these tests pin is narrower than the failure mode.
Prompt constraint 1 in `app/generators/passage/prompts.py` already states
"Word count MUST be between 720 and 915 words (target 780-840 words; aim for
~800 words)", but the generator had no way to make that verifiable at
generation time. Every drift therefore *consumed* a whole artifact version --
either a repair ran out of headroom trying to extend a 682-word draft, or a
regeneration ran out of headroom trying to trim a 921-word draft. The generator
now derives the band invariant deterministically and buys one grounded re-ask
*inside the version already being spent*.

Explicitly NOT done, and pinned shut below:
  * no prose mutation. Truncating or padding to force length would be synthesis
    and would fabricate a different claim, so the guard never edits model output.
  * no relaxed evaluator. When the re-ask is refused the artifact is returned
    unchanged and the validator still fails it closed, exactly as before.
  * no cap raised. The guard's re-ask bound is a generator-internal constant and
    is not one of the loop policy caps (max_versions / max_generated_versions /
    max_total_repairs); QUANTITY_GUARD_MAX_RETRIES uses the same posture.
  * no truncation/clamp/pad. Out-of-band drafts are re-generated, never clamped.

Tests (a)-(d) below assert only observable generator behaviour (how many provider
calls were made, what was returned, what the next prompt looked like), so they
fail on real assertions against the pre-fix generator rather than on a missing
import.

All fixtures are authored here: no held-out corpus, no live provider, no network.
"""

from __future__ import annotations

import json
from typing import Any, List, Optional

import pytest

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.policies import (
    PASSAGE_MAX_WORDS as POLICY_PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS as POLICY_PASSAGE_MIN_WORDS,
)
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.providers.models import ProviderRequest, ProviderResponse, UsageReport


# The guard re-asks at most this many times per artifact draft. This is a
# generator-internal bound, deliberately tiny, and is NOT one of the loop policy
# caps. It mirrors QUANTITY_GUARD_MAX_RETRIES in posture.
EXPECTED_MAX_REASKS = 1

# The IELTS Academic canonical band comes from app.contracts.policies; pin it
# here so the tests catch a regression that loosens the bound instead of going
# through policies again. If policies.py is ever widened, that is a separate
# discussion.
WORD_COUNT_BAND_MIN = 720
WORD_COUNT_BAND_MAX = 915

assert WORD_COUNT_BAND_MIN == POLICY_PASSAGE_MIN_WORDS
assert WORD_COUNT_BAND_MAX == POLICY_PASSAGE_MAX_WORDS


# A neutral source that yields no invented quantities under the canonical matcher
# -- each draft below is "lorem ipsum"-style prose, so the quantity guard never
# fires and the word-count guard is the only invariant under test.
SOURCE_TEXT = " ".join(
    [
        "Source-style",
        "academic",
        "prose",
        "describing",
        "a",
        "long-running",
        "field",
        "study",
        "with",
        "thorough",
        "methodology",
        "and",
        "careful",
        "controls",
        "across",
        "multiple",
        "sites",
        "and",
        "time",
        "windows",
    ]
    * 12
)


def _make_refs() -> tuple[ArtifactRef, ArtifactRef]:
    return (
        ArtifactRef(
            artifactId="art_bp_wc",
            version=1,
            artifactType=ArtifactType.EXAM_BLUEPRINT,
            contentHash="1" * 64,
        ),
        ArtifactRef(
            artifactId="art_eg_wc",
            version=1,
            artifactType=ArtifactType.EVIDENCE_GRAPH,
            contentHash="2" * 64,
        ),
    )


class _ScriptedGateway:
    """Replays a fixed script of raw responses, one per call, recording every request."""

    def __init__(self, responses: List[str]):
        self._responses = list(responses)
        self.requests: List[ProviderRequest] = []

    async def execute(
        self, req: ProviderRequest, epoch: int = 1, lease_owner: Optional[Any] = None
    ) -> ProviderResponse:
        self.requests.append(req)
        raw = self._responses[min(len(self.requests) - 1, len(self._responses) - 1)]
        return ProviderResponse(
            operation_id=req.operation_id,
            provider_name="stub",
            model_name="stub-model",
            raw_text=raw,
            usage=UsageReport(prompt_tokens=100, completion_tokens=200, total_tokens=300),
            latency_seconds=0.01,
        )


def _payload(passage: str) -> str:
    return json.dumps(
        {
            "title": "Word Count Drift",
            "passage": passage,
            "styleProfile": "EXPOSITORY_SCIENTIFIC",
        }
    )


def _context(source_text: str = SOURCE_TEXT) -> PassageGenerationContext:
    bp_ref, eg_ref = _make_refs()
    return PassageGenerationContext(
        blueprintRef=bp_ref,
        evidenceGraphRef=eg_ref,
        sectionIndex=2,
        topic="Word Count Drift",
        sourceText=source_text,
    )


def _make_passage(words: int) -> str:
    """Build a deterministic passage whose canonical word count is exactly `words`."""
    return " ".join(["lorem"] * words)


# Production defect shape: undershot (682 < 720). The 660 and 673 measurements
# in the campaign fall in the same undershoot band; 682 was the OPEN blocker.
SHORT_PASSAGE_682 = _make_passage(682)
# An in-band response so the re-ask lands cleanly inside the band.
IN_BAND_PASSAGE_800 = _make_passage(800)
# A second undershot response so a re-ask is refused; the draft is returned
# UNCHANGED so the validator still fails it closed (no clamp / no synthesis).
ALSO_SHORT_700 = _make_passage(700)
# Production defect shape: overshot (921 > 915). 921 was the first OPEN blocker
# in this paper, the only overshoot in the campaign.
LONG_PASSAGE_921 = _make_passage(921)


# ── (a) out-of-band draft triggers exactly one re-ask, in-band second draft used ─

@pytest.mark.asyncio
async def test_out_of_band_draft_triggers_exactly_one_reask_and_in_band_draft_is_used():
    """An undershot draft is re-asked once with the actual count and the floor named,
    and the in-band second draft is returned -- so the artifact version budget is
    spent once, not twice, and the unfixable drift is no longer paper-fatal.

    This is the case-15 fix shape. Before the guard, the 682-word draft was
    returned verbatim, the version was consumed by SECTION_WORD_COUNT_OUT_OF_BOUNDS,
    and the paper died holding a single OPEN word-count blocker.
    """
    gw = _ScriptedGateway([_payload(SHORT_PASSAGE_682), _payload(IN_BAND_PASSAGE_800)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_wc_a", version=1)

    # Exactly two provider calls: the original draft plus one grounded re-ask.
    assert len(gw.requests) == 1 + EXPECTED_MAX_REASKS

    # The re-ask names the ACTUAL measured count (682), the band floor (720),
    # and the deficit explicitly, so the model is told what actually failed.
    reask_prompt = gw.requests[1].messages[1].content
    assert "682" in reask_prompt
    assert str(WORD_COUNT_BAND_MIN) in reask_prompt
    assert "deficit" in reask_prompt

    # The returned draft is the in-band re-ask -- not the first draft, no clamp,
    # no padding. The producer never edits model output.
    assert env.payload["passage"] == IN_BAND_PASSAGE_800
    assert env.payload["wordCount"] == WORD_COUNT_BAND_MIN + 80

    # Audit trail mirrors the quantity guard's pattern -- the field exists and is
    # truthful, it grants no pass and relaxes nothing.
    assert env.payload.get("wordCountGuardReasks") == EXPECTED_MAX_REASKS

    # The artifact still reports version 1: the re-ask never consumed a version.
    assert env.version == 1


# ── (b) in-band draft costs exactly one provider call -- guard is not a tax ───

@pytest.mark.asyncio
async def test_in_band_draft_costs_exactly_one_provider_call():
    """A draft already in band costs exactly one provider call. The guard is a
    recovery chance, not a tax on every artifact.

    Regression guard: if a future change ever makes the guard fire
    indiscriminately, the silent re-ask would double the per-artifact cost on
    every passage. This test catches that by asserting both the call count and
    the absence of length-feedback prose in the (only) prompt.
    """
    gw = _ScriptedGateway([_payload(IN_BAND_PASSAGE_800)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_wc_b", version=1)

    assert len(gw.requests) == 1
    assert env.payload.get("wordCountGuardReasks") == 0
    assert env.payload["passage"] == IN_BAND_PASSAGE_800

    # The single prompt contains no length-guard prose and no count literal of
    # an out-of-band draft. (Band literals 720/915 may still appear from the
    # prompt's own constraint 1; the test pins absence of the *guard* signal.)
    only_prompt = gw.requests[0].messages[1].content
    assert "LENGTH GUARD" not in only_prompt


# ── (c) persistently out-of-band draft stops after exactly one re-ask ─────────

@pytest.mark.asyncio
async def test_persistently_out_of_band_draft_stops_after_exactly_one_reask():
    """When the re-ask is also out-of-band, the guard stops after exactly one
    re-ask and surfaces the second draft UNCHANGED for the validator.

    The guard is a recovery chance, not an authority. It must not pad a short
    draft (that is synthesis and would fabricate unsupported content), and it
    must not convert a refused draft into an accepted one. The authoritative
    verdict stays with the validators, which still fail this artifact closed.
    """
    gw = _ScriptedGateway([_payload(SHORT_PASSAGE_682), _payload(ALSO_SHORT_700)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_wc_c", version=1)

    # Bounded: the guard re-asks exactly once and never again. This is also the
    # contract pin against accidentally growing the budget later.
    assert EXPECTED_MAX_REASKS == 1
    assert len(gw.requests) == 1 + EXPECTED_MAX_REASKS

    # The re-ask prompt names the FIRST draft's measured count (682) and the
    # band floor (720) so the second chance is precise.
    reask_prompt = gw.requests[1].messages[1].content
    assert "682" in reask_prompt
    assert str(WORD_COUNT_BAND_MIN) in reask_prompt

    # No synthesis, no clamp, no pad: the returned draft is byte-identical to
    # what the model produced on its second attempt. The ungrounded word count
    # is recorded as an audit signal so attribution stays truthful -- parallel
    # to `ungroundedNumericTokens` for the quantity guard.
    assert env.payload["passage"] == ALSO_SHORT_700
    assert env.payload["wordCount"] == 700
    assert env.payload.get("wordCountGuardReasks") == EXPECTED_MAX_REASKS


# ── (d) the count used is the canonical validator count ──────────────────────

def test_count_used_is_canonical_validator_count():
    """The guard measures with the SAME `count_words` rule the validators use.

    If the guard invented a second counting rule it could "pass" a draft that
    the validator still rejects, or worse, refuse one the validator would have
    accepted -- silently moving the band. This test pins that the helper under
    test calls the canonical implementation and agrees with the validator's
    count at every boundary.

    Boundaries exercised: 719 (just under floor), 720 (floor), 800 (middle),
    915 (ceiling), 916 (just over ceiling). The canonical count of each
    fixture is exactly `n`; the guard's helper must match.
    """
    from app.contracts.policies import count_words as canonical_count_words
    from app.generators.passage.generator import _measure_passage_words

    for n in (719, WORD_COUNT_BAND_MIN, 800, WORD_COUNT_BAND_MAX, 916):
        text = _make_passage(n)
        canonical = canonical_count_words(text)
        assert canonical == n, (
            "sanity: fixture text must canonical-count to exactly n words; "
            f"got {canonical} for n={n}"
        )
        assert _measure_passage_words(text) == canonical, (
            "guard helper diverged from canonical validator count: "
            f"_measure_passage_words={_measure_passage_words(text)} "
            f"vs canonical={canonical} at n={n}"
        )

    # And the empty / None path is closed: guard helper never raises on
    # missing text -- it counts zero -- so a malformed draft never wedges the
    # generation loop in an exception path.
    assert _measure_passage_words("") == 0
    assert _measure_passage_words(None) == 0  # type: ignore[arg-type]


# ── (e) overshoot direction is symmetrical and equally bounded ────────────────

@pytest.mark.asyncio
async def test_overshoot_draft_triggers_one_reask_with_ceiling_named():
    """An overshot draft (921 > 915) is re-asked once with the ceiling named;
    an in-band second draft is returned. Mirrors test (a) for the upper bound.

    The campaign showed 921 was the first OPEN blocker in this paper -- the
    only overshoot in the run -- so this direction MUST be wired identically
    to the undershoot direction. A guard that only checked the floor would
    miss it.
    """
    gw = _ScriptedGateway([_payload(LONG_PASSAGE_921), _payload(IN_BAND_PASSAGE_800)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_wc_e", version=1)

    assert len(gw.requests) == 1 + EXPECTED_MAX_REASKS

    reask_prompt = gw.requests[1].messages[1].content
    assert "921" in reask_prompt
    assert str(WORD_COUNT_BAND_MAX) in reask_prompt
    assert "overshoot" in reask_prompt

    assert env.payload["passage"] == IN_BAND_PASSAGE_800
    assert env.payload.get("wordCountGuardReasks") == EXPECTED_MAX_REASKS
    assert env.version == 1


# ── (f) the bound itself is not relaxable through the context ────────────────

@pytest.mark.asyncio
async def test_guard_enforces_policy_band_even_when_context_band_is_overridden():
    """The guard must police the band the VALIDATOR enforces, not the caller's.

    `PassageGenerationContext.target_min_words` / `target_max_words` are
    caller-overridable, but the deterministic validators enforce the fixed
    policy band [PASSAGE_MIN_WORDS, PASSAGE_MAX_WORDS]. If the guard read the
    context, a caller could widen the band and silently switch this guard off
    while the validator still rejected the very same artifact at 720/915 --
    trading one wasted version slot for a permanently unusable guard.

    Here the context claims a [600, 2000] band, which the 682-word draft
    satisfies. The guard must still fire, because 682 is outside the real
    policy band.
    """
    bp_ref, eg_ref = _make_refs()
    widened_context = PassageGenerationContext(
        blueprintRef=bp_ref,
        evidenceGraphRef=eg_ref,
        sectionIndex=2,
        topic="Word Count Drift",
        sourceText=SOURCE_TEXT,
        targetMinWords=600,
        targetMaxWords=2000,
    )
    # Sanity: the widened context really would have accepted this draft.
    assert 600 <= 682 <= 2000

    gw = _ScriptedGateway([_payload(SHORT_PASSAGE_682), _payload(IN_BAND_PASSAGE_800)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=widened_context, run_id="bench_wc_f", version=1)

    # The guard fired anyway, against the policy band, and named the real floor.
    assert len(gw.requests) == 1 + EXPECTED_MAX_REASKS
    reask_prompt = gw.requests[1].messages[1].content
    assert str(WORD_COUNT_BAND_MIN) in reask_prompt
    # The audit field records the band actually enforced. The payload is frozen
    # for immutability, so the list reads back as a tuple.
    assert tuple(env.payload.get("wordCountBand") or ()) == (
        WORD_COUNT_BAND_MIN,
        WORD_COUNT_BAND_MAX,
    )
    assert env.payload.get("wordCountGuardReasks") == EXPECTED_MAX_REASKS
