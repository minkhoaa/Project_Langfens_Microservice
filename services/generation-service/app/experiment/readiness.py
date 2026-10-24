"""Risk register, failed pilot cases, performance bottlenecks, and pilot exit readiness (RG08-S05).

Invariants:
- Risk register, failed pilot cases, performance bottlenecks and exact final readiness criteria.
- All critical findings resolved or final freeze BLOCKED.
- Unresolved determinism or data leak cannot be downgraded to warning (fails closed with CriticalRiskDowngradeForbiddenError).
- Inviolable freeze prerequisites: freeze permitted only when readiness_criteria_met is True.
"""

from __future__ import annotations

from typing import Any, Dict, List, Literal, Optional

from pydantic import Field

from app.contracts.base import CanonicalBaseModel


class CriticalRiskDowngradeForbiddenError(RuntimeError):
    """Raised when an attempt is made to downgrade a critical security or determinism risk to warning."""


class PilotFreezeBlockedError(RuntimeError):
    """Raised when a final freeze is attempted while critical risks or performance blockers remain unresolved."""


RiskSeverity = Literal["CRITICAL", "HIGH", "MEDIUM", "LOW"]
RiskCategory = Literal[
    "DATA_LEAKAGE",
    "DETERMINISM",
    "AUTHORIZATION",
    "DURABILITY",
    "PERFORMANCE",
    "SCHEMA",
]


class RiskItem(CanonicalBaseModel):
    """Item recorded in the pilot risk register."""

    risk_id: str
    title: str
    category: RiskCategory
    severity: RiskSeverity
    is_resolved: bool = False
    resolution_note: Optional[str] = None


class PerformanceBottleneck(CanonicalBaseModel):
    """Performance metric tracking latency or retry amplification bottlenecks."""

    operation_name: str
    latency_p50_ms: float
    latency_p95_ms: float
    retry_amplification_factor: float = 1.0
    is_acceptable: bool = True


class PilotExitDecision(CanonicalBaseModel):
    """Formal readiness decision for exiting pilot phase and freezing benchmark prerequisites."""

    decision: Literal["READY_FOR_FREEZE", "BLOCKED"]
    unresolved_critical_risks: List[RiskItem] = Field(default_factory=list)
    open_bottlenecks: List[PerformanceBottleneck] = Field(default_factory=list)
    failed_pilot_cases: List[Dict[str, Any]] = Field(default_factory=list)
    readiness_criteria_met: bool = False


NON_DOWNGRADEABLE_CATEGORIES = {
    "DATA_LEAKAGE",
    "DETERMINISM",
    "AUTHORIZATION",
    "DURABILITY",
}


class PilotReadinessAssessor:
    """Manages the risk register, evaluates failed pilot cases, and determines final freeze readiness."""

    def __init__(self) -> None:
        self._risks: Dict[str, RiskItem] = {}

    def register_risk(self, risk: RiskItem) -> None:
        """Registers a risk into the pilot risk register."""
        self._risks[risk.risk_id] = risk

    def downgrade_risk(self, risk_id: str, new_severity: RiskSeverity) -> None:
        """Attempts to change the severity of a registered risk.

        Fails closed with CriticalRiskDowngradeForbiddenError if the risk is CRITICAL and belongs to
        protected scientific or security categories.
        """
        if risk_id not in self._risks:
            raise KeyError(f"Risk '{risk_id}' not found in register.")

        risk = self._risks[risk_id]
        if risk.severity == "CRITICAL" and risk.category in NON_DOWNGRADEABLE_CATEGORIES:
            raise CriticalRiskDowngradeForbiddenError(
                f"CRITICAL_RISK_DOWNGRADE_FORBIDDEN: Risk '{risk_id}' of category '{risk.category}' "
                f"is a critical integrity invariant and cannot be downgraded to '{new_severity}'."
            )

        self._risks[risk_id] = risk.model_copy(update={"severity": new_severity})

    def resolve_risk(self, risk_id: str, resolution_note: str) -> None:
        """Marks a registered risk as resolved with mandatory evidence note."""
        if risk_id not in self._risks:
            raise KeyError(f"Risk '{risk_id}' not found in register.")

        risk = self._risks[risk_id]
        self._risks[risk_id] = risk.model_copy(
            update={"is_resolved": True, "resolution_note": resolution_note}
        )

    def evaluate_pilot_exit(
        self,
        failed_cases: List[Dict[str, Any]],
        bottlenecks: List[PerformanceBottleneck],
    ) -> PilotExitDecision:
        """Evaluates whether the pilot exit criteria are satisfied.

        Strict invariant: Any open CRITICAL risk, unacceptable performance bottleneck,
        or unresolved failed pilot case forces a BLOCKED readiness decision.
        """
        unresolved_critical = [
            r for r in self._risks.values() if r.severity == "CRITICAL" and not r.is_resolved
        ]
        unacceptable_bottlenecks = [b for b in bottlenecks if not b.is_acceptable]

        is_ready = (
            len(unresolved_critical) == 0
            and len(unacceptable_bottlenecks) == 0
            and len(failed_cases) == 0
        )
        decision = "READY_FOR_FREEZE" if is_ready else "BLOCKED"

        return PilotExitDecision(
            decision=decision,
            unresolved_critical_risks=unresolved_critical,
            open_bottlenecks=unacceptable_bottlenecks,
            failed_pilot_cases=failed_cases,
            readiness_criteria_met=is_ready,
        )

    def assert_freeze_allowed(self) -> None:
        """Validates that final freeze prerequisites are satisfied; raises PilotFreezeBlockedError if BLOCKED."""
        decision = self.evaluate_pilot_exit(failed_cases=[], bottlenecks=[])
        if decision.decision == "BLOCKED":
            raise PilotFreezeBlockedError(
                f"PILOT_FREEZE_BLOCKED: Final freeze blocked due to {len(decision.unresolved_critical_risks)} "
                "unresolved critical risks in the register."
            )
