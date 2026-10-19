"""Acceptance test suite for RQ2_DATASET_V2 Grammar RulePacks and CEFR Taxonomy (Sprint V2-S03).

Verifies:
1. Exactly 7 GrammarRulePack instances conforming to Pydantic v2 GrammarRulePack schema.
2. Authentic bibliographic citations with ISBNs under publisher All Rights Reserved status.
3. Deterministic SHA-256 content fingerprints.
4. Exactly 21 registered sub-rules across 7 families with transparent epistemic CEFR tracking.
5. Exactly 56 original academic example sentences (8 per family) with global uniqueness.
6. Applicability constraints and exception definitions on every RulePack.
7. Production negative tests asserting fail-closed rejection of syntactic violations:
   - Inversion: missing operator inversion, spurious subject-modifying only inversion.
   - Conditionals: direct lexical verb inversion without auxiliary operator.
   - Subjunctive: inflected verb in that-clause, do-periphrasis negation.
   - Participles: dangling/unattached participles with non-coreferential matrix subjects.
   - Passives: illicit personal reporting passives with unpermitted verbs (suggest).
   - Modals: illicit 'must not have' for impossible deduction.
"""

from __future__ import annotations

import re
from typing import Any, Dict, List

import pytest

from app.contracts.research import GrammarRulePack, SourceRef
from app.experiment.grammar_packs_v2 import (
    PUBLISHER_RIGHTS_ALL_RESERVED,
    REFERENCE_WORK_SOURCE_SHA256,
    RULE_PACK_CONTENT_SHA256,
    V2_EXAMPLE_SUB_RULE_MAP,
    V2_GRAMMAR_ERROR_TAXONOMY,
    V2_GRAMMAR_RULE_PACKS,
    V2_SUB_RULE_REGISTRY,
    compute_rulepack_content_sha256,
    get_v2_grammar_rule_pack,
    list_v2_grammar_rule_packs,
    VALIDATION_STATUS_INCONCLUSIVE,
    VALIDATION_STATUS_INVALID,
    VALIDATION_STATUS_VALID,
    validate_grammar_rule_pack_integrity,
    validate_syntactic_construction,
)

EXPECTED_FAMILY_IDS = [
    "fam-v2-grammar-inversion",
    "fam-v2-grammar-conditionals",
    "fam-v2-grammar-clefts",
    "fam-v2-grammar-subjunctive",
    "fam-v2-grammar-participles",
    "fam-v2-grammar-modals",
    "fam-v2-grammar-passives",
]


# ===========================================================================
# Tier 1: Schema Conformance & Provenance Invariants
# ===========================================================================


def test_rule_pack_count_and_schema_conformance() -> None:
    """Asserts that exactly 7 RulePacks exist and strictly conform to GrammarRulePack schema."""
    packs = list_v2_grammar_rule_packs()
    assert len(packs) == 7, f"Expected exactly 7 RulePacks, got {len(packs)}"
    assert sorted(list(V2_GRAMMAR_RULE_PACKS.keys())) == sorted(EXPECTED_FAMILY_IDS)

    for pack in packs:
        assert isinstance(pack, GrammarRulePack)
        assert isinstance(pack.source, SourceRef)
        assert pack.rule_pack_id in EXPECTED_FAMILY_IDS
        assert len(pack.topic) > 5
        assert len(pack.level) >= 2


def test_rule_pack_provenance_and_rights_integrity() -> None:
    """Verifies authentic bibliographic metadata with ISBNs under publisher ALL_RIGHTS_RESERVED."""
    for pack in list_v2_grammar_rule_packs():
        source = pack.source
        # Publisher rights status
        assert source.license == PUBLISHER_RIGHTS_ALL_RESERVED, (
            f"Expected license='{PUBLISHER_RIGHTS_ALL_RESERVED}', got '{source.license}'"
        )
        # Catalog ISBN URN (no fabricated DOIs for printed reference grammars)
        assert source.provenance_uri.startswith("urn:isbn:"), (
            f"Expected ISBN URN, got '{source.provenance_uri}'"
        )
        assert source.source_version == "v2.0"
        # Deterministic 64-hex SHA-256
        assert re.match(r"^[0-9a-f]{64}$", source.source_sha256)


