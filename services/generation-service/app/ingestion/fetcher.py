"""Hardened Fetcher and Orchestrator for Source Ingestion in Langfens Loop Engine V2.

Features:
- Preserves Europe PMC and OpenAlex API lookups and metadata
- Safe Web URL fetching protected by connection-level SSRF checks and redirect revalidation
- Full enforcement of license provenance and length policies
- Multi-format ingestion dispatcher (PMC, URL, HTML, Markdown, Plain Text)
- Clean error hierarchies with backward-compatible SourceError and SourceNetworkError
"""

from __future__ import annotations

import asyncio
import hashlib
import os
import re
import urllib.parse
from typing import Any, Awaitable, Callable, Optional

import httpx

from app.config import settings
from app.ingestion.cleaner import (
    NORMALIZER_VERSION,
    clean_html,
    clean_markdown,
    clean_plain_text,
    clean_xml_full_text,
    CleanerError,
)
from app.ingestion.license import (
    count_words,
    evaluate_universal_license,
    validate_source_length,
    LicenseError,
    SourceLengthError,
)
from app.ingestion.security import (
    is_safe_url,
    validate_extracted_content_length,
    SafeAsyncClient,
    ResourceCapError,
    SecurityError,
    SSRFError,
)

OPENALEX = "https://api.openalex.org/works"
EUROPE_PMC = "https://www.ebi.ac.uk/europepmc/webservices/rest"
PMCID_PATTERN = re.compile(r"^PMC[0-9]+$", re.IGNORECASE)
WORD_PATTERN = re.compile(r"\b[\w'-]+\b")

ProgressCallback = Callable[[str, str], Awaitable[None]]


class SourceError(ValueError):
    """Base error for all ingestion failures."""
    pass


class SourceNetworkError(SourceError):
    """Network-related transport failures."""
    pass


async def _progress(
    callback: Optional[ProgressCallback],
    message: str,
    level: str = "Information",
) -> None:
    if callback is not None:
        await callback(level, message)


def source_excerpt(content: str, max_chars: int = 15_000) -> str:
    """Samples across an article while keeping LLM prompt within TPM limits."""
    if len(content) <= max_chars:
        return content
    paragraphs = [part.strip() for part in content.split("\n\n") if part.strip()]
    if not paragraphs:
        return content[:max_chars]
    count = min(24, len(paragraphs))
    indices = sorted({round(i * (len(paragraphs) - 1) / max(1, count - 1)) for i in range(count)})
    per_paragraph = max_chars // count - 2
    return "\n\n".join(paragraphs[i][:per_paragraph] for i in indices)


def detect_source_type(payload: str) -> str:
    """Infers source format from raw payload text."""
    s = payload.strip()
    if PMCID_PATTERN.fullmatch(s):
        return "pmc"
    if re.match(r"^https?://", s, re.IGNORECASE):
        return "url"
    if re.search(r"<(?:!DOCTYPE|html|head|body|article|main|div|p)\b", s, re.IGNORECASE):
        return "html"
    if re.search(r"^#{1,6}\s+|\[.+?\]\(.+?\)|```", s, re.MULTILINE):
        return "markdown"
    return "text"


