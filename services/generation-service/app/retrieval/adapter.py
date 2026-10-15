"""Adapters implementing KnowledgeRetrievalPort for RG06-S02."""

from __future__ import annotations

import hashlib
import os
import re
from typing import Any, Dict, List, Optional, Tuple
import httpx

from app.contracts.research import GrammarRulePack
from app.contracts.solver import scan_text_for_security_leaks, SecurityLeakageError
from app.retrieval.port import (
    KnowledgeHit,
    KnowledgeRetrievalPort,
    RetrievalResult,
    RetrievalScope,
)

INJECTION_PATTERNS = [
    re.compile(r"ignore\s+(?:all\s+)?previous\s+instructions", re.IGNORECASE),
    re.compile(r"system\s*:\s*output", re.IGNORECASE),
    re.compile(r"bypass\s+(?:filter|security|guard)", re.IGNORECASE),
    re.compile(r"confidential\s+keys", re.IGNORECASE),
]

STOPWORDS = {
    "rule", "rules", "grammar", "exercise", "pack", "english", "ielts",
    "the", "a", "an", "in", "on", "of", "and", "or", "for", "to", "is", "are",
}


def detect_prompt_injection(text: str) -> bool:
    """Scans text for prompt injection keywords or system instruction overrides."""
    if not text:
        return False
    for pat in INJECTION_PATTERNS:
        if pat.search(text):
            return True
    return False


def compute_rule_pack_hash(rule_pack: GrammarRulePack) -> str:
    """Computes a deterministic SHA-256 digest of rule pack content."""
    payload = "|".join([
        rule_pack.rule_pack_id,
        rule_pack.source.source_id,
        rule_pack.source.source_sha256,
        rule_pack.topic,
        rule_pack.level,
        ",".join(sorted(rule_pack.rule_ids)),
        ",".join(rule_pack.applicability),
        ",".join(rule_pack.exceptions),
        ",".join(rule_pack.examples),
    ])
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


class InMemoryKnowledgeRetrievalAdapter(KnowledgeRetrievalPort):
    """In-memory reference adapter providing safe, isolated knowledge retrieval."""

    def __init__(self):
        # Maps rule_pack_id -> (rule_pack, tenant_id)
        self._store: Dict[str, Tuple[GrammarRulePack, str]] = {}

    def register_rule_pack(self, rule_pack: GrammarRulePack, tenant_id: str) -> None:
        """Registers a rule pack bound to a specific tenant."""
        self._store[rule_pack.rule_pack_id] = (rule_pack, tenant_id)

    async def search(self, query: str, scope: RetrievalScope) -> RetrievalResult:
        """Executes a scoped, injection-safe search over registered rule packs."""
        cleaned_query = (query or "").strip()

        # 1. Empty / Whitespace-only / Punctuation-only -> Safe no-evidence fallback
        words = re.findall(r"\w+", cleaned_query)
        if not words:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error=None,
            )

        # 2. Check for Prompt Injection / Security Leaks
        try:
            scan_text_for_security_leaks(cleaned_query)
        except SecurityLeakageError:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error="SECURITY_PROMPT_INJECTION_DETECTED",
            )

        if detect_prompt_injection(cleaned_query):
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error="SECURITY_PROMPT_INJECTION_DETECTED",
            )

        # 3. Filter candidates by tenant scope and authorized sources
        query_tokens = set(w.lower() for w in words)
        content_tokens = query_tokens - STOPWORDS or query_tokens
        candidate_hits: List[KnowledgeHit] = []

        for rule_pack, tenant_id in self._store.values():
            # Cross-tenant boundary check
            if tenant_id != scope.tenant_id:
                continue

            # Source ID allowlist check
            if scope.allowed_source_ids and rule_pack.source.source_id not in scope.allowed_source_ids:
                continue

            # License allowlist check
            if scope.allowed_licenses and rule_pack.source.license not in scope.allowed_licenses:
                continue

            # Compute text overlap relevance
            searchable_text = " ".join([
                rule_pack.topic,
                " ".join(rule_pack.rule_ids),
                " ".join(rule_pack.applicability),
                " ".join(rule_pack.examples),
            ]).lower()
            doc_tokens = set(re.findall(r"\w+", searchable_text))

            content_doc_tokens = doc_tokens - STOPWORDS or doc_tokens
            intersection = content_tokens.intersection(content_doc_tokens)
            if not intersection:
                continue

            # Jaccard-like term overlap score
            relevance = len(intersection) / len(content_tokens)
            if relevance < scope.min_relevance_threshold:
                continue

            candidate_hits.append(
                KnowledgeHit(
                    rule_pack=rule_pack,
                    relevance_score=min(1.0, float(relevance)),
                    citation=rule_pack.source.provenance_uri,
                    content_hash=compute_rule_pack_hash(rule_pack),
                )
            )

        # Sort hits by relevance descending
        candidate_hits.sort(key=lambda h: h.relevance_score, reverse=True)

        if not candidate_hits:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error=None,
            )

        return RetrievalResult(
            query=cleaned_query,
            hits=candidate_hits,
            total_hits=len(candidate_hits),
            no_evidence_fallback=False,
            error=None,
        )

    async def get_by_id(self, rule_pack_id: str, scope: RetrievalScope) -> Optional[GrammarRulePack]:
        """Fetches a rule pack by ID, strictly enforcing tenant boundary."""
        entry = self._store.get(rule_pack_id)
        if not entry:
            return None
        rule_pack, tenant_id = entry
        if tenant_id != scope.tenant_id:
            return None
        return rule_pack