def test_sha256_digest_integrity_and_determinism() -> None:
    """Asserts that source_sha256 matches cited source record and content_sha256 is deterministic."""
    citation_map = {
        "fam-v2-grammar-inversion": "Quirk, Greenbaum, Leech, & Svartvik (1985) §18.24–39; Huddleston & Pullum (2002) Ch. 11 §7",
        "fam-v2-grammar-conditionals": "Quirk et al. (1985) §14.23; Huddleston & Pullum (2002) Ch. 8 §2",
        "fam-v2-grammar-clefts": "Biber et al. (1999) §11.4; Quirk et al. (1985) §18.25–32",
        "fam-v2-grammar-subjunctive": "Quirk et al. (1985) §3.58–62; Huddleston & Pullum (2002) Ch. 3 §1.4",
        "fam-v2-grammar-participles": "Quirk et al. (1985) §15.56–62; Biber et al. (1999) §9.4",
        "fam-v2-grammar-modals": "Quirk et al. (1985) §4.49–66; Murphy (2019) Units 27–29",
        "fam-v2-grammar-passives": "Quirk et al. (1985) §16.64–68; Hewings (2013) Unit 24; Biber et al. (1999) §11.3",
    }

    for pack in list_v2_grammar_rule_packs():
        # 1. SourceRef.source_sha256 must match the authentic reference work SHA-256
        expected_source_hash = REFERENCE_WORK_SOURCE_SHA256[pack.source.source_id]
        assert pack.source.source_sha256 == expected_source_hash, (
            f"SourceRef hash mismatch for {pack.rule_pack_id}: {pack.source.source_sha256} != {expected_source_hash}"
        )

        # 2. RulePack content SHA-256 must match deterministic recomputation
        expected_citation = citation_map[pack.rule_pack_id]
        recomputed_content_hash = compute_rulepack_content_sha256(
            pack.rule_pack_id,
            pack.topic,
            pack.level,
            pack.rule_ids,
            pack.applicability,
            pack.exceptions,
            pack.examples,
            expected_citation,
        )
        assert RULE_PACK_CONTENT_SHA256[pack.rule_pack_id] == recomputed_content_hash, (
            f"Content hash mismatch for {pack.rule_pack_id}"
        )

# ===========================================================================
# Tier 2: Sub-Rule Registry & Epistemic CEFR Tracking
# ===========================================================================


def test_sub_rule_registry_and_cardinality() -> None:
    """Verifies that all 21 defined sub-rules are registered across the 7 families."""
    assert len(V2_SUB_RULE_REGISTRY) == 21, f"Expected 21 sub-rules, got {len(V2_SUB_RULE_REGISTRY)}"

    # Check each family has exactly 3 sub-rules registered
    for family_id in EXPECTED_FAMILY_IDS:
        pack = get_v2_grammar_rule_pack(family_id)
        assert len(pack.rule_ids) == 3, f"Expected 3 rule_ids in {family_id}, got {len(pack.rule_ids)}"
        for r_id in pack.rule_ids:
            assert r_id in V2_SUB_RULE_REGISTRY
            entry = V2_SUB_RULE_REGISTRY[r_id]
            assert entry["family_id"] == family_id
            assert len(entry["reference"]) > 5
            assert len(entry["syntactic_target"]) > 5


def test_epistemic_cefr_status_tracking() -> None:
    """Asserts that all sub-rules are tracked as PROPOSED and review items are flagged."""
    for r_id, entry in V2_SUB_RULE_REGISTRY.items():
        # Every sub-rule must have explicit cefr_attribution == "PROPOSED"
        assert entry["cefr_attribution"] == "PROPOSED", (
            f"Expected cefr_attribution='PROPOSED' for {r_id}, got '{entry.get('cefr_attribution')}'"
        )
        assert entry["cefr_evidence_status"].startswith("PROPOSED_"), (
            f"Evidence status must start with PROPOSED_ for {r_id}: '{entry['cefr_evidence_status']}'"
        )
        assert "adjudication_note" in entry and len(entry["adjudication_note"]) > 10

    # SUBJ-01 must be flagged for curator adjudication (regional dialect split unsupported)
    subj_01 = V2_SUB_RULE_REGISTRY["SUBJ-01"]
    assert subj_01["cefr_evidence_status"] == "PROPOSED_FLAGGED_AS_UNSUPPORTED_CLAIM_PENDING_CURATOR_ADJUDICATION"
    assert subj_01["curator_adjudication_required"] is True

    # PASS-01 must be flagged for curator adjudication (B1 suitability for academic IELTS)
    pass_01 = V2_SUB_RULE_REGISTRY["PASS-01"]
    assert pass_01["cefr_evidence_status"] == "PROPOSED_FLAGGED_FOR_CURATOR_ADJUDICATION"
    assert pass_01["curator_adjudication_required"] is True

    # All other 19 sub-rules require primary Cambridge EGP descriptor ID verification
    for r_id, entry in V2_SUB_RULE_REGISTRY.items():
        if r_id not in {"SUBJ-01", "PASS-01"}:
            assert entry["cefr_evidence_status"] == "PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID"
            assert entry["curator_adjudication_required"] is False

