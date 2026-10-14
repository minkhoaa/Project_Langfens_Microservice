"""Phase 13 — Token Accounting and Decision Lineage Tracking.

Enforces:
- Strict partitioning of reported_tokens, estimated_tokens, and unknown_tokens.
- Accurate pricing snapshots without conflating estimated heuristics with billed actuals.
- Immutable / append-only decision lineage ledger explaining loop choices,
  evaluator triggers, and issue repairs.
"""

from __future__ import annotations

import threading
import time
from dataclasses import dataclass, field
from typing import Any, Dict, List, Mapping, Optional, Sequence, Tuple

from app.observability.metrics import MetricsRecorder, get_metrics_recorder
from app.observability.redaction import (
    BoundedLabel,
    ModelKind,
    ProviderKind,
    TokenKind,
    redact_payload,
)

# Reference pricing per 1K tokens in USD (prompt / completion averages)
MODEL_PRICING_PER_1K: Mapping[str, Tuple[float, float]] = {
    ModelKind.GPT_4O.value: (0.005, 0.015),
    ModelKind.GPT_4O_MINI.value: (0.00015, 0.0006),
    ModelKind.GROQ_LLAMA.value: (0.00059, 0.00079),
    ModelKind.MINIMAX_TEXT_01.value: (0.0002, 0.0011),
    ModelKind.GEMINI_15.value: (0.000075, 0.0003),
    ModelKind.QWEN_25.value: (0.0, 0.0),
}


@dataclass(frozen=True)
class TokenUsageEntry:
    provider: str
    model: str
    reported_tokens: int
    estimated_tokens: int
    unknown_tokens: int
    timestamp: float = field(default_factory=time.time)

    @property
    def total_tokens(self) -> int:
        return self.reported_tokens + self.estimated_tokens + self.unknown_tokens


@dataclass(frozen=True)
class PricingSnapshot:
    provider: str
    model: str
    reported_tokens: int
    estimated_tokens: int
    unknown_tokens: int
    total_tokens: int
    estimated_usd: float
    billed_actual_usd: Optional[float]
    pricing_status: str  # "reported_actual", "estimated", "partial", "unknown"
    timestamp: float = field(default_factory=time.time)


