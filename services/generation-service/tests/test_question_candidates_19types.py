"""Comprehensive tests for 19 IELTS Question Families Prompt Generation & Candidate Validation."""

import pytest
from app.contracts.question_type import QuestionPromptFamily
from app.contracts.questions import (
    CandidateOption,
    TrueFalseCandidate,
    SentenceCompletionCandidate,
    MultipleChoiceSingleCandidate,
    MultipleChoiceMultipleCandidate,
    MatchingHeadingsCandidate,
    FlowChartCandidate,
    DiagramLabelCandidate,
    TableCompletionCandidate,
    ShortAnswerCandidate,
    SummaryBoxCandidate,
)
from app.generators.question.prompts import render_question_prompt
from app.context import validate_candidate_slot


SAMPLE_PASSAGE = (
    "The history of subterranean urban infrastructure began in the mid-nineteenth century in London. "
    "Charles Pearson proposed constructing a subterranean railway to ease street congestion. "
    "In 1863, the Metropolitan Railway opened using steam locomotives. "
    "Later technological advancements introduced electric traction and shield tunnelling methods."
)


def test_render_question_prompt_all_19_types():
    """Verify render_question_prompt generates robust prompts for all 19 IELTS question families."""
    for family in QuestionPromptFamily:
        # MAP_LABEL and MULTIPLE_CHOICE_SINGLE_IMAGE are optional compatibility aliases
        if family.name in ("MAP_LABEL", "MULTIPLE_CHOICE_SINGLE_IMAGE"):
            continue

        prompt_data = render_question_prompt(
            family=family,
            slot_number=1,
            passage_text=SAMPLE_PASSAGE,
            total_questions=13,
        )

        assert isinstance(prompt_data, str)
        assert len(prompt_data) > 80
        assert "JSON" in prompt_data
        assert str(family.value) in prompt_data or family.name in prompt_data

        # Visual layout requirements for FLOW_CHART and DIAGRAM_LABEL
        if family == QuestionPromptFamily.FLOW_CHART:
            assert "step" in prompt_data.lower()
            assert "flow" in prompt_data.lower()
        elif family == QuestionPromptFamily.DIAGRAM_LABEL:
            assert "label" in prompt_data.lower() or "callout" in prompt_data.lower()
            assert "part" in prompt_data.lower() or "diagram" in prompt_data.lower()


def test_validate_candidate_slot_true_false_and_yes_no():
    """Verify TFNG and YNNG validation, including NOT GIVEN absence assessment."""
    # Valid TRUE
    tf_valid = {
        "prompt": "The Metropolitan Railway began operations in the 19th century.",
        "answer": "TRUE",
        "evidence_quote": "In 1863, the Metropolitan Railway opened",
    }
    issues = validate_candidate_slot(tf_valid, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)
    assert len(issues) == 0

    # Invalid answer string
    tf_invalid = {
        "prompt": "The Metropolitan Railway began operations in the 19th century.",
        "answer": "CORRECT",
    }
    issues = validate_candidate_slot(tf_invalid, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)
    assert any("must be TRUE, FALSE, or NOT GIVEN" in str(i) for i in issues)

    # Valid NOT GIVEN with absence assessment
    tf_ng_valid = {
        "prompt": "Charles Pearson was knighted for his engineering achievements.",
        "answer": "NOT GIVEN",
        "absence_assessment": {
            "is_absent": True,
            "searched_concepts": ["knighted", "honours"],
            "closest_sentence": "Charles Pearson proposed constructing a subterranean railway.",
            "divergence_reason": "No mention of knighthood or honours.",
        },
    }
    issues = validate_candidate_slot(tf_ng_valid, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)
    assert len(issues) == 0

    # NOT GIVEN missing absence assessment
    tf_ng_no_absence = {
        "prompt": "Charles Pearson was knighted for his engineering achievements.",
        "answer": "NOT GIVEN",
    }
    issues = validate_candidate_slot(tf_ng_no_absence, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)
    assert any("absence" in str(i).lower() for i in issues)


def test_validate_candidate_slot_completions():
    """Verify sentence, summary, note, and form completion validation (<=3 words, blank marker)."""
    # Valid Sentence Completion
    sc_valid = {
        "prompt": "The first underground railway operated using ______ locomotives.",
        "answer": "steam",
    }
    issues = validate_candidate_slot(sc_valid, QuestionPromptFamily.SENTENCE_COMPLETION)
    assert len(issues) == 0

    # Missing blank marker
    sc_no_blank = {
        "prompt": "The first underground railway operated using steam locomotives.",
        "answer": "steam",
    }
    issues = validate_candidate_slot(sc_no_blank, QuestionPromptFamily.SENTENCE_COMPLETION)
    assert any("blank marker" in str(i).lower() for i in issues)

    # Answer exceeds 3 words
    sc_too_long = {
        "prompt": "The first underground railway operated using ______ in London.",
        "answer": "very powerful old steam locomotives",
    }
    issues = validate_candidate_slot(sc_too_long, QuestionPromptFamily.SENTENCE_COMPLETION)
    assert any("3 words" in str(i) for i in issues)


