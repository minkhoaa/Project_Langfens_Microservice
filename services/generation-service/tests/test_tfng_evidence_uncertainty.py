"""Incomplete lexical checks must never clear a real adversarial blocker."""
import pytest

from app.contracts.solver import AdjudicationVerdict, StudentVisibleQuestion
from app.solvers.adjudication import adjudicate_item
from app.solvers.adversary import parse_and_validate_adversary_output
from app.solvers.comparison import compare_answers


def adversary(passage, statement, answer, quote):
    question = StudentVisibleQuestion(question_number=1,
        question_type="TRUE_FALSE_NOT_GIVEN", prompt=statement)
    raw = {"isAmbiguous": True, "identifiedAlternatives": [{
        "alternativeAnswer": answer, "plausibilityScore": .9,
        "isGroundedInPassage": True, "reasoning": "A competing reading needs review.",
        "citedSpans": [{"spanText": quote}],
    }]}
    output, errors, rejected = parse_and_validate_adversary_output(
        raw, passage, 1, student_question=question)
    assert not errors
    return question, output, rejected


@pytest.mark.parametrize("statement,positive,negative", [
    ("The furnace uses charcoal.", "The furnace uses charcoal.", "The furnace never uses charcoal."),
    ("Oxygen is required for smelting.", "Oxygen is required for smelting.", "Smelting can proceed without oxygen."),
])
def test_unrecognized_contradiction_is_not_clean_key_confirmation(statement, positive, negative):
    passage = positive + " " + negative
    question, output, rejected = adversary(passage, statement, "FALSE", negative)
    result = adjudicate_item(compare_answers("TRUE", "TRUE", question.question_type, 1),
                            output, passage, student_question=question)
    assert result.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE
    assert output.is_ambiguous
    assert rejected == []


def test_not_given_alternative_cannot_ignore_entailed_fact_elsewhere_in_passage():
    passage = "The furnace is in Nsukka. The furnace uses charcoal."
    _, output, rejected = adversary(passage, "The furnace uses charcoal.",
                                    "NOT_GIVEN", "The furnace is in Nsukka.")
    assert not output.is_ambiguous
    assert rejected


def test_not_given_alternative_with_nonliteral_conflict_remains_unresolved():
    passage = "The furnace is in Nsukka. The furnace dates to 700 BCE."
    _, output, rejected = adversary(passage, "The furnace dates to 600 BCE.",
                                    "NOT_GIVEN", "The furnace is in Nsukka.")
    # A lexical numeric mismatch is not authoritative proposition adjudication.
    # Preserve the review blocker rather than certifying a clean answer key.
    assert output.is_ambiguous
    assert rejected == []


def test_lexical_false_positive_cannot_discard_legitimate_not_given_challenge():
    passage = "The furnace uses wood."
    question, output, rejected = adversary(passage, "The furnace uses charcoal.",
                                         "NOT_GIVEN", passage)
    result = adjudicate_item(compare_answers("TRUE", "TRUE", question.question_type, 1),
                            output, passage, student_question=question)
    assert result.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE
    assert output.is_ambiguous
    assert rejected == []
