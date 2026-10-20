"""End-to-End Mock Acceptance Tests for ReadingGenerationPipeline.

Verifies:
1. Full 40-question, 3-section paper generation sequential (`parallel=False`).
2. Full 40-question, 3-section paper generation parallel (`parallel=True`).
3. Finalization verification: `build_exam` called when `finalize=True`, omitted when `False`.
4. Contiguous 1–40 question numbering, valid groups, and paper total word counts.
5. Finalization idempotency: re-running on completed state reuses artifacts and preserves exam ID.
6. Subset execution: generating a single section through the pipeline leaves paper unfinalized.
"""

from __future__ import annotations

from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.blueprint import QuestionType
from app.contracts.policies import count_words
from app.reading_models import PipelineRequest, PipelineResult
from app.reading_policy import PinnedExecutionPolicy

from tests.unified.mock_fixtures import (
    create_mock_environment,
    create_pipeline_request,
    create_source_inputs,
)


@pytest.mark.asyncio
async def test_full_reading_pipeline_sequential_mock_e2e() -> None:
    """Tests complete sequential execution across Stages 0 through 8."""
    run_id = f"e2e-seq-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
    )
    # Ensure client is initialized with the request authority
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    result = await pipeline.execute(request)

    # 1. Pipeline result structure
    assert isinstance(result, PipelineResult)
    assert result.status == "ACCEPTED"
    assert result.run_id == run_id
    assert len(result.sections) == 3

    # 2. Section indices and ordering
    assert [s.section_id for s in result.sections] == [1, 2, 3]

    # 3. Paper assembly verification
    assert result.paper is not None
    assert result.paper.artifact_type == ArtifactType.READING_PAPER
    assert result.paper.verify_integrity()

    paper_payload = result.paper.payload
    assert paper_payload["totalQuestions"] == 40
    all_paper_questions = [
        q for sec in paper_payload["sections"] for grp in sec.get("groups", []) for q in grp.get("questions", [])
    ]
    assert len(all_paper_questions) == 40

    # 4. Strictly contiguous question numbering 1..40
    actual_numbers = [q["questionNumber"] for q in all_paper_questions]
    assert actual_numbers == list(range(1, 41))

    # 5. Section question boundaries
    s1_numbers = [q["questionNumber"] for grp in paper_payload["sections"][0]["groups"] for q in grp["questions"]]
    s2_numbers = [q["questionNumber"] for grp in paper_payload["sections"][1]["groups"] for q in grp["questions"]]
    s3_numbers = [q["questionNumber"] for grp in paper_payload["sections"][2]["groups"] for q in grp["questions"]]
    assert s1_numbers == list(range(1, 14))
    assert s2_numbers == list(range(14, 27))
    assert s3_numbers == list(range(27, 41))

    # 6. Word count verification
    total_words = paper_payload["totalWords"]
    assert policy.paper_min_words <= total_words <= policy.paper_max_words
    assert 2150 <= total_words <= 2750

    # 7. Finalization verification: examId populated via CheckpointClient.build_exam
    assert result.exam_id is not None
    assert run_id in client.built_exams
    assert client.built_exams[run_id].examId == result.exam_id


@pytest.mark.asyncio
async def test_full_reading_pipeline_parallel_mock_e2e() -> None:
    """Tests complete parallel execution across sections (Stages 4–6 via asyncio.gather)."""
    run_id = f"e2e-par-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=True,
        finalize=True,
        policy=policy,
    )
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    result = await pipeline.execute(request)

    assert result.status == "ACCEPTED"
    assert len(result.sections) == 3
    # Parallel gather preserves or sorts back to contiguous section order
    assert [s.section_id for s in result.sections] == [1, 2, 3]

    assert result.paper is not None
    assert result.exam_id is not None
    assert result.paper.payload["totalQuestions"] == 40

    all_nums = [
        q["questionNumber"]
        for sec in result.paper.payload["sections"]
        for grp in sec.get("groups", [])
        for q in grp.get("questions", [])
    ]
    assert all_nums == list(range(1, 41))


@pytest.mark.asyncio
async def test_reading_pipeline_without_finalization() -> None:
    """Tests pipeline assembly when finalize=False: paper generated, exam not created."""
    run_id = f"e2e-no-final-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, _, _ = create_mock_environment(policy=policy, run_id=run_id)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=False,
        policy=policy,
    )
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    result = await pipeline.execute(request)

    assert result.status == "ACCEPTED"
    assert result.paper is not None
    # Exam building was skipped
    assert result.exam_id is None
    assert run_id not in client.built_exams


@pytest.mark.asyncio
async def test_reading_pipeline_subset_section_execution() -> None:
    """Tests partial pipeline execution for Section 2 only (no paper assembly)."""
    run_id = f"e2e-subset-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, _, _ = create_mock_environment(policy=policy, run_id=run_id)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(2,),
        parallel=False,
        finalize=True,
        policy=policy,
    )
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    result = await pipeline.execute(request)

    assert result.status == "ACCEPTED"
    assert len(result.sections) == 1
    assert result.sections[0].section_id == 2
    # Paper assembly requires all three sections; should be None
    assert result.paper is None
    assert result.exam_id is None

    # Section 2 questions match Q14–26
    sec_payload = result.sections[0].payload
    q_nums = [q["questionNumber"] for grp in sec_payload.get("groups", []) for q in grp.get("questions", [])]
    assert q_nums == list(range(14, 27))


@pytest.mark.asyncio
async def test_reading_pipeline_idempotent_re_execution() -> None:
    """Tests that re-executing a completed pipeline run is safe and idempotent."""
    run_id = f"e2e-idemp-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, _, _ = create_mock_environment(policy=policy, run_id=run_id)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1, 2, 3),
        parallel=False,
        finalize=True,
        policy=policy,
    )
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    # First execution
    result_1 = await pipeline.execute(request)
    assert result_1.exam_id is not None
    first_commits_count = len(client.commits)

    # Second execution on identical run
    result_2 = await pipeline.execute(request)
    assert result_2.status == "ACCEPTED"
    assert result_2.exam_id == result_1.exam_id
    assert result_2.paper.content_hash == result_1.paper.content_hash

    # Second run reused artifacts; no duplicate commit explosion
    assert len(client.commits) == first_commits_count
    assert result_2.metrics["artifacts_reused"] >= 3
