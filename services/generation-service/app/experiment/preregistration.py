"""Primary endpoints, abstention policy, and statistical preregistration (RG09-S03).

Implements normative research obligations from:
- generation_baseline/research/ANALYSIS_PLAN.md (Primary endpoint, paired contrasts, resampling unit)
- generation_baseline/contracts/JSON_SCHEMAS.json ($defs/ExperimentManifest.primary_endpoint)

Invariants:
1. Primary endpoint is strictly: independent_final_PASS / all_assigned.
2. Abstention rule: UNCERTAIN, timeout, runtime failure, or missing output are non-PASS (fail-closed).
3. Resampling unit is dataset_item_id, paired across A, B, and C (never questions as independent units).
4. Paired contrasts: C - A and C - B differences with 95% bootstrap confidence intervals.
5. Fails closed: Post-hoc endpoint switching after observing C results raises PostHocEndpointSwitchingForbiddenError.
"""

from __future__ import annotations

import hashlib
import json
import random
from typing import Any, Dict, List, Literal, Optional, Tuple

from pydantic import Field, model_validator

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import ExecutionStatus, OutputAvailability


class PostHocEndpointSwitchingForbiddenError(RuntimeError):
    """Raised when an attempt is made to alter the preregistered primary endpoint after observing performance."""


class AnalysisPlanTamperedError(RuntimeError):
    """Raised when analysis plan hash does not match preregistered SHA256."""


class StatisticalPlanValidationError(ValueError):
    """Raised when observation data is invalid or missing required arms."""


class PairedContrastEstimate(CanonicalBaseModel):
    """Estimated difference in pass proportion between two arms with confidence intervals."""

    contrast_name: str  # "C_minus_A" or "C_minus_B"
    point_estimate: float
    ci_lower: float
    ci_upper: float
    confidence_level: float = 0.95
    p_value_approx: float


class DomainAnalysisResult(CanonicalBaseModel):
    """Statistical summary for a specific domain (Reading or Grammar)."""

    domain: Literal["READING", "GRAMMAR"]
    total_assigned: int
    evaluable_count: int
    abstained_count: int
    arm_pass_rates: Dict[str, float]
    contrasts: List[PairedContrastEstimate]


class StatisticalContrastsResult(CanonicalBaseModel):
    """Full preregistered contrast report across domains and pooled analysis."""

    plan_id: str
    plan_sha256: str
    primary_endpoint: str
    reading_result: Optional[DomainAnalysisResult] = None
    grammar_result: Optional[DomainAnalysisResult] = None
    pooled_contrasts: List[PairedContrastEstimate] = Field(default_factory=list)


def _compute_analysis_plan_hash(
    plan_id: str,
    primary_endpoint: str,
    abstention_rule: str,
    resampling_unit: str,
    paired_contrasts: List[str],
    confidence_level: float,
) -> str:
    canonical_content = f"{plan_id}:{primary_endpoint}:{abstention_rule}:{resampling_unit}:{json.dumps(paired_contrasts)}:{confidence_level}"
    return hashlib.sha256(canonical_content.encode("utf-8")).hexdigest()


