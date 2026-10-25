"""Target-family offline acceptance. Scripted transport is not provider quality evidence.

Runs real SectionRunner, StageExecutor, gateway and validators. Persistence here
is an enforcing in-memory contract double; PostgreSQL grants are tested in .NET.
Blind responses are authored separately, never derived from generated keys.
"""
import json
import re
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.blueprint import QuestionType
from app.contracts.policies import count_words
from app.persistence.client import CheckpointApiError
from app.providers.models import Capability, ProviderResponse, UsageReport
from app.providers.registry import ProviderRegistry
from app.providers.gateway import ProviderGateway
from app.reading_generation import build_blueprint, build_evidence, prepare_source
from app.reading_evaluation import evaluate_blueprint, evaluate_evidence, evaluate_source
from app.reading_models import RunContext, SourceRef
from app.reading_policy import PinnedExecutionPolicy, GroupConfig
from app.section_runner import SectionRunner
from app.stage_executor import StageExecutor
from tests.unified.mock_fixtures import InMemoryCheckpointClient, MockProvider, SECTION_1_SOURCE_TEXT, create_source_inputs


class EnforcingStore(InMemoryCheckpointClient):
    def grant_operation(self, request):
        self.fence(request)
        if request.operationId not in self.operations and request.parentOperationId:
            parent = self.operations.get(request.parentOperationId)
            if not parent or parent.status != "RESERVED" or parent.sectionId != request.sectionId:
                raise CheckpointApiError(422, "Missing exact RESERVED parent/section")
            children = [o for o in self.operations.values() if o.parentOperationId == parent.operationId]
            tokens = sum(o.tokensUsed if o.status == "COMPLETED" and o.accountingType in ("REPORTED", "RECONCILED")
                         else max(o.tokensUsed, o.tokenReservation) for o in children)
            wall = sum(o.wallTimeUsedSeconds if o.status == "COMPLETED" else o.wallTimeReservationSeconds for o in children)
            if tokens + request.tokenReservation > parent.tokenReservation or wall + request.wallTimeReservationSeconds > parent.wallTimeReservationSeconds:
                raise CheckpointApiError(422, "Parent reservation exceeded")
        ack = super().grant_operation(request)
        if not ack.isReplay:
            self.operations[request.operationId] = self.operations[request.operationId].model_copy(update={
                "parentOperationId": request.parentOperationId, "sectionId": request.sectionId})
        return ack

    def reconcile_operation(self, request):
        ack = super().reconcile_operation(request)
        self.operations[request.operationId] = self.operations[request.operationId].model_copy(update={"accountingType": request.accountingType.upper()})
        return ack

    def save_draft_checkpoint(self, request):
        ack = super().save_draft_checkpoint(request)
        # Match SaveDraftCheckpointAsync: wrapper usage is known, while physical
        # descendants retain their own reported/estimated/unknown accounting.
        op = self.operations[request.operationId]
        self.operations[request.operationId] = op.model_copy(update={"accountingType": "REPORTED"})
        return ack

    def commit_checkpoint(self, request):
        ack = super().commit_checkpoint(request)
        op = self.operations[request.operationId]
        self.operations[request.operationId] = op.model_copy(update={"accountingType": "REPORTED"})
        return ack


# Independently authored student tasks and blind answers. No generated-key lookup.
COMPLETIONS = {
    6: ("Fine deposits", "Composition", "Fine [6] alternated with coarser mineral grains.", "organic silt"),
    7: ("Water-sluicing", "Purpose", "Controlled sluicing prevented [7].", "soil salinization"),
    8: ("Pollen sampling", "Location", "Samples came from adjacent [8].", "peat cores"),
    9: ("Lipid residues", "Product", "Ruminant [9] were indicated by isotope values.", "dairy products"),
    10: ("", "", "Take wood samples from [10] piles supporting trackways.", "oak"),
    11: ("", "", "Extract timber from mature upland [11] woodlands.", "deciduous"),
    12: ("", "", "Measure heavy [12] isotope ratios in subfossil cellulose.", "oxygen"),
    13: ("", "", "Analyze hearth clays using portable [13] fluorescence.", "X-ray"),
}


