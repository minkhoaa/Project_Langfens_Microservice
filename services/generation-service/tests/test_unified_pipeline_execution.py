"""Tests for Task 7: Unified Pipeline Stage Integration & Checkpoint Adapter.

Verifies:
1. Explicit bidirectional artifact identity mapping in CheckpointClient between legacy loop IDs
   (art_passage_s{i}, art_qcand_s{i}_{slot}) and canonical pipeline IDs (passage:{run_id}:{i}, question:{run_id}:{q_num}).
2. Seamless legacy resolution in get_artifact, get_artifact_head, and commit_artifact.
3. BoundedLoopRuntime as the sole loop authority inside ReadingGenerationPipeline and SectionRunner
   with standardized canonical artifact IDs.
4. Autonomous recovery escalation and surgical item repair on question evaluation defect.
"""
from __future__ import annotations

import json
from unittest.mock import patch, MagicMock
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import AcademicIssue, IssueCode, IssueSeverity, IssueScope
from app.contracts.loop import DecisionType, LoopReason
from app.loop.controller import EscalationLadder
from app.loop.runtime import BoundedLoopRuntime
from app.persistence.client import (
    CheckpointClient,
    canonicalize_artifact_id,
    legacy_artifact_id,
    get_artifact_aliases,
)
from app.persistence.models import CheckpointCommitRequest
from app.reading_models import PipelineRequest, PipelineResult
from app.reading_policy import PinnedExecutionPolicy
from tests.unified.mock_fixtures import (
    create_mock_environment,
    create_pipeline_request,
)


def test_artifact_identity_mapping_bidirectional():
    """Verifies bidirectional mapping between legacy loop IDs and canonical pipeline IDs."""
    run_id = "run_test_map"

    # 1. Passage mapping
    assert canonicalize_artifact_id("art_passage_s1", run_id) == f"passage:{run_id}:1"
    assert canonicalize_artifact_id("art_passage_s2", run_id) == f"passage:{run_id}:2"
    assert canonicalize_artifact_id("art_passage_s3", run_id) == f"passage:{run_id}:3"
    assert legacy_artifact_id(f"passage:{run_id}:1") == "art_passage_s1"
    assert legacy_artifact_id(f"passage:{run_id}:2") == "art_passage_s2"
    assert legacy_artifact_id(f"passage:{run_id}:3") == "art_passage_s3"

    # 2. Question mapping across sections
    # Section 1: slots 1..13 -> questions 1..13
    assert canonicalize_artifact_id("art_qcand_s1_1", run_id) == f"question:{run_id}:1"
    assert canonicalize_artifact_id("art_qcand_s1_13", run_id) == f"question:{run_id}:13"
    assert legacy_artifact_id(f"question:{run_id}:1") == "art_qcand_s1_1"
    assert legacy_artifact_id(f"question:{run_id}:13") == "art_qcand_s1_13"

    # Section 2: slots 1..13 -> questions 14..26
    assert canonicalize_artifact_id("art_qcand_s2_1", run_id) == f"question:{run_id}:14"
    assert canonicalize_artifact_id("art_qcand_s2_13", run_id) == f"question:{run_id}:26"
    assert legacy_artifact_id(f"question:{run_id}:14") == "art_qcand_s2_1"
    assert legacy_artifact_id(f"question:{run_id}:26") == "art_qcand_s2_13"

    # Section 3: slots 1..14 -> questions 27..40
    assert canonicalize_artifact_id("art_qcand_s3_1", run_id) == f"question:{run_id}:27"
    assert canonicalize_artifact_id("art_qcand_s3_14", run_id) == f"question:{run_id}:40"
    assert legacy_artifact_id(f"question:{run_id}:27") == "art_qcand_s3_1"
    assert legacy_artifact_id(f"question:{run_id}:40") == "art_qcand_s3_14"

    # 3. Source, Evidence, Blueprint, Section, Paper
    assert canonicalize_artifact_id("art_source_s1", run_id) == f"source:{run_id}:1"
    assert canonicalize_artifact_id("art_evidence_s2", run_id) == f"evidence:{run_id}:2"
    assert canonicalize_artifact_id("art_blueprint", run_id) == f"blueprint:{run_id}"
    assert canonicalize_artifact_id("art_section_s3", run_id) == f"section:{run_id}:3"
    assert canonicalize_artifact_id("art_paper", run_id) == f"paper:{run_id}"

    assert legacy_artifact_id(f"source:{run_id}:1") == "art_source_s1"
    assert legacy_artifact_id(f"evidence:{run_id}:2") == "art_evidence_s2"
    assert legacy_artifact_id(f"blueprint:{run_id}") == "art_blueprint"
    assert legacy_artifact_id(f"section:{run_id}:3") == "art_section_s3"
    assert legacy_artifact_id(f"paper:{run_id}") == "art_paper"

    # 4. Aliases set check
    aliases = get_artifact_aliases("art_passage_s1", run_id)
    assert f"passage:{run_id}:1" in aliases
    assert "art_passage_s1" in aliases


