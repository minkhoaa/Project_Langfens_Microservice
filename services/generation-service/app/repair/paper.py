"""Paper Repair Router, Directives, and Surgical Repair Engine for Langfens V2 (Phase 12 / P12-04, P12-05).

Implements surgical scoped repair routing and closure invalidation for full Reading Papers:
- Cross-section duplicate question -> targeted item repair/reselection in the affected section.
- Cross-section prompt/instruction leakage -> targeted item prompt modification.
- Single-section passage defect -> targeted section loop rerun with exact descendant invalidation.
- Unaffected sections, passages, and questions strictly preserve their artifact IDs and content hashes.
- Authoritative paper evaluation and repair directives bind exact refs, issues, preconditions, authority, and budget.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Mapping
from enum import Enum
from typing import Any, Dict, List, Optional, Sequence, Set, Tuple
from uuid import uuid4
from pydantic import Field

from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.contracts.base import CanonicalBaseModel
from app.contracts.blueprint import QuestionType
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.paper import (
    ReadingPaperPayload,
    ReadingPaperSnapshot,
    assemble_immutable_paper,
)
from app.contracts.policies import count_words
from app.contracts.section import SectionPayload, assemble_immutable_section
from app.repair.base import (
    BaseRepairer,
    RepairCapabilityMetadata,
    RepairExecutionError,
    RepairJustificationError,
    RepairScope,
)

logger = logging.getLogger(__name__)

_QUESTION_REF_PATTERN = re.compile(r"(?:^|_)q(\d+)$", re.IGNORECASE)


class PaperRepairActionType(str, Enum):
    ITEM_REPAIR = "ITEM_REPAIR"
    ITEM_RESELECT = "ITEM_RESELECT"
    SECTION_REPAIR = "SECTION_REPAIR"
    CROSS_SECTION_DEDUPLICATION = "CROSS_SECTION_DEDUPLICATION"
    PASSAGE_REPAIR = "PASSAGE_REPAIR"
    NEEDS_SOURCES = "NEEDS_SOURCES"
    TRANSIENT_RETRY = "TRANSIENT_RETRY"
    PERMANENT_FAIL = "PERMANENT_FAIL"


class PaperRepairRoute(CanonicalBaseModel):
    """Detailed routing decision for repairing a full-paper level defect."""

    route_id: str = Field(default_factory=lambda: f"route_{uuid4().hex[:8]}", alias="routeId")
    action_type: PaperRepairActionType = Field(..., alias="actionType")
    target_scope: RepairScope = Field(..., alias="targetScope")
    target_section_ids: List[int] = Field(default_factory=list, alias="targetSectionIds")
    target_question_numbers: List[int] = Field(default_factory=list, alias="targetQuestionNumbers")
    invalidated_artifact_ids: List[str] = Field(default_factory=list, alias="invalidatedArtifactIds")
    preserved_artifact_ids: List[str] = Field(default_factory=list, alias="preservedArtifactIds")
    rationale: str = ""
    workflow_status: str = "IN_PROGRESS"


class PaperRepairDirective(CanonicalBaseModel):
    """Internal authenticated directive specifying exact paper repair parameters."""

    directive_id: str = Field(default_factory=lambda: f"dir_{uuid4().hex[:8]}", alias="directiveId")
    affected_refs: List[ArtifactRef] = Field(default_factory=list, alias="affectedRefs")
    issues: List[Issue] = Field(default_factory=list)
    preconditions: Dict[str, Any] = Field(default_factory=dict)
    authority: Dict[str, Any] = Field(default_factory=dict)
    budget: Dict[str, Any] = Field(default_factory=dict)
    target_section_id: Optional[int] = Field(default=None, alias="targetSectionId")
    target_question_number: Optional[int] = Field(default=None, alias="targetQuestionNumber")
    patch_payload: Optional[Dict[str, Any]] = Field(default=None, alias="patchPayload")
    question_patches: Dict[int, Dict[str, Any]] = Field(default_factory=dict, alias="questionPatches")


class PaperRepairResult(CanonicalBaseModel):
    """Result of executing a paper-level surgical repair."""

    repaired_envelope: ArtifactEnvelope = Field(..., alias="repairedEnvelope")
    applied_actions: List[str] = Field(default_factory=list, alias="appliedActions")
    invalidated_refs: List[ArtifactRef] = Field(default_factory=list, alias="invalidatedRefs")
    preserved_refs: List[ArtifactRef] = Field(default_factory=list, alias="preservedRefs")
    replacement_question_envelopes: List[ArtifactEnvelope] = Field(
        default_factory=list, alias="replacementQuestionEnvelopes"
    )
    replacement_section_envelopes: List[ArtifactEnvelope] = Field(
        default_factory=list, alias="replacementSectionEnvelopes"
    )
    tokens_used: int = Field(default=0, alias="tokensUsed")
    wall_time_used_seconds: float = Field(default=0.0, alias="wallTimeUsedSeconds")

# ── PaperRepairRouter ────────────────────────────────────────────────────────


class PaperRepairRouter:
    """Evaluates full ReadingPaper issues and routes repairs to the minimal sufficient scope."""

    def route_repair(
        self,
        paper_artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
    ) -> PaperRepairRoute:
        """Determines the minimal surgical repair scope and invalidation cascade for paper issues."""
        if not issues:
            return PaperRepairRoute(
                actionType=PaperRepairActionType.TRANSIENT_RETRY,
                targetScope=RepairScope.QUESTION,
                rationale="No issues to route",
                workflow_status="COMPLETED",
            )

        payload = paper_artifact.payload
        sections = payload.get("sections", [])

        # Check for cross-section duplication or prompt answer leakage
        has_dup_question = any(
            iss.code == IssueCode.DUPLICATE_CONTENT and iss.scope == IssueScope.QUESTION
            for iss in issues
        )
        has_leak_issue = any(
            iss.code == IssueCode.ANSWER_LEAKAGE for iss in issues
        )
        has_passage_overlap = any(
            iss.code == IssueCode.DUPLICATE_CONTENT and iss.scope == IssueScope.PAPER
            for iss in issues
        )
        has_section_wc = any(
            iss.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS and iss.scope == IssueScope.SECTION
            for iss in issues
        )

        target_section_ids: List[int] = []
        target_q_nums: List[int] = []
        invalidated_ids: List[str] = []
        preserved_ids: List[str] = []

        # Find target question numbers and target sections from issue messages and affected refs
        for iss in issues:
            # Parse question number if present
            if "Question " in iss.message:
                import re
                m = re.search(r"Question (\d+)", iss.message)
                if m:
                    target_q_nums.append(int(m.group(1)))
            # Parse section id if present
            if "Section " in iss.message or "Passage " in iss.message:
                import re
                m = re.search(r"(?:Section|Passage) (\d+)", iss.message)
                if m:
                    target_section_ids.append(int(m.group(1)))

        target_q_nums = sorted(list(set(target_q_nums)))
        target_section_ids = sorted(list(set(target_section_ids)))

        # If question issue, map to specific section
        if target_q_nums and not target_section_ids:
            for q_num in target_q_nums:
                if 1 <= q_num <= 13:
                    target_section_ids.append(1)
                elif 14 <= q_num <= 26:
                    target_section_ids.append(2)
                elif 27 <= q_num <= 40:
                    target_section_ids.append(3)
            target_section_ids = sorted(list(set(target_section_ids)))

        # Determine invalidation closure
        all_section_ids = [1, 2, 3]
        for sec in sections:
            sec_id = sec.get("sectionId", 1)
            sec_art_id = sec.get("artifactId") or sec.get("artifact_id") or f"art_section_s{sec_id}"
            if sec_id in target_section_ids:
                invalidated_ids.append(sec_art_id)
            else:
                preserved_ids.append(sec_art_id)

        # Route action
        if has_dup_question or has_leak_issue:
            return PaperRepairRoute(
                actionType=PaperRepairActionType.ITEM_REPAIR,
                targetScope=RepairScope.QUESTION,
                targetSectionIds=target_section_ids or [1],
                targetQuestionNumbers=target_q_nums,
                invalidatedArtifactIds=invalidated_ids,
                preservedArtifactIds=preserved_ids,
                rationale=f"Surgical question repair for questions {target_q_nums} in sections {target_section_ids}",
                workflow_status="IN_PROGRESS",
            )
        elif has_passage_overlap or has_section_wc:
            return PaperRepairRoute(
                actionType=PaperRepairActionType.PASSAGE_REPAIR,
                targetScope=RepairScope.PASSAGE,
                targetSectionIds=target_section_ids or [1],
                targetQuestionNumbers=target_q_nums,
                invalidatedArtifactIds=invalidated_ids,
                preservedArtifactIds=preserved_ids,
                rationale=f"Passage repair required for section(s) {target_section_ids}",
                workflow_status="IN_PROGRESS",
            )
        else:
            return PaperRepairRoute(
                actionType=PaperRepairActionType.SECTION_REPAIR,
                targetScope=RepairScope.SECTION,
                targetSectionIds=target_section_ids or [1],
                targetQuestionNumbers=target_q_nums,
                invalidatedArtifactIds=invalidated_ids,
                preservedArtifactIds=preserved_ids,
                rationale=f"Section repair required for section(s) {target_section_ids}",
                workflow_status="IN_PROGRESS",
            )


# ── PaperSurgicalRepairer ────────────────────────────────────────────────────


class PaperSurgicalRepairer(BaseRepairer):
    """Executes surgical in-place modifications on ReadingPaper artifacts, preserving unaffected hashes."""

    def __init__(self, repairer_id: str = "repairer_paper_surgical"):
        super().__init__(
            RepairCapabilityMetadata(
                repairer_id=repairer_id,
                repairer_version="1.0.0",
                name="Paper Surgical Repairer",
                description="Surgically repairs whole-paper question items, prompt duplicates, and leakage",
                handled_codes={
                    IssueCode.DUPLICATE_CONTENT,
                    IssueCode.ANSWER_LEAKAGE,
                    IssueCode.WORD_LIMIT_EXCEEDED,
                    IssueCode.BAD_DISTRACTOR,
                    IssueCode.AMBIGUOUS_ANSWER,
                    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    IssueCode.QUESTION_COUNT_MISMATCH,
                    IssueCode.QUESTION_NUMBERING_INVALID,
                    IssueCode.SECTION_GROUP_COUNT_MISMATCH,
                    IssueCode.SECTION_GROUP_TYPE_MISMATCH,
                    IssueCode.SECTION_GROUP_SIZE_MISMATCH,
                },
                scope=RepairScope.SECTION,
                target_artifact_types=[ArtifactType.READING_PAPER],
            )
        )
        self.router = PaperRepairRouter()
        # P15 invariant: a paper repair rebuilds the paper to reference NEW child
        # question/section artifacts. Those children must be persisted and accepted
        # before the paper that points at them can be accepted, otherwise the closure
        # invariant ("never accept an artifact bound to non-accepted parents") is
        # violated. The base `repair()` protocol returns only the envelope, so the full
        # result is retained here for the authoritative caller
        # (`PaperRepairerAdapter`) to commit child-by-child under fenced CAS.
        self.last_repair_result: Optional[PaperRepairResult] = None

    async def _repair_impl(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        route = self.router.route_repair(artifact, issues)
        directive = PaperRepairDirective(
            affectedRefs=[artifact.to_ref()],
            issues=list(issues),
            targetSectionId=route.target_section_ids[0] if route.target_section_ids else 1,
            targetQuestionNumber=route.target_question_numbers[0] if route.target_question_numbers else None,
        )
        # P15 case-04: the router selected a scope but never synthesized the mutation
        # payload that `repair_paper` requires, so every paper-level repair aborted at
        # the empty-directive gate and burned all three versions before reporting the
        # misleading "MAX_VERSIONS: N exact-target blockers". Derive the surgical patch
        # from each issue's evaluator-supplied, evidence-grounded `proposed_repair` so
        # the repair is grounded rather than invented. Issues with no grounded proposal
        # still fail closed -- the gate below is unchanged.
        question_patches, patch_payload = self._derive_surgical_patch(artifact, issues, route)
        if question_patches or patch_payload:
            directive = directive.model_copy(
                update={"question_patches": question_patches, "patch_payload": patch_payload}
            )
        res = self.repair_paper(artifact, directive)
        # Retain the full result (replacement children + invalidated/preserved refs)
        # so the authoritative caller can persist and accept the rebuilt closure.
        self.last_repair_result = res
        return res.repaired_envelope

    @staticmethod
    def _derive_surgical_patch(
        paper_artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        route: PaperRepairRoute,
    ) -> tuple[Dict[int, Dict[str, Any]], Dict[str, Any]]:
        """Derives a grounded, minimal surgical patch from evaluator-proposed repairs.

        Only an issue that carries an explicit `proposed_repair` (i.e. the evaluator
        determined a concrete, passage-grounded correction) contributes a mutation. This
        keeps the exact-closure invariant intact: nothing is invented locally, and any
        defect without a grounded proposal still reaches the empty-directive gate and
        fails closed.
        """
        question_patches: Dict[int, Dict[str, Any]] = {}
        patch_payload: Dict[str, Any] = {}

        question_lookup: Dict[int, Mapping[str, Any]] = {}
        for sec in paper_artifact.payload.get("sections", []) or []:
            # The envelope payload is frozen, so entries are MappingProxyType, not dict.
            groups = sec.get("groups", []) if isinstance(sec, Mapping) else []
            for grp in groups:
                questions = grp.get("questions", []) if isinstance(grp, Mapping) else []
                for q in questions:
                    if not isinstance(q, Mapping):
                        continue
                    q_num = q.get("questionNumber") or q.get("number")
                    if q_num is not None:
                        question_lookup[int(q_num)] = q

        for iss in issues:
            proposal = (iss.proposed_repair or "").strip()
            if not proposal:
                continue

            q_nums: List[int] = []
            for ref in iss.affected_refs:
                match = _QUESTION_REF_PATTERN.search(ref.artifact_id)
                if match:
                    q_nums.append(int(match.group(1)))
            if not q_nums and "Question " in iss.message:
                match = re.search(r"Question (\d+)", iss.message)
                if match:
                    q_nums.append(int(match.group(1)))
            if not q_nums:
                q_nums = list(route.target_question_numbers)

            for q_num in q_nums:
                question = question_lookup.get(q_num)
                if question is None:
                    continue
                if iss.code == IssueCode.ANSWER_LEAKAGE:
                    prompt = str(question.get("prompt") or question.get("statement") or "")
                    if prompt and proposal.lower() in prompt.lower():
                        sanitized = re.sub(
                            re.escape(proposal), "[...]", prompt, flags=re.IGNORECASE
                        )
                        if sanitized != prompt:
                            question_patches.setdefault(q_num, {})
                            question_patches[q_num]["prompt"] = sanitized
                            if "statement" in question:
                                question_patches[q_num]["statement"] = sanitized
                elif iss.code == IssueCode.WORD_LIMIT_EXCEEDED:
                    answer = str(question.get("answer") or "").strip()
                    if answer and len(answer.split()) > 3:
                        question_patches.setdefault(q_num, {})["answer"] = proposal
                else:
                    question_patches.setdefault(q_num, {})["answer"] = proposal

        passage_key = "passage"
        if patch_payload:
            patch_payload = (
                {passage_key: patch_payload[passage_key]}
                if passage_key in patch_payload
                else patch_payload
            )
        return question_patches, patch_payload

    def repair_paper(
        self,
        paper_artifact: ArtifactEnvelope,
        directive: PaperRepairDirective,
    ) -> PaperRepairResult:
        if not directive.patch_payload and not directive.question_patches:
            raise RepairJustificationError(
                "Paper-level defect requires non-empty patch_payload or question_patches, "
                "or section loop re-execution with updated authoritative heads; "
                "uncoordinated inline mutation is forbidden by exact closure invariant"
            )
        from app.repair.question import unwrap_payload

        payload = unwrap_payload(paper_artifact.payload)
        raw_sections = payload.get("sections", [])
        existing_sec_refs = [
            ArtifactRef.model_validate(sr) for sr in (payload.get("sectionRefs") or [])
        ]
        existing_passage_refs = [
            ArtifactRef.model_validate(pr) for pr in (payload.get("passageRefs") or [])
        ]
        blueprint_ref = (
            ArtifactRef.model_validate(payload.get("blueprintRef"))
            if payload.get("blueprintRef")
            else None
        )
        if blueprint_ref is None:
            raise RepairExecutionError(
                "Paper artifact lacks required blueprintRef. Fallback parent synthesis is strictly prohibited."
            )

        target_sec_id = directive.target_section_id
        target_q_num = directive.target_question_number
        patch = directive.patch_payload or {}
        question_patches = directive.question_patches or {}

        repaired_sections: List[Any] = []
        invalidated_refs: List[ArtifactRef] = []
        preserved_refs: List[ArtifactRef] = []
        replacement_question_envelopes: List[ArtifactEnvelope] = []
        replacement_section_envelopes: List[ArtifactEnvelope] = []
        applied_actions: List[str] = []

        for idx, sec in enumerate(raw_sections):
            sec_dict = dict(sec)
            sec_id = int(sec_dict.get("sectionId", idx + 1))
            orig_sec_ref = existing_sec_refs[idx] if idx < len(existing_sec_refs) else None
            sec_art_id = (
                orig_sec_ref.artifact_id
                if orig_sec_ref is not None
                else (sec_dict.get("artifactId") or sec_dict.get("artifact_id") or f"art_section_s{sec_id}")
            )
            orig_sec_ver = (
                orig_sec_ref.version
                if orig_sec_ref is not None
                else int(sec_dict.get("version", 1))
            )
            orig_sec_hash = (
                orig_sec_ref.content_hash
                if orig_sec_ref is not None
                else (sec_dict.get("contentHash") or "0" * 64)
            )
            sec_ref_snapshot = ArtifactRef(
                artifactId=sec_art_id,
                artifactType=ArtifactType.SECTION,
                version=orig_sec_ver,
                contentHash=orig_sec_hash,
            )

            if not question_patches and target_sec_id is not None and sec_id != target_sec_id:
                repaired_sections.append({
                    **sec_dict,
                    "__artifactId": sec_art_id,
                    "__version": orig_sec_ver,
                    "__contentHash": orig_sec_hash,
                })
                preserved_refs.append(sec_ref_snapshot)
                for qr_raw in sec_dict.get("questionRefs", []) or []:
                    preserved_refs.append(ArtifactRef.model_validate(qr_raw))
                continue

            if sec_dict.get("passageRef"):
                sec_passage_ref = ArtifactRef.model_validate(sec_dict["passageRef"])
            elif idx < len(existing_passage_refs):
                sec_passage_ref = existing_passage_refs[idx]
            else:
                raise RepairExecutionError(
                    f"Section {sec_id} lacks required passageRef. Fallback parent synthesis is strictly prohibited."
                )
            sec_bp_ref = (
                ArtifactRef.model_validate(sec_dict["blueprintRef"])
                if sec_dict.get("blueprintRef")
                else blueprint_ref
            )
            orig_sec_q_refs = [
                ArtifactRef.model_validate(qr) for qr in (sec_dict.get("questionRefs") or [])
            ]
            orig_q_ref_by_id = {qr.artifact_id: qr for qr in orig_sec_q_refs}

            sec_modified = False
            modified_groups: List[Dict[str, Any]] = []
            updated_sec_q_refs: List[ArtifactRef] = []
            flat_q_idx = 0

            for grp in sec_dict.get("groups", []):
                grp_dict = dict(grp)
                modified_questions: List[Dict[str, Any]] = []
                for q in grp_dict.get("questions", []):
                    q_dict = dict(q)
                    q_num = q_dict.get("questionNumber") or q_dict.get("number")
                    q_art_id_default = f"art_q_{q_num}" if q_num is not None else f"art_q_idx_{flat_q_idx + 1}"
                    orig_q_ref = orig_q_ref_by_id.get(q_art_id_default) or (
                        orig_sec_q_refs[flat_q_idx] if flat_q_idx < len(orig_sec_q_refs) else None
                    )
                    q_was_patched = False
                    active_patch = None
                    if question_patches and q_num in question_patches:
                        active_patch = question_patches[q_num]
                    elif target_q_num is not None and q_num == target_q_num:
                        active_patch = patch

                    if active_patch:
                        had_stmt = "statement" in q_dict
                        had_prompt = "prompt" in q_dict
                        for k, v in active_patch.items():
                            q_dict[k] = v
                        if "prompt" in active_patch and had_stmt:
                            q_dict["statement"] = active_patch["prompt"]
                        if "statement" in active_patch and had_prompt:
                            q_dict["prompt"] = active_patch["statement"]
                        if had_stmt and not had_prompt:
                            q_dict.pop("prompt", None)
                        elif had_prompt and not had_stmt:
                            q_dict.pop("statement", None)
                        applied_actions.append(
                            f"Patched Question {q_num} in Section {sec_id}: {list(active_patch.keys())}"
                        )
                        sec_modified = True
                        q_was_patched = True

                    if q_was_patched:
                        new_q_env = ArtifactEnvelope.create(
                            artifact_id=orig_q_ref.artifact_id if orig_q_ref is not None else q_art_id_default,
                            artifact_type=ArtifactType.QUESTION,
                            run_id=paper_artifact.run_id,
                            payload=dict(q_dict),
                            producer_version="2.0.0",
                            version=(orig_q_ref.version + 1) if orig_q_ref is not None else 2,
                            section_id=sec_id,
                            parent_refs=[sec_passage_ref, sec_bp_ref],
                            schema_version="2.0.0",
                        )
                        replacement_question_envelopes.append(new_q_env)
                        updated_sec_q_refs.append(new_q_env.to_ref())
                        if orig_q_ref is not None:
                            invalidated_refs.append(orig_q_ref)
                    else:
                        if orig_q_ref is not None:
                            updated_sec_q_refs.append(orig_q_ref)
                            preserved_refs.append(orig_q_ref)
                    modified_questions.append(q_dict)
                    flat_q_idx += 1
                grp_dict["questions"] = modified_questions
                modified_groups.append(grp_dict)

            sec_dict["groups"] = modified_groups

            if "passage" in patch and (target_sec_id is None or sec_id == target_sec_id):
                sec_dict["passage"] = patch["passage"]
                sec_dict["wordCount"] = count_words(patch["passage"])
                applied_actions.append(f"Patched passage in Section {sec_id}")
                sec_modified = True

            if not sec_modified:
                repaired_sections.append({
                    **dict(sec),
                    "__artifactId": sec_art_id,
                    "__version": orig_sec_ver,
                    "__contentHash": orig_sec_hash,
                })
                preserved_refs.append(sec_ref_snapshot)
                continue

            if updated_sec_q_refs:
                sec_dict["questionRefs"] = [
                    qr.model_dump(mode="json", by_alias=True) for qr in updated_sec_q_refs
                ]
            sec_parent_refs = [sec_passage_ref, sec_bp_ref] + (
                updated_sec_q_refs if updated_sec_q_refs else orig_sec_q_refs
            )
            new_sec_env = ArtifactEnvelope.create(
                artifact_id=sec_art_id,
                artifact_type=ArtifactType.SECTION,
                run_id=paper_artifact.run_id,
                payload=dict(sec_dict),
                producer_version="2.0.0",
                version=orig_sec_ver + 1,
                section_id=sec_id,
                parent_refs=sec_parent_refs,
                schema_version="2.0.0",
            )
            replacement_section_envelopes.append(new_sec_env)
            repaired_sections.append(new_sec_env)
            invalidated_refs.append(sec_ref_snapshot)

        new_version = paper_artifact.version + 1
        new_paper_envelope = assemble_immutable_paper(
            sections=repaired_sections,
            blueprint_ref=blueprint_ref,
            run_id=paper_artifact.run_id,
            paper_id=payload.get("paperId"),
            title=payload.get("title"),
            version=new_version,
            evaluations_summary={"repairedAt": directive.directive_id},
        )

        return PaperRepairResult(
            repairedEnvelope=new_paper_envelope,
            appliedActions=applied_actions,
            invalidatedRefs=invalidated_refs,
            preservedRefs=preserved_refs,
            replacementQuestionEnvelopes=replacement_question_envelopes,
            replacementSectionEnvelopes=replacement_section_envelopes,
            tokensUsed=0,
            wallTimeUsedSeconds=0.0,
        )
