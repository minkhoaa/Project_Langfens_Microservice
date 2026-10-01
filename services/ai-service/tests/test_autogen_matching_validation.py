"""Tests for autogen_matching_validation service and canonical contract shapes."""
from __future__ import annotations

import copy
import json
from pathlib import Path

import pytest

from app.prompts.autogen_data import JSON_SHAPES
from app.services.autogen_matching_validation import (
    MATCHING_TYPES,
    validate_matching_question,
)

CONTRACT_PATH = Path(__file__).resolve().parents[1] / "app/prompts/autogen_contract.json"


@pytest.fixture(scope="module")
def contract_data() -> dict:
    with open(CONTRACT_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def test_all_19_json_shapes_are_valid_parseable_json():
    assert len(JSON_SHAPES) == 19
    for qtype, shape_str in JSON_SHAPES.items():
        parsed = json.loads(shape_str)
        assert isinstance(parsed, dict)
        assert parsed.get("type") == qtype


@pytest.mark.parametrize(
    "source_q,qtype",
    [
        (6, "MATCHING_HEADING"),
        (7, "MATCHING_INFORMATION"),
        (9, "MATCHING_FEATURES"),
        (10, "MATCHING_ENDINGS"),
        (20, "MATCHING_FEATURES"),
        (22, "MATCHING_ENDINGS"),
    ],
)
def test_canonical_matching_examples_pass_validation(contract_data, source_q, qtype):
    matching_exs = [
        e for e in contract_data["examples"]
        if e.get("sourceQuestion") == source_q and e.get("question", {}).get("type") == qtype
    ]
    assert len(matching_exs) == 1
    q = matching_exs[0]["question"]
    issues = validate_matching_question(
        q,
        expected_type=qtype,
        expected_skill=q.get("skill", "READING"),
        expected_difficulty=q.get("difficulty", 3),
    )
    assert issues == []


@pytest.mark.parametrize(
    "qtype",
    ["MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS"],
)
def test_matching_validation_rejects_non_dict(qtype):
    issues = validate_matching_question("not a dict", qtype, "READING", 3)
    assert issues == ["question must be a JSON object"]


@pytest.mark.parametrize(
    "qtype",
    ["MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS"],
)
def test_matching_validation_rejects_wrong_type(contract_data, qtype):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == qtype)
    bad = copy.deepcopy(ex)
    bad["type"] = "MULTIPLE_CHOICE_SINGLE"
    issues = validate_matching_question(bad, qtype, "READING", 3)
    assert any("type must be" in s for s in issues)


@pytest.mark.parametrize(
    "qtype",
    ["MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS"],
)
def test_matching_validation_rejects_wrong_skill(contract_data, qtype):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == qtype)
    bad = copy.deepcopy(ex)
    bad["skill"] = "LISTENING"
    issues = validate_matching_question(bad, qtype, "READING", 3)
    assert any("skill must be" in s for s in issues)


@pytest.mark.parametrize(
    "qtype",
    ["MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS"],
)
def test_matching_validation_rejects_boolean_or_mismatched_difficulty(contract_data, qtype):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == qtype)
    # boolean difficulty
    bad_bool = copy.deepcopy(ex)
    bad_bool["difficulty"] = True
    issues = validate_matching_question(bad_bool, qtype, "READING", 3)
    assert any("difficulty must be an integer" in s for s in issues)

    # mismatched difficulty
    bad_diff = copy.deepcopy(ex)
    bad_diff["difficulty"] = 5
    issues = validate_matching_question(bad_diff, qtype, "READING", 3)
    assert any("difficulty must be 3" in s for s in issues)


@pytest.mark.parametrize(
    "field",
    [
        "blankAcceptTexts",
        "blankAcceptRegex",
        "orderCorrects",
        "shortAnswerAcceptTexts",
        "shortAnswerAcceptRegex",
    ],
)
def test_matching_validation_rejects_forbidden_fields(contract_data, field):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    bad[field] = {"1": ["test"]} if "Texts" in field or "Regex" in field else ["step-a"]
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("forbidden answer-family field" in s for s in issues)


