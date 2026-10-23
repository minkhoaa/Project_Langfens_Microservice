"""Comprehensive tests for 19 IELTS Question Families Prompt Generation & Candidate Validation."""

import asyncio
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


def test_completion_evaluators_verbatim_and_offsets():
    from app.evaluators.deterministic import AnswerVerbatimAndLengthEvaluator, EvidenceOffsetEvaluator
    from app.contracts.artifact import ArtifactEnvelope, ArtifactType
    from app.reading_evaluation import evaluate_question

    passage_text = "The subterranean Metropolitan Railway opened in 1863 using steam locomotives to ease street congestion."
    completion_types = ["NOTE_COMPLETION", "TABLE_COMPLETION", "FORM_COMPLETION"]
    
    verbatim_evaluator = AnswerVerbatimAndLengthEvaluator()
    offset_evaluator = EvidenceOffsetEvaluator()

    for ctype in completion_types:
        # Subcase 1: Non-verbatim answer rejected
        bad_ans_art = ArtifactEnvelope.create(
            f"art_{ctype}_bad_ans",
            ArtifactType.QUESTION,
            "run_test",
            {
                "questionNumber": 2,
                "questionType": ctype,
                "prompt": f"Locomotives were powered by [2] in 1863.",
                "answer": "diesel engines",  # Not in passage!
                "explanation": "Valid explanation exceeding twenty-five characters in length.",
                "difficulty": "FOUNDATION",
                "evidenceQuote": "using steam locomotives",
                "passageText": passage_text,
                "passageEvidence": {"startChar": 53, "endChar": 76, "text": "using steam locomotives"},
                "evidenceClaimRef": "claim_1",
            },
            "1.0.0",
        )
        res_v = asyncio.run(verbatim_evaluator.evaluate(None, bad_ans_art, "intent_test"))
        assert not res_v.is_pass(), f"{ctype} must reject non-verbatim answer in AnswerVerbatimAndLengthEvaluator"

        evals = evaluate_question(bad_ans_art, passage_text, "FOUNDATION", ())
        v_eval = next(e for e in evals if e.evaluator_id == "eval_answer_verbatim_length")
        assert not v_eval.is_pass(), f"{ctype} must reject non-verbatim answer in evaluate_question"

        # Subcase 2: Valid verbatim answer with passageEvidence accepted
        good_art = ArtifactEnvelope.create(
            f"art_{ctype}_good",
            ArtifactType.QUESTION,
            "run_test",
            {
                "questionNumber": 2,
                "questionType": ctype,
                "prompt": f"Locomotives were powered by [2] in 1863.",
                "answer": "steam",
                "explanation": "Valid explanation exceeding twenty-five characters in length.",
                "difficulty": "FOUNDATION",
                "evidenceQuote": "using steam locomotives",
                "passageEvidence": {"startChar": 53, "endChar": 76, "text": "using steam locomotives"},
                "evidenceClaimRef": "claim_1",
            },
            "1.0.0",
        )
        # Test EvidenceOffsetEvaluator reading passageEvidence object
        good_art_with_pass = ArtifactEnvelope.create(
            f"art_{ctype}_good_pass",
            ArtifactType.QUESTION,
            "run_test",
            {
                **good_art.payload,
                "passageText": passage_text,
            },
            "1.0.0",
        )
        res_o = asyncio.run(offset_evaluator.evaluate(None, good_art_with_pass, "intent_test"))
        assert res_o.is_pass(), f"{ctype} must pass EvidenceOffsetEvaluator with canonical passageEvidence"

        # Subcase 3: Invalid offsets [-1:-1] rejected by EvidenceOffsetEvaluator
        bad_offset_art = ArtifactEnvelope.create(
            f"art_{ctype}_bad_offsets",
            ArtifactType.QUESTION,
            "run_test",
            {
                **good_art.payload,
                "passageText": passage_text,
                "passageEvidence": {"startChar": -1, "endChar": -1, "text": "using steam locomotives"},
            },
            "1.0.0",
        )
        res_bad_o = asyncio.run(offset_evaluator.evaluate(None, bad_offset_art, "intent_test"))
        assert not res_bad_o.is_pass(), f"{ctype} must reject negative offsets [-1:-1] in EvidenceOffsetEvaluator"

def test_all_21_families_templates_contain_explanation_and_evidence():
    """Verify all 21 QuestionPromptFamily templates and system instructions include explanation and evidenceQuote."""
    from app.generators.question.prompts import PROMPT_TEMPLATES, SYSTEM_PROMPTS
    assert len(QuestionPromptFamily) == 21

    for family in QuestionPromptFamily:
        template = PROMPT_TEMPLATES[family]
        sys_prompt = SYSTEM_PROMPTS[family]

        # 1. Template JSON schema must contain "explanation"
        assert '"explanation":' in template, f"{family.name} template is missing 'explanation' in JSON schema"

        # 2. Template must require minimum 25 characters for explanation
        assert "25" in template or "25" in sys_prompt, f"{family.name} must specify >= 25 characters for explanation"

        # 3. Template JSON schema must contain "evidenceQuote"
        assert '"evidenceQuote":' in template, f"{family.name} template is missing 'evidenceQuote' in JSON schema"


def test_render_question_prompt_all_19_families():
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


