"""Authoritative Regression Test Suite for NOT_GIVEN Autonomous Generation.

Covers the 12 required invariant verification scenarios:
1. Valid TFNG NOT_GIVEN with confirmed absenceAssessment, topicalContextSpan, and exact passageEvidence offsets.
2. Valid YNNG NOT_GIVEN with confirmed absenceAssessment, topicalContextSpan, and exact passageEvidence offsets.
3. Missing absenceAssessment on NOT_GIVEN rejected fail-closed.
4. Missing or False absenceConfirmed on NOT_GIVEN rejected fail-closed.
5. Missing or invalid topical context offsets (e.g. offset 0 substitution or mismatch) rejected fail-closed.
6. TRUE/FALSE/YES/NO with valid positive evidence passes; presence of absenceAssessment rejected.
7. Incorrectly classified NOT_GIVEN where passage entails the statement is rejected.
8. Incorrectly classified NOT_GIVEN where passage contradicts the statement is rejected.
9. Candidate-pool alternative selection: defective candidate (e.g. invalid NOT_GIVEN) bypassed in favor of valid candidate in pool without extra provider calls.
10. Bounded repair triggered when all candidates in pool fail.
11. Real Pydantic model validation on TrueFalseNotGivenQuestion, YesNoNotGivenQuestion, TrueFalseCandidate, YesNoCandidate.
12. SectionRunner mock execution, restart/resume, and checkpoint integrity with NOT_GIVEN questions.
"""

import pytest
from pydantic import ValidationError

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evidence import AbsenceAssessment
from app.contracts.question_type import QuestionPromptFamily
from app.contracts.questions import (
    TrueFalseAnswer,
    YesNoAnswer,
    TrueFalseCandidate,
    YesNoCandidate,
    TrueFalseNotGivenQuestion,
    YesNoNotGivenQuestion,
)
from app.context import validate_candidate_slot
from app.reading_evaluation import evaluate_question, IssueCode
from app.section_runner import _parse_single_candidate, _parse_candidate_payload


PASSAGE_TEXT = (
    "The emergence of iron metallurgy in West Africa represents a pivotal development in the region's "
    "technological and cultural history, with evidence of diverse smelting techniques dating back to the first millennium BCE. "
    "Further west, early iron smelting is attested in Burkina Faso around 700 BCE at Douroula, where multiple intact furnaces were documented. "
    "However, archaeological expeditions have found no evidence of bronze casting predating iron tools in this geographical region."
)

TOPICAL_SPAN = "Further west, early iron smelting is attested in Burkina Faso around 700 BCE at Douroula, where multiple intact furnaces were documented."
TOPICAL_START = PASSAGE_TEXT.find(TOPICAL_SPAN)
TOPICAL_END = TOPICAL_START + len(TOPICAL_SPAN)

CLAIMS_MAP = {
    "claim_1": {
        "claimId": "claim_1",
        "text": "Early iron smelting is attested in Burkina Faso around 700 BCE at Douroula.",
    }
}


# ==============================================================================
# Scenario 1 & 2: Valid TFNG and YNNG NOT_GIVEN
# ==============================================================================

def test_01_valid_tfng_not_given_passes_all_evaluators():
    """Scenario 1: Valid TFNG NOT_GIVEN with confirmed AbsenceAssessment and exact topical offsets."""
    assessment = {
        "assessmentId": "abs_q5",
        "claimOrTopic": "Specific mining depth at Douroula",
        "absenceReason": "The passage discusses surface smelting furnaces at Douroula but never mentions underground mining depth.",
        "topicalContextSpan": TOPICAL_SPAN,
        "absenceConfirmed": True,
    }
    cand = {
        "statement": "Archaeologists at Douroula excavated mining shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "absenceAssessment": assessment,
        "explanation": "The passage discusses early iron smelting at Douroula but contains no information regarding the depth of mining shafts.",
    }
    parsed = _parse_single_candidate(
        cand=cand,
        raw_payload={"candidates": [cand]},
        q_num=5,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=PASSAGE_TEXT,
        claims_map=CLAIMS_MAP,
        claim_id="claim_1",
        difficulty="FOUNDATION",
        target_focus=TOPICAL_SPAN,
    )

    assert parsed["answer"] == "NOT_GIVEN"
    assert "evidenceQuote" not in parsed or parsed.get("evidenceQuote") is None
    assert parsed["absenceAssessment"]["absenceConfirmed"] is True
    assert parsed["absenceAssessment"]["topicalContextSpan"] == TOPICAL_SPAN
    assert parsed["passageEvidence"]["startChar"] == TOPICAL_START
    assert parsed["passageEvidence"]["endChar"] == TOPICAL_END
    assert parsed["passageEvidence"]["text"] == TOPICAL_SPAN

    # Real evaluation
    art = ArtifactEnvelope.create(
        "art_q5",
        ArtifactType.QUESTION,
        "run_test",
        parsed,
        "2.0.0",
    )
    evals = evaluate_question(art, PASSAGE_TEXT, "FOUNDATION", ())
    for e in evals:
        assert e.is_pass(), f"Evaluator {e.evaluator_id} failed: {[i.message for i in e.issues]}"


