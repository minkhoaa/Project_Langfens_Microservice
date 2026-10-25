"""Offline regressions: callback failures cannot authorize blind redispatch."""
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.persistence.models import OperationResumeInfo
from app.reading_policy import PinnedExecutionPolicy
from app.stage_executor import StageExecutor, StageExecutorError
from tests.test_hybrid_production_integration import (
    FencedTestCheckpointClient, make_parent_artifacts, make_production_run_context,
)


def setup_stage():
    client = FencedTestCheckpointClient("run_callback_recovery", 1, uuid4())
    passage, blueprint = make_parent_artifacts(client.run_id)
    for parent in (passage, blueprint):
        client.add_accepted_artifact(parent)
    ctx, _ = make_production_run_context(client.run_id, 1, client.active_lease_owner, client)
    executor = StageExecutor(client, ctx, PinnedExecutionPolicy(provider="minimax"),
                             required_evaluator_ids=("eval_question_semantic",))
    return client, executor, (passage.to_ref(), blueprint.to_ref())


def evaluation(art):
    return [EvaluationResult(
        evaluationId=f"eval_v{art.version}", evaluatorId="eval_question_semantic",
        evaluatorVersion="1.0.0", targetRef=art.to_ref(),
        inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.FAIL,
        score=0.0, issues=[Issue.create(
            f"issue_v{art.version}", IssueCode.AMBIGUOUS_ANSWER, IssueSeverity.CRITICAL,
            IssueScope.QUESTION, "Competing factual answers", affected_refs=[art.to_ref()],
            evaluator_id="eval_question_semantic",
        )],
    )]


@pytest.mark.asyncio
@pytest.mark.parametrize("accepts_intent", [True, False])
async def test_repair_body_type_error_does_not_repeat_callback(accepts_intent):
    """Removing pre-call signature inspection must cause a duplicate side effect."""
    client, executor, parents = setup_stage()
    attempts = []
    async def generate(version):
        return {"questionNumber": 5, "statement": f"Draft {version}"}
    async def evaluate(art):
        return evaluation(art)
    async def modern(art, issues, version, *, intent_id=None):
        attempts.append(intent_id)
        raise TypeError("provider result parser failed after dispatch")
    async def legacy(art, issues, version):
        attempts.append("legacy")
        raise TypeError("provider result parser failed after dispatch")
    with pytest.raises(StageExecutorError):
        await executor.execute(f"question:{client.run_id}:5", ArtifactType.QUESTION,
                               parents, generate, evaluate, section_id=1,
                               repair=modern if accepts_intent else legacy)
    assert len(attempts) == 1, "A TypeError inside repair is not a signature mismatch"
    if accepts_intent:
        assert attempts[0].startswith("loop:")


@pytest.mark.asyncio
@pytest.mark.parametrize("status", ["UNKNOWN_OUTCOME", "RESERVED"])
async def test_unknown_provider_after_generation_blocks_evaluation_and_commit(status):
    """A locally returned artifact cannot hide an unresolved paid operation."""
    client, executor, parents = setup_stage()
    art_id = f"question:{client.run_id}:5"
    evaluated = []
    async def generate(version):
        client.operations["provider_unknown"] = OperationResumeInfo(
            operationId="provider_unknown", operationType="PROVIDER_CALL", status=status,
            artifactId=art_id, requestHash="a" * 64, tokenReservation=7500,
            tokensUsed=0, accountingType="UNKNOWN", wallTimeReservationSeconds=60,
            wallTimeUsedSeconds=0,
        )
        return {"questionNumber": 5, "statement": "Returned draft"}
    async def evaluate(art):
        evaluated.append(art.to_ref())
        return [e.model_copy(update={"status": EvaluationStatus.PASS, "issues": [], "score": 1.0})
                for e in evaluation(art)]
    with pytest.raises(StageExecutorError, match="UNKNOWN_OUTCOME"):
        await executor.execute(art_id, ArtifactType.QUESTION, parents, generate, evaluate, section_id=1)
    assert evaluated == []
    assert art_id not in client.heads
    assert client.operations["provider_unknown"].status == status
    # The rejected parent must not erase the unknown child's reservation.
    assert client.operations["provider_unknown"].tokenReservation == 7500
    # Child reconciliation alone cannot invent the missing wrapper result or
    # authorize replay. Operator reconciliation must also dispose of that parent.
    client.operations["provider_unknown"] = client.operations["provider_unknown"].model_copy(
        update={"status": "COMPLETED", "tokensUsed": 2000, "accountingType": "RECONCILED"})
    from app.stage_executor import UnresolvedProviderOutcomeError
    restarted = StageExecutor(client, executor.context, executor.policy,
                              required_evaluator_ids=("eval_question_semantic",))
    async def refuse_redispatch(version):
        pytest.fail("Provider reconciliation alone must not replay generation")
    with pytest.raises(UnresolvedProviderOutcomeError):
        await restarted.execute(art_id, ArtifactType.QUESTION, parents,
                                refuse_redispatch, evaluate, section_id=1)


