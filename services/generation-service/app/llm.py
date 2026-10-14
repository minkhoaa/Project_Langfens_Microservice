"""Compatibility wrapper for legacy callers in Generation Service.

Maintains backward-compatibility for callers expecting llm_generate() or LLMService
while delegating all routing, rate-limiting, and retries to ProviderGateway.
Status: MIGRATED_TO_V2 (Closed Phase 15).
"""
from __future__ import annotations

import datetime
import json
import logging
import os
import re
from pathlib import Path
from typing import Any, Callable, Coroutine, Dict, List, Optional
from uuid import UUID, uuid4

from app.config import settings
from app.persistence.client import CheckpointClient
from app.providers.base import redact_secrets
from app.providers.gateway import ProviderGateway, provider_gateway
from app.providers.models import (
    Capability,
    ChatMessage,
    ProviderRequest,
    ProviderResponse,
)
from app.providers.parser import clean_reasoning_tags, parse_defensive_json

logger = logging.getLogger(__name__)


def _clean_text_content(text: str) -> str:
    return clean_reasoning_tags(text)


def _extract_json(text: str) -> Any:
    return parse_defensive_json(text, allow_repair=True)


def format_prompt(template: str, variables: Dict[str, Any]) -> str:
    """Safe variable replacement that preserves literal JSON braces in prompts."""
    result = template
    for key, val in variables.items():
        result = result.replace(f"{{{key}}}", str(val))
    return result


class LLMService:
    """Compatibility facade delegating to the unified ProviderGateway."""

    def __init__(self, gateway: Optional[ProviderGateway] = None) -> None:
        self._gateway = gateway or provider_gateway
        self._checkpoint_client: Optional[CheckpointClient] = None
        self._init_checkpoint_client()

    def _init_checkpoint_client(self) -> None:
        try:
            self._checkpoint_client = CheckpointClient()
            if self._gateway.checkpoint_client is None:
                self._gateway.checkpoint_client = self._checkpoint_client
        except Exception as exc:
            logger.debug("CheckpointClient not initialized in LLMService: %s", exc)

    async def generate(
        self,
        prompt_template: str,
        variables: Dict[str, Any],
        model_size: str = "large",
        provider: Optional[str] = None,
        temperature: float = 0.3,
        max_tokens: int = 4096,
        expect_json: bool = False,
        stream_callback: Optional[Callable[[str, str], Any]] = None,
        operation_id: Optional[str] = None,
        run_id: Optional[str] = None,
        epoch: int = 1,
        lease_owner: Optional[UUID] = None,
        section_id: Optional[str] = None,
        artifact_id: Optional[str] = None,
        target_model: Optional[Any] = None,
        response_schema: Optional[Dict[str, Any]] = None,
        **kwargs: Any,
    ) -> Any:
        formatted_prompt = format_prompt(prompt_template, variables)
        op_id = operation_id or f"op_{uuid4().hex[:16]}"

        if not run_id:
            raise ProviderError("run_id is required: every provider request must obtain an authenticated durable grant before dispatch")
        if lease_owner is None:
            raise ProviderError("lease_owner is required: every provider request must obtain an authenticated durable grant before dispatch")
        if not section_id or not artifact_id:
            raise ProviderError("section_id and artifact_id are required for hierarchical budget tracking")

        if self._checkpoint_client is None:
            self._init_checkpoint_client()

        req = ProviderRequest(
            capability=Capability.GENERATE_JSON if expect_json else Capability.GENERATE_TEXT,
            messages=[ChatMessage(role="user", content=formatted_prompt)],
            operation_id=op_id,
            run_id=run_id,
            section_id=section_id,
            artifact_id=artifact_id,
            parent_operation_id=kwargs.get("parent_operation_id"),
            model_size=model_size,
            preferred_provider=provider,
            temperature=temperature,
            max_tokens=max_tokens,
            timeout_seconds=float(kwargs.get("timeout_seconds", 60.0)),
            target_model=target_model,
            response_schema=response_schema,
            allow_repair=True,
            stream_callback=stream_callback,
        )

        resp = await self._gateway.execute(
            request=req,
            epoch=epoch,
            lease_owner=lease_owner,
        )

        if expect_json:
            return resp.parsed_payload
        return {"text": resp.raw_text}


_llm_service = LLMService()


async def llm_generate(**kwargs: Any) -> Any:
    """Entry point for legacy pipeline callers."""
    return await _llm_service.generate(**kwargs)