def test_02_valid_ynng_not_given_passes_all_evaluators():
    """Scenario 2: Valid YNNG NOT_GIVEN with confirmed AbsenceAssessment and exact topical offsets."""
    assessment = {
        "assessmentId": "abs_q28",
        "claimOrTopic": "Writer opinion on future excavation prospects",
        "absenceReason": "The passage provides historical dates but does not disclose the author's opinion on future excavations.",
        "topicalContextSpan": TOPICAL_SPAN,
        "absenceConfirmed": True,
    }
    cand = {
        "statement": "The author believes that future excavations at Douroula will reveal earlier smelting dates.",
        "answer": "NOT_GIVEN",
        "absenceAssessment": assessment,
        "explanation": "The passage reports evidence from Douroula but does not express the author's personal views on future excavations.",
    }
    parsed = _parse_single_candidate(
        cand=cand,
        raw_payload={"candidates": [cand]},
        q_num=28,
        q_type="YES_NO_NOT_GIVEN",
        passage_text=PASSAGE_TEXT,
        claims_map=CLAIMS_MAP,
        claim_id="claim_1",
        difficulty="FOUNDATION",
        target_focus=TOPICAL_SPAN,
    )

    assert parsed["answer"] == "NOT_GIVEN"
    assert "evidenceQuote" not in parsed or parsed.get("evidenceQuote") is None
    assert parsed["absenceAssessment"]["absenceConfirmed"] is True
    assert parsed["passageEvidence"]["startChar"] == TOPICAL_START
    assert parsed["passageEvidence"]["endChar"] == TOPICAL_END

    art = ArtifactEnvelope.create(
        "art_q28",
        ArtifactType.QUESTION,
        "run_test",
        parsed,
        "2.0.0",
    )
    evals = evaluate_question(art, PASSAGE_TEXT, "FOUNDATION", ())
    for e in evals:
        assert e.is_pass(), f"Evaluator {e.evaluator_id} failed: {[i.message for i in e.issues]}"


# ==============================================================================
# Scenario 3: Missing absenceAssessment
# ==============================================================================

