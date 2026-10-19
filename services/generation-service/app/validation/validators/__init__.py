"""Registers all 19 canonical IELTS question validators into the registry."""
from __future__ import annotations

from app.validation.registry import QuestionValidatorRegistry
from app.validation.validators.choice import (
    MultipleChoiceMultipleValidator,
    MultipleChoiceSingleImageValidator,
    MultipleChoiceSingleValidator,
    TrueFalseNotGivenValidator,
    YesNoNotGivenValidator,
)
from app.validation.validators.completion import (
    DiagramLabelValidator,
    FormCompletionValidator,
    MapLabelValidator,
    NoteCompletionValidator,
    SentenceCompletionValidator,
    SummaryCompletionValidator,
    TableCompletionValidator,
)
from app.validation.validators.matching import (
    ClassificationValidator,
    MatchingEndingsValidator,
    MatchingFeaturesValidator,
    MatchingHeadingValidator,
    MatchingInformationValidator,
)
from app.validation.validators.ordering import FlowChartValidator
from app.validation.validators.short_answer import ShortAnswerValidator


def register_all_validators(registry: QuestionValidatorRegistry) -> None:
    """Register all 19 IELTS question type validators."""
    # Choice types (5)
    registry.register(MultipleChoiceSingleValidator())
    registry.register(MultipleChoiceMultipleValidator())
    registry.register(MultipleChoiceSingleImageValidator())
    registry.register(TrueFalseNotGivenValidator())
    registry.register(YesNoNotGivenValidator())

    # Completion types (7)
    registry.register(SummaryCompletionValidator())
    registry.register(TableCompletionValidator())
    registry.register(NoteCompletionValidator())
    registry.register(FormCompletionValidator())
    registry.register(SentenceCompletionValidator())
    registry.register(DiagramLabelValidator())
    registry.register(MapLabelValidator())

    # Matching types (5)
    registry.register(MatchingHeadingValidator())
    registry.register(MatchingInformationValidator())
    registry.register(MatchingFeaturesValidator())
    registry.register(MatchingEndingsValidator())
    registry.register(ClassificationValidator())

    # Ordering type (1)
    registry.register(FlowChartValidator())

    # Short answer type (1)
    registry.register(ShortAnswerValidator())
