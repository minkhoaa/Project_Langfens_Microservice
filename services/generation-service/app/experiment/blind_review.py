"""Sealed gold vault and blind review export manager (RG09-S02).

Implements gold isolation, blind reviewer partitions, neutral exports and adjudication.
- generation_baseline/contracts/JSON_SCHEMAS.json ($defs/NeutralOutput, $defs/GenerationResult)

Invariants:
1. Blind review export: Reviewers cannot infer arm A/B/C, prompt versions, or models from IDs or metadata.
2. Neutral payload: Stripped of answers, internal verdicts, in-loop pass flags, trace refs, and private answers.
3. Sealed gold mapping: Mapping between blind_item_id and true assignment is stored in SealedGoldVault.
4. Gold smuggling prevention: Generator or Solver inputs containing gold or reference answers fail closed.
5. Adjudication policy: Multi-reviewer agreement and tie-breaking protocol.
"""

from __future__ import annotations

import hashlib
import hmac
import json
import secrets
from typing import Any, Dict, List, Literal, Optional, Set, Tuple
from uuid import uuid4

from pydantic import Field, field_validator

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    ExperimentAssignment,
    GenerationResult,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
)


class GoldSmugglingForbiddenError(RuntimeError):
    """Raised when gold answers or reference labels are embedded in Generator or Solver input."""


class SealedGoldAccessForbiddenError(RuntimeError):
    """Raised when an actor without EXPERIMENT_AUDITOR role attempts to unblind sealed gold."""


class BlindReviewValidationError(ValueError):
    """Raised when blind review export payload or review response is malformed."""


FORBIDDEN_GOLD_KEYS: Set[str] = {
    "_gold_answer",
    "gold_answer",
    "goldAnswer",
    "gold_key",
    "goldKey",
    "verified_gold",
    "verifiedGold",
    "reference_answer",
    "referenceAnswer",
    "target_answer",
    "targetAnswer",
    "correct_answer",
    "correctAnswer",
    "expert_label",
    "expertLabel",
    "in_loop_pass",
    "inLoopPass",
    "internal_verdict",
    "internalVerdict",
}


class BlindReviewQuestion(CanonicalBaseModel):
    """Sanitized question presented to a blind reviewer without answers or verdicts."""

    question_id: str
    question_type: str
    text: str
    options: List[str] = Field(default_factory=list)
    instructions: str


class BlindReviewItem(CanonicalBaseModel):
    """Sanitized evaluation item presented to a blind reviewer."""

    blind_item_id: str
    domain: Literal["READING", "GRAMMAR"]
    context_text: str
    questions: List[BlindReviewQuestion]
    reviewer_instructions: str = (
        "Rate the factual groundedness, grammatical accuracy, and clarity of questions. "
        "Do not assume any specific model, prompt, or experimental arm origin."
    )


class SealedGoldMappingEntry(CanonicalBaseModel):
    """Secure, tamper-evident mapping between a blind reviewer ID and ground-truth metadata."""

    blind_item_id: str
    actual_assignment_id: str
    actual_configuration_id: Literal["A", "B", "C"]
    dataset_item_id: str
    domain: Literal["READING", "GRAMMAR"]
    gold_answer_key: Dict[str, str] = Field(default_factory=dict)
    mapping_hash: str


class ReviewerVerdictSubmission(CanonicalBaseModel):
    """Evaluation verdict submitted by an independent human or blind reviewer."""

    blind_item_id: str
    reviewer_id: str
    verdict: Literal["PASS", "FAIL", "UNCERTAIN"]
    confidence: float = Field(..., ge=0.0, le=1.0)
    notes: Optional[str] = None


class AdjudicationOutcome(CanonicalBaseModel):
    """Reconciled multi-reviewer decision for a blind review item."""

    blind_item_id: str
    review_count: int
    unanimous: bool
    final_verdict: Literal["PASS", "FAIL", "UNCERTAIN", "ADJUDICATION_REQUIRED"]
    adjudicator_notes: Optional[str] = None


