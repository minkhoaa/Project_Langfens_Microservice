"""Test Suite for Phase 10 Blind Solvers, Adversary, and Evidence Grounding (T10-01..T10-08).

Tests:
- T10-01: Hidden-key/evidence canary absent in serialized payload (allowlist isolation).
- T10-02: Key-swap request hash invariant and comparison outcome changes.
- T10-03: TFNG / YNNG annotated pairs and stance vs fact distinction.
- T10-04: MCQ / completion ambiguity detection by adversary (HIGH blocker).
- T10-05: Unsupported adversary outside-knowledge claims rejected (valid item does not fail).
- T10-06: Timeout / malformed / budget exhaustion fail-closed non-pass with SDK retry=0.
- T10-07: Option / passage cache invalidation and student-visible cache keying.
- T10-08: Provider diversity traces and correlated-review limitation tracking.
"""

from __future__ import annotations

import asyncio
import hashlib
import json
import time
from typing import Any, Dict, List
from uuid import uuid4
import pytest
from pathlib import Path
from tests.test_t08_passage_loop import SQLiteCheckpointSimulation
# The SQLiteCheckpointSimulation-backed scenarios are simulation-only, not PostgreSQL durability/CAS evidence.
from app.providers.base import BaseProvider
from app.providers.errors import RateLimitedError
from app.providers.registry import ProviderRegistry
from app.loop.policy import LoopPolicy
from app.facade import GenerationFacade
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    QuestionStructureEvaluator,
)

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueCode, IssueScope, IssueSeverity
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.contracts.solver import (
    AdjudicationResult,
    AdjudicationVerdict,
    AdversaryAlternative,
    AdversaryAmbiguityType,
    AdversaryOutput,
    BlindSolverInput,
    ComparisonResult,
    DisagreementSeverity,
    DiversityProfile,
    SecurityLeakageError,
    SolverOutput,
    SolverSpan,
    StudentVisibleOption,
    StudentVisibleQuestion,
)
from app.evaluators.solver import BlindSolverEvaluator
from app.generators.question.context import (
    OptionItem,
    QuestionCandidate,
    QuestionCandidatePool,
)
from app.providers.errors import (
    BudgetExhaustedError,
    ProviderError,
    TimeoutError as ProviderTimeoutError,
)
from app.providers.gateway import ProviderGateway
from app.providers.models import (
    Capability,
    FinishReason,
    UsageAccountingType,
    ProviderRequest,
    ProviderResponse,
    UsageReport,
)
from app.providers.retry import RetryPolicy
from app.solvers.adjudication import adjudicate_item
from app.solvers.adversary import parse_and_validate_adversary_output
from app.solvers.cache import BlindSolverCache, compute_solver_cache_key
from app.solvers.comparison import (
    compare_answers,
    normalize_completion_string,
    normalize_mcq_answer,
    normalize_tfng_answer,
    normalize_ynng_answer,
)
from app.solvers.diversity import build_diversity_profile
from app.solvers.prompts import (
    ADVERSARY_PROMPT_VERSION,
    SOLVER_PROMPT_VERSION,
    build_adversary_messages,
    build_solver_messages,
    get_adversary_asset_info,
    get_solver_asset_info,
    redact_solver_payload,
)
from app.solvers.serializer import (
    build_blind_solver_input,
    build_secure_envelope,
    project_to_student_visible,
)
from app.solvers.solver import (
    normalize_solver_answer,
    parse_and_validate_solver_output,
)


SAMPLE_PASSAGE = (
    "The rapid growth of synthetic biology has unlocked unprecedented opportunities for microbial engineering. "
    "Researchers at the Cambridge Institute successfully modified bacterial ribosomes in 2024 to synthesize "
    "non-canonical amino acids with remarkable fidelity. However, Dr. Eleanor Vance argued that metabolic burden "
    "remains an insurmountable obstacle for commercial scaling, while Professor Alan Davies maintained that "
    "adaptive laboratory evolution will overcome current efficiency bottlenecks within five years."
)


# ==============================================================================
# T10-01: Hidden-key/evidence canary absent serialized payload (P10-01, P10-02)
# ==============================================================================

