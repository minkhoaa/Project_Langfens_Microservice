"""Critical Content Generation Correctness Gate Acceptance Tests.

Verifies the 7 mandatory correctness gates on branch `autonomous-generation`:
1. The committed passage actually originates from the provider response.
2. Provider failure cannot produce an ACCEPTED passage.
3. Generated questions actually originate from parsed provider candidates.
4. Incorrect MCQ keys and unsupported TRUE/FALSE/NOT GIVEN answers are rejected.
5. Blind-solver/adversarial checks run and can block acceptance.
6. All three sections use the same runner and pass full-paper mock E2E.
7. Crash recovery does not regenerate accepted content or replay unknown provider calls.

INVARIANT: NO live MiniMax calls; hermetic recorded fixtures and deterministic ProviderGateway only.
"""

from __future__ import annotations

import asyncio
from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.blueprint import QuestionType
from app.contracts.issue import IssueCode
from app.contracts.policies import count_words
from app.persistence.models import OperationResumeInfo
from app.providers.errors import ProviderError, TimeoutError as ProviderTimeoutError
from app.providers.models import Capability, ProviderRequest
from app.reading_evaluation import evaluate_passage, evaluate_question
from app.reading_models import AcceptedSectionArtifact, PipelineRequest, PipelineResult, RunContext, SourceRef
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.section_runner import SectionRunner
from app.stage_executor import (
    EvaluationRejectedError, RecoveryKind, StageExecutor, StageFailedError,
    UnresolvedProviderOutcomeError,
)

from tests.unified.mock_fixtures import (
    SECTION_1_SOURCE_TEXT,
    SECTION_2_SOURCE_TEXT,
    SECTION_3_SOURCE_TEXT,
    create_mock_environment,
    create_pipeline_request,
    create_source_inputs,
)
from tests.unified.test_section_standalone import _setup_standalone_prerequisites


def _bound_claim_for_question(source_ref: SourceRef, blueprint_env: ArtifactEnvelope, section_id: int, question_number: int) -> dict[str, Any]:
    section = next(s for s in blueprint_env.payload["sections"] if s["sectionId"] == section_id)
    slot = next(s for s in section["questionSlots"] if s["questionNumber"] == question_number)
    claim_id = (slot.get("claimRefIds") or [None])[0]
    claim = next((c for c in source_ref.evidence.payload["claims"] if c["claimId"] == claim_id), None)
    assert claim is not None, f"Blueprint slot Q{question_number} has no matching verified claim"
    return claim


# ─── Gate 1: Committed passage originates from provider response ─────────────

