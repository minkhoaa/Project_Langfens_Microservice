"""Phase 15 V2 Repair & Closure Regression Tests (T-RC1 .. T-RC7).

Verifies:
- T-RC1: QuestionItemRepairer recovers single-question ArtifactType.QUESTION payloads from
         SCHEMA_VIOLATION (empty answer) via candidate-pool selection and gateway regeneration.
- T-RC2: QuestionItemRepairer preserves fail-closed RepairJustificationError invariants when
         no valid candidate or passage-grounded span exists.
- T-RC3: PaperSurgicalRepairer.repair_paper produces replacement question and section envelopes,
         updates sectionRefs/questionRefs/parent_refs, preserves unaffected hashes bit-for-bit,
         and handles .NET worker section payload conventions (dual number/questionNumber).
- T-RC4: PaperRepairerAdapter.repair persists replacement question and section heads via
         CheckpointClient, updates context.input_dependencies and accepted_dependencies,
         and passes DependencyValidator.validate_dependency_freshness and PaperLeakageEvaluator.
- T-RC5: PassageSentenceRepairer expands short passages (< 720 words) from source_text while
         softening certainty boosters in added sentences, updating payload['text'], and
         passing GroundingFidelityEvaluator without introducing OVERSTATED_CERTAINTY.
- T-RC6: SectionSurgicalRepairer sanitizes intra-section exact answer leakage messages.
- T-RC7: Empty paper repair directive fails closed with RepairJustificationError (and ValueError).
"""

from __future__ import annotations

from typing import Any, Dict, List
from pathlib import Path
from uuid import uuid4

import pytest

from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.paper import assemble_immutable_paper
from app.evaluators.deterministic import PassageStyleEvaluator, PassageWordCountEvaluator
from app.evaluators.paper import PaperLeakageEvaluator
from app.evaluators.semantic import GroundingFidelityEvaluator
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.dependencies import DependencyValidator
from app.loop.paper import PaperRepairerAdapter
from app.repair.base import RepairJustificationError
from app.repair.paper import (
    PaperRepairDirective,
    PaperRepairRouter,
    PaperSurgicalRepairer,
)
from app.repair.passage import PassageSentenceRepairer
from app.repair.question import QuestionItemRepairer
from app.repair.section import SectionSurgicalRepairer


