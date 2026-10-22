"""Tests for Workstream A: Evidence-Aware Semantic Claim Binding.

Verifies:
A1. Same evidence + policy → identical allocations/bindings/hash.
A2. Different claim structure → appropriate suitability response.
A3. Unrelated verified claim → rejected binding.
A4. Missing claim ID → fail closed.
A5. Empty accepted claim graph → no accepted blueprint.
A6. Stale evidence dependency → invalidation/rejection.
A7. Insufficient family-specific evidence → safe handling / diagnostic.
A8. Valid full blueprint → 3 sections, 40 numbered slots.
A9. Explicit legacy preset → no regression.
"""

from __future__ import annotations

import copy
import pytest
from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.blueprint import ExamBlueprint
from app.contracts.evidence import EvidenceGraph, VerifiedClaim, SourceOffset
from app.blueprint.claim_binding import (
    bind_claims_to_slots,
    score_claim_suitability_for_family,
)
from app.blueprint.generator import generate_dynamic_blueprint
from app.blueprint.validators import validate_blueprint
from app.reading_generation import build_blueprint
from app.reading_policy import PinnedExecutionPolicy


def _make_sample_claims(section_id: int = 1) -> list[dict]:
    return [
        {
            "claimId": f"claim_s{section_id}_proc_1",
            "text": "The primary biochemical pathway converts dissolved silica into protective cellular frustules through enzymatic regulation.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["pathway", "converts", "regulation", "biochemical"],
        },
        {
            "claimId": f"claim_s{section_id}_proc_2",
            "text": "During the secondary stage of cell division, chromosomes separate and trigger intermediate membrane synthesis.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["stage", "trigger", "synthesis", "membrane"],
        },
        {
            "claimId": f"claim_s{section_id}_entity_1",
            "text": "Dr. Eleanor Vance at Oxford University identified three distinct population groups inhabiting coastal wetlands in 1994.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["identified", "population", "groups", "oxford"],
        },
        {
            "claimId": f"claim_s{section_id}_entity_2",
            "text": "The research team classified two sub-species according to cranial morphometrics and geographical distribution.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["classified", "team", "species", "category"],
        },
        {
            "claimId": f"claim_s{section_id}_stance_1",
            "text": "Critics argue that current oceanic carbon sequestration models overestimate biological pump efficiency by twenty percent.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["argue", "critics", "contend", "overestimate"],
        },
        {
            "claimId": f"claim_s{section_id}_stance_2",
            "text": "Professor Aris Thorne hypothesized that atmospheric transmission anomalies reflect stellar flare activity rather than planetary rings.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["hypothesized", "suggests", "viewpoint", "speculate"],
        },
        {
            "claimId": f"claim_s{section_id}_fact_1",
            "text": "Archaeological excavation in 1982 revealed that the settlement expanded across 45 hectares during the third century BC.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["excavation", "hectares", "century", "measured"],
        },
        {
            "claimId": f"claim_s{section_id}_fact_2",
            "text": "Water salinity levels reached an average concentration of 34 parts per thousand throughout the tidal estuary.",
            "sourceId": f"src_s{section_id}",
            "keywords": ["salinity", "average", "concentration", "measured"],
        },
    ]


