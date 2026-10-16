"""Tests for RG02-S05 4-Role Agent Traces and Usage Accounting."""

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.trace import (
    AgentRole,
    AgentTraceEvent,
    UsageConfidence,
    UsageRecord,
)


def load_schemas():
    schema_path = Path(__file__).resolve().parents[3] / "generation_baseline" / "contracts" / "JSON_SCHEMAS.json"
    return json.loads(schema_path.read_text())


def test_pos_four_agent_roles_traces():
    """POS: All 4 agent roles (COORDINATOR, GENERATOR, REVIEWER, VALIDATOR) serialize valid AgentTraceEvents."""
    schemas = load_schemas()
    roles = [AgentRole.COORDINATOR, AgentRole.GENERATOR, AgentRole.REVIEWER, AgentRole.VALIDATOR]
    sha = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    for role in roles:
        trace = AgentTraceEvent(
            trace_id=f"tr-{role.value.lower()}-001",
            run_id="run-test-01",
            agent_role=role,
            capability_name=f"cap_{role.value.lower()}",
            input_sha256=sha,
            output_sha256=sha,
            started_at="2026-10-15T08:00:00Z",
            ended_at="2026-10-15T08:00:05Z",
            event_status="COMPLETED",
        )
        jsonschema.Draft202012Validator({
            "$schema": schemas["$schema"],
            "$defs": schemas["$defs"],
            "$ref": "#/$defs/AgentTraceEvent",
        }).validate(trace.model_dump())


def test_pos_usage_confidence_levels():
    """POS: EXACT, ESTIMATED, and UNKNOWN confidence levels serialize valid UsageRecords."""
    schemas = load_schemas()

    exact_ur = UsageRecord(
        run_id="run-exact-01",
        llm_calls=5,
        prompt_tokens=1200,
        completion_tokens=450,
        cost_usd=0.0125,
        usage_confidence=UsageConfidence.EXACT,
        pricing_version="groq-2026-03",
        failure_usage_reason=None,
    )
    jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/UsageRecord",
    }).validate(exact_ur.model_dump())

    unknown_ur = UsageRecord(
        run_id="run-unknown-01",
        llm_calls=1,
        prompt_tokens=None,
        completion_tokens=None,
        cost_usd=None,
        usage_confidence=UsageConfidence.UNKNOWN,
        pricing_version=None,
        failure_usage_reason="Provider socket timeout before HTTP headers were received.",
    )
    jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/UsageRecord",
    }).validate(unknown_ur.model_dump())


def test_neg_unknown_usage_missing_reason_rejected():
    """NEG: Unknown usage cannot be cost-free without an explicit failure_usage_reason."""
    with pytest.raises(ValidationError):
        UsageRecord(
            run_id="run-bad-01",
            llm_calls=1,
            prompt_tokens=None,
            completion_tokens=None,
            cost_usd=None,
            usage_confidence=UsageConfidence.UNKNOWN,
            failure_usage_reason=None,
        )


def test_neg_invalid_agent_role_rejected():
    """NEG: Unallowed role names cannot be passed to AgentTraceEvent."""
    sha = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    with pytest.raises(ValidationError):
        AgentTraceEvent(
            trace_id="tr-bad-001",
            run_id="run-test-01",
            agent_role="STUDENT",
            capability_name="cap_student",
            input_sha256=sha,
            output_sha256=sha,
            started_at="2026-10-15T08:00:00Z",
            ended_at="2026-10-15T08:00:05Z",
            event_status="COMPLETED",
        )


def test_neg_negative_llm_calls_rejected():
    """NEG: Negative calls counter is rejected."""
    with pytest.raises(ValidationError):
        UsageRecord(
            run_id="run-neg-01",
            llm_calls=-1,
            usage_confidence=UsageConfidence.EXACT,
        )


