import asyncio
import logging
import os
import sys
import time
import uuid
from concurrent.futures import ThreadPoolExecutor
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from starlette.middleware.base import BaseHTTPMiddleware

from app.config import settings
from app.routers import health, embed, writing, grammar, speaking, practice

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s: %(message)s")
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

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())[:8]
        start = time.time()
        response = await call_next(request)
        duration_ms = (time.time() - start) * 1000
        logger.info(
            "request_id=%s method=%s path=%s status=%s duration_ms=%.1f",
            request_id,
            request.method,
            request.url.path,
            response.status_code,
            duration_ms,
        )
        response.headers["X-Request-ID"] = request_id
        return response


from app.middleware.rate_limit import RateLimitMiddleware
app.add_middleware(RateLimitMiddleware)
app.add_middleware(RequestLoggingMiddleware)

app.include_router(health.router, prefix="/api")
app.include_router(embed.router, prefix="/api")
app.include_router(writing.router, prefix="/api")
app.include_router(grammar.router, prefix="/api")
app.include_router(speaking.router, prefix="/api")
app.include_router(practice.router, prefix="/api")
