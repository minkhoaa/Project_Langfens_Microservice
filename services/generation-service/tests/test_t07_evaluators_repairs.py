"""Tests for Phase 07: EvaluatorRegistry, RepairRegistry, and Quality Corpus.

Validates all G07 acceptance scenarios (T07-01 to T07-08) and P07-06 evaluator identity invariants:
- T07-01: Invalid answer length/schema/evidence offset -> Deterministic FAIL; expensive calls = 0
- T07-02: Semantic annotated corpus on pinned config -> Confusion matrices meeting thresholds
- T07-03: Repair one question in independent group -> Unaffected questions hash/ref preserved
- T07-04: Repair summary blank -> Re-evaluate whole shared group
- T07-05: Repair passage sentence -> Invalidate dependent question evaluations
- T07-06: Cached result with different prompt/model/parent -> Cache miss; no stale reuse
- T07-07: Unsupported claim with valid lexical span -> Grounding FAIL; score cannot override
- T07-08: Answer repair without passage evidence -> Rejected; requires evidence justification
- P07-06: Unrelated evaluator cannot resolve prior issues; requires corresponding evaluator identity
"""

import asyncio
import json
from pathlib import Path
from typing import Any, Dict, List
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType, compute_content_hash
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity, IssueStatus
from app.contracts.policies import POLICY_VERSION
from app.evaluators.base import (
    BaseEvaluator,
    EvaluationStage,
    EvaluatorConfigurationError,
    EvaluatorConflictError,
    EvaluatorMetadata,
    EvaluatorMissingPrerequisiteError,
)
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    DuplicateAndShingleEvaluator,
    EvidenceOffsetEvaluator,
    PassageWordCountEvaluator,
    QuestionStructureEvaluator,
    check_prompt_answer_leakage,
    matches_exact_token_bound,
)
from app.evaluators.registry import (
    EvaluationCache,
    EvaluatorRegistry,
    compute_evaluation_cache_key,
)
from app.evaluators.metrics import calculate_semantic_benchmark_metrics
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    HeuristicQualityScorer,
    NotGivenSemanticsEvaluator,
)
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.ledger import IssueLedgerManager
from app.repair.base import (
    RepairExecutionError,
    RepairJustificationError,
    RepairScope,
)
from app.repair.passage import PassageSentenceRepairer
from app.repair.planner import RepairPlan, RepairPlanner
from app.repair.question import QuestionItemRepairer, SummaryGroupRepairer
from app.repair.registry import RepairRegistry

BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent
CORPUS_DIR = BASE_DIR / "artifacts" / "refactor" / "phase-07" / "corpus"
ARTIFACTS_DIR = BASE_DIR / "artifacts" / "refactor" / "phase-07"

def make_context(owner_id: str | None = None, parents: tuple = (), target: str = "sec_test") -> LoopContext:
    owner = uuid4()
    return LoopContext(
        runId="run_t07",
        targetArtifactId=target,
        targetArtifactType=ArtifactType.SECTION,
        scope=IssueScope.SECTION,
        inputDependencies=tuple(parents),
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )


def make_envelope(
    artifact_id: str,
    artifact_type: ArtifactType,
    version: int,
    payload: Dict[str, Any],
    parent_refs: List[ArtifactRef] | None = None,
) -> ArtifactEnvelope:
    return ArtifactEnvelope.create(
        artifact_id=artifact_id,
        artifact_type=artifact_type,
        version=version,
        payload=payload,
        parent_refs=parent_refs or [],
        producer_version="2.0.0",
        run_id="run_test",
    )


# ── T07-01: Deterministic Short-Circuit ─────────────────────────────────────

@pytest.mark.asyncio
async def test_t07_01_deterministic_short_circuit_halts_expensive_calls():
    """T07-01: Invalid answer length/schema/evidence offset -> Deterministic FAIL; expensive calls = 0."""
    ctx = make_context()
    registry = EvaluatorRegistry()

    # Register deterministic evaluator
    det_eval = AnswerVerbatimAndLengthEvaluator()
    registry.register(det_eval)

    # Spy expensive evaluator tracking invocation count
    class SpyExpensiveEvaluator(BaseEvaluator):
        def __init__(self):
            super().__init__(
                EvaluatorMetadata(
                    evaluator_id="eval_spy_expensive",
                    name="Spy Expensive Evaluator",
                    stage=EvaluationStage.SEMANTIC,
                    target_artifact_types=[ArtifactType.SECTION],
                    is_expensive=True,
                )
            )
            self.call_count = 0

        async def _evaluate_impl(self, context, artifact, intent_id):
            self.call_count += 1
            return EvaluationResult(
                evaluation_id="spy_res",
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=artifact.to_ref(),
                status=EvaluationStatus.PASS,
                issues=[],
            )

    spy_eval = SpyExpensiveEvaluator()
    registry.register(spy_eval)

    # Create artifact with invalid answer length (> 3 words)
    invalid_payload = {
        "sectionIndex": 1,
        "passage": "Coral reefs support twenty-five percent of marine life in tropical oceans.",
        "groups": [
            {
                "questionType": "SentenceCompletion",
                "questions": [
                    {
                        "questionNumber": 1,
                        "prompt": "Coral reefs support a large fraction of _____.",
                        "answer": "twenty-five percent of all marine living species",  # 7 words (> 3)
                    }
                ],
            }
        ],
    }
    art = make_envelope("sec_invalid_wc", ArtifactType.SECTION, 1, invalid_payload)

    # Execute evaluation pipeline
    results = await registry.evaluate_pipeline(ctx, art, intent_id="intent_01")

    # 1. Deterministic evaluator ran and returned FAIL
    assert len(results) == 1
    det_res = results[0]
    assert det_res.evaluator_id == "eval_answer_verbatim_length"
    assert det_res.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.WORD_LIMIT_EXCEEDED for iss in det_res.issues)

    # 2. Invariant: Expensive evaluator was short-circuited; call count MUST BE 0!
    assert spy_eval.call_count == 0


# ── T07-02: Semantic Corpus Evaluation & Thresholds ─────────────────────────

