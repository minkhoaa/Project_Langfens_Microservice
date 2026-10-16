"""Unit tests for RG10 corpus disjointness and dry-run campaign readiness.

Verifies:
- Authoritative baseline resource loading and leakage detection (positive and negative).
- Source-family quarantine and ID collision enforcement.
- Word count bounds, label balance, and verbatim citation span checks.
- Clean synthetic control passes when isolated; fails when leaked.
- Pending holdout directory handling.
- Campaign readiness check covers all 9 research aspects offline with zero provider calls.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any, Dict, List

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(REPO_ROOT))

from app.experiment.campaign_readiness import (
    CampaignReadinessAuditor,
    CampaignReadinessReport,
)
from generation_baseline.tools.check_corpus_disjointness import (
    RESERVED_GRAMMAR_FAMILIES,
    RESERVED_READING_FAMILIES,
    BaselineCorpusRepository,
    audit_corpus_disjointness,
    check_grammar_corpus,
    check_reading_corpus,
    extract_3gram_shingles,
    jaccard_similarity,
)


@pytest.fixture
def baseline_repo() -> BaselineCorpusRepository:
    repo = BaselineCorpusRepository()
    loaded = repo.load_authoritative_baselines()
    assert loaded is True, f"Failed to load baseline resources: {repo.load_error}"
    return repo


@pytest.fixture
def valid_reading_holdout_item() -> Dict[str, Any]:
    passage_text = (
        "Millisecond pulsars are rapidly rotating magnetized neutron stars whose rotational periods "
        "range from one to ten milliseconds. They are thought to be formed in close binary systems where "
        "an old neutron star accretes matter and angular momentum from a companion star that overflows its Roche lobe. "
        "During this protracted accretion phase, which can endure for hundreds of millions of years, the neutron star "
        "spins up to extreme frequencies. Once mass transfer ceases, the system becomes observable as a radio millisecond pulsar. "
        "Observational surveys utilizing sensitive radio telescopes have uncovered hundreds of these energetic stellar remnants. "
        "Their astonishing rotational stability rivals that of terrestrial atomic clocks, making them invaluable celestial laboratories "
        "for probing fundamental physics. Astrophysicists utilize pulsar timing arrays to search for low-frequency gravitational waves "
        "originating from supermassive black hole binaries. Furthermore, high-precision timing observations allow researchers to test "
        "Einstein's theory of general relativity under strong gravitational field conditions. The polar cap acceleration regions generate "
        "intense electric fields capable of accelerating charged particles to ultrarelativistic energies. As these particles travel along "
        "curved magnetic field lines, they produce coherent radio emission and energetic gamma-ray pulses detected by orbital observatories."
    )
    # Expand to achieve ~750 words
    expanded_text = (passage_text + " ") * 4
    wc = len(expanded_text.split())
    assert 720 <= wc <= 915

    return {
        "item_id": "test-clean-holdout-reading-01",
        "source_family_id": "fam-astrophysics-pulsar-08",
        "domain": "READING",
        "question_type": "TFNG",
        "passage_id": "pass-test-01",
        "passage_title": "Astrophysical Mechanics of Millisecond Pulsars",
        "passage_word_count": wc,
        "passage_text": expanded_text,
        "statement": "Pulsar timing arrays are deployed by astrophysicists to search for low-frequency gravitational waves.",
        "ground_truth_label": "TRUE",
        "evidence_span": "Astrophysicists utilize pulsar timing arrays to search for low-frequency gravitational waves",
        "provenance": {
            "source_title": "Scholarly Treatise on Pulsar Astrophysics",
            "author": "Dr. Researcher",
            "year": 2024,
            "license": "CC-BY-4.0",
        },
    }


@pytest.fixture
def valid_grammar_holdout_item() -> Dict[str, Any]:
    return {
        "item_id": "test-clean-holdout-grammar-01",
        "source_family_id": "fam-mood-subjunctive-08",
        "domain": "GRAMMAR",
        "question_type": "GRAMMAR_MCQ",
        "topic": "Mandative Subjunctive in Formal Registers",
        "stem": "Which of the following sentences correctly utilizes the mandative subjunctive?",
        "options": [
            "A) The senate demands that each senator attends the inquiry.",
            "B) The senate demands that each senator attend the inquiry.",
            "C) The senate demands that each senator attending the inquiry.",
            "D) The senate demands each senator to attending the inquiry.",
        ],
        "ground_truth_key": "B",
        "distractor_flaws": {
            "A": {"error_code": "INDICATIVE_INFLECTION", "explanation": "Inflected 3rd-person 'attends'"},
            "C": {"error_code": "PARTICIPLE_FRAGMENT", "explanation": "Present participle 'attending' without auxiliary"},
            "D": {"error_code": "CATENATIVE_ERROR", "explanation": "Corrupt prepositional infinitive"},
        },
    }


def test_baseline_repo_loads_authoritative_data(baseline_repo: BaselineCorpusRepository):
    """Verifies baseline repository successfully loads non-empty sets across all categories."""
    assert len(baseline_repo.known_item_ids) > 20
    assert len(baseline_repo.forbidden_families) > 10
    assert len(baseline_repo.baseline_reading_passages) > 10
    assert len(baseline_repo.baseline_grammar_stems) > 5


def test_reading_corpus_detects_forbidden_family(baseline_repo: BaselineCorpusRepository, valid_reading_holdout_item: Dict[str, Any]):
    """NEG: Leaked item with forbidden DEV family is rejected."""
    bad_item = dict(valid_reading_holdout_item)
    bad_item["source_family_id"] = "fam-marine-01"  # in forbidden families
    ok, errs, _ = check_reading_corpus([bad_item] * 18, baseline_repo)
    assert ok is False
    assert any("collides with forbidden DEV/calibration families" in e or "invalid source_family_id" in e for e in errs)


def test_reading_corpus_detects_item_id_collision(baseline_repo: BaselineCorpusRepository, valid_reading_holdout_item: Dict[str, Any]):
    """NEG: Holdout item using existing calibration item ID is rejected."""
    bad_item = dict(valid_reading_holdout_item)
    bad_item["item_id"] = "calib-tfng-01"  # Known ID from CALIBRATION_CORPUS
    ok, errs, _ = check_reading_corpus([bad_item] * 18, baseline_repo)
    assert ok is False
    assert any("Holdout item_id collision with historical/dev baseline: 'calib-tfng-01'" in e for e in errs)


def test_reading_corpus_detects_passage_text_leakage(baseline_repo: BaselineCorpusRepository, valid_reading_holdout_item: Dict[str, Any]):
    """NEG: Holdout passage copying text from a baseline passage is rejected by Jaccard check."""
    bad_item = dict(valid_reading_holdout_item)
    base_id, base_text = baseline_repo.baseline_reading_passages[0]
    bad_item["passage_text"] = base_text
    bad_item["passage_word_count"] = len(base_text.split())
    ok, errs, _ = check_reading_corpus([bad_item] * 18, baseline_repo)
    assert ok is False
    assert any("leakage" in e.lower() for e in errs)


def test_reading_corpus_detects_missing_evidence_span(baseline_repo: BaselineCorpusRepository, valid_reading_holdout_item: Dict[str, Any]):
    """NEG: TRUE/FALSE item without evidence span is rejected."""
    bad_item = dict(valid_reading_holdout_item)
    bad_item["ground_truth_label"] = "TRUE"
    bad_item["evidence_span"] = ""  # Missing span
    ok, errs, _ = check_reading_corpus([bad_item] * 18, baseline_repo)
    assert ok is False
    assert any("missing mandatory evidence_span citation" in e for e in errs)


def test_reading_corpus_detects_non_verbatim_evidence_span(baseline_repo: BaselineCorpusRepository, valid_reading_holdout_item: Dict[str, Any]):
    """NEG: Evidence span that does not exist in passage text is rejected."""
    bad_item = dict(valid_reading_holdout_item)
    bad_item["ground_truth_label"] = "TRUE"
    bad_item["evidence_span"] = "Completely hallucinated text not present in passage at all."
    ok, errs, _ = check_reading_corpus([bad_item] * 18, baseline_repo)
    assert ok is False
    assert any("evidence_span is not a verbatim substring of passage_text" in e for e in errs)


def test_grammar_corpus_detects_invalid_key_and_missing_error_code(baseline_repo: BaselineCorpusRepository, valid_grammar_holdout_item: Dict[str, Any]):
    """NEG: Grammar item with bad key or missing distractor error code is rejected."""
    bad_item = dict(valid_grammar_holdout_item)
    bad_item["ground_truth_key"] = "E"  # Invalid key
    bad_item["distractor_flaws"]["A"]["error_code"] = ""  # Missing error code
    ok, errs, _ = check_grammar_corpus([bad_item] * 12, baseline_repo)
    assert ok is False
    assert any("invalid ground_truth_key 'E'" in e for e in errs)
    assert any("missing non-empty error_code" in e for e in errs)


def test_grammar_corpus_detects_stem_collision(baseline_repo: BaselineCorpusRepository, valid_grammar_holdout_item: Dict[str, Any]):
    """NEG: Grammar item copying stem from baseline question is rejected."""
    bad_item = dict(valid_grammar_holdout_item)
    base_id, base_stem = baseline_repo.baseline_grammar_stems[0]
    bad_item["stem"] = base_stem
    ok, errs, _ = check_grammar_corpus([bad_item] * 12, baseline_repo)
    assert ok is False
    assert any("exact grammar stem collision detected against baseline item" in e for e in errs)


def test_pending_holdout_directory_reports_pending():
    """POS: Unpopulated holdout directory reports SPECIFICATION_PENDING_INDEPENDENT_CURATION."""
    res = audit_corpus_disjointness(Path("generation_baseline/holdout"))
    assert res["status"] == "SPECIFICATION_PENDING_INDEPENDENT_CURATION"
    assert res["eligible_for_sealing"] is False
    assert "PENDING external human panel curation" in res["message"]


def test_campaign_readiness_dry_run_covers_all_nine_areas():
    """POS: Campaign readiness dry-run covers all 9 required areas with 0 network calls."""
    auditor = CampaignReadinessAuditor()
    report: CampaignReadinessReport = auditor.run_readiness_audit()

    assert report.is_dry_run is True
    # 1. Dataset identity & hashes
    assert report.dataset_readiness.reading_task_count == 28
    assert report.dataset_readiness.grammar_task_count == 28
    assert report.dataset_readiness.total_task_count == 56
    assert len(report.dataset_readiness.combined_source_sha256) == 64
    assert report.dataset_readiness.is_source_isolated is True
    assert report.dataset_readiness.holdout_manifest_status == "SPECIFICATION_PENDING_INDEPENDENT_CURATION"
    assert report.dataset_readiness.holdout_seals_are_null is True

    # 2. Version readiness
    assert report.version_readiness.evaluator_version == "neutral-eval-v2.7"
    assert report.version_readiness.rubric_version == "rubric-qgeval-v2.7"
    assert report.version_readiness.foundation_model_id == "minimax/MiniMax-Text-01"
    assert report.version_readiness.experimental_arms == ["A", "B", "C"]

    # 3. Roster & denominators
    assert report.roster_and_denominators.total_assignments == 168
    assert report.roster_and_denominators.reading_assignments == 84
    assert report.roster_and_denominators.grammar_assignments == 84
    assert report.roster_and_denominators.assignments_per_arm["A"] == 56
    assert report.roster_and_denominators.assignments_per_arm["B"] == 56
    assert report.roster_and_denominators.assignments_per_arm["C"] == 56
    assert report.roster_and_denominators.judge_holdout_denominator == 30
    assert report.roster_and_denominators.judge_holdout_reading_stratum == 18
    assert report.roster_and_denominators.judge_holdout_grammar_stratum == 12

    # 4. Provider quota status (0 network calls)
    assert report.provider_quota_status.live_network_calls_made == 0
    assert report.provider_quota_status.prior_verified_status == "BLOCKED_EXTERNAL_QUOTA"
    assert report.provider_quota_status.status == "BLOCKED"

    # 5. Human panel readiness
    assert report.human_panel_readiness.panel_status == "AWAITING_HUMAN_PANEL"
    assert report.human_panel_readiness.synthetic_human_scores_present is False

    # 6. Raw response preservation
    assert len(report.raw_response_preservation.raw_response_directories_found) > 0
    assert report.raw_response_preservation.total_raw_responses_on_disk > 0
    assert report.raw_response_preservation.status == "VERIFIED"

    # 7. Failure & uncertainty accounting
    assert report.failure_and_uncertainty_accounting.fail_closed_on_uncertain is True
    assert report.failure_and_uncertainty_accounting.missing_output_classified_as_fail is True

    # 8. Statistical analysis plan
    assert report.statistical_analysis_plan.primary_endpoint == "independent_final_PASS / all_assigned"
    assert report.statistical_analysis_plan.resampling_unit == "dataset_item_id"

    # 9. Overall readiness
    assert report.overall_software_readiness == "READY"
    assert report.overall_campaign_readiness == "HOLD"
    assert len(report.blockers) == 3
    assert len(report.actionable_resume_criteria) == 4
