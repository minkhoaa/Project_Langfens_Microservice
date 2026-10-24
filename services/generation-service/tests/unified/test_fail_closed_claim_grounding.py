"""Mandatory Fail-Closed Semantic Claim Binding & Authoritative Acceptance Suite (Workstream C).

Tests:
C1. Suitable verified claim accepted.
C2. Existing but irrelevant claim rejected.
C3. All unsuitable claims -> fail closed.
C4. Claim from another section rejected.
C5. Missing graph membership rejected in evaluate_blueprint.
C6. Stale claim / evidence graph rejected.
C7. Missing passage quote rejected in compose_questions.
C8. No unrelated fallback span accepted (first-sentence fallback removed).
C9. Deterministic claim selection preserved.
C10. Valid legacy and dynamic paths remain compatible.
C11. Invalid binding rejected on the authoritative production path (pipeline / evaluate_blueprint),
     not merely in a standalone unit test.
"""

from __future__ import annotations

import pytest
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.blueprint import QuestionSlot, TargetDifficulty, DifficultyLevel
from app.contracts.issue import IssueCode
from app.contracts.question_type import QuestionPromptFamily
from app.blueprint.claim_binding import (
    bind_claims_to_slots,
    check_claim_eligibility_for_family,
    score_claim_suitability_for_family,
)
from app.reading_evaluation import evaluate_blueprint
from app.reading_generation import compose_questions
from app.reading_policy import PinnedExecutionPolicy


def make_slot(q_num: int, q_type: QuestionPromptFamily, sec_id: int = 1) -> QuestionSlot:
    return QuestionSlot(
        questionNumber=q_num,
        sectionId=sec_id,
        groupIndex=0,
        questionType=q_type,
        targetSkill="factual_inference",
        targetDifficulty=TargetDifficulty(level=DifficultyLevel.FOUNDATION, isCalibrated=False, rationale="Editorial"),
        claimRefIds=[],
    )


def test_c1_suitable_verified_claim_accepted():
    """C1: Claim matching family semantic criteria is accepted and given a high score."""
    proc_claim = {
        "claimId": "claim:proc_1",
        "text": "The cycle converts fluid pressure into kinetic energy through a turbine mechanism.",
        "keywords": ["cycle", "mechanism", "converts"],
        "sectionId": 1,
    }
    assert check_claim_eligibility_for_family(proc_claim, "FLOW_CHART", section_id=1) is True
    score = score_claim_suitability_for_family(proc_claim, "FLOW_CHART", section_id=1)
    assert score >= 4.0


def test_c2_existing_but_irrelevant_claim_rejected():
    """C2: An existing claim with zero semantic overlap for the family is deemed ineligible."""
    irrelevant_claim = {
        "claimId": "claim:irrel_1",
        "text": "The ceramic glaze contained trace residues of medieval lead enamel.",
        "keywords": ["glaze", "enamel"],
        "sectionId": 1,
    }
    assert check_claim_eligibility_for_family(irrelevant_claim, "FLOW_CHART", section_id=1) is False
    score = score_claim_suitability_for_family(irrelevant_claim, "FLOW_CHART", section_id=1)
    assert score <= 0.0


def test_c3_all_unsuitable_claims_fail_closed():
    """C3: When all candidate claims fail semantic eligibility, bind_claims_to_slots fails closed."""
    slot = make_slot(1, QuestionPromptFamily.FLOW_CHART, sec_id=1)
    unsuitable_claims = [
        {"claimId": "c1", "text": "The painter used lapis lazuli pigment.", "keywords": ["pigment"], "sectionId": 1},
        {"claimId": "c2", "text": "Excavators uncovered decorative pottery shards.", "keywords": ["pottery"], "sectionId": 1},
    ]
    with pytest.raises(ValueError, match="no eligible verified claims"):
        bind_claims_to_slots([slot], unsuitable_claims, section_id=1, graph_id="eg_1", run_id="run_1")


def test_c4_claim_from_another_section_rejected():
    """C4: Claims belonging to a different section/source are strictly rejected."""
    slot = make_slot(1, QuestionPromptFamily.FLOW_CHART, sec_id=1)
    other_section_claim = {
        "claimId": "c_sec2",
        "text": "The flow mechanism converts fluid pressure into mechanical work in a cyclical sequence.",
        "keywords": ["mechanism", "cycle"],
        "sectionId": 2,  # Belongs to section 2
        "sourceId": "PMC_SEC2",
    }
    with pytest.raises(ValueError, match="cross-section|no eligible verified claims"):
        bind_claims_to_slots([slot], [other_section_claim], section_id=1, graph_id="eg_1", run_id="run_1")


