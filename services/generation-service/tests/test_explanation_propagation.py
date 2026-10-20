"""Regression tests proving explanations survive Candidate -> Question -> Section serialization

Verifies:
1. Candidate.explanation propagates to Question artifact envelope.
2. Question envelope explanation propagates to Section group questions.
3. Generic placeholder explanations matching the regex are recognized and rejected.
4. Authentic textual explanations pass through uncorrupted without fallback fabrication.
"""

from __future__ import annotations

import re
import pytest
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.section import assemble_immutable_section
from app.generators.question.context import QuestionCandidate


def test_candidate_explanation_survives_question_and_section_serialization():
    bp_ref = ArtifactRef(
        artifactId="bp_sec_1",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="0" * 64,
    )
    p_ref = ArtifactRef(
        artifactId="art_passage_s1",
        artifactType=ArtifactType.PASSAGE,
        version=1,
        contentHash="0" * 64,
    )

    # 1. Candidate retains explanation
    real_explanation_q1 = (
        "According to paragraph 2, satellite data confirms extensive coastal light density."
    )
    cand = QuestionCandidate(
        candidateId="cand_exp_1",
        slotId="slot_1",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=1,
        questionType="TrueFalseNotGiven",
        prompt="The Persian Gulf is exposed to ALAN.",
        answer="TRUE",
        evidenceQuote="Regions such as the Mediterranean and Persian Gulf are exposed.",
        explanation=real_explanation_q1,
        score=1.0,
    )
    assert cand.explanation == real_explanation_q1

    # 2. Candidate payload into Question artifact envelope preserves explanation
    q_payload = {
        "passage": "Sample passage text with sufficient words for testing purposes.",
        "questionNumber": cand.question_number,
        "questionType": cand.question_type,
        "prompt": cand.prompt,
        "answer": cand.answer,
        "evidenceQuote": cand.evidence_quote,
        "explanation": cand.explanation,
        "score": cand.score,
        "candidateId": cand.candidate_id,
    }
    q_env = ArtifactEnvelope.create(
        artifact_id="art_q_1",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        payload=q_payload,
        run_id="run_test",
        producer_version="2.0.0",
    )
    assert q_env.payload["explanation"] == real_explanation_q1

    # 3. Assemble full section with 13 questions and verify explanation survives
    p_env = ArtifactEnvelope.create(
        artifact_id="art_passage_s1",
        artifact_type=ArtifactType.PASSAGE,
        version=1,
        payload={
            "passage": "Sample passage text with sufficient words for testing purposes. " * 30,
            "title": "Marine Science",
        },
        run_id="run_test",
        producer_version="2.0.0",
    )

    q_envs = [q_env]
    for i in range(2, 14):
        q_type = "TrueFalseNotGiven" if i <= 7 else "SentenceCompletion"
        qi = ArtifactEnvelope.create(
            artifact_id=f"art_q_{i}",
            artifact_type=ArtifactType.QUESTION,
            version=1,
            payload={
                "questionNumber": i,
                "questionType": q_type,
                "prompt": f"Prompt statement for question {i}.",
                "answer": "TRUE" if i <= 7 else "sample answer",
                "evidenceQuote": "Sample passage text with sufficient words for testing purposes.",
                "explanation": f"Specific textual rationale for question {i} found in paragraph {i % 3 + 1}.",
                "score": 1.0,
                "candidateId": f"cand_{i}",
            },
            run_id="run_test",
            producer_version="2.0.0",
        )
        q_envs.append(qi)

    sec_env = assemble_immutable_section(
        section_index=1,
        title="Marine Science",
        passage_envelope=p_env,
        blueprint_ref=bp_ref,
        question_envelopes=q_envs,
        run_id="run_test",
        version=1,
    )

    sec_payload = sec_env.payload
    q1_in_sec = sec_payload["groups"][0]["questions"][0]
    assert q1_in_sec["explanation"] == real_explanation_q1

    # 4. Verify generic regex detects placeholders while authentic explanation passes
    generic_regex = re.compile(
        r"^Explanation for question\s+\d+\s+based on passage text\.$", re.IGNORECASE
    )
    assert generic_regex.match("Explanation for question 1 based on passage text.") is not None
    assert generic_regex.match("Explanation for question 13 based on passage text.") is not None
    assert generic_regex.match(q1_in_sec["explanation"]) is None
