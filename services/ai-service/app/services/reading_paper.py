"""Source verification and passage-grounded IELTS Academic Reading generation."""
from __future__ import annotations

import asyncio
import hashlib
import html
from html.parser import HTMLParser
import ipaddress
import json
import os
import re
import socket
import unicodedata
import urllib.parse
import xml.etree.ElementTree as ET
from typing import Any, Awaitable, Callable

import httpx

from app.services.groq_service import groq_generate
from app.services.reading_paper_prompts import (
    build_group_instruction,
    build_passage_extension_prompt,
    build_passage_prompt,
    build_passage_revision_prompt,
    build_question_prompt,
)

OPENALEX = "https://api.openalex.org/works"
EUROPE_PMC = "https://www.ebi.ac.uk/europepmc/webservices/rest"
PMCID = re.compile(r"^PMC[0-9]+$", re.I)
WORD = re.compile(r"\b[\w'-]+\b")
ANSWER_TOKEN = re.compile(r"\d+(?:[.,]\d+)*(?:%|)?|[^\W\d_]+(?:[-'][^\W\d_]+)*", re.UNICODE)
LICENSE = re.compile(r"creativecommons\.org/(?:licenses/by/[0-9.]+(?:/[a-z-]+)?|publicdomain/zero/[0-9.]+)", re.I)
COUNTS = ((7, 6), (6, 7), (7, 7))
TYPES = (("TRUE_FALSE_NOT_GIVEN", "SENTENCE_COMPLETION"),
         ("MULTIPLE_CHOICE_SINGLE", "SUMMARY_COMPLETION"),
         ("YES_NO_NOT_GIVEN", "SHORT_ANSWER"))
ProgressCallback = Callable[[str, str], Awaitable[None]]


class SourceError(ValueError):
    pass


class SourceNetworkError(SourceError):
    pass


async def _progress(callback: ProgressCallback | None, message: str,
                    level: str = "Information") -> None:
    if callback is not None:
        await callback(level, message)


def _text(element: ET.Element | None) -> str:
    return " ".join(" ".join(element.itertext()).split()) if element is not None else ""


def parse_full_text(xml: bytes, pmcid: str) -> dict[str, Any]:
    if len(xml) > 4_000_000:
        raise SourceError("Full text is too large")
    try:
        root = ET.fromstring(xml)
    except ET.ParseError as exc:
        raise SourceError("Full text XML is invalid") from exc
    license_nodes = root.findall(".//license")
    license_values = [" ".join([node.attrib.get("{http://www.w3.org/1999/xlink}href", ""), _text(node)])
                      for node in license_nodes]
    license_value = next((value for value in license_values if LICENSE.search(value)), "")
    if not license_value:
        raise SourceError("No verified CC BY or CC0 license in full text")
    match = LICENSE.search(license_value)
    assert match is not None
    body = root.find(".//body")
    paragraphs = [_text(node) for node in body.iter("p")] if body is not None else []
    paragraphs = [p for p in paragraphs if len(WORD.findall(p)) >= 12]
    content = "\n\n".join(paragraphs)
    if len(WORD.findall(content)) < 600:
        raise SourceError("Full text is too short for a Reading passage")
    title = _text(root.find(".//article-title")) or pmcid
    authors = []
    for contributor in root.findall(".//contrib[@contrib-type='author']"):
        name = _text(contributor.find("./name")) or _text(contributor.find("./collab"))
        if name and name not in authors:
            authors.append(name)
    if not authors:
        raise SourceError("Author attribution unavailable in full text")
    doi_node = root.find(".//article-id[@pub-id-type='doi']")
    doi = _text(doi_node) or None
    return {"pmcid": pmcid.upper(), "title": title, "authors": ", ".join(authors), "doi": doi,
            "url": f"https://europepmc.org/articles/{pmcid.upper()}",
            "license": "https://" + match.group(0), "wordCount": len(WORD.findall(content)),
            "content": content[:70_000]}

class SemanticHTMLCleaner(HTMLParser):
    """Strips non-content tags and extracts clean semantic paragraphs and titles."""
    SUPPRESS_TAGS = {
        "script", "style", "noscript", "iframe", "nav", "header", "footer",
        "aside", "form", "svg", "button", "canvas", "figure", "figcaption",
        "select", "option", "audio", "video", "menu",
    }
    BLOCK_TAGS = {
        "p", "div", "h1", "h2", "h3", "h4", "h5", "h6", "li", "blockquote",
        "article", "section", "tr", "br", "hr", "main",
    }

    def __init__(self) -> None:
        super().__init__()
        self.suppress = 0
        self.pieces: list[str] = []
        self.title = ""
        self.author: str | None = None
        self._in_title = False
        self._in_h1 = False
        self.first_h1 = ""

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag_lower = tag.lower()
        attr_dict = {k.lower(): (v or "") for k, v in attrs}

        if tag_lower == "meta" and not self.author:
            name = attr_dict.get("name", "").lower()
            prop = attr_dict.get("property", "").lower()
            if name in ("author", "article:author", "byl") or prop in ("article:author", "author"):
                content = attr_dict.get("content", "").strip()
                if content:
                    self.author = content

        if tag_lower in self.SUPPRESS_TAGS:
            self.suppress += 1
            return
        if self.suppress > 0:
            return

        if tag_lower == "title":
            self._in_title = True
        elif tag_lower == "h1" and not self.first_h1:
            self._in_h1 = True

        if tag_lower in self.BLOCK_TAGS:
            self.pieces.append("\n\n")

    def handle_endtag(self, tag: str) -> None:
        tag_lower = tag.lower()
        if tag_lower in self.SUPPRESS_TAGS:
            self.suppress = max(0, self.suppress - 1)
            return
        if self.suppress > 0:
            return

        if tag_lower == "title":
            self._in_title = False
        elif tag_lower == "h1":
            self._in_h1 = False

        if tag_lower in self.BLOCK_TAGS:
            self.pieces.append("\n\n")

    def handle_data(self, data: str) -> None:
        if self.suppress > 0:
            return
        text = data.strip()
        if not text:
            return
        if self._in_title and not self.title:
            self.title = text
        if self._in_h1 and not self.first_h1:
            self.first_h1 = text
        self.pieces.append(data)


