"""Opt-in PostgreSQL/HTTP/current-pipeline integration; no live model claims.

Invoked by the exact Section1PostgresPipelineTests .NET filter, which owns the
isolated host. Each generation phase is a fresh process; the crash is after a
real durable question commit but before its ACK reaches the loop.
"""
from __future__ import annotations

import asyncio
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
from urllib.parse import urlsplit
from uuid import uuid4

import httpx
import pytest

from app.config import Settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, canonical_json_dump
from app.contracts.blueprint import ExamBlueprint, QuestionType, compute_canonical_blueprint_hash
from app.contracts.policies import count_words
from app.persistence.client import CheckpointClient
from app.pipeline import ReadingGenerationPipeline
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability
from app.providers.registry import ProviderRegistry
from app.reading_models import PipelineRequest
from app.reading_policy import GroupConfig, PinnedExecutionPolicy
from app.stage_executor import StageExecutor
from tests.test_section1_target_offline import COMPLETIONS, TargetTransport
from tests.unified.mock_fixtures import SECTION_1_SOURCE_TEXT, create_source_inputs

# Same independently authored 13 tasks/answers as the offline fixture. Explicitly
# name the four laboratory/construction processes, so full-pipeline blueprint
# eligibility (which also examines evidence) is exercised without bypassing it.
PROCESS_SOURCE_TEXT = SECTION_1_SOURCE_TEXT
for old, new in (
    ("Dendrochronological dating of oak piles", "During the dating process, dendrochronological dating of oak piles"),
    ("The construction of these causeways required", "The construction process for these causeways required"),
    ("Heavy oxygen isotope ratios preserved", "During the reconstruction process, heavy oxygen isotope ratios preserved"),
    ("Furthermore, trace element geochemical signatures", "During the analytical process, trace element geochemical signatures"),
):
    assert old in PROCESS_SOURCE_TEXT
    PROCESS_SOURCE_TEXT = PROCESS_SOURCE_TEXT.replace(old, new)


def fixture(path, data=None):
    url = os.environ["SECTION1_FIXTURE_URL"]
    with httpx.Client(trust_env=False, timeout=60) as client:
        response = client.request("GET" if data is None else "POST", url + path,
            headers={"X-Internal-Service-Key": os.environ["SECTION1_FIXTURE_KEY"]}, json=data)
        response.raise_for_status()
        return response.json() if response.content else None


def deny_non_fixture_network():
    """Fail before any external connect, including accidental live provider use."""
    endpoint = urlsplit(os.environ["SECTION1_FIXTURE_URL"])
    assert endpoint.hostname == "127.0.0.1"
    original = socket.socket.connect
    def connect(sock, address):
        if not isinstance(address, tuple) or address[:2] != ("127.0.0.1", endpoint.port):
            raise AssertionError(f"Network destination outside isolated fixture: {address}")
        return original(sock, address)
    socket.socket.connect = connect


class CrashAfterQuestionAckClient(CheckpointClient):
    def __init__(self, crash=None):
        super().__init__(os.environ["SECTION1_FIXTURE_URL"], os.environ["SECTION1_FIXTURE_KEY"])
        self.crash = crash
        assert self.base_url == os.environ["SECTION1_FIXTURE_URL"]
        assert self.internal_api_key == os.environ["SECTION1_FIXTURE_KEY"]

    def commit_checkpoint(self, request):
        ack = super().commit_checkpoint(request)
        if self.crash == "crash" and request.artifact.artifact_id.endswith(":5") and request.artifact.artifact_type == ArtifactType.QUESTION:
            print("FAULT: question 5 committed by HTTP authority; exiting before loop ACK", flush=True)
            os._exit(86)
        if self.crash == "crash-finalization" and request.artifact.artifact_type == ArtifactType.SECTION:
            print("FAULT: Section committed by HTTP authority; exiting before finalization ACK", flush=True)
            os._exit(90)
        return ack

    async def reconcile_operation_async(self, request):
        ack = await super().reconcile_operation_async(request)
        if self.crash in ("crash-generation", "crash-evaluation", "crash-repair"):
            state = self.resume_state(request.runId)
            operations = {op.operationId: op for op in state.operations}
            physical = operations[request.operationId]
            parent = operations.get(physical.parentOperationId)
            required = {"crash-generation": "GENERATE", "crash-evaluation": "EVALUATE", "crash-repair": "REPAIR"}[self.crash]
            if (physical.operationType == "PROVIDER_CALL" and parent is not None
                and parent.artifactId.endswith(":5") and parent.operationType == required):
                # Evaluation has two child calls. Crash only after all known
                # authoritative solver/adversary outcomes are durably available.
                children = [op for op in state.operations if op.parentOperationId == parent.operationId]
                if required == "GENERATE" or len(children) == 2:
                    print(f"FAULT: {required} provider outcomes committed; wrapper still RESERVED", flush=True)
                    os._exit({"GENERATE": 88, "EVALUATE": 89, "REPAIR": 91}[required])
        return ack


