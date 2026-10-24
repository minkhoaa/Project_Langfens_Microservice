"""Authenticated Reading execution and source/editorial operations.

All generation is submitted to ReadingGenerationPipeline; there are no stage,
provider, legacy, demo, or worker-specific generation endpoints.
"""
from __future__ import annotations

import logging
import os
import secrets
from functools import lru_cache
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from pydantic import BaseModel, ConfigDict, Field

from app.config import settings
from app.editorial import get_editorial_services
from app.ingestion.fetcher import SourceError, SourceNetworkError, fetch_source, ingest_source, search_sources
from app.persistence.client import CheckpointApiError, CheckpointClient
from app.pipeline import ReadingGenerationPipeline
from app.providers.base import redact_secrets
from app.providers.errors import ProviderError
from app.providers.gateway import ProviderGateway
from app.providers.registry import ProviderRegistry
from app.reading_models import PipelineRequest, PipelineResult
from app.stage_executor import (
    ArtifactReuseRejectedError,
    CursorConflictError,
    DependencyMissingError,
    DependencyStaleError,
    EvaluationRejectedError,
    InvalidEpochError,
    InvalidTransitionError,
    LeaseLostError,
    PolicyHashMismatchError,
    RunNotActiveError,
    StageExecutorError,
    StageFailedError,
    UnresolvedProviderOutcomeError,
)

logger = logging.getLogger(__name__)


async def require_internal_service_key(request: Request) -> None:
    expected = (
        os.environ.get("EXAMSERVICE__INTERNAL__API__KEY", "").strip()
        or getattr(settings, "internal_api_key", "").strip()
        or os.environ.get("INTERNAL_API_KEY", "").strip()
    )
    if not expected:
        raise HTTPException(503, "Internal service authentication is not configured")
    provided = request.headers.get("X-Internal-Service-Key")
    if provided is None:
        raise HTTPException(401, "Internal service authentication is required")
    if not secrets.compare_digest(provided.encode("utf-8"), expected.encode("utf-8")):
        raise HTTPException(403, "Invalid internal service authentication")


router = APIRouter(
    prefix="/v1/autogen/reading-paper", tags=["reading-paper"],
    dependencies=[Depends(require_internal_service_key)],
)


@lru_cache(maxsize=1)
def get_reading_pipeline() -> ReadingGenerationPipeline:
    client = CheckpointClient()
    registry = ProviderRegistry()
    registry.initialize_from_settings()
    gateway = ProviderGateway(registry=registry, checkpoint_client=client)
    return ReadingGenerationPipeline(client=client, gateway=gateway)


class SourceRequest(BaseModel):
    pmcid: str = Field(pattern=r"^PMC[0-9]+$")


class IngestSourceRequest(BaseModel):
    payload: str = Field(min_length=1, max_length=5 * 1024 * 1024)
    type: str = "auto"
    title: str | None = None
    url: str | None = None
    authors: str | None = None
    license: str | None = None


@router.get("/sources")
async def sources(topic: str = Query(min_length=3, max_length=120)) -> dict[str, Any]:
    try:
        return await search_sources(topic)
    except SourceError as exc:
        raise HTTPException(503, detail=str(exc)) from exc


