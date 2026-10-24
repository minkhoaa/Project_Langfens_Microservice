"""Unit tests for RG04-S02: Sealed Judge Holdout and Access Control."""

import pytest
from app.evaluators.calibration import (
    CALIBRATION_CORPUS,
    JUDGE_HOLDOUT_CORPUS,
    CalibrationAccessController,
    HoldoutAccessViolationError,
    verify_split_disjointness,
)


def test_pos_rg04_s02_holdout_disjointness():
    """POS-RG04-S02: No subject/family overlap and label access controls tested."""
    is_disjoint, violations = verify_split_disjointness(CALIBRATION_CORPUS, JUDGE_HOLDOUT_CORPUS)
    assert is_disjoint is True, f"Split disjointness violated: {violations}"
    assert len(violations) == 0

    # Explicitly assert zero source_family_id overlap
    calib_families = {it.source_family_id for it in CALIBRATION_CORPUS}
    holdout_families = {it.source_family_id for it in JUDGE_HOLDOUT_CORPUS}
    assert len(calib_families.intersection(holdout_families)) == 0


def test_neg_rg04_s02_calibration_access_controller_blocks_holdout_gold():
    """NEG-RG04-S02: Calibration queries cannot read judge-holdout gold.

    Enforces that calibration access controller raises HoldoutAccessViolationError.
    """
    controller = CalibrationAccessController(JUDGE_HOLDOUT_CORPUS)

    # Allowed: calibration items can be read
    controller.assert_can_access_for_calibration("calib-tfng-01")

    # Forbidden: holdout item access raises HoldoutAccessViolationError
    with pytest.raises(HoldoutAccessViolationError) as exc_info:
        controller.assert_can_access_for_calibration("holdout-tfng-01")
    assert "belongs to sealed JUDGE_HOLDOUT split" in str(exc_info.value)


def test_edge_rg04_s02_detect_near_duplicate_leakage():
    """EDGE-RG04-S02: Near-duplicate passage text triggers disjointness violation."""
    from app.evaluators.calibration import BenchmarkStratum, CalibrationItem
    from app.evaluators.rubric import EvaluationVerdict

    leaky_holdout = [
        CalibrationItem(
            item_id="holdout-leaky-01",
            source_family_id="fam-unique-99",  # Unique family
            domain="reading",
            question_type="TFNG",
            stratum=BenchmarkStratum.VALID,
            # Identical passage text to calib-tfng-01!
            passage_text="The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. Observations show accelerated melting along the coast.",
            question_data={"prompt": "statement"},
            reference_verdict=EvaluationVerdict.PASS,
            reference_rationale="Leaked copy",
        )
    ]

    is_disjoint, violations = verify_split_disjointness(CALIBRATION_CORPUS, leaky_holdout)
    assert is_disjoint is False
    assert any("Passage text leakage" in v for v in violations)
