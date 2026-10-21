"""Contract test verifying all 19 IELTS Reading question families have canonical wire names and candidate schemas."""

import pytest
from pydantic import BaseModel
from app.contracts.question_type import QuestionPromptFamily
from app.contracts.questions import (
    get_candidate_schema,
    TrueFalseCandidate,
    YesNoCandidate,
    SentenceCompletionCandidate,
    SummaryCompletionCandidate,
    SummaryBoxCandidate,
    MultipleChoiceSingleCandidate,
    MultipleChoiceMultipleCandidate,
    MatchingHeadingsCandidate,
    MatchingInformationCandidate,
    MatchingFeaturesCandidate,
    MatchingSentenceEndingsCandidate,
    TableCompletionCandidate,
    FlowChartCandidate,
    DiagramLabelCandidate,
    ShortAnswerCandidate,
    NoteCompletionCandidate,
    FormCompletionCandidate,
    ClassificationCandidate,
    ChoosingTitleCandidate,
)

EXPECTED_19_MAPPINGS = {
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: TrueFalseCandidate,
    QuestionPromptFamily.YES_NO_NOT_GIVEN: YesNoCandidate,
    QuestionPromptFamily.SENTENCE_COMPLETION: SentenceCompletionCandidate,
    QuestionPromptFamily.SUMMARY_COMPLETION: SummaryCompletionCandidate,
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX: SummaryBoxCandidate,
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: MultipleChoiceSingleCandidate,
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE: MultipleChoiceMultipleCandidate,
    QuestionPromptFamily.MATCHING_HEADING: MatchingHeadingsCandidate,
    QuestionPromptFamily.MATCHING_INFORMATION: MatchingInformationCandidate,
    QuestionPromptFamily.MATCHING_FEATURES: MatchingFeaturesCandidate,
    QuestionPromptFamily.MATCHING_ENDINGS: MatchingSentenceEndingsCandidate,
    QuestionPromptFamily.TABLE_COMPLETION: TableCompletionCandidate,
    QuestionPromptFamily.FLOW_CHART: FlowChartCandidate,
    QuestionPromptFamily.DIAGRAM_LABEL: DiagramLabelCandidate,
    QuestionPromptFamily.SHORT_ANSWER: ShortAnswerCandidate,
    QuestionPromptFamily.NOTE_COMPLETION: NoteCompletionCandidate,
    QuestionPromptFamily.FORM_COMPLETION: FormCompletionCandidate,
    QuestionPromptFamily.CLASSIFICATION: ClassificationCandidate,
    QuestionPromptFamily.CHOOSING_TITLE: ChoosingTitleCandidate,
}


def test_all_19_types_have_schemas_and_wire_names():
    assert len(QuestionPromptFamily) >= 19
    for family in QuestionPromptFamily:
        schema_cls = get_candidate_schema(family)
        assert schema_cls is not None, f"Missing schema class for {family}"
        assert issubclass(schema_cls, BaseModel), f"{schema_cls} must inherit from pydantic.BaseModel"


def test_expected_mappings_and_instantiation():
    for family, expected_cls in EXPECTED_19_MAPPINGS.items():
        resolved_cls = get_candidate_schema(family)
        assert resolved_cls == expected_cls, f"Expected {expected_cls} for {family}, got {resolved_cls}"


def test_wire_values_match_canonical_strings():
    # Canonical wire constants matching C# QuestionType constants
    assert QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN.value == "TRUE_FALSE_NOT_GIVEN"
    assert QuestionPromptFamily.YES_NO_NOT_GIVEN.value == "YES_NO_NOT_GIVEN"
    assert QuestionPromptFamily.SENTENCE_COMPLETION.value == "SENTENCE_COMPLETION"
    assert QuestionPromptFamily.SUMMARY_COMPLETION.value == "SUMMARY_COMPLETION"
    assert QuestionPromptFamily.SUMMARY_COMPLETION_BOX.value == "SUMMARY_COMPLETION_BOX"
    assert QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE.value == "MULTIPLE_CHOICE_SINGLE"
    assert QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE.value == "MULTIPLE_CHOICE_MULTIPLE"
    assert QuestionPromptFamily.MATCHING_HEADING.value == "MATCHING_HEADING"
    assert QuestionPromptFamily.MATCHING_INFORMATION.value == "MATCHING_INFORMATION"
    assert QuestionPromptFamily.MATCHING_FEATURES.value == "MATCHING_FEATURES"
    assert QuestionPromptFamily.MATCHING_ENDINGS.value == "MATCHING_ENDINGS"
    assert QuestionPromptFamily.TABLE_COMPLETION.value == "TABLE_COMPLETION"
    assert QuestionPromptFamily.FLOW_CHART.value == "FLOW_CHART"
    assert QuestionPromptFamily.DIAGRAM_LABEL.value == "DIAGRAM_LABEL"
    assert QuestionPromptFamily.SHORT_ANSWER.value == "SHORT_ANSWER"
    assert QuestionPromptFamily.NOTE_COMPLETION.value == "NOTE_COMPLETION"
    assert QuestionPromptFamily.FORM_COMPLETION.value == "FORM_COMPLETION"
    assert QuestionPromptFamily.CLASSIFICATION.value == "CLASSIFICATION"
    assert QuestionPromptFamily.CHOOSING_TITLE.value == "CHOOSING_TITLE"


def test_question_prompt_family_from_raw():
    assert QuestionPromptFamily.from_raw("TRUE_FALSE_NOT_GIVEN") == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN
    assert QuestionPromptFamily.from_raw("true_false_not_given") == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN
    assert QuestionPromptFamily.from_raw("TrueFalseNotGiven") == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN
    assert QuestionPromptFamily.from_raw("matching_headings") == QuestionPromptFamily.MATCHING_HEADING
    assert QuestionPromptFamily.from_raw("CHOOSING_A_TITLE") == QuestionPromptFamily.CHOOSING_TITLE
    assert QuestionPromptFamily.from_raw("summary_box") == QuestionPromptFamily.SUMMARY_COMPLETION_BOX

    with pytest.raises(ValueError, match="Unknown or unsupported question family: INVALID_FAMILY"):
        QuestionPromptFamily.from_raw("INVALID_FAMILY")

    with pytest.raises(ValueError, match="Unknown or unsupported question family"):
        QuestionPromptFamily.from_raw("unsupported_custom_type")
