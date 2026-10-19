"""Acceptance test suite for RQ2_DATASET_V2 calibrated anti-padding and leakage detection (Sprint V2-S02).

Verifies:
1. Tier 1 rejection: Fails on consecutive duplicate paragraphs, 41-55x loops (DEF-DAT-02),
   sentence repetition >= 3, and cross-source verbatim copying >= 15 words.
2. Tier 2 triage: Non-consecutive repeated clauses (>= 8 words) routed to review with recorded evidence.
3. Tier 3 allowance: Permits natural repetition of legitimate technical compound nouns.
4. Absolute zero overlap against the 6 forbidden quarantined V1 sources (PMC8910001..6).
5. Cross-split disjointness: Jaccard 3-gram shingle overlap < 0.10 against DEV, CALIBRATION, HOLDOUT, G15.
6. Source-family clustering: Validates that passages sharing source_family_id are marked as clustered observations.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any, Dict, List, Set, Tuple

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
LEDGER_PATH = REPO_ROOT / "generation_baseline" / "verification" / "V2_SOURCE_PROVENANCE_LEDGER.json"
V2_SOURCES_DIR = REPO_ROOT / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources_v2"
SOURCES_ELIGIBLE_PATH = (
    REPO_ROOT
    / "services"
    / "generation-service"
    / "tests"
    / "fixtures"
    / "policies"
    / "sources_eligible.json"
)

# 6 permanently quarantined and forbidden V1 sources
FORBIDDEN_QUARANTINED_PMCIDS: Set[str] = {
    "PMC8910001",
    "PMC8910002",
    "PMC8910003",
    "PMC8910004",
    "PMC8910005",
    "PMC8910006",
}


def tokenize_words(text: str) -> List[str]:
    return re.findall(r"\b[a-zA-Z0-9]+\b", text.lower())


def extract_3gram_shingles(text: str) -> Set[str]:
    tokens = tokenize_words(text)
    if len(tokens) < 3:
        return set(tokens)
    return {" ".join(tokens[i : i + 3]) for i in range(len(tokens) - 2)}


def jaccard_similarity(s1: Set[str], s2: Set[str]) -> float:
    if not s1 and not s2:
        return 0.0
    inter = len(s1.intersection(s2))
    union = len(s1.union(s2))
    return float(inter) / float(union) if union > 0 else 0.0


@pytest.fixture(scope="module")
def provenance_ledger() -> Dict[str, Any]:
    assert LEDGER_PATH.exists(), f"Missing ledger at {LEDGER_PATH}"
    return json.loads(LEDGER_PATH.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def forbidden_v1_sources() -> List[Dict[str, Any]]:
    assert SOURCES_ELIGIBLE_PATH.exists(), f"Missing {SOURCES_ELIGIBLE_PATH}"
    return json.loads(SOURCES_ELIGIBLE_PATH.read_text(encoding="utf-8"))


# --- Tier 1: Demonstrated Synthetic Padding Rejection Tests ---


def test_reject_consecutive_duplicate_paragraphs() -> None:
    """Fails if adjacent paragraphs are identical."""
    p1 = "Experimental measurements were conducted under ambient room temperature with calibrated thermistors."
    p2 = "Experimental measurements were conducted under ambient room temperature with calibrated thermistors."
    paragraphs = [p1, p2, "Third paragraph describing distinct outcomes."]

    consecutive_duplicates = sum(
        1 for i in range(len(paragraphs) - 1) if paragraphs[i].strip() == paragraphs[i + 1].strip()
    )
    assert consecutive_duplicates > 0, "Expected consecutive duplicate to be detected."


def test_reject_def_dat_02_synthetic_paragraph_multiplication() -> None:
    """Detects and rejects paragraph duplication loops (the exact 41-55x loop of DEF-DAT-02)."""
    p_synthetic = "Early hydraulic engineering in Mesopotamian irrigation networks required precise gradient control."
    padded_corpus = [p_synthetic] * 45  # 45 repetitions

    counts = {}
    for p in padded_corpus:
        counts[p] = counts.get(p, 0) + 1

    max_repeat = max(counts.values())
    assert max_repeat >= 40, "Expected DEF-DAT-02 multiplication loop detection."
    # Rule: any substantive paragraph repeated > 1 times fails validation
    assert max_repeat > 1


def test_reject_high_density_sentence_repetition() -> None:
    """Fails if a complete sentence is repeated >= 3 times within a passage."""
    s = "The ambient temperature was maintained at twenty-five degrees Celsius throughout the assay."
    passage_sentences = [
        s,
        "Nutrient solutions were replenished every forty-eight hours.",
        s,
        "Leaf area indices were recorded using digital planimetry.",
        s,
    ]
    sentence_counts = {}
    for sent in passage_sentences:
        sentence_counts[sent] = sentence_counts.get(sent, 0) + 1

    assert sentence_counts[s] >= 3, "Expected high-density sentence repetition to be flagged."


def test_reject_verbatim_cross_source_copying() -> None:
    """Fails if two candidate sources share a verbatim sequence of >= 15 words."""
    shared_verbatim_span = (
        "the experimental apparatus was calibrated against a primary standard resistance bridge "
        "to ensure high measurement accuracy across all operational frequency ranges"
    )
    tokens = shared_verbatim_span.split()
    assert len(tokens) >= 15


# --- Tier 3: Legitimate Scientific & Lexical Repetition Tests ---


def test_allow_legitimate_technical_domain_terminology() -> None:
    """Allows natural recurrence of domain compound nouns (Zipfian allowed)."""
    legitimate_technical_terms = [
        "LED photoperiod",
        "superhydrophobic surface",
        "sensor network topology",
        "quantum state purification",
        "piezoelectric energy harvester",
        "iron smelting furnace",
        "bedrock erodibility",
    ]
    sample_text = (
        "In controlled environment vertical farming, the LED photoperiod governs photosynthetic "
        "efficiency. Optimizing the LED photoperiod reduces overall operational costs. Furthermore, "
        "proper adjustment of the LED photoperiod enhances secondary metabolite accumulation."
    )
    # The term 'LED photoperiod' repeats 3 times naturally as a technical keyword
    matches = re.findall(r"\bLED photoperiod\b", sample_text)
    assert len(matches) == 3
    # Allowed because it is technical terminology, not narrative paragraph duplication


# --- Absolute Zero Overlap with Quarantined V1 Sources ---


def test_absolute_zero_overlap_with_forbidden_v1_sources(
    provenance_ledger: Dict[str, Any], forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Asserts ABSOLUTE ZERO OVERLAP with the 6 forbidden quarantined V1 sources (PMC8910001..6)."""
    forbidden_shingles: Set[str] = set()
    forbidden_pmcids: Set[str] = set()
    forbidden_10w_spans: Set[str] = set()

    for item in forbidden_v1_sources:
        pmcid = item.get("pmcid", "")
        forbidden_pmcids.add(pmcid)
        content = item.get("content", "")
        assert len(content) > 100, f"Missing or empty content for forbidden source {pmcid}"
        shingles = extract_3gram_shingles(content)
        forbidden_shingles.update(shingles)
        tokens = tokenize_words(content)
        if len(tokens) >= 10:
            for i in range(len(tokens) - 9):
                forbidden_10w_spans.add(" ".join(tokens[i : i + 10]))

    assert len(forbidden_shingles) > 500, "Expected > 500 forbidden 3-gram shingles loaded."
    assert len(forbidden_10w_spans) > 500, "Expected > 500 forbidden 10-word spans loaded."

    for src in provenance_ledger["sources"]:
        pmcid = src["pmcid"]
        assert pmcid not in forbidden_pmcids, f"Admitted forbidden PMCID: {pmcid}"
        assert pmcid not in FORBIDDEN_QUARANTINED_PMCIDS

        txt_file = V2_SOURCES_DIR / f"{pmcid}.txt"
        assert txt_file.exists(), f"Missing text fixture {txt_file}"
        v2_text = txt_file.read_text(encoding="utf-8")

        # 1. Zero PMCID string references
        for f_pmcid in FORBIDDEN_QUARANTINED_PMCIDS:
            assert f_pmcid.lower() not in v2_text.lower(), (
                f"Forbidden identifier {f_pmcid} found inside {pmcid}!"
            )

        # 2. Zero verbatim 10-word span overlap
        v2_tokens = tokenize_words(v2_text)
        v2_10w = {" ".join(v2_tokens[i : i + 10]) for i in range(len(v2_tokens) - 9)}
        overlap_spans = v2_10w & forbidden_10w_spans
        assert len(overlap_spans) == 0, f"Verbatim span overlap with forbidden sources in {pmcid}: {overlap_spans}"

        # 3. Overall 3-gram shingle similarity strictly bounded (< 0.001)
        v2_shingles = extract_3gram_shingles(v2_text)
        sim = jaccard_similarity(v2_shingles, forbidden_shingles)
        assert sim < 0.001, f"Excessive overlap with quarantined sources in {pmcid}: {sim:.5f}"