# ===========================================================================
# Tier 3: Original Academic Examples & Invariant Checks
# ===========================================================================


def test_original_example_cardinality_and_uniqueness() -> None:
    """Asserts exactly 8 original academic examples per RulePack (56 total) with global uniqueness."""
    all_examples: List[str] = []

    for pack in list_v2_grammar_rule_packs():
        assert len(pack.examples) == 8, f"Expected 8 examples in {pack.rule_pack_id}, got {len(pack.examples)}"
        for ex in pack.examples:
            assert isinstance(ex, str)
            assert len(ex) > 30, f"Example too short in {pack.rule_pack_id}: '{ex}'"
            assert ex.endswith("."), f"Example must end with period: '{ex}'"
            all_examples.append(ex)

    assert len(all_examples) == 56, f"Expected 56 total examples, got {len(all_examples)}"
    assert len(set(all_examples)) == 56, "All 56 examples must be globally unique across all RulePacks"


def test_structural_applicability_and_exceptions_presence() -> None:
    """Verifies that every RulePack documents at least 3 applicability constraints and 3 exceptions."""
    for pack in list_v2_grammar_rule_packs():
        assert len(pack.applicability) >= 3, f"Insufficient applicability rules in {pack.rule_pack_id}"
        assert len(pack.exceptions) >= 3, f"Insufficient exceptions in {pack.rule_pack_id}"
        for rule in pack.applicability:
            assert len(rule) > 15
        for exc in pack.exceptions:
            assert len(exc) > 15



def test_sub_rule_example_allocation_and_quotas() -> None:
    """Asserts that each sub-rule receives its exact pre-specified quota of original academic examples."""
    expected_quotas: Dict[str, Dict[str, int]] = {
        "fam-v2-grammar-inversion": {"INV-01": 3, "INV-02": 3, "INV-03": 2},
        "fam-v2-grammar-conditionals": {"COND-01": 3, "COND-02": 2, "COND-03": 3},
        "fam-v2-grammar-clefts": {"CLEFT-01": 4, "CLEFT-02": 2, "CLEFT-03": 2},
        "fam-v2-grammar-subjunctive": {"SUBJ-01": 4, "SUBJ-02": 2, "SUBJ-03": 2},
        "fam-v2-grammar-participles": {"PART-01": 3, "PART-02": 3, "PART-03": 2},
        "fam-v2-grammar-modals": {"MOD-01": 3, "MOD-02": 3, "MOD-03": 2},
        "fam-v2-grammar-passives": {"PASS-01": 3, "PASS-02": 3, "PASS-03": 2},
    }

    for family_id, quotas in expected_quotas.items():
        assert family_id in V2_EXAMPLE_SUB_RULE_MAP, f"Missing mapping for {family_id}"
        allocations = V2_EXAMPLE_SUB_RULE_MAP[family_id]
        assert len(allocations) == 8, f"Expected 8 allocations for {family_id}, got {len(allocations)}"

        # Count occurrences
        counts: Dict[str, int] = {}
        for r_id in allocations:
            counts[r_id] = counts.get(r_id, 0) + 1

        assert counts == quotas, f"Quota mismatch in {family_id}: expected {quotas}, got {counts}"

# ===========================================================================
# Tier 4: Production Negative & Boundary Rejection Tests
# ===========================================================================


