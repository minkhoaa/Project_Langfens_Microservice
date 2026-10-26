"""Multiple evaluator diagnostics cannot repeat paid repair work in one version."""
import pytest

from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from tests.test_hybrid_question_repair_integration import (
    DummyLoopContext, hybrid_env, make_question_artifact, seed_repair_parent,
)


@pytest.mark.asyncio
async def test_multiple_semantic_diagnostics_produce_one_grounded_repair_version(hybrid_env):
    repairer, transport, gateway, client = hybrid_env
    context = DummyLoopContext(gateway, client)
    original = make_question_artifact()
    original_ref = original.to_ref()
    issues = [Issue(code=IssueCode.AMBIGUOUS_ANSWER, message=message,
        severity=IssueSeverity.CRITICAL, scope=IssueScope.QUESTION)
        for message in ("Question 2 has competing answers", "Question 2 lacks the required time anchor")]
    await seed_repair_parent(client, run_id=context.run_id, operation_id="duplicate-diagnostics",
        artifact_id=original.artifact_id, section_id=context.section_id, lease_owner=context.authority.lease_owner)
    repaired = await repairer.repair(context, original, issues, "duplicate-diagnostics", 2)
    assert repaired.version == 2
    assert "14th century" in repaired.payload["prompt"]
    assert original.to_ref() == original_ref and original.verify_integrity()
    assert len(transport.dispatched_requests) == 2  # one plan, one new candidate
    assert sum(r.pinned_model == "MiniMax-M3" for r in transport.dispatched_requests) == 1
