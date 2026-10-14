"""Canonical Base Model for Langfens Loop Engine V2 Contracts."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class CanonicalBaseModel(BaseModel):
    """Base model enforcing immutability, field alias population, and strict rejection of unknown fields."""

    model_config = ConfigDict(
        frozen=True,
        populate_by_name=True,
        extra="forbid",
    )
