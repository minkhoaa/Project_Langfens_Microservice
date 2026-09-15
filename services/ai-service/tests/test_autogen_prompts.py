"""Snapshot tests for autogen prompt builders.

These tests ensure the prompt builder produces stable output across refactors.
Update snapshots only when prompt changes are intentional.
"""
from __future__ import annotations

import pytest

from app.prompts.autogen import build_system_prompt, build_user_prompt


@pytest.mark.parametrize(
    "qtype,json_shape,constraints",
    [
        ("MULTIPLE_CHOICE_SINGLE", '{"type":"X","options":[]}', ["options ≥ 2"]),
        ("SUMMARY_COMPLETION", '{"type":"X","blankAcceptTexts":{}}', ["blankAcceptTexts ≥ 1"]),
        ("FLOW_CHART", '{"type":"X","orderCorrects":[]}', ["orderCorrects ≥ 2"]),
    ],
)
def test_build_system_prompt_includes_required_sections(qtype, json_shape, constraints):
    prompt = build_system_prompt(qtype, json_shape, constraints)
    assert qtype in prompt
    assert json_shape in prompt
    assert "Strict JSON mode" in prompt
    assert "Output ONLY a single JSON array" in prompt


def test_build_system_prompt_includes_constraints():
    constraints = ["MCQ must have ≥ 2 options", "Exactly 1 isCorrect=true"]
    prompt = build_system_prompt("MULTIPLE_CHOICE_SINGLE", "{}", constraints)
    assert "MCQ must have ≥ 2 options" in prompt
    assert "Exactly 1 isCorrect=true" in prompt


def test_build_user_prompt_includes_passage_count_difficulty():
    prompt = build_user_prompt("MULTIPLE_CHOICE_SINGLE", "source text here", 3, 4)
    assert "source text here" in prompt
    assert "Generate 3 MULTIPLE_CHOICE_SINGLE question(s)" in prompt
    assert "at difficulty 4" in prompt


def test_build_user_prompt_includes_optional_extra():
    prompt = build_user_prompt(
        "MULTIPLE_CHOICE_SINGLE", "passage", 2, 3, extra="academic register"
    )
    assert "Extra context: academic register" in prompt


def test_build_user_prompt_omits_extra_when_empty():
    prompt = build_user_prompt("MULTIPLE_CHOICE_SINGLE", "passage", 2, 3)
    assert "Extra context" not in prompt
