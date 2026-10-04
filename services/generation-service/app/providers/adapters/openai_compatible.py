from __future__ import annotations

import asyncio
import logging
import time
import httpx
from typing import Any, Dict, List, Optional
from openai import (
    AsyncOpenAI,
    APIConnectionError,
    APIStatusError,
    AuthenticationError,
    RateLimitError as OpenAIRateLimitError,
)

from app.providers.base import BaseProvider, redact_secrets
from app.providers.errors import (
    CancelledError,
    InvalidJsonError,
    ProviderError,
    ProviderUnavailableError,
    RateLimitedError,
    SchemaMismatchError,
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

logger = logging.getLogger(__name__)


class OpenAICompatibleProvider(BaseProvider):
    """Generic adapter for OpenAI-compatible Chat Completions APIs."""

    def __init__(
        self,
        name: str,
        base_url: str,
        models: Dict[str, str],
        supports_response_format: bool = True,
        http_client: Optional[httpx.AsyncClient] = None,
        max_retries: int = 0,
    ):
        super().__init__(name=name, base_url=base_url, models=models)
        self.supports_response_format = supports_response_format
        self.http_client = http_client
        self.max_retries = max_retries
        self._clients: Dict[str, AsyncOpenAI] = {}

    def _get_client(self, api_key: str) -> AsyncOpenAI:
        cache_key = f"{self.name}:{api_key[:8]}"
        if cache_key not in self._clients:
            client_kwargs: Dict[str, Any] = {
                "api_key": api_key,
                "base_url": self.base_url,
                "max_retries": self.max_retries,
            }
            if self.http_client is not None:
                client_kwargs["http_client"] = self.http_client
            self._clients[cache_key] = AsyncOpenAI(**client_kwargs)
        return self._clients[cache_key]
    def _build_create_kwargs(self, request: ProviderRequest, model_name: str) -> Dict[str, Any]:
        messages = [{"role": m.role, "content": m.content} for m in request.messages]
        kwargs: Dict[str, Any] = {
            "model": model_name,
            "messages": messages,
            "temperature": request.temperature,
            "max_tokens": request.max_tokens,
        }
        if request.capability == Capability.GENERATE_JSON and self.supports_response_format:
            kwargs["response_format"] = {"type": "json_object"}
        return kwargs

    async def call(self, request: ProviderRequest, api_key: str, deadline: float) -> ProviderResponse:
        t0 = time.perf_counter()
        now = time.time()
        remaining = deadline - now
        if remaining <= 0:
            raise ProviderTimeoutError(
                f"Deadline exceeded before calling provider {self.name}",
                provider_name=self.name,
                operation_id=request.operation_id,
            )

        timeout_for_call = min(float(request.timeout_seconds), remaining)
        model_name = self.get_model_name(request.model_size)
        client = self._get_client(api_key)
        kwargs = self._build_create_kwargs(request, model_name)

        try:
            if request.stream_callback is not None:
                kwargs["stream"] = True
                content_parts: List[str] = []
                sanitizer = StreamingReasoningSanitizer()

                async def _consume_stream() -> str:
                    stream_resp = await client.chat.completions.create(**kwargs)
                    async for chunk in stream_resp:
                        if time.time() > deadline:
                            raise ProviderTimeoutError(
                                f"Absolute deadline exceeded while reading stream from provider {self.name}",
                                provider_name=self.name,
                                operation_id=request.operation_id,
                            )
                        if not getattr(chunk, "choices", None):
                            continue
                        ch = chunk.choices[0]
                        delta = getattr(ch, "delta", None)
                        if not delta:
                            continue
                        tok = getattr(delta, "content", None) or ""
                        r_tok = getattr(delta, "reasoning_content", None) or getattr(delta, "reasoning", None) or ""

                        if r_tok:
                            sanitizer.reasoning_tokens_count += max(1, len(r_tok) // 4)

                        if tok:
                            safe_tok = sanitizer.feed(tok)
                            if safe_tok:
                                content_parts.append(safe_tok)
                                cb_res = request.stream_callback("content", safe_tok)
                                if asyncio.iscoroutine(cb_res):
                                    await cb_res

                    safe_tail = sanitizer.flush()
                    if safe_tail:
                        content_parts.append(safe_tail)
                        cb_res = request.stream_callback("content", safe_tail)
                        if asyncio.iscoroutine(cb_res):
                            await cb_res

                    return "".join(content_parts)

                raw_text = await asyncio.wait_for(_consume_stream(), timeout=timeout_for_call)
                finish_reason_raw = "stop"
                resp_usage = None
                request_id = None
            else:
                response = await asyncio.wait_for(
                    client.chat.completions.create(**kwargs),
                    timeout=timeout_for_call,
                )
                choice = response.choices[0]
                raw_text = choice.message.content or ""
                finish_reason_raw = choice.finish_reason or "stop"
                resp_usage = getattr(response, "usage", None)
                request_id = getattr(response, "id", None)

            latency = time.perf_counter() - t0

            # Map finish reason
            if finish_reason_raw == "length":
                finish_reason = FinishReason.LENGTH
            elif finish_reason_raw == "content_filter":
                finish_reason = FinishReason.CONTENT_FILTER
            elif finish_reason_raw == "stop":
                finish_reason = FinishReason.STOP
            else:
                finish_reason = FinishReason.UNKNOWN

            if finish_reason == FinishReason.LENGTH:
                raise TruncatedOutputError(
                    f"Provider {self.name} cut off output (finish_reason=length)",
                    raw_text=raw_text,
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )

            # Clean reasoning tags: <think> tags must NEVER leak into business payload or logs
            cleaned_text = clean_reasoning_tags(raw_text)

            # Resolve usage report
            if resp_usage:
                p_tokens = getattr(resp_usage, "prompt_tokens", 0) or 0
                c_tokens = getattr(resp_usage, "completion_tokens", 0) or 0
                t_tokens = getattr(resp_usage, "total_tokens", 0) or (p_tokens + c_tokens)
                r_tokens = 0
                details = getattr(resp_usage, "completion_tokens_details", None)
                if details:
                    r_tokens = getattr(details, "reasoning_tokens", 0) or 0
                usage = UsageReport(
                    prompt_tokens=p_tokens,
                    completion_tokens=c_tokens,
                    total_tokens=t_tokens,
                    reasoning_tokens=r_tokens,
                    accounting_type=UsageAccountingType.REPORTED,
                )
            else:
                prompt_est = sum(self.estimate_tokens(m.content) for m in request.messages)
                comp_est = self.estimate_tokens(cleaned_text)
                usage = UsageReport(
                    prompt_tokens=prompt_est,
                    completion_tokens=comp_est,
                    total_tokens=prompt_est + comp_est,
                    reasoning_tokens=0,
                    accounting_type=UsageAccountingType.ESTIMATED,
                )

            # Defensive parsing if JSON is expected
            parsed_payload = None
            if request.capability == Capability.GENERATE_JSON or request.response_schema is not None or request.target_model is not None:
                parsed_payload = parse_defensive_json(
                    raw_text=cleaned_text,
                    max_response_bytes=request.max_response_bytes,
                    target_model=request.target_model,
                    response_schema=request.response_schema,
                    allow_repair=request.allow_repair,
                )

            return ProviderResponse(
                operation_id=request.operation_id,
                provider_name=self.name,
                model_name=model_name,
                raw_text=cleaned_text,
                parsed_payload=parsed_payload,
                finish_reason=finish_reason,
                usage=usage,
                provider_request_id=request_id,
                latency_seconds=round(latency, 4),
                attempts_count=1,
            )

        except asyncio.CancelledError:
            raise CancelledError(
                f"Request was cancelled during call to provider {self.name}",
                provider_name=self.name,
                operation_id=request.operation_id,
            )
        except asyncio.TimeoutError:
            raise ProviderTimeoutError(
                f"Timeout after {timeout_for_call:.1f}s waiting for provider {self.name}",
                provider_name=self.name,
                operation_id=request.operation_id,
            )
        except OpenAIRateLimitError as rle:
            retry_after = None
            # Check response headers if available on exception
            resp = getattr(rle, "response", None)
            if resp and hasattr(resp, "headers"):
                ra_header = resp.headers.get("retry-after")
                if ra_header:
                    try:
                        retry_after = float(ra_header)
                    except ValueError:
                        pass
            raise RateLimitedError(
                message=redact_secrets(str(rle)),
                retry_after_seconds=retry_after,
                provider_name=self.name,
                operation_id=request.operation_id,
            )
        except AuthenticationError as ae:
            raise UnauthorizedError(
                message=redact_secrets(str(ae)),
                status_code=401,
                provider_name=self.name,
                operation_id=request.operation_id,
            )
        except APIStatusError as ase:
            status_code = getattr(ase, "status_code", 500)
            msg = redact_secrets(str(ase))
            if status_code in (401, 403):
                raise UnauthorizedError(
                    message=msg,
                    status_code=status_code,
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )
            elif status_code == 429:
                retry_after = None
                resp = getattr(ase, "response", None)
                if resp and hasattr(resp, "headers"):
                    ra_header = resp.headers.get("retry-after")
                    if ra_header:
                        try:
                            retry_after = float(ra_header)
                        except ValueError:
                            pass
                raise RateLimitedError(
                    message=msg,
                    retry_after_seconds=retry_after,
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )
            elif status_code in (408, 504):
                raise ProviderTimeoutError(
                    message=msg,
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )
            elif status_code >= 500:
                raise ProviderUnavailableError(
                    message=msg,
                    status_code=status_code,
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )
            else:
                raise ProviderError(
                    message=msg,
                    is_retryable=False,
                    status_code=status_code,
                    provider_name=self.name,
                    operation_id=request.operation_id,
                )
        except APIConnectionError as ace:
            raise ProviderUnavailableError(
                message=redact_secrets(f"Connection failed: {ace}"),
                provider_name=self.name,
                operation_id=request.operation_id,
            )
        except (InvalidJsonError, SchemaMismatchError, TruncatedOutputError):
            raise
        except Exception as exc:
            raise ProviderError(
                message=redact_secrets(f"Unexpected provider error: {exc}"),
                is_retryable=False,
                provider_name=self.name,
                operation_id=request.operation_id,
            )

    async def check_health(self, api_key: Optional[str] = None) -> bool:
        if not api_key:
            return False
        try:
            client = self._get_client(api_key)
            model_name = self.get_model_name("small")
            resp = await asyncio.wait_for(
                client.chat.completions.create(
                    model=model_name,
                    messages=[{"role": "user", "content": "ping"}],
                    max_tokens=5,
                ),
                timeout=10.0,
            )
            return bool(resp and resp.choices)
        except Exception as exc:
            logger.warning("Health check failed for %s: %s", self.name, redact_secrets(str(exc)))
            return False
