import asyncio
from unittest.mock import AsyncMock, patch

import pytest

from app.schemas import ReassembledEssay

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

    async def fake_reassemble(collection, query, top_k, filters):
        # Crude routing: the criterion label is in filters["criterion"]
        crit = filters.get("criterion", "")
        return {
            "ta": refs_ta,
            "cc": refs_cc,
            "lr": refs_lr,
            "gr": refs_gr,
        }[crit]

    with patch(
        "app.services.search_service.search_and_reassemble",
        new=AsyncMock(side_effect=fake_reassemble),
    ) as mock_sa, patch(
        "app.services.per_criterion_rag.settings"
    ) as mock_settings:
        mock_settings.qdrant_collection_writing = "writing_samples"
        from app.services import per_criterion_rag

        out = await per_criterion_rag.retrieve("should students wear uniforms", "TASK_2")

    assert set(out.keys()) == {"ta", "cc", "lr", "gr"}
    assert out["ta"][0].parent_id == "ta1"
    assert out["gr"][0].parent_id == "gr1"
    # 4 queries were issued
    assert mock_sa.await_count == 4

@pytest.mark.asyncio
async def test_retrieve_degrades_to_empty_on_rag_failure():
    async def boom(*args, **kwargs):
        raise RuntimeError("qdrant down")

    with patch(
        "app.services.search_service.search_and_reassemble",
        new=AsyncMock(side_effect=boom),
    ), patch(
        "app.services.per_criterion_rag.settings"
    ) as mock_settings:
        mock_settings.qdrant_collection_writing = "writing_samples"
        from app.services import per_criterion_rag

        out = await per_criterion_rag.retrieve("topic", "TASK_2")

    assert out == {"ta": [], "cc": [], "lr": [], "gr": []}