def _make_worker_section_envelope(
    sec_id: int,
    run_id: str,
    bp_ref: ArtifactRef,
    q_overrides: Dict[int, Dict[str, Any]] | None = None,
) -> tuple[ArtifactEnvelope, ArtifactRef, List[ArtifactEnvelope]]:
    """Builds a realistic .NET worker-shaped Section envelope + passage ref + question envelopes."""
    q_overrides = q_overrides or {}
    sentences = [
        "The purification framework operates exclusively on quantum states where the target form is known a priori and is prepared by multiple independent applications of a noise channel to initialized copies."
    ]
    for w in range(1, 58):
        sentences.append(
            f"Dataset_{sec_id}_{w} confirms that specimen_{sec_id}_{w} exhibits physical observations "
            f"regarding marker_{sec_id}_{w} across condition_{sec_id}_{w} within apparatus_{sec_id}_{w}."
        )
    passage_text = " ".join(sentences)
    p_env = ArtifactEnvelope.create(
        artifact_id=f"art_passage_s{sec_id}",
        artifact_type=ArtifactType.PASSAGE,
        run_id=run_id,
        payload={"text": passage_text, "passage": passage_text, "wordCount": len(passage_text.split())},
        producer_version="2.0.0",
        version=1,
        section_id=sec_id,
        parent_refs=[bp_ref],
        schema_version="2.0.0",
    )
    p_ref = p_env.to_ref()

    if sec_id == 1:
        g1_type, g1_nums = "TRUE_FALSE_NOT_GIVEN", list(range(1, 8))
        g2_type, g2_nums = "SENTENCE_COMPLETION", list(range(8, 14))
    elif sec_id == 2:
        g1_type, g1_nums = "MULTIPLE_CHOICE_SINGLE", list(range(14, 20))
        g2_type, g2_nums = "SUMMARY_COMPLETION", list(range(20, 27))
    else:
        g1_type, g1_nums = "YES_NO_NOT_GIVEN", list(range(27, 34))
        g2_type, g2_nums = "SHORT_ANSWER", list(range(34, 41))

    q_envs: List[ArtifactEnvelope] = []
    q_refs: List[ArtifactRef] = []

    def _build_group_questions(q_type: str, nums: List[int]) -> List[Dict[str, Any]]:
        items: List[Dict[str, Any]] = []
        for idx_in_grp, n in enumerate(nums):
            ev_sent = sentences[(n % (len(sentences) - 1)) + 1]
            if q_type in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
                tf_opts = ["TRUE", "FALSE", "NOT GIVEN"] if q_type == "TRUE_FALSE_NOT_GIVEN" else ["YES", "NO", "NOT GIVEN"]
                tf_ans = ("TRUE" if idx_in_grp % 2 == 0 else "FALSE") if q_type == "TRUE_FALSE_NOT_GIVEN" else ("YES" if idx_in_grp % 2 == 0 else "NO")
                q_dict: Dict[str, Any] = {
                    "number": n,
                    "questionNumber": n,
                    "questionType": q_type,
                    "prompt": f"Statement_{n} evaluates whether specimen_{sec_id}_{n} displays marker_{sec_id}_{n} under condition_{sec_id}_{n}.",
                    "answer": tf_ans,
                    "options": tf_opts,
                    "evidenceQuote": ev_sent,
                    "explanation": f"Question {n} verified directly against sentence {n} in section {sec_id}.",
                }
            elif q_type == "MULTIPLE_CHOICE_SINGLE":
                mcq_ans = ["A", "B", "C", "D"][idx_in_grp % 4]
                q_dict = {
                    "number": n,
                    "questionNumber": n,
                    "questionType": q_type,
                    "prompt": f"Query_{n} asks which outcome characterizes specimen_{sec_id}_{n} inside apparatus_{sec_id}_{n}?",
                    "answer": mcq_ans,
                    "options": [
                        f"A. Finding_{n}_alpha",
                        f"B. Finding_{n}_beta",
                        f"C. Finding_{n}_gamma",
                        f"D. Finding_{n}_delta",
                    ],
                    "evidenceQuote": ev_sent,
                    "explanation": f"Question {n} verified directly against sentence {n} in section {sec_id}.",
                }
            else:
                q_dict = {
                    "number": n,
                    "questionNumber": n,
                    "questionType": q_type,
                    "prompt": f"Item_{n} notes that specimen_{sec_id}_{n} exhibits [{n}] regarding marker_{sec_id}_{n}.",
                    "answer": "physical observations",
                    "options": [],
                    "evidenceQuote": ev_sent,
                    "explanation": f"Question {n} verified directly against sentence {n} in section {sec_id}.",
                }
            if n in q_overrides:
                q_dict.update(q_overrides[n])
            q_env = ArtifactEnvelope.create(
                artifact_id=f"art_q_{n}",
                artifact_type=ArtifactType.QUESTION,
                run_id=run_id,
                payload=dict(q_dict),
                producer_version="2.0.0",
                version=1,
                section_id=sec_id,
                parent_refs=[p_ref, bp_ref],
                schema_version="2.0.0",
            )
            q_envs.append(q_env)
            q_refs.append(q_env.to_ref())
            items.append(q_dict)
        return items

    g1_qs = _build_group_questions(g1_type, g1_nums)
    g2_qs = _build_group_questions(g2_type, g2_nums)

    sec_payload = {
        "sectionId": sec_id,
        "title": f"Section {sec_id} Title",
        "passage": passage_text,
        "source": {
            "pmcid": f"PMC1350000{sec_id}",
            "title": f"Source {sec_id}",
            "doi": f"10.1000/test.{sec_id}",
            "url": f"https://example.org/{sec_id}",
            "license": "CC BY 4.0",
            "wordCount": len(passage_text.split()),
            "authors": ["Author A"],
        },
        "passageRef": p_ref.model_dump(mode="json", by_alias=True),
        "blueprintRef": bp_ref.model_dump(mode="json", by_alias=True),
        "questionRefs": [qr.model_dump(mode="json", by_alias=True) for qr in q_refs],
        "evaluationsSummary": {
            "freshEvaluations": True,
            "hasStaleDependencies": False,
            "solverCovered": True,
            "adversaryCovered": True,
            "acceptedEvaluationRefs": (
                [f"eval_solver_{qr.artifact_id}_v{qr.version}" for qr in q_refs]
                + [f"eval_adversary_{qr.artifact_id}_v{qr.version}" for qr in q_refs]
                + [f"eval_gf_{p_env.artifact_id}"]
            ),
            "passageHash": p_env.content_hash,
            "blueprintHash": bp_ref.content_hash,
            "questionCount": len(q_refs),
            "assembledFromAcceptedRefs": True,
        },
        "groups": [
            {
                "groupId": f"grp_s{sec_id}_1",
                "questionType": g1_type,
                "instructions": "Answer the questions.",
                "questions": g1_qs,
            },
            {
                "groupId": f"grp_s{sec_id}_2",
                "questionType": g2_type,
                "instructions": "Complete the items.",
                "questions": g2_qs,
            },
        ],
    }
    sec_env = ArtifactEnvelope.create(
        artifact_id=f"art_section_{sec_id}",
        artifact_type=ArtifactType.SECTION,
        run_id=run_id,
        payload=sec_payload,
        producer_version="2.0.0",
        version=1,
        section_id=sec_id,
        parent_refs=[p_ref, bp_ref] + q_refs,
        schema_version="2.0.0",
    )
    return sec_env, p_ref, q_envs


