"""Additional pinned policy and request wire contract regressions."""
import json
from uuid import uuid4

import pytest
from pydantic import ValidationError

from app.reading_models import PipelineRequest, RunContext, SourceInput
from app.reading_policy import PinnedExecutionPolicy


def test_camel_case_policy_and_hash_are_stable():
    policy = PinnedExecutionPolicy(provider="mock")
    wire = policy.to_wire_dict()
    assert wire["sections"][1]["startNumber"] == 14
    assert "providerCallSeconds" in wire
    assert "provider_call_seconds" not in wire
    assert PinnedExecutionPolicy.model_validate(wire).hash == policy.hash
    assert PinnedExecutionPolicy.model_validate_json(json.dumps(wire, indent=3)).hash == policy.hash
    assert policy.sections[1].group_numbers(1) == tuple(range(20, 27))


@pytest.mark.parametrize("field,value", [
    ("run_wall_seconds", float("inf")), ("run_wall_seconds", float("nan")),
    ("max_candidates", 21), ("max_repairs", 11),
    ("max_evaluations_per_artifact", 0), ("max_dependency_depth", 0),
    ("max_recovery_attempts", -1), ("require_blind_solver", False),
    ("is_unlimited", True), ("skip_validation", True), ("provider", "  "),
])
def test_policy_has_no_unbounded_or_bypass_representation(field, value):
    with pytest.raises(ValidationError):
        PinnedExecutionPolicy(provider="mock", **{field: value}) if field != "provider" else PinnedExecutionPolicy(provider=value)


def test_remaining_budget_is_clamped_by_both_ancestors():
    policy = PinnedExecutionPolicy(provider="mock", run_token_cap=110, run_wall_seconds=50)
    budget = policy.remaining_budget(2, section_tokens_used=99_900, run_tokens_used=100,
                                    section_wall_seconds_used=899, run_wall_seconds_used=49.5)
    assert budget.tokens_available == 10
    assert budget.provider_call_seconds_available == 0.5
    exhausted = policy.remaining_budget(2, run_tokens_used=110)
    assert not exhausted.can_dispatch


def test_pipeline_request_roundtrip_and_authority_context():
    policy = PinnedExecutionPolicy(provider="mock")
    request = PipelineRequest(runId="run-contract", jobId=uuid4(), epoch=1, leaseOwner=uuid4(),
        topic="Science", sectionIndices=(2,), policy=policy,
        sources=(SourceInput(sectionIndex=2, pmcid="PMC123", title="Study", url="https://example.test",
                             license="CC-BY", content="Verified source"),))
    restored = PipelineRequest.model_validate_json(request.model_dump_json(by_alias=True))
    assert restored == request
    assert RunContext.from_request(request).policy_hash == policy.hash
    with pytest.raises(ValidationError):
        PipelineRequest.model_validate({**request.model_dump(), "section_indices": (1,)})