class AuthoredBlueprintExecutor(StageExecutor):
    """Only author deterministic fixture inputs, before normal validators/commit."""
    async def execute(self, artifact_id, artifact_type, parents, generate, evaluate, **kwargs):
        if artifact_type == ArtifactType.EXAM_BLUEPRINT:
            original = generate
            async def generate(version):
                payload = await original(version)
                state = self.client.resume_state(self.context.run_id)
                evidence = next(ArtifactEnvelope.model_validate_json(a.envelopeJson) for a in state.artifacts
                    if a.artifactType == ArtifactType.EVIDENCE_GRAPH)
                for slot in payload["sections"][0]["questionSlots"]:
                    slot["claimRefIds"] = [evidence.payload["claims"][slot["questionNumber"] - 1]["claimId"]]
                    slot["isNotGivenTarget"] = slot["questionNumber"] == 3
                payload["contentHash"] = compute_canonical_blueprint_hash(ExamBlueprint.model_validate(payload))
                return payload
        return await super().execute(artifact_id, artifact_type, parents, generate, evaluate, **kwargs)


class DurableTargetTransport(TargetTransport):
    def __init__(self, client, run, scenario):
        super().__init__([], scenario)
        self.client, self.run = client, run
        self.ledger = Path(os.environ["SECTION1_FIXTURE_EVIDENCE"]) / f"{run}-transport.jsonl"

    async def call(self, request, api_key, deadline):
        if not self.claims:
            state = self.client.resume_state(self.run)
            evidence = next(ArtifactEnvelope.model_validate_json(a.envelopeJson) for a in state.artifacts
                if a.artifactType == ArtifactType.EVIDENCE_GRAPH)
            self.claims = evidence.payload["claims"]
        with self.ledger.open("a") as stream:
            stream.write(json.dumps({"pid": os.getpid(), "operation": request.operation_id,
                "artifact": request.artifact_id, "capability": request.capability.value}) + "\n")
            stream.flush()
            os.fsync(stream.fileno())
        if self.scenario == "unknown" and request.capability == Capability.SOLVE_ITEM:
            from app.providers.errors import TimeoutError
            raise TimeoutError("Scripted unknown outcome after dispatch; do not replay")
        repair_case = os.environ.get("SECTION1_FIXTURE_CRASH_BOUNDARY") == "repair"
        if repair_case and request.capability == Capability.PLAN_REPAIR:
            from app.providers.models import ProviderResponse, UsageReport
            details = json.loads(request.messages[-1].content.split("\n\n", 1)[1])
            data = {"issueCode": details["detectedIssues"][0]["code"], "targetQuestion": 5,
                "repairAction": "REPHRASE_STEM", "diagnosis": "Replace the meta-textual assertion with the cited factual proposition.",
                "repairConstraints": ["Test the factual content of the bound claim, not what the passage discusses."],
                "preserveEvidenceClaimRef": details["authoritativeClaimRef"]}
            self.requests.append(request)
            response = ProviderResponse(operation_id=request.operation_id, provider_name=self.name, model_name="offline-scripted-m3",
                raw_text=json.dumps(data), parsed_payload=data,
                usage=UsageReport(total_tokens=1000, accounting_type="reported"), latency_seconds=0.01)
        else:
            fixture_request = request
            if repair_case and request.capability == Capability.GENERATE_JSON and request.artifact_id.startswith("questions_section_"):
                # The production repair generator still owns a legacy group scope;
                # the scripted response is selected from its explicit question task.
                fixture_request = request.model_copy(update={"artifact_id": f"question:{self.run}:5"})
            response = await super().call(fixture_request, api_key, deadline)
        if repair_case and request.capability == Capability.GENERATE_JSON and request.artifact_id.endswith(":5"):
            state = self.client.resume_state(self.run)
            parent = next(op for op in state.operations if op.operationId == request.parent_operation_id)
            if parent.operationType == "GENERATE":
                data = dict(response.parsed_payload)
                candidate = dict(data["candidates"][0])
                candidate["prompt"] = "The passage discusses " + self.claims[4]["text"].lower()
                data["candidates"] = [candidate]
                response = response.model_copy(update={"parsed_payload": data, "raw_text": json.dumps(data)})
        if request.artifact_id.startswith("passage:"):
            payload = dict(response.parsed_payload, passage=PROCESS_SOURCE_TEXT)
            response = response.model_copy(update={"parsed_payload": payload, "raw_text": json.dumps(payload)})
        return response


