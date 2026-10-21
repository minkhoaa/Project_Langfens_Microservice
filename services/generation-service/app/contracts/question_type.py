"""Canonical Question Prompt Families and Wire Constants.

Defines the 19 IELTS Reading question families with wire constants matching
Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs.
"""

from __future__ import annotations

from enum import Enum
from typing import Any


class QuestionPromptFamily(str, Enum):
    """Canonical enum representing the 19 IELTS Reading question families."""

    TRUE_FALSE_NOT_GIVEN = "TRUE_FALSE_NOT_GIVEN"
    YES_NO_NOT_GIVEN = "YES_NO_NOT_GIVEN"
    SENTENCE_COMPLETION = "SENTENCE_COMPLETION"
    SUMMARY_COMPLETION = "SUMMARY_COMPLETION"
    SUMMARY_COMPLETION_BOX = "SUMMARY_COMPLETION_BOX"
    MULTIPLE_CHOICE_SINGLE = "MULTIPLE_CHOICE_SINGLE"
    MULTIPLE_CHOICE_MULTIPLE = "MULTIPLE_CHOICE_MULTIPLE"
    MATCHING_HEADING = "MATCHING_HEADING"
    MATCHING_INFORMATION = "MATCHING_INFORMATION"
    MATCHING_FEATURES = "MATCHING_FEATURES"
    MATCHING_ENDINGS = "MATCHING_ENDINGS"
    TABLE_COMPLETION = "TABLE_COMPLETION"
    FLOW_CHART = "FLOW_CHART"
    DIAGRAM_LABEL = "DIAGRAM_LABEL"
    SHORT_ANSWER = "SHORT_ANSWER"
    NOTE_COMPLETION = "NOTE_COMPLETION"
    FORM_COMPLETION = "FORM_COMPLETION"
    CLASSIFICATION = "CLASSIFICATION"
    CHOOSING_TITLE = "CHOOSING_TITLE"

    # Preserved optional image/map types for compatibility if referenced
    MULTIPLE_CHOICE_SINGLE_IMAGE = "MULTIPLE_CHOICE_SINGLE_IMAGE"
    MAP_LABEL = "MAP_LABEL"

    @classmethod
    def from_raw(cls, val: Any) -> "QuestionPromptFamily":
        """Resolve QuestionPromptFamily from string or enum value flexibly."""
        if isinstance(val, QuestionPromptFamily):
            return val
        raw = str(getattr(val, "value", val)).strip()
        norm = raw.replace("_", "").replace("-", "").replace(" ", "").lower()

        # Direct name or value match
        for member in cls:
            if member.value == raw:
                return member
            if member.name.replace("_", "").lower() == norm or member.value.replace("_", "").lower() == norm:
                return member

        # Common aliases & historical forms
        alias_map = {
            "summarybox": cls.SUMMARY_COMPLETION_BOX,
            "summarycompletionbox": cls.SUMMARY_COMPLETION_BOX,
            "choosingatitle": cls.CHOOSING_TITLE,
            "choosingtitle": cls.CHOOSING_TITLE,
            "matchingheadings": cls.MATCHING_HEADING,
            "matchingheading": cls.MATCHING_HEADING,
            "matchingsentenceendings": cls.MATCHING_ENDINGS,
            "matchingendings": cls.MATCHING_ENDINGS,
            "flowchartcompletion": cls.FLOW_CHART,
            "flowchart": cls.FLOW_CHART,
            "diagramlabelcompletion": cls.DIAGRAM_LABEL,
            "diagramlabel": cls.DIAGRAM_LABEL,
        }
        if norm in alias_map:
            return alias_map[norm]

        return cls.TRUE_FALSE_NOT_GIVEN
