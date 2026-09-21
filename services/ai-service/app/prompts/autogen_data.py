"""Server-side mirror of questionSchemas.ts jsonShape + constraints.

This module is a Python copy of the TypeScript source. To prevent drift,
both must be updated together. Sprint 9 introduces codegen (Phase 9.4 of
PLAN.md).

Keep this in sync with langfens-fe-app/src/app/admin/_lib/questionSchemas.ts.
"""
from __future__ import annotations

JSON_SHAPES: dict[str, str] = {
    "MULTIPLE_CHOICE_SINGLE": """{
  "type": "MULTIPLE_CHOICE_SINGLE",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "What is the main idea of paragraph 2?",
  "explanationMd": "The passage states...",
  "options": [
    { "contentMd": "A. The moon's orbit", "isCorrect": false },
    { "contentMd": "B. The sun's energy", "isCorrect": true }
  ]
}""",
    "MULTIPLE_CHOICE_MULTIPLE": """{
  "type": "MULTIPLE_CHOICE_MULTIPLE",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "Which THREE of the following are mentioned?",
  "options": [
    { "contentMd": "A. Item one", "isCorrect": true },
    { "contentMd": "B. Item two", "isCorrect": false }
  ]
}""",
    "TRUE_FALSE_NOT_GIVEN": """{
  "type": "TRUE_FALSE_NOT_GIVEN",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "The author argues that...",
  "options": [
    { "contentMd": "True", "isCorrect": true },
    { "contentMd": "False", "isCorrect": false },
    { "contentMd": "Not Given", "isCorrect": false }
  ]
}""",
    "YES_NO_NOT_GIVEN": """{
  "type": "YES_NO_NOT_GIVEN",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "The author believes...",
  "options": [
    { "contentMd": "Yes", "isCorrect": true },
    { "contentMd": "No", "isCorrect": false },
    { "contentMd": "Not Given", "isCorrect": false }
  ]
}""",
    "MULTIPLE_CHOICE_SINGLE_IMAGE": """{
  "type": "MULTIPLE_CHOICE_SINGLE_IMAGE",
  "skill": "LISTENING",
  "difficulty": 3,
  "promptMd": "Which image matches the description?",
  "options": [
    { "contentMd": "A. Option 1", "imageUrl": "https://.../1.png", "altText": "...", "isCorrect": true }
  ]
}""",
    "SUMMARY_COMPLETION": """{
  "type": "SUMMARY_COMPLETION",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "Complete the summary:\n\nThe moon orbits the [1] every [2] days.",
  "blankAcceptTexts": {
    "1": ["earth", "Earth"],
    "2": ["27", "twenty-seven"]
  }
}""",
    "TABLE_COMPLETION": """{
  "type": "TABLE_COMPLETION",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "Complete the table:\n\n| Year | Sales |\n|------|-------|\n| 2020 | [1]   |",
  "blankAcceptTexts": { "1": ["100", "one hundred"] }
}""",
    "NOTE_COMPLETION": """{
  "type": "NOTE_COMPLETION",
  "skill": "LISTENING",
  "difficulty": 2,
  "promptMd": "Notes:\n- Type: [1]\n- Capacity: [2] people",
  "blankAcceptTexts": { "1": ["workshop"], "2": ["20"] }
}""",
    "FORM_COMPLETION": """{
  "type": "FORM_COMPLETION",
  "skill": "LISTENING",
  "difficulty": 2,
  "promptMd": "Application Form\n\nName: [1]\nDate: [2]\nRoom: [3]",
  "blankAcceptTexts": {
    "1": ["Rachel Torres", "Torres"],
    "2": ["15 September"],
    "3": ["single"]
  }
}""",
    "SENTENCE_COMPLETION": """{
  "type": "SENTENCE_COMPLETION",
  "skill": "READING",
  "promptMd": "1. Listening to music reduces [1] levels.\n2. The brain's [2] manages emotion.",
  "blankAcceptTexts": { "1": ["cortisol"], "2": ["nucleus accumbens"] }
}""",
    "SHORT_ANSWER": """{
  "type": "SHORT_ANSWER",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "What percentage of patients showed improvement?",
  "shortAnswerAcceptTexts": ["15", "fifteen", "15%"],
  "shortAnswerAcceptRegex": ["^\\d+(\\.\\d+)?\\s*%?$"]
}""",
    "DIAGRAM_LABEL": """{
  "type": "DIAGRAM_LABEL",
  "skill": "LISTENING",
  "difficulty": 3,
  "promptMd": "Label the diagram below with [1], [2]…",
  "imageUrl": "https://.../diagram.png",
  "blankAcceptTexts": { "1": ["chloroplast"], "2": ["nucleus"] }
}""",
    "MAP_LABEL": """{
  "type": "MAP_LABEL",
  "skill": "LISTENING",
  "difficulty": 3,
  "promptMd": "Label positions [1] through [2] on the map.",
  "imageUrl": "https://.../map.png",
  "blankAcceptTexts": { "1": ["library"], "2": ["park"] }
}""",
    "MATCHING_HEADING": """{
  "type": "MATCHING_HEADING",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "Reading passage...",
  "options": [
    { "contentMd": "i. The Early Years" },
    { "contentMd": "ii. The Modern Period" }
  ],
  "matchPairs": {
    "A": ["i", "Paragraph A excerpt"],
    "B": ["ii", "Paragraph B excerpt"]
  }
}""",
    "MATCHING_INFORMATION": """{
  "type": "MATCHING_INFORMATION",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "14. Which paragraph mentions X?\n15. Which paragraph describes Y?",
  "matchPairs": {
    "1": ["B", "Question 14 text"],
    "2": ["A", "Question 15 text"]
  }
}""",
    "MATCHING_FEATURES": """{
  "type": "MATCHING_FEATURES",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "1. The speaker\n2. The researcher",
  "options": [
    { "contentMd": "A. Used the method" },
    { "contentMd": "B. Criticised the theory" }
  ],
  "matchPairs": {
    "1": ["A", "The speaker"],
    "2": ["B", "The researcher"]
  }
}""",
    "MATCHING_ENDINGS": """{
  "type": "MATCHING_ENDINGS",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "21. Despite the rain,\n22. As the temperature rose,",
  "options": [
    { "contentMd": "A. the team continued." },
    { "contentMd": "B. the ice began to melt." }
  ],
  "matchPairs": {
    "1": ["A", "Despite the rain,"],
    "2": ["B", "As the temperature rose,"]
  }
}""",
    "CLASSIFICATION": """{
  "type": "CLASSIFICATION",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "Classify as:\nA. dopamine research\nB. cultural factors\nC. musical training\n\n1. Musicians have more gray matter...\n2. What one finds beautiful...\n3. The brain shows...",
  "options": [
    { "contentMd": "A. dopamine research" },
    { "contentMd": "B. cultural factors" },
    { "contentMd": "C. musical training" }
  ],
  "matchPairs": {
    "1": ["C"],
    "2": ["B"],
    "3": ["A"]
  }
}""",
    "FLOW_CHART": """{
  "type": "FLOW_CHART",
  "skill": "LISTENING",
  "difficulty": 3,
  "promptMd": "Complete the flow chart below.",
  "orderCorrects": ["collect-samples", "analyze-data", "publish-results"]
}""",
}

