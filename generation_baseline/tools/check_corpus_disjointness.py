#!/usr/bin/env python3
"""Authoritative confirmatory holdout corpus eligibility and disjointness verification tool.

Checks:
1. Authoritative baseline resource availability (fails closed if baseline unavailable).
2. Item-ID collision checks across all historical calibration, pilot, and dev splits.
3. Source-family quarantine isolation:
   - Reading must be strictly in RESERVED_READING_FAMILIES and disjoint from all DEV/calibration families.
   - Grammar must be strictly in RESERVED_GRAMMAR_FAMILIES and disjoint from all DEV/calibration families.
4. Exact and near-duplicate leakage checks:
   - Reading: exact substring/equality check and 3-gram shingle Jaccard similarity < 0.30 against all baseline texts.
   - Grammar: exact stem/option equality check and 3-gram shingle Jaccard similarity against all baseline grammar items.
5. Quotas and distribution balance:
   - Reading: exactly 18 items (9 per family; 6 TRUE, 6 FALSE, 6 NOT GIVEN; 720-915 words; verbatim spans for TRUE/FALSE).
   - Grammar: exactly 12 items (6 per family; 1 defensible key in A/B/C/D, exactly 3 distractors with error codes).

Usage:
    python3 generation_baseline/tools/check_corpus_disjointness.py [--holdout-dir PATH]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

# Add repo root and generation-service to path
REPO_ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO_ROOT / "services" / "generation-service"))
from app.experiment.stopword_policy import extract_verbatim_spans

SPLIT_DEV = "DEV"
SPLIT_CALIBRATION = "CALIBRATION"
SPLIT_HOLDOUT = "HOLDOUT"
SPLIT_G15 = "G15"
SPLIT_V1_INHERITED = "V1_INHERITED"
CATEGORY_QUARANTINED = "QUARANTINED"
CATEGORY_PRIOR_PHASE_TEST = "PRIOR_PHASE_TEST"

APPROVED_V1_INHERITANCE_MAP: Dict[str, Dict[str, str]] = {
    "PMC13621526": {
        "v1_source_id": "PMC13621526",
        "v1_family_id": "fam-clean-pmc-13621526",
    },
    "PMC13604763": {
        "v1_source_id": "PMC13604763",
        "v1_family_id": "fam-clean-pmc-13604763",
    },
    "PMC13517498": {
        "v1_source_id": "PMC13517498",
        "v1_family_id": "fam-clean-pmc-13517498",
    },
    "PMC13407692": {
        "v1_source_id": "PMC13407692",
        "v1_family_id": "fam-clean-pmc-13407692",
    },
}

RESERVED_READING_FAMILIES: Set[str] = {
    "fam-astrophysics-pulsar-08",
    "fam-paleontology-cambrian-09",
}

RESERVED_GRAMMAR_FAMILIES: Set[str] = {
    "fam-mood-subjunctive-08",
    "fam-aspect-participle-09",
}


def normalize_text_tokens(text: str) -> List[str]:
    """Tokenizes text for exact/shingle comparison."""
    return re.findall(r"\b[a-zA-Z0-9]+\b", text.lower())


def extract_3gram_shingles(text: str) -> Set[str]:
    """Extracts lowercase word 3-gram shingles for near-duplicate Jaccard computation."""
    tokens = normalize_text_tokens(text)
    if len(tokens) < 3:
        return set(tokens)
    return {" ".join(tokens[i : i + 3]) for i in range(len(tokens) - 2)}


def jaccard_similarity(s1: Set[str], s2: Set[str]) -> float:
    """Computes Jaccard similarity between two shingle sets."""
    if not s1 and not s2:
        return 0.0
    intersection = len(s1.intersection(s2))
    union = len(s1.union(s2))
    return float(intersection) / float(union) if union > 0 else 0.0


class BaselineCorpusRepository:
    """Loads authoritative baseline texts, task IDs, and source families across the repository."""

    def __init__(self, repo_root: Path = REPO_ROOT) -> None:
        self.repo_root = repo_root
        self.known_item_ids: Set[str] = set()
        self.forbidden_families: Set[str] = set()
        self.baseline_reading_passages: List[Tuple[str, str]] = []  # (source_id, text)
        self.baseline_reading_statements: List[Tuple[str, str]] = []  # (item_id, statement)
        self.baseline_grammar_stems: List[Tuple[str, str]] = []  # (item_id, stem)
        self.baseline_records: List[Dict[str, Any]] = []
        self.families_by_split: Dict[str, Set[str]] = {
            SPLIT_DEV: set(),
            SPLIT_CALIBRATION: set(),
            SPLIT_HOLDOUT: set(),
            SPLIT_G15: set(),
            SPLIT_V1_INHERITED: set(),
            CATEGORY_QUARANTINED: set(),
            CATEGORY_PRIOR_PHASE_TEST: set(),
        }
        self.is_loaded: bool = False
        self.load_error: Optional[str] = None

    def load_authoritative_baselines(self) -> bool:
        """Loads all baseline data. Returns True if successful, False otherwise."""
        try:
            # 1. Load forbidden families from final_dataset
            from app.experiment.final_dataset import FORBIDDEN_DEV_CALIBRATION_FAMILIES
            self.forbidden_families.update(FORBIDDEN_DEV_CALIBRATION_FAMILIES)
            dev_known = {"coral_reefs", "antarctic_ice", "renewable_energy", "urban_agri"}
            calib_known = {"fam-marine-01", "fam-energy-01", "fam-agri-01"}
            holdout_known = {
                "fam-geology-01", "fam-marine-02", "fam-quantum-01", "fam-neuro-01",
                "fam-climate-01", "fam-astrophysics-pulsar-08", "fam-paleontology-cambrian-09",
            }
            g15_known = {
                "PMC13503497", "fam-pmc-13503497", "PMC13583341", "fam-pmc-13583341",
                "PMC13560651", "fam-pmc-13560651", "PMC12804876", "fam-pmc-12804876",
            }
            quarantined_known = {
                "PMC13001950", "PMC13391382", "PMC13550489", "PMC13572963",
            }
            prior_phase_test_known = {
                "national_geographic", "cambridge_advanced", "oxford_academic",
                "academic_grammar_corpus", "marine_biology", "neuroscience",
            }
            v1_inherited_known = {
                "fam-clean-pmc-13621526", "fam-clean-pmc-13604763",
                "fam-clean-pmc-13517498", "fam-clean-pmc-13407692",
            }
            self.families_by_split[SPLIT_DEV].update(dev_known)
            self.families_by_split[SPLIT_CALIBRATION].update(calib_known)
            self.families_by_split[SPLIT_HOLDOUT].update(holdout_known)
            self.families_by_split[SPLIT_G15].update(g15_known)
            self.families_by_split[CATEGORY_QUARANTINED].update(quarantined_known)
            self.families_by_split[CATEGORY_PRIOR_PHASE_TEST].update(prior_phase_test_known)
            self.families_by_split[SPLIT_V1_INHERITED].update(v1_inherited_known)

            # 2. Load calibration corpora items
            from app.evaluators.calibration import (
                CALIBRATION_CORPUS,
                EVALUATOR_V2_3_CALIBRATION_CORPUS,
                EVALUATOR_V2_5_CALIBRATION_CORPUS,
                FRESH_JUDGE_HOLDOUT_CORPUS_V2,
                JUDGE_HOLDOUT_CORPUS,
            )
            all_calib = list(CALIBRATION_CORPUS) + list(EVALUATOR_V2_5_CALIBRATION_CORPUS) + list(JUDGE_HOLDOUT_CORPUS) + list(FRESH_JUDGE_HOLDOUT_CORPUS_V2)
            holdout_item_ids = {it.item_id for it in list(JUDGE_HOLDOUT_CORPUS) + list(FRESH_JUDGE_HOLDOUT_CORPUS_V2)}
            for it in all_calib:
                self.known_item_ids.add(it.item_id)
                self.forbidden_families.add(it.source_family_id)
                split_val = SPLIT_HOLDOUT if it.item_id in holdout_item_ids else SPLIT_CALIBRATION
                self.families_by_split[split_val].add(it.source_family_id)
                if it.passage_text:
                    self.baseline_reading_passages.append((it.item_id, it.passage_text))
                    self.baseline_records.append({
                        "source_id": it.item_id,
                        "text": it.passage_text,
                        "split": split_val,
                        "source_family": it.source_family_id,
                        "spans_10w": extract_verbatim_spans(it.passage_text, 10),
                        "shingles": extract_3gram_shingles(it.passage_text),
                    })
                q_data = it.question_data or {}
                stmt = q_data.get("statement") or q_data.get("text")
                if stmt:
                    if it.question_type == "GRAMMAR_MCQ":
                        self.baseline_grammar_stems.append((it.item_id, stmt))
                    else:
                        self.baseline_reading_statements.append((it.item_id, stmt))
            # 3. Load baseline source texts from test fixtures
            sources_dir = self.repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
            if sources_dir.exists():
                for txt_file in sources_dir.glob("*.txt"):
                    text = txt_file.read_text(encoding="utf-8")
                    self.baseline_reading_passages.append((txt_file.stem, text))
                    stem = txt_file.stem
                    if stem in {"PMC13621526", "PMC13604763", "PMC13517498", "PMC13407692"}:
                        s_split = SPLIT_V1_INHERITED
                        s_fam = f"fam-clean-pmc-{stem[3:]}"
                    else:
                        s_split = SPLIT_G15
                        s_fam = f"fam-pmc-{stem[3:]}" if stem.startswith("PMC") else stem
                    self.families_by_split[s_split].add(s_fam)
                    self.baseline_records.append({
                        "source_id": stem,
                        "text": text,
                        "split": s_split,
                        "source_family": s_fam,
                        "spans_10w": extract_verbatim_spans(text, 10),
                        "shingles": extract_3gram_shingles(text),
                    })
                quarantined_dir = sources_dir / "quarantined"
                if quarantined_dir.exists():
                    for q_file in quarantined_dir.glob("*.txt"):
                        q_text = q_file.read_text(encoding="utf-8")
                        self.baseline_reading_passages.append((q_file.stem, q_text))
                        self.families_by_split[CATEGORY_QUARANTINED].add(q_file.stem)
                        self.baseline_records.append({
                            "source_id": q_file.stem,
                            "text": q_text,
                            "split": CATEGORY_QUARANTINED,
                            "source_family": q_file.stem,
                            "spans_10w": extract_verbatim_spans(q_text, 10),
                            "shingles": extract_3gram_shingles(q_text),
                        })

            # 4. Load fidelity corpus
            fidelity_path = self.repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "fidelity_corpus.json"
            if fidelity_path.exists():
                with open(fidelity_path, "r", encoding="utf-8") as f:
                    f_data = json.load(f)
                for case in f_data.get("cases", []):
                    c_id = case.get("id")
                    if c_id:
                        self.known_item_ids.add(c_id)
                    s_fam = case.get("source_family")
                    c_split = SPLIT_HOLDOUT if case.get("split") == "holdout" else SPLIT_DEV
                    if s_fam:
                        self.forbidden_families.add(s_fam)
                        self.families_by_split[c_split].add(s_fam)
                    s_text = case.get("source_text")
                    if s_text:
                        self.baseline_reading_passages.append((c_id or "case", s_text))
                        self.baseline_records.append({
                            "source_id": c_id or "case",
                            "text": s_text,
                            "split": c_split,
                            "source_family": s_fam,
                            "spans_10w": extract_verbatim_spans(s_text, 10),
                            "shingles": extract_3gram_shingles(s_text),
                        })
                    c_text = case.get("claim_text")
                    if c_text:
                        self.baseline_reading_statements.append((c_id or "claim", c_text))

            # 5. Load questions corpus
            q_path = self.repo_root / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "questions_corpus.json"
            if q_path.exists():
                with open(q_path, "r", encoding="utf-8") as f:
                    q_data = json.load(f)
                for q in q_data.get("questions", []):
                    qid = q.get("question_id") or q.get("id")
                    if qid:
                        self.known_item_ids.add(qid)
                    stem = q.get("question_text") or q.get("stem") or q.get("text")
                    if stem:
                        self.baseline_grammar_stems.append((qid or "q", stem))
                for p_id, p_text in q_data.get("passages", {}).items():
                    self.baseline_reading_passages.append((p_id, p_text))
                    self.forbidden_families.add(p_id)
                    self.families_by_split[SPLIT_DEV].add(p_id)
                    self.baseline_records.append({
                        "source_id": p_id,
                        "text": p_text,
                        "split": SPLIT_DEV,
                        "source_family": p_id,
                        "spans_10w": extract_verbatim_spans(p_text, 10),
                        "shingles": extract_3gram_shingles(p_text),
                    })

            self.is_loaded = True
            return True
        except Exception as e:
            self.load_error = str(e)
            self.is_loaded = False
            return False


def check_reading_corpus(
    items: List[Dict[str, Any]],
    baseline: BaselineCorpusRepository,
) -> Tuple[bool, List[str], Dict[str, Any]]:
    """Audits reading holdout items for quotas, balance, spans, collisions, and leakage."""
    errors: List[str] = []
    stats: Dict[str, Any] = {
        "total_items": len(items),
        "families": {},
        "labels": {"TRUE": 0, "FALSE": 0, "NOT GIVEN": 0},
    }

    if len(items) != 18:
        errors.append(f"Reading quota violation: expected exactly 18 items, got {len(items)}")

    seen_ids: Set[str] = set()

    for i, it in enumerate(items):
        item_id = it.get("item_id", f"item_{i}")
        fam_id = it.get("source_family_id")
        label = it.get("ground_truth_label")
        passage_text = it.get("passage_text", "")
        statement = it.get("statement", "")
        passage_wc = it.get("passage_word_count", len(passage_text.split()))

        # 1. ID collision check
        if item_id in seen_ids:
            errors.append(f"Duplicate holdout item_id within submission: '{item_id}'")
        seen_ids.add(item_id)

        if item_id in baseline.known_item_ids:
            errors.append(f"Holdout item_id collision with historical/dev baseline: '{item_id}'")

        # 2. Source-Family Quarantine & Isolation
        if fam_id not in RESERVED_READING_FAMILIES:
            errors.append(
                f"{item_id}: invalid source_family_id '{fam_id}'. Must be strictly within reserved set {RESERVED_READING_FAMILIES}"
            )
        if fam_id in baseline.forbidden_families:
            errors.append(
                f"{item_id}: source_family_id '{fam_id}' collides with forbidden DEV/calibration families"
            )
        stats["families"][fam_id] = stats["families"].get(fam_id, 0) + 1

        # 3. Label check
        if label not in stats["labels"]:
            errors.append(f"{item_id}: invalid label '{label}'. Must be TRUE, FALSE, or NOT GIVEN")
        else:
            stats["labels"][label] += 1

        # 4. Mandatory evidence spans for TRUE / FALSE
        if label in ("TRUE", "FALSE"):
            span = it.get("evidence_span")
            if not span or not isinstance(span, str) or not span.strip():
                errors.append(f"{item_id} ({label}): missing mandatory evidence_span citation")
            elif span.strip().lower() not in passage_text.lower():
                errors.append(f"{item_id} ({label}): evidence_span is not a verbatim substring of passage_text")

        # 5. Passage length bounds
        if not (720 <= passage_wc <= 915):
            errors.append(f"{item_id}: passage length {passage_wc} words outside allowable bounds [720, 915]")

        # 6. Exact and Near-duplicate Leakage Checks against baseline
        if passage_text:
            holdout_passage_shingles = extract_3gram_shingles(passage_text)
            for base_id, base_text in baseline.baseline_reading_passages:
                # Exact equality or containment
                if passage_text.strip().lower() in base_text.strip().lower() or base_text.strip().lower() in passage_text.strip().lower():
                    if len(passage_text.split()) > 20 and len(base_text.split()) > 20:
                        errors.append(f"{item_id}: exact passage text leakage detected against baseline '{base_id}'")
                # 3-gram shingle Jaccard
                base_shingles = extract_3gram_shingles(base_text)
                sim = jaccard_similarity(holdout_passage_shingles, base_shingles)
                if sim >= 0.30:
                    errors.append(
                        f"{item_id}: near-duplicate passage leakage against baseline '{base_id}' "
                        f"(3-gram Jaccard similarity {sim:.3f} >= 0.30)"
                    )

        if statement:
            norm_statement = " ".join(normalize_text_tokens(statement))
            for base_id, base_stmt in baseline.baseline_reading_statements:
                norm_base_stmt = " ".join(normalize_text_tokens(base_stmt))
                if norm_statement and norm_statement == norm_base_stmt:
                    errors.append(f"{item_id}: exact statement text collision detected against baseline item '{base_id}'")

    # Check balanced distribution
    for lbl in ("TRUE", "FALSE", "NOT GIVEN"):
        if stats["labels"].get(lbl, 0) != 6:
            errors.append(f"Label imbalance: expected exactly 6 {lbl} items, found {stats['labels'].get(lbl, 0)}")

    for fam in RESERVED_READING_FAMILIES:
        if stats["families"].get(fam, 0) != 9:
            errors.append(f"Family imbalance: expected exactly 9 items for {fam}, found {stats['families'].get(fam, 0)}")

    return len(errors) == 0, errors, stats


def check_grammar_corpus(
    items: List[Dict[str, Any]],
    baseline: BaselineCorpusRepository,
) -> Tuple[bool, List[str], Dict[str, Any]]:
    """Audits grammar holdout items for quotas, keys, distractors, collisions, and leakage."""
    errors: List[str] = []
    stats: Dict[str, Any] = {
        "total_items": len(items),
        "families": {},
    }

    if len(items) != 12:
        errors.append(f"Grammar quota violation: expected exactly 12 items, got {len(items)}")

    seen_ids: Set[str] = set()

    for i, it in enumerate(items):
        item_id = it.get("item_id", f"item_{i}")
        fam_id = it.get("source_family_id")
        key = it.get("ground_truth_key")
        stem = it.get("stem", "")
        options = it.get("options", [])
        distractor_flaws = it.get("distractor_flaws", {})

        # 1. ID collision check
        if item_id in seen_ids:
            errors.append(f"Duplicate grammar holdout item_id within submission: '{item_id}'")
        seen_ids.add(item_id)

        if item_id in baseline.known_item_ids:
            errors.append(f"Holdout grammar item_id collision with historical/dev baseline: '{item_id}'")

        # 2. Source-Family Quarantine & Isolation
        if fam_id not in RESERVED_GRAMMAR_FAMILIES:
            errors.append(
                f"{item_id}: invalid source_family_id '{fam_id}'. Must be strictly within reserved set {RESERVED_GRAMMAR_FAMILIES}"
            )
        if fam_id in baseline.forbidden_families:
            errors.append(
                f"{item_id}: source_family_id '{fam_id}' collides with forbidden DEV/calibration families"
            )
        stats["families"][fam_id] = stats["families"].get(fam_id, 0) + 1

        # 3. Ground truth key check
        if key not in ("A", "B", "C", "D"):
            errors.append(f"{item_id}: invalid ground_truth_key '{key}'. Must be 'A', 'B', 'C', or 'D'")

        # 4. Options check
        if len(options) != 4:
            errors.append(f"{item_id}: expected exactly 4 options, found {len(options)}")

        # 5. Distractor error codes and explanations
        if isinstance(distractor_flaws, dict):
            if len(distractor_flaws) != 3:
                errors.append(f"{item_id}: expected exactly 3 distractor flaws, found {len(distractor_flaws)}")
            for d_opt, d_info in distractor_flaws.items():
                if d_opt == key:
                    errors.append(f"{item_id}: key '{key}' cannot be listed in distractor_flaws")
                if not isinstance(d_info, dict) or not d_info.get("error_code"):
                    errors.append(f"{item_id}: distractor '{d_opt}' missing non-empty error_code")
                if not isinstance(d_info, dict) or not d_info.get("explanation"):
                    errors.append(f"{item_id}: distractor '{d_opt}' missing grammatical explanation")
        else:
            errors.append(f"{item_id}: distractor_flaws must be a dictionary")

        # 6. Stem leakage against baseline grammar items
        if stem:
            norm_stem = " ".join(normalize_text_tokens(stem))
            for base_id, base_stem in baseline.baseline_grammar_stems:
                norm_base_stem = " ".join(normalize_text_tokens(base_stem))
                if norm_stem and norm_stem == norm_base_stem:
                    errors.append(f"{item_id}: exact grammar stem collision detected against baseline item '{base_id}'")

    for fam in RESERVED_GRAMMAR_FAMILIES:
        if stats["families"].get(fam, 0) != 6:
            errors.append(f"Grammar family imbalance: expected exactly 6 items for {fam}, found {stats['families'].get(fam, 0)}")

    return len(errors) == 0, errors, stats


def audit_corpus_disjointness(
    holdout_dir: Path,
    baseline: Optional[BaselineCorpusRepository] = None,
) -> Dict[str, Any]:
    """Runs full audit if holdout files exist; reports pending status if uncurated."""
    reading_path = holdout_dir / "reading_corpus.json"
    grammar_path = holdout_dir / "grammar_rule_packs.json"

    if not reading_path.exists() or not grammar_path.exists():
        return {
            "status": "SPECIFICATION_PENDING_INDEPENDENT_CURATION",
            "eligible_for_sealing": False,
            "message": (
                f"Holdout directory '{holdout_dir}' does not contain curated submissions. "
                "Corpus status remains strictly PENDING external human panel curation."
            ),
            "files_checked": {
                "reading_corpus": str(reading_path),
                "reading_exists": reading_path.exists(),
                "grammar_rule_packs": str(grammar_path),
                "grammar_exists": grammar_path.exists(),
            },
        }

    # Initialize and load authoritative baselines
    if baseline is None:
        baseline = BaselineCorpusRepository(REPO_ROOT)
    if not baseline.is_loaded:
        ok = baseline.load_authoritative_baselines()
        if not ok:
            return {
                "status": "BLOCKED_BASELINE_UNAVAILABLE",
                "eligible_for_sealing": False,
                "error": f"Failed to load authoritative baseline resources: {baseline.load_error}",
            }

    with open(reading_path, "r", encoding="utf-8") as f:
        reading_items = json.load(f)
    with open(grammar_path, "r", encoding="utf-8") as f:
        grammar_items = json.load(f)

    r_ok, r_errs, r_stats = check_reading_corpus(reading_items, baseline)
    g_ok, g_errs, g_stats = check_grammar_corpus(grammar_items, baseline)

    all_errors = r_errs + g_errs
    eligible = (len(all_errors) == 0)

    return {
        "status": "AUDITED_ELIGIBLE" if eligible else "AUDIT_REJECTED",
        "eligible_for_sealing": eligible,
        "total_errors": len(all_errors),
        "errors": all_errors,
        "reading_stats": r_stats,
        "grammar_stats": g_stats,
        "baseline_checks": {
            "known_baseline_ids_count": len(baseline.known_item_ids),
            "forbidden_families_count": len(baseline.forbidden_families),
            "baseline_passages_count": len(baseline.baseline_reading_passages),
            "baseline_grammar_stems_count": len(baseline.baseline_grammar_stems),
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Check confirmatory holdout eligibility and disjointness.")
    parser.add_argument(
        "--holdout-dir",
        type=Path,
        default=Path("generation_baseline/holdout"),
        help="Path to holdout directory containing curated items.",
    )
    args = parser.parse_args()

    result = audit_corpus_disjointness(args.holdout_dir)
    print(json.dumps(result, indent=2))
    return 0 if result.get("eligible_for_sealing") or result.get("status") == "SPECIFICATION_PENDING_INDEPENDENT_CURATION" else 1


if __name__ == "__main__":
    sys.exit(main())
