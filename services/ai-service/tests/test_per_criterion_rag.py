import asyncio
from unittest.mock import AsyncMock, patch

import pytest

from app.schemas import ReassembledEssay, SearchResult

def _ref(pid: str, band: float = 7.0):
    return ReassembledEssay(
        parent_id=pid,
        text=f"ref {pid}",
        score=0.9,
        metadata={"band_overall": band},
    )

@pytest.mark.asyncio
async def test_retrieve_runs_four_queries_in_parallel():
    refs_ta = [_ref("ta1")]
    refs_cc = [_ref("cc1")]
    refs_lr = [_ref("lr1")]
    refs_gr = [_ref("gr1")]
    grammar_rules = [SearchResult(id="g1", text="rule", score=0.8, metadata={"category": "subject-verb"})]

    async def fake_reassemble(collection, query, top_k, filters):
        # Crude routing: the criterion label is in filters["criterion"]
        crit = filters.get("criterion", "")
        return {
            "ta": refs_ta,
            "cc": refs_cc,
            "lr": refs_lr,
            "gr": refs_gr,
        }[crit]

    async def fake_search(collection, query, top_k, filters):
        return grammar_rules

    with patch(
        "app.services.search_service.search_and_reassemble",
        new=AsyncMock(side_effect=fake_reassemble),
    ) as mock_sa, patch(
        "app.services.search_service.search",
        new=AsyncMock(side_effect=fake_search),
    ) as mock_search, patch(
        "app.services.per_criterion_rag.settings"
    ) as mock_settings:
        mock_settings.qdrant_collection_writing = "writing_samples"
        mock_settings.qdrant_collection_grammar = "grammar_knowledge"
        from app.services import per_criterion_rag

        out = await per_criterion_rag.retrieve("should students wear uniforms", "TASK_2")

    assert set(out.keys()) == {"ta", "cc", "lr", "gr", "grammar_rules"}
    assert out["ta"][0].parent_id == "ta1"
    assert out["gr"][0].parent_id == "gr1"
    assert out["grammar_rules"][0].id == "g1"
    # 4 essay queries + 1 grammar rules query
    assert mock_sa.await_count == 4
    assert mock_search.await_count == 1

@pytest.mark.asyncio
async def test_retrieve_degrades_to_essay_empty_and_grammar_fallback_on_rag_failure():
    async def boom(*args, **kwargs):
        raise RuntimeError("qdrant down")

    with patch(
        "app.services.search_service.search_and_reassemble",
        new=AsyncMock(side_effect=boom),
    ), patch(
        "app.services.search_service.search",
        new=AsyncMock(side_effect=boom),
    ), patch(
        "app.services.per_criterion_rag.settings"
    ) as mock_settings:
        mock_settings.qdrant_collection_writing = "writing_samples"
        mock_settings.qdrant_collection_grammar = "grammar_knowledge"
        from app.services import per_criterion_rag

        out = await per_criterion_rag.retrieve("topic", "TASK_2")

    # Essay criteria degrade to []; grammar rules fall back to the built-in set
    # so the FE pill row and the LLM prompt always have content.
    assert out["ta"] == [] and out["cc"] == [] and out["lr"] == [] and out["gr"] == []
    assert len(out["grammar_rules"]) > 0
    assert all(r.id.startswith("fallback-") for r in out["grammar_rules"])