def clean_html(html_str: str) -> tuple[str, str, str | None]:
    cleaner = SemanticHTMLCleaner()
    try:
        cleaner.feed(html_str)
    except Exception:
        pass
    raw = "".join(cleaner.pieces)
    raw = html.unescape(raw)
    raw = unicodedata.normalize("NFKC", raw)
    paragraphs = [re.sub(r"\s+", " ", p).strip() for p in raw.split("\n\n")]
    cleaned = "\n\n".join(p for p in paragraphs if p)
    title = (cleaner.title or cleaner.first_h1).strip()
    return cleaned, title, cleaner.author


def clean_markdown(md_text: str) -> tuple[str, str]:
    text = (md_text or "").strip()
    # Strip YAML frontmatter
    text = re.sub(r"^---\s*\n[\s\S]*?\n---\s*\n", "", text)
    title = ""
    title_match = re.search(r"^#{1,3}\s+(.+)$", text, re.MULTILINE)
    if title_match:
        title = title_match.group(1).strip()
    # Strip image markup ![alt](url)
    text = re.sub(r"!\[[^\]]*\]\([^)]+\)", "", text)
    # Convert links [text](url) to text
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    # Strip code block wrappers
    text = re.sub(r"```[a-zA-Z]*\n([\s\S]*?)\n```", r"\1", text)
    # Strip bold/italic formatting
    text = re.sub(r"(\*\*|__)(.*?)\1", r"\2", text)
    text = re.sub(r"(\*|_)(.*?)\1", r"\2", text)
    # Strip headers #
    text = re.sub(r"^#{1,6}\s+", "", text, flags=re.MULTILINE)
    text = html.unescape(text)
    text = unicodedata.normalize("NFKC", text)
    paragraphs = [re.sub(r"\s+", " ", p).strip() for p in text.split("\n\n")]
    cleaned = "\n\n".join(p for p in paragraphs if p)
    return cleaned, title


def clean_plain_text(text: str) -> tuple[str, str]:
    text = (text or "").strip()
    text = html.unescape(text)
    text = unicodedata.normalize("NFKC", text)
    raw_paragraphs = re.split(r"\n\s*\n", text)
    paragraphs = [re.sub(r"\s+", " ", p).strip() for p in raw_paragraphs]
    paragraphs = [p for p in paragraphs if p]
    cleaned = "\n\n".join(paragraphs)
    first_line = paragraphs[0] if paragraphs else ""
    if len(first_line) <= 120:
        title = first_line.strip("# \t-*")
    else:
        title = first_line[:100].rsplit(" ", 1)[0].strip("# \t-*")
    return cleaned, title


def is_safe_url(url: str) -> bool:
    try:
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme not in ("http", "https"):
            return False
        hostname = parsed.hostname
        if not hostname:
            return False
        for res in socket.getaddrinfo(hostname, None):
            ip_str = res[4][0]
            ip = ipaddress.ip_address(ip_str)
            if ip.is_loopback or ip.is_private or ip.is_link_local or ip.is_multicast or ip.is_reserved:
                return False
        return True
    except Exception:
        return False


async def fetch_web_url(url: str, timeout_seconds: float = 30.0) -> dict[str, Any]:
    if not is_safe_url(url):
        raise SourceError("URL points to a restricted, private, or invalid network address")

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 LangfensAcademic/1.0",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,text/plain;q=0.8,*/*;q=0.7",
    }
    timeout = httpx.Timeout(timeout_seconds, connect=10.0)
    try:
        async with httpx.AsyncClient(timeout=timeout, follow_redirects=True, headers=headers) as client:
            response = await client.get(url)
            response.raise_for_status()
            content_type = response.headers.get("content-type", "").lower()
            text = response.text
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
        "wordCount": len(WORD.findall(cleaned)),
    }


def detect_source_type(payload: str) -> str:
    s = payload.strip()
    if PMCID.fullmatch(s):
        return "pmc"
    if re.match(r"^https?://", s, re.I):
        return "url"
    if re.search(r"<(?:!DOCTYPE|html|head|body|article|main|div|p)\b", s, re.I):
        return "html"
    if re.search(r"^#{1,6}\s+|\[.+?\]\(.+?\)|```", s, re.M):
        return "markdown"
    return "text"


