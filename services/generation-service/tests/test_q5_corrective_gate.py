"""Exact historical Q5 replay and the boundaries missed by earlier Hybrid doubles."""
from __future__ import annotations

import json
from pathlib import Path
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.issue import IssueCode
from app.contracts.solver import AdjudicationVerdict
from app.reading_evaluation import evaluate_question, verify_question_claim_provenance
from app.section_runner import _parse_candidate_payload, _parse_single_candidate
from app.solvers.adjudication import adjudicate_item
from app.solvers.adversary import parse_and_validate_adversary_output
from app.solvers.comparison import compare_answers
from app.solvers.serializer import build_blind_solver_input
from app.solvers.solver import parse_and_validate_solver_output

ROOT = Path(__file__).resolve().parents[3]
HISTORY = ROOT / "reports/hybrid_13q_post_hardening_2250820f-0ed9-42cb-80e8-70bcc38f2a7e.json"


@pytest.fixture(scope="module")
def history():
    snap = json.loads(HISTORY.read_text())
    arts = [(a, json.loads(a["PayloadJson"])) for a in snap["all_artifacts"]]
    passage = next(p["passage"] for a, p in arts if a["ArtifactType"] == "Passage")
    claims = next(p["claims"] for a, p in arts if a["ArtifactType"] == "EvidenceGraph")
    claims = {c["claimId"]: c for c in claims}
    slot = next(p for a, p in arts if a["ArtifactType"] == "ExamBlueprint")["sections"][0]["questionSlots"][4]
    ops = {o["OperationId"]: json.loads(o["ResultRefJson"]) for o in snap["operations"]["actual_db_operations"] if o["OperationType"] == "PROVIDER_CALL"}
    return snap, arts, passage, claims, slot, ops


def parse_candidate(history, version, index):
    snap, _, passage, claims, slot, ops = history
    raw = ops[f"op:{snap['run_id']}:question:5:1_{version}"]["parsed_payload"]
    parsed = _parse_single_candidate(raw["candidates"][index], raw, 5, slot["questionType"], passage, claims, slot["claimRefIds"][0], "FOUNDATION")
    return raw, parsed


@pytest.mark.parametrize("version", [1, 2, 3])
@pytest.mark.parametrize("index", [0, 1])
def test_q5_bound_positive_evidence_not_conflicted_by_bibliography(history, version, index):
    """Bibliographic authors must not masquerade as competing geographical facts."""
    _, parsed = parse_candidate(history, version, index)
    _, _, passage, claims, slot, _ = history
    assert verify_question_claim_provenance(parsed, slot, claims, passage) == []
    ev = parsed["passageEvidence"]
    assert passage[ev["startChar"]:ev["endChar"]] == ev["text"]
    assert "direct evidence for sustained production there remains limited" in ev["text"]


@pytest.mark.parametrize("version", [1, 2, 3])
def test_q5_positive_advisory_priority_and_true_only_pool(history, version):
    raw, _ = parse_candidate(history, version, 0)
    _, _, passage, claims, slot, _ = history
    args = (5, slot["questionType"], passage, claims, slot["claimRefIds"][0], "FOUNDATION")
    assert _parse_candidate_payload(raw, *args, is_not_given_target=False)["answer"] == "FALSE"
    only_true = {"candidates": [raw["candidates"][1], raw["candidates"][2]]}
    assert _parse_candidate_payload(only_true, *args, is_not_given_target=False)["answer"] == "TRUE"


@pytest.mark.parametrize("version", [1, 2, 3])
def test_q5_meta_presence_not_given_is_not_accepted_even_if_solver_agrees(history, version):
    _, parsed = parse_candidate(history, version, 2)
    snap, _, passage, claims, slot, _ = history
    art = ArtifactEnvelope.create("question:offline:5", ArtifactType.QUESTION, snap["run_id"], parsed, "test")
    results = evaluate_question(art, passage, "FOUNDATION", [], blueprint_slot=slot, claims=claims)
    semantic = next(e for e in results if e.evaluator_id == "eval_question_semantic")
    assert not semantic.is_pass()
    assert any(i.code == IssueCode.TFNG_BOUNDARY_CONFLICT for i in semantic.issues)


@pytest.mark.parametrize("version", [1, 2, 3])
def test_q5_adversary_topic_span_does_not_prove_alternative(history, version):
    _, parsed = parse_candidate(history, version, 2)
    snap, _, passage, _, _, ops = history
    raw = ops[f"op_adv_{snap['run_id']}_question:{snap['run_id']}:5_{version}"]["raw_text"]
    adv, errors, rejected = parse_and_validate_adversary_output(raw, passage, 5, student_question=build_blind_solver_input(passage, parsed).question)
    assert errors == []
    assert adv.is_ambiguous is False
    assert rejected  # Invalid TFNG labels / absence-as-contradiction are auditable, not silently trusted.


@pytest.mark.parametrize("version", [1, 2, 3])
def test_q5_solver_spans_are_exact_after_localization(history, version):
    snap, _, passage, _, slot, ops = history
    raw = ops[f"op_solve_{snap['run_id']}_question:{snap['run_id']}:5_{version}"]["raw_text"]
    solver, errors = parse_and_validate_solver_output(raw, passage, 5, slot["questionType"])
    if solver is None:
        assert errors  # V2/V3 invented quotations remain non-pass.
    else:
        assert not errors
        for span in solver.cited_spans:
            assert passage[span.start_char:span.end_char] == span.span_text


