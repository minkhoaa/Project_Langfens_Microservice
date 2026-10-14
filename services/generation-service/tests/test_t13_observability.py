"""Phase 13 — Observability, Redaction, Metrics, Accounting & Tracing Tests.

Tests:
1. Privacy & Redaction (API keys, Bearer tokens, internal keys, CoT blocks, source bodies, canary checks)
2. UI-facing Error Sanitization (no stack traces or secret leakage)
3. Bounded Label Cardinality & Metric Recorders
4. Token Accounting (reported vs estimated vs unknown tokens, pricing snapshots)
5. Decision Lineage tracking
6. Distributed Tracing & W3C TraceContext
7. Metric Exporters & Grafana Dashboard generation
"""

import json
import pytest
from app.observability import (
    BoundedLabel,
    CanaryResult,
    Counter,
    DashboardConfig,
    DecisionLineage,
    Gauge,
    Histogram,
    IssueKind,
    LoopEventKind,
    METRIC_DEFINITIONS,
    MetricsRecorder,
    ModelKind,
    OperationKind,
    OperationTimer,
    OutcomeKind,
    PricingSnapshot,
    ProviderKind,
    ReasonKind,
    Redactor,
    RepairKind,
    SanitizedUserError,
    SeverityKind,
    Span,
    StatusKind,
    TokenAccountant,
    TokenKind,
    TracingContext,
    UnboundedLabelError,
    VerdictKind,
    build_grafana_dashboard,
    build_opentelemetry_export,
    build_prometheus_payload,
    format_prometheus_line,
    redact_label,
    redact_payload,
    redact_source,
    redact_text,
    redaction_canary,
    sanitize_user_error,
)


class TestPrivacyAndRedaction:
    """Validates redaction of secrets, CoT, and copyrighted sources."""

    def test_scrub_api_keys(self) -> None:
        raw = "Header Authorization: Bearer sk-ant-api03-abcdef1234567890abcdef and sk-proj-1234567890abcdef123456"
        scrubbed = redact_text(raw)
        assert "sk-ant-api03" not in scrubbed
        assert "sk-proj-123456" not in scrubbed
        assert "[REDACTED:" in scrubbed

    def test_scrub_bearer_tokens(self) -> None:
        raw = "Authorization: Bearer my_secret_token_12345_xyz"
        scrubbed = redact_text(raw)
        assert "my_secret_token_12345_xyz" not in scrubbed
        assert "[REDACTED:BEARER_TOKEN_REDACTED]" in scrubbed

    def test_scrub_internal_service_key(self) -> None:
        raw = "X-Internal-Service-Key: super-secret-internal-service-key-999"
        scrubbed = redact_text(raw)
        assert "super-secret-internal-service-key-999" not in scrubbed
        assert "[REDACTED:INTERNAL_SERVICE_KEY_REDACTED]" in scrubbed

    def test_scrub_cot_thinking_tags(self) -> None:
        raw = "The final answer is B.<thinking>Let me think step by step: option A is wrong because of X.</thinking> Good."
        scrubbed = redact_text(raw)
        assert "Let me think step by step" not in scrubbed
        assert "The final answer is B." in scrubbed
        assert "Good." in scrubbed
        assert "[REDACTED:COT_REDACTED]" in scrubbed

    def test_scrub_fenced_thinking_blocks(self) -> None:
        raw = "Start.\n```thinking\nInternal model reasoning: checking constraints\n```\nEnd result."
        scrubbed = redact_text(raw)
        assert "Internal model reasoning" not in scrubbed
        assert "Start." in scrubbed
        assert "End result." in scrubbed

    def test_scrub_reasoning_fence(self) -> None:
        raw = "Prefix <<|model reasoning stream here|>> Suffix"
        scrubbed = redact_text(raw)
        assert "model reasoning stream here" not in scrubbed
        assert "Prefix" in scrubbed
        assert "Suffix" in scrubbed

    def test_scrub_copyrighted_source_body(self) -> None:
        long_text = "Academic paper text about climate change in the Arctic region. " * 30
        res = redact_source(long_text)
        assert isinstance(res, dict)
        assert res["redacted"] is True
        assert res["length_chars"] > 500
        assert "hash" in res
        assert len(res["hash"]) == 64  # SHA-256

    def test_redaction_canary_passes(self) -> None:
        canary = redaction_canary()
        assert isinstance(canary, CanaryResult)
        assert canary.passed is True
        assert len(canary.leaks) == 0
        assert canary.inspected > 0

    def test_sanitize_user_error_no_leaks(self) -> None:
        class FakeInternalSecretError(RuntimeError):
            pass

        exc = FakeInternalSecretError("Database connection failed for user admin password=supersecretpass with key sk-1234567890123456")
        sanitized = sanitize_user_error(exc, code=StatusKind.FAILED)

        assert isinstance(sanitized, SanitizedUserError)
        assert sanitized.code == StatusKind.FAILED.value
        assert "supersecretpass" not in sanitized.message
        assert "sk-1234567890123456" not in sanitized.message


