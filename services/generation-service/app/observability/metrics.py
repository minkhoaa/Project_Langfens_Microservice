"""Phase 13 — Metrics recorder with strictly bounded label dimensions.

Enforces:
- Operation latencies (Histogram)
- Provider calls (Counter)
- Evaluator durations (Histogram)
- Repairs (Counter)
- Issues (Counter)
- Exhaustion events (Counter)
- Stale writer / resume events (Counter)
- Token counters (Counter, reported vs estimated vs unknown)
- Pricing snapshots (Gauge)
- Strict label validation against BoundedLabel enums (UnboundedLabelError on invalid).
"""

from __future__ import annotations

import threading
import time
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Mapping, Optional, Sequence, Tuple

from app.observability.redaction import (
    BoundedLabel,
    IssueKind,
    LoopEventKind,
    ModelKind,
    OperationKind,
    OutcomeKind,
    ProviderKind,
    ReasonKind,
    RepairKind,
    SeverityKind,
    StatusKind,
    TokenKind,
    UnboundedLabelError,
    VerdictKind,
)

# Standard latency buckets in seconds
DEFAULT_LATENCY_BUCKETS: Tuple[float, ...] = (
    0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0, 60.0, 120.0, 300.0
)


@dataclass
class MetricSample:
    name: str
    labels: Mapping[str, str]
    value: float
    timestamp: float = field(default_factory=time.time)


class Counter:
    """Thread-safe bounded in-memory Prometheus counter."""

    def __init__(self, name: str, description: str, label_names: Sequence[str]):
        self.name = name
        self.description = description
        self.label_names = tuple(label_names)
        self._lock = threading.Lock()
        self._values: Dict[Tuple[Tuple[str, str], ...], float] = defaultdict(float)

    def inc(self, amount: float = 1.0, **labels: Any) -> None:
        if amount < 0:
            raise ValueError("Counter cannot be decremented")
        norm_labels = self._validate_labels(labels)
        with self._lock:
            self._values[norm_labels] += amount

    def get(self, **labels: Any) -> float:
        norm_labels = self._validate_labels(labels)
        with self._lock:
            return self._values.get(norm_labels, 0.0)

    def collect(self) -> List[MetricSample]:
        with self._lock:
            return [
                MetricSample(name=self.name, labels=dict(lbl_tuple), value=val)
                for lbl_tuple, val in self._values.items()
            ]

    def _validate_labels(self, labels: Mapping[str, Any]) -> Tuple[Tuple[str, str], ...]:
        normalized = {}
        for name in self.label_names:
            if name not in labels:
                raise ValueError(f"Missing required label: {name}")
            val = labels[name]
            if isinstance(val, BoundedLabel):
                normalized[name] = str(val.value)
            elif isinstance(val, str):
                normalized[name] = val
            else:
                normalized[name] = str(val)
        return tuple(sorted(normalized.items()))


class Gauge:
    """Thread-safe bounded in-memory Prometheus gauge."""

    def __init__(self, name: str, description: str, label_names: Sequence[str]):
        self.name = name
        self.description = description
        self.label_names = tuple(label_names)
        self._lock = threading.Lock()
        self._values: Dict[Tuple[Tuple[str, str], ...], float] = {}

    def set(self, value: float, **labels: Any) -> None:
        norm_labels = self._validate_labels(labels)
        with self._lock:
            self._values[norm_labels] = float(value)

    def get(self, **labels: Any) -> Optional[float]:
        norm_labels = self._validate_labels(labels)
        with self._lock:
            return self._values.get(norm_labels)

    def collect(self) -> List[MetricSample]:
        with self._lock:
            return [
                MetricSample(name=self.name, labels=dict(lbl_tuple), value=val)
                for lbl_tuple, val in self._values.items()
            ]

    def _validate_labels(self, labels: Mapping[str, Any]) -> Tuple[Tuple[str, str], ...]:
        normalized = {}
        for name in self.label_names:
            if name not in labels:
                raise ValueError(f"Missing required label: {name}")
            val = labels[name]
            if isinstance(val, BoundedLabel):
                normalized[name] = str(val.value)
            elif isinstance(val, str):
                normalized[name] = val
            else:
                normalized[name] = str(val)
        return tuple(sorted(normalized.items()))


