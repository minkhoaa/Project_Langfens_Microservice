"""Phase 13 — Observability, Redaction, Metrics, Tracing, Accounting & Dashboards."""

from app.observability.redaction import (
    BoundedLabel,
    CanaryResult,
    IssueKind,
    LoopEventKind,
    ModelKind,
    OperationKind,
    OutcomeKind,
    ProviderKind,
    ReasonKind,
    Redactor,
    RepairKind,
    SanitizedUserError,
    SeverityKind,
    StatusKind,
    TokenKind,
    UnboundedLabelError,
    VerdictKind,
    redact_label,
    redact_payload,
    redact_source,
    redact_text,
    redaction_canary,
    sanitize_user_error,
)
from app.observability.metrics import (
    Counter,
    Gauge,
    Histogram,
    MetricsRecorder,
    MetricSample,
    OperationTimer,
    get_metrics_recorder,
)
from app.observability.tracing import (
    Span,
    TracingContext,
    get_tracing_context,
)
from app.observability.accounting import (
    DecisionLineage,
    DecisionRecord,
    MODEL_PRICING_PER_1K,
    PricingSnapshot,
    TokenAccountant,
    TokenUsageEntry,
    get_decision_lineage,
    get_token_accountant,
)
from app.observability.dashboard import (
    METRIC_DEFINITIONS,
    DashboardConfig,
    build_grafana_dashboard,
    build_opentelemetry_export,
    build_prometheus_payload,
    format_prometheus_line,
)

# Coordination aliases requested by Main for Worker A wiring:
get_metrics_collector = get_metrics_recorder
get_token_ledger = get_token_accountant
get_lineage_tracker = get_decision_lineage
get_tracer = get_tracing_context

__all__ = [
    # Coordination aliases
    "get_metrics_collector",
    "get_token_ledger",
    "get_lineage_tracker",
    "get_tracer",
    # Redaction & Enums
    "BoundedLabel",
    "CanaryResult",
    "IssueKind",
    "LoopEventKind",
    "ModelKind",
    "OperationKind",
    "OutcomeKind",
    "ProviderKind",
    "ReasonKind",
    "Redactor",
    "RepairKind",
    "SanitizedUserError",
    "SeverityKind",
    "StatusKind",
    "TokenKind",
    "UnboundedLabelError",
    "VerdictKind",
    "redact_label",
    "redact_payload",
    "redact_source",
    "redact_text",
    "redaction_canary",
    "sanitize_user_error",
    # Metrics
    "Counter",
    "Gauge",
    "Histogram",
    "MetricsRecorder",
    "MetricSample",
    "OperationTimer",
    "get_metrics_recorder",
    # Tracing
    "Span",
    "TracingContext",
    "get_tracing_context",
    # Accounting & Lineage
    "DecisionLineage",
    "DecisionRecord",
    "MODEL_PRICING_PER_1K",
    "PricingSnapshot",
    "TokenAccountant",
    "TokenUsageEntry",
    "get_decision_lineage",
    "get_token_accountant",
    # Dashboards & Export
    "METRIC_DEFINITIONS",
    "DashboardConfig",
    "build_grafana_dashboard",
    "build_opentelemetry_export",
    "build_prometheus_payload",
    "format_prometheus_line",
]