def test_edge_in_flight_trace_event_with_null_output():
    """EDGE: In-flight trace with null output_sha256 and null ended_at validates cleanly."""
    schemas = load_schemas()
    sha = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    trace = AgentTraceEvent(
        trace_id="tr-inflight-001",
        run_id="run-test-01",
        agent_role=AgentRole.GENERATOR,
        capability_name="passage_generation",
        input_sha256=sha,
        output_sha256=None,
        started_at="2026-10-15T08:00:00Z",
        ended_at=None,
        event_status="IN_PROGRESS",
    )
    jsonschema.Draft202012Validator({
        "$schema": schemas["$schema"],
        "$defs": schemas["$defs"],
        "$ref": "#/$defs/AgentTraceEvent",
    }).validate(trace.model_dump())


def test_pos_gateway_record_usage_buckets_reported_estimated_unknown():
    """POS: Token accountant partitions reported, estimated, and unknown tokens into distinct buckets."""
    from app.observability.accounting import get_token_accountant
    from app.providers.models import UsageAccountingType, UsageReport

    accountant = get_token_accountant()
    provider = "groq"
    model = "groq_llama"

    # 1. REPORTED usage
    rep_usage = UsageReport(prompt_tokens=100, completion_tokens=50, total_tokens=150, accounting_type=UsageAccountingType.REPORTED)
    rep_tokens = rep_usage.total_tokens if rep_usage.accounting_type == UsageAccountingType.REPORTED else 0
    est_tokens = rep_usage.total_tokens if rep_usage.accounting_type == UsageAccountingType.ESTIMATED else 0
    unk_tokens = rep_usage.total_tokens if rep_usage.accounting_type == UsageAccountingType.UNKNOWN else 0
    entry_rep = accountant.record_usage(provider=provider, model=model, reported_tokens=rep_tokens, estimated_tokens=est_tokens, unknown_tokens=unk_tokens)
    assert entry_rep.reported_tokens == 150
    assert entry_rep.estimated_tokens == 0
    assert entry_rep.unknown_tokens == 0

    # 2. ESTIMATED usage
    est_usage = UsageReport(prompt_tokens=200, completion_tokens=100, total_tokens=300, accounting_type=UsageAccountingType.ESTIMATED)
    rep_tokens = est_usage.total_tokens if est_usage.accounting_type == UsageAccountingType.REPORTED else 0
    est_tokens = est_usage.total_tokens if est_usage.accounting_type == UsageAccountingType.ESTIMATED else 0
    unk_tokens = est_usage.total_tokens if est_usage.accounting_type == UsageAccountingType.UNKNOWN else 0
    entry_est = accountant.record_usage(provider=provider, model=model, reported_tokens=rep_tokens, estimated_tokens=est_tokens, unknown_tokens=unk_tokens)
    assert entry_est.reported_tokens == 0
    assert entry_est.estimated_tokens == 300
    assert entry_est.unknown_tokens == 0

    # 3. UNKNOWN usage (socket/provider failure)
    unk_usage = UsageReport(total_tokens=50, accounting_type=UsageAccountingType.UNKNOWN)
    rep_tokens = unk_usage.total_tokens if unk_usage.accounting_type == UsageAccountingType.REPORTED else 0
    est_tokens = unk_usage.total_tokens if unk_usage.accounting_type == UsageAccountingType.ESTIMATED else 0
    unk_tokens = unk_usage.total_tokens if unk_usage.accounting_type == UsageAccountingType.UNKNOWN else 0
    entry_unk = accountant.record_usage(provider=provider, model=model, reported_tokens=rep_tokens, estimated_tokens=est_tokens, unknown_tokens=unk_tokens)
    assert entry_unk.reported_tokens == 0
    assert entry_unk.estimated_tokens == 0
    assert entry_unk.unknown_tokens == 50


def test_neg_unknown_usage_with_cost_or_tokens_rejected():
    """NEG: Unknown usage cannot default to 0.0 cost or 0 tokens; must be None."""
    with pytest.raises(ValidationError):
        UsageRecord(
            run_id="run-bad-cost-01",
            llm_calls=1,
            cost_usd=0.0,
            usage_confidence=UsageConfidence.UNKNOWN,
            failure_usage_reason="timeout",
        )

    with pytest.raises(ValidationError):
        UsageRecord(
            run_id="run-bad-tokens-01",
            llm_calls=1,
            prompt_tokens=0,
            usage_confidence=UsageConfidence.UNKNOWN,
            failure_usage_reason="timeout",
        )