CONSTRAINTS: dict[str, list[str]] = {
    "MULTIPLE_CHOICE_SINGLE": [
        "options[] must have exactly 1 with isCorrect=true (single answer)",
        "options[].contentMd should follow 'A. text', 'B. text' convention"
    ],
    "MULTIPLE_CHOICE_MULTIPLE": [
        "options[] must have 2+ with isCorrect=true",
        "options[].contentMd should follow 'A. text'...'H. text' convention"
    ],
    "TRUE_FALSE_NOT_GIVEN": [
        "options[] must contain exactly 3 items: True, False, Not Given",
        "exactly 1 must be isCorrect=true"
    ],
    "YES_NO_NOT_GIVEN": [
        "options[] must contain exactly 3 items: Yes, No, Not Given",
        "exactly 1 must be isCorrect=true"
    ],
    "MULTIPLE_CHOICE_SINGLE_IMAGE": [
        "options[].imageUrl is recommended for image-based MCQ",
        "options[].altText is required when imageUrl is set (a11y)"
    ],
    "SUMMARY_COMPLETION": [
        "promptMd should contain [N] placeholders OR numbered list",
        "blankAcceptTexts keys must match placeholder indices (e.g. '1', '2'…)",
        "each blank value can be string[] (multiple acceptable spellings)"
    ],
    "TABLE_COMPLETION": [
        "promptMd typically contains a markdown table with [N] cells",
        "blankAcceptTexts keys match placeholder indices"
    ],
    "NOTE_COMPLETION": [
        "Same as SummaryCompletion."
    ],
    "FORM_COMPLETION": [
        "Same as SummaryCompletion."
    ],
    "SENTENCE_COMPLETION": [
        "Same as SummaryCompletion."
    ],
    "SHORT_ANSWER": [
        "shortAnswerAcceptTexts is compared case-insensitively",
        "shortAnswerAcceptRegex uses .NET regex syntax",
        "at least one of texts/regex must be non-empty"
    ],
    "DIAGRAM_LABEL": [
        "imageUrl is required for DIAGRAM_LABEL",
        "promptMd should describe what to label (or be empty)",
        "blankAcceptTexts keys match placeholder indices"
    ],
    "MAP_LABEL": [
        "imageUrl is required for MAP_LABEL",
        "blankAcceptTexts keys match placeholder indices"
    ],
    "MATCHING_HEADING": [
        "matchPairs keys = paragraph letters (A, B, C…)",
        "matchPairs values[0] = heading Roman numeral",
        "options[] = heading pool (i, ii, iii…)"
    ],
    "MATCHING_INFORMATION": [
        "matchPairs keys = 1-based question index strings ('1', '2', …)",
        "matchPairs values[0] = paragraph letter (A-H)"
    ],
    "MATCHING_FEATURES": [
        "options[] = feature list (A-H)",
        "matchPairs keys = 1-based item index ('1', '2', …)",
        "features can be reused across items"
    ],
    "MATCHING_ENDINGS": [
        "options[] = endings pool (A-H)",
        "matchPairs keys = 1-based beginning index ('1', '2', …)",
        "endings can only be used once (one-to-one)"
    ],
    "CLASSIFICATION": [
        "promptMd MUST contain 'A. label', 'B. label' for categories and '1. text', '2. text' for statements",
        "matchPairs keys = 1-based statement index ('1', '2', …)",
        "matchPairs values[0] = category letter (A, B, C…)"
    ],
    "FLOW_CHART": [
        "orderCorrects must be slug-like (lowercase, hyphenated)",
        "must have at least 2 unique steps"
    ],
}


def get_json_shape(qtype: str) -> str:
    """Return the canonical JSON shape for a question type.

    Args:
        qtype: QuestionType enum value.

    Returns:
        JSON shape string.

    Raises:
        KeyError: if qtype is not in JSON_SHAPES.
    """
    if qtype not in JSON_SHAPES:
        raise KeyError(f"No JSON_SHAPES entry for type {qtype!r}")
    return JSON_SHAPES[qtype]


def get_constraints(qtype: str) -> list[str]:
    """Return the constraint strings for a question type.

    Args:
        qtype: QuestionType enum value.

    Returns:
        List of constraint strings (empty list if no constraints defined).
    """
    return CONSTRAINTS.get(qtype, [])
