"""Phase 01 Contract and Policy Tests (T01-01 to T01-06).

Validates canonical contracts, versioned code policies, absence semantics,
immutability hashing, and evaluator pass/fail boundaries.
"""

import json
import os
import pytest
from pydantic import ValidationError

from app.contracts import (
    AbsenceAssessment,
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    CanonicalBaseModel,
    DecisionType,
    EvaluationResult,
    EvaluationStatus,
    Issue,
    IssueCode,
    IssueScope,
    IssueSeverity,
    IssueStatus,
    LoopDecision,
    LoopState,
    MultipleChoiceSingleQuestion,
    QuestionGroup,
    QuestionType,
    ReadingPaper,
    ReadingSection,
    SentenceCompletionQuestion,
    ShortAnswerQuestion,
    SummaryCompletionQuestion,
    TrueFalseAnswer,
    TrueFalseNotGivenQuestion,
    YesNoAnswer,
    YesNoNotGivenQuestion,
    compute_content_hash,
    count_words,
    match_verbatim_in_passage,
    validate_answer_length,
    validate_reading_paper_policies,
    validate_reading_section_policies,
    validate_loop_decision,
    validate_transition,
)

FIXTURES_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "fixtures/contracts")
)


# ---------------------------------------------------------------------------
# T01-01: Round-trip fixtures Python <-> JSON <-> .NET <-> JSON <-> Python
# ---------------------------------------------------------------------------
def test_t01_01_fixture_envelope_roundtrip():
    envelope_path = os.path.join(FIXTURES_DIR, "artifact_envelope.json")
    with open(envelope_path, "r", encoding="utf-8") as f:
        raw_json = f.read()

    envelope = ArtifactEnvelope.model_validate_json(raw_json)
    assert envelope.artifact_id == "art_passage_001"
    assert envelope.artifact_type == ArtifactType.PASSAGE
    assert envelope.version == 1
    assert envelope.verify_integrity() is True

    # Check Unicode preservation (Vietnamese & scientific characters)
    payload = envelope.payload
    assert "khí quyển cổ đại" in payload["title"]
    assert "λ = 532 nm, ΔT = 1.5°C" in payload["scientificSymbols"]
    assert payload["nullField"] is None

    # Check serialization roundtrip matches content
    dumped = envelope.model_dump_json(by_alias=True)
    roundtrip = ArtifactEnvelope.model_validate_json(dumped)
    assert roundtrip.content_hash == envelope.content_hash
    assert roundtrip.created_at == envelope.created_at


def test_t01_01_fixture_reading_paper_roundtrip():
    paper_path = os.path.join(FIXTURES_DIR, "reading_paper_valid.json")
    with open(paper_path, "r", encoding="utf-8") as f:
        raw_json = f.read()

    paper = ReadingPaper.model_validate_json(raw_json)
    assert paper.total_questions == 40
    assert len(paper.sections) == 3
    assert paper.sections[0].word_count == 750

    # Policy validation on valid fixture must produce zero issues
    issues = validate_reading_paper_policies(paper)
    assert len(issues) == 0, f"Expected 0 issues for valid paper, got: {[i.message for i in issues]}"