async def ingest_source(
    payload: str,
    source_type: str = "auto",
    title: str | None = None,
    url: str | None = None,
    authors: str | None = None,
    license_str: str | None = None,
    progress: ProgressCallback | None = None,
) -> dict[str, Any]:
    payload_str = (payload or "").strip()
    if not payload_str:
        raise SourceError("Source payload cannot be empty")

    if source_type == "auto":
        detected_type = detect_source_type(payload_str)
    else:
        detected_type = source_type.lower().strip()

    await _progress(progress, f"Ingesting source of type '{detected_type}'.")

    if detected_type == "pmc":
        article = await fetch_source(payload_str, progress)
        source_id = article["pmcid"]
        content = article["content"]
        extracted_title = article["title"]
        extracted_authors = article["authors"]
        extracted_url = article["url"]
        extracted_license = article["license"]
        doi = article.get("doi")
    elif detected_type == "url":
        fetched = await fetch_web_url(payload_str)
        content = fetched["content"]
        extracted_title = fetched["title"]
        extracted_authors = fetched["authors"]
        extracted_url = fetched["url"]
        extracted_license = "Web Public"
        doi = None
        source_id = f"URL_{hashlib.sha256(payload_str.encode()).hexdigest()[:12]}"
    elif detected_type == "html":
        content, extracted_title, extracted_authors = clean_html(payload_str)
        extracted_url = url or ""
        extracted_license = license_str or "User Provided"
        doi = None
        source_id = f"HTML_{hashlib.sha256(content[:500].encode()).hexdigest()[:12]}"
    elif detected_type == "markdown":
        content, extracted_title = clean_markdown(payload_str)
        extracted_authors = authors or ""
        extracted_url = url or ""
        extracted_license = license_str or "User Provided"
        doi = None
        source_id = f"MD_{hashlib.sha256(content[:500].encode()).hexdigest()[:12]}"
    elif detected_type == "text":
        content, extracted_title = clean_plain_text(payload_str)
        extracted_authors = authors or ""
        extracted_url = url or ""
        extracted_license = license_str or "User Provided"
        doi = None
        source_id = f"TXT_{hashlib.sha256(content[:500].encode()).hexdigest()[:12]}"
    else:
        raise SourceError(f"Unsupported source type: {detected_type}")

    word_count = len(WORD.findall(content))
    if word_count < 600:
        raise SourceError(f"Source content is too short ({word_count} words; minimum is 600 words for IELTS Reading)")

    final_title = (title or extracted_title or "Untitled Source").strip()[:180]
    final_authors = (authors or extracted_authors or "").strip()[:240]

    await _progress(progress, f"Source ingested successfully: '{final_title}' ({word_count} words).")

    return {
        "sourceType": detected_type,
        "sourceId": source_id,
        "pmcid": source_id,
        "title": final_title,
        "url": url or extracted_url or "",
        "authors": final_authors,
        "doi": doi,
        "license": license_str or extracted_license or "User Provided",
        "wordCount": word_count,
        "content": content[:70_000],
    }

async def fetch_source(pmcid: str, progress: ProgressCallback | None = None) -> dict[str, Any]:
    if not PMCID.fullmatch(pmcid):
        raise SourceError("Invalid PMCID")
    timeout = httpx.Timeout(60.0, connect=15.0)
    async with httpx.AsyncClient(timeout=timeout, follow_redirects=False) as client:
        for attempt in range(3):
            try:
                await _progress(progress, f"Europe PMC full-text request started for {pmcid.upper()} (attempt {attempt + 1}/3).")
                response = await client.get(f"{EUROPE_PMC}/{pmcid.upper()}/fullTextXML")
                if response.status_code == 404:
                    raise SourceError("Open full text is unavailable")
                if response.status_code in (429, 502, 503, 504) and attempt < 2:
                    await _progress(progress, f"Europe PMC returned HTTP {response.status_code}; retrying.", "Warning")
                    await asyncio.sleep(2.0 * (attempt + 1))
                    continue
                response.raise_for_status()
                break
            except httpx.HTTPError as exc:
                if attempt < 2 and isinstance(exc, (httpx.TimeoutException, httpx.ConnectError)):
                    err_label = type(exc).__name__
                    await _progress(progress, f"Europe PMC request failed ({err_label}); retrying.", "Warning")
                    await asyncio.sleep(2.0 * (attempt + 1))
                    continue
                raise SourceNetworkError(f"Europe PMC request failed: {exc}") from exc
    await _progress(progress, f"Europe PMC returned HTTP {response.status_code}; validating XML, license and author metadata.")
    result = parse_full_text(response.content, pmcid)
    await _progress(progress, f"Source parsed successfully ({result['wordCount']} words; {result['license']}).")
    return result


async def resolve_pmcid(work: dict[str, Any], client: httpx.AsyncClient) -> dict[str, Any] | None:
    """Join an OpenAlex DOI to Europe PMC metadata before fetching full text."""
    doi_url = work.get("doi") or (work.get("ids") or {}).get("doi") or ""
    doi = str(doi_url).removeprefix("https://doi.org/").strip()
    if not re.fullmatch(r"10\.\d{4,9}/\S{1,180}", doi, re.I):
        return None
    try:
        response = await client.get(f"{EUROPE_PMC}/search", params={
            "query": f"DOI:{doi}", "format": "json", "pageSize": 2})
        response.raise_for_status()
        results = response.json().get("resultList", {}).get("result", [])
    except (httpx.HTTPError, ValueError) as exc:
        raise SourceNetworkError(f"Europe PMC metadata request failed: {exc}") from exc
    for result in results:
        pmcid = str(result.get("pmcid") or "").upper()
        if PMCID.fullmatch(pmcid) and result.get("isOpenAccess") == "Y":
            return {"pmcid": pmcid, "openAlexId": work.get("id"),
                    "topicId": ((work.get("primary_topic") or {}).get("subfield") or {}).get("id")
                    or (work.get("primary_topic") or {}).get("id")}
    return None