class SealedGoldVault:
    """Isolated cryptographic vault for storing sealed gold and unblinding keys."""

    def __init__(self, salt: Optional[bytes] = None) -> None:
        self._salt = salt or secrets.token_bytes(32)
        self._entries: Dict[str, SealedGoldMappingEntry] = {}
        self._is_sealed: bool = False

    @property
    def is_sealed(self) -> bool:
        return self._is_sealed

    def store_mapping(
        self,
        blind_item_id: str,
        assignment_id: str,
        configuration_id: Literal["A", "B", "C"],
        dataset_item_id: str,
        domain: Literal["READING", "GRAMMAR"],
        gold_answer_key: Dict[str, str],
    ) -> SealedGoldMappingEntry:
        """Stores a mapping entry and calculates its cryptographic tamper hash."""
        if self._is_sealed:
            raise RuntimeError("Cannot add mappings to an already sealed vault")

        entry_data = f"{blind_item_id}:{assignment_id}:{configuration_id}:{dataset_item_id}:{json.dumps(gold_answer_key, sort_keys=True)}"
        mac = hmac.new(self._salt, entry_data.encode("utf-8"), hashlib.sha256).hexdigest()

        entry = SealedGoldMappingEntry(
            blind_item_id=blind_item_id,
            actual_assignment_id=assignment_id,
            actual_configuration_id=configuration_id,
            dataset_item_id=dataset_item_id,
            domain=domain,
            gold_answer_key=gold_answer_key,
            mapping_hash=mac,
        )
        self._entries[blind_item_id] = entry
        return entry

    def seal_vault(self) -> str:
        """Seals the vault, computing a root SHA256 integrity hash across all mappings."""
        self._is_sealed = True
        sorted_hashes = sorted([e.mapping_hash for e in self._entries.values()])
        root_data = ":".join(sorted_hashes)
        return hashlib.sha256(root_data.encode("utf-8")).hexdigest()

    def get_mapping(
        self,
        blind_item_id: str,
        actor_role: str,
    ) -> SealedGoldMappingEntry:
        """Retrieves ground-truth unblinding mapping only for authorized auditors."""
        if actor_role != "EXPERIMENT_AUDITOR":
            raise SealedGoldAccessForbiddenError(
                f"Role '{actor_role}' is not authorized to access sealed gold mapping. "
                "Only 'EXPERIMENT_AUDITOR' is permitted."
            )
        if blind_item_id not in self._entries:
            raise KeyError(f"Blind item ID '{blind_item_id}' not found in vault")
        return self._entries[blind_item_id]


