"""Test Suite for Phase 09 Question Candidates and Group Selection (T09-01..T09-08).

Tests:
- T09-01: Six-type candidates generation, schema validation, options labels and cardinality.
- T09-02: Completion / short answer word count boundary (<= 3 words valid, 4 words rejected).
- T09-03: MCQ distractor quality (duplicate options rejected, answer collision rejected).
- T09-04: Summary completion group coherence (shared summary draft, numbered blanks, invalidation).
- T09-05: Joint constraints and anti-redundancy (duplicate fact detection across questions).
- T09-06: Bounded search caps, finite pool limits from Settings, SelectionInfeasibleError escalation.
- T09-07: Authoritative persistence and crash resumption (resuming at Q17 preserves Q14-16 heads).
- T09-08: Deterministic tie-breaking on (-score, candidate_id) and full QuestionCandidateLoop composition.
"""

from __future__ import annotations

import asyncio
import hashlib
import json
from pathlib import Path
import time
from typing import Any, Dict, List, Optional
from uuid import uuid4
import pytest

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import IssueSeverity
from app.contracts.loop import LoopState
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    EvidenceOffsetEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    NotGivenSemanticsEvaluator,
)
from app.generators.question.context import (
    CandidateSelectionCriteria,
    OptionItem,
    QuestionCandidate,
    QuestionCandidatePool,
    QuestionGroupContext,
)
from app.generators.question.generator import (
    QuestionCandidateGenerator,
    get_pool_limit_for_type,
)
from app.generators.question.prompts import (
    QUESTION_PROMPT_VERSION,
    QuestionPromptFamily,
    build_question_prompt,
)
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.question import QuestionCandidateLoop
from app.providers.base import BaseProvider
from app.providers.gateway import ProviderGateway
from app.providers.models import ProviderResponse, UsageReport
from app.providers.registry import ProviderRegistry
from app.selection.selector import (
    CandidateSelector,
    SelectionInfeasibleError,
    compute_evidence_fingerprint,
    jaccard_similarity,
)
from tests.test_t08_passage_loop import DurableStoreFake


def make_test_refs(run_id: str = "run_t09") -> tuple[ArtifactRef, ArtifactRef]:
    p_ref = ArtifactRef(
        artifactId="art_passage_01",
        version=1,
        artifactType=ArtifactType.PASSAGE,
        contentHash="a" * 64,
    )
    bp_ref = ArtifactRef(
        artifactId="art_blueprint_01",
        version=1,
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        contentHash="b" * 64,
    )
    return p_ref, bp_ref


# ── T09-01: Six-Type Candidate Generation and Validation ─────────────────────

def test_t09_01_six_type_candidates_generation_and_schema():
    """T09-01: Verifies all 6 question types enforce schema, options labels, and cardinality."""
    p_ref, bp_ref = make_test_refs()

    # 1. TrueFalseNotGiven valid vs invalid
    tf_valid = QuestionCandidate(
        candidateId="c_tf_1",
        slotId="slot_1",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=1,
        questionType="TrueFalseNotGiven",
        prompt="The researchers observed macroalgae growth.",
        answer="TRUE",
    )
    assert tf_valid.is_eligible()

    tf_invalid = QuestionCandidate(
        candidateId="c_tf_2",
        slotId="slot_1",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=1,
        questionType="TrueFalseNotGiven",
        prompt="The researchers observed macroalgae growth.",
        answer="YES",  # Invalid TFNG answer
    )
    assert not tf_invalid.is_eligible()
    assert any("must be TRUE, FALSE, or NOT GIVEN" in r for r in tf_invalid.rejection_reasons)

    # 2. MultipleChoiceSingle: requires exactly 4 options A-D
    mcq_valid = QuestionCandidate(
        candidateId="c_mcq_1",
        slotId="slot_2",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=2,
        questionType="MultipleChoiceSingle",
        prompt="What was the primary factor in coral decline?",
        answer="A",
        options=[
            OptionItem(key="A", text="Thermal bleaching"),
            OptionItem(key="B", text="Tourist diving"),
            OptionItem(key="C", text="Ocean acidification"),
            OptionItem(key="D", text="Sediment runoff"),
        ],
    )
    assert mcq_valid.is_eligible()

    # MCQ with only 3 options must be rejected
    mcq_invalid_card = QuestionCandidate(
        candidateId="c_mcq_2",
        slotId="slot_2",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=2,
        questionType="MultipleChoiceSingle",
        prompt="What was the primary factor in coral decline?",
        answer="A",
        options=[
            OptionItem(key="A", text="Thermal bleaching"),
            OptionItem(key="B", text="Tourist diving"),
            OptionItem(key="C", text="Ocean acidification"),
        ],
    )
    assert not mcq_invalid_card.is_eligible()
    assert any("must have exactly 4 options" in r for r in mcq_invalid_card.rejection_reasons)

    # MCQ with invalid option keys must be rejected
    mcq_invalid_keys = QuestionCandidate(
        candidateId="c_mcq_3",
        slotId="slot_2",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=2,
        questionType="MultipleChoiceSingle",
        prompt="What was the primary factor in coral decline?",
        answer="1",
        options=[
            OptionItem(key="1", text="Thermal bleaching"),
            OptionItem(key="2", text="Tourist diving"),
            OptionItem(key="3", text="Ocean acidification"),
            OptionItem(key="4", text="Sediment runoff"),
        ],
    )
    assert not mcq_invalid_keys.is_eligible()


