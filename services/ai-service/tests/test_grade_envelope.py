import json
from unittest.mock import AsyncMock, patch

import pytest

from app.schemas import WritingGradeRequest

@pytest.mark.asyncio
async def test_grade_writing_returns_envelope_with_evidence_ids():
    req = WritingGradeRequest(
        task="Some IELTS task",
        answer="x " * 300,
        word_count=300,
        task_type="TASK_2",
    )

    fake_refs_by_criterion = {
        "ta": [],
        "cc": [],
        "lr": [],
        "gr": [],
    }

    llm_result = {
        "ob": 6.5,
        "ta": {"b": 6.0, "c": "...", "evidence_ids": ["ref-ta-1"]},
        "cc": {"b": 6.0, "c": "...", "evidence_ids": []},
        "lr": {"b": 7.0, "c": "...", "evidence_ids": ["ref-lr-1"]},
        "gr": {"b": 6.0, "c": "...", "evidence_ids": []},
        "s": ["tip"],
        "p": "improved",
    }

    # The pre-LLM band estimator makes a separate llm_service.generate call.
    # side_effect returns the estimator result for the first call and the
    # grader result for the second.
    estimator_result = {"band": 6.0, "reason": "test mock"}

    async def _llm_dispatch(*args, **kwargs):
        prompt = (kwargs.get("variables") or {}).get("prompt", "")
        if "Score the essay below" in prompt:
            return estimator_result
        return llm_result

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value=fake_refs_by_criterion),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=_llm_dispatch),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    # Existing flat fields still work
    assert resp.ta.b == 6.0
    assert resp.cc.b == 6.0
    assert resp.lr.b == 7.0
    assert resp.gr.b == 6.0
    # Envelope is populated. ob is the mean of the 4 criteria (rounded),
    # per IELTS convention — not the LLM's literal "ob" field, which can
    # drift from the criteria.
    assert resp.envelope is not None
    assert resp.envelope.domain == "writing"
    assert resp.envelope.overall_band == 6.0  # mean(6, 6, 7, 6) = 6.25 -> 6.0
    assert resp.ob == 6.0
    crits = {c.name: c for c in resp.envelope.criteria}
    assert crits["task_response"].band == 6.0
    assert crits["task_response"].evidence_ids == ["ref-ta-1"]
    assert crits["lexical_resource"].evidence_ids == ["ref-lr-1"]
    assert crits["grammatical_range"].evidence_ids == []

@pytest.mark.asyncio
async def test_grade_writing_degrades_when_llm_omits_evidence_ids():
    req = WritingGradeRequest(
        task="Some task prompt for IELTS writing",
        answer="x " * 300,
        word_count=300,
        task_type="TASK_2",
    )
    llm_result = {
        "ob": 6.0,
        "ta": {"b": 6.0, "c": "no ids"},
        "cc": {"b": 6.0, "c": "no ids"},
        "lr": {"b": 6.0, "c": "no ids"},
        "gr": {"b": 6.0, "c": "no ids"},
        "s": [],
        "p": "",
    }
    estimator_result = {"band": 5.5, "reason": "test mock"}

    async def _llm_dispatch(*args, **kwargs):
        prompt = (kwargs.get("variables") or {}).get("prompt", "")
        if "Score the essay below" in prompt:
            return estimator_result
        return llm_result

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value={"ta": [], "cc": [], "lr": [], "gr": []}),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=_llm_dispatch),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    assert resp.envelope is not None
    for c in resp.envelope.criteria:
        assert c.evidence_ids == []


