import time
import pytest
from app.services.roleplay_session_service import _memory_sessions, get_session, create_session
from app.schemas import RoleplayScenario
from app.routers import speaking as speaking_router
from fastapi.testclient import TestClient
from app.main import app
from unittest.mock import patch, AsyncMock


def test_session_fallback_expires_correctly(monkeypatch):
    # Temporarily set TTL to 1 second for testing
    monkeypatch.setattr("app.services.roleplay_session_service.SESSION_TTL_SECONDS", 1)
    # Re-initialize the TTLCache with the new TTL
    from cachetools import TTLCache
    import app.services.roleplay_session_service as rss
    rss._memory_sessions = TTLCache(maxsize=10, ttl=1)
    rss._redis_disabled = True
    rss._redis_client = None

    scenario = RoleplayScenario(
        id="123", slug="test-scenario", title="Test", difficulty="BEGINNER",
        ielts_part="SITUATIONAL", context="ctx", user_role="user", agent_role="agent",
        opening_prompt="hello", target_vocabulary=[], target_grammar=[], suggested_topics=[],
        duration_min=1, turn_count_target=2
    )
    
    session = create_session("user-1", scenario)
    session_id = session["session_id"]
    
    # Should exist immediately
    assert get_session(session_id) is not None
    
    # Wait for TTL to expire
    time.sleep(1.1)
    
    # Should be evicted
    assert get_session(session_id) is None


@pytest.mark.asyncio
async def test_roleplay_works_when_qdrant_unavailable(monkeypatch):
    client = TestClient(app)
    
    # Mock Qdrant to throw an exception
    async def mock_search(*args, **kwargs):
        raise Exception("Qdrant connection refused")
        
    monkeypatch.setattr("app.routers.speaking.search_speaking_memory", mock_search)
    monkeypatch.setattr("app.routers.speaking.get_scenario_by_slug", lambda x: RoleplayScenario(
        id="123", slug="test", title="Test", difficulty="BEGINNER",
        ielts_part="SITUATIONAL", context="ctx", user_role="user", agent_role="agent",
        opening_prompt="hello", target_vocabulary=[], target_grammar=[], suggested_topics=[],
        duration_min=1, turn_count_target=2
    ))
    
    # Mock LLM generation so we don't need Ollama running
    async def mock_generate(*args, **kwargs):
        return "This is a fallback reply.", "No feedback."
    monkeypatch.setattr("app.routers.speaking.generate_roleplay_reply", mock_generate)
    
    # Create a session
    import app.services.roleplay_session_service as rss
    rss._redis_disabled = True
    rss._redis_client = None
    session = rss.create_session("user-1", rss.RoleplayScenario(
        id="123", slug="test", title="Test", difficulty="BEGINNER",
        ielts_part="SITUATIONAL", context="ctx", user_role="user", agent_role="agent",
        opening_prompt="hello", target_vocabulary=[], target_grammar=[], suggested_topics=[],
        duration_min=1, turn_count_target=2
    ))
    
    # Make request
    resp = client.post("/api/v1/speaking/roleplay/turn-with-speech", json={
        "session_id": session["session_id"],
        "user_id": "user-1",
        "text": "Hello",
        "errors": [{"word": "hello", "type": "incorrect"}],
        "score": 0.5
    })
    
    # Should succeed despite Qdrant error (isolated failure)
    assert resp.status_code == 200
    data = resp.json()
    assert data["agent_message"]["text"] == "This is a fallback reply."


@pytest.mark.asyncio
async def test_memory_retrieval_uses_new_strategy_error_words(monkeypatch):
    client = TestClient(app)
    
    # Track the query text used
    captured_query = {}
    
    async def mock_search(user_id, query_text, scenario_slug, limit):
        captured_query["text"] = query_text
        return []
        
    monkeypatch.setattr("app.routers.speaking.search_speaking_memory", mock_search)
    monkeypatch.setattr("app.routers.speaking.get_scenario_by_slug", lambda x: RoleplayScenario(
        id="123", slug="test", title="Test", difficulty="BEGINNER",
        ielts_part="SITUATIONAL", context="ctx", user_role="user", agent_role="agent",
        opening_prompt="hello", target_vocabulary=[], target_grammar=[], suggested_topics=[],
        duration_min=1, turn_count_target=2
    ))
    
    async def mock_generate(*args, **kwargs):
        return "Reply", "Feedback"
    monkeypatch.setattr("app.routers.speaking.generate_roleplay_reply", mock_generate)
    
    import app.services.roleplay_session_service as rss
    rss._redis_disabled = True
    rss._redis_client = None
    session = rss.create_session("user-1", rss.RoleplayScenario(
        id="123", slug="test", title="Test", difficulty="BEGINNER",
        ielts_part="SITUATIONAL", context="ctx", user_role="user", agent_role="agent",
        opening_prompt="hello", target_vocabulary=[], target_grammar=[], suggested_topics=[],
        duration_min=1, turn_count_target=2
    ))
    
    # Make request with specific error words
    client.post("/api/v1/speaking/roleplay/turn-with-speech", json={
        "session_id": session["session_id"],
        "user_id": "user-1",
        "text": "I like to eat aplle",
        "errors": [{"word": "apple", "type": "incorrect"}],
        "score": 0.5
    })
    
    # Ensure memory search used the error word ("apple"), not the full text
    assert captured_query.get("text") == "apple"