@pytest.mark.asyncio
async def test_trc1_question_item_repairer_recovers_empty_answer_from_candidates():
    """T-RC1: Single-question ArtifactType.QUESTION with empty answer recovers from candidate pool."""
    run_id = "run_trc1"
    passage_text = "Researchers observed that cortical plasticity enhances memory consolidation during sleep."
    payload = {
        "questionNumber": 20,
        "questionType": "SUMMARY_COMPLETION",
        "prompt": "",
        "answer": "",
        "passage": passage_text,
        "candidates": [
            {
                "candidateId": "cand_broken",
                "questionNumber": 20,
                "questionType": "SUMMARY_COMPLETION",
                "prompt": "",
                "answer": "",
            },
            {
                "candidateId": "cand_valid",
                "questionNumber": 20,
                "questionType": "SUMMARY_COMPLETION",
                "prompt": "Researchers observed that [20] enhances memory consolidation during sleep.",
                "answer": "cortical plasticity",
                "evidenceQuote": passage_text,
                "explanation": "Verified verbatim in passage.",
                "score": 0.95,
            },
        ],
    }
    art = ArtifactEnvelope.create(
        artifact_id="art_q_slot_20",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=payload,
        producer_version="2.0.0",
        version=1,
    )
    issue = Issue.create(
        issue_id="iss_empty_q20",
        code=IssueCode.SCHEMA_VIOLATION,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 20 answer cannot be empty or missing",
        affected_refs=[art.to_ref()],
    )
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.QUESTION,
        targetArtifactId="art_q_slot_20",
        targetArtifactType=ArtifactType.QUESTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
    )
    repairer = QuestionItemRepairer()
    repaired = await repairer.repair(ctx, art, [issue], intent_id="op_rep_q20", version=2)
    assert repaired.version == 2
    assert repaired.payload["answer"] == "cortical plasticity"
    assert "[20]" in repaired.payload["prompt"]


