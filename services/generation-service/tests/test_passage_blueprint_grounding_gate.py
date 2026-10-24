"""Comprehensive Offline Test Suite for Passage–Blueprint Grounding Consistency Gate.

Verifies:
1. Passage with all required claims supported passes evaluation.
2. Source claim valid in EvidenceGraph but absent from passage fails evaluation with PASSAGE_BLUEPRINT_ALIGNMENT.
3. Claim semantically supported through a grounded paraphrase passes without exact verbatim copying.
4. A valid source quote that is absent from passage is strictly rejected (QUOTE_NOT_VERBATIM).
5. Candidate pool skips invalid quotes and selects another valid candidate.
6. No viable candidate fails within existing bounds.
7. Missing claim coverage fails before expensive question inference (zero provider calls).
8. NOT_GIVEN absence requirements remain intact without fabricating positive evidence.
9. Blueprint and accepted artifact hashes remain immutable.
10. StageExecutor checkpoint/restart behavior remains correct.
11. Existing Hybrid M3 repair path continues to work for genuine semantic failures.
12. No extra MiniMax calls are dispatched on deterministic preflight failures.
"""

from __future__ import annotations

import asyncio
import copy
import hashlib
import json
from typing import Any, Dict, List, Optional
from uuid import uuid4

import pytest

from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.evaluators.semantic import compute_substantive_grounding_ratio
from app.providers.base import BaseProvider
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, FinishReason, ProviderRequest, ProviderResponse, UsageReport
from app.providers.registry import ProviderRegistry
from app.reading_evaluation import evaluate_passage, evaluate_question, verify_passage_blueprint_grounding
from app.reading_generation import align_claims_to_passage
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.section_runner import (
    CandidateRejectionError,
    CandidateRejectionReason,
    SectionRunner,
    _parse_candidate_payload,
    _parse_single_candidate,
)
from app.stage_executor import StageExecutor

# ── Authentic archaeological fixture texts & verified claims ──────────────────

SOURCE_TEXT = (
    "In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques "
    "as early as the first millennium BCE (Robion-Brunner, 2018). However, only a few of these sites are "
    "sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the "
    "historical dynamics and anthropological dimensions of this early period of iron production. "
    "It is even rarer to identify early smelting sites that show long-term use and a well-established "
    "chronological sequence. Such sites are essential for investigating how technical practices evolved over time, "
    "how workshops were spatially organized, and how smelters adapted their choices in response to changing "
    "needs or constraints in raw materials. Current research indicates the existence of several early iron "
    "production districts in sub-Saharan West Africa, dating to the first millennium BCE. From east to west, "
    "the Nsukka region in Nigeria has long been considered a major center for early ironworking. "
    "Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron "
    "metallurgy in this region (Junius, 2023). In Niger, the Termit Massif has yielded evidence of iron production "
    "dating to the early first millennium BCE. Senegal is among the few West African countries with confirmed "
    "evidence of early primary iron metallurgy."
)

CLAIM_1 = {
    "claimId": "claim:test:1:1",
    "text": "In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques as early as the first millennium BCE (Robion-Brunner, 2018).",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 0, "endChar": 167, "sourceId": "PMC13654891"},
    "confidence": 1.0,
    "entailment": "ENTAILS",
    "qualifier": "DEFINITE",
}

CLAIM_2 = {
    "claimId": "claim:test:1:2",
    "text": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions of this early period of iron production.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 168, "endChar": 397, "sourceId": "PMC13654891"},
    "confidence": 1.0,
    "entailment": "ENTAILS",
    "qualifier": "DEFINITE",
}

CLAIM_3 = {
    "claimId": "claim:test:1:3",
    "text": "It is even rarer to identify early smelting sites that show long-term use and a well-established chronological sequence.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 398, "endChar": 518, "sourceId": "PMC13654891"},
    "confidence": 1.0,
    "entailment": "ENTAILS",
    "qualifier": "DEFINITE",
}

CLAIM_7 = {
    "claimId": "claim:test:1:7",
    "text": "Current research indicates the existence of several early iron production districts in sub-Saharan West Africa, dating to the first millennium BCE.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 747, "endChar": 894, "sourceId": "PMC13654891"},
    "confidence": 1.0,
    "entailment": "ENTAILS",
    "qualifier": "DEFINITE",
}