async def fetch_source(
    pmcid: str,
    progress: Optional[ProgressCallback] = None,
) -> dict[str, Any]:
    """Fetches full-text XML from Europe PMC with license and attribution verification."""
    if not PMCID_PATTERN.fullmatch(pmcid):
        raise SourceError("Invalid PMCID")

    timeout = httpx.Timeout(60.0, connect=15.0)
    async with httpx.AsyncClient(timeout=timeout, follow_redirects=False) as client:
        response: Optional[httpx.Response] = None
        for attempt in range(3):
            try:
                await _progress(
                    progress,
                    f"Europe PMC full-text request started for {pmcid.upper()} (attempt {attempt + 1}/3).",
                )
                response = await client.get(f"{EUROPE_PMC}/{pmcid.upper()}/fullTextXML")
                if response.status_code == 404:
                    raise SourceError("Open full text is unavailable")
                if response.status_code in (429, 502, 503, 504) and attempt < 2:
                    await _progress(
                        progress,
                        f"Europe PMC returned HTTP {response.status_code}; retrying.",
                        "Warning",
                    )
                    await asyncio.sleep(2.0 * (attempt + 1))
                    continue
                response.raise_for_status()
                break
            except httpx.HTTPError as exc:
                if attempt < 2 and isinstance(exc, (httpx.TimeoutException, httpx.ConnectError)):
                    err_label = type(exc).__name__
                    await _progress(
                        progress,
                        f"Europe PMC request failed ({err_label}); retrying.",
                        "Warning",
                    )
                    await asyncio.sleep(2.0 * (attempt + 1))
                    continue
                raise SourceNetworkError(f"Europe PMC request failed: {exc}") from exc

    if response is None:
        raise SourceNetworkError("Europe PMC request failed to produce a response")

    await _progress(
        progress,
        f"Europe PMC returned HTTP {response.status_code}; validating XML, license and author metadata.",
    )

    try:
        result = clean_xml_full_text(response.content, pmcid)
    except (CleanerError, LicenseError, SourceLengthError) as exc:
        raise SourceError(str(exc)) from exc

    await _progress(
        progress,
        f"Source parsed successfully ({result['wordCount']} words; {result['license']}).",
    )
    return result


