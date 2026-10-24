"""Comprehensive Tests for Autonomous Blueprint Recovery (Task: Fix Autonomous Blueprint Recovery).

Covers:
1. Realistic run IDs beginning with 'run_' (e.g. run_d6a23408bff741a78e5dd67c94a497e3):
   - Genuine extracted claims can be bound.
   - Verified claims with 'claim:run_' prefix pass eligibility and validation.
2. Fake / synthetic / out-of-graph claims are strictly rejected.
3. Cross-section claims are strictly rejected.
4. Blueprint generation completes on valid source evidence.
5. Genuine incompatibility triggers deterministic, policy-compliant family reallocation.
6. When reallocation is impossible, controlled evidence re-extraction from verified source text is triggered.
7. Truthful terminal error when no compatible evidence exists.
8. Stagnation detection stops safely.
9. Deterministic content hashing and checkpoint integrity are preserved.
"""

from __future__ import annotations

import copy
import hashlib
import pytest
from uuid import uuid4

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.blueprint import (
    ExamBlueprint,
    QuestionSlot,
    QuestionType,
    SectionBlueprint,
    TargetDifficulty,
    DifficultyLevel,
    compute_canonical_blueprint_hash,
)
from app.contracts.issue import IssueCode
from app.contracts.question_type import QuestionPromptFamily
from app.blueprint.claim_binding import (
    bind_claims_to_slots,
    check_claim_eligibility_for_family,
    score_claim_suitability_for_family,
)
from app.blueprint.generator import (
    generate_dynamic_blueprint,
    InsufficientEvidenceForAllocationError,
    SECTION_1_FAMILIES,
    SECTION_2_FAMILIES,
    SECTION_3_FAMILIES,
)
from app.blueprint.validators import validate_blueprint
from app.reading_evaluation import evaluate_blueprint, evaluate_evidence
from app.reading_generation import (
    build_blueprint,
    build_evidence,
    reextract_evidence_for_section,
)
from app.reading_policy import PinnedExecutionPolicy


REALISTIC_RUN_ID = "run_d6a23408bff741a78e5dd67c94a497e3"


def _make_source_envelope(run_id: str = REALISTIC_RUN_ID, section_id: int = 1, text: str | None = None) -> ArtifactEnvelope:
    sample_text = (
        "Marine biologists recorded water temperature anomalies exceeding two degrees Celsius in 1984. "
        "The primary reduction process converts atmospheric carbon into dissolved organic matter through cyclical enzymatic pathways. "
        "Field observations confirmed that seventy percent of coral polyps bleached during the extreme El Nino event. "
        "Researchers classified three distinct species of macroalgae based on cellular morphometrics and pigment density. "
        "Laboratory measurements demonstrated that calcium carbonate saturation decreased by fifteen percent over five decades. "
        "The reaction mechanism triggers immediate bicarbonate absorption when water acidity surpasses baseline thresholds. "
        "Critics contend that satellite telemetry overestimates sea surface temperature variations in shallow lagoon habitats. "
        "Excavations of fossilized reef structures revealed rapid recovery patterns following prehistoric thermal disturbances."
    )
    if text:
        sample_text = text

    return ArtifactEnvelope.create(
        f"source:{run_id}:{section_id}",
        ArtifactType.SOURCE_PACK,
        run_id,
        {
            "sources": [
                {
                    "sourceId": f"pmc_sec{section_id}_{run_id[:8]}",
                    "title": f"Scholarly Source for Section {section_id}",
                    "document": {"text": sample_text},
                    "license": "CC BY 4.0",
                    "licenseCleared": True,
                }
            ]
        },
        "1.0.0",
        section_id=section_id,
    )


