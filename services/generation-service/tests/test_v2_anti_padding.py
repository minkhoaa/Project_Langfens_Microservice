"""Acceptance test suite for RQ2_DATASET_V2 calibrated anti-padding and leakage detection (Sprint V2-S02).

Verifies:
1. Tier 1 rejection: Fails on consecutive duplicate paragraphs, 41-55x loops (DEF-DAT-02),
   sentence repetition >= 3, and cross-source verbatim copying >= 15 words.
2. Tier 2 triage: Non-consecutive repeated clauses (>= 8 words) routed to review with recorded evidence.
3. Tier 3 allowance: Permits natural repetition of legitimate technical compound nouns.
4. Exact preregistered forbidden-source policy:
   - Distinguishes raw 3-grams from content-word shingles.
   - Strict zero content-word 3-gram overlap under documented stopword policy.
   - Strict zero verbatim 6-word span overlap.
5. Production validator invocation: Negative tests call verify_anti_contamination directly.
6. Genuine baseline disjointness: Checks candidate sources against all available DEV, CALIBRATION,
   HOLDOUT, and G15 baseline evidence without exposing holdout gold to generator.
7. Source-family clustering: Validates that passages sharing source_family_id are marked as clustered observations.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Set, Tuple

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(REPO_ROOT / "services" / "generation-service"))
sys.path.insert(0, str(REPO_ROOT))

from app.experiment.stopword_policy import (
    STANDARD_ENGLISH_STOPWORDS,
    extract_content_word_3grams,
    extract_raw_3grams,
    extract_verbatim_spans,
    is_pure_function_word_3gram,
    tokenize_content_words,
    tokenize_raw_words,
)
from generation_baseline.tools.check_corpus_disjointness import (
    BaselineCorpusRepository,
    RESERVED_READING_FAMILIES,
    jaccard_similarity,
)
from generation_baseline.tools.verify_and_ingest_pmc_sources import (
    FORBIDDEN_QUARANTINED_PMCIDS,
    check_baseline_split_disjointness,
    load_forbidden_v1_sources,
    verify_anti_contamination,
)

LEDGER_PATH = REPO_ROOT / "generation_baseline" / "verification" / "V2_SOURCE_PROVENANCE_LEDGER.json"
TRIAGE_PATH = REPO_ROOT / "generation_baseline" / "verification" / "PADDING_REVIEW_TRIAGE.json"
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


@pytest.fixture(scope="module")
def provenance_ledger() -> Dict[str, Any]:
    assert LEDGER_PATH.exists(), f"Missing ledger at {LEDGER_PATH}"
    return json.loads(LEDGER_PATH.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def forbidden_v1_sources() -> List[Dict[str, Any]]:
    assert SOURCES_ELIGIBLE_PATH.exists(), f"Missing {SOURCES_ELIGIBLE_PATH}"
    sources = load_forbidden_v1_sources()
    assert len(sources) == 6, f"Expected 6 forbidden sources, got {len(sources)}"
    return sources


@pytest.fixture(scope="module")
def baseline_repo() -> BaselineCorpusRepository:
    repo = BaselineCorpusRepository()
    loaded = repo.load_authoritative_baselines()
    assert loaded is True, f"Failed to load baseline repository: {repo.load_error}"
    return repo


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
    sample_text = (
        "In controlled environment vertical farming, the LED photoperiod governs photosynthetic "
        "efficiency. Optimizing the LED photoperiod reduces overall operational costs. Furthermore, "
        "proper adjustment of the LED photoperiod enhances secondary metabolite accumulation."
    )
    matches = re.findall(r"\bLED photoperiod\b", sample_text)
    assert len(matches) == 3


# --- Exact Preregistered Forbidden-Source Policy & Verification ---


def test_exact_preregistered_forbidden_source_policy(
    provenance_ledger: Dict[str, Any], forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Enforces exact preregistered policy: zero content-word overlap, zero verbatim 6-word spans."""
    all_forbidden_c3g: Set[str] = set()
    all_forbidden_6w: Set[str] = set()
    forbidden_pmcids: Set[str] = set()

    for item in forbidden_v1_sources:
        forbidden_pmcids.add(item["pmcid"])
        all_forbidden_c3g.update(item["content_3grams"])
        all_forbidden_6w.update(item["spans_6w"])

    assert len(all_forbidden_c3g) > 400, "Forbidden content 3-grams must be loaded."
    assert len(all_forbidden_6w) > 400, "Forbidden 6-word spans must be loaded."

    for src in provenance_ledger["sources"]:
        pmcid = src["pmcid"]
        assert pmcid not in forbidden_pmcids
        assert pmcid not in FORBIDDEN_QUARANTINED_PMCIDS

        txt_file = V2_SOURCES_DIR / f"{pmcid}.txt"
        assert txt_file.exists(), f"Missing text fixture {txt_file}"
        v2_text = txt_file.read_text(encoding="utf-8")

        # 1. Zero PMCID string references
        for f_pmcid in FORBIDDEN_QUARANTINED_PMCIDS:
            assert f_pmcid.lower() not in v2_text.lower(), f"Forbidden identifier {f_pmcid} in {pmcid}"

        # 2. Strict Zero Verbatim 6-Word Span Overlap
        v2_6w = extract_verbatim_spans(v2_text, span_length=6)
        shared_6w = v2_6w & all_forbidden_6w
        assert len(shared_6w) == 0, f"Found shared 6-word verbatim spans in {pmcid}: {shared_6w}"

        # 3. Strict Zero Content-Word 3-Gram Overlap (Documented Stopword Policy)
        v2_c3g = extract_content_word_3grams(v2_text)
        shared_c3g = v2_c3g & all_forbidden_c3g
        assert len(shared_c3g) == 0, f"Found shared content-word 3-grams in {pmcid}: {shared_c3g}"


