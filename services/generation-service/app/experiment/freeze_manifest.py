"""Provider, prompt, resource budget, and safety freeze manager (RG09-S04).

Implements normative research obligations from:
- Frozen prompt versions, model families and budget tracking
- generation_baseline/contracts/JSON_SCHEMAS.json ($defs/ExperimentManifest)
- deploy/envs/loop-caps.env (Approved runtime caps, timeouts, and token ceilings)

Invariants:
1. Frozen models & revisions: Foundation model pinned to 'minimax/MiniMax-Text-01', revision pinned to UNKNOWN if not exposed by provider.
2. Prompt hashes: Explicit SHA256 hashes of system and task prompts for arms A, B, and C.
3. Strict fallback prohibition: Provider fallback or model substitution fails closed (ProviderFallbackForbiddenError).
4. UNLIMITED cap reality: Unlimited application caps do NOT imply infinite tokens or zero timeouts.
5. Unknown token usage: Provider quotas or missing usage are tracked transparently as UNKNOWN, never coerced to 0.
"""

from __future__ import annotations

import hashlib
import json
from typing import Any, Dict, List, Literal, Optional, Tuple

from pydantic import Field, model_validator

from app.contracts.base import CanonicalBaseModel
from app.experiment.paired import ProviderFallbackForbiddenError


class ResourceBudgetExceededError(RuntimeError):
    """Raised when an operation exceeds declared token or financial resource ceilings."""


class OperationTimeoutError(TimeoutError):
    """Raised when operation wall-clock duration exceeds strict frozen timeout limit."""


class SamplingParameterTamperedError(RuntimeError):
    """Raised when sampling parameters (temperature, top_p, seed) differ from pinned values."""


class SamplingParameters(CanonicalBaseModel):
    """Deterministic sampling parameters pinned for reproducibility."""

    temperature: float = Field(default=0.2, ge=0.0, le=2.0)
    top_p: float = Field(default=0.95, ge=0.0, le=1.0)
    max_tokens: int = Field(default=4000, ge=1)
    seed: int = 2026