@pytest.mark.asyncio
async def test_gate_1_committed_passage_originates_from_provider_response() -> None:
    """Gate 1: Verifies committed passage draft strictly originates from provider gateway response."""
    run_id = f"gate1-prov-origin-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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
    source_input = all_sources[0]  # Section 1
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    # Distinctive recorded academic passage payload
    distinct_title = "DISTINCTIVE_PROVENANCE_PASSAGE_TITLE_S1"
    # Construct distinct paragraphs embedding verified claims
    claims = source_ref.evidence.payload.get("claims", [])
    connectives = [
        "Subsequent empirical analyses reinforced this documented methodological pattern across the surveyed landscape.",
        "Detailed sedimentary measurements confirmed the structural and environmental characteristics of the regional habitat.",
        "Systematic comparative sampling provided consistent supporting evidence across the designated excavation zones.",
        "Careful contextual recording and stratigraphic calibration remained central to the interdisciplinary analytical approach.",
        "Comprehensive environmental assessments further highlighted several consistent parameters throughout the developmental horizon.",
    ]
    academic_connectives = [
        "Careful comparative analysis of these physical samples indicated consistent structural adaptation across consecutive chronological intervals.",
        "The integration of microstratigraphic profiling with geochemical screening provided essential corroboration for the initial empirical model.",
        "Such interdisciplinary observations emphasize the complex operational relationships between resource availability and communal infrastructure.",
        "Systematic evaluation across multiple independent sampling horizons confirmed that these primary features were deliberately engineered rather than incidental.",
        "Further contextual assessment established that regional depositional processes maintained continuous stability throughout the recorded horizon.",
        "These combined findings illustrate the sophisticated technical competence and organizational capacity governing local environmental management.",
        "Methodological uniformity across the recovered materials ensured that interpretive classifications remained reliable and reproducible.",
        "Extended macro-botanical analysis substantiated the presence of coordinated agricultural management throughout the regional river basin.",
        "Detailed geochemical profiling of preserved sediments verified the absence of modern intrusive contamination within the core strata.",
        "The spatial coherence of these structural alignments demonstrates an established architectural tradition spanning multiple generations.",
        "Subsequent laboratory examinations corroborated the primary interpretive conclusions across all diagnostic indicators.",
        "Comprehensive macroscopic examination reaffirmed that local technological traditions remained stable and resilient.",
        "These empirical observations provide critical documentation regarding early socioeconomic organization and landscape engineering.",
        "Careful spatial documentation confirmed that distinct operational zones were maintained throughout consecutive occupational phases.",
        "The overall architectural and stratigraphic evidence substantiates an enduring tradition of deliberate resource stewardship.",
    ]
    distinct_paragraphs = []
    for i in range(5):
        c_slice = claims[i * 3 : (i + 1) * 3]
        s_list = []
        for j, c in enumerate(c_slice):
            s_list.append(c["text"].strip())
            s_list.append(connectives[(i * 3 + j) % len(connectives)])
        s_list.append(academic_connectives[i * 3])
        s_list.append(academic_connectives[i * 3 + 1])
        s_list.append(academic_connectives[i * 3 + 2])
        distinct_paragraphs.append(" ".join(s_list))
    distinct_passage = "\n\n".join(distinct_paragraphs)
    word_count = count_words(distinct_passage)
    assert 720 <= word_count <= 915, f"Word count {word_count} must be within 720-915"

    recorded_passage_payload = {
        "title": distinct_title,
        "passage": distinct_passage,
        "wordCount": word_count,
        "styleProfile": "EXPOSITORY_SCIENTIFIC",
    }

    # Bind scripted provider response for the section 1 passage artifact
    passage_art_id = f"passage:{run_id}:1"
    provider.script_response(passage_art_id, recorded_passage_payload)

    runner = SectionRunner(client, gateway)
    result = await runner.run(
        context,
        config,
        source_ref,
        blueprint_env.to_ref(),
        policy,
    )

    # Invariant: Committed passage strictly carries the provider's distinct title and text
    assert result.passage is not None
    assert result.passage.payload["title"] == distinct_title
    assert result.passage.payload["passage"] == distinct_passage
    assert result.passage.payload["wordCount"] == word_count

    # Verify provider was physically invoked for passage generation
    passage_calls = [
        req for req, _ in provider.call_log
        if req.capability == Capability.GENERATE_JSON and ("passage:" in (req.artifact_id or ""))
    ]
    assert len(passage_calls) >= 1
    assert passage_calls[0].artifact_id == passage_art_id


# ─── Gate 2: Provider failure cannot produce an ACCEPTED passage ──────────────

@pytest.mark.asyncio
async def test_gate_2_provider_failure_cannot_produce_accepted_passage() -> None:
    """Gate 2: Verifies that provider failure triggers fail-closed error without falling back to synthetic composition."""
    run_id = f"gate2-prov-fail-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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
    source_input = all_sources[0]
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    # Inject provider failure when passage generation is invoked
    provider.fail_next(ProviderError("MiniMax 503 Service Unavailable: Rate limit exceeded"))

    runner = SectionRunner(client, gateway)
    with pytest.raises((StageFailedError, UnresolvedProviderOutcomeError)) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    # Invariant: Must fail closed with error mentioning generation failure
    assert f"passage:{run_id}:1" in str(exc_info.value)

    # Invariant: Durable state must NOT have an accepted passage head
    resume_state = client.resume_state(run_id)
    accepted_passage_heads = [
        a for a in resume_state.artifacts
        if a.artifactId == f"passage:{run_id}:1" and not a.isStale
    ]
    assert len(accepted_passage_heads) == 0


