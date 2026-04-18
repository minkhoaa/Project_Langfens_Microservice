import json
from pathlib import Path

import pytest

from app.config import settings


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