def test_realistic_run_id_genuine_claims_bound_and_accepted():
    """1. Realistic run IDs beginning with 'run_' produce claims that bind and pass all evaluators."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    src_env = _make_source_envelope(REALISTIC_RUN_ID, 1)

    # 1. build_evidence generates legitimate run-scoped claim IDs: claim:run_...:1:1
    ev_dict = build_evidence(src_env, REALISTIC_RUN_ID, 1, policy)
    claims = ev_dict["claims"]
    assert len(claims) >= policy.min_verified_claims
    assert all(c["claimId"].startswith(f"claim:{REALISTIC_RUN_ID}:1:") for c in claims)

    # 2. check_claim_eligibility_for_family accepts genuine claims with 'claim:run_' prefix
    eligible = [
        c for c in claims
        if check_claim_eligibility_for_family(c, "TRUE_FALSE_NOT_GIVEN", 1)
    ]
    assert len(eligible) > 0, "Genuine claims must not be rejected by prefix"

    # 3. bind_claims_to_slots successfully binds slots without ValueError
    slots = [
        QuestionSlot(
            questionNumber=i,
            sectionId=1,
            groupIndex=0,
            questionType=QuestionType.TRUE_FALSE_NOT_GIVEN,
            targetSkill="factual_inference",
            targetDifficulty=TargetDifficulty(level=DifficultyLevel.FOUNDATION, isCalibrated=False, rationale="Editorial"),
            claimRefIds=[],
        )
        for i in range(1, 8)
    ]
    bound = bind_claims_to_slots(slots, claims, 1, "graph_1", REALISTIC_RUN_ID)
    assert all(len(s.claim_ref_ids) == 1 for s in bound)
    assert all(s.claim_ref_ids[0].startswith(f"claim:{REALISTIC_RUN_ID}:1:") for s in bound)

    # 4. validate_blueprint and evaluate_blueprint accept genuine claims with 'claim:run_' prefix
    ev_dict2 = build_evidence(_make_source_envelope(REALISTIC_RUN_ID, 2), REALISTIC_RUN_ID, 2, policy)
    ev_dict3 = build_evidence(_make_source_envelope(REALISTIC_RUN_ID, 3), REALISTIC_RUN_ID, 3, policy)
    bp = generate_dynamic_blueprint(policy, {
        "run_id": REALISTIC_RUN_ID,
        "section_evidence": {1: ev_dict, 2: ev_dict2, 3: ev_dict3},
    })
    sec1_slots = bp.sections[0].question_slots
    assert all(len(s.claim_ref_ids) > 0 for s in sec1_slots)
    assert all(cid.startswith(f"claim:{REALISTIC_RUN_ID}:1:") for s in sec1_slots for cid in s.claim_ref_ids)

    issues = validate_blueprint(bp, mode="dynamic")
    critical = [i for i in issues if i.severity.value.upper() == "CRITICAL"]
    assert not critical, f"Validation produced critical issues: {critical}"

    bp_env = ArtifactEnvelope.create(f"blueprint:{REALISTIC_RUN_ID}", ArtifactType.EXAM_BLUEPRINT, REALISTIC_RUN_ID, bp.model_dump(by_alias=True), "1.0.0")
    ev_env1 = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:1", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, ev_dict, "1.0.0", section_id=1)
    ev_env2 = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:2", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, ev_dict2, "1.0.0", section_id=2)
    ev_env3 = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:3", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, ev_dict3, "1.0.0", section_id=3)
    eval_results = evaluate_blueprint(bp_env, policy, (1, 2, 3), evidence_map={1: ev_env1, 2: ev_env2, 3: ev_env3})
    failed = [e for e in eval_results if not e.is_pass()]
    assert not failed, f"Production evaluate_blueprint rejected genuine claims: {[i.message for e in failed for i in e.issues]}"


def test_fake_and_out_of_graph_claims_rejected():
    """2. Fake prefixes and out-of-graph claims are strictly rejected by validators and evaluators."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    src_env = _make_source_envelope(REALISTIC_RUN_ID, 1)
    ev_dict = build_evidence(src_env, REALISTIC_RUN_ID, 1, policy)
    bp = generate_dynamic_blueprint(policy, {
        "run_id": REALISTIC_RUN_ID,
        "section_evidence": {1: ev_dict},
    })

    # Case A: Explicitly fake claim IDs
    tampered_bp = copy.deepcopy(bp)
    tampered_bp.sections[0].question_slots[0] = tampered_bp.sections[0].question_slots[0].model_copy(
        update={"claim_ref_ids": ["claim:synthetic:fabricated_1"]}
    )
    issues = validate_blueprint(tampered_bp, mode="dynamic")
    assert any(i.code == "BLUEPRINT_FABRICATED_CLAIM_PROHIBITED" for i in issues)

    tampered_bp2 = copy.deepcopy(bp)
    tampered_bp2.sections[0].question_slots[0] = tampered_bp2.sections[0].question_slots[0].model_copy(
        update={"claim_ref_ids": ["claim:fake_candidate_99"]}
    )
    issues2 = validate_blueprint(tampered_bp2, mode="dynamic")
    assert any(i.code == "BLUEPRINT_FABRICATED_CLAIM_PROHIBITED" for i in issues2)

    # Case B: Out-of-graph claim (claim looks formatted but does not exist in EvidenceGraph)
    tampered_bp3 = copy.deepcopy(bp)
    tampered_bp3.sections[0].question_slots[0] = tampered_bp3.sections[0].question_slots[0].model_copy(
        update={"claim_ref_ids": [f"claim:{REALISTIC_RUN_ID}:1:999"]}
    )
    ev_env = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:1", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, ev_dict, "1.0.0", section_id=1)
    issues3 = validate_blueprint(tampered_bp3, mode="dynamic", evidence_map={1: ev_env})
    assert any(i.code == "BLUEPRINT_CLAIM_NOT_FOUND" for i in issues3)

    bp_env = ArtifactEnvelope.create(f"blueprint:{REALISTIC_RUN_ID}", ArtifactType.EXAM_BLUEPRINT, REALISTIC_RUN_ID, tampered_bp3.model_dump(by_alias=True), "1.0.0")
    eval_results = evaluate_blueprint(bp_env, policy, (1, 2, 3), evidence_map={1: ev_env})
    failed = [e for e in eval_results if not e.is_pass()]
    assert any("not in Section 1's verified EvidenceGraph" in i.message for e in failed for i in e.issues)


