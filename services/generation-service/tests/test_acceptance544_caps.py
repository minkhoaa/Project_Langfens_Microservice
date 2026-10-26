from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[3]


def test_compose_cannot_override_approved_parent_child_operation_budget():
    compose = yaml.safe_load((ROOT / "deploy/compose.benchmark-text.yaml").read_text())
    caps = dict(line.split("=", 1) for line in (ROOT / "deploy/envs/loop-caps.env").read_text().splitlines() if line and not line.startswith("#"))
    effective = dict(caps)
    effective.update(line.split("=", 1) for line in compose["services"]["generation-service"]["environment"])
    assert int(effective["LOOP_OPERATION_WALL_RESERVATION_SECONDS"]) == 60
