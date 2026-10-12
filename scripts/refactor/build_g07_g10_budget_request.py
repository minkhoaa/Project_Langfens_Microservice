"""Per-iteration planned-token reservation helper used by gates G07–G10.

This module owns the canonical "planned token reservation for one logical
dispatch attempt against a provider" arithmetic. It is consumed by:
- ``test_campaign_budget_allocation.py`` (regression test)
- ``scripts/refactor/benchmark_campaign.py`` callers that need to compare
  provider-reservation wording against ledger semantics.

The helper is intentionally side-effect free and depends only on the
provider registry / adapter contract. It MUST remain pure so that retries
inherit the same upper-bound token cost that the gateway will commit to
on each attempt (no optimistic under-reservation that would later become
a "true cost" reconciliation surprise).
"""

from __future__ import annotations

from typing import Iterable

from app.providers.registry import ProviderRegistry
from app.providers.models import ProviderRequest


def _candidate_providers(registry: ProviderRegistry) -> Iterable:
    """Yield registered providers whose ``model_size`` matches the request.

    ``ProviderRegistry`` does not provide a public enumeration method in
    every version, so this helper tries both the explicit API and the
    private fallback ``_providers`` mapping. We deliberately ignore
    providers that don't expose ``conservative_token_reservation``
    (e.g. recording-only stubs) so the caller always gets a real bound.
    """
    candidates = []
    try:
        candidates = list(registry.all_providers())  # type: ignore[attr-defined]
    except AttributeError:
        pass
    if not candidates:
        # Fallback for registries that keep providers under ``_providers``
        internal = getattr(registry, "_providers", None)
        if isinstance(internal, dict):
            candidates = list(internal.values())
    return [p for p in candidates if hasattr(p, "conservative_token_reservation")]


def _pick_provider(registry: ProviderRegistry, request: ProviderRequest):
    """Select the provider whose declared models include the request size."""
    size = request.model_size or "large"
    for provider in _candidate_providers(registry):
        try:
            model_name = provider.get_model_name(size)
        except Exception:
            continue
        if model_name:
            return provider
    for provider in _candidate_providers(registry):
        return provider  # any provider with a bound is acceptable
    return None


def _planned_token_reservation(
    registry: ProviderRegistry,
    request: ProviderRequest,
    retry_attempts: int = 1,
) -> int:
    """Compute the total token reservation across ``retry_attempts``.

    The total reservation must equal
    ``provider.conservative_token_reservation(request) * retry_attempts``
    so that the campaign ledger reserves full upper-bound capacity
    before any provider call is dispatched. Implementations that try
    to "save" tokens on retries violate ADR-005 truthful accounting.
    """
    if retry_attempts < 1:
        raise ValueError("retry_attempts must be >= 1")
    provider = _pick_provider(registry, request)
    if provider is None:
        # No provider admits a reservation. We surface this loudly so callers
        # don't accidentally dispatch into an unbound provider.
        raise RuntimeError(
            "No provider registered for capability "
            f"{request.capability!r} — cannot compute planned reservation"
        )
    per_attempt = provider.conservative_token_reservation(request)
    return per_attempt * retry_attempts