class FrozenPromptSpec(CanonicalBaseModel):
    """Pinned prompt version and its cryptographic SHA256 template hash."""

    version_tag: str
    template_text: str
    template_sha256: str = ""

    @model_validator(mode="before")
    @classmethod
    def populate_template_hash(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if not data.get("template_sha256") and data.get("template_text"):
                text = data["template_text"]
                data["template_sha256"] = hashlib.sha256(text.encode("utf-8")).hexdigest()
        return data


class ResourceSafetyPolicy(CanonicalBaseModel):
    """Execution budgets, timeouts, and fallback restrictions."""

    max_wall_time_seconds: int = 60
    max_tokens_per_request: int = 8000
    max_total_campaign_tokens: int = 1200000
    allow_provider_fallback: Literal[False] = False
    allow_model_downgrade: Literal[False] = False
    is_unlimited_cap: bool = False  # UNLIMITED does not bypass hard safety ceilings!


class ProviderUsageRecord(CanonicalBaseModel):
    """Resource usage tracking with explicit transparency on unknown/estimated quantities."""

    request_id: str
    tokens_prompt: Optional[int] = None
    tokens_completion: Optional[int] = None
    tokens_total: Optional[int] = None
    is_estimated: bool = False
    quota_status: Literal["REPORTED", "ESTIMATED", "UNKNOWN"]
    wall_time_ms: float


class ProviderFreezeManager:
    """Manages frozen model configurations, prompt templates, and resource safety enforcement."""

    def __init__(
        self,
        foundation_model_id: str = "minimax/MiniMax-Text-01",
        model_revision: Optional[str] = "UNKNOWN",
        sampling_params: Optional[SamplingParameters] = None,
        safety_policy: Optional[ResourceSafetyPolicy] = None,
    ) -> None:
        self.foundation_model_id = foundation_model_id
        self.model_revision = model_revision
        self.sampling_params = sampling_params or SamplingParameters()
        self.safety_policy = safety_policy or ResourceSafetyPolicy()

        # Frozen prompts for Arms A, B, and C
        self._prompts: Dict[str, FrozenPromptSpec] = {
            "A": FrozenPromptSpec(
                version_tag="v2.1-baseline",
                template_text="System: You are an IELTS generation assistant. Generate passage and questions.",
            ),
            "B": FrozenPromptSpec(
                version_tag="v2.2-grounded",
                template_text="System: You are an IELTS examiner. Generate strictly grounded passage and questions.",
            ),
            "C": FrozenPromptSpec(
                version_tag="v3.0-adversarial",
                template_text="System: You are an IELTS author with adversarial critique and schema repair loop.",
            ),
        }

    def get_prompt_spec(self, arm: Literal["A", "B", "C"]) -> FrozenPromptSpec:
        """Retrieves the frozen prompt specification and hash for an experimental arm."""
        return self._prompts[arm]

    def validate_provider_and_model(self, requested_model_id: str) -> None:
        """Enforces that requested model strictly matches the immutable pinned model."""
        if requested_model_id != self.foundation_model_id:
            raise ProviderFallbackForbiddenError(
                f"Requested model '{requested_model_id}' does not match pinned model '{self.foundation_model_id}'. "
                "Provider fallback is strictly forbidden (fails closed)."
            )

    def validate_sampling_parameters(self, params: SamplingParameters) -> None:
        """Validates that execution does not tamper with pinned sampling parameters."""
        if (
            params.temperature != self.sampling_params.temperature
            or params.top_p != self.sampling_params.top_p
            or params.seed != self.sampling_params.seed
        ):
            raise SamplingParameterTamperedError(
                f"Sampling parameters tampered: got temp={params.temperature}, seed={params.seed}. "
                f"Expected temp={self.sampling_params.temperature}, seed={self.sampling_params.seed}."
            )

    def enforce_resource_safety(
        self,
        elapsed_seconds: float,
        tokens_consumed: Optional[int],
        unlimited_cap_requested: bool = False,
    ) -> None:
        """Enforces timeout and token budget ceilings, rejecting 'UNLIMITED' bypass assumptions."""
        # UNLIMITED application cap does NOT imply no timeouts or infinite tokens
        if elapsed_seconds > self.safety_policy.max_wall_time_seconds:
            raise OperationTimeoutError(
                f"Operation duration {elapsed_seconds:.2f}s exceeded max safety timeout "
                f"{self.safety_policy.max_wall_time_seconds}s (unlimited_cap={unlimited_cap_requested})"
            )

        if tokens_consumed is not None:
            if tokens_consumed > self.safety_policy.max_tokens_per_request:
                raise ResourceBudgetExceededError(
                    f"Token usage {tokens_consumed} exceeded per-request limit "
                    f"{self.safety_policy.max_tokens_per_request} (unlimited_cap={unlimited_cap_requested})"
                )

    def record_usage(
        self,
        request_id: str,
        wall_time_ms: float,
        tokens_prompt: Optional[int] = None,
        tokens_completion: Optional[int] = None,
    ) -> ProviderUsageRecord:
        """Records provider token telemetry, never coercing missing values to zero."""
        if tokens_prompt is not None and tokens_completion is not None:
            return ProviderUsageRecord(
                request_id=request_id,
                tokens_prompt=tokens_prompt,
                tokens_completion=tokens_completion,
                tokens_total=tokens_prompt + tokens_completion,
                is_estimated=False,
                quota_status="REPORTED",
                wall_time_ms=wall_time_ms,
            )
        else:
            # Missing usage is explicitly UNKNOWN, NOT coerced to 0!
            return ProviderUsageRecord(
                request_id=request_id,
                tokens_prompt=None,
                tokens_completion=None,
                tokens_total=None,
                is_estimated=True,
                quota_status="UNKNOWN",
                wall_time_ms=wall_time_ms,
            )