class RecordingGateway(ProviderGateway):
    async def execute(self, request, **kwargs):
        path = Path(os.environ["SECTION1_FIXTURE_EVIDENCE"]) / f"{request.run_id}-requests.jsonl"
        with path.open("a") as stream:
            stream.write(json.dumps({"operation": request.operation_id, "messages": [m.model_dump(mode="json") for m in request.messages]}) + "\n")
        return await super().execute(request, **kwargs)


async def generation_phase(run, mode):
    deny_non_fixture_network()
    client = CrashAfterQuestionAckClient(crash=mode if mode.startswith("crash") else None)
    state = client.resume_state(run)
    assert state.isCompatible, state.incompatibilityReason
    request = PipelineRequest.model_validate(fixture(f"/fixture/request/{run}"))
    pinned = json.loads(state.budgetProfileJson)
    assert pinned["executionPolicyHash"] == request.policy.hash == state.policyHash
    assert PinnedExecutionPolicy.model_validate(pinned["executionPolicy"]).hash == request.policy.hash
    transport = DurableTargetTransport(client, run, mode)
    registry = ProviderRegistry()
    registry.register_provider(transport, keys=["offline-not-a-provider-key"])
    gateway = RecordingGateway(registry=registry, checkpoint_client=client)
    pipeline = ReadingGenerationPipeline(client, gateway, executor_factory=lambda context, policy, **kw:
        AuthoredBlueprintExecutor(client, context, policy, **kw))
    try:
        result = await pipeline.execute(request)
    except Exception:
        if mode not in ("unknown", "budget"):
            raise
        state = client.resume_state(run)
        assert not any(a.artifactType == ArtifactType.SECTION for a in state.artifacts)
        print(f"EXPECTED_FAIL_CLOSED {mode}", flush=True)
        return
    assert mode not in ("unknown", "budget"), f"Negative unexpectedly finalized: {mode}"
    assert len(result.sections) == 1
    assert result.sections[0].verify_integrity()
    print(f"PHASE_OK {mode} pid={os.getpid()} transport_calls={len(transport.requests)}", flush=True)


def provision():
    run = "section1_fixture_" + uuid4().hex
    base = PinnedExecutionPolicy(provider="minimax", blueprint_mode="legacy_preset")
    config = base.section(1).model_copy(update={"groups": (
        GroupConfig(questionType=QuestionType.TRUE_FALSE_NOT_GIVEN, count=5),
        GroupConfig(questionType=QuestionType.TABLE_COMPLETION, count=4),
        GroupConfig(questionType=QuestionType.FLOW_CHART, count=4))})
    policy = base.model_copy(update={"sections": (config,)})
    request = PipelineRequest(runId=run, jobId=uuid4(), epoch=1, leaseOwner=uuid4(), topic="Wetland Research",
        sources=(create_source_inputs()[0].model_copy(update={"content": PROCESS_SOURCE_TEXT}),),
        sectionIndices=(1,), policy=policy, finalize=False)
    # Use the approved shared production profile, not Settings' smaller defaults
    # or ad-hoc cap overrides. The host disables credential .env loading only.
    settings = Settings()
    profile = settings.loop_caps_profile_json
    fixture("/fixture/provision", {"request": request.model_dump(mode="json", by_alias=True),
        "capProfileJson": profile, "capProfileSha256": hashlib.sha256(profile.encode()).hexdigest()})
    client = CrashAfterQuestionAckClient()
    state = client.resume_state(run)
    assert state.isCompatible and state.policyHash == policy.hash
    assert not state.artifacts and not state.operations and not state.loopCursors
    return request


