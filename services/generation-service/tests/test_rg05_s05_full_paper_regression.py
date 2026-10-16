"""Unit tests for RG05-S05: Full-Paper Regression Boundary and Coexistence."""

import pytest
from pydantic import ValidationError

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueCode, IssueScope
from app.contracts.paper import (
    ReadingPaperPayload,
    ReadingPaperSnapshot,
    assemble_immutable_paper,
)
from app.contracts.research import (
    ReadingTask,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.evaluators.paper import PaperStructureEvaluator
from uuid import uuid4
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.standalone_reading import StandaloneReadingRunner
from tests.test_t12_paper_loop import create_mock_section_envelope


VALID_PASSAGE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have been losing mass at an accelerated rate over the past two decades. However, "
    "East Antarctica remains relatively stable, with some high-altitude areas experiencing "
    "modest gains in snowfall that partially offset coastal losses."
)


@pytest.mark.asyncio
async def test_pos_rg05_s05_production_full_paper_invariants_intact():
    """POS-RG05-S05: Full Reading 3 sections/6 groups/40 questions contract and PaperStructureEvaluator intact."""
    run_id = "run_pos_rg05_s05"
    bp_ref = ArtifactRef(
        artifactId="art_bp_01",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )

    s1 = create_mock_section_envelope(1, 800, run_id)  # 13 questions (1-13)
    s2 = create_mock_section_envelope(2, 800, run_id)  # 13 questions (14-26)
    s3 = create_mock_section_envelope(3, 800, run_id)  # 14 questions (27-40)

    # 1. Valid full paper assembly
    valid_paper_envelope = assemble_immutable_paper(
        sections=[s1, s2, s3],
        blueprint_ref=bp_ref,
        run_id=run_id,
    )
    assert valid_paper_envelope.payload["totalQuestions"] == 40
    assert 2150 <= valid_paper_envelope.payload["totalWords"] <= 2750

    evaluator = PaperStructureEvaluator()
    ctx = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId=valid_paper_envelope.artifact_id,
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    res_valid = await evaluator.evaluate(ctx, valid_paper_envelope, "intent_valid")
    assert res_valid.status == EvaluationStatus.PASS

    # 2. Strict rejection of incomplete paper (only 2 sections assembled raises ValueError)
    with pytest.raises(ValueError, match="requires exactly 3 sections"):
        assemble_immutable_paper(
            sections=[s1, s2],  # Only 2 sections!
            blueprint_ref=bp_ref,
            run_id=run_id,
        )


def test_neg_rg05_s05_single_passage_cannot_create_draft_exam():
    """NEG-RG05-S05: Single-passage run cannot create partial production Draft Exam or be assembled as full paper."""
    runner = StandaloneReadingRunner()
    req = StandaloneReadingRequest(
        run_id="run-test-single",
        dataset_item_id="reading-item-08",
        configuration_id="A",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=6,
            difficulty="B2",
        ),
        source_pack_id="sp-antarctica-01",
    )
    result = runner.run_unit(request=req, passage_text=VALID_PASSAGE)

    # Output is a single passage research result, NOT a 3-section production paper
    assert result.task_type == "READING_SINGLE_PASSAGE"
    assert len(result.generated_content.question_groups) == 1
    assert len(result.generated_content.questions) == 5

    # Attempting to assemble a production paper with a single section raises ValueError
    bp_ref = ArtifactRef(
        artifactId="art_bp_01",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )
    s1 = create_mock_section_envelope(1, 800, "run_test_single")
    with pytest.raises(Exception):
        assemble_immutable_paper(
            sections=[s1],  # Only 1 section!
            blueprint_ref=bp_ref,
            run_id="run_test_single",
        )


def test_edge_rg05_s05_coexistence_without_collision():
    """EDGE-RG05-S05: Standalone research request and production paper contracts coexist cleanly."""
    req = StandaloneReadingRequest(
        run_id="run-coexistence-01",
        dataset_item_id="reading-item-09",
        configuration_id="C",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.SHORT_ANSWER],
            requested_question_count=4,
            difficulty="ADVANCED",
        ),
        source_pack_id="sp-coexist-01",
        is_research_mode=True,
    )
    assert req.is_research_mode is True
    assert req.task.task_type == "READING_SINGLE_PASSAGE"