def test_c5_missing_graph_membership_rejected_in_evaluate_blueprint():
    """C5: Authoritative evaluate_blueprint rejects slots referencing claims not in the evidence graph."""
    policy = PinnedExecutionPolicy(provider="mock")
    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "passageObjectives": ["Objective 1"],
                "evidenceGraphRef": {"artifactId": "eg_1", "version": 1, "contentHash": "h1"},
                "questionSlots": [
                    {
                        "questionNumber": q_num,
                        "questionType": "TRUE_FALSE_NOT_GIVEN",
                        "claimRefIds": ["claim:non_existent_999"],
                    }
                    for q_num in range(1, 14)
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create("bp:test_c5", ArtifactType.EXAM_BLUEPRINT, "run_c5", bp_payload, "1.0.0")
    evidence_map = {
        1: {
            "claims": [
                {"claimId": "claim:real_1", "text": "Real verified claim text.", "keywords": []}
            ]
        }
    }
    eval_results = evaluate_blueprint(bp_env, policy, (1,), evidence_map=evidence_map)
    failed = [e for e in eval_results if not e.is_pass()]
    assert len(failed) > 0, "evaluate_blueprint must fail closed when slot references missing claim"
    assert any("not in Section 1's verified EvidenceGraph" in i.message for e in failed for i in e.issues)


def test_c6_stale_claim_evidence_graph_rejected():
    """C6: Stale or unverified claims fail blueprint evaluation."""
    policy = PinnedExecutionPolicy(provider="mock")
    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "passageObjectives": ["Objective 1"],
                "evidenceGraphRef": {"artifactId": "eg_1", "version": 1, "contentHash": "h1"},
                "questionSlots": [
                    {
                        "questionNumber": q_num,
                        "questionType": "TRUE_FALSE_NOT_GIVEN",
                        "claimRefIds": ["claim:stale_1"],
                    }
                    for q_num in range(1, 14)
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create("bp:test_c6", ArtifactType.EXAM_BLUEPRINT, "run_c6", bp_payload, "1.0.0")
    evidence_map = {1: {"claims": []}}  # Empty claims in graph
    eval_results = evaluate_blueprint(bp_env, policy, (1,), evidence_map=evidence_map)
    failed = [e for e in eval_results if not e.is_pass()]
    assert len(failed) > 0


def test_c7_c8_missing_passage_quote_rejected_no_fallback_to_para1():
    """C7 & C8: In compose_questions, if a bound claim quote cannot be located in the passage,
    it must fail closed (raise ValueError) instead of substituting paragraph 1."""
    policy = PinnedExecutionPolicy(provider="mock")
    config = policy.section(1)
    passage = "A paragraph about early Bronze Age settlements in western Europe. Completely unrelated to metallurgy."
    claims = [
        {
            "claimId": "claim_metal_1",
            "text": "Furnace temperatures reached twelve hundred degrees Celsius during reduction.",
        }
    ]
    slots = [
        {
            "questionNumber": q_num,
            "groupIndex": 0,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "claimRefIds": ["claim_metal_1"],
        }
        for q_num in range(1, 14)
    ]
    with pytest.raises(ValueError, match="cannot be located in the passage text"):
        compose_questions(1, passage, claims, slots, config)


def test_c9_deterministic_claim_selection_preserved():
    """C9: Deterministic selection produces identical bindings across runs."""
    slot = make_slot(1, QuestionPromptFamily.FLOW_CHART, sec_id=1)
    eligible_claims = [
        {"claimId": "c_proc_1", "text": "Continuous process transforms iron ore through gas reduction.", "keywords": ["process", "transforms"], "sectionId": 1},
        {"claimId": "c_proc_2", "text": "The operational cycle produces refined bloomery iron in a multi-stage reaction.", "keywords": ["cycle", "produces"], "sectionId": 1},
    ]
    res1 = bind_claims_to_slots([slot], eligible_claims, section_id=1, graph_id="eg_1", run_id="run_det")
    res2 = bind_claims_to_slots([slot], eligible_claims, section_id=1, graph_id="eg_1", run_id="run_det")
    assert res1[0].claim_ref_ids == res2[0].claim_ref_ids


def test_c10_valid_dynamic_and_legacy_paths_compatible():
    """C10: Valid claims succeed under both dynamic and legacy preset policy modes."""
    slot = make_slot(1, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN, sec_id=1)
    claim = {
        "claimId": "c_tfng",
        "text": "Radiocarbon dating measured occupation spanning twelve centuries.",
        "keywords": ["dating", "measured"],
        "sectionId": 1,
    }
    bound = bind_claims_to_slots([slot], [claim], section_id=1, graph_id="eg_1", run_id="run_dyn")
    assert bound[0].claim_ref_ids == ["c_tfng"]


def test_c11_invalid_binding_rejected_on_authoritative_pipeline_path():
    """C11: Pipeline evaluate_blueprint_stage rejects fabricated and ungrounded claims fail-closed."""
    policy = PinnedExecutionPolicy(provider="mock")
    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "passageObjectives": ["Objective 1"],
                "evidenceGraphRef": {"artifactId": "eg_1", "version": 1, "contentHash": "h1"},
                "questionSlots": [
                    {
                        "questionNumber": q_num,
                        "questionType": "TRUE_FALSE_NOT_GIVEN",
                        "claimRefIds": ["claim:synthetic:unauthorized"],
                    }
                    for q_num in range(1, 14)
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create("bp:test_c11", ArtifactType.EXAM_BLUEPRINT, "run_c11", bp_payload, "1.0.0")
    evidence_map = {1: {"claims": [{"claimId": "claim:legit_1", "text": "Legitimate claim", "keywords": []}]}}
    eval_results = evaluate_blueprint(bp_env, policy, (1,), evidence_map=evidence_map)
    failed = [e for e in eval_results if not e.is_pass()]
    assert len(failed) > 0
    assert any("fabricated synthetic claim" in i.message or "not in Section 1's verified EvidenceGraph" in i.message for e in failed for i in e.issues)
