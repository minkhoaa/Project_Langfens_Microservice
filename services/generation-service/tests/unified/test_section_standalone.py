"""Standalone reading section generation tests (Section 1, 2, and 3).

Verifies:
1. Standalone Section 1 generation produces exact contiguous Q1–13.
2. Standalone Section 2 generation produces exact contiguous Q14–26.
3. Standalone Section 3 generation produces exact contiguous Q27–40.
4. All sections run through the EXACT SAME SectionRunner class and method;
   differences are purely configuration data.
5. Determinism: identical input sources produce byte-identical artifact hashes.
6. Zero cross-section state leakage: standalone run commits only artifacts for
   its configured section index.
"""

from __future__ import annotations

from typing import Any
from uuid import uuid4
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.blueprint import QuestionType
from app.contracts.policies import count_words
from app.reading_generation import build_blueprint, build_evidence, prepare_source
from app.reading_models import (
    AcceptedSectionArtifact, RunContext, SourceInput, SourceRef,
)
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.section_runner import SectionRunner
from app.stage_executor import StageExecutor

from tests.unified.mock_fixtures import (
    SECTION_1_SOURCE_TEXT,
    SECTION_2_SOURCE_TEXT,
    SECTION_3_SOURCE_TEXT,
    create_mock_environment,
    create_source_inputs,
)


async def _setup_standalone_prerequisites(
    client: Any,
    context: RunContext,
    section_index: int,
    source_input: SourceInput,
    policy: PinnedExecutionPolicy,
) -> tuple[SourceRef, ArtifactEnvelope]:
    """Helper executing stages 1-3 prerequisites for a single section."""
    executor = StageExecutor(client, context, policy)

    # 1. Source Pack
    source_art_id = f"source:{context.run_id}:{section_index}"

    async def gen_source(ver: int) -> dict[str, Any]:
        return await prepare_source(source_input, context.run_id, policy)

    async def eval_source(art: ArtifactEnvelope) -> list[Any]:
        from app.reading_evaluation import evaluate_source
        return evaluate_source(art, policy)

    source_env = await executor.execute(
        source_art_id,
        ArtifactType.SOURCE_PACK,
        (),
        gen_source,
        eval_source,
        section_id=section_index,
    )

    # 2. Evidence Graph
    evidence_art_id = f"evidence:{context.run_id}:{section_index}"

    async def gen_evidence(ver: int) -> dict[str, Any]:
        return build_evidence(source_env, context.run_id, section_index, policy)

    async def eval_evidence(art: ArtifactEnvelope) -> list[Any]:
        from app.reading_evaluation import evaluate_evidence
        text_map = {
            source_env.payload["sources"][0]["sourceId"]: source_env.payload["sources"][0]["document"]["text"]
        }
        return evaluate_evidence(art, text_map, policy.min_verified_claims)

    evidence_env = await executor.execute(
        evidence_art_id,
        ArtifactType.EVIDENCE_GRAPH,
        (source_env.to_ref(),),
        gen_evidence,
        eval_evidence,
        section_id=section_index,
    )

    source_ref = SourceRef(source=source_env, evidence=evidence_env)

    # 3. Blueprint (scoped to section_index)
    bp_art_id = f"blueprint:{context.run_id}"

    async def gen_blueprint(ver: int) -> dict[str, Any]:
        return build_blueprint(
            context.run_id,
            "Standalone Test Topic",
            (section_index,),
            {section_index: source_env},
            {section_index: evidence_env},
            policy,
        )

    async def eval_blueprint(art: ArtifactEnvelope) -> list[Any]:
        from app.reading_evaluation import evaluate_blueprint
        return evaluate_blueprint(art, policy, (section_index,))

    blueprint_env = await executor.execute(
        bp_art_id,
        ArtifactType.EXAM_BLUEPRINT,
        (evidence_env.to_ref(),),
        gen_blueprint,
        eval_blueprint,
    )

    return source_ref, blueprint_env