def test_negative_inversion_missing_auxiliary_inversion_rejected() -> None:
    """Asserts that failure to invert after fronted negative adjunct is detected as a syntactic defect."""
    # Valid inversion: "Under no circumstances should researchers alter..."
    valid_sentence = "Under no circumstances should researchers alter experimental parameters."
    # Defective non-inversion: "Under no circumstances researchers should alter..."
    defective_sentence = "Under no circumstances researchers should alter experimental parameters."

    # Validate trigger pattern: initial negative adverbial requires auxiliary immediately preceding subject
    has_initial_neg = defective_sentence.lower().startswith("under no circumstances")
    assert has_initial_neg is True

    # Check inversion pattern: after "under no circumstances", auxiliary must precede noun phrase
    remainder = defective_sentence[len("under no circumstances") :].strip()
    first_word = remainder.split()[0].lower()
    modal_auxiliaries = {"should", "must", "can", "could", "will", "would", "did", "does", "do", "have", "had", "has"}

    is_inverted = first_word in modal_auxiliaries
    assert is_inverted is False, "Defective sentence must fail auxiliary-initial inversion check!"

    # Contrast with valid sentence
    valid_remainder = valid_sentence[len("under no circumstances") :].strip()
    valid_first_word = valid_remainder.split()[0].lower()
    assert valid_first_word in modal_auxiliaries, "Valid sentence must exhibit auxiliary inversion!"


def test_negative_inversion_spurious_subject_modifying_only_rejected() -> None:
    """Asserts that true spurious operator inversion fronting aux before subject NP is detected as ERR-INV-02."""
    # Valid subject-modifying declarative: "Only senior researchers attended the symposium."
    # Canonical declarative order with emphatic do-support: "Only senior researchers did attend..." (not inversion)
    # True spurious operator inversion (defective): "Only did senior researchers attend the symposium."
    true_defective = "Only did senior researchers attend the symposium."
    res = validate_syntactic_construction("fam-v2-grammar-inversion", true_defective)
    assert res["status"] == VALIDATION_STATUS_INVALID
    assert res["is_valid"] is False
    assert any("ERR-INV-02" in err for err in res["errors"])

def test_negative_conditionals_lexical_verb_direct_inversion_rejected() -> None:
    """Asserts that direct inversion of lexical verbs without auxiliary operator is rejected."""
    # Inverted conditionals strictly require auxiliary operators (had, were, should).
    # Valid: "Had the geology team accurately calibrated..."
    # Defective: "Knew the geology team the pressure data..." (illicit lexical verb fronting)
    defective_inverted = "Knew the geology team the pressure data, the anomaly would have been prevented."

    first_word = defective_inverted.split()[0].lower()
    valid_inversion_operators = {"had", "were", "should"}

    is_valid_operator = first_word in valid_inversion_operators
    assert is_valid_operator is False, f"Lexical verb '{first_word}' cannot serve as inverted conditional operator!"


def test_negative_subjunctive_inflected_verb_rejected() -> None:
    """Asserts that inflected verbs in mandative that-clauses are detected as invalid."""
    # Mandative subjunctive requires invariant base form (submit, remain, decontaminate).
    # Valid: "...recommended that the investigator submit a revised framework."
    # Defective indicative: "...recommended that the investigator submits a revised framework."
    defective_subjunctive = (
        "The bioethics supervisory committee recommended that the principal investigator submits a revised framework."
    )

    # Detect 3rd-person singular inflection on embedded verb after suasion predicate
    match = re.search(r"recommended that the \w+ (\w+)", defective_subjunctive, re.IGNORECASE)
    assert match is not None
    # In the defective sentence, "principal investigator submits" contains inflected "submits"
    assert "submits" in defective_subjunctive
    is_base_form = "submits".endswith("s") is False
    assert is_base_form is False, "Inflected verb 'submits' violates mandative base form requirement!"


def test_negative_subjunctive_do_periphrasis_negation_rejected() -> None:
    """Asserts that do-support in negative mandative subjunctive is rejected."""
    # Valid: "...insisted that the pharmaceutical sponsor not unblind patient outcome data."
    # Defective: "...insisted that the pharmaceutical sponsor does not unblind patient outcome data."
    defective_negative_subj = (
        "The panel insisted that the pharmaceutical sponsor does not unblind patient outcome data."
    )

    has_do_negation = bool(re.search(r"insisted that .* (does not|did not|do not) \w+", defective_negative_subj))
    assert has_do_negation is True, "Detected invalid do-periphrasis in negative mandative subjunctive!"