@pytest.mark.asyncio
async def test_trc2_question_item_repairer_fails_closed_when_candidates_all_invalid():
    """T-RC2: QuestionItemRepairer raises RepairJustificationError when no valid candidate exists."""
    run_id = "run_trc2"
    passage_text = "Researchers observed that cortical plasticity enhances memory consolidation during sleep."
    payload = {
        "questionNumber": 20,
        "questionType": "SUMMARY_COMPLETION",
        "prompt": "",
        "answer": "",
        "passage": passage_text,
        "candidates": [
            {
                "candidateId": "cand_ungrounded",
                "questionNumber": 20,
                "questionType": "SUMMARY_COMPLETION",
                "prompt": "Summary [20].",
                "answer": "extraterrestrial meteors",
            }
        ],
    }
    art = ArtifactEnvelope.create(
        artifact_id="art_q_slot_20",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=payload,
        producer_version="2.0.0",
        version=1,
    )
    issue = Issue.create(
        issue_id="iss_empty_q20_fail",
        code=IssueCode.SCHEMA_VIOLATION,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 20 answer cannot be empty or missing",
        affected_refs=[art.to_ref()],
    )
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.QUESTION,
        targetArtifactId="art_q_slot_20",
        targetArtifactType=ArtifactType.QUESTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
    )
    repairer = QuestionItemRepairer()
    with pytest.raises(RepairJustificationError, match="cannot repair schema violation"):
        await repairer.repair(ctx, art, [issue], intent_id="op_rep_fail", version=2)


