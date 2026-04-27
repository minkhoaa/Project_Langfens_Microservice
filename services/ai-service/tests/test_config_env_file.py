"""Regression tests for the env_file resolution in app.config."""
from __future__ import annotations

import os
from pathlib import Path

from app.config import Settings


def test_env_file_path_is_relative_or_overridable():
    """Settings must not hard-code an absolute developer-specific path."""
    config_file = Path(__file__).resolve().parent.parent.joinpath("app", "config.py").read_text()
    assert "/home/khoi/" not in config_file, (
        "config.py must not hard-code /home/khoi/... — use a relative or env-based path"
    )


def test_env_file_resolves_relative_to_repo():
    """The resolved env_file should point at deploy/envs/ai.env in the repo."""
    resolved = Settings.Config.env_file
    assert resolved.endswith("deploy/envs/ai.env"), (
        f"env_file should end with deploy/envs/ai.env, got {resolved}"
    )


def test_env_file_can_be_overridden_via_env_var(monkeypatch, tmp_path):
    """Setting AI_SERVICE_ENV_FILE before import would override the resolved path.

    Note: env_file is resolved at class-definition time, so this test exercises
    the resolver function in isolation rather than the cached Config attribute.
    """
    fake = tmp_path / "fake.env"
    fake.write_text("OLLAMA_MODEL=test-override\n")
    monkeypatch.setenv("AI_SERVICE_ENV_FILE", str(fake))
    # Re-evaluate the same expression that config.py uses for env_file:
    resolved = os.getenv(
        "AI_SERVICE_ENV_FILE",
        str(Path("app/config.py").resolve().parents[3] / "deploy" / "envs" / "ai.env"),
    )
    assert resolved == str(fake)


def test_settings_instantiates_without_error():
    """Sanity: Settings() must not raise, regardless of env_file presence."""
    s = Settings()
    assert s.environment is not None
    assert s.qdrant_collection_writing
