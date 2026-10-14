from __future__ import annotations

import asyncio
import hashlib
import json
import logging
import os
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from uuid import UUID

from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import OperationGrantRequest, OperationReconcileRequest, UnknownOutcomeRequest
from app.providers.base import redact_secrets
from app.providers.errors import (
    BudgetExhaustedError,
    CancelledError,
    DeadlineExceededError,
    InvalidJsonError,
    ProviderError,
    ProviderUnavailableError,
    RateLimitedError,
    TimeoutError as ProviderTimeoutError,
    TruncatedOutputError,
    UnauthorizedError,
)
from app.providers.models import ProviderRequest, ProviderResponse, UsageAccountingType
from app.providers.registry import ProviderRegistry, provider_registry
from app.providers.retry import RetryPolicy

logger = logging.getLogger(__name__)



class ProviderGateway:
    """Common gateway; every physical provider transport is durably budgeted."""

    def __init__(
        self,
        registry: Optional[ProviderRegistry] = None,
        retry_policy: Optional[RetryPolicy] = None,
        checkpoint_client: Optional[CheckpointClient] = None,
    ):
        self.registry = registry or provider_registry
        self.retry_policy = retry_policy or RetryPolicy(max_attempts=3)
        self.checkpoint_client = checkpoint_client
        self.last_response: Optional[ProviderResponse] = None

    async def execute(
        self,
        request: ProviderRequest,
        epoch: int = 1,
        lease_owner: Optional[UUID] = None,
    ) -> ProviderResponse:
        max_attempts = self.retry_policy.max_attempts
        is_unlimited_profile = (
            request.is_unlimited is True
            or float(request.wall_time_reservation_seconds) <= 0
            or (request.preferred_provider and request.preferred_provider.lower() == "minimax")
        )
        if not is_unlimited_profile and self.checkpoint_client and request.run_id:
            try:
                if getattr(self, "_unlimited_runs", None) is None:
                    self._unlimited_runs = set()
                if request.run_id in self._unlimited_runs:
                    is_unlimited_profile = True
                else:
                    state = self.checkpoint_client.resume_state(request.run_id)
                    if state and state.budgetProfileJson and "UNLIMITED" in state.budgetProfileJson:
                        self._unlimited_runs.add(request.run_id)
                        is_unlimited_profile = True
            except Exception:
                pass

        per_attempt_timeout = max(float(request.timeout_seconds), 120.0) if is_unlimited_profile else float(request.timeout_seconds)
        deadline = time.time() + (per_attempt_timeout * max_attempts if is_unlimited_profile else float(request.timeout_seconds))
        if not request.operation_id:
            raise ProviderError("operation_id is required for all provider requests")
        if not request.messages:
            raise ProviderError("At least one chat message is required")
        if self.checkpoint_client is None:
            raise ProviderError(
                "Authentication and durable persistence authority required: checkpoint_client cannot be None",
                is_retryable=False,
                operation_id=request.operation_id,
            )
        if not request.run_id:
            raise ProviderError(
                "Durable operation reservation required: request.run_id cannot be empty",
                is_retryable=False,
                operation_id=request.operation_id,
            )
        if lease_owner is None:
            raise ProviderError(
                "Lease authority required: lease_owner cannot be None",
                is_retryable=False,
                operation_id=request.operation_id,
            )

        prompt_hash = request.prompt_hash
        if not prompt_hash:
            prompt_text = "".join(f"{message.role}:{message.content}\n" for message in request.messages)
            prompt_hash = hashlib.sha256(prompt_text.encode("utf-8")).hexdigest()
        logical_hash = hashlib.sha256(json.dumps(
            {
                "promptHash": prompt_hash,
                "messages": [{"role": message.role, "content": message.content} for message in request.messages],
                "capability": request.capability.value,
                "modelSize": request.model_size,
                "preferredProvider": request.preferred_provider,
                "modelConfigVersion": request.model_config_version,
                "temperature": request.temperature,
                "maxTokens": request.max_tokens,
                "responseSchema": request.response_schema,
            },
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=True,
            default=str,
        ).encode("ascii")).hexdigest()

        provider_order = self.registry.get_provider_order(preferred=request.preferred_provider)
        if not provider_order:
            raise ProviderUnavailableError("No registered LLM providers available", operation_id=request.operation_id)

        max_attempts = self.retry_policy.max_attempts
        attempt_number = 1
        provider_index = 0
        last_error: Optional[Exception] = None

        async def mark_unknown(operation_id: str, error: BaseException) -> None:
            await self.checkpoint_client.record_unknown_outcome_async(
                UnknownOutcomeRequest(
                    runId=request.run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=operation_id,
                    errorMessage=redact_secrets(str(error))[:500],
                )
            )
        effective_max_attempts = max_attempts
        while attempt_number <= effective_max_attempts:
            if not is_unlimited_profile and time.time() >= deadline:
                last_error = DeadlineExceededError(
                    f"Overall deadline of {request.timeout_seconds:.1f}s exceeded for operation '{request.operation_id}'",
                    operation_id=request.operation_id,
                )
                break
            if is_unlimited_profile:
                deadline = max(deadline, time.time() + per_attempt_timeout)
            if provider_index >= len(provider_order):
                provider_index = 0

            provider_name = provider_order[provider_index]
            provider = self.registry.get_provider(provider_name)
            if provider is None:
                provider_index += 1
                if provider_index >= len(provider_order):
                    last_error = ProviderUnavailableError("No registered providers remain", operation_id=request.operation_id)
                    break
                continue

            key_info = await self.registry.get_next_key(provider_name)
            if key_info is None and time.time() + 5.0 < deadline:
                await asyncio.sleep(2.0)
                key_info = await self.registry.get_next_key(provider_name)
            if key_info is None:
                logger.warning("All %s keys exhausted/in cooldown; rotating to fallback provider", provider_name.upper())
                provider_index += 1
                if provider_index >= len(provider_order):
                    last_error = ProviderUnavailableError("All configured provider keys are unavailable", operation_id=request.operation_id)
                    break
                continue

            api_key, key_index = key_info
            rate_limiter = self.registry.get_rate_limiter(provider_name)
            semaphore = self.registry.get_semaphore(provider_name)
            await rate_limiter.acquire()
            retry_after: Optional[float] = None
            retryable_failure = False
            attempt_operation_id = request.operation_id if attempt_number == 1 else f"{request.operation_id}:attempt:{attempt_number}"
            attempt_request = request.model_copy(update={"operation_id": attempt_operation_id})

            async with semaphore:
                if not is_unlimited_profile and time.time() >= deadline:
                    last_error = DeadlineExceededError(
                        f"Deadline elapsed before reservation for operation '{request.operation_id}'",
                        operation_id=request.operation_id,
                    )
                    break

                token_reservation = provider.conservative_token_reservation(attempt_request)
                if token_reservation <= 0:
                    raise ProviderError("Provider returned an invalid non-positive token reservation", operation_id=attempt_operation_id)
                if is_unlimited_profile:
                    wall_reservation = per_attempt_timeout
                else:
                    elapsed_gateway_wall = time.time() - (deadline - float(request.timeout_seconds))
                    remaining_parent_wall = max(0.0, float(request.wall_time_reservation_seconds) - max(0.0, elapsed_gateway_wall))
                    wall_reservation = min(
                        float(request.wall_time_reservation_seconds),
                        remaining_parent_wall,
                        max(0.0, deadline - time.time()),
                    )
                    if wall_reservation <= 0:
                        last_error = DeadlineExceededError("No remaining time for a provider attempt", operation_id=request.operation_id)
                        break

                model_name = provider.get_model_name(request.model_size)
                attempt_hash = hashlib.sha256(json.dumps(
                    {
                        "request": logical_hash,
                        "attempt": attempt_number,
                        "provider": provider_name,
                        "model": model_name,
                        "tokenReservation": token_reservation,
                    },
                    sort_keys=True,
                    separators=(",", ":"),
                    ensure_ascii=True,
                ).encode("ascii")).hexdigest()
                grant_request = OperationGrantRequest(
                    runId=request.run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=attempt_operation_id,
                    operationType="PROVIDER_CALL",
                    requestHash=attempt_hash,
                    tokenReservation=token_reservation,
                    costReservationUsd=0.0,
                    wallTimeReservationSeconds=wall_reservation,
                    sectionId=request.section_id,
                    artifactId=request.artifact_id,
                    parentOperationId=request.parent_operation_id,
                )
                try:
                    grant = await self.checkpoint_client.grant_operation_async(grant_request)
                except CheckpointApiError as api_error:
                    if api_error.status_code == 422:
                        raise BudgetExhaustedError(f"Budget cap exceeded: {api_error.message}", operation_id=attempt_operation_id)
                    if api_error.status_code == 409:
                        raise ProviderError(
                            f"Epoch fencing violation or request hash conflict: {api_error.message}",
                            is_retryable=False,
                            status_code=409,
                            operation_id=attempt_operation_id,
                        )
                    raise ProviderError(
                        f"Checkpoint service error: {api_error.message}",
                        is_retryable=False,
                        status_code=api_error.status_code,
                        operation_id=attempt_operation_id,
                    )

                if grant.isReplay:
                    status = grant.status.upper()
                    if status == "COMPLETED":
                        if grant.reservationBreached or grant.budgetBreachDetected:
                            raise BudgetExhaustedError(
                                "Persisted provider attempt breached its reservation; further dispatch is blocked",
                                operation_id=attempt_operation_id,
                            )
                        result_json = grant.resultRefJson
                        if result_json is None:
                            state = await self.checkpoint_client.resume_state_async(request.run_id)
                            persisted = next((op for op in state.operations or [] if op.operationId == attempt_operation_id), None)
                            result_json = persisted.resultRefJson if persisted else None
                        if not result_json:
                            raise ProviderError(
                                "Completed provider attempt has no persisted response to replay",
                                is_retryable=False,
                                status_code=409,
                                operation_id=attempt_operation_id,
                            )
                        response = ProviderResponse.model_validate_json(result_json)
                        response.operation_id = request.operation_id
                        response.attempts_count = attempt_number
                        self.last_response = response
                        return response
                    if status not in ("RESERVED", "UNKNOWN_OUTCOME"):
                        raise ProviderError(
                            f"Persisted provider attempt has non-replayable status '{status}'",
                            is_retryable=False,
                            status_code=409,
                            operation_id=attempt_operation_id,
                        )
                    if status == "RESERVED":
                        await mark_unknown(attempt_operation_id, RuntimeError("Replayed RESERVED attempt is ambiguous after restart"))
                    last_error = ProviderUnavailableError(
                        f"Persisted attempt '{attempt_operation_id}' has unknown outcome; advancing without redispatch",
                        operation_id=attempt_operation_id,
                    )
                    retryable_failure = True
                else:
                    if time.time() >= deadline:
                        last_error = DeadlineExceededError(
                            "Deadline elapsed after durable reservation and before provider dispatch",
                            operation_id=attempt_operation_id,
                        )
                        await mark_unknown(attempt_operation_id, last_error)
                        break
                    try:
                        call_deadline = time.time() + per_attempt_timeout
                        response = await provider.call(attempt_request, api_key, call_deadline)
                    except UnauthorizedError as error:
                        await mark_unknown(attempt_operation_id, error)
                        logger.error("Provider %s authentication failed (HTTP 401/403): %s", provider_name, redact_secrets(str(error)))
                        raise
                    except RateLimitedError as error:
                        last_error = error
                        retry_after = error.retry_after_seconds
                        await self.registry.mark_key_exhausted(
                            provider_name,
                            key_index,
                            cooldown_seconds=retry_after or 65.0,
                            reason=str(error),
                        )
                        # Safely reconcile definite HTTP 429 rejection (UNKNOWN usage, zero tokens)
                        try:
                            reconcile_429 = OperationReconcileRequest(
                                runId=request.run_id,
                                epoch=epoch,
                                leaseOwner=lease_owner,
                                operationId=attempt_operation_id,
                                tokensUsed=0,
                                wallTimeUsedSeconds=0.1,
                                promptTokensUsed=None,
                                completionTokensUsed=None,
                                reasoningTokensUsed=None,
                                accountingType=UsageAccountingType.UNKNOWN.value,
                                resultRefJson=json.dumps({"error": "HTTP 429 RateLimitedError", "retry_after": error.retry_after_seconds}),
                            )
                            await self.checkpoint_client.reconcile_operation_async(reconcile_429)
                        except Exception as rec_err:
                            logger.warning("Could not reconcile 429 attempt '%s': %s", attempt_operation_id, rec_err)
                            await mark_unknown(attempt_operation_id, error)
                        retryable_failure = True
                    except (ProviderTimeoutError, ProviderUnavailableError) as error:
                        await mark_unknown(attempt_operation_id, error)
                        last_error = error
                        retryable_failure = True
                    except (CancelledError, asyncio.CancelledError):
                        # The durable RESERVED row is conservative and is treated as unknown on resume.
                        raise
                    except (InvalidJsonError, TruncatedOutputError) as error:
                        rep_usage = getattr(error, "usage", None)
                        if rep_usage is not None and getattr(rep_usage, "total_tokens", 0) > 0:
                            try:
                                reconcile_actual = OperationReconcileRequest(
                                    runId=request.run_id,
                                    epoch=epoch,
                                    leaseOwner=lease_owner,
                                    operationId=attempt_operation_id,
                                    tokensUsed=rep_usage.total_tokens,
                                    wallTimeUsedSeconds=0.1,
                                    promptTokensUsed=rep_usage.prompt_tokens,
                                    completionTokensUsed=rep_usage.completion_tokens,
                                    reasoningTokensUsed=rep_usage.reasoning_tokens,
                                    accountingType=rep_usage.accounting_type.value if hasattr(rep_usage.accounting_type, "value") else str(rep_usage.accounting_type),
                                    resultRefJson=json.dumps({"error": str(error)}),
                                )
                                await self.checkpoint_client.reconcile_operation_async(reconcile_actual)
                            except Exception as rec_err:
                                logger.warning("Could not reconcile format error attempt '%s': %s", attempt_operation_id, rec_err)
                                await mark_unknown(attempt_operation_id, error)
                        else:
                            await mark_unknown(attempt_operation_id, error)
                        last_error = error
                        retryable_failure = True
                        logger.warning("Provider %s returned format error on attempt %d: %s; retrying dispatch", provider_name, attempt_number, error)
                    except Exception as error:
                        await mark_unknown(attempt_operation_id, error)
                        last_error = error
                        logger.error("Non-retryable provider error from %s: %s", provider_name, redact_secrets(str(error)))
                        break
                    else:
                        response.operation_id = request.operation_id
                        response.attempts_count = attempt_number
                        usage = response.usage
                        usage_known = usage.accounting_type != UsageAccountingType.UNKNOWN
                        result_json = response.model_dump_json(by_alias=True)
                        try:
                            from app.observability.accounting import get_token_accountant
                            rep_tokens = usage.total_tokens if usage.accounting_type == UsageAccountingType.REPORTED_ACTUAL else 0
                            est_tokens = usage.total_tokens if usage.accounting_type == UsageAccountingType.ESTIMATED_HEURISTIC else 0
                            unk_tokens = usage.total_tokens if usage.accounting_type == UsageAccountingType.UNKNOWN else 0
                            get_token_accountant().record_usage(
                                provider=provider_name,
                                model=response.model_name or model_name,
                                reported_tokens=rep_tokens,
                                estimated_tokens=est_tokens,
                                unknown_tokens=unk_tokens,
                            )
                        except Exception as acc_err:
                            logger.debug("Telemetry token accounting notice: %s", acc_err)
                        reconcile_request = OperationReconcileRequest(
                            runId=request.run_id,
                            epoch=epoch,
                            leaseOwner=lease_owner,
                            operationId=attempt_operation_id,
                            tokensUsed=usage.total_tokens if usage_known else 0,
                            wallTimeUsedSeconds=response.latency_seconds,
                            promptTokensUsed=usage.prompt_tokens if usage_known else None,
                            completionTokensUsed=usage.completion_tokens if usage_known else None,
                            reasoningTokensUsed=usage.reasoning_tokens if usage_known else None,
                            costUsedUsd=usage.estimated_cost_usd,
                            accountingType=usage.accounting_type.value,
                            resultRefJson=result_json,
                        )
                        try:
                            result = await self.checkpoint_client.reconcile_operation_async(reconcile_request)
                        except Exception as error:
                            logger.error("Failed to reconcile operation '%s': %s", attempt_operation_id, redact_secrets(str(error)))
                            raise ProviderError(
                                f"Failed to persist durable operation reconciliation: {redact_secrets(str(error))}",
                                is_retryable=False,
                                operation_id=attempt_operation_id,
                            ) from error
                        self.last_response = response
                        if result.reservationBreached or result.budgetBreachDetected:
                            raise BudgetExhaustedError(
                                "Provider usage exceeded its durable reservation; actual usage was recorded and further dispatch is blocked",
                                operation_id=attempt_operation_id,
                            )
                        return response

            if not retryable_failure:
                break
            # If this physical attempt failed with RateLimitedError on a multi-key provider,
            # rotate immediately to the next key on the SAME provider (do not apply exhausted key's retry_after delay)
            provider_keys = self.registry._keys.get(provider_name, [])
            if isinstance(last_error, RateLimitedError) and len(provider_keys) > 1 and attempt_number < min(4, len(provider_keys)):
                attempt_number += 1
                effective_max_attempts = max(effective_max_attempts, attempt_number)
                continue

            if attempt_number >= max_attempts:
                break
            delay = self.retry_policy.compute_delay(attempt_number - 1, retry_after=retry_after)
            if not is_unlimited_profile and time.time() + delay > deadline:
                last_error = DeadlineExceededError(
                    f"Backoff delay ({delay:.1f}s) would exceed remaining deadline for operation '{request.operation_id}'",
                    operation_id=request.operation_id,
                )
                break
            try:
                await asyncio.sleep(delay)
            except asyncio.CancelledError:
                raise CancelledError(
                    f"Operation '{request.operation_id}' was cancelled during backoff",
                    operation_id=request.operation_id,
                )
            provider_index = (provider_index + 1) % len(provider_order)
            attempt_number += 1

        if not is_unlimited_profile and time.time() >= deadline:
            raise DeadlineExceededError(
                f"Overall deadline of {request.timeout_seconds:.1f}s exceeded for operation '{request.operation_id}'",
                operation_id=request.operation_id,
            )
        if isinstance(last_error, ProviderError):
            raise last_error
        raise ProviderUnavailableError(
            f"All {max_attempts} attempts exhausted for operation '{request.operation_id}'. Last error: {last_error}",
            operation_id=request.operation_id,
        )


provider_gateway = ProviderGateway()