class TestBoundedLabelCardinality:
    """Validates bounded enum constraints on Prometheus metric labels."""

    def test_valid_bounded_labels(self) -> None:
        assert redact_label(OperationKind, "synthesis") == "synthesis"
        assert redact_label(ProviderKind, "openai") == "openai"
        assert redact_label(StatusKind, "running") == "running"
        assert redact_label(TokenKind, "reported") == "reported"

    def test_invalid_bounded_labels_raise_error(self) -> None:
        # Arbitrary unbounded strings (like user_ids or run_ids) must be rejected
        with pytest.raises(UnboundedLabelError):
            OperationKind("unbounded_custom_op_123")

        with pytest.raises(UnboundedLabelError):
            ProviderKind("unknown_provider_xyz")

        with pytest.raises(UnboundedLabelError):
            TokenKind("random_token_type")

        with pytest.raises(UnboundedLabelError):
            redact_label(ModelKind, "run_id_9999_leak")


class TestMetricsAndTelemetry:
    """Validates metrics recording, histograms, counters, and timers."""

    def test_operation_timer_and_latency(self) -> None:
        recorder = MetricsRecorder()
        with OperationTimer(recorder, OperationKind.SYNTHESIS, LoopEventKind.COMPLETED) as timer:
            assert timer.operation_kind == OperationKind.SYNTHESIS
            # Simulate short work
            _ = sum(i for i in range(1000))

        samples = recorder.collect_all()
        latency_samples = [s for s in samples if s.name.startswith("generation_operation_latency_seconds")]
        assert len(latency_samples) > 0
        assert any(s.name == "generation_operation_latency_seconds_count" and s.value == 1.0 for s in latency_samples)

    def test_provider_calls_counter(self) -> None:
        recorder = MetricsRecorder()
        recorder.record_provider_call(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, OutcomeKind.OK)
        recorder.record_provider_call(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, OutcomeKind.ERROR)

        samples = recorder.collect_all()
        p_samples = [s for s in samples if s.name == "generation_provider_calls_total"]
        assert len(p_samples) == 2
        assert sum(s.value for s in p_samples) == 2.0

    def test_evaluator_durations(self) -> None:
        recorder = MetricsRecorder()
        recorder.record_evaluator("flesch_kincaid", VerdictKind.PASS, 0.045)
        recorder.record_evaluator("flesch_kincaid", VerdictKind.FAIL, 0.120)

        samples = recorder.collect_all()
        ev_samples = [s for s in samples if s.name.startswith("generation_evaluator_duration_seconds")]
        assert len(ev_samples) > 0

    def test_repairs_and_issues(self) -> None:
        recorder = MetricsRecorder()
        recorder.record_repair(RepairKind.PASSAGE_SENTENCE, OutcomeKind.OK)
        recorder.record_issue(IssueKind.FACTUAL, SeverityKind.WARNING)

        samples = recorder.collect_all()
        assert any(s.name == "generation_repairs_total" and s.value == 1.0 for s in samples)
        assert any(s.name == "generation_issues_total" and s.value == 1.0 for s in samples)

    def test_exhaustion_and_stale_writer(self) -> None:
        recorder = MetricsRecorder()
        recorder.record_exhaustion(LoopEventKind.LOOP_EXHAUSTED, ReasonKind.BUDGET_EXHAUSTED)
        recorder.record_stale_writer(ReasonKind.CONCURRENCY_LOST)
        recorder.record_resume(ReasonKind.CHECKPOINT_STALE)

        samples = recorder.collect_all()
        assert any(s.name == "generation_exhaustion_events_total" and s.value == 1.0 for s in samples)
        assert any(s.name == "generation_stale_writer_total" and s.value == 1.0 for s in samples)
        assert any(s.name == "generation_resume_events_total" and s.value == 1.0 for s in samples)


