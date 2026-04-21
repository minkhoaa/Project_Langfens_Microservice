"""
tests/test_speaking_memory.py
=============================
Tests for speaking memory save + retrieval and Qdrant-unavailable resilience.

Run:
    pytest tests/test_speaking_memory.py -v
"""

from __future__ import annotations

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_errors(words: list[str]) -> list[dict]:
    return [{"word": w, "type": "incorrect"} for w in words]


# ---------------------------------------------------------------------------
# summarise_memory_for_prompt  (pure function, no mocks needed)
# ---------------------------------------------------------------------------

from app.services.speaking_memory_service import summarise_memory_for_prompt


class TestSummariseMemoryForPrompt:
    def test_empty_hits_returns_empty_string(self):
        assert summarise_memory_for_prompt([]) == ""

    def test_no_errors_no_low_score_returns_empty(self):
        hits = [{"text": "hello", "errors": [], "score": 0.95}]
        assert summarise_memory_for_prompt(hits) == ""

    def test_single_error_word_appears_in_output(self):
        hits = [{"text": "hello", "errors": [{"word": "think", "type": "incorrect"}], "score": 0.6}]
        result = summarise_memory_for_prompt(hits)
        assert "think" in result
        assert result.startswith("•")

    def test_caps_at_three_problem_words(self):
        errors = _make_errors(["apple", "banana", "cherry", "date", "elderberry"])
        hits = [{"text": "...", "errors": errors, "score": 0.5}]
        result = summarise_memory_for_prompt(hits)
        # Only 3 words should appear
        mentioned = [w for w in ["apple", "banana", "cherry", "date", "elderberry"] if w in result]
        assert len(mentioned) <= 3

    def test_two_low_score_hits_adds_delivery_bullet(self):
        hits = [
            {"text": "a", "errors": [], "score": 0.40},
            {"text": "b", "errors": [], "score": 0.45},
        ]
        result = summarise_memory_for_prompt(hits)
        assert "unclear" in result or "short" in result

    def test_deduplicates_error_words(self):
        hits = [
            {"text": "a", "errors": [{"word": "think", "type": "incorrect"}], "score": 0.5},
            {"text": "b", "errors": [{"word": "think", "type": "incorrect"}], "score": 0.5},
        ]
        result = summarise_memory_for_prompt(hits)
        # "think" should appear only once
        assert result.count('"think"') == 1


# ---------------------------------------------------------------------------
# save_speaking_memory  (mocks embedding + qdrant client)
# ---------------------------------------------------------------------------

from app.services.speaking_memory_service import save_speaking_memory


class TestSaveSpeakingMemory:
    @pytest.mark.asyncio
    async def test_successful_save_calls_upsert(self):
        fake_vector = [0.1] * 768
        mock_client = MagicMock()

        with (
            patch(
                "app.services.speaking_memory_service.embed_query",
                new=AsyncMock(return_value=fake_vector),
            ),
            patch(
                "app.services.speaking_memory_service.get_qdrant_client",
                return_value=mock_client,
            ),
        ):
            await save_speaking_memory(
                user_id="user-1",
                session_id="sess-1",
                scenario_slug="restaurant-ordering",
                text="I would like to order the pasta",
                errors=[{"word": "pasta", "type": "incorrect"}],
                score=0.72,
            )

        mock_client.upsert.assert_called_once()
        call_kwargs = mock_client.upsert.call_args.kwargs
        assert call_kwargs["collection_name"] == "speaking_memory"
        point = call_kwargs["points"][0]
        assert point.vector == fake_vector
        assert point.payload["user_id"] == "user-1"
        assert point.payload["score"] == 0.72
        assert len(point.payload["errors"]) == 1

    @pytest.mark.asyncio
    async def test_embedding_failure_does_not_raise(self):
        """If embedding fails, save_speaking_memory must return None silently."""
        with patch(
            "app.services.speaking_memory_service.embed_query",
            new=AsyncMock(side_effect=RuntimeError("Gemini API down")),
        ):
            # Must not raise
            result = await save_speaking_memory(
                user_id="user-1",
                session_id="sess-1",
                scenario_slug="restaurant-ordering",
                text="hello",
                errors=[],
                score=0.5,
            )
        assert result is None

    @pytest.mark.asyncio
    async def test_qdrant_upsert_failure_does_not_raise(self):
        """If Qdrant is unavailable, save must return None silently."""
        fake_vector = [0.0] * 768
        mock_client = MagicMock()
        mock_client.upsert.side_effect = ConnectionError("Qdrant is down")

        with (
            patch(
                "app.services.speaking_memory_service.embed_query",
                new=AsyncMock(return_value=fake_vector),
            ),
            patch(
                "app.services.speaking_memory_service.get_qdrant_client",
                return_value=mock_client,
            ),
        ):
            result = await save_speaking_memory(
                user_id="u",
                session_id="s",
                scenario_slug="slug",
                text="hello",
                errors=[],
                score=0.5,
            )
        assert result is None


# ---------------------------------------------------------------------------
# search_speaking_memory  (mocks embedding + qdrant client)
# ---------------------------------------------------------------------------

from app.services.speaking_memory_service import search_speaking_memory