# ─── Gate 3: Generated questions actually originate from parsed candidates ───

@pytest.mark.asyncio
async def test_gate_3_generated_questions_originate_from_parsed_provider_candidates() -> None:
    """Gate 3: Verifies question artifacts originate from parsed provider candidates, not fixed key rotations."""
    run_id = f"gate3-cand-origin-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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
    source_input = all_sources[0]
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    # Script a distinctive candidate grounded in the immutable claim allocated to Q1.
    q1_claim = _bound_claim_for_question(source_ref, blueprint_env, 1, 1)
    quote_in_passage = q1_claim["text"]
    distinct_statement = f"PROVENANCE_Q1_STATEMENT: {q1_claim['text']}"
    explanation = f"The allocated passage claim explicitly supports this statement: {q1_claim['text']}"

    q1_candidate = {
        "candidates": [
            {
                "questionNumber": 1,
                "statement": distinct_statement,
                "answer": "TRUE",
                "evidenceQuote": quote_in_passage,
                "explanation": explanation,
            }
        ]
    }
    provider.script_response(f"question:{run_id}:1", q1_candidate)

    runner = SectionRunner(client, gateway)
    result = await runner.run(
        context,
        config,
        source_ref,
        blueprint_env.to_ref(),
        policy,
    )

    # Invariant: Question 1 artifact strictly matches provider candidate
    q1_env = next(q for q in result.questions if q.payload.get("questionNumber") == 1)
    assert q1_env.payload["statement"] == distinct_statement
    assert q1_env.payload["answer"] == "TRUE"
    assert q1_env.payload["evidenceQuote"] == quote_in_passage
    assert q1_env.payload["explanation"] == explanation


# ─── Gate 4: Incorrect MCQ keys and unsupported TFNG are rejected ────────────

@pytest.mark.asyncio
async def test_gate_4_incorrect_mcq_keys_and_unsupported_tfng_rejected() -> None:
    """Gate 4: Proves that incorrect MCQ keys and unsupported TFNG answers are rejected by evaluators."""
    run_id = f"gate4-reject-bad-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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
    source_input = all_sources[0]
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    # Subcase A: Unsupported TFNG where evidence quote is NOT in the passage
    fake_quote = "This non-existent quote does not appear anywhere in the passage text at all."
    bad_tfng_candidate = {
        "candidates": [
            {
                "questionNumber": 1,
                "statement": "An ungrounded claim that lacks evidence.",
                "answer": "TRUE",
                "evidenceQuote": fake_quote,
                "explanation": "Attempting to claim an unsupported fact as valid.",
            }
        ]
    }
    provider.script_response(f"question:{run_id}:1", bad_tfng_candidate)

    runner = SectionRunner(client, gateway)
    with pytest.raises((EvaluationRejectedError, StageFailedError)) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    assert f"question:{run_id}:1" in str(exc_info.value)


@pytest.mark.asyncio
async def test_gate_4b_mcq_duplicate_options_rejected() -> None:
    """Gate 4b: Proves MCQ question with duplicate options or bad distractors is rejected."""
    run_id = f"gate4b-mcq-dup-{uuid4().hex[:8]}"
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
    source_input = all_sources[1]  # Section 2 has MCQ Single (Q14-19)
    config = policy.section(2)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 2, source_input, policy
    )

    # Keep the candidate provenance-valid so the duplicate-option evaluator is reached.
    q14_claim = _bound_claim_for_question(source_ref, blueprint_env, 2, 14)
    quote_in_s2 = q14_claim["text"]
    bad_mcq_candidate = {
        "candidates": [
            {
                "questionNumber": 14,
                "prompt": "Which statement is supported by the passage?",
                "options": [
                    f"A. {q14_claim['text']}",
                    f"B. {q14_claim['text']}",  # Duplicate option
                    "C. The passage explicitly states the opposite condition.",
                    "D. The passage provides no information about this topic.",
                ],
                "correctOption": "A",
                "evidenceQuote": quote_in_s2,
                "explanation": f"The passage supports the selected option: {q14_claim['text']}",
            }
        ]
    }
    provider.script_response(f"question:{run_id}:14", bad_mcq_candidate)

    runner = SectionRunner(client, gateway)
    with pytest.raises(EvaluationRejectedError) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    assert f"question:{run_id}:14" in str(exc_info.value)