class TargetTransport(MockProvider):
    def __init__(self, claims, scenario=None):
        super().__init__(name="minimax")
        self.claims = claims
        self.scenario = scenario
        self.blind_requests = []

    def conservative_token_reservation(self, request):
        if self.scenario == "budget" and request.capability == Capability.SOLVE_ITEM:
            return 10001
        return 7504 if request.capability == Capability.EVALUATE_ITEM else 7369 if request.capability == Capability.SOLVE_ITEM else 5759

    async def call(self, request, api_key, deadline):
        self.requests.append(request)
        text = request.messages[-1].content
        if request.capability in (Capability.SOLVE_ITEM, Capability.EVALUATE_ITEM):
            self.blind_requests.append(request)
            match = re.search(r'(?:question_number="|<question_number>)(\d+)', text)
            number = int(match.group(1))
            if request.capability == Capability.SOLVE_ITEM:
                data = {"questionNumber": number, "normalizedAnswer": {1: "TRUE", 2: "FALSE", 3: "NOT_GIVEN", 4: "TRUE", 5: "TRUE"}[number] if number <= 5 else COMPLETIONS[number][3],
                        "justification": "The factual statement or requested term is explicitly supported by the cited sentence.",
                        "citedSpans": [{"spanText": self.claims[number-1]["text"]}]}
            else:
                data = {"questionNumber": number, "isAmbiguous": False, "identifiedAlternatives": [],
                        "adversarySummary": "No alternative answer is supported by this task and passage."}
        elif request.artifact_id.startswith("passage:"):
            data = {"title": "Wetland Agricultural Investigations", "passage": SECTION_1_SOURCE_TEXT}
        else:
            number = int(request.artifact_id.rsplit(":", 1)[-1])
            quote = self.claims[number-1]["text"]
            candidate = {"prompt": quote, "answer": "TRUE", "evidenceQuote": quote,
                         "explanation": "The quoted sentence explicitly establishes the requested factual detail."}
            if number == 2:
                candidate.update(prompt="Radiocarbon determinations from waterlogged sediment strata do not indicate continuous occupation spanning the middle to late Bronze Age.", answer="FALSE")
            elif number == 3:
                candidate.update(prompt="The lakeside storage pits were financed by merchant guilds.", answer="NOT_GIVEN",
                    absenceAssessment={"assessmentId": "offline_absence_q3", "claimOrTopic": "Financing of storage pits",
                        "absenceReason": "The passage describes the storage pits but supplies no information about their financing or merchant guilds.",
                        "topicalContextSpan": quote, "absenceConfirmed": True})
                candidate.pop("evidenceQuote")
            if number >= 6:
                row, col, prompt, answer = COMPLETIONS[number]
                candidate.update(prompt=prompt, answer=answer)
                if number <= 9:
                    candidate.update(tableContext="Wetland research: samples and findings", rowHeader=row, colHeader=col)
                else:
                    candidate.update(flowSteps=["Collect the relevant archaeological sample", prompt, "Record the resulting measurement"], stepIndex=1)
            if number == 6 and self.scenario == "malformed_stimulus":
                candidate.update(tableContext="", rowHeader="", colHeader="")
            if number == 6 and self.scenario == "missing_evidence":
                candidate.pop("evidenceQuote")
            data = {"candidates": [candidate]}
        if self.scenario == "ambiguity" and request.capability == Capability.SOLVE_ITEM:
            data["normalizedAnswer"] = "FALSE"  # independent disagreement, never relabel the generated key
        usage = 1923 if request.capability == Capability.SOLVE_ITEM else 2259 if request.capability == Capability.EVALUATE_ITEM else 1000
        return ProviderResponse(operation_id=request.operation_id, provider_name=self.name, model_name="offline-scripted",
            raw_text=json.dumps(data), parsed_payload=data, usage=UsageReport(total_tokens=usage, accounting_type="reported"), latency_seconds=0.01)


