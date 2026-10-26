"""Terminal evaluator outcomes survive cursor loss without rerunning work."""
import json

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from tests.test_reading_stage_executor import Authority, Crash, evaluation, execute


@pytest.mark.asyncio
async def test_terminal_evaluation_without_separate_row_recovers_exactly_once():
    store = Authority()
    store.crash_commit = True
    calls = []

    async def evaluate(artifact):
        calls.append(artifact.to_ref())
        return [evaluation(artifact)]

    with pytest.raises(Crash):
        await execute(store, evaluate=evaluate)
    assert store.evaluations == []  # terminal result exists only in the operation
    before = tuple(store.operations)
    accepted = await execute(store, evaluate=evaluate)
    assert calls == [accepted.to_ref()]
    assert tuple(store.operations) == before
    assert len(store.commits) == 1
    assert all(op.status == "COMPLETED" for op in store.operations.values())
    assert await execute(store, evaluate=evaluate) == accepted
    assert calls == [accepted.to_ref()]
    assert len(store.commits) == 1


@pytest.mark.asyncio
@pytest.mark.parametrize("corruption", ["missing", "malformed", "hash", "evaluator", "version", "parents", "conflict"])
async def test_terminal_evaluation_corruption_never_replays_or_accepts(corruption):
    store = Authority()
    store.crash_commit = True
    with pytest.raises(Crash):
        await execute(store)
    operation = next(op for op in store.operations.values() if op.operationType == "EVALUATE")
    result = json.loads(operation.resultRefJson)
    if corruption == "missing":
        raw = None
    elif corruption == "malformed":
        raw = "not-json"
    else:
        if corruption == "hash":
            result["targetRef"]["contentHash"] = "0" * 64
        elif corruption == "evaluator":
            result["evaluatorId"] = "different-evaluator"
        elif corruption == "version":
            result["evaluatorVersion"] = "unapproved-version"
        elif corruption == "parents":
            parent = ArtifactEnvelope.create(
                artifact_id="unrelated", artifact_type=ArtifactType.SOURCE_PACK,
                run_id=store.context.run_id, payload={"fixture": "unrelated"}, producer_version="1.0.0",
            )
            result["inputDependencyRefs"] = [parent.to_ref().model_dump(mode="json", by_alias=True)]
        else:
            draft = next(iter(store.drafts.values()))
            store.evaluations.append(evaluation(draft).model_copy(update={"evaluation_id": "conflicting-result"}))
        raw = json.dumps(result)
    store.operations[operation.operationId] = operation.model_copy(update={"resultRefJson": raw})
    before = dict(store.operations)

    async def never(*args, **kwargs):
        pytest.fail("A corrupt terminal result must not authorize repeated work")

    with pytest.raises(ValueError, match="Completed evaluation operation"):
        await execute(store, generate=never, evaluate=never)
    assert store.heads == {}
    assert store.commits == []
    assert store.operations == before
