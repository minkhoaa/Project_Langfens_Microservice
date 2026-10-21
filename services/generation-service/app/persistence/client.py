import hashlib
import re
import json
import os
from typing import Any, Dict, Optional
from uuid import UUID
import httpx

from app.persistence.models import (
    OperationGrantRequest,
    OperationGrantResult,
    CheckpointCommitRequest,
    CheckpointImportRequest,
    DraftCheckpointRequest,
    CheckpointAck,
    ResumeStateResult,
    InvalidateDependencyRequest,
    LoopCursorCheckpointRequest,
    LoopCursorCheckpoint,
    InvalidateDependencyResult,
    BuildExamInternalRequest,
    BuildExamInternalResult,
    BenchmarkCampaignCreateRequest,
    BenchmarkCampaignStatus,
    BenchmarkCaseProvisionRequest,
    BenchmarkCaseCompleteRequest,
    BenchmarkCaseProvisionResult,
    SetBudgetAllocationsRequest,
    SetBudgetAllocationsResult,
    OperationReconcileRequest,
    OperationReconcileResult,
    UnknownOutcomeRequest,
    UnknownOutcomeAck,
    OutboxEventRecord,
)

# ── Canonical & Legacy Artifact ID Mapping ──────────────────────────────────

SECTION_QUESTION_OFFSETS = {
    1: (1, 13, 0),
    2: (14, 26, 13),
    3: (27, 40, 26),
}


def _q_num_to_sec_slot(q_num: int) -> tuple[int, int]:
    if 1 <= q_num <= 13:
        return 1, q_num
    if 14 <= q_num <= 26:
        return 2, q_num - 13
    if 27 <= q_num <= 40:
        return 3, q_num - 26
    return 1, q_num


def canonicalize_artifact_id(artifact_id: str, run_id: Optional[str] = None) -> str:
    """Converts a legacy or partial artifact ID to the canonical pipeline format."""
    if not artifact_id:
        return artifact_id

    parts = artifact_id.split(":")
    if len(parts) >= 2 and parts[0] in ("source", "evidence", "blueprint", "passage", "question", "section", "paper"):
        if len(parts) == 2 and parts[0] in ("blueprint", "paper"):
            return artifact_id
        if len(parts) == 3:
            return artifact_id

    effective_run_id = run_id or "run"

    # Match legacy passage: art_passage_s1
    m = re.match(r"^art_passage_s(\d+)$", artifact_id)
    if m:
        return f"passage:{effective_run_id}:{m.group(1)}"

    # Match legacy question candidate: art_qcand_s{sec}_{slot} or art_q_s{sec}_{slot}
    m = re.match(r"^art_q(?:cand)?_s([1-3])_(\d+)$", artifact_id)
    if m:
        sec = int(m.group(1))
        slot = int(m.group(2))
        offset = SECTION_QUESTION_OFFSETS[sec][2]
        q_num = offset + slot
        return f"question:{effective_run_id}:{q_num}"

    # Match legacy question with direct number: art_q_{num} or art_qcand_{num} or question_{num}
    m = re.match(r"^(?:art_q(?:cand)?|question)_(\d+)$", artifact_id)
    if m:
        return f"question:{effective_run_id}:{m.group(1)}"

    # Match legacy source: art_source_s(\d+)
    m = re.match(r"^art_source_s(\d+)$", artifact_id)
    if m:
        return f"source:{effective_run_id}:{m.group(1)}"

    # Match legacy evidence: art_evidence_s(\d+)
    m = re.match(r"^art_evidence_s(\d+)$", artifact_id)
    if m:
        return f"evidence:{effective_run_id}:{m.group(1)}"

    # Match legacy blueprint: art_blueprint.*
    if artifact_id == "art_blueprint" or artifact_id.startswith("art_blueprint_"):
        return f"blueprint:{effective_run_id}"

    # Match legacy section: art_section_s(\d+)
    m = re.match(r"^art_section_s(\d+)$", artifact_id)
    if m:
        return f"section:{effective_run_id}:{m.group(1)}"

    # Match legacy paper: art_paper.*
    if artifact_id == "art_paper" or artifact_id.startswith("art_paper_"):
        return f"paper:{effective_run_id}"

    return artifact_id