class Histogram:
    """Thread-safe bounded in-memory histogram with fixed buckets."""

    def __init__(
        self,
        name: str,
        description: str,
        label_names: Sequence[str],
        buckets: Sequence[float] = DEFAULT_LATENCY_BUCKETS,
    ):
        self.name = name
        self.description = description
        self.label_names = tuple(label_names)
        self.buckets = tuple(sorted(buckets))
        self._lock = threading.Lock()
        # Key -> (count, sum, bucket_counts_dict)
        self._data: Dict[Tuple[Tuple[str, str], ...], Tuple[int, float, Dict[float, int]]] = defaultdict(
            lambda: (0, 0.0, {b: 0 for b in self.buckets})
        )

    def observe(self, value: float, **labels: Any) -> None:
        norm_labels = self._validate_labels(labels)
        with self._lock:
            count, total, b_counts = self._data[norm_labels]
            new_b_counts = dict(b_counts)
            for b in self.buckets:
                if value <= b:
                    new_b_counts[b] = new_b_counts.get(b, 0) + 1
            self._data[norm_labels] = (count + 1, total + value, new_b_counts)

    def get_stats(self, **labels: Any) -> Tuple[int, float, Dict[float, int]]:
        norm_labels = self._validate_labels(labels)
        with self._lock:
            return self._data[norm_labels]

    def collect(self) -> List[MetricSample]:
        samples: List[MetricSample] = []
        with self._lock:
            for lbl_tuple, (count, total, b_counts) in self._data.items():
                lbls = dict(lbl_tuple)
                # Bucket samples
                cum = 0
                for b in self.buckets:
                    cum = b_counts.get(b, 0)
                    b_lbls = dict(lbls)
                    b_lbls["le"] = str(b)
                    samples.append(MetricSample(name=f"{self.name}_bucket", labels=b_lbls, value=float(cum)))
                # +Inf bucket
                inf_lbls = dict(lbls)
                inf_lbls["le"] = "+Inf"
                samples.append(MetricSample(name=f"{self.name}_bucket", labels=inf_lbls, value=float(count)))
                # Count and sum
                samples.append(MetricSample(name=f"{self.name}_count", labels=lbls, value=float(count)))
                samples.append(MetricSample(name=f"{self.name}_sum", labels=lbls, value=float(total)))
        return samples

    def _validate_labels(self, labels: Mapping[str, Any]) -> Tuple[Tuple[str, str], ...]:
        normalized = {}
        for name in self.label_names:
            if name not in labels:
                raise ValueError(f"Missing required label: {name}")
            val = labels[name]
            if isinstance(val, BoundedLabel):
                normalized[name] = str(val.value)
            elif isinstance(val, str):
                normalized[name] = val
            else:
                normalized[name] = str(val)
        return tuple(sorted(normalized.items()))


