"""A known provider response can rebuild its wrapper only under replay-only dispatch."""
import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.providers.base import BaseProvider
from app.providers.errors import ProviderError
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest, ProviderResponse, UsageReport
from app.providers.registry import ProviderRegistry
from app.stage_executor import StageExecutor, StageExecutorError
from tests.test_reading_stage_executor import Authority, Crash, evaluation


class Transport(BaseProvider):
    def __init__(self):
        super().__init__("fixture", "https://fixture.invalid", {"large": "fixture"})
        self.calls = []

    async def check_health(self, api_key):
        return True

    async def call(self, request, api_key, deadline):
        self.calls.append(request.operation_id)
        return ProviderResponse(operation_id=request.operation_id, provider_name=self.name, model_name="fixture",
            raw_text='{"text":"authoritative response"}', parsed_payload={"text": "authoritative response"},
            usage=UsageReport(total_tokens=100, accounting_type="reported"), latency_seconds=0.01)


@pytest.mark.asyncio
@pytest.mark.parametrize("boundary", ["GENERATE", "EVALUATE", "REPAIR"])
@pytest.mark.parametrize("recovery", ["known", "new-call", "swallowed-new-call", "missing-response", "unknown"])
async def test_orphan_wrapper_recovery_is_read_only_and_fail_closed(boundary, recovery):
    class Store(Authority):
        should_crash = True

        def reconcile_operation(self, request):
            ack = super().reconcile_operation(request)
            op = self.operations[request.operationId]
            parent = self.operations.get(op.parentOperationId)
            if self.should_crash and op.operationType == "PROVIDER_CALL" and parent.operationType == boundary:
                self.should_crash = False
                raise Crash()
            return ack

    store = Store()
    transport = Transport()
    registry = ProviderRegistry()
    registry.register_provider(transport, keys=["offline-fixture-key"])
    gateway = ProviderGateway(registry=registry, checkpoint_client=store)
    resumed = False

    async def call(context, name):
        operation = context.parent_operation_id + ":" + name
        if resumed and recovery in ("new-call", "swallowed-new-call"):
            operation += ":uncommitted"
        request = ProviderRequest(capability=Capability.GENERATE_JSON,
            messages=[ChatMessage(role="user", content="Read the authoritative fixture response")],
            run_id=store.context.run_id, artifact_id="passage", section_id="1",
            parent_operation_id=context.parent_operation_id, operation_id=operation,
            pinned_provider="fixture", pinned_model="fixture", max_tokens=128,
            wall_time_reservation_seconds=1)
        try:
            return await gateway.execute(request, epoch=1, lease_owner=store.context.lease_owner)
        except ProviderError:
            if recovery != "swallowed-new-call":
                raise
            return ProviderResponse(operation_id=operation, provider_name="fixture", model_name="fixture",
                raw_text='{"text":"swallowed failure"}', parsed_payload={"text": "swallowed failure"},
                usage=UsageReport(total_tokens=0, accounting_type="reported"))

    async def generate(version, *, operation_context):
        if boundary == "GENERATE":
            response = await call(operation_context, "generate")
            return dict(response.parsed_payload)
        return {"text": "flawed" if boundary == "REPAIR" else "initial"}

    async def evaluate(artifact, *, operation_context):
        if boundary == "EVALUATE":
            await call(operation_context, "evaluate")
        result = evaluation(artifact)
        if boundary == "REPAIR" and artifact.version == 1:
            issue = Issue.create("fixture-failure", IssueCode.AMBIGUOUS_ANSWER, IssueSeverity.CRITICAL,
                IssueScope.PASSAGE, "Ambiguous passage fixture", affected_refs=[artifact.to_ref()], evaluator_id="required")
            result = result.model_copy(update={"status": EvaluationStatus.FAIL, "issues": [issue]})
        return [result]

    async def repair(artifact, issues, version, *, operation_context):
        response = await call(operation_context, "repair")
        return dict(response.parsed_payload)

    async def run():
        return await store.executor().execute("passage", ArtifactType.PASSAGE, (), generate, evaluate,
            section_id=1, repair=repair if boundary == "REPAIR" else None)

    with pytest.raises(Crash):
        await run()
    physical = next(op for op in store.operations.values() if op.operationType == "PROVIDER_CALL")
    assert physical.status == "COMPLETED" and physical.resultRefJson
    parent = store.operations[physical.parentOperationId]
    assert parent.status == "RESERVED" and parent.operationType == boundary
    operations_before = set(store.operations)
    if recovery == "missing-response":
        store.operations[physical.operationId] = physical.model_copy(update={"resultRefJson": None})
    elif recovery == "unknown":
        store.operations[physical.operationId] = physical.model_copy(update={"status": "UNKNOWN_OUTCOME"})
    resumed = True
    if recovery == "known":
        accepted = await run()
        assert accepted.version == (2 if boundary == "REPAIR" else 1)
        assert all(op.status == "COMPLETED" for op in store.operations.values())
        assert await run() == accepted
    else:
        with pytest.raises(StageExecutorError):
            await run()
        assert store.heads == {}
        assert set(store.operations) == operations_before, "Recovery cannot allocate new provider work"
        assert store.operations[parent.operationId].status == "RESERVED"
    assert transport.calls == [physical.operationId], "Never redispatch known or possibly-paid work"
