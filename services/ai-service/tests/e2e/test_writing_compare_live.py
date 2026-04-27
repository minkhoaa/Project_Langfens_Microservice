"""Live smoke against POST /api/v1/writing/compare.

Requires:
    - ai-service reachable at AI_SERVICE_URL (default http://localhost:8092)
    - Ollama reachable + bge-m3 pulled (for embeddings)
    - Qdrant cloud reachable with writing_samples populated (1024-dim BGE-M3)
    - Groq API keys configured (USE_OPENAI_LIKE=true) OR Ollama LLM model pulled

Run with:
    pytest tests/e2e/test_writing_compare_live.py --run-live -v
"""
from __future__ import annotations

import time

import pytest

from app.schemas import CompareResponse
from tests.e2e.fixtures.essays import ALL_ESSAYS, WC_A_BAND9, WC_B_BAND6


@pytest.mark.live
@pytest.mark.asyncio
@pytest.mark.parametrize("essay", ALL_ESSAYS, ids=lambda e: e.id)
async def test_compare_returns_valid_schema(http_client, essay):
    payload = {
        "essay_text": essay.text,
        "topic": essay.topic,
        "task_type": essay.task_type,
        "student_band": essay.student_band,
    }
    t0 = time.perf_counter()
    resp = await http_client.post("/api/v1/writing/compare", json=payload)
    elapsed = time.perf_counter() - t0
    assert resp.status_code == 200, (
        f"{essay.id}: HTTP {resp.status_code} body={resp.text[:300]}"
    )
    data = CompareResponse.model_validate(resp.json())
    assert elapsed < 60.0, f"{essay.id}: latency {elapsed:.1f}s exceeds 60s budget"
    print(f"\n[{essay.id}] latency={elapsed:.2f}s "
          f"refs={len(data.references)} comps={len(data.sentence_comparisons)}")


@pytest.mark.live
@pytest.mark.asyncio
async def test_compare_band_b_has_meaningful_feedback(http_client):
    """A band-6 essay must yield ≥3 sentence comparisons + ≥2 references at band ≥7."""
    essay = WC_B_BAND6
    payload = {
        "essay_text": essay.text,
        "topic": essay.topic,
        "task_type": essay.task_type,
        "student_band": essay.student_band,
    }
    resp = await http_client.post("/api/v1/writing/compare", json=payload)
    assert resp.status_code == 200, resp.text[:300]
    data = CompareResponse.model_validate(resp.json())

    if not data.no_references_found:
        assert len(data.references) >= 2, f"got {len(data.references)} references"
        high_band_refs = [r for r in data.references if r.band >= 7.0]
        assert len(high_band_refs) >= 1, "expected at least one reference band ≥7"
        for r in data.references:
            assert 0.0 <= r.similarity_score <= 1.0
            assert r.band >= essay.student_band, (
                f"reference band {r.band} below student band {essay.student_band}"
            )

    assert len(data.sentence_comparisons) >= 3, (
        f"got {len(data.sentence_comparisons)} sentence comparisons"
    )
    valid_categories = {"vocabulary", "grammar", "coherence", "structure"}
    for sc in data.sentence_comparisons:
        assert sc.category in valid_categories
        assert sc.original.strip()
        assert sc.improved.strip()
        assert sc.explanation.strip()


@pytest.mark.live
@pytest.mark.asyncio
async def test_compare_band_a_uses_exemplar_mode(http_client):
    """Band 8.5+ submission should still produce step_up_band ≥8 OR target_band ≥8.5."""
    essay = WC_A_BAND9
    payload = {
        "essay_text": essay.text,
        "topic": essay.topic,
        "task_type": essay.task_type,
        "student_band": essay.student_band,
    }
    resp = await http_client.post("/api/v1/writing/compare", json=payload)
    assert resp.status_code == 200, resp.text[:300]
    data = CompareResponse.model_validate(resp.json())
    assert data.step_up_band >= 8.0 or data.target_band >= 8.5, (
        f"band-9 essay produced step_up_band={data.step_up_band}, "
        f"target_band={data.target_band}"
    )


@pytest.mark.live
@pytest.mark.asyncio
async def test_compare_rejects_short_essay(http_client):
    """essay_text < 50 chars must 422."""
    resp = await http_client.post("/api/v1/writing/compare", json={
        "essay_text": "too short",
        "topic": "Some valid IELTS topic",
        "task_type": "TASK_2",
        "student_band": 6.0,
    })
    assert resp.status_code == 422


@pytest.mark.live
@pytest.mark.asyncio
async def test_compare_rejects_invalid_band(http_client):
    """student_band outside [1, 9] must 422."""
    resp = await http_client.post("/api/v1/writing/compare", json={
        "essay_text": "x" * 100,
        "topic": "Some valid IELTS topic",
        "task_type": "TASK_2",
        "student_band": 0.0,
    })
    assert resp.status_code == 422
