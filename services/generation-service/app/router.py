"""Internal Reading-paper operations used by exam-service jobs."""
from __future__ import annotations

import asyncio
import json
import logging
import traceback
from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, Request
from pydantic import BaseModel, Field
from starlette.responses import StreamingResponse

from app.extractor import (
    SourceError,
    SourceNetworkError,
    fetch_source,
    ingest_source,
    search_sources,
)
from app.pipeline import generate_section

router = APIRouter(prefix="/v1/autogen/reading-paper", tags=["reading-paper"])
logger = logging.getLogger(__name__)


class SourceRequest(BaseModel):
    pmcid: str = Field(pattern=r"^PMC[0-9]+$")


class IngestSourceRequest(BaseModel):
    payload: str = Field(min_length=1)
    type: str = Field(default="auto")
    title: str | None = None
    url: str | None = None
    authors: str | None = None
    license: str | None = None


class SectionRequest(BaseModel):
    topic: str = Field(min_length=3, max_length=120)
    index: int = Field(ge=1, le=3)
    source: dict[str, Any]
    provider: str | None = None
    run_id: str = Field(alias="runId")
    epoch: int = 1
    lease_owner: UUID = Field(alias="leaseOwner")
    parent_operation_id: str = Field(alias="parentOperationId")
    engine: str | None = None
    blueprint_ref: dict[str, Any] | None = Field(default=None, alias="blueprintRef")
    evidence_graph_ref: dict[str, Any] | None = Field(default=None, alias="evidenceGraphRef")

class QuestionsRequest(BaseModel):
    passage_ref: dict[str, Any] = Field(alias="passageRef")
    blueprint_ref: dict[str, Any] = Field(alias="blueprintRef")
    slots: list[dict[str, Any]] = Field(default_factory=list)
    run_id: str = Field(alias="runId")
    lease_owner: UUID = Field(alias="leaseOwner")
    epoch: int = 1
    section_index: int = Field(default=1, alias="sectionIndex")
    engine: str = "v2"

@router.get("/sources")
async def sources(topic: str = Query(min_length=3, max_length=120)) -> dict[str, Any]:
    try:
        return await search_sources(topic)
    except SourceError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc


@router.post("/source")
async def source(request: SourceRequest) -> dict[str, Any]:
    try:
        result = await fetch_source(request.pmcid)
        return {key: value for key, value in result.items() if key != "content"}
    except SourceNetworkError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc


@router.post("/source/ingest")
async def ingest(request: IngestSourceRequest) -> dict[str, Any]:
    try:
        result = await ingest_source(
            payload=request.payload,
            source_type=request.type,
            title=request.title,
            url=request.url,
            authors=request.authors,
            license_str=request.license,
        )
        return result
    except SourceNetworkError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc


@router.post("/questions")
async def questions(request: QuestionsRequest, http_request: Request) -> Any:
    from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
    from app.facade import get_generation_facade
    from app.loop.policy import LoopPolicy

    try:
        p_ref = ArtifactRef.model_validate(request.passage_ref)
        bp_ref = ArtifactRef.model_validate(request.blueprint_ref)
    except Exception as exc:
        raise HTTPException(status_code=422, detail=f"Invalid dependency reference schema: {exc}")

    if p_ref.artifact_type != ArtifactType.PASSAGE:
        raise HTTPException(
            status_code=422,
            detail=f"Expected passageRef to be ArtifactType.PASSAGE, got {p_ref.artifact_type}",
        )

    facade = get_generation_facade()
    client = facade.get_persistence_client()

    passage_art = None
    try:
        res_state = client.resume_state(request.run_id)
        for art in (res_state.artifacts or []):
            if art.artifactId == p_ref.artifact_id and art.acceptedVersion == p_ref.version:
                if not art.isStale and art.acceptedHash.lower() == p_ref.content_hash.lower():
                    if art.envelopeJson:
                        passage_art = ArtifactEnvelope.model_validate_json(art.envelopeJson)
                    else:
                        payload = json.loads(art.payloadJson) if hasattr(art, "payloadJson") else {}
                        passage_art = ArtifactEnvelope.create(
                            artifact_id=art.artifactId,
                            artifact_type=ArtifactType.PASSAGE,
                            version=art.acceptedVersion,
                            payload=payload,
                            parent_refs=getattr(art, "parentRefs", []),
                            run_id=request.run_id,
                        )
                    break
    except Exception as exc:
        logger.warning("Error fetching durable state: %s", exc)

    if not passage_art:
        raise HTTPException(
            status_code=422,
            detail="Passage dependency missing, stale, or hash mismatched in authoritative persistence store",
        )

    slots = request.slots
    if not slots:
        base_num = (request.section_index - 1) * 13 + 1
        slots = [
            {"number": base_num, "type": "TrueFalseNotGiven"},
            {"number": base_num + 1, "type": "TrueFalseNotGiven"},
            {"number": base_num + 2, "type": "TrueFalseNotGiven"},
            {"number": base_num + 3, "type": "SentenceCompletion"},
        ]

    policy = LoopPolicy.from_settings(
        max_total_tokens=100000,
        max_wall_time_seconds=600.0,
        required_evaluator_ids=(
            "eval_question_structure",
            "eval_answer_verbatim_length",
        ),
    )

    try:
        res = await facade.generate_questions_v2(
            passage_artifact=passage_art,
            blueprint_ref=bp_ref,
            question_slots=slots,
            run_id=request.run_id,
            lease_owner=request.lease_owner,
            epoch=request.epoch,
            section_index=request.section_index,
            policy=policy,
        )
        return res
    except Exception as exc:
        logger.error("Question candidate generation failed: %s", exc, exc_info=True)
        raise HTTPException(status_code=500, detail=str(exc)) from exc

