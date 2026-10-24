"""Tests for Dynamic Blueprint Planner and Configurable Allocation (Task 2)."""

import pytest
from app.blueprint.generator import generate_dynamic_blueprint
from app.blueprint.validators import validate_blueprint
from app.contracts.blueprint import QuestionType
from app.contracts.question_type import QuestionPromptFamily
from app.reading_policy import PinnedExecutionPolicy


def test_dynamic_blueprint_allocates_40_questions_variable_groups():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    blueprint = generate_dynamic_blueprint(policy, {"topics": ["marine_biology", "cognitive_linguistics", "renewable_energy"]})
    assert blueprint.total_questions == 40
    assert len(blueprint.sections) == 3
    
    # Check section question counts sum to 40
    counts = [len(s.question_slots) for s in blueprint.sections]
    assert sum(counts) == 40
    assert counts == [13, 13, 14]

    # Validate using dynamic validator
    issues = validate_blueprint(blueprint, mode="dynamic")
    critical_issues = [i for i in issues if i.severity.value.upper() == "CRITICAL"]
    assert not critical_issues, f"Unexpected critical issues: {critical_issues}"


def test_dynamic_blueprint_section_suitability():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    blueprint = generate_dynamic_blueprint(policy)

    # Section 1: Factual / descriptive types
    # (e.g. TFNG, Notes, Table, Flowchart, Sentence Completion, Short Answer)
    sec1_allowed = {
        QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN,
        QuestionPromptFamily.NOTE_COMPLETION,
        QuestionPromptFamily.TABLE_COMPLETION,
        QuestionPromptFamily.FLOW_CHART,
        QuestionPromptFamily.SENTENCE_COMPLETION,
        QuestionPromptFamily.SHORT_ANSWER,
        QuestionPromptFamily.FORM_COMPLETION,
        QuestionType.TRUE_FALSE_NOT_GIVEN,
        QuestionType.SENTENCE_COMPLETION,
        QuestionType.SHORT_ANSWER,
    }
    sec1_types = {slot.question_type for slot in blueprint.sections[0].question_slots}
    assert sec1_types.issubset(sec1_allowed), f"Sec1 types {sec1_types} outside allowed {sec1_allowed}"

    # Section 2: Technical / discursive types
    # (e.g. Matching Information, Matching Features, Summary Completion, Diagram Label, Classification)
    sec2_allowed = {
        QuestionPromptFamily.MATCHING_INFORMATION,
        QuestionPromptFamily.MATCHING_FEATURES,
        QuestionPromptFamily.SUMMARY_COMPLETION,
        QuestionPromptFamily.SUMMARY_COMPLETION_BOX,
        QuestionPromptFamily.DIAGRAM_LABEL,
        QuestionPromptFamily.CLASSIFICATION,
        QuestionType.SUMMARY_COMPLETION,
        QuestionType.MULTIPLE_CHOICE_SINGLE,
    }
    sec2_types = {slot.question_type for slot in blueprint.sections[1].question_slots}
    assert sec2_types.issubset(sec2_allowed), f"Sec2 types {sec2_types} outside allowed {sec2_allowed}"

    # Section 3: Argumentative / debate types
    # (e.g. Matching Headings, Yes/No/Not Given, Multiple Choice Multiple, Sentence Endings, Multiple Choice Single)
    sec3_allowed = {
        QuestionPromptFamily.MATCHING_HEADING,
        QuestionPromptFamily.YES_NO_NOT_GIVEN,
        QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE,
        QuestionPromptFamily.MATCHING_ENDINGS,
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
        QuestionPromptFamily.CHOOSING_TITLE,
        QuestionType.YES_NO_NOT_GIVEN,
        QuestionType.MULTIPLE_CHOICE_SINGLE,
    }
    sec3_types = {slot.question_type for slot in blueprint.sections[2].question_slots}
    assert sec3_types.issubset(sec3_allowed), f"Sec3 types {sec3_types} outside allowed {sec3_allowed}"


