"""Multi-format content normalization and cleaning for Langfens Loop Engine V2.

Supported formats:
- Europe PMC JATS XML full text
- Semantic HTML article bodies (removes scripts, styles, boilerplate, keeps headings/tables)
- Markdown articles (removes frontmatter, images, codeblocks, formatting)
- Plain text bodies (normalizes paragraphs)

All normalizers enforce:
- Normalizer version tracking ("v2.0.0")
- NFKC Unicode normalization
- Deterministic idempotency: clean(clean(text)) == clean(text)
"""

from __future__ import annotations

import html
from html.parser import HTMLParser
import re
import unicodedata
import xml.etree.ElementTree as ET
from typing import Any, Optional, Tuple

from app.ingestion.license import (
    count_words,
    validate_europe_pmc_license,
    validate_source_length,
    LicenseError,
    SourceLengthError,
)

NORMALIZER_VERSION = "v2.0.0"
MAX_XML_BYTES = 4_000_000


class CleanerError(ValueError):
    """Raised when cleaning or parsing source content fails."""
    pass


def _text(element: Optional[ET.Element]) -> str:
    """Extracts and normalizes whitespace from an ElementTree element."""
    return " ".join(" ".join(element.itertext()).split()) if element is not None else ""


class SemanticHTMLCleaner(HTMLParser):
    """Strips non-content tags and boilerplate while extracting clean semantic text."""

    SUPPRESS_TAGS = frozenset({
        "script", "style", "noscript", "iframe", "nav", "header", "footer",
        "aside", "form", "svg", "button", "canvas", "figure", "figcaption",
        "select", "option", "audio", "video", "menu",
    })
    BLOCK_TAGS = frozenset({
        "p", "div", "h1", "h2", "h3", "h4", "h5", "h6", "li", "blockquote",
        "article", "section", "tr", "br", "hr", "main",
    })
    BOILERPLATE_CLASSES = frozenset({
        "ad", "advertisement", "sidebar", "social-share", "comments",
        "related", "related-news", "relatednews", "related-posts", "related-articles",
        "other-news", "othernews", "recommend", "recommended", "recommendation",
        "breadcrumb", "breadcrumbs", "tags", "tag-list", "taglist", "article-tags",
        "popular", "trending", "most-read", "mostread", "top-news",
        "more-news", "news-list", "widget", "share", "listing", "cookie-notice",
    })
    BOILERPLATE_IDS = frozenset({
        "cookie-notice", "cookie_notice", "sidebar", "related-news", "comments",
        "footer", "header", "nav", "menu", "advertisement", "ad",
    })
    VOID_TAGS = frozenset({
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr",
    })

    def __init__(self) -> None:
        super().__init__()
        self.suppress_stack: list[str] = []
        self.pieces: list[str] = []
        self.title: str = ""
        self.author: Optional[str] = None
        self._in_title: bool = False
        self._in_h1: bool = False
        self.first_h1: str = ""

    @staticmethod
    def _class_tokens(value: str) -> set[str]:
        tokens = set()
        for part in (value or "").split():
            clean = part.strip().lower()
            if clean:
                tokens.add(clean)
                for sub in re.split(r"[-_]+", clean):
                    if sub:
                        tokens.add(sub)
        return tokens

    def _matches_boilerplate(self, attr_dict: dict[str, str]) -> bool:
        classes = self._class_tokens(attr_dict.get("class", ""))
        if classes & self.BOILERPLATE_CLASSES:
            return True
        element_id = (attr_dict.get("id", "") or "").strip().lower()
        if element_id:
            id_tokens = {element_id} | {sub for sub in re.split(r"[-_]+", element_id) if sub}
            if id_tokens & self.BOILERPLATE_IDS or id_tokens & self.BOILERPLATE_CLASSES:
                return True
        return False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, Optional[str]]]) -> None:
        tag_lower = tag.lower()
        attr_dict = {k.lower(): (v or "") for k, v in attrs}

        if tag_lower == "meta" and not self.author:
            name = attr_dict.get("name", "").lower()
            prop = attr_dict.get("property", "").lower()
            if name in ("author", "article:author", "byl") or prop in ("article:author", "author"):
                content = attr_dict.get("content", "").strip()
                if content:
                    self.author = content

        if self.suppress_stack:
            if tag_lower not in self.VOID_TAGS:
                self.suppress_stack.append(tag_lower)
            return

        if tag_lower in self.SUPPRESS_TAGS or self._matches_boilerplate(attr_dict):
            if tag_lower not in self.VOID_TAGS:
                self.suppress_stack.append(tag_lower)
            return

        if tag_lower == "title":
            self._in_title = True
        elif tag_lower == "h1" and not self.first_h1:
            self._in_h1 = True

        if tag_lower in self.BLOCK_TAGS:
            self.pieces.append("\n\n")

    def handle_endtag(self, tag: str) -> None:
        tag_lower = tag.lower()
        if self.suppress_stack:
            if self.suppress_stack[-1] == tag_lower:
                self.suppress_stack.pop()
            elif tag_lower in self.suppress_stack:
                while self.suppress_stack and self.suppress_stack[-1] != tag_lower:
                    self.suppress_stack.pop()
                if self.suppress_stack:
                    self.suppress_stack.pop()
            return

        if tag_lower == "title":
            self._in_title = False
        elif tag_lower == "h1":
            self._in_h1 = False

        if tag_lower in self.BLOCK_TAGS:
            self.pieces.append("\n\n")

    def handle_data(self, data: str) -> None:
        if self.suppress_stack:
            return
        text = data.strip()
        if not text:
            return
        if self._in_title and not self.title:
            self.title = text
        if self._in_h1 and not self.first_h1:
            self.first_h1 = text
        self.pieces.append(data)