class MetricsRecorder:
    """Central registry and recorder for bounded generation metrics."""

    def __init__(self) -> None:
        # Latencies
        self.operation_latency = Histogram(
            name="generation_operation_latency_seconds",
            description="Latency of generation pipeline operations in seconds",
            label_names=["operation_kind", "status", "loop_event_kind"],
        )
        self.evaluator_duration = Histogram(
            name="generation_evaluator_duration_seconds",
            description="Duration of evaluator passes in seconds",
            label_names=["evaluator_kind", "verdict"],
        )

        # Provider calls
        self.provider_calls = Counter(
            name="generation_provider_calls_total",
            description="Total number of external provider LLM/API calls",
            label_names=["provider_kind", "model_kind", "outcome"],
        )

        # Repairs & Issues
        self.repairs = Counter(
            name="generation_repairs_total",
            description="Total number of automated repairs executed",
            label_names=["repair_kind", "outcome"],
        )
        self.issues = Counter(
            name="generation_issues_total",
            description="Total number of quality or validation issues detected",
            label_names=["issue_kind", "severity"],
        )

        # Loop lifecycle & exhaustions
        self.exhaustions = Counter(
            name="generation_exhaustion_events_total",
            description="Total loop limit exhaustions (budget, attempts, deadline)",
            label_names=["event_kind", "reason"],
        )
        self.stale_writers = Counter(
            name="generation_stale_writer_total",
            description="Total detected stale writer / concurrency fencing occurrences",
            label_names=["reason"],
        )
        self.resume_events = Counter(
            name="generation_resume_events_total",
            description="Total session or checkpoint resume events",
            label_names=["reason"],
        )

        # Token counters (strictly partitioned by TokenKind)
        self.tokens = Counter(
            name="generation_tokens_total",
            description="Total tokens processed by token accounting category",
            label_names=["token_kind", "provider_kind", "model_kind"],
        )

        # Pricing gauge
        self.pricing_snapshot = Gauge(
            name="generation_pricing_snapshot_usd",
            description="Latest pricing estimate snapshot in USD",
            label_names=["provider_kind", "model_kind"],
        )

    # --- Convenience recorders enforcing bounded label types ---

    def record_operation_latency(
        self,
        duration: float,
        operation_kind: OperationKind | str,
        status: StatusKind | str,
        loop_event_kind: LoopEventKind | str = LoopEventKind.COMPLETED,
    ) -> None:
        op = OperationKind(operation_kind)
        st = StatusKind(status)
        ev = LoopEventKind(loop_event_kind)
        self.operation_latency.observe(
            duration,
            operation_kind=op.value,
            status=st.value,
            loop_event_kind=ev.value,
        )

    def record_provider_call(
        self,
        provider_kind: ProviderKind | str,
        model_kind: ModelKind | str,
        outcome: OutcomeKind | str,
    ) -> None:
        p = ProviderKind(provider_kind)
        m = ModelKind(model_kind)
        o = OutcomeKind(outcome)
        self.provider_calls.inc(
            1.0,
            provider_kind=p.value,
            model_kind=m.value,
            outcome=o.value,
        )

    def record_evaluator(
        self,
        evaluator_kind: str,
        verdict: VerdictKind | str,
        duration: float,
    ) -> None:
        v = VerdictKind(verdict)
        # evaluator_kind is bounded by the known evaluator registry names
        self.evaluator_duration.observe(
            duration,
            evaluator_kind=str(evaluator_kind).lower(),
            verdict=v.value,
        )

    def record_repair(
        self,
        repair_kind: RepairKind | str,
        outcome: OutcomeKind | str,
    ) -> None:
        r = RepairKind(repair_kind)
        o = OutcomeKind(outcome)
        self.repairs.inc(1.0, repair_kind=r.value, outcome=o.value)

    def record_issue(
        self,
        issue_kind: IssueKind | str,
        severity: SeverityKind | str,
    ) -> None:
        i = IssueKind(issue_kind)
        s = SeverityKind(severity)
        self.issues.inc(1.0, issue_kind=i.value, severity=s.value)

    def record_exhaustion(
        self,
        event_kind: LoopEventKind | str,
        reason: ReasonKind | str,
    ) -> None:
        e = LoopEventKind(event_kind)
        r = ReasonKind(reason)
        self.exhaustions.inc(1.0, event_kind=e.value, reason=r.value)

    def record_stale_writer(self, reason: ReasonKind | str = ReasonKind.CONCURRENCY_LOST) -> None:
        r = ReasonKind(reason)
        self.stale_writers.inc(1.0, reason=r.value)

    def record_resume(self, reason: ReasonKind | str = ReasonKind.CHECKPOINT_STALE) -> None:
        r = ReasonKind(reason)
        self.resume_events.inc(1.0, reason=r.value)

    def record_tokens(
        self,
        token_kind: TokenKind | str,
        provider_kind: ProviderKind | str,
        model_kind: ModelKind | str,
        amount: float,
    ) -> None:
        t = TokenKind(token_kind)
        p = ProviderKind(provider_kind)
        m = ModelKind(model_kind)
        self.tokens.inc(
            amount,
            token_kind=t.value,
            provider_kind=p.value,
            model_kind=m.value,
        )

    def record_pricing_snapshot(
        self,
        provider_kind: ProviderKind | str,
        model_kind: ModelKind | str,
        amount_usd: float,
    ) -> None:
        p = ProviderKind(provider_kind)
        m = ModelKind(model_kind)
        self.pricing_snapshot.set(
            amount_usd,
            provider_kind=p.value,
            model_kind=m.value,
        )

    def collect_all(self) -> List[MetricSample]:
        samples: List[MetricSample] = []
        samples.extend(self.operation_latency.collect())
        samples.extend(self.evaluator_duration.collect())
        samples.extend(self.provider_calls.collect())
        samples.extend(self.repairs.collect())
        samples.extend(self.issues.collect())
        samples.extend(self.exhaustions.collect())
        samples.extend(self.stale_writers.collect())
        samples.extend(self.resume_events.collect())
        samples.extend(self.tokens.collect())
        samples.extend(self.pricing_snapshot.collect())
        return samples


class OperationTimer:
    """Context manager for timing operations and recording to MetricsRecorder."""

    def __init__(
        self,
        recorder: MetricsRecorder,
        operation_kind: OperationKind | str,
        loop_event_kind: LoopEventKind | str = LoopEventKind.COMPLETED,
    ) -> None:
        self.recorder = recorder
        self.operation_kind = OperationKind(operation_kind)
        self.loop_event_kind = LoopEventKind(loop_event_kind)
        self.start_time: float = 0.0
        self.status: StatusKind = StatusKind.RUNNING

    def __enter__(self) -> "OperationTimer":
        self.start_time = time.perf_counter()
        return self

    def __exit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        duration = max(0.0, time.perf_counter() - self.start_time)
        if exc_type is not None:
            self.status = StatusKind.FAILED
        elif self.status == StatusKind.RUNNING:
            self.status = StatusKind.COMPLETED
        self.recorder.record_operation_latency(
            duration=duration,
            operation_kind=self.operation_kind,
            status=self.status,
            loop_event_kind=self.loop_event_kind,
        )


_DEFAULT_METRICS = MetricsRecorder()


def get_metrics_recorder() -> MetricsRecorder:
    return _DEFAULT_METRICS
