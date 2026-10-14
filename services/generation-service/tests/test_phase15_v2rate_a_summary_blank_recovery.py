"""Focused regression tests for Agent A's Phase 15 V2 valid-Draft fix.

Defect: a SummaryCompletion group can come back from the provider with one blank
whose answer is empty, so the blank was dropped and its slot starved. Slot Q20
then produced a 0-candidate pool, the artifact carried `answer: ""`, and
app/evaluators/deterministic.py raised `SCHEMA_VIOLATION: Question 20 answer
cannot be empty or missing` (CRITICAL, exact-target). The slot retried, got the
same shape, and burned all three versions -> MAX_VERSIONS. That is the dispatch
signature recorded for cases 8/13/14/16/18 (gen_qpool_20_* x3, nothing after).

Fix, in `generate_candidate_pool`: a hybrid SummaryCompletion payload that
carries BOTH `blanks` and a direct `candidates` entry for this exact slot was
having its `candidates` list discarded unconditionally. `normalize_question_
generation_payload` deliberately preserves the slot-matched direct candidate, so
the generator was throwing away a model-supplied, slot-matched, grounded answer.
It is now retained and used as the recovery source when the group's own blank
for this slot is unusable.

DELIBERATELY NOT DONE -- documented here because it was attempted and rejected:
mining a 1-3 word span out of the blank's `evidenceQuote` when the answer was
empty. That was implemented, then removed. The evidenceQuote identifies the
source SENTENCE, not which words fill that particular cloze, so a mined span can
satisfy every mechanical gate (verbatim in passage, 1-3 words, non-leaking,
mutually distinct) and still be semantically wrong. Concretely, for the cloze
"Researchers gathered [2]" a mined span yielded "three salinity gradients", while
the quoted sentence says core profiles were collected *across* those gradients.
`test_..._never_mines_a_span_from_evidence_quote` below pins that behaviour shut.
Recovery is therefore restricted to text the model supplied AS the answer.

All fixtures are authored for this test file: no held-out evaluation corpus, no
live provider, no network.
"""

from __future__ import annotations

import json
from typing import Any, List, Optional
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.issue import IssueScope
from app.generators.question.generator import QuestionCandidateGenerator
from app.loop.context import AuthorityGrant, LoopContext
from app.providers.models import ProviderRequest, ProviderResponse, UsageReport


PASSAGE = (
    "Estuarine wetlands regulate tidal sediment transport through dense root matrices. "
    "Field coring campaigns collected forty-two core profiles across three salinity gradients. "
    "Samples were preserved using cryogenic freezing aboard the survey barge before laboratory assay. "
    "Spectrometric calibration relied on automated optical sensors to quantify suspended particulates."
)

SENT_ROOT = "Estuarine wetlands regulate tidal sediment transport through dense root matrices."
SENT_CORING = "Field coring campaigns collected forty-two core profiles across three salinity gradients."
SENT_CRYO = "Samples were preserved using cryogenic freezing aboard the survey barge before laboratory assay."
SENT_OPTICAL = "Spectrometric calibration relied on automated optical sensors to quantify suspended particulates."


def _make_refs() -> tuple[ArtifactRef, ArtifactRef]:
    return (
        ArtifactRef(artifactId="art_passage_dev", version=1, artifactType=ArtifactType.PASSAGE, contentHash="1" * 64),
        ArtifactRef(artifactId="art_blueprint_dev", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="2" * 64),
    )


def _make_loop_context(run_id: str = "bench_phase15_v2rate_a") -> LoopContext:
    return LoopContext(
        runId=run_id,
        targetArtifactId="art_q_slot_20",
        targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )


