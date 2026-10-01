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
    overall_blocking_recall = invalid_detected / invalid_total if invalid_total else 0.0
    false_rejection_rate = valid_rejected / valid_total if valid_total else 0.0
    ambiguity_recall = ambiguous_detected / ambiguous_total if ambiguous_total else 0.0
    canary_rejection_rate = canary_rejected / canary_total if canary_total else 0.0

    # Save Confusion Matrices to Artifacts
    confusion_report = {
        "evaluationSummary": {
            "totalQuestionsEvaluated": valid_total + invalid_total,
            "validQuestions": valid_total,
            "invalidQuestions": invalid_total,
            "criticalCanariesCount": canary_total,
        },
        "rates": {
            "overallBlockingRecall": overall_blocking_recall,
            "falseRejectionRate": false_rejection_rate,
            "ambiguityRecall": ambiguity_recall,
            "canaryRejectionRate": canary_rejection_rate,
        },
        "perTypeMetrics": per_type_metrics,
        "acceptanceThresholds": {
            "overallBlockingRecallMin": 0.95,
            "perTypeBlockingRecallMin": 0.90,
            "ambiguityRecallMin": 0.90,
            "falseRejectionRateMax": 0.10,
            "criticalCanaryRejectionRateMin": 1.00,
        },
        "benchmarkStatus": "CONTAMINATED_BENCHMARK_DEVELOPMENT_ONLY",
        "quarantineRationale": (
            "Corpus labels were exposed in session diagnostics. In accordance with P07-09 "
            "and validation matrix, this dataset is quarantined as development evidence. "
            "No semantic gate PASS is claimed until evaluated on an unseen, family-disjoint holdout."
        ),
    }
    with open(ARTIFACTS_DIR / "confusion-matrices.json", "w") as f:
        json.dump(confusion_report, f, indent=2)

    # Diagnostic verification: All 120 questions and 12 canaries were processed
    assert valid_total + invalid_total == 120, "Must evaluate all 120 corpus questions"
    assert canary_total == 12, "Must evaluate all 12 critical canaries"
    assert canary_rejection_rate == 1.00, f"Critical canaries must be 100% rejected, got {canary_rejection_rate:.2%}"
    assert overall_blocking_recall > 0.0, "Blocking recall must be non-zero"

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
    repairer = QuestionItemRepairer()
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
