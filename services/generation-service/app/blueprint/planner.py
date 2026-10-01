"""Deterministic Versioned Blueprint Planner for Langfens Loop Engine V2."""

from __future__ import annotations

import hashlib
import json
from typing import Dict, List, Optional
from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.evidence import EvidenceGraph
from app.contracts.blueprint import (
    ExamBlueprint,
    SectionBlueprint,
    QuestionSlot,
    QuestionType,
    QuestionTypeAllocation,
    PassageObjective,
    BudgetAllocation,
    TargetDifficulty,
    DifficultyLevel,
    EvidenceGraphRef,
)
from app.blueprint.policies import (
    BLUEPRINT_POLICY_VERSION,
    BLUEPRINT_SCHEMA_VERSION,
    SECTION_CONFIGURATIONS,
    SECTION_MIN_WORDS,
    SECTION_MAX_WORDS,
    PAPER_MIN_WORDS,
    PAPER_MAX_WORDS,
    DEFAULT_MAX_CANDIDATES_PER_SLOT,
    DEFAULT_REPAIR_HEADROOM_CALLS,
    DEFAULT_MAX_TOKENS_PER_SECTION,
)
from app.blueprint.suitability import evaluate_source_suitability, SourceSuitabilityResult
from app.blueprint.validators import validate_blueprint


class SectionPlanInput(CanonicalBaseModel):
    """Input payload for planning a single section."""

    section_id: int = Field(..., ge=1, le=3, alias="sectionId")
    topic: str
    evidence_graph: EvidenceGraph = Field(..., alias="evidenceGraph")
    target_word_count: int = Field(default=800, ge=720, le=915, alias="targetWordCount")
    max_candidates_per_slot: int = Field(default=DEFAULT_MAX_CANDIDATES_PER_SLOT, alias="maxCandidatesPerSlot")
    repair_headroom_calls: int = Field(default=DEFAULT_REPAIR_HEADROOM_CALLS, alias="repairHeadroomCalls")
    max_tokens: int = Field(default=DEFAULT_MAX_TOKENS_PER_SECTION, alias="maxTokens")


class BlueprintPlanResult(CanonicalBaseModel):
    """Execution result of blueprint planning."""

    success: bool
    status: str  # ACCEPTED, SOURCE_INSUFFICIENT, STALE_OR_REJECTED_GRAPH, BUDGET_EXCEEDED, VALIDATION_FAILED
    reason: Optional[str] = None
    blueprint: Optional[ExamBlueprint] = None
    suitability_results: Dict[int, SourceSuitabilityResult] = Field(default_factory=dict)
    action: str = "PROCEED"  # PROCEED or NEEDS_SOURCES