def child(run, mode, expected=0):
    completed = subprocess.run([sys.executable, __file__, "phase", run, mode],
        text=True, capture_output=True, timeout=480)
    print(completed.stdout, end="", flush=True)
    print(completed.stderr, end="", flush=True)
    assert completed.returncode == expected, f"phase {mode}: exit {completed.returncode}, expected {expected}"


def ledger(run):
    path = Path(os.environ["SECTION1_FIXTURE_EVIDENCE"]) / f"{run}-transport.jsonl"
    return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []


def verify_completed(run):
    client = CrashAfterQuestionAckClient()
    state = client.resume_state(run)
    snapshot = fixture(f"/fixture/snapshot/{run}")
    envelopes = [ArtifactEnvelope.model_validate_json(a.envelopeJson) for a in state.artifacts]
    assert all(a.verify_integrity() for a in envelopes)
    passage = next(a for a in envelopes if a.artifact_type == ArtifactType.PASSAGE)
    section = next(a for a in envelopes if a.artifact_type == ArtifactType.SECTION)
    questions = sorted((a for a in envelopes if a.artifact_type == ArtifactType.QUESTION), key=lambda a: a.payload["questionNumber"])
    assert len(questions) == 13
    assert 720 <= count_words(passage.payload["passage"]) <= 915
    section_questions = [q for g in section.payload["groups"] for q in g["questions"]]
    assert [q["questionNumber"] for q in section_questions] == list(range(1, 14))
    refs = {a.to_ref() for a in envelopes}
    assert all(parent in refs for a in envelopes for parent in a.parent_refs)
    assert all(q.to_ref() in section.parent_refs for q in questions)
    mandatory = {"eval_question_structure", "eval_answer_verbatim_length", "eval_evidence_offsets",
        "eval_question_uniqueness", "eval_question_semantic", "eval_blind_solver_adversary"}
    for number, question in enumerate(questions, 1):
        evals = [e for e in state.evaluations if e.target_ref == question.to_ref()]
        assert {e.evaluator_id for e in evals} == mandatory
        assert all(e.is_pass() for e in evals)
        for field in ("tableContext", "rowHeader", "colHeader", "flowSteps", "stepIndex"):
            assert section_questions[number - 1].get(field) == question.payload.get(field)
        cursor = next(c for c in snapshot["cursors"] if c["artifactId"] == question.artifact_id)
        budget = json.loads(cursor["stateJson"])["budget"]
        repaired = os.environ.get("SECTION1_FIXTURE_CRASH_BOUNDARY") == "repair" and number == 5
        expected_tokens, expected_calls = (7182, 5) if repaired else (5182, 3)
        assert budget["tokensUsed"] == expected_tokens and budget["callsUsed"] == expected_calls, budget
        if repaired:
            assert question.version == 2 and budget["repairsUsed"] == 1
        if number >= 10:
            assert question.payload["flowSteps"][1] == COMPLETIONS[number][2]
            assert question.payload["stepIndex"] == 1
        elif number >= 6:
            assert question.payload["rowHeader"] == COMPLETIONS[number][0]
            assert question.payload["colHeader"] == COMPLETIONS[number][1]
    calls = ledger(run)
    extra = 2 if os.environ.get("SECTION1_FIXTURE_CRASH_BOUNDARY") == "repair" else 0
    assert len(calls) == 40 + extra and len({c["operation"] for c in calls}) == 40 + extra
    operations = {op["operationId"]: op for op in snapshot["operations"]}
    # Resume wire data must preserve durable attribution for accounting/fencing.
    for resumed in state.operations:
        durable = operations[resumed.operationId]
        assert resumed.parentOperationId == durable["parentOperationId"], resumed.operationId
        assert resumed.sectionId == durable["sectionId"], resumed.operationId
    caps = json.loads(state.budgetProfileJson)["caps"]
    for allocation in snapshot["allocations"]:
        if allocation["scopeType"] == "SECTION":
            prefix = "legacySection"
        else:
            family = allocation["scopeId"].split("_")[0]
            prefix = "legacyArtifact" + family.title()
        assert allocation["tokenCap"] == caps[prefix + "TokenCap"], allocation
        assert allocation["callCap"] == caps[prefix + "CallCap"], allocation
        assert allocation["wallTimeCapSeconds"] == caps[prefix + "WallTimeCapSeconds"], allocation
    assert all(op["status"] == "COMPLETED" for op in operations.values())
    for call in calls:
        op = operations[call["operation"]]
        assert op["operationType"] == "PROVIDER_CALL" and op["accountingType"] == "REPORTED"
        parent = operations[op["parentOperationId"]]
        expected = "EVALUATE" if call["capability"] in ("solve_item", "evaluate_item") else "GENERATE"
        if call["capability"] == "plan_repair" or (extra and parent["operationType"] == "REPAIR"):
            expected = "REPAIR"
        assert parent["operationType"] == expected
        assert op["sectionId"] == parent["sectionId"] == "1"
    assert snapshot["run"]["budgetUsedCalls"] == 40 + extra
    assert snapshot["run"]["budgetUsedTokens"] == 1000 + 13 * 5182 + extra * 1000
    return snapshot


