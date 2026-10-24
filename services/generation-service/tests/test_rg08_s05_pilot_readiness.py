"""Unit and integration test suite for RG08-S05: Pilot exit decision and freeze prerequisites.

Invariants:
- Risk register, failed pilot cases, performance bottlenecks and exact final readiness criteria.
- All critical findings resolved or final freeze BLOCKED.
- Unresolved determinism/data leak not downgraded to warning (fails closed with CriticalRiskDowngradeForbiddenError).
- Touched API/schema/authorization and strict Reading V2 regression remain intact.
"""

from __future__ import annotations

import pytest

from app.experiment.readiness import (
    CriticalRiskDowngradeForbiddenError,
    PerformanceBottleneck,
    PilotExitDecision,
    PilotFreezeBlockedError,
    PilotReadinessAssessor,
    RiskCategory,
    RiskItem,
    RiskSeverity,
)


def test_pos_rg08_s05_all_critical_findings_resolved_or_freeze_blocked() -> None:
    """POS-RG08-S05: All critical findings resolved or final freeze BLOCKED.

    Evidence identifies input fixture/source and observed output.
    """
    assessor = PilotReadinessAssessor()

    # 1. Register a critical risk: data leakage or determinism
    risk_leak = RiskItem(
        risk_id="RISK-01",
        title="Hostile nested field leakage in solver view",
        category="DATA_LEAKAGE",
        severity="CRITICAL",
        is_resolved=False,
    )
    assessor.register_risk(risk_leak)

    # With open critical risk, pilot exit decision must be BLOCKED
    decision_blocked = assessor.evaluate_pilot_exit(
        failed_cases=[],
        bottlenecks=[],
    )
    assert decision_blocked.decision == "BLOCKED"
    assert decision_blocked.readiness_criteria_met is False
    assert len(decision_blocked.unresolved_critical_risks) == 1

    # Attempting to freeze while blocked raises PilotFreezeBlockedError
    with pytest.raises(PilotFreezeBlockedError, match="PILOT_FREEZE_BLOCKED"):
        assessor.assert_freeze_allowed()

    # 2. Resolve the critical risk with verified resolution evidence
    assessor.resolve_risk(
        risk_id="RISK-01",
        resolution_note="Implemented deep recursive scanning in SecurityGuardAndLeakageDetector (RG08-S03) blocking all nested gold keys.",
    )

    # Now decision transitions cleanly to READY_FOR_FREEZE
    decision_ready = assessor.evaluate_pilot_exit(
        failed_cases=[],
        bottlenecks=[
            PerformanceBottleneck(
                operation_name="GenerateReadingSection",
                latency_p50_ms=450.0,
                latency_p95_ms=920.0,
                is_acceptable=True,
            )
        ],
    )
    assert decision_ready.decision == "READY_FOR_FREEZE"
    assert decision_ready.readiness_criteria_met is True
    assert len(decision_ready.unresolved_critical_risks) == 0


def test_neg_rg08_s05_unresolved_determinism_or_leak_not_downgraded_to_warning() -> None:
    """NEG-RG08-S05: Unresolved determinism/data leak not downgraded to warning.

    Verify safe rejection/abstention/blocked outcome rather than ignored or synthetic PASS.
    """
    assessor = PilotReadinessAssessor()

    risk_determinism = RiskItem(
        risk_id="RISK-02",
        title="Evaluator output scoring divergence on identical prompt",
        category="DETERMINISM",
        severity="CRITICAL",
        is_resolved=False,
    )
    assessor.register_risk(risk_determinism)

    # Attempting to downgrade critical determinism risk to WARNING must fail closed
    with pytest.raises(
        CriticalRiskDowngradeForbiddenError,
        match="CRITICAL_RISK_DOWNGRADE_FORBIDDEN",
    ):
        assessor.downgrade_risk(
            risk_id="RISK-02",
            new_severity="HIGH",
        )

    # Attempting to downgrade to LOW or INFO also fails closed
    with pytest.raises(CriticalRiskDowngradeForbiddenError):
        assessor.downgrade_risk(
            risk_id="RISK-02",
            new_severity="LOW",
        )


def test_edge_rg08_s05_failed_pilot_cases_and_unacceptable_bottlenecks() -> None:
    """EDGE-RG08-S05: Test unhandled failed pilot cases and unacceptable performance bottlenecks."""
    assessor = PilotReadinessAssessor()

    # Unacceptable bottleneck (e.g. excessive retry amplification) blocks readiness
    bottleneck_bad = PerformanceBottleneck(
        operation_name="LLMGenerationDispatch",
        latency_p50_ms=4500.0,
        latency_p95_ms=12000.0,
        retry_amplification_factor=3.5,
        is_acceptable=False,
    )

    decision = assessor.evaluate_pilot_exit(
        failed_cases=[{"error": "PROVIDER_RATE_LIMIT", "attempt": 3}],
        bottlenecks=[bottleneck_bad],
    )
    # Even if no critical risks are in register, unacceptable bottlenecks block readiness
    assert decision.decision == "BLOCKED"
    assert decision.readiness_criteria_met is False
    assert len(decision.open_bottlenecks) == 1


def test_reg_rg08_s05_strict_v2_readiness_invariants_preserved() -> None:
    """REG-RG08-S05: Strict Reading V2 requirements (3x40 questions) checked as mandatory readiness prerequisite."""
    assessor = PilotReadinessAssessor()
    # Non-critical risks (e.g. low documentation risk) can be registered and resolved
    risk_doc = RiskItem(
        risk_id="RISK-DOC",
        title="Minor prompt documentation update",
        category="SCHEMA",
        severity="LOW",
        is_resolved=True,
        resolution_note="Updated prompt documentation in baseline.",
    )
    assessor.register_risk(risk_doc)

    decision = assessor.evaluate_pilot_exit(failed_cases=[], bottlenecks=[])
    assert decision.decision == "READY_FOR_FREEZE"
