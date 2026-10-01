"""FastAPI application for the IELTS Reading Paper Generation microservice."""
from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.router import router as reading_paper_router

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s: %(message)s")
logger = logging.getLogger("generation-service")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    logger.info("Starting generation-service on port %d (env=%s)...", settings.port, settings.environment)
    yield
    logger.info("Shutting down generation-service...")


app = FastAPI(
    title="Langfens Generation Service",
    version="1.0.0",
    description="Autonomous IELTS Reading paper generation microservice",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount router with and without /api prefix for maximum compatibility
app.include_router(reading_paper_router, prefix="/api")
app.include_router(reading_paper_router)


@app.get("/healthz", tags=["health"])
@app.get("/api/healthz", tags=["health"])
async def healthz() -> dict[str, str]:
    return {"status": "ok", "service": "generation-service"}
