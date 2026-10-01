from __future__ import annotations

import asyncio
import logging
import random
import time
from typing import Any, Callable, Coroutine, Optional, TypeVar

from app.providers.base import redact_secrets
from app.providers.errors import (
    CancelledError,
    DeadlineExceededError,
    ProviderError,
    RateLimitedError,
    UnauthorizedError,
)

logger = logging.getLogger(__name__)

T = TypeVar("T")


class RetryPolicy:
    """Configurable retry policy with exponential backoff, full jitter,

    Retry-After honoring within deadline, and strict non-retryable error handling.
    """

    def __init__(
        self,
        max_attempts: int = 3,
        base_delay_seconds: float = 0.5,
        max_delay_seconds: float = 10.0,
        jitter_factor: float = 0.5,
    ):
        self.max_attempts = max_attempts
        self.base_delay_seconds = base_delay_seconds
        self.max_delay_seconds = max_delay_seconds
        self.jitter_factor = jitter_factor

    def compute_delay(self, attempt: int, retry_after: Optional[float] = None) -> float:
        """Computes delay for attempt (0-indexed) with exponential backoff and jitter."""
        if retry_after is not None and retry_after > 0:
            return retry_after

        # Exponential backoff: base * 2^attempt
        backoff = min(self.max_delay_seconds, self.base_delay_seconds * (2 ** attempt))
        # Full jitter between (1 - jitter) * backoff and backoff
        jitter_min = backoff * (1.0 - self.jitter_factor)
        delay = random.uniform(jitter_min, backoff)
        return round(delay, 3)

    async def execute(
        self,
        fn: Callable[[], Coroutine[Any, Any, T]],
        deadline: float,
        operation_id: str = "",
        on_retry: Optional[Callable[[int, Exception, float], Coroutine[Any, Any, None]]] = None,
    ) -> T:
        """Executes async operation with bounded retries under a hard deadline."""
        attempt = 0
        last_error: Optional[Exception] = None

        while attempt < self.max_attempts:
            now = time.time()
            if now >= deadline:
                raise DeadlineExceededError(
                    f"Deadline exceeded before attempt {attempt + 1} for operation '{operation_id}'",
                    operation_id=operation_id,
                )

            try:
                return await fn()
            except CancelledError:
                raise
            except asyncio.CancelledError:
                raise CancelledError(f"Operation '{operation_id}' was cancelled", operation_id=operation_id)
            except UnauthorizedError as unauth_err:
                # 401/403: Security errors must NEVER be retried!
                logger.warning("Non-retryable authorization error: %s", redact_secrets(str(unauth_err)))
                raise
            except ProviderError as p_err:
                if not p_err.is_retryable:
                    raise

                last_error = p_err
                attempt += 1
                if attempt >= self.max_attempts:
                    break

                # Determine wait time
                retry_after = getattr(p_err, "retry_after_seconds", None)
                delay = self.compute_delay(attempt - 1, retry_after=retry_after)

                # Check if delay would breach deadline
                if time.time() + delay > deadline:
                    logger.warning(
                        "Retry-After / backoff delay (%.2fs) exceeds remaining deadline for operation '%s'",
                        delay,
                        operation_id,
                    )
                    raise DeadlineExceededError(
                        f"Retry delay ({delay:.2fs}) would exceed remaining deadline for operation '{operation_id}'",
                        operation_id=operation_id,
                    )

                if on_retry is not None:
                    cb_res = on_retry(attempt, p_err, delay)
                    if asyncio.iscoroutine(cb_res):
                        await cb_res

                logger.info(
                    "Retrying operation '%s' (attempt %d/%d) after %.2fs delay: %s",
                    operation_id,
                    attempt + 1,
                    self.max_attempts,
                    delay,
                    redact_secrets(str(p_err)),
                )

                try:
                    await asyncio.sleep(delay)
                except asyncio.CancelledError:
                    raise CancelledError(
                        f"Operation '{operation_id}' was cancelled during retry wait",
                        operation_id=operation_id,
                    )

            except Exception as exc:
                # Unexpected exception: do not retry blindly
                logger.error("Unexpected non-retryable exception: %s", redact_secrets(str(exc)))
                raise

        if last_error is not None:
            raise last_error

        raise ProviderError(f"All {self.max_attempts} attempts failed for operation '{operation_id}'")