@pytest.mark.asyncio
async def test_grade_writing_clamps_llm_ob_to_band_estimate_plus_one():
    """Regression: pre-LLM band estimator must clamp the full grader's `ob`
    to at most (estimate + 1.0). Without the clamp, a Band 3 essay is
    inflated to Band 6 via RAG anchoring (the bug that motivated this
    estimator). The estimator sees ONLY the essay text — no RAG — so its
    return is the floor the full grader cannot exceed.
    """
    req = WritingGradeRequest(
        task="Do you agree or disagree with the use of smartphones by children?",
        # Intentionally Band 3 prose: subject-verb errors, repeated "very",
        # word-by-word translation patterns, missing articles.
        answer=(
            "Nowadays, many people is think child use phone and computer tablet "
            "too much time. I am very agree this think because it make child very "
            "bad grow up in future time. " * 5
        ),
        word_count=200,
        task_type="TASK_2",
    )
    # Estimator says Band 3.0
    estimator_result = {"band": 3.0, "reason": "test mock: low band"}
    # Full LLM returns ob=6.0 (the inflation bug we are fixing)
    llm_result = {
        "ob": 6.0,
        "ta": {"b": 6.0, "c": "..."},
        "cc": {"b": 6.0, "c": "..."},
        "lr": {"b": 6.0, "c": "..."},
        "gr": {"b": 6.0, "c": "..."},
        "s": [],
        "p": "",
    }

    async def _llm_dispatch(*args, **kwargs):
        prompt = (kwargs.get("variables") or {}).get("prompt", "")
        if "Score the essay below" in prompt:
            return estimator_result
        return llm_result

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value={"ta": [], "cc": [], "lr": [], "gr": [], "grammar_rules": []}),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=_llm_dispatch),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    # The clamp: estimate=3.0, max allowed = estimate + 1.0 = 4.0
    assert resp.ob <= 4.0, (
        f"ob={resp.ob} was not clamped to band_estimate+1.0=4.0; the "
        "Band-3-essay-returns-Band-6 RAG-anchoring bug has regressed"
    )
    assert resp.envelope.overall_band == resp.ob

    # Regression: ob and per-criteria must be consistent. The previous bug
    # clamped ob to 4.0 but left criteria at 6.0, producing a UI where
    # the overall band read 4.0 next to four 6.0 criterion bars.
    crits = [resp.ta.b, resp.cc.b, resp.lr.b, resp.gr.b]
    expected = round((sum(crits) / 4.0) * 2) / 2
    assert resp.ob == expected, (
        f"ob={resp.ob} is inconsistent with criterion mean={expected} "
        f"(criteria={crits}); the overall and per-criterion bands must agree"
    )


@pytest.mark.asyncio
async def test_grade_writing_does_not_clamp_when_llm_agrees_with_estimate():
    """When the LLM band is within (estimate, estimate+1.0], no clamp fires."""
    req = WritingGradeRequest(
        task="Some IELTS task",
        answer="x " * 300,
        word_count=300,
        task_type="TASK_2",
    )
    estimator_result = {"band": 6.0, "reason": "test mock"}
    llm_result = {
        "ob": 6.5,  # within +1.0 of estimate=6.0
        "ta": {"b": 6.0, "c": "..."},
        "cc": {"b": 6.0, "c": "..."},
        "lr": {"b": 7.0, "c": "..."},
        "gr": {"b": 6.0, "c": "..."},
        "s": [],
        "p": "",
    }

    async def _llm_dispatch(*args, **kwargs):
        prompt = (kwargs.get("variables") or {}).get("prompt", "")
        if "Score the essay below" in prompt:
            return estimator_result
        return llm_result

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value={"ta": [], "cc": [], "lr": [], "gr": [], "grammar_rules": []}),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=_llm_dispatch),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    # No clamp: LLM band is within the +1.0 window. ob is the mean of the
    # criteria (rounded to 0.5), per IELTS convention.
    assert resp.ob == 6.0  # mean(6, 6, 7, 6) = 6.25 -> 6.0


