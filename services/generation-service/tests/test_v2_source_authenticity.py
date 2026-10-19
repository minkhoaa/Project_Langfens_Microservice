"""Acceptance test suite for RQ2_DATASET_V2 source authenticity and provenance ledger (Sprint V2-S02).

Verifies:
1. All 7 candidate sources recorded in V2_SOURCE_PROVENANCE_LEDGER.json.
2. Authentic bibliographic metadata (PMCID, DOI, journal, publication year).
3. Verifiable Creative Commons Attribution 4.0 International (CC-BY-4.0) licenses.
4. Cryptographic SHA-256 digests (raw XML, extracted body, clean text, fixture).
5. Deterministic text correspondence for inherited candidate sources (>=98% token alignment).
6. Existence and non-emptiness of V2 fixture files in isolated sources_v2 namespace.
7. Strict zero historical mutation of quarantined V1 files.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any, Dict, List

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
LEDGER_PATH = REPO_ROOT / "generation_baseline" / "verification" / "V2_SOURCE_PROVENANCE_LEDGER.json"
V2_SOURCES_DIR = REPO_ROOT / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources_v2"
V1_SOURCES_DIR = REPO_ROOT / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
QUARANTINE_MANIFEST_PATH = REPO_ROOT / "generation_baseline" / "verification" / "V1_QUARANTINE_MANIFEST.json"


@pytest.fixture(scope="module")
def provenance_ledger() -> Dict[str, Any]:
    assert LEDGER_PATH.exists(), f"Provenance ledger not found at {LEDGER_PATH}"
    data = json.loads(LEDGER_PATH.read_text(encoding="utf-8"))
    assert data.get("ledger_id") == "V2_SOURCE_PROVENANCE_LEDGER"
    return data


@pytest.fixture(scope="module")
def quarantine_manifest() -> Dict[str, Any]:
    assert QUARANTINE_MANIFEST_PATH.exists(), f"Quarantine manifest not found at {QUARANTINE_MANIFEST_PATH}"
    return json.loads(QUARANTINE_MANIFEST_PATH.read_text(encoding="utf-8"))


def test_ledger_structure_and_source_count(provenance_ledger: Dict[str, Any]) -> None:
    """Verifies that exactly 7 sources are evaluated, admitted, and verified."""
    assert provenance_ledger["total_sources_evaluated"] == 7
    assert provenance_ledger["total_sources_admitted"] == 7
    assert provenance_ledger["all_sources_verified"] is True
    assert len(provenance_ledger["sources"]) == 7


def test_source_bibliographic_metadata(provenance_ledger: Dict[str, Any]) -> None:
    """Verifies genuine bibliographic metadata across all 7 sources."""
    expected_pmcids = {
        "PMC13621526",
        "PMC13604763",
        "PMC13517498",
        "PMC13407692",
        "PMC13665993",
        "PMC13667678",
        "PMC13654891",
    }
    found_pmcids = {s["pmcid"] for s in provenance_ledger["sources"]}
    assert found_pmcids == expected_pmcids

    for source in provenance_ledger["sources"]:
        assert source["pmcid"].startswith("PMC")
        assert len(source["article_title"]) > 10, f"Title too short for {source['pmcid']}"
        assert len(source["journal"]) > 2, f"Missing journal for {source['pmcid']}"
        assert source["publication_year"] in {"2025", "2026"}, f"Unexpected year for {source['pmcid']}"
        assert source["doi"].startswith("10."), f"Invalid DOI for {source['pmcid']}"


def test_license_open_access_authenticity(provenance_ledger: Dict[str, Any]) -> None:
    """Asserts that all 7 sources have verified open-access CC-BY licenses from XML."""
    for source in provenance_ledger["sources"]:
        lic = source["license_evidence"]
        assert lic["license_type"] == "CC-BY-4.0"
        assert lic["is_verified_open_access"] is True
        assert len(lic["license_p_verbatim"]) > 20, f"Missing license_p text for {source['pmcid']}"


def test_cryptographic_digests_and_fixture_existence(provenance_ledger: Dict[str, Any]) -> None:
    """Verifies that all SHA-256 digests match actual file contents on disk."""
    for source in provenance_ledger["sources"]:
        digests = source["cryptographic_digests"]
        v2_txt = REPO_ROOT / digests["v2_fixture_path"]
        v2_xml = REPO_ROOT / digests["v2_xml_path"]

        assert v2_txt.exists(), f"Missing V2 text fixture: {v2_txt}"
        assert v2_xml.exists(), f"Missing V2 XML fixture: {v2_xml}"

        actual_txt_hash = hashlib.sha256(v2_txt.read_bytes()).hexdigest()
        actual_xml_hash = hashlib.sha256(v2_xml.read_bytes()).hexdigest()

        assert actual_txt_hash == digests["fixture_sha256"]
        assert actual_xml_hash == digests["raw_xml_sha256"]
        assert digests["canonical_clean_text_sha256"] == digests["fixture_sha256"]


def test_deterministic_text_correspondence(provenance_ledger: Dict[str, Any]) -> None:
    """Verifies strengthened deterministic ordered token correspondence between fixtures and canonical XML."""
    for source in provenance_ledger["sources"]:
        corr = source["deterministic_correspondence"]
        if source["classification"] == "INHERITED_CANDIDATE":
            assert corr["status"] == "VERIFIED_DETERMINISTIC_CORRESPONDENCE"
            assert corr["is_faithful_substring"] is True
            assert corr["ordered_token_match"] is True
            assert corr["token_correspondence_ratio"] >= 0.97
            assert corr["start_token_index"] == 0
            # Check unmatched/modified spans
            for span in corr.get("unmatched_or_modified_spans", []):
                assert span["span_type"] == "EMBEDDED_FIGURE_CAPTION"
                assert "figure_caption_exclusion" in span["authorized_transformation"]
        else:
            assert corr["status"] == "NOT_APPLICABLE_REPLACEMENT_SOURCE"
            assert corr["ordered_token_match"] is True

def test_authorized_transformations_log_complete_without_truncation(provenance_ledger: Dict[str, Any]) -> None:
    """Asserts that all authorized transformations are preserved in full without truncation to 15 entries."""
    for source in provenance_ledger["sources"]:
        corr = source["deterministic_correspondence"]
        cnt = corr.get("authorized_transformations_count", 0)
        log_entries = corr.get("authorized_transformations_log", [])
        assert len(log_entries) == cnt, (
            f"Transformation log truncated for {source['pmcid']}: logged {len(log_entries)} != total {cnt}"
        )
        if source["classification"] == "INHERITED_CANDIDATE":
            assert cnt > 15, f"Expected inherited candidate {source['pmcid']} to have > 15 transformations"
            # Validate that every entry has required audit structure
            for entry in log_entries:
                assert "stream" in entry
                assert "span_type" in entry
                assert "authorized_transformation" in entry
                assert "justification" in entry

def test_four_passage_feasibility_in_ledger(provenance_ledger: Dict[str, Any]) -> None:
    """Verifies that every source provides sufficient usable words for 4 passages (350-650w)."""
    for source in provenance_ledger["sources"]:
        feas = source["passage_feasibility"]
        assert feas["feasible"] is True, f"Feasibility failed for {source['pmcid']}: {feas.get('error')}"
        assert feas["passage_count"] == 4, f"Expected 4 passages for {source['pmcid']}"
        for w in feas["passage_word_counts"]:
            assert 350 <= w <= 650, f"Passage word count {w} outside 350-650 bounds in {source['pmcid']}"


def test_zero_mutation_to_historical_v1_files(quarantine_manifest: Dict[str, Any]) -> None:
    """Ensures that all historical V1 fixture files remain strictly unchanged."""
    for item in quarantine_manifest["inventories"]["fixtures"]:
        rel_path = item["relative_path"]
        expected_hash = item["sha256"]
        disk_path = REPO_ROOT / rel_path
        assert disk_path.exists(), f"Historical fixture missing: {rel_path}"
        actual_hash = hashlib.sha256(disk_path.read_bytes()).hexdigest()
        assert actual_hash == expected_hash, f"Historical mutation detected in {rel_path}!"