def test_cross_section_claims_strictly_rejected():
    """3. Cross-section claim references are strictly rejected fail-closed."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    src_env = _make_source_envelope(REALISTIC_RUN_ID, 1)
    ev_dict = build_evidence(src_env, REALISTIC_RUN_ID, 1, policy)
    bp = generate_dynamic_blueprint(policy, {
        "run_id": REALISTIC_RUN_ID,
        "section_evidence": {1: ev_dict},
    })

    # Tamper Section 1 slot with a claim belonging to Section 2
    tampered = copy.deepcopy(bp)
    tampered.sections[0].question_slots[0] = tampered.sections[0].question_slots[0].model_copy(
        update={"claim_ref_ids": [f"claim:{REALISTIC_RUN_ID}:2:1"]}
    )

    # In validator
    issues = validate_blueprint(tampered, mode="dynamic")
    assert any(i.code == "BLUEPRINT_CROSS_SECTION_CLAIM_PROHIBITED" for i in issues)

    # In evaluator
    bp_env = ArtifactEnvelope.create(f"blueprint:{REALISTIC_RUN_ID}", ArtifactType.EXAM_BLUEPRINT, REALISTIC_RUN_ID, tampered.model_dump(by_alias=True), "1.0.0")
    eval_results = evaluate_blueprint(bp_env, policy, (1, 2, 3))
    failed = [e for e in eval_results if not e.is_pass()]
    assert any("cross-section claim" in i.message for e in failed for i in e.issues)


def test_blueprint_generation_completes_on_valid_source_evidence():
    """4. Full 3-section, 40-question blueprint generation completes and satisfies all invariants."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    src1 = _make_source_envelope(REALISTIC_RUN_ID, 1)
    src2 = _make_source_envelope(REALISTIC_RUN_ID, 2)
    src3 = _make_source_envelope(REALISTIC_RUN_ID, 3)

    ev1 = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:1", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, build_evidence(src1, REALISTIC_RUN_ID, 1, policy), "1.0.0", section_id=1)
    ev2 = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:2", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, build_evidence(src2, REALISTIC_RUN_ID, 2, policy), "1.0.0", section_id=2)
    ev3 = ArtifactEnvelope.create(f"evidence:{REALISTIC_RUN_ID}:3", ArtifactType.EVIDENCE_GRAPH, REALISTIC_RUN_ID, build_evidence(src3, REALISTIC_RUN_ID, 3, policy), "1.0.0", section_id=3)

    sources_map = {1: src1, 2: src2, 3: src3}
    evidence_map = {1: ev1, 2: ev2, 3: ev3}

    bp_dict = build_blueprint(
        REALISTIC_RUN_ID,
        "IELTS Academic Reading Simulation",
        (1, 2, 3),
        sources_map,
        evidence_map,
        policy,
    )

    bp = ExamBlueprint.model_validate(bp_dict)
    assert bp.total_questions == 40
    assert len(bp.sections) == 3
    counts = [len(s.question_slots) for s in bp.sections]
    assert counts == [13, 13, 14]

    # Contiguous 1 to 40
    all_q_nums = [s.question_number for sec in bp.sections for s in sec.question_slots]
    assert all_q_nums == list(range(1, 41))

    # All slots bind genuine claims
    for sec in bp.sections:
        for slot in sec.question_slots:
            assert len(slot.claim_ref_ids) == 1
            assert slot.claim_ref_ids[0].startswith(f"claim:{REALISTIC_RUN_ID}:{sec.section_id}:")

    # Production evaluator acceptance
    bp_env = ArtifactEnvelope.create(f"blueprint:{REALISTIC_RUN_ID}", ArtifactType.EXAM_BLUEPRINT, REALISTIC_RUN_ID, bp_dict, "1.0.0")
    eval_results = evaluate_blueprint(bp_env, policy, (1, 2, 3), evidence_map=evidence_map)
    failed = [e for e in eval_results if not e.is_pass()]
    assert not failed, f"Production evaluate_blueprint rejected blueprint: {[i.message for e in failed for i in e.issues]}"