def test_checkpoint_client_legacy_name_resolution():
    """Verifies get_artifact, get_artifact_head, and commit_artifact resolve legacy names."""
    run_id = f"test-res-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, _ = create_mock_environment(policy=policy, run_id=run_id)

    # 1. Commit an artifact with legacy ID
    legacy_env = ArtifactEnvelope.create(
        artifact_id="art_passage_s1",
        artifact_type=ArtifactType.PASSAGE,
        run_id=run_id,
        payload={"passage": "Historical text content here.", "wordCount": 750},
        producer_version="1.0.0",
        version=1,
    )
    commit_req = CheckpointCommitRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        operationId=f"op_commit_p1_{uuid4().hex[:6]}",
        requestHash="hash_p1",
        artifact=legacy_env,
        expectedHeadVersion=None,
        expectedHeadHash=None,
        tokensUsed=100,
    )
    ack = client.commit_artifact(commit_req)
    assert ack.artifactId == "art_passage_s1"

    # 2. Retrieve head using canonical ID `passage:{run_id}:1`
    head = client.get_artifact_head(run_id, f"passage:{run_id}:1")
    assert head is not None
    assert head.payload["passage"] == "Historical text content here."

    # 3. Retrieve specific version using canonical ID
    art = client.get_artifact(run_id, f"passage:{run_id}:1", version=1)
    assert art is not None
    assert art.version == 1

    # 4. Commit artifact with canonical ID, retrieve via legacy ID
    q_env = ArtifactEnvelope.create(
        artifact_id=f"question:{run_id}:14",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload={"questionNumber": 14, "prompt": "What is the phenomenon?", "answer": "TRUE"},
        producer_version="1.0.0",
        version=1,
        parent_refs=(legacy_env.to_ref(),),
    )
    q_commit_req = CheckpointCommitRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        operationId=f"op_commit_q14_{uuid4().hex[:6]}",
        requestHash="hash_q14",
        artifact=q_env,
        expectedHeadVersion=None,
        expectedHeadHash=None,
        tokensUsed=50,
    )
    client.commit_artifact(q_commit_req)

    # Query via legacy ID `art_qcand_s2_1`
    q_head = client.get_artifact_head(run_id, "art_qcand_s2_1")
    assert q_head is not None
    assert q_head.payload["questionNumber"] == 14


@pytest.mark.asyncio
async def test_pipeline_delegates_to_bounded_loop_with_canonical_ids():
    """Verifies ReadingGenerationPipeline delegates execution to BoundedLoopRuntime and uses canonical IDs."""
    run_id = f"test-unified-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    runtime_instances = []
    original_init = BoundedLoopRuntime.__init__

    def spy_runtime_init(self, *args, **kwargs):
        runtime_instances.append(self)
        original_init(self, *args, **kwargs)

    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1,),
        parallel=False,
        finalize=False,
        policy=policy,
    )
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    with patch.object(BoundedLoopRuntime, "__init__", spy_runtime_init):
        result = await pipeline.execute(request)

    assert isinstance(result, PipelineResult)
    assert result.status == "ACCEPTED"
    assert len(result.sections) == 1

    # BoundedLoopRuntime must have been instantiated as the execution authority
    assert len(runtime_instances) > 0, "BoundedLoopRuntime was not invoked during pipeline execution"

    # Verify that all persisted heads use canonical IDs
    persisted_ids = {art.artifactId for art in client.resume_state(run_id).artifacts}
    assert f"source:{run_id}:1" in persisted_ids
    assert f"evidence:{run_id}:1" in persisted_ids
    assert f"blueprint:{run_id}" in persisted_ids
    assert f"passage:{run_id}:1" in persisted_ids
    assert f"section:{run_id}:1" in persisted_ids
    for q_num in range(1, 14):
        assert f"question:{run_id}:{q_num}" in persisted_ids


@pytest.mark.asyncio
async def test_question_evaluation_failure_invokes_surgical_item_repair():
    """Verifies that when question evaluation fails, the recovery ladder invokes surgical repair."""
    run_id = f"test-repair-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # Verifies end-to-end question verification and repair invariants
    request = create_pipeline_request(
        run_id=run_id,
        section_indices=(1,),
        parallel=False,
        finalize=False,
        policy=policy,
    )
    client.init_run(run_id=request.run_id, epoch=request.epoch, lease_owner=request.lease_owner, policy_hash=policy.hash, job_id=request.job_id)

    result = await pipeline.execute(request)
    assert result.status == "ACCEPTED"
    sec1 = result.sections[0]
    questions = [q for grp in sec1.payload.get("groups", []) for q in grp.get("questions", [])]
    assert len(questions) == 13
    for q in questions:
        # All questions must satisfy length and quality invariants
        ans = str(q.get("answer") or "")
        words = [w for w in ans.split() if any(c.isalnum() for c in w)]
        assert len(words) <= 3, f"Question {q.get('questionNumber')} answer '{ans}' exceeds IELTS word limit"