def test_matching_validation_rejects_letter_key_in_match_pairs(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    val = bad["matchPairs"].pop("1")
    bad["matchPairs"]["A"] = val
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("positive decimal string" in s for s in issues)


def test_matching_validation_rejects_target_mismatch(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    # Remove target 1 from prompt
    bad["promptMd"] = bad["promptMd"].replace("1. Blockbuster exhibitions\n", "")
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("do not match promptMd targets" in s for s in issues)


def test_matching_validation_rejects_is_correct_true(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    bad["options"][0]["isCorrect"] = True
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("isCorrect must be false" in s for s in issues)


def test_matching_validation_rejects_zero_or_duplicate_idx(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    # Duplicate idx
    bad_dup = copy.deepcopy(ex)
    bad_dup["options"][1]["idx"] = 1
    issues = validate_matching_question(bad_dup, "MATCHING_FEATURES", "READING", 3)
    assert any("options idx must be sequential 1-based integers" in s for s in issues)

    # 0 idx
    bad_zero = copy.deepcopy(ex)
    bad_zero["options"][0]["idx"] = 0
    issues = validate_matching_question(bad_zero, "MATCHING_FEATURES", "READING", 3)
    assert any("options idx must be sequential 1-based integers" in s for s in issues)


def test_matching_validation_rejects_unknown_grading_key(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    bad["matchPairs"]["1"] = ["Z", "Blockbuster exhibitions"]
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("does not exist in options choice pool" in s for s in issues)


def test_matching_validation_rejects_missing_display_label(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    bad["matchPairs"]["1"] = ["A", ""]
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("displayLabel must be a non-empty string" in s for s in issues)


def test_matching_validation_rejects_missing_distractor(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_HEADING")
    bad = copy.deepcopy(ex)
    # Retain only 5 options for 5 targets (no distractor)
    bad["options"] = bad["options"][:5]
    issues = validate_matching_question(bad, "MATCHING_HEADING", "READING", 3)
    assert any("distractor" in s for s in issues)


def test_matching_validation_rejects_duplicate_option_labels(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    bad["options"][1]["contentMd"] = bad["options"][0]["contentMd"]
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("options must have unique label keys" in s for s in issues)


def test_matching_heading_display_label_must_match_heading_text(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_HEADING")
    bad = copy.deepcopy(ex)
    # Mistakenly set displayLabel to paragraph name instead of heading text
    bad["matchPairs"]["1"] = ["i", "Paragraph 1"]
    issues = validate_matching_question(bad, "MATCHING_HEADING", "READING", 3)
    assert any("does not match correct heading text" in s for s in issues)


def test_matching_non_heading_display_label_must_match_target_text(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_FEATURES")
    bad = copy.deepcopy(ex)
    bad["matchPairs"]["1"] = ["A", "Incorrect Target Text"]
    issues = validate_matching_question(bad, "MATCHING_FEATURES", "READING", 3)
    assert any("does not match target text" in s for s in issues)


def test_matching_heading_and_endings_reject_duplicate_grading_keys(contract_data):
    # HEADING
    ex_h = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_HEADING")
    bad_h = copy.deepcopy(ex_h)
    bad_h["matchPairs"]["2"] = ["i", bad_h["matchPairs"]["1"][1]]
    issues_h = validate_matching_question(bad_h, "MATCHING_HEADING", "READING", 3)
    assert any("grading keys must be distinct" in s for s in issues_h)

    # ENDINGS
    ex_e = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_ENDINGS")
    bad_e = copy.deepcopy(ex_e)
    bad_e["matchPairs"]["2"] = ["A", bad_e["matchPairs"]["2"][1]]
    issues_e = validate_matching_question(bad_e, "MATCHING_ENDINGS", "READING", 3)
    assert any("grading keys must be distinct" in s for s in issues_e)


def test_matching_information_pool_format_enforced(contract_data):
    ex = next(e["question"] for e in contract_data["examples"] if e["question"]["type"] == "MATCHING_INFORMATION")
    bad = copy.deepcopy(ex)
    bad["options"][0]["contentMd"] = "A. Some other text"
    issues = validate_matching_question(bad, "MATCHING_INFORMATION", "READING", 3)
    assert any("must be 'A. Paragraph A'" in s for s in issues)