class PreregisteredAnalysisPlan(CanonicalBaseModel):
    """Immutable preregistration document fixing endpoints, contrasts, and analysis policies."""

    plan_id: str = "prereg-rq2-2026-v1"
    primary_endpoint: str = "independent_final_PASS / all_assigned"
    abstention_rule: str = "UNCERTAIN, timeout, failed validation, and missing external evaluation counted as non-PASS"
    resampling_unit: str = "dataset_item_id"
    paired_contrasts: List[str] = Field(default_factory=lambda: ["C_minus_A", "C_minus_B"])
    confidence_level: float = 0.95
    num_bootstrap_replicates: int = 1000
    seed: int = 2026
    is_pinned: bool = True
    plan_sha256: str = ""

    @model_validator(mode="before")
    @classmethod
    def populate_hash(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if not data.get("plan_sha256"):
                plan_id = data.get("plan_id", "prereg-rq2-2026-v1")
                primary_endpoint = data.get("primary_endpoint", "independent_final_PASS / all_assigned")
                abstention_rule = data.get(
                    "abstention_rule",
                    "UNCERTAIN, timeout, failed validation, and missing external evaluation counted as non-PASS",
                )
                resampling_unit = data.get("resampling_unit", "dataset_item_id")
                paired_contrasts = data.get("paired_contrasts", ["C_minus_A", "C_minus_B"])
                confidence_level = data.get("confidence_level", 0.95)
                data["plan_sha256"] = _compute_analysis_plan_hash(
                    plan_id=plan_id,
                    primary_endpoint=primary_endpoint,
                    abstention_rule=abstention_rule,
                    resampling_unit=resampling_unit,
                    paired_contrasts=paired_contrasts,
                    confidence_level=confidence_level,
                )
        return data

    def compute_plan_hash(self) -> str:
        """Computes deterministic SHA256 of the frozen analysis parameters."""
        return _compute_analysis_plan_hash(
            plan_id=self.plan_id,
            primary_endpoint=self.primary_endpoint,
            abstention_rule=self.abstention_rule,
            resampling_unit=self.resampling_unit,
            paired_contrasts=self.paired_contrasts,
            confidence_level=self.confidence_level,
        )

    def assert_plan_unmodified(self, observed_plan_sha: str) -> None:
        """Enforces that analysis plan has not been tampered with or modified post-hoc."""
        expected_sha = self.compute_plan_hash()
        if observed_plan_sha != expected_sha:
            raise AnalysisPlanTamperedError(
                f"Analysis plan SHA256 mismatch. Expected '{expected_sha}', got '{observed_plan_sha}'"
            )

    def switch_endpoint(self, new_endpoint: str) -> None:
        """Forbidden operation: Switching endpoint post-hoc fails closed."""
        raise PostHocEndpointSwitchingForbiddenError(
            f"Cannot switch primary endpoint from '{self.primary_endpoint}' to '{new_endpoint}'. "
            "Post-hoc endpoint selection is strictly forbidden by research protocol (prompt-sprint-09-03:26)."
        )

    def evaluate_item_pass(
        self,
        verdict: str,
        execution_status: ExecutionStatus,
        output_availability: OutputAvailability,
    ) -> float:
        """Evaluates whether an assignment meets the strict primary pass criteria.

        Invariants:
        - Must be PASS.
        - Must be COMPLETED.
        - Must have NORMALIZED or PARSEABLE output.
        - UNCERTAIN, FAIL, TIMED_OUT, or missing evaluation returns 0.0 (non-PASS).
        """
        if verdict != "PASS":
            return 0.0
        if execution_status != ExecutionStatus.COMPLETED:
            return 0.0
        if output_availability not in (OutputAvailability.NORMALIZED, OutputAvailability.PARSEABLE):
            return 0.0
        return 1.0

    def compute_domain_contrasts(
        self,
        domain: Literal["READING", "GRAMMAR"],
        paired_scores: Dict[str, Dict[str, float]],
    ) -> DomainAnalysisResult:
        """Computes paired contrasts (C - A, C - B) and 95% bootstrap CIs for a single domain.

        Args:
            domain: "READING" or "GRAMMAR"
            paired_scores: mapping of dataset_item_id -> {"A": 0.0|1.0, "B": 0.0|1.0, "C": 0.0|1.0}
        """
        if not paired_scores:
            raise StatisticalPlanValidationError(f"No paired observations provided for domain {domain}")

        item_ids = sorted(paired_scores.keys())
        n_items = len(item_ids)

        diffs_ca: List[float] = []
        diffs_cb: List[float] = []
        a_scores: List[float] = []
        b_scores: List[float] = []
        c_scores: List[float] = []

        for item_id in item_ids:
            scores = paired_scores[item_id]
            if "A" not in scores or "B" not in scores or "C" not in scores:
                raise StatisticalPlanValidationError(
                    f"Item {item_id} is missing observations for required arms (has {list(scores.keys())})"
                )
            a_val = float(scores["A"])
            b_val = float(scores["B"])
            c_val = float(scores["C"])
            a_scores.append(a_val)
            b_scores.append(b_val)
            c_scores.append(c_val)
            diffs_ca.append(c_val - a_val)
            diffs_cb.append(c_val - b_val)

        pass_a = sum(a_scores) / n_items
        pass_b = sum(b_scores) / n_items
        pass_c = sum(c_scores) / n_items
        diff_ca_mean = sum(diffs_ca) / n_items
        diff_cb_mean = sum(diffs_cb) / n_items

        rng = random.Random(self.seed)
        boot_ca: List[float] = []
        boot_cb: List[float] = []

        for _ in range(self.num_bootstrap_replicates):
            sample_ca = [diffs_ca[rng.randint(0, n_items - 1)] for _ in range(n_items)]
            sample_cb = [diffs_cb[rng.randint(0, n_items - 1)] for _ in range(n_items)]
            boot_ca.append(sum(sample_ca) / n_items)
            boot_cb.append(sum(sample_cb) / n_items)

        boot_ca.sort()
        boot_cb.sort()

        alpha = 1.0 - self.confidence_level
        low_idx = int((alpha / 2) * self.num_bootstrap_replicates)
        high_idx = int((1 - alpha / 2) * self.num_bootstrap_replicates)

        ci_ca_low = boot_ca[low_idx]
        ci_ca_high = boot_ca[high_idx]
        ci_cb_low = boot_cb[low_idx]
        ci_cb_high = boot_cb[high_idx]

        # Approximate p-value from bootstrap null exclusion
        p_ca = (
            sum(1 for val in boot_ca if val <= 0.0) / len(boot_ca)
            if pass_c >= pass_a
            else sum(1 for val in boot_ca if val >= 0.0) / len(boot_ca)
        )
        p_cb = (
            sum(1 for val in boot_cb if val <= 0.0) / len(boot_cb)
            if pass_c >= pass_b
            else sum(1 for val in boot_cb if val >= 0.0) / len(boot_cb)
        )

        contrast_ca = PairedContrastEstimate(
            contrast_name="C_minus_A",
            point_estimate=diff_ca_mean,
            ci_lower=min(ci_ca_low, diff_ca_mean),
            ci_upper=max(ci_ca_high, diff_ca_mean),
            confidence_level=self.confidence_level,
            p_value_approx=max(0.001, p_ca),
        )

        contrast_cb = PairedContrastEstimate(
            contrast_name="C_minus_B",
            point_estimate=diff_cb_mean,
            ci_lower=min(ci_cb_low, diff_cb_mean),
            ci_upper=max(ci_cb_high, diff_cb_mean),
            confidence_level=self.confidence_level,
            p_value_approx=max(0.001, p_cb),
        )
        return DomainAnalysisResult(
            domain=domain,
            total_assigned=n_items,
            evaluable_count=n_items,
            abstained_count=0,
            arm_pass_rates={"A": pass_a, "B": pass_b, "C": pass_c},
            contrasts=[contrast_ca, contrast_cb],
        )
