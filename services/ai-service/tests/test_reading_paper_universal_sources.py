"""Unit tests for Universal Source Ingestion in reading_paper."""
from __future__ import annotations

import asyncio
from unittest.mock import AsyncMock, patch

import httpx
import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.services.reading_paper import (
    SemanticHTMLCleaner,
    SourceError,
    clean_html,
    clean_markdown,
    clean_plain_text,
    detect_source_type,
    fetch_web_url,
    generate_section,
    ingest_source,
    is_safe_url,
)


# Helper to generate dummy text with exact word count
def make_words(count: int, topic: str = "science") -> str:
    base = f"The study of {topic} provides essential insights into biological and physical systems across diverse ecosystems. "
    words_per_base = len(base.split())
    repetitions = (count // words_per_base) + 2
    full = (base * repetitions).split()[:count]
    return " ".join(full)


class TestHTMLCleaner:
    def test_strips_scripts_styles_and_boilerplate(self):
        html_input = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Marine Ecosystems</title>
            <style>body { color: red; }</style>
            <script>alert('track');</script>
            <meta name="author" content="Dr. Elena Rostova" />
        </head>
        <body>
            <nav><a href="/">Home</a></nav>
            <header><h1>Marine Ecosystems in the Anthropocene</h1></header>
            <article>
                <p>Coral reefs are fragile marine structures supporting extraordinary biodiversity.</p>
                <div>They face increasing threats from ocean acidification and thermal stress.</div>
            </article>
            <aside><div class="ad">Buy our diving gear!</div></aside>
            <footer>Copyright 2026 Ocean Institute</footer>
        </body>
        </html>
        """
        cleaned, title, author = clean_html(html_input)
        assert title == "Marine Ecosystems"
        assert author == "Dr. Elena Rostova"
        assert "Coral reefs are fragile marine structures" in cleaned
        assert "ocean acidification" in cleaned
        assert "alert" not in cleaned
        assert "color: red" not in cleaned
        assert "Buy our diving gear" not in cleaned
        assert "Copyright 2026" not in cleaned

    def test_unescapes_entities_and_normalizes_whitespace(self):
        html_input = "<p>Temperature &gt; 30&deg;C &amp; salinity &lt; 35&permil;&nbsp;causes stress.</p>"
        cleaned, title, author = clean_html(html_input)
        assert ">" in cleaned
        assert "<" in cleaned
        assert "&" in cleaned
        assert "  " not in cleaned


class TestMarkdownCleaner:
    def test_cleans_frontmatter_links_and_formatting(self):
        md_input = """---
title: Arctic Melting
author: Polar Research Group
---

# Arctic Melting and Ocean Currents

Global warming has accelerated **ice sheet retreat** in Greenland. According to [NSIDC data](https://nsidc.org), ice volume has fallen significantly.

![Glacier photo](https://example.com/glacier.png)

```python
# Simulation model code
run_model()
```

### Feedback Mechanisms

Albedo reduction causes further *solar radiation absorption*.
"""
        cleaned, title = clean_markdown(md_input)
        assert title == "Arctic Melting and Ocean Currents"
        assert "Global warming has accelerated ice sheet retreat" in cleaned
        assert "NSIDC data" in cleaned
        assert "https://nsidc.org" not in cleaned
        assert "Glacier photo" not in cleaned
        assert "Feedback Mechanisms" in cleaned
        assert "author: Polar Research" not in cleaned


class TestPlainTextCleaner:
    def test_normalizes_paragraphs_and_extracts_title(self):
        raw_text = """Understanding Cognitive Psychology

Cognitive psychology explores internal mental processes including perception, thinking, memory, and attention.

Researchers investigate how individuals acquire, process, and store complex informational structures.
"""
        cleaned, title = clean_plain_text(raw_text)
        assert title == "Understanding Cognitive Psychology"
        assert len(cleaned.split("\n\n")) == 3
        assert "acquiring" not in cleaned
        assert "store complex informational structures" in cleaned


class TestSSRFProtection:
    def test_blocks_loopback_addresses(self):
        assert not is_safe_url("http://127.0.0.1:8000/api")
        assert not is_safe_url("http://localhost:5000")
        assert not is_safe_url("http://[::1]:8080/test")

    def test_blocks_private_rfc1918_addresses(self):
        assert not is_safe_url("http://10.0.0.1/admin")
        assert not is_safe_url("http://172.16.0.1/")
        assert not is_safe_url("http://192.168.1.254/")

    def test_blocks_cloud_metadata_service(self):
        assert not is_safe_url("http://169.254.169.254/latest/meta-data/")

    def test_blocks_invalid_schemes(self):
        assert not is_safe_url("file:///etc/passwd")
        assert not is_safe_url("ftp://example.com/file")
        assert not is_safe_url("gopher://example.com")

    def test_allows_public_urls(self):
        assert is_safe_url("https://example.com/article")
        assert is_safe_url("https://www.nature.com/articles/d41586-024-00001-w")


class TestSourceTypeDetection:
    def test_detects_pmcid(self):
        assert detect_source_type("PMC13417782") == "pmc"
        assert detect_source_type("pmc9999999") == "pmc"

    def test_detects_url(self):
        assert detect_source_type("https://en.wikipedia.org/wiki/Ecology") == "url"
        assert detect_source_type("http://example.org/study.html") == "url"

    def test_detects_html(self):
        assert detect_source_type("<!DOCTYPE html><html><body>Article</body></html>") == "html"
        assert detect_source_type("<article><p>First paragraph</p></article>") == "html"

    def test_detects_markdown(self):
        assert detect_source_type("# Title\n\nSome [link](url) and **bold** text") == "markdown"

    def test_detects_plain_text(self):
        assert detect_source_type("Just a simple plain text article with multiple words.") == "text"


@pytest.mark.asyncio
class TestIngestSource:
    async def test_ingest_plain_text_success(self):
        text = "Deep Ocean Trench Ecology\n\n" + make_words(700, "deep-sea ecology")
        result = await ingest_source(payload=text, source_type="text")
        assert result["sourceType"] == "text"
        assert result["title"] == "Deep Ocean Trench Ecology"
        assert result["wordCount"] >= 700
        assert "Deep Ocean Trench Ecology" in result["content"]
        assert result["sourceId"].startswith("TXT_")
        assert result["pmcid"].startswith("TXT_")

    async def test_ingest_plain_text_too_short_raises_error(self):
        short_text = "Short Title\n\nOnly a few words here."
        with pytest.raises(SourceError, match="Source content is too short"):
            await ingest_source(payload=short_text, source_type="text")

    async def test_ingest_html_success(self):
        html_content = f"""
        <html>
        <head><title>Urban Green Spaces</title><meta name="author" content="Dr. Sarah Chen"></head>
        <body>
            <header><h1>Urban Green Spaces</h1></header>
            <p>{make_words(650, 'urban architecture and parks')}</p>
        </body>
        </html>
        """
        result = await ingest_source(payload=html_content, source_type="html")
        assert result["sourceType"] == "html"
        assert result["title"] == "Urban Green Spaces"
        assert result["authors"] == "Dr. Sarah Chen"
        assert result["wordCount"] >= 650
        assert result["sourceId"].startswith("HTML_")

    async def test_ingest_markdown_success(self):
        md_content = f"""# Artificial Intelligence in Medicine\n\n{make_words(680, 'medical diagnosis')}\n"""
        result = await ingest_source(payload=md_content, source_type="markdown")
        assert result["sourceType"] == "markdown"
        assert result["title"] == "Artificial Intelligence in Medicine"
        assert result["wordCount"] >= 680
        assert result["sourceId"].startswith("MD_")

    async def test_ingest_url_blocks_ssrf(self):
        with pytest.raises(SourceError, match="restricted, private, or invalid"):
            await ingest_source(payload="http://127.0.0.1:8080/secret", source_type="url")

    async def test_ingest_url_mocked_fetch(self):
        html_payload = f"""
        <html><head><title>Renewable Energy</title></head>
        <body><p>{make_words(620, 'wind turbines')}</p></body></html>
        """
        mock_response = httpx.Response(
            status_code=200,
            headers={"content-type": "text/html; charset=utf-8"},
            text=html_payload,
            request=httpx.Request("GET", "https://example.org/article"),
        )
        with patch("httpx.AsyncClient.get", new_callable=AsyncMock, return_value=mock_response), \
             patch("app.services.reading_paper.is_safe_url", return_value=True):
            result = await ingest_source(payload="https://example.org/article", source_type="url")
            assert result["sourceType"] == "url"
            assert result["title"] == "Renewable Energy"
            assert result["wordCount"] >= 620
            assert result["url"] == "https://example.org/article"
            assert result["sourceId"].startswith("URL_")


@pytest.mark.asyncio
class TestIngestRouterEndpoint:
    async def test_ingest_endpoint_valid_text(self):
        text = "Linguistic Relativity Hypothesis\n\n" + make_words(650, "linguistics")
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/reading-paper/source/ingest",
                json={"payload": text, "type": "text", "title": "Custom Title"},
            )
            assert resp.status_code == 200
            data = resp.json()
            assert data["title"] == "Custom Title"
            assert data["wordCount"] >= 650
            assert data["sourceType"] == "text"

    async def test_ingest_endpoint_too_short_returns_422(self):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/reading-paper/source/ingest",
                json={"payload": "Too short content", "type": "text"},
            )
            assert resp.status_code == 422
            assert "too short" in resp.json()["detail"].lower()

    async def test_ingest_endpoint_ssrf_returns_422(self):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/reading-paper/source/ingest",
                json={"payload": "http://127.0.0.1/private", "type": "url"},
            )
            assert resp.status_code == 422
            assert "restricted" in resp.json()["detail"].lower()