async def run_target_section(scenario=None):
    run = "run_offline_target_section1"
    base = PinnedExecutionPolicy(provider="minimax", blueprint_mode="legacy_preset")
    config = base.section(1).model_copy(update={"groups": (
        GroupConfig(questionType=QuestionType.TRUE_FALSE_NOT_GIVEN, count=5),
        GroupConfig(questionType=QuestionType.TABLE_COMPLETION, count=4),
        GroupConfig(questionType=QuestionType.FLOW_CHART, count=4))})
    policy = base.model_copy(update={"sections": (config,)})
    store = EnforcingStore(policy_hash=policy.hash)
    store.init_run(run, policy_hash=policy.hash)
    ctx = RunContext(runId=run, jobId=store.default_job_id, epoch=1, leaseOwner=store.default_lease_owner, policyHash=policy.hash, client=store)
    executor = StageExecutor(store, ctx, policy)
    source_input = create_source_inputs()[0]
    async def source_gen(ver):
        return await prepare_source(source_input, run, policy)
    async def source_eval(art):
        return evaluate_source(art, policy)
    source = await executor.execute(f"source:{run}:1", ArtifactType.SOURCE_PACK, (), source_gen, source_eval, section_id=1)
    async def evidence_gen(ver):
        return build_evidence(source, run, 1, policy)
    async def evidence_eval(art):
        return evaluate_evidence(art, {source.payload["sources"][0]["sourceId"]: SECTION_1_SOURCE_TEXT}, policy.min_verified_claims)
    evidence = await executor.execute(f"evidence:{run}:1", ArtifactType.EVIDENCE_GRAPH, (source.to_ref(),), evidence_gen, evidence_eval, section_id=1)
    async def blueprint_gen(ver):
        payload = build_blueprint(run, "Wetland Research", (1,), {1: source}, {1: evidence}, policy)
        # Author a new immutable target fixture, never rewrite a historical graph/head.
        for slot in payload["sections"][0]["questionSlots"]:
            slot["claimRefIds"] = [evidence.payload["claims"][slot["questionNumber"]-1]["claimId"]]
            slot["isNotGivenTarget"] = slot["questionNumber"] == 3
        from app.contracts.blueprint import ExamBlueprint, compute_canonical_blueprint_hash
        bp = ExamBlueprint.model_validate(payload)
        payload["contentHash"] = compute_canonical_blueprint_hash(bp)
        return payload
    async def blueprint_eval(art):
        return evaluate_blueprint(art, policy, (1,))
    blueprint = await executor.execute(f"blueprint:{run}", ArtifactType.EXAM_BLUEPRINT, (evidence.to_ref(),), blueprint_gen, blueprint_eval)
    transport = TargetTransport(evidence.payload["claims"], scenario)
    registry = ProviderRegistry()
    registry.register_provider(transport, keys=["offline-no-live"])
    gateway = ProviderGateway(registry=registry, checkpoint_client=store)
    runner = SectionRunner(store, gateway)
    try:
        result = await runner.run(ctx, config, SourceRef(source=source, evidence=evidence), blueprint.to_ref(), policy)
    except Exception:
        assert (run, f"section:{run}:1") not in store.heads
        raise
    return run, store, transport, result, runner, ctx, config, source, evidence, blueprint, policy


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", ["budget", "malformed_stimulus", "missing_evidence", "ambiguity"])
async def test_target_section1_negative_cases_never_finalize(scenario):
    from app.stage_executor import StageExecutorError
    with pytest.raises(StageExecutorError):
        await run_target_section(scenario)


@pytest.mark.asyncio
async def test_target_section1_finalizes_13_hash_bound_heads_with_all_mandatory_passes():
    run, store, transport, result, runner, ctx, config, source, evidence, blueprint, policy = await run_target_section()
    assert len(result.questions) == 13
    assert 720 <= count_words(result.passage.payload["passage"]) <= 915
    assert result.section.verify_integrity()
    section_questions = [q for group in result.section.payload["groups"] for q in group["questions"]]
    assert [q["questionNumber"] for q in section_questions] == list(range(1, 14))
    for number, question in enumerate(result.questions, 1):
        assert question.verify_integrity()
        assert store.heads[(run, question.artifact_id)].to_ref() == question.to_ref()
        evaluations = [e for e in store.evaluations if e.target_ref == question.to_ref()]
        assert {e.evaluator_id for e in evaluations} == {"eval_question_structure", "eval_answer_verbatim_length", "eval_evidence_offsets", "eval_question_uniqueness", "eval_question_semantic", "eval_blind_solver_adversary"}
        assert all(e.is_pass() for e in evaluations)
        for field in ("tableContext", "rowHeader", "colHeader", "flowSteps", "stepIndex"):
            assert section_questions[number-1].get(field) == question.payload.get(field)
        budget = json.loads(store.cursors[(run, question.artifact_id)].stateJson)["budget"]
        assert budget["tokensUsed"] == 5182  # 1000 generate + 1923 solve + 2259 adversary
        assert budget["callsUsed"] == 3  # wrappers are not physical calls
        if number >= 10:
            assert list(question.payload["flowSteps"])[1] == COMPLETIONS[number][2]
            assert question.payload["stepIndex"] == 1
        elif number >= 6:
            assert question.payload["rowHeader"] == COMPLETIONS[number][0]
            assert question.payload["colHeader"] == COMPLETIONS[number][1]
    assert len(transport.requests) == 40  # passage + 13 * (generate + solve + adversary)
    for request in transport.requests:
        op = store.operations[request.operation_id]
        assert op.status == "COMPLETED"
        assert op.parentOperationId in store.operations
        parent = store.operations[op.parentOperationId]
        assert parent.operationType == ("EVALUATE" if request in transport.blind_requests else "GENERATE")
    assert all(o.status == "COMPLETED" for o in store.operations.values())
    assert store.heads[(run, result.section.artifact_id)].to_ref() == result.section.to_ref()
    # Resume the accepted section through production orchestration: no new paid work.
    resumed = await runner.run(ctx, config, SourceRef(source=source, evidence=evidence), blueprint.to_ref(), policy)
    assert resumed.section.to_ref() == result.section.to_ref()
    assert len(transport.requests) == 40
