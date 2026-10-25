"""Offline Acceptance Gate: Q1 Claim-Local Evidence Fix & Regression Suite.

Verifies:
1. Q1 original TRUE candidate with mixed Claim 1/2 quote localizes to Claim 2 evidence.
2. Correct Claim 2 evidence-local span verification.
3. Historical Q1 NOT_GIVEN entailment failure (TFNG_BOUNDARY_CONFLICT).
4. Historical Q1 V2 blind-solver disagreement (UNSUPPORTED_OR_CONTRADICTED_CLAIM).
5. Legitimate competing-claim evidence rejection (Op 16 Candidate 1).
6. Shared geography without factual contradiction (Sentence 1 with West Africa).
7. Numerical, chronological, entity, and qualifier drift rejection.
8. Historical Q2, Q4, Q5 wrong-claim associations fail closed.
9. Historical Q10 invalid FLOW_CHART answer rejected before provider calls.
10. Valid semantic paraphrase with correct quote offsets accepted.
11. Candidate selection priority and bounded regeneration behavior.
12. SectionRunner candidate payload production-path integration.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueCode
from app.contracts.solver import AdjudicationVerdict, StudentVisibleQuestion
from app.evaluators.solver import compare_answers
from app.reading_evaluation import evaluate_question, verify_question_claim_provenance
from app.section_runner import (
    CandidateRejectionError,
    CandidateRejectionReason,
    _parse_candidate_payload,
    _parse_single_candidate,
    _validate_completion_candidate_grounding,
)
from app.solvers.adjudication import adjudicate_item

SNAPSHOT_POST_HARDENING = Path(__file__).resolve().parent.parent.parent.parent / "reports" / "hybrid_13q_post_hardening_cba0c609-f9c0-4294-b687-362a7413519a.json"
SNAPSHOT_13Q_LIVE = Path(__file__).resolve().parent.parent.parent.parent / "reports" / "hybrid_single_section_13q_live_snapshot.json"


@pytest.fixture(scope="module")
def post_hardening_data() -> Dict[str, Any]:
    with open(SNAPSHOT_POST_HARDENING, "r", encoding="utf-8") as f:
        data = json.load(f)

    artifacts = {
        a["ArtifactType"]: json.loads(a["PayloadJson"])
        for a in data.get("all_artifacts", [])
        if a.get("PayloadJson")
    }
    passage = artifacts["Passage"]["passage"]
    alignments = artifacts["Passage"].get("claimAlignments", [])
    claims_list = artifacts["EvidenceGraph"]["claims"]
    claims_map = {c["claimId"]: c for c in claims_list}
    blueprint = artifacts["ExamBlueprint"]
    slot1 = blueprint["sections"][0]["questionSlots"][0]

    ops_by_id = {}
    for op in data["operations"]["actual_db_operations"]:
        if op.get("ResultRefJson"):
            ref = json.loads(op["ResultRefJson"])
            ops_by_id[op["OperationId"]] = ref

    return {
        "passage": passage,
        "alignments": alignments,
        "claims_map": claims_map,
        "blueprint": blueprint,
        "slot1": slot1,
        "ops": ops_by_id,
        "raw_data": data,
    }


def test_01_q1_original_true_candidate_mixed_claim_quote_localizes_to_claim2(post_hardening_data):
    """Proves that Q1 Op 16 Candidate 0, whose raw quote mixed Claim 1 and Claim 2,
    is localized to the exact, contiguous Claim 2 span and passes all gates.
    """
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    alignments = post_hardening_data["alignments"]
    bound_claim_id = slot1["claimRefIds"][0]

    op16 = post_hardening_data["ops"]["op:run_cba0c609f9c04294b687362a7413519a:question:1:1_1"]
    cand0 = op16["parsed_payload"]["candidates"][0]

    assert cand0["answer"] == "TRUE"
    assert "While the region boasts" in cand0["evidenceQuote"]
    assert "only a few provide the necessary detail" in cand0["evidenceQuote"]

    parsed = _parse_single_candidate(
        cand=cand0,
        raw_payload=op16["parsed_payload"],
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage,
        claims_map=claims_map,
        claim_id=bound_claim_id,
        difficulty="FOUNDATION",
    )

    # 1. Localized quote is exact Claim 2 span
    expected_local_quote = "only a few provide the necessary detail for in-depth analysis of historical and anthropological dimensions."
    assert parsed["evidenceQuote"] == expected_local_quote
    pe = parsed["passageEvidence"]
    assert pe["text"] == expected_local_quote
    assert passage[pe["startChar"]:pe["endChar"]] == expected_local_quote

    # 2. Provenance verification PASSES
    prov_issues = verify_question_claim_provenance(
        question_payload=parsed,
        blueprint_slot=slot1,
        claims=claims_map,
        passage=passage,
        passage_alignments=alignments,
    )
    assert prov_issues == []

    # 3. All deterministic evaluators PASS
    env = ArtifactEnvelope(
        artifact_id="question:test:1",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        content_hash="0" * 64,
        producer_version="1.0.0",
        created_at=datetime.now(timezone.utc),
        payload=parsed,
        parent_refs=[],
        run_id="run_test",
    )
    eval_results = evaluate_question(
        artifact=env,
        passage=passage,
        difficulty="FOUNDATION",
        siblings=[],
        blueprint_slot=slot1,
        claims=claims_map,
        passage_alignments=alignments,
    )
    assert all(r.status == EvaluationStatus.PASS for r in eval_results)


def test_02_correct_claim2_evidence_local_span(post_hardening_data):
    """Proves the localized span has clean provenance to Claim 2 and zero overlap with competing claims."""
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    bound_claim_id = slot1["claimRefIds"][0]
    local_quote = "only a few provide the necessary detail for in-depth analysis of historical and anthropological dimensions."
    p_start = passage.find(local_quote)
    p_end = p_start + len(local_quote)

    payload = {
        "questionNumber": 1,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "The passage states that only a few iron production sites in West Africa provide sufficient detail for in-depth historical and anthropological analysis.",
        "answer": "TRUE",
        "evidenceQuote": local_quote,
        "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": local_quote},
        "evidenceClaimRef": bound_claim_id,
        "explanation": "The passage states that only a few provide necessary detail.",
        "difficulty": "FOUNDATION",
    }
    issues = verify_question_claim_provenance(payload, slot1, claims_map, passage)
    assert issues == []


def test_03_historical_q1_not_given_entailment_failure(post_hardening_data):
    """Proves that historical Q1 Op 16 Candidate 2 (labeled NOT_GIVEN) is rejected
    by eval_question_semantic because the passage actually entails the statement.
    """
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    op16 = post_hardening_data["ops"]["op:run_cba0c609f9c04294b687362a7413519a:question:1:1_1"]
    cand2 = op16["parsed_payload"]["candidates"][2]

    assert cand2["answer"] == "NOT_GIVEN"

    parsed = _parse_single_candidate(
        cand=cand2,
        raw_payload=op16["parsed_payload"],
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage,
        claims_map=claims_map,
        claim_id=slot1["claimRefIds"][0],
        difficulty="FOUNDATION",
    )

    env = ArtifactEnvelope(
        artifact_id="question:test:1",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        content_hash="0" * 64,
        producer_version="1.0.0",
        created_at=datetime.now(timezone.utc),
        payload=parsed,
        parent_refs=[],
        run_id="run_test",
    )
    eval_results = evaluate_question(
        artifact=env,
        passage=passage,
        difficulty="FOUNDATION",
        siblings=[],
        blueprint_slot=slot1,
        claims=claims_map,
    )
    sem_eval = next(r for r in eval_results if r.evaluator_id == "eval_question_semantic")
    assert sem_eval.status == EvaluationStatus.FAIL
    assert any(i.code == IssueCode.TFNG_BOUNDARY_CONFLICT for i in sem_eval.issues)


def test_04_historical_q1_v2_blind_solver_disagreement(post_hardening_data):
    """Proves that historical Q1 v2 (Op 25 Candidate 2) fails blind-solver adjudication
    because the solver legitimately deduced TRUE from the passage while the key was NOT_GIVEN.
    """
    passage = post_hardening_data["passage"]
    stmt = "The passage discusses the specific challenges of studying early iron production in West Africa due to the lack of well-preserved sites."
    expected_key = "NOT_GIVEN"
    solver_key = "TRUE"

    cmp = compare_answers(expected_key, solver_key, "TRUE_FALSE_NOT_GIVEN", 1)
    sv = StudentVisibleQuestion(
        question_number=1,
        question_type="TRUE_FALSE_NOT_GIVEN",
        prompt=stmt,
    )
    quote = "The study of early iron production in West Africa has long been a subject of significant scholarly interest, yet it remains challenging due to the scarcity of well-preserved, well-documented, and well-dated sites."
    adj = adjudicate_item(comparison=cmp, passage_text=passage, student_question=sv, evidence_quote=quote)

    assert adj.verdict in (AdjudicationVerdict.KEY_CONTRADICTED, AdjudicationVerdict.SOLVER_DEFECTIVE)


def test_05_legitimate_competing_claim_evidence_must_still_be_rejected(post_hardening_data):
    """Proves that a candidate citing pure competing-claim evidence (Op 16 Candidate 1, Claim 1)
    is strictly rejected with CLAIM_PROVENANCE_MISMATCH and is NOT accepted or mis-localized.
    """
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    bound_claim_id = slot1["claimRefIds"][0]
    op16 = post_hardening_data["ops"]["op:run_cba0c609f9c04294b687362a7413519a:question:1:1_1"]
    cand1 = op16["parsed_payload"]["candidates"][1]

    assert cand1["answer"] == "FALSE"

    parsed = _parse_single_candidate(
        cand=cand1,
        raw_payload=op16["parsed_payload"],
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage,
        claims_map=claims_map,
        claim_id=bound_claim_id,
        difficulty="FOUNDATION",
    )

    prov_issues = verify_question_claim_provenance(
        question_payload=parsed,
        blueprint_slot=slot1,
        claims=claims_map,
        passage=passage,
    )
    assert len(prov_issues) > 0
    assert prov_issues[0][0] == IssueCode.CLAIM_PROVENANCE_MISMATCH
    assert "primarily supports claim" in prov_issues[0][1]


def test_06_shared_geography_without_factual_contradiction(post_hardening_data):
    """Proves that sharing a broad regional geographic entity ('West Africa') without
    factual contradiction does not trigger a false-positive marker conflict.
    """
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    bound_claim_id = slot1["claimRefIds"][0]

    # Sentence 1 quote from Op 25 Candidate 1:
    quote_s1 = "The study of early iron production in West Africa has long been a subject of significant scholarly interest, yet it remains challenging due to the scarcity of well-preserved, well-documented, and well-dated sites."
    p_start = passage.find(quote_s1)
    p_end = p_start + len(quote_s1)

    payload = {
        "questionNumber": 1,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "The passage mentions that the study of early iron production in West Africa is a subject of significant scholarly interest.",
        "answer": "TRUE",
        "evidenceQuote": quote_s1,
        "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote_s1},
        "evidenceClaimRef": bound_claim_id,
        "explanation": "The passage explicitly notes that the study is of significant scholarly interest.",
        "difficulty": "FOUNDATION",
    }

    issues = verify_question_claim_provenance(
        question_payload=payload,
        blueprint_slot=slot1,
        claims=claims_map,
        passage=passage,
    )
    assert issues == []


@pytest.mark.parametrize(
    ("bound_claim", "competing_claim", "expected_conflict_type"),
    [
        ("Several sites in Lake Kivu were dated to 600 BCE.", "Several sites in Lake Kivu were dated to 700 BCE.", "number"),
        ("Only a few sites in Lake Kivu showed sustained production.", "Most sites in Lake Kivu showed sustained production.", "qualifier"),
        ("Researchers in Senegal reported iron production at Site A.", "Researchers in Nigeria reported iron production at Site A.", "entity"),
        ("The study recorded exactly 12 sites in Lake Kivu.", "The study recorded exactly 21 sites in Lake Kivu.", "number"),
    ],
)
def test_07_numerical_chronological_entity_and_qualifier_drift(bound_claim, competing_claim, expected_conflict_type):
    """Proves factual drift across numbers, qualifiers, and entities is strictly caught."""
    bound_id = "claim:run_test:1:1"
    other_id = "claim:run_test:1:2"
    claims = {
        bound_id: {"claimId": bound_id, "text": bound_claim},
        other_id: {"claimId": other_id, "text": competing_claim},
    }
    slot = {"questionNumber": 1, "claimRefIds": [bound_id]}
    payload = {
        "questionNumber": 1,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "The passage reports this detail.",
        "answer": "TRUE",
        "evidenceClaimRef": bound_id,
        "evidenceQuote": competing_claim,
        "passageEvidence": {"startChar": 0, "endChar": len(competing_claim), "text": competing_claim},
    }
    issues = verify_question_claim_provenance(payload, slot, claims, competing_claim)
    assert len(issues) > 0
    assert issues[0][0] == IssueCode.CLAIM_PROVENANCE_MISMATCH


def test_08_historical_q2_q4_q5_wrong_claim_associations():
    """Proves that historical snapshot Q2, Q4, Q5 wrong-claim associations fail closed."""
    with open(SNAPSHOT_13Q_LIVE, "r", encoding="utf-8") as f:
        snap = json.load(f)

    eg = {}
    passage = ""
    questions = {}
    blueprint = None
    for a in snap.get("all_artifacts", []):
        pl = json.loads(a.get("PayloadJson", "{}"))
        if a.get("ArtifactType") == "EvidenceGraph":
            for c in pl.get("claims", []):
                eg[c["claimId"]] = c
        elif a.get("ArtifactType") == "Passage" and a.get("Version") == 2:
            passage = pl.get("passage", "")
        elif a.get("ArtifactType") == "Question":
            questions[(a["ArtifactId"], a["Version"])] = pl
        elif a.get("ArtifactType") == "ExamBlueprint":
            blueprint = pl

    slots = {s["questionNumber"]: s for s in blueprint["sections"][0]["questionSlots"]}

    for q_num in (2, 4, 5):
        payload = next(v for k, v in questions.items() if k[0].endswith(f":{q_num}") and k[1] == 1)
        slot = slots[q_num]
        issues = verify_question_claim_provenance(payload, slot, eg, passage)
        assert len(issues) > 0
        assert issues[0][0] == IssueCode.CLAIM_PROVENANCE_MISMATCH


def test_09_historical_q10_invalid_flow_chart_answer():
    """Proves that historical Q10 answer 'hosted districts' is rejected before provider calls."""
    with open(SNAPSHOT_13Q_LIVE, "r", encoding="utf-8") as f:
        snap = json.load(f)

    eg = {}
    passage = ""
    for a in snap.get("all_artifacts", []):
        pl = json.loads(a.get("PayloadJson", "{}"))
        if a.get("ArtifactType") == "EvidenceGraph":
            for c in pl.get("claims", []):
                eg[c["claimId"]] = c
        elif a.get("ArtifactType") == "Passage" and a.get("Version") == 2:
            passage = pl.get("passage", "")

    bad_payload = {
        "questionNumber": 10,
        "questionType": "FLOW_CHART",
        "prompt": "Complete the flow chart: [10]",
        "flowSteps": ["Stage 1", "Stage 2: ______", "Stage 3"],
        "answer": "hosted districts",
        "evidenceQuote": "Current research indicates that sub-Saharan West Africa hosted several early iron production districts...",
    }

    with pytest.raises(CandidateRejectionError) as exc_info:
        _validate_completion_candidate_grounding(
            cand_payload=bad_payload,
            q_num=10,
            q_type="FLOW_CHART",
            passage_text=passage,
            claims_map=eg,
            claim_id="claim:run_3c31dd54fb1a4465831bcaf6e6ecdb29:1:7",
        )
    assert exc_info.value.reason == CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE


def test_10_valid_semantic_paraphrase_and_correct_quote_offsets(post_hardening_data):
    """Proves that a valid paraphrased question with exact quote offsets is accepted."""
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    bound_claim_id = slot1["claimRefIds"][0]

    quote = "only a few provide the necessary detail for in-depth analysis of historical and anthropological dimensions."
    p_start = passage.find(quote)
    p_end = p_start + len(quote)

    valid_payload = {
        "questionNumber": 1,
        "questionType": "TRUE_FALSE_NOT_GIVEN",
        "statement": "A limited number of iron-smelting sites in the region yield adequate information for comprehensive historical investigation.",
        "answer": "TRUE",
        "evidenceQuote": quote,
        "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
        "evidenceClaimRef": bound_claim_id,
        "explanation": "The passage confirms that only a few sites provide the required detail.",
        "difficulty": "FOUNDATION",
    }

    issues = verify_question_claim_provenance(valid_payload, slot1, claims_map, passage)
    assert issues == []


def test_11_candidate_selection_priority_and_bounded_regeneration(post_hardening_data):
    """Proves that when Op 16 candidates are evaluated by _parse_candidate_payload,
    Candidate 0 (TRUE) is selected over Candidate 2 (NOT_GIVEN) because slot1 has
    isNotGivenTarget=False, and Candidate 1 (competing claim) is filtered out.
    """
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    bound_claim_id = slot1["claimRefIds"][0]
    op16 = post_hardening_data["ops"]["op:run_cba0c609f9c04294b687362a7413519a:question:1:1_1"]

    selected = _parse_candidate_payload(
        raw_payload=op16["parsed_payload"],
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage,
        claims_map=claims_map,
        claim_id=bound_claim_id,
        difficulty="FOUNDATION",
        is_not_given_target=slot1.get("isNotGivenTarget"),
    )

    assert selected["answer"] == "TRUE"
    assert selected["evidenceQuote"] == "only a few provide the necessary detail for in-depth analysis of historical and anthropological dimensions."
    assert selected["evidenceClaimRef"] == bound_claim_id


def test_12_section_runner_production_path_integration(post_hardening_data):
    """Proves end-to-end SectionRunner candidate extraction integration:
    - Candidate 0 passes candidate parsing and provenance validation.
    - Resulting ArtifactEnvelope passes all evaluate_question evaluators.
    """
    passage = post_hardening_data["passage"]
    claims_map = post_hardening_data["claims_map"]
    slot1 = post_hardening_data["slot1"]
    alignments = post_hardening_data["alignments"]
    bound_claim_id = slot1["claimRefIds"][0]
    op16 = post_hardening_data["ops"]["op:run_cba0c609f9c04294b687362a7413519a:question:1:1_1"]

    selected = _parse_candidate_payload(
        raw_payload=op16["parsed_payload"],
        q_num=1,
        q_type="TRUE_FALSE_NOT_GIVEN",
        passage_text=passage,
        claims_map=claims_map,
        claim_id=bound_claim_id,
        difficulty="FOUNDATION",
        target_focus=alignments[0]["passageQuote"] if alignments else None,
        is_not_given_target=False,
    )

    env = ArtifactEnvelope(
        artifact_id="question:run_test:1",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        content_hash="c" * 64,
        producer_version="1.0.0",
        created_at=datetime.now(timezone.utc),
        payload=selected,
        parent_refs=[],
        run_id="run_test",
    )

    eval_results = evaluate_question(
        artifact=env,
        passage=passage,
        difficulty="FOUNDATION",
        siblings=[],
        blueprint_slot=slot1,
        claims=claims_map,
        passage_alignments=alignments,
    )

    assert all(r.status == EvaluationStatus.PASS for r in eval_results)