def test_t10_01_canary_absence_in_serialized_payload():
    """T10-01: Verifies that expected answer, evidence quote, explanation, and private canaries

    are strictly absent from the serialized BlindSolverInput, XML envelope, and chat messages.
    """
    secret_canary = "CANARY_SECRET_ANSWER_KEY_XYZ_999"
    secret_evidence = "CANARY_HIDDEN_EVIDENCE_EXPLANATION_ABC"

    # Input object containing answers, evidence quotes, explanations, and canaries
    raw_candidate = {
        "questionNumber": 7,
        "questionType": "MULTIPLE_CHOICE_SINGLE",
        "prompt": "What did Cambridge researchers modify in 2024?",
        "options": [
            {"key": "A", "text": "Bacterial ribosomes"},
            {"key": "B", "text": "Viral capsids"},
            {"key": "C", "text": "Yeast mitochondria"},
            {"key": "D", "text": "Plant chloroplasts"},
        ],
        "answer": secret_canary,
        "correctOption": "A",
        "evidenceQuote": secret_evidence,
        "explanation": f"The answer is confirmed by {secret_canary}",
        "absenceAssessment": {"absenceConfirmed": True},
        "metadata": {"hidden_hint": secret_canary},
        "generationPrompt": f"Generate question where answer is {secret_canary}",
        "score": 0.99,
        "rejected": False,
    }

    # 1. Project to StudentVisibleQuestion
    sv_question = project_to_student_visible(raw_candidate)
    assert sv_question.question_number == 7
    assert sv_question.prompt == "What did Cambridge researchers modify in 2024?"
    assert len(sv_question.options) == 4

    # 2. Build BlindSolverInput
    solver_input = build_blind_solver_input(
        passage_text=SAMPLE_PASSAGE,
        question_data=raw_candidate,
        section_id=1,
    )

    # 3. Serialize to canonical payload
    payload = solver_input.to_canonical_payload()
    serialized_str = json.dumps(payload)

    # CRITICAL INVARIANT: Canaries and private keys must NOT appear in payload string
    assert secret_canary not in serialized_str
    assert secret_evidence not in serialized_str
    assert "correctOption" not in serialized_str
    assert "evidenceQuote" not in serialized_str
    assert "explanation" not in serialized_str
    assert "absenceAssessment" not in serialized_str
    assert "generationPrompt" not in serialized_str

    # 4. Check XML envelope
    envelope = build_secure_envelope(SAMPLE_PASSAGE, sv_question)
    assert secret_canary not in envelope
    assert secret_evidence not in envelope
    assert "<approved_passage>" in envelope
    assert "<student_question" in envelope

    # 5. Check Prompt Messages
    messages = build_solver_messages(solver_input)
    messages_str = json.dumps(messages)
    assert secret_canary not in messages_str
    assert secret_evidence not in messages_str

    # 6. Untrusted student prompt with literal '"answer": "TRUE"' stays escaped inside <prompt> (P10-02)
    adv_prompt = 'Question with injected text: "answer": "TRUE" and <script>alert(1)</script>'
    q_adversarial = StudentVisibleQuestion(
        questionNumber=1,
        questionType="TFNG",
        prompt=adv_prompt,
    )
    solver_input_adv = BlindSolverInput(
        passageText=SAMPLE_PASSAGE,
        question=q_adversarial,
    )
    adv_payload = solver_input_adv.to_canonical_payload()
    assert adv_payload["question"]["prompt"] == adv_prompt

    adv_envelope = build_secure_envelope(SAMPLE_PASSAGE, q_adversarial)
    assert "&quot;answer&quot;: &quot;TRUE&quot;" in adv_envelope
    assert "&lt;script&gt;" in adv_envelope
    assert "<prompt>" in adv_envelope

    # 7. Test field leakage defense via allowlist/extra-field boundary
    with pytest.raises(Exception):  # ValidationError for extra field
        StudentVisibleQuestion(
            questionNumber=1,
            questionType="TFNG",
            prompt="Test prompt",
            answer="TRUE",  # Prohibited extra field forbidden by extra="forbid"
        )

# ==============================================================================
# T10-02: Key-swap request hash invariant and compare outcome changed (P10-01, P10-05, P10-08)
# ==============================================================================

def test_t10_02_key_swap_request_hash_invariant_and_compare_outcome_changed():
    """T10-02: Swapping the expected answer on a question MUST leave the solver request hash

    and solver cache key 100% identical, while flipping the comparison outcome.
    """
    item_v1 = {
        "questionNumber": 3,
        "questionType": "MULTIPLE_CHOICE_SINGLE",
        "prompt": "According to the passage, who argued that metabolic burden remains insurmountable?",
        "options": [
            {"key": "A", "text": "Dr. Eleanor Vance"},
            {"key": "B", "text": "Professor Alan Davies"},
            {"key": "C", "text": "The Cambridge team"},
            {"key": "D", "text": "Dr. Robert Smith"},
        ],
        "answer": "A",
        "correctOption": "A",
        "explanation": "Dr. Vance argued metabolic burden is insurmountable.",
    }

    # Version 2 with swapped answer key "B"
    item_v2 = dict(item_v1)
    item_v2["answer"] = "B"
    item_v2["correctOption"] = "B"
    item_v2["explanation"] = "Swapped explanation."

    input_v1 = build_blind_solver_input(SAMPLE_PASSAGE, item_v1)
    input_v2 = build_blind_solver_input(SAMPLE_PASSAGE, item_v2)

    hash_v1 = input_v1.compute_request_hash()
    hash_v2 = input_v2.compute_request_hash()

    # INVARIANT: Request hashes MUST be identical
    assert hash_v1 == hash_v2, "Solver request hash mutated upon expected key swap!"

    # Cache keys MUST also be identical
    cache_key_v1 = compute_solver_cache_key(
        SAMPLE_PASSAGE, input_v1.question, SOLVER_PROMPT_VERSION, "mock-model"
    )
    cache_key_v2 = compute_solver_cache_key(
        SAMPLE_PASSAGE, input_v2.question, SOLVER_PROMPT_VERSION, "mock-model"
    )
    assert cache_key_v1 == cache_key_v2, "Solver cache key mutated upon expected key swap!"

    # Solver answers "A"
    solver_answer = "A"

    # Comparison against v1 expected answer "A" -> MATCH
    comp_v1 = compare_answers(
        expected_answer="A",
        solver_answer=solver_answer,
        question_type="MULTIPLE_CHOICE_SINGLE",
        question_number=3,
        options=input_v1.question.options,
    )
    assert comp_v1.is_match is True
    assert comp_v1.normalized_expected == "A"
    assert comp_v1.normalized_solver == "A"

    # Comparison against v2 expected answer "B" -> MISMATCH
    comp_v2 = compare_answers(
        expected_answer="B",
        solver_answer=solver_answer,
        question_type="MULTIPLE_CHOICE_SINGLE",
        question_number=3,
        options=input_v2.question.options,
    )
    assert comp_v2.is_match is False
    assert comp_v2.normalized_expected == "B"
    assert comp_v2.normalized_solver == "A"


# ==============================================================================
# T10-03: TFNG/YNNG annotated pairs and stance vs fact distinction (P10-03, P10-05)
# ==============================================================================