class TestSearchSpeakingMemory:
    @pytest.mark.asyncio
    async def test_successful_search_returns_compact_dicts(self):
        fake_vector = [0.2] * 768

        # Build a fake Qdrant hit
        fake_point = MagicMock()
        fake_point.payload = {
            "text": "I tink this is good",
            "errors": [{"word": "think", "type": "incorrect"}],
            "score": 0.68,
        }
        fake_point.score = 0.91  # similarity score from Qdrant

        mock_hits = MagicMock()
        mock_hits.points = [fake_point]

        mock_client = MagicMock()
        mock_client.query_points.return_value = mock_hits

        with (
            patch(
                "app.services.speaking_memory_service.embed_query",
                new=AsyncMock(return_value=fake_vector),
            ),
            patch(
                "app.services.speaking_memory_service.get_qdrant_client",
                return_value=mock_client,
            ),
        ):
            results = await search_speaking_memory(
                user_id="user-1",
                query_text="I think this is good",
                scenario_slug="restaurant-ordering",
            )

        assert len(results) == 1
        assert results[0]["text"] == "I tink this is good"
        assert results[0]["errors"][0]["word"] == "think"
        assert results[0]["score"] == 0.68

    @pytest.mark.asyncio
    async def test_qdrant_unavailable_returns_empty_list(self):
        """If Qdrant is down, search must return [] silently."""
        fake_vector = [0.0] * 768
        mock_client = MagicMock()
        mock_client.query_points.side_effect = ConnectionError("Qdrant is down")

        with (
            patch(
                "app.services.speaking_memory_service.embed_query",
                new=AsyncMock(return_value=fake_vector),
            ),
            patch(
                "app.services.speaking_memory_service.get_qdrant_client",
                return_value=mock_client,
            ),
        ):
            results = await search_speaking_memory(
                user_id="user-1",
                query_text="hello",
            )

        assert results == []

    @pytest.mark.asyncio
    async def test_embedding_failure_returns_empty_list(self):
        with patch(
            "app.services.speaking_memory_service.embed_query",
            new=AsyncMock(side_effect=RuntimeError("API key invalid")),
        ):
            results = await search_speaking_memory(
                user_id="user-1",
                query_text="hello",
            )
        assert results == []

    @pytest.mark.asyncio
    async def test_user_id_filter_is_always_applied(self):
        """Verify the Qdrant filter always includes user_id."""
        fake_vector = [0.0] * 768
        mock_client = MagicMock()
        mock_hits = MagicMock()
        mock_hits.points = []
        mock_client.query_points.return_value = mock_hits

        with (
            patch(
                "app.services.speaking_memory_service.embed_query",
                new=AsyncMock(return_value=fake_vector),
            ),
            patch(
                "app.services.speaking_memory_service.get_qdrant_client",
                return_value=mock_client,
            ),
        ):
            await search_speaking_memory(user_id="user-abc", query_text="hello")

        call_kwargs = mock_client.query_points.call_args.kwargs
        qdrant_filter = call_kwargs["query_filter"]
        condition_keys = [c.key for c in qdrant_filter.must]
        assert "user_id" in condition_keys


# ---------------------------------------------------------------------------
# /turn-with-speech endpoint: Qdrant down → roleplay still works
# ---------------------------------------------------------------------------

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


class TestTurnWithSpeechMemoryResilience:
    """
    Qdrant is completely unavailable. The /turn-with-speech endpoint must
    still return 200 — memory failure must be transparent to the caller.
    """

    def test_roleplay_continues_when_qdrant_is_down(self):
        # Patch session, scenario, ollama, and memory all at once
        fake_session = {
            "session_id": "test-sess",
            "user_id": "user-1",
            "scenario_slug": "restaurant-ordering",
            "turns": [
                {"speaker": "agent", "text": "Welcome!", "turn_index": 1, "timestamp": "2026-01-01T00:00:00+00:00"}
            ],
            "started_at": "2026-01-01T00:00:00+00:00",
            "updated_at": "2026-01-01T00:00:00+00:00",
        }
        fake_user_turn = {"speaker": "user", "text": "I would like pasta", "turn_index": 2, "timestamp": "2026-01-01T00:00:01+00:00"}
        fake_agent_turn = {"speaker": "agent", "text": "Great choice!", "turn_index": 3, "timestamp": "2026-01-01T00:00:02+00:00"}
        fake_session_after = {**fake_session, "turns": fake_session["turns"] + [fake_user_turn, fake_agent_turn]}

        from app.schemas import RoleplayScenario

        fake_scenario = RoleplayScenario(
            id="s1", slug="restaurant-ordering", title="Restaurant Ordering",
            difficulty="BEGINNER", ielts_part="SITUATIONAL",
            context="You are ordering food.", user_role="Customer",
            agent_role="Server", opening_prompt="Welcome!",
            target_vocabulary=["menu", "order"], duration_min=5,
        )

        with (
            patch("app.routers.speaking.get_session", return_value=fake_session),
            patch("app.routers.speaking.get_scenario_by_slug", return_value=fake_scenario),
            patch(
                "app.routers.speaking.append_turn",
                side_effect=[
                    (fake_session_after, fake_user_turn),
                    (fake_session_after, fake_agent_turn),
                ],
            ),
            patch(
                "app.routers.speaking.generate_roleplay_reply",
                new=AsyncMock(return_value=("Great choice!", "")),
            ),
            # Qdrant completely unavailable
            patch(
                "app.routers.speaking.search_speaking_memory",
                new=AsyncMock(side_effect=ConnectionError("Qdrant is down")),
            ),
            patch(
                "app.routers.speaking.save_speaking_memory",
                new=AsyncMock(side_effect=ConnectionError("Qdrant is down")),
            ),
        ):
            resp = client.post(
                "/api/v1/speaking/roleplay/turn-with-speech",
                json={
                    "session_id": "test-sess",
                    "user_id": "user-1",
                    "text": "I would like pasta",
                    "errors": [{"word": "pasta", "type": "incorrect"}],
                    "score": 0.72,
                },
            )

        assert resp.status_code == 200
        body = resp.json()
        assert body["agent_message"]["text"] == "Great choice!"
        assert "session_id" in body
