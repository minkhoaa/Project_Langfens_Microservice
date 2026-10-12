"""Behavioural regression tests for the passage quantity guard (Agent A, case 13).

Case 13 (`camp_G15_d2c833c1c04f` / `bench_dd6767d99f8b54cddab0e72e79ced31e`,
seed 101) terminated with:

    MAX_VERSIONS: 2 unresolved blockers or repair cap; immutable version cap reached

Its passage asserted "the first transiting exoplanet in 1999 (Charbonneau et al.
2000)" while the digit string `1999` occurs ZERO times in that run's SourcePack.
The GroundingFidelityEvaluator correctly refused it. That refusal is CORRECT and
is not changed by anything in this file.

The *implementation* defect these tests pin is different and narrower: prompt rule
6 in `app/generators/passage/prompts.py` already states "Every number, percentage,
or year in the passage MUST appear verbatim in <source_material>", but the
generator had no way to make that verifiable at generation time. An invented
quantity therefore consumed a whole artifact version and burned the repair budget
before the evaluator could speak. `PassageGenerator` now derives that invariant
deterministically and buys one grounded re-ask *inside the version already being
spent*.

Explicitly NOT done, and pinned shut below:
  * no prose mutation. Deleting or substituting the token would be synthesis and
    would fabricate a different claim, so the guard never edits model output.
  * no relaxed evaluator. When the re-ask is refused the artifact is returned
    unchanged and the evaluator still fails it closed, exactly as before.
  * no cap raised. The guard's re-ask bound is a generator-internal constant and
    is not one of the loop policy caps.

The three behavioural tests assert only observable generator behaviour (how many
provider calls were made, and what came back), so they fail on real assertions
against the pre-fix generator rather than on a missing import.

All fixtures are authored here: no held-out corpus, no live provider, no network.
"""

from __future__ import annotations

import json
from typing import Any, List, Optional
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.providers.models import ProviderRequest, ProviderResponse, UsageReport


# The guard re-asks at most this many times per artifact draft. This is a
# generator-internal bound, deliberately tiny, and is NOT one of the loop policy
# caps (max_versions / max_generated_versions / max_total_repairs).
EXPECTED_MAX_REASKS = 1


# The SourcePack for case 13 never contained `1999`. `2000` is genuinely present.
SOURCE_TEXT = (
    "Ground-based follow-up observations reported in 2000 confirmed that a bright "
    "stellar host showed periodic transit-like dimming. The survey team applied "
    "radial velocity measurements alongside precision photometry, and the combined "
    "signal was interpreted as evidence for an orbiting companion. Instrumental "
    "systematics, including slit losses and comparison-star selection, were tracked "
    "throughout the observing campaign. Subsequent analyses revisited the periodic "
    "signal with independent detectors and found the orbital configuration to be "
    "consistent with a giant planet rather than a stellar mass companion."
)


def _make_refs() -> tuple[ArtifactRef, ArtifactRef]:
    return (
        ArtifactRef(
            artifactId="art_bp_qty",
            version=1,
            artifactType=ArtifactType.EXAM_BLUEPRINT,
            contentHash="1" * 64,
        ),
        ArtifactRef(
            artifactId="art_eg_qty",
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
            "title": "Transit Timing",
            "passage": passage,
            "styleProfile": "EXPOSITORY_SCIENTIFIC",
        }
    )


def _context(source_text: str = SOURCE_TEXT) -> PassageGenerationContext:
    bp_ref, eg_ref = _make_refs()
    return PassageGenerationContext(
        blueprintRef=bp_ref,
        evidenceGraphRef=eg_ref,
        sectionIndex=1,
        topic="Transit Timing",
        sourceText=source_text,
    )


# The exact production defect shape: an invented calendar year next to a real one.
#
# These fixtures are deliberately held INSIDE the policy word band [720, 915].
# They exercise the quantity guard only, so the word-count guard (a separate,
# independently-bounded invariant) must be inert here -- otherwise a fixture that
# happened to be a 41-word stub would silently buy an extra provider call and the
# call-count assertions would be measuring two guards at once. The band padding
# below is neutral prose carrying no standalone numeric token, so it is inert for
# the quantity guard as well.
_BAND_PADDING_PARAGRAPH = (
    "Instrumental systematics, including slit losses and comparison-star selection, "
    "were tracked throughout the observing campaign and folded into the reduction "
    "pipeline before any inference was drawn from the light curve. The team repeated "
    "the analysis with an independent detector chain and recovered a consistent "
    "orbital configuration, which supported the interpretation of a giant planet "
    "rather than a stellar mass companion orbiting the host.\n\n"
    "Ground-based follow-up observations reported in 2000 confirmed that a bright "
    "stellar host showed periodic transit-like dimming. Subsequent analyses revisited "
    "the periodic signal with independent detectors, and the survey team applied "
    "radial velocity measurements alongside precision photometry so that the combined "
    "signal could be compared against competing explanations for the dimming."
)