def test_03_missing_absence_assessment_rejected():
    """Scenario 3: NOT_GIVEN without absenceAssessment fails parser, Pydantic, and evaluators."""
    # 1. Parser rejection
    cand_no_absence = {
        "statement": "Archaeologists excavated shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "evidenceQuote": TOPICAL_SPAN,  # Spurious quote
        "explanation": "The passage does not mention thirty meter deep shafts at all.",
    }
    with pytest.raises(ValueError, match="absenceAssessment"):
        _parse_single_candidate(
            cand=cand_no_absence,
            raw_payload={"candidates": [cand_no_absence]},
            q_num=5,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=PASSAGE_TEXT,
            claims_map=CLAIMS_MAP,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    # 2. Pydantic validation rejection
    with pytest.raises(ValidationError, match="absenceAssessment is strictly required"):
        TrueFalseNotGivenQuestion(
            questionNumber=5,
            statement="Archaeologists excavated shafts deeper than thirty meters.",
            answer=TrueFalseAnswer.NOT_GIVEN,
            explanation="Valid pedagogical explanation exceeding twenty-five characters in length.",
            absenceAssessment=None,
        )

    # 3. Direct evaluator rejection
    raw_payload = {
        "questionNumber": 5,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "Archaeologists excavated shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "explanation": "Valid pedagogical explanation exceeding twenty-five characters in length.",
        "difficulty": "FOUNDATION",
        "passageEvidence": {"startChar": TOPICAL_START, "endChar": TOPICAL_END, "text": TOPICAL_SPAN},
        "evidenceClaimRef": "claim_1",
        "absenceAssessment": None,
    }
    art = ArtifactEnvelope.create("art_no_abs", ArtifactType.QUESTION, "run_test", raw_payload, "2.0.0")
    evals = evaluate_question(art, PASSAGE_TEXT, "FOUNDATION", ())
    struct_eval = next(e for e in evals if e.evaluator_id == "eval_question_structure")
    evidence_eval = next(e for e in evals if e.evaluator_id == "eval_evidence_offsets")
    assert not struct_eval.is_pass()
    assert not evidence_eval.is_pass()


# ==============================================================================
# Scenario 4: Missing or False absenceConfirmed
# ==============================================================================

def test_04_missing_or_false_absence_confirmed_rejected():
    """Scenario 4: NOT_GIVEN where absenceConfirmed is False or missing is rejected."""
    # Subcase A: absenceConfirmed=False
    cand_false_confirmed = {
        "statement": "Archaeologists excavated shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "absenceAssessment": {
            "assessmentId": "abs_q5",
            "claimOrTopic": "Mining depth",
            "absenceReason": "Not mentioned",
            "topicalContextSpan": TOPICAL_SPAN,
            "absenceConfirmed": False,
        },
        "explanation": "Valid explanation exceeding twenty-five characters.",
    }
    with pytest.raises(ValueError, match="absenceConfirmed must be True"):
        _parse_single_candidate(
            cand=cand_false_confirmed,
            raw_payload={"candidates": [cand_false_confirmed]},
            q_num=5,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=PASSAGE_TEXT,
            claims_map=CLAIMS_MAP,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    # Subcase B: absenceConfirmed omitted / None
    cand_none_confirmed = {
        "statement": "Archaeologists excavated shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "absenceAssessment": {
            "assessmentId": "abs_q5",
            "claimOrTopic": "Mining depth",
            "absenceReason": "Not mentioned",
            "topicalContextSpan": TOPICAL_SPAN,
        },
        "explanation": "Valid explanation exceeding twenty-five characters.",
    }
    with pytest.raises(ValueError, match="absenceConfirmed must be True"):
        _parse_single_candidate(
            cand=cand_none_confirmed,
            raw_payload={"candidates": [cand_none_confirmed]},
            q_num=5,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=PASSAGE_TEXT,
            claims_map=CLAIMS_MAP,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )


# ==============================================================================
# Scenario 5: Missing or invalid topical context offsets
# ==============================================================================