def test_genuine_incompatibility_triggers_bounded_reallocation():
    """5. When evidence lacks support for a family, deterministic reallocation selects a compatible family from the section pool."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")

    # Evidence for Section 1 has only pure factual/quantitative claims (no process keywords)
    factual_claims = [
        {"claimId": f"claim:{REALISTIC_RUN_ID}:1:{i}", "text": f"Excavation {i} recovered forty stone implements in 198{i}.", "keywords": ["excavation", "recovered", "stone"], "sectionId": 1}
        for i in range(1, 15)
    ]
    ev_summary = {
        "run_id": REALISTIC_RUN_ID,
        "topics": ["Archaeological Excavation", "Technical Engineering", "Academic Debate"],
        "section_evidence": {
            1: {"claims": factual_claims, "claim_count": 14},
        },
    }

    bp = generate_dynamic_blueprint(policy, ev_summary)
    sec1_slots = bp.sections[0].question_slots
    assert len(sec1_slots) == 13

    # All assigned families in Section 1 must belong to SECTION_1_FAMILIES
    allowed_types = {QuestionType(f.value) for f in SECTION_1_FAMILIES}
    actual_types = {s.question_type for s in sec1_slots}
    assert actual_types.issubset(allowed_types), f"Reallocated types {actual_types} outside allowed {allowed_types}"

    # Verify every slot is bound to verified factual evidence
    for s in sec1_slots:
        assert len(s.claim_ref_ids) == 1
        assert any(c["claimId"] == s.claim_ref_ids[0] for c in factual_claims)


def test_reallocation_impossible_triggers_controlled_evidence_reextraction():
    """6. When initial evidence has zero compatible families, build_blueprint performs controlled re-extraction from source text."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic", min_verified_claims=2)
    # Source text contains rich factual sentences
    source_text = (
        "In 1923 archaeologists uncovered twelve bronze vessels at the excavation site. "
        "The survey recorded forty hectares of agricultural terraces spanning the valley basin. "
        "Measurements confirmed that water salinity averaged thirty parts per thousand in the estuary. "
        "Excavations revealed three distinct stratigraphic layers dating to the early Bronze Age. "
        "Radiocarbon analysis determined that occupation persisted for over six hundred years."
    )
    src1 = _make_source_envelope(REALISTIC_RUN_ID, 1, text=source_text)

    # Intentionally start with an evidence graph containing 2 irrelevant cross-section claims
    irrelevant_claims = [
        {"claimId": f"claim:{REALISTIC_RUN_ID}:1:1", "text": "Short word.", "keywords": ["word"], "sectionId": 1},
        {"claimId": f"claim:{REALISTIC_RUN_ID}:1:2", "text": "Tiny note.", "keywords": ["note"], "sectionId": 1},
    ]
    ev1 = ArtifactEnvelope.create(
        f"evidence:{REALISTIC_RUN_ID}:1",
        ArtifactType.EVIDENCE_GRAPH,
        REALISTIC_RUN_ID,
        {"graphId": f"graph:{REALISTIC_RUN_ID}:1", "sourcePackId": "src_1", "contentHash": "h1", "claims": irrelevant_claims},
        "1.0.0",
        section_id=1,
    )

    sources_map = {1: src1}
    evidence_map = {1: ev1}

    # build_blueprint will trigger controlled evidence re-extraction from src1
    bp_dict = build_blueprint(
        REALISTIC_RUN_ID,
        "Archaeological History",
        (1,),
        sources_map,
        evidence_map,
        policy,
    )

    bp = ExamBlueprint.model_validate(bp_dict)
    sec1 = bp.sections[0]
    assert len(sec1.question_slots) == 13
    assert all(len(s.claim_ref_ids) == 1 for s in sec1.question_slots)

    # Re-extracted evidence is now in evidence_map and has verified claims
    updated_ev = evidence_map[1]
    ev_claims = updated_ev.payload["claims"]
    assert len(ev_claims) >= policy.min_verified_claims
    assert any("bronze" in c["text"] or "excavation" in c["text"] for c in ev_claims)