class BlueprintPlanner:
    """Plans full reading paper blueprints deterministically from verified EvidenceGraphs."""

    def __init__(self, policy_version: str = BLUEPRINT_POLICY_VERSION):
        self.policy_version = policy_version

    def plan_exam(
        self,
        run_id: str,
        blueprint_id: str,
        section_inputs: List[SectionPlanInput],
        parent_budget_cap_tokens: Optional[int] = None,
    ) -> BlueprintPlanResult:
        """Plans complete 3-section IELTS Academic Reading exam blueprint.

        Fails closed before generation if:
        - Any EvidenceGraph is rejected or stale.
        - Any source is unsuitable (e.g. low diversity, missing mechanisms or opinions).
        - Budget oversubscribes parent reservation cap.
        """
        if len(section_inputs) != 3:
            return BlueprintPlanResult(
                success=False,
                status="VALIDATION_FAILED",
                reason=f"Expected exactly 3 sections; received {len(section_inputs)}.",
                action="NEEDS_SOURCES",
            )

        # Sort sections by section_id
        sorted_inputs = sorted(section_inputs, key=lambda s: s.section_id)
        if [s.section_id for s in sorted_inputs] != [1, 2, 3]:
            return BlueprintPlanResult(
                success=False,
                status="VALIDATION_FAILED",
                reason=f"Section IDs must be exactly [1, 2, 3]; received {[s.section_id for s in sorted_inputs]}.",
                action="NEEDS_SOURCES",
            )

        suitability_map: Dict[int, SourceSuitabilityResult] = {}
        planned_sections: List[SectionBlueprint] = []

        # 1. Evaluate Pre-requisites & Suitability for all sections
        for s_in in sorted_inputs:
            eg = s_in.evidence_graph

            # Step 1a: Check EvidenceGraph status
            if eg.status != "ACCEPTED":
                return BlueprintPlanResult(
                    success=False,
                    status="STALE_OR_REJECTED_GRAPH",
                    reason=f"Section {s_in.section_id} references EvidenceGraph with status '{eg.status}'; must be ACCEPTED.",
                    action="NEEDS_SOURCES",
                )

            # Step 1b: Evaluate suitability (evidence diversity, mechanisms, opinions)
            suitability = evaluate_source_suitability(eg, s_in.section_id)
            suitability_map[s_in.section_id] = suitability
            if not suitability.is_suitable:
                return BlueprintPlanResult(
                    success=False,
                    status="SOURCE_INSUFFICIENT",
                    reason=f"Section {s_in.section_id} source is unsuitable: {suitability.rejection_reason}",
                    suitability_results=suitability_map,
                    action="NEEDS_SOURCES",
                )

        # 2. Budget Scaling & Feasibility
        total_tokens_requested = sum(s.max_tokens for s in sorted_inputs)
        effective_inputs: List[SectionPlanInput] = []
        if parent_budget_cap_tokens is not None and total_tokens_requested > parent_budget_cap_tokens:
            scale_factor = parent_budget_cap_tokens / total_tokens_requested
            if scale_factor < 0.5:
                return BlueprintPlanResult(
                    success=False,
                    status="BUDGET_EXCEEDED",
                    reason=f"Total requested tokens {total_tokens_requested} exceeds parent cap {parent_budget_cap_tokens} beyond allowable scaling factor (0.5).",
                    action="NEEDS_SOURCES",
                )
            for s_in in sorted_inputs:
                new_tokens = int(s_in.max_tokens * scale_factor)
                effective_inputs.append(
                    s_in.model_copy(update={"max_tokens": new_tokens, "max_candidates_per_slot": 1})
                )
        else:
            effective_inputs = sorted_inputs

        # 3. Construct Sections & Slots
        for s_in in effective_inputs:
            section_bp = self._plan_section(s_in)
            planned_sections.append(section_bp)

        # 4. Assemble ExamBlueprint & compute content hash
        draft_bp = ExamBlueprint(
            blueprint_id=blueprint_id,
            run_id=run_id,
            policy_version=self.policy_version,
            schema_version=BLUEPRINT_SCHEMA_VERSION,
            sections=planned_sections,
            total_questions=40,
            target_word_count_min=PAPER_MIN_WORDS,
            target_word_count_max=PAPER_MAX_WORDS,
            parent_budget_cap_tokens=parent_budget_cap_tokens,
        )
        canonical_dict = draft_bp.model_dump(by_alias=True)
        canonical_dict.pop("createdAt", None)
        canonical_dict.pop("contentHash", None)
        canonical_dict.pop("invalidatedDescendants", None)
        canonical_json = json.dumps(canonical_dict, sort_keys=True)
        content_hash = hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()
        blueprint = draft_bp.model_copy(update={"content_hash": content_hash})

        # 5. Final Validation
        issues = validate_blueprint(blueprint)
        from app.contracts.issue import IssueSeverity
        blocking_issues = [i for i in issues if i.severity == IssueSeverity.CRITICAL]
        if blocking_issues:
            return BlueprintPlanResult(
                success=False,
                status="VALIDATION_FAILED",
                reason=f"Blueprint validation failed: {[b.message for b in blocking_issues]}",
                action="NEEDS_SOURCES",
            )
        return BlueprintPlanResult(
            success=True,
            status="ACCEPTED",
            blueprint=blueprint,
            suitability_results=suitability_map,
            action="PROCEED",
        )

    def _plan_section(self, s_in: SectionPlanInput) -> SectionBlueprint:
        sec_id = s_in.section_id
        config = SECTION_CONFIGURATIONS[sec_id]
        claims = s_in.evidence_graph.claims or []

        # Graph Ref
        graph_ref = EvidenceGraphRef(
            graph_id=s_in.evidence_graph.graph_id,
            source_pack_id=s_in.evidence_graph.source_pack_id,
            version=s_in.evidence_graph.version,
            content_hash=s_in.evidence_graph.content_hash,
            status=s_in.evidence_graph.status,
            claim_count=len(claims),
        )

        # Passage Objectives
        objectives: List[PassageObjective] = []
        role = "factual_foundation" if sec_id == 1 else ("process_mechanism" if sec_id == 2 else "argument_viewpoint")
        chunk_size = max(1, len(claims) // 3)
        for i in range(3):
            sub_claims = claims[i * chunk_size : (i + 1) * chunk_size]
            c_ids = [c.claim_id for c in sub_claims]
            objectives.append(
                PassageObjective(
                    objective_id=f"obj_sec{sec_id}_{i+1}",
                    description=f"Objective {i+1} covering {len(c_ids)} claims for {s_in.topic}",
                    mapped_claim_ids=c_ids,
                    role=role,
                )
            )

        # Question Allocations & Slots
        allocations: List[QuestionTypeAllocation] = []
        slots: List[QuestionSlot] = []

        claim_idx = 0
        for grp in config["groups"]:
            allocations.append(
                QuestionTypeAllocation(
                    question_type=grp["question_type"],
                    count=grp["count"],
                    start_question_number=grp["start_question_number"],
                    end_question_number=grp["end_question_number"],
                )
            )

            # Assign slots
            for q_num in range(grp["start_question_number"], grp["end_question_number"] + 1):
                # Pick supporting claim
                ref_claims = [claims[claim_idx % len(claims)].claim_id] if claims else []
                claim_idx += 1

                # Target skill and difficulty
                skill, diff_level, rationale, is_not_given = self._determine_slot_attributes(
                    sec_id, grp["group_index"], q_num
                )

                slots.append(
                    QuestionSlot(
                        question_number=q_num,
                        section_id=sec_id,
                        group_index=grp["group_index"],
                        question_type=grp["question_type"],
                        target_skill=skill,
                        target_difficulty=TargetDifficulty(
                            level=diff_level,
                            rationale=rationale,
                            is_calibrated=False,  # Policy: heuristic/editorial only!
                        ),
                        claim_ref_ids=ref_claims,
                        is_not_given_target=is_not_given,
                        max_concentration_per_paragraph=2,
                    )
                )

        # Budget Allocation
        budget = BudgetAllocation(
            max_candidates_per_slot=min(s_in.max_candidates_per_slot, 3),
            repair_headroom_calls=s_in.repair_headroom_calls,
            max_tokens_allocated=s_in.max_tokens,
        )

        return SectionBlueprint(
            section_id=sec_id,
            topic=s_in.topic,
            target_word_count=s_in.target_word_count,
            evidence_graph_ref=graph_ref,
            passage_objectives=objectives,
            question_allocations=allocations,
            question_slots=slots,
            budget_allocation=budget,
            total_questions=config["total_questions"],
        )

    def _determine_slot_attributes(
        self, sec_id: int, group_index: int, q_num: int
    ) -> tuple[str, DifficultyLevel, str, bool]:
        """Determines target skill, difficulty level, rationale, and not-given flag."""
        # Section 1
        if sec_id == 1:
            if group_index == 0:  # TFNG (Q1-Q7)
                # Slots 3 and 7 planned as NOT GIVEN targets
                is_ng = q_num in (3, 7)
                skill = "factual_identification"
                diff = DifficultyLevel.FOUNDATION if q_num <= 4 else DifficultyLevel.MODERATE
                rationale = f"Section 1 TFNG testing direct factual proposition for Q{q_num}."
                return skill, diff, rationale, is_ng
            else:  # Sentence Completion (Q8-Q13)
                skill = "detail_scanning"
                diff = DifficultyLevel.FOUNDATION if q_num <= 10 else DifficultyLevel.MODERATE
                rationale = f"Section 1 Sentence Completion scanning verbatim tokens for Q{q_num}."
                return skill, diff, rationale, False

        # Section 2
        elif sec_id == 2:
            if group_index == 0:  # MCQ Single (Q14-Q19)
                skill = "mechanism_comprehension"
                diff = DifficultyLevel.MODERATE if q_num <= 17 else DifficultyLevel.ADVANCED
                rationale = f"Section 2 MCQ evaluating analytical process steps for Q{q_num}."
                return skill, diff, rationale, False
            else:  # Summary Completion (Q20-Q26)
                skill = "process_synthesis"
                diff = DifficultyLevel.MODERATE if q_num <= 23 else DifficultyLevel.ADVANCED
                rationale = f"Section 2 Summary Completion synthesizing causal steps for Q{q_num}."
                return skill, diff, rationale, False

        # Section 3
        else:
            if group_index == 0:  # YNNG (Q27-Q33)
                # Slots 30 and 33 planned as NOT GIVEN targets
                is_ng = q_num in (30, 33)
                skill = "viewpoint_evaluation"
                diff = DifficultyLevel.MODERATE if q_num <= 29 else DifficultyLevel.ADVANCED
                rationale = f"Section 3 YNNG assessing author perspective/argument for Q{q_num}."
                return skill, diff, rationale, is_ng
            else:  # Short Answer (Q34-Q40)
                skill = "complex_inference"
                diff = DifficultyLevel.MODERATE if q_num <= 37 else DifficultyLevel.ADVANCED
                rationale = f"Section 3 Short Answer extracting precise opinion evidence for Q{q_num}."
                return skill, diff, rationale, False
