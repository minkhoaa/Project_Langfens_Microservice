"""End-to-End Autonomous IELTS Reading Generation Harness Smoke Test.

Covers Task 9 acceptance criteria:
1. Full 40-question paper generation across Sections 1, 2, and 3 via ReadingGenerationPipeline.
2. Defect injection on Question 23 (simulated answer length defect violating IELTS limit).
3. Verification that Question 23 undergoes ITEM_REPAIR, is re-evaluated, and accepted (version 2).
4. Verification that all other 39 questions remain intact at version 1 without unnecessary invalidation.
5. All 40 questions are accepted with contiguous numbering and finalization (build_exam).
"""

from __future__ import annotations

import json
import re
from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import AcademicIssue, Issue, IssueCode, IssueSeverity, IssueScope
from app.contracts.loop import DecisionType
from app.loop.runtime import BoundedLoopRuntime
from app.persistence.client import canonicalize_artifact_id
from app.pipeline import ReadingGenerationPipeline
from app.reading_models import PipelineRequest, PipelineResult
from app.reading_policy import PinnedExecutionPolicy

from tests.unified.mock_fixtures import (
    create_mock_environment,
    create_pipeline_request,
)


@pytest.mark.asyncio
async def test_end_to_end_autonomous_generation_with_q23_defect_recovery() -> None:
    """End-to-end smoke test verifying 40-question paper generation and Question 23 autonomous recovery."""
    run_id = f"smoke-e2e-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="legacy_preset")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

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

    q23_art_id = canonicalize_artifact_id(f"question:{run_id}:23", run_id)
    solve_q23_count = 0

    # Intercept default provider: inject defect in blank 23 of summary_group
    original_call = provider.call

    async def hooked_provider_call(req, api_key, deadline):
        nonlocal solve_q23_count
        art_id = req.artifact_id or ""
        op_id = req.operation_id or ""
        resp = await original_call(req, api_key, deadline)

        # Intercept question 23 generation to inject defect (4 words) within its legitimate bound evidence
        if req.capability.value == "generate_json" and (":23" in op_id or ":23" in art_id or "summary_group" in op_id or "summary_group" in art_id):
            if isinstance(resp.parsed_payload, dict):
                blanks = resp.parsed_payload.get("blanks")
                if isinstance(blanks, list):
                    for b in blanks:
                        if b.get("number") == 23 or b.get("questionNumber") == 23:
                            q_text = b.get("evidenceQuote") or "Marine biogeochemical cycles in oligotrophic oceanic gyres"
                            words = q_text.split()[:4]
                            b["answer"] = " ".join(words).lower()
                cands = resp.parsed_payload.get("candidates")
                if isinstance(cands, list):
                    for c in cands:
                        if c.get("questionNumber") == 23 or c.get("number") == 23:
                            q_text = c.get("evidenceQuote") or "Marine biogeochemical cycles in oligotrophic oceanic gyres"
                            words = q_text.split()[:4]
                            c["answer"] = " ".join(words).lower()
                resp.raw_text = json.dumps(resp.parsed_payload, ensure_ascii=False)

        # Hook blind solver for question 23:
        # On v1 candidate (4 words), deterministic evaluation fails and blind solver is short-circuited.
        # On v2 repaired candidate (3 words), blind solver confirms the repaired answer.
        if req.capability.value == "solve_item":
            user_msg = req.messages[-1].content if req.messages else ""
            q_num_match = re.search(r'(?:question_number="|<question_number>)(\d+)', user_msg)
            q_num = int(q_num_match.group(1)) if q_num_match else 1
            if q_num == 23:
                solve_q23_count += 1
                q_last = provider._last_questions.get(23, {})
                quote_target = str(q_last.get("evidenceQuote") or "Natural iron fertilization experiments")
                words = [w for w in re.findall(r"\b[A-Za-z0-9\-]+\b", quote_target)][:4]
                solv_ans = " ".join(words[-3:]) if len(words) >= 3 else " ".join(words)
                resp.parsed_payload = {
                    "questionNumber": 23,
                    "normalizedAnswer": solv_ans,
                    "justification": f"Verified by passage evidence: {solv_ans}",
                    "citedSpans": [{"spanText": quote_target[:80]}],
                    "selfReportedConfidence": 0.95,
                }
                resp.raw_text = json.dumps(resp.parsed_payload, ensure_ascii=False)

        return resp

    provider.call = hooked_provider_call

    # Execute canonical ReadingGenerationPipeline
    result = await pipeline.execute(request)

    # 1. Structural assertions on PipelineResult
    assert isinstance(result, PipelineResult)
    assert result.status == "ACCEPTED"
    assert result.run_id == run_id
    assert len(result.sections) == 3

    # 2. Assert all 40 questions are present and accepted
    assert result.paper is not None
    assert result.paper.artifact_type == ArtifactType.READING_PAPER
    paper_payload = result.paper.payload
    assert paper_payload["totalQuestions"] == 40

    all_paper_questions = [
        q for sec in paper_payload["sections"] for grp in sec.get("groups", []) for q in grp.get("questions", [])
    ]
    assert len(all_paper_questions) == 40
    actual_numbers = [q["questionNumber"] for q in all_paper_questions]
    assert actual_numbers == list(range(1, 41))

    # 3. Assert Question 23 underwent ITEM_REPAIR and was accepted at version >= 2
    q23_head = client.get_artifact_head(run_id, q23_art_id)
    assert q23_head is not None, "Question 23 head artifact not found in durable storage"
    assert q23_head.version >= 2, f"Expected Q23 to undergo repair and advance version (got version {q23_head.version})"

    # Verify Q23 payload answer satisfies IELTS limit (<= 3 words)
    q23_ans = str(q23_head.payload.get("answer", ""))
    words_q23 = [w for w in q23_ans.split() if any(c.isalnum() for c in w)]
    assert len(words_q23) <= 3, f"Repaired Question 23 answer '{q23_ans}' exceeds 3 words"

    # 4. Assert other 39 questions remained intact at version 1
    for q_num in range(1, 41):
        if q_num == 23:
            continue
        art_id = canonicalize_artifact_id(f"question:{run_id}:{q_num}", run_id)
        head = client.get_artifact_head(run_id, art_id)
        assert head is not None, f"Question {q_num} head artifact not found"
        assert head.version == 1, f"Question {q_num} version was {head.version}, expected 1 (unaffected by Q23 repair)"

    # 5. Assert finalization occurred (examId generated)
    assert result.exam_id is not None
    assert run_id in client.built_exams