class _StubGateway:
    def __init__(self, raw_text: str):
        self.raw_text = raw_text
        self.requests: List[ProviderRequest] = []

    async def execute(self, req: ProviderRequest, epoch: int = 1, lease_owner: Optional[Any] = None) -> ProviderResponse:
        self.requests.append(req)
        return ProviderResponse(
            operation_id=req.operation_id,
            provider_name="stub",
            model_name="stub-model",
            raw_text=self.raw_text,
            usage=UsageReport(prompt_tokens=100, completion_tokens=200, total_tokens=300),
            latency_seconds=0.05,
        )


async def _run_slot(payload: dict, slot: int = 20, start: int = 20, blank_count: int = 4):
    p_ref, bp_ref = _make_refs()
    ctx = _make_loop_context()
    gen = QuestionCandidateGenerator(gateway=_StubGateway(json.dumps(payload)))
    pool = await gen.generate_candidate_pool(
        passage_text=PASSAGE,
        question_type="SummaryCompletion",
        question_number=slot,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        run_id=ctx.run_id,
        context=ctx,
        group_start_number=start,
        blank_count=blank_count,
    )
    return pool, gen


def _payload(blanks: List[dict], summary_text: str, candidates: Optional[List[dict]] = None) -> dict:
    out = {"summaryTitle": "Estuarine Wetland Survey", "summaryText": summary_text, "blanks": blanks}
    if candidates is not None:
        out["candidates"] = candidates
    return out


SUMMARY_TEXT = (
    "Estuarine wetlands stabilize sediment movement via [1]. "
    "Researchers mapped [2] across distinct zones. "
    "Field teams applied [3] on the vessel while [4] measured particulates."
)


# ── The production failure shape ────────────────────────────────────────────

@pytest.mark.asyncio
async def test_phase15_v2rate_a_hybrid_slot_candidate_serves_starved_q20():
    """Q20's blank is empty but the payload carries a grounded Q20 candidate -> slot is served.

    Reproduces the exact campaign shape: slot Q20 (group_start_number=20) came
    back with `answer: ""`, which was dropped, leaving a 0-candidate pool and a
    SCHEMA_VIOLATION that burned all three versions. Here the same response also
    carries the model's own direct candidate for Q20, which must be used.
    """
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
        {"number": 22, "placeholder": "[3]", "answer": "cryogenic freezing", "evidenceQuote": SENT_CRYO},
        {"number": 23, "placeholder": "[4]", "answer": "automated optical sensors", "evidenceQuote": SENT_OPTICAL},
    ]
    # "salinity gradients" is deliberately NOT in SENT_ROOT, so this candidate is
    # distinguishable from any span that could be mined out of Q20's evidenceQuote.
    candidates = [
        {
            "questionNumber": 20,
            "prompt": "Estuarine wetlands regulate tidal sediment movement via ______.",
            "answer": "salinity gradients",
            "evidenceQuote": SENT_CORING,
            "explanation": "Core profiles were collected across three salinity gradients.",
        }
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT, candidates))

    assert len(pool.candidates) == 1, "starved Q20 must be served, not left empty"
    cand = pool.candidates[0]
    assert cand.answer == "salinity gradients", "must reuse the model's own slot answer, not a derived span"
    assert cand.answer in PASSAGE
    assert 1 <= len(cand.answer.split()) <= 3
    assert cand.answer.lower() not in SUMMARY_TEXT.lower(), "anti-leakage must hold"
    assert cand.is_eligible()


@pytest.mark.asyncio
async def test_phase15_v2rate_a_never_mines_a_span_from_evidence_quote():
    """The engine must NOT invent an answer by mining the blank's evidenceQuote.

    Q20's blank is empty and its evidenceQuote is a verbatim passage sentence, so
    a naive implementation could pull a plausible 1-3 word span out of it. That
    span would pass every mechanical gate and still be wrong: for the cloze
    "Estuarine wetlands stabilize sediment movement via [1]" the only real answer
    is in SENT_ROOT, and any other span is not what that cloze asks for.
    No model-supplied answer exists for this slot, so the slot must stay empty.
    """
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT), slot=20, blank_count=2)

    assert len(pool.candidates) == 0, "must fail closed rather than synthesize an answer"
    assert pool.dropped_blank_reasons.get(20) == "empty_answer"