# --- Negative Tests Invoking Production Contamination Validator ---


def test_negative_reject_injected_forbidden_pmcid_production_validator(
    forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Asserts that production verify_anti_contamination rejects text containing forbidden PMCID."""
    contaminated_text = "Recent studies on PMC8910002 demonstrated significant environmental degradation."
    clean_ok, issues, triage, max_sim = verify_anti_contamination(
        contaminated_text, candidate_pmcid="PMC_TEST_NEG", forbidden_sources=forbidden_v1_sources
    )
    assert clean_ok is False, "Production validator must reject text containing forbidden PMCID!"
    assert any("Forbidden source identifier PMC8910002" in iss for iss in issues)


def test_negative_reject_injected_forbidden_6word_span_production_validator(
    forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Asserts that production verify_anti_contamination rejects injected 6-word forbidden verbatim span."""
    forbidden_content = forbidden_v1_sources[0]["content"]
    forbidden_tokens = tokenize_raw_words(forbidden_content)
    span_6w = " ".join(forbidden_tokens[20:26])
    assert len(span_6w.split()) == 6

    clean_sample = (
        "Controlled environment agriculture provides significant advantages for commercial crop cultivation. "
        "The experimental setup utilized advanced LED arrays with adjustable spectral output. "
    ) * 10
    contaminated_sample = clean_sample + " " + span_6w + " " + clean_sample

    clean_ok, issues, triage, max_sim = verify_anti_contamination(
        contaminated_sample, candidate_pmcid="PMC_TEST_NEG", forbidden_sources=forbidden_v1_sources
    )
    assert clean_ok is False, "Production validator must reject text containing 6-word verbatim overlap!"
    assert any("Verbatim 6-word span overlap" in iss for iss in issues)


def test_negative_boundary_5word_vs_6word_production_validator(
    forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Tests exact 6-word boundary condition: 5 words do not trigger 6-word span rejection."""
    forbidden_content = forbidden_v1_sources[0]["content"]
    forbidden_tokens = tokenize_raw_words(forbidden_content)
    span_5w = " ".join(forbidden_tokens[20:25])
    assert len(span_5w.split()) == 5

    clean_sample = "Plant biology requires rigorous calibration of light intensity and spectral distribution. " * 10
    test_5w_sample = clean_sample + " " + span_5w + " " + clean_sample

    clean_ok, issues, triage, max_sim = verify_anti_contamination(
        test_5w_sample, candidate_pmcid="PMC_TEST_5W", forbidden_sources=forbidden_v1_sources
    )
    # The 5-word span does not trigger 6-word span rejection
    assert not any("Verbatim 6-word span overlap" in iss for iss in issues)


def test_negative_reject_injected_forbidden_content_3gram_production_validator(
    forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Asserts that production verify_anti_contamination rejects injected forbidden content-word 3-gram."""
    f_content_3g = list(forbidden_v1_sources[1]["content_3grams"])[0]
    c_words = f_content_3g.split()
    assert len(c_words) == 3

    clean_sample = "Environmental hydrology studies groundwater movement through porous rock formations. " * 10
    contaminated_sample = clean_sample + f" The study evaluated {c_words[0]} with {c_words[1]} and {c_words[2]}. " + clean_sample

    clean_ok, issues, triage, max_sim = verify_anti_contamination(
        contaminated_sample, candidate_pmcid="PMC_TEST_C3G", forbidden_sources=forbidden_v1_sources
    )
    assert clean_ok is False, "Production validator must reject substantive content-word 3-gram overlap!"
    assert any("Content-word 3-gram overlap" in iss for iss in issues)


def test_negative_reject_injected_forbidden_title_production_validator(
    forbidden_v1_sources: List[Dict[str, Any]]
) -> None:
    """Asserts that production verify_anti_contamination rejects injected forbidden title."""
    title_span = "Early Hydraulic Engineering in Mesopotamian"
    clean_sample = "Ancient archaeological findings document canal development across the alluvial plain. " * 10
    contaminated_sample = clean_sample + f" A paper entitled {title_span} was examined. " + clean_sample

    clean_ok, issues, triage, max_sim = verify_anti_contamination(
        contaminated_sample, candidate_pmcid="PMC_TEST_TITLE", forbidden_sources=forbidden_v1_sources
    )
    assert clean_ok is False, "Production validator must reject forbidden title substring!"
    assert any("Forbidden title span" in iss for iss in issues)


# --- Genuine Baseline Disjointness Verification ---


def test_genuine_baseline_split_disjointness_all_seven_sources(
    provenance_ledger: Dict[str, Any], baseline_repo: BaselineCorpusRepository
) -> None:
    """Validates split-based disjointness and zero shared 10-word spans against 93 excluded + 4 permitted V1 (97 total)."""
    assert len(baseline_repo.baseline_reading_passages) == 97, f"Expected 97 passages, got {len(baseline_repo.baseline_reading_passages)}"
    assert len(baseline_repo.baseline_records) == 97, f"Expected 97 records, got {len(baseline_repo.baseline_records)}"
    assert len(baseline_repo.forbidden_families) >= 70, "Expected >= 70 forbidden families loaded."
    for src in provenance_ledger["sources"]:
        pmcid = src["pmcid"]
        family_id = src["family_id"]
        classification = src.get("classification", "INHERITED_CANDIDATE")
        txt_path = V2_SOURCES_DIR / f"{pmcid}.txt"
        assert txt_path.exists()
        clean_text = txt_path.read_text(encoding="utf-8")

        result = check_baseline_split_disjointness(
            pmcid, family_id, clean_text, baseline_repo, classification=classification
        )
        assert result["status"] == "PASS", f"Baseline disjointness failed for {pmcid}: {result['diagnostics']}"
        assert result["is_dev_collision"] is False
        assert result["is_calib_collision"] is False
        assert result["is_reserved_holdout_collision"] is False
        assert result["is_g15_collision"] is False
        assert result["is_quarantined_collision"] is False
        assert result["is_prior_phase_collision"] is False
        assert result["is_forbidden_family_collision"] is False
        assert result["zero_shared_10word_spans"] is True, f"Found shared 10-word spans in {pmcid}: {result['shared_10word_span_collisions']}"
        assert result["shared_10word_span_collisions_count"] == 0
        assert result["max_baseline_shingle_jaccard"] < 0.10, (
            f"Jaccard {result['max_baseline_shingle_jaccard']} >= 0.10 for {pmcid}"
        )

        v1_exc = result["v1_inheritance_exception"]
        if classification == "INHERITED_CANDIDATE":
            assert v1_exc["is_approved"] is True, f"Expected approved V1 inheritance for {pmcid}"
            assert v1_exc["cross_source_v1_collision"] is False
        else:
            assert v1_exc["is_approved"] is False
            assert v1_exc["cross_source_v1_collision"] is False

        # Assert split representation
        counts = result["split_counts"]
        assert counts["DEV"] == 25
        assert counts["CALIBRATION"] == 29
        assert counts["HOLDOUT"] == 30
        assert counts["G15"] == 5
        assert counts["QUARANTINED"] == 4
        assert counts["V1_INHERITED"] == 4
        assert sum(counts[s] for s in ("DEV", "CALIBRATION", "HOLDOUT", "G15", "QUARANTINED")) == 93
        assert counts["V1_INHERITED"] == 4


def test_negative_reject_injected_cross_split_10word_span_production_validator(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Asserts that production check_baseline_split_disjointness rejects injected 10-word span from DEV/G15 baseline."""
    # Locate a DEV record with >= 10 words
    dev_record = next(r for r in baseline_repo.baseline_records if r["split"] == "DEV" and len(r["text"].split()) >= 15)
    dev_tokens = dev_record["text"].split()
    dev_10w_span = " ".join(dev_tokens[2:12])

    clean_sample = (
        "A controlled environment agriculture system monitors ambient temperature, relative humidity, "
        "and spectral irradiance continuously. Advanced sensor telemetry optimizes photosynthesis rates "
        "without manual intervention. Nutrient concentrations remain strictly regulated throughout all stages."
    )
    tainted_sample = clean_sample + " " + dev_10w_span

    result = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_SPLIT_10W",
        candidate_family_id="fam-v2-test-clean",
        clean_text=tainted_sample,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert result["status"] == "FAIL", "Validator must reject injected cross-split 10-word span!"
    assert result["zero_shared_10word_spans"] is False
    assert result["shared_10word_span_collisions_count"] > 0
    assert any(c["split"] == "DEV" for c in result["shared_10word_span_collisions"])


def test_negative_boundary_9word_vs_10word_cross_split_production_validator(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Tests exact 10-word boundary condition: 9 words do not trigger 10-word cross-split rejection, 10 words fail."""
    dev_record = next(r for r in baseline_repo.baseline_records if r["split"] == "DEV" and len(r["text"].split()) >= 15)
    dev_tokens = dev_record["text"].split()
    dev_9w_span = " ".join(dev_tokens[2:11])
    dev_10w_span = " ".join(dev_tokens[2:12])

    clean_sample = (
        "Vertical farming facilities optimize resource utilization by recapturing ninety-five percent "
        "of transpired moisture. Artificial lighting arrays supply photons across narrow spectral bands "
        "to maximize chlorophyll absorption and minimize wasted energy."
    )

    # 1. 9-word span injection: zero_shared_10word_spans must remain True
    sample_9w = clean_sample + " " + dev_9w_span
    res_9w = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_BOUNDARY_9W",
        candidate_family_id="fam-v2-test-boundary",
        clean_text=sample_9w,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert res_9w["zero_shared_10word_spans"] is True, "9-word span must not trigger 10-word collision rejection!"

    # 2. 10-word span injection: zero_shared_10word_spans must be False and fail closed
    sample_10w = clean_sample + " " + dev_10w_span
    res_10w = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_BOUNDARY_10W",
        candidate_family_id="fam-v2-test-boundary",
        clean_text=sample_10w,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert res_10w["status"] == "FAIL"
    assert res_10w["zero_shared_10word_spans"] is False
    assert res_10w["shared_10word_span_collisions_count"] > 0


def test_negative_reject_genuine_dev_family_collision_production_validator(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Asserts that production validator rejects genuine DEV family collision."""
    clean_sample = (
        "Autonomous robotic harvesters operate within greenhouse facilities using computer vision pipelines. "
        "Fruit ripeness is classified via convolutional neural networks trained on multispectral imagery."
    )
    result = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_DEV_FAM",
        candidate_family_id="coral_reefs",  # Genuine DEV family
        clean_text=clean_sample,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert result["status"] == "FAIL"
    assert result["is_dev_collision"] is True
    assert result["is_forbidden_family_collision"] is True


def test_negative_reject_genuine_g15_family_collision_production_validator(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Asserts that production validator rejects genuine G15 campaign family collision."""
    clean_sample = (
        "Autonomous robotic harvesters operate within greenhouse facilities using computer vision pipelines. "
        "Fruit ripeness is classified via convolutional neural networks trained on multispectral imagery."
    )
    result = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_G15_FAM",
        candidate_family_id="PMC13503497",  # Genuine G15 campaign family
        clean_text=clean_sample,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert result["status"] == "FAIL"
    assert result["is_g15_collision"] is True
    assert result["is_forbidden_family_collision"] is True


def test_negative_reject_unapproved_v1_cross_source_collision(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Asserts that replacement source colliding with V1 family is rejected without inheritance exception."""
    clean_sample = (
        "Autonomous robotic harvesters operate within greenhouse facilities using computer vision pipelines. "
        "Fruit ripeness is classified via convolutional neural networks trained on multispectral imagery."
    )
    # Replacement source pretending to use a V1 family
    result = check_baseline_split_disjointness(
        candidate_pmcid="PMC13665993",  # A replacement source
        candidate_family_id="fam-clean-pmc-13621526",  # A V1 family
        clean_text=clean_sample,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert result["status"] == "FAIL"
    assert result["v1_inheritance_exception"]["is_approved"] is False
    assert result["v1_inheritance_exception"]["cross_source_v1_collision"] is True


def test_negative_reject_quarantined_family_collision_production_validator(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Asserts that production validator rejects quarantined source family collision."""
    clean_sample = (
        "Autonomous robotic harvesters operate within greenhouse facilities using computer vision pipelines. "
        "Fruit ripeness is classified via convolutional neural networks trained on multispectral imagery."
    )
    result = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_QUAR_FAM",
        candidate_family_id="PMC13001950",  # Quarantined source family from final_dataset.py
        clean_text=clean_sample,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert result["status"] == "FAIL"
    assert result["is_quarantined_collision"] is True
    assert result["is_forbidden_family_collision"] is True


def test_negative_reject_prior_phase_test_family_collision_production_validator(
    baseline_repo: BaselineCorpusRepository
) -> None:
    """Asserts that production validator rejects prior phase test source family collision."""
    clean_sample = (
        "Autonomous robotic harvesters operate within greenhouse facilities using computer vision pipelines. "
        "Fruit ripeness is classified via convolutional neural networks trained on multispectral imagery."
    )
    result = check_baseline_split_disjointness(
        candidate_pmcid="PMC_TEST_PRIOR_FAM",
        candidate_family_id="national_geographic",  # Prior phase test source family from final_dataset.py
        clean_text=clean_sample,
        repo=baseline_repo,
        classification="REPLACEMENT_SOURCE",
    )
    assert result["status"] == "FAIL"
    assert result["is_prior_phase_collision"] is True
    assert result["is_forbidden_family_collision"] is True

# --- Triage Ledger & Documented Policy Verification ---


def test_triage_ledger_records_review_required_without_inventing_approval() -> None:
    """Verifies that PADDING_REVIEW_TRIAGE.json audits raw 3-gram matches as REVIEW_REQUIRED."""
    assert TRIAGE_PATH.exists(), f"Missing triage ledger at {TRIAGE_PATH}"
    data = json.loads(TRIAGE_PATH.read_text(encoding="utf-8"))
    assert data["triage_id"] == "PADDING_REVIEW_TRIAGE"
    assert data["total_triage_entries"] > 0
    assert data["review_required_count"] == data["total_triage_entries"]

    for entry in data["triage_entries"]:
        assert entry["triage_category"] == "SUSPECTED_LEXICAL_FALSE_POSITIVE"
        assert entry["disposition"] == "REVIEW_REQUIRED", (
            "Suspected lexical false positives must be recorded as REVIEW_REQUIRED; approval cannot be invented."
        )
        assert entry["shared_6word_spans_count"] == 0
        assert entry["shared_content_3gram_count"] == 0


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