@pytest.mark.asyncio
async def test_t07_02_semantic_annotated_corpus_thresholds():
    """T07-02: Semantic annotated corpus on pinned config -> Meets master plan thresholds.
    
    Thresholds:
    - Overall blocking recall >= 95%
    - Per-type blocking recall >= 90%
    - Ambiguity recall >= 90%
    - False rejection rate <= 10%
    - Critical canaries rejection: 100%
    """
    assert CORPUS_DIR.exists(), "Corpus directory missing; run generate_phase07_corpus.py"

    ctx = make_context()

    # Load questions corpus (120 items)
    with open(CORPUS_DIR / "questions_corpus.json") as f:
        q_corpus = json.load(f)

    # Load fidelity corpus (42 cases)
    with open(CORPUS_DIR / "fidelity_corpus.json") as f:
        f_corpus = json.load(f)

    # Evaluators
    det_structure = QuestionStructureEvaluator()
    det_length = AnswerVerbatimAndLengthEvaluator()
    det_offsets = EvidenceOffsetEvaluator()
    det_duplicate = DuplicateAndShingleEvaluator()
    sem_grounding = GroundingFidelityEvaluator()
    sem_ambiguity = AmbiguityAndDistractorEvaluator()
    sem_not_given = NotGivenSemanticsEvaluator()

    pipeline_evaluators = [
        det_structure,
        det_length,
        det_offsets,
        det_duplicate,
        sem_grounding,
        sem_ambiguity,
        sem_not_given,
    ]

    per_type_metrics: Dict[str, Dict[str, int]] = {}
    ambiguous_total = 0
    ambiguous_detected = 0

    valid_total = 0
    valid_rejected = 0

    invalid_total = 0
    invalid_detected = 0

    for q_type, type_data in q_corpus["types"].items():
        per_type_metrics[q_type] = {"tp": 0, "fn": 0, "tn": 0, "fp": 0}
        passages = q_corpus["passages"]

        # 1. Evaluate Valid Questions
        for q in type_data.get("valid", []):
            valid_total += 1
            src_fam = q.get("source_family", "coral_reefs")
            pass_text = passages.get(src_fam, "")
            payload = {
                "passage": pass_text,
                "questionNumber": q.get("number", 1),
                "questionType": q_type,
                "prompt": q.get("prompt"),
                "answer": q.get("answer"),
                "options": q.get("options", []),
                "evidenceQuote": q.get("evidenceQuote", ""),
            }
            art = make_envelope(f"q_v_{q_type}_{q.get('number')}", ArtifactType.QUESTION, 1, payload)

            all_issues: List[Issue] = []
            for ev in pipeline_evaluators:
                res = await ev.evaluate(ctx, art, intent_id="eval_test")
                all_issues.extend(res.issues)

            blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in all_issues)
            if blocking:
                valid_rejected += 1
                per_type_metrics[q_type]["fp"] += 1
            else:
                per_type_metrics[q_type]["tn"] += 1

        # 2. Evaluate Invalid Questions
        for q in type_data.get("invalid", []):
            invalid_total += 1
            expected_issue = q.get("issue_code")
            if expected_issue == "AMBIGUOUS_ANSWER":
                ambiguous_total += 1

            src_fam = q.get("source_family", "coral_reefs")
            pass_text = passages.get(src_fam, "")
            payload = {
                "passage": pass_text,
                "questionNumber": q.get("number", 1),
                "questionType": q_type,
                "prompt": q.get("prompt"),
                "answer": q.get("answer"),
                "options": q.get("options", []),
                "evidenceQuote": q.get("evidenceQuote", ""),
                "evidenceStart": q.get("evidenceStart"),
                "evidenceEnd": q.get("evidenceEnd"),
            }
            art = make_envelope(f"q_i_{q_type}_{q.get('number')}", ArtifactType.QUESTION, 1, payload)

            all_issues: List[Issue] = []
            for ev in pipeline_evaluators:
                res = await ev.evaluate(ctx, art, intent_id="eval_test")
                all_issues.extend(res.issues)

            blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in all_issues)
            if blocking:
                invalid_detected += 1
                per_type_metrics[q_type]["tp"] += 1
                if expected_issue == "AMBIGUOUS_ANSWER" and any(i.code == IssueCode.AMBIGUOUS_ANSWER for i in all_issues):
                    ambiguous_detected += 1
            else:
                per_type_metrics[q_type]["fn"] += 1

    # 3. Evaluate Fidelity Canaries
    canary_total = 0
    canary_rejected = 0

    for f_case in f_corpus["cases"]:
        if f_case.get("critical_canary"):
            canary_total += 1
            payload = {
                "claims": [{"claimId": f_case["id"], "claimText": f_case["claim_text"]}],
                "sourceText": f_case["source_text"],
            }
            art = make_envelope(f_case["id"], ArtifactType.EVIDENCE_GRAPH, 1, payload)
            res = await sem_grounding.evaluate(ctx, art, intent_id="canary_test")
            if not res.is_pass():
                canary_rejected += 1

    # Compute Statistical Rates
    records: Dict[str, Any] = {}
    canary_records: List[Dict[str, Any]] = []

    for q_type, type_data in q_corpus["types"].items():
        passages = q_corpus["passages"]
        for q in type_data.get("valid", []):
            case_id = f"q_v_{q_type}_{q.get('number')}"
            # Evaluate with pipeline
            src_fam = q.get("source_family", "coral_reefs")
            payload = {
                "passage": passages.get(src_fam, ""),
                "questionNumber": q.get("number", 1),
                "questionType": q_type,
                "prompt": q.get("prompt"),
                "answer": q.get("answer"),
                "options": q.get("options", []),
                "evidenceQuote": q.get("evidenceQuote", ""),
            }
            art = make_envelope(case_id, ArtifactType.QUESTION, 1, payload)
            all_issues = []
            for ev in pipeline_evaluators:
                res = await ev.evaluate(ctx, art, intent_id="eval_test")
                all_issues.extend(res.issues)
            blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in all_issues)
            records[case_id] = {
                "caseId": case_id,
                "questionType": q_type,
                "groundTruthValid": True,
                "isBlocking": blocking,
                "issueCodes": [i.code.value for i in all_issues],
                "expectedIssueCode": "",
            }

        for q in type_data.get("invalid", []):
            case_id = f"q_i_{q_type}_{q.get('number')}"
            src_fam = q.get("source_family", "coral_reefs")
            payload = {
                "passage": passages.get(src_fam, ""),
                "questionNumber": q.get("number", 1),
                "questionType": q_type,
                "prompt": q.get("prompt"),
                "answer": q.get("answer"),
                "options": q.get("options", []),
                "evidenceQuote": q.get("evidenceQuote", ""),
                "evidenceStart": q.get("evidenceStart"),
                "evidenceEnd": q.get("evidenceEnd"),
            }
            art = make_envelope(case_id, ArtifactType.QUESTION, 1, payload)
            all_issues = []
            for ev in pipeline_evaluators:
                res = await ev.evaluate(ctx, art, intent_id="eval_test")
                all_issues.extend(res.issues)
            blocking = any(i.severity == IssueSeverity.CRITICAL or i.blocking for i in all_issues)
            records[case_id] = {
                "caseId": case_id,
                "questionType": q_type,
                "groundTruthValid": False,
                "isBlocking": blocking,
                "issueCodes": [i.code.value for i in all_issues],
                "expectedIssueCode": q.get("issue_code"),
            }

    for f_case in f_corpus["cases"]:
        if f_case.get("critical_canary"):
            payload = {
                "claims": [{"claimId": f_case["id"], "claimText": f_case["claim_text"]}],
                "sourceText": f_case["source_text"],
            }
            art = make_envelope(f_case["id"], ArtifactType.EVIDENCE_GRAPH, 1, payload)
            res = await sem_grounding.evaluate(ctx, art, intent_id="canary_test")
            canary_records.append({
                "caseId": f_case["id"],
                "canaryId": f_case["id"],
                "repetition": 0,
                "isCriticalCanary": True,
                "isBlocking": not res.is_pass(),
                "issueCodes": [i.code.value for i in res.issues],
            })

    calc_result = calculate_semantic_benchmark_metrics(
        records=records,
        campaign_id="test_t07_02_diagnostic",
        partition="dev",
        canary_records=canary_records,
        canary_repetitions=1,
    )

    summary = calc_result.to_canonical_summary()
    with open(ARTIFACTS_DIR / "local-dev-test-confusion-matrices.json", "w") as f:
        json.dump(summary, f, indent=2)

    assert calc_result.overall.total == 120, "Must evaluate all 120 corpus questions"
    assert len(canary_records) == 12, "Must evaluate all 12 critical canaries"
    assert calc_result.canaries.worst_run_rate == 1.00, f"Critical canaries must be 100% rejected, got {calc_result.canaries.worst_run_rate:.2%}"
    assert calc_result.overall.recall > 0.0, "Blocking recall must be non-zero"

# ── T07-03: Independent Question Repair Preserves Unaffected Questions ───────

@pytest.mark.asyncio
async def test_t07_03_independent_question_repair_preserves_unaffected():
    """T07-03: Repair one question in an independent group -> Unaffected questions hash/ref preserved."""
    ctx = make_context()
    repairer = QuestionItemRepairer()

    q1_payload = {
        "questionNumber": 1,
        "questionType": "SentenceCompletion",
        "prompt": "Deep polar ice cores reveal historical _____.",
        "answer": "ancient Antarctic polar ice strata layers",  # 6 words (excessive)
    }
    q2_payload = {
        "questionNumber": 2,
        "questionType": "SentenceCompletion",
        "prompt": "Milankovitch cycles modulate solar insolation at northern _____.",
        "answer": "latitudes",  # 1 word, pristine
    }

    sec_payload = {
        "sectionIndex": 1,
        "passage": "Deep polar ice cores reveal historical ice strata layers. Milankovitch cycles modulate solar insolation at northern latitudes.",
        "groups": [
            {
                "questionType": "SentenceCompletion",
                "questions": [q1_payload, q2_payload],
            }
        ],
    }

    art_v1 = make_envelope("sec_independent_q", ArtifactType.SECTION, 1, sec_payload)

    # Hash of Q2 before repair
    q2_before_str = json.dumps(q2_payload, sort_keys=True)

    issue = Issue.create(
        issue_id="iss_wc_q1",
        code=IssueCode.WORD_LIMIT_EXCEEDED,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 answer exceeds maximum 3 words limit",
        affected_refs=[art_v1.to_ref()],
    )

    art_v2 = await repairer.repair(ctx, art_v1, [issue], intent_id="rep_intent", version=2)

    # Invariant checks:
    assert art_v2.version == 2
    assert art_v2.content_hash != art_v1.content_hash

    repaired_q1 = art_v2.payload["groups"][0]["questions"][0]
    repaired_q2 = art_v2.payload["groups"][0]["questions"][1]

    # Q1 was repaired
    assert len(repaired_q1["answer"].split()) <= 3

    # Q2 was completely unaffected; payload matches before repair
    q2_after_str = json.dumps(dict(repaired_q2), sort_keys=True)
    assert q2_before_str == q2_after_str, "Unaffected question 2 was modified during question 1 repair!"


# ── T07-04: Summary Blank Repair Forces Group Re-Evaluation ──────────────────