class TestTokenAccounting:
    """Validates strictly partitioned token accounting and pricing snapshots."""

    def test_strictly_distinguish_token_kinds(self) -> None:
        recorder = MetricsRecorder()
        accountant = TokenAccountant(metrics=recorder)

        # 1. Reported tokens from provider
        entry1 = accountant.record_usage(
            ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, reported_tokens=1500
        )
        assert entry1.reported_tokens == 1500
        assert entry1.estimated_tokens == 0
        assert entry1.unknown_tokens == 0
        assert entry1.total_tokens == 1500

        # 2. Local heuristic estimated tokens
        entry2 = accountant.record_usage(
            ProviderKind.OPENAI, ModelKind.GPT_4O, estimated_tokens=800
        )
        assert entry2.reported_tokens == 0
        assert entry2.estimated_tokens == 800
        assert entry2.unknown_tokens == 0

        # 3. Unknown tokens (e.g. streaming cutoff without usage header)
        entry3 = accountant.record_usage(
            ProviderKind.GROQ, ModelKind.GROQ_LLAMA, unknown_tokens=500
        )
        assert entry3.unknown_tokens == 500

    def test_pricing_snapshot_status(self) -> None:
        recorder = MetricsRecorder()
        accountant = TokenAccountant(metrics=recorder)

        # Reported only -> reported_actual
        accountant.record_usage(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, reported_tokens=2000)
        snap1 = accountant.compute_pricing_snapshot(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01)
        assert snap1.pricing_status == "reported_actual"
        assert snap1.billed_actual_usd is not None
        assert snap1.estimated_usd > 0.0

        # Estimated tokens present -> partial or estimated, billed_actual is None
        accountant.record_usage(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, estimated_tokens=1000)
        snap2 = accountant.compute_pricing_snapshot(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01)
        assert snap2.pricing_status == "partial"
        assert snap2.billed_actual_usd is None

        # Unknown tokens only -> unknown
        snap3 = accountant.compute_pricing_snapshot(ProviderKind.GOOGLE, ModelKind.GEMINI_15)
        assert snap3.pricing_status == "reported_actual"  # 0 tokens = 0 usd reported
        accountant.record_usage(ProviderKind.GOOGLE, ModelKind.GEMINI_15, unknown_tokens=300)
        snap4 = accountant.compute_pricing_snapshot(ProviderKind.GOOGLE, ModelKind.GEMINI_15)
        assert snap4.pricing_status == "unknown"
        assert snap4.billed_actual_usd is None


