"""Unit tests for RG03-S04: Partial and Uncertain Evaluation Results."""

import json
from pathlib import Path
import jsonschema
import pytest

from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import EvaluationVerdict


def load_schemas():
    schema_path = Path(__file__).resolve().parents[3] / "generation_baseline" / "contracts" / "JSON_SCHEMAS.json"
    return json.loads(schema_path.read_text())


PASSAGE_SAMPLE = (
    "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. "
    "Recent satellite observations indicate that portions of the West Antarctic Ice Sheet "
    "have been losing mass at an accelerated rate over the past two decades."
)

VALID_QUESTION = {
    "question_number": 1,
    "question_type": "TFNG",
    "prompt": "The Antarctic ice sheet holds the majority of the world's fresh water.",
    "answer": "TRUE",
    "evidence_quote": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
}


def test_pos_rg03_s04_deterministic_accounting_and_schema_validation():
    """POS-RG03-S04: Completed, raw-only, parseable, and none scenarios have deterministic accounting.

    Emitted EvaluationResult conforms strictly to JSON_SCHEMAS.json#/$defs/EvaluationResult.
    """
    schemas = load_schemas()
    validator = jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/EvaluationResult",
    })
    evaluator = NeutralEvaluator()

    # 1. Completed valid run
    res_valid = evaluator.evaluate_item(
        dataset_item_id="item-pos-01",
        passage_text=PASSAGE_SAMPLE,
        question_data=VALID_QUESTION,
    )
    assert res_valid.evaluable is True
    assert res_valid.verdict == EvaluationVerdict.PASS
    validator.validate(res_valid.model_dump())

    # 2. Parseable but ungrounded run
    ungrounded_q = dict(VALID_QUESTION, evidence_quote="Nonexistent quote from outer space.")
    res_ungrounded = evaluator.evaluate_item(
        dataset_item_id="item-pos-02",
        passage_text=PASSAGE_SAMPLE,
        question_data=ungrounded_q,
    )
    assert res_ungrounded.evaluable is True
    assert res_ungrounded.verdict == EvaluationVerdict.FAIL
    validator.validate(res_ungrounded.model_dump())


def test_neg_rg03_s04_no_output_cannot_receive_invented_semantic_scores():
    """NEG-RG03-S04: No-output requests cannot receive invented semantic scores."""
    schemas = load_schemas()
    validator = jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/EvaluationResult",
    })
    evaluator = NeutralEvaluator()

    # Scenario: None payload (no output generated)
    res_none = evaluator.evaluate_item(
        dataset_item_id="item-none",
        passage_text=PASSAGE_SAMPLE,
        question_data=None,
    )
    assert res_none.evaluable is False
    assert res_none.verdict == EvaluationVerdict.FAIL
    assert res_none.semantic_scores == {}  # Strictly empty: NO invented scores!
    assert res_none.abstention_reason == "Empty or non-parseable question payload"
    validator.validate(res_none.model_dump())

    # Scenario: Empty dictionary payload
    res_empty = evaluator.evaluate_item(
        dataset_item_id="item-empty",
        passage_text=PASSAGE_SAMPLE,
        question_data={},
    )
    assert res_empty.evaluable is False
    assert res_empty.verdict == EvaluationVerdict.FAIL
    assert res_empty.semantic_scores == {}
    validator.validate(res_empty.model_dump())


def test_edge_rg03_s04_truncated_passage_or_missing_prompt():
    """EDGE-RG03-S04: Truncated passage (< 30 chars) or missing prompt sets evaluable=False."""
    evaluator = NeutralEvaluator()

    # Short passage
    res_short = evaluator.evaluate_item(
        dataset_item_id="item-short",
        passage_text="Too short",
        question_data=VALID_QUESTION,
    )
    assert res_short.evaluable is False
    assert res_short.verdict == EvaluationVerdict.FAIL
    assert "passage too short" in res_short.abstention_reason.lower()

    # Missing prompt
    no_prompt_q = dict(VALID_QUESTION, prompt="")
    res_no_prompt = evaluator.evaluate_item(
        dataset_item_id="item-no-prompt",
        passage_text=PASSAGE_SAMPLE,
        question_data=no_prompt_q,
    )
    assert res_no_prompt.evaluable is False
    assert res_no_prompt.verdict == EvaluationVerdict.FAIL
    assert "prompt missing" in res_no_prompt.abstention_reason.lower()

def test_edge_rg03_s04_in_loop_evaluation_result_bridge_to_canonical_schema():
    """EDGE-RG03-S04: In-loop engine EvaluationResult bridges to normative JSON_SCHEMAS.json#/$defs/EvaluationResult."""
    from app.contracts.artifact import ArtifactRef, ArtifactType
    from app.contracts.evaluation import EvaluationResult, EvaluationStatus

    schemas = load_schemas()
    validator = jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/EvaluationResult",
    })

    target = ArtifactRef(
        artifact_id="art_123",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        content_hash="b" * 64,
    )
    in_loop_res = EvaluationResult(
        evaluation_id="eval_in_loop_01",
        evaluator_id="det_eval_v1",
        evaluator_version="1.0.0",
        target_ref=target,
        status=EvaluationStatus.ERROR,
    )

    canonical_payload = in_loop_res.to_canonical_research_result(
        dataset_item_id="ds_item_01",
        output_sha256="a" * 64,
    )

    assert canonical_payload["verdict"] == "UNCERTAIN"  # ERROR maps to UNCERTAIN
    assert canonical_payload["evaluable"] is False
    validator.validate(canonical_payload)