def clean_html(html_str: str) -> Tuple[str, str, Optional[str]]:
    """Strips non-content HTML tags and extracts clean text, title, and author."""
    cleaner = SemanticHTMLCleaner()
    try:
        cleaner.feed(html_str)
    except Exception:
        pass
    raw = "".join(cleaner.pieces)
    raw = html.unescape(raw)
    raw = unicodedata.normalize("NFKC", raw)
    paragraphs = [re.sub(r"[ \t]+", " ", p).strip() for p in raw.split("\n\n")]
    cleaned = "\n\n".join(p for p in paragraphs if p)
    title = (cleaner.title or cleaner.first_h1).strip()
    return cleaned, title, cleaner.author


def clean_markdown(md_text: str) -> Tuple[str, str]:
    """Cleans Markdown documents, stripping frontmatter, images, links, and code blocks."""
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
    # Strip code blocks
    text = re.sub(r"```[a-zA-Z]*\n[\s\S]*?\n```", "", text)
    # Strip bold/italic formatting
    text = re.sub(r"(\*\*|__)(.*?)\1", r"\2", text)
    text = re.sub(r"(\*|_)(.*?)\1", r"\2", text)
    # Strip headers #
    text = re.sub(r"^#{1,6}\s+", "", text, flags=re.MULTILINE)
    text = html.unescape(text)
    text = unicodedata.normalize("NFKC", text)
    paragraphs = [re.sub(r"[ \t]+", " ", p).strip() for p in text.split("\n\n")]
    cleaned = "\n\n".join(p for p in paragraphs if p)
    return cleaned, title


def clean_plain_text(text: str) -> Tuple[str, str]:
    """Normalizes plain text paragraphs and infers title."""
    text = (text or "").strip()
    text = html.unescape(text)
    text = unicodedata.normalize("NFKC", text)
    raw_paragraphs = re.split(r"\n\s*\n", text)
    paragraphs = [re.sub(r"[ \t]+", " ", p).strip() for p in raw_paragraphs]
    paragraphs = [p for p in paragraphs if p]
    cleaned = "\n\n".join(paragraphs)
    first_line = paragraphs[0] if paragraphs else ""
    if len(first_line) <= 120:
        title = first_line.strip("# \t-*")
    else:
        title = first_line[:100].rsplit(" ", 1)[0].strip("# \t-*")
    return cleaned, title


def clean_xml_full_text(xml_bytes: bytes, pmcid: str) -> dict[str, Any]:
    """Parses and normalizes Europe PMC JATS full text XML."""
    if len(xml_bytes) > MAX_XML_BYTES:
        raise CleanerError("Full text is too large")

    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError as exc:
        raise CleanerError("Full text XML is invalid") from exc

    license_nodes = root.findall(".//license")
    license_values = [
        " ".join([node.attrib.get("{http://www.w3.org/1999/xlink}href", ""), _text(node)])
        for node in license_nodes
    ]
    raw_license = " ".join(license_values)
    try:
        verified_license_url = validate_europe_pmc_license(raw_license)
    except LicenseError as exc:
        raise CleanerError(str(exc)) from exc
    body = root.find(".//body")
    paragraphs = [_text(node) for node in body.iter("p")] if body is not None else []
    # Filter out captions or short notes (< 12 words)
    paragraphs = [unicodedata.normalize("NFKC", p) for p in paragraphs if count_words(p) >= 12]
    content = "\n\n".join(paragraphs)

    word_count = count_words(content)
    if word_count < 600:
        raise CleanerError("Full text is too short for a Reading passage")
    title = _text(root.find(".//article-title")) or pmcid
    authors = []
    for contributor in root.findall(".//contrib[@contrib-type='author']"):
        name = _text(contributor.find("./name")) or _text(contributor.find("./collab"))
        if name and name not in authors:
            authors.append(name)

    if not authors:
        raise CleanerError("Author attribution unavailable in full text")

    doi_node = root.find(".//article-id[@pub-id-type='doi']")
    doi = _text(doi_node) or None

    return {
        "pmcid": pmcid.upper(),
        "title": title,
        "authors": ", ".join(authors),
        "doi": doi,
        "url": f"https://europepmc.org/articles/{pmcid.upper()}",
        "license": verified_license_url,
        "wordCount": word_count,
        "content": content[:70_000],
        "normalizerVersion": NORMALIZER_VERSION,
    }


def normalize_source_content(
    raw_text: str,
    source_type: str,
) -> Tuple[str, str, Optional[str]]:
    """Dispatches content cleaning and returns (cleaned_text, title, author)."""
    st = source_type.lower()
    if st == "html":
        return clean_html(raw_text)
    elif st == "markdown":
        cleaned, title = clean_markdown(raw_text)
        return cleaned, title, None
    else:
        cleaned, title = clean_plain_text(raw_text)
        return cleaned, title, None
