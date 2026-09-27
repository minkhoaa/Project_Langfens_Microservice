# Universal Source Ingestion Specification for IELTS Reading Paper Generation

## 1. Executive Summary & Objectives

The IELTS Academic Reading paper generation system currently relies exclusively on Europe PMC academic articles via PMCID lookup. To support realistic, diverse, and practical test generation workflows, this specification defines the **Universal Source Ingestion Architecture** supporting all source modalities:
- **Raw plain text** (pasted articles, essays, reports, book excerpts)
- **Raw HTML / Web documents** (rich text, scraped articles, CMS content)
- **Markdown documents** (structured markdown with headers, lists, and tables)
- **Direct Web URLs** (HTTP/HTTPS article fetching with automated boilerplate removal and metadata extraction)
- **Academic JATS XML** (Europe PMC with CC licensing, preserving existing academic workflows)

### Key Requirements
1. **Format Agnostic**: An admin or educator can paste plain text, input HTML, provide a Web URL, or select an academic paper. The downstream generation pipeline (passage rewriting, question generation, answer verification) operates identically on the sanitized source.
2. **Robust Content Sanitization**: Strips scripts, styles, navigational elements, advertisements, cookie notices, and boilerplates, producing high-fidelity semantic text.
3. **IELTS Compatibility**: Ensures every source satisfies IELTS Academic Reading criteria: length (≥ 600 words), vocabulary density, factual coherence, and clear topic orientation.
4. **Security & Safety**: Enforces strict URL validation (preventing SSRF, blocking loopback/internal RFC 1918 IPs), size limits (max 5 MB raw input, max 100,000 characters sanitized), and sanitizes HTML against injection.
5. **Zero-Breaking-Change Backward Compatibility**: Existing PMCID workflows (`PMC...`) remain 100% functional without requiring database migration or frontend breaking changes.

---

## 2. Source Types Taxonomy

| Source Type | Identifier / Input | Ingestion Strategy | Metadata Extracted |
|---|---|---|---|
| `ACADEMIC_PMC` | `PMC\d+` (e.g., `PMC13417782`) | REST call to Europe PMC `fullTextXML`, JATS XML parser. | Title, Authors, DOI, URL, CC License, Word Count. |
| `WEB_URL` | Valid `http://` or `https://` URL | Async HTTP GET with browser headers, Follow-Redirects (max 5), DOM parsing, boilerplate removal, Readability heuristics. | Page Title, Meta Author/Byline, Canonical URL, Domain, Word Count. |
| `HTML` | Raw HTML string (`<!DOCTYPE`, `<html>`, or tags) | BeautifulSoup/HTML parser stripping non-content tags (`<script>`, `<style>`, `<nav>`, `<header>`, `<footer>`, `<aside>`, `<svg>`, ads), preserving semantic paragraphs and headings. | Document Title (`<title>` or first `<h1>`), Word Count. |
| `MARKDOWN` | Raw Markdown string | Markdown normalization: strips frontmatter (`---...---`), converts links `[text](url)` to `text`, strips image markup, extracts headings and paragraphs. | First Heading 1/2 as Title, Word Count. |
| `RAW_TEXT` | Plain UTF-8 text string | Whitespace normalization, paragraph reconstruction (detecting double newlines or indentation), word count validation. | First non-empty line or auto-generated Title, Word Count. |

---

## 3. Ingestion & Sanitization Pipeline

```
  [Raw Input: PMC / URL / HTML / Markdown / Text]
                        │
                        ▼
            ┌──────────────────────┐
            │   Type Detection     │  Auto-detect or explicit sourceType
            └──────────┬───────────┘
                       │
       ┌───────────────┼───────────────┬───────────────┐
       ▼               ▼               ▼               ▼
  [Europe PMC]     [Web URL]        [HTML]       [Text/Markdown]
   JATS XML        HTTP Fetch     Tag Cleaner     Normalizer
       │               │               │               │
       └───────────────┼───────────────┴───────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Boilerplate Removal │  Strip nav, ads, scripts, footers, notices
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Text Normalization   │  Unicode NFKC, clean whitespace, paragraphs
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Quality & Gate Check │  Word count ≥ 600, English check, density
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Unified Source DTO   │  Passed to Passage Generator & Reviewer
            └──────────────────────┘
```

### 3.1 Content Extraction Rules

1. **HTML & Web Content Cleaning**:
   - Decompose / remove non-content tags: `script`, `style`, `noscript`, `iframe`, `nav`, `header`, `footer`, `aside`, `form`, `svg`, `button`, `canvas`, `figure`, `figcaption`.
   - Remove elements matching common advertisement/boilerplate selectors (`.ad`, `.advertisement`, `#cookie-notice`, `.sidebar`, `.social-share`, `.comments`).
   - Extract semantic paragraphs: convert `<h1>`-`<h6>`, `<p>`, `<li>`, `<blockquote>` to text separated by double newlines (`\n\n`).
   - Replace `<br>` and `<hr>` with newlines.
   - Decode HTML entities (`&nbsp;` $\rightarrow$ space, `&amp;` $\rightarrow$ `&`, etc.).