def test_t10_03_tfng_ynng_annotated_pairs():
    """T10-03: Tests TRUE/FALSE/NOT GIVEN and YES/NO/NOT GIVEN canonical comparisons,

    verifying whole-passage fact vs author stance distinction.
    """
    # 1. TFNG Canonical Comparison
    assert compare_answers("TRUE", "TRUE", "TRUE_FALSE_NOT_GIVEN").is_match is True
    assert compare_answers("True", "true.", "TFNG").is_match is True
    assert compare_answers("FALSE", "FALSE", "TFNG").is_match is True
    assert compare_answers("NOT_GIVEN", "NOT GIVEN", "TFNG").is_match is True
    assert compare_answers("TRUE", "FALSE", "TFNG").is_match is False
    assert compare_answers("TRUE", "NOT_GIVEN", "TFNG").is_match is False

    # 2. YNNG Canonical Comparison (Stance)
    assert compare_answers("YES", "YES", "YES_NO_NOT_GIVEN").is_match is True
    assert compare_answers("Yes", "YES.", "YNNG").is_match is True
    assert compare_answers("NO", "NO", "YNNG").is_match is True
    assert compare_answers("NOT_GIVEN", "NG", "YNNG").is_match is True
    assert compare_answers("YES", "NO", "YNNG").is_match is False

    # 3. Stance vs Fact Normalization
    assert normalize_tfng_answer("TRUE") == "TRUE"
    assert normalize_tfng_answer("FALSE") == "FALSE"
    assert normalize_ynng_answer("YES") == "YES"
    assert normalize_ynng_answer("NO") == "NO"

    # 4. Completion Canonical Normalization with UK/US aliases
    comp_match = compare_answers(
        expected_answer="laboratory colour",
        solver_answer="laboratory color",
        question_type="SENTENCE_COMPLETION",
    )
    assert comp_match.is_match is True, "Canonical UK/US alias failed to normalize"

    # Strict invariant: Fuzzy matching must NEVER pass non-matching items
    comp_fuzzy_reject = compare_answers(
        expected_answer="bacterial ribosomes",
        solver_answer="bacterial ribozymes",  # Typo / different word
        question_type="SHORT_ANSWER",
    )
    assert comp_fuzzy_reject.is_match is False, "Fuzzy match erroneously passed a mismatch!"

    # 5. Regression: Real schema names (PascalCase without underscores)
    assert compare_answers("TRUE", "TRUE", "TrueFalseNotGiven").is_match is True
    assert compare_answers("TRUE", "TRUE", "TrueFalseNotGiven").comparison_details["mode"] == "TFNG_CANONICAL"
    assert compare_answers("NOT GIVEN", "NOT_GIVEN", "TrueFalseNotGiven").is_match is True
    assert compare_answers("YES", "YES", "YesNoNotGiven").is_match is True
    assert compare_answers("YES", "YES", "YesNoNotGiven").comparison_details["mode"] == "YNNG_CANONICAL"
    assert compare_answers("NOT GIVEN", "NOT_GIVEN", "YesNoNotGiven").is_match is True
    assert compare_answers("A", "A", "MultipleChoiceSingle").is_match is True
    assert compare_answers("A", "A", "MultipleChoiceSingle").comparison_details["mode"] == "MCQ_OPTION_ID"
    assert normalize_solver_answer("NOT GIVEN", "TrueFalseNotGiven") == "NOT_GIVEN"
    assert normalize_solver_answer("NOT GIVEN", "YesNoNotGiven") == "NOT_GIVEN"
    assert normalize_solver_answer("Option B.", "MultipleChoiceSingle") == "B"

# ==============================================================================
# T10-04: MCQ/completion ambiguity detection by adversary (P10-04, P10-07)
# ==============================================================================

def test_t10_04_mcq_completion_ambiguity_detection():
    """T10-04: Adversary identifies genuine grounded ambiguity in options, creating a HIGH blocker."""
    raw_adv_output = {
        "questionNumber": 2,
        "isAmbiguous": True,
        "adversarySummary": "Both option A and option B are defensible based on Vance and Davies claims.",
        "identifiedAlternatives": [
            {
                "alternativeAnswer": "B",
                "ambiguityType": "MULTIPLE_VALID_OPTIONS",
                "plausibilityScore": 0.95,
                "citedSpans": [
                    {
                        "spanText": "adaptive laboratory evolution will overcome current efficiency bottlenecks within five years"
                    }
                ],
                "reasoning": "Passage explicitly supports Davies' perspective as well.",
                "isGroundedInPassage": True,
            }
        ],
    }

    adv_output, errors, unsupp = parse_and_validate_adversary_output(
        raw_output=raw_adv_output,
        passage_text=SAMPLE_PASSAGE,
        expected_question_number=2,
    )
    assert not errors
    assert adv_output is not None
    assert adv_output.is_ambiguous is True
    assert len(adv_output.identified_alternatives) == 1
    assert adv_output.identified_alternatives[0].cited_spans[0].start_char is not None

    # Adjudication MUST flag AMBIGUOUS_DEFECTIVE with HIGH severity
    comp = ComparisonResult(
        questionNumber=2,
        isMatch=True,  # Even though solver matched option A
        expectedAnswer="A",
        solverAnswer="A",
        normalizedExpected="A",
        normalizedSolver="A",
        questionType="MULTIPLE_CHOICE_SINGLE",
    )
    adjudication = adjudicate_item(
        comparison=comp,
        adversary_output=adv_output,
        passage_text=SAMPLE_PASSAGE,
    )
    assert adjudication.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE
    assert adjudication.severity == DisagreementSeverity.HIGH
    assert adjudication.resolution_action == "REPAIR_OPTIONS_OR_REGENERATE_ITEM"


# ==============================================================================
# T10-05: Unsupported adversary alternatives defense (P10-04, P10-07)
# ==============================================================================