def test_matching_and_classification_prompt_schemas_include_options_and_headings():
    """Verify prompt templates for matching and classification include options or headings in JSON schema."""
    # 1. Matching Headings
    prompt_heading = render_question_prompt(QuestionPromptFamily.MATCHING_HEADING, 1, SAMPLE_PASSAGE)
    assert '"headings":' in prompt_heading
    assert "Heading i:" in prompt_heading

    # 2. Matching Features
    prompt_features = render_question_prompt(QuestionPromptFamily.MATCHING_FEATURES, 2, SAMPLE_PASSAGE)
    assert '"options":' in prompt_features
    assert "Feature or Person" in prompt_features

    # 3. Matching Endings
    prompt_endings = render_question_prompt(QuestionPromptFamily.MATCHING_ENDINGS, 3, SAMPLE_PASSAGE)
    assert '"options":' in prompt_endings
    assert "Ending completion" in prompt_endings

    # 4. Classification
    prompt_class = render_question_prompt(QuestionPromptFamily.CLASSIFICATION, 4, SAMPLE_PASSAGE)
    assert '"options":' in prompt_class
    assert "Category A" in prompt_class
def test_validate_candidate_slot_true_false_and_yes_no():
    """Verify TFNG and YNNG validation, including NOT GIVEN absence assessment."""
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
    # NOT GIVEN with Pydantic AbsenceAssessment where is_absent=False must be rejected
    from pydantic import BaseModel

    class MockAbsenceAssessment(BaseModel):
        is_absent: bool = False
        absence_reason: str = "Present in text"

    tf_ng_falsy_obj = {
        "prompt": "Charles Pearson was knighted for his engineering achievements.",
        "answer": "NOT GIVEN",
        "absence_assessment": MockAbsenceAssessment(is_absent=False),
    }
    issues_falsy = validate_candidate_slot(tf_ng_falsy_obj, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)
    assert any("absence assessment" in str(i).lower() for i in issues_falsy)

    # NOT GIVEN with Pydantic AbsenceAssessment where is_absent=True must pass
    tf_ng_truthy_obj = {
        "prompt": "Charles Pearson was knighted for his engineering achievements.",
        "answer": "NOT GIVEN",
        "absence_assessment": MockAbsenceAssessment(is_absent=True, absence_reason="Not found"),
    }
    issues_truthy = validate_candidate_slot(tf_ng_truthy_obj, QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN)
    assert len(issues_truthy) == 0

    # Also test YNNG with Pydantic AbsenceAssessment
    yn_ng_falsy_obj = {
        "prompt": "Charles Pearson was knighted for his engineering achievements.",
        "answer": "NOT GIVEN",
        "absence_assessment": MockAbsenceAssessment(is_absent=False),
    }
    issues_yn = validate_candidate_slot(yn_ng_falsy_obj, QuestionPromptFamily.YES_NO_NOT_GIVEN)
    assert any("absence assessment" in str(i).lower() for i in issues_yn)
def test_validate_candidate_slot_completions():
    """Verify sentence, summary, note, and form completion validation (<=3 words, blank marker)."""
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
    # Verify blank marker requirements across ALL completion families
    completion_families = [
        QuestionPromptFamily.SENTENCE_COMPLETION,
        QuestionPromptFamily.TABLE_COMPLETION,
        QuestionPromptFamily.NOTE_COMPLETION,
        QuestionPromptFamily.FORM_COMPLETION,
    ]
    for comp_fam in completion_families:
        # Missing blank marker
        cand_no_blank = {
            "prompt": f"Summary sentence for {comp_fam.value} without marker.",
            "answer": "valid word",
        }
        iss = validate_candidate_slot(cand_no_blank, comp_fam)
        assert any("blank marker" in str(i).lower() for i in iss), f"Failed for {comp_fam}"

        # Valid with ______
        cand_with_underscores = {
            "prompt": f"Summary sentence for {comp_fam.value} with ______ marker.",
            "answer": "valid word",
        }
        assert len(validate_candidate_slot(cand_with_underscores, comp_fam)) == 0

        # Valid with [blank]
        cand_with_bracket = {
            "prompt": f"Summary sentence for {comp_fam.value} with [blank] marker.",
            "answer": "valid word",
        }
        assert len(validate_candidate_slot(cand_with_bracket, comp_fam)) == 0

        # Valid with [1]
        cand_with_num = {
            "prompt": f"Summary sentence for {comp_fam.value} with [1] marker.",
            "answer": "valid word",
        }
        assert len(validate_candidate_slot(cand_with_num, comp_fam)) == 0

    # FLOW_CHART missing blank marker
    flow_no_blank = {
        "prompt": "Complete the flow chart below.",
        "answer": "steam engines",
        "flow_steps": ["Step 1 initial stage", "Step 2 final stage"],
    }
    flow_issues = validate_candidate_slot(flow_no_blank, QuestionPromptFamily.FLOW_CHART)
    assert any("blank marker" in str(i).lower() for i in flow_issues)

    # FLOW_CHART with blank marker in flow_steps
    flow_with_blank = {
        "prompt": "Complete the flow chart below.",
        "answer": "steam engines",
        "flow_steps": ["Step 1 initial stage", "Step 2 final stage with ______"],
    }
    assert len(validate_candidate_slot(flow_with_blank, QuestionPromptFamily.FLOW_CHART)) == 0
def test_validate_candidate_slot_mcq_single_and_multiple():
    """Verify Multiple Choice options count, distinctness, and key validation."""
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