2. **Web URL Security & SSRF Protection**:
   - Scheme must be `http` or `https`.
   - Host must resolve to a public IP. Disallow `localhost`, `127.0.0.1`, `::1`, `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `169.254.0.0/16` (link-local/cloud metadata service).
   - Maximum response body size: 5 MB.
   - Read timeout: 30 seconds, connect timeout: 10 seconds.

3. **Text Normalization**:
   - Normalize Unicode to NFKC.
   - Replace carriage returns (`\r\n` $\rightarrow$ `\n`).
   - Collapse 3+ consecutive newlines to double newline (`\n\n`).
   - Replace non-breaking spaces and tabs with standard space.
   - Trim leading/trailing whitespace.

4. **Quality Gates**:
   - **Minimum Word Count**: Source must contain at least 600 words (`len(re.findall(r"\b[\w'-]+\b", content)) >= 600`).
   - **Maximum Content Length**: Capped at 70,000 characters for LLM prompt safety.
   - **Title Extraction**: Automatically extracted from `<title>`, `<h1>`, or the first non-empty line (capped at 180 characters).

---

## 4. Unified Data Contracts

### 4.1 Schema Definition (`ReadingSource`)

```json
{
  "sourceType": "pmc | url | html | text | markdown",
  "sourceId": "string (PMC ID, URL, or generated UUID/hash)",
  "title": "string (article or passage title, 3–180 chars)",
  "url": "string (Europe PMC URL, original web URL, or custom reference)",
  "authors": "string or null (author attribution or domain)",
  "doi": "string or null",
  "license": "string (e.g. 'CC BY 4.0', 'Web Public', 'User Provided')",
  "wordCount": 1250,
  "content": "string (cleaned semantic text, up to 70,000 chars)",
  "metadata": {
    "domain": "example.com",
    "description": "optional summary",
    "format": "html"
  }
}
```

### 4.2 Compatibility Mapping with Existing `.NET` Models
In `exam-service`:
`ReadingSource(string Pmcid, string Title, string? Doi, string Url, string License, int WordCount, string? Authors, string? OpenAlexId, string? TopicId)`
- For non-PMC sources:
  - `Pmcid` stores the source identifier: `CUSTOM:<hash>` or `URL:<domain-slug>` (satisfying unique tracking and string requirements).
  - `License` defaults to `"User Provided"` or `"Web Open Source"`.
  - `Url` points to the origin URL or placeholder `"local://manual-source"`.

---

## 5. API Endpoints Contract

### 5.1 POST `/api/v1/autogen/reading-paper/source/ingest`
Ingests any source from raw payload and returns validated metadata:
```json
// Request Body
{
  "type": "auto | pmc | url | html | text | markdown",
  "payload": "string (URL, raw text, HTML content, or PMCID)",
  "title": "optional custom title override"
}

// Response Body (200 OK)
{
  "sourceType": "html",
  "sourceId": "custom_a1b2c3d4",
  "title": "A Cognitive-Affective Dual-Path Model of Learner Engagement",
  "url": "https://example.org/article",
  "authors": "Jane Doe et al.",
  "license": "Web Public",
  "wordCount": 1420,
  "contentPreview": "Artificial intelligence tools in academic writing..."
}
```

### 5.2 POST `/api/v1/autogen/reading-paper/section`
Updated to accept either a `pmcid` reference or an inline pre-ingested `source` dictionary containing the cleaned `content`.

---

## 6. Verification & Test Plan

1. **Unit Tests (`test_reading_paper_universal_sources.py`)**:
   - Parsing valid HTML with nested tags, scripts, navigation, and ads $\rightarrow$ clean semantic paragraphs and extracted title.
   - Parsing raw plain text and multi-paragraph essays.
   - Parsing markdown text with headers, bullet points, blockquotes, and stripped link markup.
   - Handling web URL fetching with mocked HTTP responses and error conditions (404, 500, timeouts).
   - Security validation: blocking loopback IPs (`127.0.0.1`, `169.254.169.254`, `localhost`).
   - Word count validation: rejecting sources with < 600 words.
2. **Integration Verification**:
   - Feeding a raw text source into `generate_section` end-to-end to generate an IELTS Reading Section with 2 groups and 13 questions.
   - Feeding an HTML article into `generate_section` to ensure `review_passage_source` verifies claims accurately against extracted HTML text.