@pytest.mark.asyncio
async def test_trc3_trc4_paper_surgical_repair_persists_heads_and_maintains_closure():
    """T-RC3 & T-RC4: Paper-level surgical repair updates question/section heads, preserves unaffected hashes, and satisfies closure."""
    run_id = "bench_1c5dedf68a69188a0d6ff07f280a9a35"
    bp_ref = ArtifactRef(
        artifactId="bp_sec_1_c8cccd2c",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="87a27c25097f92372fa5682124fb1bc28953341a20c4e247ef184dd42d598701",
    )
    s1, p1_ref, q1_envs = _make_worker_section_envelope(
        1,
        run_id,
        bp_ref,
        q_overrides={
            7: {
                "prompt": "The purification framework operates on quantum states where the target form is known a priori.",
            },
            8: {
                "prompt": "The purification framework operates exclusively on quantum states where the target form is known [8].",
                "answer": "a priori",
            },
        },
    )
    s2, p2_ref, q2_envs = _make_worker_section_envelope(2, run_id, bp_ref)
    s3, p3_ref, q3_envs = _make_worker_section_envelope(3, run_id, bp_ref)

    paper_v1 = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id, paper_id="paper_case04", version=1)

    leak_eval = PaperLeakageEvaluator()
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId=paper_v1.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
        inputDependencies=paper_v1.parent_refs,
    )
    eval_v1 = await leak_eval.evaluate(ctx, paper_v1, "eval_v1")
    assert eval_v1.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.ANSWER_LEAKAGE for iss in eval_v1.issues)

    accepted_deps: Dict[str, ArtifactRef] = {ref.artifact_id: ref for ref in paper_v1.parent_refs}
    committed_envelopes: Dict[str, ArtifactEnvelope] = {}
    commit_requests: Dict[str, Any] = {}
    committed_evaluations: List[EvaluationResult] = []

    class _MockCheckpointClient:
        def resume_state(self, r_id: str):
            import hashlib as _hl
            import json as _json
            from app.config import settings
            from app.persistence.models import ResumeStateResult

            snap = settings.create_unlimited_benchmark_snapshot()
            snap_json = _json.dumps(snap, sort_keys=True, separators=(",", ":"))
            snap_sha = _hl.sha256(snap_json.encode("utf-8")).hexdigest()

            base_evals: List[EvaluationResult] = [
                EvaluationResult(
                    evaluationId=f"eval_bsa_{q.artifact_id}_v{q.version}",
                    evaluatorId="eval_blind_solver_adversary",
                    evaluatorVersion="1.0.0",
                    targetRef=q.to_ref(),
                    inputDependencyRefs=[p1_ref, bp_ref],
                    status=EvaluationStatus.PASS,
                    score=1.0,
                    issues=[],
                )
                for q in q1_envs
            ] + [
                EvaluationResult(
                    evaluationId="eval_gf_art_passage_s1",
                    evaluatorId="eval_grounding_fidelity",
                    evaluatorVersion="2.0.0",
                    targetRef=p1_ref,
                    inputDependencyRefs=[bp_ref],
                    status=EvaluationStatus.PASS,
                    score=1.0,
                    issues=[],
                )
            ]
            all_evals = list(base_evals) + list(committed_evaluations)

            return ResumeStateResult(
                runId=r_id,
                jobId=str(uuid4()),
                status="RUNNING",
                epoch=1,
                isCompatible=True,
                engineVersion="2.0.0",
                schemaVersion="2.0.0",
                policyVersion="2.0.0",
                budgetProfileJson=snap_json,
                budgetProfileSha256=snap_sha,
                budgetProfileVersion=snap["profileVersion"],
                budgetProfileSource=snap["profileSource"],
                artifacts=[],
                draftArtifacts=[],
                loopCursors=[],
                operations=[],
                evaluations=all_evals,
            )

        def save_loop_cursor(self, request):
            return type(
                "CursorAck",
                (),
                {
                    "artifactId": getattr(request, "artifactId", getattr(request, "artifact_id", "")),
                    "revision": getattr(request, "expectedRevision", getattr(request, "expected_revision", 0)) + 1,
                    "stateJson": getattr(request, "stateJson", getattr(request, "state_json", "")),
                },
            )()

        def grant_operation(self, request):
            op_id = getattr(request, "operationId", getattr(request, "operation_id", ""))
            tok_res = getattr(request, "tokenReservation", getattr(request, "token_reservation", 0))
            return type("Grant", (), {"operationId": op_id, "tokenReservation": tok_res, "isReplay": False})()

        def save_draft_checkpoint(self, request):
            return type(
                "DraftAck",
                (),
                {
                    "artifactId": request.artifact.artifact_id,
                    "version": request.artifact.version,
                    "contentHash": request.artifact.content_hash,
                },
            )()

        def reconcile_operation(self, request):
            return type("ReconcileAck", (), {"status": "COMPLETED"})()

        def commit_checkpoint(self, request):
            committed_envelopes[request.artifact.artifact_id] = request.artifact
            commit_requests[request.artifact.artifact_id] = request
            if request.evaluations:
                committed_evaluations.extend(request.evaluations)
            if request.artifact.artifact_type == ArtifactType.QUESTION:
                committed_evaluations.append(
                    EvaluationResult(
                        evaluationId=f"eval_bsa_{request.artifact.artifact_id}_v{request.artifact.version}",
                        evaluatorId="eval_blind_solver_adversary",
                        evaluatorVersion="1.0.0",
                        targetRef=request.artifact.to_ref(),
                        inputDependencyRefs=[p1_ref, bp_ref],
                        status=EvaluationStatus.PASS,
                        score=1.0,
                        issues=[],
                    )
                )
            return type(
                "Ack",
                (),
                {
                    "artifactId": request.artifact.artifact_id,
                    "version": request.artifact.version,
                    "contentHash": request.artifact.content_hash,
                },
            )()
    adapter = PaperRepairerAdapter(
        PaperSurgicalRepairer(),
        PaperRepairRouter(),
        persistence_client=_MockCheckpointClient(),
        accepted_dependencies=accepted_deps,
    )
    paper_v2 = await adapter.repair(ctx, paper_v1, eval_v1.issues, "intent_rep_v2", version=2)

    # 1. Replacement artifacts for art_q_7 and art_section_1 were evaluated, persisted, and committed via CAS at version 2
    assert "art_q_7" in committed_envelopes
    assert committed_envelopes["art_q_7"].version == 2
    assert getattr(commit_requests["art_q_7"], "expectedHeadVersion", getattr(commit_requests["art_q_7"], "expected_head_version", None)) == 1
    assert len(commit_requests["art_q_7"].evaluations) >= 2
    assert "art_section_1" in committed_envelopes
    assert committed_envelopes["art_section_1"].version == 2
    assert getattr(commit_requests["art_section_1"], "expectedHeadVersion", getattr(commit_requests["art_section_1"], "expected_head_version", None)) == 1
    assert len(commit_requests["art_section_1"].evaluations) >= 2
    assert "art_section_2" not in committed_envelopes
    assert "art_section_3" not in committed_envelopes

    # 2. Unaffected sections (2 and 3) and unaffected questions (e.g. art_q_8) preserve exact version & hash
    sec_refs_v2 = [ArtifactRef.model_validate(r) for r in paper_v2.payload["sectionRefs"]]
    assert sec_refs_v2[0] == committed_envelopes["art_section_1"].to_ref()
    assert sec_refs_v2[1] == s2.to_ref()
    assert sec_refs_v2[2] == s3.to_ref()

    # 3. Inline section hash parity matches ReadingPaperFinalSnapshot.LoadAsync check
    sec1_env_v2 = committed_envelopes["art_section_1"]
    assert compute_content_hash(paper_v2.payload["sections"][0], sec1_env_v2.parent_refs) == sec1_env_v2.content_hash
    assert compute_content_hash(paper_v2.payload["sections"][1], s2.parent_refs) == s2.content_hash
    assert compute_content_hash(paper_v2.payload["sections"][2], s3.parent_refs) == s3.content_hash

    # 4. DependencyValidator.validate_dependency_freshness and context.input_dependencies match
    assert tuple(paper_v2.parent_refs) == tuple(ctx.input_dependencies)
    fresh, stale_reasons = DependencyValidator.validate_dependency_freshness(paper_v2, accepted_deps)
    assert fresh, f"Expected fresh dependencies after repair, got: {stale_reasons}"

    # 5. Re-evaluating repaired paper with PaperLeakageEvaluator passes with 0 issues
    eval_v2 = await leak_eval.evaluate(ctx, paper_v2, "eval_v2")
    assert eval_v2.status == EvaluationStatus.PASS
    assert len(eval_v2.issues) == 0


