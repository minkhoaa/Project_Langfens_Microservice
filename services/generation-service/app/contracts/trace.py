"""Canonical 4-Role Agent Trace and Usage Accounting Contracts (RG02-S05).

Invariants:
- 4 logical agent roles: COORDINATOR, GENERATOR, REVIEWER, VALIDATOR.
- Usage confidence: EXACT, ESTIMATED, UNKNOWN.
- Provider errors and unknown usage must not default to zero/cost-free.
"""

from __future__ import annotations

from enum import Enum
from typing import Optional
from pydantic import Field, model_validator
from typing_extensions import Self

from app.contracts.base import CanonicalBaseModel


class AgentRole(str, Enum):
    COORDINATOR = "COORDINATOR"
    GENERATOR = "GENERATOR"
    REVIEWER = "REVIEWER"
    VALIDATOR = "VALIDATOR"


class UsageConfidence(str, Enum):
    EXACT = "EXACT"
    ESTIMATED = "ESTIMATED"
    UNKNOWN = "UNKNOWN"


class UsageRecord(CanonicalBaseModel):
    """Canonical UsageRecord matching JSON_SCHEMAS.json.

    Invariants:
    - When usage_confidence is UNKNOWN, failure_usage_reason is required.
    - Negative calls or costs are strictly forbidden.
    - Provider failures must not be falsely treated as free (cost=0.0 with EXACT confidence).
    """

    run_id: str = Field(..., min_length=1, alias="run_id")
    llm_calls: int = Field(..., ge=0, alias="llm_calls")
    prompt_tokens: Optional[int] = Field(default=None, ge=0, alias="prompt_tokens")
    completion_tokens: Optional[int] = Field(default=None, ge=0, alias="completion_tokens")
    cost_usd: Optional[float] = Field(default=None, ge=0.0, alias="cost_usd")
    usage_confidence: UsageConfidence = Field(..., alias="usage_confidence")
    pricing_version: Optional[str] = Field(default=None, alias="pricing_version")
    failure_usage_reason: Optional[str] = Field(default=None, alias="failure_usage_reason")

    @model_validator(mode="after")
    def validate_unknown_reason(self) -> Self:
        if self.usage_confidence == UsageConfidence.UNKNOWN:
            if not self.failure_usage_reason:
                raise ValueError("failure_usage_reason is required when usage_confidence is UNKNOWN")
            if self.cost_usd is not None:
                raise ValueError("cost_usd must be None when usage_confidence is UNKNOWN; unknown usage cannot default to 0/cost-free")
            if self.prompt_tokens is not None or self.completion_tokens is not None:
                raise ValueError("prompt_tokens and completion_tokens must be None when usage_confidence is UNKNOWN")
        return self


class AgentTraceEvent(CanonicalBaseModel):
    """Canonical 4-role AgentTraceEvent matching JSON_SCHEMAS.json."""

    trace_id: str = Field(..., min_length=1, alias="trace_id")
    run_id: str = Field(..., min_length=1, alias="run_id")
    agent_role: AgentRole = Field(..., alias="agent_role")
    capability_name: str = Field(..., min_length=1, alias="capability_name")
    input_sha256: str = Field(..., pattern=r"^[0-9a-f]{64}$", alias="input_sha256")
    output_sha256: Optional[str] = Field(default=None, alias="output_sha256")
    started_at: str = Field(..., alias="started_at")
    ended_at: Optional[str] = Field(default=None, alias="ended_at")
    event_status: str = Field(..., min_length=1, alias="event_status")
