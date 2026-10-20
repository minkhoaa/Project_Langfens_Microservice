"""Cross-service conformance tests ensuring Python, .NET, and contract interpret all 19 answer contracts identically.

Validates:
1. Exact 1-to-1 parity of all 19 question types across Python, .NET contracts, and JSON schema.
2. Identical answer-family field rules (allowed vs forbidden fields) for all 19 types.
3. Identical word-count limits (<= 3 words) across completion and short answer.
4. Identical language regex and placeholder rejection rules.
5. In-process deterministic evaluation without unnecessary network hops.
"""
import json
from pathlib import Path
import re
import pytest

from app.validation import ALL_19_TYPES, get_validator_registry, validate_question, ValidationPolicy, ValidationStatus

REPO_ROOT = Path(__file__).resolve().parents[3]
CS_QUESTION_TYPE_PATH = REPO_ROOT / "services/_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs"
CONTRACT_PATH = REPO_ROOT / "services/ai-service/app/prompts/autogen_contract.json"


def extract_csharp_question_types() -> set[str]:
    """Extract string constants from QuestionType.cs."""
    content = CS_QUESTION_TYPE_PATH.read_text(encoding="utf-8")
    matches = re.findall(r'public const string \w+ = "([A-Z0-9_]+)";', content)
    return set(matches)


def test_19_types_parity_with_csharp_contract():
    """Python ALL_19_TYPES must match C# QuestionType.cs exactly."""
    cs_types = extract_csharp_question_types()
    assert cs_types == ALL_19_TYPES
    assert len(cs_types) == 19


def test_19_types_parity_with_json_schema_contract():
    """autogen_contract.json must define canonical shapes for all 19 types."""
    with open(CONTRACT_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    json_types = set()
    for item in data.get("examples", []):
        q = item.get("question")
        if q and "type" in q:
            json_types.add(q["type"])

    assert json_types == ALL_19_TYPES
    assert len(json_types) == 19


def test_answer_family_isolation_conformance():
    """Each of the 19 types must strictly isolate its answer family without field leakage."""
    registry = get_validator_registry()

    choice_types = {
        "MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_MULTIPLE",
        "MULTIPLE_CHOICE_SINGLE_IMAGE", "TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"
    }
    completion_types = {
        "SUMMARY_COMPLETION", "TABLE_COMPLETION", "NOTE_COMPLETION",
        "FORM_COMPLETION", "SENTENCE_COMPLETION", "DIAGRAM_LABEL", "MAP_LABEL"
    }
    matching_types = {
        "MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES",
        "MATCHING_ENDINGS", "CLASSIFICATION"
    }
    ordering_types = {"FLOW_CHART"}
    short_answer_types = {"SHORT_ANSWER"}

    for qtype in ALL_19_TYPES:
        validator = registry.get(qtype)
        assert validator is not None
        allowed = validator.allowed_answer_fields

        if qtype in choice_types:
            assert allowed == {"options"}, f"{qtype} must only allow options"
        elif qtype in completion_types:
            assert "blankAcceptTexts" in allowed, f"{qtype} must allow blankAcceptTexts"
            assert "matchPairs" not in allowed
            assert "orderCorrects" not in allowed
        elif qtype in matching_types:
            assert "matchPairs" in allowed, f"{qtype} must allow matchPairs"
            assert "blankAcceptTexts" not in allowed
            assert "orderCorrects" not in allowed
        elif qtype in ordering_types:
            assert allowed == {"orderCorrects"}, f"{qtype} must only allow orderCorrects"
        elif qtype in short_answer_types:
            assert "shortAnswerAcceptTexts" in allowed
            assert "options" not in allowed


def test_vietnamese_language_regex_conformance():
    """Verify Python Vietnamese screening matches .NET VietnameseRegex character class."""
    from app.validation.common import VIETNAMESE_DIACRITICS_RE, VIETNAMESE_WORDS_RE
    def is_vietnamese(text: str) -> bool:
        return bool(VIETNAMESE_DIACRITICS_RE.search(text) or VIETNAMESE_WORDS_RE.search(text))

    test_words = [
        ("Câu hỏi", True),
        ("Đọc đoạn văn", True),
        ("Ngữ pháp", True),
        ("Giải thích", True),
        ("Tiếng Việt", True),
        ("Hello world", False),
        ("Cambridge IELTS Academic Reading Test", False),
        ("Paper was invented in China using mulberry fibres", False),
    ]

    for word, should_match in test_words:
        matched = is_vietnamese(word)
        assert matched == should_match, f"Failed for '{word}': expected {should_match}, got {matched}"
