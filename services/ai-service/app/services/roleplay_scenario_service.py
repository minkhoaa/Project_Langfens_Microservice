import json
import logging
from pathlib import Path

from app.config import settings
from app.schemas import RoleplayScenario

logger = logging.getLogger(__name__)
_FALLBACK_SCENARIOS_DIR = Path(__file__).resolve().parents[1] / "data" / "scenarios"


def load_scenarios() -> list[RoleplayScenario]:
    scenarios_dir = Path(settings.roleplay_scenarios_dir)
    if not scenarios_dir.exists():
        scenarios_dir = _FALLBACK_SCENARIOS_DIR
    if not scenarios_dir.exists():
        return []

    scenarios: list[RoleplayScenario] = []
    for scenario_path in sorted(scenarios_dir.glob("*.json")):
        try:
            payload = json.loads(scenario_path.read_text(encoding="utf-8"))
            scenarios.append(RoleplayScenario.model_validate(payload))
        except Exception as exc:
            logger.warning("Skipping invalid scenario file %s: %s", scenario_path, exc)

    scenarios.sort(key=lambda scenario: (scenario.difficulty, scenario.title.lower(), scenario.slug))
    return scenarios


def get_scenario_by_slug(slug: str) -> RoleplayScenario | None:
    normalized_slug = slug.strip().lower()
    for scenario in load_scenarios():
        if scenario.slug.lower() == normalized_slug:
            return scenario
    return None