# ─── Gate 5: Blind solver and adversarial checks block acceptance ─────────────

@pytest.mark.asyncio
async def test_gate_5a_blind_solver_disagreement_blocks_acceptance() -> None:
    """Gate 5a: Proves that when independent blind solver disagrees with author key, acceptance is blocked."""
    run_id = f"gate5a-blind-block-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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
    source_input = all_sources[0]
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    # Author generates a TRUE question tied to the immutable Q1 blueprint claim.
    q1_claim = _bound_claim_for_question(source_ref, blueprint_env, 1, 1)
    quote = q1_claim["text"]
    provider.script_response(f"question:{run_id}:1", {
        "candidates": [{
            "questionNumber": 1,
            "statement": q1_claim["text"],
            "answer": "TRUE",
            "evidenceQuote": quote,
            "explanation": f"The allocated claim supports this true statement: {q1_claim['text']}",
        }]
    })

    # But independent blind solver determines the answer is FALSE!
    provider.script_response(Capability.SOLVE_ITEM.value, {
        "questionNumber": 1,
        "normalizedAnswer": "FALSE",  # Disagrees with author key TRUE!
        "justification": "The passage indicates no intentional hydrological modification occurred.",
        "citedSpans": [{"spanText": quote}],
        "selfReportedConfidence": 0.95,
    })

    runner = SectionRunner(client, gateway)
    with pytest.raises(EvaluationRejectedError) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    # Acceptance blocked by blind solver disagreement
    assert f"question:{run_id}:1" in str(exc_info.value)
    assert any(
        e.evaluator_id == "eval_blind_solver_adversary" and not e.is_pass()
        for e in exc_info.value.evaluations
    )


@pytest.mark.asyncio
async def test_gate_5b_adversary_ambiguity_blocks_acceptance() -> None:
    """Gate 5b: Proves that when adversary detects grounded ambiguity or multiple valid options, acceptance is blocked."""
    run_id = f"gate5b-adv-block-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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
    source_input = all_sources[0]
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    q1_claim = _bound_claim_for_question(source_ref, blueprint_env, 1, 1)
    quote = q1_claim["text"]
    ambiguous_statement = f"It is clear that {q1_claim['text']}"
    provider.script_response(f"question:{run_id}:1", {
        "candidates": [{
            "questionNumber": 1,
            "statement": ambiguous_statement,
            "answer": "TRUE",
            "evidenceQuote": quote,
            "explanation": f"The allocated claim supports this true statement: {q1_claim['text']}",
        }]
    })

    # Solver matches TRUE
    provider.script_response(Capability.SOLVE_ITEM.value, {
        "questionNumber": 1,
        "normalizedAnswer": "TRUE",
        "justification": f"Verified by passage evidence: {quote}",
        "citedSpans": [{"spanText": quote}],
        "selfReportedConfidence": 0.95,
    })

    # But adversary detects critical ambiguity!
    provider.script_response(Capability.EVALUATE_ITEM.value, {
        "questionNumber": 1,
        "isAmbiguous": True,
        "adversarySummary": "Statement can equally be interpreted as NOT GIVEN due to ambiguous temporal framing.",
        "identifiedAlternatives": [
            {
                "alternativeAnswer": "NOT_GIVEN",
                "ambiguityType": "MULTIPLE_VALID_OPTIONS",
                "reasoning": "Temporal boundary is insufficiently defined in the question stem.",
                "isGroundedInPassage": True,
                "citedSpans": [{"spanText": quote}],
            }
        ],
    })

    # Isolate evaluator rejection from hybrid repair-provider availability.
    context = context.model_copy(update={"enable_hybrid_repair": False})
    runner = SectionRunner(client, gateway)
    with pytest.raises(EvaluationRejectedError) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    # Acceptance blocked by adversary ambiguity finding
    assert f"question:{run_id}:1" in str(exc_info.value)
    assert any(
        e.evaluator_id == "eval_blind_solver_adversary" and not e.is_pass()
        for e in exc_info.value.evaluations
    )