async def fetch_web_url(
    url: str,
    timeout_seconds: float = 30.0,
) -> dict[str, Any]:
    """Fetches a Web URL using SafeAsyncClient protecting against SSRF, rebinding, and resource bombs."""
    safe, reason = is_safe_url(url, resolve_dns=True)
    if not safe:
        raise SourceError(f"URL points to a restricted, private, or invalid network address: {reason}")

    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 LangfensAcademic/2.0"
        ),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,text/plain;q=0.8,*/*;q=0.7",
    }

    client = SafeAsyncClient(
        read_timeout=timeout_seconds,
        connect_timeout=10.0,
    )

    try:
        response = await client.get(url, headers=headers)
        response.raise_for_status()
        content_type = response.headers.get("content-type", "").lower()
        text = response.text
    except SSRFError as exc:
        raise SourceError(f"URL points to a restricted, private, or invalid network address: {exc}") from exc
    except ResourceCapError as exc:
        raise SourceError(f"Web URL response body exceeds limit: {exc}") from exc
    except httpx.HTTPError as exc:
        raise SourceNetworkError(f"Web URL request failed: {exc}") from exc

    if "html" in content_type or "<html" in text[:1000].lower():
        cleaned, title, author = clean_html(text)
    else:
        cleaned, title = clean_plain_text(text)
        author = None

    parsed_url = urllib.parse.urlparse(url)
    domain = parsed_url.hostname or "web"

    return {
        "title": title or f"Article from {domain}",
        "authors": author or domain,
        "url": str(response.url),
        "content": cleaned,
        "wordCount": count_words(cleaned),
        "domain": domain,
    }


async def resolve_pmcid(
    work: dict[str, Any],
    client: httpx.AsyncClient,
) -> Optional[dict[str, Any]]:
    """Joins an OpenAlex DOI to Europe PMC metadata before fetching full text."""
    doi_url = work.get("doi") or (work.get("ids") or {}).get("doi") or ""
    doi = str(doi_url).removeprefix("https://doi.org/").strip()
    if not re.fullmatch(r"10\.\d{4,9}/\S{1,180}", doi, re.IGNORECASE):
        return None
    try:
        response = await client.get(
            f"{EUROPE_PMC}/search",
            params={"query": f"DOI:{doi}", "format": "json", "pageSize": 2},
        )
        response.raise_for_status()
        results = response.json().get("resultList", {}).get("result", [])
    except (httpx.HTTPError, ValueError) as exc:
        raise SourceNetworkError(f"Europe PMC metadata request failed: {exc}") from exc

    for result in results:
        pmcid = str(result.get("pmcid") or "").upper()
        if PMCID_PATTERN.fullmatch(pmcid) and result.get("isOpenAccess") == "Y":
            return {
                "pmcid": pmcid,
                "openAlexId": work.get("id"),
                "topicId": ((work.get("primary_topic") or {}).get("subfield") or {}).get("id")
                or (work.get("primary_topic") or {}).get("id"),
            }
    return None


async def search_sources(topic: str) -> dict[str, Any]:
    """Queries OpenAlex for candidate works and filters via Europe PMC open access resolution."""
    if not 3 <= len(topic.strip()) <= 120:
        raise SourceError("Topic must contain 3–120 characters")

    params: dict[str, Any] = {
        "search": topic.strip(),
        "per-page": 50,
        "filter": "from_publication_date:2020-01-01,open_access.is_oa:true",
    }
    openalex_key = os.getenv("OPENALEX_API_KEY") or settings.openalex_api_key
    if openalex_key:
        params["api_key"] = openalex_key

    async with httpx.AsyncClient(timeout=20.0) as client:
        try:
            response = await client.get(OPENALEX, params=params)
            if response.status_code == 429:
                raise SourceError("OpenAlex rate limit reached; configure OPENALEX_API_KEY or retry later")
            response.raise_for_status()
            works = response.json().get("results", [])
        except (httpx.HTTPError, ValueError) as exc:
            if isinstance(exc, SourceError):
                raise
            raise SourceError(f"OpenAlex search failed: {exc}") from exc

    verified: list[dict[str, Any]] = []
    semaphore = asyncio.Semaphore(4)
    network_errors: list[str] = []

    async with httpx.AsyncClient(timeout=15.0) as client:
        async def resolve(work: dict[str, Any]) -> Optional[dict[str, Any]]:
            async with semaphore:
                try:
                    return await resolve_pmcid(work, client)
                except SourceNetworkError as exc:
                    network_errors.append(str(exc))
                    return None

        resolved = await asyncio.gather(*(resolve(work) for work in works[:40]))

    candidates = []
    seen_pmcids: set[str] = set()
    for candidate in resolved:
        if candidate is not None and candidate["pmcid"] not in seen_pmcids:
            candidates.append(candidate)
            seen_pmcids.add(candidate["pmcid"])
        if len(candidates) >= 24:
            break

    async def verify(candidate: dict[str, Any]) -> Optional[dict[str, Any]]:
        async with semaphore:
            try:
                source = await fetch_source(candidate["pmcid"])
            except SourceNetworkError as exc:
                network_errors.append(str(exc))
                return None
            except SourceError:
                return None
            return {key: value for key, value in source.items() if key != "content"} | {
                "openAlexId": candidate["openAlexId"],
                "topicId": candidate["topicId"],
            }

    seen_dois: set[str] = set()
    for item in await asyncio.gather(*(verify(c) for c in candidates)):
        if item is not None:
            doi = (item.get("doi") or "").casefold()
            if doi and doi in seen_dois:
                continue
            if doi:
                seen_dois.add(doi)
            verified.append(item)

    chosen: list[str] = []
    topics: set[str] = set()
    for item in verified:
        if item["topicId"] and item["topicId"] not in topics:
            chosen.append(item["pmcid"])
            topics.add(item["topicId"])
        if len(chosen) == 3:
            break
    for item in verified:
        if len(chosen) == 3:
            break
        if item["pmcid"] not in chosen:
            chosen.append(item["pmcid"])

    message = None
    if not chosen:
        message = (
            "Europe PMC could not verify the candidate sources; retry source search."
            if network_errors
            else "No eligible full-text sources were found; try a broader topic."
        )
    elif network_errors:
        message = "Some candidate sources could not be verified; you can use the available sources or retry search."

    return {"sources": verified, "selectedPmcids": chosen, "message": message}


async def ingest_source(
    payload: str,
    source_type: str = "auto",
    title: Optional[str] = None,
    url: Optional[str] = None,
    authors: Optional[str] = None,
    license_str: Optional[str] = None,
    progress: Optional[ProgressCallback] = None,
    strict_license: bool = False,
) -> dict[str, Any]:
    """Ingests, cleans, validates, and normalizes a source from any supported format."""
    payload_str = (payload or "").strip()
    if not payload_str:
        raise SourceError("Source payload cannot be empty")
    if len(payload_str.encode("utf-8")) > 5 * 1024 * 1024:
        raise SourceError("Source payload exceeds 5MB limit")

    detected_type = source_type.lower() if source_type != "auto" else detect_source_type(payload_str)
    await _progress(progress, f"Ingesting source (detected type: {detected_type}).")

    extracted_title = ""
    extracted_authors = ""
    extracted_url = ""
    extracted_license = ""
    domain_val = None
    doi = None

    if detected_type == "pmc":
        pmcid_match = re.search(r"PMC[0-9]+", payload_str, re.IGNORECASE)
        if not pmcid_match:
            raise SourceError(f"Invalid PMCID: {payload_str}")
        pmcid = pmcid_match.group(0).upper()
        res = await fetch_source(pmcid, progress)
        content = res["content"]
        source_id = res["pmcid"]
        extracted_title = res["title"]
        extracted_authors = res["authors"]
        extracted_url = res["url"]
        extracted_license = res["license"]
        doi = res.get("doi")
        domain_val = "europepmc.org"
    elif detected_type == "url":
        url_match = re.search(r"https?://\S+", payload_str)
        target_url = url_match.group(0) if url_match else payload_str
        res = await fetch_web_url(target_url)
        content = res["content"]
        source_id = f"URL:{hashlib.sha256(target_url.encode()).hexdigest()[:12]}"
        extracted_title = res["title"]
        extracted_authors = res["authors"]
        extracted_url = res["url"]
        
        # Enforce universal license policy: unknown rights not automatically approved
        try:
            cleared, eff_license = evaluate_universal_license(license_str, strict=strict_license)
        except LicenseError as exc:
            raise SourceError(str(exc)) from exc

        extracted_license = eff_license
        domain_val = res.get("domain")
    elif detected_type == "html":
        content, extracted_title, extracted_authors_val = clean_html(payload_str)
        extracted_authors = extracted_authors_val or ""
        extracted_url = url or ""
        
        try:
            cleared, eff_license = evaluate_universal_license(license_str, strict=strict_license)
        except LicenseError as exc:
            raise SourceError(str(exc)) from exc

        extracted_license = eff_license
        source_id = f"CUSTOM:{hashlib.sha256(content[:500].encode()).hexdigest()[:12]}"
        if url:
            domain_val = urllib.parse.urlparse(url).hostname
    elif detected_type == "markdown":
        content, extracted_title = clean_markdown(payload_str)
        extracted_authors = authors or ""
        extracted_url = url or ""
        
        try:
            cleared, eff_license = evaluate_universal_license(license_str, strict=strict_license)
        except LicenseError as exc:
            raise SourceError(str(exc)) from exc

        extracted_license = eff_license
        source_id = f"CUSTOM:{hashlib.sha256(content[:500].encode()).hexdigest()[:12]}"
        if url:
            domain_val = urllib.parse.urlparse(url).hostname
    elif detected_type in ("text", "custom"):
        content, extracted_title = clean_plain_text(payload_str)
        extracted_authors = authors or ""
        extracted_url = url or ""
        
        try:
            cleared, eff_license = evaluate_universal_license(license_str, strict=strict_license)
        except LicenseError as exc:
            raise SourceError(str(exc)) from exc

        extracted_license = eff_license
        source_id = f"CUSTOM:{hashlib.sha256(content[:500].encode()).hexdigest()[:12]}"
        if url:
            domain_val = urllib.parse.urlparse(url).hostname
    else:
        raise SourceError(f"Unsupported source type: {detected_type}")

    # Enforce character cap
    try:
        validate_extracted_content_length(content)
    except ResourceCapError as exc:
        raise SourceError(str(exc)) from exc

    # Enforce length requirement
    word_count = count_words(content)
    try:
        validate_source_length(word_count)
    except SourceLengthError as exc:
        raise SourceError(str(exc)) from exc

    final_title = (title or extracted_title or "Untitled Source").strip()[:180]
    final_authors = (authors or extracted_authors or "").strip()[:240]

    await _progress(
        progress,
        f"Source ingested successfully: '{final_title}' ({word_count} words).",
    )

    return {
        "sourceType": detected_type,
        "sourceId": source_id,
        "pmcid": source_id,
        "title": final_title,
        "url": url or extracted_url or "",
        "authors": final_authors,
        "doi": doi,
        "license": extracted_license,
        "wordCount": word_count,
        "content": content[:70_000],
        "contentPreview": content[:300].strip(),
        "normalizerVersion": NORMALIZER_VERSION,
        "metadata": {
            "domain": domain_val,
            "description": None,
            "format": detected_type,
        },
    }
