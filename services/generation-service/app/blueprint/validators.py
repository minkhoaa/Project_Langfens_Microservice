"""Code-Enforced Blueprint Validators for Langfens Loop Engine V2."""

from __future__ import annotations

from typing import Any, List, Optional
from pydantic import Field
from app.contracts.base import CanonicalBaseModel
from app.contracts.blueprint import (
    ExamBlueprint,
    SectionBlueprint,
    QuestionSlot,
    QuestionType,
    DifficultyLevel,
)
from app.contracts.question_type import QuestionPromptFamily
from app.contracts.issue import IssueSeverity
from app.blueprint.policies import (
    BLUEPRINT_POLICY_VERSION,
    SECTION_CONFIGURATIONS,
    TOTAL_PAPER_QUESTIONS,
    PAPER_MIN_WORDS,
    PAPER_MAX_WORDS,
    SECTION_MIN_WORDS,
    SECTION_MAX_WORDS,
)


class BlueprintIssue(CanonicalBaseModel):
    """Specific error or defect detected during blueprint validation."""

    code: str
    severity: IssueSeverity = IssueSeverity.CRITICAL
    message: str
    field: str


def validate_blueprint(
    blueprint: ExamBlueprint,
    mode: Optional[str] = None,
    evidence_map: Optional[Dict[int, Any]] = None,
    require_claims: Optional[bool] = None,
) -> List[BlueprintIssue]:
    """Validates structural and policy integrity of an ExamBlueprint.

    Supports 'dynamic' mode (default unless blueprint metadata or parameter specifies legacy_preset)
    and strict 'legacy_preset' mode.
    """
    issues: List[BlueprintIssue] = []

    effective_mode = mode or (blueprint.metadata or {}).get("blueprint_mode", "dynamic")
    if blueprint.total_questions != TOTAL_PAPER_QUESTIONS:
        issues.append(
            BlueprintIssue(
                code="BLUEPRINT_INVALID_TOTAL_QUESTIONS",
                severity=IssueSeverity.CRITICAL,
                message=f"ExamBlueprint total questions is {blueprint.total_questions}; expected {TOTAL_PAPER_QUESTIONS}.",
                field="totalQuestions",
            )
        )

    # 2. Section count and IDs
    sections = blueprint.sections or []
    if len(sections) != 3:
        issues.append(
            BlueprintIssue(
                code="BLUEPRINT_INVALID_SECTION_COUNT",
                severity=IssueSeverity.CRITICAL,
                message=f"ExamBlueprint has {len(sections)} sections; expected exactly 3.",
                field="sections",
            )
        )

    section_ids = [s.section_id for s in sections]
    if sorted(section_ids) != [1, 2, 3]:
        issues.append(
            BlueprintIssue(
                code="BLUEPRINT_INVALID_SECTION_IDS",
                severity=IssueSeverity.CRITICAL,
                message=f"Sections must be exactly [1, 2, 3]; got {section_ids}.",
                field="sections",
            )
        )

    # 3. Paper Word count targets
    if blueprint.target_word_count_min < PAPER_MIN_WORDS:
        issues.append(
            BlueprintIssue(
                code="BLUEPRINT_WORD_COUNT_MIN_TOO_LOW",
                severity=IssueSeverity.CRITICAL,
                message=f"targetWordCountMin {blueprint.target_word_count_min} < {PAPER_MIN_WORDS}.",
                field="targetWordCountMin",
            )
        )
    if blueprint.target_word_count_max > PAPER_MAX_WORDS:
        issues.append(
            BlueprintIssue(
                code="BLUEPRINT_WORD_COUNT_MAX_TOO_HIGH",
                severity=IssueSeverity.CRITICAL,
                message=f"targetWordCountMax {blueprint.target_word_count_max} > {PAPER_MAX_WORDS}.",
                field="targetWordCountMax",
            )
        )

    # 4. Slot coverage & question numbering across whole paper
    all_slots: List[QuestionSlot] = []
    for s in sections:
        all_slots.extend(s.question_slots or [])

    slot_numbers = [slot.question_number for slot in all_slots]
    expected_numbers = list(range(1, 41))

    if sorted(slot_numbers) != expected_numbers:
        missing = set(expected_numbers) - set(slot_numbers)
        duplicates = [x for x in slot_numbers if slot_numbers.count(x) > 1]
        issues.append(
            BlueprintIssue(
                code="BLUEPRINT_SLOTS_NOT_CONTIGUOUS_1_TO_40",
                severity=IssueSeverity.CRITICAL,
                message=f"Question slots must be contiguous 1..40. Missing: {sorted(missing)}, Duplicates: {sorted(set(duplicates))}.",
                field="questionSlots",
            )
        )

    # 5. Section-by-Section Validation
    total_planned_tokens = 0
    for section in sections:
        sec_id = section.section_id
        if sec_id not in SECTION_CONFIGURATIONS:
            continue

        sec_config = SECTION_CONFIGURATIONS[sec_id]

        # Target word count per section
        if section.target_word_count < SECTION_MIN_WORDS or section.target_word_count > SECTION_MAX_WORDS:
            issues.append(
                BlueprintIssue(
                    code="BLUEPRINT_SECTION_WORD_COUNT_OUT_OF_RANGE",
                    severity=IssueSeverity.CRITICAL,
                    message=f"Section {sec_id} target word count {section.target_word_count} not in [{SECTION_MIN_WORDS}, {SECTION_MAX_WORDS}].",
                    field=f"sections[{sec_id}].targetWordCount",
                )
            )

        # EvidenceGraphRef check
        graph_ref = section.evidence_graph_ref
        if not graph_ref:
            issues.append(
                BlueprintIssue(
                    code="BLUEPRINT_MISSING_GRAPH_REF",
                    severity=IssueSeverity.CRITICAL,
                    message=f"Section {sec_id} is missing evidenceGraphRef.",
                    field=f"sections[{sec_id}].evidenceGraphRef",
                )
            )
        else:
            if graph_ref.status != "ACCEPTED":
                issues.append(
                    BlueprintIssue(
                        code="BLUEPRINT_GRAPH_REF_NOT_ACCEPTED",
                        severity=IssueSeverity.CRITICAL,
                        message=f"Section {sec_id} references EvidenceGraph {graph_ref.graph_id} with status '{graph_ref.status}'; must be ACCEPTED.",
                        field=f"sections[{sec_id}].evidenceGraphRef.status",
                    )
                )
            if not graph_ref.content_hash:
                issues.append(
                    BlueprintIssue(
                        code="BLUEPRINT_GRAPH_REF_EMPTY_HASH",
                        severity=IssueSeverity.CRITICAL,
                        message=f"Section {sec_id} EvidenceGraph ref has empty contentHash.",
                        field=f"sections[{sec_id}].evidenceGraphRef.contentHash",
                    )
                )

        # Slots in this section
        sec_slots = section.question_slots or []
        if effective_mode == "legacy_preset":
            if len(sec_slots) != sec_config["total_questions"]:
                issues.append(
                    BlueprintIssue(
                        code="BLUEPRINT_SECTION_SLOT_COUNT_MISMATCH",
                        severity=IssueSeverity.CRITICAL,
                        message=f"Section {sec_id} has {len(sec_slots)} slots; expected {sec_config['total_questions']}.",
                        field=f"sections[{sec_id}].questionSlots",
                    )
                )

            # Validate Groups and Question Types strictly for legacy preset
            for grp in sec_config["groups"]:
                grp_slots = [
                    s for s in sec_slots
                    if s.group_index == grp["group_index"]
                ]
                if len(grp_slots) != grp["count"]:
                    issues.append(
                        BlueprintIssue(
                            code="BLUEPRINT_GROUP_COUNT_MISMATCH",
                            severity=IssueSeverity.CRITICAL,
                            message=(
                                f"Section {sec_id} Group {grp['group_index']} has {len(grp_slots)} slots; "
                                f"expected {grp['count']} ({grp['question_type'].value})."
                            ),
                            field=f"sections[{sec_id}].questionSlots",
                        )
                    )

                for slot in grp_slots:
                    raw_slot_type = slot.question_type
                    slot_type_val = getattr(raw_slot_type, "value", str(raw_slot_type))
                    expected_val = getattr(grp["question_type"], "value", str(grp["question_type"]))
                    if slot_type_val != expected_val:
                        issues.append(
                            BlueprintIssue(
                                code="BLUEPRINT_SLOT_TYPE_MISMATCH",
                                severity=IssueSeverity.CRITICAL,
                                message=(
                                    f"Question {slot.question_number} in Section {sec_id} Group {grp['group_index']} "
                                    f"has type {slot_type_val}; expected {expected_val}."
                                ),
                                field=f"sections[{sec_id}].questionSlots[{slot.question_number}].questionType",
                            )
                        )

                    # Difficulty checks
                    diff = slot.target_difficulty
                    if diff.is_calibrated:
                        issues.append(
                            BlueprintIssue(
                                code="BLUEPRINT_CALIBRATED_DIFFICULTY_PROHIBITED",
                                severity=IssueSeverity.CRITICAL,
                                message=(
                                    f"Question {slot.question_number} claims calibrated IELTS band difficulty. "
                                    f"Pre-pilot calibrated difficulty is prohibited by policy."
                                ),
                                field=f"sections[{sec_id}].questionSlots[{slot.question_number}].targetDifficulty.isCalibrated",
                            )
                        )
                    if not diff.rationale or len(diff.rationale.strip()) < 5:
                        issues.append(
                            BlueprintIssue(
                                code="BLUEPRINT_DIFFICULTY_RATIONALE_MISSING",
                                severity=IssueSeverity.CRITICAL,
                                message=f"Question {slot.question_number} lacks targetDifficulty rationale.",
                                field=f"sections[{sec_id}].questionSlots[{slot.question_number}].targetDifficulty.rationale",
                            )
                        )
        else:
            # Dynamic mode:
            # - Allow >= 1 groups per section
            # - Validate slot count >= 1 and that all slots sum to section total
            if len(sec_slots) < 1:
                issues.append(
                    BlueprintIssue(
                        code="BLUEPRINT_SECTION_EMPTY_SLOTS",
                        severity=IssueSeverity.CRITICAL,
                        message=f"Section {sec_id} has no question slots.",
                        field=f"sections[{sec_id}].questionSlots",
                    )
                )

            # Validate that question types in slots are valid IELTS families
            for slot in sec_slots:
                raw_type = slot.question_type
                # Check if it's strictly a member of QuestionPromptFamily or QuestionType
                is_valid_type = False
                if isinstance(raw_type, (QuestionPromptFamily, QuestionType)):
                    is_valid_type = True
                elif isinstance(raw_type, str):
                    # Check if string matches any QuestionPromptFamily name/value or QuestionType name/value
                    norm = raw_type.strip()
                    is_valid_type = any(
                        norm == member.value or norm == member.name for member in QuestionPromptFamily
                    ) or any(
                        norm == member.value or norm == member.name for member in QuestionType
                    )

                if not is_valid_type:
                    issues.append(
                        BlueprintIssue(
                            code="BLUEPRINT_INVALID_QUESTION_TYPE",
                            severity=IssueSeverity.CRITICAL,
                            message=f"Question {slot.question_number} has unrecognized question type: {raw_type}.",
                            field=f"sections[{sec_id}].questionSlots[{slot.question_number}].questionType",
                        )
                    )

                # Difficulty checks (P05-05: difficulty is heuristic/editorial, NOT calibrated IELTS band)
                diff = slot.target_difficulty
                if diff.is_calibrated:
                    issues.append(
                        BlueprintIssue(
                            code="BLUEPRINT_CALIBRATED_DIFFICULTY_PROHIBITED",
                            severity=IssueSeverity.CRITICAL,
                            message=(
                                f"Question {slot.question_number} claims calibrated IELTS band difficulty. "
                                f"Pre-pilot calibrated difficulty is prohibited by policy."
                            ),
                            field=f"sections[{sec_id}].questionSlots[{slot.question_number}].targetDifficulty.isCalibrated",
                        )
                    )
                if not diff.rationale or len(diff.rationale.strip()) < 5:
                    issues.append(
                        BlueprintIssue(
                            code="BLUEPRINT_DIFFICULTY_RATIONALE_MISSING",
                            severity=IssueSeverity.CRITICAL,
                            message=f"Question {slot.question_number} lacks targetDifficulty rationale.",
                            field=f"sections[{sec_id}].questionSlots[{slot.question_number}].targetDifficulty.rationale",
                        )
                    )

                # Claim reference checks: non-empty when claims are required and non-fabricated
                must_have_claims = require_claims if require_claims is not None else (evidence_map is not None)
                if must_have_claims and not slot.claim_ref_ids:
                    issues.append(
                        BlueprintIssue(
                            code="BLUEPRINT_EMPTY_CLAIM_REFS",
                            severity=IssueSeverity.CRITICAL,
                            message=f"Question {slot.question_number} has empty claimRefIds; accepted blueprint question slots must reference verified evidence.",
                            field=f"sections[{sec_id}].questionSlots[{slot.question_number}].claimRefIds",
                        )
                    )
                for cid in slot.claim_ref_ids:
                    if cid.startswith("claim:run_") or cid.startswith("claim:None:") or cid.startswith("claim:synthetic:"):
                        issues.append(
                            BlueprintIssue(
                                code="BLUEPRINT_FABRICATED_CLAIM_PROHIBITED",
                                severity=IssueSeverity.CRITICAL,
                                message=f"Question {slot.question_number} has fabricated synthetic claim ID '{cid}'.",
                                field=f"sections[{sec_id}].questionSlots[{slot.question_number}].claimRefIds",
                            )
                        )
                if evidence_map and sec_id in evidence_map:
                    ev_data = evidence_map[sec_id]
                    ev_payload = getattr(ev_data, "payload", ev_data) if hasattr(ev_data, "payload") else ev_data
                    if isinstance(ev_payload, dict):
                        ev_claims = ev_payload.get("claims", [])
                    elif hasattr(ev_payload, "claims"):
                        ev_claims = ev_payload.claims or []
                    else:
                        ev_claims = []
                    valid_cids = {
                        c.claim_id if hasattr(c, "claim_id") else c.get("claimId")
                        for c in ev_claims
                    }
                    for cid in slot.claim_ref_ids:
                        if cid not in valid_cids:
                            issues.append(
                                BlueprintIssue(
                                    code="BLUEPRINT_CLAIM_NOT_FOUND",
                                    severity=IssueSeverity.CRITICAL,
                                    message=f"Question {slot.question_number} references claim '{cid}' which is not in Section {sec_id}'s verified EvidenceGraph.",
                                    field=f"sections[{sec_id}].questionSlots[{slot.question_number}].claimRefIds",
                                )
                            )
        # Budget Allocation Check
        if section.budget_allocation:
            total_planned_tokens += section.budget_allocation.max_tokens_allocated
            if section.budget_allocation.max_candidates_per_slot > 3:
                issues.append(
                    BlueprintIssue(
                        code="BLUEPRINT_CANDIDATE_ALLOCATION_EXCEEDS_CAP",
                        severity=IssueSeverity.CRITICAL,
                        message=(
                            f"Section {sec_id} allocated {section.budget_allocation.max_candidates_per_slot} "
                            f"candidates per slot (cap is 3)."
                        ),
                        field=f"sections[{sec_id}].budgetAllocation.maxCandidatesPerSlot",
                    )
                )
    # 6. Overall Budget Cap
    if blueprint.parent_budget_cap_tokens is not None:
        if total_planned_tokens > blueprint.parent_budget_cap_tokens:
            issues.append(
                BlueprintIssue(
                    code="BLUEPRINT_BUDGET_EXCEEDS_PARENT_CAP",
                    severity=IssueSeverity.CRITICAL,
                    message=(
                        f"Total planned tokens {total_planned_tokens} exceeds parent cap "
                        f"{blueprint.parent_budget_cap_tokens}."
                    ),
                    field="parentBudgetCapTokens",
                )
            )

    return issues