class BlindReviewManager:
    """Manages creation of neutral blind review exports and input gold scanning."""

    def __init__(self, vault: Optional[SealedGoldVault] = None) -> None:
        self._vault = vault or SealedGoldVault()
        self._reviewer_submissions: Dict[str, List[ReviewerVerdictSubmission]] = {}

    @property
    def vault(self) -> SealedGoldVault:
        return self._vault

    def assert_no_gold_in_input(self, payload: Any, context_label: str = "Input") -> None:
        """Recursively scans generator or solver input to ensure no gold answers are embedded."""
        if isinstance(payload, dict):
            for key, value in payload.items():
                if key in FORBIDDEN_GOLD_KEYS or any(
                    forbidden in key.lower() for forbidden in ["gold_answer", "reference_answer", "gold_key"]
                ):
                    raise GoldSmugglingForbiddenError(
                        f"{context_label} contains forbidden gold key '{key}'. "
                        "Gold answers cannot be embedded in Generator or Solver inputs."
                    )
                self.assert_no_gold_in_input(value, context_label=context_label)
        elif isinstance(payload, list):
            for item in payload:
                self.assert_no_gold_in_input(item, context_label=context_label)

    def export_blind_review_item(
        self,
        assignment: ExperimentAssignment,
        generation_result: GenerationResult,
        domain: Literal["READING", "GRAMMAR"],
        gold_answers: Dict[str, str],
    ) -> BlindReviewItem:
        """Exports a neutral, blind review item with no trace of arm or model identity."""
        if not generation_result.generated_content:
            raise BlindReviewValidationError(
                f"Cannot export blind review item for result {generation_result.run_id} without generated_content"
            )

        content = generation_result.generated_content

        # Generate a purely random blind review ID with no correlation to arm or run_id
        blind_item_id = f"rev-blind-{uuid4().hex[:16]}"

        # Store the unblinding mapping into the sealed vault
        self._vault.store_mapping(
            blind_item_id=blind_item_id,
            assignment_id=assignment.assignment_id,
            configuration_id=assignment.configuration_id,
            dataset_item_id=assignment.dataset_item_id,
            domain=domain,
            gold_answer_key=gold_answers,
        )

        # Convert questions to sanitized blind review questions
        sanitized_questions: List[BlindReviewQuestion] = []
        for q in content.questions:
            sanitized_q = BlindReviewQuestion(
                question_id=f"q-{uuid4().hex[:8]}",  # Re-randomize question IDs to avoid leaking order
                question_type=str(q.question_type),
                text=q.text,
                options=list(q.options),
                instructions=q.instructions,
            )
            sanitized_questions.append(sanitized_q)

        return BlindReviewItem(
            blind_item_id=blind_item_id,
            domain=domain,
            context_text=content.context_text,
            questions=sanitized_questions,
        )

    def submit_review(self, submission: ReviewerVerdictSubmission) -> None:
        """Records a blind review submission from an independent reviewer."""
        if submission.blind_item_id not in self._reviewer_submissions:
            self._reviewer_submissions[submission.blind_item_id] = []

        existing_reviewers = {s.reviewer_id for s in self._reviewer_submissions[submission.blind_item_id]}
        if submission.reviewer_id in existing_reviewers:
            raise BlindReviewValidationError(
                f"Reviewer '{submission.reviewer_id}' has already submitted a verdict for {submission.blind_item_id}"
            )

        self._reviewer_submissions[submission.blind_item_id].append(submission)

    def adjudicate_item(self, blind_item_id: str) -> AdjudicationOutcome:
        """Adjudicates review submissions using consensus and tie-breaker policies."""
        submissions = self._reviewer_submissions.get(blind_item_id, [])
        if not submissions:
            raise BlindReviewValidationError(f"No review submissions found for item {blind_item_id}")

        verdicts = [s.verdict for s in submissions]

        # Case 1: Unanimous consensus
        if len(set(verdicts)) == 1:
            return AdjudicationOutcome(
                blind_item_id=blind_item_id,
                review_count=len(submissions),
                unanimous=True,
                final_verdict=verdicts[0],
                adjudicator_notes="Unanimous consensus among all reviewers",
            )

        # Case 2: Split decision with 2 reviewers -> requires adjudication
        if len(submissions) == 2:
            return AdjudicationOutcome(
                blind_item_id=blind_item_id,
                review_count=2,
                unanimous=False,
                final_verdict="ADJUDICATION_REQUIRED",
                adjudicator_notes="Split verdict between 2 reviewers; escalated to expert adjudicator",
            )

        # Case 3: 3+ reviewers with clear majority
        pass_count = verdicts.count("PASS")
        fail_count = verdicts.count("FAIL")
        uncertain_count = verdicts.count("UNCERTAIN")

        if pass_count > len(verdicts) / 2:
            return AdjudicationOutcome(
                blind_item_id=blind_item_id,
                review_count=len(submissions),
                unanimous=False,
                final_verdict="PASS",
                adjudicator_notes=f"Majority PASS ({pass_count}/{len(verdicts)})",
            )
        elif fail_count > len(verdicts) / 2:
            return AdjudicationOutcome(
                blind_item_id=blind_item_id,
                review_count=len(submissions),
                unanimous=False,
                final_verdict="FAIL",
                adjudicator_notes=f"Majority FAIL ({fail_count}/{len(verdicts)})",
            )
        else:
            # Abstained / unresolved tie fails closed as UNCERTAIN
            return AdjudicationOutcome(
                blind_item_id=blind_item_id,
                review_count=len(submissions),
                unanimous=False,
                final_verdict="UNCERTAIN",
                adjudicator_notes=f"No majority reached; fails closed as UNCERTAIN ({pass_count}P/{fail_count}F/{uncertain_count}U)",
            )