class TokenAccountant:
    """Thread-safe accountant strictly tracking token provenance categories."""

    def __init__(self, metrics: Optional[MetricsRecorder] = None) -> None:
        self._metrics = metrics or get_metrics_recorder()
        self._lock = threading.Lock()
        self._entries: List[TokenUsageEntry] = []
        # (provider, model) -> [reported_sum, estimated_sum, unknown_sum]
        self._aggregates: Dict[Tuple[str, str], List[int]] = {}

    def record_usage(
        self,
        provider: ProviderKind | str,
        model: ModelKind | str,
        *,
        reported_tokens: int = 0,
        estimated_tokens: int = 0,
        unknown_tokens: int = 0,
    ) -> TokenUsageEntry:
        p = ProviderKind(provider).value
        m = ModelKind(model).value

        rep = max(0, int(reported_tokens))
        est = max(0, int(estimated_tokens))
        unk = max(0, int(unknown_tokens))

        entry = TokenUsageEntry(
            provider=p,
            model=m,
            reported_tokens=rep,
            estimated_tokens=est,
            unknown_tokens=unk,
        )

        with self._lock:
            self._entries.append(entry)
            if (p, m) not in self._aggregates:
                self._aggregates[(p, m)] = [0, 0, 0]
            self._aggregates[(p, m)][0] += rep
            self._aggregates[(p, m)][1] += est
            self._aggregates[(p, m)][2] += unk

        # Record into bounded metrics
        if rep > 0:
            self._metrics.record_tokens(TokenKind.REPORTED, p, m, float(rep))
        if est > 0:
            self._metrics.record_tokens(TokenKind.ESTIMATED, p, m, float(est))
        if unk > 0:
            self._metrics.record_tokens(TokenKind.UNKNOWN, p, m, float(unk))

        # Update pricing snapshot gauge
        snapshot = self.compute_pricing_snapshot(p, m)
        self._metrics.record_pricing_snapshot(p, m, snapshot.estimated_usd)

        return entry

    def compute_pricing_snapshot(
        self, provider: ProviderKind | str, model: ModelKind | str
    ) -> PricingSnapshot:
        p = ProviderKind(provider).value
        m = ModelKind(model).value

        with self._lock:
            agg = list(self._aggregates.get((p, m), [0, 0, 0]))

        rep, est, unk = agg[0], agg[1], agg[2]
        tot = rep + est + unk

        rate_in, rate_out = MODEL_PRICING_PER_1K.get(m, (0.001, 0.002))
        avg_rate_per_token = (rate_in + rate_out) / 2.0 / 1000.0

        estimated_usd = round(tot * avg_rate_per_token, 6)

        if unk > 0 and rep == 0 and est == 0:
            pricing_status = "unknown"
            billed_actual_usd = None
        elif est > 0 or unk > 0:
            pricing_status = "partial" if rep > 0 else "estimated"
            billed_actual_usd = None
        elif rep > 0:
            pricing_status = "reported_actual"
            billed_actual_usd = estimated_usd
        else:
            pricing_status = "reported_actual"
            billed_actual_usd = 0.0

        return PricingSnapshot(
            provider=p,
            model=m,
            reported_tokens=rep,
            estimated_tokens=est,
            unknown_tokens=unk,
            total_tokens=tot,
            estimated_usd=estimated_usd,
            billed_actual_usd=billed_actual_usd,
            pricing_status=pricing_status,
        )

    def get_all_snapshots(self) -> List[PricingSnapshot]:
        with self._lock:
            keys = list(self._aggregates.keys())
        return [self.compute_pricing_snapshot(p, m) for p, m in keys]

    def get_entries(self) -> List[TokenUsageEntry]:
        with self._lock:
            return list(self._entries)


@dataclass(frozen=True)
class DecisionRecord:
    decision_id: str
    run_id: str
    sequence: int
    decision_type: str
    reason: str
    evaluator_verdicts: Mapping[str, str] = field(default_factory=dict)
    repaired_artifacts: Tuple[str, ...] = ()
    evidence_refs: Tuple[str, ...] = ()
    timestamp: float = field(default_factory=time.time)


class DecisionLineage:
    """Thread-safe append-only ledger of loop decisions and resolutions."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._records: List[DecisionRecord] = []

    def record_decision(
        self,
        decision_id: str,
        run_id: str,
        sequence: int,
        decision_type: str,
        reason: str,
        evaluator_verdicts: Optional[Mapping[str, str]] = None,
        repaired_artifacts: Optional[Sequence[str]] = None,
        evidence_refs: Optional[Sequence[str]] = None,
    ) -> DecisionRecord:
        safe_verdicts = {
            str(k): str(v) for k, v in (evaluator_verdicts or {}).items()
        }
        safe_artifacts = tuple(str(a) for a in (repaired_artifacts or ()))
        safe_refs = tuple(str(r) for r in (evidence_refs or ()))

        rec = DecisionRecord(
            decision_id=str(decision_id),
            run_id=str(run_id),
            sequence=int(sequence),
            decision_type=str(decision_type),
            reason=str(reason),
            evaluator_verdicts=safe_verdicts,
            repaired_artifacts=safe_artifacts,
            evidence_refs=safe_refs,
        )

        with self._lock:
            self._records.append(rec)
        return rec

    def get_records(self, run_id: Optional[str] = None) -> List[DecisionRecord]:
        with self._lock:
            if run_id is None:
                return list(self._records)
            return [r for r in self._records if r.run_id == run_id]


_DEFAULT_ACCOUNTANT = TokenAccountant()
_DEFAULT_LINEAGE = DecisionLineage()


def get_token_accountant() -> TokenAccountant:
    return _DEFAULT_ACCOUNTANT


def get_decision_lineage() -> DecisionLineage:
    return _DEFAULT_LINEAGE


# ---------------------------------------------------------------------------
# Phase 15 — Run-level accounting reconciliation (Measurement Integrity contract)
# ---------------------------------------------------------------------------

PROVIDER_CALL_OPERATION_TYPES = frozenset(
    {"PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE"}
)
"""Operation row classifications whose tokens/wall-time come from physical provider dispatches.