class TestDecisionLineage:
    """Validates immutable decision lineage ledger."""

    def test_record_and_retrieve_lineage(self) -> None:
        lineage = DecisionLineage()
        rec1 = lineage.record_decision(
            decision_id="dec-1",
            run_id="run-100",
            sequence=1,
            decision_type="EVALUATOR_RETRY",
            reason="Flesch-Kincaid score 14.5 exceeds Band 7 target",
            evaluator_verdicts={"flesch_kincaid": "FAIL", "academic_vocab": "PASS"},
            repaired_artifacts=["passage_p1"],
            evidence_refs=["ev-01", "ev-02"],
        )

        assert rec1.decision_id == "dec-1"
        assert rec1.sequence == 1
        assert rec1.evaluator_verdicts["flesch_kincaid"] == "FAIL"
        assert len(rec1.evidence_refs) == 2

        all_records = lineage.get_records("run-100")
        assert len(all_records) == 1
        assert all_records[0].decision_type == "EVALUATOR_RETRY"


class TestDistributedTracing:
    """Validates W3C TraceContext propagation and span nesting."""

    def test_w3c_traceparent_injection_and_extraction(self) -> None:
        ctx = TracingContext()
        tp_header = "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
        extracted = ctx.extract_traceparent(tp_header)
        assert extracted is True
        assert ctx.trace_id == "4bf92f3577b34da6a3ce929d0e0e4736"
        assert ctx.span_id == "00f067aa0ba902b7"

        injected = ctx.inject_traceparent()
        assert injected.startswith("00-4bf92f3577b34da6a3ce929d0e0e4736-")

    def test_span_lifecycle_and_nesting(self) -> None:
        ctx = TracingContext()
        ctx.clear()

        span1 = ctx.start_span("generate_section", run_id="run-1", operation_id="op-1")
        assert span1.parent_span_id is None
        assert span1.run_id == "run-1"

        span2 = ctx.start_span("evaluate_passage")
        assert span2.parent_span_id == span1.span_id
        assert span2.trace_id == span1.trace_id

        span2.set_attribute("evaluator.kind", "flesch_kincaid")
        span2.finish(status="OK")
        assert span2.status == "OK"
        assert span2.duration_seconds >= 0.0

        span1.finish(status="OK")
        spans = ctx.get_collected_spans()
        assert len(spans) == 2


class TestDashboardAndExposition:
    """Validates Prometheus format exposition, OTel JSON export, and Grafana schemas."""

    def test_format_prometheus_line(self) -> None:
        line = format_prometheus_line("http_requests_total", {"method": "GET", "status": "200"}, 42.0)
        assert line == 'http_requests_total{method="GET",status="200"} 42.0'

    def test_build_prometheus_payload(self) -> None:
        recorder = MetricsRecorder()
        recorder.record_provider_call(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, OutcomeKind.OK)
        payload = build_prometheus_payload(recorder)

        assert "# HELP generation_provider_calls_total" in payload
        assert "# TYPE generation_provider_calls_total counter" in payload
        assert 'generation_provider_calls_total{model_kind="MiniMax-Text-01",outcome="ok",provider_kind="MiniMax"} 1.0' in payload

    def test_build_opentelemetry_export(self) -> None:
        recorder = MetricsRecorder()
        recorder.record_issue(IssueKind.FACTUAL, SeverityKind.ERROR)
        otel_export = build_opentelemetry_export(recorder)

        assert "resourceMetrics" in otel_export
        assert len(otel_export["resourceMetrics"]) > 0
        scope_metrics = otel_export["resourceMetrics"][0]["scopeMetrics"]
        assert len(scope_metrics) > 0
        metrics = scope_metrics[0]["metrics"]
        assert any(m["name"] == "generation_issues_total" for m in metrics)

    def test_build_grafana_dashboard_json(self) -> None:
        dashboard = build_grafana_dashboard(title="IELTS Test Dashboard")
        assert dashboard["title"] == "IELTS Test Dashboard"
        assert dashboard["schemaVersion"] == 36
        assert len(dashboard["panels"]) == 7

        json_str = DashboardConfig.get_grafana_dashboard_json()
        parsed = json.loads(json_str)
        assert parsed["title"] == "Langfens IELTS Reading Paper Generation"
        assert len(parsed["panels"]) == 7