def test_t01_01_true_cross_language_roundtrip_python_dotnet_python():
    """Validates that JSON serialized by .NET is read back by Python with 100% fidelity."""
    # 1. Artifact Envelope produced by .NET
    dotnet_envelope_path = os.path.join(FIXTURES_DIR, "dotnet_roundtrip_envelope.json")
    if os.path.exists(dotnet_envelope_path):
        with open(dotnet_envelope_path, "r", encoding="utf-8") as f:
            raw_dotnet_json = f.read()
        envelope = ArtifactEnvelope.model_validate_json(raw_dotnet_json)
        assert envelope.artifact_id == "art_passage_001"
        assert envelope.version == 1
        assert "khí quyển cổ đại" in envelope.payload["title"]
        assert "λ = 532 nm, ΔT = 1.5°C" in envelope.payload["scientificSymbols"]
        assert envelope.payload["nullField"] is None
        assert envelope.verify_integrity() is True

    # 2. Reading Paper produced by .NET
    dotnet_paper_path = os.path.join(FIXTURES_DIR, "dotnet_roundtrip_paper.json")
    if os.path.exists(dotnet_paper_path):
        with open(dotnet_paper_path, "r", encoding="utf-8") as f:
            raw_dotnet_paper = f.read()
        paper = ReadingPaper.model_validate_json(raw_dotnet_paper)
        assert paper.total_questions == 40
        assert len(paper.sections) == 3
        issues = validate_reading_paper_policies(paper)
        assert len(issues) == 0

    # 3. Evaluation Result produced by .NET
    dotnet_eval_path = os.path.join(FIXTURES_DIR, "dotnet_roundtrip_eval.json")
    if os.path.exists(dotnet_eval_path):
        with open(dotnet_eval_path, "r", encoding="utf-8") as f:
            raw_dotnet_eval = f.read()
        eval_res = EvaluationResult.model_validate_json(raw_dotnet_eval)
        assert eval_res.status == EvaluationStatus.PASS
        assert eval_res.is_pass() is True


# ---------------------------------------------------------------------------
# T01-02: Deserialize wrong type / count / unknown fields (extra='forbid')
# ---------------------------------------------------------------------------
def test_t01_02_unknown_field_rejection_extra_forbid():
    """Validates that extra unknown fields are strictly rejected across domain models."""
    with pytest.raises(ValidationError, match="Extra inputs are not permitted"):
        ArtifactRef.model_validate({
            "artifactId": "art_01",
            "artifactType": "Passage",
            "version": 1,
            "contentHash": "a" * 64,
            "unexpectedExtraField": "malicious_or_unknown",
        })

    with pytest.raises(ValidationError, match="Extra inputs are not permitted"):
        SentenceCompletionQuestion.model_validate({
            "questionNumber": 1,
            "explanation": "Valid explanation text.",
            "prompt": "The prompt with _____ blank.",
            "answer": "ice cores",
            "evidenceQuote": "Passage quote text here.",
            "unknownInject": 12345,
        })


def test_t01_02_schema_rejection_invalid_mcq_options():
    # MCQ requires exactly 4 distinct options
    with pytest.raises(ValidationError):
        MultipleChoiceSingleQuestion(
            questionNumber=1,
            explanation="Explanation text here.",
            prompt="What is the test question?",
            options=["Option A", "Option B", "Option C"],  # Only 3 options
            correctOption="A",
            evidenceQuote="Passage quotation text here.",
        )

    # MCQ with duplicate options must be rejected
    with pytest.raises(ValidationError):
        MultipleChoiceSingleQuestion(
            questionNumber=1,
            explanation="Explanation text here.",
            prompt="What is the test question?",
            options=["Option A", "Option B", "Option A", "Option D"],  # Duplicate Option A
            correctOption="A",
            evidenceQuote="Passage quotation text here.",
        )


def test_t01_02_schema_rejection_invalid_question_number():
    with pytest.raises(ValidationError):
        # Question number must be between 1 and 40
        SentenceCompletionQuestion(
            questionNumber=0,  # Invalid
            explanation="Valid explanation.",
            prompt="Sentence prompt with _____ blank.",
            answer="ice cores",
            evidenceQuote="The ancient Antarctic ice cores reveal carbon records.",
        )


def test_t01_02_schema_rejection_envelope_negative_version():
    with pytest.raises(ValidationError):
        ArtifactEnvelope(
            artifactId="art_test",
            artifactType=ArtifactType.PASSAGE,
            version=-1,  # Must be >= 1
            runId="run_01",
            contentHash="a" * 64,
            createdAt="2026-09-30T12:00:00Z",
            producerVersion="v1",
            payload={},
        )