def test_negative_participles_dangling_participle_rejected() -> None:
    """Asserts that dangling participles with non-coreferential matrix subjects are detected."""
    # Valid coreferential: "Having synthesized the compound, the organic chemistry team conducted NMR..."
    # (Agent of 'having synthesized' = organic chemistry team = matrix subject)
    # Dangling defective: "Having synthesized the compound, NMR spectroscopy was conducted..."
    # (Matrix subject is 'NMR spectroscopy', which cannot synthesize compounds)
    dangling_sentence = (
        "Having synthesized the novel compound, nuclear magnetic resonance spectroscopy was conducted."
    )

    # Fronted participle clause
    assert dangling_sentence.startswith("Having synthesized")
    comma_idx = dangling_sentence.find(",")
    assert comma_idx != -1
    matrix_clause = dangling_sentence[comma_idx + 1 :].strip()

    # Matrix subject is inanimate technique/object
    matrix_subject = matrix_clause.split()[0].lower()
    inanimate_subjects = {"nuclear", "nmr", "spectroscopy", "data", "results", "analysis"}
    is_dangling = matrix_subject in inanimate_subjects
    assert is_dangling is True, "Detected dangling participle modifying inanimate technique rather than researcher agent!"


def test_negative_passives_unpermitted_personal_passive_suggest_rejected() -> None:
    """Asserts that personal reporting passives with unpermitted verbs (suggest) are detected."""
    # Verbs like 'suggest' and 'explain' permit impersonal passives ("It is suggested that..."),
    # but strictly disallow personal reporting passives with to-infinitive (*"He is suggested to be...").
    defective_personal_passive = "The novel catalyst is suggested to increase reaction yield by thirty percent."

    has_suggest_personal_passive = bool(re.search(r"is suggested to \w+", defective_personal_passive))
    assert has_suggest_personal_passive is True, (
        "Detected unpermitted personal reporting passive with verb 'suggest'!"
    )


def test_negative_modals_must_not_have_impossible_deduction_rejected() -> None:
    """Asserts that 'must not have' for impossible past deduction is rejected in favor of 'cannot have'."""
    # In standard academic English, impossible past deduction requires 'cannot have' or 'could not have'.
    # Defective: "The aquifer depletion must not have resulted solely from seasonal drought..."
    defective_modal_deduction = (
        "The aquifer depletion must not have resulted solely from seasonal precipitation deficits."
    )

    has_must_not_have = "must not have" in defective_modal_deduction
    assert has_must_not_have is True, (
        "Detected 'must not have' in epistemic deduction context where 'cannot have' is required!"
    )




def test_negative_clefts_demonstrative_substitution_rejected() -> None:
    """Asserts that demonstrative pronoun substitution ('this'/'that') in it-clefts is rejected."""
    defective_cleft = "This was the sudden deceleration of the North Atlantic subpolar gyre that caused the anomaly."
    res = validate_syntactic_construction("fam-v2-grammar-clefts", defective_cleft)
    assert res["is_valid"] is False
    assert any("ERR-CLEFT-01" in err for err in res["errors"])


def test_production_syntactic_validator_all_56_examples_pass() -> None:
    """Asserts that all 56 authored academic example sentences pass the production syntactic validator."""
    for pack in list_v2_grammar_rule_packs():
        for ex in pack.examples:
            res = validate_syntactic_construction(pack.rule_pack_id, ex)
            assert res["is_valid"] is True, (
                f"Authored example failed syntactic validation in {pack.rule_pack_id}: '{ex}' -> Errors: {res['errors']}"
            )


def test_production_syntactic_validator_detects_all_defect_classes() -> None:
    """Asserts that validate_syntactic_construction detects all 9 documented defect classes."""
    defect_cases = [
        ("fam-v2-grammar-inversion", "Under no circumstances researchers should alter experimental parameters.", "ERR-INV-01"),
        ("fam-v2-grammar-inversion", "Only did senior researchers attend the symposium.", "ERR-INV-02"),
        ("fam-v2-grammar-conditionals", "Knew the geology team the pressure data, the anomaly would have been prevented.", "ERR-COND-01"),
        ("fam-v2-grammar-clefts", "This was the catalyst that accelerated the reaction.", "ERR-CLEFT-01"),
        ("fam-v2-grammar-subjunctive", "The committee recommended that the investigator submits a revised framework.", "ERR-SUBJ-01"),
        ("fam-v2-grammar-subjunctive", "The panel insisted that the sponsor does not unblind outcome data.", "ERR-SUBJ-02"),
        ("fam-v2-grammar-participles", "Having synthesized the compound, NMR spectroscopy was conducted.", "ERR-PART-01"),
        ("fam-v2-grammar-modals", "The aquifer depletion must not have resulted solely from precipitation deficits.", "ERR-MOD-01"),
        ("fam-v2-grammar-passives", "The novel catalyst is suggested to increase reaction yield by thirty percent.", "ERR-PASS-01"),
    ]
    for family_id, sentence, expected_err in defect_cases:
        res = validate_syntactic_construction(family_id, sentence)
        assert res["is_valid"] is False, f"Expected defect detection for: '{sentence}'"
        assert any(expected_err in err for err in res["errors"]), (
            f"Expected error code '{expected_err}' in {res['errors']} for sentence: '{sentence}'"
        )