def negative_authority(request):
    run = request.run_id
    base = {"runId": run, "epoch": request.epoch, "leaseOwner": str(request.lease_owner),
        "operationId": "fixture-evaluate", "operationType": "EVALUATE", "requestHash": "fixture-hash",
        "tokenReservation": 10000, "wallTimeReservationSeconds": 60, "sectionId": "1", "artifactId": f"question:{run}:1"}
    endpoint = "/api/internal/reading-paper/checkpoints/"
    fixture(endpoint + "grant-operation", base)
    physical = dict(base, operationId="fixture-solve", operationType="PROVIDER_CALL", tokenReservation=7369,
        parentOperationId="fixture-evaluate")
    fixture(endpoint + "grant-operation", physical)
    fixture(endpoint + "unknown-outcome", {"runId": run, "epoch": 1, "leaseOwner": str(request.lease_owner),
        "operationId": "fixture-solve", "errorMessage": "scripted uncertain dispatch"})
    # Fresh real client sees durable UNKNOWN; grant replay cannot authorize redispatch.
    replay = fixture(endpoint + "grant-operation", physical)
    assert replay["isReplay"] and replay["status"] == "UNKNOWN_OUTCOME"
    before = fixture(f"/fixture/snapshot/{run}")
    assert before["run"]["budgetUsedTokens"] == 7369 and before["run"]["budgetUsedCalls"] == 1
    with pytest.raises(httpx.HTTPStatusError) as blocked:
        fixture(endpoint + "grant-operation", dict(physical, operationId="fixture-adversary", tokenReservation=7504, wallTimeReservationSeconds=1))
    assert blocked.value.response.status_code == 422
    assert fixture(f"/fixture/snapshot/{run}") == before
    takeover = fixture(f"/fixture/takeover/{run}", {})
    after = fixture(f"/fixture/snapshot/{run}")
    assert takeover["epoch"] == 2 and takeover["leaseOwner"] != str(request.lease_owner)
    for path, data in [
        ("grant-operation", dict(physical, operationId="stale-owner")),
        ("operations/reconcile", {"runId": run, "epoch": 1, "leaseOwner": str(request.lease_owner), "operationId": "fixture-solve", "tokensUsed": 0, "wallTimeUsedSeconds": 0, "accountingType": "REPORTED"}),
        ("unknown-outcome", {"runId": run, "epoch": 1, "leaseOwner": str(request.lease_owner), "operationId": "fixture-solve", "errorMessage": "stale"}),
    ]:
        with pytest.raises(httpx.HTTPStatusError) as fenced:
            fixture(endpoint + path, data)
        assert fenced.value.response.status_code == 409
        assert fixture(f"/fixture/snapshot/{run}") == after
    assert not after["heads"]
    print("NEGATIVE_OK durable_unknown_reservation legitimate_takeover stale_grant_reconcile_unknown", flush=True)