def test_dynamic_blueprint_legacy_mode():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="legacy_preset")
    blueprint = generate_dynamic_blueprint(policy)
    assert blueprint.total_questions == 40
    assert len(blueprint.sections) == 3

    # Legacy preset has exactly 2 groups per section:
    # Sec 1: TFNG 7, Sentence Completion 6
    # Sec 2: MCQ Single 6, Summary Completion 7
    # Sec 3: YNNG 7, Short Answer 7
    s1_slots = blueprint.sections[0].question_slots
    assert len([s for s in s1_slots if s.group_index == 0]) == 7
    assert len([s for s in s1_slots if s.group_index == 1]) == 6

    issues = validate_blueprint(blueprint, mode="legacy_preset")
    critical_issues = [i for i in issues if i.severity.value.upper() == "CRITICAL"]
    assert not critical_issues, f"Legacy preset validation failed: {critical_issues}"


def test_validate_blueprint_dynamic_allows_three_groups():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    blueprint = generate_dynamic_blueprint(policy)

    # Section 2 explicitly has 3 groups (5, 4, 4)
    sec2_groups = {slot.group_index for slot in blueprint.sections[1].question_slots}
    assert len(sec2_groups) == 3, f"Expected 3 groups in Section 2, got {sec2_groups}"

    # Validate under dynamic mode succeeds
    dynamic_issues = [i for i in validate_blueprint(blueprint, mode="dynamic") if i.severity.value.upper() == "CRITICAL"]
    assert not dynamic_issues

    # Legacy mode must reject this blueprint because Section 2 has 3 groups
    legacy_issues = [i for i in validate_blueprint(blueprint, mode="legacy_preset") if i.severity.value.upper() == "CRITICAL"]
    assert len(legacy_issues) > 0


def test_validate_blueprint_rejects_invalid_question_type():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    blueprint = generate_dynamic_blueprint(policy)

    # Tamper one slot with an invalid type string
    tampered_slots = list(blueprint.sections[0].question_slots)
    tampered_slots[0] = tampered_slots[0].model_copy(update={"question_type": "INVALID_RANDOM_TYPE"})
    tampered_sec = blueprint.sections[0].model_copy(update={"question_slots": tampered_slots})
    tampered_bp = blueprint.model_copy(update={"sections": [tampered_sec, blueprint.sections[1], blueprint.sections[2]]})

    issues = validate_blueprint(tampered_bp, mode="dynamic")
    type_issues = [i for i in issues if i.code == "BLUEPRINT_INVALID_QUESTION_TYPE"]
    assert len(type_issues) >= 1
    assert type_issues[0].severity.value.upper() == "CRITICAL"


def test_dynamic_blueprint_selects_families_based_on_evidence():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    evidence_with_processes = {
        "topics": ["Section 1 Biology", "Section 2 Industrial Process", "Section 3 Scientific Debate"],
        "section_evidence": {
            1: {"has_chronology": True, "claim_count": 12},
            2: {"has_mechanisms": True, "process_steps": 5, "claim_count": 14},
            3: {"has_arguments": True, "opinions_count": 8, "claim_count": 15},
        }
    }
    bp = generate_dynamic_blueprint(policy, evidence_with_processes)
    assert bp.total_questions == 40
    assert len(bp.sections) == 3
    s2_types = {q.question_type.value for q in bp.sections[1].question_slots}
    assert any(t in ("FLOW_CHART", "DIAGRAM_LABEL", "SUMMARY_COMPLETION", "TABLE_COMPLETION", "SUMMARY_COMPLETION_BOX") for t in s2_types)


def test_dynamic_blueprint_deterministic_reproducibility():
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    evidence = {
        "topics": ["Marine Ecosystems", "Atmospheric Physics", "Linguistic Evolution"],
        "run_id": "run_stable_12345",
    }
    bp1 = generate_dynamic_blueprint(policy, evidence)
    bp2 = generate_dynamic_blueprint(policy, evidence)

    types1 = [q.question_type.value for s in bp1.sections for q in s.question_slots]
    types2 = [q.question_type.value for s in bp2.sections for q in s.question_slots]
    assert types1 == types2, "Dynamic blueprint must be 100% deterministic given identical evidence"
    assert bp1.content_hash == bp2.content_hash, f"content_hash must match: {bp1.content_hash} != {bp2.content_hash}"


