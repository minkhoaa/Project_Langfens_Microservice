"""Acceptance test suite for SemanticSentenceSegmenter (Sprint V2-S02).

Verifies:
1. Boundary parser correctness on academic abbreviations, decimals, citations, and formulas.
2. Passage length contract: 350-650 words per passage across 100% of extracted passages.
3. Severed anaphora detection and discourse integrity.
4. Fail-closed rejection of insufficient word counts without mechanical forcing or padding.
5. Extraction of exactly 4 valid passages across all 7 admitted V2 candidate sources (28 passages total).
6. Source-family cluster metadata presence on every segmented passage.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

import pytest

from app.experiment.segmentation import (
    InsufficientUsableWordCountError,
    SegmentedPassage,
    SemanticSentenceSegmenter,
)

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
LEDGER_PATH = REPO_ROOT / "generation_baseline" / "verification" / "V2_SOURCE_PROVENANCE_LEDGER.json"
V2_SOURCES_DIR = REPO_ROOT / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources_v2"


@pytest.fixture
def segmenter() -> SemanticSentenceSegmenter:
    return SemanticSentenceSegmenter(min_words=350, max_words=650, target_passages=4)


@pytest.fixture(scope="module")
def provenance_ledger() -> Dict[str, Any]:
    assert LEDGER_PATH.exists(), f"Provenance ledger missing: {LEDGER_PATH}"
    return json.loads(LEDGER_PATH.read_text(encoding="utf-8"))


def test_abbreviation_and_decimal_boundary_preservation(segmenter: SemanticSentenceSegmenter) -> None:
    """Ensures sentence splitter does not sever abbreviations, decimals, or citations."""
    sample = (
        "In modern controlled environment agriculture, Aldiyab et al. demonstrated that LED spectra "
        "significantly improve crop morphology (e.g. leaf area and shoot biomass). "
        "The photoperiod ratio was maintained at 16:8 with a pH of 6.5 and p < 0.05. "
        "Concentrations of dissolved CO2 and H2O were monitored continuously by Dr. Smith and Prof. Jones. "
        "Previous findings [1, 2] reported contradictory results. A final conclusion was established."
    )
    sentences = segmenter.split_into_sentences(sample)
    assert len(sentences) == 5, f"Expected 5 sentences, got {len(sentences)}: {sentences}"
    assert "Aldiyab et al." in sentences[0]
    assert "e.g." in sentences[0]
    assert "16:8" in sentences[1]
    assert "p < 0.05" in sentences[1]
    assert "CO2 and H2O" in sentences[2]
    assert "Dr. Smith and Prof. Jones." in sentences[2]


def test_severed_anaphora_detection(segmenter: SemanticSentenceSegmenter) -> None:
    """Verifies that dangling anaphoric pronouns are detected."""
    bad_sentence = "This occurred because the ambient temperature fluctuated rapidly."
    has_anaphora, reason = segmenter.check_opening_anaphora(bad_sentence)
    assert has_anaphora is True
    assert "severed anaphora" in reason.lower()

    good_sentence = "Ambient temperature fluctuations caused rapid thermal instability across the chamber."
    has_anaphora, reason = segmenter.check_opening_anaphora(good_sentence)
    assert has_anaphora is False


def test_insufficient_word_count_rejection(segmenter: SemanticSentenceSegmenter) -> None:
    """Asserts that texts with < 1400 words fail closed and are not mechanically forced."""
    short_text = "This is a short academic sentence explaining a controlled experiment. " * 50  # ~450 words
    with pytest.raises(InsufficientUsableWordCountError) as exc_info:
        segmenter.segment_into_passages(short_text, "PMC_SHORT", "fam-short", target_count=4)
    assert "insufficient" in str(exc_info.value).lower()

    feas = segmenter.evaluate_feasibility(short_text, "PMC_SHORT", "fam-short", target_count=4)
    assert feas["feasible"] is False
    assert feas["passage_count"] == 0
    assert "insufficient" in feas["error"].lower()


def test_passage_length_contract_and_whole_sentence_packing(segmenter: SemanticSentenceSegmenter) -> None:
    """Verifies that all extracted passages fall within [350, 650] words and contain whole sentences."""
    # Construct a synthetic multi-paragraph text with ~2500 words
    paragraphs = []
    for i in range(15):
        para = f"Paragraph {i+1} outlines the methodology of empirical measurement. " + (
            "The experimental results showed consistent trends across all baseline conditions. "
            "Data was verified using independent calibration protocols to ensure reproducibility. "
        ) * 5
        paragraphs.append(para)
    synthetic_text = "\n\n".join(paragraphs)

    passages = segmenter.segment_into_passages(synthetic_text, "PMC_TEST", "fam-test", target_count=4)
    assert len(passages) == 4

    for p in passages:
        assert 350 <= p.word_count <= 650, f"Passage {p.passage_id} length {p.word_count} outside bounds."
        assert p.text.endswith((".", "!", "?")), f"Passage {p.passage_id} did not end at a whole sentence."
        # Verify no mid-word cuts
        assert not p.text.endswith("-"), f"Passage {p.passage_id} ends with dangling hyphen."


def test_all_seven_v2_sources_yield_four_valid_passages(
    segmenter: SemanticSentenceSegmenter, provenance_ledger: Dict[str, Any]
) -> None:
    """Validates that all 7 admitted candidate sources yield exactly 4 compliant passages (28 total)."""
    all_passages: List[SegmentedPassage] = []

    for src in provenance_ledger["sources"]:
        pmcid = src["pmcid"]
        family_id = src["family_id"]
        txt_path = V2_SOURCES_DIR / f"{pmcid}.txt"
        assert txt_path.exists(), f"V2 fixture missing for {pmcid}"

        clean_text = txt_path.read_text(encoding="utf-8")
        passages = segmenter.segment_into_passages(clean_text, pmcid, family_id, target_count=4)

        assert len(passages) == 4, f"Source {pmcid} yielded {len(passages)} passages instead of 4."
        for p in passages:
            assert 350 <= p.word_count <= 650, f"{p.passage_id} word count {p.word_count} outside [350, 650]."
            assert p.source_family_id == family_id
            assert p.cluster_id == family_id
            all_passages.append(p)

    assert len(all_passages) == 28, f"Expected 28 total Reading passages, got {len(all_passages)}"