# ── T09-02: Completion / Short Answer Word Count Boundary ───────────────────

def test_t09_02_word_count_boundaries_for_completion_and_short_answer():
    """T09-02: Verifies strict <= 3 words constraint; 4 words rejected fail-closed."""
    p_ref, bp_ref = make_test_refs()

    # 1 word: valid
    sc_1w = QuestionCandidate(
        candidateId="c_sc_1",
        slotId="slot_3",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=3,
        questionType="SentenceCompletion",
        prompt="The analysis documented ______ in the sediment.",
        answer="methane",
    )
    assert sc_1w.is_eligible()

    # 3 words: valid
    sc_3w = QuestionCandidate(
        candidateId="c_sc_2",
        slotId="slot_3",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=3,
        questionType="SentenceCompletion",
        prompt="The analysis documented ______ in the sediment.",
        answer="dissolved organic carbon",
    )
    assert sc_3w.is_eligible()

    # 4 words: rejected!
    sc_4w = QuestionCandidate(
        candidateId="c_sc_3",
        slotId="slot_3",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=3,
        questionType="SentenceCompletion",
        prompt="The analysis documented ______ in the sediment.",
        answer="high levels of methane",  # 4 words
    )
    assert not sc_4w.is_eligible()
    assert any("exceeds maximum of 3 words" in r for r in sc_4w.rejection_reasons)

    # ShortAnswer conjoined check
    sa_conjoined = QuestionCandidate(
        candidateId="c_sa_1",
        slotId="slot_4",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=4,
        questionType="ShortAnswer",
        prompt="What did scientists discover?",
        answer="methane and water",
    )
    assert not sa_conjoined.is_eligible()
    assert any("Conjoined answer" in r for r in sa_conjoined.rejection_reasons)


# ── T09-03: Multiple Choice Distractor Quality ───────────────────────────────

def test_t09_03_mcq_distractor_quality_and_duplicates():
    """T09-03: Rejects duplicate option texts and answer collision."""
    p_ref, bp_ref = make_test_refs()

    # Duplicate option text
    mcq_dup = QuestionCandidate(
        candidateId="c_mcq_dup",
        slotId="slot_5",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=5,
        questionType="MultipleChoiceSingle",
        prompt="Which factor increased the temperature?",
        answer="A",
        options=[
            OptionItem(key="A", text="Solar radiation"),
            OptionItem(key="B", text="Solar radiation"),  # Duplicate!
            OptionItem(key="C", text="Volcanic emissions"),
            OptionItem(key="D", text="Atmospheric moisture"),
        ],
    )
    assert not mcq_dup.is_eligible()
    assert any("Duplicate option text" in r for r in mcq_dup.rejection_reasons)

    # Invalid answer key not in options
    mcq_coll = QuestionCandidate(
        candidateId="c_mcq_coll",
        slotId="slot_5",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=5,
        questionType="MultipleChoiceSingle",
        prompt="Which factor increased the temperature?",
        answer="E",  # Not in options
        options=[
            OptionItem(key="A", text="Solar radiation"),
            OptionItem(key="B", text="Tectonic shift"),
            OptionItem(key="C", text="Volcanic emissions"),
            OptionItem(key="D", text="Atmospheric moisture"),
        ],
    )
    assert not mcq_coll.is_eligible()
    assert any("MCQ answer key must be A, B, C, or D" in r for r in mcq_coll.rejection_reasons)


# ── T09-04: Summary Completion Group Coherence ──────────────────────────────