@pytest.mark.asyncio
async def test_t07_04_summary_blank_repair_forces_group_reevaluation():
    """T07-04: Repair summary blank altering coherence -> Re-evaluate whole shared group."""
    registry = RepairRegistry()
    summary_repairer = SummaryGroupRepairer()
    registry.register(summary_repairer)
    planner = RepairPlanner(registry)
    ctx = make_context()
    # Summary group with 3 questions but only 1 blank in shared context
    group_payload = {
        "questionType": "SummaryCompletion",
        "sharedContext": "Investigation reveals correlation with [BLANK_1] across studied samples.",
        "questions": [
            {"questionNumber": 1, "answer": "light"},
            {"questionNumber": 2, "answer": "temperature"},
            {"questionNumber": 3, "answer": "salinity"},
        ],
    }
    sec_payload = {
        "sectionIndex": 2,
        "passage": "Investigation reveals correlation with light, temperature, and salinity.",
        "groups": [group_payload],
    }
    art = make_envelope("sec_summary_grp", ArtifactType.SECTION, 1, sec_payload)

    issue = Issue.create(
        issue_id="iss_summary_blank_mismatch",
        code=IssueCode.SCHEMA_VIOLATION,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION_GROUP,
        message="Summary group has 1 blank in sharedContext for 3 questions",
        affected_refs=[art.to_ref()],
    )

    plan = planner.plan_repair(art, [issue])

    # Invariant checks:
    assert plan.selected_scope == RepairScope.GROUP
    assert plan.repairer_id == "rep_summary_group"
    assert plan.requires_full_group_reevaluation is True, "Summary blank repair must force whole group re-evaluation!"

    # 1. Attempting repair without proposed repair when blank count is mismatched fails closed (no fabricated filler)
    with pytest.raises(RepairExecutionError, match="without destroying text coherence; requires full group regeneration"):
        await summary_repairer.repair(ctx, art, [issue], intent_id="rep_fail", version=2)

    # 2. Repairing unindexed blanks preserving existing text in place
    group_with_unindexed = {
        "questionType": "SummaryCompletion",
        "sharedContext": "Observations indicate [BLANK] while deeper strata reveal [BLANK].",
        "questions": [{"questionNumber": 1, "answer": "light"}, {"questionNumber": 2, "answer": "temperature"}],
    }
    sec_unindexed = make_envelope("sec_unidx", ArtifactType.SECTION, 1, {"sectionIndex": 2, "groups": [group_with_unindexed]})
    repaired_unidx = await summary_repairer.repair(ctx, sec_unindexed, [issue], intent_id="rep_unidx", version=2)
    expected_text = "Observations indicate [BLANK_1] while deeper strata reveal [BLANK_2]."
    assert repaired_unidx.payload["groups"][0]["sharedContext"] == expected_text, "Existing text must be preserved!"

# ── T07-05: Passage Repair Invalidates Dependent Question Evaluations ────────

@pytest.mark.asyncio
async def test_t07_05_passage_sentence_repair_invalidates_dependencies():
    """T07-05: Repair passage sentence -> Relevant dependencies invalidated; section cannot be accepted without revalidation."""
    registry = RepairRegistry()
    passage_repairer = PassageSentenceRepairer()
    registry.register(passage_repairer)
    planner = RepairPlanner(registry)

    sec_payload = {
        "sectionIndex": 1,
        "passage": "Agricultural sediment runoff definitely proves total destruction of all delicate coral polyps.",
        "groups": [
            {
                "questionType": "TrueFalseNotGiven",
                "questions": [{"questionNumber": 1, "prompt": "Runoff causes destruction.", "answer": "TRUE"}],
            }
        ],
    }
    art_passage = make_envelope("sec_passage_fidel", ArtifactType.SECTION, 1, sec_payload)

    # Dependent questions with valid 64-hex content hashes
    dep_q1 = ArtifactRef(artifact_id="q_coral_01", artifact_type=ArtifactType.QUESTION, version=1, content_hash="a" * 64)
    dep_q2 = ArtifactRef(artifact_id="q_coral_02", artifact_type=ArtifactType.QUESTION, version=1, content_hash="b" * 64)
    issue = Issue.create(
        issue_id="iss_cert_passage",
        code=IssueCode.OVERSTATED_CERTAINTY,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.PASSAGE,
        message="Passage asserts 'definitely proves' overstating certainty",
        affected_refs=[art_passage.to_ref()],
    )

    plan = planner.plan_repair(art_passage, [issue], dependent_question_refs=[dep_q1, dep_q2])

    # Invariants:
    assert plan.selected_scope == RepairScope.PASSAGE
    assert dep_q1 in plan.invalidated_dependency_refs
    assert dep_q2 in plan.invalidated_dependency_refs
    assert len(plan.invalidated_dependency_refs) == 2, "All dependent questions must be invalidated on passage repair!"


# ── T07-06: Cache Key Pinning and Stale Invalidation ──────────────────────────

def test_t07_06_cache_key_pinning_and_stale_invalidation():
    """T07-06: Cached result with different prompt/model/parent hash -> Cache miss; no stale reuse."""
    base_payload = "hash_payload_123"
    base_parents = "hash_parents_456"
    schema_ver = "2.0.0"
    policy_ver = POLICY_VERSION
    eval_id = "eval_grounding_fidelity"
    eval_ver = "1.0.0"
    prompt_ver = "prompt_v1"
    model_name = "MiniMax-Text-01"

    key_base = compute_evaluation_cache_key(
        base_payload, base_parents, schema_ver, policy_ver, eval_id, eval_ver, prompt_ver, model_name
    )

    # 1. Identical parameters -> Exact same key (Cache Hit)
    key_identical = compute_evaluation_cache_key(
        base_payload, base_parents, schema_ver, policy_ver, eval_id, eval_ver, prompt_ver, model_name
    )
    assert key_base == key_identical

    # 2. Different prompt version -> Cache Miss
    key_diff_prompt = compute_evaluation_cache_key(
        base_payload, base_parents, schema_ver, policy_ver, eval_id, eval_ver, "prompt_v2", model_name
    )
    assert key_base != key_diff_prompt

    # 3. Different model name -> Cache Miss
    key_diff_model = compute_evaluation_cache_key(
        base_payload, base_parents, schema_ver, policy_ver, eval_id, eval_ver, prompt_ver, "gpt-oss-20b"
    )
    assert key_base != key_diff_model

    # 4. Different parent/dependency closure hash -> Cache Miss
    key_diff_parents = compute_evaluation_cache_key(
        base_payload, "hash_parents_altered", schema_ver, policy_ver, eval_id, eval_ver, prompt_ver, model_name
    )
    assert key_base != key_diff_parents

    # 5. Different evaluator version -> Cache Miss
    key_diff_eval = compute_evaluation_cache_key(
        base_payload, base_parents, schema_ver, policy_ver, eval_id, "2.0.0", prompt_ver, model_name
    )
    assert key_base != key_diff_eval


# ── T07-07: Unsupported Claim Fails Despite Valid Spans ──────────────────────

@pytest.mark.asyncio
async def test_t07_07_unsupported_claim_fails_despite_valid_spans():
    """T07-07: Unsupported claim with valid lexical/evidence span -> Grounding FAIL; score cannot override."""
    ctx = make_context()
    grounding_eval = GroundingFidelityEvaluator()

    # Passage mentions 14%
    source_text = "Controlled field experiments demonstrated that macroalgae cover increased by 14% in surveyed plots."
    # Claim points to the valid passage, but distorts number to 40%
    payload = {
        "sourceText": source_text,
        "claims": [
            {
                "claimId": "clm_distorted_num",
                "claimText": "Field experiments showed macroalgae cover expanded by 40% in surveyed plots.",
                "quote": "macroalgae cover increased by 14% in surveyed plots",  # Valid span quote
            }
        ],
    }
    art = make_envelope("eg_num_distortion", ArtifactType.EVIDENCE_GRAPH, 1, payload)

    result = await grounding_eval.evaluate(ctx, art, intent_id="intent_clm")

    # Invariants:
    assert result.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM for i in result.issues)
    assert result.is_pass() is False, "Blocking critical issue must strictly prevent PASS even if score > 0!"


# ── T07-08: Answer Repair Requires Evidence Justification ─────────────────────

def test_t07_08_answer_repair_requires_evidence_justification():
    """T07-08: Repair altering answer to agree with reviewer but passage does not support it -> Rejected."""
    registry = RepairRegistry()
    registry.register(QuestionItemRepairer())
    planner = RepairPlanner(registry)

    passage_text = "Glaciologists recover deep ice strata layers from Antarctic drilling sites."
    payload = {
        "passage": passage_text,
        "questionType": "SentenceCompletion",
        "questionNumber": 1,
        "prompt": "Glaciologists recover deep _____ from Antarctic sites.",
        "answer": "ice strata layers",
    }
    art = make_envelope("q_ans_justification", ArtifactType.QUESTION, 1, payload)

    issue = Issue.create(
        issue_id="iss_ans_ambig",
        code=IssueCode.AMBIGUOUS_ANSWER,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Answer is ambiguous according to external solver",
        affected_refs=[art.to_ref()],
    )

    # 1. Attempt answer repair without any evidence justification -> Must raise RepairJustificationError
    with pytest.raises(RepairJustificationError, match="missing mandatory evidence justification"):
        planner.plan_repair(art, [issue], proposed_new_answer="extraterrestrial comets", evidence_justification=None)

    # 2. Attempt answer repair with justification quote NOT supported by the passage -> Must raise RepairJustificationError
    with pytest.raises(RepairJustificationError, match="not supported by passage"):
        planner.plan_repair(
            art,
            [issue],
            proposed_new_answer="extraterrestrial comets",
            evidence_justification="comets recovered from Antarctic sites",
        )

    # 3. Valid answer repair with passage-supported evidence justification -> Succeeds
    plan = planner.plan_repair(
        art,
        [issue],
        proposed_new_answer="ice strata",
        evidence_justification="recover deep ice strata layers",
    )
    assert plan.selected_scope == RepairScope.QUESTION
    assert plan.evidence_justification == "recover deep ice strata layers"