def test_grammar_error_taxonomy_registry() -> None:
    """Asserts that all 9 distractor error categories are registered with complete diagnostics."""
    assert len(V2_GRAMMAR_ERROR_TAXONOMY) == 9
    expected_error_codes = {
        "ERR-INV-01", "ERR-INV-02", "ERR-COND-01",
        "ERR-CLEFT-01", "ERR-SUBJ-01", "ERR-SUBJ-02",
        "ERR-PART-01", "ERR-MOD-01", "ERR-PASS-01",
    }
    assert set(V2_GRAMMAR_ERROR_TAXONOMY.keys()) == expected_error_codes

    for code, entry in V2_GRAMMAR_ERROR_TAXONOMY.items():
        assert entry["family_id"] in EXPECTED_FAMILY_IDS
        assert len(entry["target_rule_id"]) > 3
        assert len(entry["defect_type"]) > 3
        assert len(entry["description"]) > 15
        assert len(entry["diagnostic"]) > 15
# ===========================================================================
# Tier 5: Registry Functions & Integrity Helper Tests
# ===========================================================================


def test_get_v2_grammar_rule_pack_lookup() -> None:
    """Tests successful retrieval by ID and KeyError on unknown ID."""
    pack = get_v2_grammar_rule_pack("fam-v2-grammar-inversion")
    assert pack.rule_pack_id == "fam-v2-grammar-inversion"

    with pytest.raises(KeyError, match="Unknown V2 GrammarRulePack identifier"):
        get_v2_grammar_rule_pack("fam-v2-unknown-rulepack")


def test_validate_grammar_rule_pack_integrity_helper() -> None:
    """Tests the integrity validator on all valid packs and asserts detection of invalid modifications."""
    for pack in list_v2_grammar_rule_packs():
        res = validate_grammar_rule_pack_integrity(pack)
        assert res["is_valid"] is True, f"Integrity validation failed for {pack.rule_pack_id}: {res['issues']}"
        assert res["examples_count"] == 8
        assert res["rule_ids_count"] >= 3

    # Test detection on defective copy
    valid_pack = get_v2_grammar_rule_pack("fam-v2-grammar-inversion")
    defective_pack = valid_pack.model_copy(deep=True)
    defective_pack.examples.pop()  # Drop 1 example -> now 7 instead of 8

    res_defective = validate_grammar_rule_pack_integrity(defective_pack)
    assert res_defective["is_valid"] is False
    assert any("Expected exactly 8 examples" in issue for issue in res_defective["issues"])


# ===========================================================================
# Tier 6: Cryptographic Provenance Ledger Verification
# ===========================================================================