def legacy_artifact_id(artifact_id: str, run_id: Optional[str] = None) -> str:
    """Converts a canonical artifact ID to the legacy loop format."""
    if not artifact_id:
        return artifact_id

    if artifact_id.startswith("art_"):
        return artifact_id

    parts = artifact_id.split(":")
    if len(parts) >= 2:
        kind = parts[0]
        if kind == "passage" and len(parts) == 3:
            return f"art_passage_s{parts[2]}"
        if kind == "question" and len(parts) == 3:
            try:
                q_num = int(parts[2])
                sec, slot = _q_num_to_sec_slot(q_num)
                return f"art_qcand_s{sec}_{slot}"
            except ValueError:
                return f"art_q_{parts[2]}"
        if kind == "section" and len(parts) == 3:
            return f"art_section_s{parts[2]}"
        if kind == "source" and len(parts) == 3:
            return f"art_source_s{parts[2]}"
        if kind == "evidence" and len(parts) == 3:
            return f"art_evidence_s{parts[2]}"
        if kind == "blueprint":
            return "art_blueprint"
        if kind == "paper":
            return "art_paper"

    return artifact_id


def get_artifact_aliases(artifact_id: str, run_id: Optional[str] = None) -> set[str]:
    """Returns all known identity representations (canonical, legacy variants) for an artifact."""
    aliases: set[str] = {artifact_id}
    canonical = canonicalize_artifact_id(artifact_id, run_id)
    legacy = legacy_artifact_id(artifact_id, run_id)
    aliases.add(canonical)
    aliases.add(legacy)

    parts = canonical.split(":")
    if len(parts) == 3 and parts[0] == "question":
        try:
            q_num = int(parts[2])
            sec, slot = _q_num_to_sec_slot(q_num)
            aliases.add(f"art_qcand_s{sec}_{slot}")
            aliases.add(f"art_q_s{sec}_{slot}")
            aliases.add(f"art_q_{q_num}")
            aliases.add(f"question_{q_num}")
        except ValueError:
            pass

    return aliases

class CheckpointApiError(Exception):
    def __init__(self, status_code: int, message: str, payload: Optional[Dict[str, Any]] = None):
        super().__init__(f"HTTP {status_code}: {message}")
        self.status_code = status_code
        self.message = message
        self.payload = payload or {}