async def search_sources(topic: str) -> dict[str, Any]:
    if not 3 <= len(topic.strip()) <= 120:
        raise SourceError("Topic must contain 3–120 characters")
    params = {"search": topic.strip(), "per-page": 50,
              "filter": "from_publication_date:2020-01-01,open_access.is_oa:true"}
    if os.getenv("OPENALEX_API_KEY"):
        params["api_key"] = os.environ["OPENALEX_API_KEY"]
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
        async def resolve(work: dict[str, Any]) -> dict[str, Any] | None:
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

    async def verify(candidate: dict[str, Any]) -> dict[str, Any] | None:
        async with semaphore:
            try:
                source = await fetch_source(candidate["pmcid"])
            except SourceNetworkError as exc:
                network_errors.append(str(exc))
                return None
            except SourceError:
                return None
            return {key: value for key, value in source.items() if key != "content"} | {
                "openAlexId": candidate["openAlexId"], "topicId": candidate["topicId"]}

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
        message = ("Europe PMC could not verify the candidate sources; retry source search."
                   if network_errors else "No eligible full-text sources were found; try a broader topic.")
    elif network_errors:
        message = "Some candidate sources could not be verified; you can use the available sources or retry search."
    return {"sources": verified, "selectedPmcids": chosen, "message": message}


def _words(text: str) -> int:
    return len(WORD.findall(text))


def _answer_within_ielts_limit(answer: str) -> bool:
    tokens = ANSWER_TOKEN.findall(answer.strip())
    numbers = [token for token in tokens if token[:1].isdigit()]
    words = [token for token in tokens if not token[:1].isdigit()]
    return bool(tokens) and len(words) <= 3 and len(numbers) <= 1 and len(tokens) <= 4


def _answer_occurs_in_passage(answer: str, passage: str) -> bool:
    return bool(re.search(r"(?<!\w)" + re.escape(answer.strip()) + r"(?!\w)", passage, re.I))


def validate_passage_content(title: str, passage: str) -> None:
    internal_section_heading = re.compile(r"(?im)^\s*Section\s+[1-3]\s*:\s*.+$")
    if internal_section_heading.search(title) or internal_section_heading.search(passage):
        raise ValueError("Passage contains an internal section label")


def source_excerpt(content: str, max_chars: int = 15_000) -> str:
    """Sample across the article while keeping one LLM request below provider TPM limits."""
    if len(content) <= max_chars:
        return content
    paragraphs = [part.strip() for part in content.split("\n\n") if part.strip()]
    if not paragraphs:
        return content[:max_chars]
    count = min(24, len(paragraphs))
    indices = sorted({round(i * (len(paragraphs) - 1) / max(1, count - 1)) for i in range(count)})
    per_paragraph = max_chars // count - 2
    return "\n\n".join(paragraphs[i][:per_paragraph] for i in indices)


def trim_passage(passage: str) -> str:
    if _words(passage) <= 900:
        return passage
    for boundary in reversed([m.end() for m in re.finditer(r"[.!?](?=\s|$)", passage)]):
        trimmed = passage[:boundary].strip()
        if 720 <= _words(trimmed) <= 900:
            return trimmed
    return passage


async def extend_passage(passage: str, article_content: str, topic: str,
                         progress: ProgressCallback | None = None, *, index: int) -> str:
    """Add source-grounded paragraphs when a model under-delivers the word target."""
    for attempt in range(4):
        words = _words(passage)
        if words >= 720:
            break
        await _progress(progress, f"Passage has {words} words; requesting continuation {attempt + 1}/4.")
        requested = min(400, max(170, int((800 - words) * 1.5)))
        result = await generate_json(
            prompt_template="{instruction}\n\nSOURCE EXCERPTS:\n{source}\n\nPASSAGE SO FAR:\n{passage}",
            variables={"instruction": build_passage_extension_prompt(topic, index, requested),
                "source": source_excerpt(article_content, 8_000), "passage": passage[-7_000:]},
            expect_json=False, max_tokens=3000, progress=progress)
        addition = str(result.get("text") or result.get("continuation") or "").strip()
        if _words(addition) < 40:
            await _progress(progress, "Passage continuation was too short; stopping extension.", "Warning")
            break
        passage += "\n\n" + addition
        await _progress(progress, f"Passage continuation added; current length is {_words(passage)} words.")
    return trim_passage(passage)


async def generate_json(*, progress: ProgressCallback | None = None, **kwargs: Any) -> dict[str, Any]:
    """Wait for a provider TPM window only when a valid-sized request is rate limited."""
    for attempt in range(3):
        await _progress(progress,
                        f"LLM request started (JSON={kwargs.get('expect_json', True)}, max tokens={kwargs.get('max_tokens', 'default')}, attempt {attempt + 1}/3).")
        try:
            result = await groq_generate(**kwargs)
            await _progress(progress, f"LLM response received ({len(json.dumps(result, ensure_ascii=False))} characters).")
            return result
        except RuntimeError as exc:
            error = str(exc).lower()
            if "413" in error or "request too large" in error:
                await _progress(progress, f"LLM rejected the request size: {exc}", "Error")
                raise ValueError("LLM request exceeds provider token limit") from exc
            if attempt == 2 or not any(token in error for token in ("429", "rate limit", "rate_limit")):
                await _progress(progress, f"LLM request failed: {exc}", "Error")
                raise
            await _progress(progress, f"LLM rate limited the request; retrying after 65 seconds (attempt {attempt + 2}/3).", "Warning")
            await asyncio.sleep(65)
        except Exception as exc:
            await _progress(progress, f"LLM request failed: {exc}", "Error")
            raise
    raise AssertionError("unreachable")