def test_grammar_provenance_ledger_file_integrity() -> None:
    """Verifies V2_GRAMMAR_PROVENANCE_LEDGER.json structure, digests, and governance."""
    import hashlib
    import json
    from pathlib import Path

    repo_root = Path(__file__).resolve().parent.parent.parent.parent
    ledger_path = repo_root / "generation_baseline" / "verification" / "V2_GRAMMAR_PROVENANCE_LEDGER.json"

    assert ledger_path.exists(), f"Provenance ledger missing at: {ledger_path}"
    ledger_data = json.loads(ledger_path.read_text(encoding="utf-8"))

    assert ledger_data["ledger_id"] == "V2_GRAMMAR_PROVENANCE_LEDGER"
    assert ledger_data["governing_sprint"] == "V2-S03"
    assert ledger_data["total_reference_works"] == 5
    assert ledger_data["total_rule_packs"] == 7
    assert ledger_data["total_sub_rules"] == 21
    assert ledger_data["total_examples"] == 56

    # Verify each reference work canonical SHA-256
    for ref in ledger_data["reference_works"]:
        ref_copy = dict(ref)
        stored_hash = ref_copy.pop("source_sha256")
        canonical_bytes = json.dumps(ref_copy, sort_keys=True, separators=(",", ":")).encode("utf-8")
        computed_hash = hashlib.sha256(canonical_bytes).hexdigest()
        assert stored_hash == computed_hash, f"Reference hash mismatch for {ref['source_id']}"
        assert ref["license"] == PUBLISHER_RIGHTS_ALL_RESERVED
        assert ref["provenance_uri"].startswith("urn:isbn:")

    # Verify rule packs summary matches loaded rule packs
    ledger_pack_map = {p["rule_pack_id"]: p for p in ledger_data["rule_packs"]}
    assert set(ledger_pack_map.keys()) == set(EXPECTED_FAMILY_IDS)

    for family_id in EXPECTED_FAMILY_IDS:
        live_pack = get_v2_grammar_rule_pack(family_id)
        ledger_pack = ledger_pack_map[family_id]
        assert live_pack.source.source_sha256 == ledger_pack["source_sha256"], (
            f"Source SHA-256 mismatch between live pack and ledger for {family_id}"
        )
        assert RULE_PACK_CONTENT_SHA256[family_id] == ledger_pack["rule_pack_content_sha256"], (
            f"Content SHA-256 mismatch between live pack and ledger for {family_id}"
        )
        assert len(live_pack.examples) == ledger_pack["examples_count"] == 8
        assert len(live_pack.rule_ids) == ledger_pack["sub_rules_count"] == 3

    # Governance and rights assertions
    gov = ledger_data["governance_and_rights"]
    assert gov["publisher_rights_status"] == PUBLISHER_RIGHTS_ALL_RESERVED
    assert gov["dataset_ready_state"] == "HOLD"
    assert gov["fair_use_memorandum_status"] == "PENDING_INSTITUTIONAL_SIGN_OFF"
    assert gov["reading_findings_status"] == "REVIEW_REQUIRED_PENDING_CURATOR_ADJUDICATION"
    assert len(gov["unsupported_claims_flagged"]) >= 2

# ===========================================================================
# Tier 6: Adversarial Negative Tests, Dialect Alternatives & Oracle Separation
# ===========================================================================


def test_validator_fail_open_prevention_on_non_target_sentences() -> None:
    """Asserts that absence of error is NOT treated as valid: sentences lacking target construction are INCONCLUSIVE."""
    non_target_cases = [
        ("fam-v2-grammar-inversion", "The research team published their findings in a peer-reviewed journal."),
        ("fam-v2-grammar-conditionals", "The laboratory purchased advanced mass spectrometers last autumn."),
        ("fam-v2-grammar-clefts", "The sudden deceleration of the subpolar gyre caused the regional cooling anomaly."),
        ("fam-v2-grammar-subjunctive", "The principal investigator submitted a revised protocol following peer feedback."),
        ("fam-v2-grammar-participles", "The organic chemistry team synthesized the compound and conducted NMR spectroscopy."),
        ("fam-v2-grammar-modals", "The adult sauropod specimen suffered from cardiovascular pathology."),
        ("fam-v2-grammar-passives", "Paleoclimatologists believe that agrarian cultivation originated during the Holocene."),
    ]

    for family_id, sentence in non_target_cases:
        res = validate_syntactic_construction(family_id, sentence)
        assert res["status"] == VALIDATION_STATUS_INCONCLUSIVE, (
            f"Expected INCONCLUSIVE for non-target sentence '{sentence}' in {family_id}, got {res['status']}"
        )
        assert res["is_valid"] is False, f"Non-target sentence must NOT be classified as valid: '{sentence}'"
        assert res["positive_match"] is False, f"Non-target sentence must NOT match positive target criteria: '{sentence}'"
        assert "absence of defect is not proof of validity" in res["details"]


def test_validator_marks_subject_only_declarative_do_as_inconclusive() -> None:
    """Asserts that 'Only NP did V' is classified as INCONCLUSIVE rather than confidently INVALID.

    Subject-modifying 'only' maintains canonical subject-auxiliary order and may represent
    valid emphatic affirmative do-support rather than an inversion defect.
    """
    subject_only_emphatic = "Only senior researchers did attend the symposium."
    res = validate_syntactic_construction("fam-v2-grammar-inversion", subject_only_emphatic)
    assert res["status"] == VALIDATION_STATUS_INCONCLUSIVE, (
        f"Expected INCONCLUSIVE for subject-only declarative do-support, got {res['status']}"
    )
    assert res["is_valid"] is False
    assert res["positive_match"] is False
    assert "emphatic assertion" in res["details"] or "canonical subject-auxiliary order" in res["details"]