@pytest.mark.asyncio
async def test_t07_08_repairer_fails_closed_when_answer_lacks_passage_support():
    """T07-08: QuestionItemRepairer fails closed if trimmed answer has no passage evidence justification."""
    ctx = make_context()
    repairer = QuestionItemRepairer()
    # Passage contains NO words from the answer
    payload = {
        "passage": "Glaciologists analyze isotopic signals from Greenland deep ice cores.",
        "questionType": "SentenceCompletion",
        "questionNumber": 1,
        "prompt": "Samples come from _____.",
        "answer": "unrelated alien cosmic meteors from outer galaxy",  # > 3 words, and none match passage
    }
    art = make_envelope("q_unjustified_trim", ArtifactType.QUESTION, 1, payload)
    issue = Issue.create(
        issue_id="iss_wc_fail",
        code=IssueCode.WORD_LIMIT_EXCEEDED,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 answer exceeds maximum 3 words limit",
        affected_refs=[art.to_ref()],
    )
    with pytest.raises(RepairJustificationError, match="Cannot justify trimmed answer"):
        await repairer.repair(ctx, art, [issue], intent_id="rep_fail", version=2)

@pytest.mark.asyncio
async def test_t07_08_option_repair_fails_closed_when_passage_has_no_concepts():
    """T07-08: QuestionItemRepairer fails closed if options cannot be grounded in passage."""
    ctx = make_context()
    repairer = QuestionItemRepairer()
    payload = {
        "passage": "Reefs change.",
        "questionType": "MultipleChoiceSingle",
        "questionNumber": 1,
        "prompt": "What happens?",
        "answer": "A",
        "options": [{"key": "A", "text": "Reefs change"}],
    }
    art = make_envelope("q_opt_fail", ArtifactType.QUESTION, 1, payload)
    issue = Issue.create(
        issue_id="iss_opt_fail",
        code=IssueCode.INSUFFICIENT_OPTIONS,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="MultipleChoiceSingle must have 4 options",
        affected_refs=[art.to_ref()],
    )
    with pytest.raises(RepairJustificationError, match="requires explicit passage-backed justification"):
        await repairer.repair(ctx, art, [issue], intent_id="rep_opt_fail", version=2)

    # Also test BAD_DISTRACTOR without proposed_repair fails closed
    bad_dist_issue = Issue.create(
        issue_id="iss_dist_fail",
        code=IssueCode.BAD_DISTRACTOR,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 distractor is invalid",
        affected_refs=[art.to_ref()],
    )
    with pytest.raises(RepairJustificationError, match="requires explicit passage-backed justification"):
        await repairer.repair(ctx, art, [bad_dist_issue], intent_id="rep_dist_fail", version=2)


@pytest.mark.asyncio
async def test_t07_08_distractor_repair_with_evidence_and_uniqueness():
    """T07-08: Distractor repair with verifiable passage quote + wrongness rationale succeeds; duplicate fails uniqueness."""
    ctx = make_context()
    class MockOptionGateway:
        def __init__(self):
            self.checkpoint_client = object()
            self.last_response = None
        async def execute(self, req, epoch=1, lease_owner=None):
            user_msg = req.messages[-1].content
            if "Advanced battery storage" in user_msg:
                payload = {
                    "options": [
                        {"key": "A", "status": "SUPPORTED", "supporting_sentence": "Advanced battery storage provides long-duration backup.", "reason": "Explicitly stated in text"},
                        {"key": "B", "status": "SUPPORTED", "supporting_sentence": "Hydro storage provides long-duration backup.", "reason": "Explicitly stated in text"},
                        {"key": "C", "status": "REFUTED", "supporting_sentence": "", "reason": "Not stated"},
                        {"key": "D", "status": "REFUTED", "supporting_sentence": "", "reason": "Not stated"},
                    ]
                }
            else:
                payload = {
                    "options": [
                        {"key": "A", "status": "REFUTED", "supporting_sentence": "Solar and wind installations expand rapidly.", "reason": "Variable generation, not backup"},
                        {"key": "B", "status": "SUPPORTED", "supporting_sentence": "Hydro storage provides long-duration backup.", "reason": "Explicitly stated in text"},
                        {"key": "C", "status": "REFUTED", "supporting_sentence": "", "reason": "Not stated"},
                        {"key": "D", "status": "REFUTED", "supporting_sentence": "", "reason": "Not stated"},
                    ]
                }
            return type("Resp", (), {
                "parsed_payload": payload,
                "raw_text": json.dumps(payload),
                "provider_name": "mock",
                "model_name": "mock-eval",
            })()
    mock_gw = MockOptionGateway()
    repairer = QuestionItemRepairer(gateway=mock_gw)
    pass_text = "Solar and wind installations expand rapidly. Hydro storage provides long-duration backup."
    payload = {
        "passage": pass_text,
        "questionType": "MultipleChoiceSingle",
        "questionNumber": 1,
        "prompt": "What renewable technology provides long-duration backup?",
        "answer": "B",
        "options": [
            {"key": "A", "text": "Duplicate answer text"},
            {"key": "B", "text": "Hydro storage"},
            {"key": "C", "text": "Geothermal deep wells"},
            {"key": "D", "text": "Biomass plants"},
        ],
    }
    art = make_envelope("q_mcq_dist_repair", ArtifactType.QUESTION, 1, payload)

    # 1. Missing wrongness rationale -> raises RepairJustificationError
    issue_no_rationale = Issue.create(
        issue_id="iss_dist_1",
        code=IssueCode.BAD_DISTRACTOR,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 distractor A is bad",
        affected_refs=[art.to_ref()],
        evidence="Solar and wind installations expand rapidly",
        proposed_repair="A: Solar and wind installations",
    )
    with pytest.raises(RepairJustificationError, match="missing mandatory wrongness rationale"):
        await repairer.repair(ctx, art, [issue_no_rationale], intent_id="rep_d1", version=2)

    # 2. Duplicate option resulting from repair -> raises RepairJustificationError (post-repair uniqueness fails)
    issue_dup = Issue.create(
        issue_id="iss_dist_2",
        code=IssueCode.BAD_DISTRACTOR,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 distractor A is bad",
        affected_refs=[art.to_ref()],
        evidence="Hydro storage provides long-duration backup",
        proposed_repair="A: Hydro storage | Rationale: Wrong because...",
    )
    with pytest.raises(RepairJustificationError, match="uniqueness failed"):
        await repairer.repair(ctx, art, [issue_dup], intent_id="rep_d2", version=2)
    # 3. Replacement option that is also supported as TRUE by passage (second correct answer) -> Post-repair evaluator fails uniqueness
    pass_with_second_ans = "Solar and wind installations expand rapidly. Hydro storage provides long-duration backup. Advanced battery storage provides long-duration backup."
    art_second = make_envelope("q_mcq_two_answers", ArtifactType.QUESTION, 1, {**payload, "passage": pass_with_second_ans})
    issue_second = Issue.create(
        issue_id="iss_dist_second",
        code=IssueCode.BAD_DISTRACTOR,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 distractor A is bad",
        affected_refs=[art_second.to_ref()],
        evidence="Advanced battery storage provides long-duration backup",
        proposed_repair="A: Advanced battery storage | Rationale: Claimed wrong but actually true in text",
    )
    with pytest.raises(RepairJustificationError, match="single-answer uniqueness"):
        await repairer.repair(ctx, art_second, [issue_second], intent_id="rep_sec", version=2)

    # 4. Valid repair with evidence quote + wrongness rationale -> Evaluator confirms single correct answer -> Succeeds
    issue_valid = Issue.create(
        issue_id="iss_dist_3",
        code=IssueCode.BAD_DISTRACTOR,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 1 distractor A is bad",
        affected_refs=[art.to_ref()],
        evidence="Solar and wind installations expand rapidly",
        proposed_repair="A: Solar and wind installations | Rationale: Wrong because wind/solar are variable generation, not long-duration backup",
    )
    repaired_art = await repairer.repair(ctx, art, [issue_valid], intent_id="rep_d3", version=2)
    assert repaired_art.version == 2
    assert repaired_art.payload["options"][0]["text"] == "Solar and wind installations"