@pytest.mark.asyncio
async def test_trc5_passage_sentence_repairer_expands_short_passage_without_certainty_regression():
    """T-RC5: PassageSentenceRepairer expands short passage from source_text while softening certainty boosters."""
    run_id = "bench_4aff1c1cc4992c6f114653ecf95b7684"
    short_passage = " ".join(
        [
            f"Initial clinical observations in cohort {i} indicate moderate metabolic adaptations under controlled conditions."
            for i in range(1, 15)
        ]
    )
    assert len(short_passage.split()) < 720

    source_sentences = [
        f"Experiment {i} confirms that biomarker_{i}_alpha always regulates pathway_{i}_beta "
        f"while enzyme_{i}_gamma definitely stabilizes receptor_{i}_delta across tissue_{i}_epsilon "
        f"under protocol_{i}_zeta within chamber_{i}_eta."
        for i in range(1, 45)
    ]
    source_text = short_passage + " " + " ".join(source_sentences)

    art_v2 = ArtifactEnvelope.create(
        artifact_id="art_passage_s3",
        artifact_type=ArtifactType.PASSAGE,
        run_id=run_id,
        payload={
            "text": short_passage,
            "passage": short_passage,
            "passageText": short_passage,
            "sourceText": source_text,
            "wordCount": len(short_passage.split()),
        },
        producer_version="2.0.0",
        version=2,
        section_id=3,
    )
    issue_wc = Issue.create(
        issue_id="iss_wc_short",
        code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.PASSAGE,
        message=f"Passage word count {len(short_passage.split())} is outside permitted bounds [720, 915]",
        affected_refs=[art_v2.to_ref()],
        evaluator_id="eval_passage_word_count",
    )
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.PASSAGE,
        targetArtifactId="art_passage_s3",
        targetArtifactType=ArtifactType.PASSAGE,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
    )
    repairer = PassageSentenceRepairer()
    art_v3 = await repairer.repair(ctx, art_v2, [issue_wc], intent_id="op_rep_passage", version=3)

    assert art_v3.version == 3
    assert art_v3.payload["text"] == art_v3.payload["passage"]
    assert 720 <= art_v3.payload["wordCount"] <= 915

    wc_eval = PassageWordCountEvaluator()
    style_eval = PassageStyleEvaluator()
    gf_eval = GroundingFidelityEvaluator()

    res_wc = await wc_eval.evaluate(ctx, art_v3, "eval_wc_v3")
    res_style = await style_eval.evaluate(ctx, art_v3, "eval_style_v3")
    res_gf = await gf_eval.evaluate(ctx, art_v3, "eval_gf_v3")

    assert res_wc.status == EvaluationStatus.PASS
    assert res_style.status == EvaluationStatus.PASS
    assert res_gf.status == EvaluationStatus.PASS, f"Unexpected grounding issues: {res_gf.issues}"


