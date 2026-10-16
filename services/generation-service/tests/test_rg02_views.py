"""Tests for RG02-S02 Isolated Evidence Views and Canary/Alias Security Scans."""

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.solver import (
    AnswerVerificationView,
    BlindSolverResult,
    CanonicalQuestion,
    GoldReferenceView,
    SecurityLeakageError,
    SolverView,
)
from app.solvers.serializer import (
    project_to_answer_verification_view,
    project_to_gold_reference_view,
    project_to_solver_view,
)


def load_schemas():
    schema_path = Path(__file__).resolve().parents[3] / "generation_baseline" / "contracts" / "JSON_SCHEMAS.json"
    return json.loads(schema_path.read_text())


def test_pos_solver_view_projection_and_schema():
    """POS: Projecting raw question strips answer/explanation and conforms to JSON_SCHEMAS.json."""
    schemas = load_schemas()
    raw_q = {
        "question_id": "q101",
        "question_type": "TFNG",
        "prompt": "Is synthetic biology growing rapidly?",
        "instructions": "Choose TRUE, FALSE, or NOT GIVEN.",
        "answer": "TRUE",
        "correctOption": "TRUE",
        "explanation": "Private rationale that must not leak",
        "canary": "CANARY_123",
    }
    context = "The rapid growth of synthetic biology has unlocked unprecedented opportunities."
    sv = project_to_solver_view(context_text=context, question_data=raw_q)

    assert sv.question.text == "Is synthetic biology growing rapidly?"
    assert not hasattr(sv.question, "answer")
    assert not hasattr(sv.question, "correctOption")

    jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/SolverView",
    }).validate(sv.model_dump())


def test_pos_answer_verification_view_schema():
    """POS: AnswerVerificationView matches JSON_SCHEMAS.json specification."""
    schemas = load_schemas()
    av = project_to_answer_verification_view(
        blind_result={
            "question_id": "q101",
            "proposed_solution": "TRUE",
            "reasoning_evidence": "Passage mentions rapid growth",
            "confidence": 0.95,
        },
        generator_proposed_answer="TRUE",
        source_evidence_ref="evidence-ref-101",
        acceptable_variants=["true", "True"],
    )
    jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/AnswerVerificationView",
    }).validate(av.model_dump())


def test_pos_gold_reference_view_schema():
    """POS: GoldReferenceView matches JSON_SCHEMAS.json specification."""
    schemas = load_schemas()
    gv = project_to_gold_reference_view(
        item_id="q101",
        expert_label="TRUE",
        label_version="v1.0",
        adjudicator_id="expert-human-01",
    )
    jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/GoldReferenceView",
    }).validate(gv.model_dump())


def test_neg_serialized_alias_in_allowed_reference_text():
    """NEG: Serialized JSON containing generator_proposed_answer in allowed_reference_text is rejected."""
    raw_q = {"question_id": "q101", "question_type": "TFNG", "prompt": "Prompt", "instructions": "Inst"}
    injected_text = json.dumps({"generator_proposed_answer": "CANARY_SECRET"})
    with pytest.raises((SecurityLeakageError, ValidationError)) as excinfo:
        project_to_solver_view("Valid text.", raw_q, allowed_reference_text=injected_text)
    assert "generator_proposed_answer" in str(excinfo.value)


def test_neg_canary_in_context_text():
    """NEG: Canary strings in context_text are rejected immediately."""
    raw_q = {"question_id": "q101", "question_type": "TFNG", "prompt": "Prompt", "instructions": "Inst"}
    with pytest.raises((SecurityLeakageError, ValidationError)) as excinfo:
        project_to_solver_view("Context with CANARY_SECRET embedded.", raw_q)
    assert "canary" in str(excinfo.value).lower()


def test_neg_direct_solver_view_leak_rejection():
    """NEG: Direct creation of SolverView with correct_option alias in reference text fails."""
    with pytest.raises((SecurityLeakageError, ValidationError)) as excinfo:
        SolverView(
            context_text="Valid text",
            question=CanonicalQuestion(question_id="q1", question_type="TFNG", text="Valid text", instructions="Inst"),
            allowed_reference_text='{"correct_option": "A"}',
        )
    assert "correct_option" in str(excinfo.value)


def test_neg_serialized_answer_alias_in_allowed_reference_text():
    """NEG: Serialized JSON containing answer and explanation in allowed_reference_text is rejected."""
    raw_q = {"question_id": "q101", "question_type": "TFNG", "prompt": "Prompt", "instructions": "Inst"}
    injected_text = json.dumps({"answer": "TRUE", "explanation": "This is leaked rationale"})
    with pytest.raises((SecurityLeakageError, ValidationError)) as excinfo:
        project_to_solver_view("Valid text.", raw_q, allowed_reference_text=injected_text)
    assert "answer" in str(excinfo.value).lower()

def test_edge_empty_fields_and_short_passages():
    """EDGE: Empty context text, missing adjudicator_id, and short passages fail validation."""
    raw_q = {"question_id": "q1", "question_type": "TFNG", "prompt": "Prompt"}
    with pytest.raises(ValueError):
        project_to_solver_view("", raw_q)

    with pytest.raises(ValueError):
        project_to_gold_reference_view("q1", "TRUE", "v1", "")

    with pytest.raises(ValueError):
        project_to_answer_verification_view(
            blind_result={"question_id": "q1", "proposed_solution": "T", "reasoning_evidence": "E", "confidence": 1.0},
            generator_proposed_answer="",
            source_evidence_ref="ref",
        )