# ---------------------------------------------------------------------------
# T01-03: Change 1 char of payload / parent ref -> hash changes & deep immutability
# ---------------------------------------------------------------------------
def test_t01_03_immutability_and_hash_sensitivity():
    payload_v1 = {"temperature": 1.5, "unit": "celsius", "note": "Initial observation"}
    payload_v2 = {"temperature": 1.6, "unit": "celsius", "note": "Initial observation"}  # 1 char changed

    hash_v1 = compute_content_hash(payload_v1)
    hash_v2 = compute_content_hash(payload_v2)
    assert hash_v1 != hash_v2

    envelope_v1 = ArtifactEnvelope.create(
        artifact_id="art_exp_01",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_01",
        payload=payload_v1,
        producer_version="test@1.0.0",
        version=1,
    )
    assert envelope_v1.content_hash == hash_v1

    # Creating next version increments version and updates hash
    envelope_v2 = envelope_v1.create_next_version(
        new_payload=payload_v2,
        producer_version="test@1.0.0",
        parent_refs=[envelope_v1.to_ref()],
    )
    assert envelope_v2.version == 2
    assert envelope_v2.content_hash != envelope_v1.content_hash
    assert len(envelope_v2.parent_refs) == 1
    assert envelope_v2.parent_refs[0].content_hash == hash_v1


def test_t01_03_parent_ref_change_alters_content_hash():
    """Changing parent version strictly changes the artifact content hash even if payload is identical."""
    parent_v1 = ArtifactRef(
        artifactId="art_parent",
        artifactType=ArtifactType.EVIDENCE_GRAPH,
        version=1,
        contentHash="a" * 64,
    )
    parent_v2 = ArtifactRef(
        artifactId="art_parent",
        artifactType=ArtifactType.EVIDENCE_GRAPH,
        version=2,
        contentHash="a" * 64,
    )
    payload = {"data": "same payload"}

    hash_with_v1 = compute_content_hash(payload, [parent_v1])
    hash_with_v2 = compute_content_hash(payload, [parent_v2])
    assert hash_with_v1 != hash_with_v2


def test_t01_03_deep_immutability_rejects_post_creation_mutation():
    """Mutating payload or parent_refs in-place must fail."""
    envelope = ArtifactEnvelope.create(
        artifact_id="art_immutable",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_01",
        payload={"title": "Frozen Title", "nested": {"count": 10}},
        producer_version="1.0.0",
        version=1,
        parent_refs=[
            ArtifactRef(
                artifactId="art_p",
                artifactType=ArtifactType.SOURCE_PACK,
                version=1,
                contentHash="b" * 64,
            )
        ],
    )

    # Attempting to mutate nested payload must raise TypeError (MappingProxyType)
    with pytest.raises(TypeError):
        envelope.payload["title"] = "Mutated Title"

    with pytest.raises(TypeError):
        envelope.payload["nested"]["count"] = 20

    # Attempting to mutate parent_refs must fail (tuple has no append)
    with pytest.raises(AttributeError):
        envelope.parent_refs.append(
            ArtifactRef(
                artifactId="art_p2",
                artifactType=ArtifactType.SOURCE_PACK,
                version=2,
                contentHash="c" * 64,
            )
        )


