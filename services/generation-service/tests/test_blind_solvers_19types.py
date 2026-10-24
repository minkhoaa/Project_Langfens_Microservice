"""Test suite for Zero-Leakage Blind Solvers, Adversary Ambiguity & Adjudication for all 19 IELTS Reading Types.
"""

from __future__ import annotations

import pytest
from typing import Any, Dict, List
from app.contracts.evaluation import EvaluationStatus
from app.contracts.question_type import QuestionPromptFamily
from app.contracts.solver import (
    AdjudicationResult,
    AdjudicationVerdict,
    AdversaryAlternative,
    AdversaryAmbiguityType,
    AdversaryOutput,
    ComparisonResult,
    DisagreementSeverity,
    SolverOutput,
    SolverSpan,
    StudentVisibleOption,
    StudentVisibleQuestion,
)
from app.evaluators.solver import BlindSolverEvaluator
from app.solvers.serializer import (
    project_to_student_visible,
    build_blind_solver_input,
    build_secure_envelope,
)
from app.solvers.comparison import (
    compare_answers,
    normalize_roman_numeral,
    normalize_letter_code,
    normalize_multichoice_multiple,
    normalize_box_completion,
)
from app.solvers.adjudication import adjudicate_item


ALL_19_FAMILIES = [
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN,
    QuestionPromptFamily.YES_NO_NOT_GIVEN,
    QuestionPromptFamily.SENTENCE_COMPLETION,
    QuestionPromptFamily.SUMMARY_COMPLETION,
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX,
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE,
    QuestionPromptFamily.MATCHING_HEADING,
    QuestionPromptFamily.MATCHING_INFORMATION,
    QuestionPromptFamily.MATCHING_FEATURES,
    QuestionPromptFamily.MATCHING_ENDINGS,
    QuestionPromptFamily.TABLE_COMPLETION,
    QuestionPromptFamily.FLOW_CHART,
    QuestionPromptFamily.DIAGRAM_LABEL,
    QuestionPromptFamily.SHORT_ANSWER,
    QuestionPromptFamily.NOTE_COMPLETION,
    QuestionPromptFamily.FORM_COMPLETION,
    QuestionPromptFamily.CLASSIFICATION,
    QuestionPromptFamily.CHOOSING_TITLE,
]


def _build_dummy_candidate(family: QuestionPromptFamily, q_num: int = 1) -> Dict[str, Any]:
    """Builds a rich mock candidate containing answer keys, evidence, and options."""
    base: Dict[str, Any] = {
        "questionNumber": q_num,
        "questionType": family.value,
        "prompt": f"Test prompt for question {q_num} in family {family.value}",
        "instructions": "Answer strictly using the text.",
        "sharedContext": "Section context header",
        # Sensitive data that MUST NEVER leak to student visible question or solver
        "answer": "SECRET_KEY_123",
        "correctOption": "B",
        "evidenceQuote": "This is a secret quote from paragraph 2 proving the answer.",
        "evidenceSpan": {"startChar": 10, "endChar": 50},
        "explanation": "Because the text mentions it directly.",
        "absenceAssessment": "Absence justified because fact is omitted.",
        "canary": "CANARY_TOKEN_DO_NOT_LEAK",
        "score": 1.0,
        "rejected": False,
        "rejectionReasons": [],
    }

    if family in (
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
        QuestionPromptFamily.CHOOSING_TITLE,
    ):
        base["options"] = [
            {"key": "A", "text": "First option text", "isCorrect": False},
            {"key": "B", "text": "Second option text", "isCorrect": True},
            {"key": "C", "text": "Third option text", "isCorrect": False},
            {"key": "D", "text": "Fourth option text", "isCorrect": False},
        ]
    elif family == QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE:
        base["options"] = [
            {"key": "A", "text": "Option A", "isCorrect": True},
            {"key": "B", "text": "Option B", "isCorrect": False},
            {"key": "C", "text": "Option C", "isCorrect": True},
            {"key": "D", "text": "Option D", "isCorrect": False},
            {"key": "E", "text": "Option E", "isCorrect": False},
        ]
    elif family == QuestionPromptFamily.MATCHING_HEADING:
        base["paragraphRef"] = "Paragraph A"
        base["options"] = [
            {"key": "i", "text": "Heading Roman One", "isCorrect": False},
            {"key": "ii", "text": "Heading Roman Two", "isCorrect": True},
            {"key": "iii", "text": "Heading Roman Three", "isCorrect": False},
            {"key": "iv", "text": "Heading Roman Four", "isCorrect": False},
        ]
    elif family in (
        QuestionPromptFamily.MATCHING_FEATURES,
        QuestionPromptFamily.MATCHING_ENDINGS,
        QuestionPromptFamily.CLASSIFICATION,
    ):
        base["options"] = [
            {"key": "A", "text": "Feature or Ending A"},
            {"key": "B", "text": "Feature or Ending B"},
            {"key": "C", "text": "Feature or Ending C"},
        ]
    elif family == QuestionPromptFamily.SUMMARY_COMPLETION_BOX:
        base["options"] = [
            {"key": "A", "text": "agricultural runoff"},
            {"key": "B", "text": "industrial emissions"},
            {"key": "C", "text": "urban sprawl"},
            {"key": "D", "text": "coastal erosion"},
        ]

    return base


