"""Unit tests for RG05-S03: Candidate Groups and Local Verification."""

import pytest
from app.contracts.research import (
    ExecutionStatus,
    ReadingTask,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.loop.standalone_reading import StandaloneReadingRunner


VALID_PASSAGE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have been losing mass at an accelerated rate over the past two decades. However, "
    "East Antarctica remains relatively stable, with some high-altitude areas experiencing "
    "modest gains in snowfall that partially offset coastal losses."
)


def test_pos_rg05_s03_candidate_groups_uniqueness_and_types():
    """POS-RG05-S03: Question answer uniqueness, TFNG/YNNG, MCQ and completion case tests."""
    runner = StandaloneReadingRunner()

    req = StandaloneReadingRequest(
        run_id="run-groups-01",
        dataset_item_id="reading-item-03",
        configuration_id="A",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.MCQ_SINGLE],
            requested_question_count=10,
            difficulty="B2",
        ),
        source_pack_id="sp-antarctica-01",
    )

    result = runner.run_unit(request=req, passage_text=VALID_PASSAGE)
    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.generated_content is not None

    content = result.generated_content
    assert len(content.question_groups) == 2

    # Check question ID uniqueness
    all_q_ids = [q.question_id for q in content.questions]
    assert len(all_q_ids) == len(set(all_q_ids)), "Question IDs must be strictly unique"

    # Check group 1: TFNG questions
    tfng_qs = [q for q in content.questions if q.question_type == StandaloneGroupType.TFNG]
    assert len(tfng_qs) > 0
    for q in tfng_qs:
        assert "TRUE, FALSE, or NOT GIVEN" in q.instructions

    # Check group 2: MCQ questions with distinct options
    mcq_qs = [q for q in content.questions if q.question_type == StandaloneGroupType.MCQ_SINGLE]
    assert len(mcq_qs) > 0
    for q in mcq_qs:
        assert len(q.options) >= 2
        assert len(q.options) == len(set(q.options)), "MCQ options must be distinct"


def test_neg_rg05_s03_question_id_drift_prevention():
    """NEG-RG05-S03: Shared summary dependencies and question IDs cannot silently drift."""
    runner = StandaloneReadingRunner()

    req = StandaloneReadingRequest(
        run_id="run-groups-02",
        dataset_item_id="reading-item-04",
        configuration_id="B",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.SENTENCE_COMPLETION],
            requested_question_count=5,
            difficulty="MODERATE",
        ),
        source_pack_id="sp-antarctica-01",
    )

    result = runner.run_unit(request=req, passage_text=VALID_PASSAGE)
    content = result.generated_content

    # Every question ID referenced in question_groups MUST exist in questions list
    declared_q_ids = set()
    for g in content.question_groups:
        declared_q_ids.update(g.question_ids)

    actual_q_ids = {q.question_id for q in content.questions}
    assert declared_q_ids == actual_q_ids, "Question group mapping drifted from question list"


def test_edge_rg05_s03_single_group_partitioning():
    """EDGE-RG05-S03: Single group partition creates exactly 1 question group."""
    runner = StandaloneReadingRunner()
    req = StandaloneReadingRequest(
        run_id="run-groups-03",
        dataset_item_id="reading-item-05",
        configuration_id="C",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.SHORT_ANSWER],
            requested_question_count=4,
            difficulty="ADVANCED",
        ),
        source_pack_id="sp-antarctica-01",
    )
    result = runner.run_unit(request=req, passage_text=VALID_PASSAGE)
    assert len(result.generated_content.question_groups) == 1