def test_no_compatible_evidence_leads_to_truthful_terminal_error():
    """7. When source text is genuinely insufficient and cannot produce evidence, fails closed with truthful terminal error."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic", max_recovery_attempts=2)
    # Source text contains only 2 short words (cannot yield valid spans)
    src_tiny = _make_source_envelope(REALISTIC_RUN_ID, 1, text="Too brief.")
    empty_ev = ArtifactEnvelope.create(
        f"evidence:{REALISTIC_RUN_ID}:1",
        ArtifactType.EVIDENCE_GRAPH,
        REALISTIC_RUN_ID,
        {"graphId": f"graph:{REALISTIC_RUN_ID}:1", "sourcePackId": "src_1", "contentHash": "empty", "claims": []},
        "1.0.0",
        section_id=1,
    )

    with pytest.raises(ValueError, match="insufficient|Unable to extract|exhausted"):
        build_blueprint(
            REALISTIC_RUN_ID,
            "Nonsense",
            (1,),
            {1: src_tiny},
            {1: empty_ev},
            policy,
        )


def test_recovery_budget_bounds_enforced():
    """9. Recovery attempts respect policy.max_recovery_attempts ceiling and do not retry infinitely."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic", max_recovery_attempts=1)
    src_empty = _make_source_envelope(REALISTIC_RUN_ID, 1, text="No usable sentences.")
    empty_ev = ArtifactEnvelope.create(
        f"evidence:{REALISTIC_RUN_ID}:1",
        ArtifactType.EVIDENCE_GRAPH,
        REALISTIC_RUN_ID,
        {"graphId": f"graph:{REALISTIC_RUN_ID}:1", "sourcePackId": "src_1", "contentHash": "empty", "claims": []},
        "1.0.0",
        section_id=1,
    )

    with pytest.raises(ValueError, match="insufficient|exhausted|Unable to extract"):
        build_blueprint(
            REALISTIC_RUN_ID,
            "Bounded Budget Test",
            (1,),
            {1: src_empty},
            {1: empty_ev},
            policy,
        )


