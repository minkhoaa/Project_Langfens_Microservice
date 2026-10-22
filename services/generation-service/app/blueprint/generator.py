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
    compute_canonical_blueprint_hash,
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
    QuestionPromptFamily.FORM_COMPLETION,
]

SECTION_2_FAMILIES = [
    QuestionPromptFamily.MATCHING_INFORMATION,
    QuestionPromptFamily.MATCHING_FEATURES,
    QuestionPromptFamily.SUMMARY_COMPLETION,
    QuestionPromptFamily.DIAGRAM_LABEL,
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX,
    QuestionPromptFamily.CLASSIFICATION,
]

SECTION_3_FAMILIES = [
    QuestionPromptFamily.MATCHING_HEADING,
    QuestionPromptFamily.YES_NO_NOT_GIVEN,
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE,
    QuestionPromptFamily.MATCHING_ENDINGS,
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
    QuestionPromptFamily.CHOOSING_TITLE,
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


def _score_family_suitability(
    fam: QuestionPromptFamily,
    sec_id: int,
    sec_evidence: Dict[str, Any],
    topic: str,
    seed_int: int,
) -> float:
    """Scores candidate question family based on evidence characteristics and deterministic tie-breaking."""
    score = 1.0
    text_corpus = (str(topic) + " " + json.dumps(sec_evidence)).lower()

    # Evidence keyword matching
    if any(k in text_corpus for k in ("mechanism", "process", "cycle", "produce", "step", "flow", "pathway", "engineering")):
        if fam in (QuestionPromptFamily.FLOW_CHART, QuestionPromptFamily.DIAGRAM_LABEL, QuestionPromptFamily.TABLE_COMPLETION):
            score += 5.0
        elif fam in (QuestionPromptFamily.SUMMARY_COMPLETION, QuestionPromptFamily.SUMMARY_COMPLETION_BOX):
            score += 3.0

    if any(k in text_corpus for k in ("argue", "claim", "debate", "hypothesis", "theorize", "view", "opinion", "contend", "dispute")):
        if fam in (QuestionPromptFamily.YES_NO_NOT_GIVEN, QuestionPromptFamily.MATCHING_ENDINGS, QuestionPromptFamily.MATCHING_HEADING):
            score += 5.0
        elif fam in (QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE, QuestionPromptFamily.CHOOSING_TITLE):
            score += 3.0

    if any(k in text_corpus for k in ("entity", "researcher", "population", "species", "discover", "category", "feature")):
        if fam in (QuestionPromptFamily.MATCHING_FEATURES, QuestionPromptFamily.CLASSIFICATION, QuestionPromptFamily.MATCHING_INFORMATION):
            score += 4.0

    if any(k in text_corpus for k in ("observe", "strata", "date", "measure", "year", "history", "factual", "chronol")):
        if fam in (QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN, QuestionPromptFamily.SENTENCE_COMPLETION, QuestionPromptFamily.NOTE_COMPLETION, QuestionPromptFamily.SHORT_ANSWER):
            score += 4.0

    # Section 1 authentic anchor: IELTS Academic Passage 1 prioritizes TRUE_FALSE_NOT_GIVEN
    if sec_id == 1 and fam == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN:
        score += 2.0

    # Deterministic pseudo-random tie-break for reproducible variety
    tie_break_seed = f"{seed_int}:{sec_id}:{fam.value}"
    tie_break_hash = int(hashlib.sha256(tie_break_seed.encode()).hexdigest()[:6], 16)
    score += (tie_break_hash % 1000) / 1000.0

    return score


def _determine_section_group_counts(
    sec_id: int,
    sec_evidence: Dict[str, Any],
    seed_int: int,
) -> List[int]:
    """Determines authentic variable question group counts per IELTS Academic section summing to 13, 13, 14."""
    claims = sec_evidence.get("claims", [])
    claim_count = sec_evidence.get("claim_count") or len(claims)
    has_processes = sec_evidence.get("has_mechanisms") or sec_evidence.get("process_steps")

    if sec_id == 1:
        # Sum to 13
        opts = [[7, 6], [6, 7], [5, 4, 4]]
        if claim_count >= 14:
            return opts[2]  # 3 groups for rich evidence
        return opts[(seed_int + 1 + claim_count) % len(opts)]
    elif sec_id == 2:
        # Section 2 dynamic: 3 groups summing to 13
        opts = [[5, 4, 4], [4, 5, 4], [4, 4, 5]]
        if has_processes:
            return opts[0]
        return opts[(seed_int + 2 + claim_count) % len(opts)]
    else:
        # Sum to 14
        opts = [[7, 7], [5, 5, 4], [6, 4, 4]]
        if claim_count >= 14:
            return opts[1]
        return opts[(seed_int + 3 + claim_count) % len(opts)]


def generate_dynamic_blueprint(
    policy: PinnedExecutionPolicy,
    evidence_summary: Optional[Dict[str, Any]] = None,
) -> ExamBlueprint:
    """Generates an ExamBlueprint according to policy and evidence summary.

    When policy.blueprint_mode == 'legacy_preset', returns the strict 6-type preset.
    When policy.blueprint_mode == 'dynamic', allocates questions across 3 sections
    (13, 13, 14 summing to 40) using authentic evidence-driven suitability and diversity.
    """
    evidence_summary = evidence_summary or {}
    run_id = evidence_summary.get("run_id") or f"run_{uuid.uuid4().hex[:8]}"
    blueprint_id = f"blueprint:{run_id}" if "run_id" in evidence_summary else f"bp_{uuid.uuid4().hex[:12]}"

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

    seed_str = f"{policy.provider}_{'_'.join(topics)}"
    seed_val = int(hashlib.sha256(seed_str.encode("utf-8")).hexdigest()[:8], 16)

    sections: List[SectionBlueprint] = []
    used_families_paper: set[QuestionPromptFamily] = set()

    for s_idx, target in enumerate(section_targets):
        sec_id = target["section_id"]
        total_sec_q = target["total_questions"]
        start_q = target["start_q"]
        pool = target["families"]
        topic_str = topics[s_idx] if s_idx < len(topics) else f"Academic Topic for Section {sec_id}"
        sec_ev = evidence_summary.get("section_evidence", {}).get(sec_id, {})

        # Evidence-driven group distribution (summing to total_sec_q)
        group_counts = _determine_section_group_counts(sec_id, sec_ev, seed_val)

        # Evidence-driven family scoring & selection enforcing paper-wide diversity
        scored_families = sorted(
            pool,
            key=lambda f: _score_family_suitability(f, sec_id, sec_ev, topic_str, seed_val),
            reverse=True,
        )

        selected_families: List[QuestionPromptFamily] = []
        for fam in scored_families:
            if fam not in used_families_paper:
                selected_families.append(fam)
                used_families_paper.add(fam)
                if len(selected_families) == len(group_counts):
                    break

        if len(selected_families) < len(group_counts):
            for fam in scored_families:
                if fam not in selected_families:
                    selected_families.append(fam)
                    if len(selected_families) == len(group_counts):
                        break

        slots: List[QuestionSlot] = []
        allocations: List[QuestionTypeAllocation] = []
        q_cursor = start_q

        for grp_idx, (g_count, fam) in enumerate(zip(group_counts, selected_families)):
            g_start = q_cursor
            g_end = q_cursor + g_count - 1

            allocations.append(
                QuestionTypeAllocation(
                    question_type=QuestionType(fam.value),
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
                        question_type=QuestionType(fam.value),
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

    content_hash = compute_canonical_blueprint_hash(draft_bp)
    return draft_bp.model_copy(update={"content_hash": content_hash})
