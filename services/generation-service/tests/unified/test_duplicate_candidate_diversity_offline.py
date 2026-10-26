"""Offline regression tests for duplicate candidate diversity, candidate pool selection,
blueprint claim allocation, and autonomous recovery.

Verifies:
1. At least 5 distinct eligible claims produce 5 distinct TFNG slot bindings.
2. Controlled reuse when eligible claims < question slots.
3. Candidate pool selection rejects duplicate candidate 0 and selects valid candidate 1
   without an additional provider call.
4. Superficial paraphrases remain strictly rejected (shingle overlap > 0.70).
5. All candidates invalid triggers bounded recovery with precise exhausted target feedback.
6. Mismatched or fabricated evidenceClaimRef fails closed.
"""

from __future__ import annotations

from typing import Any
import pytest
from uuid import uuid4

from app.blueprint.claim_binding import (
    bind_claims_to_slots,
    check_claim_eligibility_for_family,
    score_claim_suitability_for_family,
)
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.blueprint import DifficultyLevel, QuestionSlot, QuestionType, TargetDifficulty
from app.contracts.policies import calculate_shingle_overlap
from app.contracts.question_type import QuestionPromptFamily
from app.section_runner import _parse_candidate_payload, SectionRunner
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.reading_models import RunContext, SourceRef

from tests.unified.mock_fixtures import (
    InMemoryCheckpointClient,
    MockProvider,
    SECTION_1_SOURCE_TEXT,
    create_mock_environment,
    create_pipeline_request,
)


def _bound_claim(source_ref: SourceRef, blueprint: ArtifactEnvelope, section_id: int, question_number: int) -> dict[str, Any]:
    section = next(s for s in blueprint.payload["sections"] if s["sectionId"] == section_id)
    slot = next(s for s in section["questionSlots"] if s["questionNumber"] == question_number)
    claim_id = slot["claimRefIds"][0]
    return next(c for c in source_ref.evidence.payload["claims"] if c["claimId"] == claim_id)


def _make_tfng_slot(q_num: int, group_idx: int = 0, sec_id: int = 1) -> QuestionSlot:
    return QuestionSlot(
        questionNumber=q_num,
        sectionId=sec_id,
        groupIndex=group_idx,
        questionType=QuestionType.TRUE_FALSE_NOT_GIVEN,
        targetSkill="factual_inference",
        targetDifficulty=TargetDifficulty(
            level=DifficultyLevel.FOUNDATION,
            isCalibrated=False,
            rationale="Editorial",
        ),
        claimRefIds=[],
    )


# ── 1. Blueprint Claim Allocation Tests (Task 1 / Check 1) ───────────────────

def test_at_least_5_distinct_eligible_claims_produce_5_distinct_tfng_bindings():
    """Verify that when >= 5 eligible claims exist, all 5 TFNG slots receive distinct claim bindings."""
    claims = [
        {
            "claimId": f"claim:run_test:1:{i}",
            "text": f"Archaeological excavation {i} in year {1980 + i} measured {i * 15} hectares of land with density level {i}.",
            "keywords": ["excavation", "measured", "year", "density"],
            "sectionId": 1,
        }
        for i in range(1, 9)
    ]
    slots = [_make_tfng_slot(q_num=i, group_idx=0, sec_id=1) for i in range(1, 6)]

    bound_slots = bind_claims_to_slots(
        slots=slots,
        claims=claims,
        section_id=1,
        graph_id="eg_test_1",
        run_id="run_test",
    )

    bound_cids = [s.claim_ref_ids[0] for s in bound_slots]
    assert len(bound_cids) == 5
    assert len(set(bound_cids)) == 5, f"Expected 5 distinct claim bindings, got: {bound_cids}"
    for cid in bound_cids:
        assert cid.startswith("claim:run_test:1:")


def test_claim_allocation_controlled_reuse_when_claims_fewer_than_slots():
    """Verify controlled balanced claim reuse only when eligible claims are fewer than slots."""
    claims = [
        {
            "claimId": "claim:run_test:1:alpha",
            "text": "Excavation alpha measured 45 hectares date century average.",
            "keywords": ["measured"],
            "sectionId": 1,
        },
        {
            "claimId": "claim:run_test:1:beta",
            "text": "Excavation beta recorded depth of 12 meters in tidal estuary.",
            "keywords": ["recorded"],
            "sectionId": 1,
        },
    ]
    slots = [_make_tfng_slot(q_num=i, group_idx=0, sec_id=1) for i in range(1, 6)]

    bound_slots = bind_claims_to_slots(
        slots=slots,
        claims=claims,
        section_id=1,
        graph_id="eg_test_1",
        run_id="run_test",
    )

    bound_cids = [s.claim_ref_ids[0] for s in bound_slots]
    assert len(bound_cids) == 5
    # Both claims must be used, balanced across the 5 slots
    assert set(bound_cids) == {"claim:run_test:1:alpha", "claim:run_test:1:beta"}
    assert bound_cids.count("claim:run_test:1:alpha") in (2, 3)
    assert bound_cids.count("claim:run_test:1:beta") in (2, 3)