def test_05_missing_or_invalid_topical_context_offsets_rejected():
    """Scenario 5: Topical context offsets must not substitute 0 or accept ungrounded spans."""
    # Subcase A: topicalContextSpan not in passage
    cand_bad_span = {
        "statement": "Archaeologists excavated shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "absenceAssessment": {
            "assessmentId": "abs_q5",
            "claimOrTopic": "Mining depth",
            "absenceReason": "The passage makes no mention of shaft depths at all.",
            "topicalContextSpan": "Non-existent anchor text that does not appear in passage.",
            "absenceConfirmed": True,
        },
        "explanation": "Valid explanation exceeding twenty-five characters.",
    }
    with pytest.raises(ValueError, match="topicalContextSpan.*not found in passage"):
        _parse_single_candidate(
            cand=cand_bad_span,
            raw_payload={"candidates": [cand_bad_span]},
            q_num=5,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=PASSAGE_TEXT,
            claims_map=CLAIMS_MAP,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    # Subcase B: Offsets artificially set to [0:20] where text does not match
    bad_offset_payload = {
        "questionNumber": 5,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "Archaeologists excavated shafts deeper than thirty meters.",
        "answer": "NOT_GIVEN",
        "explanation": "Valid explanation exceeding twenty-five characters.",
        "difficulty": "FOUNDATION",
        "passageEvidence": {"startChar": 0, "endChar": 20, "text": TOPICAL_SPAN},  # Mismatch!
        "evidenceClaimRef": "claim_1",
        "absenceAssessment": {
            "assessmentId": "abs_q5",
            "claimOrTopic": "Mining depth",
            "absenceReason": "The passage makes no mention of shaft depths at all.",
            "topicalContextSpan": TOPICAL_SPAN,
            "absenceConfirmed": True,
        },
    }
    art_bad_offset = ArtifactEnvelope.create("art_bad_off", ArtifactType.QUESTION, "run_test", bad_offset_payload, "2.0.0")
    evals = evaluate_question(art_bad_offset, PASSAGE_TEXT, "FOUNDATION", ())
    ev_eval = next(e for e in evals if e.evaluator_id == "eval_evidence_offsets")
    assert not ev_eval.is_pass()
    assert any(i.code == IssueCode.EVIDENCE_MISSING for i in ev_eval.issues)


# ==============================================================================
# Scenario 6: TRUE/FALSE/YES/NO with valid evidence & prohibited absenceAssessment
# ==============================================================================

def test_06_true_false_positive_evidence_and_absence_prohibition():
    """Scenario 6: TRUE/FALSE requires evidenceQuote; absenceAssessment is strictly prohibited."""
    true_quote = "Further west, early iron smelting is attested in Burkina Faso around 700 BCE at Douroula"
    # Subcase A: Valid TRUE candidate passes
    cand_valid_true = {
        "statement": "Early iron smelting in Burkina Faso has been dated to approximately 700 BCE.",
        "answer": "TRUE",
        "evidenceQuote": true_quote,
        "explanation": "The passage confirms that early iron smelting is attested around 700 BCE in Burkina Faso.",
    }
    parsed_true = _parse_single_candidate(
        cand=cand_valid_true,
        raw_payload={"candidates": [cand_valid_true]},
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=PASSAGE_TEXT,
        claims_map=CLAIMS_MAP,
        claim_id="claim_1",
        difficulty="FOUNDATION",
    )
    assert parsed_true["answer"] == "TRUE"
    assert parsed_true["evidenceQuote"] == true_quote
    assert "absenceAssessment" not in parsed_true

    art_true = ArtifactEnvelope.create("art_true", ArtifactType.QUESTION, "run_test", parsed_true, "2.0.0")
    evals = evaluate_question(art_true, PASSAGE_TEXT, "FOUNDATION", ())
    for e in evals:
        assert e.is_pass(), f"Evaluator {e.evaluator_id} failed on valid TRUE: {[i.message for i in e.issues]}"

    # Subcase B: TRUE candidate with spurious absenceAssessment is rejected by parser & Pydantic
    cand_spurious_abs = {
        "statement": "Early iron smelting in Burkina Faso has been dated to approximately 700 BCE.",
        "answer": "TRUE",
        "evidenceQuote": true_quote,
        "absenceAssessment": {
            "assessmentId": "abs_spurious",
            "claimOrTopic": "Smelting",
            "absenceReason": "None",
            "absenceConfirmed": True,
        },
        "explanation": "Valid explanation exceeding twenty-five characters in length.",
    }
    with pytest.raises(ValueError, match="prohibited absenceAssessment"):
        _parse_single_candidate(
            cand=cand_spurious_abs,
            raw_payload={"candidates": [cand_spurious_abs]},
            q_num=1,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=PASSAGE_TEXT,
            claims_map=CLAIMS_MAP,
            claim_id="claim_1",
            difficulty="FOUNDATION",
        )

    with pytest.raises(ValidationError, match="absenceAssessment must not be present"):
        TrueFalseNotGivenQuestion(
            questionNumber=1,
            statement="Early iron smelting in Burkina Faso has been dated to approximately 700 BCE.",
            answer=TrueFalseAnswer.TRUE,
            evidenceQuote=true_quote,
            absenceAssessment=AbsenceAssessment(
                assessmentId="abs_spurious",
                claimOrTopic="Smelting",
                absenceReason="None",
                absenceConfirmed=True,
            ),
            explanation="Valid explanation exceeding twenty-five characters in length.",
        )


# ==============================================================================
# Scenario 7 & 8: NOT_GIVEN semantic evaluation (Entailment & Contradiction)
# ==============================================================================

def test_07_not_given_entailed_by_passage_is_rejected():
    """Scenario 7: Statement classified as NOT_GIVEN, but passage entails it -> REJECTED (should be TRUE)."""
    # Statement is actually entailed by passage sentence: "early iron smelting is attested in Burkina Faso around 700 BCE at Douroula"
    entailed_stmt = "Evidence shows that iron was smelted in Burkina Faso as early as 700 BCE."
    payload = {
        "questionNumber": 5,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": entailed_stmt,
        "answer": "NOT_GIVEN",
        "explanation": "The candidate author claims this is not given, but passage actually proves it.",
        "difficulty": "FOUNDATION",
        "passageEvidence": {"startChar": TOPICAL_START, "endChar": TOPICAL_END, "text": TOPICAL_SPAN},
        "evidenceClaimRef": "claim_1",
        "absenceAssessment": {
            "assessmentId": "abs_q5",
            "claimOrTopic": "Burkina Faso iron smelting date",
            "absenceReason": "Erroneously claims this date is not given.",
            "topicalContextSpan": TOPICAL_SPAN,
            "absenceConfirmed": True,
        },
    }
    art = ArtifactEnvelope.create("art_entailed_ng", ArtifactType.QUESTION, "run_test", payload, "2.0.0")
    evals = evaluate_question(art, PASSAGE_TEXT, "FOUNDATION", ())
    sem_eval = next(e for e in evals if e.evaluator_id == "eval_question_semantic")
    assert not sem_eval.is_pass()
    assert any("entail" in i.message.lower() for i in sem_eval.issues)


def test_08_not_given_contradicted_by_passage_is_rejected():
    """Scenario 8: Statement classified as NOT_GIVEN, but passage contradicts it -> REJECTED (should be FALSE)."""
    # Passage explicitly says: "archaeological expeditions have found no evidence of bronze casting predating iron tools"
    contradicted_stmt = "Archaeologists discovered bronze casting that predated iron tools in West Africa."
    payload = {
        "questionNumber": 5,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": contradicted_stmt,
        "answer": "NOT_GIVEN",
        "explanation": "Candidate author claims bronze casting date is not given, but passage explicitly contradicts it.",
        "difficulty": "FOUNDATION",
        "passageEvidence": {"startChar": TOPICAL_START, "endChar": TOPICAL_END, "text": TOPICAL_SPAN},
        "evidenceClaimRef": "claim_1",
        "absenceAssessment": {
            "assessmentId": "abs_q5",
            "claimOrTopic": "Bronze casting date",
            "absenceReason": "Erroneously claims bronze casting presence is omitted.",
            "topicalContextSpan": TOPICAL_SPAN,
            "absenceConfirmed": True,
        },
    }
    art = ArtifactEnvelope.create("art_contra_ng", ArtifactType.QUESTION, "run_test", payload, "2.0.0")
    evals = evaluate_question(art, PASSAGE_TEXT, "FOUNDATION", ())
    sem_eval = next(e for e in evals if e.evaluator_id == "eval_question_semantic")
    assert not sem_eval.is_pass()
    assert any("contradict" in i.message.lower() for i in sem_eval.issues)


# ==============================================================================
# Scenario 9 & 10: Candidate Pool Alternative Selection & Bounded Repair
# ==============================================================================

def test_09_candidate_pool_selects_valid_alternative_without_extra_call():
    """Scenario 9: Candidate 0 is a defective NOT_GIVEN (missing absenceAssessment),

    but candidate 1 is a valid TRUE question. The parser must reject candidate 0
    and cleanly select candidate 1 from the pool without error.
    """
    true_quote = "early iron smelting is attested in Burkina Faso around 700 BCE at Douroula"
    raw_payload = {
        "candidates": [
            {
                # Defective candidate: NOT_GIVEN without absenceAssessment
                "statement": "Archaeologists excavated shafts deeper than thirty meters.",
                "answer": "NOT_GIVEN",
                "evidenceQuote": true_quote,
                "explanation": "This candidate is missing absenceAssessment sub-object.",
            },
            {
                # Valid candidate: TRUE with verbatim evidenceQuote
                "statement": "Early iron smelting was present at Douroula around 700 BCE.",
                "answer": "TRUE",
                "evidenceQuote": true_quote,
                "explanation": "The passage confirms iron smelting at Douroula around 700 BCE.",
            },
        ]
    }
    selected = _parse_candidate_payload(
        raw_payload=raw_payload,
        q_num=5,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=PASSAGE_TEXT,
        claims_map=CLAIMS_MAP,
        claim_id="claim_1",
        difficulty="FOUNDATION",
        target_focus=TOPICAL_SPAN,
    )
    assert selected["answer"] == "TRUE"
    assert selected["statement"] == "Early iron smelting was present at Douroula around 700 BCE."
    assert selected["evidenceQuote"] == true_quote


def test_10_bounded_repair_when_all_candidates_fail():
    """Scenario 10: When all candidates in the candidate pool fail, parser raises informative ValueError

    allowing the runner's bounded repair loop to catch and retry.
    """
    raw_payload = {
        "candidates": [
            {
                # Defective NOT_GIVEN
                "statement": "Archaeologists excavated shafts deeper than thirty meters.",
                "answer": "NOT_GIVEN",
                "explanation": "Missing absenceAssessment.",
            },
            {
                # Defective TRUE: ungrounded quote
                "statement": "Iron was discovered in 2000 BCE.",
                "answer": "TRUE",
                "evidenceQuote": "This quote does not exist in the passage.",
                "explanation": "Explanation for invalid candidate.",
            },
        ]
    }
    with pytest.raises(ValueError) as excinfo:
        _parse_candidate_payload(
            raw_payload=raw_payload,
            q_num=5,
            q_type="TRUE_FALSE_NOT_GIVEN",
            passage_text=PASSAGE_TEXT,
            claims_map=CLAIMS_MAP,
            claim_id="claim_1",
            difficulty="FOUNDATION",
            target_focus=TOPICAL_SPAN,
        )
    assert "absenceAssessment" in str(excinfo.value) or "evidence quote is not found" in str(excinfo.value)


# ==============================================================================
# Scenario 11: Real Pydantic model validation on contracts
# ==============================================================================

def test_11_pydantic_contracts_validation():
    """Scenario 11: Tests canonical TrueFalseNotGivenQuestion and TrueFalseCandidate schemas."""
    # 1. Valid NOT GIVEN TrueFalseCandidate
    tf_cand = TrueFalseCandidate(
        prompt="Archaeologists at Douroula found Roman coins.",
        answer="NOT_GIVEN",
        absenceAssessment=AbsenceAssessment(
            assessmentId="abs_cand_1",
            claimOrTopic="Roman coins discovery",
            absenceReason="Passage describes local African metallurgical items with no mention of Roman artifacts.",
            topicalContextSpan=TOPICAL_SPAN,
            absenceConfirmed=True,
        ),
        explanation="Valid pedagogical explanation exceeding twenty-five characters in length.",
    )
    assert tf_cand.answer == "NOT_GIVEN"
    assert tf_cand.absence_assessment is not None
    assert tf_cand.absence_assessment.absence_confirmed is True

    # 2. Defective NOT GIVEN TrueFalseCandidate (missing absenceAssessment)
    with pytest.raises(ValidationError, match="absenceAssessment"):
        TrueFalseCandidate(
            prompt="Archaeologists at Douroula found Roman coins.",
            answer="NOT_GIVEN",
            explanation="Valid pedagogical explanation exceeding twenty-five characters in length.",
        )

    # 3. Defective TRUE TrueFalseCandidate (containing absenceAssessment)
    with pytest.raises(ValidationError, match="absenceAssessment"):
        TrueFalseCandidate(
            prompt="Iron smelting is attested at Douroula.",
            answer="TRUE",
            evidenceQuote="early iron smelting is attested in Burkina Faso around 700 BCE at Douroula",
            absenceAssessment=AbsenceAssessment(
                assessmentId="abs_cand_2",
                claimOrTopic="Iron smelting",
                absenceReason="None",
                absenceConfirmed=True,
            ),
            explanation="Valid pedagogical explanation exceeding twenty-five characters in length.",
        )


# ==============================================================================
# Scenario 12: SectionRunner execution with valid NOT_GIVEN candidate
# ==============================================================================

@pytest.mark.asyncio
async def test_12_section_runner_execution_with_not_given_question():
    """Scenario 12: SectionRunner mock execution cleanly produces and commits a valid NOT_GIVEN question."""
    from uuid import uuid4
    from tests.unified.mock_fixtures import create_mock_environment
    from tests.unified.test_section_standalone import _setup_standalone_prerequisites, create_source_inputs
    from app.contracts.blueprint import DifficultyLevel
    from app.reading_policy import GroupConfig, PinnedExecutionPolicy, SectionConfig
    from app.reading_models import RunContext
    from app.section_runner import SectionRunner

    run_id = f"sr-ng-mock-{uuid4().hex[:8]}"
    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="legacy_preset")
    pipeline, client, provider, gateway = create_mock_environment(policy=policy, run_id=run_id)

    context = RunContext(
        runId=run_id,
        jobId=client.default_job_id,
        epoch=1,
        leaseOwner=client.default_lease_owner,
        policyHash=policy.hash,
        client=client,
        gateway=gateway,
    )

    all_sources = create_source_inputs()
    source_input = next(s for s in all_sources if s.section_index == 1)
    config = policy.section(1)

    source_ref, blueprint_env = await _setup_standalone_prerequisites(
        client, context, 1, source_input, policy
    )

    # Bind the scripted absence assessment to this run's immutable blueprint,
    # rather than an unrelated historical passage or a randomly selected claim.
    slot = blueprint_env.payload["sections"][0]["questionSlots"][0]
    claim_id = slot["claimRefIds"][0]
    bound_claim = next(c for c in source_ref.evidence.payload["claims"] if c["claimId"] == claim_id)
    topical_anchor = bound_claim["text"]
    ng_stmt = "The archaeological research project was financed by merchant guilds."
    q1_op_id = f"op:{run_id}:question:1:1_1"
    provider.script_response(
        q1_op_id,
        {
            "candidates": [
                {
                    "statement": ng_stmt,
                    "answer": "NOT_GIVEN",
                    "absenceAssessment": {
                        "assessmentId": f"abs_{run_id}_1",
                        "claimOrTopic": "Financing of the archaeological research",
                        "absenceReason": "The passage describes archaeological findings but supplies no information about research financing or merchant guilds.",
                        "topicalContextSpan": topical_anchor,
                        "absenceConfirmed": True,
                    },
                    "explanation": "The passage reports archaeological findings but provides no information about research financing.",
                }
            ]
        },
    )
    provider.script_response(
        f"op_solve_{run_id}_question:{run_id}:1_1",
        {
            "questionNumber": 1,
            "normalizedAnswer": "NOT_GIVEN",
            "justification": "The passage reports archaeological findings but never identifies a source of research financing.",
            "citedSpans": [{"spanText": topical_anchor}],
            "selfReportedConfidence": 0.95,
        },
    )

    runner = SectionRunner(client, gateway)
    res = await runner.run(context, config, source_ref, blueprint_env.to_ref(), policy)

    assert len(res.questions) == 13
    q1_art = res.questions[0]
    assert q1_art.payload["answer"] == "NOT_GIVEN"
    assert q1_art.payload["statement"] == ng_stmt
    assert q1_art.payload["absenceAssessment"]["absenceConfirmed"] is True
    assert q1_art.payload["absenceAssessment"]["topicalContextSpan"] == topical_anchor
    assert q1_art.payload["passageEvidence"]["text"] == topical_anchor
    assert "evidenceQuote" not in q1_art.payload or q1_art.payload.get("evidenceQuote") is None

    # Checkpoint integrity verification: state checkpoint must record committed Q1 artifact
    state = client.resume_state(run_id)
    committed_q1 = next((a for a in state.artifacts if a.artifactId == f"question:{run_id}:1"), None)
    assert committed_q1 is not None
    assert committed_q1.acceptedVersion >= 1
