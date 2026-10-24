"""Unit tests for RG05-S01: Standalone Reading Request Contract."""

import pytest
from pydantic import ValidationError

from app.contracts.research import (
    ReadingTask,
    StandaloneGroupType,
    StandaloneReadingRequest,
)


def test_pos_rg05_s01_valid_standalone_reading_request():
    """POS-RG05-S01: Valid standalone reading request with 1-2 groups and difficulty."""
    # 1. Single group request
    req_single = StandaloneReadingRequest(
        run_id="run-test-01",
        dataset_item_id="reading-item-01",
        configuration_id="A",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=6,
            difficulty="B2",
        ),
        source_pack_id="sp-antarctica-01",
    )
    assert req_single.task.task_type == "READING_SINGLE_PASSAGE"
    assert len(req_single.task.requested_groups) == 1
    assert req_single.is_research_mode is True

    # 2. Two groups request
    req_double = StandaloneReadingRequest(
        run_id="run-test-02",
        dataset_item_id="reading-item-02",
        configuration_id="B",
        task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
            requested_question_count=13,
            difficulty="MODERATE",
        ),
        source_pack_id="sp-energy-01",
    )
    assert len(req_double.task.requested_groups) == 2


def test_neg_rg05_s01_cannot_impersonate_full_paper():
    """NEG-RG05-S01: Research unit cannot impersonate completed 40-question Exam.

    Rejects requests with task_type != 'READING_SINGLE_PASSAGE' or > 2 groups.
    """
    # Reject task_type='READING_FULL_PAPER' in standalone reading request
    with pytest.raises(ValidationError):
        ReadingTask(
            task_type="READING_FULL_PAPER",  # Forbidden for standalone reading unit!
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=40,
            difficulty="B2",
        )

    # Reject > 2 groups
    with pytest.raises(ValidationError):
        ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[
                StandaloneGroupType.TFNG,
                StandaloneGroupType.MCQ_SINGLE,
                StandaloneGroupType.SUMMARY_COMPLETION,  # 3 groups!
            ],
            requested_question_count=15,
            difficulty="B2",
        )


def test_edge_rg05_s01_empty_groups_or_zero_questions():
    """EDGE-RG05-S01: Zero groups or question count < 1 rejected."""
    # Empty groups list
    with pytest.raises(ValidationError):
        ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[],
            requested_question_count=5,
            difficulty="B2",
        )

    # Question count < 1
    with pytest.raises(ValidationError):
        ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=0,
            difficulty="B2",
        )
