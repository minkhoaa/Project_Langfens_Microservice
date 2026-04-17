import os
import pytest

QDRANT_ENDPOINT = os.getenv("QDRANT_ENDPOINT", "")
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY", "")

skip_no_qdrant = pytest.mark.skipif(
    not QDRANT_ENDPOINT, reason="QDRANT_ENDPOINT not set"
)


@skip_no_qdrant
@pytest.mark.asyncio
async def test_reassemble_returns_full_essays():
    from unittest.mock import patch
    with patch("app.config.settings.qdrant_endpoint", QDRANT_ENDPOINT), \
         patch("app.config.settings.qdrant_api_key", QDRANT_API_KEY):
        from app.services.search_service import search_and_reassemble

        results = await search_and_reassemble(
            collection="writing_samples",
            query="education and technology",
            top_k=2,
            filters={"band_overall": {"gte": 7.0, "lte": 9.0}, "task_type": "TASK_2"},
        )

    assert len(results) > 0
    for r in results:
        assert r.parent_id
        assert len(r.text) > 100
        assert r.metadata.get("band_overall", 0) >= 7.0
        assert "\n\n" in r.text


@skip_no_qdrant
@pytest.mark.asyncio
async def test_grammar_search_still_works():
    from unittest.mock import patch
    with patch("app.config.settings.qdrant_endpoint", QDRANT_ENDPOINT), \
         patch("app.config.settings.qdrant_api_key", QDRANT_API_KEY):
        from app.services.search_service import search

        results = await search(
            collection="grammar_knowledge",
            query="subject verb agreement",
            top_k=3,
        )

    assert len(results) > 0
    assert results[0].text
    assert results[0].score > 0
