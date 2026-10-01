"""Canonical Evidence Graph Contracts for Langfens Loop Engine V2."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import Field

from .base import CanonicalBaseModel


class EntailmentLabel(str, Enum):
    ENTAILS = "ENTAILS"
    CONTRADICTS = "CONTRADICTS"
    NEUTRAL = "NEUTRAL"
    UNVERIFIABLE = "UNVERIFIABLE"


class Qualifier(str, Enum):
    DEFINITE = "DEFINITE"
    PROBABLE = "PROBABLE"
    POSSIBLE = "POSSIBLE"
    HYPOTHETICAL = "HYPOTHETICAL"
    UNSUPPORTED = "UNSUPPORTED"


class SourceOffset(CanonicalBaseModel):
    """Character offsets within a source document."""

    start_char: int = Field(..., ge=0, alias="startChar")
    end_char: int = Field(..., ge=0, alias="endChar")
    source_id: str = Field(..., alias="sourceId")


class VerifiedClaim(CanonicalBaseModel):
    """Fact claim verified against source texts with exact provenance."""

    claim_id: str = Field(..., alias="claimId")
    text: str
    source_id: str = Field(..., alias="sourceId")
    offsets: Optional[SourceOffset] = None
    confidence: float = Field(default=1.0, ge=0.0, le=1.0)
    entailment: EntailmentLabel = Field(default=EntailmentLabel.ENTAILS)
    qualifier: Qualifier = Field(default=Qualifier.DEFINITE)
    keywords: List[str] = Field(default_factory=list)


class AbsenceAssessment(CanonicalBaseModel):
    """Semantics for NOT GIVEN items: proves absence rather than forcing fake positive quote."""

    assessment_id: str = Field(..., alias="assessmentId")
    claim_or_topic: str = Field(..., alias="claimOrTopic")
    absence_reason: str = Field(..., alias="absenceReason")
    topical_context_span: Optional[str] = Field(default=None, alias="topicalContextSpan")
    absence_confirmed: bool = Field(default=True, alias="absenceConfirmed")


class TopicalContextSpan(CanonicalBaseModel):
    """Adjacent topical context in text without asserting direct proof."""

    span_id: str = Field(..., alias="spanId")
    section_id: int = Field(..., alias="sectionId")
    start_char: int = Field(..., ge=0, alias="startChar")
    end_char: int = Field(..., ge=0, alias="endChar")
    snippet: str


class EvidenceGraph(CanonicalBaseModel):
    """Graph of grounded factual claims and absence assessments."""

    graph_id: str = Field(..., alias="graphId")
    run_id: str = Field(..., alias="runId")
    source_pack_id: Optional[str] = Field(default=None, alias="sourcePackId")
    version: str = Field(default="v1.0.0")
    content_hash: Optional[str] = Field(default=None, alias="contentHash")
    status: str = Field(default="ACCEPTED")
    section_id: Optional[int] = Field(default=None, alias="sectionId")
    claims: List[VerifiedClaim] = Field(default_factory=list)
    absence_assessments: List[AbsenceAssessment] = Field(
        default_factory=list,
        alias="absenceAssessments",
    )
    verified_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        alias="verifiedAt",
    )
