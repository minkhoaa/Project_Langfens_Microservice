"""Prompt contract tests for section-aware IELTS Reading generation."""

import pytest

from app.prompts import (
    build_group_instruction,
    build_passage_extension_prompt,
    build_passage_prompt,
    build_passage_revision_prompt,
    build_question_prompt,
)


@pytest.mark.parametrize("index", [1, 2])
def test_non_third_section_passage_prompts_do_not_require_sustained_argument(index):
    prompt = build_passage_prompt("digital writing tools", index, "Study of writing practice")

    assert "must contain a sustained argument" not in prompt.casefold()
    assert "do not include internal section labels" in prompt.casefold()


def test_third_section_passage_prompt_uses_its_own_argument_profile():
    prompt = build_passage_prompt("digital writing tools", 3, "Study of writing practice")

    assert "must contain a sustained argument" in prompt.casefold()
    assert "section 3" in prompt.casefold()


def test_passage_prompt_preserves_source_limits_and_avoids_causal_overclaiming():
    prompt = build_passage_prompt("digital writing tools", 1, "Study of writing practice")

    assert "do not turn correlation into causation" in prompt.casefold()
    assert "preserve the study's limitations" in prompt.casefold()
    assert "do not copy sentences from the source" in prompt.casefold()


@pytest.mark.parametrize("index", [1, 2, 3])
def test_passage_extension_prompt_preserves_source_fidelity_and_section_profile(index):
    prompt = build_passage_extension_prompt("digital writing tools", index, requested_words=200).casefold()

    assert "preserve the study's limitations" in prompt
    assert "do not turn correlation into causation" in prompt
    assert "do not include a heading" in prompt
    assert ("must contain a sustained argument" in prompt) is (index == 3)


@pytest.mark.parametrize("index", [1, 2, 3])
def test_passage_revision_prompt_preserves_source_fidelity_and_section_profile(index):
    prompt = build_passage_revision_prompt("digital writing tools", index).casefold()

    assert "fix only the listed source-fidelity problems" in prompt
    assert "preserve the study's limitations" in prompt
    assert "do not turn correlation into causation" in prompt
    assert "do not include internal section labels" in prompt
    assert ("must contain a sustained argument" in prompt) is (index == 3)


@pytest.mark.parametrize(
    ("kind", "required"),
    [
        ("TRUE_FALSE_NOT_GIVEN", ("supported by the passage", "contradicted by the passage", "neither stated nor contradicted")),
        ("YES_NO_NOT_GIVEN", ("the writer's view or claim", "neither stated nor contradicted")),
        ("MULTIPLE_CHOICE_SINGLE", ("exactly one correct answer", "four distinct options labelled a. to d.")),
        ("SENTENCE_COMPLETION", ("exactly one numbered blank marker", "own number", "no more than three words and/or a number")),
        ("SUMMARY_COMPLETION", ("one coherent summary", "no more than three words and/or a number")),
        ("SHORT_ANSWER", ("direct question", "no more than three words and/or a number")),
    ],
)
def test_question_prompt_has_type_specific_constraints(kind, required):
    prompt = build_question_prompt(kind, count=1, first=8, last=8).casefold()

    for phrase in required:
        assert phrase in prompt


def test_completion_prompt_uses_each_questions_own_numbered_blank():
    prompt = build_question_prompt("SENTENCE_COMPLETION", count=3, first=8, last=10).casefold()

    assert "exactly one numbered blank marker using that question's own number" in prompt
    assert "[8] for question 8 and [9] for question 9" in prompt


@pytest.mark.parametrize(
    ("kind", "expected"),
    [
        ("TRUE_FALSE_NOT_GIVEN", "TRUE if the passage supports each part of the statement; FALSE if the passage contradicts it; NOT GIVEN if it is neither stated nor contradicted."),
        ("YES_NO_NOT_GIVEN", "YES if the writer expresses this view; NO if the writer expresses the opposite view; NOT GIVEN if the writer's view is neither stated nor contradicted."),
        ("SENTENCE_COMPLETION", "Write NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer."),
        ("SUMMARY_COMPLETION", "Complete the summary. Write NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer."),
        ("SHORT_ANSWER", "Answer each question using NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage."),
        ("MULTIPLE_CHOICE_SINGLE", "Choose the correct letter, A, B, C or D."),
    ],
)
def test_group_instruction_is_explicit_for_its_question_type(kind, expected):
    assert build_group_instruction(kind, 8, 13) == f"Questions 8–13. {expected}"


def test_replacement_question_prompt_keeps_the_type_rubric():
    prompt = build_question_prompt("TRUE_FALSE_NOT_GIVEN", count=1, first=7, last=7, replacement=True).casefold()

    assert "replace only question 7" in prompt
    assert "false means at least one part is directly contradicted" in prompt
    assert 'return json object {"question":' in prompt
