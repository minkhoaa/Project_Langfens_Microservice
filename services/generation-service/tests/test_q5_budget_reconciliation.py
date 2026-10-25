"""Local loop accounting must agree with durable provider usage, not phantom parents."""
from __future__ import annotations

import json
from pathlib import Path
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.persistence.models import OperationResumeInfo
from app.reading_policy import PinnedExecutionPolicy
from app.stage_executor import StageExecutor
from tests.test_hybrid_production_integration import (
    FencedTestCheckpointClient, make_parent_artifacts, make_production_run_context,
)

ROOT = Path(__file__).resolve().parents[3]


@pytest.mark.asyncio
async def test_stage_executor_reconciles_unparented_provider_usage_once():
    """Production generation callbacks had no parentOperationId; they still cost tokens."""
    class ReportedClient(FencedTestCheckpointClient):
        def save_draft_checkpoint(self, request):
            ack = super().save_draft_checkpoint(request)
            self.operations[request.operationId] = self.operations[request.operationId].model_copy(update={"accountingType": "REPORTED"})
            return ack
        def reconcile_operation(self, request):
            ack = super().reconcile_operation(request)
            self.operations[request.operationId] = self.operations[request.operationId].model_copy(update={"accountingType": request.accountingType})
            return ack
    client = ReportedClient("run_q5_accounting", 1, uuid4())
    passage, blueprint = make_parent_artifacts(client.run_id)
    client.add_accepted_artifact(passage)
    client.add_accepted_artifact(blueprint)
    ctx, _ = make_production_run_context(client.run_id, 1, client.active_lease_owner, client)
    art_id = f"question:{client.run_id}:5"
    async def generate(version):
        client.operations["provider_q5"] = OperationResumeInfo(
            operationId="provider_q5", operationType="PROVIDER_CALL", status="COMPLETED", artifactId=art_id,
            requestHash="a" * 64, tokenReservation=5759, tokensUsed=2442, accountingType="REPORTED",
            wallTimeReservationSeconds=60, wallTimeUsedSeconds=16,
        )
        return {"questionNumber": 5, "answer": "TRUE"}
    async def evaluate(art):
        return [EvaluationResult(evaluationId="eval_done", evaluatorId="offline", evaluatorVersion="1.0.0", targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.PASS, issues=[], score=1)]
    executor = StageExecutor(client, ctx, PinnedExecutionPolicy(provider="minimax"), required_evaluator_ids=("offline",))
    art = await executor.execute(art_id, ArtifactType.QUESTION, (passage.to_ref(), blueprint.to_ref()), generate, evaluate, section_id=1)
    cursor = json.loads(client.saved_cursors[-1].stateJson)
    assert cursor["budget"]["tokensUsed"] == 2442, [(o.operationId, o.status, o.tokensUsed, o.accountingType) for o in client.operations.values()]
    # Accepted replay must not redispatch generation/evaluation or create new charges.
    before = len(client.grants)
    assert (await executor.execute(art_id, ArtifactType.QUESTION, (passage.to_ref(), blueprint.to_ref()), generate, evaluate, section_id=1)).to_ref() == art.to_ref()
    assert len(client.grants) == before


@pytest.mark.asyncio
async def test_paid_evaluation_is_not_dispatched_before_its_loop_reservation():
    """A batched callback used to solve during the zero-token structure adapter."""
    client = FencedTestCheckpointClient("run_q5_deferred", 1, uuid4())
    passage, blueprint = make_parent_artifacts(client.run_id)
    client.add_accepted_artifact(passage)
    client.add_accepted_artifact(blueprint)
    ctx, _ = make_production_run_context(client.run_id, 1, client.active_lease_owner, client)
    paid_reservations_at_dispatch = []
    ids = ("eval_question_structure", "eval_blind_solver_adversary")
    async def generate(version):
        return {"questionNumber": 5}
    async def evaluate(art, *, evaluator_id=None):
        if evaluator_id is None or evaluator_id == "eval_blind_solver_adversary":
            paid_reservations_at_dispatch.append(any(g.operationType == "EVALUATE" and g.tokenReservation > 0 for g in client.grants))
        return [EvaluationResult(evaluationId=f"eval_{eid}", evaluatorId=eid, evaluatorVersion="1.0.0", targetRef=art.to_ref(), inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.PASS, issues=[], score=1) for eid in ids]
    executor = StageExecutor(client, ctx, PinnedExecutionPolicy(provider="minimax"), required_evaluator_ids=ids)
    await executor.execute(f"question:{client.run_id}:5", ArtifactType.QUESTION, (passage.to_ref(), blueprint.to_ref()), generate, evaluate, section_id=1)
    assert paid_reservations_at_dispatch == [True]


