import json
from pathlib import Path

import pytest

from app.config import settings
from fastapi.testclient import TestClient
from app.main import app


def _write_scenario(path: Path, slug: str, title: str, difficulty: str) -> None:
    payload = {
        "id": f"00000000-0000-0000-0000-{slug[-12:].replace('-', '')[:12].ljust(12, '0')}",
        "slug": slug,
        "title": title,
        "difficulty": difficulty,
        "ielts_part": "SITUATIONAL",
        "context": "You are in a guided speaking situation and need to respond clearly with relevant details.",
        "user_role": "An IELTS learner practicing spoken English",
        "agent_role": "A roleplay partner guiding the conversation",
        "opening_prompt": "Welcome. Let's begin with a natural introduction before we move to the main task.",
        "target_vocabulary": ["confident", "clarify", "respond", "detail", "situation"],
        "target_grammar": ["Present Simple", "Follow-up questions"],
        "suggested_topics": ["daily life", "plans"],
        "duration_min": 5,
        "turn_count_target": 8,
    }
    path.write_text(json.dumps(payload), encoding="utf-8")


@pytest.mark.asyncio
async def test_list_roleplay_scenarios_returns_sorted_catalog(tmp_path):
    from app.routers.speaking import list_roleplay_scenarios

    scenarios_dir = tmp_path / "scenarios"
    scenarios_dir.mkdir()
    _write_scenario(scenarios_dir / "hotel.json", "hotel-check-in", "Hotel Check-in", "BEGINNER")
    _write_scenario(scenarios_dir / "airport.json", "airport-help-desk", "Airport Help Desk", "INTERMEDIATE")

    original_dir = settings.roleplay_scenarios_dir
    settings.roleplay_scenarios_dir = str(scenarios_dir)

    try:
        response = await list_roleplay_scenarios()
    finally:
        settings.roleplay_scenarios_dir = original_dir

    assert response.total == 2
    assert [scenario.slug for scenario in response.scenarios] == [
        "hotel-check-in",
        "airport-help-desk",
    ]


@pytest.mark.asyncio
async def test_list_roleplay_scenarios_skips_invalid_files(tmp_path):
    from app.routers.speaking import list_roleplay_scenarios

    scenarios_dir = tmp_path / "scenarios"
    scenarios_dir.mkdir()
    _write_scenario(scenarios_dir / "restaurant.json", "restaurant-ordering", "Restaurant Ordering", "BEGINNER")
    (scenarios_dir / "broken.json").write_text("{not-valid-json}", encoding="utf-8")

    original_dir = settings.roleplay_scenarios_dir
    settings.roleplay_scenarios_dir = str(scenarios_dir)

    try:
        response = await list_roleplay_scenarios()
    finally:
        settings.roleplay_scenarios_dir = original_dir

    assert response.total == 1
    assert response.scenarios[0].slug == "restaurant-ordering"


def test_start_roleplay_session_returns_opening_prompt(tmp_path, monkeypatch):
    scenarios_dir = tmp_path / "scenarios"
    scenarios_dir.mkdir()
    _write_scenario(scenarios_dir / "hotel.json", "hotel-check-in", "Hotel Check-in", "BEGINNER")

    from app.routers import speaking as speaking_router

    monkeypatch.setattr(speaking_router, "ensure_speaking_memory_collection", lambda: None)

    original_dir = settings.roleplay_scenarios_dir
    settings.roleplay_scenarios_dir = str(scenarios_dir)

    try:
        with TestClient(app) as client:
            response = client.post(
                "/api/v1/speaking/roleplay/start",
                json={"user_id": "user-123", "scenario_slug": "hotel-check-in"},
            )
    finally:
        settings.roleplay_scenarios_dir = original_dir

    assert response.status_code == 200
    body = response.json()
    assert body["user_id"] == "user-123"
    assert body["scenario"]["slug"] == "hotel-check-in"
    assert body["agent_message"]["speaker"] == "agent"
    assert body["agent_message"]["turn_index"] == 1


def test_turn_endpoint_appends_user_and_agent_turns(tmp_path, monkeypatch):
    scenarios_dir = tmp_path / "scenarios"
    scenarios_dir.mkdir()
    _write_scenario(scenarios_dir / "airport.json", "airport-help-desk", "Airport Help Desk", "INTERMEDIATE")

    from app.routers import speaking as speaking_router

    monkeypatch.setattr(speaking_router, "ensure_speaking_memory_collection", lambda: None)

    async def fake_generate_agent_reply(*args, **kwargs):
        return "Could you describe your suitcase, please?"

    monkeypatch.setattr(speaking_router, "generate_agent_reply", fake_generate_agent_reply)

    original_dir = settings.roleplay_scenarios_dir
    settings.roleplay_scenarios_dir = str(scenarios_dir)

    try:
        with TestClient(app) as client:
            start_resp = client.post(
                "/api/v1/speaking/roleplay/start",
                json={"user_id": "user-456", "scenario_slug": "airport-help-desk"},
            )
            session_id = start_resp.json()["session_id"]

            turn_resp = client.post(
                "/api/v1/speaking/roleplay/turn",
                json={
                    "session_id": session_id,
                    "user_id": "user-456",
                    "utterance": "My luggage did not arrive on carousel 7.",
                },
            )
    finally:
        settings.roleplay_scenarios_dir = original_dir

    assert start_resp.status_code == 200
    assert turn_resp.status_code == 200
    body = turn_resp.json()
    assert body["scenario_slug"] == "airport-help-desk"
    assert body["user_message"]["speaker"] == "user"
    assert body["agent_message"]["speaker"] == "agent"
    assert body["turn_count"] == 3


def test_turn_endpoint_rejects_wrong_user(tmp_path, monkeypatch):
    scenarios_dir = tmp_path / "scenarios"
    scenarios_dir.mkdir()
    _write_scenario(scenarios_dir / "restaurant.json", "restaurant-ordering", "Restaurant Ordering", "BEGINNER")

    from app.routers import speaking as speaking_router

    monkeypatch.setattr(speaking_router, "ensure_speaking_memory_collection", lambda: None)

    original_dir = settings.roleplay_scenarios_dir
    settings.roleplay_scenarios_dir = str(scenarios_dir)

    try:
        with TestClient(app) as client:
            start_resp = client.post(
                "/api/v1/speaking/roleplay/start",
                json={"user_id": "owner", "scenario_slug": "restaurant-ordering"},
            )
            session_id = start_resp.json()["session_id"]
            turn_resp = client.post(
                "/api/v1/speaking/roleplay/turn",
                json={
                    "session_id": session_id,
                    "user_id": "intruder",
                    "utterance": "I want to order pasta.",
                },
            )
    finally:
        settings.roleplay_scenarios_dir = original_dir

    assert start_resp.status_code == 200
    assert turn_resp.status_code == 403