# ---------------------------------------------------------------------------
# T01-04: Evaluator error and critical issues block PASS
# ---------------------------------------------------------------------------
def test_t01_04_evaluator_error_blocks_pass():
    ref = ArtifactRef(
        artifactId="art_target_01",
        artifactType=ArtifactType.SECTION,
        version=1,
        contentHash="f" * 64,
    )

    # 1. Explicit ERROR status cannot be PASS
    eval_err = EvaluationResult.create_error(
        evaluation_id="eval_001",
        evaluator_id="eval_sec_01",
        evaluator_version="1.0.0",
        target_ref=ref,
        error_message="Gateway timeout",
    )
    assert eval_err.status == EvaluationStatus.ERROR
    assert eval_err.is_pass() is False

    # 2. Status PASS but with open CRITICAL issue cannot be PASS
    critical_issue = Issue.create(
        issue_id="iss_crit_01",
        code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Claim contradicted by source paper",
        affected_refs=[ref],
        status=IssueStatus.OPEN,
    )
    eval_with_crit = EvaluationResult(
        evaluationId="eval_002",
        evaluatorId="eval_sec_02",
        evaluatorVersion="1.0.0",
        targetRef=ref,
        status=EvaluationStatus.PASS,
        issues=[critical_issue],
    )
    assert eval_with_crit.is_pass() is False
    # 3. Transition check: cannot transition from EVALUATING to COMPLETED if not valid
    assert validate_transition(LoopState.EVALUATING, LoopState.COMPLETED) is True
    assert validate_transition(LoopState.COMPLETED, LoopState.DRAFTING) is False

    # 4. Fail-closed decision validation: A PASS decision or transition to COMPLETED
    # MUST be strictly inadmissible without a matching, passing EvaluationResult.
    pass_decision = LoopDecision(
        decisionId="dec_001",
        runId="run_01",
        decision=DecisionType.PASS,
        currentState=LoopState.EVALUATING,
        nextState=LoopState.COMPLETED,
        reason="Evaluation successful",
        targetScope=IssueScope.SECTION,
        evaluationRef="eval_pass_valid",
    )

    # 4a. Missing evaluation (evaluation=None): MUST be rejected fail-closed
    ok_none, err_none = validate_loop_decision(pass_decision, None)
    assert ok_none is False
    assert "Fail-closed rejection" in err_none
    assert pass_decision.is_admissible(None) is False

    # 4b. Evaluator error: MUST be rejected fail-closed
    ok_err, err_msg = validate_loop_decision(pass_decision, eval_err)
    assert ok_err is False
    assert "cannot decide PASS" in err_msg
    assert pass_decision.is_admissible(eval_err) is False

    # 4c. Open critical issues: MUST be rejected fail-closed
    ok_crit, err_crit = validate_loop_decision(pass_decision, eval_with_crit)
    assert ok_crit is False
    assert "open CRITICAL issues" in err_crit
    assert pass_decision.is_admissible(eval_with_crit) is False

    # 4d. Mismatched evaluationRef: MUST be rejected fail-closed
    valid_eval = EvaluationResult(
        evaluationId="eval_pass_valid",
        evaluatorId="eval_sec_01",
        evaluatorVersion="1.0.0",
        targetRef=ref,
        status=EvaluationStatus.PASS,
        issues=[],
    )
    mismatched_eval = EvaluationResult(
        evaluationId="eval_diff_id",
        evaluatorId="eval_sec_01",
        evaluatorVersion="1.0.0",
        targetRef=ref,
        status=EvaluationStatus.PASS,
        issues=[],
    )
    ok_mismatch, err_mismatch = validate_loop_decision(pass_decision, mismatched_eval)
    assert ok_mismatch is False
    assert "does not match" in err_mismatch

    # 4e. Valid passing evaluation with matching evaluationRef: MUST pass
    ok_valid, err_valid = validate_loop_decision(pass_decision, valid_eval)
    assert ok_valid is True
    assert err_valid is None
    assert pass_decision.is_admissible(valid_eval) is True