def validate_section(data: dict[str, Any], index: int) -> dict[str, Any]:
    if index not in (1, 2, 3):
        raise ValueError("Section index must be 1–3")
    passage = str(data.get("passage", "")).strip()
    if not 720 <= _words(passage) <= 915:
        raise ValueError("Passage must contain 720–915 words")
    validate_passage_content(str(data.get("title", "")), passage)
    groups = data.get("groups")
    if not isinstance(groups, list) or len(groups) != 2:
        raise ValueError("Section must have two question groups")
    expected = sum(COUNTS[index - 1])
    seen: set[str] = set()
    number = sum(sum(c) for c in COUNTS[:index - 1]) + 1
    for group_index, group in enumerate(groups):
        if group.get("type") != TYPES[index - 1][group_index]:
            raise ValueError("Wrong question type")
        questions = group.get("questions")
        if not isinstance(questions, list) or len(questions) != COUNTS[index - 1][group_index]:
            raise ValueError("Wrong group question count")
        first = number
        last = first + len(questions) - 1
        if group.get("instruction") != build_group_instruction(group["type"], first, last):
            raise ValueError(f"Question group instruction does not match {group['type']}")
        validate_group_candidate(group["type"], len(questions), first, questions, passage)
        for question in questions:
            if question.get("number") != number:
                raise ValueError("Question numbers must be continuous")
            prompt = str(question.get("prompt", "")).strip()
            key = re.sub(r"\W+", "", prompt.casefold())
            if key in seen:
                raise ValueError("Duplicate question")
            seen.add(key)
            number += 1
    if number != sum(sum(c) for c in COUNTS[:index - 1]) + expected + 1:
        raise ValueError("Wrong section question count")
    return data


def validate_group_candidate(kind: str, count: int, first: int,
                             questions: Any, passage: str) -> None:
    if not isinstance(questions, list) or len(questions) != count:
        raise ValueError(f"Expected {count} separate {kind} question objects")
    passage_norm = " ".join(passage.split()).casefold()
    for offset, question in enumerate(questions):
        number = first + offset
        if not isinstance(question, dict) or question.get("number") != number:
            raise ValueError(f"Question numbers must run from {first} to {first + count - 1}")
        prompt = str(question.get("prompt", ""))
        answer = str(question.get("answer", "")).strip()
        evidence = " ".join(str(question.get("evidenceQuote", "")).split())
        explanation = str(question.get("explanation", ""))
        if not prompt.strip() or not answer or len(explanation) < 25 or len(evidence) < 15:
            raise ValueError(f"Question {number} lacks a grounded prompt, answer or evidence")
        if evidence.casefold() not in passage_norm:
            raise ValueError(f"Question {number} Evidence quote is absent from passage")
        if kind in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE"):
            options = question.get("options")
            expected = (["TRUE", "FALSE", "NOT GIVEN"] if kind == "TRUE_FALSE_NOT_GIVEN"
                        else ["YES", "NO", "NOT GIVEN"] if kind == "YES_NO_NOT_GIVEN" else None)
            if not isinstance(options, list) or len(options) != (4 if expected is None else 3) \
                    or answer not in options or (expected and options != expected):
                raise ValueError(f"Question {number} has invalid options or answer")
            if expected is None and any(not str(option).startswith(f"{letter}.")
                                        for letter, option in zip("ABCD", options)):
                raise ValueError(f"Question {number} requires A–D options")
        if kind in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION"):
            if prompt.count(f"[{number}]") != 1 or not _answer_within_ielts_limit(answer):
                raise ValueError(f"Question {number} must have one [{number}] blank and a valid three-word/number answer")
            prompt_without_blank = prompt.replace(f"[{number}]", "", 1)
            if answer.casefold() in " ".join(prompt_without_blank.split()).casefold():
                raise ValueError(f"Question {number} has answer leakage in its completion prompt")
        if kind in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION", "SHORT_ANSWER"):
            if not _answer_within_ielts_limit(answer) or not _answer_occurs_in_passage(answer, passage):
                raise ValueError(f"Question {number} answer must appear in passage")
            if kind == "SHORT_ANSWER" and answer.casefold() in " ".join(prompt.split()).casefold():
                raise ValueError(f"Question {number} has answer leakage in its short-answer prompt")


def repair_evidence(questions: list[dict[str, Any]], passage: str) -> None:
    """Normalize quote whitespace only; never replace evidence by semantic similarity."""
    normalized_passage = " ".join(passage.split()).casefold()
    for question in questions:
        evidence = " ".join(str(question.get("evidenceQuote", "")).split())
        if evidence and evidence.casefold() in normalized_passage:
            question["evidenceQuote"] = evidence