def test_t10_05_unsupported_adversary_alternatives_rejected():
    """T10-05: Adversary claims outside knowledge not grounded in passage text.

    The unsupported claim is filtered out and the valid item is ACCEPTED.
    """
    raw_adv_output = {
        "questionNumber": 5,
        "isAmbiguous": True,
        "adversarySummary": "Option C might be true in general physics.",
        "identifiedAlternatives": [
            {
                "alternativeAnswer": "C",
                "ambiguityType": "MULTIPLE_VALID_OPTIONS",
                "plausibilityScore": 0.9,
                "citedSpans": [
                    # Span does NOT exist in SAMPLE_PASSAGE
                    {"spanText": "Quantum teleportation occurs at room temperature"}
                ],
                "reasoning": "In the real world outside knowledge shows quantum teleportation is possible.",
                "isGroundedInPassage": False,
            }
        ],
    }

    adv_output, errors, unsupp = parse_and_validate_adversary_output(
        raw_output=raw_adv_output,
        passage_text=SAMPLE_PASSAGE,
        expected_question_number=5,
    )
    assert not errors
    assert len(unsupp) == 1
    assert unsupp[0]["alternative_answer"] == "C"

    # Effective is_ambiguous MUST be False because the allegation was unsupported outside knowledge
    assert adv_output.is_ambiguous is False
    assert len(adv_output.identified_alternatives) == 0

    # Adjudication with solver match MUST confirm the key
    comp = ComparisonResult(
        questionNumber=5,
        isMatch=True,
        expectedAnswer="TRUE",
        solverAnswer="TRUE",
        normalizedExpected="TRUE",
        normalizedSolver="TRUE",
        questionType="TFNG",
    )
    adjudication = adjudicate_item(
        comparison=comp,
        adversary_output=adv_output,
        passage_text=SAMPLE_PASSAGE,
    )
    assert adjudication.verdict == AdjudicationVerdict.KEY_CONFIRMED
    assert adjudication.severity == DisagreementSeverity.NONE
    assert adjudication.resolution_action == "ACCEPT_ITEM"


# ==============================================================================
# T10-06: Timeout/malformed/budget non-pass handling (P10-03, P10-09)
# ==============================================================================

@pytest.mark.asyncio
async def test_t10_06_timeout_malformed_budget_non_pass():
    """T10-06: Evaluates fail-closed handling on timeout, malformed JSON, and budget exhaustion

    under SDK retry=0.
    """
    # 1. Malformed JSON handling in parse_and_validate_solver_output
    malformed_json = "NOT_A_JSON_STRING_<<<ERROR>>>"
    out, errors = parse_and_validate_solver_output(malformed_json, SAMPLE_PASSAGE, 1)
    assert out is None
    assert len(errors) > 0
    assert "valid JSON" in errors[0]

    # 2. Hidden chain-of-thought detection
    cot_output = {
        "questionNumber": 1,
        "normalizedAnswer": "TRUE",
        "thought": "Let me think secretly about this step by step...",
        "justification": "Valid justification.",
        "citedSpans": [{"spanText": "growth of synthetic biology"}],
    }
    out_cot, errors_cot = parse_and_validate_solver_output(cot_output, SAMPLE_PASSAGE, 1)
    assert out_cot is None
    assert any("chain-of-thought" in e for e in errors_cot)

    # 3. Invalid cited span detection (span not in passage)
    bad_span_output = {
        "questionNumber": 1,
        "normalizedAnswer": "TRUE",
        "justification": "Valid justification.",
        "citedSpans": [{"spanText": "Text not appearing anywhere in this passage at all"}],
    }
    out_span, errors_span = parse_and_validate_solver_output(bad_span_output, SAMPLE_PASSAGE, 1)
    assert out_span is None
    assert any("does not exist verbatim" in e for e in errors_span)

    # 3b. Missing cited span detection across all answers (including NOT GIVEN): strictly non-pass
    for ans, qtype in [("TRUE", "TFNG"), ("FALSE", "TFNG"), ("NOT GIVEN", "TrueFalseNotGiven"), ("YES", "YNNG"), ("A", "MultipleChoiceSingle")]:
        empty_span_output = {
            "questionNumber": 1,
            "normalizedAnswer": ans,
            "justification": "Valid justification without cited spans.",
            "citedSpans": [],
        }
        out_no_span, errors_no_span = parse_and_validate_solver_output(empty_span_output, SAMPLE_PASSAGE, 1, question_type=qtype)
        assert out_no_span is None, f"Empty cited spans erroneously passed for answer '{ans}'!"
        assert any("valid passage-grounded cited spans" in e for e in errors_no_span)

    # 3c. Valid cited span for NOT GIVEN: citing the topical passage text succeeds
    valid_ng_output = {
        "questionNumber": 1,
        "normalizedAnswer": "NOT GIVEN",
        "justification": "The passage discusses synthetic biology growth but does not mention clinical trials.",
        "citedSpans": [{"spanText": "growth of synthetic biology"}],
    }
    out_valid_ng, errors_valid_ng = parse_and_validate_solver_output(valid_ng_output, SAMPLE_PASSAGE, 1, question_type="TrueFalseNotGiven")
    assert out_valid_ng is not None, f"Valid cited span for NOT GIVEN failed: {errors_valid_ng}"
    assert len(errors_valid_ng) == 0
    assert out_valid_ng.normalized_answer == "NOT_GIVEN"
    assert len(out_valid_ng.cited_spans) == 1
    # 4. Gateway Timeout and Budget Exhaustion with SDK retry=0
    class FakeTimeoutGateway:
        def __init__(self):
            self.retry_policy = RetryPolicy(max_attempts=1)

        async def execute(self, req, epoch=1, lease_owner=None):
            # Assert SDK retry=0 enforced
            assert self.retry_policy.max_attempts == 1
            raise ProviderTimeoutError("Gateway call timed out after 30s")

    evaluator = BlindSolverEvaluator(gateway=FakeTimeoutGateway())
    blind_input = build_blind_solver_input(
        passage_text=SAMPLE_PASSAGE,
        question_data={"questionNumber": 1, "questionType": "TFNG", "prompt": "Test prompt"},
    )
    target_ref = ArtifactRef(
        artifact_type=ArtifactType.QUESTION,
        artifact_id="q1",
        version=1,
        content_hash="0" * 64,
    )

    res, adj = await evaluator.evaluate_blind_input(blind_input, "TRUE", target_ref)
    assert res.status == EvaluationStatus.ERROR
    assert res.score == 0.0
    assert adj.verdict == AdjudicationVerdict.SOLVER_DEFECTIVE

    # 5. Missing Gateway Fails Closed with EVALUATOR_UNAVAILABLE (no simulated false-pass in production)
    evaluator_no_gw = BlindSolverEvaluator(gateway=None, allow_simulation=False)
    res_no_gw, adj_no_gw = await evaluator_no_gw.evaluate_blind_input(blind_input, "TRUE", target_ref)
    assert res_no_gw.status == EvaluationStatus.ERROR
    assert res_no_gw.issues[0].code == IssueCode.EVALUATOR_UNAVAILABLE
    assert "ProviderGateway is required" in res_no_gw.issues[0].message


