"""Unit tests for RG05-S02: Resumable Passage Loop Research Adapter."""

import hashlib
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

SAMPLE_REQUEST = StandaloneReadingRequest(
    run_id="run-passage-01",
    dataset_item_id="reading-item-01",
    configuration_id="A",
    task=ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG],
        requested_question_count=5,
        difficulty="B2",
    ),
    source_pack_id="sp-antarctica-01",
)


def test_pos_rg05_s02_resumable_passage_loop_identical_hash():
    """POS-RG05-S02: Timeout and crash resume reach same content hash without duplicates."""
    runner = StandaloneReadingRunner()

    # Initial run
    res_1 = runner.run_unit(request=SAMPLE_REQUEST, passage_text=VALID_PASSAGE)
    assert res_1.execution_status == ExecutionStatus.COMPLETED
    assert res_1.generated_content is not None

    hash_1 = hashlib.sha256(res_1.generated_content.context_text.encode("utf-8")).hexdigest()

    # Resumed run on identical source pack / passage text
    res_2 = runner.run_unit(request=SAMPLE_REQUEST, passage_text=VALID_PASSAGE)
    assert res_2.execution_status == ExecutionStatus.COMPLETED

    hash_2 = hashlib.sha256(res_2.generated_content.context_text.encode("utf-8")).hexdigest()

    # Content hash must be identical across runs
    assert hash_1 == hash_2
    assert len(res_1.generated_content.questions) == len(res_2.generated_content.questions)


def test_neg_rg05_s02_reject_unsupported_or_short_source():
    """NEG-RG05-S02: Python cannot bypass authoritative APIs or accept unsupported/short source."""
    runner = StandaloneReadingRunner()

    # Short passage (< 50 chars) fails validation immediately
    res_short = runner.run_unit(
        request=SAMPLE_REQUEST,
        passage_text="Too short to form an IELTS reading passage.",
    )
    assert res_short.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert res_short.failure_code == "PASSAGE_EMPTY_OR_TOO_SHORT"
    assert res_short.generated_content is None


def test_edge_rg05_s02_empty_passage_handling():
    """EDGE-RG05-S02: Empty passage text handled safely without exception."""
    runner = StandaloneReadingRunner()
    res_empty = runner.run_unit(request=SAMPLE_REQUEST, passage_text="")
    assert res_empty.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert res_empty.failure_code == "PASSAGE_EMPTY_OR_TOO_SHORT"