SOURCE_REVIEW_ISSUES = {
    "unsupported_claim", "contradicted_claim", "causal_overstatement",
    "overstated_certainty", "unmeasured_outcome", "population_or_method_mismatch",
}
def _normalize_source_review_issue(issue: str) -> str:
    cleaned = issue.strip().lower().replace(" ", "_").rstrip(".")
    if cleaned.endswith("s") and cleaned[:-1] in SOURCE_REVIEW_ISSUES:
        return cleaned[:-1]
    if cleaned in SOURCE_REVIEW_ISSUES:
        return cleaned
    mapping = {
        "unsupported": "unsupported_claim",
        "unsupported_claims": "unsupported_claim",
        "contradicted": "contradicted_claim",
        "contradicted_claims": "contradicted_claim",
        "causation": "causal_overstatement",
        "overstatement": "causal_overstatement",
        "certainty": "overstated_certainty",
        "unmeasured": "unmeasured_outcome",
        "population_mismatch": "population_or_method_mismatch",
        "method_mismatch": "population_or_method_mismatch",
    }
    return mapping.get(cleaned, issue)



async def review_passage_source(source_text: str, passage: str,
                                progress: ProgressCallback | None = None) -> list[dict[str, str]]:
    await _progress(progress, "Source-fidelity review started.")
    review = await generate_json(
        prompt_template="{instruction}\n\nSOURCE EXCERPTS:\n{source}\n\nGENERATED PASSAGE:\n{passage}",
        variables={"instruction": (
            "Check the generated passage against ONLY the supplied source. Verify every factual claim, "
            "including population, method, findings, uncertainty and outcomes measured. Flag unsupported "
            "or contradicted claims, overstated certainty, claims that turn correlation into causation, "
            "and claims about outcomes the source did not measure. Do not request stylistic "
            "changes. Return JSON {\"passed\":boolean,\"findings\":[{\"claimQuote\":string,"
            "\"issue\":string,\"reason\":string}]}. Use issue codes from: "
            "unsupported_claim, contradicted_claim, causal_overstatement, overstated_certainty, "
            "unmeasured_outcome, population_or_method_mismatch. Give a concise reason, not internal reasoning."
        ), "source": source_excerpt(source_text, 14_000), "passage": passage},
        expect_json=True, temperature=0.1, max_tokens=5000, progress=progress)
    if not isinstance(review, dict) or type(review.get("passed")) is not bool or not isinstance(review.get("findings"), list):
        raise ValueError("Source-fidelity review returned malformed output")
    findings = review["findings"]
    for finding in findings:
        if isinstance(finding, dict) and isinstance(finding.get("issue"), str):
            finding["issue"] = _normalize_source_review_issue(finding["issue"])
        if (not isinstance(finding, dict) or not str(finding.get("claimQuote", "")).strip()
                or finding.get("issue") not in SOURCE_REVIEW_ISSUES
                or not str(finding.get("reason", "")).strip()):
            raise ValueError("Source-fidelity review returned a malformed finding")
    if review["passed"] != (len(findings) == 0):
        raise ValueError("Source-fidelity review result conflicts with its findings")
    if findings:
        await _progress(progress, f"Source-fidelity review found {len(findings)} issue(s): "
                        + "; ".join(f"{item['issue']}: {item['reason'][:240]}" for item in findings), "Warning")
    else:
        await _progress(progress, "Source-fidelity review passed; no unsupported or overstated claims found.")
    return findings


QUESTION_REVIEW_ISSUES = {
    "unsupported", "contradicted", "not_given_misused", "ambiguous", "duplicate",
    "type_mismatch", "wrong_answer", "explanation_mismatch", "answer_leakage",
    "multiple_correct_options", "word_limit", "invalid_evidence", "too_direct",
}


async def review_answers(passage: str, groups: list[dict[str, Any]],
                         progress: ProgressCallback | None = None) -> dict[int, dict[str, Any]]:
    await _progress(progress, "Independent answer review started.")
    review = await generate_json(
        prompt_template="{instruction}\n\n{payload}",
        variables={"instruction": (
            "Review every question independently against ONLY the passage and its group instruction. "
            "Assess each group as a set for IELTS Academic Reading fit: items should require useful "
            "paraphrase, inference, or interpretation of relationships, rather than all being direct phrase "
            "lookups. If nearly all items in a group can be answered by copying a nearby phrase without "
            "interpreting it, mark the overly direct items with too_direct. A direct fact can still be valid "
            "when the question requires interpreting or matching its meaning. Do not add outside knowledge. "
            "For TRUE/FALSE/NOT GIVEN, TRUE is supported, FALSE is contradicted, and NOT GIVEN is neither "
            "stated nor contradicted; related facts and outside knowledge do not prove a statement. For "
            "YES/NO/NOT GIVEN, judge only the writer's view or claim. Check that the answer is correct and "
            "unique, the exact evidence supports the whole answer, the explanation matches that evidence, "
            "the type and instruction are followed, the answer is not leaked in the prompt, and no multiple "
            "choice has multiple correct options or more than one plausible correct option. Check for answer "
            "leakage. For SUMMARY_COMPLETION, check that the prompts form a connected summary in question "
            "number order. Reject ambiguous, unsupported, duplicate or over-limit items. Return JSON "
            "{\"reviews\":[{\"number\":integer,\"valid\":boolean,"
            "\"issues\":[issue_code],\"reason\":string}]}; give one entry for every question. Allowed "
            "issue codes: unsupported, contradicted, not_given_misused, ambiguous, duplicate, type_mismatch, "
            "wrong_answer, explanation_mismatch, answer_leakage, multiple_correct_options, word_limit, "
            "invalid_evidence, too_direct. A valid item has no issues. An invalid item has at least one issue and a concise "
            "reason. Do not provide internal reasoning."
        ), "payload": json.dumps({"passage": passage, "groups": groups}, ensure_ascii=False)},
        expect_json=True, temperature=0.1, max_tokens=2800, progress=progress)
    raw = review.get("reviews") if isinstance(review, dict) else None
    expected = [question["number"] for group in groups for question in group["questions"]]
    if not isinstance(raw, list) or len(raw) != len(expected):
        raise ValueError("Independent answer review must return one verdict for every question")
    parsed: dict[int, dict[str, Any]] = {}
    for item in raw:
        if not isinstance(item, dict) or type(item.get("number")) is not int or type(item.get("valid")) is not bool:
            raise ValueError("Independent answer review returned a malformed question verdict")
        number = item["number"]
        issues = item.get("issues")
        reason = item.get("reason")
        if (number not in expected or number in parsed or not isinstance(issues, list)
                or not all(isinstance(issue, str) and issue in QUESTION_REVIEW_ISSUES for issue in issues)
                or not isinstance(reason, str) or (item["valid"] and issues)
                or (not item["valid"] and (not issues or not reason.strip()))):
            raise ValueError("Independent answer review returned an invalid question verdict")
        parsed[number] = {"number": number, "valid": item["valid"], "issues": issues,
                          "reason": reason.strip()[:400]}
    if set(parsed) != set(expected):
        raise ValueError("Independent answer review must cover every question")
    await _progress(progress, f"Independent answer review completed: {sum(item['valid'] for item in parsed.values())}/{len(parsed)} passed.")
    return parsed


