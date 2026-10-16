"""Unit tests for RG09-S04: Freeze providers, prompts, resources and safety.

Parent: generation_baseline/prompts/sprints/prompt-sprint-09-04.md
Objective: Model revisions if available, sampling params, prompt hashes, budgets/timeouts and fallback policies versioned.
Decisive acceptance condition: Same task/model family and declared limits; unknown provider quotas noted; UNLIMITED cap does not imply no timeouts or free tokens.
"""

from __future__ import annotations

import pytest

from app.experiment.freeze_manifest import (
    FrozenPromptSpec,
    OperationTimeoutError,
    ProviderFallbackForbiddenError,
    ProviderFreezeManager,
    ResourceBudgetExceededError,
    ResourceSafetyPolicy,
    SamplingParameters,
    SamplingParameterTamperedError,
)


def test_pos_rg09_s04_frozen_providers_and_prompts():
    """POS-RG09-S04: Model minimax/MiniMax-Text-01, prompt hashes, and sampling parameters pinned."""
    manager = ProviderFreezeManager(
        foundation_model_id="minimax/MiniMax-Text-01",
        model_revision="UNKNOWN",
    )

    # 1. Pinned model and revision
    assert manager.foundation_model_id == "minimax/MiniMax-Text-01"
    assert manager.model_revision == "UNKNOWN"

    # 2. Frozen prompts have explicit SHA256 hashes for all 3 arms
    prompt_a = manager.get_prompt_spec("A")
    prompt_b = manager.get_prompt_spec("B")
    prompt_c = manager.get_prompt_spec("C")

    assert len(prompt_a.template_sha256) == 64
    assert len(prompt_b.template_sha256) == 64
    assert len(prompt_c.template_sha256) == 64
    assert prompt_a.template_sha256 != prompt_b.template_sha256 != prompt_c.template_sha256

    # 3. Pinned sampling parameters
    assert manager.sampling_params.temperature == 0.2
    assert manager.sampling_params.top_p == 0.95
    assert manager.sampling_params.seed == 2026

    # 4. Valid model succeeds validation
    manager.validate_provider_and_model("minimax/MiniMax-Text-01")

    # 5. Reported token telemetry is recorded accurately
    usage = manager.record_usage(
        request_id="req-101",
        wall_time_ms=1250.0,
        tokens_prompt=1500,
        tokens_completion=500,
    )
    assert usage.tokens_total == 2000
    assert usage.quota_status == "REPORTED"
    assert usage.is_estimated is False


def test_neg_rg09_s04_unlimited_cap_reality_and_fallback_forbidden():
    """NEG-RG09-S04: UNLIMITED cap fails closed on timeout/tokens; provider fallback forbidden."""
    manager = ProviderFreezeManager(
        safety_policy=ResourceSafetyPolicy(
            max_wall_time_seconds=60,
            max_tokens_per_request=8000,
            is_unlimited_cap=True,  # Requesting UNLIMITED does NOT bypass hard limits!
        )
    )

    # 1. Timeout exceeds 60s -> OperationTimeoutError
    with pytest.raises(OperationTimeoutError) as exc_info:
        manager.enforce_resource_safety(
            elapsed_seconds=65.0,
            tokens_consumed=1000,
            unlimited_cap_requested=True,
        )
    assert "exceeded max safety timeout" in str(exc_info.value)

    # 2. Token consumption exceeds 8,000 -> ResourceBudgetExceededError
    with pytest.raises(ResourceBudgetExceededError) as exc_info:
        manager.enforce_resource_safety(
            elapsed_seconds=10.0,
            tokens_consumed=9500,
            unlimited_cap_requested=True,
        )
    assert "exceeded per-request limit" in str(exc_info.value)

    # 3. Provider fallback to a different model (e.g., smaller or fallback model) fails closed
    with pytest.raises(ProviderFallbackForbiddenError) as exc_info:
        manager.validate_provider_and_model("groq/llama-3.3-70b-versatile")
    assert "Provider fallback is strictly forbidden" in str(exc_info.value)


def test_edge_rg09_s04_tampered_sampling_and_unknown_quota():
    """EDGE-RG09-S04: Tampered sampling params rejected and missing usage noted as UNKNOWN."""
    manager = ProviderFreezeManager()

    # 1. Tampered temperature rejected
    tampered_temp = SamplingParameters(temperature=0.7, top_p=0.95, seed=2026)
    with pytest.raises(SamplingParameterTamperedError):
        manager.validate_sampling_parameters(tampered_temp)

    # 2. Tampered seed rejected
    tampered_seed = SamplingParameters(temperature=0.2, top_p=0.95, seed=9999)
    with pytest.raises(SamplingParameterTamperedError):
        manager.validate_sampling_parameters(tampered_seed)

    # 3. Missing tokens from provider recorded transparently as UNKNOWN, not coerced to 0
    usage_unknown = manager.record_usage(
        request_id="req-102",
        wall_time_ms=800.0,
        tokens_prompt=None,  # Missing provider telemetry
        tokens_completion=None,
    )
    assert usage_unknown.tokens_total is None
    assert usage_unknown.quota_status == "UNKNOWN"
    assert usage_unknown.is_estimated is True


def test_reg_rg09_s04_safety_policy_immutability():
    """REG-RG09-S04: Resource safety policy disallows provider fallback or model downgrade."""
    policy = ResourceSafetyPolicy()
    assert policy.allow_provider_fallback is False
    assert policy.allow_model_downgrade is False