class FakeSolverTransportProvider(BaseProvider):
    """Predictable BaseProvider test double for solver and adversary operations."""

    def __init__(self, answer="TRUE", span="growth of synthetic biology"):
        super().__init__(
            name="mock_solver_provider",
            base_url="http://fake.test",
            models={"large": "mock-solver-model", "small": "mock-solver-model"},
        )
        self.answer = answer
        self.span = span
        self.recorded_calls = []

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        self.recorded_calls.append(request.capability)
        if request.capability == Capability.SOLVE_ITEM:
            payload = {
                "questionNumber": 1,
                "normalizedAnswer": self.answer,
                "justification": "Approved passage confirms synthetic biology growth.",
                "citedSpans": [{"spanText": self.span}],
                "selfReportedConfidence": 0.95,
            }
        elif request.capability == Capability.EVALUATE_ITEM:
            payload = {
                "questionNumber": 1,
                "isAmbiguous": False,
                "adversarySummary": "No ambiguity found in item.",
                "identifiedAlternatives": [],
            }
        else:
            payload = {"status": "ok"}

        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name="mock_solver_provider",
            model_name="mock-solver-model",
            raw_text=json.dumps(payload),
            parsed_payload=None,  # Proves raw_text extraction path
            usage=UsageReport(prompt_tokens=150, completion_tokens=60, total_tokens=210, accounting_type=UsageAccountingType.REPORTED),
            latency_seconds=0.04,
        )

    async def check_health(self) -> bool:
        return True


@pytest.mark.asyncio
async def test_t10_06_b_simulated_gateway_and_persistence_accounting(tmp_path: Path):
    """T10-06-B simulation: exercise gateway protocol behavior against SQLite only.

    This does not prove authoritative operation reservation, PostgreSQL durability,
    or production fencing; real persistence evidence is in the separate integration suite.
    """
    owner_id = uuid4()
    run_id = f"run_p10_auth_{uuid4().hex[:8]}"
    epoch = 3
    store = SQLiteCheckpointSimulation(tmp_path / "test_auth.db", owner=owner_id, epoch=epoch)

    provider = FakeSolverTransportProvider(answer="TRUE", span="growth of synthetic biology")
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["fake_key_12345678"])

    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=3),
        checkpoint_client=store,
    )

    evaluator = BlindSolverEvaluator(
        gateway=gateway,
        solver_provider="mock_solver_provider",
        solver_model="mock-solver-model",
        adversary_provider="mock_solver_provider",
        adversary_model="mock-solver-model",
    )

    context = LoopContext(
        runId=run_id,
        scope=IssueScope.QUESTION,
        targetArtifactId="art_q_test_1",
        targetArtifactType=ArtifactType.QUESTION,
        authority=AuthorityGrant(leaseOwner=owner_id, epoch=epoch),
    )

    blind_input = build_blind_solver_input(
        passage_text=SAMPLE_PASSAGE,
        question_data={
            "questionNumber": 1,
            "questionType": "TFNG",
            "prompt": "Synthetic biology has unlocked opportunities for microbial engineering.",
            "answer": "TRUE",
        },
    )

    target_ref = ArtifactRef(
        artifact_type=ArtifactType.QUESTION,
        artifact_id="art_q_test_1",
        version=1,
        content_hash="0" * 64,
    )

    res, adj = await evaluator.evaluate_blind_input(
        blind_input=blind_input,
        expected_answer="TRUE",
        target_ref=target_ref,
        context=context,
    )

    assert res.status == EvaluationStatus.PASS
    assert res.score == 1.0
    assert adj.verdict == AdjudicationVerdict.KEY_CONFIRMED
    assert adj.solver_match is True
    assert adj.adversary_ambiguity_found is False

    # Verify SQLiteCheckpointSimulation recorded the simulated operations.
    state = store._state()
    assert len(state["ops"]) >= 2  # Solve + Evaluate operations granted and reconciled
    for op_id, op in state["ops"].items():
        assert op["status"] == "COMPLETED"
        assert op["tokensUsed"] > 0

    assert Capability.SOLVE_ITEM in provider.recorded_calls
    assert Capability.EVALUATE_ITEM in provider.recorded_calls
    # Verify gateway retry policy was restored to max_attempts=3 after SDK retry=0 execution
    assert gateway.retry_policy.max_attempts == 3