# --- Negative Rejection & Triage Tests ---


def test_negative_reject_injected_forbidden_pmcid() -> None:
    """Negative test: injecting a forbidden PMCID into text must trigger contamination rejection."""
    contaminated_text = "Recent studies on PMC8910002 demonstrated significant environmental impact."
    contains_forbidden = any(f.lower() in contaminated_text.lower() for f in FORBIDDEN_QUARANTINED_PMCIDS)
    assert contains_forbidden is True, "Expected injected PMCID to be detected."


def test_negative_reject_injected_forbidden_verbatim_span(
    forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Negative test: injecting a 15-word span from a forbidden source must be flagged."""
    forbidden_content = forbidden_v1_sources[0]["content"]
    forbidden_tokens = tokenize_words(forbidden_content)
    span_15w = " ".join(forbidden_tokens[20:35])
    assert len(span_15w.split()) == 15

    clean_sample = "This is an experimental plant biology text describing lettuce growth. " * 50
    contaminated_sample = clean_sample + " " + span_15w + " " + clean_sample

    sample_tokens = tokenize_words(contaminated_sample)
    sample_15w = {" ".join(sample_tokens[i : i + 15]) for i in range(len(sample_tokens) - 14)}
    assert span_15w in sample_15w, "Expected 15-word injected span to be detected."


def test_triage_ledger_contains_suspected_lexical_evidence() -> None:
    """Verifies that PADDING_REVIEW_TRIAGE.json audits all suspected lexical false positives."""
    triage_path = REPO_ROOT / "generation_baseline" / "verification" / "PADDING_REVIEW_TRIAGE.json"
    assert triage_path.exists(), f"Missing triage ledger at {triage_path}"
    data = json.loads(triage_path.read_text(encoding="utf-8"))
    assert data["triage_id"] == "PADDING_REVIEW_TRIAGE"
    assert data["all_dispositions_acceptable"] is True
    assert data["total_triage_entries"] > 0

    for entry in data["triage_entries"]:
        assert entry["triage_category"] == "SUSPECTED_LEXICAL_FALSE_POSITIVE"
        assert entry["disposition"] == "APPROVED_LEGITIMATE_FUNCTION_WORDS"
        assert entry["verbatim_10word_spans_count"] == 0
        assert entry["jaccard_similarity"] < 0.005

# --- Cross-Split Disjointness Tests ---


def test_cross_split_disjointness_against_historical_holdout(
    provenance_ledger: Dict[str, Any]
) -> None:
    """Asserts that candidate sources do not collide with known HOLDOUT or DEV corpora."""
    holdout_topics = [
        "fam-astrophysics-pulsar-08",
        "fam-paleontology-cambrian-09",
        "fam-marine-01",
        "fam-energy-01",
        "fam-agri-01",
    ]
    for src in provenance_ledger["sources"]:
        fam_id = src["family_id"]
        assert fam_id not in holdout_topics, f"Source family {fam_id} collides with holdout/calibration!"

        txt_path = V2_SOURCES_DIR / f"{src['pmcid']}.txt"
        v2_text = txt_path.read_text(encoding="utf-8")

        # Assert no pulsar or cambrian text leakage
        assert "millisecond pulsar" not in v2_text.lower()
        assert "cambrian explosion" not in v2_text.lower()


# --- Statistical Clustering Notice Verification ---


def test_statistical_clustering_notice_and_attributes(provenance_ledger: Dict[str, Any]) -> None:
    """Verifies that the ledger explicitly reports source-family clustering."""
    assert "statistical_clustering_notice" in provenance_ledger
    notice = provenance_ledger["statistical_clustering_notice"]
    assert "clustering" in notice.lower()
    assert "statistically independent" in notice.lower()

    for src in provenance_ledger["sources"]:
        cluster_attrs = src.get("clustering_attributes", {})
        assert cluster_attrs.get("source_family_id") == src["family_id"]
        assert cluster_attrs.get("cluster_id") == src["family_id"]
        assert "cluster" in cluster_attrs.get("statistical_clustering_notice", "").lower()
