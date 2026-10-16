"""Unit tests for RG05-S04: Neutral Output, Partials and Usage."""

import json
from pathlib import Path
import jsonschema
import pytest

from app.contracts.research import (
    ExecutionStatus,
    OutputAvailability,
    ReadingTask,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.loop.standalone_reading import StandaloneReadingRunner


def load_schemas():
    schema_path = Path(__file__).resolve().parents[3] / "generation_baseline" / "contracts" / "JSON_SCHEMAS.json"
    return json.loads(schema_path.read_text())


VALID_PASSAGE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have been losing mass at an accelerated rate over the past two decades."
)

SAMPLE_REQUEST = StandaloneReadingRequest(
    run_id="run-output-01",
    dataset_item_id="reading-item-06",
    configuration_id="A",
    task=ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG],
        requested_question_count=5,
        difficulty="B2",
    ),
    source_pack_id="sp-antarctica-01",
)


def test_pos_rg05_s04_failed_validation_retains_parseable_output():
    """POS-RG05-S04: Parseable failed output retained for fair external evaluation."""
    schemas = load_schemas()
    validator = jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/GenerationResult",
    })

    runner = StandaloneReadingRunner()
    result = runner.run_unit(
        request=SAMPLE_REQUEST,
        passage_text=VALID_PASSAGE,
        simulate_failure="VALIDATION_FAILED",
    )

    # Invariants for partial failed run:
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.output_availability == OutputAvailability.PARSEABLE
    assert result.generated_content is not None
    assert result.failure_code == "DISTRACTOR_AMBIGUITY"

    # Schema validation against normative JSON_SCHEMAS.json
    validator.validate(result.model_dump(mode="json"))


def test_neg_rg05_s04_timeout_produces_raw_only_without_invented_tokens():
    """NEG-RG05-S04: UNKNOWN provider tokens not coerced to zero; timeouts produce RAW_ONLY."""
    schemas = load_schemas()
    validator = jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/GenerationResult",
    })

    runner = StandaloneReadingRunner()
    result = runner.run_unit(
        request=SAMPLE_REQUEST,
        passage_text=VALID_PASSAGE,
        simulate_failure="TIMEOUT",
    )

    assert result.execution_status == ExecutionStatus.TIMED_OUT
    assert result.output_availability == OutputAvailability.RAW_ONLY
    assert result.generated_content is None
    assert result.failure_code == "WALL_TIME_EXCEEDED"

    validator.validate(result.model_dump(mode="json"))


def test_edge_rg05_s04_completed_generation_result_schema_valid():
    """EDGE-RG05-S04: Completed run conforms strictly to JSON_SCHEMAS.json#/$defs/GenerationResult."""
    schemas = load_schemas()
    validator = jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/GenerationResult",
    })

    runner = StandaloneReadingRunner()
    result = runner.run_unit(request=SAMPLE_REQUEST, passage_text=VALID_PASSAGE)

    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.output_availability == OutputAvailability.NORMALIZED
    assert result.generated_content is not None
    validator.validate(result.model_dump(mode="json"))
