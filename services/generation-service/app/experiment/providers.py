"""Explicit research-only bridge to the existing OpenAI-compatible adapters.

Unlike the production gateway, this bridge never rotates providers or retries.
It inspects the SDK response's model (the production adapter reports its configured
model instead), retains response text before normalization, and never infers cost.
Construct it explicitly with a configured MiniMax/Groq/OpenAI-compatible adapter
and environment-supplied credentials; construction does not perform network I/O.
"""
from __future__ import annotations
import asyncio
import hashlib
import json
import re
import time
from pathlib import Path
from typing import Any

from openai import APIConnectionError, APIStatusError, APITimeoutError

from app.contracts.research import ExecutionStatus
from app.experiment.freeze_manifest import ResourceBudgetExceededError
from app.experiment.runners import LLMDispatchResponse
from app.providers.adapters.openai_compatible import OpenAICompatibleProvider
from app.providers.models import Capability, ChatMessage, ProviderRequest


class RawResponseStore:
    """Secure, write-through store for authentic provider responses (attempt_id + stage keyed)."""

    def __init__(self, storage_dir: str | Path | None = None) -> None:
        if storage_dir is None:
            storage_dir = Path("generation_baseline/.execution/RG10/raw_responses")
        self.storage_dir = Path(storage_dir)
        self.storage_dir.mkdir(parents=True, exist_ok=True)
        try:
            self.storage_dir.chmod(0o700)
        except OSError:
            pass

    def store(
        self,
        *,
        operation_id: str,
        stage: str,
        model_id: str | None,
        prompt: str,
        system_prompt: str,
        raw_text: str,
        latency_ms: float | None = None,
        tokens: dict[str, Any] | None = None,
        provider_request_id: str | None = None,
        request_config: dict[str, Any] | None = None,
        failure_code: str | None = None,
    ) -> str:
        safe_op = re.sub(r"[^a-zA-Z0-9_-]", "_", operation_id)
        timestamp_ns = time.time_ns()
        filename = f"{safe_op}_{stage}_{timestamp_ns}.json"
        target_path = self.storage_dir / filename
        data = {
            "operation_id": operation_id,
            "stage": stage,
            "model_id": model_id,
            "provider_request_id": provider_request_id,
            "raw_text": raw_text,
            "raw_text_sha256": hashlib.sha256(raw_text.encode("utf-8")).hexdigest() if raw_text else None,
            "prompt_sha256": hashlib.sha256(prompt.encode("utf-8")).hexdigest() if prompt else None,
            "system_prompt_sha256": hashlib.sha256(system_prompt.encode("utf-8")).hexdigest() if system_prompt else None,
            "latency_ms": latency_ms,
            "tokens": tokens or {},
            "request_config": request_config or {},
            "failure_code": failure_code,
            "recorded_at_ns": timestamp_ns,
        }
        temp_path = target_path.with_suffix(".tmp")
        temp_path.write_text(json.dumps(data, indent=2), encoding="utf-8")
        try:
            temp_path.chmod(0o600)
        except OSError:
            pass
        temp_path.replace(target_path)
        return f"secure://raw_responses/{filename}"