@pytest.mark.asyncio
async def test_phase15_v2rate_a_empty_answer_without_model_answer_fails_closed():
    """Empty answer and no slot-matched candidate anywhere -> blank stays dropped."""
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": ""},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT), slot=20, blank_count=2)

    assert len(pool.candidates) == 0
    assert pool.dropped_blank_reasons.get(20) == "empty_answer"


@pytest.mark.asyncio
async def test_phase15_v2rate_a_sibling_slot_candidate_is_not_borrowed():
    """A direct candidate for a DIFFERENT slot must never be used to serve Q20.

    The recovery is slot-matched: `normalize_question_generation_payload` filters
    `candidates` by keep_question_number, and nothing else may rescue a starved
    slot. Answering Q20 with Q21's candidate would be a silent swap.
    """
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]
    candidates = [
        {
            "questionNumber": 21,
            "prompt": "Researchers mapped ______ across distinct zones.",
            "answer": "automated optical sensors",
            "evidenceQuote": SENT_OPTICAL,
            "explanation": "Spectrometric calibration relied on automated optical sensors.",
        }
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT, candidates), slot=20, blank_count=2)

    assert len(pool.candidates) == 0, "must not borrow another slot's candidate"
    assert pool.dropped_blank_reasons.get(20) == "empty_answer"