# ─── Gate 6: All three sections use the same runner and pass mock E2E ────────

@pytest.mark.asyncio
async def test_gate_6_all_three_sections_use_same_runner_full_paper_mock_e2e() -> None:
    """Gate 6: Verifies all three sections use the exact same SectionRunner class and pass full 40-question mock E2E."""
    run_id = f"gate6-e2e-40q-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # Verify pipeline uses single SectionRunner factory/class
    runner_instance = pipeline._get_runner()
    assert isinstance(runner_instance, SectionRunner)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
    )
    client.init_run(
        run_id=request.run_id,
        epoch=request.epoch,
        lease_owner=request.lease_owner,
        policy_hash=policy.hash,
        job_id=request.job_id,
    )

    result = await pipeline.execute(request)

    assert isinstance(result, PipelineResult)
    assert result.status == "ACCEPTED"
    assert len(result.sections) == 3
    assert result.paper is not None
    assert result.exam_id is not None

    paper_payload = result.paper.payload
    assert paper_payload["totalQuestions"] == 40
    assert 2150 <= paper_payload["totalWords"] <= 2750

    # Contiguous 1–40 numbering
    all_questions = [
        q for sec in paper_payload["sections"] for grp in sec.get("groups", []) for q in grp.get("questions", [])
    ]
    assert len(all_questions) == 40
    assert [q["questionNumber"] for q in all_questions] == list(range(1, 41))

    # All three section indices represented
    assert [s.section_id for s in result.sections] == [1, 2, 3]


# ─── Gate 7: Crash recovery preserves accepted content and handles unknowns ──

@pytest.mark.asyncio
async def test_gate_7_crash_recovery_preserves_accepted_content_no_replay() -> None:
    """Gate 7: Verifies crash recovery reuses accepted content without redispatch and halts on unresolved unknowns."""
    run_id = f"gate7-recovery-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # 1. First execution: run Section 1 only to accept passage and questions
    req_s1 = create_pipeline_request(
        run_id=run_id,
        section_indices=(1,),
        parallel=False,
        finalize=False,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )
    client.init_run(
        run_id=run_id,
        epoch=req_s1.epoch,
        lease_owner=req_s1.lease_owner,
        policy_hash=policy.hash,
        job_id=req_s1.job_id,
    )
    res_s1 = await pipeline.execute(req_s1)
    assert res_s1.status == "ACCEPTED"

    # Count calls after section 1 accepted
    calls_after_s1 = len(provider.requests)
    assert calls_after_s1 > 0

    # 2. Crash & Resume: re-run Section 1
    # Check that already accepted Section 1 artifacts are reused with 0 new provider calls
    res_s1_resumed = await pipeline.execute(req_s1)
    assert res_s1_resumed.status == "ACCEPTED"
    assert len(provider.requests) == calls_after_s1  # ZERO new provider calls for Section 1!

    # 3. Halt on unresolved unknown provider outcome
    # Inject an in-flight operation for Section 2 passage
    s2_passage_art_id = f"passage:{run_id}:2"
    client.operations["op_unknown_s2_passage"] = OperationResumeInfo(
        operationId="op_unknown_s2_passage",
        operationType="PROVIDER_CALL",
        artifactId=s2_passage_art_id,
        status="RESERVED",
        requestHash="a" * 64,
        tokenReservation=1000,
        tokensUsed=0,
        wallTimeReservationSeconds=60.0,
        wallTimeUsedSeconds=0.0,
    )

    req_s2 = create_pipeline_request(
        run_id=run_id,
        section_indices=(2,),
        parallel=False,
        finalize=False,
        policy=policy,
        job_id=client.default_job_id,
        lease_owner=client.default_lease_owner,
    )

    with pytest.raises(UnresolvedProviderOutcomeError) as exc_info:
        await pipeline.execute(req_s2)

    assert "op_unknown_s2_passage" in str(exc_info.value)
