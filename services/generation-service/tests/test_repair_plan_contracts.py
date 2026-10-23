from __future__ import annotations

import pytest
from pydantic import ValidationError

from app.contracts.issue import IssueCode
from app.repair.contracts import (
    RepairAction,
    RepairPlan,
    RepairPlanValidationError,
    validate_repair_plan_compatibility,
)


def test_valid_repair_plan_passes_validation():
    plan = RepairPlan(
        issueCode=IssueCode.AMBIGUOUS_ANSWER,
        targetQuestion=3,
        repairAction=RepairAction.REPHRASE_STEM,
        diagnosis="The stem allows multiple interpretations without qualifying the timeframe.",
        repairConstraints=[
            "Qualify the century explicitly to 14th century",
            "Preserve verified answer 'iron smelting'",
        ],
        preserveEvidenceClaimRef="claim_s1_fact_02",
        expectedCorrection="What technology spread across West Africa during the 14th century?",
    )
    validate_repair_plan_compatibility(plan, authoritative_claim_ref="claim_s1_fact_02")
    assert plan.repair_action == RepairAction.REPHRASE_STEM
    assert plan.target_question == 3


def test_invalid_repair_action_rejected():
    with pytest.raises(ValidationError):
        RepairPlan(
            issueCode=IssueCode.AMBIGUOUS_ANSWER,
            targetQuestion=1,
            repairAction="ARBITRARY_TOOL_CALL",  # Not in strict enum
            diagnosis="invalid",
            repairConstraints=["constraint 1"],
            preserveEvidenceClaimRef="claim_1",
        )


def test_incompatible_issue_code_and_action_rejected():
    # BAD_DISTRACTOR cannot use REFINE_CLOZE_TARGET (MCQ distractor requires SWAP_DISTRACTOR)
    plan = RepairPlan(
        issueCode=IssueCode.BAD_DISTRACTOR,
        targetQuestion=2,
        repairAction=RepairAction.REFINE_CLOZE_TARGET,
        diagnosis="Wrong action for distractor issue",
        repairConstraints=["Some constraint"],
        preserveEvidenceClaimRef="claim_1",
    )
    with pytest.raises(RepairPlanValidationError, match="Incompatible repairAction"):
        validate_repair_plan_compatibility(plan, authoritative_claim_ref="claim_1")


def test_claim_mutation_rejected():
    plan = RepairPlan(
        issueCode=IssueCode.AMBIGUOUS_ANSWER,
        targetQuestion=5,
        repairAction=RepairAction.REPHRASE_STEM,
        diagnosis="Stem ambiguous",
        repairConstraints=["Constrain to paragraph 2"],
        preserveEvidenceClaimRef="mutated_claim_id_99",  # Mutated from authoritative
    )
    with pytest.raises(RepairPlanValidationError, match="Claim preservation violated"):
        validate_repair_plan_compatibility(plan, authoritative_claim_ref="claim_s1_fact_02")


def test_empty_constraints_rejected():
    plan = RepairPlan(
        issueCode=IssueCode.AMBIGUOUS_ANSWER,
        targetQuestion=1,
        repairAction=RepairAction.REPHRASE_STEM,
        diagnosis="Stem ambiguous",
        repairConstraints=[],  # Empty
        preserveEvidenceClaimRef="claim_1",
    )
    with pytest.raises(RepairPlanValidationError, match="repairConstraints must contain at least one directive"):
        validate_repair_plan_compatibility(plan, authoritative_claim_ref="claim_1")


def test_all_five_repair_actions_exist():
    expected = {
        "REPHRASE_STEM",
        "SWAP_DISTRACTOR",
        "REFINE_CLOZE_TARGET",
        "CLARIFY_NOT_GIVEN_BOUNDARY",
        "REGENERATE_DISTINCT_CANDIDATE",
    }
    actual = {a.value for a in RepairAction}
    assert actual == expected
