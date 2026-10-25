"""Offline regressions for operation authority and immutable student stimuli."""
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.generators.question.generator import QuestionCandidateGenerator
from app.blueprint.claim_binding import bind_claims_to_slots, check_claim_eligibility_for_family, score_claim_suitability_for_family
from app.repair.question import QuestionItemRepairer
from app.stage_executor import StageExecutor
from app.reading_policy import PinnedExecutionPolicy
from tests.test_hybrid_production_integration import FencedTestCheckpointClient, make_parent_artifacts, make_production_run_context


@pytest.mark.asyncio
async def test_stage_callbacks_receive_own_authorized_parent_not_outer_context():
    client = FencedTestCheckpointClient("run_operation_authority", 1, uuid4())
    passage, blueprint = make_parent_artifacts(client.run_id)
    for parent in (passage, blueprint):
        client.add_accepted_artifact(parent)
    ctx, _ = make_production_run_context(client.run_id, 1, client.active_lease_owner, client)
    executor = StageExecutor(client, ctx, PinnedExecutionPolicy(provider="minimax"),
                             required_evaluator_ids=("eval_blind_solver_adversary",))
    observed = []
    async def generate(version, *, operation_context=None):
        observed.append(("GENERATE", operation_context))
        return {"questionNumber": 5, "statement": "Iron production was sustained."}
    async def evaluate(art, *, evaluator_id=None, operation_context=None):
        observed.append(("EVALUATE", operation_context))
        return [EvaluationResult(evaluationId="blind_pass", evaluatorId=evaluator_id,
            evaluatorVersion="1.0.0", targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs),
            status=EvaluationStatus.PASS, score=1.0)]
    accepted = await executor.execute(f"question:{client.run_id}:5", ArtifactType.QUESTION,
        (passage.to_ref(), blueprint.to_ref()), generate, evaluate, section_id=1)
    assert accepted.version == 1
    assert len(observed) == 2
    for kind, authority in observed:
        assert authority is not None, f"{kind} callback lost operation authority"
        parent = client.operations[authority.parent_operation_id]
        assert parent.operationType == kind
        assert authority.run_id == client.run_id
        assert authority.epoch == 1
        assert authority.lease_owner == client.active_lease_owner
    evaluation_grant = next(g for g in client.grants if g.operationType == "EVALUATE")
    # The existing pinned profile, not an invented/global cap, authorizes 10k.
    assert evaluation_grant.tokenReservation == 10000
    assert getattr(ctx, "parent_operation_id", None) is None


STIMULI = [
    ("TABLE_COMPLETION", {"tableContext": "Furnace inputs", "rowHeader": "Fuel", "colHeader": "Material"}),
    ("FLOW_CHART", {"flowSteps": ["Collect ore", "Heat using [10]"], "stepIndex": 0}),
]


@pytest.mark.parametrize("family,stimulus", STIMULI)
def test_question_core_hash_covers_all_student_stimulus_fields(family, stimulus):
    from app.reading_evaluation import question_core, question_digest
    payload = {"questionNumber": 10, "questionType": family, "prompt": "Fuel: [10]", "answer": "charcoal", **stimulus}
    core = question_core(payload)
    for key, value in stimulus.items():
        assert core.get(key) == value
        replacement = ["Changed step"] if isinstance(value, list) else 1 if isinstance(value, int) else "Changed context"
        assert question_digest({**payload, key: replacement}) != question_digest(payload)


@pytest.mark.parametrize("family,stimulus", STIMULI)
def test_provider_pool_roundtrip_retains_student_stimulus(family, stimulus):
    passage, blueprint = make_parent_artifacts("run_stimulus")
    raw = {"prompt": "The furnace uses ______.", "answer": "charcoal",
           "evidenceQuote": "The furnace uses charcoal.", **stimulus}
    pool = QuestionCandidateGenerator().build_pool_from_raw_candidates(
        [raw], "The furnace uses charcoal.", family, 10, passage.to_ref(), blueprint.to_ref())
    serialized = pool.candidates[0].model_dump(mode="json", by_alias=True)
    for key, value in stimulus.items():
        assert serialized.get(key) == value


@pytest.mark.asyncio
@pytest.mark.parametrize("family,stimulus", STIMULI)
@pytest.mark.parametrize("replace_stimulus", [True, False])
async def test_repair_replaces_or_preserves_stimulus_without_mutating_prior_version(family, stimulus, replace_stimulus):
    old = {key: (["Old step"] if isinstance(val, list) else 1 if isinstance(val, int) else "Old label")
           for key, val in stimulus.items()}
    candidate = {"prompt": "A furnace requires ______.", "answer": "charcoal",
                 "evidenceQuote": "The furnace uses charcoal."}
    if replace_stimulus:
        candidate.update(stimulus)
    payload = {"questionNumber": 10, "questionType": family, "prompt": "Old ______.",
               "answer": "ore", "passage": "The furnace uses charcoal.", "candidates": [candidate], **old}
    art = ArtifactEnvelope.create("question:run_stimulus:10", ArtifactType.QUESTION, "run_stimulus", payload, "test", section_id=1)
    original_hash = art.content_hash
    issue = Issue.create("schema", IssueCode.SCHEMA_VIOLATION, IssueSeverity.CRITICAL,
                         IssueScope.QUESTION, "Question 10 malformed", affected_refs=[art.to_ref()])
    repaired = await QuestionItemRepairer(enable_hybrid=False)._repair_impl(None, art, [issue], "repair_stimulus", 2)
    for key, value in (stimulus if replace_stimulus else old).items():
        actual = repaired.payload.get(key)
        assert list(actual) == value if isinstance(value, list) else actual == value
    assert repaired.version == 2
    assert art.content_hash == original_hash
    assert art.payload["prompt"] == "Old ______."


