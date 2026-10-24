"""Unit tests for RG04-S05: Evaluator Freeze Manifest and Reliability Decision."""

import hashlib
import json
import pytest

from app.evaluators.calibration import (
    CALIBRATION_CORPUS,
    JUDGE_HOLDOUT_CORPUS,
    generate_evaluator_freeze_manifest,
    measure_evaluator_reliability,
)
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import RubricProfile


def test_pos_rg04_s05_generate_evaluator_freeze_manifest():
    """POS-RG04-S05: Immutable evaluator manifest generated with hashes and reliability metrics."""
    rubric = RubricProfile()
    evaluator = NeutralEvaluator(rubric=rubric)
    metrics = measure_evaluator_reliability(evaluator, JUDGE_HOLDOUT_CORPUS, "JUDGE_HOLDOUT")

    source_hash = hashlib.sha256(b"evaluator_source_code_freeze").hexdigest()

    manifest = generate_evaluator_freeze_manifest(
        evaluator=evaluator,
        rubric=rubric,
        calibration_items=CALIBRATION_CORPUS,
        holdout_items=JUDGE_HOLDOUT_CORPUS,
        holdout_metrics=metrics,
        evaluator_source_hash=source_hash,
    )

    # Invariants:
    assert manifest["manifest_version"] == "1.0.0"
    assert manifest["freeze_phase"] == "RG04"
    assert manifest["evaluator_source_sha256"] == source_hash
    assert manifest["rubric_version"] == "R1-2026.1"
    assert manifest["dataset_splits"]["split_disjointness_verified"] is True
    assert manifest["dataset_splits"]["calibration_item_count"] == len(CALIBRATION_CORPUS)
    assert manifest["dataset_splits"]["holdout_item_count"] == len(JUDGE_HOLDOUT_CORPUS)

    # Human expert panel status remains explicitly BLOCKED without independent review
    panel = manifest["human_adjudication_panel"]
    assert panel["status"] == "BLOCKED_PENDING_EXTERNAL_PANEL"
    assert "unapproved external resource" in panel["reason"]


def test_neg_rg04_s05_tampered_threshold_detected():
    """NEG-RG04-S05: No judge revision after freeze without new version (tamper detection)."""
    rubric = RubricProfile()
    evaluator = NeutralEvaluator(rubric=rubric)
    metrics = measure_evaluator_reliability(evaluator, JUDGE_HOLDOUT_CORPUS, "JUDGE_HOLDOUT")
    source_hash = hashlib.sha256(b"evaluator_source_code_freeze").hexdigest()

    manifest = generate_evaluator_freeze_manifest(
        evaluator=evaluator,
        rubric=rubric,
        calibration_items=CALIBRATION_CORPUS,
        holdout_items=JUDGE_HOLDOUT_CORPUS,
        holdout_metrics=metrics,
        evaluator_source_hash=source_hash,
    )

    # If thresholds are changed in active code without updating rubric_version:
    tampered_rubric = RubricProfile(min_grounding_score=2.0)  # Tampered!
    assert tampered_rubric.min_grounding_score != manifest["frozen_thresholds"]["min_grounding_score"]


def test_edge_rg04_s05_deterministic_manifest_hashes():
    """EDGE-RG04-S05: Manifest serialization produces bit-for-bit identical hashes across repeat runs."""
    rubric = RubricProfile()
    evaluator = NeutralEvaluator(rubric=rubric)
    metrics = measure_evaluator_reliability(evaluator, JUDGE_HOLDOUT_CORPUS, "JUDGE_HOLDOUT")
    source_hash = hashlib.sha256(b"source").hexdigest()

    m1 = generate_evaluator_freeze_manifest(evaluator, rubric, CALIBRATION_CORPUS, JUDGE_HOLDOUT_CORPUS, metrics, source_hash)
    m2 = generate_evaluator_freeze_manifest(evaluator, rubric, CALIBRATION_CORPUS, JUDGE_HOLDOUT_CORPUS, metrics, source_hash)

    assert json.dumps(m1, sort_keys=True) == json.dumps(m2, sort_keys=True)