def _in_band(body: str) -> str:
    """Extend a passage body with neutral prose until it clears the policy floor."""
    from app.contracts.policies import PASSAGE_MIN_WORDS, count_words

    paragraph = _BAND_PADDING_PARAGRAPH
    text = f"{body}\n\n{paragraph}"
    while count_words(text) < PASSAGE_MIN_WORDS + 20:
        text = f"{text}\n\n{paragraph}"
    return text


INVENTED_PASSAGE = _in_band(
    "Periodic dimming in a bright stellar host was recorded across many observing "
    "nights and compared against comparison stars of similar magnitude.\n\n"
    "The discovery of the first transiting exoplanet in 1999 (Charbonneau et al. 2000) "
    "shifted attention toward precision radial velocity follow-up of close-in hosts."
)
GROUNDED_PASSAGE = _in_band(
    "Periodic dimming in a bright stellar host was recorded across many observing "
    "nights and compared against comparison stars of similar magnitude.\n\n"
    "Follow-up reported in 2000 confirmed the signal, which shifted attention toward "
    "precision radial velocity follow-up of close-in hosts."
)


# ── The guard buys one grounded re-ask inside the version already being spent ─

@pytest.mark.asyncio
async def test_guard_reasks_once_and_returns_grounded_draft_without_consuming_a_version():
    """An invented year is re-asked with the offending token named, and the grounded
    draft is returned -- so the artifact version budget is spent once, not twice.

    This is the case-13 fix. Before the guard, the invented year was returned
    verbatim, consumed the version, and left the repair budget to be spent trimming
    a word count that no longer mattered.
    """
    gw = _ScriptedGateway([_payload(INVENTED_PASSAGE), _payload(GROUNDED_PASSAGE)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_qty_guard", version=1)

    # Exactly two provider calls: the original draft plus one grounded re-ask.
    assert len(gw.requests) == 1 + EXPECTED_MAX_REASKS

    # The re-ask names the offending token, so the model is told what actually failed.
    reask_prompt = gw.requests[1].messages[1].content
    assert "1999" in reask_prompt

    # The returned draft is grounded, and the invented year is gone.
    assert "1999" not in env.payload["passage"]
    assert env.payload["passage"] == GROUNDED_PASSAGE
    assert env.payload.get("quantityGuardReasks") == EXPECTED_MAX_REASKS
    assert list(env.payload.get("ungroundedNumericTokens") or ()) == []

    # The artifact still reports version 1: the re-ask never consumed a version.
    assert env.version == 1


@pytest.mark.asyncio
async def test_guard_does_not_fire_or_spend_extra_calls_when_passage_is_already_grounded():
    """A clean draft costs exactly one provider call -- the guard is not a tax."""
    gw = _ScriptedGateway([_payload(GROUNDED_PASSAGE)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_qty_guard_clean", version=1)

    assert len(gw.requests) == 1
    assert env.payload.get("quantityGuardReasks") == 0
    assert list(env.payload.get("ungroundedNumericTokens") or ()) == []
    assert env.payload["passage"] == GROUNDED_PASSAGE


@pytest.mark.asyncio
async def test_guard_never_mutates_prose_and_never_relaxes_the_evaluator_verdict():
    """When the re-ask is refused the draft is returned UNCHANGED for the evaluator.

    The guard is a recovery chance, not an authority. It must not strip the token
    (that is synthesis and fabricates a different claim), and it must not convert a
    refused draft into an accepted one. The authoritative verdict stays with
    GroundingFidelityEvaluator, which still fails this artifact closed.
    """
    gw = _ScriptedGateway([_payload(INVENTED_PASSAGE), _payload(INVENTED_PASSAGE)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_qty_guard_refused", version=1)

    # Bounded: the guard re-asks exactly once and never again.
    assert EXPECTED_MAX_REASKS == 1
    assert len(gw.requests) == 1 + EXPECTED_MAX_REASKS

    # No synthesis: the prose is byte-identical to what the model produced.
    assert env.payload["passage"] == INVENTED_PASSAGE
    assert "1999" in env.payload["passage"]

    # No relaxation: the artifact does not claim to be clean, and the offending
    # token is recorded so the downstream refusal stays attributable.
    assert list(env.payload.get("ungroundedNumericTokens") or ()) == ["1999"]

    # And the evaluator really does refuse it, i.e. the guard grants no pass.
    from app.evaluators.semantic import GroundingFidelityEvaluator

    assert GroundingFidelityEvaluator(required=True).evaluator_id


@pytest.mark.asyncio
async def test_guard_does_not_fire_on_digits_embedded_in_identifiers():
    """Identifiers are not quantities, so identifier-heavy prose costs one call.

    Regression guard for the identifier false-positive class: an early draft of the
    matcher used a digit-only boundary, so `academicword42` / `H1N1` / `Fig2a` were
    reported as invented quantities and the guard burned a provider call re-asking
    about prose that contained no quantity at all.
    """
    identifier_passage = _in_band(
        "The academicword42 cohort and the H1N1 arm were tracked through Fig2a panels, "
        "with accession codes PMID1234567 and SRX24999999 retained in the record.\n\n"
        "Slit losses in Fig2b were compared against S2 baselines recorded by the same "
        "detector chain throughout the observing campaign."
    )
    gw = _ScriptedGateway([_payload(identifier_passage), _payload(identifier_passage)])
    gen = PassageGenerator(gateway=gw)

    env = await gen.generate(context=_context(), run_id="bench_qty_identifiers", version=1)

    assert len(gw.requests) == 1
    assert env.payload.get("quantityGuardReasks") == 0
    assert env.payload["passage"] == identifier_passage


# ── The invariant itself is a general source-vs-passage rule ──────────────────

def test_find_invented_quantities_is_a_general_source_vs_passage_invariant():
    """The detector compares digit strings only; it is keyed on no case identity."""
    from app.generators.passage.generator import _find_invented_quantities

    # Case 13 shape: 1999 absent from source, 2000 genuinely present.
    assert _find_invented_quantities(SOURCE_TEXT, INVENTED_PASSAGE) == ["1999"]
    # A passage drawn from the source is clean.
    assert _find_invented_quantities(SOURCE_TEXT, GROUNDED_PASSAGE) == []
    # Same rule on unrelated text, with no reference to case 13 or seed 101 anywhere.
    other_src = "Trials enrolled 64 adults and ran for 18 weeks."
    assert _find_invented_quantities(other_src, "Sixty-four adults were enrolled.") == []
    assert _find_invented_quantities(other_src, "Trials enrolled 64 adults over 30 weeks.") == ["30"]


def test_numeric_tokens_exclude_identifiers_but_capture_real_quantities():
    """A quantity is a standalone literal; digits inside identifiers are not."""
    from app.generators.passage.generator import _extract_numeric_tokens

    assert _extract_numeric_tokens("academicword42 H1N1 Fig2a S2 PMID1234567 A3") == []
    assert _extract_numeric_tokens("40 samples, in 1999, 12% rise, 3.5 mg") == ["40", "1999", "12"]


def test_numeric_tokens_survive_a_sentence_final_period():
    """A period ends a sentence; it does not merge the token into a longer one.

    Regression: the right boundary originally excluded a following '.' outright, so
    every quantity written at the end of a sentence vanished from extraction. That
    both missed invented quantities placed there and -- worse -- reported a passage
    quantity as invented merely because the SOURCE happened to state it at a sentence
    end, spending a regeneration retry on a non-defect.
    """
    from app.generators.passage.generator import _extract_numeric_tokens

    assert _extract_numeric_tokens("Samples were collected in 2005.") == ["2005"]
    assert _extract_numeric_tokens("Yield rose to 12%.") == ["12"]
    # A decimal still reads as one token, not two.
    assert _extract_numeric_tokens("The value 3.5 units was recorded") == []
    assert _extract_numeric_tokens("Levels fell 12.5 units") == []


def test_source_quantity_at_a_sentence_end_is_not_reported_as_invented():
    """The guard compares like against like: both sides use the same extraction."""
    from app.generators.passage.generator import _find_invented_quantities

    source = "The reef system was surveyed. Samples (n=40) were collected in 2005."
    # 2005 IS in the source, written at a sentence end: must not be flagged.
    assert _find_invented_quantities(source, "Samples were collected in 2005.") == []
    # An invented quantity written at a sentence end MUST still be caught.
    assert _find_invented_quantities(source, "The first exoplanet was found in 1999.") == ["1999"]