def test_build_blueprint_production_reproducibility_and_evidence_awareness():
    from app.reading_generation import build_blueprint
    from app.contracts.artifact import ArtifactEnvelope, ArtifactType

    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    sec_configs = policy.sections
    verified_claims = [
        {"claimId": f"claim_sec1_{i}", "text": f"Verified factual claim {i} regarding marine organisms"}
        for i in range(1, 15)
    ]
    evidence_env = ArtifactEnvelope.create(
        "art_eg_1",
        ArtifactType.EVIDENCE_GRAPH,
        "run_repro_1",
        {
            "graphId": "graph_sec1_v1",
            "sourcePackId": "src_sec1_v1",
            "contentHash": "abc123hash",
            "claims": verified_claims,
        },
        "2.0.0",
    )

    # 1. Two calls with identical inputs must produce IDENTICAL contentHash
    bp1 = build_blueprint(
        evidence_env,
        "run_repro_1",
        sec_configs,
        policy=policy,
        topic="Marine Ecosystems",
    )
    bp2 = build_blueprint(
        evidence_env,
        "run_repro_1",
        sec_configs,
        policy=policy,
        topic="Marine Ecosystems",
    )

    assert bp1["contentHash"] == bp2["contentHash"], (
        f"Production blueprint contentHash drifted across identical runs: {bp1['contentHash']} != {bp2['contentHash']}"
    )

    # 2. Mutating evidence changes contentHash
    altered_claims = [
        {"claimId": f"claim_sec1_{i}", "text": f"Altered claim {i}"}
        for i in range(1, 15)
    ]
    altered_evidence = ArtifactEnvelope.create(
        "art_eg_2",
        ArtifactType.EVIDENCE_GRAPH,
        "run_repro_1",
        {
            "graphId": "graph_sec1_v2",
            "sourcePackId": "src_sec1_v2",
            "contentHash": "def456altered",
            "claims": altered_claims,
        },
        "2.0.0",
    )
    bp_mutated = build_blueprint(
        altered_evidence,
        "run_repro_1",
        sec_configs,
        policy=policy,
        topic="Marine Ecosystems",
    )
    assert bp_mutated["contentHash"] != bp1["contentHash"], "Mutating evidence must alter contentHash"

    # 3. All slots have claim references resolving to verified evidence (no synthetic fallback)
    for sec in bp1["sections"]:
        for slot in sec["questionSlots"]:
            assert len(slot["claimRefIds"]) > 0
            for cid in slot["claimRefIds"]:
                assert not cid.startswith("claim:fake_"), f"Found synthetic fabricated claim {cid}"
                assert any(c["claimId"] == cid for c in verified_claims), f"Claim {cid} not in verified evidence"

    # 4. Missing claims cannot produce accepted claim refs (never fabricate synthetic claims)
    empty_evidence = ArtifactEnvelope.create(
        "art_eg_empty",
        ArtifactType.EVIDENCE_GRAPH,
        "run_repro_1",
        {
            "graphId": "graph_sec1_empty",
            "sourcePackId": "src_sec1_empty",
            "contentHash": "emptyhash",
            "claims": [],
        },
        "2.0.0",
    )
    bp_empty = build_blueprint(
        empty_evidence,
        "run_repro_1",
        sec_configs,
        policy=policy,
        topic="Marine Ecosystems",
    )
    for sec in bp_empty["sections"]:
        for slot in sec["questionSlots"]:
            assert slot["claimRefIds"] == [], (
                f"Missing claims must NOT produce accepted claim refs; got {slot['claimRefIds']}"
            )

    # 5. Blueprint validation rejects fabricated synthetic claim IDs
    from app.blueprint.validators import validate_blueprint
    from app.contracts.blueprint import ExamBlueprint
    tampered_bp_dict = dict(bp1)
    tampered_bp_dict["sections"][0]["questionSlots"][0]["claimRefIds"] = ["claim:fake_repro_1:1:1"]
    tampered_bp = ExamBlueprint.model_validate(tampered_bp_dict)
    issues = validate_blueprint(tampered_bp, mode="dynamic")
    assert any(i.code == "BLUEPRINT_FABRICATED_CLAIM_PROHIBITED" for i in issues), (
        "Blueprint validation must reject fabricated synthetic claim IDs"
    )


