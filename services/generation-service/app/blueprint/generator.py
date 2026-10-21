"""Dynamic Blueprint Generator for Autonomous IELTS Reading Generation Harness (Task 2)."""

from __future__ import annotations

import hashlib
import json
import uuid
from typing import Any, Dict, List, Optional

from app.blueprint.policies import (
    BLUEPRINT_POLICY_VERSION,
    BLUEPRINT_SCHEMA_VERSION,
    PAPER_MIN_WORDS,
    PAPER_MAX_WORDS,
    SECTION_MIN_WORDS,
    SECTION_MAX_WORDS,
    SECTION_CONFIGURATIONS,
)
from app.contracts.blueprint import (
    BudgetAllocation,
    DifficultyLevel,
    EvidenceGraphRef,
    ExamBlueprint,
    PassageObjective,
    QuestionSlot,
    QuestionType,
    QuestionTypeAllocation,
    SectionBlueprint,
    TargetDifficulty,
)
from app.contracts.question_type import QuestionPromptFamily
from app.reading_policy import PinnedExecutionPolicy


# Academic Suitability Pools per IELTS section profile:
# Section 1: Factual, descriptive texts (TFNG, Notes, Tables, Flowcharts, Sentence Completion, Short Answer)
SECTION_1_FAMILIES = [
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN,
    QuestionPromptFamily.NOTE_COMPLETION,
    QuestionPromptFamily.TABLE_COMPLETION,
    QuestionPromptFamily.FLOW_CHART,
    QuestionPromptFamily.SENTENCE_COMPLETION,
    QuestionPromptFamily.SHORT_ANSWER,
]

# Section 2: Technical, analytical, discursive texts (Matching Info, Matching Features, Summary Completion, Diagram Label)
SECTION_2_FAMILIES = [
    QuestionPromptFamily.MATCHING_INFORMATION,
    QuestionPromptFamily.MATCHING_FEATURES,
    QuestionPromptFamily.SUMMARY_COMPLETION,
    QuestionPromptFamily.DIAGRAM_LABEL,
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX,
]

# Section 3: Argumentative, complex academic debate, viewpoints (Matching Headings, YNNG, MCQ Multiple, Sentence Endings, MCQ Single)
SECTION_3_FAMILIES = [
    QuestionPromptFamily.MATCHING_HEADING,
    QuestionPromptFamily.YES_NO_NOT_GIVEN,
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE,
    QuestionPromptFamily.MATCHING_ENDINGS,
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
]