def test_a1_reproducible_evidence_and_policy_yields_identical_bindings_and_hash():
    """A1. Identical evidence and policy produce 100% identical allocations, claim bindings, and contentHash."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    claims = _make_sample_claims(section_id=1)
    ev_env = ArtifactEnvelope.create(
        "art_eg_1",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a1",
        {
            "graphId": "graph_s1",
            "sourcePackId": "src_s1",
            "contentHash": "sha_hash_evidence_1",
            "claims": claims,
        },
        "2.0.0",
    )

    bp1 = build_blueprint(ev_env, "run_a1", policy.sections, policy=policy, topic="Paleo-agriculture")
    bp2 = build_blueprint(ev_env, "run_a1", policy.sections, policy=policy, topic="Paleo-agriculture")

    assert bp1["contentHash"] == bp2["contentHash"]
    for s1, s2 in zip(bp1["sections"], bp2["sections"]):
        assert len(s1["questionSlots"]) == len(s2["questionSlots"])
        for q1, q2 in zip(s1["questionSlots"], s2["questionSlots"]):
            assert q1["questionNumber"] == q2["questionNumber"]
            assert q1["questionType"] == q2["questionType"]
            assert q1["claimRefIds"] == q2["claimRefIds"]


def test_a2_claim_structure_suitability_differentiation():
    """A2. Semantic claim scoring differentiates process, stance, entity, and factual claims."""
    claims = _make_sample_claims(section_id=2)
    claim_by_id = {c["claimId"]: c for c in claims}

    # FLOW_CHART scores higher on process claim than on stance or entity claim
    flow_proc_score = score_claim_suitability_for_family(claim_by_id["claim_s2_proc_1"], "FLOW_CHART", 2)
    flow_stance_score = score_claim_suitability_for_family(claim_by_id["claim_s2_stance_1"], "FLOW_CHART", 2)
    assert flow_proc_score > flow_stance_score, f"Process score {flow_proc_score} must exceed stance score {flow_stance_score}"

    # YES_NO_NOT_GIVEN scores higher on stance claim than on process claim
    yn_stance_score = score_claim_suitability_for_family(claim_by_id["claim_s2_stance_1"], "YES_NO_NOT_GIVEN", 3)
    yn_proc_score = score_claim_suitability_for_family(claim_by_id["claim_s2_proc_1"], "YES_NO_NOT_GIVEN", 3)
    assert yn_stance_score > yn_proc_score

    # MATCHING_FEATURES scores higher on entity claim than on factual salinity claim
    mf_entity_score = score_claim_suitability_for_family(claim_by_id["claim_s2_entity_1"], "MATCHING_FEATURES", 2)
    mf_fact_score = score_claim_suitability_for_family(claim_by_id["claim_s2_fact_2"], "MATCHING_FEATURES", 2)
    assert mf_entity_score > mf_fact_score


def test_a3_unrelated_or_unregistered_claim_binding_is_rejected_by_validator():
    """A3. Claim references not belonging to the section's verified EvidenceGraph are rejected."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    claims = _make_sample_claims(section_id=1)
    ev_env = ArtifactEnvelope.create(
        "art_eg_1",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a3",
        {
            "graphId": "graph_s1",
            "sourcePackId": "src_s1",
            "contentHash": "sha_hash_a3",
            "claims": claims,
        },
        "2.0.0",
    )
    bp = build_blueprint(ev_env, "run_a3", policy.sections, policy=policy, topic="History of Science")

    # Tamper with slot 1 to point to an unrelated claim ID not in the evidence
    bp_tampered = copy.deepcopy(bp)
    bp_tampered["sections"][0]["questionSlots"][0]["claimRefIds"] = ["claim_unrelated_alien_id_999"]

    exam_bp = ExamBlueprint.model_validate(bp_tampered)
    evidence_map = {1: ev_env}
    issues = validate_blueprint(exam_bp, mode="dynamic", evidence_map=evidence_map)
    unrelated_issues = [i for i in issues if i.code == "BLUEPRINT_CLAIM_NOT_FOUND"]
    assert len(unrelated_issues) > 0, "Validator must reject claim IDs not present in verified EvidenceGraph"


def test_a4_missing_or_empty_claim_id_fails_closed():
    """A4. Empty claim reference on a dynamic slot is strictly rejected."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    claims = _make_sample_claims(section_id=1)
    ev_env = ArtifactEnvelope.create(
        "art_eg_1",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a4",
        {
            "graphId": "graph_s1",
            "sourcePackId": "src_s1",
            "contentHash": "sha_hash_a4",
            "claims": claims,
        },
        "2.0.0",
    )
    bp = build_blueprint(ev_env, "run_a4", policy.sections, policy=policy, topic="Geological Surveys")
    bp_empty_ref = copy.deepcopy(bp)
    bp_empty_ref["sections"][0]["questionSlots"][0]["claimRefIds"] = []

    exam_bp = ExamBlueprint.model_validate(bp_empty_ref)
    issues = validate_blueprint(exam_bp, mode="dynamic", require_claims=True)
    empty_issues = [i for i in issues if i.code == "BLUEPRINT_EMPTY_CLAIM_REFS"]
    assert len(empty_issues) > 0, "Validator must reject empty claimRefIds on accepted question slots"


def test_a5_empty_accepted_claim_graph_produces_no_accepted_claims():
    """A5. Empty claim graph produces empty claimRefIds and cannot pass validation."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    empty_ev_env = ArtifactEnvelope.create(
        "art_eg_empty",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a5",
        {
            "graphId": "graph_s1_empty",
            "sourcePackId": "src_s1_empty",
            "contentHash": "sha_empty",
            "claims": [],
        },
        "2.0.0",
    )
    bp_empty = build_blueprint(empty_ev_env, "run_a5", policy.sections, policy=policy, topic="Empty Topic")
    exam_bp = ExamBlueprint.model_validate(bp_empty)
    # Validating empty claims with require_claims=True must catch all empty slots
    issues = validate_blueprint(exam_bp, mode="dynamic", require_claims=True)
    empty_issues = [i for i in issues if i.code == "BLUEPRINT_EMPTY_CLAIM_REFS"]
    assert len(empty_issues) == 40, f"Expected 40 empty claim issues, got {len(empty_issues)}"


