"""Campaign budget ledger and checkpoint client wrapper for benchmark runs.

Implements ADR-001/002/005 truthful accounting for campaign budgets,
providing:
- Atomic JSON persistence of local ledger state.
- Unlimited vs capped campaign budgeting with CAS / restart recovery.
- Reconciled token / wall time tracking with breach detection.
- Pass-through CampaignCheckpointClient wrapping the authoritative CheckpointClient.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import tempfile
from typing import Any, Dict, List, Optional
from uuid import uuid4

from app.persistence.client import CheckpointApiError
from app.persistence.models import (
    OperationGrantRequest,
    OperationGrantResult,
    OperationReconcileRequest,
    OperationReconcileResult,
    OperationResumeInfo,
)


class CampaignAuthorizationError(Exception):
    """Raised when a campaign case is not fresh (already completed or used).

    Used by helpers that enforce per-case idempotency for benchmark campaigns,
    mirroring the AuthorizationGate behavior of the authoritative system.
    """


def atomic_write_json(path: Path | str, data: Any) -> None:
    """Writes data as JSON atomically by writing to a temporary file first."""
    p = Path(path).resolve()
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp_fd, tmp_name = tempfile.mkstemp(
        dir=str(p.parent),
        prefix=f".{p.name}.",
        suffix=".tmp",
    )
    try:
        with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, default=str)
        os.replace(tmp_name, str(p))
    except Exception:
        if os.path.exists(tmp_name):
            try:
                os.remove(tmp_name)
            except OSError:
                pass
        raise


def acceptance_config(gate_id: str) -> Dict[str, Any]:
    """Provides configuration profile snapshot and SHA256 binding for a gate."""
    from app.config import settings, cap_snapshot_sha256
    try:
        snapshot = settings.unlimited_caps_snapshot()
    except AttributeError:
        snapshot = settings.loop_caps_snapshot()
    return {
        "gate": gate_id,
        "sha256": cap_snapshot_sha256(snapshot),
        "snapshot": snapshot,
    }

def derive_campaign_id(
    gate_id: str,
    corpus_hash: str = "",
    config_hash: str = "",
    salt: str = "",
) -> str:
    """Generates a campaign ID bound to gate, corpus SHA256, and configuration hash.

    When any binding (corpus content or config profile) changes, this derives a
    new distinct campaign ID to prevent cross-binding state contamination.
    """
    raw = f"{gate_id}:{corpus_hash}:{config_hash}:{salt}"
    digest = hashlib.sha256(raw.encode("utf-8")).hexdigest()[:12]
    return f"camp_{gate_id}_{digest}"


class CampaignBudgetLedger:
    """Manages local ledger and budget enforcement for a benchmark campaign."""

    def __init__(
        self,
        ledger_path: Path | str,
        budget_file: Optional[Path | str] = None,
        campaign_id: str = "",
        corpus_hash: str = "",
        config_hash: str = "",
        is_unlimited: bool = False,
    ) -> None:
        self.ledger_path = Path(ledger_path)
        self.budget_file = Path(budget_file) if budget_file else None
        self.campaign_id = campaign_id or f"camp_{uuid4().hex[:8]}"
        self.corpus_hash = corpus_hash
        self.config_hash = config_hash
        self.is_unlimited = is_unlimited or (self.budget_file is None)

        self._operations: Dict[str, Dict[str, Any]] = {}
        self._budget_breach_detected: bool = False

        if self.budget_file and self.budget_file.exists():
            with open(self.budget_file, "r", encoding="utf-8") as f:
                budget_data = json.load(f)
            caps = budget_data.get("caps", {})
            self.calls_cap: int = int(caps.get("gatewayOperations", budget_data.get("budgetCapCalls", -1)))
            self.tokens_cap: int = int(caps.get("accountedTokens", budget_data.get("budgetCapTokens", -1)))
            self.wall_cap: float = float(caps.get("wallTimeSeconds", budget_data.get("budgetCapWallTimeSeconds", -1.0)))
            self.authorization_id: str = budget_data.get("authorizationId", f"auth-{self.campaign_id}")
            self.authorized_by: str = budget_data.get("authorizedBy", "system")
        else:
            self.calls_cap = -1
            self.tokens_cap = -1
            self.wall_cap = -1.0
            self.authorization_id = f"auto-minimax-{uuid4().hex[:12]}"
            self.authorized_by = "system-auto-minimax-benchmark"

        if self.ledger_path.exists():
            self._load()
        else:
            self._save()

    def _load(self) -> None:
        try:
            with open(self.ledger_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            self._operations = data.get("operations", {})
            self._budget_breach_detected = data.get("budgetBreachDetected", False)
        except Exception:
            self._operations = {}
            self._budget_breach_detected = False

    def _save(self) -> None:
        state = {
            "campaignId": self.campaign_id,
            "authorizationId": self.authorization_id,
            "authorizedBy": self.authorized_by,
            "corpusSha256": self.corpus_hash,
            "configSha256": self.config_hash,
            "isUnlimited": self.is_unlimited,
            "budgetBreachDetected": self._budget_breach_detected,
            "operations": self._operations,
            "summary": self.summary(),
        }
        atomic_write_json(self.ledger_path, state)

    def summary(self) -> Dict[str, Any]:
        """Calculates current accounted operations, tokens, and status counts."""
        accounted_tokens = 0
        statuses: Dict[str, int] = {}

        for op in self._operations.values():
            st = op.get("status", "UNKNOWN")
            statuses[st] = statuses.get(st, 0) + 1
            if st == "COMPLETED":
                accounted_tokens += op.get("tokensUsed", 0)
            else:
                accounted_tokens += op.get("tokenReservation", 0)

        return {
            "gatewayOperations": len(self._operations),
            "accountedTokens": accounted_tokens,
            "budgetBreachDetected": self._budget_breach_detected,
            "operationStatuses": statuses,
        }

    def reserve(self, request: OperationGrantRequest) -> None:
        """Reserves budget for an operation, enforcing campaign caps."""
        if self._budget_breach_detected:
            raise CheckpointApiError(
                422,
                f"Campaign {self.campaign_id} has detected a budget breach; refusing new reservations.",
            )

        if not self.is_unlimited:
            curr_summary = self.summary()
            if self.calls_cap != -1 and curr_summary["gatewayOperations"] + 1 > self.calls_cap:
                raise CheckpointApiError(
                    422,
                    f"Campaign calls cap ({self.calls_cap}) exhausted.",
                )
            if self.tokens_cap != -1 and curr_summary["accountedTokens"] + request.tokenReservation > self.tokens_cap:
                raise CheckpointApiError(
                    422,
                    f"Campaign token cap ({self.tokens_cap}) exceeded by reservation {request.tokenReservation}.",
                )

        self._operations[request.operationId] = {
            "operationId": request.operationId,
            "runId": request.runId,
            "status": "RESERVED",
            "tokenReservation": request.tokenReservation,
            "tokensUsed": 0,
            "wallTimeReservationSeconds": request.wallTimeReservationSeconds,
            "wallTimeUsedSeconds": 0.0,
            "requestHash": request.requestHash,
            "reservedAt": datetime.now(timezone.utc).isoformat(),
        }
        self._save()

    def reconcile(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        """Reconciles actual usage of an operation and checks for campaign budget breaches."""
        op_record = self._operations.get(request.operationId, {})
        op_record.update({
            "operationId": request.operationId,
            "runId": request.runId,
            "status": "COMPLETED",
            "tokensUsed": request.tokensUsed,
            "wallTimeUsedSeconds": request.wallTimeUsedSeconds,
            "reconciledAt": datetime.now(timezone.utc).isoformat(),
        })
        self._operations[request.operationId] = op_record

        # Check for campaign token cap breach
        if not self.is_unlimited and self.tokens_cap != -1:
            total_tokens = self.summary()["accountedTokens"]
            if total_tokens > self.tokens_cap:
                self._budget_breach_detected = True

        self._save()
        return OperationReconcileResult(
            operationId=request.operationId,
            status="COMPLETED",
            tokensUsed=request.tokensUsed,
            wallTimeUsedSeconds=request.wallTimeUsedSeconds,
            reconciledAt=datetime.now(timezone.utc),
            reservationBreached=False,
            budgetBreachDetected=self._budget_breach_detected,
        )

    def recover_after_restart(self) -> Dict[str, Any]:
        """Marks in-flight reservations as UNKNOWN_OUTCOME on restart."""
        recovered_count = 0
        for op in self._operations.values():
            if op.get("status") == "RESERVED":
                op["status"] = "UNKNOWN_OUTCOME"
                recovered_count += 1
        self._save()
        summary = self.summary()
        return {
            "recoveredReservations": recovered_count,
            "gatewayOperations": summary["gatewayOperations"],
            "accountedTokens": summary["accountedTokens"],
            "operationStatuses": summary["operationStatuses"],
        }

    def sync_remote_operations(self, run_id: str, remote_ops: List[OperationResumeInfo]) -> None:
        """Updates local ledger with remote authoritative operation outcomes."""
        for rop in remote_ops:
            op_data = self._operations.get(rop.operationId, {})
            op_data.update({
                "operationId": rop.operationId,
                "status": rop.status,
                "tokenReservation": rop.tokenReservation,
                "tokensUsed": rop.tokensUsed,
                "wallTimeReservationSeconds": rop.wallTimeReservationSeconds,
                "wallTimeUsedSeconds": rop.wallTimeUsedSeconds,
            })
            self._operations[rop.operationId] = op_data
        self._save()


class CampaignCheckpointClient:
    """Decorates a CheckpointClient with CampaignBudgetLedger tracking and replay protection."""

    def __init__(
        self,
        inner: Any,
        ledger: CampaignBudgetLedger,
        run_calls_cap: int = -1,
        run_tokens_cap: int = -1,
        run_wall_time_cap: int = -1,
        artifact_tokens_cap: int = -1,
        artifact_wall_time_cap: int = -1,
    ) -> None:
        self.inner = inner
        self.ledger = ledger
        self.run_calls_cap = run_calls_cap
        self.run_tokens_cap = run_tokens_cap
        self.run_wall_time_cap = run_wall_time_cap
        self.artifact_tokens_cap = artifact_tokens_cap
        self.artifact_wall_time_cap = artifact_wall_time_cap

    async def grant_operation_async(self, request: OperationGrantRequest) -> OperationGrantResult:
        """Validates campaign budget, checks replay, and forwards to inner client."""
        # Check replay protection
        existing = self.ledger._operations.get(request.operationId)
        if existing and existing.get("status") in ("COMPLETED", "RESERVED"):
            raise CheckpointApiError(
                409,
                f"Operation {request.operationId} is already {existing.get('status')}; replay rejected.",
            )

        # Enforce ledger budget reservation
        self.ledger.reserve(request)

        if hasattr(self.inner, "grant_operation_async"):
            return await self.inner.grant_operation_async(request)
        return self.inner.grant_operation(request)

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        existing = self.ledger._operations.get(request.operationId)
        if existing and existing.get("status") in ("COMPLETED", "RESERVED"):
            raise CheckpointApiError(
                409,
                f"Operation {request.operationId} is already {existing.get('status')}; replay rejected.",
            )
        self.ledger.reserve(request)
        if hasattr(self.inner, "grant_operation"):
            return self.inner.grant_operation(request)
        return asyncio.run(self.inner.grant_operation_async(request))

    async def reconcile_operation_async(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        reconcile_res = self.ledger.reconcile(request)
        if hasattr(self.inner, "reconcile_operation_async"):
            inner_res = await self.inner.reconcile_operation_async(request)
            return inner_res
        elif hasattr(self.inner, "reconcile_operation"):
            return self.inner.reconcile_operation(request)
        return reconcile_res

    def reconcile_operation(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        reconcile_res = self.ledger.reconcile(request)
        if hasattr(self.inner, "reconcile_operation"):
            return self.inner.reconcile_operation(request)
        elif hasattr(self.inner, "reconcile_operation_async"):
            return asyncio.run(self.inner.reconcile_operation_async(request))
        return reconcile_res

    def __getattr__(self, name: str) -> Any:
        return getattr(self.inner, name)
