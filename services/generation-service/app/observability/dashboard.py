"""Phase 13 — Observability Dashboard and Metric Exposition.

Provides:
- Metric schema definitions with bounded label dimensions.
- Prometheus text exposition formatter.
- OpenTelemetry-compatible metric export dictionary.
- Grafana Dashboard JSON generator and standard template.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any, Dict, List, Mapping, Optional, Sequence

from app.observability.metrics import MetricsRecorder, get_metrics_recorder

# Canonical metric registry definitions
METRIC_DEFINITIONS: List[Dict[str, Any]] = [
    {
        "name": "generation_operation_latency_seconds",
        "type": "histogram",
        "unit": "seconds",
        "description": "Latency of generation pipeline operations in seconds",
        "labels": ["operation_kind", "status", "loop_event_kind"],
        "bounded": True,
    },
    {
        "name": "generation_evaluator_duration_seconds",
        "type": "histogram",
        "unit": "seconds",
        "description": "Duration of evaluator passes in seconds",
        "labels": ["evaluator_kind", "verdict"],
        "bounded": True,
    },
    {
        "name": "generation_provider_calls_total",
        "type": "counter",
        "unit": "calls",
        "description": "Total number of external provider LLM/API calls",
        "labels": ["provider_kind", "model_kind", "outcome"],
        "bounded": True,
    },
    {
        "name": "generation_repairs_total",
        "type": "counter",
        "unit": "repairs",
        "description": "Total number of automated repairs executed",
        "labels": ["repair_kind", "outcome"],
        "bounded": True,
    },
    {
        "name": "generation_issues_total",
        "type": "counter",
        "unit": "issues",
        "description": "Total number of quality or validation issues detected",
        "labels": ["issue_kind", "severity"],
        "bounded": True,
    },
    {
        "name": "generation_exhaustion_events_total",
        "type": "counter",
        "unit": "events",
        "description": "Total loop limit exhaustions (budget, attempts, deadline)",
        "labels": ["event_kind", "reason"],
        "bounded": True,
    },
    {
        "name": "generation_stale_writer_total",
        "type": "counter",
        "unit": "events",
        "description": "Total detected stale writer / concurrency fencing occurrences",
        "labels": ["reason"],
        "bounded": True,
    },
    {
        "name": "generation_resume_events_total",
        "type": "counter",
        "unit": "events",
        "description": "Total session or checkpoint resume events",
        "labels": ["reason"],
        "bounded": True,
    },
    {
        "name": "generation_tokens_total",
        "type": "counter",
        "unit": "tokens",
        "description": "Total tokens processed by token accounting category",
        "labels": ["token_kind", "provider_kind", "model_kind"],
        "bounded": True,
    },
    {
        "name": "generation_pricing_snapshot_usd",
        "type": "gauge",
        "unit": "USD",
        "description": "Latest pricing estimate snapshot in USD",
        "labels": ["provider_kind", "model_kind"],
        "bounded": True,
    },
]


def format_prometheus_line(name: str, labels: Mapping[str, str], value: float) -> str:
    """Format a single metric sample into standard Prometheus exposition format."""
    if not labels:
        return f"{name} {value}"
    label_parts = [f'{k}="{v}"' for k, v in sorted(labels.items())]
    return f"{name}{{{','.join(label_parts)}}} {value}"


def build_prometheus_payload(recorder: Optional[MetricsRecorder] = None) -> str:
    """Renders all registered metric samples into standard Prometheus text format."""
    rec = recorder or get_metrics_recorder()
    samples = rec.collect_all()

    # Group samples by base name for TYPE and HELP annotations
    lines: List[str] = []
    seen_headers: set[str] = set()

    for defn in METRIC_DEFINITIONS:
        m_name = defn["name"]
        m_type = defn["type"]
        m_desc = defn["description"]

        # Collect matching samples
        matching = [s for s in samples if s.name == m_name or s.name.startswith(f"{m_name}_")]
        if matching:
            lines.append(f"# HELP {m_name} {m_desc}")
            lines.append(f"# TYPE {m_name} {m_type}")
            for sample in matching:
                lines.append(format_prometheus_line(sample.name, sample.labels, sample.value))

    return "\n".join(lines) + ("\n" if lines else "")


def build_opentelemetry_export(recorder: Optional[MetricsRecorder] = None) -> Dict[str, Any]:
    """Renders in-memory metrics into an OpenTelemetry Metrics JSON payload structure."""
    rec = recorder or get_metrics_recorder()
    samples = rec.collect_all()

    metrics_list: List[Dict[str, Any]] = []
    for sample in samples:
        metrics_list.append({
            "name": sample.name,
            "attributes": sample.labels,
            "value": sample.value,
            "timestamp_unix_nano": int(sample.timestamp * 1e9),
        })

    return {
        "resourceMetrics": [
            {
                "resource": {
                    "attributes": [
                        {"key": "service.name", "value": {"stringValue": "generation-service"}},
                        {"key": "service.namespace", "value": {"stringValue": "langfens"}},
                        {"key": "service.version", "value": {"stringValue": "2.0.0"}},
                    ]
                },
                "scopeMetrics": [
                    {
                        "scope": {"name": "app.observability", "version": "2.0.0"},
                        "metrics": metrics_list,
                    }
                ],
            }
        ]
    }


def build_grafana_dashboard(
    title: str = "Langfens IELTS Reading Paper Generation",
    refresh: str = "5s",
) -> Dict[str, Any]:
    """Generates a complete, compliant Grafana Dashboard JSON schema v3."""
    return {
        "title": title,
        "schemaVersion": 36,
        "version": 1,
        "refresh": refresh,
        "timezone": "utc",
        "tags": ["langfens", "generation-service", "ielts", "llm"],
        "panels": [
            {
                "id": 1,
                "title": "Generation Latency (P95 / P50)",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
                "targets": [
                    {
                        "expr": "histogram_quantile(0.95, sum(rate(generation_operation_latency_seconds_bucket[5m])) by (le, operation_kind))",
                        "legendFormat": "{{operation_kind}} (p95)",
                    },
                    {
                        "expr": "histogram_quantile(0.50, sum(rate(generation_operation_latency_seconds_bucket[5m])) by (le, operation_kind))",
                        "legendFormat": "{{operation_kind}} (p50)",
                    },
                ],
            },
            {
                "id": 2,
                "title": "Token Consumption by Kind & Provider",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
                "targets": [
                    {
                        "expr": "sum(rate(generation_tokens_total[5m])) by (token_kind, provider_kind)",
                        "legendFormat": "{{token_kind}} ({{provider_kind}})",
                    }
                ],
            },
            {
                "id": 3,
                "title": "Quality Evaluator Durations",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
                "targets": [
                    {
                        "expr": "sum(rate(generation_evaluator_duration_seconds_sum[5m])) by (evaluator_kind) / sum(rate(generation_evaluator_duration_seconds_count[5m])) by (evaluator_kind)",
                        "legendFormat": "{{evaluator_kind}} avg duration",
                    }
                ],
            },
            {
                "id": 4,
                "title": "Automated Repairs & Quality Issues",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
                "targets": [
                    {
                        "expr": "sum(rate(generation_repairs_total[5m])) by (repair_kind)",
                        "legendFormat": "Repair: {{repair_kind}}",
                    },
                    {
                        "expr": "sum(rate(generation_issues_total[5m])) by (issue_kind)",
                        "legendFormat": "Issue: {{issue_kind}}",
                    },
                ],
            },
            {
                "id": 5,
                "title": "Provider Call Outcomes & Errors",
                "type": "stat",
                "gridPos": {"h": 6, "w": 8, "x": 0, "y": 16},
                "targets": [
                    {
                        "expr": "sum(increase(generation_provider_calls_total[1h])) by (outcome)",
                        "legendFormat": "{{outcome}}",
                    }
                ],
            },
            {
                "id": 6,
                "title": "Estimated Cost Snapshot ($ USD)",
                "type": "stat",
                "gridPos": {"h": 6, "w": 8, "x": 8, "y": 16},
                "targets": [
                    {
                        "expr": "sum(generation_pricing_snapshot_usd)",
                        "legendFormat": "Total USD",
                    }
                ],
            },
            {
                "id": 7,
                "title": "Loop Limits & Stale Writer Events",
                "type": "stat",
                "gridPos": {"h": 6, "w": 8, "x": 16, "y": 16},
                "targets": [
                    {
                        "expr": "sum(increase(generation_exhaustion_events_total[1h]))",
                        "legendFormat": "Exhaustions",
                    },
                    {
                        "expr": "sum(increase(generation_stale_writer_total[1h]))",
                        "legendFormat": "Stale Writers",
                    },
                    {
                        "expr": "sum(increase(generation_resume_events_total[1h]))",
                        "legendFormat": "Resumes",
                    },
                ],
            },
        ],
    }


class DashboardConfig:
    """Utility wrapper around dashboard generators and metrics schemas."""

    METRICS = METRIC_DEFINITIONS

    @staticmethod
    def get_prometheus_payload(recorder: Optional[MetricsRecorder] = None) -> str:
        return build_prometheus_payload(recorder)

    @staticmethod
    def get_opentelemetry_export(recorder: Optional[MetricsRecorder] = None) -> Dict[str, Any]:
        return build_opentelemetry_export(recorder)

    @staticmethod
    def get_grafana_dashboard_json(title: str = "Langfens IELTS Reading Paper Generation") -> str:
        return json.dumps(build_grafana_dashboard(title=title), indent=2)