@router.post("/section")
async def section(request: SectionRequest, http_request: Request) -> Any:
    is_ndjson = "application/x-ndjson" in http_request.headers.get("accept", "").lower()
    is_v2 = (
        (request.engine and request.engine.lower() == "v2")
        or http_request.headers.get("x-langfens-engine", "").lower() == "v2"
        or http_request.query_params.get("engine", "").lower() == "v2"
    )

    if is_v2:
        from app.contracts.artifact import ArtifactRef, ArtifactType
        from app.contracts.loop import DecisionType, LoopReason
        from app.facade import get_generation_facade
        from app.generators.passage.context import PassageGenerationContext
        from app.generators.passage.prompts import PassageStyleProfile

        # Invariant: Do NOT fabricate synthetic placeholder source text!
        source_text = (
            request.source.get("content", "")
            or request.source.get("text", "")
            or request.source.get("sourceText", "")
        ).strip()

        if len(source_text) < 50:
            error_payload = {
                "decision": DecisionType.FAIL.value,
                "terminalReason": "Missing or insufficient approved source material for passage generation",
                "terminalReasonCode": LoopReason.SOURCE_INSUFFICIENT.value,
            }
            if is_ndjson:
                return StreamingResponse(
                    iter([json.dumps({"type": "error", "error": error_payload}) + "\n"]),
                    media_type="application/x-ndjson",
                )
            return error_payload

        # Invariant: Require exact accepted ExamBlueprint and EvidenceGraph dependencies
        bp_ref = None
        eg_ref = None
        if request.blueprint_ref and request.evidence_graph_ref:
            try:
                bp_ref = ArtifactRef.model_validate(request.blueprint_ref)
                eg_ref = ArtifactRef.model_validate(request.evidence_graph_ref)
            except Exception as exc:
                logger.warning("Caller provided invalid dependency refs: %s", exc)

        facade = get_generation_facade()
        if not bp_ref or not eg_ref:
            # Resolve from authoritative persistence store
            client = facade.get_persistence_client()
            try:
                res_state = client.resume_state(request.run_id)
                for art in res_state.artifacts:
                    if art.artifactType == ArtifactType.EXAM_BLUEPRINT.value and not art.isStale:
                        bp_ref = ArtifactRef(
                            artifactId=art.artifactId,
                            artifactType=ArtifactType.EXAM_BLUEPRINT,
                            version=art.acceptedVersion,
                            contentHash=art.acceptedHash,
                        )
                    elif art.artifactType == ArtifactType.EVIDENCE_GRAPH.value and not art.isStale:
                        eg_ref = ArtifactRef(
                            artifactId=art.artifactId,
                            artifactType=ArtifactType.EVIDENCE_GRAPH,
                            version=art.acceptedVersion,
                            contentHash=art.acceptedHash,
                        )
            except Exception as exc:
                logger.debug("Dependency resolution encountered notice: %s", exc)

        if not bp_ref or not eg_ref:
            error_payload = {
                "decision": DecisionType.FAIL.value,
                "terminalReason": "Missing required accepted upstream dependencies (ExamBlueprint and EvidenceGraph)",
                "terminalReasonCode": LoopReason.STALE_DEPENDENCY.value,
            }
            if is_ndjson:
                return StreamingResponse(
                    iter([json.dumps({"type": "error", "error": error_payload}) + "\n"]),
                    media_type="application/x-ndjson",
                )
            return error_payload

        passage_ctx = PassageGenerationContext(
            blueprintRef=bp_ref,
            evidenceGraphRef=eg_ref,
            sectionIndex=request.index,
            topic=request.topic,
            sourceText=source_text,
            styleProfile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        )

        loop_res = await facade.generate_passage_v2(
            passage_context=passage_ctx,
            run_id=request.run_id,
            lease_owner=request.lease_owner,
            epoch=request.epoch,
        )

        if is_ndjson:
            async def _stream_v2_events():
                yield json.dumps({"type": "log", "message": "V2 passage synthesis and evaluation started"}) + "\n"
                if loop_res.accepted_artifact:
                    clean_payload = loop_res.accepted_artifact.model_dump(mode="json")["payload"]
                    yield json.dumps({"type": "section", "payload": clean_payload}) + "\n"
                else:
                    yield json.dumps({
                        "type": "error",
                        "decision": loop_res.decision.value,
                        "terminalReason": loop_res.terminal_reason,
                        "terminalReasonCode": loop_res.terminal_reason_code.value,
                    }) + "\n"

            return StreamingResponse(_stream_v2_events(), media_type="application/x-ndjson")

        if loop_res.accepted_artifact:
            return loop_res.accepted_artifact.model_dump(mode="json")["payload"]
        return {
            "decision": loop_res.decision.value,
            "terminalReason": loop_res.terminal_reason,
            "terminalReasonCode": loop_res.terminal_reason_code.value,
        }

    # Legacy V1 execution path
    if is_ndjson:
        return StreamingResponse(_stream_section(request), media_type="application/x-ndjson")
    try:
        return await generate_section(
            request.topic,
            request.index,
            request.source,
            provider=request.provider,
            run_id=request.run_id,
            epoch=request.epoch,
            lease_owner=request.lease_owner,
            parent_operation_id=request.parent_operation_id,
        )
    except SourceNetworkError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