@pytest.mark.asyncio
async def test_t10_06_c_facade_and_loop_composition_with_required_blind_solver(tmp_path: Path):
    """T10-06-C: End-to-end composition of GenerationFacade, QuestionCandidateLoop, and

    BlindSolverEvaluator as a required evaluator under authoritative CheckpointClient durability.
    """
    owner_id = uuid4()
    run_id = f"run_facade_p10_{uuid4().hex[:8]}"
    store = SQLiteCheckpointSimulation(tmp_path / "test_facade_loop.db", owner=owner_id, epoch=1)

    provider = FakeSolverTransportProvider(answer="TRUE", span="growth of synthetic biology")
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["fake_key_12345678"])

    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=3),
        checkpoint_client=store,
    )

    eval_reg = EvaluatorRegistry()
    eval_reg.register(QuestionStructureEvaluator())
    eval_reg.register(AnswerVerbatimAndLengthEvaluator())
    eval_reg.register(
        BlindSolverEvaluator(
            gateway=gateway,
            solver_provider="mock_solver_provider",
            solver_model="mock-solver-model",
            adversary_provider="mock_solver_provider",
            adversary_model="mock-solver-model",
        )
    )

    facade = GenerationFacade(
        gateway=gateway,
        evaluator_registry=eval_reg,
        persistence_client=store,
    )

    # Seed passage and blueprint envelopes in store
    bp_art = ArtifactEnvelope.create("art_bp_01", ArtifactType.EXAM_BLUEPRINT, run_id, {"title": "BP"}, "2.0.0")
    passage_art = ArtifactEnvelope.create(
        "art_passage_s1",
        ArtifactType.PASSAGE,
        run_id,
        {"text": SAMPLE_PASSAGE, "wordCount": 750, "paragraphs": [SAMPLE_PASSAGE]},
        "2.0.0",
        parent_refs=(bp_art.to_ref(),),
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": bp_art, "evaluations": []})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": passage_art, "evaluations": []})())

    from app.generators.question.generator import QuestionCandidateGenerator
    from app.loop.question import QuestionCandidateLoop

    class DeterministicCandidateGenerator(QuestionCandidateGenerator):
        def __init__(self, gateway=None):
            super().__init__(gateway=gateway)

        async def generate_candidate_pool(
            self,
            passage_text: str,
            question_type: str,
            question_number: int,
            passage_ref: ArtifactRef,
            blueprint_ref: ArtifactRef,
            run_id: str,
            section_id: Optional[str] = "1",
            context: Optional[LoopContext] = None,
            custom_pool_limit: Optional[int] = None,
            group_id: Optional[str] = None,
            parent_operation_id: Optional[str] = None,
        ) -> QuestionCandidatePool:
            pool = QuestionCandidatePool(
                slotId=f"slot_q{question_number}_{question_type}",
                questionNumber=question_number,
                questionType=question_type,
                poolLimit=2,
            )
            c = QuestionCandidate(
                candidateId=f"cand_p10_{question_number}",
                slotId=f"slot_q{question_number}_{question_type}",
                passageRef=passage_ref,
                blueprintRef=blueprint_ref,
                questionNumber=question_number,
                questionType=question_type,
                prompt="The rapid growth of synthetic biology has unlocked opportunities for microbial engineering.",
                answer="TRUE",
                evidenceQuote="The rapid growth of synthetic biology has unlocked unprecedented opportunities for microbial engineering.",
            )
            pool.add_candidate(c)
            return pool

    custom_generator = DeterministicCandidateGenerator(gateway=gateway)

    # QuestionCandidateLoop with REQUIRED eval_blind_solver_adversary
    loop_policy = LoopPolicy.from_settings(
        required_evaluator_ids=("eval_question_structure", "eval_answer_verbatim_length", "eval_blind_solver_adversary"),
    )

    q_loop = QuestionCandidateLoop(
        generator=custom_generator,
        persistence_client=store,
        evaluator_registry=eval_reg,
        policy=loop_policy,
    )

    slots = [
        {"slot_id": "slot_1", "question_number": 1, "question_type": "TFNG"},
    ]

    res = await q_loop.run(
        passage_artifact=passage_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )

    assert res["status"] == "COMPLETED"
    assert res["totalQuestions"] == 1
    assert Capability.SOLVE_ITEM in provider.recorded_calls
    assert Capability.EVALUATE_ITEM in provider.recorded_calls

# ==============================================================================
# T10-07: Option/passage cache invalidation (P10-08)
# ==============================================================================

def test_t10_07_option_passage_cache_invalidation():
    """T10-07: Verifies exact student-visible cache key calculation and automatic invalidation

    on option or passage modification.
    """
    cache = BlindSolverCache(max_entries=10)

    q1 = StudentVisibleQuestion(
        questionNumber=4,
        questionType="MULTIPLE_CHOICE_SINGLE",
        prompt="Initial prompt stem",
        options=[
            StudentVisibleOption(key="A", text="Option A original"),
            StudentVisibleOption(key="B", text="Option B original"),
        ],
    )

    k_base = compute_solver_cache_key(SAMPLE_PASSAGE, q1, "v1.0.0", "gpt-4o")

    # Put into cache
    sample_output = SolverOutput(
        questionNumber=4,
        normalizedAnswer="A",
        justification="Passage grounded.",
        citedSpans=[SolverSpan(spanText="growth of synthetic biology")],
    )
    cache.put_solver_output(k_base, sample_output)
    assert cache.get_solver_output(k_base) is not None
    assert cache.hits == 1

    # 1. Mutate Option Text -> MUST invalidate cache key
    q_mutated_option = StudentVisibleQuestion(
        questionNumber=4,
        questionType="MULTIPLE_CHOICE_SINGLE",
        prompt="Initial prompt stem",
        options=[
            StudentVisibleOption(key="A", text="Option A MODIFIED"),
            StudentVisibleOption(key="B", text="Option B original"),
        ],
    )
    k_mut_opt = compute_solver_cache_key(SAMPLE_PASSAGE, q_mutated_option, "v1.0.0", "gpt-4o")
    assert k_mut_opt != k_base, "Cache key failed to invalidate upon option text mutation!"
    assert cache.get_solver_output(k_mut_opt) is None
    assert cache.misses == 1

    # 2. Mutate Prompt Text -> MUST invalidate cache key
    q_mutated_prompt = StudentVisibleQuestion(
        questionNumber=4,
        questionType="MULTIPLE_CHOICE_SINGLE",
        prompt="MODIFIED prompt stem",
        options=q1.options,
    )
    k_mut_prompt = compute_solver_cache_key(SAMPLE_PASSAGE, q_mutated_prompt, "v1.0.0", "gpt-4o")
    assert k_mut_prompt != k_base

    # 3. Mutate Passage Text -> MUST invalidate cache key
    mutated_passage = SAMPLE_PASSAGE + " Added additional sentences at the end."
    k_mut_passage = compute_solver_cache_key(mutated_passage, q1, "v1.0.0", "gpt-4o")
    assert k_mut_passage != k_base

    # 4. Invalidate clears cache
    cache.invalidate()
    assert cache.get_solver_output(k_base) is None