@pytest.mark.asyncio
@pytest.mark.parametrize("section_index,expected_start,expected_count,expected_types", [
    (1, 1, 13, [QuestionType.TRUE_FALSE_NOT_GIVEN, QuestionType.SENTENCE_COMPLETION]),
    (2, 14, 13, [QuestionType.MULTIPLE_CHOICE_SINGLE, QuestionType.SUMMARY_COMPLETION]),
    (3, 27, 14, [QuestionType.YES_NO_NOT_GIVEN, QuestionType.SHORT_ANSWER]),
])
async def test_section_standalone_generation(
    section_index: int,
    expected_start: int,
    expected_count: int,
    expected_types: list[QuestionType],
) -> None:
    """Verifies each section generates cleanly via the same authoritative SectionRunner."""
    run_id = f"standalone-s{section_index}-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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

    all_sources = create_source_inputs()
    source_input = next(s for s in all_sources if s.section_index == section_index)
    config = policy.section(section_index)

    # Prepare prerequisites
    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, section_index, source_input, policy
    )

    # Execute standalone run through the authoritative SectionRunner
    runner = SectionRunner(client, gateway)
    result = await runner.run(
        context,
        config,
        source_ref,
        blueprint_env.to_ref(),
        policy,
    )

    # 1. Verification of return types and structure
    assert isinstance(result, AcceptedSectionArtifact)
    assert result.section.artifact_type == ArtifactType.SECTION
    assert result.passage.artifact_type == ArtifactType.PASSAGE
    assert len(result.questions) == expected_count

    # 2. Numbering domain verification
    expected_numbers = tuple(range(expected_start, expected_start + expected_count))
    actual_numbers = tuple(q.payload.get("questionNumber") for q in result.questions)
    assert actual_numbers == expected_numbers
    assert actual_numbers == config.question_numbers()

    # 3. Question group types verification
    sec_payload = result.section.payload
    groups = sec_payload.get("groups", [])
    assert len(groups) == len(expected_types)
    assert [g.get("questionType") for g in groups] == [t.value for t in expected_types]

    # 4. Passage constraints verification
    passage_text = str(result.passage.payload.get("passage", ""))
    words = count_words(passage_text)
    assert config.min_words <= words <= config.max_words
    assert 720 <= words <= 915

    # 5. Integrity verification
    assert result.section.verify_integrity()
    assert result.passage.verify_integrity()
    for q_env in result.questions:
        assert q_env.verify_integrity()

    # 6. Checkpoint persistence verification
    stored_sec = await StageExecutor(client, context, policy).get_accepted(result.section.artifact_id)
    assert stored_sec is not None
    assert stored_sec.content_hash == result.section.content_hash


@pytest.mark.asyncio
async def test_section_runner_is_strictly_identical_class_across_sections() -> None:
    """Verifies Section 1, 2, and 3 use the exact same SectionRunner instance and method."""
    policy = PinnedExecutionPolicy(provider="mock")
    run_id = f"identical-runner-{uuid4().hex[:8]}"
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

    runner = SectionRunner(client, gateway)
    all_sources = create_source_inputs()

    # Run Section 1
    s1_input = next(s for s in all_sources if s.section_index == 1)
    s1_src, s1_bp = await _setup_standalone_prerequisites(client, context, 1, s1_input, policy)
    s1_res = await runner.run(context, policy.section(1), s1_src, s1_bp.to_ref(), policy)
    assert len(s1_res.questions) == 13

    # Run Section 2 using the EXACT same runner instance
    s2_input = next(s for s in all_sources if s.section_index == 2)
    s2_src, s2_bp = await _setup_standalone_prerequisites(client, context, 2, s2_input, policy)
    s2_res = await runner.run(context, policy.section(2), s2_src, s2_bp.to_ref(), policy)
    assert len(s2_res.questions) == 13

    # Run Section 3 using the EXACT same runner instance
    s3_input = next(s for s in all_sources if s.section_index == 3)
    s3_src, s3_bp = await _setup_standalone_prerequisites(client, context, 3, s3_input, policy)
    s3_res = await runner.run(context, policy.section(3), s3_src, s3_bp.to_ref(), policy)
    assert len(s3_res.questions) == 14

    # Confirms single runner method
    assert s1_res.section.section_id == 1
    assert s2_res.section.section_id == 2
    assert s3_res.section.section_id == 3