@pytest.mark.asyncio
class TestGenerateSectionWithUniversalSource:
    async def test_generate_section_accepts_pre_ingested_content(self):
        """Pre-ingested sources must bypass fetch_source and generate sections directly."""
        pre_ingested_source = {
            "sourceId": "TXT_custom123",
            "sourceType": "text",
            "title": "Quantum Computing Fundamentals",
            "authors": "Dr. Alice Smith",
            "license": "User Provided",
            "content": "Quantum Computing Fundamentals\n\n" + make_words(700, "quantum physics"),
        }

        from tests.test_reading_paper import valid_section
        generated = valid_section(1)
        reviews = {
            number: {"number": number, "valid": True, "issues": [], "reason": ""}
            for group in generated["groups"]
            for q in group["questions"]
            for number in [q["number"]]
        }

        with patch("app.services.reading_paper.fetch_source") as mock_fetch, \
             patch("app.services.reading_paper.review_passage_source", new_callable=AsyncMock, return_value=[]), \
             patch("app.services.reading_paper.review_answers", new_callable=AsyncMock, return_value=reviews), \
             patch("app.services.reading_paper.generate_json", new_callable=AsyncMock) as mock_gen, \
             patch("app.services.reading_paper.validate_section") as mock_val:

            mock_gen.side_effect = [
                {"text": f"{generated['title']}\n\n{generated['passage']}"},
                *[{"questions": group["questions"]} for group in generated["groups"]],
            ]
            mock_val.side_effect = lambda s, idx: s

            result = await generate_section(
                topic="Quantum Computing",
                index=1,
                source=pre_ingested_source,
            )

            # fetch_source should NOT be called because content was already present
            mock_fetch.assert_not_called()
            assert result["title"] == generated["title"]
            assert result["source"]["pmcid"] == "TXT_custom123"
            assert result["source"]["license"] == "User Provided"
