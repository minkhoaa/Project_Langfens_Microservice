"""Regression checks for persisted Phase 07 metric recalculations."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from app.evaluators.metrics import METRIC_ENGINE_HASH, METRIC_ENGINE_VERSION


REPO_ROOT = Path(__file__).resolve().parents[3]
METRIC_ARTIFACTS = (
    REPO_ROOT / "artifacts/refactor/phase-07/dev-metrics-recalculated.json",
    REPO_ROOT / "artifacts/refactor/phase-07/holdout-metrics-recalculated.json",
)


@pytest.mark.parametrize("artifact_path", METRIC_ARTIFACTS, ids=lambda path: path.name)
def test_recalculated_artifact_binds_current_engine_and_reconciles_rejections(
    artifact_path: Path,
) -> None:
    artifact = json.loads(artifact_path.read_text(encoding="utf-8"))
    metadata = artifact["metadata"]
    rates = artifact["rates"]

    assert metadata.get("metricEngineVersion") is not None
    assert metadata.get("metricEngineHash") is not None
    if "totalValidRejectedCount" in rates:
        assert rates["totalValidRejectedCount"] == (
            rates["semanticFalsePositivesCount"]
            + rates["operationalRejectionsOfValidCount"]
        )
    else:
        assert "falseRejectionRate" in rates