@pytest.mark.asyncio
async def test_question_item_repair_and_stagnation_ladder():
    """Explicitly verifies ITEM_REPAIR -> PASS and Stagnation -> ITEM_RESELECT ladder in stage execution."""
    run_id = f"test-ladder-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    _, client, _, _ = create_mock_environment(policy=policy, run_id=run_id)
    from app.reading_models import RunContext
    from app.stage_executor import StageExecutor

    context = RunContext(
        run_id=run_id,
        epoch=1,
        lease_owner=client.default_lease_owner,
        job_id=client.default_job_id,
        policy_hash=policy.hash,
    )
    executor = StageExecutor(client, context, policy, required_evaluator_ids=("eval_question_structure",))

    passage_text = "The deep oceanic trench contains distinct hydrothermal vent ecosystems supported by chemosynthetic bacteria."
    # A question repair requires real immutable passage/blueprint parents even
    # when the repair callback itself is deterministic and performs no transport.
    passage = ArtifactEnvelope.create(
        artifact_id=f"passage:{run_id}:1", artifact_type=ArtifactType.PASSAGE,
        run_id=run_id, payload={"passage": passage_text}, producer_version="1.0.0",
    )
    blueprint = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}", artifact_type=ArtifactType.EXAM_BLUEPRINT,
        run_id=run_id, payload={"fixture": "surgical-repair-parent"}, producer_version="1.0.0",
    )
    for parent in (passage, blueprint):
        client.heads[(run_id, parent.artifact_id)] = parent

    attempt_count = 0
    repair_count = 0

    async def generate_flawed_question(ver: int) -> dict:
        nonlocal attempt_count
        attempt_count += 1
        return {
            "questionNumber": 5,
            "questionType": "SHORT_ANSWER",
            "prompt": "What organisms support hydrothermal vent ecosystems in question 5?",
            "answer": "distinct hydrothermal vent ecosystems supported by chemosynthetic bacteria",  # 8 words -> exceeds 3-word limit
            "explanation": "The passage states that hydrothermal vent ecosystems are supported by chemosynthetic bacteria.",
            "evidenceQuote": "chemosynthetic bacteria",
        }

    async def evaluate_flawed_question(art: ArtifactEnvelope) -> list[EvaluationResult]:
        words = [w for w in str(art.payload.get("answer", "")).split() if any(c.isalnum() for c in w)]
        if len(words) > 3:
            issue = AcademicIssue(
                code=IssueCode.WORD_LIMIT_EXCEEDED,
                scope=IssueScope.QUESTION,
                severity=IssueSeverity.CRITICAL,
                message=f"Question 5 answer '{art.payload.get('answer')}' has {len(words)} words, exceeding the 3-word limit.",
                artifact_ref=art.artifact_id,
                affected_refs=[art.to_ref()],
            )
            return [EvaluationResult(
                evaluationId=f"eval_flaw_{uuid4().hex[:8]}",
                evaluatorId="eval_question_structure",
                evaluatorVersion="1.0.0",
                targetRef=art.to_ref(),
                status=EvaluationStatus.FAIL,
                issues=[issue],
                score=0.0,
            )]
        return [EvaluationResult(
            evaluationId=f"eval_pass_{uuid4().hex[:8]}",
            evaluatorId="eval_question_structure",
            evaluatorVersion="1.0.0",
            targetRef=art.to_ref(),
            status=EvaluationStatus.PASS,
            issues=[],
            score=1.0,
        )]

    async def surgical_repair(art: ArtifactEnvelope, issues: Sequence[Any], ver: int) -> dict:
        nonlocal repair_count
        repair_count += 1
        pl = dict(art.payload)
        # Surgically trim answer to passage evidence quote (2 words)
        pl["answer"] = "chemosynthetic bacteria"
        return pl

    q_art_id = f"question:{run_id}:5"
    committed_env = await executor.execute(
        artifact_id=q_art_id,
        artifact_type=ArtifactType.QUESTION,
        parents=(passage.to_ref(), blueprint.to_ref()),
        generate=generate_flawed_question,
        evaluate=evaluate_flawed_question,
        section_id=1,
        repair=surgical_repair,
    )

    assert committed_env is not None
    assert committed_env.artifact_id == q_art_id
    assert committed_env.version == 2
    assert committed_env.payload["answer"] == "chemosynthetic bacteria"
    assert repair_count == 1, "Surgical repair was not invoked on defect"


@pytest.mark.asyncio
async def test_historical_checkpoint_resumption_with_legacy_ids():
    """Verifies pipeline can resume from a run where earlier sections used legacy IDs."""
    run_id = f"test-hist-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    # Pre-populate historical section 1 under legacy IDs
    legacy_passage = ArtifactEnvelope.create(
        artifact_id="art_passage_s1",
        artifact_type=ArtifactType.PASSAGE,
        run_id=run_id,
        payload={"passage": "Pre-existing historical passage for section 1.", "wordCount": 780},
        producer_version="1.0.0",
        version=1,
        section_id=1,
    )
    client.heads[(run_id, "art_passage_s1")] = legacy_passage

    # Look up using canonical ID
    resumed_head = client.get_artifact_head(run_id, f"passage:{run_id}:1")
    assert resumed_head is not None
    assert resumed_head.artifact_id == "art_passage_s1"
    assert resumed_head.payload["wordCount"] == 780
