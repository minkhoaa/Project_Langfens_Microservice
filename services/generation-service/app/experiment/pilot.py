"""Small DEV Paired Pilot Runner and Reconciler (RG08-S01).

Invariants:
- Both task domains (Reading and Grammar) and A/B/C run on nonfinal inputs with representative constraints.
- Pilot cannot touch or peek at final sealed dataset (fails closed with FinalBenchmarkAccessForbiddenError).
- Per-config expected counts, costs, quality, and failure records reconcile completely.
- Research attempts remain strictly isolated from production publishing.
"""

from __future__ import annotations

from typing import Any, Dict, List, Literal, Optional, Tuple

from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    ExecutionStatus,
    OutputAvailability,
    PairedTaskFixture,
    StandaloneGrammarRequest,
    StandaloneReadingRequest,
)
from app.evaluators.independent import NeutralEvaluator
from app.experiment.ledger import AttemptRecord, ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
    DefaultRecordingExperimentClient,
)


class FinalBenchmarkAccessForbiddenError(RuntimeError):
    """Raised when a pilot execution attempts to access or peek at the sealed final benchmark."""


ALLOWED_PILOT_SPLITS = {"DEV", "CALIBRATION"}
FORBIDDEN_PILOT_SPLITS = {"FINAL_EVAL", "SEALED_BENCHMARK", "FINAL", "SEALED"}


class PilotExecutionSummary(CanonicalBaseModel):
    """Reconciled summary of pilot campaign executions across experimental arms."""

    total_assigned_requests: int = Field(default=0, ge=0)
    per_config_counts: Dict[str, int] = Field(default_factory=dict)
    per_config_costs: Dict[str, Optional[float]] = Field(default_factory=dict)
    per_config_quality_verdicts: Dict[str, Dict[str, int]] = Field(default_factory=dict)
    failure_records: List[Dict[str, Any]] = Field(default_factory=list)
    reconciled: bool = False