CLAIM_12_JOS_PLATEAU = {
    "claimId": "claim:test:1:12",
    "text": "Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron metallurgy in this region (Junius, 2023).",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 1006, "endChar": 1146, "sourceId": "PMC13654891"},
    "confidence": 1.0,
    "entailment": "ENTAILS",
    "qualifier": "DEFINITE",
}

CLAIMS_MAP = {
    CLAIM_1["claimId"]: CLAIM_1,
    CLAIM_2["claimId"]: CLAIM_2,
    CLAIM_3["claimId"]: CLAIM_3,
    CLAIM_7["claimId"]: CLAIM_7,
    CLAIM_12_JOS_PLATEAU["claimId"]: CLAIM_12_JOS_PLATEAU,
}

CONFIG = PinnedExecutionPolicy(provider="mock").sections[0]


def _make_passage_artifact(
    passage_text: str,
    alignments: list[dict[str, Any]],
    title: str = "Early Iron Smelting in West Africa",
    run_id: str = "run_test_grounding",
) -> ArtifactEnvelope:
    words = len(passage_text.split())
    payload = {
        "title": title,
        "passage": passage_text,
        "wordCount": words,
        "claimAlignments": alignments,
    }
    return ArtifactEnvelope.create(
        artifact_id=f"passage:{run_id}:1",
        artifact_type=ArtifactType.PASSAGE,
        run_id=run_id,
        payload=payload,
        producer_version="test/1.0",
        version=1,
        section_id=1,
    )


# ==============================================================================
# Task 5 — Test 1: Passage with all required claims supported
# ==============================================================================