@pytest.mark.asyncio
async def test_phase15_v2rate_a_hybrid_candidate_still_passes_all_gates():
    """A slot-matched candidate is validated exactly like any other answer.

    Each candidate below breaks one gate; every one must be rejected, proving the
    recovery path does not become a permissive bypass around the normal checks.
    """
    base_blanks = [
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]

    # (a) answer longer than 3 words AND with no verbatim sub-span to repair to
    #     -> rejected. (An over-length answer that CONTAINS a usable sub-span is
    #     legitimately repaired; that case is covered separately below.)
    too_long = [
        {
            "questionNumber": 20,
            "prompt": "x ______ y",
            "answer": "photosynthetic capacity of submerged vegetation",
            "evidenceQuote": SENT_ROOT,
            "explanation": "ungrounded and too long",
        }
    ]
    pool, _ = await _run_slot(
        _payload([{"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT}] + base_blanks,
                 SUMMARY_TEXT, too_long),
        slot=20, blank_count=2)
    assert len(pool.candidates) == 0

    # (b) answer not verbatim in the passage -> rejected
    ungrounded = [
        {
            "questionNumber": 20,
            "prompt": "x ______ y",
            "answer": "photosynthetic capacity",
            "evidenceQuote": SENT_ROOT,
            "explanation": "not in passage",
        }
    ]
    pool, _ = await _run_slot(
        _payload([{"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT}] + base_blanks,
                 SUMMARY_TEXT, ungrounded),
        slot=20, blank_count=2)
    assert len(pool.candidates) == 0

    # (c) answer already present in summaryText (anti-leakage) -> rejected
    leaking = [
        {
            "questionNumber": 20,
            "prompt": "x ______ y",
            "answer": "salinity gradients",
            "evidenceQuote": SENT_CORING,
            "explanation": "leaks",
        }
    ]
    leaking_summary = SUMMARY_TEXT + " Salinity gradients defined each surveyed zone."
    pool, _ = await _run_slot(
        _payload([{"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT}] + base_blanks,
                 leaking_summary, leaking),
        slot=20, blank_count=2)
    assert len(pool.candidates) == 0

    # (d) answer duplicating a surviving sibling answer -> rejected
    duplicate = [
        {
            "questionNumber": 20,
            "prompt": "x ______ y",
            "answer": "forty-two core profiles",
            "evidenceQuote": SENT_CORING,
            "explanation": "duplicate",
        }
    ]
    pool, _ = await _run_slot(
        _payload([{"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT}] + base_blanks,
                 SUMMARY_TEXT, duplicate),
        slot=20, blank_count=2)
    assert len(pool.candidates) == 0


@pytest.mark.asyncio
async def test_phase15_v2rate_a_hybrid_candidate_over_length_is_repaired():
    """An over-length slot candidate is repaired to a 1-3 word verbatim sub-span.

    Repair here uses only text the model supplied AS the answer, so the
    sub-span is derived from the model's own answer rather than invented.
    """
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]
    candidates = [
        {
            "questionNumber": 20,
            "prompt": "Estuarine wetlands regulate sediment movement via ______.",
            "answer": "dense root matrices regulate",
            "evidenceQuote": SENT_ROOT,
            "explanation": "wetlands regulate sediment movement through dense root matrices",
        }
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT, candidates), slot=20, blank_count=2)

    assert len(pool.candidates) == 1
    cand = pool.candidates[0]
    assert 1 <= len(cand.answer.split()) <= 3
    assert cand.answer in PASSAGE
    assert cand.answer.lower() not in SUMMARY_TEXT.lower()


@pytest.mark.asyncio
async def test_phase15_v2rate_a_group_blank_still_wins_over_hybrid_candidate():
    """When the group's own blank for the slot IS usable, it must be used.

    The hybrid candidate is a fallback for a starved slot only; it must never
    override a good blank, or every well-formed group would drift toward the
    direct-candidate shape.
    """
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "dense root matrices", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]
    candidates = [
        {
            "questionNumber": 20,
            "prompt": "x ______ y",
            "answer": "salinity gradients",
            "evidenceQuote": SENT_CORING,
            "explanation": "should not win",
        }
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT, candidates), slot=20, blank_count=2)

    assert len(pool.candidates) == 1
    assert pool.candidates[0].answer == "dense root matrices", "the group's own blank must take precedence"


@pytest.mark.asyncio
async def test_phase15_v2rate_a_sibling_slots_unaffected_by_recovery():
    """Recovery for Q20 must not renumber, compact, or shift any sibling blank."""
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
        {"number": 22, "placeholder": "[3]", "answer": "cryogenic freezing", "evidenceQuote": SENT_CRYO},
        {"number": 23, "placeholder": "[4]", "answer": "automated optical sensors", "evidenceQuote": SENT_OPTICAL},
    ]
    _pool, gen = await _run_slot(_payload(blanks, SUMMARY_TEXT))
    kept = gen._last_summary_parsed["blanks"]

    assert [b["number"] for b in kept] == [21, 22, 23], "no compaction; Q20 keeps its own identity"
    assert [b["_orig_index"] for b in kept] == [1, 2, 3]
    by_num = {b["number"]: b["answer"] for b in kept}
    assert by_num[21] == "forty-two core profiles"
    assert by_num[22] == "cryogenic freezing"
    assert by_num[23] == "automated optical sensors"


@pytest.mark.asyncio
async def test_phase15_v2rate_a_repaired_blank_is_not_reported_as_dropped():
    """A blank repaired from its own answer must not remain listed as dropped.

    Drop reasons are recorded before repair; leaving a stale reason behind after a
    successful repair makes the ledger claim a blank was dropped when it was kept.
    """
    blanks = [
        {"number": 20, "placeholder": "[1]", "answer": "dense root matrices regulate transport", "evidenceQuote": SENT_ROOT},
        {"number": 21, "placeholder": "[2]", "answer": "forty-two core profiles", "evidenceQuote": SENT_CORING},
    ]
    pool, _gen = await _run_slot(_payload(blanks, SUMMARY_TEXT), slot=20, blank_count=2)

    assert len(pool.candidates) == 1
    assert pool.candidates[0].answer in PASSAGE
    assert 20 not in pool.dropped_blank_reasons, "repaired blank must not still be reported as dropped"