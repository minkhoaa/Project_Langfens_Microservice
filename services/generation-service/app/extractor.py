"""Backward-compatible living adapter for source extraction and ingestion in Langfens Loop Engine V2.

Delegates core capabilities to canonical modular components in `app.ingestion`:
- `app.ingestion.security`: SSRF protection, IP/DNS validation, connection pinning, resource caps
- `app.ingestion.license`: Europe PMC CC-BY/CC0 verification, universal source policy, word counts
- `app.ingestion.cleaner`: XML, HTML, Markdown, and text normalizers with version tracking
- `app.ingestion.chunker`: Stable spans with Unicode code-point alignment, chunking, and coverage mapping
- `app.ingestion.source_pack`: Canonical SourcePack generation and revision invalidation
- `app.ingestion.fetcher`: Network fetching and format dispatching

Status: LIVING_PUBLIC_ADAPTER_PRESERVED (Closed Phase 15).
"""

from __future__ import annotations

import re
import xml.etree.ElementTree as ET
from typing import Any, Awaitable, Callable, Optional

from app.ingestion.cleaner import (
    CleanerError,
    SemanticHTMLCleaner,
    clean_html,
    clean_markdown,
    clean_plain_text,
    clean_xml_full_text,
)
from app.ingestion.fetcher import (
    EUROPE_PMC,
    OPENALEX,
    PMCID_PATTERN as PMCID,
    WORD_PATTERN as WORD,
    ProgressCallback,
    SourceError,
    SourceNetworkError,
    _progress,
    detect_source_type,
    fetch_source,
    fetch_web_url,
    ingest_source,
    resolve_pmcid,
    search_sources,
    source_excerpt,
)
from app.ingestion.license import (
    EUROPE_PMC_CC_LICENSE_PATTERN as LICENSE,
    LicenseError,
    SourceLengthError,
)
from app.ingestion.security import is_safe_url as _is_safe_url

__all__ = [
    "OPENALEX",
    "EUROPE_PMC",
    "PMCID",
    "WORD",
    "LICENSE",
    "ProgressCallback",
    "SourceError",
    "SourceNetworkError",
    "SemanticHTMLCleaner",
    "clean_html",
    "clean_markdown",
    "clean_plain_text",
    "clean_xml_full_text",
    "detect_source_type",
    "fetch_source",
    "fetch_web_url",
    "ingest_source",
    "is_safe_url",
    "parse_full_text",
    "resolve_pmcid",
    "search_sources",
    "source_excerpt",
]


def _text(element: Optional[ET.Element]) -> str:
    """Extracts and normalizes whitespace from an ElementTree element."""
    return " ".join(" ".join(element.itertext()).split()) if element is not None else ""


def is_safe_url(url: str) -> bool:
    """Backward-compatible boolean check for safe URL targets."""
    safe, _ = _is_safe_url(url, resolve_dns=True)
    return safe


def parse_full_text(xml: bytes, pmcid: str) -> dict[str, Any]:
    """Backward-compatible parser for Europe PMC JATS XML full text."""
    try:
        return clean_xml_full_text(xml, pmcid)
    except (CleanerError, LicenseError, SourceLengthError) as exc:
        raise SourceError(str(exc)) from exc