# =====================================================================
# 1. Zero-Leakage Serialization Tests Across All 19 Types
# =====================================================================

def test_all_19_families_are_covered():
    assert len(ALL_19_FAMILIES) == 19


@pytest.mark.parametrize("family", ALL_19_FAMILIES)
def test_zero_leakage_serialization_all_19_types(family: QuestionPromptFamily):
    candidate = _build_dummy_candidate(family)
    sv = project_to_student_visible(candidate)

    assert isinstance(sv, StudentVisibleQuestion)
    assert sv.question_number == 1
    assert sv.prompt == f"Test prompt for question 1 in family {family.value}"

    # Dump to dict and string for inspection
    sv_dump = sv.model_dump(by_alias=True)
    sv_str = str(sv_dump).lower()

    # Zero leakage checks
    forbidden = [
        "secret_key_123",
        "secret quote",
        "because the text mentions",
        "absence justified",
        "canary_token",
        "iscorrect",
        "correctoption",
        "evidencequote",
        "evidencespan",
    ]
    for secret in forbidden:
        assert secret not in sv_str, f"Leak of '{secret}' detected in student-visible question for family {family}!"

    # Envelope verification
    passage = "A" * 100
    envelope = build_secure_envelope(passage, sv)
    for secret in forbidden:
        assert secret not in envelope.lower(), f"Leak of '{secret}' detected in secure envelope for family {family}!"


def test_project_to_student_visible_alternative_options_keys():
    for field_name, fam in [
        ("headings", QuestionPromptFamily.MATCHING_HEADING),
        ("features", QuestionPromptFamily.MATCHING_FEATURES),
        ("endings", QuestionPromptFamily.MATCHING_ENDINGS),
        ("categories", QuestionPromptFamily.CLASSIFICATION),
    ]:
        cand = {
            "questionNumber": 1,
            "questionType": fam.value,
            "prompt": "Test matching prompt",
            "instructions": "Match the items.",
            field_name: [
                {"key": "A", "text": "Option 1"},
                {"key": "B", "text": "Option 2"},
            ],
        }
        sv = project_to_student_visible(cand)
        assert sv.options is not None
        assert len(sv.options) == 2
        assert sv.options[0].key == "A"
        assert sv.options[0].text == "Option 1"
# =====================================================================
# 2. Answer Comparison Normalizers Across All 19 Types
# =====================================================================

def test_matching_heading_roman_numeral_normalizer():
    # Test normalization of Roman numerals
    assert normalize_roman_numeral("iii") == "III"
    assert normalize_roman_numeral("  iv. ") == "IV"
    assert normalize_roman_numeral("Section ix") == "IX"
    assert normalize_roman_numeral("viii") == "VIII"
    assert normalize_roman_numeral("vii") == "VII"
    assert normalize_roman_numeral("VI") == "VI"
    assert normalize_roman_numeral("x") == "X"

    # Comparison should match case-insensitively and handle dots/whitespace
    res = compare_answers(
        expected_answer="iv",
        solver_answer="IV.",
        question_type=QuestionPromptFamily.MATCHING_HEADING.value,
        question_number=1,
    )
    assert res.is_match is True
    assert res.normalized_expected == "IV"
    assert res.normalized_solver == "IV"

    # Mismatch check
    res_mismatch = compare_answers(
        expected_answer="iv",
        solver_answer="vi",
        question_type=QuestionPromptFamily.MATCHING_HEADING.value,
        question_number=1,
    )
    assert res_mismatch.is_match is False


def test_matching_features_and_info_letter_code_normalizer():
    assert normalize_letter_code("B") == "B"
    assert normalize_letter_code("option c") == "C"
    assert normalize_letter_code("  (D)  ") == "D"

    for fam in [
        QuestionPromptFamily.MATCHING_INFORMATION,
        QuestionPromptFamily.MATCHING_FEATURES,
        QuestionPromptFamily.MATCHING_ENDINGS,
        QuestionPromptFamily.CLASSIFICATION,
    ]:
        res = compare_answers(
            expected_answer="B",
            solver_answer="Option B.",
            question_type=fam.value,
            question_number=2,
        )
        assert res.is_match is True
        assert res.normalized_expected == "B"
        assert res.normalized_solver == "B"


