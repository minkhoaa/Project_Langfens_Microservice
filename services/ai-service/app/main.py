import asyncio
import logging
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from contextlib import asynccontextmanager

from fastapi import FastAPI
from app.config import settings
from app.routers import health, embed, writing, grammar, speaking, practice

logger = logging.getLogger(__name__)
_executor = ThreadPoolExecutor(max_workers=1)


@asynccontextmanager
async def lifespan(app: FastAPI):
    if (
        settings.disable_ingestion_on_startup
        or os.getenv("PYTEST_CURRENT_TEST")
        or "pytest" in sys.modules
    ):
        yield
        return

    from app.services.ingestion_service import run_ingestion
    loop = asyncio.get_event_loop()
    asyncio.ensure_future(loop.run_in_executor(_executor, run_ingestion))
    yield
    _executor.shutdown(wait=False)


app = FastAPI(title="Langfens AI Service", version="1.0.0", lifespan=lifespan)

from app.middleware.rate_limit import RateLimitMiddleware
app.add_middleware(RateLimitMiddleware)

app.include_router(health.router, prefix="/api")
app.include_router(embed.router, prefix="/api")
app.include_router(writing.router, prefix="/api")
app.include_router(grammar.router, prefix="/api")
app.include_router(speaking.router, prefix="/api")
app.include_router(practice.router, prefix="/api")