@pytest.mark.asyncio
async def test_trc6_trc7_section_leakage_repair_and_empty_directive_fail_closed():
    """T-RC6 & T-RC7: SectionSurgicalRepairer handles non-parenthesized leakage messages and empty paper patch fails closed."""
    run_id = "run_trc6"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    s1, _, _ = _make_worker_section_envelope(
        1,
        run_id,
        bp_ref,
        q_overrides={
            7: {"prompt": "The purification framework operates where the target form is known a priori."},
            8: {"prompt": "The target form is known [8].", "answer": "a priori"},
        },
    )
    s2, _, _ = _make_worker_section_envelope(2, run_id, bp_ref)
    s3, _, _ = _make_worker_section_envelope(3, run_id, bp_ref)

    sec_issue = Issue.create(
        issue_id="iss_sec_leak",
        code=IssueCode.ANSWER_LEAKAGE,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 7 prompt intra-section exact answer leaks answer 'a priori' for Question 8",
        affected_refs=[s1.to_ref()],
    )
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.SECTION,
        targetArtifactId=s1.artifact_id,
        targetArtifactType=ArtifactType.SECTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
    )
    sec_repaired = await SectionSurgicalRepairer().repair(ctx, s1, [sec_issue], "op_sec_rep", version=2)
    q7_repaired = sec_repaired.payload["groups"][0]["questions"][6]
    assert "a priori" not in q7_repaired["prompt"]

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    with pytest.raises(RepairJustificationError, match="patch"):
        PaperSurgicalRepairer().repair_paper(
            paper,
            PaperRepairDirective(affectedRefs=[paper.to_ref()], targetSectionId=1, targetQuestionNumber=1),
        )


