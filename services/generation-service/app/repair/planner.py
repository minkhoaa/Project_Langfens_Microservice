"""RepairPlanner for Langfens Loop Engine V2.

Implements P07-07 & P07-08:
- Selects smallest sufficient repair scope (QUESTION -> GROUP -> PASSAGE -> SECTION)
- Enforces evidence justification for answer / option repairs (rejects unsupported answer changes, T07-08)
- Summary group blank change invalidates and forces re-evaluation of whole shared group (T07-04)
- Passage change invalidates all downstream question evaluations (T07-05)
- Preserves unaffected accepted question refs/hashes untouched (T07-03)
"""

from __future__ import annotations

from typing import List, Optional, Sequence, Set
from uuid import uuid4
from pydantic import Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.issue import Issue, IssueCode, IssueScope
from app.contracts.policies import match_verbatim_in_passage
from app.repair.base import (
    BaseRepairer,
    RepairExecutionError,
    RepairJustificationError,
    RepairScope,
)
from app.repair.registry import RepairRegistry


class RepairPlan(CanonicalBaseModel):
    """Execution plan detailing surgical scope, chosen repairer, and invalidation cascade."""

    plan_id: str = Field(default_factory=lambda: f"rplan_{uuid4().hex[:10]}", alias="planId")
    target_artifact_ref: ArtifactRef = Field(..., alias="targetArtifactRef")
    selected_scope: RepairScope = Field(..., alias="selectedScope")
    repairer_id: str = Field(..., alias="repairerId")
    target_issue_fingerprints: List[str] = Field(default_factory=list, alias="targetIssueFingerprints")
    affected_item_ids: List[str] = Field(default_factory=list, alias="affectedItemIds")
    invalidated_dependency_refs: List[ArtifactRef] = Field(default_factory=list, alias="invalidatedDependencyRefs")
    evidence_justification: Optional[str] = Field(default=None, alias="evidenceJustification")
    requires_full_group_reevaluation: bool = Field(default=False, alias="requiresFullGroupReevaluation")
    requires_uniqueness_reevaluation: bool = Field(default=False, alias="requiresUniquenessReevaluation")
    rationale: str = ""

class RepairPlanner:
    """Plans surgical repairs by selecting minimal sufficient scope and enforcing safety rules."""

    def __init__(self, registry: RepairRegistry):
        self._registry = registry

    def plan_repair(
        self,
        artifact: ArtifactEnvelope,
        open_issues: Sequence[Issue],
        dependent_question_refs: Optional[Sequence[ArtifactRef]] = None,
        proposed_new_answer: Optional[str] = None,
        proposed_options: Optional[List[Dict[str, str]]] = None,
        evidence_justification: Optional[str] = None,
    ) -> RepairPlan:
        """Constructs an optimal RepairPlan with minimal sufficient scope and invalidation tracking."""
        if not open_issues:
            raise RepairExecutionError("Cannot construct a repair plan with zero open issues")

        # 1. Determine smallest sufficient scope required to resolve the issues
        has_passage_issue = any(
            iss.scope == IssueScope.PASSAGE
            or iss.code in (
                IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                IssueCode.OVERSTATED_CERTAINTY,
                IssueCode.CAUSAL_OVERSTATEMENT,
                IssueCode.UNMEASURED_OUTCOME,
            )
            for iss in open_issues
        )
        has_group_issue = any(
            iss.scope == IssueScope.QUESTION_GROUP
            or "summary" in iss.message.lower()
            or "blank" in iss.message.lower()
            for iss in open_issues
        )

        if has_passage_issue:
            selected_scope = RepairScope.PASSAGE
        elif has_group_issue:
            selected_scope = RepairScope.GROUP
        else:
            selected_scope = RepairScope.QUESTION

        # 2. Find eligible repairer for this scope and issues
        repairer: Optional[BaseRepairer] = None
        for iss in open_issues:
            cands = self._registry.find_repairers_for_issue(
                iss, target_artifact_type=artifact.artifact_type, scope=selected_scope
            )
            if cands:
                repairer = cands[0]
                break

        if repairer is None:
            # Fallback to any repairer matching the scope for this artifact type
            for rep in self._registry.list_repairers():
                if rep.scope == selected_scope and artifact.artifact_type in rep.metadata.target_artifact_types:
                    repairer = rep
                    break

        if repairer is None:
            raise RepairExecutionError(
                f"No registered repairer available for scope {selected_scope.value} on {artifact.artifact_type.value}"
            )

        # 3. P07-08 / T07-08: Invariant on Answer & Option Repair Evidence Justification
        passage_text = artifact.payload.get("passage", "") or artifact.payload.get("passageText", "")
        if proposed_new_answer is not None:
            if not evidence_justification:
                raise RepairJustificationError(
                    f"Answer repair to '{proposed_new_answer}' rejected: missing mandatory evidence justification quote"
                )
            # Verify that the passage actually supports the proposed answer
            if passage_text and not match_verbatim_in_passage(proposed_new_answer, passage_text):
                raise RepairJustificationError(
                    f"Answer repair to '{proposed_new_answer}' rejected: proposed answer is not supported by "
                    f"passage text (passage evidence justification failed)"
                )

        if proposed_options is not None:
            if not evidence_justification:
                raise RepairJustificationError(
                    "Option repair rejected: missing mandatory evidence justification quote for proposed options"
                )
            for opt in proposed_options:
                opt_text = opt.get("text", "")
                if opt_text and passage_text and not any(term.lower() in passage_text.lower() for term in opt_text.split() if len(term) > 3):
                    raise RepairJustificationError(
                        f"Option repair rejected: option '{opt_text}' is not grounded in passage text"
                    )
        # 4. Invalidation cascade calculation (P07-08, T07-04, T07-05)
        invalidated_refs: List[ArtifactRef] = []
        requires_group_reeval = False
        requires_uniqueness = any(iss.code in (IssueCode.BAD_DISTRACTOR, IssueCode.INSUFFICIENT_OPTIONS) for iss in open_issues)
        if selected_scope == RepairScope.PASSAGE:
            # T07-05: Passage sentence repair invalidates ALL dependent question evaluations!
            if dependent_question_refs:
                invalidated_refs = list(dependent_question_refs)
            requires_group_reeval = True
        elif selected_scope == RepairScope.GROUP:
            # T07-04: Summary group shared blank repair requires re-evaluating the entire shared group
            requires_group_reeval = True

        affected_items = []
        for iss in open_issues:
            for ref in iss.affected_refs:
                affected_items.append(f"{ref.artifact_id}:v{ref.version}")

        return RepairPlan(
            target_artifact_ref=artifact.to_ref(),
            selected_scope=selected_scope,
            repairer_id=repairer.repairer_id,
            target_issue_fingerprints=[iss.fingerprint for iss in open_issues],
            affected_item_ids=affected_items,
            invalidated_dependency_refs=invalidated_refs,
            evidence_justification=evidence_justification,
            requires_full_group_reevaluation=requires_group_reeval,
            requires_uniqueness_reevaluation=requires_uniqueness,
            rationale=(
                f"{len(open_issues)} issue(s) using {repairer.repairer_id}"
            ),
        )