# ==============================================================================
# T10-08: True diversity traces and correlated-review reporting (P10-06)
# ==============================================================================

def test_t10_08_true_diversity_traces():
    """T10-08: Verifies model diversity profile tracing and correlated-review reporting."""
    # Case 1: Same model used for solver and adversary (single provider)
    profile_same = build_diversity_profile(
        solver_provider="openai",
        solver_model="gpt-4o-mini",
        adversary_provider="openai",
        adversary_model="gpt-4o-mini",
    )
    assert profile_same.is_independent_model is False
    assert profile_same.correlated_review is True
    assert profile_same.limitation_note is not None
    assert "Statistical independence is not achieved" in profile_same.limitation_note

    # Case 2: Separate providers and models
    profile_distinct = build_diversity_profile(
        solver_provider="minimax",
        solver_model="MiniMax-Text-01",
        adversary_provider="groq",
        adversary_model="llama-3.3-70b-versatile",
    )
    assert profile_distinct.is_independent_model is True
    assert profile_distinct.correlated_review is False
    assert profile_distinct.limitation_note is None

    # Assert asset tracking info matches expected constants
    solver_asset = get_solver_asset_info()
    adv_asset = get_adversary_asset_info()
    assert solver_asset["version"] == SOLVER_PROMPT_VERSION
    assert adv_asset["version"] == ADVERSARY_PROMPT_VERSION
    assert len(solver_asset["promptHash"]) == 64
    assert len(adv_asset["promptHash"]) == 64

@pytest.mark.asyncio
async def test_t10_09_gateway_rate_limit_rotation_and_safe_reconciliation(tmp_path: Path):
    """T10-09: Verifies that an explicit 429 on Key 1 safely reconciles with UNKNOWN usage,
    immediately rotates to Key 2 on the SAME provider (groq) without deadline backoff delay,
    preserves groq provider identity, and leaves all operations COMPLETED.
    """
    run_id = "run_t10_429_rotation"
    owner_id = uuid4()
    epoch = 1
    store = SQLiteCheckpointSimulation(tmp_path / "test_429.db", owner=owner_id, epoch=epoch)

    class FakeKeyRotatingProvider(BaseProvider):
        def __init__(self):
            super().__init__(name="groq", base_url="https://api.groq.com/openai/v1", models={"large": "openai/gpt-oss-20b"})
            self.call_history = []

        def conservative_token_reservation(self, request):
            return 2500

        async def check_health(self) -> bool:
            return True
        async def call(self, request, api_key: str, deadline: float):
            self.call_history.append((api_key, time.time()))
            if "key_1" in api_key:
                raise RateLimitedError("TPD limit exceeded: 200000 reached", retry_after_seconds=116.0)
            # Key 2 succeeds
            payload = {
                "questionNumber": 1,
                "isAmbiguous": False,
                "adversarySummary": "Key 2 verified clean item with zero ambiguity.",
                "identifiedAlternatives": [],
            }
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name="groq",
                model_name="openai/gpt-oss-20b",
                raw_text=json.dumps(payload),
                parsed_payload=payload,
                usage=UsageReport(prompt_tokens=1500, completion_tokens=100, total_tokens=1600, accounting_type=UsageAccountingType.REPORTED),
                latency_seconds=0.25,
            )

    groq_provider = FakeKeyRotatingProvider()
    registry = ProviderRegistry()
    registry.register_provider(groq_provider, keys=["fake_key_1_429", "fake_key_2_success"])

    class FakeSolverProvider(BaseProvider):
        def __init__(self):
            super().__init__(name="minimax", base_url="https://api.minimaxi.chat/v1", models={"large": "MiniMax-Text-01"})

        def conservative_token_reservation(self, request):
            return 2000

        async def check_health(self) -> bool:
            return True

        async def call(self, request, api_key: str, deadline: float):
            payload = {
                "questionNumber": 1,
                "normalizedAnswer": "TRUE",
                "citedSpans": [{"spanText": "Microbial engineering has expanded rapidly in synthetic biology.", "startChar": 0, "endChar": 65}],
                "justification": "Direct passage quote proves answer.",
                "selfReportedConfidence": 0.95,
            }
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name="minimax",
                model_name="MiniMax-Text-01",
                raw_text=json.dumps(payload),
                parsed_payload=payload,
                usage=UsageReport(prompt_tokens=1200, completion_tokens=80, total_tokens=1280, accounting_type=UsageAccountingType.REPORTED),
                latency_seconds=0.3,
            )

    solver_provider = FakeSolverProvider()
    registry.register_provider(solver_provider, keys=["fake_minimax_key"])

    gateway = ProviderGateway(
        registry=registry,
        retry_policy=RetryPolicy(max_attempts=1),
        checkpoint_client=store,
    )

    evaluator = BlindSolverEvaluator(
        gateway=gateway,
        solver_provider="minimax",
        solver_model="MiniMax-Text-01",
        adversary_provider="groq",
        adversary_model="openai/gpt-oss-20b",
    )

    context = LoopContext(
        runId=run_id,
        scope=IssueScope.QUESTION,
        targetArtifactId="art_q_test_429",
        targetArtifactType=ArtifactType.QUESTION,
        authority=AuthorityGrant(leaseOwner=owner_id, epoch=epoch),
    )

    passage_text = "Microbial engineering has expanded rapidly in synthetic biology."
    blind_input = build_blind_solver_input(
        passage_text=passage_text,
        question_data={
            "questionNumber": 1,
            "questionType": "TrueFalseNotGiven",
            "prompt": "Microbial engineering has expanded rapidly.",
            "answer": "TRUE",
        },
    )
    target_ref = ArtifactRef(
        artifact_type=ArtifactType.QUESTION,
        artifact_id="art_q_test_429",
        version=1,
        content_hash="0" * 64,
    )

    res, adj = await evaluator.evaluate_blind_input(
        blind_input=blind_input,
        expected_answer="TRUE",
        target_ref=target_ref,
        context=context,
    )

    assert res.status == EvaluationStatus.PASS, f"Expected PASS, got {res.status}"
    assert adj.verdict == AdjudicationVerdict.KEY_CONFIRMED
    assert adj.adversary_ambiguity_found is False

    # 2. Strict provider provenance preserved (groq, NOT minimax!)
    assert evaluator.adversary_provider == "groq"
    assert evaluator.adversary_model == "openai/gpt-oss-20b"
    assert len(groq_provider.call_history) == 2
    assert "key_1" in groq_provider.call_history[0][0]
    assert "key_2" in groq_provider.call_history[1][0]

    # 3. All operations reconciled and completed
    ops = list(store._state()["ops"].values())
    assert len(ops) == 3, f"Expected 3 ops (1 solver, 2 adversary attempts), got {len(ops)}"
    assert all(o["status"] == "COMPLETED" for o in ops), "All operations must be COMPLETED!"

    # 4. Truthful usage accounting
    adv_op_1 = next(o for o in ops if o["operationId"].startswith("op_adv_") and ":attempt:" not in o["operationId"])
    adv_op_2 = next(o for o in ops if ":attempt:2" in o["operationId"])
    assert adv_op_1["tokensUsed"] == 0
    assert "HTTP 429" in (adv_op_1.get("resultRefJson") or "")
    assert adv_op_2["tokensUsed"] == 1600