Used by ``reconcile_run_accounting`` to decide whether a run's accounting is anchored on
provider-side measured tokens, on its own ``GENERATE_*`` reservation, or on a rolled-up
section/paper wrapper that re-counts children.
"""

WRAPPER_OPERATION_TYPES = frozenset(
    {"GENERATE_SECTION", "GENERATE_PAPER", "GENERATE_BLUEPRINT",
     "GENERATE_PASSAGE", "GENERATE_QUESTION", "CHECKPOINT_COMMIT"}
)
"""Logical/wrapper operations that may not be physical provider calls.

These are the rows that historically double-counted ``PROVIDER_CALL`` child usage via the
section/paper rollup path; the contract demands that any reconciliation against the run
budget MUST credit a wrapper only when there is no physical provider-call operation in
the run.
"""

UNLIMITED_BENCHMARK_FIELDS = (
    "budgetCapCalls",
    "budgetCapTokens",
    "budgetCapWallTimeSeconds",
    "benchmarkMode",
    "benchmarkMonetaryCapMode",
)


def _coerce_int(value: Any, default: int = 0) -> int:
    if value is None:
        return default
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _coerce_float(value: Any, default: float = 0.0) -> float:
    if value is None:
        return default
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _op_attr(op: Any, *names: str, default: Any = None) -> Any:
    """Return the first attribute or dict-key of ``op`` that exists.

    Operations may be dataclasses (attribute access), Pydantic models, or plain ``dict``s
    (e.g. from the SQLite simulation); this helper bridges the three shapes uniformly.
    """
    if op is None:
        return default
    if isinstance(op, Mapping):
        for name in names:
            if name in op:
                return op[name]
        for name in names:
            snake = _to_snake(name)
            if snake in op:
                return op[snake]
        return default
    for name in names:
        if hasattr(op, name):
            return getattr(op, name)
    for name in names:
        snake = _to_snake(name)
        if hasattr(op, snake):
            return getattr(op, snake)
    return default


def _to_snake(name: str) -> str:
    out: List[str] = []
    for index, char in enumerate(name):
        if char.isupper() and index > 0 and not name[index - 1].isupper():
            out.append("_")
        out.append(char.lower())
    return "".join(out)


def _unique_dispatch_operation_ids(
    transport_dispatches: Sequence[Mapping[str, Any]],
    target_run_id: Optional[str] = None,
) -> int:
    seen: set = set()
    for entry in transport_dispatches or ():
        if not isinstance(entry, Mapping):
            continue
        if target_run_id:
            entry_run = entry.get("runId") or entry.get("run_id")
            if entry_run and str(entry_run) != str(target_run_id):
                continue
        op_id = entry.get("operationId") or entry.get("operation_id")
        if op_id is None:
            continue
        seen.add(str(op_id))
    return len(seen)


def reconcile_run_accounting(
    operations: Sequence[Any],
    transport_dispatches: Sequence[Mapping[str, Any]],
    run_row: Optional[Mapping[str, Any]] = None,
    elapsed_wall_seconds: Optional[float] = None,
) -> Dict[str, Any]:
    """Reconcile a reading-paper run against its persisted operations and provider traces.

    Implements the Measurement-Integrity contract consumed by both the C# ``CheckpointService``
    and the Python ``BoundedLoopRuntime`` so that ``run_tokens_used``, the per-operation-type
    rollups, and the ``dispatchesReconciled`` invariant are derived from a single source of
    truth. ``operations`` may be a list of dataclasses, Pydantic models, or plain dicts
    (e.g. SQLite simulation rows); ``transport_dispatches`` is the per-attempt provider
    trace (multi-run append log); ``run_row`` optionally carries the persisted budget
    totals which override cumulative-derived values when present.

    Returns a dict with the following fields, all integers unless noted:

    - ``uniqueProviderDispatches``: count of unique ``operationId`` entries in
      ``transport_dispatches`` for the run.
    - ``persistedProviderCallOperations``: count of ``operations`` whose
      ``OperationType`` is in :data:`PROVIDER_CALL_OPERATION_TYPES`.
    - ``totalOperationsPersisted``: total rows in ``operations``.
    - ``operationsByType``: ``{operationType: {count, tokensUsed, tokenReservation,
      wallTimeUsedSeconds}}`` rollup across all rows.
    - ``reportedTokens``: sum of ``TokensUsed`` on completed provider-call operations with
      ``AccountingType == "REPORTED"``.
    - ``estimatedTokens``: sum of ``TokensUsed`` on completed provider-call operations with
      ``AccountingType == "ESTIMATED"``.
    - ``unknownTokens``: sum of ``TokensUsed`` on provider-call operations with
      ``AccountingType == "UNKNOWN"`` OR that are in ``UNKNOWN_OUTCOME`` status.
    - ``unknownOutcomeOperationsCount``: count of provider-call operations in
      ``UNKNOWN_OUTCOME`` status or ``AccountingType == "UNKNOWN"``.
    - ``accountedProviderTokens``: authoritative token usage across provider-call
      operations: ``reportedTokens + max(tokensUsed, tokenReservation)`` for
      ``ESTIMATED`` accounting plus ``max(0, tokenReservation)`` for ``RESERVED`` and
      ``UNKNOWN_OUTCOME`` operations.
    - ``runTokensUsed``: ``run_row["budgetUsedTokens"]`` if provided, else
      ``accountedProviderTokens``.
    - ``allOperationsTokensSum``: raw ``SUM(tokensUsed)`` across all operation rows.
    - ``outstandingTokenReservations``: ``SUM(max(0, tokenReservation))`` for active
      ``RESERVED`` or ``UNKNOWN_OUTCOME`` provider-call operations.
    - ``grossPositiveReservationsGranted``: ``SUM(max(0, tokenReservation))`` across all
      operations, ignoring ``-1`` unlimited sentinels.
    - ``unlimitedSentinelOperationsCount``: count of operations with
      ``tokenReservation < 0``.
    - ``wallTime``: dict with ``endToEndWallSeconds`` (``elapsed_wall_seconds``),
      ``cumulativeProviderLatencySeconds`` (sum of ``WallTimeUsedSeconds`` on provider-call
      operations), ``accountedRunWallSeconds`` (``run_row["budgetUsedWallTimeSeconds"]`` if
      provided else cumulative latency), and ``outstandingWallReservationSeconds``
      (``SUM(max(0.0, wallTimeReservationSeconds))`` for ``RESERVED``/``UNKNOWN_OUTCOME``
      provider-call operations).
    - ``dispatchesReconciled``: ``True`` iff ``uniqueProviderDispatches ==
      persistedProviderCallOperations`` AND ``runTokensUsed == accountedProviderTokens``.
    """
    run_row = run_row or {}
    ops_list = list(operations or ())

    operations_by_type: Dict[str, Dict[str, Any]] = {}
    all_tokens_sum = 0
    gross_positive_reservations = 0
    unlimited_sentinel_count = 0

    reported_tokens = 0
    estimated_tokens = 0
    unknown_tokens = 0
    unknown_outcome_count = 0
    accounted_provider_tokens = 0
    outstanding_token_reservations = 0
    cumulative_provider_latency = 0.0
    outstanding_wall_reservations = 0.0

    persisted_provider_call_count = 0

    for op in ops_list:
        op_type_raw = _op_attr(op, "OperationType", "operation_type", "operationType")
        op_type = str(op_type_raw or "").upper() if op_type_raw is not None else ""
        accounting_type = _op_attr(op, "AccountingType", "accounting_type", "accountingType")
        status_raw = _op_attr(op, "Status", "status")
        status = str(status_raw or "").upper() if status_raw is not None else ""
        tokens_used = _coerce_int(_op_attr(op, "TokensUsed", "tokens_used", "tokensUsed"))
        token_reservation = _coerce_int(_op_attr(op, "TokenReservation", "token_reservation", "tokenReservation"))
        wall_time_used = _coerce_float(_op_attr(op, "WallTimeUsedSeconds", "wall_time_used_seconds", "wallTimeUsedSeconds"))
        wall_time_reservation = _coerce_float(_op_attr(op, "WallTimeReservationSeconds", "wall_time_reservation_seconds", "wallTimeReservationSeconds"))

        bucket = operations_by_type.setdefault(
            op_type or "(UNCLASSIFIED)",
            {"count": 0, "tokensUsed": 0, "tokenReservation": 0, "wallTimeUsedSeconds": 0.0},
        )
        bucket["count"] += 1
        bucket["tokensUsed"] += tokens_used
        bucket["tokenReservation"] += token_reservation
        bucket["wallTimeUsedSeconds"] += wall_time_used

        all_tokens_sum += tokens_used
        if token_reservation >= 0:
            gross_positive_reservations += token_reservation
        else:
            unlimited_sentinel_count += 1

        if op_type in PROVIDER_CALL_OPERATION_TYPES:
            persisted_provider_call_count += 1
            cumulative_provider_latency += wall_time_used

            accounting_norm = str(accounting_type or "").upper()
            is_unknown_outcome = status == "UNKNOWN_OUTCOME" or accounting_norm == "UNKNOWN"
            is_reserved = status == "RESERVED"
            is_completed = status == "COMPLETED"

            if is_unknown_outcome:
                unknown_outcome_count += 1
                unknown_tokens += tokens_used
                outstanding_token_reservations += max(0, token_reservation)
                outstanding_wall_reservations += max(0.0, wall_time_reservation)
                accounted_provider_tokens += max(0, token_reservation)
            elif accounting_norm == "REPORTED" and is_completed:
                reported_tokens += tokens_used
                accounted_provider_tokens += tokens_used
            elif accounting_norm == "ESTIMATED" and is_completed:
                estimated_tokens += tokens_used
                accounted_provider_tokens += max(tokens_used, token_reservation)
            elif is_reserved:
                outstanding_token_reservations += max(0, token_reservation)
                outstanding_wall_reservations += max(0.0, wall_time_reservation)
                accounted_provider_tokens += max(0, token_reservation)
            else:
                # Unknown / unknown-outcome / mixed; clamp to non-negative reservation.
                if tokens_used > 0:
                    unknown_tokens += tokens_used
                outstanding_token_reservations += max(0, token_reservation)
                outstanding_wall_reservations += max(0.0, wall_time_reservation)
                accounted_provider_tokens += max(tokens_used, max(0, token_reservation))

    if run_row and "budgetUsedTokens" in run_row and run_row["budgetUsedTokens"] is not None:
        run_tokens_used = _coerce_int(run_row["budgetUsedTokens"])
    else:
        run_tokens_used = accounted_provider_tokens

    if run_row and "budgetUsedWallTimeSeconds" in run_row and run_row["budgetUsedWallTimeSeconds"] is not None:
        accounted_run_wall_seconds = _coerce_float(run_row["budgetUsedWallTimeSeconds"])
    else:
        accounted_run_wall_seconds = round(cumulative_provider_latency, 4)

    end_to_end_wall = _coerce_float(elapsed_wall_seconds) if elapsed_wall_seconds is not None else 0.0

    target_run_id = None
    if run_row:
        target_run_id = run_row.get("runId") or run_row.get("run_id")
    unique_provider_dispatches = _unique_dispatch_operation_ids(
        transport_dispatches or (), target_run_id=target_run_id
    )

    dispatches_reconciled = (
        unique_provider_dispatches == persisted_provider_call_count
        and run_tokens_used == accounted_provider_tokens
    )

    wall_time = {
        "endToEndWallSeconds": float(end_to_end_wall),
        "cumulativeProviderLatencySeconds": round(cumulative_provider_latency, 4),
        "accountedRunWallSeconds": round(accounted_run_wall_seconds, 4),
        "outstandingWallReservationSeconds": round(outstanding_wall_reservations, 4),
    }

    return {
        "uniqueProviderDispatches": unique_provider_dispatches,
        "persistedProviderCallOperations": persisted_provider_call_count,
        "totalOperationsPersisted": len(ops_list),
        "operationsByType": operations_by_type,
        "reportedTokens": reported_tokens,
        "estimatedTokens": estimated_tokens,
        "unknownTokens": unknown_tokens,
        "unknownOutcomeOperationsCount": unknown_outcome_count,
        "accountedProviderTokens": accounted_provider_tokens,
        "runTokensUsed": run_tokens_used,
        "allOperationsTokensSum": all_tokens_sum,
        "outstandingTokenReservations": outstanding_token_reservations,
        "grossPositiveReservationsGranted": gross_positive_reservations,
        "netReservationsGranted": gross_positive_reservations - unlimited_sentinel_count,
        "unlimitedSentinelOperationsCount": unlimited_sentinel_count,
        "wallTime": wall_time,
        "dispatchesReconciled": dispatches_reconciled,
    }


def verify_unlimited_minimax_profile(
    profile_snapshot: Mapping[str, Any],
    run_row: Optional[Mapping[str, Any]] = None,
) -> Dict[str, Any]:
    """Confirm a ``loop_caps_snapshot`` represents the approved automatic MiniMax benchmark policy.

    The MiniMax unlimited profile (auto-selected by ``ReadingPaperCapsProfile.ToUnlimitedBenchmarkProfile``
    and the Python ``settings.create_unlimited_benchmark_snapshot``) sets the following to indicate
    that the run may dispatch unlimited calls/tokens/wall-time without manual approval files:

    - ``benchmarkMode == "UNLIMITED"``
    - ``benchmarkMonetaryCapMode == "UNLIMITED"``
    - ``budgetCapCalls == -1``
    - ``budgetCapTokens == -1``
    - ``budgetCapWallTimeSeconds == -1``

    Returns a dict with ``isUnlimited`` (bool), ``checks`` (per-field pass/fail), and
    ``violations`` (list of human-readable failure messages). ``run_row`` is optional and,
    when supplied, MUST itself carry the same ``-1`` caps to keep profile and persisted run
    consistent.
    """
    checks: Dict[str, Any] = {}
    violations: List[str] = []

    snapshot = profile_snapshot or {}

    def _check(field: str, actual: Any, expected: Any) -> None:
        ok = actual == expected
        checks[field] = {"expected": expected, "actual": actual, "ok": ok}
        if not ok:
            violations.append(
                f"{field}: expected {expected!r}, got {actual!r}"
            )

    _check("benchmarkMode", snapshot.get("benchmarkMode"), "UNLIMITED")
    _check("benchmarkMonetaryCapMode", snapshot.get("benchmarkMonetaryCapMode"), "UNLIMITED")

    if "budgetCapCalls" in snapshot:
        _check("budgetCapCalls", snapshot.get("budgetCapCalls"), -1)
    if "budgetCapTokens" in snapshot:
        _check("budgetCapTokens", snapshot.get("budgetCapTokens"), -1)
    if "budgetCapWallTimeSeconds" in snapshot:
        _check("budgetCapWallTimeSeconds", snapshot.get("budgetCapWallTimeSeconds"), -1)

    if run_row is not None:
        for cap_field in ("budgetCapCalls", "budgetCapTokens", "budgetCapWallTimeSeconds"):
            value = run_row.get(cap_field)
            if value is not None:
                _check(f"run.{cap_field}", value, -1)
    return {
        "isUnlimited": len(violations) == 0,
        "checks": checks,
        "violations": violations,
    }