def _build_legacy_preset_blueprint(policy: PinnedExecutionPolicy, run_id: str, blueprint_id: str) -> ExamBlueprint:
    """Builds standard 6-type preset blueprint matching SECTION_CONFIGURATIONS."""
    sections: List[SectionBlueprint] = []

    for sec_id in [1, 2, 3]:
        cfg = SECTION_CONFIGURATIONS[sec_id]
        slots: List[QuestionSlot] = []
        allocations: List[QuestionTypeAllocation] = []

        for grp in cfg["groups"]:
            allocations.append(
                QuestionTypeAllocation(
                    question_type=grp["question_type"],
                    count=grp["count"],
                    start_question_number=grp["start_question_number"],
                    end_question_number=grp["end_question_number"],
                )
            )
            for q_num in range(grp["start_question_number"], grp["end_question_number"] + 1):
                diff_level = (
                    DifficultyLevel.FOUNDATION
                    if sec_id == 1
                    else (DifficultyLevel.MODERATE if sec_id == 2 else DifficultyLevel.ADVANCED)
                )
                slots.append(
                    QuestionSlot(
                        question_number=q_num,
                        section_id=sec_id,
                        group_index=grp["group_index"],
                        question_type=grp["question_type"],
                        target_skill=f"Target skill for question {q_num} in section {sec_id}",
                        target_difficulty=TargetDifficulty(
                            level=diff_level,
                            rationale=f"Editorial heuristic difficulty for Section {sec_id} slot {q_num}.",
                            is_calibrated=False,
                        ),
                        claim_ref_ids=[],
                        is_not_given_target=(
                            grp["question_type"] in (QuestionType.TRUE_FALSE_NOT_GIVEN, QuestionType.YES_NO_NOT_GIVEN)
                            and q_num % 3 == 0
                        ),
                    )
                )

        eg_ref = EvidenceGraphRef(
            graph_id=f"eg_sec{sec_id}_{run_id[:8]}",
            source_pack_id=f"pack_sec{sec_id}",
            version="v1.0.0",
            content_hash=hashlib.sha256(f"hash_sec{sec_id}_{run_id}".encode("utf-8")).hexdigest(),
            status="ACCEPTED",
            claim_count=10,
        )

        sections.append(
            SectionBlueprint(
                section_id=sec_id,
                topic=f"Academic Topic for Section {sec_id}",
                target_word_count=800,
                evidence_graph_ref=eg_ref,
                passage_objectives=[
                    PassageObjective(
                        objective_id=f"obj_sec{sec_id}_1",
                        description=f"Passage objective for section {sec_id}",
                        mapped_claim_ids=[],
                        role="factual_foundation" if sec_id == 1 else ("process_mechanism" if sec_id == 2 else "argument_viewpoint"),
                    )
                ],
                question_allocations=allocations,
                question_slots=slots,
                budget_allocation=BudgetAllocation(
                    max_candidates_per_slot=1,
                    repair_headroom_calls=2,
                    max_tokens_allocated=15000,
                ),
                total_questions=cfg["total_questions"],
            )
        )

    bp = ExamBlueprint(
        blueprint_id=blueprint_id,
        run_id=run_id,
        policy_version=BLUEPRINT_POLICY_VERSION,
        schema_version=BLUEPRINT_SCHEMA_VERSION,
        sections=sections,
        total_questions=40,
        target_word_count_min=PAPER_MIN_WORDS,
        target_word_count_max=PAPER_MAX_WORDS,
        metadata={"blueprint_mode": "legacy_preset"},
    )
    return bp