def test_multiple_choice_multiple_order_independent_normalizer():
    # Test set normalization
    assert normalize_multichoice_multiple("A, C") == "A, C"
    assert normalize_multichoice_multiple("C, A") == "A, C"
    assert normalize_multichoice_multiple("B and D") == "B, D"
    assert normalize_multichoice_multiple("E, B, A") == "A, B, E"

    # Comparison order independence
    res = compare_answers(
        expected_answer="B, D",
        solver_answer="D, B",
        question_type=QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE.value,
        question_number=3,
    )
    assert res.is_match is True
    assert res.normalized_expected == "B, D"
    assert res.normalized_solver == "B, D"

    # Partial match should not be a full match
    res_partial = compare_answers(
        expected_answer="B, D",
        solver_answer="B, C",
        question_type=QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE.value,
        question_number=3,
    )
    assert res_partial.is_match is False


def test_summary_completion_box_normalizer():
    options = [
        StudentVisibleOption(key="A", text="agricultural runoff"),
        StudentVisibleOption(key="B", text="industrial emissions"),
        StudentVisibleOption(key="C", text="urban sprawl"),
    ]

    # Solver gives the letter "B" directly
    res1 = compare_answers(
        expected_answer="B",
        solver_answer="B",
        question_type=QuestionPromptFamily.SUMMARY_COMPLETION_BOX.value,
        question_number=4,
        options=options,
    )
    assert res1.is_match is True

    # Solver gives the text of option B
    res2 = compare_answers(
        expected_answer="B",
        solver_answer="Industrial emissions.",
        question_type=QuestionPromptFamily.SUMMARY_COMPLETION_BOX.value,
        question_number=4,
        options=options,
    )
    assert res2.is_match is True
    assert res2.normalized_solver == "B"

    # Expected is text, solver is letter
    res3 = compare_answers(
        expected_answer="industrial emissions",
        solver_answer="B",
        question_type=QuestionPromptFamily.SUMMARY_COMPLETION_BOX.value,
        question_number=4,
        options=options,
    )
    assert res3.is_match is True


@pytest.mark.parametrize("family", [
    QuestionPromptFamily.SENTENCE_COMPLETION,
    QuestionPromptFamily.SUMMARY_COMPLETION,
    QuestionPromptFamily.TABLE_COMPLETION,
    QuestionPromptFamily.FLOW_CHART,
    QuestionPromptFamily.DIAGRAM_LABEL,
    QuestionPromptFamily.SHORT_ANSWER,
    QuestionPromptFamily.NOTE_COMPLETION,
    QuestionPromptFamily.FORM_COMPLETION,
])
def test_completion_types_canonical_comparison(family: QuestionPromptFamily):
    res = compare_answers(
        expected_answer="water vapor",
        solver_answer="  Water Vapor.  ",
        question_type=family.value,
        question_number=5,
    )
    assert res.is_match is True
    assert res.normalized_expected == "water vapor"
    assert res.normalized_solver == "water vapor"


# =====================================================================
# 3. Adversarial Ambiguity & Adjudication Across Types
# =====================================================================

def test_adjudicate_item_detects_ambiguity_in_matching_headings():
    # Expected key is IV, solver finds IV, but adversary finds valid grounded alt II
    comparison = ComparisonResult(
        question_number=1,
        is_match=True,
        expected_answer="IV",
        solver_answer="IV",
        normalized_expected="IV",
        normalized_solver="IV",
        question_type=QuestionPromptFamily.MATCHING_HEADING.value,
        comparison_details={},
    )
    adversary = AdversaryOutput(
        question_number=1,
        is_ambiguous=True,
        adversary_summary="Paragraph also supports Heading II",
        identified_alternatives=[
            AdversaryAlternative(
                alternative_answer="II",
                ambiguity_type=AdversaryAmbiguityType.MULTIPLE_VALID_OPTIONS,
                plausibility_score=0.95,
                reasoning="Paragraph also strongly aligns with Heading II",
                is_grounded_in_passage=True,
                cited_spans=[
                    SolverSpan(span_text="Supporting span text for heading II", start_char=10, end_char=45)
                ],
            )
        ],
    )

    adj = adjudicate_item(comparison, adversary_output=adversary)
    assert adj.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE
    assert adj.severity == DisagreementSeverity.HIGH
    assert adj.adversary_ambiguity_found is True
    assert adj.solver_match is True