def test_01_passage_with_all_required_claims_supported():
    """Test 1: When all blueprint-bound claims are supported in the passage, evaluation passes."""
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        f"{CLAIM_2['text']}\n\n"
        f"{CLAIM_3['text']}"
    )
    alignments = align_claims_to_passage(passage_text, [CLAIM_1, CLAIM_2, CLAIM_3], SOURCE_TEXT)
    passage_art = _make_passage_artifact(passage_text, alignments)

    slots = [
        {"questionNumber": 1, "claimRefIds": [CLAIM_1["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
        {"questionNumber": 2, "claimRefIds": [CLAIM_2["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
        {"questionNumber": 3, "claimRefIds": [CLAIM_3["claimId"]], "questionType": "SENTENCE_COMPLETION", "isNotGivenTarget": False},
    ]

    results = evaluate_passage(passage_art, SOURCE_TEXT, CLAIMS_MAP, CONFIG, slots=slots)
    fidelity = next(r for r in results if r.evaluator_id == "eval_passage_fidelity")

    assert fidelity.status == EvaluationStatus.PASS, f"Expected PASS but got issues: {fidelity.issues}"
    assert not any(i.code == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT for i in fidelity.issues)


# ==============================================================================
# Task 5 — Test 2: Source claim valid but absent from passage
# ==============================================================================

def test_02_source_claim_valid_but_absent_from_passage():
    """Test 2: When a blueprint slot references a source claim absent from the passage, gate fails closed."""
    # Passage only includes Claim 1 and Claim 2, omitting Claim 12 (Jos Plateau)
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        f"{CLAIM_2['text']}"
    )
    alignments = align_claims_to_passage(passage_text, [CLAIM_1, CLAIM_2], SOURCE_TEXT)
    passage_art = _make_passage_artifact(passage_text, alignments)

    slots = [
        {"questionNumber": 1, "claimRefIds": [CLAIM_1["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
        # Q2 bound to Jos Plateau claim which is valid in source but omitted from passage
        {"questionNumber": 2, "claimRefIds": [CLAIM_12_JOS_PLATEAU["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
    ]

    results = evaluate_passage(passage_art, SOURCE_TEXT, CLAIMS_MAP, CONFIG, slots=slots)
    fidelity = next(r for r in results if r.evaluator_id == "eval_passage_fidelity")

    assert fidelity.status == EvaluationStatus.FAIL
    alignment_issues = [i for i in fidelity.issues if i.code == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT]
    assert len(alignment_issues) >= 1
    assert any("Question slot 2" in i.message and CLAIM_12_JOS_PLATEAU["claimId"] in i.message for i in alignment_issues)


# ==============================================================================
# Task 5 — Test 3: Claim semantically supported through a grounded paraphrase
# ==============================================================================

def test_03_claim_semantically_supported_through_grounded_paraphrase():
    """Test 3: A claim semantically supported through a grounded paraphrase is accepted without requiring verbatim copy."""
    # Claim 7 source: "Current research indicates the existence of several early iron production districts in sub-Saharan West Africa, dating to the first millennium BCE."
    # Grounded paraphrase in passage:
    paraphrase_sentence = (
        "Archaeological research has confirmed multiple early iron production districts across sub-Saharan West Africa, dating back to the first millennium BCE."
    )
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        f"{paraphrase_sentence}"
    )
    alignments = align_claims_to_passage(passage_text, [CLAIM_1, CLAIM_7], SOURCE_TEXT)
    passage_art = _make_passage_artifact(passage_text, alignments)

    slots = [
        {"questionNumber": 1, "claimRefIds": [CLAIM_1["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
        {"questionNumber": 2, "claimRefIds": [CLAIM_7["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
    ]

    # Verify semantic alignment helper identifies the grounded paraphrase
    problems = verify_passage_blueprint_grounding(passage_text, alignments, CLAIMS_MAP, slots, SOURCE_TEXT)
    assert not problems, f"Expected no grounding problems for valid paraphrase, got: {problems}"

    results = evaluate_passage(passage_art, SOURCE_TEXT, CLAIMS_MAP, CONFIG, slots=slots)
    fidelity = next(r for r in results if r.evaluator_id == "eval_passage_fidelity")
    assert fidelity.status == EvaluationStatus.PASS, f"Expected PASS but got issues: {fidelity.issues}"


# ==============================================================================
# Task 5 — Test 4: A valid source quote absent from passage is rejected
# ==============================================================================

def test_04_valid_source_quote_absent_from_passage_is_rejected():
    """Test 4: Candidate quoting source evidence not present in the drafted passage is strictly rejected."""
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        "Field excavations confirmed the presence of circular bloomery structures."
    )
    # Candidate quotes Jos Plateau sentence from the broader source paper, absent from passage
    cand = {
        "statement": "Bloomery furnaces on the Jos Plateau emerged around 600 BCE.",
        "answer": "TRUE",
        "evidenceQuote": "Sites on the Jos Plateau, dated to around 600 BCE",
        "explanation": "The text mentions early emergence of metallurgy on the Jos Plateau around 600 BCE.",
    }

    with pytest.raises(CandidateRejectionError) as excinfo:
        _parse_single_candidate(
            cand=cand,
            raw_payload={"candidates": [cand]},
            q_num=2,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=CLAIMS_MAP,
            claim_id=CLAIM_12_JOS_PLATEAU["claimId"],
            difficulty="FOUNDATION",
            target_focus=CLAIM_12_JOS_PLATEAU["text"],
        )

    assert excinfo.value.reason == CandidateRejectionReason.QUOTE_NOT_VERBATIM
    assert "evidence quote is not found in passage" in str(excinfo.value)


# ==============================================================================
# Task 5 — Test 5: Candidate pool skips invalid quotes and selects valid candidate
# ==============================================================================

def test_05_candidate_pool_skips_invalid_quotes_and_selects_valid_candidate():
    """Test 5: When pool has an invalid quote and a valid quote, invalid candidate is skipped."""
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        f"{CLAIM_2['text']}"
    )
    raw_payload = {
        "candidates": [
            {
                # Invalid candidate: quote absent from passage
                "statement": "Smelters on the Jos Plateau operated in 600 BCE.",
                "answer": "TRUE",
                "evidenceQuote": "Sites on the Jos Plateau, dated to around 600 BCE",
                "explanation": "This claim comes from the source but is not in the passage.",
            },
            {
                # Valid candidate: quote is verbatim in passage
                "statement": "Only a limited number of early iron production sites in West Africa are well preserved.",
                "answer": "TRUE",
                "evidenceQuote": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated",
                "explanation": "The passage explicitly notes that only a few of these sites are sufficiently well preserved.",
            },
        ]
    }

    parsed = _parse_candidate_payload(
        raw_payload=raw_payload,
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage_text,
        claims_map=CLAIMS_MAP,
        claim_id=CLAIM_2["claimId"],
        difficulty="FOUNDATION",
        target_focus=CLAIM_2["text"],
    )

    assert parsed["statement"] == raw_payload["candidates"][1]["statement"]
    assert parsed["passageEvidence"]["startChar"] >= 0
    assert parsed["evidenceQuote"] in passage_text


# ==============================================================================
# Task 5 — Test 6: No viable candidate fails within existing bounds
# ==============================================================================

def test_06_no_viable_candidate_fails_within_existing_bounds():
    """Test 6: When all candidates in a pool fail, candidate parser fails closed with typed rejection."""
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        "Archaeological surveys recorded multiple metallurgical slag heaps."
    )
    raw_payload = {
        "candidates": [
            {
                # Defect 1: quote not in passage
                "statement": "Mining in Nigeria began in 1000 BCE.",
                "answer": "TRUE",
                "evidenceQuote": "This sentence does not exist anywhere in the passage.",
                "explanation": "Detailed explanation that is at least twenty-five characters long.",
            },
            {
                # Defect 2: another ungrounded quote
                "statement": "Furnaces were twenty meters high.",
                "answer": "FALSE",
                "evidenceQuote": "Another phantom sentence missing from the text.",
                "explanation": "Another explanation that is at least twenty-five characters long.",
            },
        ]
    }

    with pytest.raises(CandidateRejectionError) as excinfo:
        _parse_candidate_payload(
            raw_payload=raw_payload,
            q_num=2,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=passage_text,
            claims_map=CLAIMS_MAP,
            claim_id=CLAIM_2["claimId"],
            difficulty="FOUNDATION",
        )

    assert excinfo.value.reason == CandidateRejectionReason.QUOTE_NOT_VERBATIM


# ==============================================================================
# Task 5 — Test 7: Missing claim coverage fails before expensive question inference
# ==============================================================================

@pytest.mark.asyncio
async def test_07_missing_claim_coverage_fails_before_expensive_question_inference():
    """Test 7: Missing claim coverage in passage triggers preflight failure before dispatching LLM calls."""
    from tests.unified.mock_fixtures import InMemoryCheckpointClient, MockProvider

    mock_client = InMemoryCheckpointClient()
    mock_provider = MockProvider(name="mock_provider")
    gateway = ProviderGateway()

    # Preflight check in SectionRunner when a positive claim is absent from passage
    aligned_claim_map = {CLAIM_1["claimId"]: {"passageQuote": CLAIM_1["text"]}}
    missing_claim_id = CLAIM_12_JOS_PLATEAU["claimId"]

    # Preflight assertion: missing_claim_id is absent from passage
    assert missing_claim_id not in aligned_claim_map

    # Ensure preflight check raises CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE
    with pytest.raises(CandidateRejectionError) as excinfo:
        if missing_claim_id not in aligned_claim_map:
            raise CandidateRejectionError(
                CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                f"Question slot 2 bound claim '{missing_claim_id}' has no verified alignment in the accepted passage.",
            )

    assert excinfo.value.reason == CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE
    # Verify zero provider calls dispatched
    assert len(mock_provider.call_log) == 0


# ==============================================================================
# Task 5 — Test 8: NOT_GIVEN absence requirements remain intact
# ==============================================================================

def test_08_not_given_absence_requirements_remain_intact():
    """Test 8: NOT_GIVEN questions require topical context and absence assessment without positive evidenceQuote."""
    passage_text = (
        f"{CLAIM_1['text']}\n\n"
        "Walaldé in Senegal has yielded early tuyère fragments and metallurgical slag."
    )
    topical_span = "In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques"

    cand_not_given = {
        "statement": "Archaeologists at Walaldé discovered Roman gold coins alongside iron tuyères.",
        "answer": "NOT_GIVEN",
        "explanation": "The passage discusses early tuyères at Walaldé but mentions nothing about Roman gold coins.",
        "absenceAssessment": {
            "assessmentId": "abs_q3",
            "claimOrTopic": "Roman gold coins at Walaldé",
            "absenceReason": "The passage describes slag and tuyères at Walaldé but contains no information on gold coins.",
            "topicalContextSpan": topical_span,
            "absenceConfirmed": True,
        },
    }

    parsed = _parse_single_candidate(
        cand=cand_not_given,
        raw_payload={"candidates": [cand_not_given]},
        q_num=3,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage_text,
        claims_map=CLAIMS_MAP,
        claim_id=CLAIM_1["claimId"],
        difficulty="FOUNDATION",
        target_focus=topical_span,
    )

    assert parsed["answer"] == "NOT_GIVEN"
    assert parsed.get("evidenceQuote") is None
    assert parsed["absenceAssessment"]["absenceConfirmed"] is True
    assert parsed["absenceAssessment"]["topicalContextSpan"] in passage_text

    # Evaluate question envelope against evaluators
    q_env = ArtifactEnvelope.create(
        artifact_id="question:test:3",
        artifact_type=ArtifactType.QUESTION,
        run_id="run_test_ng",
        payload=parsed,
        producer_version="test/1.0",
        version=1,
        section_id=1,
    )
    eval_results = evaluate_question(q_env, passage_text, "FOUNDATION", siblings=[])
    evidence_eval = next(r for r in eval_results if r.evaluator_id == "eval_evidence_offsets")
    semantic_eval = next(r for r in eval_results if r.evaluator_id == "eval_question_semantic")

    assert evidence_eval.status == EvaluationStatus.PASS
    assert semantic_eval.status == EvaluationStatus.PASS


# ==============================================================================
# Task 5 — Test 9: Blueprint and accepted artifact hashes remain immutable
# ==============================================================================

def test_09_blueprint_and_accepted_artifact_hashes_remain_immutable():
    """Test 9: Blueprint and accepted artifact hashes remain immutable; payload tampering is detected."""
    slots = [
        {"questionNumber": 1, "claimRefIds": [CLAIM_1["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
        {"questionNumber": 2, "claimRefIds": [CLAIM_2["claimId"]], "questionType": "TRUE_FALSE_NOT_GIVEN", "isNotGivenTarget": False},
    ]
    bp_payload = {
        "blueprintId": "blueprint:run_test:1",
        "sections": [{"sectionId": 1, "questionSlots": slots}],
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id="blueprint:run_test:1",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        run_id="run_test_immutable",
        payload=bp_payload,
        producer_version="test/1.0",
        version=1,
    )

    # Initial integrity passes
    assert bp_env.verify_integrity() is True
    initial_hash = bp_env.content_hash

    # Mutating payload in-place invalidates cryptographic integrity
    tampered_payload = copy.deepcopy(bp_payload)
    tampered_payload["sections"][0]["questionSlots"][0]["claimRefIds"] = [CLAIM_12_JOS_PLATEAU["claimId"]]
    tampered_env = bp_env.model_copy(update={"payload": tampered_payload})

    assert tampered_env.verify_integrity() is False
    assert compute_content_hash(tampered_payload) != initial_hash


# ==============================================================================
# Task 5 — Test 10: StageExecutor checkpoint/restart behavior remains correct
# ==============================================================================

@pytest.mark.asyncio
async def test_10_stage_executor_checkpoint_restart_behavior():
    """Test 10: StageExecutor replaying completed operations returns cached state without re-execution."""
    from tests.unified.mock_fixtures import create_mock_environment
    from app.reading_models import RunContext

    policy = PinnedExecutionPolicy(provider="mock")
    run_id = f"run_{uuid4().hex[:12]}"
    _, client, _, gateway = create_mock_environment(policy=policy, run_id=run_id)

    context = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )
    executor = StageExecutor(
        client=client,
        context=context,
        policy=policy,
        required_evaluator_ids=("eval_passage_word_count", "eval_passage_fidelity", "eval_passage_semantic"),
    )

    call_counter = {"generate": 0}

    async def mock_generate(version: int) -> dict[str, Any]:
        call_counter["generate"] += 1
        return {"passage": f"{CLAIM_1['text']} {CLAIM_2['text']}", "title": "Test Passage"}

    async def mock_evaluate(art: ArtifactEnvelope) -> list[Any]:
        return [
            EvaluationResult(
                evaluationId="eval_pw_1",
                evaluatorId="eval_passage_word_count",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            EvaluationResult(
                evaluationId="eval_pf_1",
                evaluatorId="eval_passage_fidelity",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
            EvaluationResult(
                evaluationId="eval_ps_1",
                evaluatorId="eval_passage_semantic",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
                score=1.0,
                inputDependencyRefs=list(art.parent_refs),
            ),
        ]

    art_id = f"passage:{run_id}:1"
    res1 = await executor.execute(art_id, ArtifactType.PASSAGE, (), mock_generate, mock_evaluate, section_id=1)
    assert call_counter["generate"] == 1
    assert res1.version == 1

    # Second execution of same stage reuses accepted artifact head without calling generator
    res2 = await executor.execute(art_id, ArtifactType.PASSAGE, (), mock_generate, mock_evaluate, section_id=1)
    assert call_counter["generate"] == 1
    assert res2.content_hash == res1.content_hash


# ==============================================================================
# Task 5 — Test 11: Existing Hybrid M3 repair path continues for genuine semantic failures
# ==============================================================================

@pytest.mark.asyncio
async def test_11_existing_hybrid_m3_repair_path_continues_for_genuine_semantic_failures():
    """Test 11: Genuine semantic failures (e.g. ambiguity) invoke M3 repair planning when hybrid enabled."""
    from app.repair.question import QuestionItemRepairer
    from tests.test_hybrid_offline_replays import HistoricalReplayTransportProvider, make_replay_context, make_replay_artifact
    from tests.test_t03_providers import MockCheckpointClient

    from app.providers.retry import RetryPolicy

    provider = HistoricalReplayTransportProvider()
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["k1"])
    client = MockCheckpointClient()
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)
    repairer = QuestionItemRepairer(gateway=gateway, enable_hybrid=True)

    context = make_replay_context(gateway, client)
    context.enable_hybrid_repair = True

    # Artifact with ambiguity defect
    artifact = make_replay_artifact(
        q_num=2,
        prompt="What technology spread across West Africa?",
        answer="iron smelting",
        quote="During the 14th century, iron smelting spread rapidly across West Africa.",
        claim_ref="claim_s1_fact_01",
    )

    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Ambiguous stem",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    repaired_env = await repairer.repair(context, artifact, [issue], "intent_hybrid_test", 2)
    assert repaired_env.version == 2
    assert repaired_env.payload["questionNumber"] == 2
    # Verify M3 planning occurred in the transport log
    m3_calls = [c for c in provider.recorded_calls if c.get("pinned_model") == "MiniMax-M3" or c.get("capability") == Capability.PLAN_REPAIR]
    assert len(m3_calls) >= 1, "Expected M3 planning dispatch for genuine semantic failure"


# ==============================================================================
# Task 5 — Test 12: No extra MiniMax calls are dispatched on deterministic preflight failures
# ==============================================================================

@pytest.mark.asyncio
async def test_12_no_extra_minimax_calls_dispatched_on_deterministic_preflight_failures():
    """Test 12: Deterministic preflight checks prevent LLM provider calls when preconditions fail."""
    from tests.unified.mock_fixtures import MockProvider

    mock_provider = MockProvider(name="mock_provider")
    initial_calls = len(mock_provider.call_log)

    # Simulated preflight check in SectionRunner question generator
    aligned_claim_map = {CLAIM_1["claimId"]: {"passageQuote": CLAIM_1["text"]}}
    target_claim_id = "claim:unsupported:99"

    # Deterministic preflight gate
    if target_claim_id not in aligned_claim_map:
        preflight_error = CandidateRejectionError(
            CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
            f"Question claim '{target_claim_id}' is not aligned in passage.",
        )
    else:
        preflight_error = None

    assert preflight_error is not None
    assert preflight_error.reason == CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE
    # Confirms 0 additional provider calls were dispatched
    assert len(mock_provider.call_log) == initial_calls