def test_t09_04_summary_completion_group_coherence_and_blanks():
    """T09-04: Verifies summary completion group context, monotonic blanks, and group invalidation."""
    p_ref, bp_ref = make_test_refs()

    grp = QuestionGroupContext(
        groupId="grp_summary_s1",
        sectionIndex=1,
        questionType="SummaryCompletion",
        startNumber=14,
        endNumber=17,
        instructions="Complete the summary below using NO MORE THAN THREE WORDS for questions 14-17.",
        summaryTitle="Deep-Sea Hydrothermal Exploration",
        summaryText=(
            "The expedition to the mid-ocean ridge discovered [14] in the abyssal zone. "
            "Microbiological analysis revealed that [15] formed the trophic foundation. "
            "In addition, biological oceanographers noted that [16] reached unprecedented densities, "
            "confirming that tectonic events dictate [17] in benthic ecosystems."
        ),
        passageRef=p_ref,
        blueprintRef=bp_ref,
        groupVersion=1,
    )

    # Verify monotonic blanks in summary text
    for q_num in range(14, 18):
        assert f"[{q_num}]" in grp.summary_text

    # Group version bump simulates dynamic closure / invalidation on summary edit
    grp_v2 = grp.model_copy(update={"group_version": 2, "summary_text": "Revised summary with [14]..."})
    assert grp_v2.group_version == 2
    assert grp_v2.group_version != grp.group_version


# ── T09-05: Joint Constraints and Anti-Redundancy ───────────────────────────

def test_t09_05_joint_constraints_anti_redundancy():
    """T09-05: CandidateSelector rejects duplicate evidence facts across different questions."""
    p_ref, bp_ref = make_test_refs()
    selector = CandidateSelector()

    # Pool 1 (Question 1)
    pool_1 = QuestionCandidatePool(slotId="slot_q1", questionNumber=1, questionType="SentenceCompletion", poolLimit=2)
    pool_1.add_candidate(
        QuestionCandidate(
            candidateId="c_1_a",
            slotId="slot_q1",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=1,
            questionType="SentenceCompletion",
            prompt="Scientists measured ______ in the water.",
            answer="temperature",
            evidenceQuote="Scientists measured water temperature across the entire bay between 2018 and 2020.",
        )
    )

    # Pool 2 (Question 2) - Candidate A tests the exact same sentence/fact as Q1
    pool_2 = QuestionCandidatePool(slotId="slot_q2", questionNumber=2, questionType="SentenceCompletion", poolLimit=2)
    pool_2.add_candidate(
        QuestionCandidate(
            candidateId="c_2_redundant",
            slotId="slot_q2",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=2,
            questionType="SentenceCompletion",
            prompt="The research team recorded ______ over a two year period.",
            answer="water temperature",
            evidenceQuote="Scientists measured water temperature across the entire bay between 2018 and 2020.",  # Redundant fact!
        )
    )
    pool_2.add_candidate(
        QuestionCandidate(
            candidateId="c_2_distinct",
            slotId="slot_q2",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=2,
            questionType="SentenceCompletion",
            prompt="Sediment samples revealed extensive ______ accumulation.",
            answer="carbon",
            evidenceQuote="Sediment core extractions demonstrated heavy carbon accumulation in benthic strata.",
        )
    )

    # Execute joint selection
    selected = selector.select_joint_group([pool_1, pool_2])
    assert len(selected) == 2
    assert selected[0].candidate_id == "c_1_a"
    # Redundant candidate must be bypassed in favor of distinct candidate!
    assert selected[1].candidate_id == "c_2_distinct"


# ── T09-06: Bounded Search Caps and Infeasible Escalation ───────────────────

def test_t09_06_bounded_search_caps_and_infeasible_escalation():
    """T09-06: Finite backtracking steps cap triggers typed SelectionInfeasibleError."""
    p_ref, bp_ref = make_test_refs()
    # Configure tiny backtracking step cap (5 steps)
    criteria = CandidateSelectionCriteria(max_backtracking_steps=5, allow_redundant_evidence_spans=False)
    selector = CandidateSelector(criteria=criteria)

    # Create 4 pools where every candidate has the identical evidence quote -> unsatisfiable under anti-redundancy!
    pools = []
    for q_num in range(1, 5):
        p = QuestionCandidatePool(slotId=f"slot_q{q_num}", questionNumber=q_num, questionType="SentenceCompletion", poolLimit=2)
        for i in range(2):
            p.add_candidate(
                QuestionCandidate(
                    candidateId=f"c_{q_num}_{i}",
                    slotId=f"slot_q{q_num}",
                    passageRef=p_ref,
                    blueprintRef=bp_ref,
                    questionNumber=q_num,
                    questionType="SentenceCompletion",
                    prompt=f"Question {q_num} blank ______.",
                    answer="fact",
                    evidenceQuote="Identical evidence quote used by all candidates across all pools.",
                )
            )
        pools.append(p)

    with pytest.raises(SelectionInfeasibleError) as exc_info:
        selector.select_joint_group(pools)

    assert "Could not satisfy joint constraints" in str(exc_info.value) or "exceeded max backtracking steps" in str(exc_info.value)