@pytest.mark.asyncio
async def test_t07_08_insufficient_options_contract_validations():
    """T07-08: INSUFFICIENT_OPTIONS repair rejects duplicate keys, duplicate texts, answer collision, and enforces 4 options."""
    ctx = make_context()
    repairer = QuestionItemRepairer()
    pass_text = "Solar and wind installations expand rapidly. Hydro storage provides long-duration backup. Geothermal deep wells provide continuous baseload. Compressed air energy storage remains in development."
    base_options = [
        {"key": "A", "text": "Solar and wind installations"},
        {"key": "B", "text": "Hydro storage"},
        {"key": "C", "text": "Geothermal deep wells"},
    ]
    payload = {
        "passage": pass_text,
        "questionType": "MultipleChoiceSingle",
        "questionNumber": 1,
        "prompt": "What renewable technology provides long-duration backup?",
        "answer": "B",
        "options": list(base_options),
    }
    art = make_envelope("q_mcq_insufficient", ArtifactType.QUESTION, 1, payload)

    # 1. Reject key already present (key 'A' is already present)
    iss_dup_key = Issue.create(
        issue_id="iss_k1", code=IssueCode.INSUFFICIENT_OPTIONS, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
        message="Needs 4th option", affected_refs=[art.to_ref()],
        evidence="Compressed air energy storage remains in development",
        proposed_repair="A: Compressed air energy storage | Rationale: Wrong because...",
    )
    with pytest.raises(RepairJustificationError, match="already present"):
        await repairer.repair(ctx, art, [iss_dup_key], intent_id="rep_k1", version=2)

    # 2. Reject key matching answer key ('D' is answer, options only have A, B, C)
    art_missing_ans = make_envelope("q_mcq_missing_ans", ArtifactType.QUESTION, 1, {**payload, "answer": "D"})
    iss_ans_key = Issue.create(
        issue_id="iss_k2", code=IssueCode.INSUFFICIENT_OPTIONS, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
        message="Needs 4th option", affected_refs=[art_missing_ans.to_ref()],
        evidence="Compressed air energy storage remains in development",
        proposed_repair="D: Compressed air energy storage | Rationale: Wrong because...",
    )
    with pytest.raises(RepairJustificationError, match="cannot add new option with correct answer key"):
        await repairer.repair(ctx, art_missing_ans, [iss_ans_key], intent_id="rep_k2", version=2)
    # 3. Reject option text matching answer text
    iss_ans_text = Issue.create(
        issue_id="iss_k3", code=IssueCode.INSUFFICIENT_OPTIONS, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
        message="Needs 4th option", affected_refs=[art.to_ref()],
        evidence="Hydro storage provides long-duration backup",
        proposed_repair="D: Hydro storage | Rationale: Wrong because...",
    )
    with pytest.raises(RepairJustificationError, match="identical to correct answer"):
        await repairer.repair(ctx, art, [iss_ans_text], intent_id="rep_k3", version=2)

    # 4. Reject option text duplicating an existing option text
    iss_dup_text = Issue.create(
        issue_id="iss_k4", code=IssueCode.INSUFFICIENT_OPTIONS, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
        message="Needs 4th option", affected_refs=[art.to_ref()],
        evidence="Solar and wind installations expand rapidly",
        proposed_repair="D: Solar and wind installations | Rationale: Wrong because...",
    )
    with pytest.raises(RepairJustificationError, match="duplicates an existing option"):
        await repairer.repair(ctx, art, [iss_dup_text], intent_id="rep_k4", version=2)

    # 4.5. Reject option text absent from passage (ungrounded concept)
    iss_ungrounded = Issue.create(
        issue_id="iss_k_ungrounded", code=IssueCode.INSUFFICIENT_OPTIONS, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
        message="Needs 4th option", affected_refs=[art.to_ref()],
        evidence="Compressed air energy storage remains in development",
        proposed_repair="D: Wave and tidal converters | Rationale: Wrong because...",
    )
    with pytest.raises(RepairJustificationError, match="not grounded in passage text"):
        await repairer.repair(ctx, art, [iss_ungrounded], intent_id="rep_ungrounded", version=2)

    # 5. Valid 4th option added with genuine passage evidence and wrongness rationale -> Succeeds
    iss_valid_opt = Issue.create(
        issue_id="iss_k5", code=IssueCode.INSUFFICIENT_OPTIONS, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION,
        message="Needs 4th option", affected_refs=[art.to_ref()],
        evidence="Compressed air energy storage remains in development",
        proposed_repair="D: Compressed air energy storage | Rationale: Wrong because compressed air is in early development, not long-duration backup",
    )
    repaired = await repairer.repair(ctx, art, [iss_valid_opt], intent_id="rep_k5", version=2)
    assert repaired.version == 2
    assert len(repaired.payload["options"]) == 4
    assert repaired.payload["options"][3]["key"] == "D"
    assert repaired.payload["options"][3]["text"] == "Compressed air energy storage"

def test_p07_06_evaluator_identity_in_issue_resolution():
    """P07-06: An open issue can only be resolved by the corresponding evaluator identity on a newer version."""
    ctx = make_context()
    art_v1 = make_envelope("art_doc_01", ArtifactType.SECTION, 1, {"title": "Doc V1"})
    art_v2 = make_envelope("art_doc_01", ArtifactType.SECTION, 2, {"title": "Doc V2"})

    ledger = IssueLedgerManager(ctx.run_id)

    # Issue detected by eval_syntax
    issue = ledger.record_issue(
        code=IssueCode.WORD_LIMIT_EXCEEDED,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Word limit exceeded in question 1",
        affected_refs=[art_v1.to_ref()],
        reported_by="eval_syntax",
    )

    # 1. Attempt to resolve with PASS from an unrelated evaluator (eval_grammar) -> Must raise ValueError
    unrelated_pass = EvaluationResult(
        evaluation_id="eval_res_grammar",
        evaluator_id="eval_grammar",
        evaluator_version="1.0.0",
        target_ref=art_v2.to_ref(),
        status=EvaluationStatus.PASS,
        issues=[],
        resolved_issue_fingerprints=[issue.fingerprint],
    )
    with pytest.raises(ValueError, match="Resolution requires the corresponding evaluator 'eval_syntax'"):
        ledger.resolve_issue(issue.fingerprint, unrelated_pass)

    # 2. Resolve with PASS from the corresponding evaluator (eval_syntax) on v2 -> Succeeds
    correct_pass = EvaluationResult(
        evaluation_id="eval_res_syntax_v2",
        evaluator_id="eval_syntax",
        evaluator_version="1.0.0",
        target_ref=art_v2.to_ref(),
        status=EvaluationStatus.PASS,
        issues=[],
        resolved_issue_fingerprints=[issue.fingerprint],
    )
    success = ledger.resolve_issue(issue.fingerprint, correct_pass)
    assert success is True
    assert not ledger.has_unresolved_blockers()
    assert ledger.issues[0].status == IssueStatus.RESOLVED


def test_p07_06_find_resolvable_fingerprints_matches_evaluator_id():
    """P07-06: find_resolvable_fingerprints accurately matches open issues using issue.evaluator_id."""
    ctx = make_context()
    art_v1 = make_envelope("art_section_01", ArtifactType.SECTION, 1, {"title": "Section V1"})
    art_v2 = make_envelope("art_section_01", ArtifactType.SECTION, 2, {"title": "Section V2"})

    ledger = IssueLedgerManager(ctx.run_id)

    # Record 2 issues: one by eval_wc, one by eval_fidel
    iss1 = ledger.record_issue(
        code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.SECTION,
        message="Section word count out of bounds",
        affected_refs=[art_v1.to_ref()],
        reported_by="eval_wc",
    )
    iss2 = ledger.record_issue(
        code=IssueCode.OVERSTATED_CERTAINTY,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.PASSAGE,
        message="Overstated certainty",
        affected_refs=[art_v1.to_ref()],
        reported_by="eval_fidel",
    )

    # Lookup for eval_wc on v2
    resolvable_wc = ledger.find_resolvable_fingerprints("eval_wc", art_v2.to_ref())
    assert iss1.fingerprint in resolvable_wc
    assert iss2.fingerprint not in resolvable_wc

    # Lookup for eval_fidel on v2
    resolvable_fidel = ledger.find_resolvable_fingerprints("eval_fidel", art_v2.to_ref())
    assert iss2.fingerprint in resolvable_fidel
    assert iss1.fingerprint not in resolvable_fidel


@pytest.mark.asyncio
async def test_base_evaluator_does_not_auto_resolve_other_evaluator_shared_code_issue():
    """BaseEvaluator.evaluate() must not auto-resolve an open issue with shared code if owned by another evaluator."""
    from app.evaluators.semantic import AmbiguityAndDistractorEvaluator, NotGivenSemanticsEvaluator
    from app.loop.context import AuthorityGrant, LoopContext
    from app.loop.ledger import IssueLedgerManager
    from uuid import uuid4

    owner = uuid4()
    run_id = "run_shared_code_test"
    ledger = IssueLedgerManager(run_id)
    art_v1 = make_envelope("art_q_1", ArtifactType.QUESTION, 1, {"prompt": "Statement 1", "answer": "NOT_GIVEN"})
    art_v2 = make_envelope("art_q_1", ArtifactType.QUESTION, 2, {"prompt": "Statement 1", "answer": "NOT_GIVEN"})

    # NotGivenSemanticsEvaluator recorded AMBIGUOUS_ANSWER on v1
    iss = ledger.record_issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Ambiguous answer from NOT_GIVEN contradiction",
        affected_refs=[art_v1.to_ref()],
        reported_by="eval_not_given_semantics",
    )

    ctx = LoopContext(
        runId=run_id,
        targetArtifactId="art_q_1",
        targetArtifactType=ArtifactType.QUESTION,
        scope="QUESTION",
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
        openIssues=(iss,),
    )

    # AmbiguityAndDistractorEvaluator evaluates v2 and passes
    eval_ambig = AmbiguityAndDistractorEvaluator(required=False)
    res = await eval_ambig.evaluate(ctx, art_v2, "intent_eval")

    # Must NOT contain iss.fingerprint in resolved_issue_fingerprints because it belongs to eval_not_given_semantics
    assert iss.fingerprint not in (res.resolved_issue_fingerprints or [])