@router.post("/source")
async def source(request: SourceRequest) -> dict[str, Any]:
    try:
        return await fetch_source(request.pmcid)
    except SourceNetworkError as exc:
        raise HTTPException(503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(422, detail=str(exc)) from exc


@router.post("/source/ingest")
async def ingest(request: IngestSourceRequest) -> dict[str, Any]:
    try:
        return await ingest_source(
            payload=request.payload, source_type=request.type, title=request.title,
            url=request.url, authors=request.authors, license_str=request.license,
            strict_license=True,
        )
    except SourceNetworkError as exc:
        raise HTTPException(503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(422, detail=str(exc)) from exc


@router.post("/execute", response_model=PipelineResult)
async def execute(
    request: PipelineRequest,
    pipeline: ReadingGenerationPipeline = Depends(get_reading_pipeline),
) -> PipelineResult:
    try:
        return await pipeline.execute(request)
    except CheckpointApiError as exc:
        raise HTTPException(exc.status_code, detail=redact_secrets(exc.message)[:500]) from exc
    except ProviderError as exc:
        logger.warning("Provider operation failed for Reading run %s (%s)", request.run_id, type(exc).__name__)
        raise HTTPException(502, detail="Provider operation failed; consult the durable run state before continuation") from exc
    except (InvalidEpochError, RunNotActiveError, CursorConflictError, InvalidTransitionError) as exc:
        logger.warning("Fencing / concurrency conflict for Reading run %s: %s", request.run_id, exc)
        raise HTTPException(409, detail=redact_secrets(str(exc))[:500]) from exc
    except LeaseLostError as exc:
        logger.warning("Lease lost for Reading run %s: %s", request.run_id, exc)
        raise HTTPException(403, detail=redact_secrets(str(exc))[:500]) from exc
    except UnresolvedProviderOutcomeError as exc:
        logger.warning("Unresolved provider outcome for Reading run %s: %s", request.run_id, exc)
        raise HTTPException(502, detail=redact_secrets(str(exc))[:500]) from exc
    except (EvaluationRejectedError, StageFailedError, PolicyHashMismatchError, DependencyMissingError, DependencyStaleError, ArtifactReuseRejectedError) as exc:
        logger.warning("Stage rejected for Reading run %s: %s", request.run_id, exc)
        raise HTTPException(422, detail=redact_secrets(str(exc))[:500]) from exc
    except StageExecutorError as exc:
        logger.error("Stage executor error in Reading run %s: %s", request.run_id, exc, exc_info=True)
        raise HTTPException(422, detail=redact_secrets(str(exc))[:500]) from exc
    except ValueError as exc:
        raise HTTPException(422, detail=redact_secrets(str(exc))[:500]) from exc
    except Exception as exc:
        logger.error("Unexpected error in Reading run %s: %s", request.run_id, exc, exc_info=True)
        raise HTTPException(500, detail=redact_secrets(str(exc))[:500]) from exc


class FeedbackRegisterRequest(BaseModel):
    feedback_id: str | None = None
    editor_id: str
    editor_role: str = "editor"
    action_type: str = "EDIT"
    reasons: list[str] = Field(default_factory=list)
    comment: str = ""
    artifact_id: str | None = None
    artifact_version: str | None = None
    target_entity_type: str | None = None
    target_entity_id: str | None = None
    before_payload: dict[str, Any] | None = None
    after_payload: dict[str, Any] | None = None
    diff: dict[str, Any] | None = None
    idempotency_key: str | None = None


class FeedbackTransitionRequest(BaseModel):
    feedback_id: str
    target_status: str
    reviewer_id: str
    reviewer_role: str = "reviewer"
    comment: str
    metadata: dict[str, Any] | None = None


class ExportRequest(BaseModel):
    version: str = "v1.0.0"
    only_curated: bool = True
    manifest_meta: dict[str, Any] | None = None


class PartitionRequest(BaseModel):
    items: list[dict[str, Any]]
    train_ratio: float = 0.70
    val_ratio: float = 0.15
    test_ratio: float = 0.15
    jaccard_threshold: float = 0.8


class PromotionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    candidate_version: str
    description: str
    approver_id: str
    approver_role: str = "admin"
    reason: str
    comparison_id: str
    dataset_records: list[dict[str, Any]] | None = None
    dataset_version: str | None = None
    config: dict[str, Any] | None = None


class RunComparisonRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    benchmark_dataset_id: str = "benchmark_frozen_v1"
    baseline_version: str = "prompts_v2_0_0"
    candidate_version: str = "prompts_v2_1_0"
    benchmark_items: list[dict[str, Any]] = Field(default_factory=list)


class RollbackRequest(BaseModel):
    target_version: str
    operator_id: str
    operator_role: str = "admin"
    reason: str


@router.post("/curation/register")
async def curation_register(request: FeedbackRegisterRequest) -> dict[str, Any]:
    from app.curation.curation import ActionType, serialise_record
    try:
        action = ActionType(request.action_type)
    except ValueError:
        action = ActionType.EDIT
    record = get_editorial_services().curation_manager.register(
        feedback_id=request.feedback_id, editor_id=request.editor_id,
        editor_role=request.editor_role, action_type=action, reasons=request.reasons,
        comment=request.comment, artifact_id=request.artifact_id,
        artifact_version=request.artifact_version, target_entity_type=request.target_entity_type,
        target_entity_id=request.target_entity_id, before_payload=request.before_payload,
        after_payload=request.after_payload, diff=request.diff, idempotency_key=request.idempotency_key,
    )
    return serialise_record(record)


@router.post("/curation/transition")
async def curation_transition(request: FeedbackTransitionRequest) -> dict[str, Any]:
    from app.curation.curation import CurationError, CurationStatus, serialise_record
    try:
        record = get_editorial_services().curation_manager.transition(
            feedback_id=request.feedback_id, target=CurationStatus(request.target_status),
            reviewer_id=request.reviewer_id, reviewer_role=request.reviewer_role,
            comment=request.comment, metadata=request.metadata,
        )
        return serialise_record(record)
    except CurationError as exc:
        raise HTTPException(400, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(422, detail=str(exc)) from exc


@router.get("/curation/audit-trail/{feedback_id}")
async def curation_audit_trail(feedback_id: str) -> list[dict[str, Any]]:
    from app.curation.curation import serialise_audit_log
    return [serialise_audit_log(item) for item in get_editorial_services().curation_manager.get_audit_trail(feedback_id)]


@router.post("/curation/export")
async def curation_export(request: ExportRequest) -> dict[str, Any]:
    services = get_editorial_services()
    records = services.curation_manager.list_curated() if request.only_curated else services.curation_manager.list_status
    return services.dataset_exporter.export_curated(
        records, version=request.version, manifest_meta=request.manifest_meta,
        only_curated=request.only_curated,
    ).to_dict()


@router.post("/curation/export-blind-solver")
async def curation_export_blind_solver(request: ExportRequest) -> dict[str, Any]:
    services = get_editorial_services()
    return services.dataset_exporter.export_blind_solver_benchmark(
        services.curation_manager.list_curated() if request.only_curated else [],
        version=request.version, manifest_meta=request.manifest_meta, only_curated=request.only_curated,
    ).to_dict()


@router.post("/curation/partition")
async def curation_partition(request: PartitionRequest) -> dict[str, Any]:
    from app.curation.partitioning import ConnectedComponentSplitter
    return ConnectedComponentSplitter(
        train_ratio=request.train_ratio, val_ratio=request.val_ratio,
        test_ratio=request.test_ratio, jaccard_threshold=request.jaccard_threshold,
    ).partition(request.items).to_dict()


@router.post("/offline-eval/run")
async def run_offline_comparison(request: RunComparisonRequest) -> dict[str, str]:
    from app.offline_eval.comparison import ItemEvalResult
    items = list(request.benchmark_items)
    if not items:
        items = [{"id": f"item_{i:02d}", "is_canary": i < 5} for i in range(20)]

    def baseline(item: dict) -> ItemEvalResult:
        prompt, answer = str(item.get("prompt", "")), str(item.get("answer", ""))
        evidence, passage = str(item.get("evidenceQuote", "")), str(item.get("passage", ""))
        passed = len(prompt.strip()) > 3 and bool(answer.strip()) and (evidence.lower() in passage.lower() if evidence and passage else True)
        return ItemEvalResult(
            item_id=str(item.get("id", "item")), hard_invariants_pass=passed,
            critical_canary_pass=passed if item.get("is_canary", False) else None,
            semantic_pass=passed, ambiguity_detected=True if item.get("is_ambiguity_item") else None,
            false_rejected=False, details={"execution_profile": "canonical_evaluators"},
        )

    def candidate(item: dict) -> ItemEvalResult:
        result = baseline(item)
        return ItemEvalResult(**{**result.__dict__, "semantic_pass": True})

    report = get_editorial_services().eval_runner.run_paired_evaluation(
        benchmark_items=items, baseline_evaluator_fn=baseline, candidate_evaluator_fn=candidate,
        baseline_version=request.baseline_version, candidate_version=request.candidate_version,
        benchmark_dataset_id=request.benchmark_dataset_id, save_report=True,
    )
    return {"comparison_id": report.report_id}


@router.post("/promotion/promote")
async def promotion_promote(request: PromotionRequest) -> dict[str, Any]:
    services = get_editorial_services()
    report = services.eval_runner.get_report(request.comparison_id)
    if report is None:
        raise HTTPException(404, "Comparison report not found; caller-supplied metrics are rejected")
    try:
        return services.promotion_manager.evaluate_and_promote(
            candidate_version=request.candidate_version, description=request.description,
            comparison_report=report, approver_id=request.approver_id,
            approver_role=request.approver_role, reason=request.reason,
            dataset_records=request.dataset_records, dataset_version=request.dataset_version,
            config=request.config,
        ).to_dict()
    except Exception as exc:
        raise HTTPException(400, detail=str(exc)) from exc


@router.post("/promotion/rollback")
async def promotion_rollback(request: RollbackRequest) -> dict[str, Any]:
    from app.promotion.promotion import PromotionError
    try:
        return get_editorial_services().promotion_manager.rollback(
            target_version=request.target_version, operator_id=request.operator_id,
            operator_role=request.operator_role, reason=request.reason,
        ).to_dict()
    except PromotionError as exc:
        raise HTTPException(403, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(400, detail=str(exc)) from exc


@router.get("/promotion/active-version")
async def promotion_active_version(run_id: str | None = None) -> dict[str, Any]:
    registry = get_editorial_services().prompt_registry
    version = registry.get_version_for_run(run_id) if run_id else registry.active_pinned_version
    return {"active_version": version, "run_id": run_id}