@pytest.mark.parametrize(
    ("statement", "answer", "passage", "ambiguous"),
    [
        # A lexical non-match is unresolved, not proof an independent review is invalid.
        ("Nsukka furnaces used charcoal.", "FALSE", "Nsukka was a centre for early ironworking.", True),
        ("The furnace dates to 600 BCE.", "FALSE", "The furnace dates to 700 BCE.", True),
        ("The furnace dates to 600 BCE.", "TRUE", "The furnace dates to 600 BCE.", True),
        ("The furnace dates to 600 BCE.", "a topic description", "The furnace dates to 600 BCE.", False),
    ],
)
def test_tfng_alternatives_require_proposition_level_evidence(statement, answer, passage, ambiguous):
    from app.contracts.solver import StudentVisibleQuestion
    raw = {"questionNumber": 1, "isAmbiguous": True, "identifiedAlternatives": [{
        "alternativeAnswer": answer, "reasoning": "Review against the cited passage sentence.",
        "plausibilityScore": .9, "isGroundedInPassage": True,
        "citedSpans": [{"spanText": passage, "startChar": 0, "endChar": len(passage)}],
    }]}
    adv, errors, rejected = parse_and_validate_adversary_output(raw, passage, 1, student_question=StudentVisibleQuestion(question_number=1, question_type="TRUE_FALSE_NOT_GIVEN", prompt=statement))
    assert not errors
    assert adv.is_ambiguous == ambiguous
    assert bool(rejected) != ambiguous


def test_genuine_conflicting_tfng_evidence_remains_blocking():
    from app.contracts.solver import StudentVisibleQuestion
    passage = "The furnace dates to 600 BCE. The furnace dates to 700 BCE."
    question = StudentVisibleQuestion(question_number=1, question_type="TRUE_FALSE_NOT_GIVEN", prompt="The furnace dates to 600 BCE.")
    raw = {"isAmbiguous": True, "identifiedAlternatives": [{"alternativeAnswer": "FALSE", "plausibilityScore": .9,
        "reasoning": "The passage gives conflicting dates for the same furnace.", "citedSpans": [{"spanText": "The furnace dates to 700 BCE."}]}]}
    adv, _, _ = parse_and_validate_adversary_output(raw, passage, 1, student_question=question)
    adj = adjudicate_item(compare_answers("TRUE", "TRUE", question.question_type, 1), adv, passage, student_question=question)
    assert adj.verdict == AdjudicationVerdict.AMBIGUOUS_DEFECTIVE


@pytest.mark.asyncio
async def test_numeric_parent_scope_reaches_typed_m3_and_text01_transport():
    """Real grant authority compares exact section strings, unlike earlier doubles."""
    from tests.test_hybrid_production_integration import (
        FencedTestCheckpointClient, RecordingHybridIntegrationProvider,
        make_production_question_artifact, make_production_run_context,
    )
    from app.persistence.client import CheckpointApiError
    from app.persistence.models import OperationGrantRequest
    from app.providers.gateway import ProviderGateway, RetryPolicy
    from app.providers.registry import ProviderRegistry
    from app.contracts.issue import Issue, IssueScope, IssueSeverity
    from app.repair.question import QuestionItemRepairer

    class ExactScopeClient(FencedTestCheckpointClient):
        def grant_operation(self, request):
            if request.parentOperationId:
                parent = next(g for g in self.grants if g.operationId == request.parentOperationId)
                if request.sectionId != parent.sectionId:
                    raise CheckpointApiError(422, "Parent operation belongs to section '1', child requested another section")
            return super().grant_operation(request)

    client = ExactScopeClient("run_q5_scope", 1, uuid4())
    provider = RecordingHybridIntegrationProvider()
    registry = ProviderRegistry()
    registry.register_provider(provider, keys=["offline"])
    gateway = ProviderGateway(registry=registry, checkpoint_client=client, retry_policy=RetryPolicy(max_attempts=1))
    ctx, _ = make_production_run_context(client.run_id, 1, client.active_lease_owner, client, gateway)
    client.grant_operation(OperationGrantRequest(runId=ctx.run_id, epoch=1, leaseOwner=ctx.lease_owner, operationId="repair_numeric", operationType="REPAIR", requestHash="f" * 64, tokenReservation=15000, wallTimeReservationSeconds=60, sectionId="1"))
    art = make_production_question_artifact(ctx.run_id)
    issue = Issue(code=IssueCode.AMBIGUOUS_ANSWER, severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION, message="Question 2 lacks a century anchor", affected_refs=[art.to_ref()])
    repaired = await QuestionItemRepairer(gateway=gateway).repair(ctx, art, [issue], "repair_numeric", 2)
    assert repaired.version == 2
    assert "14th century" in repaired.payload["prompt"]
    assert repaired.payload["answer"] == art.payload["answer"]
    assert repaired.payload["evidenceClaimRef"] == art.payload["evidenceClaimRef"]
    assert [r.pinned_model for r in provider.dispatched_requests] == ["MiniMax-M3", "MiniMax-Text-01"]
    assert all(g.sectionId == "1" for g in client.grants)