def test_a6_stale_or_fabricated_claim_prefix_is_prohibited():
    """A6. Fabricated synthetic claim IDs like claim:run_... or claim:None:... are prohibited."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    claims = _make_sample_claims(section_id=1)
    ev_env = ArtifactEnvelope.create(
        "art_eg_1",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a6",
        {
            "graphId": "graph_s1",
            "sourcePackId": "src_s1",
            "contentHash": "sha_hash_a6",
            "claims": claims,
        },
        "2.0.0",
    )
    bp = build_blueprint(ev_env, "run_a6", policy.sections, policy=policy, topic="Marine Biology")
    bp_fab = copy.deepcopy(bp)
    bp_fab["sections"][0]["questionSlots"][0]["claimRefIds"] = ["claim:run_a6:1:1"]
    bp_fab["sections"][0]["questionSlots"][1]["claimRefIds"] = ["claim:None:1:2"]
    bp_fab["sections"][0]["questionSlots"][2]["claimRefIds"] = ["claim:synthetic:1:3"]

    exam_bp = ExamBlueprint.model_validate(bp_fab)
    issues = validate_blueprint(exam_bp, mode="dynamic")
    fab_issues = [i for i in issues if i.code == "BLUEPRINT_FABRICATED_CLAIM_PROHIBITED"]
    assert len(fab_issues) == 3, f"Expected 3 fabricated claim issues, got {len(fab_issues)}"


def test_a7_insufficient_family_specific_evidence_handled_safely():
    """A7. Attempting to bind an empty claim set raises ValueError immediately."""
    from app.contracts.blueprint import QuestionSlot, QuestionType, TargetDifficulty, DifficultyLevel
    slot = QuestionSlot(
        questionNumber=1,
        sectionId=1,
        groupIndex=0,
        questionType=QuestionType.FLOW_CHART,
        targetSkill="Process understanding",
        targetDifficulty=TargetDifficulty(
            level=DifficultyLevel.FOUNDATION,
            rationale="Test difficulty rationale for question 1",
            isCalibrated=False,
        ),
        claimRefIds=[],
    )
    with pytest.raises(ValueError, match="contains zero verified claims"):
        bind_claims_to_slots([slot], [], section_id=1, graph_id="g1", run_id="r1")


def test_a8_valid_full_blueprint_covers_3_sections_and_40_numbered_slots():
    """A8. Valid full dynamic blueprint has 3 sections, exactly 40 contiguous numbered slots, and valid claim bindings."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    claims = _make_sample_claims(section_id=1)
    ev_env = ArtifactEnvelope.create(
        "art_eg_1",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a8",
        {
            "graphId": "graph_s1",
            "sourcePackId": "src_s1",
            "contentHash": "sha_hash_a8",
            "claims": claims,
        },
        "2.0.0",
    )
    bp = build_blueprint(ev_env, "run_a8", policy.sections, policy=policy, topic="Academic Research")
    exam_bp = ExamBlueprint.model_validate(bp)
    assert len(exam_bp.sections) == 3
    assert exam_bp.total_questions == 40

    all_q_nums = [slot.question_number for sec in exam_bp.sections for slot in sec.question_slots]
    assert all_q_nums == list(range(1, 41))

    # All slots have non-empty, non-synthetic claim references
    for sec in exam_bp.sections:
        for slot in sec.question_slots:
            assert len(slot.claim_ref_ids) > 0
            for cid in slot.claim_ref_ids:
                assert not cid.startswith("claim:run_")
                assert not cid.startswith("claim:None:")


def test_a9_explicit_legacy_preset_no_regression():
    """A9. Legacy preset mode preserves existing 6-type structure without regression."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="legacy_preset")
    claims = _make_sample_claims(section_id=1)
    ev_env = ArtifactEnvelope.create(
        "art_eg_legacy",
        ArtifactType.EVIDENCE_GRAPH,
        "run_a9",
        {
            "graphId": "graph_s1_legacy",
            "sourcePackId": "src_s1_legacy",
            "contentHash": "sha_legacy",
            "claims": claims,
        },
        "2.0.0",
    )
    bp = build_blueprint(ev_env, "run_a9", policy.sections, policy=policy, topic="Legacy Test")
    exam_bp = ExamBlueprint.model_validate(bp)
    assert exam_bp.total_questions == 40
    issues = validate_blueprint(exam_bp, mode="legacy_preset")
    critical = [i for i in issues if i.severity.value.upper() == "CRITICAL"]
    assert not critical, f"Legacy preset had unexpected critical issues: {critical}"