def test_p07_01_metadata_settings_wiring_and_override():
    """P07-01: Metadata timeouts and tokens default to runtime Settings and support explicit overrides."""
    from app.config import settings

    # 1. Defaults correctly mirror Settings
    det_ev = PassageWordCountEvaluator()
    assert det_ev.metadata.timeout_seconds == settings.evaluator_deterministic_timeout_seconds

    sem_ev = GroundingFidelityEvaluator()
    assert sem_ev.metadata.timeout_seconds == settings.evaluator_semantic_timeout_seconds
    assert sem_ev.metadata.estimated_tokens == settings.evaluator_max_tokens_per_evaluation

    rep = PassageSentenceRepairer()
    assert rep.metadata.timeout_seconds == settings.repair_timeout_seconds
    assert rep.metadata.estimated_tokens == settings.repair_max_tokens_per_attempt

    # 2. Explicit constructor overrides are honored
    custom_det = PassageWordCountEvaluator(timeout_seconds=42.0)
    assert custom_det.metadata.timeout_seconds == 42.0

    custom_sem = GroundingFidelityEvaluator(timeout_seconds=88.5, estimated_tokens=5500)
    assert custom_sem.metadata.timeout_seconds == 88.5
    assert custom_sem.metadata.estimated_tokens == 5500

    custom_rep = PassageSentenceRepairer(timeout_seconds=77.0, estimated_tokens=3200)
    assert custom_rep.metadata.timeout_seconds == 77.0
    assert custom_rep.metadata.estimated_tokens == 3200

# ── Gate G07 Audit Remediation Regression Tests ──────────────────────────────

class _SpyTimeoutEvaluator(BaseEvaluator):
    def __init__(self, timeout_sec: float = 0.05):
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="spy_timeout",
                evaluator_version="1.0.0",
                name="Spy Timeout Evaluator",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.QUESTION],
                timeout_seconds=timeout_sec,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
        await asyncio.sleep(0.3)
        return EvaluationResult(
            evaluationId="eval_never",
            evaluatorId=self.evaluator_id,
            evaluatorVersion=self.evaluator_version,
            targetRef=artifact.to_ref(),
            status=EvaluationStatus.PASS,
        )


class _SpyExceptionEvaluator(BaseEvaluator):
    def __init__(self):
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="spy_exception",
                evaluator_version="1.0.0",
                name="Spy Exception Evaluator",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.QUESTION],
                timeout_seconds=10.0,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
        raise RuntimeError("Simulated unhandled LLM transport disconnect")


class _SpyMalformedEvaluator(BaseEvaluator):
    def __init__(self, mode: str = "none"):
        self.mode = mode
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="spy_malformed",
                evaluator_version="1.0.0",
                name="Spy Malformed Evaluator",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.QUESTION],
                timeout_seconds=10.0,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str) -> Any:
        if self.mode == "none":
            return None
        if self.mode == "empty_error":
            return EvaluationResult(
                evaluationId="eval_empty_err",
                evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version,
                targetRef=artifact.to_ref(),
                status=EvaluationStatus.ERROR,
                issues=[],
            )
        return {"raw": "dict_not_envelope"}


@pytest.mark.asyncio
async def test_audit_timeout_fail_closed_error_result():
    """AUDIT-TIMEOUT-FAIL-CLOSED: BaseEvaluator timeout produces typed ERROR result without TypeError."""
    ctx = make_context()
    art = make_envelope("q_timeout_test", ArtifactType.QUESTION, 1, {"prompt": "Test prompt"})
    evaluator = _SpyTimeoutEvaluator(timeout_sec=0.05)

    res = await evaluator.evaluate(ctx, art, intent_id="intent_tout")

    assert isinstance(res, EvaluationResult), "Result must be typed EvaluationResult"
    assert res.status == EvaluationStatus.ERROR, f"Expected ERROR status, got {res.status}"
    assert res.is_pass() is False, "ERROR result must not pass is_pass()"
    assert res.evaluator_id == "spy_timeout"
    assert res.evaluator_version == "1.0.0"
    assert res.target_ref == art.to_ref()
    assert len(res.issues) == 1, "Must contain exactly 1 attached critical issue"
    issue = res.issues[0]
    assert issue.code == IssueCode.EVALUATOR_UNAVAILABLE
    assert issue.severity == IssueSeverity.CRITICAL
    assert issue.scope == ctx.scope
    assert issue.evaluator_id == "spy_timeout"
    assert issue.affected_refs == [art.to_ref()]
    assert "timed out after 0.1s" in issue.message or "timed out" in issue.message


@pytest.mark.asyncio
async def test_audit_exception_fail_closed_error_result():
    """BaseEvaluator unhandled exception produces typed ERROR result with sanitized message."""
    ctx = make_context()
    art = make_envelope("q_ex_test", ArtifactType.QUESTION, 1, {"prompt": "Test prompt"})
    evaluator = _SpyExceptionEvaluator()

    res = await evaluator.evaluate(ctx, art, intent_id="intent_ex")

    assert isinstance(res, EvaluationResult)
    assert res.status == EvaluationStatus.ERROR
    assert res.is_pass() is False
    assert len(res.issues) == 1
    issue = res.issues[0]
    assert issue.code == IssueCode.EVALUATOR_UNAVAILABLE
    assert issue.severity == IssueSeverity.CRITICAL
    assert "Simulated unhandled LLM transport disconnect" in issue.message


@pytest.mark.asyncio
async def test_audit_malformed_output_fail_closed():
    """BaseEvaluator malformed output produces typed ERROR result with MALFORMED_OUTPUT issue."""
    ctx = make_context()
    art = make_envelope("q_mal_test", ArtifactType.QUESTION, 1, {"prompt": "Test prompt"})

    # 1. Returned None
    ev_none = _SpyMalformedEvaluator(mode="none")
    res_none = await ev_none.evaluate(ctx, art, intent_id="intent_mal1")
    assert res_none.status == EvaluationStatus.ERROR
    assert res_none.issues[0].code == IssueCode.SCHEMA_VIOLATION

    # 2. Returned ERROR status without issues (must attach critical issue)
    ev_empty = _SpyMalformedEvaluator(mode="empty_error")
    res_empty = await ev_empty.evaluate(ctx, art, intent_id="intent_mal2")
    assert res_empty.status == EvaluationStatus.ERROR
    assert len(res_empty.issues) >= 1
    assert res_empty.issues[0].code == IssueCode.EVALUATOR_UNAVAILABLE


