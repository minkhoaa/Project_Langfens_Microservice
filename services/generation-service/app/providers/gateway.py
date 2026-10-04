from __future__ import annotations

import asyncio
import hashlib
import logging
import time
from typing import Any, Dict, List, Optional
from uuid import UUID

from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import OperationGrantRequest, OperationReconcileRequest, UnknownOutcomeRequest
from app.providers.base import redact_secrets
from app.providers.errors import (
    BudgetExhaustedError,
    CancelledError,
    DeadlineExceededError,
    ProviderError,
    ProviderUnavailableError,
    RateLimitedError,
    TimeoutError as ProviderTimeoutError,
    UnauthorizedError,
)
from app.providers.models import (
    FinishReason,
    ProviderRequest,
    ProviderResponse,
    UsageAccountingType,
    UsageReport,
)
from app.providers.registry import ProviderRegistry, provider_registry
from app.providers.retry import RetryPolicy

logger = logging.getLogger(__name__)


class ProviderGateway:
    """Authoritative common gateway for all LLM interactions in Loop Engine V2.

    Coordinates operation reservations, provider selection, key rotation,
    concurrency limits, rate buckets, retries, and usage reconciliation.
    """

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
        """Executes a single provider request through the unified gateway pipeline.

        FAIL-CLOSED: Every provider request MUST obtain an authenticated durable
        operation reservation from the persistence authority before dispatch.
        """
        t0 = time.perf_counter()
        deadline = time.time() + float(request.timeout_seconds)

        # 1. Validation & prompt hash computation
        if not request.operation_id:
            raise ProviderError("operation_id is required for all provider requests")
        if not request.messages:
            raise ProviderError("At least one chat message is required")

        prompt_hash = request.prompt_hash
        if not prompt_hash:
            prompt_content = "".join(f"{m.role}:{m.content}\n" for m in request.messages)
            prompt_hash = hashlib.sha256(prompt_content.encode("utf-8")).hexdigest()

        # 2. FAIL-CLOSED Authority Check: Bounded Operation Grant is strictly required
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

        grant_req = OperationGrantRequest(
            runId=request.run_id,
            epoch=epoch,
            leaseOwner=lease_owner,
            operationId=request.operation_id,
            operationType="PROVIDER_CALL",
            requestHash=prompt_hash,
            tokenReservation=request.max_tokens,
            costReservationUsd=0.0,
            wallTimeReservationSeconds=request.wall_time_reservation_seconds,
            sectionId=request.section_id,
            artifactId=request.artifact_id,
            parentOperationId=request.parent_operation_id,
        )

        try:
            grant_res = await self.checkpoint_client.grant_operation_async(grant_req)
            _ = grant_res.operationId
        except CheckpointApiError as api_err:
            if api_err.status_code == 422:
                # Budget cap exceeded on Run, Section, or Artifact
                raise BudgetExhaustedError(
                    f"Budget cap exceeded: {api_err.message}",
                    operation_id=request.operation_id,
                )
            elif api_err.status_code == 409:
                raise ProviderError(
                    f"Epoch fencing violation or request hash conflict: {api_err.message}",
                    is_retryable=False,
                    status_code=409,
                    operation_id=request.operation_id,
                )
            raise ProviderError(
                f"Checkpoint service error: {api_err.message}",
                is_retryable=False,
                status_code=api_err.status_code,
                operation_id=request.operation_id,
            )

        # 3. Provider Routing & Execution with Shared 3-Attempt Global Ceiling
        provider_order = self.registry.get_provider_order(preferred=request.preferred_provider)
        if not provider_order:
            raise ProviderUnavailableError(
                "No registered LLM providers available",
                operation_id=request.operation_id,
            )

        last_error: Optional[Exception] = None
        total_attempts = 0
        max_operation_attempts = self.retry_policy.max_attempts  # Strictly 3 attempts per operation total
        provider_index = 0

        while total_attempts < max_operation_attempts:
            if time.time() >= deadline:
                last_error = DeadlineExceededError(
                    f"Overall deadline of {request.timeout_seconds:.1f}s exceeded for operation '{request.operation_id}'",
                    operation_id=request.operation_id,
                )
                break

            if provider_index >= len(provider_order):
                provider_index = 0

            provider_name = provider_order[provider_index]
            provider = self.registry.get_provider(provider_name)
            if provider is None:
                provider_index += 1
                continue

            key_info = await self.registry.get_next_key(provider_name)
            if key_info is None:
                logger.warning("All %s keys exhausted/in cooldown; rotating to fallback provider", provider_name.upper())
                provider_index += 1
                if provider_index >= len(provider_order):
                    break
                continue

            api_key, key_index = key_info
            semaphore = self.registry.get_semaphore(provider_name)
            rate_limiter = self.registry.get_rate_limiter(provider_name)

            total_attempts += 1

            try:
                await rate_limiter.acquire()
                async with semaphore:
                    resp = await provider.call(request, api_key, deadline)

                resp.attempts_count = total_attempts

                # 4. Usage reconciliation: ensure usage is not silently zero and persist reconciliation
                if resp.usage.total_tokens == 0:
                    est = sum(provider.estimate_tokens(m.content) for m in request.messages) + provider.estimate_tokens(resp.raw_text)
                    resp.usage.total_tokens = max(1, est)
                    resp.usage.accounting_type = UsageAccountingType.ESTIMATED

                reconcile_req = OperationReconcileRequest(
                    runId=request.run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=request.operation_id,
                    tokensUsed=resp.usage.total_tokens,
                    wallTimeUsedSeconds=resp.latency_seconds,
                    costUsedUsd=resp.usage.estimated_cost_usd,
                    accountingType=resp.usage.accounting_type.value,
                )
                try:
                    await self.checkpoint_client.reconcile_operation_async(reconcile_req)
                except Exception as rec_err:
                    logger.error("Failed to reconcile operation '%s': %s", request.operation_id, redact_secrets(str(rec_err)))
                    raise ProviderError(
                        f"Failed to persist durable operation reconciliation: {rec_err}",
                        is_retryable=False,
                        operation_id=request.operation_id,
                    )
                self.last_response = resp
                return resp
            except UnauthorizedError as unauth_err:
                last_error = unauth_err
                # 401/403 Invalid API key: fail closed immediately; do NOT retry or rotate
                logger.error("Provider %s authentication failed (HTTP 401/403): %s", provider_name, redact_secrets(str(unauth_err)))
                raise

            except RateLimitedError as rle:
                last_error = rle
                cooldown = rle.retry_after_seconds or 65.0
                await self.registry.mark_key_exhausted(
                    provider_name,
                    key_index,
                    cooldown_seconds=cooldown,
                    reason=str(rle),
                )
                if total_attempts >= max_operation_attempts:
                    break

                delay = self.retry_policy.compute_delay(total_attempts - 1, retry_after=rle.retry_after_seconds)
                if time.time() + delay > deadline:
                    last_error = DeadlineExceededError(
                        f"Retry-After / backoff delay ({delay:.1f}s) would exceed remaining deadline for operation '{request.operation_id}'",
                        operation_id=request.operation_id,
                    )
                    break

                logger.info(
                    "Rate limited by %s; waiting %.2fs before attempt %d/%d",
                    provider_name,
                    delay,
                    total_attempts + 1,
                    max_operation_attempts,
                )
                try:
                    await asyncio.sleep(delay)
                except asyncio.CancelledError:
                    raise CancelledError(
                        f"Operation '{request.operation_id}' was cancelled during backoff",
                        operation_id=request.operation_id,
                    )

                provider_index = (provider_index + 1) % len(provider_order)

            except (ProviderTimeoutError, ProviderUnavailableError) as trans_err:
                last_error = trans_err
                if total_attempts >= max_operation_attempts:
                    break

                delay = self.retry_policy.compute_delay(total_attempts - 1)
                if time.time() + delay > deadline:
                    last_error = DeadlineExceededError(
                        f"Backoff delay ({delay:.1f}s) would exceed remaining deadline for operation '{request.operation_id}'",
                        operation_id=request.operation_id,
                    )
                    break

                logger.info(
                    "Transient error from %s: %s; waiting %.2fs before attempt %d/%d",
                    provider_name,
                    redact_secrets(str(trans_err)),
                    delay,
                    total_attempts + 1,
                    max_operation_attempts,
                )
                try:
                    await asyncio.sleep(delay)
                except asyncio.CancelledError:
                    raise CancelledError(
                        f"Operation '{request.operation_id}' was cancelled during backoff",
                        operation_id=request.operation_id,
                    )

                provider_index = (provider_index + 1) % len(provider_order)

            except (CancelledError, asyncio.CancelledError):
                raise
            except Exception as exc:
                last_error = exc
                logger.error("Non-retryable provider error from %s: %s", provider_name, redact_secrets(str(exc)))
                break

        # 5. All attempts failed or timed out: Record UNKNOWN_OUTCOME per ADR-004
        try:
            err_msg = str(last_error) if last_error else "All providers exhausted or deadline exceeded"
            await self.checkpoint_client.record_unknown_outcome_async(
                UnknownOutcomeRequest(
                    runId=request.run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=request.operation_id,
                    errorMessage=err_msg[:500],
                )
            )
            logger.info(
                "Recorded UNKNOWN_OUTCOME for operation '%s'; token reservation preserved",
                request.operation_id,
            )
        except Exception as record_err:
            logger.error("Failed to record UNKNOWN_OUTCOME: %s", redact_secrets(str(record_err)))

        if time.time() >= deadline:
            raise DeadlineExceededError(
                f"Overall deadline of {request.timeout_seconds:.1f}s exceeded for operation '{request.operation_id}'",
                operation_id=request.operation_id,
            )

        if isinstance(last_error, ProviderError):
            raise last_error

        raise ProviderUnavailableError(
            f"All {max_operation_attempts} attempts exhausted for operation '{request.operation_id}'. Last error: {last_error}",
            operation_id=request.operation_id,
        )


provider_gateway = ProviderGateway()
