"""Canonical Source Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import Field

from .base import CanonicalBaseModel


class IngestionStatus(str, Enum):
    SUCCESS = "SUCCESS"
    REJECTED = "REJECTED"
    INSUFFICIENT_LENGTH = "INSUFFICIENT_LENGTH"
    FETCH_ERROR = "FETCH_ERROR"
    LICENSE_INELIGIBLE = "LICENSE_INELIGIBLE"


class SourceMetadata(CanonicalBaseModel):
    """Metadata for an ingested scientific paper or open-access source."""

    pmid: Optional[str] = None
    pmcid: Optional[str] = None
    doi: Optional[str] = None
    title: str
    authors: List[str] = Field(default_factory=list)
    journal: Optional[str] = None
    pub_date: Optional[str] = Field(default=None, alias="pubDate")
    source_url: str = Field(..., alias="sourceUrl")
    license_type: str = Field(default="Open Access", alias="licenseType")
    license_cleared: bool = Field(default=True, alias="licenseCleared")


class SourceDocument(CanonicalBaseModel):
    """Cleaned extracted body of the source document."""

    text: str
    word_count: int = Field(..., ge=0, alias="wordCount")
    paragraphs: List[str] = Field(default_factory=list)
    headings: List[str] = Field(default_factory=list)
    extracted_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="extractedAt",
    )


class SourceItem(CanonicalBaseModel):
    """Single ingested source item with metadata and cleaned content."""

    source_id: str = Field(..., alias="sourceId")
    metadata: SourceMetadata
    document: SourceDocument


class SourcePack(CanonicalBaseModel):
    """Normalized pack of sources providing grounded facts for a section or paper."""

    pack_id: str = Field(..., alias="packId")
    run_id: str = Field(..., alias="runId")
    section_id: Optional[int] = Field(default=None, alias="sectionId")
    revision: int = Field(default=1, ge=1)
    sources: List[SourceItem] = Field(default_factory=list)
    combined_word_count: int = Field(..., ge=0, alias="combinedWordCount")
    suitability_score: float = Field(default=1.0, ge=0.0, le=1.0, alias="suitabilityScore")
    license_cleared: bool = Field(default=True, alias="licenseCleared")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="createdAt",
    )


class IngestionResult(CanonicalBaseModel):
    """Result of an ingestion operation."""

    status: IngestionStatus
    source_pack: Optional[SourcePack] = Field(default=None, alias="sourcePack")
    error_message: Optional[str] = Field(default=None, alias="errorMessage")