def test_adjudicate_item_detects_ambiguity_in_mcq_multiple():
    # Expected key is "A, C", but adversary finds option "D" is equally supported
    comparison = ComparisonResult(
        question_number=2,
        is_match=True,
        expected_answer="A, C",
        solver_answer="A, C",
        normalized_expected="A, C",
        normalized_solver="A, C",
        question_type=QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE.value,
        comparison_details={},
    )
    adversary = AdversaryOutput(
        question_number=2,
        is_ambiguous=True,
        adversary_summary="Option D also directly supported by paragraph 3",
        identified_alternatives=[
            AdversaryAlternative(
                alternative_answer="A, D",
                ambiguity_type=AdversaryAmbiguityType.MULTIPLE_VALID_OPTIONS,
                plausibility_score=0.96,
                reasoning="Option D is directly supported by paragraph 3",
                is_grounded_in_passage=True,
                cited_spans=[
                    SolverSpan(span_text="Option D text span", start_char=50, end_char=80)
                ],
            )
        ],
    )

    adj = adjudicate_item(comparison, adversary_output=adversary)
    assert adj.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE
    assert adj.severity == DisagreementSeverity.HIGH
    assert adj.adversary_ambiguity_found is True


def test_adjudicate_item_ungrounded_alternative_does_not_block():
    comparison = ComparisonResult(
        question_number=3,
        is_match=True,
        expected_answer="water vapor",
        solver_answer="water vapor",
        normalized_expected="water vapor",
        normalized_solver="water vapor",
        question_type=QuestionPromptFamily.SENTENCE_COMPLETION.value,
        comparison_details={},
    )
    adversary = AdversaryOutput(
        question_number=3,
        is_ambiguous=True,
        adversary_summary="Outside knowledge says nitrogen",
        identified_alternatives=[
            AdversaryAlternative(
                alternative_answer="nitrogen",
                ambiguity_type=AdversaryAmbiguityType.MULTIPLE_VALID_OPTIONS,
                plausibility_score=0.8,
                reasoning="General external chemistry fact",
                is_grounded_in_passage=False,  # NOT grounded in passage!
                cited_spans=[],
            )
        ],
    )

    adj = adjudicate_item(comparison, adversary_output=adversary)
    assert adj.verdict == AdjudicationVerdict.KEY_CONFIRMED
    assert adj.severity == DisagreementSeverity.NONE
    assert adj.solver_match is True


# =====================================================================
# 4. BlindSolverEvaluator Dispatch Across All 19 Types
# =====================================================================

@pytest.mark.asyncio
@pytest.mark.parametrize("family", ALL_19_FAMILIES)
async def test_blind_solver_evaluator_handles_all_19_families(family: QuestionPromptFamily):
    evaluator = BlindSolverEvaluator(allow_simulation=True)
    candidate = _build_dummy_candidate(family)
    candidate["passage"] = (
        "The atmospheric concentration of water vapor fluctuates significantly across different biomes. "
        "Paragraph A discusses tropical climates with heavy humidity and constant evaporation. "
        "Paragraph B focuses on arid deserts where precipitation is negligible and temperatures vary drastically. "
        "Detailed records from meteorological stations confirm that these patterns remain consistent."
    )
    if family == QuestionPromptFamily.MATCHING_HEADING:
        candidate["answer"] = "i"
    elif family in (
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE,
        QuestionPromptFamily.CHOOSING_TITLE,
        QuestionPromptFamily.SUMMARY_COMPLETION_BOX,
        QuestionPromptFamily.MATCHING_FEATURES,
        QuestionPromptFamily.MATCHING_ENDINGS,
        QuestionPromptFamily.CLASSIFICATION,
    ):
        candidate["answer"] = "A"
    elif family == QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE:
        candidate["answer"] = "A, C"
    elif family == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN:
        candidate["answer"] = "TRUE"
    elif family == QuestionPromptFamily.YES_NO_NOT_GIVEN:
        candidate["answer"] = "YES"
    else:
        candidate["answer"] = "The"

    from app.contracts.artifact import ArtifactEnvelope, ArtifactType
    art = ArtifactEnvelope.create(
        artifact_id="art_test_q1",
        artifact_type=ArtifactType.QUESTION,
        run_id="run_test",
        payload=candidate,
        producer_version="2.0.0",
        version=1,
    )

    result = await evaluator._evaluate_impl(context=None, artifact=art, intent_id="intent_1")
    assert result is not None
    assert result.evaluator_id == "eval_blind_solver_adversary"
    assert result.status in (EvaluationStatus.PASS, EvaluationStatus.FAIL)