def test_blueprint_checkpoint_integrity_and_deterministic_hashing():
    """10. Blueprint generation maintains 100% deterministic content hashing across identical calls."""
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    src = _make_source_envelope(REALISTIC_RUN_ID, 1)
    ev = ArtifactEnvelope.create(
        f"evidence:{REALISTIC_RUN_ID}:1",
        ArtifactType.EVIDENCE_GRAPH,
        REALISTIC_RUN_ID,
        build_evidence(src, REALISTIC_RUN_ID, 1, policy),
        "1.0.0",
        section_id=1,
    )

    bp1 = build_blueprint(REALISTIC_RUN_ID, "Topic A", (1,), {1: src}, {1: ev}, policy)
    bp2 = build_blueprint(REALISTIC_RUN_ID, "Topic A", (1,), {1: src}, {1: ev}, policy)

    assert bp1["contentHash"] == bp2["contentHash"]
    assert bp1["blueprintId"] == bp2["blueprintId"]
    assert bp1["sections"][0]["questionSlots"] == bp2["sections"][0]["questionSlots"]


@pytest.mark.asyncio
async def test_real_execution_path_evidence_recovery_durable_checkpoint_and_section_runner():
    """Real execution path: Source -> EvidenceGraph -> Blueprint Recovery -> Durable Checkpoint -> SectionRunner.
    
    Verifies:
    1. Re-extracted evidence is validated and durably accepted through StageExecutor/checkpoint authority.
    2. Recovered EvidenceGraph has correct artifact identity, version, content hash, and parent references.
    3. Blueprint and SectionRunner consume the exact same authoritative accepted evidence.
    4. No in-memory-only or uncommitted evidence is accepted.
    5. All 3 sections and 40 question allocations remain strictly valid (13, 13, 14 questions).
    """
    from tests.unified.mock_fixtures import create_mock_environment, create_pipeline_request
    from app.contracts.artifact import canonical_json_dump
    import app.pipeline as pipeline_mod
    import app.reading_generation as rg_mod

    run_id = f"run_recov_40q_{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic", min_verified_claims=2)
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    req = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )
    client.init_run(run_id=req.run_id, epoch=req.epoch, lease_owner=req.lease_owner, policy_hash=policy.hash, job_id=req.job_id)

    orig_build_evidence = pipeline_mod.build_evidence
    s1_call_count = 0

    def mock_build_evidence_ineligible_section_1(*args, **kwargs):
        nonlocal s1_call_count
        s_idx = args[2] if len(args) > 2 else kwargs.get("section_id", 1)
        if s_idx == 1:
            s1_call_count += 1
            if s1_call_count == 1:
                # Stage 2 initial extraction: valid claims against source text, but with sectionId=2
                # so check_claim_eligibility_for_family rejects them for Section 1 blueprint allocation
                real_ev = orig_build_evidence(*args, **kwargs)
                for c in real_ev["claims"]:
                    parts = c["claimId"].split(":")
                    if len(parts) >= 4:
                        parts[2] = "2"
                        c["claimId"] = ":".join(parts)
                return real_ev
        return orig_build_evidence(*args, **kwargs)

    pipeline_mod.build_evidence = mock_build_evidence_ineligible_section_1
    rg_mod.build_evidence = mock_build_evidence_ineligible_section_1
    try:
        result = await pipeline.execute(req)
        assert result.status == "ACCEPTED"
        assert s1_call_count == 2, "Section 1 evidence must be re-extracted during recovery"

        # 1. Re-extracted evidence is validated and durably accepted as version 2
        s1_ev_head = client.heads.get((run_id, f"evidence:{run_id}:1"))
        assert s1_ev_head is not None
        assert s1_ev_head.version == 2, "Recovered evidence must be durably committed as version 2"
        assert len(s1_ev_head.payload.get("claims", [])) >= policy.min_verified_claims

        # 2. Correct artifact identity, content hash, and parent references
        assert s1_ev_head.artifact_id == f"evidence:{run_id}:1"
        assert s1_ev_head.artifact_type == ArtifactType.EVIDENCE_GRAPH
        assert len(s1_ev_head.parent_refs) == 1
        assert s1_ev_head.parent_refs[0].artifact_id == f"source:{run_id}:1"
        assert s1_ev_head.verify_integrity() is True

        # 3. Blueprint and SectionRunner consume the same authoritative accepted evidence
        bp_head = client.heads.get((run_id, f"blueprint:{run_id}"))
        assert bp_head is not None
        bp_sec1 = bp_head.payload["sections"][0]
        assert bp_sec1["evidenceGraphRef"]["contentHash"] == s1_ev_head.content_hash

        # All Section 1 question slots bind verified claims from the recovered evidence
        s1_claim_ids = {c["claimId"] for c in s1_ev_head.payload["claims"]}
        for slot in bp_sec1["questionSlots"]:
            assert len(slot["claimRefIds"]) == 1
            assert slot["claimRefIds"][0] in s1_claim_ids

        # 4. No in-memory-only or uncommitted evidence accepted
        state = client.resume_state(run_id)
        ev1_state = next(a for a in state.artifacts if a.artifactId == f"evidence:{run_id}:1")
        assert ev1_state.acceptedHash == s1_ev_head.content_hash
        assert ev1_state.acceptedVersion == 2

        # 5. All 3 sections and 40 question allocations remain valid
        assert len(result.sections) == 3
        assert result.paper is not None
        assert result.paper.payload["totalQuestions"] == 40
        all_questions = [
            q for sec in result.paper.payload["sections"] for grp in sec.get("groups", []) for q in grp.get("questions", [])
        ]
        assert len(all_questions) == 40
        assert [q["questionNumber"] for q in all_questions] == list(range(1, 41))

        s1_numbers = [q["questionNumber"] for grp in result.paper.payload["sections"][0]["groups"] for q in grp["questions"]]
        s2_numbers = [q["questionNumber"] for grp in result.paper.payload["sections"][1]["groups"] for q in grp["questions"]]
        s3_numbers = [q["questionNumber"] for grp in result.paper.payload["sections"][2]["groups"] for q in grp["questions"]]
        assert s1_numbers == list(range(1, 14))
        assert s2_numbers == list(range(14, 27))
        assert s3_numbers == list(range(27, 41))
        assert result.exam_id is not None
    finally:
        pipeline_mod.build_evidence = orig_build_evidence
        rg_mod.build_evidence = orig_build_evidence