@pytest.mark.asyncio
async def test_trc8_section_structure_evaluator_fails_closed_without_solver_adversary_coverage():
    """T-RC8: fresh solver/adversary coverage fails CLOSED, enforced by its owning evaluator.

    Layering note (Phase 15 / T11): `SectionStructureEvaluator` owns deterministic
    Section *shape* invariants. Fresh Blind Solver / Adversary coverage is a *coverage*
    guarantee, owned by `SectionCoverageEvaluator`. T11-01/T11-02 require a structurally
    valid section to PASS the structural evaluator regardless of coverage binding, while
    T-RC8 requires the coverage guarantee to fail closed. Both hold only when the two
    concerns have separate owners, so this test asserts against the owner.

    The guarantee is UNCHANGED in strength: absent, partial or explicitly-uncovered
    summaries all still yield CRITICAL FRESH_EVALUATION_MISSING.
    """
    from app.evaluators.coverage import SectionCoverageEvaluator
    from app.evaluators.section import SectionStructureEvaluator

    run_id = "run_trc8"
    bp_ref = ArtifactRef(
        artifactId="art_bp",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )
    s1, _, _ = _make_worker_section_envelope(1, run_id, bp_ref)

    # 1. Section with evaluationsSummary = None
    payload_no_eval = dict(s1.payload)
    payload_no_eval.pop("evaluationsSummary", None)
    s1_no_eval = ArtifactEnvelope.create(
        artifact_id="art_sec_no_eval",
        artifact_type=ArtifactType.SECTION,
        run_id=run_id,
        payload=payload_no_eval,
        producer_version="2.0.0",
        version=1,
        section_id=1,
        parent_refs=s1.parent_refs,
    )
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.SECTION,
        targetArtifactId="art_sec_no_eval",
        targetArtifactType=ArtifactType.SECTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
        budgetTracker=BudgetTracker(),
    )
    evaluator = SectionCoverageEvaluator()
    res_none = await evaluator.evaluate(ctx, s1_no_eval, "eval_none")
    assert res_none.status == EvaluationStatus.FAIL
    assert any(
        i.code == IssueCode.FRESH_EVALUATION_MISSING
        and i.severity == IssueSeverity.CRITICAL
        for i in res_none.issues
    ), "absent coverage evidence must fail closed with a CRITICAL blocker"

    # 2. Section with evaluationsSummary lacking solver/adversary coverage
    payload_uncovered = dict(s1.payload)
    payload_uncovered["evaluationsSummary"] = {
        "freshEvaluations": True,
        "hasStaleDependencies": False,
        "solverCovered": False,
        "adversaryCovered": False,
        "acceptedEvaluationRefs": ["eval_misc"],
    }
    s1_uncovered = ArtifactEnvelope.create(
        artifact_id="art_sec_uncovered",
        artifact_type=ArtifactType.SECTION,
        run_id=run_id,
        payload=payload_uncovered,
        producer_version="2.0.0",
        version=1,
        section_id=1,
        parent_refs=s1.parent_refs,
    )
    res_uncov = await evaluator.evaluate(ctx, s1_uncovered, "eval_uncov")
    assert res_uncov.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.FRESH_EVALUATION_MISSING for i in res_uncov.issues)

    # 3. Ownership boundary. The structural evaluator no longer emits the
    #    "absent evaluationsSummary" blocker -- that conflation is what made a
    #    structurally valid section impossible to pass (T11-01/T11-02). It still
    #    honours an explicitly negative summary fail-closed, which is a duplicate of
    #    the coverage verdict, not a relaxation.
    struct = SectionStructureEvaluator()
    res_struct_none = await struct.evaluate(ctx, s1_no_eval, "eval_struct_none")
    assert not any(
        i.code == IssueCode.FRESH_EVALUATION_MISSING for i in res_struct_none.issues
    ), "structural invariants must not be coupled to coverage binding"
    res_struct_neg = await struct.evaluate(ctx, s1_uncovered, "eval_struct_neg")
    assert any(
        i.code == IssueCode.FRESH_EVALUATION_MISSING for i in res_struct_neg.issues
    ), "an explicitly uncovered summary must still fail closed"

    # 4. Coverage stays enforced where it is actually computed: the paper loop builds
    #    the section coverage summary from the durable child evaluation ledger and so
    #    is the layer that must register the coverage evaluator as required.
    import app.loop.paper as paper_mod

    paper_src = Path(paper_mod.__file__).read_text()
    assert "SectionCoverageEvaluator(required=True)" in paper_src, (
        "the fresh solver/adversary coverage guarantee must remain enforced by the "
        "layer that computes coverage evidence"
    )