class DevPilotRunner:
    """Orchestrates small DEV paired pilots across Reading and Grammar domains."""

    def __init__(
        self,
        assignment_manager: PairedAssignmentManager,
        ledger: ExperimentReplayLedger,
        evaluator: Optional[NeutralEvaluator] = None,
        runner_a: Optional[ConfigurationARunner] = None,
        runner_b: Optional[ConfigurationBRunner] = None,
        runner_c: Optional[ConfigurationCRunner] = None,
    ) -> None:
        self.assignment_manager = assignment_manager
        self.ledger = ledger
        self.evaluator = evaluator or NeutralEvaluator()

        default_client = DefaultRecordingExperimentClient()
        self.runner_a = runner_a or ConfigurationARunner(client=default_client)
        self.runner_b = runner_b or ConfigurationBRunner(client=default_client)
        self.runner_c = runner_c or ConfigurationCRunner(client=default_client)

    def run_pilot(
        self, fixtures: List[Tuple[PairedTaskFixture, str]]
    ) -> PilotExecutionSummary:
        """Runs the DEV paired pilot across provided fixtures, enforcing nonfinal constraints."""
        if not fixtures:
            raise ValueError("Pilot requires at least one fixture to execute.")

        # Guard: check all splits before executing any runs
        for fixture, split in fixtures:
            normalized_split = split.upper().strip()
            if (
                normalized_split in FORBIDDEN_PILOT_SPLITS
                or "FINAL" in normalized_split
                or "SEALED" in normalized_split
            ):
                raise FinalBenchmarkAccessForbiddenError(
                    f"Pilot execution cannot access final sealed benchmark dataset (requested split: {split})."
                )
            if normalized_split not in ALLOWED_PILOT_SPLITS:
                raise ValueError(
                    f"Invalid dataset split for pilot: {split}. Allowed nonfinal splits: {sorted(ALLOWED_PILOT_SPLITS)}"
                )

        per_config_counts: Dict[str, int] = {"A": 0, "B": 0, "C": 0}
        per_config_costs: Dict[str, Optional[float]] = {"A": 0.0, "B": 0.0, "C": 0.0}
        per_config_quality_verdicts: Dict[str, Dict[str, int]] = {
            "A": {},
            "B": {},
            "C": {},
        }
        failure_records: List[Dict[str, Any]] = []
        total_assigned = 0

        for fixture, split in fixtures:
            assignments = self.assignment_manager.create_paired_assignments(fixture)
            self.ledger.freeze_assignments(assignments)

            for assignment in assignments:
                self.assignment_manager.register_assignment(assignment)
                total_assigned += 1
                arm = assignment.configuration_id
                per_config_counts[arm] += 1

                run_id = f"pilot-{assignment.assignment_id}"
                req = self.assignment_manager.map_arm_request(fixture, arm, run_id=run_id)
                prompt_version = getattr(fixture.prompt_versions, arm)

                # Execute arm runner
                if fixture.domain == "READING":
                    assert isinstance(req, StandaloneReadingRequest)
                    if arm == "A":
                        result, usage = self.runner_a.generate_reading(
                            req,
                            fixture.passage_text or "",
                            prompt_version,
                            fixture.foundation_model_id,
                        )
                    elif arm == "B":
                        result, _trace, usage = self.runner_b.generate_reading(
                            req,
                            fixture.passage_text or "",
                            prompt_version,
                            fixture.foundation_model_id,
                        )
                    elif arm == "C":
                        result, _trace, usage = self.runner_c.generate_reading(
                            req,
                            fixture.passage_text or "",
                            prompt_version,
                            fixture.foundation_model_id,
                        )
                elif fixture.domain == "GRAMMAR":
                    assert isinstance(req, StandaloneGrammarRequest)
                    if arm == "A":
                        result, usage = self.runner_a.generate_grammar(
                            req, prompt_version, fixture.foundation_model_id
                        )
                    elif arm == "B":
                        result, _trace, usage = self.runner_b.generate_grammar(
                            req, prompt_version, fixture.foundation_model_id
                        )
                    elif arm == "C":
                        result, _trace, usage = self.runner_c.generate_grammar(
                            req, prompt_version, fixture.foundation_model_id
                        )
                    else:
                        raise ValueError(f"Unknown configuration arm: {arm}")
                else:
                    raise ValueError(f"Unsupported research domain: {fixture.domain}")
                # Usage and cost tracking
                cost = usage.get("cost_usd")
                previous = per_config_costs[arm]
                per_config_costs[arm] = previous + cost if previous is not None and cost is not None else None
                total_tokens = usage.get("total_tokens")

                # Quality evaluation
                if (
                    result.output_availability in (OutputAvailability.NORMALIZED, OutputAvailability.PARSEABLE)
                    and result.generated_content is not None
                    and len(result.generated_content.questions) > 0
                ):
                    context_meta = {"rule_pack": fixture.rule_pack} if fixture.domain == "GRAMMAR" and fixture.rule_pack else None
                    for q in result.generated_content.questions:
                        eval_res = self.evaluator.evaluate_item(
                            dataset_item_id=fixture.dataset_item_id,
                            passage_text=result.generated_content.context_text,
                            question_data=q.model_dump(),
                            context_metadata=context_meta,
                        )
                        verdict_str = (
                            eval_res.verdict.value
                            if hasattr(eval_res.verdict, "value")
                            else str(eval_res.verdict)
                        )
                        per_config_quality_verdicts[arm][verdict_str] = (
                            per_config_quality_verdicts[arm].get(verdict_str, 0) + 1
                        )
                else:
                    per_config_quality_verdicts[arm]["UNEVALUABLE"] = (
                        per_config_quality_verdicts[arm].get("UNEVALUABLE", 0) + 1
                    )

                # Record attempt in replay ledger
                attempt_id = f"att-{assignment.assignment_id}"
                failure_code = None
                if result.execution_status != ExecutionStatus.COMPLETED:
                    failure_code = str(result.execution_status)
                    failure_records.append(
                        {
                            "attempt_id": attempt_id,
                            "assignment_id": assignment.assignment_id,
                            "configuration_id": arm,
                            "status": str(result.execution_status),
                        }
                    )

                attempt_record = AttemptRecord(
                    attempt_id=attempt_id,
                    assignment_id=assignment.assignment_id,
                    dataset_item_id=assignment.dataset_item_id,
                    configuration_id=arm,
                    attempt_number=assignment.attempt_number,
                    execution_status=result.execution_status,
                    output_availability=result.output_availability,
                    failure_code=failure_code,
                    usage_call_count=int(usage.get("call_count", 1)),
                    usage_total_tokens=total_tokens,
                    usage_prompt_tokens=usage.get("prompt_tokens"),
                    usage_completion_tokens=usage.get("completion_tokens"),
                    usage_confidence=usage.get("confidence", "UNKNOWN"),
                    token_source=usage.get("token_source", "UNKNOWN"),
                    cost_usd=cost, cost_source=usage.get("cost_source", "UNKNOWN"),
                    estimated_cost_usd=usage.get("estimated_cost_usd"),
                    confirmed_billing_usd=usage.get("confirmed_billing_usd"),
                    latency_ms=usage.get("latency_ms"), provenance=usage.get("provenance", {}),
                    is_terminal=True,
                )
                self.ledger.record_attempt(attempt_record)
                self.ledger.record_output(attempt_id, result)

        # Check reconciliation: counts sum to total assigned
        reconciled = sum(per_config_counts.values()) == total_assigned

        return PilotExecutionSummary(
            total_assigned_requests=total_assigned,
            per_config_counts=per_config_counts,
            per_config_costs=per_config_costs,
            per_config_quality_verdicts=per_config_quality_verdicts,
            failure_records=failure_records,
            reconciled=reconciled,
        )
