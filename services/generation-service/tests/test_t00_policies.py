"""T00-03: Replay source and policy boundary fixtures (Python generation-service).

Validates:
- 599 vs 600 words boundary
- SSRF protection on loopback/private IPs
- XML CC-BY/CC0 license enforcement
- Section passage 720-915 words boundaries
- All 6 question types from questions_corpus.json (valid vs invalid)
"""
from __future__ import annotations

import json
from pathlib import Path
import pytest

from app.extractor import (
    SourceError,
    clean_html,
    detect_source_type,
    ingest_source,
    is_safe_url,
    parse_full_text,
)
from app.pipeline import (
    _answer_occurs_in_passage,
    _answer_within_ielts_limit,
    _words,
    validate_group_candidate,
    validate_section,
)
from tests.test_pipeline import xml_with_license
from tests.offline_support.dns_fixtures import public_dns

# Anchor fixture paths to the repository root. A bare relative path resolves against
# the pytest working directory (services/generation-service), so the corpus lookup
# reported "Missing questions_corpus.json" for a fixture that is committed.
FIXTURES_DIR = Path(__file__).resolve().parent / "fixtures" / "policies"


def test_t00_03_source_word_count_boundary():
    """Verify 599 words rejected, 600 words accepted."""
    xml_599 = xml_with_license("https://creativecommons.org/licenses/by/4.0/", words=599)
    with pytest.raises(SourceError, match="Full text is too short"):
        parse_full_text(xml_599, "PMC8910001")

    xml_600 = xml_with_license("https://creativecommons.org/licenses/by/4.0/", words=600)
    parsed = parse_full_text(xml_600, "PMC8910001")
    assert parsed["wordCount"] == 600


def test_t00_03_ssrf_safety_boundary(public_dns):
    """Verify SSRF filters deny private/loopback/metadata endpoints and allow public domains."""
    denied = [
        "http://127.0.0.1:8080/secret",
        "http://localhost/admin",
        "http://10.0.0.1/status",
        "http://192.168.1.1/router",
        "http://172.16.0.1/api",
        "http://169.254.169.254/latest/meta-data/",
        "ftp://example.com/file",
        "file:///etc/passwd",
    ]
    for url in denied:
        assert not is_safe_url(url), f"Expected {url} to be blocked by is_safe_url"

    allowed = [
        "https://www.nature.com/articles/sample",
        "https://europepmc.org/articles/PMC8910001",
        "https://example.org/study",
    ]
    for url in allowed:
        assert is_safe_url(url), f"Expected {url} to be allowed by is_safe_url"


def test_t00_03_license_boundary():
    """Verify CC-BY and CC0 pass, while proprietary licenses fail."""
    cc_by = xml_with_license("https://creativecommons.org/licenses/by/4.0/")
    assert parse_full_text(cc_by, "PMC1")["license"].startswith("https://creativecommons.org/licenses/by/4.0")

    cc0 = xml_with_license("https://creativecommons.org/publicdomain/zero/1.0/")
    assert parse_full_text(cc0, "PMC2")["license"].startswith("https://creativecommons.org/publicdomain/zero/1.0")

    proprietary = xml_with_license("https://all-rights-reserved.com/license")
    with pytest.raises(SourceError, match="No verified CC BY or CC0 license"):
        parse_full_text(proprietary, "PMC3")


def test_t00_03_passage_length_boundaries():
    """Verify 719 rejected, 720-915 accepted, 916 rejected."""
    base = "Scientists found species in the forest and measured changes over time. "
    from tests.test_pipeline import valid_section

    # 719 words
    sec_719 = valid_section(1)
    words_needed = 719
    sec_719["passage"] = (base * (words_needed // _words(base) + 1))
    while _words(sec_719["passage"]) > 719:
        sec_719["passage"] = " ".join(sec_719["passage"].split()[:-1])
    assert _words(sec_719["passage"]) == 719
    with pytest.raises(ValueError, match="Passage must contain 720–915 words"):
        validate_section(sec_719, 1)

    # 720 words
    sec_720 = valid_section(1)
    sec_720["passage"] = sec_719["passage"] + " extraWord"
    assert _words(sec_720["passage"]) == 720
    # To pass question evidence checks, ensure evidence matches
    assert validate_section(sec_720, 1)["passage"] == sec_720["passage"]

    # 915 words
    sec_915 = valid_section(1)
    while _words(sec_915["passage"]) < 915:
        sec_915["passage"] += " word"
    while _words(sec_915["passage"]) > 915:
        sec_915["passage"] = " ".join(sec_915["passage"].split()[:-1])
    assert _words(sec_915["passage"]) == 915
    assert validate_section(sec_915, 1)["passage"] == sec_915["passage"]

    # 916 words
    sec_916 = valid_section(1)
    sec_916["passage"] = sec_915["passage"] + " extra"
    assert _words(sec_916["passage"]) == 916
    with pytest.raises(ValueError, match="Passage must contain 720–915 words"):
        validate_section(sec_916, 1)


def test_t00_03_questions_corpus_all_six_types():
    """Replay questions corpus for all 6 types and verify pass/fail fidelity."""
    corpus_path = FIXTURES_DIR / "questions_corpus.json"
    assert corpus_path.exists(), "Missing questions_corpus.json fixture"
    corpus = json.loads(corpus_path.read_text(encoding="utf-8"))
    passage = corpus["passage"]

    for type_name, items in corpus["types"].items():
        valid_items = items["valid"]
        invalid_items = items["invalid"]

        # Validate valid items
        # Group them into a group candidate
        first_num = valid_items[0]["number"]
        validate_group_candidate(type_name, len(valid_items), first_num, valid_items, passage)

        # Validate invalid items individually or as broken groups
        for invalid_item in invalid_items:
            single_list = [invalid_item]
            with pytest.raises(ValueError):
                validate_group_candidate(type_name, 1, invalid_item["number"], single_list, passage)