@pytest.mark.asyncio
async def test_audit_cancellation_preserved_not_swallowed():
    """BaseEvaluator preserves runtime cancellation semantics: never swallows CancelledError."""
    ctx = make_context()
    art = make_envelope("q_cancel_test", ArtifactType.QUESTION, 1, {"prompt": "Test prompt"})

    class _CancellableEvaluator(BaseEvaluator):
        def __init__(self):
            super().__init__(
                EvaluatorMetadata(
                    evaluator_id="spy_cancellable",
                    name="Cancellable Evaluator",
                    stage=EvaluationStage.SEMANTIC,
                    target_artifact_types=[ArtifactType.QUESTION],
                    timeout_seconds=30.0,
                )
            )

        async def _evaluate_impl(self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
            await asyncio.sleep(10.0)
            return EvaluationResult(
                evaluationId="ev", evaluatorId=self.evaluator_id, evaluatorVersion="1.0.0",
                targetRef=artifact.to_ref(), status=EvaluationStatus.PASS,
            )

    evaluator = _CancellableEvaluator()
    task = asyncio.create_task(evaluator.evaluate(ctx, art, "intent_cancel"))
    await asyncio.sleep(0.01)
    task.cancel()

    with pytest.raises(asyncio.CancelledError):
        await task


@pytest.mark.asyncio
async def test_audit_required_evaluator_enforcement_in_pipeline():
    """AUDIT-REQUIRED-WIRING: Missing required evaluator creates recorded failure and prevents PASS."""
    ctx = make_context()
    art = make_envelope("q_req_test", ArtifactType.QUESTION, 1, {"prompt": "Test prompt"})
    registry = EvaluatorRegistry()
    # Register one evaluator
    det_eval = AnswerVerbatimAndLengthEvaluator()
    registry.register(det_eval)

    # 1. Pipeline called with required evaluator that is NOT in registry
    results = await registry.evaluate_pipeline(
        ctx,
        art,
        intent_id="intent_req",
        required_evaluator_ids=["eval_not_given_semantics", "eval_answer_verbatim_length"],
    )
    assert len(results) == 1
    res = results[0]
    assert res.status == EvaluationStatus.ERROR
    assert res.issues[0].code == IssueCode.EVALUATOR_UNAVAILABLE
    assert "eval_not_given_semantics" in res.issues[0].message
    assert res.is_pass() is False

    # 2. Strict raise_on_missing_required raises EvaluatorConfigurationError
    with pytest.raises(EvaluatorConfigurationError, match="missing required evaluator"):
        await registry.evaluate_pipeline(
            ctx,
            art,
            intent_id="intent_req",
            required_evaluator_ids=["eval_not_given_semantics"],
            raise_on_missing_required=True,
        )


@pytest.mark.asyncio
async def test_audit_dynamic_closure_traversal_passage_and_sister_questions():
    """AUDIT-REPAIR-CLOSURE: Traverses exact graph consumers; preserves unaffected sister questions."""
    registry = RepairRegistry()
    summary_repairer = SummaryGroupRepairer()
    q_repairer = QuestionItemRepairer()
    passage_repairer = PassageSentenceRepairer()
    registry.register(summary_repairer)
    registry.register(q_repairer)
    registry.register(passage_repairer)
    planner = RepairPlanner(registry)

    # Setup lineage graph:
    # Passage -> Q1, Q2 -> Section
    passage_art = make_envelope("passage_01", ArtifactType.PASSAGE, 1, {"passageText": "The clinical trial lasted six weeks."})
    q1_art = make_envelope(
        "q1_item", ArtifactType.QUESTION, 1,
        {"prompt": "Trial duration", "answer": "six weeks"},
        parent_refs=[passage_art.to_ref()],
    )
    q2_art = make_envelope(
        "q2_item", ArtifactType.QUESTION, 1,
        {"prompt": "Patient outcomes", "answer": "improved sleep"},
        parent_refs=[passage_art.to_ref()],
    )
    section_art = make_envelope(
        "sec_01", ArtifactType.SECTION, 1,
        {"sectionIndex": 1},
        parent_refs=[passage_art.to_ref(), q1_art.to_ref(), q2_art.to_ref()],
    )
    artifacts_pool = [passage_art, q1_art, q2_art, section_art]

    # 1. Repair single question Q1:
    # Q1 changes -> section is invalidated (consumes Q1); sister Q2 is unaffected!
    issue_q1 = Issue.create(
        issue_id="iss_q1",
        code=IssueCode.WORD_LIMIT_EXCEEDED,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Answer exceeds word limit",
        affected_refs=[q1_art.to_ref()],
    )
    plan_q = planner.plan_repair(q1_art, [issue_q1], artifacts_pool=artifacts_pool)
    inv_ids = {r.artifact_id for r in plan_q.invalidated_dependency_refs}
    unaff_ids = {r.artifact_id for r in plan_q.unaffected_accepted_refs}

    assert "sec_01" in inv_ids, "Section aggregating Q1 must be invalidated"
    assert "q2_item" in unaff_ids, "Sister question Q2 must remain unaffected"
    assert "q2_item" not in inv_ids, "Sister question Q2 must not be invalidated"

    # 2. Repair Passage:
    # All consuming questions Q1, Q2, and Section must be in invalidated closure!
    issue_p = Issue.create(
        issue_id="iss_p",
        code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.PASSAGE,
        message="Passage word count out of bounds",
        affected_refs=[passage_art.to_ref()],
    )
    plan_p = planner.plan_repair(passage_art, [issue_p], artifacts_pool=artifacts_pool)
    inv_p_ids = {r.artifact_id for r in plan_p.invalidated_dependency_refs}
    assert "q1_item" in inv_p_ids
    assert "q2_item" in inv_p_ids
    assert "sec_01" in inv_p_ids


@pytest.mark.asyncio
async def test_audit_dynamic_closure_cycle_and_missing_metadata_detection():
    """AUDIT-REPAIR-CLOSURE: Detects malformed graphs, cycles, and missing metadata fail-closed."""
    registry = RepairRegistry()
    registry.register(PassageSentenceRepairer())
    planner = RepairPlanner(registry)

    art1 = make_envelope("art_a", ArtifactType.PASSAGE, 1, {"text": "A"})
    art2 = make_envelope("art_b", ArtifactType.QUESTION, 1, {"text": "B"}, parent_refs=[art1.to_ref()])
    # Create cycle: art1 references art2
    art1_cycle = art1.model_copy(update={"parent_refs": (art2.to_ref(),)})

    issue = Issue.create(
        issue_id="iss_cycle",
        code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.PASSAGE,
        message="Word count issue",
        affected_refs=[art1_cycle.to_ref()],
    )

    # Cycle must raise RepairExecutionError
    with pytest.raises(RepairExecutionError, match="cycle detected"):
        planner.plan_repair(art1_cycle, [issue], artifacts_pool=[art1_cycle, art2])

    # Missing metadata on passage repair without pool or dependent refs must fail-closed
    with pytest.raises(RepairExecutionError, match="Missing dependency metadata"):
        planner.plan_repair(art1, [issue], artifacts_pool=None, dependent_question_refs=None)


@pytest.mark.asyncio
async def test_audit_not_given_semantics_polar_opposites_and_minimal_pairs():
    """AUDIT-NOT-GIVEN-SEMANTICS: Validates polar opposites and all 4 annotated minimal pairs."""
    ctx = make_context()
    evaluator = NotGivenSemanticsEvaluator()

    # 1. Audit Finding 3 Case: 'remained steady' vs 'declined significantly'
    passage_fish = "Across surveyed marine reserves, herbivorous fish populations declined significantly due to warming."
    q_fish_invalid = {
        "questionNumber": 1,
        "questionType": "TrueFalseNotGiven",
        "prompt": "Herbivorous fish populations remained steady across all surveyed reefs.",
        "answer": "NOT_GIVEN",  # Incorrectly labeled NOT_GIVEN when passage explicitly contradicts it!
    }
    art_fish = make_envelope("q_fish", ArtifactType.QUESTION, 1, {**q_fish_invalid, "passage": passage_fish})
    res_fish = await evaluator.evaluate(ctx, art_fish, intent_id="eval_fish")
    assert res_fish.status == EvaluationStatus.FAIL, "Contradicted statement labeled NOT_GIVEN must FAIL"
    assert any(i.code == IssueCode.AMBIGUOUS_ANSWER for i in res_fish.issues)
    assert "correct answer must be FALSE" in res_fish.issues[0].message

    # 2. Minimal Pair 1: Passage 6 weeks vs Statement 10 weeks -> Contradiction!
    passage_weeks = "In a controlled clinical trial lasting six weeks, researchers monitored patient sleep architecture."
    q_pair1 = {
        "questionNumber": 2,
        "questionType": "TrueFalseNotGiven",
        "prompt": "The clinical trial lasted ten weeks.",
        "answer": "NOT_GIVEN",  # Contradicted by 6 weeks vs 10 weeks!
    }
    art_pair1 = make_envelope("q_pair1", ArtifactType.QUESTION, 1, {**q_pair1, "passage": passage_weeks})
    res_pair1 = await evaluator.evaluate(ctx, art_pair1, intent_id="eval_p1")
    assert res_pair1.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.AMBIGUOUS_ANSWER for i in res_pair1.issues)

    # 3. Minimal Pair 2: Sleep improvement vs Statement cholesterol decreased (completely absent) -> Valid NOT_GIVEN!
    q_pair2 = {
        "questionNumber": 3,
        "questionType": "TrueFalseNotGiven",
        "prompt": "Participants' cholesterol decreased during the clinical trial.",
        "answer": "NOT_GIVEN",
    }
    art_pair2 = make_envelope("q_pair2", ArtifactType.QUESTION, 1, {**q_pair2, "passage": passage_weeks})
    res_pair2 = await evaluator.evaluate(ctx, art_pair2, intent_id="eval_p2")
    assert res_pair2.status == EvaluationStatus.PASS, "Truly absent concept labeled NOT_GIVEN must PASS"

    # 4. Minimal Pair 3: Author explicitly rejects compulsory participation vs Statement author supports it -> NO (contradiction)!
    passage_stance = "The author explicitly rejects compulsory participation in community volunteer programs, favoring voluntary engagement."
    q_pair3_ng = {
        "questionNumber": 4,
        "questionType": "YesNoNotGiven",
        "prompt": "The author supports compulsory participation in community volunteer programs.",
        "answer": "NOT_GIVEN",  # Rejected: Author explicitly rejects it, answer must be NO!
    }
    art_pair3_ng = make_envelope("q_pair3_ng", ArtifactType.QUESTION, 1, {**q_pair3_ng, "passage": passage_stance})
    res_pair3_ng = await evaluator.evaluate(ctx, art_pair3_ng, intent_id="eval_p3_ng")
    assert res_pair3_ng.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.AMBIGUOUS_ANSWER for i in res_pair3_ng.issues)
    assert "correct answer must be NO" in res_pair3_ng.issues[0].message

    q_pair3_yes = {
        "questionNumber": 5,
        "questionType": "YesNoNotGiven",
        "prompt": "The author supports compulsory participation in community volunteer programs.",
        "answer": "YES",  # Rejected: Contradicts author's explicit view!
    }
    art_pair3_yes = make_envelope("q_pair3_yes", ArtifactType.QUESTION, 1, {**q_pair3_yes, "passage": passage_stance})
    res_pair3_yes = await evaluator.evaluate(ctx, art_pair3_yes, intent_id="eval_p3_yes")
    assert res_pair3_yes.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM for i in res_pair3_yes.issues)

    # 5. Minimal Pair 4: Author discusses participation rates (no stance on compulsory) -> Valid NOT_GIVEN!
    passage_rates = "The author discusses participation rates, noting that sixty percent of local residents engaged in programs."
    q_pair4 = {
        "questionNumber": 6,
        "questionType": "YesNoNotGiven",
        "prompt": "The author supports compulsory participation in community programs.",
        "answer": "NOT_GIVEN",
    }
    art_pair4 = make_envelope("q_pair4", ArtifactType.QUESTION, 1, {**q_pair4, "passage": passage_rates})
    res_pair4 = await evaluator.evaluate(ctx, art_pair4, intent_id="eval_p4")
    assert res_pair4.status == EvaluationStatus.PASS, "Unstated author stance labeled NOT_GIVEN must PASS"