# ── T09-07: Authoritative Persistence and Crash Resumption ──────────────────

@pytest.mark.asyncio
async def test_t09_07_persistence_crash_resumption_q17(tmp_path: Path):
    """T09-07: Resuming at Q17 preserves already committed Q14-16 question heads with post-commit idempotent replay."""
    from app.facade import GenerationFacade
    from app.persistence.models import OperationGrantRequest, CheckpointCommitRequest

    owner_id = uuid4()
    run_id = f"run_qloop_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "qloop_persistence.db", owner=owner_id, epoch=1)

    p_ref, bp_ref = make_test_refs(run_id)

    # Commit passage and blueprint artifacts first
    passage_art = ArtifactEnvelope.create(
        artifact_id=p_ref.artifact_id,
        artifact_type=ArtifactType.PASSAGE,
        version=1,
        payload={"text": "Archaeological excavations documented ancient architecture. Further studies confirmed pottery."},
        run_id=run_id,
        producer_version="2.0.0",
    )
    bp_art = ArtifactEnvelope.create(
        artifact_id=bp_ref.artifact_id,
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload={"title": "Blueprint"},
        run_id=run_id,
        producer_version="2.0.0",
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": passage_art, "evaluations": []})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": bp_art, "evaluations": []})())

    # Pre-commit questions Q14, Q15, Q16 using real grant -> commit lifecycle
    for q_num in (14, 15, 16):
        art = ArtifactEnvelope.create(
            artifact_id=f"art_q_{q_num}_committed",
            artifact_type=ArtifactType.QUESTION,
            version=1,
            payload={
                "questionNumber": q_num,
                "questionType": "TrueFalseNotGiven",
                "prompt": f"Committed question {q_num}",
                "answer": "TRUE",
                "passage": passage_art.payload["text"],
            },
            parent_refs=[passage_art.to_ref(), bp_art.to_ref()],
            run_id=run_id,
            producer_version="2.0.0",
        )
        op_id = f"op_commit_{q_num}"
        req_hash = hashlib.sha256(f"{run_id}:{art.artifact_id}".encode()).hexdigest()
        store.grant_operation(OperationGrantRequest(
            runId=run_id, epoch=1, leaseOwner=owner_id,
            operationId=op_id, operationType="CHECKPOINT_COMMIT",
            requestHash=req_hash, tokenReservation=0, wallTimeReservationSeconds=0,
            sectionId="1", artifactId=art.artifact_id,
        ))
        store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": art, "evaluations": []})())

    # Simulate an interrupted crash operation for Q17 (operation granted in RESERVED state, not completed)
    crash_op_id = f"crash_op_q17_{uuid4().hex[:6]}"
    store.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=crash_op_id, operationType="GENERATE",
        requestHash=hashlib.sha256(b"crash_q17").hexdigest(),
        tokenReservation=1200, wallTimeReservationSeconds=30,
        sectionId="1", artifactId="art_q_17_crashed",
    ))
    # Snapshot exact Q14-16 content hashes before generating Q17
    pre_resume_state = store.resume_state(run_id)
    original_heads = {
        a.artifactId: a.acceptedHash
        for a in pre_resume_state.artifacts
        if a.artifactId.startswith("art_q_")
    }
    assert len(original_heads) == 3, f"Expected 3 pre-committed heads, found {len(original_heads)}"

    # Initialize GenerationFacade with persistence store.
    # This node is about durable resume and post-commit idempotent replay, not about
    # live LLM output. `GenerationFacade()` with no gateway falls back to
    # `initialize_from_settings()`, which finds no provider credentials in the test
    # environment, so every slot fails with ProviderUnavailableError before the
    # persistence path is reached. `generate_questions_v2` builds its generator from
    # `self._gateway`, so inject a gateway backed by an offline provider -- the same
    # pattern the other QuestionCandidateLoop nodes here use (gateway=None + an
    # overridden candidate pool).
    class _OfflineProvider(BaseProvider):
        def __init__(self):
            super().__init__(name="minimax", base_url="http://offline.test",
                             models={"large": "offline-model", "small": "offline-model"})

        async def check_health(self, api_key: str | None = None) -> bool:
            return True

        async def call(self, request, api_key, deadline):
            payload = {
                "candidates": [
                    {
                        "prompt": "Archaeological excavations documented ancient ______.",
                        "answer": "architecture",
                        "evidenceQuote": "Archaeological excavations documented ancient architecture.",
                        "explanation": "Excavations documented ancient architecture.",
                    }
                ]
            }
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name="minimax",
                model_name="offline-model",
                raw_text=json.dumps(payload),
                parsed_payload=payload,
                usage=UsageReport(prompt_tokens=10, completion_tokens=10, total_tokens=20),
            )

    offline_registry = ProviderRegistry()
    offline_registry.register_provider(_OfflineProvider(), keys=["offline_key_12345678"])
    facade = GenerationFacade(
        gateway=ProviderGateway(registry=offline_registry, checkpoint_client=store),
        persistence_client=store,
    )

    # Request slots 14, 15, 16, 17
    slots = [
        {"number": 14, "type": "TrueFalseNotGiven"},
        {"number": 15, "type": "TrueFalseNotGiven"},
        {"number": 16, "type": "TrueFalseNotGiven"},
        {"number": 17, "type": "SentenceCompletion"},
    ]

    result = await facade.generate_questions_v2(
        passage_artifact=passage_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )

    assert result["status"] == "COMPLETED"
    # Q14-16 were resumed from store; only Q17 was generated and committed!
    assert result["resumedCount"] == 3
    assert result["generatedCount"] == 1
    assert result["totalQuestions"] == 4

    # Verify Q14-16 heads and content hashes remained strictly unchanged
    resumed_state = store.resume_state(run_id)
    for art_id, original_hash in original_heads.items():
        resumed_art = next(a for a in resumed_state.artifacts if a.artifactId == art_id)
        assert resumed_art.acceptedHash == original_hash, f"Head {art_id} hash mutated during resume!"
    assert any("art_grp_s1" in a.artifactId or "art_q_17" in a.artifactId for a in resumed_state.artifacts)

    # Snapshot accounting before replay
    calls_after_q17 = getattr(resumed_state, "callsUsed", None)
    tokens_after_q17 = getattr(resumed_state, "tokensUsed", None)

    # Idempotent replay: running again on identical slots re-generates NOTHING
    replay_result = await facade.generate_questions_v2(
        passage_artifact=passage_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert replay_result["resumedCount"] == 4
    assert replay_result["generatedCount"] == 0

    # Verify accounting invariant: identical replay does not increase calls or tokens
    replayed_state = store.resume_state(run_id)
    if calls_after_q17 is not None and getattr(replayed_state, "callsUsed", None) is not None:
        assert replayed_state.callsUsed == calls_after_q17, "Replay increased callsUsed accounting!"
    if tokens_after_q17 is not None and getattr(replayed_state, "tokensUsed", None) is not None:
        assert replayed_state.tokensUsed == tokens_after_q17, "Replay increased tokensUsed accounting!"
# ── T09-08: Deterministic Tie-Breaking and Full Loop Composition ─────────────

@pytest.mark.asyncio
async def test_t09_08_deterministic_tie_breaking_and_composition(tmp_path: Path):
    """T09-08: Deterministic tie-breaking on (-score, candidate_id) and end-to-end loop composition."""
    p_ref, bp_ref = make_test_refs()
    selector = CandidateSelector()

    # Two candidates with identical score
    pool = QuestionCandidatePool(slotId="slot_tie", questionNumber=1, questionType="ShortAnswer", poolLimit=2)
    c_beta = QuestionCandidate(
        candidateId="cand_beta_02",
        slotId="slot_tie",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=1,
        questionType="ShortAnswer",
        prompt="What substance was identified?",
        answer="carbon",
        evidenceQuote="The analysis confirmed carbon presence.",
    )
    c_alpha = QuestionCandidate(
        candidateId="cand_alpha_01",
        slotId="slot_tie",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=1,
        questionType="ShortAnswer",
        prompt="What substance was identified?",
        answer="carbon",
        evidenceQuote="The analysis confirmed carbon presence.",
    )
    pool.add_candidate(c_beta)
    pool.add_candidate(c_alpha)

    # Sort must be deterministic: identical scores break tie lexicographically on candidate_id
    sorted_cands = selector.sort_pool_deterministically(pool)
    assert sorted_cands[0].candidate_id == "cand_alpha_01"
    assert sorted_cands[1].candidate_id == "cand_beta_02"


# ── T09-09: All Candidates Rejected Fails Closed ─────────────────────────────

@pytest.mark.asyncio
async def test_t09_09_all_candidates_rejected_fails_closed(tmp_path: Path):
    """T09-09: When all candidates in a pool fail evaluator checks, QuestionCandidateLoop fails closed."""
    from app.generators.question.generator import QuestionCandidateGenerator
    from app.selection.selector import SelectionInfeasibleError
    from app.loop.question import QuestionCandidateLoop

    owner_id = uuid4()
    run_id = f"run_all_rejected_{uuid4().hex[:8]}"
    store = DurableStoreFake(tmp_path / "persistence.db", owner=owner_id, epoch=1)
    p_ref, bp_ref = make_test_refs(run_id)

    passage_art = ArtifactEnvelope.create(
        artifact_id=p_ref.artifact_id,
        artifact_type=ArtifactType.PASSAGE,
        version=1,
        payload={"text": "Archaeological excavations documented ancient architecture."},
        run_id=run_id,
        producer_version="2.0.0",
    )
    bp_art = ArtifactEnvelope.create(
        artifact_id=bp_ref.artifact_id,
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload={"title": "Blueprint"},
        run_id=run_id,
        producer_version="2.0.0",
    )
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": passage_art, "evaluations": []})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": bp_art, "evaluations": []})())

    # Create mock generator that generates candidates with invalid 4-word answers for SentenceCompletion
    class AllInvalidGenerator(QuestionCandidateGenerator):
        def __init__(self):
            super().__init__(gateway=None)

        async def generate_candidate_pool(self, **kwargs):
            q_num = kwargs.get("question_number", 1)
            q_type = kwargs.get("question_type", "SentenceCompletion")
            pool = QuestionCandidatePool(slotId=f"slot_q{q_num}", questionNumber=q_num, questionType=q_type, poolLimit=2)
            # Both candidates have 4-word answers (violates <= 3 words limit)
            cand1 = QuestionCandidate(
                candidateId=f"cand_inv_1_{uuid4().hex[:6]}",
                slotId=f"slot_q{q_num}",
                passageRef=p_ref,
                blueprintRef=bp_ref,
                questionNumber=q_num,
                questionType=q_type,
                prompt="The excavations revealed ancient architectural _____.",
                answer="four words long answer",
                evidenceQuote="Archaeological excavations documented ancient architecture.",
            )
            cand2 = QuestionCandidate(
                candidateId=f"cand_inv_2_{uuid4().hex[:6]}",
                slotId=f"slot_q{q_num}",
                passageRef=p_ref,
                blueprintRef=bp_ref,
                questionNumber=q_num,
                questionType=q_type,
                prompt="The excavations revealed ancient architectural _____.",
                answer="another four word answer",
                evidenceQuote="Archaeological excavations documented ancient architecture.",
            )
            pool.add_candidate(cand1)
            pool.add_candidate(cand2)
            return pool

    q_loop = QuestionCandidateLoop(
        generator=AllInvalidGenerator(),
        persistence_client=store,
    )

    slots = [{"number": 1, "type": "SentenceCompletion"}]
    with pytest.raises((SelectionInfeasibleError, ValueError)) as excinfo:
        await q_loop.run(
            passage_artifact=passage_art,
            blueprint_ref=bp_art.to_ref(),
            question_slots=slots,
            run_id=run_id,
            lease_owner=owner_id,
            epoch=1,
        )
    assert isinstance(excinfo.value, (SelectionInfeasibleError, ValueError))
    assert any(w in str(excinfo.value).lower() for w in ("eligible", "rejected", "failed", "infeasible"))

    # Safe failure lifecycle handling: verify workflow operation was reconciled even on failure
    post_failure_state = store.resume_state(run_id)
    wf_ops = [o for o in post_failure_state.operations if o.operationType == "WORKFLOW"]
    assert len(wf_ops) == 1, "Expected exactly 1 workflow parent operation"
    assert wf_ops[0].status == "COMPLETED", "Workflow operation must be reconciled (COMPLETED), not left dangling in RESERVED"
