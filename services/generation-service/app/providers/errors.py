from __future__ import annotations

from typing import Optional


class ProviderError(Exception):
    """Base error for all provider and gateway operations in Loop Engine V2."""

    def __init__(
        self,
        message: str,
        is_retryable: bool = False,
        status_code: Optional[int] = None,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(message)
        self.message = message
        self.is_retryable = is_retryable
        self.status_code = status_code
        self.provider_name = provider_name
        self.operation_id = operation_id


class RateLimitedError(ProviderError):
    """HTTP 429 or provider rate limit quota reached."""

    def __init__(
        self,
        message: str,
        retry_after_seconds: Optional[float] = None,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=True,
            status_code=429,
            provider_name=provider_name,
            operation_id=operation_id,
        )
        self.retry_after_seconds = retry_after_seconds


class UnauthorizedError(ProviderError):
    """HTTP 401/403 Invalid or missing API key, forbidden access. Non-retryable."""

    def __init__(
        self,
        message: str,
        status_code: int = 401,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=False,
            status_code=status_code,
            provider_name=provider_name,
            operation_id=operation_id,
        )


class TimeoutError(ProviderError):
    """Network connection or read timeout during provider invocation."""

    def __init__(
        self,
        message: str,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=True,
            status_code=408,
            provider_name=provider_name,
            operation_id=operation_id,
        )


class CancelledError(ProviderError):
    """Task or operation was cancelled by caller or cancellation token. Non-retryable."""

    def __init__(
        self,
        message: str = "Operation was cancelled",
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=False,
            status_code=499,
            provider_name=provider_name,
            operation_id=operation_id,
        )


class InvalidJsonError(ProviderError):
    """JSON output is malformed, contains syntax errors, or multiple top-level objects. Non-retryable without repair."""

    def __init__(
        self,
        message: str,
        raw_text: Optional[str] = None,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=False,
            status_code=422,
            provider_name=provider_name,
            operation_id=operation_id,
        )
        self.raw_text = raw_text


class TruncatedOutputError(ProviderError):
    """Output was cut off due to max_tokens or finish_reason=length."""

    def __init__(
        self,
        message: str,
        raw_text: Optional[str] = None,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=True,
            status_code=422,
            provider_name=provider_name,
            operation_id=operation_id,
        )
        self.raw_text = raw_text


class SchemaMismatchError(ProviderError):
    """Parsed JSON does not conform to the expected target schema or type invariants."""

    def __init__(
        self,
        message: str,
        validation_errors: Optional[list] = None,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=False,
            status_code=422,
            provider_name=provider_name,
            operation_id=operation_id,
        )
        self.validation_errors = validation_errors or []


class ProviderUnavailableError(ProviderError):
    """HTTP 5xx, connection drop, DNS failure, or provider outage."""

    def __init__(
        self,
        message: str,
        status_code: int = 503,
        provider_name: Optional[str] = None,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=True,
            status_code=status_code,
            provider_name=provider_name,
            operation_id=operation_id,
        )


class BudgetExhaustedError(ProviderError):
    """Operation reservation denied due to run, section, or token budget exhaustion."""

    def __init__(
        self,
        message: str,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=False,
            status_code=429,
            operation_id=operation_id,
        )


class DeadlineExceededError(ProviderError):
    """Operation or retry wait would exceed overall hard deadline."""

    def __init__(
        self,
        message: str,
        operation_id: Optional[str] = None,
    ):
        super().__init__(
            message=message,
            is_retryable=False,
            status_code=504,
            operation_id=operation_id,
        )