@pytest.mark.asyncio
@pytest.mark.parametrize("boundary", ["repair", "evaluate"])
async def test_unknown_after_callback_stops_before_regeneration_or_acceptance(boundary):
    """Catching a repair exception or receiving PASS must not hide paid uncertainty."""
    client, executor, parents = setup_stage()
    art_id = f"question:{client.run_id}:5"
    generations = []
    def record_unknown():
        client.operations["provider_unknown"] = OperationResumeInfo(
            operationId="provider_unknown", operationType="PROVIDER_CALL",
            status="UNKNOWN_OUTCOME", artifactId=art_id, requestHash="a" * 64,
            tokenReservation=7500, tokensUsed=0, accountingType="UNKNOWN",
            wallTimeReservationSeconds=60, wallTimeUsedSeconds=0,
        )
    async def generate(version):
        generations.append(version)
        return {"questionNumber": 5, "statement": f"Draft {version}"}
    async def evaluate(art):
        result = evaluation(art)
        if boundary == "evaluate":
            record_unknown()
            return [result[0].model_copy(update={"status": EvaluationStatus.PASS,
                                                "issues": [], "score": 1.0})]
        return result
    async def repair(art, issues, version, *, intent_id=None):
        record_unknown()
        raise RuntimeError("transport response lost")
    with pytest.raises(StageExecutorError, match="UNKNOWN_OUTCOME"):
        await executor.execute(art_id, ArtifactType.QUESTION, parents, generate, evaluate,
                               section_id=1, repair=repair)
    assert generations == [1]
    assert art_id not in client.heads
    parent_type = "REPAIR" if boundary == "repair" else "EVALUATE"
    parent = next(o for o in client.operations.values() if o.operationType == parent_type)
    assert parent.status == "RESERVED", "Uncertain work must not be reconciled to free zero usage"


@pytest.mark.asyncio
async def test_unrelated_unknown_provider_does_not_block_independent_artifact():
    """The uncertainty fence is artifact-local, not an accidental whole-run cap."""
    client, executor, parents = setup_stage()
    client.operations["unrelated_unknown"] = OperationResumeInfo(
        operationId="unrelated_unknown", operationType="PROVIDER_CALL",
        status="UNKNOWN_OUTCOME", artifactId=f"question:{client.run_id}:99",
        requestHash="a" * 64, tokenReservation=7500, tokensUsed=0,
        accountingType="UNKNOWN", wallTimeReservationSeconds=60, wallTimeUsedSeconds=0,
    )
    async def generate(version):
        return {"questionNumber": 5}
    async def evaluate(art):
        return [evaluation(art)[0].model_copy(update={"status": EvaluationStatus.PASS,
                                                    "issues": [], "score": 1.0})]
    accepted = await executor.execute(f"question:{client.run_id}:5", ArtifactType.QUESTION,
                                      parents, generate, evaluate, section_id=1)
    assert accepted.version == 1
