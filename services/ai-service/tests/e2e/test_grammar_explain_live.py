"""Live smoke against POST /api/v1/grammar/explain + /batch-explain."""
from __future__ import annotations

import time

import pytest

from app.schemas import GrammarBatchExplainResponse, GrammarExplainResponse


SAMPLE_ERRORS = [
    {
        "error_text": "the goverment must to spend more money",
        "context": "the goverment must to spend more money on healthcare and pensions.",
        "correct_form": "the government must spend more money",
        "language": "en-GB",
    },
    {
        "error_text": "old people they cannot work anymore",
        "context": "the workers are less because old people they cannot work anymore.",
        "correct_form": "old people cannot work anymore",
        "language": "en-GB",
    },
    {
        "error_text": "the economy is grow slower",
        "context": "so the economy is grow slower than before.",
        "correct_form": "the economy grows slower",
        "language": "en-GB",
    },
    {
        "error_text": "Sometime they fighting because of phone",
        "context": "Sometime they fighting because of phone.",
        "correct_form": "Sometimes they fight because of phones",
        "language": "en-GB",
    },
    {
        "error_text": "school must controll it carefully",
        "context": "mobile phone in school have more bad than good and school must controll it carefully.",
        "correct_form": "schools must control it carefully",
        "language": "en-GB",
    },
]

ALLOWED_CATEGORIES = {
    "tense", "subject-verb", "word-order", "article",
    "preposition", "pronoun", "collocation", "other",
}


@pytest.mark.live
@pytest.mark.asyncio
async def test_grammar_explain_single(http_client):
    err = SAMPLE_ERRORS[0]
    resp = await http_client.post("/api/v1/grammar/explain", json=err)
    assert resp.status_code == 200, resp.text[:300]
    data = GrammarExplainResponse.model_validate(resp.json())
    assert len(data.explanation) >= 20
    assert len(data.rule_description) >= 20
    assert data.correct_form
    assert len(data.examples) >= 2
    assert data.category in ALLOWED_CATEGORIES


@pytest.mark.live
@pytest.mark.asyncio
async def test_grammar_batch_explain_returns_all(http_client):
    payload = {"errors": SAMPLE_ERRORS, "max_concurrent": 3}
    t0 = time.perf_counter()
    resp = await http_client.post("/api/v1/grammar/batch-explain", json=payload)
    elapsed = time.perf_counter() - t0
    assert resp.status_code == 200, resp.text[:300]
    data = GrammarBatchExplainResponse.model_validate(resp.json())
    assert data.total_count == len(SAMPLE_ERRORS)
    # At least 80% success — 1 LLM hiccup tolerated.
    assert data.failed_count <= 1, f"failed_count={data.failed_count}"
    assert len(data.results) == len(SAMPLE_ERRORS) - data.failed_count
    for r in data.results:
        assert len(r.explanation) >= 20
        assert len(r.examples) >= 2
        assert r.category in ALLOWED_CATEGORIES
    # 5 errors / max_concurrent=3, 30s timeout each → upper bound ~60s.
    assert elapsed < 60.0, f"batch latency {elapsed:.1f}s"
    print(f"\n[grammar-batch] N={len(SAMPLE_ERRORS)} elapsed={elapsed:.2f}s "
          f"failed={data.failed_count}")
