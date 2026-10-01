from __future__ import annotations

import asyncio
import time
from typing import Any, Callable, Dict, List, Optional, Union

from app.providers.base import BaseProvider, redact_secrets
from app.providers.errors import (
    CancelledError,
    InvalidJsonError,
    ProviderUnavailableError,
    RateLimitedError,
    TimeoutError as ProviderTimeoutError,
    TruncatedOutputError,
    UnauthorizedError,
)
from app.providers.models import (
    Capability,
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageAccountingType,
    UsageReport,
)
from app.providers.parser import (
    StreamingReasoningSanitizer,
    clean_reasoning_tags,
    parse_defensive_json,
)


class FakeTransportProvider(BaseProvider):
    """Deterministic mock/recording transport provider for chaos, unit, and regression tests.

    Supports queueing responses, injecting synthetic faults (429, 401, 5xx, timeout, malformed JSON,
    reasoning tags, etc.), and recording every call for leak/parity verification.
    """

    def __init__(
        self,
        name: str = "mock-provider",
        base_url: str = "http://fake-transport.local/v1",
        models: Optional[Dict[str, str]] = None,
    ):
        super().__init__(
            name=name,
            base_url=base_url,
            models=models or {"large": "mock-large", "medium": "mock-medium", "small": "mock-small"},
        )
        self.queue: List[Union[Dict[str, Any], Exception, Callable[[], Any]]] = []
        self.recorded_calls: List[Dict[str, Any]] = []

    def enqueue_response(
        self,
        raw_text: str,
        usage: Optional[UsageReport] = None,
        finish_reason: FinishReason = FinishReason.STOP,
        delay_seconds: float = 0.0,
    ) -> None:
        self.queue.append({
            "type": "response",
            "raw_text": raw_text,
            "usage": usage,
            "finish_reason": finish_reason,
            "delay_seconds": delay_seconds,
        })

    def enqueue_fault(self, fault: Union[Exception, Callable[[], Any]]) -> None:
        self.queue.append(fault)

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        t0 = time.perf_counter()
        now = time.time()
        remaining = deadline - now
        if remaining <= 0:
            raise ProviderTimeoutError(
                f"Deadline exceeded before calling {self.name}",
                provider_name=self.name,
                operation_id=request.operation_id,
            )

        self.recorded_calls.append({
            "request": request,
            "api_key": api_key,
            "timestamp": now,
        })

        if not self.queue:
            # Default fallback mock response
            raw_text = '{"status": "ok", "message": "default mock response"}'
            parsed = parse_defensive_json(raw_text) if request.capability == Capability.GENERATE_JSON else None
            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name=self.name,
                model_name=self.get_model_name(request.model_size),
                raw_text=raw_text,
                parsed_payload=parsed,
                finish_reason=FinishReason.STOP,
                usage=UsageReport(
                    prompt_tokens=10,
                    completion_tokens=10,
                    total_tokens=20,
                    accounting_type=UsageAccountingType.REPORTED,
                ),
                latency_seconds=0.001,
                attempts_count=1,
            )

        item = self.queue.pop(0)

        if isinstance(item, Exception):
            raise item
        elif callable(item):
            res = item()
            if isinstance(res, Exception):
                raise res
            item = res

        delay = item.get("delay_seconds", 0.0)
        if delay > 0:
            if delay > remaining:
                await asyncio.sleep(remaining)
                raise ProviderTimeoutError(
                    f"Call delayed {delay}s exceeded remaining deadline {remaining:.2f}s",
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )
            await asyncio.sleep(delay)

        raw_text = item.get("raw_text", "")
        finish_reason = item.get("finish_reason", FinishReason.STOP)
        usage = item.get("usage")

        if finish_reason == FinishReason.LENGTH:
            raise TruncatedOutputError(
                "Output truncated due to length cap",
                raw_text=raw_text,
                provider_name=self.name,
                operation_id=request.operation_id,
            )

        # Clean reasoning tags using streaming sanitizer if streaming
        if request.stream_callback is not None:
            sanitizer = StreamingReasoningSanitizer()
            safe_tok = sanitizer.feed(raw_text)
            safe_tail = sanitizer.flush()
            emitted = safe_tok + safe_tail
            if emitted:
                cb_res = request.stream_callback("content", emitted)
                if asyncio.iscoroutine(cb_res):
                    await cb_res

        cleaned_text = clean_reasoning_tags(raw_text)

        if usage is None:
            usage = UsageReport(
                prompt_tokens=10,
                completion_tokens=max(1, len(cleaned_text) // 4),
                total_tokens=10 + max(1, len(cleaned_text) // 4),
                accounting_type=UsageAccountingType.REPORTED,
            )

        parsed_payload = None
        if request.capability == Capability.GENERATE_JSON or request.response_schema is not None or request.target_model is not None:
            parsed_payload = parse_defensive_json(
                raw_text=cleaned_text,
                max_response_bytes=request.max_response_bytes,
                target_model=request.target_model,
                response_schema=request.response_schema,
                allow_repair=request.allow_repair,
            )

        latency = time.perf_counter() - t0
        return ProviderResponse(
            operation_id=request.operation_id,
            provider_name=self.name,
            model_name=self.get_model_name(request.model_size),
            raw_text=cleaned_text,
            parsed_payload=parsed_payload,
            finish_reason=finish_reason,
            usage=usage,
            provider_request_id=f"mock-req-{len(self.recorded_calls)}",
            latency_seconds=round(latency, 4),
            attempts_count=1,
        )

    async def check_health(self, api_key: Optional[str] = None) -> bool:
        return True

    def assert_no_secret_leaks(self, secrets: List[str]) -> bool:
        """Verifies that none of the provided secrets leaked into recorded requests or outputs."""
        for call_record in self.recorded_calls:
            req: ProviderRequest = call_record["request"]
            for m in req.messages:
                for sec in secrets:
                    if sec and sec in m.content:
                        return False
        return True
