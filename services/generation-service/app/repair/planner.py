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
from app.contracts.evaluation import EvaluationResult
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
    unaffected_accepted_refs: List[ArtifactRef] = Field(default_factory=list, alias="unaffectedAcceptedRefs")
    invalidated_evaluation_ids: List[str] = Field(default_factory=list, alias="invalidatedEvaluationIds")
    evidence_justification: Optional[str] = Field(default=None, alias="evidenceJustification")
    requires_full_group_reevaluation: bool = Field(default=False, alias="requiresFullGroupReevaluation")
    requires_uniqueness_reevaluation: bool = Field(default=False, alias="requiresUniquenessReevaluation")
    rationale: str = ""

class RepairPlanner:
    """Plans surgical repairs by selecting minimal sufficient scope and enforcing safety rules."""

    def __init__(self, registry: RepairRegistry):
        self._registry = registry

    def compute_dynamic_invalidation_closure(
        self,
        artifact: ArtifactEnvelope,
        selected_scope: RepairScope,
        artifacts_pool: Optional[Sequence[ArtifactEnvelope]] = None,
        dependent_question_refs: Optional[Sequence[ArtifactRef]] = None,
        all_evaluations: Optional[Sequence[EvaluationResult]] = None,
    ) -> tuple[List[ArtifactRef], List[ArtifactRef], List[str]]:
        """Computes exact dynamic transitive dependency invalidation closure.
        
        Validates graph integrity (null metadata, missing parent refs), detects cycles using DFS,
        and traverses downstream consumers of changed refs.
        Returns: (invalidated_dependency_refs, unaffected_accepted_refs, invalidated_evaluation_ids).
        """
        if artifacts_pool is not None and len(artifacts_pool) > 0:
            by_id: Dict[str, ArtifactEnvelope] = {}
            for art in artifacts_pool:
                if art.parent_refs is None:
                    raise RepairExecutionError(
                        f"Malformed dependency metadata: artifact '{art.artifact_id}' has null parentRefs"
                    )
                for p in art.parent_refs:
                    if not p.artifact_id or not p.content_hash:
                        raise RepairExecutionError(
                            f"Malformed dependency metadata: parent reference in '{art.artifact_id}' lacks id/hash"
                        )
                by_id[art.artifact_id] = art

            consumers_adj: Dict[str, Set[str]] = {}
            for art in artifacts_pool:
                for p in art.parent_refs:
                    consumers_adj.setdefault(p.artifact_id, set()).add(art.artifact_id)

            color: Dict[str, int] = {art.artifact_id: 0 for art in artifacts_pool}

            def has_cycle(node_id: str, stack: List[str]) -> bool:
                color[node_id] = 1
                node_art = by_id.get(node_id)
                if node_art:
                    for p in node_art.parent_refs:
                        p_id = p.artifact_id
                        if p_id in by_id:
                            if color[p_id] == 1:
                                stack.append(f"{node_id}->{p_id}")
                                return True
                            if color[p_id] == 0:
                                if has_cycle(p_id, stack):
                                    stack.append(f"{node_id}->{p_id}")
                                    return True
                color[node_id] = 2
                return False

            for art in artifacts_pool:
                if color[art.artifact_id] == 0:
                    cycle_stack: List[str] = []
                    if has_cycle(art.artifact_id, cycle_stack):
                        raise RepairExecutionError(
                            f"Malformed dependency graph: cycle detected in artifact dependency lineage ({' -> '.join(reversed(cycle_stack))})"
                        )

            invalidated_ids: Set[str] = set()
            visited: Set[str] = set()
            start_ids: List[str] = [artifact.artifact_id]

            if selected_scope == RepairScope.GROUP:
                for art in artifacts_pool:
                    if any(p.artifact_id == artifact.artifact_id for p in art.parent_refs):
                        start_ids.append(art.artifact_id)

            queue: List[str] = list(dict.fromkeys(start_ids))
            while queue:
                curr_id = queue.pop(0)
                if curr_id in visited:
                    continue
                visited.add(curr_id)
                for consumer_id in consumers_adj.get(curr_id, set()):
                    if consumer_id not in invalidated_ids:
                        invalidated_ids.add(consumer_id)
                        queue.append(consumer_id)

            invalidated_refs = [
                by_id[aid].to_ref() for aid in sorted(invalidated_ids) if aid in by_id and aid != artifact.artifact_id
            ]

            if dependent_question_refs:
                inv_keys = {(r.artifact_id, r.version) for r in invalidated_refs}
                for dr in dependent_question_refs:
                    if (dr.artifact_id, dr.version) not in inv_keys:
                        invalidated_refs.append(dr)
                        inv_keys.add((dr.artifact_id, dr.version))

            unaffected_refs = [
                art.to_ref() for art in artifacts_pool
                if art.artifact_id not in invalidated_ids and art.artifact_id != artifact.artifact_id
            ]

            invalidated_eval_ids: List[str] = []
            if all_evaluations:
                for ev in all_evaluations:
                    if (
                        ev.target_ref.artifact_id in invalidated_ids
                        or ev.target_ref.artifact_id == artifact.artifact_id
                        or any(p.artifact_id in invalidated_ids or p.artifact_id == artifact.artifact_id for p in ev.input_dependency_refs)
                    ):
                        invalidated_eval_ids.append(ev.evaluation_id)

            return invalidated_refs, unaffected_refs, invalidated_eval_ids

        if dependent_question_refs:
            invalidated_refs = list(dependent_question_refs)
            return invalidated_refs, [], []

        if selected_scope == RepairScope.GROUP:
            embedded_refs: List[ArtifactRef] = []
            if artifact.artifact_type == ArtifactType.SECTION:
                for grp in artifact.payload.get("groups", []):
                    for q in grp.get("questions", []):
                        q_num = q.get("questionNumber") or q.get("number")
                        if q_num:
                            embedded_refs.append(
                                ArtifactRef(
                                    artifactId=f"{artifact.artifact_id}_q{q_num}",
                                    artifactType=ArtifactType.QUESTION,
                                    version=artifact.version,
                                    contentHash=artifact.content_hash,
                                )
                            )
            return embedded_refs, [], []

        if selected_scope == RepairScope.PASSAGE and artifact.artifact_type == ArtifactType.PASSAGE:
            raise RepairExecutionError(
                f"Missing dependency metadata: cannot determine invalidation closure for scope {selected_scope.value} "
                "without artifacts_pool or dependent_question_refs (cannot accept empty closure on missing graph)"
            )

        return [], [], []

    def plan_repair(
        self,
        artifact: ArtifactEnvelope,
        open_issues: Sequence[Issue],
        dependent_question_refs: Optional[Sequence[ArtifactRef]] = None,
        proposed_new_answer: Optional[str] = None,
        proposed_options: Optional[List[Dict[str, str]]] = None,
        evidence_justification: Optional[str] = None,
        artifacts_pool: Optional[Sequence[ArtifactEnvelope]] = None,
        all_evaluations: Optional[Sequence[EvaluationResult]] = None,
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
        # 4. Dynamic invalidation cascade calculation (P07-08, T07-04, T07-05)
        invalidated_refs, unaffected_refs, invalidated_eval_ids = self.compute_dynamic_invalidation_closure(
            artifact=artifact,
            selected_scope=selected_scope,
            artifacts_pool=artifacts_pool,
            dependent_question_refs=dependent_question_refs,
            all_evaluations=all_evaluations,
        )
        requires_group_reeval = selected_scope in (RepairScope.PASSAGE, RepairScope.GROUP)
        requires_uniqueness = any(iss.code in (IssueCode.BAD_DISTRACTOR, IssueCode.INSUFFICIENT_OPTIONS) for iss in open_issues)
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
            unaffected_accepted_refs=unaffected_refs,
            invalidated_evaluation_ids=invalidated_eval_ids,
            evidence_justification=evidence_justification,
            requires_full_group_reevaluation=requires_group_reeval,
            requires_uniqueness_reevaluation=requires_uniqueness,
            rationale=(
                f"{len(open_issues)} issue(s) using {repairer.repairer_id}"
            ),
        )