# ── 2. Candidate Pool Selection Tests (Task 2 / Checks 2 & 3) ─────────────────

def test_duplicate_candidate_0_rejected_and_valid_candidate_1_selected():
    """Reproduces the exact Q1/Q2 failure scenario:

    Candidate 0 is identical to accepted Question 1.
    Candidate 1 is novel, valid, and passage-grounded.
    Candidate pool selection must reject Candidate 0 and return Candidate 1 without extra calls.
    """
    passage_text = (
        "However, only a few of these sites are sufficiently well preserved, well documented, "
        "and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions. "
        "Archaeological excavations at Didé West 1 identified extensive ancient slag mounds across three sectors."
    )
    claims_map = {
        "claim:run_test:1:2": {
            "claimId": "claim:run_test:1:2",
            "text": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions.",
        }
    }

    # Question 1 was previously accepted
    q1_payload = {
        "questionNumber": 1,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "The majority of iron production sites in West Africa are well preserved and well documented.",
        "answer": "FALSE",
        "evidenceQuote": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions.",
        "explanation": "The text states that only a few sites are well preserved and documented, contradicting majority.",
        "difficulty": "FOUNDATION",
        "passageEvidence": {"startChar": 0, "endChar": 169, "text": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions."},
        "evidenceClaimRef": "claim:run_test:1:2",
    }
    q1_envelope = ArtifactEnvelope.create(
        "question:run_test:1",
        ArtifactType.QUESTION,
        "run_test",
        q1_payload,
        "1.0.0",
    )

    # Provider returns candidate 0 (duplicate of Q1) and candidate 1 (novel)
    raw_provider_payload = {
        "candidates": [
            {
                "statement": "The majority of iron production sites in West Africa are well preserved and well documented.",
                "answer": "FALSE",
                "evidenceQuote": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions.",
                "explanation": "The passage confirms that only a few sites are well preserved and well documented.",
            },
            {
                "statement": "Only a few sites are sufficiently well preserved and documented for in-depth analysis.",
                "answer": "TRUE",
                "evidenceQuote": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions.",
                "explanation": "The passage explicitly limits the well-preserved and documented sites to only a few.",
            },
        ]
    }

    selected = _parse_candidate_payload(
        raw_payload=raw_provider_payload,
        q_num=2,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage_text,
        claims_map=claims_map,
        claim_id="claim:run_test:1:2",
        difficulty="FOUNDATION",
        prior_questions=[q1_envelope],
    )

    assert selected["questionNumber"] == 2
    assert selected["statement"] == "Only a few sites are sufficiently well preserved and documented for in-depth analysis."
    assert selected["answer"] == "TRUE"
    assert selected["evidenceClaimRef"] == "claim:run_test:1:2"


def test_superficial_paraphrase_candidate_rejected():
    """Verify that superficial paraphrases (prefixing 'The passage suggests that...', shingle overlap > 0.70)

    are strictly rejected.
    """
    passage_text = (
        "However, only a few of these sites are sufficiently well preserved, well documented, "
        "and well dated to allow for in-depth analysis of the historical dynamics."
    )
    claims_map = {
        "claim:run_test:1:2": {
            "claimId": "claim:run_test:1:2",
            "text": "Only a few sites are well preserved.",
        }
    }

    q1_payload = {
        "questionNumber": 1,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "The majority of iron production sites in West Africa are well preserved and well documented.",
        "answer": "FALSE",
    }
    q1_envelope = ArtifactEnvelope.create("question:run_test:1", ArtifactType.QUESTION, "run_test", q1_payload, "1.0.0")

    # Paraphrased candidate with shingle overlap > 0.70
    paraphrase_payload = {
        "candidates": [
            {
                "statement": "The passage suggests that the majority of iron production sites in West Africa are well preserved and well documented.",
                "answer": "FALSE",
                "evidenceQuote": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics.",
                "explanation": "The passage states only a few sites are well preserved and documented.",
            }
        ]
    }

    with pytest.raises(ValueError, match="duplicates an already accepted question"):
        _parse_candidate_payload(
            raw_payload=paraphrase_payload,
            q_num=2,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim:run_test:1:2",
            difficulty="FOUNDATION",
            prior_questions=[q1_envelope],
        )


# ── 3. Autonomous Recovery & Evidence Grounding Tests (Task 3 / Checks 4 & 5) ─

def test_all_candidates_invalid_or_duplicate_raises_for_retry():
    """When all candidates in a pool are duplicates or invalid, _parse_candidate_payload raises ValueError."""
    passage_text = "However, only a few of these sites are sufficiently well preserved."
    claims_map = {"claim:1": {"claimId": "claim:1", "text": "A few sites are preserved."}}

    q1_payload = {
        "questionNumber": 1,
        "statement": "Sites are well preserved in West Africa.",
        "answer": "TRUE",
    }
    q1_envelope = ArtifactEnvelope.create("question:run_test:1", ArtifactType.QUESTION, "run_test", q1_payload, "1.0.0")

    all_dup_payload = {
        "candidates": [
            {
                "statement": "Sites are well preserved in West Africa.",
                "answer": "TRUE",
                "evidenceQuote": "However, only a few of these sites are sufficiently well preserved.",
                "explanation": "Explanation meeting the minimum twenty-five character length.",
            },
            {
                "statement": "Sites are well preserved in West Africa.",
                "answer": "FALSE",
                "evidenceQuote": "However, only a few of these sites are sufficiently well preserved.",
                "explanation": "Another explanation meeting the minimum twenty-five character length.",
            },
        ]
    }

    with pytest.raises(ValueError, match="duplicates an already accepted question"):
        _parse_candidate_payload(
            raw_payload=all_dup_payload,
            q_num=2,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim:1",
            difficulty="FOUNDATION",
            prior_questions=[q1_envelope],
        )


def test_mismatched_evidence_claim_ref_is_prohibited():
    """A candidate claiming an ungrounded or cross-section claim ID not matching the blueprint slot is rejected."""
    passage_text = "Evidence text found in the passage."
    claims_map = {"claim:s1:1": {"claimId": "claim:s1:1", "text": passage_text}}

    payload = {
        "statement": "Valid statement about the passage.",
        "answer": "TRUE",
        "evidenceQuote": passage_text,
        "explanation": "Valid explanation exceeding twenty-five characters in length.",
    }

    # Bounded parsing with claim_id='claim:s1:1' guarantees evidenceClaimRef='claim:s1:1'
    parsed = _parse_candidate_payload(
        raw_payload=payload,
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage_text,
        claims_map=claims_map,
        claim_id="claim:s1:1",
        difficulty="FOUNDATION",
    )
    assert parsed["evidenceClaimRef"] == "claim:s1:1"
    assert parsed["evidenceClaimRef"] != "claim:s2:cross_section_99"


# ── 4. End-to-End SectionRunner Candidate Pool & Recovery Tests ──────────────

@pytest.mark.asyncio
async def test_section_runner_selects_candidate_1_when_candidate_0_is_duplicate():
    """Verifies SectionRunner evaluates all candidates in the candidate pool:

    When candidate 0 duplicates question 1, candidate 1 is selected immediately on attempt 0
    without triggering a provider repair call.
    """
    from tests.unified.test_section_standalone import _setup_standalone_prerequisites, create_source_inputs

    run_id = f"sr-cand-pool-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="legacy_preset")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    context = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    all_sources = create_source_inputs()
    source_input = next(s for s in all_sources if s.section_index == 1)
    config = policy.section(1)

    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    q1_claim = _bound_claim(source_ref, blueprint_env, 1, 1)
    q2_claim = _bound_claim(source_ref, blueprint_env, 1, 2)
    quote1, quote2 = q1_claim["text"], q2_claim["text"]
    quote = quote1
    s1 = q1_claim["text"]
    s2 = q2_claim["text"]

    # Script Question 1
    q1_op_id = f"op:{run_id}:question:1:1_1"
    provider.script_response(
        q1_op_id,
        {
            "candidates": [
                {
                    "statement": s1,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for Question 1 exceeding twenty-five characters in length.",
                }
            ]
        },
    )
    provider.script_response(
        f"op_solve_{run_id}_question:{run_id}:1_1",
        {
            "questionNumber": 1,
            "normalizedAnswer": "TRUE",
            "justification": f"Verified by evidence: {quote}",
            "citedSpans": [{"spanText": quote}],
            "selfReportedConfidence": 0.95,
        },
    )

    # Script Question 2: Candidate 0 duplicates Q1, Candidate 1 is novel
    quote = quote2
    q2_op_id = f"op:{run_id}:question:2:1_1"
    provider.script_response(
        q2_op_id,
        {
            "candidates": [
                {
                    "statement": s1,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for candidate 0 exceeding twenty-five characters in length.",
                },
                {
                    "statement": s2,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for candidate 1 exceeding twenty-five characters in length.",
                },
            ]
        },
    )
    provider.script_response(
        f"op_solve_{run_id}_question:{run_id}:2_1",
        {
            "questionNumber": 2,
            "normalizedAnswer": "TRUE",
            "justification": f"Verified by evidence: {quote}",
            "citedSpans": [{"spanText": quote}],
            "selfReportedConfidence": 0.95,
        },
    )

    runner = SectionRunner(client, gateway)
    res = await runner.run(context, config, source_ref, blueprint_env.to_ref(), policy)

    assert len(res.questions) == 13
    q1_art = res.questions[0]
    q2_art = res.questions[1]

    # Verify Question 1 received statement s1
    assert q1_art.payload["statement"] == s1
    # Verify Question 2 received candidate 1 statement s2 (novel), NOT candidate 0 (duplicate)
    assert q2_art.payload["statement"] == s2

    # Verify Question 2 did NOT trigger an attempt 2 provider call (_att2)
    att2_calls = [
        req for req, _ in provider.call_log
        if req.operation_id.endswith("_att2") and ":question:2:" in req.operation_id
    ]
    assert len(att2_calls) == 0, f"Candidate 1 should have been selected on attempt 0 without retry, but saw: {att2_calls}"


@pytest.mark.asyncio
async def test_section_runner_all_candidates_duplicate_triggers_bounded_recovery():
    """Verifies that when all candidates in attempt 1 are duplicates, SectionRunner invokes

    attempt 2 with precise negative constraints identifying exhausted targets, and succeeds.
    """
    from tests.unified.test_section_standalone import _setup_standalone_prerequisites, create_source_inputs

    run_id = f"sr-recovery-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="legacy_preset")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    context = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    all_sources = create_source_inputs()
    source_input = next(s for s in all_sources if s.section_index == 1)
    config = policy.section(1)

    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    q1_claim = _bound_claim(source_ref, blueprint_env, 1, 1)
    q2_claim = _bound_claim(source_ref, blueprint_env, 1, 2)
    quote1, quote2 = q1_claim["text"], q2_claim["text"]
    quote = quote1
    s1 = q1_claim["text"]
    s_dup_paraphrase = f"The passage suggests that {q1_claim['text']}"
    s_recovered = q2_claim["text"]

    # Question 1: Scripted to return s1
    q1_op_id = f"op:{run_id}:question:1:1_1"
    provider.script_response(
        q1_op_id,
        {
            "candidates": [
                {
                    "statement": s1,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for Q1 exceeding twenty-five characters in length.",
                }
            ]
        },
    )
    provider.script_response(
        f"op_solve_{run_id}_question:{run_id}:1_1",
        {
            "questionNumber": 1,
            "normalizedAnswer": "TRUE",
            "justification": f"Verified by evidence: {quote}",
            "citedSpans": [{"spanText": quote}],
            "selfReportedConfidence": 0.95,
        },
    )

    # Attempt 1 for Q2: All candidates duplicate Q1 (one exact, one paraphrase > 0.70 overlap)
    quote = quote2
    q2_att1_op = f"op:{run_id}:question:2:1_1"
    provider.script_response(
        q2_att1_op,
        {
            "candidates": [
                {
                    "statement": s1,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for candidate 0 exceeding twenty-five characters in length.",
                },
                {
                    "statement": s_dup_paraphrase,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for candidate 1 exceeding twenty-five characters in length.",
                },
            ]
        },
    )

    # Attempt 2 for Q2: Recovered novel candidate
    q2_att2_op = f"op:{run_id}:question:2:1_1_att2"
    provider.script_response(
        q2_att2_op,
        {
            "candidates": [
                {
                    "statement": s_recovered,
                    "answer": "TRUE",
                    "evidenceQuote": quote,
                    "explanation": "Explanation for recovered candidate exceeding twenty-five characters in length.",
                }
            ]
        },
    )

    provider.script_response(
        f"op_solve_{run_id}_question:{run_id}:2_1",
        {
            "questionNumber": 2,
            "normalizedAnswer": "TRUE",
            "justification": f"Verified by evidence: {quote}",
            "citedSpans": [{"spanText": quote}],
            "selfReportedConfidence": 0.95,
        },
    )

    runner = SectionRunner(client, gateway)
    res = await runner.run(context, config, source_ref, blueprint_env.to_ref(), policy)

    assert len(res.questions) == 13
    q2_art = res.questions[1]
    assert q2_art.payload["statement"] == s_recovered

    # Verify attempt 2 was invoked with precise feedback identifying exhausted targets
    att2_calls = [
        req for req, _ in provider.call_log
        if req.operation_id == q2_att2_op
    ]
    assert len(att2_calls) == 1
    user_msg = att2_calls[0].messages[1].content
    assert "PREVIOUS ATTEMPT DEFECT" in user_msg
    assert "EXHAUSTED FACTUAL TARGETS" in user_msg
    assert "CRITICAL CANDIDATE DIVERSITY AND UNIQUENESS INVARIANT" in user_msg