@pytest.mark.parametrize("accounting,status,used,expected", [
    ("REPORTED", "COMPLETED", 2000, 2000),
    ("RECONCILED", "COMPLETED", 2000, 2000),
    ("ESTIMATED", "COMPLETED", 2000, 7500),
    ("ESTIMATED", "COMPLETED", 0, 7500),
    ("UNKNOWN", "COMPLETED", 2000, 7500),
    ("", "COMPLETED", 2000, 7500),
    ("REPORTED", "UNKNOWN_OUTCOME", 2000, 7500),
    ("REPORTED", "COMPLETED", 0, 0),
    ("ESTIMATED", "COMPLETED", 8000, 8000),
])
def test_provider_charge_matches_durable_refund_authority(accounting, status, used, expected):
    """Estimated usage cannot create headroom that PostgreSQL does not refund."""
    from app.loop.runtime import BoundedLoopRuntime
    from app.loop.context import LoopContext, AuthorityGrant
    from app.loop.policy import LoopPolicy
    from app.contracts.issue import IssueScope
    client = FencedTestCheckpointClient("run_conservative_usage", 1, uuid4())
    art_id = f"question:{client.run_id}:5"
    client.operations["provider"] = OperationResumeInfo(
        operationId="provider", operationType="PROVIDER_CALL", status=status,
        artifactId=art_id, requestHash="a" * 64, tokenReservation=7500,
        tokensUsed=used, accountingType=accounting, wallTimeReservationSeconds=60,
        wallTimeUsedSeconds=1,
    )
    context = LoopContext(runId=client.run_id, targetArtifactId=art_id,
                          targetArtifactType=ArtifactType.QUESTION, scope=IssueScope.QUESTION,
                          authority=AuthorityGrant(leaseOwner=client.active_lease_owner, epoch=1))
    runtime = BoundedLoopRuntime(context=context, policy=LoopPolicy(), generator=None,
                                 evaluators=[], persistence_client=client)
    assert runtime._refresh_provider_token_accounting()
    assert context.budget_tracker.tokens_used == expected
    # Rebuilding in a fresh runtime must yield the same conservative headroom.
    context.budget_tracker.tokens_used = 0
    restarted = BoundedLoopRuntime(context=context, policy=LoopPolicy(), generator=None,
                                   evaluators=[], persistence_client=client)
    restarted._refresh_provider_token_accounting()
    assert context.budget_tracker.tokens_used == expected


def test_saved_q5_local_counter_rebuilds_from_durable_operations_without_refunding_unknown():
    """A restart must not preserve the old 60k phantom counter or double-charge parents."""
    from app.loop.runtime import BoundedLoopRuntime
    from app.loop.context import LoopContext, AuthorityGrant
    from app.loop.policy import LoopPolicy
    from app.contracts.issue import IssueScope
    data = json.loads((ROOT / "reports/q5_corrective_durable_accounting.json").read_text())
    art_id = f"question:{data['run']['RunId']}:5"
    client = FencedTestCheckpointClient(data["run"]["RunId"], 2, uuid4())
    for op in data["operations"]:
        if op["ArtifactId"] == art_id:
            fields = OperationResumeInfo.model_fields
            client.operations[op["OperationId"]] = OperationResumeInfo.model_validate({k[0].lower() + k[1:]: v for k, v in op.items() if v is not None and k[0].lower() + k[1:] in fields})
    context = LoopContext(runId=client.run_id, targetArtifactId=art_id, targetArtifactType=ArtifactType.QUESTION, scope=IssueScope.QUESTION, authority=AuthorityGrant(leaseOwner=client.active_lease_owner, epoch=2))
    runtime = BoundedLoopRuntime(context=context, policy=LoopPolicy(), generator=None, evaluators=[], persistence_client=client)
    context.budget_tracker.tokens_used = 60000
    assert runtime._refresh_provider_token_accounting()
    assert context.budget_tracker.tokens_used == 19973
    # Completed parent aggregates and their child usage count once.
    client.operations["aggregate"] = OperationResumeInfo(operationId="aggregate", operationType="EVALUATE", status="COMPLETED", artifactId=art_id, tokenReservation=10000, tokensUsed=500, accountingType="REPORTED", requestHash="b" * 64, wallTimeReservationSeconds=60, wallTimeUsedSeconds=1)
    client.operations["child"] = OperationResumeInfo(operationId="child", parentOperationId="aggregate", operationType="PROVIDER_CALL", status="COMPLETED", artifactId=art_id, tokenReservation=1000, tokensUsed=500, accountingType="REPORTED", requestHash="c" * 64, wallTimeReservationSeconds=60, wallTimeUsedSeconds=1)
    client.operations["unknown"] = OperationResumeInfo(operationId="unknown", operationType="PROVIDER_CALL", status="UNKNOWN_OUTCOME", artifactId=art_id, tokenReservation=7500, tokensUsed=0, accountingType="UNKNOWN", requestHash="d" * 64, wallTimeReservationSeconds=60, wallTimeUsedSeconds=0)
    runtime._refresh_provider_token_accounting()
    assert context.budget_tracker.tokens_used == 27973