class HttpKnowledgeRetrievalAdapter(KnowledgeRetrievalPort):
    """Adapter over observed ai-service /v1/grammar/search vector endpoint.

    Invariants:
    - Queries upstream ai-service grammar vector collection.
    - Transparently handles upstream reality: ai-service lacks tenant authentication and
      Qdrant points lack structured citations and content hashes.
    - Forbids fabricating missing citations, content hashes, or tenant scopes.
    """

    def __init__(self, base_url: Optional[str] = None, client: Optional[httpx.AsyncClient] = None):
        resolved_url = (
            base_url
            or os.environ.get("services__ai-service__http__0")
            or os.environ.get("AI_SERVICE_URL")
            or os.environ.get("AI_SERVICE_ENDPOINT")
        )
        self.base_url = resolved_url.rstrip("/") if resolved_url else None
        self._client = client

    async def search(self, query: str, scope: RetrievalScope) -> RetrievalResult:
        cleaned_query = (query or "").strip()
        words = re.findall(r"\w+", cleaned_query)
        if not words:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error=None,
            )

        try:
            scan_text_for_security_leaks(cleaned_query)
        except SecurityLeakageError:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error="SECURITY_PROMPT_INJECTION_DETECTED",
            )

        if detect_prompt_injection(cleaned_query):
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error="SECURITY_PROMPT_INJECTION_DETECTED",
            )

        if not self.base_url:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error="AI_SERVICE_URL_NOT_CONFIGURED",
            )

        # Call upstream ai-service /v1/grammar/search
        client = self._client or httpx.AsyncClient(timeout=10.0)
        try:
            resp = await client.post(
                f"{self.base_url}/v1/grammar/search",
                json={"query": cleaned_query, "top_k": 5, "filters": {}},
            )
            if resp.status_code != 200:
                return RetrievalResult(
                    query=cleaned_query,
                    hits=[],
                    total_hits=0,
                    no_evidence_fallback=True,
                    error=f"UPSTREAM_HTTP_ERROR_{resp.status_code}",
                )
            data = resp.json()
            raw_results = data.get("results", [])
        except Exception as e:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error=f"UPSTREAM_COMMUNICATION_ERROR: {e}",
            )
        finally:
            if self._client is None:
                await client.aclose()

        # Parse results: upstream SearchResult has {id, text, score, metadata}
        # Upstream vector DB currently lacks tenant auth, citation URIs, and source content hashes.
        hits: List[KnowledgeHit] = []
        for r in raw_results:
            meta = r.get("metadata", {})
            rule_pack_data = meta.get("rule_pack")
            if not rule_pack_data or not isinstance(rule_pack_data, dict):
                continue

            point_tenant = meta.get("tenant_id")
            # Fail closed: missing tenant_id or mismatched tenant is strictly unauthorized
            if not point_tenant or point_tenant != scope.tenant_id:
                continue
            try:
                rule_pack = GrammarRulePack(**rule_pack_data)
                hits.append(
                    KnowledgeHit(
                        rule_pack=rule_pack,
                        relevance_score=float(r.get("score", 0.0)),
                        citation=rule_pack.source.provenance_uri,
                        content_hash=compute_rule_pack_hash(rule_pack),
                    )
                )
            except Exception:
                continue

        if not hits:
            return RetrievalResult(
                query=cleaned_query,
                hits=[],
                total_hits=0,
                no_evidence_fallback=True,
                error="UPSTREAM_LACKS_STRUCTURED_CITATION_AND_TENANT_PROVENANCE" if raw_results else None,
            )

        return RetrievalResult(
            query=cleaned_query,
            hits=hits,
            total_hits=len(hits),
            no_evidence_fallback=False,
            error=None,
        )

    async def get_by_id(self, rule_pack_id: str, scope: RetrievalScope) -> Optional[GrammarRulePack]:
        return None