class CheckpointClient:
    """Authenticated persistence client for Loop Engine V2 communicating with exam-service.
    
    Adheres strictly to Authoritative Persistence Ownership and
    Fencing Epoch & Checkpoint Ack principles.
    """

    def __init__(
        self,
        base_url: Optional[str] = None,
        internal_api_key: Optional[str] = None,
        timeout: float = 30.0,
    ):
        self._base_url = base_url
        self._internal_api_key = internal_api_key
        self.timeout = timeout
        if not self.internal_api_key or not self.internal_api_key.strip():
            raise ValueError("EXAMSERVICE__INTERNAL__API__KEY is not configured")

    @property
    def base_url(self) -> str:
        return (
            os.environ.get("EXAM_SERVICE_URL")
            or os.environ.get("EXAMSERVICE__EXAM__ADDRESS")
            or self._base_url
            or "http://localhost:5000"
        ).rstrip("/")

    @base_url.setter
    def base_url(self, value: Optional[str]) -> None:
        self._base_url = value

    @property
    def internal_api_key(self) -> str:
        return (
            os.environ.get("EXAMSERVICE__INTERNAL__API__KEY")
            or os.environ.get("InternalApiKey")
            or self._internal_api_key
            or ""
        )

    @internal_api_key.setter
    def internal_api_key(self, value: Optional[str]) -> None:
        self._internal_api_key = value

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

    def import_checkpoint(self, request: CheckpointImportRequest) -> CheckpointAck:
        """Imports and binds a verified historical/continuation checkpoint."""
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/import"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            ack = CheckpointAck.model_validate(resp.json())
            self._verify_ack(request, ack)
            return ack

    async def import_checkpoint_async(self, request: CheckpointImportRequest) -> CheckpointAck:
        """Async imports and binds a verified historical/continuation checkpoint."""
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/import"
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

    async def resume_state_async(self, run_id: str) -> ResumeStateResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/resume/{run_id}"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.get(url, headers=self._get_headers())
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

    async def create_benchmark_campaign_async(self, request: BenchmarkCampaignCreateRequest) -> BenchmarkCampaignStatus:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/campaigns"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return BenchmarkCampaignStatus.model_validate(resp.json())

    async def get_benchmark_campaign_async(self, campaign_id: str) -> BenchmarkCampaignStatus:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/campaigns/{campaign_id}"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.get(url, headers=self._get_headers())
            if resp.status_code != 200:
                self._handle_error(resp)
            return BenchmarkCampaignStatus.model_validate(resp.json())

    async def provision_benchmark_case_async(self, request: BenchmarkCaseProvisionRequest) -> BenchmarkCaseProvisionResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/campaigns/cases/provision"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return BenchmarkCaseProvisionResult.model_validate(resp.json())

    async def complete_benchmark_case_async(self, request: BenchmarkCaseCompleteRequest) -> BenchmarkCaseProvisionResult:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/campaigns/cases/complete"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.post(url, headers=self._get_headers(), json=request.model_dump(mode="json", by_alias=True))
            if resp.status_code != 200:
                self._handle_error(resp)
            return BenchmarkCaseProvisionResult.model_validate(resp.json())

    def get_outbox_events(self, run_id: str, after_sequence: int = 0) -> list[dict[str, Any]]:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/events/{run_id}?afterSequence={after_sequence}"
        with httpx.Client(timeout=self.timeout) as client:
            resp = client.get(url, headers=self._get_headers())
            if resp.status_code != 200:
                self._handle_error(resp)
            return resp.json()

    async def get_outbox_events_async(self, run_id: str, after_sequence: int = 0) -> list[dict[str, Any]]:
        url = f"{self.base_url}/api/internal/reading-paper/checkpoints/events/{run_id}?afterSequence={after_sequence}"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            resp = await client.get(url, headers=self._get_headers())
            if resp.status_code != 200:
                self._handle_error(resp)
            return resp.json()
    def get_artifact_head(self, run_id: str, artifact_id: str) -> Optional[Any]:
        """Retrieves authoritative head for an artifact, resolving canonical and legacy aliases."""
        from app.contracts.artifact import ArtifactEnvelope
        aliases = get_artifact_aliases(artifact_id, run_id)
        state = self.resume_state(run_id)
        for art_info in (state.artifacts or []):
            if art_info.artifactId in aliases:
                if art_info.envelopeJson:
                    return ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                payload = json.loads(art_info.payloadJson) if isinstance(art_info.payloadJson, str) else (art_info.payloadJson or {})
                return ArtifactEnvelope.create(
                    artifact_id=art_info.artifactId,
                    artifact_type=art_info.artifactType,
                    run_id=run_id,
                    payload=payload,
                    producer_version="1.0.0",
                    version=art_info.acceptedVersion,
                )
        return None

    async def get_artifact_head_async(self, run_id: str, artifact_id: str) -> Optional[Any]:
        from app.contracts.artifact import ArtifactEnvelope
        aliases = get_artifact_aliases(artifact_id, run_id)
        state = await self.resume_state_async(run_id)
        for art_info in (state.artifacts or []):
            if art_info.artifactId in aliases:
                if art_info.envelopeJson:
                    return ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                payload = json.loads(art_info.payloadJson) if isinstance(art_info.payloadJson, str) else (art_info.payloadJson or {})
                return ArtifactEnvelope.create(
                    artifact_id=art_info.artifactId,
                    artifact_type=art_info.artifactType,
                    run_id=run_id,
                    payload=payload,
                    producer_version="1.0.0",
                    version=art_info.acceptedVersion,
                )
        return None

    def get_artifact(self, run_id: str, artifact_id: str, version: Optional[int] = None) -> Optional[Any]:
        """Retrieves an accepted head or draft artifact by ID and optional version with alias resolution."""
        from app.contracts.artifact import ArtifactEnvelope
        aliases = get_artifact_aliases(artifact_id, run_id)
        state = self.resume_state(run_id)
        for art_info in (state.artifacts or []):
            if art_info.artifactId in aliases:
                if version is None or art_info.acceptedVersion == version:
                    if art_info.envelopeJson:
                        return ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                    payload = json.loads(art_info.payloadJson) if isinstance(art_info.payloadJson, str) else (art_info.payloadJson or {})
                    return ArtifactEnvelope.create(
                        artifact_id=art_info.artifactId,
                        artifact_type=art_info.artifactType,
                        run_id=run_id,
                        payload=payload,
                        producer_version="1.0.0",
                        version=art_info.acceptedVersion,
                    )
        for draft_info in (state.draftArtifacts or []):
            if draft_info.artifactId in aliases:
                if version is None or draft_info.acceptedVersion == version:
                    if draft_info.envelopeJson:
                        return ArtifactEnvelope.model_validate_json(draft_info.envelopeJson)
                    payload = json.loads(draft_info.payloadJson) if isinstance(draft_info.payloadJson, str) else (draft_info.payloadJson or {})
                    return ArtifactEnvelope.create(
                        artifact_id=draft_info.artifactId,
                        artifact_type=draft_info.artifactType,
                        run_id=run_id,
                        payload=payload,
                        producer_version="1.0.0",
                        version=draft_info.acceptedVersion,
                    )
        return None

    async def get_artifact_async(self, run_id: str, artifact_id: str, version: Optional[int] = None) -> Optional[Any]:
        from app.contracts.artifact import ArtifactEnvelope
        aliases = get_artifact_aliases(artifact_id, run_id)
        state = await self.resume_state_async(run_id)
        for art_info in (state.artifacts or []):
            if art_info.artifactId in aliases:
                if version is None or art_info.acceptedVersion == version:
                    if art_info.envelopeJson:
                        return ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                    payload = json.loads(art_info.payloadJson) if isinstance(art_info.payloadJson, str) else (art_info.payloadJson or {})
                    return ArtifactEnvelope.create(
                        artifact_id=art_info.artifactId,
                        artifact_type=art_info.artifactType,
                        run_id=run_id,
                        payload=payload,
                        producer_version="1.0.0",
                        version=art_info.acceptedVersion,
                    )
        for draft_info in (state.draftArtifacts or []):
            if draft_info.artifactId in aliases:
                if version is None or draft_info.acceptedVersion == version:
                    if draft_info.envelopeJson:
                        return ArtifactEnvelope.model_validate_json(draft_info.envelopeJson)
                    payload = json.loads(draft_info.payloadJson) if isinstance(draft_info.payloadJson, str) else (draft_info.payloadJson or {})
                    return ArtifactEnvelope.create(
                        artifact_id=draft_info.artifactId,
                        artifact_type=draft_info.artifactType,
                        run_id=run_id,
                        payload=payload,
                        producer_version="1.0.0",
                        version=draft_info.acceptedVersion,
                    )
        return None

    def commit_artifact(self, request: CheckpointCommitRequest) -> CheckpointAck:
        """Alias for commit_checkpoint for seamless artifact persistence."""
        return self.commit_checkpoint(request)

    async def commit_artifact_async(self, request: CheckpointCommitRequest) -> CheckpointAck:
        return await self.commit_checkpoint_async(request)
    def _verify_ack(self, request: Any, ack: CheckpointAck) -> None:
        req_run_id = getattr(request, "runId", getattr(request, "run_id", None))
        req_epoch = getattr(request, "epoch", None)
        if req_run_id is not None and ack.runId != req_run_id:
            raise ValueError(f"CheckpointAck runId mismatch: ack={ack.runId}, req={req_run_id}")
        if req_epoch is not None and ack.epoch != req_epoch:
            raise ValueError(f"CheckpointAck epoch mismatch: ack={ack.epoch}, req={req_epoch}")
        if hasattr(request, "artifact") and request.artifact:
            art_id = getattr(request.artifact, "artifact_id", getattr(request.artifact, "artifactId", None))
            art_ver = getattr(request.artifact, "version", None)
            art_hash = getattr(request.artifact, "content_hash", getattr(request.artifact, "contentHash", None))
            if art_id and ack.artifactId != art_id:
                raise ValueError(f"CheckpointAck artifactId mismatch: ack={ack.artifactId}, req={art_id}")
            if art_ver is not None and ack.version != art_ver:
                raise ValueError(f"CheckpointAck version mismatch: ack={ack.version}, req={art_ver}")
            if art_hash and ack.contentHash.lower() != art_hash.lower():
                raise ValueError(f"CheckpointAck contentHash mismatch: ack={ack.contentHash}, req={art_hash}")

    def _handle_error(self, resp: httpx.Response) -> None:
        try:
            data = resp.json()
            message = data.get("error") or data.get("message") or resp.text
        except Exception:
            message = resp.text
        raise CheckpointApiError(status_code=resp.status_code, message=message)
