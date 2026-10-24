"""Unit tests for RG09-S03: Primary endpoints and statistical preregistration.

Objective: End-to-end pass definition, abstention rule, paired contrasts, resampling unit and CIs fixed.
Decisive acceptance condition: Statistical plan is human-readable, executable and pinned; no endpoint picked post-hoc.
"""

from __future__ import annotations

import pytest

from app.contracts.research import ExecutionStatus, OutputAvailability
from app.experiment.preregistration import (
    AnalysisPlanTamperedError,
    PairedContrastEstimate,
    PostHocEndpointSwitchingForbiddenError,
    PreregisteredAnalysisPlan,
    StatisticalPlanValidationError,
)


def test_pos_rg09_s03_pinned_plan_and_paired_contrasts():
    """POS-RG09-S03: Pinned analysis plan computes paired bootstrap contrasts and 95% CIs."""
    plan = PreregisteredAnalysisPlan()

    # 1. Plan is human-readable, executable, and pinned by SHA256
    assert plan.primary_endpoint == "independent_final_PASS / all_assigned"
    assert plan.resampling_unit == "dataset_item_id"
    assert len(plan.plan_sha256) == 64
    assert plan.is_pinned is True

    # 2. Simulate 28 paired items for Reading domain with known ground-truth pattern
    # Arm C outperforms B, and B outperforms A
    paired_scores = {}
    for i in range(1, 29):
        item_id = f"final-reading-{i:03d}"
        # A: 50% pass, B: 65% pass, C: 85% pass
        a_pass = 1.0 if (i % 2 == 0) else 0.0
        b_pass = 1.0 if (i % 3 != 0) else 0.0
        c_pass = 1.0 if (i % 5 != 0) else 0.0
        paired_scores[item_id] = {"A": a_pass, "B": b_pass, "C": c_pass}

    result = plan.compute_domain_contrasts("READING", paired_scores)

    # 3. Verify domain contrasts summary
    assert result.domain == "READING"
    assert result.total_assigned == 28
    assert len(result.contrasts) == 2

    c_minus_a = next(c for c in result.contrasts if c.contrast_name == "C_minus_A")
    c_minus_b = next(c for c in result.contrasts if c.contrast_name == "C_minus_B")

    # Point estimates match mean differences
    assert c_minus_a.point_estimate == pytest.approx(result.arm_pass_rates["C"] - result.arm_pass_rates["A"])
    assert c_minus_b.point_estimate == pytest.approx(result.arm_pass_rates["C"] - result.arm_pass_rates["B"])

    # 95% CIs bracket point estimates
    assert c_minus_a.ci_lower <= c_minus_a.point_estimate <= c_minus_a.ci_upper
    assert c_minus_b.ci_lower <= c_minus_b.point_estimate <= c_minus_b.ci_upper


def test_neg_rg09_s03_post_hoc_endpoint_switching_forbidden():
    """NEG-RG09-S03: Post-hoc endpoint switching and plan tampering fail closed with explicit errors."""
    plan = PreregisteredAnalysisPlan()

    # 1. Attempting to switch primary endpoint after observing arm C results raises error
    with pytest.raises(PostHocEndpointSwitchingForbiddenError) as exc_info:
        plan.switch_endpoint("evaluable_only_PASS / evaluable_assigned")
    assert "Post-hoc endpoint selection is strictly forbidden" in str(exc_info.value)

    # 2. Tampered plan SHA256 raises AnalysisPlanTamperedError
    with pytest.raises(AnalysisPlanTamperedError):
        plan.assert_plan_unmodified("0" * 64)


def test_edge_rg09_s03_abstention_fail_closed_and_missing_arm():
    """EDGE-RG09-S03: Abstentions/timeouts evaluate to 0.0 and missing arms raise validation error."""
    plan = PreregisteredAnalysisPlan()

    # 1. UNCERTAIN verdict evaluates strictly to 0.0 (fail-closed, not PASS)
    assert plan.evaluate_item_pass(
        verdict="UNCERTAIN",
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NORMALIZED,
    ) == 0.0

    # 2. Timeout evaluates to 0.0
    assert plan.evaluate_item_pass(
        verdict="PASS",
        execution_status=ExecutionStatus.TIMED_OUT,
        output_availability=OutputAvailability.PARSEABLE,
    ) == 0.0

    # 3. Missing / unparseable output evaluates to 0.0
    assert plan.evaluate_item_pass(
        verdict="PASS",
        execution_status=ExecutionStatus.COMPLETED,
        output_availability=OutputAvailability.NONE,
    ) == 0.0

    # 4. Incomplete paired observation (missing arm B) raises StatisticalPlanValidationError
    incomplete_scores = {
        "item-1": {"A": 1.0, "C": 1.0}  # Missing B!
    }
    with pytest.raises(StatisticalPlanValidationError) as exc_info:
        plan.compute_domain_contrasts("READING", incomplete_scores)
    assert "missing observations" in str(exc_info.value)


def test_reg_rg09_s03_analysis_plan_reproducibility():
    """REG-RG09-S03: Fixed random seed produces 100% reproducible bootstrap intervals."""
    plan1 = PreregisteredAnalysisPlan(seed=2026)
    plan2 = PreregisteredAnalysisPlan(seed=2026)

    scores = {f"it-{i}": {"A": 0.5, "B": 0.6, "C": 0.8} for i in range(25)}

    res1 = plan1.compute_domain_contrasts("READING", scores)
    res2 = plan2.compute_domain_contrasts("READING", scores)

    # Assert exact numerical determinism
    assert res1.contrasts[0].ci_lower == res2.contrasts[0].ci_lower
    assert res1.contrasts[0].ci_upper == res2.contrasts[0].ci_upper
    assert res1.contrasts[1].ci_lower == res2.contrasts[1].ci_lower
    assert res1.contrasts[1].ci_upper == res2.contrasts[1].ci_upper