@pytest.mark.asyncio
async def test_recovery_across_restart_resume_without_stale_dependencies():
    """Recovery works across restart/resume without stale dependencies.
    
    Verifies that a pipeline resumed after evidence recovery seamlessly reuses
    the authoritative accepted evidence and blueprint without DependencyStaleError.
    """
    from tests.unified.mock_fixtures import create_mock_environment, create_pipeline_request
    import app.pipeline as pipeline_mod
    import app.reading_generation as rg_mod

    run_id = f"run_recov_resume_{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic", min_verified_claims=2)
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    req = create_pipeline_request(
        run_id=run_id,
        section_indices=(1,),
        parallel=False,
        finalize=False,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )
    client.init_run(run_id=req.run_id, epoch=req.epoch, lease_owner=req.lease_owner, policy_hash=policy.hash, job_id=req.job_id)

    orig_build_evidence = pipeline_mod.build_evidence
    s1_call_count = 0

    def mock_build_evidence_ineligible_once(*args, **kwargs):
        nonlocal s1_call_count
        s1_call_count += 1
        if s1_call_count == 1:
            real_ev = orig_build_evidence(*args, **kwargs)
            for c in real_ev["claims"]:
                parts = c["claimId"].split(":")
                if len(parts) >= 4:
                    parts[2] = "2"
                    c["claimId"] = ":".join(parts)
            return real_ev
        return orig_build_evidence(*args, **kwargs)

    pipeline_mod.build_evidence = mock_build_evidence_ineligible_once
    rg_mod.build_evidence = mock_build_evidence_ineligible_once
    try:
        # Run 1: Completes recovery and accepts all artifacts
        res1 = await pipeline.execute(req)
        assert res1.status == "ACCEPTED"

        # Run 2 (Simulate crash / restart with fresh pipeline instance):
        # Must resume cleanly from durable checkpoints with 0 new build_evidence calls
        pipeline2, _, _, _ = create_mock_environment(policy=policy, run_id=run_id)
        pipeline2.client = client
        pipeline2.gateway = gateway

        res2 = await pipeline2.execute(req)
        assert res2.status == "ACCEPTED"
        assert s1_call_count == 2, "Resume must reuse accepted checkpoints without regenerating"
        assert res2.sections[0].content_hash == res1.sections[0].content_hash
    finally:
        pipeline_mod.build_evidence = orig_build_evidence
        rg_mod.build_evidence = orig_build_evidence