def test_validate_candidate_slot_mcq_single_and_multiple():
    """Verify Multiple Choice options count, distinctness, and key validation."""
    # Valid MCQ Single
    mcq_valid = {
        "prompt": "Who proposed the construction of London's subterranean railway?",
        "answer": "B",
        "options": [
            {"key": "A", "text": "Isambard Kingdom Brunel"},
            {"key": "B", "text": "Charles Pearson"},
            {"key": "C", "text": "George Stephenson"},
            {"key": "D", "text": "Robert Stephenson"},
        ],
    }
    issues = validate_candidate_slot(mcq_valid, QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE)
    assert len(issues) == 0

    # MCQ with duplicate options
    mcq_dup = {
        "prompt": "Who proposed the construction of London's subterranean railway?",
        "answer": "A",
        "options": [
            {"key": "A", "text": "Charles Pearson"},
            {"key": "B", "text": "Charles Pearson"},
            {"key": "C", "text": "George Stephenson"},
            {"key": "D", "text": "Robert Stephenson"},
        ],
    }
    issues = validate_candidate_slot(mcq_dup, QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE)
    assert any("duplicate" in str(i).lower() for i in issues)

    # MCQ with fewer than 4 options
    mcq_few = {
        "prompt": "Who proposed the construction of London's subterranean railway?",
        "answer": "A",
        "options": [
            {"key": "A", "text": "Charles Pearson"},
            {"key": "B", "text": "George Stephenson"},
        ],
    }
    issues = validate_candidate_slot(mcq_few, QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE)
    assert any("4 options" in str(i) for i in issues)


def test_validate_candidate_slot_visual_and_complex_types():
    """Verify Flow Chart, Diagram Label, Table Completion, and Headings."""
    # Valid Flow Chart
    flow_valid = {
        "prompt": "Complete the flow chart below. Choose NO MORE THAN TWO WORDS from the passage.",
        "answer": "steam locomotives",
        "flow_steps": [
            "Street congestion increases in London",
            "Charles Pearson proposes subterranean railway",
            "Opening of Metropolitan Railway using ______",
            "Later introduction of electric traction",
        ],
    }
    issues = validate_candidate_slot(flow_valid, QuestionPromptFamily.FLOW_CHART)
    assert len(issues) == 0

    # Flow chart without steps
    flow_invalid = {
        "prompt": "Complete the flow chart below.",
        "answer": "steam locomotives",
        "flow_steps": [],
    }
    issues = validate_candidate_slot(flow_invalid, QuestionPromptFamily.FLOW_CHART)
    assert any("flow_steps" in str(i).lower() or "step" in str(i).lower() for i in issues)

    # Diagram Label missing callout or label
    diag_invalid = {
        "prompt": "Label the diagram below.",
        "answer": "shield",
        "callout_label": "",
    }
    issues = validate_candidate_slot(diag_invalid, QuestionPromptFamily.DIAGRAM_LABEL)
    assert len(issues) > 0


def test_validate_candidate_slot_with_pydantic_instances():
    """Verify validate_candidate_slot seamlessly works with Pydantic BaseCandidate instances."""
    candidate = SentenceCompletionCandidate(
        prompt="The railway initially utilized ______ locomotives.",
        answer="steam",
        slotId="slot_1",
        questionNumber=1,
    )
    issues = validate_candidate_slot(candidate, QuestionPromptFamily.SENTENCE_COMPLETION)
    assert len(issues) == 0


