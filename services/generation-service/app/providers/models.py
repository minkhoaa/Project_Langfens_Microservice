from __future__ import annotations

import math
from enum import Enum
from typing import Any, Dict, List, Optional, Type
from pydantic import BaseModel, Field, ConfigDict, field_validator, model_validator

from app.config import settings
from app.contracts.base import CanonicalBaseModel

# Provider hard caps. Loop Engine V2 dispatch is strictly finite per attempt and per operation.
MAX_OPERATION_TIMEOUT_SECONDS = 180.0


class Capability(str, Enum):
    GENERATE_TEXT = "generate_text"
    GENERATE_JSON = "generate_json"
    EXTRACT_EVIDENCE = "extract_evidence"
    EVALUATE_ITEM = "evaluate_item"
    SOLVE_ITEM = "solve_item"
    PLAN_REPAIR = "plan_repair"


class FinishReason(str, Enum):
    STOP = "stop"
    LENGTH = "length"
    CONTENT_FILTER = "content_filter"
    ERROR = "error"
    UNKNOWN = "unknown"


class UsageAccountingType(str, Enum):
    REPORTED = "reported"
    ESTIMATED = "estimated"
    UNKNOWN = "unknown"


class UsageReport(CanonicalBaseModel):
    prompt_tokens: Optional[int] = None
    completion_tokens: Optional[int] = None
    total_tokens: int = 0
    reasoning_tokens: Optional[int] = None
    accounting_type: UsageAccountingType = UsageAccountingType.UNKNOWN
    estimated_cost_usd: float = 0.0


class ChatMessage(CanonicalBaseModel):
    role: str
    content: str


class ProviderRequest(CanonicalBaseModel):
    model_config = ConfigDict(extra="forbid", arbitrary_types_allowed=True)

    capability: Capability
    messages: List[ChatMessage]
    operation_id: str
    run_id: Optional[str] = None
    section_id: Optional[str] = None
    artifact_id: Optional[str] = None
    parent_operation_id: Optional[str] = None
    budget_reservation_id: Optional[str] = None
    model_size: str = "large"
    preferred_provider: Optional[str] = None
    pinned_provider: Optional[str] = None
    pinned_model: Optional[str] = Field(default=None, description="Operation-scoped explicit model override (e.g. MiniMax-M3)")
    deadline_unix_seconds: Optional[float] = None
    remaining_tokens: Optional[int] = None
    temperature: float = 0.3
    max_tokens: int = 4096
    timeout_seconds: float = 180.0
    wall_time_reservation_seconds: float = settings.loop_operation_wall_reservation_seconds
    model_config_version: str = "2.0.0"
    prompt_hash: str = ""
    target_model: Optional[Type[BaseModel]] = Field(default=None, exclude=True)
    response_schema: Optional[Dict[str, Any]] = None
    max_response_bytes: int = settings.loop_max_response_bytes
    allow_repair: bool = True
    allowed_providers: Optional[List[str]] = Field(default=None, description="Strict provider allowlist. If set, gateway will only ever dispatch to these providers.")
    allow_fallback: bool = Field(default=False, description="Whether fallback outside allowed providers is permitted.")
    stream_callback: Optional[Any] = Field(default=None, exclude=True)

    @field_validator("timeout_seconds")
    @classmethod
    def validate_timeout_seconds(cls, v: float) -> float:
        if v is None or not math.isfinite(v) or v <= 0 or v > MAX_OPERATION_TIMEOUT_SECONDS:
            raise ValueError(f"timeout_seconds must be finite, > 0, and <= {MAX_OPERATION_TIMEOUT_SECONDS}")
        return float(v)

    @field_validator("wall_time_reservation_seconds")
    @classmethod
    def validate_wall_time_reservation_seconds(cls, v: float) -> float:
        if v is None or not math.isfinite(v) or v <= 0:
            raise ValueError("wall_time_reservation_seconds must be finite and > 0")
        return float(v)

    @field_validator("allow_fallback")
    @classmethod
    def validate_allow_fallback(cls, v: bool) -> bool:
        if v is not False:
            raise ValueError("allow_fallback must be False in finite execution mode")
        return False

class ProviderResponse(CanonicalBaseModel):
    model_config = ConfigDict(frozen=False, extra="forbid")

    operation_id: str
    provider_name: str
    model_name: str
    raw_text: str
    parsed_payload: Optional[Any] = None
    finish_reason: FinishReason = FinishReason.STOP
    usage: UsageReport
    provider_request_id: Optional[str] = None
    latency_seconds: float = 0.0
    attempts_count: int = 1