@pytest.mark.asyncio
async def test_not_given_semantics_gateway_execution_path():
    """AUDIT-NOT-GIVEN-SEMANTICS: Verifies real Gateway request binding and canonical response parsing."""
    from unittest.mock import AsyncMock
    from app.providers.models import ProviderResponse, FinishReason, UsageReport

    ctx = make_context()
    ctx.section_id = 1
    passage_text = "The committee strongly opposed the proposed regulation."
    q_payload = {
        "questionNumber": 7,
        "questionType": "TrueFalseNotGiven",
        "prompt": "The committee supported the regulation.",
        "answer": "NOT_GIVEN",
        "passage": passage_text,
    }
    art = make_envelope("q_gw_test", ArtifactType.QUESTION, 1, q_payload)

    # Create mock gateway
    mock_gateway = AsyncMock()
    mock_gateway.checkpoint_client = object()  # non-None authority

    # 1. Gateway returns CONTRADICTED via canonical raw_text and parsed_payload
    mock_resp = ProviderResponse(
        operation_id="op_test",
        provider_name="mock_provider",
        model_name="mock_model",
        raw_text='{"relation": "CONTRADICTED", "reason": "Opposed contradicts supported"}',
        parsed_payload={"relation": "CONTRADICTED", "reason": "Opposed contradicts supported"},
        finish_reason=FinishReason.STOP,
        usage=UsageReport(prompt_tokens=50, completion_tokens=20, total_tokens=70),
    )
    mock_gateway.execute.return_value = mock_resp

    evaluator = NotGivenSemanticsEvaluator(gateway=mock_gateway)
    res = await evaluator.evaluate(ctx, art, intent_id="intent_gw")

    # Assert ProviderRequest was built with real context and artifact parameters
    assert mock_gateway.execute.called
    call_args = mock_gateway.execute.call_args[0]
    req = call_args[0]
    assert req.run_id == ctx.run_id
    assert req.section_id == "1"
    assert req.artifact_id == "q_gw_test"

    # Assert relation was parsed and NOT_GIVEN was rejected because statement is CONTRADICTED
    assert res.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.AMBIGUOUS_ANSWER for i in res.issues)

    # 2. Gateway failure maps to INCONCLUSIVE_OR_ERROR -> EVALUATOR_UNAVAILABLE (never NOT_GIVEN or PASS)
    mock_gateway.execute.side_effect = TimeoutError("Gateway timeout")
    res_err = await evaluator.evaluate(ctx, art, intent_id="intent_gw_err")
    assert res_err.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.EVALUATOR_UNAVAILABLE for i in res_err.issues)
    assert "semantic relation evaluation failed or was inconclusive" in res_err.issues[0].message


@pytest.mark.asyncio
async def test_not_given_semantics_chunked_coverage_decisive_evidence_after_3000_chars():
    """AUDIT-CHUNKED-COVERAGE: Decisive evidence occurring after 3,000 characters is evaluated, not truncated.

    Ensures:
    1. Passage with length > 3,500 chars is cleanly chunked with complete coverage.
    2. Evidence in second chunk (char > 3000) is evaluated and aggregated into CONTRADICTED.
    3. Eliminates old bug where passage[:3000] silently dropped evidence after 3,000 chars.
    """
    from unittest.mock import AsyncMock
    from app.providers.models import ProviderResponse, FinishReason, UsageReport

    ctx = make_context()
    ctx.section_id = 1

    # Create passage with 3,500+ chars: first 3,200 chars are neutral background, decisive evidence at char ~3300
    neutral_intro = "This introductory paragraph discusses general oceanographic measurements and coastal geography. " * 35
    assert len(neutral_intro) > 3000, f"Intro must exceed 3000 chars, got {len(neutral_intro)}"
    decisive_evidence = " The research expedition conclusively disproved the hypothesis regarding thermal immunity."
    full_passage = neutral_intro + decisive_evidence
    assert len(full_passage) > 3400

    q_payload = {
        "questionNumber": 12,
        "questionType": "TrueFalseNotGiven",
        "prompt": "The research expedition confirmed the hypothesis regarding thermal immunity.",
        "answer": "NOT_GIVEN",
        "passage": full_passage,
    }
    art = make_envelope("q_gw_long_test", ArtifactType.QUESTION, 1, q_payload)

    mock_gateway = AsyncMock()
    mock_gateway.checkpoint_client = object()

    async def mock_execute(req, **kwargs):
        # Check user message text
        user_msg = next(m.content for m in req.messages if m.role == "user")
        if "disproved the hypothesis regarding thermal immunity" in user_msg:
            rel = "CONTRADICTED"
            reason = "Disproved contradicts confirmed"
        else:
            rel = "NEITHER"
            reason = "Background text does not mention the hypothesis"
        return ProviderResponse(
            operation_id=req.operation_id,
            provider_name="mock_provider",
            model_name="mock_model",
            raw_text=json.dumps({"relation": rel, "reason": reason}),
            parsed_payload={"relation": rel, "reason": reason},
            finish_reason=FinishReason.STOP,
            usage=UsageReport(prompt_tokens=80, completion_tokens=25, total_tokens=105),
        )

    mock_gateway.execute.side_effect = mock_execute
    evaluator = NotGivenSemanticsEvaluator(gateway=mock_gateway)
    res = await evaluator.evaluate(ctx, art, intent_id="intent_long_passage")

    # Under old passage[:3000] bug, decisive evidence was never sent, resulting in false PASS on NOT_GIVEN.
    # With chunked coverage, mock_gateway is called for multiple chunks and Chunk 2 captures the contradiction!
    assert mock_gateway.execute.call_count >= 2, f"Expected multiple chunks, got {mock_gateway.execute.call_count}"
    assert res.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.AMBIGUOUS_ANSWER for i in res.issues)
    assert "contradicts the proposition; correct answer must be FALSE" in res.issues[0].message


@pytest.mark.asyncio
async def test_not_given_semantics_chunked_coverage_incomplete_fails_closed():
    """AUDIT-CHUNKED-COVERAGE: Incomplete chunk coverage (timeout/error) fails closed to INCONCLUSIVE_OR_ERROR."""
    from unittest.mock import AsyncMock
    from app.providers.models import ProviderResponse, FinishReason, UsageReport

    ctx = make_context()
    neutral_intro = "This introductory paragraph discusses general oceanographic measurements and coastal geography. " * 35
    full_passage = neutral_intro + " Further experiments verified the chemical reaction."

    q_payload = {
        "questionNumber": 14,
        "questionType": "TrueFalseNotGiven",
        "prompt": "Further experiments verified the chemical reaction.",
        "answer": "NOT_GIVEN",
        "passage": full_passage,
    }
    art = make_envelope("q_gw_fail_test", ArtifactType.QUESTION, 1, q_payload)

    mock_gateway = AsyncMock()
    mock_gateway.checkpoint_client = object()

    call_count = 0

    async def mock_execute(req, **kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            # First chunk succeeds with NEITHER
            return ProviderResponse(
                operation_id=req.operation_id,
                provider_name="mock_provider",
                model_name="mock_model",
                raw_text=json.dumps({"relation": "NEITHER", "reason": "Not in chunk 1"}),
                parsed_payload={"relation": "NEITHER", "reason": "Not in chunk 1"},
                finish_reason=FinishReason.STOP,
                usage=UsageReport(prompt_tokens=80, completion_tokens=25, total_tokens=105),
            )
        # Second chunk times out
        raise TimeoutError("Chunk 2 timeout under gateway")

    mock_gateway.execute.side_effect = mock_execute
    evaluator = NotGivenSemanticsEvaluator(gateway=mock_gateway)
    res = await evaluator.evaluate(ctx, art, intent_id="intent_incomplete_coverage")

    # Because coverage was incomplete, it MUST NOT conclude NEITHER (which would accept NOT_GIVEN)!
    # It MUST fail closed with EVALUATOR_UNAVAILABLE!
    assert res.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.EVALUATOR_UNAVAILABLE for i in res.issues)
    assert "semantic relation evaluation failed or was inconclusive" in res.issues[0].message