async def _stream_section(request: SectionRequest):
    events: asyncio.Queue[dict[str, Any]] = asyncio.Queue()

    async def report(level: str, message: str) -> None:
        event = {
            "type": "log",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": level,
            "message": message,
        }
        logger.log(
            getattr(logging, level.upper(), logging.INFO),
            "Reading paper passage %s: %s",
            request.index,
            message,
        )
        await events.put(event)

    await report("Information", f"Passage {request.index} generation stream opened.")
    task = asyncio.create_task(
        generate_section(
            request.topic,
            request.index,
            request.source,
            progress=report,
            provider=request.provider,
            run_id=request.run_id,
            epoch=request.epoch,
            lease_owner=request.lease_owner,
            parent_operation_id=request.parent_operation_id,
        )
    )
    try:
        while not task.done() or not events.empty():
            try:
                event = await asyncio.wait_for(events.get(), timeout=0.25)
            except TimeoutError:
                continue
            yield json.dumps(event, ensure_ascii=False, separators=(",", ":")) + "\n"

        try:
            result = await task
        except Exception as exc:
            logger.exception("Reading paper passage %s generation failed", request.index)
            yield json.dumps(
                {
                    "type": "error",
                    "httpStatus": 503
                    if isinstance(exc, SourceNetworkError)
                    else 422
                    if isinstance(exc, SourceError)
                    else 502,
                    "message": str(exc),
                    "traceback": "".join(
                        traceback.format_exception(type(exc), exc, exc.__traceback__)
                    ),
                },
                ensure_ascii=False,
                separators=(",", ":"),
            ) + "\n"
        else:
            yield json.dumps(
                {"type": "result", "section": result},
                ensure_ascii=False,
                separators=(",", ":"),
            ) + "\n"
    finally:
        if not task.done():
            task.cancel()
            await asyncio.gather(task, return_exceptions=True)