def generate_dynamic_blueprint(
    policy: PinnedExecutionPolicy,
    evidence_summary: Optional[Dict[str, Any]] = None,
) -> ExamBlueprint:
    """Generates an ExamBlueprint according to policy and evidence summary.

    When policy.blueprint_mode == 'legacy_preset', returns the strict 6-type preset.
    When policy.blueprint_mode == 'dynamic', allocates questions across 3 sections
    (13, 13, 14 summing to 40) using academic suitability distributions for sections 1, 2, and 3.
    """
    evidence_summary = evidence_summary or {}
    run_id = f"run_{uuid.uuid4().hex[:8]}"
    blueprint_id = f"bp_{uuid.uuid4().hex[:12]}"

    if policy.blueprint_mode == "legacy_preset":
        return _build_legacy_preset_blueprint(policy, run_id, blueprint_id)

    # Dynamic mode
    # Define targets per section summing to 40
    section_targets = [
        {"section_id": 1, "total_questions": 13, "start_q": 1, "families": SECTION_1_FAMILIES},
        {"section_id": 2, "total_questions": 13, "start_q": 14, "families": SECTION_2_FAMILIES},
        {"section_id": 3, "total_questions": 14, "start_q": 27, "families": SECTION_3_FAMILIES},
    ]

    topics = evidence_summary.get("topics", [
        "Natural sciences and descriptive history",
        "Technical innovation and environmental engineering",
        "Cognitive philosophy and social debate",
    ])

    sections: List[SectionBlueprint] = []

    for s_idx, target in enumerate(section_targets):
        sec_id = target["section_id"]
        total_sec_q = target["total_questions"]
        start_q = target["start_q"]
        pool = target["families"]

        # Form variable groups (e.g. 2 or 3 groups per section)
        # For 13: 7 and 6, or 5, 4, 4
        # For 14: 7 and 7, or 5, 5, 4
        if sec_id == 1:
            group_counts = [7, 6]
        elif sec_id == 2:
            group_counts = [6, 7]
        else:
            group_counts = [7, 7]

        # Select families from candidate pool for groups
        selected_families = [pool[i % len(pool)] for i in range(len(group_counts))]

        slots: List[QuestionSlot] = []
        allocations: List[QuestionTypeAllocation] = []
        q_cursor = start_q

        for grp_idx, (g_count, fam) in enumerate(zip(group_counts, selected_families)):
            g_start = q_cursor
            g_end = q_cursor + g_count - 1

            allocations.append(
                QuestionTypeAllocation(
                    question_type=fam.value,
                    count=g_count,
                    start_question_number=g_start,
                    end_question_number=g_end,
                )
            )

            for q_num in range(g_start, g_end + 1):
                diff_level = (
                    DifficultyLevel.FOUNDATION
                    if sec_id == 1
                    else (DifficultyLevel.MODERATE if sec_id == 2 else DifficultyLevel.ADVANCED)
                )
                slots.append(
                    QuestionSlot(
                        question_number=q_num,
                        section_id=sec_id,
                        group_index=grp_idx,
                        question_type=fam,
                        target_skill=f"Evaluates comprehension of {fam.value} in Section {sec_id}",
                        target_difficulty=TargetDifficulty(
                            level=diff_level,
                            rationale=f"Editorial heuristic difficulty for Section {sec_id} Question {q_num}.",
                            is_calibrated=False,
                        ),
                        claim_ref_ids=[],
                        is_not_given_target=(
                            fam in (QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN, QuestionPromptFamily.YES_NO_NOT_GIVEN)
                            and q_num % 3 == 0
                        ),
                    )
                )

            q_cursor += g_count

        eg_ref = EvidenceGraphRef(
            graph_id=f"eg_sec{sec_id}_{run_id[:8]}",
            source_pack_id=f"pack_sec{sec_id}",
            version="v1.0.0",
            content_hash=hashlib.sha256(f"hash_sec{sec_id}_{run_id}".encode("utf-8")).hexdigest(),
            status="ACCEPTED",
            claim_count=12,
        )

        topic_str = topics[s_idx] if s_idx < len(topics) else f"Academic Topic for Section {sec_id}"

        sections.append(
            SectionBlueprint(
                section_id=sec_id,
                topic=topic_str,
                target_word_count=800,
                evidence_graph_ref=eg_ref,
                passage_objectives=[
                    PassageObjective(
                        objective_id=f"obj_sec{sec_id}_1",
                        description=f"Core passage objective for section {sec_id}",
                        mapped_claim_ids=[],
                        role="factual_foundation" if sec_id == 1 else ("process_mechanism" if sec_id == 2 else "argument_viewpoint"),
                    )
                ],
                question_allocations=allocations,
                question_slots=slots,
                budget_allocation=BudgetAllocation(
                    max_candidates_per_slot=1,
                    repair_headroom_calls=2,
                    max_tokens_allocated=15000,
                ),
                total_questions=total_sec_q,
            )
        )

    draft_bp = ExamBlueprint(
        blueprint_id=blueprint_id,
        run_id=run_id,
        policy_version=BLUEPRINT_POLICY_VERSION,
        schema_version=BLUEPRINT_SCHEMA_VERSION,
        sections=sections,
        total_questions=40,
        target_word_count_min=PAPER_MIN_WORDS,
        target_word_count_max=PAPER_MAX_WORDS,
        metadata={"blueprint_mode": "dynamic"},
    )

    canonical_dict = draft_bp.model_dump(by_alias=True)
    canonical_dict.pop("createdAt", None)
    canonical_dict.pop("contentHash", None)
    canonical_dict.pop("invalidatedDescendants", None)
    canonical_json = json.dumps(canonical_dict, sort_keys=True)
    content_hash = hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()

    return draft_bp.model_copy(update={"content_hash": content_hash})
