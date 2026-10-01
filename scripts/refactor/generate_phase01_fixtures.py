"""Generates deterministic Phase 01 test fixtures for cross-language validation."""

import json
import os
import sys
from datetime import datetime, timezone

# Add generation-service to path
sys.path.insert(0, os.path.abspath("services/generation-service"))

from app.contracts import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    EvaluationResult,
    EvaluationStatus,
    Issue,
    IssueCode,
    IssueScope,
    IssueSeverity,
    IssueStatus,
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
    UsageMetrics,
    YesNoAnswer,
    YesNoNotGivenQuestion,
    AbsenceAssessment,
    compute_content_hash,
)

FIXTURES_DIR = "artifacts/refactor/phase-01/fixtures"
os.makedirs(FIXTURES_DIR, exist_ok=True)


def make_words(count: int, seed_word: str = "research") -> str:
    """Generates a text with exactly `count` words."""
    words = [f"{seed_word}{i % 50}" for i in range(count)]
    return " ".join(words)


def generate_fixtures():
    # 1. Artifact Envelope Fixture
    parent_ref = ArtifactRef(
        artifactId="art_evidence_001",
        artifactType=ArtifactType.EVIDENCE_GRAPH,
        version=1,
        contentHash="a" * 64,
    )
    payload_data = {
        "title": "Nghiên cứu về khí quyển cổ đại & nồng độ CO₂ trên Trái Đất",
        "scientificSymbols": "λ = 532 nm, ΔT = 1.5°C, H₂O vapor",
        "sampleCount": 42,
        "isVerified": True,
        "nullField": None,
    }
    envelope = ArtifactEnvelope.create(
        artifact_id="art_passage_001",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_test_001",
        section_id=1,
        payload=payload_data,
        producer_version="loop-engine-v2@0.1.0",
        version=1,
        parent_refs=[parent_ref],
        created_at=datetime(2026, 9, 30, 12, 0, 0, tzinfo=timezone.utc),
    )
    with open(os.path.join(FIXTURES_DIR, "artifact_envelope.json"), "w", encoding="utf-8") as f:
        f.write(envelope.model_dump_json(by_alias=True, indent=2))

    # 2. Evaluation Result Fixture (PASS)
    eval_pass = EvaluationResult(
        evaluationId="eval_pass_001",
        evaluatorId="evaluator_deterministic_boundary",
        evaluatorVersion="1.0.0",
        targetRef=envelope.to_ref(),
        status=EvaluationStatus.PASS,
        issues=[],
        score=1.0,
        inputDependencyRefs=[parent_ref],
        provider="internal",
        model="code-validator",
        promptVersion=None,
        elapsedMs=14.5,
        usage=UsageMetrics(promptTokens=0, completionTokens=0, totalTokens=0, costUsd=0.0),
        evaluatedAt=datetime(2026, 9, 30, 12, 0, 1, tzinfo=timezone.utc),
    )
    with open(os.path.join(FIXTURES_DIR, "evaluation_result.json"), "w", encoding="utf-8") as f:
        f.write(eval_pass.model_dump_json(by_alias=True, indent=2))

    # 3. Evaluation Result Fixture (ERROR with critical issue)
    eval_err = EvaluationResult.create_error(
        evaluation_id="eval_err_001",
        evaluator_id="evaluator_semantic_fidelity",
        evaluator_version="1.0.0",
        target_ref=envelope.to_ref(),
        error_message="LLM provider gateway timed out after 60 seconds",
        code=IssueCode.EVALUATOR_UNAVAILABLE,
        elapsed_ms=60000.0,
    )
    with open(os.path.join(FIXTURES_DIR, "evaluation_error.json"), "w", encoding="utf-8") as f:
        f.write(eval_err.model_dump_json(by_alias=True, indent=2))

    # 4. Valid NOT GIVEN and Completion Questions
    passage_text = "The ancient Antarctic ice cores reveal detailed carbon atmospheric records. In 1957, scientists recorded unprecedented solar observations in the southern hemisphere."
    
    q_tf_ng = TrueFalseNotGivenQuestion(
        questionNumber=1,
        statement="Scientists measured solar activity in Antarctica before 1950.",
        answer=TrueFalseAnswer.NOT_GIVEN,
        evidenceQuote=None,
        absenceAssessment=AbsenceAssessment(
            assessmentId="abs_001",
            claimOrTopic="Solar measurements prior to 1950",
            absenceReason="The text discusses 1957 observations but mentions nothing before 1950.",
            topicalContextSpan="In 1957, scientists recorded unprecedented solar observations",
            absenceConfirmed=True,
        ),
        explanation="The passage mentions observations began in 1957, with no mention of dates before 1950.",
    )

    q_completion = SentenceCompletionQuestion(
        questionNumber=2,
        prompt="The research team analyzed ancient _____ to measure carbon records.",
        answer="ice cores",
        evidenceQuote="The ancient Antarctic ice cores reveal detailed carbon atmospheric records.",
        explanation="'ice cores' appears directly in the text and fits the blank.",
    )

    with open(os.path.join(FIXTURES_DIR, "question_types_sample.json"), "w", encoding="utf-8") as f:
        json.dump(
            {
                "notGivenSample": q_tf_ng.model_dump(mode="json", by_alias=True),
                "completionSample": q_completion.model_dump(mode="json", by_alias=True),
            },
            f,
            indent=2,
            ensure_ascii=False,
        )

    # 5. Full Valid Reading Paper Fixture (40 questions, 3 passages, 720-915 words each, 2150-2750 total)
    # Generate 3 distinct passages with exact word counts
    p1_words = 750
    p2_words = 780
    p3_words = 820
    # Total = 2350 words (in [2150, 2750])

    p1_text = make_words(p1_words - 20, "icecore") + " The expedition discovered remarkable ancient atmospheric strata deep underground."
    p2_text = make_words(p2_words - 20, "oceanic") + " Marine biodiversity flourished around thermal hydrothermal vent ecosystems."
    p3_text = make_words(p3_words - 20, "astronomy") + " Radio telescopes detected subtle cosmic frequency modulations."

    # Section 1: 7 TFNG + 6 Sentence Completion = 13 questions (Q1 - Q13)
    s1_g1_questions = [
        TrueFalseNotGivenQuestion(
            questionNumber=i,
            statement=f"Statement regarding icecore finding number {i}.",
            answer=TrueFalseAnswer.TRUE if i % 2 == 1 else TrueFalseAnswer.NOT_GIVEN,
            evidenceQuote="The expedition discovered remarkable ancient atmospheric strata deep underground." if i % 2 == 1 else None,
            absenceAssessment=None if i % 2 == 1 else AbsenceAssessment(
                assessmentId=f"abs_s1_{i}",
                claimOrTopic=f"Icecore topic {i}",
                absenceReason="Not mentioned in passage text.",
                absenceConfirmed=True,
            ),
            explanation=f"Explanation for question {i} regarding icecore study.",
        )
        for i in range(1, 8)
    ]
    s1_g2_questions = [
        SentenceCompletionQuestion(
            questionNumber=i,
            prompt=f"Researchers in study {i} discovered remarkable ancient _____ during expedition.",
            answer="atmospheric strata",
            evidenceQuote="The expedition discovered remarkable ancient atmospheric strata deep underground.",
            explanation=f"Explanation for sentence completion question {i}.",
        )
        for i in range(8, 14)
    ]
    sec1 = ReadingSection(
        sectionId=1,
        title="Antarctic Ice Core Research",
        passage=p1_text,
        wordCount=p1_words,
        groups=[
            QuestionGroup(
                groupId="grp_s1_1",
                questionType=QuestionType.TRUE_FALSE_NOT_GIVEN,
                instructions="Do the following statements agree with the information given in Reading Passage 1?",
                questions=s1_g1_questions,
            ),
            QuestionGroup(
                groupId="grp_s1_2",
                questionType=QuestionType.SENTENCE_COMPLETION,
                instructions="Complete the sentences below. Choose NO MORE THAN THREE WORDS.",
                questions=s1_g2_questions,
            ),
        ],
    )

    # Section 2: 6 MCQ + 7 Summary Completion = 13 questions (Q14 - Q26)
    s2_g1_questions = [
        MultipleChoiceSingleQuestion(
            questionNumber=i,
            prompt=f"What was unique about the marine hydrothermal finding {i}?",
            options=[
                f"Option A regarding discovery {i}",
                f"Option B regarding discovery {i}",
                f"Option C regarding discovery {i}",
                f"Option D regarding discovery {i}",
            ],
            correctOption="A",
            evidenceQuote="Marine biodiversity flourished around thermal hydrothermal vent ecosystems.",
            explanation=f"Explanation for MCQ question {i}.",
        )
        for i in range(14, 20)
    ]
    s2_g2_questions = [
        SummaryCompletionQuestion(
            questionNumber=i,
            prompt=f"Hydrothermal vents in zone {i} supported flourishing marine _____ ecosystems.",
            answer="biodiversity",
            evidenceQuote="Marine biodiversity flourished around thermal hydrothermal vent ecosystems.",
            explanation=f"Explanation for summary completion question {i}.",
        )
        for i in range(20, 27)
    ]
    sec2 = ReadingSection(
        sectionId=2,
        title="Hydrothermal Marine Vent Ecosystems",
        passage=p2_text,
        wordCount=p2_words,
        groups=[
            QuestionGroup(
                groupId="grp_s2_1",
                questionType=QuestionType.MULTIPLE_CHOICE_SINGLE,
                instructions="Choose the correct letter, A, B, C or D.",
                questions=s2_g1_questions,
            ),
            QuestionGroup(
                groupId="grp_s2_2",
                questionType=QuestionType.SUMMARY_COMPLETION,
                instructions="Complete the summary below using words from the passage.",
                questions=s2_g2_questions,
            ),
        ],
    )

    # Section 3: 7 YNNG + 7 Short Answer = 14 questions (Q27 - Q40)
    s3_g1_questions = [
        YesNoNotGivenQuestion(
            questionNumber=i,
            statement=f"Telescope signals confirm astronomical claim number {i}.",
            answer=YesNoAnswer.YES if i % 2 == 1 else YesNoAnswer.NOT_GIVEN,
            evidenceQuote="Radio telescopes detected subtle cosmic frequency modulations." if i % 2 == 1 else None,
            absenceAssessment=None if i % 2 == 1 else AbsenceAssessment(
                assessmentId=f"abs_s3_{i}",
                claimOrTopic=f"Astronomical claim {i}",
                absenceReason="Claim is omitted from telescope analysis.",
                absenceConfirmed=True,
            ),
            explanation=f"Explanation for Yes No question {i}.",
        )
        for i in range(27, 34)
    ]
    s3_g2_questions = [
        ShortAnswerQuestion(
            questionNumber=i,
            prompt=f"What type of modulations were detected by the radio telescopes in experiment {i}?",
            answer="frequency modulations",
            evidenceQuote="Radio telescopes detected subtle cosmic frequency modulations.",
            explanation=f"Explanation for short answer question {i}.",
        )
        for i in range(34, 41)
    ]
    sec3 = ReadingSection(
        sectionId=3,
        title="Radio Telescope Astronomical Modulations",
        passage=p3_text,
        wordCount=p3_words,
        groups=[
            QuestionGroup(
                groupId="grp_s3_1",
                questionType=QuestionType.YES_NO_NOT_GIVEN,
                instructions="Do the following statements agree with the views of the writer?",
                questions=s3_g1_questions,
            ),
            QuestionGroup(
                groupId="grp_s3_2",
                questionType=QuestionType.SHORT_ANSWER,
                instructions="Answer the questions below using NO MORE THAN THREE WORDS.",
                questions=s3_g2_questions,
            ),
        ],
    )

    paper = ReadingPaper(
        paperId="paper_test_001",
        runId="run_test_001",
        title="IELTS Academic Reading Practice Test 1",
        sections=[sec1, sec2, sec3],
        totalQuestions=40,
        totalWordCount=p1_words + p2_words + p3_words,
    )

    with open(os.path.join(FIXTURES_DIR, "reading_paper_valid.json"), "w", encoding="utf-8") as f:
        f.write(paper.model_dump_json(by_alias=True, indent=2))

    print(f"Generated Phase 01 fixtures in {FIXTURES_DIR} successfully.")


if __name__ == "__main__":
    generate_fixtures()