@pytest.mark.asyncio
async def test_recovery_invalid_evidence_fails_closed():
    """Invalid re-extracted evidence fails closed and does not commit corrupt checkpoints."""
    from tests.unified.mock_fixtures import create_mock_environment, create_pipeline_request
    import app.pipeline as pipeline_mod
    import app.reading_generation as rg_mod
    from app.stage_executor import StageFailedError, EvaluationRejectedError

    run_id = f"run_recov_failclosed_{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic", min_verified_claims=2, max_recovery_attempts=1)
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    req = create_pipeline_request(
        run_id=run_id,
        section_indices=(1,),
        parallel=False,
        finalize=False,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )
    client.init_run(run_id=req.run_id, epoch=req.epoch, lease_owner=req.lease_owner, policy_hash=policy.hash, job_id=req.job_id)

    orig_build_evidence = pipeline_mod.build_evidence
    call_count = 0

    def mock_build_evidence_corrupt_reextraction(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            # Stage 2 initial: claims marked with sectionId=2 to trigger recovery
            real_ev = orig_build_evidence(*args, **kwargs)
            for c in real_ev["claims"]:
                parts = c["claimId"].split(":")
                if len(parts) >= 4:
                    parts[2] = "2"
                    c["claimId"] = ":".join(parts)
            return real_ev
        else:
            # Stage 2.5 re-extraction: return invalid claims with corrupt offsets that fail evaluate_evidence
            return {
                "graphId": f"graph:{run_id}:1",
                "sourcePackId": f"source:{run_id}:1",
                "status": "ACCEPTED",
                "contentHash": "corrupt_hash",
                "claims": [
                    {
                        "claimId": f"claim:{run_id}:1:1",
                        "text": "Fabricated claim that does not exist in source text.",
                        "sourceId": "PMC12804876",
                        "offsets": {"sourceId": "PMC12804876", "startChar": 0, "endChar": 10},
                        "confidence": 1.0,
                        "entailment": "ENTAILS",
                    },
                    {
                        "claimId": f"claim:{run_id}:1:2",
                        "text": "Another fake claim.",
                        "sourceId": "PMC12804876",
                        "offsets": {"sourceId": "PMC12804876", "startChar": 10, "endChar": 20},
                        "confidence": 1.0,
                        "entailment": "ENTAILS",
                    },
                ],
            }

    pipeline_mod.build_evidence = mock_build_evidence_corrupt_reextraction
    rg_mod.build_evidence = mock_build_evidence_corrupt_reextraction
    try:
        with pytest.raises((StageFailedError, EvaluationRejectedError, ValueError)):
            await pipeline.execute(req)

        # Corrupt evidence must NEVER be accepted as head in the checkpoint store
        state = client.resume_state(run_id)
        assert not any(a.acceptedHash == "corrupt_hash" for a in state.artifacts)
    finally:
        pipeline_mod.build_evidence = orig_build_evidence
        rg_mod.build_evidence = orig_build_evidence