@pytest.mark.asyncio
async def test_grade_writing_ob_equals_mean_of_criteria():
    """Regression: the previous clamp logic only clamped `ob` but left the
    per-criterion bands untouched. The FE then displayed a screen with
    ob=5.0 next to four 6.0 criterion bars (mean 6.1) — visually wrong and
    internally inconsistent. IELTS specifies that the overall band is the
    mean of the four criteria (rounded). The fix: clamp each criterion
    band to ceil=band_estimate+1.0, then recompute ob as their mean.
    """
    req = WritingGradeRequest(
        task="Discuss the impact of social media on teenagers.",
        answer="x " * 200,
        word_count=200,
        task_type="TASK_2",
    )
    # Estimator says 4.0; LLM tries to return 6.0 across the board
    estimator_result = {"band": 4.0, "reason": "test mock"}
    llm_result = {
        "ob": 6.0,
        "ta": {"b": 6.0, "c": "..."},
        "cc": {"b": 6.0, "c": "..."},
        "lr": {"b": 6.0, "c": "..."},
        "gr": {"b": 6.0, "c": "..."},
        "s": [],
        "p": "",
    }

    async def _llm_dispatch(*args, **kwargs):
        prompt = (kwargs.get("variables") or {}).get("prompt", "")
        if "Score the essay below" in prompt:
            return estimator_result
        return llm_result

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value={"ta": [], "cc": [], "lr": [], "gr": [], "grammar_rules": []}),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=_llm_dispatch),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    # Each criterion clamped to ceil=5.0
    assert resp.ta.b == 5.0
    assert resp.cc.b == 5.0
    assert resp.lr.b == 5.0
    assert resp.gr.b == 5.0
    # ob is the mean of criteria = 5.0 (consistent)
    assert resp.ob == 5.0
    assert resp.envelope.overall_band == 5.0
    # No more "ob=5 next to 4×6" mismatch
    crit_bands = [c.band for c in resp.envelope.criteria]
    assert abs(resp.ob - round((sum(crit_bands) / len(crit_bands)) * 2) / 2) <= 0.5


@pytest.mark.asyncio
async def test_grade_writing_handles_band_2_submission():
    """A genuine Band 2.0 submission must not be inflated to Band 6+.

    Covers the lower edge: estimator says 2.0, full LLM tries to return
    6.0, clamp brings it down to 3.0 (estimate + 1.0). The Band 2 essay
    gets a Band 2-3 score, not Band 6.
    """
    req = WritingGradeRequest(
        task="Discuss the advantages and disadvantages of social media.",
        # 25 words of near-nonsense — well below the 250-word minimum
        answer="phone phone phone bad good very much. " * 4,
        word_count=25,
        task_type="TASK_2",
    )
    estimator_result = {"band": 2.0, "reason": "test mock: very low band"}
    llm_result = {
        "ob": 6.0,  # would be the inflation bug
        "ta": {"b": 6.0, "c": "..."},
        "cc": {"b": 6.0, "c": "..."},
        "lr": {"b": 6.0, "c": "..."},
        "gr": {"b": 6.0, "c": "..."},
        "s": [],
        "p": "",
    }

    async def _llm_dispatch(*args, **kwargs):
        prompt = (kwargs.get("variables") or {}).get("prompt", "")
        if "Score the essay below" in prompt:
            return estimator_result
        return llm_result

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value={"ta": [], "cc": [], "lr": [], "gr": [], "grammar_rules": []}),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=_llm_dispatch),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    # estimate=2.0, max allowed = estimate+1.0 = 3.0
    assert resp.ob <= 3.0, (
        f"Band 2 essay returned ob={resp.ob}; the estimator clamp failed"
    )


@pytest.mark.asyncio
async def test_grade_writing_fallback_estimator_floors_short_essays():
    """When the estimator LLM fails, the regex+word-count fallback must
    still floor short essays. A 20-word essay cannot score Band 5
    regardless of regex density, because 20 words cannot satisfy the
    IELTS task response minimum at any band above 3.0.
    """
    from app.services.grade_service import _estimate_band_with_llm

    req = WritingGradeRequest(
        task="Some task",
        # 50 chars minimum (Pydantic schema gate), but only 7 words.
        # The estimator must still floor short essays below Band 3.
        answer="phone phone phone phone phone phone phone phone phone",  # 9 words
        word_count=9,
        task_type="TASK_2",
    )

    # Force the LLM call to fail so the fallback path runs
    with patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(side_effect=RuntimeError("simulated LLM outage")),
    ):
        estimate, debug = await _estimate_band_with_llm(req)

    # 9-word essay → length_floor=1.0. The word-count ceiling is 4.5
    # (for <150 words) but the LENGTH FLOOR overrides the regex penalty
    # because the essay is too short to score above Band 1 regardless
    # of how clean the gibberish is. Without the length floor, the
    # regex fallback would return 4.5 (the ceiling) for this 9-word
    # essay, allowing it to pass to the full grader as a Band 4.5
    # candidate and inflate to Band 6+ via RAG anchoring.
    assert estimate <= 2.0, (
        f"9-word essay estimated at {estimate}; the fallback should floor "
        f"short essays below Band 2"
    )
    assert debug.get("estimator") == "fallback:word_count+regex"
