"""Unit tests for RG03-S01: Versioned Three-Tier Evaluation Rubric."""

import pytest
from app.evaluators.rubric import (
    DIMENSION_ANCHORS,
    CanonicalEvaluationResult,
    EvaluationVerdict,
    RubricDimension,
    RubricProfile,
    compute_output_sha256,
)


def test_pos_rg03_s01_rubric_dimension_anchors_and_thresholds():
    """POS-RG03-S01: Dimension anchors, applicability, threshold source and evidence fields are fixed."""
    rubric = RubricProfile()

    # Verify all 5 dimensions exist and have 1-5 anchors
    for dim in RubricDimension:
        anchors = DIMENSION_ANCHORS.get(dim)
        assert anchors is not None, f"Missing anchors for {dim}"
        assert set(anchors.keys()) == {1, 2, 3, 4, 5}
        for score, text in anchors.items():
            assert len(text) > 10, f"Anchor description too short for {dim}={score}"

    # Verify frozen thresholds
    assert rubric.rubric_version == "R1-2026.1"
    assert rubric.min_average_score == 3.5
    assert rubric.min_grounding_score == 3.0
    assert rubric.min_dimension_score == 2.0

    # Test passing scores
    valid_scores = {
        RubricDimension.CLARITY.value: 4.0,
        RubricDimension.FLUENCY.value: 4.5,
        RubricDimension.RELEVANCE.value: 4.0,
        RubricDimension.GROUNDING.value: 4.0,
        RubricDimension.ANSWERABILITY.value: 4.0,
    }
    is_pass, reason = rubric.evaluate_semantic_scores(valid_scores)
    assert is_pass is True
    assert reason is None


def test_neg_rg03_s01_fluent_but_ungrounded_fails():
    """NEG-RG03-S01: Beautiful fluent but wrong/ungrounded content cannot PASS.

    Grounding score <= 2.0 MUST fail unconditionally regardless of high fluency (5.0).
    """
    rubric = RubricProfile()

    # High fluency, high clarity, but ungrounded (fabricated passage details)
    hallucinated_scores = {
        RubricDimension.CLARITY.value: 5.0,
        RubricDimension.FLUENCY.value: 5.0,
        RubricDimension.RELEVANCE.value: 4.0,
        RubricDimension.GROUNDING.value: 2.0,  # Below minimum grounding of 3.0!
        RubricDimension.ANSWERABILITY.value: 4.0,
    }

    is_pass, reason = rubric.evaluate_semantic_scores(hallucinated_scores)
    assert is_pass is False
    assert "Grounding score 2.0 is below threshold 3.0" in reason
    assert "Beautiful but ungrounded content cannot PASS" in reason


def test_edge_rg03_s01_boundary_scores_and_missing_dimensions():
    """EDGE-RG03-S01: Missing dimensions or scores outside [1.0, 5.0] are rejected cleanly."""
    rubric = RubricProfile()

    # Missing a required dimension
    incomplete_scores = {
        RubricDimension.CLARITY.value: 4.0,
        RubricDimension.FLUENCY.value: 4.0,
    }
    is_pass, reason = rubric.evaluate_semantic_scores(incomplete_scores)
    assert is_pass is False
    assert "Missing required dimension" in reason

    # Out of range scores
    invalid_scores = {
        RubricDimension.CLARITY.value: 6.0,  # > 5.0
        RubricDimension.FLUENCY.value: 4.0,
        RubricDimension.RELEVANCE.value: 4.0,
        RubricDimension.GROUNDING.value: 4.0,
        RubricDimension.ANSWERABILITY.value: 4.0,
    }
    is_pass, reason = rubric.evaluate_semantic_scores(invalid_scores)
    assert is_pass is False
    assert "out of range [1, 5]" in reason
