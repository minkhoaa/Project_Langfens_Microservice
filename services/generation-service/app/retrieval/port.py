"""Canonical Knowledge Retrieval Port and Contracts (RG06-S02).

Invariants:
- All retrieval hits provide citations, content hashes, and relevance scores.
- Scope bounds tenant isolation and source licensing.
- Absent evidence yields explicit safe fallback, never hallucinated rules.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import List, Optional
from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import GrammarRulePack


class RetrievalScope(CanonicalBaseModel):
    """Scope constraint defining tenant, authorized sources, and relevance bounds."""

    tenant_id: str = Field(..., min_length=1)
    allowed_source_ids: Optional[List[str]] = None
    allowed_licenses: Optional[List[str]] = None
    min_relevance_threshold: float = Field(default=0.0, ge=0.0, le=1.0)


class KnowledgeHit(CanonicalBaseModel):
    """A single retrieved knowledge unit with provenance and relevance."""

    rule_pack: GrammarRulePack
    relevance_score: float = Field(..., ge=0.0, le=1.0)
    citation: str = Field(..., min_length=1)
    content_hash: str = Field(..., pattern=r"^[0-9a-f]{64}$")


class RetrievalResult(CanonicalBaseModel):
    """Result of a knowledge retrieval search operation."""

    query: str
    hits: List[KnowledgeHit] = Field(default_factory=list)
    total_hits: int = Field(default=0, ge=0)
    no_evidence_fallback: bool = False
    error: Optional[str] = None


class KnowledgeRetrievalPort(ABC):
    """Abstract Port defining knowledge and rule pack retrieval capabilities."""

    @abstractmethod
    async def search(self, query: str, scope: RetrievalScope) -> RetrievalResult:
        """Searches for grammar rule packs matching query within authorized scope."""
        raise NotImplementedError

    @abstractmethod
    async def get_by_id(self, rule_pack_id: str, scope: RetrievalScope) -> Optional[GrammarRulePack]:
        """Retrieves a specific grammar rule pack by ID if authorized."""
        raise NotImplementedError