async def replace_rejected_question(passage: str, groups: list[dict[str, Any]], number: int,
                                   progress: ProgressCallback | None = None) -> None:
    for group in groups:
        for offset, old in enumerate(group["questions"]):
            if old["number"] != number:
                continue
            kind = group["type"]
            other_prompts = [q["prompt"] for g in groups for q in g["questions"] if q["number"] != number]
            instruction = build_question_prompt(kind, 1, number, number, replacement=True)
            instruction += "Do not repeat these prompts: " + json.dumps(other_prompts, ensure_ascii=False)
            await _progress(progress, f"Replacing question {number} after validation or answer review rejection.", "Warning")
            result = await generate_json(
                prompt_template="{instruction}\n\nPASSAGE:\n{passage}",
                variables={"instruction": instruction, "passage": passage}, expect_json=True,
                max_tokens=1700, progress=progress)
            replacement = result.get("question")
            if not isinstance(replacement, dict):
                raise ValueError(f"Replacement for question {number} is malformed")
            repair_evidence([replacement], passage)
            validate_group_candidate(kind, 1, number, [replacement], passage)
            group["questions"][offset] = replacement
            await _progress(progress, f"Question {number} replacement passed validation.")
            return
    raise ValueError(f"Question {number} is absent from section")


async def _generate_section_once(topic: str, index: int, source: dict[str, Any],
                                 progress: ProgressCallback | None = None) -> dict[str, Any]:
    if index not in (1, 2, 3):
        raise ValueError("Section index must be 1–3")
    if "content" in source and isinstance(source["content"], str) and len(WORD.findall(source["content"])) >= 600:
        source_title = source.get("title") or topic
        source_id = source.get("sourceId") or source.get("pmcid") or f"SRC_{index}"
        await _progress(progress, f"Passage {index}: using pre-ingested source '{source_title}'.")
        article = {
            "pmcid": source_id,
            "sourceId": source_id,
            "sourceType": source.get("sourceType", "custom"),
            "title": source_title,
            "authors": source.get("authors") or "",
            "doi": source.get("doi") or None,
            "url": source.get("url") or "",
            "license": source.get("license") or "User Provided",
            "wordCount": len(WORD.findall(source["content"])),
            "content": source["content"][:70_000],
        }
    else:
        pmcid = str(source.get("pmcid") or source.get("sourceId") or "").strip()
        await _progress(progress, f"Passage {index}: fetching and verifying source {pmcid}.")
        article = await fetch_source(pmcid, progress)
        if source.get("doi") and article.get("doi") and source["doi"].casefold() != article["doi"].casefold():
            raise SourceError("Source DOI changed")
        if source.get("license") and source["license"] != article["license"]:
            raise SourceError("Source license changed")
    await _progress(progress, f"Source verified: {article['title']} ({article['wordCount']} source words; {article['license']}).")
    await _progress(progress, f"Passage {index}: generating a source-grounded reading passage.")
    passage_result = await generate_json(
        prompt_template="{instruction}\n\n{source}",
        variables={"instruction": build_passage_prompt(topic, index, article["title"]),
                   "source": source_excerpt(article["content"], 12_000)},
        expect_json=False, max_tokens=3200,
        progress=progress)
    if "passage" in passage_result:
        passage = str(passage_result.get("passage", "")).strip()
        title = str(passage_result.get("title", "")).strip()
    else:
        raw = str(passage_result.get("text", "")).strip()
        first, _, remaining = raw.partition("\n")
        title = first.strip("# *\t ")[:180]
        passage = remaining.strip()
        if _words(passage) < 350:
            title = article["title"][:180]
            passage = raw
    if title and 350 <= _words(passage) < 720:
        passage = await extend_passage(passage, article["content"], topic, progress, index=index)
    passage = trim_passage(passage)
    if not title or not 720 <= _words(passage) <= 915:
        await _progress(progress, f"Generated passage failed title or word-count validation ({_words(passage)} words).", "Error")
        raise ValueError(f"Passage generation returned an invalid title or {_words(passage)} words")
    validate_passage_content(title, passage)
    findings = await review_passage_source(article["content"], passage, progress)
    if findings:
        await _progress(progress, "Revising source-fidelity findings before generating questions.", "Warning")
        revised = await generate_json(
            prompt_template="{instruction}\n\nSOURCE EXCERPTS:\n{source}\n\nPASSAGE TO REVISE:\n{passage}\n\nREVIEW FINDINGS:\n{findings}",
            variables={"instruction": build_passage_revision_prompt(topic, index),
                "source": source_excerpt(article["content"], 14_000), "passage": passage,
                "findings": json.dumps(findings, ensure_ascii=False)},
            expect_json=False, max_tokens=3400, progress=progress)
        revised_raw = str(revised.get("text") or revised.get("passage") or "").strip()
        revised_title, _, revised_passage = revised_raw.partition("\n")
        title = revised_title.strip("# *\t ")[:180]
        passage = trim_passage(revised_passage.strip())
        if not title or not 720 <= _words(passage) <= 915:
            raise ValueError("Source-fidelity revision returned an invalid title or passage length")
        remaining_findings = await review_passage_source(article["content"], passage, progress)
        if remaining_findings:
            details = "; ".join(f"{item['issue']}: {item['reason'][:180]}" for item in remaining_findings)
            raise ValueError(f"Source-fidelity review rejected the revised passage: {details}")
    await _progress(progress, f"Passage accepted: '{title}' ({_words(passage)} words).")
    groups = []
    start = sum(sum(c) for c in COUNTS[:index - 1]) + 1
    for group_index, (kind, count) in enumerate(zip(TYPES[index - 1], COUNTS[index - 1])):
        first = start + sum(COUNTS[index - 1][:group_index])
        last = first + count - 1
        instruction = build_question_prompt(kind, count, first, last)
        feedback = ""
        for attempt in range(3):
            await _progress(progress,
                            f"Generating question group {group_index + 1}/2: {kind}, questions {first}–{last}, attempt {attempt + 1}/3.")
            result = await generate_json(
                prompt_template="{instruction}\n\nPASSAGE:\n{passage}",
                variables={"instruction": instruction + feedback, "passage": passage},
                expect_json=True, max_tokens=5000, progress=progress)
            questions = result.get("questions", [])
            if isinstance(questions, list):
                repair_evidence([q for q in questions if isinstance(q, dict)], passage)
            try:
                for _ in range(3):
                    try:
                        validate_group_candidate(kind, count, first, questions, passage)
                        break
                    except ValueError as candidate_error:
                        match = re.search(r"Question (\d+)", str(candidate_error))
                        if match is None or not isinstance(questions, list):
                            raise
                        number = int(match.group(1))
                        if not first <= number <= last:
                            raise
                        await replace_rejected_question(
                            passage, groups + [{"type": kind, "questions": questions}], number, progress)
                validate_group_candidate(kind, count, first, questions, passage)
                await _progress(progress, f"Question group {kind} passed validation.")
                break
            except ValueError as exc:
                if attempt == 2:
                    raise
                feedback = f" Previous output was invalid: {exc}. Correct this in the next output."
                await _progress(progress, f"Question group {kind} failed validation: {exc}. Asking the model to correct it.", "Warning")
        groups.append({"type": kind, "instruction": build_group_instruction(kind, first, last),
            "questions": questions})
    await _progress(progress, "Checking section question numbering, evidence, answers and passage rules.")
    section = validate_section({"title": title, "passage": passage, "source": {
        key: value for key, value in article.items() if key != "content"}, "groups": groups}, index)
    await _progress(progress, "Section structure and question validation passed.")
    expected_numbers = list(range(start, start + sum(COUNTS[index - 1])))
    reviews = await review_answers(passage, groups, progress)
    missing = sorted(number for number in expected_numbers if not reviews[number]["valid"])
    if missing:
        for number in missing:
            review = reviews[number]
            await _progress(progress,
                            f"Independent review rejected Q{number}: {', '.join(review['issues'])}. {review['reason']}",
                            "Warning")
    if missing and len(missing) <= 4:
        for number in missing:
            await replace_rejected_question(passage, groups, number, progress)
        validate_section(section, index)
        await _progress(progress, "Rechecking the repaired questions with the independent reviewer.")
        reviews = await review_answers(passage, groups, progress)
    missing = sorted(number for number in expected_numbers if not reviews[number]["valid"])
    if missing:
        for number in missing:
            review = reviews[number]
            await _progress(progress,
                            f"Independent review still rejects Q{number}: {', '.join(review['issues'])}. {review['reason']}",
                            "Error")
        raise ValueError(f"Independent answer review rejected questions {missing}")
    await _progress(progress, f"Passage {index} completed: {len(expected_numbers)} questions passed independent review.")
    return section


async def generate_section(topic: str, index: int, source: dict[str, Any],
                           progress: ProgressCallback | None = None) -> dict[str, Any]:
    """Retry malformed model output once before the durable job records a failure."""
    for attempt in range(2):
        await _progress(progress, f"Passage {index} generation attempt {attempt + 1}/2 started.")
        try:
            return await _generate_section_once(topic, index, source, progress)
        except SourceError:
            raise
        except ValueError as exc:
            await _progress(progress, f"Passage {index} generation attempt failed validation: {exc}", "Warning")
            if attempt == 1:
                raise
    raise AssertionError("unreachable")
