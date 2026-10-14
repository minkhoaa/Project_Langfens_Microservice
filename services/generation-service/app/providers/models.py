from __future__ import annotations

from enum import Enum
from typing import Any, Dict, List, Optional, Type
from pydantic import BaseModel, Field, ConfigDict

from app.config import settings
from app.contracts.base import CanonicalBaseModel


class Capability(str, Enum):
    GENERATE_TEXT = "generate_text"
    GENERATE_JSON = "generate_json"
    EXTRACT_EVIDENCE = "extract_evidence"
    EVALUATE_ITEM = "evaluate_item"
    SOLVE_ITEM = "solve_item"


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
    temperature: float = 0.3
    max_tokens: int = 4096
    timeout_seconds: float = 60.0
    wall_time_reservation_seconds: float = settings.loop_operation_wall_reservation_seconds
    model_config_version: str = "2.0.0"
    prompt_hash: str = ""
    target_model: Optional[Type[BaseModel]] = Field(default=None, exclude=True)
    response_schema: Optional[Dict[str, Any]] = None
    max_response_bytes: int = settings.loop_max_response_bytes
    allow_repair: bool = True
    is_unlimited: Optional[bool] = None
    stream_callback: Optional[Any] = Field(default=None, exclude=True)

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