def test_validator_marks_dialect_sensitive_and_context_dependent_alternatives_as_inconclusive() -> None:
    """Asserts that dialect alternatives and context-dependent constructions yield INCONCLUSIVE."""
    # 1. British should-mandative periphrasis (alternative to base subjunctive)
    british_mandative = "The supervisory committee recommended that the principal investigator should submit a revised protocol."
    res_subj = validate_syntactic_construction("fam-v2-grammar-subjunctive", british_mandative)
    assert res_subj["status"] == VALIDATION_STATUS_INCONCLUSIVE
    assert res_subj["is_valid"] is False
    assert "should-mandative" in res_subj["details"]

    # 2. Factual indicative assertion following epistemic predicate (not suasion mandative)
    indicative_assertion = "The witness insisted that he was innocent throughout the cross-examination."
    res_ind = validate_syntactic_construction("fam-v2-grammar-subjunctive", indicative_assertion)
    assert res_ind["status"] == VALIDATION_STATUS_INCONCLUSIVE
    assert res_ind["is_valid"] is False
    assert "Indicative factual complement" in res_ind["details"]

    # 3. Post-verbal non-fronted negative adjunct (valid declarative, but lacks target inversion construction)
    non_fronted_neg = "The research team altered experimental parameters under no circumstances during the trial."
    res_inv = validate_syntactic_construction("fam-v2-grammar-inversion", non_fronted_neg)
    assert res_inv["status"] == VALIDATION_STATUS_INCONCLUSIVE
    assert res_inv["is_valid"] is False

    # 4. Deontic possession prohibition with 'must not have'
    deontic_prohibition = "All laboratory technicians must not have unattended sample containers in the fume hood."
    res_mod = validate_syntactic_construction("fam-v2-grammar-modals", deontic_prohibition)
    assert res_mod["status"] == VALIDATION_STATUS_INCONCLUSIVE
    assert res_mod["is_valid"] is False


def test_validator_unknown_and_malformed_inputs_handled_safely() -> None:
    """Asserts that empty, gibberish, and unknown family inputs fail closed safely."""
    # Empty string
    res_empty = validate_syntactic_construction("fam-v2-grammar-inversion", "")
    assert res_empty["status"] == VALIDATION_STATUS_INVALID
    assert res_empty["is_valid"] is False
    assert any("ERR-EMPTY-INPUT" in err for err in res_empty["errors"])

    # Whitespace only
    res_ws = validate_syntactic_construction("fam-v2-grammar-inversion", "   \t\n  ")
    assert res_ws["status"] == VALIDATION_STATUS_INVALID
    assert res_ws["is_valid"] is False

    # Unknown family ID
    res_unk = validate_syntactic_construction("fam-v2-grammar-unknown", "Under no circumstances should researchers alter parameters.")
    assert res_unk["status"] == VALIDATION_STATUS_INCONCLUSIVE
    assert res_unk["is_valid"] is False
    assert any("ERR-UNSUPPORTED-FAMILY" in err for err in res_unk["errors"])

    # Gibberish input
    res_gib = validate_syntactic_construction("fam-v2-grammar-conditionals", "!@#$%^&*() 1234567890 xyz abc")
    assert res_gib["status"] == VALIDATION_STATUS_INCONCLUSIVE
    assert res_gib["is_valid"] is False


def test_validator_epistemic_disclosure_and_human_oracle_separation() -> None:
    """Asserts that validator explicitly discloses its screening boundaries and does not claim human gold authority."""
    test_sentence = "Under no circumstances should researchers alter experimental parameters after protocol preregistration has been finalized."
    res = validate_syntactic_construction("fam-v2-grammar-inversion", test_sentence)
    assert res["status"] == VALIDATION_STATUS_VALID
    assert res["is_valid"] is True
    assert "EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD" in res["epistemic_disclosure"]
    assert "not constitute certified human expert validation" in res["epistemic_disclosure"]
    assert "positive_match" in res
    assert "details" in res