class OpenAICompatibleExperimentClient:
    """One pinned transport, explicit finite parameters, zero hidden retries.

    Synchronous experiment runners must be invoked outside an active async loop
    (an async host may run the complete research job with asyncio.to_thread).
    Use as a context manager or call close() to close owned SDK clients/loop.
    Injected adapters and HTTP clients remain caller-owned.
    """
    is_live = True

    def __init__(self, provider: OpenAICompatibleProvider, api_key: str, *,
                 max_tokens: int = 4000, timeout_seconds: float = 60.0,
                 temperature: float = 0.2, top_p: float = 0.95, seed: int = 2026,
                 max_response_bytes: int = 500_000,
                 raw_response_store: RawResponseStore | None = None) -> None:
        if not api_key.strip():
            raise ValueError("Explicit provider credentials are required")
        if max_tokens <= 0 or timeout_seconds <= 0 or max_response_bytes <= 0:
            raise ValueError("Finite positive completion, timeout and response limits are required")
        if not 0 <= temperature <= 2 or not 0 < top_p <= 1:
            raise ValueError("Invalid sampling parameters")
        self.provider = provider
        self._api_key = api_key
        self._provider_name = provider.name
        self._model = provider.get_model_name("large")
        self._base_url = provider.base_url
        self.max_tokens, self.timeout_seconds = max_tokens, timeout_seconds
        self.temperature, self.top_p, self.seed = temperature, top_p, seed
        self.max_response_bytes = max_response_bytes
        self.raw_response_store = raw_response_store
        self.cumulative_spent_usd: float = 0.0
        self.cumulative_tokens: int = 0
        self.max_spending_limit_usd: float | None = None
        self.recorded_dispatches: list[dict[str, Any]] = []
        self._loop: asyncio.AbstractEventLoop | None = None
        self._sdk: Any = None

    def __enter__(self) -> OpenAICompatibleExperimentClient:
        return self

    def __exit__(self, *args: Any) -> None:
        self.close()

    def close(self) -> None:
        if self._loop is not None:
            if self._sdk is not None and self.provider.http_client is None:
                self._loop.run_until_complete(self._sdk.close())
            self._loop.close()
            self._loop = None
            self._sdk = None

    def dispatch(self, prompt: str, model_id: str, system_prompt: str = "",
                 stage: str = "GENERATION", raw_output_override: str | None = None,
                 simulate_failure: str | None = None) -> LLMDispatchResponse:
        if raw_output_override is not None or simulate_failure is not None:
            return LLMDispatchResponse(raw_text="", failure_code="SYNTHETIC_OVERRIDE_FORBIDDEN",
                                       execution_status=ExecutionStatus.FAILED_RUNTIME, call_count=0)
        expected = f"{self._provider_name}/{self._model}"
        if model_id != expected or self.provider.get_model_name("large") != self._model or self.provider.name != self._provider_name or self.provider.base_url != self._base_url:
            return LLMDispatchResponse(raw_text="",
                                       failure_code="MODEL_IDENTITY_MISMATCH",
                                       execution_status=ExecutionStatus.FAILED_RUNTIME, call_count=0)
        try:
            asyncio.get_running_loop()
        except RuntimeError:
            pass
        else:
            return LLMDispatchResponse(raw_text="", model_id=model_id,
                                       failure_code="ASYNC_CONTEXT_REQUIRES_RESEARCH_WORKER",
                                       execution_status=ExecutionStatus.FAILED_RUNTIME, call_count=0)
        if self._loop is None:
            self._loop = asyncio.new_event_loop()
        response = self._loop.run_until_complete(self._dispatch(prompt, system_prompt, stage))
        self.recorded_dispatches.append({"stage": stage, "model_id": response.model_id,
                                         "provider_request_id": response.provider_request_id,
                                         "call_count": response.call_count})
        return response

    async def _dispatch(self, prompt: str, system_prompt: str, stage: str) -> LLMDispatchResponse:
        request = ProviderRequest(
            capability=Capability.GENERATE_TEXT,
            messages=[ChatMessage(role="system", content=system_prompt), ChatMessage(role="user", content=prompt)],
            operation_id=f"research-{stage}-{len(self.recorded_dispatches) + 1}",
            model_size="large", preferred_provider=self._provider_name,
            temperature=self.temperature, max_tokens=self.max_tokens,
            timeout_seconds=self.timeout_seconds, allow_repair=False,
            max_response_bytes=self.max_response_bytes,
        )
        # Reuse the existing adapter's provider-specific wire knobs (e.g. MiniMax
        # reasoning_split). Parsing/retry/model-identity behavior stays research-only.
        kwargs = {**self.provider._build_create_kwargs(request, self._model),
                  "top_p": self.top_p, "seed": self.seed}
        config = {"provider_name": self._provider_name,
                  "endpoint_sha256": hashlib.sha256(self._base_url.encode()).hexdigest(),
                  "wire_parameters": {key: value for key, value in kwargs.items() if key != "messages"},
                  "timeout_seconds": self.timeout_seconds, "max_response_bytes": self.max_response_bytes,
                  "sdk_max_retries": 0}
        if max(kwargs.get("max_tokens", 0), kwargs.get("max_completion_tokens", 0)) > self.max_tokens:
            return LLMDispatchResponse(raw_text="", request_config=config,
                                       failure_code="PROVIDER_COMPLETION_LIMIT_MISMATCH",
                                       execution_status=ExecutionStatus.FAILED_RUNTIME, call_count=0)
        if self.max_spending_limit_usd is not None and self.cumulative_spent_usd >= self.max_spending_limit_usd:
            raise ResourceBudgetExceededError(
                f"Hard campaign spending ceiling (${self.max_spending_limit_usd:.2f} USD) reached. "
                f"Current spent: ${self.cumulative_spent_usd:.4f} USD. Halting dispatches."
            )
        if self._sdk is None:
            from openai import AsyncOpenAI
            self._sdk = AsyncOpenAI(api_key=self._api_key, base_url=self._base_url, max_retries=0,
                                    http_client=self.provider.http_client)
        started = time.perf_counter()
        try:
            response = await asyncio.wait_for(self._sdk.chat.completions.create(**kwargs),
                                              timeout=self.timeout_seconds)
        except (asyncio.TimeoutError, APITimeoutError):
            return self._failure("PROVIDER_TIMEOUT", ExecutionStatus.TIMED_OUT, started, config,
                                 operation_id=request.operation_id, stage=stage, prompt=prompt, system_prompt=system_prompt)
        except APIStatusError as error:
            code = "PROVIDER_UNAUTHORIZED" if error.status_code in (401, 403) else (
                "PROVIDER_RATE_LIMITED" if error.status_code == 429 else "PROVIDER_UNAVAILABLE")
            return self._failure(code, ExecutionStatus.FAILED_RUNTIME, started, config,
                                 operation_id=request.operation_id, stage=stage, prompt=prompt, system_prompt=system_prompt)
        except APIConnectionError:
            return self._failure("PROVIDER_UNAVAILABLE", ExecutionStatus.FAILED_RUNTIME, started, config,
                                 operation_id=request.operation_id, stage=stage, prompt=prompt, system_prompt=system_prompt)
        latency = (time.perf_counter() - started) * 1000
        actual_model = getattr(response, "model", None)
        model_id = (actual_model if actual_model.startswith(self._provider_name + "/")
                    else f"{self._provider_name}/{actual_model}") if isinstance(actual_model, str) and actual_model else None
        choice = response.choices[0] if response.choices else None
        raw = choice.message.content or "" if choice else ""
        usage = getattr(response, "usage", None)
        counts = [getattr(usage, key, None) for key in ("prompt_tokens", "completion_tokens", "total_tokens")]
        counts = [value if isinstance(value, int) and not isinstance(value, bool) and value >= 0 else None for value in counts]
        if counts[2] is None and counts[0] is not None and counts[1] is not None:
            counts = [counts[0], counts[1], counts[0] + counts[1]]
        p_tok = counts[0] if counts[0] is not None else 1000
        c_tok = counts[1] if counts[1] is not None else self.max_tokens
        self.cumulative_tokens += (p_tok + c_tok)
        self.cumulative_spent_usd += (p_tok + c_tok) * 0.0000015
        confidence = "EXACT" if all(value is not None for value in counts) else "UNKNOWN"
        failure = None
        if len(raw.encode("utf-8")) > self.max_response_bytes:
            # Do not hash a truncated replacement as if it were the provider response.
            failure = "PROVIDER_RESPONSE_TOO_LARGE"
        elif choice is None:
            failure = "PROVIDER_RESPONSE_EMPTY"
        elif choice.finish_reason == "length":
            failure = "PROVIDER_OUTPUT_TRUNCATED"
        elif choice.finish_reason == "content_filter" or getattr(choice.message, "refusal", None):
            failure = "PROVIDER_OUTPUT_REJECTED"
        raw_ref = None
        if self.raw_response_store is not None:
            raw_ref = self.raw_response_store.store(
                operation_id=request.operation_id,
                stage=stage,
                model_id=model_id,
                prompt=prompt,
                system_prompt=system_prompt,
                raw_text=raw,
                latency_ms=latency,
                tokens={"prompt": counts[0], "completion": counts[1], "total": counts[2]},
                provider_request_id=getattr(response, "id", None),
                request_config=config,
                failure_code=failure,
            )
        return LLMDispatchResponse(
            raw_text=raw, model_id=model_id, prompt_tokens=counts[0], completion_tokens=counts[1],
            total_tokens=counts[2], latency_ms=latency, confidence=confidence,
            token_source="PROVIDER" if confidence == "EXACT" else "UNKNOWN",
            provider_request_id=getattr(response, "id", None), response_origin="PROVIDER",
            request_config=config, failure_code=failure,
            execution_status=ExecutionStatus.FAILED_VALIDATION if failure else None,
            raw_response_ref=raw_ref,
        )

    def _failure(self, code: str, status: ExecutionStatus, started: float, config: dict[str, Any],
                 operation_id: str = "", stage: str = "", prompt: str = "", system_prompt: str = "") -> LLMDispatchResponse:
        latency = (time.perf_counter() - started) * 1000
        raw_ref = None
        if self.raw_response_store is not None and operation_id:
            raw_ref = self.raw_response_store.store(
                operation_id=operation_id, stage=stage, model_id=f"{self._provider_name}/{self._model}",
                prompt=prompt, system_prompt=system_prompt, raw_text="", latency_ms=latency,
                request_config=config, failure_code=code,
            )
        return LLMDispatchResponse(raw_text="", failure_code=code, execution_status=status,
                                   response_origin="PROVIDER", request_config=config,
                                   latency_ms=latency, raw_response_ref=raw_ref)
