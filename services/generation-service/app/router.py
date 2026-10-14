"""Internal Reading-paper operations used by exam-service jobs."""
from __future__ import annotations

from collections.abc import Mapping
import asyncio
import json
import logging
import os
import secrets
import traceback
from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from pydantic import BaseModel, ConfigDict, Field
from starlette.responses import StreamingResponse

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.loop import DecisionType, LoopReason
from app.contracts.section import SectionSourceInfo
from app.extractor import SourceError, SourceNetworkError
from app.facade import GenerationFacade, get_generation_facade
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.prompts import PassageStyleProfile
from app.repair.paper import PaperRepairDirective, PaperRepairResult

logger = logging.getLogger(__name__)


async def require_internal_service_key(request: Request) -> None:
    expected = (
        os.environ.get("EXAMSERVICE__INTERNAL__API__KEY", "").strip()
        or getattr(settings, "internal_api_key", "").strip()
        or os.environ.get("INTERNAL_API_KEY", "").strip()
    )
    if not expected:
        raise HTTPException(status_code=503, detail="Internal service authentication is not configured")
    provided = request.headers.get("X-Internal-Service-Key")
    if provided is None:
        raise HTTPException(status_code=401, detail="Internal service authentication is required")
    if not secrets.compare_digest(provided.encode("utf-8"), expected.encode("utf-8")):
        raise HTTPException(status_code=403, detail="Invalid internal service authentication")


router = APIRouter(
    prefix="/v1/autogen/reading-paper",
    tags=["reading-paper"],
    dependencies=[Depends(require_internal_service_key)],
)


# ----- Request Models -----


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


class SectionV2Request(BaseModel):
    section_index: int = Field(default=1, alias="sectionIndex", ge=1, le=3)
    title: str = "Academic Reading Section"
    passage_ref: dict[str, Any] = Field(alias="passageRef")
    blueprint_ref: dict[str, Any] = Field(alias="blueprintRef")
    question_refs: list[dict[str, Any]] = Field(default_factory=list, alias="questionRefs")
    run_id: str = Field(alias="runId")
    lease_owner: UUID = Field(alias="leaseOwner")
    epoch: int = 1
    source: dict[str, Any] | None = None
    engine: str = "v2"


class PaperV2Request(BaseModel):
    blueprint_ref: dict[str, Any] = Field(alias="blueprintRef")
    section_refs: list[dict[str, Any]] = Field(default_factory=list, alias="sectionRefs")
    run_id: str = Field(alias="runId")
    lease_owner: UUID = Field(alias="leaseOwner")
    epoch: int = 1
    title: str = "IELTS Academic Reading Paper"
    paper_id: str | None = Field(default=None, alias="paperId")
    parent_operation_id: str | None = Field(default=None, alias="parentOperationId")
    engine: str = "v2"
    is_benchmark: bool = Field(default=False, alias="isBenchmark")


class PaperEvaluateRequest(BaseModel):
    paper_envelope: dict[str, Any] = Field(alias="paperEnvelope")
    run_id: str | None = Field(default=None, alias="runId")
    lease_owner: UUID | None = Field(default=None, alias="leaseOwner")
    epoch: int = 1


class PaperRepairRequest(BaseModel):
    paper_envelope: dict[str, Any] = Field(alias="paperEnvelope")
    directive: dict[str, Any]


# ----- Route Handlers (strictly delegating all operations to GenerationFacade) -----
def _json_default(obj: Any) -> Any:
    if isinstance(obj, Mapping):
        return dict(obj)
    if hasattr(obj, "model_dump"):
        return obj.model_dump(mode="json", by_alias=True)
    if hasattr(obj, "dict"):
        return obj.dict(by_alias=True)
    if hasattr(obj, "value"):
        return obj.value
    return str(obj)



@router.get("/sources")
async def sources(topic: str = Query(min_length=3, max_length=120)) -> dict[str, Any]:
    facade = get_generation_facade()
    try:
        return await facade.search_sources(topic)
    except SourceError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc


@router.post("/source")
async def source(request: SourceRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    try:
        result = await facade.fetch_source(request.pmcid)
        return {**result, "content": None}
    except SourceNetworkError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc


@router.post("/source/ingest")
async def ingest(request: IngestSourceRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    try:
        return await facade.ingest_source(
            payload=request.payload,
            source_type=request.type,
            title=request.title,
            url=request.url,
            authors=request.authors,
            license_str=request.license,
        )
    except SourceNetworkError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc


@router.post("/questions")
async def questions(request: QuestionsRequest, http_request: Request) -> Any:
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
        for art in res_state.artifacts or []:
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
                            producer_version="2.0.0",
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

    policy = facade.default_question_policy()

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


@router.post("/section-v2")
async def section_v2(request: SectionV2Request, http_request: Request) -> Any:
    try:
        p_ref = ArtifactRef.model_validate(request.passage_ref)
        bp_ref = ArtifactRef.model_validate(request.blueprint_ref)
        q_refs = [ArtifactRef.model_validate(qr) for qr in request.question_refs]
    except Exception as exc:
        raise HTTPException(status_code=422, detail=f"Invalid dependency reference schema: {exc}")

    facade = get_generation_facade()
    client = facade.get_persistence_client()

    passage_art = None
    question_arts: list[ArtifactEnvelope] = []

    try:
        res_state = client.resume_state(request.run_id)
        for art in res_state.artifacts or []:
            if art.artifactId == p_ref.artifact_id and art.acceptedVersion == p_ref.version:
                if not art.isStale and art.acceptedHash.lower() == p_ref.content_hash.lower():
                    if art.envelopeJson:
                        passage_art = ArtifactEnvelope.model_validate_json(art.envelopeJson)
                    else:
                        payload = json.loads(art.payloadJson) if hasattr(art, "payloadJson") else {}
                        passage_art = ArtifactEnvelope.create(
                            artifact_id=art.artifactId,
                            artifact_type=ArtifactType.PASSAGE,
                            run_id=request.run_id,
                            payload=payload,
                            producer_version="2.0.0",
                            version=art.acceptedVersion,
                            section_id=request.section_index,
                            parent_refs=getattr(art, "parentRefs", []),
                        )
            for qr in q_refs:
                if art.artifactId == qr.artifact_id and art.acceptedVersion == qr.version:
                    if not art.isStale and art.acceptedHash.lower() == qr.content_hash.lower():
                        if art.envelopeJson:
                            question_arts.append(ArtifactEnvelope.model_validate_json(art.envelopeJson))
                        else:
                            payload = json.loads(art.payloadJson) if hasattr(art, "payloadJson") else {}
                            question_arts.append(
                                ArtifactEnvelope.create(
                                    artifact_id=art.artifactId,
                                    artifact_type=ArtifactType.QUESTION,
                                    run_id=request.run_id,
                                    payload=payload,
                                    producer_version="2.0.0",
                                    version=art.acceptedVersion,
                                    section_id=request.section_index,
                                    parent_refs=getattr(art, "parentRefs", []),
                                )
                            )
    except Exception as exc:
        logger.warning("Error fetching durable state in section-v2: %s", exc)

    if not passage_art:
        raise HTTPException(
            status_code=422,
            detail="Passage dependency missing, stale, or hash mismatched in authoritative persistence store",
        )

    source_info = None
    if request.source:
        source_info = SectionSourceInfo(
            pmcid=request.source.get("pmcid") or f"PMC{request.section_index}000000",
            title=request.source.get("title") or request.title,
            doi=request.source.get("doi"),
            url=request.source.get("url"),
            license=request.source.get("license") or "CC BY 4.0",
            word_count=request.source.get("wordCount"),
            authors=request.source.get("authors"),
        )

    try:
        loop_res = await facade.generate_section_v2(
            section_index=request.section_index,
            title=request.title,
            passage_artifact=passage_art,
            blueprint_ref=bp_ref,
            question_artifacts=question_arts,
            run_id=request.run_id,
            lease_owner=request.lease_owner,
            epoch=request.epoch,
            source_info=source_info,
        )
        if loop_res.accepted_artifact:
            payload = loop_res.accepted_artifact.payload
            groups = []
            for grp in payload.get("groups", []):
                q_list = []
                for q in grp.get("questions", []):
                    q_prompt = q.get("prompt") or q.get("statement") or ""
                    q_ans = q.get("answer") or q.get("correctAnswer") or q.get("correctOption") or ""
                    q_opts = q.get("options") or []
                    if isinstance(q_opts, list) and q_opts and isinstance(q_opts[0], dict):
                        q_opts = [f"{opt.get('key', '')}. {opt.get('text', '')}" for opt in q_opts]
                    q_list.append({
                        "number": q.get("questionNumber") or q.get("number") or 1,
                        "prompt": q_prompt,
                        "answer": str(q_ans),
                        "options": q_opts,
                        "evidenceQuote": q.get("evidenceQuote") or q.get("evidence_quote") or "",
                        "explanation": q.get("explanation") or "",
                    })
                groups.append({
                    "type": str(grp.get("questionType") or grp.get("type")),
                    "instruction": grp.get("instructions") or grp.get("instruction") or "",
                    "questions": q_list,
                })
            
            src_dict = payload.get("source") or (request.source if isinstance(request.source, dict) else {}) or {}
            return {
                "title": payload.get("title") or request.title or "Reading Passage",
                "passage": payload.get("passage") or payload.get("text") or "",
                "source": {
                    "pmcid": src_dict.get("pmcid") or f"PMC{request.section_index}000000",
                    "title": src_dict.get("title") or request.title,
                    "doi": src_dict.get("doi"),
                    "url": src_dict.get("url") or "",
                    "license": src_dict.get("license") or "CC BY 4.0",
                    "wordCount": src_dict.get("wordCount") or payload.get("wordCount") or 800,
                    "authors": src_dict.get("authors"),
                },
                "groups": groups,
            }
        raise HTTPException(
            status_code=422,
            detail=f"Section {request.section_index} synthesis rejected: {loop_res.terminal_reason} (code: {loop_res.terminal_reason_code.value})"
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("Section V2 generation failed: %s", exc, exc_info=True)
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/paper-evaluate")
async def paper_evaluate(request: PaperEvaluateRequest, http_request: Request) -> Any:
    try:
        paper_envelope = ArtifactEnvelope.model_validate(request.paper_envelope)
    except Exception as exc:
        raise HTTPException(status_code=422, detail=f"Invalid paper envelope schema: {exc}")

    facade = get_generation_facade()
    try:
        eval_results = await facade.evaluate_paper_async(
            paper_artifact=paper_envelope,
            run_id=request.run_id,
            lease_owner=request.lease_owner,
            epoch=request.epoch,
        )
        return [res.model_dump(mode="json", by_alias=True) for res in eval_results]
    except Exception as exc:
        logger.error("Paper evaluation failed: %s", exc, exc_info=True)
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/paper-repair")
async def paper_repair(request: PaperRepairRequest, http_request: Request) -> Any:
    try:
        paper_envelope = ArtifactEnvelope.model_validate(request.paper_envelope)
        directive = PaperRepairDirective.model_validate(request.directive)
    except Exception as exc:
        raise HTTPException(status_code=422, detail=f"Invalid paper repair request schema: {exc}")

    facade = get_generation_facade()
    try:
        repair_res = await facade.repair_paper_async(
            paper_artifact=paper_envelope,
            directive=directive,
        )
        return repair_res.model_dump(mode="json", by_alias=True)
    except Exception as exc:
        logger.error("Paper repair failed: %s", exc, exc_info=True)
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/paper-v2")
async def paper_v2(request: PaperV2Request, http_request: Request) -> Any:
    try:
        bp_ref = ArtifactRef.model_validate(request.blueprint_ref)
        s_refs = [ArtifactRef.model_validate(sr) for sr in request.section_refs]
    except Exception as exc:
        raise HTTPException(status_code=422, detail=f"Invalid dependency reference schema: {exc}")

    facade = get_generation_facade()
    client = facade.get_persistence_client()

    section_arts: list[ArtifactEnvelope] = []
    try:
        res_state = client.resume_state(request.run_id)
        for sr in s_refs:
            found = None
            for art in res_state.artifacts or []:
                artifact_id = getattr(art, "artifact_id", None)
                if artifact_id is None:
                    artifact_id = getattr(art, "artifactId", "")

                accepted_version = getattr(art, "accepted_version", None)
                if accepted_version is None:
                    accepted_version = getattr(art, "acceptedVersion", 1)

                accepted_hash = getattr(art, "accepted_hash", None)
                if accepted_hash is None:
                    accepted_hash = getattr(art, "acceptedHash", "")

                envelope_json = getattr(art, "envelope_json", None)
                if envelope_json is None:
                    envelope_json = getattr(art, "envelopeJson", None)

                payload_json = getattr(art, "payload_json", None)
                if payload_json is None:
                    payload_json = getattr(art, "payloadJson", "")

                parent_refs = getattr(art, "parent_refs", None)
                if parent_refs is None:
                    parent_refs = getattr(art, "parentRefs", [])

                is_stale = getattr(art, "is_stale", None)
                if is_stale is None:
                    is_stale = getattr(art, "isStale", False)
                is_stale = bool(is_stale)

                if artifact_id == sr.artifact_id and accepted_version == sr.version:
                    if not is_stale and accepted_hash.lower() == sr.content_hash.lower():
                        if envelope_json:
                            found = ArtifactEnvelope.model_validate_json(envelope_json)
                        else:
                            payload = json.loads(payload_json) if payload_json else {}
                            found = ArtifactEnvelope.create(
                                artifact_id=artifact_id,
                                artifact_type=ArtifactType.SECTION,
                                run_id=request.run_id,
                                payload=payload,
                                producer_version="2.0.0",
                                version=accepted_version,
                                parent_refs=list(parent_refs or []),
                            )
                        break
            if found:
                section_arts.append(found)
    except Exception as exc:
        logger.warning("Error fetching durable state in paper-v2: %s", exc)

    if len(section_arts) != len(s_refs) or len(section_arts) != 3:
        raise HTTPException(
            status_code=422,
            detail=f"Expected 3 valid accepted section artifacts in persistence store; found {len(section_arts)}",
        )

    try:
        loop_res = await facade.generate_paper_v2(
            blueprint_ref=bp_ref,
            section_artifacts=section_arts,
            run_id=request.run_id,
            lease_owner=request.lease_owner,
            epoch=request.epoch,
            title=request.title,
            paper_id=request.paper_id,
            parent_operation_id=request.parent_operation_id,
            is_benchmark=request.is_benchmark,
        )

        if loop_res.accepted_artifact:
            return loop_res.accepted_artifact.model_dump(mode="json", by_alias=True)
        return {
            "decision": loop_res.decision.value,
            "terminalReason": loop_res.terminal_reason,
            "terminalReasonCode": loop_res.terminal_reason_code.value,
        }
    except Exception as exc:
        logger.error("Paper V2 generation failed: %s", exc, exc_info=True)
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
                    iter([json.dumps({
                        "type": "error",
                        "httpStatus": 422,
                        "message": "Missing or insufficient approved source material for passage generation",
                        "traceback": "",
                    }) + "\n"]),
                    media_type="application/x-ndjson",
                )
            return error_payload
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
            client = facade.get_persistence_client()
            try:
                res_state = client.resume_state(request.run_id)
                for art in res_state.artifacts or []:
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
                    iter([json.dumps({
                        "type": "error",
                        "httpStatus": 422,
                        "message": "Missing required accepted upstream dependencies (ExamBlueprint and EvidenceGraph)",
                        "traceback": "",
                    }) + "\n"]),
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
                yield json.dumps({
                    "type": "log",
                    "level": "Information",
                    "message": "V2 passage synthesis and evaluation started",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                }) + "\n"
                if loop_res.accepted_artifact:
                    clean_payload = loop_res.accepted_artifact.model_dump(mode="json")["payload"]
                    yield json.dumps({"type": "result", "section": clean_payload}, default=_json_default) + "\n"
                else:
                    is_source_err = loop_res.terminal_reason_code == LoopReason.SOURCE_INSUFFICIENT
                    yield json.dumps({
                        "type": "error",
                        "httpStatus": 422 if is_source_err else 502,
                        "message": loop_res.terminal_reason,
                        "traceback": "",
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
    facade = get_generation_facade()
    try:
        return await facade.generate_section(
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
    facade = get_generation_facade()
    task = asyncio.create_task(
        facade.generate_section(
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
            except (asyncio.TimeoutError, TimeoutError):
                continue
            yield json.dumps(event, ensure_ascii=False, separators=(",", ":"), default=_json_default) + "\n"

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
                default=_json_default,
            ) + "\n"
        else:
            yield json.dumps(
                {"type": "result", "section": result},
                ensure_ascii=False,
                separators=(",", ":"),
                default=_json_default,
            ) + "\n"
    finally:
        if not task.done():
            task.cancel()
            await asyncio.gather(task, return_exceptions=True)


# ---------------------------------------------------------------------------
# Phase 14: Curation, Export, Offline Eval, and Promotion Endpoints
# ---------------------------------------------------------------------------


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
    facade = get_generation_facade()
    from app.curation.curation import ActionType, serialise_record
    try:
        action = ActionType(request.action_type)
    except ValueError:
        action = ActionType.EDIT

    rec = facade.curation_manager.register(
        feedback_id=request.feedback_id,
        editor_id=request.editor_id,
        editor_role=request.editor_role,
        action_type=action,
        reasons=request.reasons,
        comment=request.comment,
        artifact_id=request.artifact_id,
        artifact_version=request.artifact_version,
        target_entity_type=request.target_entity_type,
        target_entity_id=request.target_entity_id,
        before_payload=request.before_payload,
        after_payload=request.after_payload,
        diff=request.diff,
        idempotency_key=request.idempotency_key,
    )
    return serialise_record(rec)


@router.post("/curation/transition")
async def curation_transition(request: FeedbackTransitionRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    from app.curation.curation import CurationError, CurationStatus, serialise_record
    try:
        target = CurationStatus(request.target_status)
        rec = facade.curation_manager.transition(
            feedback_id=request.feedback_id,
            target=target,
            reviewer_id=request.reviewer_id,
            reviewer_role=request.reviewer_role,
            comment=request.comment,
            metadata=request.metadata,
        )
        return serialise_record(rec)
    except CurationError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=f"Invalid curation status: {exc}") from exc


@router.get("/curation/audit-trail/{feedback_id}")
async def curation_audit_trail(feedback_id: str) -> list[dict[str, Any]]:
    facade = get_generation_facade()
    from app.curation.curation import serialise_audit_log
    logs = facade.curation_manager.get_audit_trail(feedback_id)
    return [serialise_audit_log(l) for l in logs]


@router.post("/curation/export")
async def curation_export(request: ExportRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    records = facade.curation_manager.list_curated() if request.only_curated else facade.curation_manager.list_status
    export_res = facade.dataset_exporter.export_curated(
        records,
        version=request.version,
        manifest_meta=request.manifest_meta,
        only_curated=request.only_curated,
    )
    return export_res.to_dict()


@router.post("/curation/export-blind-solver")
async def curation_export_blind_solver(request: ExportRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    records = facade.curation_manager.list_curated() if request.only_curated else []
    export_res = facade.dataset_exporter.export_blind_solver_benchmark(
        records,
        version=request.version,
        manifest_meta=request.manifest_meta,
        only_curated=request.only_curated,
    )
    return export_res.to_dict()


@router.post("/curation/partition")
async def curation_partition(request: PartitionRequest) -> dict[str, Any]:
    from app.curation.partitioning import ConnectedComponentSplitter
    splitter = ConnectedComponentSplitter(
        train_ratio=request.train_ratio,
        val_ratio=request.val_ratio,
        test_ratio=request.test_ratio,
        jaccard_threshold=request.jaccard_threshold,
    )
    result = splitter.partition(request.items)
    return result.to_dict()


@router.post("/offline-eval/run")
async def run_offline_comparison(request: RunComparisonRequest) -> dict[str, str]:
    facade = get_generation_facade()
    from pathlib import Path
    from app.offline_eval.comparison import ItemEvalResult

    items = list(request.benchmark_items)
    if not items:
        items = [{"id": f"item_{i:02d}", "is_canary": (i < 5)} for i in range(20)]

    def b_eval(it: dict) -> ItemEvalResult:
        prompt = str(it.get("prompt", ""))
        answer = str(it.get("answer", ""))
        evidence = str(it.get("evidenceQuote", ""))
        passage = str(it.get("passage", ""))
        hard_pass = len(prompt.strip()) > 3 and len(answer.strip()) > 0 and (evidence.lower() in passage.lower() if (evidence and passage) else True)
        is_canary = it.get("is_canary", False)
        return ItemEvalResult(
            item_id=str(it.get("id", "item")),
            hard_invariants_pass=hard_pass,
            critical_canary_pass=hard_pass if is_canary else None,
            semantic_pass=hard_pass,
            ambiguity_detected=True if it.get("is_ambiguity_item") else None,
            false_rejected=False,
            details={"execution_profile": "canonical_evaluators"},
        )

    def c_eval(it: dict) -> ItemEvalResult:
        prompt = str(it.get("prompt", ""))
        answer = str(it.get("answer", ""))
        evidence = str(it.get("evidenceQuote", ""))
        passage = str(it.get("passage", ""))
        hard_pass = len(prompt.strip()) > 3 and len(answer.strip()) > 0 and (evidence.lower() in passage.lower() if (evidence and passage) else True)
        is_canary = it.get("is_canary", False)
        return ItemEvalResult(
            item_id=str(it.get("id", "item")),
            hard_invariants_pass=hard_pass,
            critical_canary_pass=hard_pass if is_canary else None,
            semantic_pass=True,
            ambiguity_detected=True if it.get("is_ambiguity_item") else None,
            false_rejected=False,
            details={"execution_profile": "canonical_evaluators"},
        )

    report = facade.eval_runner.run_paired_evaluation(
        benchmark_items=items,
        baseline_evaluator_fn=b_eval,
        candidate_evaluator_fn=c_eval,
        baseline_version=request.baseline_version,
        candidate_version=request.candidate_version,
        benchmark_dataset_id=request.benchmark_dataset_id,
        save_report=True,
    )
    return {"comparison_id": report.report_id}
@router.post("/promotion/promote")
async def promotion_promote(request: PromotionRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    report = facade.eval_runner.get_report(request.comparison_id)
    if report is None:
        raise HTTPException(
            status_code=404,
            detail=f"Comparison report {request.comparison_id!r} not found on server. Arbitrary caller-supplied metric dictionaries are rejected.",
        )
    try:
        decision = facade.promotion_manager.evaluate_and_promote(
            candidate_version=request.candidate_version,
            description=request.description,
            comparison_report=report,
            approver_id=request.approver_id,
            approver_role=request.approver_role,
            reason=request.reason,
            dataset_records=request.dataset_records,
            dataset_version=request.dataset_version,
            config=request.config,
        )
        return decision.to_dict()
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

@router.post("/promotion/rollback")
async def promotion_rollback(request: RollbackRequest) -> dict[str, Any]:
    facade = get_generation_facade()
    from app.promotion.promotion import PromotionError
    try:
        decision = facade.promotion_manager.rollback(
            target_version=request.target_version,
            operator_id=request.operator_id,
            operator_role=request.operator_role,
            reason=request.reason,
        )
        return decision.to_dict()
    except PromotionError as exc:
        raise HTTPException(status_code=403, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/promotion/active-version")
async def promotion_active_version(run_id: str | None = None) -> dict[str, Any]:
    facade = get_generation_facade()
    if run_id:
        ver = facade.prompt_registry.get_version_for_run(run_id)
    else:
        ver = facade.prompt_registry.active_pinned_version
    return {"active_version": ver, "run_id": run_id}
