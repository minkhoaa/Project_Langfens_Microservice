"""Paired Assignment Manager and Common Task Fixture Mapping (RG07-S01).

Invariants:
- One experiment item mapped to A/B/C with immutable prompt/model/source pins and stable IDs.
- All three configs receive identical task/spec and comparable constraints.
- Duplicate assignment or provider fallback cannot alter a frozen row.
- Provider fallback is strictly forbidden (fails closed).
"""

from __future__ import annotations

from typing import Dict, List, Literal, Optional, Tuple, Union

from app.contracts.research import (
    ExperimentAssignment,
    PairedTaskFixture,
    StandaloneGrammarRequest,
    StandaloneReadingRequest,
)


class DuplicateAssignmentError(RuntimeError):
    """Raised when an attempt is made to register or overwrite an already frozen assignment."""


class ProviderFallbackForbiddenError(RuntimeError):
    """Raised when provider or foundation model differs from immutable pin."""


class PairedAssignmentManager:
    """Manages frozen paired assignments across experimental arms A, B, and C."""

    def __init__(self) -> None:
        self._by_key: Dict[Tuple[str, str, int], ExperimentAssignment] = {}
        self._by_id: Dict[str, ExperimentAssignment] = {}

    def create_paired_assignments(
        self, fixture: PairedTaskFixture, attempt_number: int = 1
    ) -> List[ExperimentAssignment]:
        """Creates deterministic, stable paired assignments for A, B, and C."""
        assignments: List[ExperimentAssignment] = []
        for arm in ("A", "B", "C"):
            assignment_id = f"{fixture.dataset_item_id}__arm_{arm}__att{attempt_number}"
            assignment = ExperimentAssignment(
                assignment_id=assignment_id,
                dataset_item_id=fixture.dataset_item_id,
                configuration_id=arm,  # type: ignore[arg-type]
                attempt_number=attempt_number,
                run_id=None,
                result_ref=None,
            )
            assignments.append(assignment)
        return assignments

    def register_assignment(self, assignment: ExperimentAssignment) -> None:
        """Registers an assignment row into the ledger, rejecting duplicate registration."""
        key = (
            assignment.dataset_item_id,
            assignment.configuration_id,
            assignment.attempt_number,
        )
        if key in self._by_key or assignment.assignment_id in self._by_id:
            raise DuplicateAssignmentError(
                f"Duplicate assignment detected: '{assignment.assignment_id}' already registered."
            )
        self._by_key[key] = assignment
        self._by_id[assignment.assignment_id] = assignment

    def get_assignment(self, assignment_id: str) -> Optional[ExperimentAssignment]:
        return self._by_id.get(assignment_id)

    def list_assignments(self) -> List[ExperimentAssignment]:
        return list(self._by_id.values())

    def verify_model_provider_pin(
        self, requested_model_id: str, pinned_model_id: str
    ) -> None:
        """Fails closed if the requested foundation model or provider deviates from the pin."""
        if requested_model_id != pinned_model_id:
            raise ProviderFallbackForbiddenError(
                f"Provider fallback forbidden: requested '{requested_model_id}' does not match pinned '{pinned_model_id}'."
            )

    def map_arm_request(
        self,
        fixture: PairedTaskFixture,
        arm: Literal["A", "B", "C"],
        run_id: str,
        attempt_number: int = 1,
    ) -> Union[StandaloneReadingRequest, StandaloneGrammarRequest]:
        """Maps common fixture into an authenticated arm-specific research request.

        Ensures identical task specifications and constraints across all arms.
        """
        if fixture.domain == "READING":
            if not fixture.reading_task:
                raise ValueError("Reading task specification is missing in fixture.")
            return StandaloneReadingRequest(
                run_id=run_id,
                dataset_item_id=fixture.dataset_item_id,
                configuration_id=arm,
                task=fixture.reading_task,
                source_pack_id=fixture.source.source_id,
                is_research_mode=True,
            )
        elif fixture.domain == "GRAMMAR":
            if not fixture.grammar_task or not fixture.rule_pack:
                raise ValueError("Grammar task specification or rule pack is missing in fixture.")
            return StandaloneGrammarRequest(
                run_id=run_id,
                dataset_item_id=fixture.dataset_item_id,
                configuration_id=arm,
                task=fixture.grammar_task,
                rule_pack=fixture.rule_pack,
                is_research_mode=True,
            )
        else:
            raise ValueError(f"Unsupported research domain: {fixture.domain}")