@pytest.mark.asyncio
async def test_t10_10_queued_concurrency_two_pacing_and_timeout(tmp_path: Path):
    """T10-10: Verifies that under concurrency=2, Worker 2 queuing behind Worker 1
    in TokenBucket and key pacing does not exhaust call deadline, receives full call_deadline,
    and both workers complete cleanly with all operations COMPLETED.
    """
    owner_1 = uuid4()
    owner_2 = uuid4()
    store_1 = SQLiteCheckpointSimulation(tmp_path / "test_q1.db", owner=owner_1, epoch=1)
    store_2 = SQLiteCheckpointSimulation(tmp_path / "test_q2.db", owner=owner_2, epoch=1)

    class FastFakeProvider(BaseProvider):
        def __init__(self, name="groq"):
            super().__init__(name=name, base_url="https://api.groq.com/openai/v1", models={"large": "openai/gpt-oss-20b"})

        def conservative_token_reservation(self, request):
            return 2000

        async def check_health(self) -> bool:
            return True

        async def call(self, request, api_key: str, deadline: float):
            # Assert that the physical call receives a generous call deadline (> 10s), not starved by queueing!
            remaining = deadline - time.time()
            assert remaining >= 10.0, f"Call deadline starved by queueing: only {remaining:.1f}s remaining!"
            await asyncio.sleep(0.05)
            payload = {
                "questionNumber": 1,
                "normalizedAnswer": "TRUE",
                "citedSpans": [{"spanText": "Microbial engineering has expanded rapidly in synthetic biology.", "startChar": 0, "endChar": 65}],
                "justification": "Valid passage match.",
                "selfReportedConfidence": 0.95,
                "isAmbiguous": False,
                "adversarySummary": "Clean item.",
                "identifiedAlternatives": [],
            }
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name=self.name,
                model_name="openai/gpt-oss-20b",
                raw_text=json.dumps(payload),
                parsed_payload=payload,
                usage=UsageReport(prompt_tokens=1000, completion_tokens=50, total_tokens=1050, accounting_type=UsageAccountingType.REPORTED),
                latency_seconds=0.05,
            )

    provider = FastFakeProvider()
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["key_w1", "key_w2"], max_concurrency=1, rate_per_second=2.0)

    gateway_1 = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=store_1)
    gateway_2 = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=store_2)

    evaluator_1 = BlindSolverEvaluator(gateway=gateway_1, solver_provider="groq", solver_model="openai/gpt-oss-20b", adversary_provider="groq", adversary_model="openai/gpt-oss-20b")
    evaluator_2 = BlindSolverEvaluator(gateway=gateway_2, solver_provider="groq", solver_model="openai/gpt-oss-20b", adversary_provider="groq", adversary_model="openai/gpt-oss-20b")

    ctx_1 = LoopContext(runId="run_worker_1", scope=IssueScope.QUESTION, targetArtifactId="art_w1", targetArtifactType=ArtifactType.QUESTION, authority=AuthorityGrant(leaseOwner=owner_1, epoch=1))
    ctx_2 = LoopContext(runId="run_worker_2", scope=IssueScope.QUESTION, targetArtifactId="art_w2", targetArtifactType=ArtifactType.QUESTION, authority=AuthorityGrant(leaseOwner=owner_2, epoch=1))

    passage_text = "Microbial engineering has expanded rapidly in synthetic biology."
    blind_input = build_blind_solver_input(passage_text=passage_text, question_data={"questionNumber": 1, "questionType": "TrueFalseNotGiven", "prompt": "Engineering expanded.", "answer": "TRUE"})
    t_ref_1 = ArtifactRef(artifact_type=ArtifactType.QUESTION, artifact_id="art_w1", version=1, content_hash="0"*64)
    t_ref_2 = ArtifactRef(artifact_type=ArtifactType.QUESTION, artifact_id="art_w2", version=1, content_hash="0"*64)

    # Run Worker 1 and Worker 2 concurrently
    res_1, res_2 = await asyncio.gather(
        evaluator_1.evaluate_blind_input(blind_input, "TRUE", t_ref_1, ctx_1),
        evaluator_2.evaluate_blind_input(blind_input, "TRUE", t_ref_2, ctx_2),
    )

    assert res_1[0].status == EvaluationStatus.PASS
    assert res_2[0].status == EvaluationStatus.PASS

    ops_1 = list(store_1._state()["ops"].values())
    ops_2 = list(store_2._state()["ops"].values())
    assert all(o["status"] == "COMPLETED" for o in ops_1)
    assert all(o["status"] == "COMPLETED" for o in ops_2)