def run_section1_postgres_pipeline():
    # This driver is executed by the isolated .NET integration gate, not collected
    # as an optional pytest case whose missing prerequisites could look green.
    assert "SECTION1_FIXTURE_URL" in os.environ, "Exact isolated .NET test host required"
    deny_non_fixture_network()
    output = Path(os.environ["SECTION1_FIXTURE_EVIDENCE"])
    if os.environ.get("SECTION1_FIXTURE_RESTART_VERIFY") == "1":
        receipt = json.loads((output / "acceptance.json").read_text())
        run = receipt["run_id"]
        os.environ["SECTION1_FIXTURE_CRASH_BOUNDARY"] = receipt["crash_boundary"]
        before = fixture(f"/fixture/snapshot/{run}")
        (output / "restart-before.json").write_text(json.dumps(before, indent=2))
        assert before == json.loads((output / "positive-final.json").read_text())
        verify_completed(run)
        child(run, "reentry")
        assert fixture(f"/fixture/snapshot/{run}") == before
        assert len(ledger(run)) == receipt["physical_calls"]
        (output / "restart-verification.json").write_text(json.dumps({"run_id": run, "heads_unchanged": True,
            "physical_calls": receipt["physical_calls"], "fresh_host_pid": os.getppid(), "fresh_driver_pid": os.getpid()}, indent=2))
        print("RESTART_OK fresh exam host and generation process; identical durable state; zero new work", flush=True)
        return
    request = provision()
    run = request.run_id
    boundary = os.environ.get("SECTION1_FIXTURE_CRASH_BOUNDARY", "accepted")
    modes = {"accepted": ("crash", 86), "generation": ("crash-generation", 88),
        "evaluation": ("crash-evaluation", 89), "repair": ("crash-repair", 91), "finalization": ("crash-finalization", 90)}
    mode, exit_code = modes[boundary]
    child(run, mode, expected=exit_code)
    pre_restart = fixture(f"/fixture/snapshot/{run}")
    accepted = {h["artifactId"]: (h["acceptedVersion"], h["acceptedHash"]) for h in pre_restart["heads"]}
    accepted_count = 4 if boundary in ("generation", "evaluation", "repair") else 5
    assert all(f"question:{run}:{n}" in accepted for n in range(1, accepted_count + 1))
    assert (f"section:{run}:1" in accepted) == (boundary == "finalization")
    prior_calls = ledger(run)
    child(run, "complete")
    final = verify_completed(run)
    heads = {h["artifactId"]: (h["acceptedVersion"], h["acceptedHash"]) for h in final["heads"]}
    assert all(heads[k] == value for k, value in accepted.items())
    assert not any(c["artifact"] in {f"question:{run}:{n}" for n in range(1, accepted_count + 1)} for c in ledger(run)[len(prior_calls):])
    child(run, "reentry")
    assert fixture(f"/fixture/snapshot/{run}") == final
    expected_calls = 42 if boundary == "repair" else 40
    assert len(ledger(run)) == expected_calls
    output = Path(os.environ["SECTION1_FIXTURE_EVIDENCE"])
    (output / "positive-before-restart.json").write_text(json.dumps(pre_restart, indent=2))
    (output / "positive-final.json").write_text(json.dumps(final, indent=2))
    (output / "acceptance.json").write_text(json.dumps({"run_id": run, "accepted_questions": 13,
        "mandatory_evaluator_passes": 78, "physical_calls": expected_calls, "crash_boundary": boundary,
        "mode": "SCRIPTED_TRANSPORT_POSTGRES_HTTP_REAL_PIPELINE"}, indent=2))
    negative_authority(provision())
    for scenario in ("budget", "unknown"):
        bad = provision()
        child(bad.run_id, scenario)
        before = fixture(f"/fixture/snapshot/{bad.run_id}")
        assert not any(h["artifactId"] == f"section:{bad.run_id}:1" for h in before["heads"])
        if scenario == "unknown":
            assert any(op["status"] == "UNKNOWN_OUTCOME" for op in before["operations"])
            count = len(ledger(bad.run_id))
            child(bad.run_id, scenario)
            assert len(ledger(bad.run_id)) == count
        (output / f"negative-{scenario}.json").write_text(json.dumps(before, indent=2))
    print(f"ACCEPTANCE_OK run={run} 13Q {expected_calls} physical calls; {boundary} crash, reentry, budget, unknown, fencing", flush=True)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "phase":
        asyncio.run(generation_phase(sys.argv[2], sys.argv[3]))
    else:
        run_section1_postgres_pipeline()