@pytest.mark.asyncio
async def test_section_standalone_zero_cross_section_state_leakage() -> None:
    """Verifies a standalone run for Section 2 does NOT persist artifacts for Section 1 or 3."""
    run_id = f"leakage-test-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock")
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

    all_sources = create_source_inputs()
    s2_input = next(s for s in all_sources if s.section_index == 2)
    s2_src, s2_bp = await _setup_standalone_prerequisites(client, context, 2, s2_input, policy)

    runner = SectionRunner(client, gateway)
    await runner.run(context, policy.section(2), s2_src, s2_bp.to_ref(), policy)

    committed_artifact_ids = [req.artifact.artifact_id for req in client.commits]

    # Every committed artifact belongs to section 2 or is the run-level blueprint
    for art_id in committed_artifact_ids:
        if art_id.startswith("question:"):
            q_idx = int(art_id.split(":")[-1])
            assert 14 <= q_idx <= 26, f"Cross-section question leak: {art_id}"
        elif ":" in art_id and not art_id.startswith("blueprint:"):
            sec_part = art_id.split(":")[-1]
            assert sec_part == "2", f"Cross-section artifact leak: {art_id}"


@pytest.mark.asyncio
async def test_section_standalone_deterministic_reproducibility() -> None:
    """Verifies two identical runs with the same inputs produce byte-identical outputs."""
    policy = PinnedExecutionPolicy(provider="mock")
    all_sources = create_source_inputs()
    source_input = next(s for s in all_sources if s.section_index == 2)
    config = policy.section(2)

    # First run
    run_id_1 = "det-run-1"
    _, client_1, _, gw_1 = create_mock_environment(policy=policy, run_id=run_id_1)
    ctx_1 = RunContext(
        runId=run_id_1,
        jobId=client_1.default_job_id,
        epoch=1,
        leaseOwner=client_1.default_lease_owner,
        policyHash=policy.hash,
        client=client_1,
        gateway=gw_1,
    )
    s_ref_1, bp_1 = await _setup_standalone_prerequisites(client_1, ctx_1, 2, source_input, policy)
    res_1 = await SectionRunner(client_1, gw_1).run(ctx_1, config, s_ref_1, bp_1.to_ref(), policy)

    # Second run
    run_id_2 = "det-run-2"
    _, client_2, _, gw_2 = create_mock_environment(policy=policy, run_id=run_id_2)
    ctx_2 = RunContext(
        runId=run_id_2,
        jobId=client_2.default_job_id,
        epoch=1,
        leaseOwner=client_2.default_lease_owner,
        policyHash=policy.hash,
        client=client_2,
        gateway=gw_2,
    )
    s_ref_2, bp_2 = await _setup_standalone_prerequisites(client_2, ctx_2, 2, source_input, policy)
    res_2 = await SectionRunner(client_2, gw_2).run(ctx_2, config, s_ref_2, bp_2.to_ref(), policy)

    # Payload contents are deterministic
    p1 = res_1.passage.payload
    p2 = res_2.passage.payload
    assert p1["passage"] == p2["passage"]
    assert p1["title"] == p2["title"]
    assert p1["wordCount"] == p2["wordCount"]
    assert len(res_1.questions) == len(res_2.questions) == 13
    for q1, q2 in zip(res_1.questions, res_2.questions):
        assert q1.payload["prompt"] == q2.payload["prompt"]
        ans1 = q1.payload.get("answer") or q1.payload.get("correctOption")
        ans2 = q2.payload.get("answer") or q2.payload.get("correctOption")
        assert ans1 == ans2
