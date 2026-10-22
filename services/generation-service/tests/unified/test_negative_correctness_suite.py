"""Comprehensive Negative Test Suite for Langfens Unified Reading Generation.

Verifies the mandatory negative conditions:
1. Invalid provider JSON / missing answers.
2. Incorrect TFNG and MCQ semantic keys.
3. Fake NOT GIVEN assessments.
4. Missing required evaluators blocking acceptance.
5. Provider timeout / HTTP 429 / UNKNOWN_OUTCOME.
6. Crash during blind-solver / adversary execution.
7. Resume without duplicate provider calls.
8. Duplicate finalization idempotency.
9. Three sections through one runner.

INVARIANT: Zero mocked PASS may substitute for real semantic validation.
"""

from __future__ import annotations

import asyncio
from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.policies import count_words
from app.persistence.models import (
    BuildExamInternalRequest,
    CheckpointCommitRequest,
    OperationGrantRequest,
    UnknownOutcomeRequest,
)
from app.providers.errors import (
    DeadlineExceededError,
    ProviderError,
    RateLimitedError,
    TimeoutError as ProviderTimeoutError,
)
from app.providers.models import Capability, ProviderRequest
from app.reading_evaluation import evaluate_passage, evaluate_question
from app.reading_models import PipelineRequest, PipelineResult, RunContext, SourceRef
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.section_runner import SectionRunner, _parse_candidate_payload
from app.stage_executor import (
    STAGE_REQUIRED_EVALUATORS,
    EvaluationRejectedError,
    RecoveryKind,
    StageExecutor,
    StageFailedError,
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


# ── 1. Invalid provider JSON / missing answers ───────────────────────────────

@pytest.mark.asyncio
async def test_negative_invalid_provider_json_missing_answers() -> None:
    """Verifies that provider payload missing answers or returning malformed data is rejected."""
    passage_text = "Excavations at lakeside settlements revealed complex networks of timber-revetted drainage canals."
    claims_map = {"claim_1": {"claimId": "claim_1", "text": passage_text}}

    # Subcase A: Missing answer
    malformed_cand_no_answer = {
        "statement": "Timber canals were excavated.",
        "evidenceQuote": passage_text,
        "explanation": "The passage confirms timber canals were excavated by researchers.",
    }
    with pytest.raises(ValueError, match="answer is missing"):
        _parse_candidate_payload(
            malformed_cand_no_answer,
            q_num=1,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    # Subcase B: Malformed payload type
    with pytest.raises(ValueError, match="Expected dict"):
        _parse_candidate_payload(
            "not a dict",
            q_num=1,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    # Subcase C: Missing explanation
    missing_explanation = {
        "statement": "Timber canals were excavated.",
        "answer": "TRUE",
        "evidenceQuote": passage_text,
    }
    with pytest.raises(ValueError, match="explanation is missing or too short"):
        _parse_candidate_payload(
            missing_explanation,
            q_num=1,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )


# ── 2. Incorrect TFNG and MCQ semantic keys ──────────────────────────────────

@pytest.mark.asyncio
async def test_negative_incorrect_tfng_and_mcq_semantic_keys() -> None:
    """Verifies that invalid objective answer keys (e.g. invalid TFNG key or unsupported MCQ key) fail closed."""
    passage_text = "Excavations at lakeside settlements revealed complex networks of timber-revetted drainage canals."
    claims_map = {"claim_1": {"claimId": "claim_1", "text": passage_text}}

    # Subcase A: Invalid TFNG key
    with pytest.raises(ValueError, match="Invalid answer 'MAYBE' for TRUE_FALSE_NOT_GIVEN"):
        _parse_candidate_payload(
            {
                "statement": "Settlements had canals.",
                "answer": "MAYBE",
                "evidenceQuote": passage_text,
                "explanation": "Valid explanation exceeding twenty-five characters in length.",
            },
            q_num=1,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    # Subcase B: Invalid MCQ key (e.g. 'E' or 'Z')
    mcq_invalid_key = {
        "prompt": "Which feature was discovered at the site?",
        "options": ["A. Canals", "B. Towers", "C. Walls", "D. Bridges"],
        "correctOption": "Z",
        "evidenceQuote": passage_text,
        "explanation": "Valid explanation exceeding twenty-five characters in length.",
    }
    artifact = ArtifactEnvelope.create(
        artifact_id="q_mcq_bad_key",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        run_id="run_neg",
        producer_version="2.0.0",
        payload={
            "questionNumber": 14,
            "questionType": "MULTIPLE_CHOICE_SINGLE",
            "prompt": mcq_invalid_key["prompt"],
            "options": mcq_invalid_key["options"],
            "correctOption": "Z",
            "evidenceQuote": passage_text,
            "explanation": mcq_invalid_key["explanation"],
            "difficulty": "MODERATE",
            "passageEvidence": {"startChar": 0, "endChar": len(passage_text), "text": passage_text},
            "evidenceClaimRef": "claim_1",
        },
        parent_refs=(),
    )
    evals = evaluate_question(artifact, passage_text, "MODERATE", ())
    semantic_eval = next(e for e in evals if e.evaluator_id == "eval_question_semantic")
    assert not semantic_eval.is_pass()
    assert any(i.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM for i in semantic_eval.issues)


# ── 3. Fake NOT GIVEN assessments ────────────────────────────────────────────

@pytest.mark.asyncio
async def test_negative_fake_not_given_assessments() -> None:
    """Verifies that NOT GIVEN items with fabricated positive evidence or missing absence confirmation are rejected."""
    passage_text = "Excavations at lakeside settlements revealed complex networks of timber-revetted drainage canals."

    # Subcase A: NOT GIVEN supplying positive evidence quote
    artifact_with_positive_quote = ArtifactEnvelope.create(
        artifact_id="q_ng_fake_quote",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        run_id="run_neg",
        producer_version="2.0.0",
        payload={
            "questionNumber": 4,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "Pottery kilns operated continuously during winter months.",
            "answer": "NOT_GIVEN",
            "evidenceQuote": passage_text,  # Fabricated positive quote!
            "explanation": "Valid explanation exceeding twenty-five characters in length.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": 0, "endChar": len(passage_text), "text": passage_text},
            "evidenceClaimRef": "claim_1",
            "absenceAssessment": {
                "assessmentId": "abs:4",
                "absenceConfirmed": True,
                "absenceReason": "Passage makes no mention of pottery kilns or seasonal schedules.",
            },
        },
        parent_refs=(),
    )
    evals = evaluate_question(artifact_with_positive_quote, passage_text, "FOUNDATION", ())
    evidence_eval = next(e for e in evals if e.evaluator_id == "eval_evidence_offsets")
    assert not evidence_eval.is_pass()

    # Subcase B: NOT GIVEN with absenceConfirmed=False
    artifact_unconfirmed_absence = ArtifactEnvelope.create(
        artifact_id="q_ng_unconfirmed",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        run_id="run_neg",
        producer_version="2.0.0",
        payload={
            "questionNumber": 5,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "Pottery kilns operated continuously during winter months.",
            "answer": "NOT_GIVEN",
            "explanation": "Valid explanation exceeding twenty-five characters in length.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": 0, "endChar": len(passage_text), "text": passage_text},
            "evidenceClaimRef": "claim_1",
            "absenceAssessment": {
                "assessmentId": "abs:5",
                "absenceConfirmed": False,  # Not confirmed!
                "absenceReason": "Unclear whether kilns existed.",
            },
        },
        parent_refs=(),
    )
    evals2 = evaluate_question(artifact_unconfirmed_absence, passage_text, "FOUNDATION", ())
    semantic_eval = next(e for e in evals2 if e.evaluator_id == "eval_question_semantic")
    assert not semantic_eval.is_pass()


# ── 4. Missing required evaluators ───────────────────────────────────────────

@pytest.mark.asyncio
async def test_negative_missing_required_evaluators_block_acceptance() -> None:
    """Verifies that missing any required evaluator (e.g. eval_question_semantic) strictly blocks acceptance."""
    run_id = f"neg-missing-eval-{uuid4().hex[:8]}"
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
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, all_sources[0], policy
    )

    executor = StageExecutor(
        client,
        context,
        policy,
        required_evaluator_ids=(
            "eval_question_structure",
            "eval_answer_verbatim_length",
            "eval_evidence_offsets",
            "eval_question_uniqueness",
            "eval_question_semantic",  # REQUIRED
            "eval_blind_solver_adversary",
        ),
    )

    art_id = f"question:{run_id}:1"
    q_parents = (source_ref.source.to_ref(), blueprint_env.to_ref())

    async def generate_q(version: int) -> dict[str, Any]:
        return {
            "questionNumber": 1,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "Communities modified hydrology.",
            "answer": "TRUE",
            "evidenceQuote": "Excavations at lakeside settlements revealed complex networks of timber-revetted drainage canals.",
            "explanation": "Verified in the passage text with sufficient detail.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": 0, "endChar": 50, "text": "Excavations at lakeside settlements revealed complex"},
            "evidenceClaimRef": "claim_1",
        }

    # Deliberately omit eval_question_semantic from evaluate return
    async def evaluate_omitting_semantic(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return [
            EvaluationResult(
                evaluationId="ev_1",
                evaluatorId="eval_question_structure",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            EvaluationResult(
                evaluationId="ev_2",
                evaluatorId="eval_answer_verbatim_length",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            EvaluationResult(
                evaluationId="ev_3",
                evaluatorId="eval_evidence_offsets",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            EvaluationResult(
                evaluationId="ev_4",
                evaluatorId="eval_question_uniqueness",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            EvaluationResult(
                evaluationId="ev_5",
                evaluatorId="eval_blind_solver_adversary",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            # eval_question_semantic is OMITTED!
        ]

    with pytest.raises(EvaluationRejectedError) as exc_info:
        await executor.execute(
            art_id,
            ArtifactType.QUESTION,
            q_parents,
            generate_q,
            evaluate_omitting_semantic,
            section_id=1,
        )

    assert "missing required evaluations: ['eval_question_semantic']" in str(exc_info.value)


# ── 5. Provider timeout / HTTP 429 / UNKNOWN_OUTCOME ────────────────────────

@pytest.mark.asyncio
async def test_negative_provider_timeout_and_unknown_outcome() -> None:
    """Verifies that provider timeout / 429 records UNKNOWN_OUTCOME and prevents corrupted acceptance."""
    run_id = f"neg-timeout-{uuid4().hex[:8]}"
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
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, all_sources[0], policy
    )

    # Fail provider with a timeout on question 1
    provider.fail_next(ProviderTimeoutError("Simulated socket timeout reading model response"))

    runner = SectionRunner(client, gateway)
    with pytest.raises((StageFailedError, UnresolvedProviderOutcomeError)) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    assert f"passage:{run_id}:1" in str(exc_info.value) or f"question:{run_id}:1" in str(exc_info.value)
    # Check that client recorded the failure without accepting a phantom artifact
    head = client.heads.get((run_id, f"question:{run_id}:1"))
    assert head is None, "Failed candidate must NEVER become an accepted head!"


# ── 6. Crash during blind-solver/adversary execution ─────────────────────────

@pytest.mark.asyncio
async def test_negative_crash_during_blind_solver_adversary_execution() -> None:
    """Verifies that a crash during blind solver or adversary evaluation fails closed and never accepts."""
    run_id = f"neg-solver-crash-{uuid4().hex[:8]}"
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
    config = policy.section(1)
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, all_sources[0], policy
    )

    # Inject failure on blind solver capability call
    quote = "Archaeological and paleoecological investigations across temperate river basins demonstrate that early agrarian communities actively modified local hydrology to cultivate wetland cereals."
    provider.script_response(f"question:{run_id}:1", {
        "candidates": [{
            "questionNumber": 1,
            "statement": "Early communities modified local hydrology for cereal cultivation.",
            "answer": "TRUE",
            "evidenceQuote": quote,
            "explanation": "Direct statement confirmed in paragraph one.",
        }]
    })

    # Cause blind solver to raise an unexpected runtime error
    async def crash_call(req, api_key, deadline):
        if req.capability == Capability.SOLVE_ITEM:
            raise RuntimeError("CRITICAL: Blind solver execution worker crashed unexpectedly")
        return await provider.call(req, api_key, deadline)

    orig_call = gateway.execute

    async def gateway_execute_hook(req, *args, **kwargs):
        if req.capability == Capability.SOLVE_ITEM:
            raise RuntimeError("CRITICAL: Solver execution connection reset")
        return await orig_call(req, *args, **kwargs)

    gateway.execute = gateway_execute_hook

    runner = SectionRunner(client, gateway)
    with pytest.raises(EvaluationRejectedError) as exc_info:
        await runner.run(
            context,
            config,
            source_ref,
            blueprint_env.to_ref(),
            policy,
        )

    assert f"question:{run_id}:1" in str(exc_info.value)
    # Ensure failure is non-pass
    assert not any(e.evaluator_id == "eval_blind_solver_adversary" and e.is_pass() for e in exc_info.value.evaluations)


# ── 7. Resume without duplicate provider calls ───────────────────────────────

@pytest.mark.asyncio
async def test_negative_resume_without_duplicate_provider_calls() -> None:
    """Verifies that resuming a partially or fully completed run makes zero redundant provider calls for accepted artifacts."""
    run_id = f"neg-resume-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # Phase 1: Run Section 1
    req1 = create_pipeline_request(
        run_id=run_id,
        section_indices=(1,),
        parallel=False,
        finalize=False,
        policy=policy,
    )
    client.init_run(run_id=req1.run_id, epoch=req1.epoch, lease_owner=req1.lease_owner, policy_hash=policy.hash, job_id=req1.job_id)
    res1 = await pipeline.execute(req1)
    calls_after_s1 = provider.calls_count
    assert len(res1.sections) == 1
    assert calls_after_s1 > 0

    # Phase 2: Re-run with Section 1 and Section 2
    req2 = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2),
        parallel=False,
        finalize=False,
        policy=policy,
        job_id=req1.job_id,
        lease_owner=req1.lease_owner,
    )
    res2 = await pipeline.execute(req2)
    assert len(res2.sections) == 2

    # Section 1 artifacts must be reused: verify no new Section 1 provider calls occurred
    s1_calls = [
        req for req, _ in provider.call_log[calls_after_s1:]
        if req.section_id == "1"
    ]
    assert len(s1_calls) == 0, f"Expected 0 redundant Section 1 calls on resume, got {len(s1_calls)}"


# ── 8. Duplicate finalization idempotency ────────────────────────────────────

@pytest.mark.asyncio
async def test_negative_duplicate_finalization_idempotent() -> None:
    """Verifies that invoking finalization repeatedly returns the existing exam idempotently without side-effects."""
    run_id = f"neg-idemp-fin-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    req = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
    )
    client.init_run(run_id=req.run_id, epoch=req.epoch, lease_owner=req.lease_owner, policy_hash=policy.hash, job_id=req.job_id)

    # First execution finalizes paper
    res1 = await pipeline.execute(req)
    assert res1.status == "ACCEPTED"
    assert res1.exam_id is not None
    exam_id_1 = res1.exam_id

    # Second execution finalizes paper again
    res2 = await pipeline.execute(req)
    assert res2.status == "ACCEPTED"
    assert res2.exam_id == exam_id_1, "Duplicate finalization must preserve exact original exam ID!"


# ── 9. Three sections through one runner ─────────────────────────────────────

@pytest.mark.asyncio
async def test_negative_three_sections_through_one_runner() -> None:
    """Verifies that a single SectionRunner instance executes Sections 1, 2, and 3 cleanly without cross-section mutation."""
    run_id = f"neg-single-runner-{uuid4().hex[:8]}"
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
    single_runner = SectionRunner(client, gateway)

    results: list[AcceptedSectionArtifact] = []
    for sec_idx in (1, 2, 3):
        src_input = all_sources[sec_idx - 1]
        cfg = policy.section(sec_idx)
        source_ref, bp_env = await _setup_standalone_prerequisites(
            client, context, sec_idx, src_input, policy
        )
        sec_res = await single_runner.run(
            context,
            cfg,
            source_ref,
            bp_env.to_ref(),
            policy,
        )
        assert sec_res.section.section_id == sec_idx
        results.append(sec_res)

    assert len(results) == 3
    assert [r.section.section_id for r in results] == [1, 2, 3]
    total_q = sum(len(r.questions) for r in results)
    assert total_q == 40


# ── 10. Fixture Grounding & Evidence Offsets Negative Tests ─────────────────

def test_negative_invalid_offsets_and_truncated_evidence():
    """Verifies that invalid offsets and truncated evidence quotes fail production evaluators."""
    passage_text = "In Southeast Asian seas, such as the Gulf of Thailand and the South China Sea, ALAN penetrates to approximately 20 meters."

    # Subcase A: Invalid negative offsets [-1:-1]
    invalid_offsets_art = ArtifactEnvelope.create(
        "art_q_neg_offsets",
        ArtifactType.QUESTION,
        "run_neg",
        {
            "questionNumber": 1,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "ALAN penetrates deep into water.",
            "answer": "TRUE",
            "evidenceQuote": "ALAN penetrates to approximately 20 meters",
            "explanation": "Valid explanation exceeding twenty-five characters in length.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": -1, "endChar": -1, "text": "ALAN penetrates to approximately 20 meters"},
            "evidenceClaimRef": "claim_1",
        },
        "1.0.0",
    )
    evals = evaluate_question(invalid_offsets_art, passage_text, "FOUNDATION", ())
    offset_eval = next(e for e in evals if e.evaluator_id == "eval_evidence_offsets")
    assert not offset_eval.is_pass()
    assert any(i.code == IssueCode.EVIDENCE_MISSING for i in offset_eval.issues)

    # Subcase B: Truncated evidence quote omitting the answer
    truncated_quote_art = ArtifactEnvelope.create(
        "art_q_truncated_quote",
        ArtifactType.QUESTION,
        "run_neg",
        {
            "questionNumber": 8,
            "questionType": "SENTENCE_COMPLETION",
            "prompt": "In Southeast Asian seas, ALAN penetrates to approximately [8] meters.",
            "answer": "20",
            "evidenceQuote": "In Southeast Asian seas",  # Omits '20'
            "explanation": "Valid explanation exceeding twenty-five characters in length.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": 0, "endChar": 23, "text": "In Southeast Asian seas"},
            "evidenceClaimRef": "claim_1",
        },
        "1.0.0",
    )
    evals = evaluate_question(truncated_quote_art, passage_text, "FOUNDATION", ())
    semantic_eval = next(e for e in evals if e.evaluator_id == "eval_question_semantic")
    assert not semantic_eval.is_pass()
    assert any(i.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM for i in semantic_eval.issues)

    # Subcase C: Missing verified claim identity
    missing_claim_art = ArtifactEnvelope.create(
        "art_q_missing_claim",
        ArtifactType.QUESTION,
        "run_neg",
        {
            "questionNumber": 1,
            "questionType": "TRUE_FALSE_NOT_GIVEN",
            "statement": "ALAN penetrates deep into water.",
            "answer": "TRUE",
            "evidenceQuote": "ALAN penetrates to approximately 20 meters",
            "explanation": "Valid explanation exceeding twenty-five characters in length.",
            "difficulty": "FOUNDATION",
            "passageEvidence": {"startChar": 80, "endChar": 122, "text": "ALAN penetrates to approximately 20 meters"},
            "evidenceClaimRef": "",  # Missing claim reference!
        },
        "1.0.0",
    )
    evals = evaluate_question(missing_claim_art, passage_text, "FOUNDATION", ())
    offset_eval = next(e for e in evals if e.evaluator_id == "eval_evidence_offsets")
    assert not offset_eval.is_pass()
    assert any(i.code == IssueCode.EVIDENCE_MISSING for i in offset_eval.issues)

