"""Internal Reading-paper operations used by exam-service jobs."""
from __future__ import annotations

import asyncio
import json
import logging
import traceback
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, HTTPException, Query, Request
from pydantic import BaseModel, Field
from starlette.responses import StreamingResponse

from app.services.reading_paper import (
    SourceError,
    SourceNetworkError,
    fetch_source,
    generate_section,
    ingest_source,
    search_sources,
)

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

@router.post("/section")
async def section(request: SectionRequest, http_request: Request) -> Any:
    if "application/x-ndjson" in http_request.headers.get("accept", "").lower():
        return StreamingResponse(_stream_section(request), media_type="application/x-ndjson")
    try:
        return await generate_section(request.topic, request.index, request.source)
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
        logger.log(getattr(logging, level.upper(), logging.INFO),
                   "Reading paper passage %s: %s", request.index, message)
        await events.put(event)

    await report("Information", f"Passage {request.index} generation stream opened.")
    task = asyncio.create_task(
        generate_section(request.topic, request.index, request.source, progress=report))
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
            yield json.dumps({
                "type": "error",
                "httpStatus": 503 if isinstance(exc, SourceNetworkError)
                else 422 if isinstance(exc, SourceError) else 502,
                "message": str(exc),
                "traceback": "".join(traceback.format_exception(type(exc), exc, exc.__traceback__)),
            }, ensure_ascii=False, separators=(",", ":")) + "\n"
        else:
            yield json.dumps({"type": "result", "section": result},
                             ensure_ascii=False, separators=(",", ":")) + "\n"
    finally:
        if not task.done():
            task.cancel()
            await asyncio.gather(task, return_exceptions=True)