# ---------------------------------------------------------------------------
# T01-05: Valid NOT GIVEN absence semantics & partial-word completion rejection
# ---------------------------------------------------------------------------
def test_t01_05_not_given_absence_semantics_strict():
    # Valid NOT GIVEN with confirmed AbsenceAssessment and NO evidence quote
    q_ng = TrueFalseNotGivenQuestion(
        questionNumber=1,
        statement="Scientists found water on Mars in 1890.",
        answer=TrueFalseAnswer.NOT_GIVEN,
        evidenceQuote=None,
        absenceAssessment=AbsenceAssessment(
            assessmentId="abs_01",
            claimOrTopic="Water on Mars discovery date",
            absenceReason="Passage discusses lunar missions, completely omitting Mars.",
            absenceConfirmed=True,
        ),
        explanation="The passage makes no mention of Mars in 1890.",
    )
    assert q_ng.answer == TrueFalseAnswer.NOT_GIVEN
    assert q_ng.evidence_quote is None
    assert q_ng.absence_assessment.absence_confirmed is True

    # NOT GIVEN without absenceAssessment must be strictly rejected
    with pytest.raises(ValidationError, match="absenceAssessment is strictly required"):
        TrueFalseNotGivenQuestion(
            questionNumber=1,
            statement="Statement without absence assessment.",
            answer=TrueFalseAnswer.NOT_GIVEN,
            evidenceQuote=None,
            absenceAssessment=None,
            explanation="Explanation text here.",
        )

    # NOT GIVEN with spurious evidenceQuote must be strictly rejected
    with pytest.raises(ValidationError, match="evidenceQuote must not be present"):
        TrueFalseNotGivenQuestion(
            questionNumber=1,
            statement="Statement with spurious quote.",
            answer=TrueFalseAnswer.NOT_GIVEN,
            evidenceQuote="Fake positive quote asserting absence.",
            absenceAssessment=AbsenceAssessment(
                assessmentId="abs_spurious",
                claimOrTopic="Topic",
                absenceReason="Reason",
                absenceConfirmed=True,
            ),
            explanation="Explanation text here.",
        )

    # TRUE/FALSE without evidenceQuote must fail validation
    with pytest.raises(ValidationError, match="evidenceQuote is required"):
        TrueFalseNotGivenQuestion(
            questionNumber=2,
            statement="The mission launched in 1969.",
            answer=TrueFalseAnswer.TRUE,
            evidenceQuote=None,
            explanation="Explanation text here.",
        )


def test_t01_05_completion_answer_constraints_and_partial_word_rejection():
    passage = "The expedition discovered ancient atmospheric strata deep underground."

    # Answer length check
    assert validate_answer_length("atmospheric strata") is True
    assert validate_answer_length("one two three") is True
    assert validate_answer_length("one two three four") is False  # 4 words exceeds limit

    # Full word verbatim matches: must pass
    assert match_verbatim_in_passage("atmospheric strata", passage) is True
    assert match_verbatim_in_passage("strata", passage) is True
    assert match_verbatim_in_passage("atmospheric", passage) is True

    # Partial-word matches: MUST BE REJECTED!
    assert match_verbatim_in_passage("rat", passage) is False  # 'rat' inside 'strata'
    assert match_verbatim_in_passage("sphere", passage) is False  # 'sphere' inside 'atmospheric'
    assert match_verbatim_in_passage("ground", passage) is False  # 'ground' inside 'underground'


# ---------------------------------------------------------------------------
# T01-06: Section and paper boundary enforcement in code
# ---------------------------------------------------------------------------
def test_t01_06_boundary_violations_detected_by_code():
    # Create section with invalid passage length: 50 words (far below 720)
    short_passage = "This is a very short passage containing only a few words."
    sec_short = ReadingSection(
        sectionId=1,
        title="Short Passage Test",
        passage=short_passage,
        wordCount=count_words(short_passage),
        groups=[],
    )
    issues = validate_reading_section_policies(sec_short, 1, 1)
    issue_codes = [i.code for i in issues]
    assert IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS in issue_codes
    assert IssueCode.QUESTION_COUNT_MISMATCH in issue_codes


def test_t01_06_duplicate_prompt_detection():
    # Paper containing duplicate prompts
    paper_path = os.path.join(FIXTURES_DIR, "reading_paper_valid.json")
    with open(paper_path, "r", encoding="utf-8") as f:
        paper_dict = json.load(f)

    # Inject duplicate prompt into Question 2 matching Question 1
    paper_dict["sections"][0]["groups"][0]["questions"][1]["statement"] = (
        paper_dict["sections"][0]["groups"][0]["questions"][0]["statement"]
    )

    paper_with_dup = ReadingPaper.model_validate(paper_dict)
    issues = validate_reading_paper_policies(paper_with_dup)
    dup_issues = [i for i in issues if i.code == IssueCode.DUPLICATE_CONTENT]
    assert len(dup_issues) > 0
    assert "duplicate prompt" in dup_issues[0].message