@pytest.mark.parametrize("family", ["TABLE_COMPLETION", "FLOW_CHART", "TRUE_FALSE_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE"])
@pytest.mark.parametrize("text", [
    ", Alpern, 2005 ; Holl, 2009 ; Killick, 2004 ; Robion-Brunner, 2018 ), which we will not revisit here.",
    "(Okafor, 2002; Holl, 2009).", "References", "We will discuss these references later.",
])
def test_bibliography_and_nonfactual_claims_cannot_bind_any_family(family, text):
    claim = {"claimId": "claim:run_stimulus:1:6", "text": text}
    assert not check_claim_eligibility_for_family(claim, family, 1)
    assert score_claim_suitability_for_family(claim, family, 1) <= 0


@pytest.mark.parametrize("text", ["The furnace operated in Nsukka in 2002.",
    "Iron production there remained limited (Okafor, 2002).", "Ore is heated with charcoal to produce iron."])
def test_substantive_claims_with_dates_or_citations_remain_eligible(text):
    assert check_claim_eligibility_for_family({"claimId": "claim:run_stimulus:1:7", "text": text}, "TABLE_COMPLETION", 1)


def test_new_q7_blueprint_binding_excludes_saved_claim6_without_rewriting_history():
    from app.contracts.blueprint import QuestionSlot
    claims = [
        {"claimId": "claim:run_stimulus:1:6", "text": ", Alpern, 2005 ; Holl, 2009 ; Killick, 2004 ; Robion-Brunner, 2018 ), which we will not revisit here."},
        {"claimId": "claim:run_stimulus:1:14", "text": "The furnace used charcoal to heat iron ore to 1200 degrees."},
    ]
    slot = QuestionSlot(questionNumber=7, sectionId=1, groupIndex=1, questionType="TABLE_COMPLETION",
                        targetSkill="Identify furnace fuel", targetDifficulty={"level": "FOUNDATION", "rationale": "Explicit fact"},
                        claimRefIds=["claim:run_stimulus:1:6"])
    rebound = bind_claims_to_slots([slot], claims, 1, "new_graph", "run_stimulus")
    assert rebound[0].claim_ref_ids == ["claim:run_stimulus:1:14"]
    assert slot.claim_ref_ids == ["claim:run_stimulus:1:6"]
    with pytest.raises(ValueError, match="no eligible verified claims"):
        bind_claims_to_slots([slot], claims[:1], 1, "citation_only_graph", "run_stimulus")


@pytest.mark.asyncio
async def test_known_failed_repair_crash_restarts_at_fallback_without_repair_redispatch():
    class PowerLoss(BaseException):
        pass
    class CrashClient(FencedTestCheckpointClient):
        crash = True
        def reconcile_operation(self, request):
            ack = super().reconcile_operation(request)
            if self.operations[request.operationId].operationType == "EVALUATE" and request.resultRefJson:
                self.evaluations.append(EvaluationResult.model_validate_json(request.resultRefJson))
            if self.operations[request.operationId].operationType == "REPAIR" and self.crash:
                self.crash = False
                raise PowerLoss("after known failure committed, before fallback cursor")
            return ack
    client = CrashClient("run_known_failure_restart", 1, uuid4())
    passage, blueprint = make_parent_artifacts(client.run_id)
    for parent in (passage, blueprint):
        client.add_accepted_artifact(parent)
    ctx, _ = make_production_run_context(client.run_id, 1, client.active_lease_owner, client)
    policy = PinnedExecutionPolicy(provider="minimax")
    attempts = []
    async def generate(version):
        return {"questionNumber": 5, "prompt": f"Fact version {version}", "answer": "TRUE"}
    async def evaluate(art):
        return [EvaluationResult(evaluationId=f"semantic_{art.version}", evaluatorId="eval_question_semantic",
            evaluatorVersion="1.0.0", targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs),
            status=EvaluationStatus.PASS if art.version > 1 else EvaluationStatus.FAIL,
            score=1.0 if art.version > 1 else 0.0,
            issues=[] if art.version > 1 else [Issue.create("ambiguity", IssueCode.AMBIGUOUS_ANSWER,
                IssueSeverity.CRITICAL, IssueScope.QUESTION, "Question 5 is ambiguous", affected_refs=[art.to_ref()],
                evaluator_id="eval_question_semantic")])]
    async def repair(art, issues, version, *, intent_id=None):
        from app.repair.base import RepairJustificationError
        attempts.append(intent_id)
        raise RepairJustificationError("No grounded correction")
    async def execute():
        return await StageExecutor(client, ctx, policy, required_evaluator_ids=("eval_question_semantic",)).execute(
            f"question:{client.run_id}:5", ArtifactType.QUESTION, (passage.to_ref(), blueprint.to_ref()),
            generate, evaluate, section_id=1, repair=repair)
    with pytest.raises(PowerLoss):
        await execute()
    accepted = await execute()
    assert accepted.version == 2
    assert len(attempts) == 1
    assert len([g for g in client.grants if g.operationType == "REPAIR"]) == 1