def test_validate_candidate_slot_comprehensive_19_families():
    """Verify validation logic for every single one of the 19 IELTS families."""
    # 1. TRUE_FALSE_NOT_GIVEN
    assert len(validate_candidate_slot({"prompt": "Statement text.", "answer": "TRUE"}, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)) == 0
    # 2. YES_NO_NOT_GIVEN
    assert len(validate_candidate_slot({"prompt": "Claim text.", "answer": "NO"}, QuestionPromptFamily.YES_NO_NOT_GIVEN)) == 0
    # 3. SENTENCE_COMPLETION
    assert len(validate_candidate_slot({"prompt": "Sentence with ______ blank.", "answer": "target word"}, QuestionPromptFamily.SENTENCE_COMPLETION)) == 0
    # 4. SUMMARY_COMPLETION
    assert len(validate_candidate_slot({"prompt": "Summary context with [1] blank.", "answer": "target word"}, QuestionPromptFamily.SUMMARY_COMPLETION)) == 0
    # 5. SUMMARY_COMPLETION_BOX
    assert len(validate_candidate_slot({
        "prompt": "Summary context with [1] blank.",
        "answer": "A",
        "options": [{"key": "A", "text": "opt 1"}, {"key": "B", "text": "opt 2"}, {"key": "C", "text": "opt 3"}],
    }, QuestionPromptFamily.SUMMARY_COMPLETION_BOX)) == 0
    # 6. MULTIPLE_CHOICE_SINGLE
    assert len(validate_candidate_slot({
        "prompt": "MCQ prompt?",
        "answer": "A",
        "options": [{"key": "A", "text": "1"}, {"key": "B", "text": "2"}, {"key": "C", "text": "3"}, {"key": "D", "text": "4"}],
    }, QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE)) == 0
    # 7. MULTIPLE_CHOICE_MULTIPLE
    assert len(validate_candidate_slot({
        "prompt": "Which TWO are correct?",
        "answer": "A, B",
        "options": [{"key": "A", "text": "1"}, {"key": "B", "text": "2"}, {"key": "C", "text": "3"}, {"key": "D", "text": "4"}, {"key": "E", "text": "5"}],
    }, QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE)) == 0
    # 8. MATCHING_HEADING
    assert len(validate_candidate_slot({
        "prompt": "Paragraph A",
        "answer": "i",
        "options": [{"key": "i", "text": "Heading 1"}, {"key": "ii", "text": "Heading 2"}, {"key": "iii", "text": "Heading 3"}],
    }, QuestionPromptFamily.MATCHING_HEADING)) == 0
    # 9. MATCHING_INFORMATION
    assert len(validate_candidate_slot({"prompt": "A mention of subterranean railways", "answer": "B"}, QuestionPromptFamily.MATCHING_INFORMATION)) == 0
    # 10. MATCHING_FEATURES
    assert len(validate_candidate_slot({
        "prompt": "Proposed subterranean railways",
        "answer": "A",
        "options": [{"key": "A", "text": "Charles Pearson"}, {"key": "B", "text": "Robert Stephenson"}],
    }, QuestionPromptFamily.MATCHING_FEATURES)) == 0
    # 11. MATCHING_ENDINGS
    assert len(validate_candidate_slot({
        "prompt": "The Metropolitan railway was constructed",
        "answer": "C",
        "options": [{"key": "A", "text": "ending 1"}, {"key": "B", "text": "ending 2"}],
    }, QuestionPromptFamily.MATCHING_ENDINGS)) == 0
    # 12. TABLE_COMPLETION
    assert len(validate_candidate_slot({"prompt": "Table row with ______", "answer": "steam engines"}, QuestionPromptFamily.TABLE_COMPLETION)) == 0
    # 13. FLOW_CHART
    assert len(validate_candidate_slot({
        "prompt": "Flow chart step with ______",
        "answer": "electric motors",
        "flow_steps": ["Step 1", "Step 2 with ______"],
    }, QuestionPromptFamily.FLOW_CHART)) == 0
    # 14. DIAGRAM_LABEL
    assert len(validate_candidate_slot({
        "prompt": "Diagram label for part 1: ______",
        "answer": "shield",
        "callout_label": "Tunnelling shield",
    }, QuestionPromptFamily.DIAGRAM_LABEL)) == 0
    # 15. SHORT_ANSWER
    assert len(validate_candidate_slot({"prompt": "What powered early trains?", "answer": "steam locomotives"}, QuestionPromptFamily.SHORT_ANSWER)) == 0
    # 16. NOTE_COMPLETION
    assert len(validate_candidate_slot({"prompt": "Note: underground ______", "answer": "infrastructure"}, QuestionPromptFamily.NOTE_COMPLETION)) == 0
    # 17. FORM_COMPLETION
    assert len(validate_candidate_slot({"prompt": "Form field: Location: ______", "answer": "London"}, QuestionPromptFamily.FORM_COMPLETION)) == 0
    # 18. CLASSIFICATION
    assert len(validate_candidate_slot({
        "prompt": "Statement to classify",
        "answer": "A",
        "options": [{"key": "A", "text": "Category A"}, {"key": "B", "text": "Category B"}],
    }, QuestionPromptFamily.CLASSIFICATION)) == 0
    # 19. CHOOSING_TITLE
    assert len(validate_candidate_slot({
        "prompt": "Choose the best title",
        "answer": "B",
        "options": [{"key": "A", "text": "Title 1"}, {"key": "B", "text": "Title 2"}, {"key": "C", "text": "Title 3"}, {"key": "D", "text": "Title 4"}],
    }, QuestionPromptFamily.CHOOSING_TITLE)) == 0
