import json
import os
from typing import Any, Dict, Optional
from uuid import UUID
import httpx

from app.persistence.models import (
    OperationGrantRequest,
    OperationGrantResult,
    CheckpointCommitRequest,
    DraftCheckpointRequest,
    CheckpointAck,
    ResumeStateResult,
    InvalidateDependencyRequest,
    LoopCursorCheckpointRequest,
    LoopCursorCheckpoint,
    InvalidateDependencyResult,
    BuildExamInternalRequest,
    BuildExamInternalResult,
    SetBudgetAllocationsRequest,
    SetBudgetAllocationsResult,
    OperationReconcileRequest,
    OperationReconcileResult,
)


class CheckpointApiError(Exception):
    def __init__(self, status_code: int, message: str, payload: Optional[Dict[str, Any]] = None):
        super().__init__(f"HTTP {status_code}: {message}")
        self.status_code = status_code
        self.message = message
        self.payload = payload or {}


class CheckpointClient:
    """Authenticated persistence client for Loop Engine V2 communicating with exam-service.
    
    Adheres strictly to ADR-001 (Authoritative Persistence Ownership) and
    ADR-002 (Fencing Epoch & Checkpoint Ack).
    """

    def __init__(
        self,
        base_url: Optional[str] = None,
        internal_api_key: Optional[str] = None,
        timeout: float = 30.0,
    ):
        self.base_url = (
            base_url
            or os.environ.get("EXAM_SERVICE_URL")
            or "http://localhost:5000"
        ).rstrip("/")
        self.internal_api_key = (
            internal_api_key
            or os.environ.get("EXAMSERVICE__INTERNAL__API__KEY")
            or os.environ.get("InternalApiKey")
        )
        if not self.internal_api_key:
            raise ValueError(
                "EXAMSERVICE__INTERNAL__API__KEY is not configured; refusing to use insecure default."
            )
        self.timeout = timeout

    def _get_headers(self) -> Dict[str, str]:
        return {
            "Content-Type": "application/json",
            "X-Internal-Service-Key": self.internal_api_key,
        }

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/grant-operation"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return OperationGrantResult.model_validate(resp.json())

    async def grant_operation_async(self, request: OperationGrantRequest) -> OperationGrantResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/grant-operation"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return OperationGrantResult.model_validate(resp.json())

    def set_budget_allocations(self, request: SetBudgetAllocationsRequest) -> SetBudgetAllocationsResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/budgets/allocate"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return SetBudgetAllocationsResult.model_validate(resp.json())

    async def set_budget_allocations_async(self, request: SetBudgetAllocationsRequest) -> SetBudgetAllocationsResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/budgets/allocate"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return SetBudgetAllocationsResult.model_validate(resp.json())
    def reconcile_operation(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/operations/reconcile"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return OperationReconcileResult.model_validate(resp.json())

    async def reconcile_operation_async(self, request: OperationReconcileRequest) -> OperationReconcileResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/operations/reconcile"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return OperationReconcileResult.model_validate(resp.json())


    def commit_checkpoint(self, request: CheckpointCommitRequest) -> CheckpointAck:
        """Atomically commits artifact, evaluations, decisions, CAS head and outbox.
        
        CRITICAL: The generation runtime MUST NOT advance until this synchronous
        acknowledgement is durably verified against the requested artifact.
        """
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/commit"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            ack = CheckpointAck.model_validate(resp.json())
            self._verify_ack(request, ack)
            return ack

    async def commit_checkpoint_async(self, request: CheckpointCommitRequest) -> CheckpointAck:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/commit"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            ack = CheckpointAck.model_validate(resp.json())
            self._verify_ack(request, ack)
            return ack

    def save_draft_checkpoint(self, request: DraftCheckpointRequest) -> CheckpointAck:
        """Saves a draft artifact checkpoint without promoting accepted head."""
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/draft"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            ack = CheckpointAck.model_validate(resp.json())
            self._verify_ack(request, ack)
            return ack

    async def save_draft_checkpoint_async(self, request: DraftCheckpointRequest) -> CheckpointAck:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/draft"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            ack = CheckpointAck.model_validate(resp.json())
            self._verify_ack(request, ack)
            return ack
    def record_unknown_outcome(self, request: UnknownOutcomeRequest) -> UnknownOutcomeAck:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/unknown-outcome"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return UnknownOutcomeAck.model_validate(resp.json())
    async def record_unknown_outcome_async(self, request: UnknownOutcomeRequest) -> UnknownOutcomeAck:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/unknown-outcome"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return UnknownOutcomeAck.model_validate(resp.json())


    def save_loop_cursor(self, request: LoopCursorCheckpointRequest) -> LoopCursorCheckpoint:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/loop/cursor"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            result = LoopCursorCheckpoint.model_validate(resp.json())
            if result.artifactId != request.artifactId or result.revision != request.expectedRevision + 1 or result.stateJson != request.stateJson:
                raise CheckpointApiError(409, "Loop cursor acknowledgement mismatch")
            return result

    def resume_state(self, run_id: str) -> ResumeStateResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/resume/{run_id}"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.get(url, headers=self._get_headers())
            if resp.status_code != 200:
                self._handle_error(resp)
            return ResumeStateResult.model_validate(resp.json())

    def invalidate_dependencies(self, request: InvalidateDependencyRequest) -> InvalidateDependencyResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/invalidate"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return InvalidateDependencyResult.model_validate(resp.json())

    def build_exam(self, request: BuildExamInternalRequest) -> BuildExamInternalResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/build-exam"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return BuildExamInternalResult.model_validate(resp.json())

    def _verify_ack(self, request: Any, ack: CheckpointAck) -> None:
        if ack.runId != request.runId:
            raise ValueError(f"CheckpointAck runId mismatch: ack={ack.runId}, req={request.runId}")
        if ack.epoch != request.epoch:
            raise ValueError(f"CheckpointAck epoch mismatch: ack={ack.epoch}, req={request.epoch}")
        if ack.artifactId != request.artifact.artifact_id:
            raise ValueError(f"CheckpointAck artifactId mismatch: ack={ack.artifactId}, req={request.artifact.artifact_id}")
        if ack.version != request.artifact.version:
            raise ValueError(f"CheckpointAck version mismatch: ack={ack.version}, req={request.artifact.version}")
        if ack.contentHash.lower() != request.artifact.content_hash.lower():
            raise ValueError(f"CheckpointAck contentHash mismatch: ack={ack.contentHash}, req={request.artifact.content_hash}")

    def _handle_error(self, resp: httpx.Response) -> None:
        try:
            data = resp.json()
            message = data.get("error") or data.get("message") or resp.text
        except Exception:
            message = resp.text
        raise CheckpointApiError(status_code=resp.status_code, message=message)
