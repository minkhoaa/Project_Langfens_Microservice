# Confirmatory Holdout Protocol and Freeze Specification (RG10 Phase E)

**Status:** SEALED SPECIFICATION — LABELS STRICTLY CLOSED  
**Date:** 2026-10-16  
**Governing Standard:** `generation_baseline/research/DATA_GOVERNANCE.md` & `RQ2_PROTOCOL.md`  

---

## 1. Purpose and Independence Invariants

To eliminate evaluation leakage and circular prompt/evaluator tuning, confirmatory hypothesis testing for the final research paper (RQ1 / RQ2) requires an uninspected, independently curated holdout corpus.

### Inviolable Governance Rules
1. **Uninspected Labels:** Neither developers, prompts, generators, nor evaluators may open, inspect, or tune against holdout items during development.
2. **Source-Family Disjointness:** Holdout passages and rule packs must originate from distinct source families with zero lexical, topical, or morphological overlap with any development split or calibration split.
3. **Single-Flight Evaluation:** Confirmatory evaluation is executed exactly once upon research freeze unsealing. Multiple evaluation runs with retrospective prompt or heuristic adjustments are strictly forbidden.
4. **Cryptographic Sealing:** The dataset item IDs, source text hashes, and task specifications are sealed via SHA256 digests prior to the campaign run.

---

## 2. Source-Family Disjointness Matrix

The following source families are strictly reserved for the Confirmatory Holdout and are quarantined from all DEV and calibration pipelines:

| Domain | Reserved Source Family ID | Topic / Structure | Quarantined From | Status |
|---|---|---|---|---|
| **READING** | `fam-astrophysics-pulsar-08` | Millisecond Pulsar Magnetospheres & Relativistic Plasma | All DEV (`fam-botany-*`, `fam-oceanography-*`) | **SEALED_RESERVED** |
| **READING** | `fam-paleontology-cambrian-09` | Burgess Shale Arthropod Radiation & Taphonomy | All DEV & Calibration splits | **SEALED_RESERVED** |
| **GRAMMAR** | `fam-mood-subjunctive-08` | Mandative Subjunctive in Legal/Formal Registers | All DEV (`fam-linguistics-*`, `fam-syntax-*`) | **SEALED_RESERVED** |
| **GRAMMAR** | `fam-aspect-participle-09` | Reduced Participle Clauses and Adverbial Qualification | All DEV & Calibration splits | **SEALED_RESERVED** |

### Historical Holdout De-registration Disclosure
- `JUDGE_HOLDOUT_CORPUS` (historical 5-item split): Formally **`RETIRED`** as of 2026-10-16 due to prior inspection during v2.1 baseline audits.
- `FRESH_JUDGE_HOLDOUT_CORPUS_V2` (historical 5-item split): Formally designated **`INSPECTED_EXPLORATORY`** due to inspection during DEV calibration. It is ineligible for confirmatory freeze.

---

## 3. Holdout Stratification and Item Quota

The Confirmatory Holdout corpus shall consist of exactly $N = 30$ balanced paired evaluation units:

1. **Reading Stratum ($n = 18$ questions)**:
   - 6 items: Strict Factual Entailment (TRUE)
   - 6 items: Explicit Factual Contradiction (FALSE)
   - 6 items: Unmentioned Topical Assertions (NOT GIVEN)
   - Balanced across both `fam-astrophysics-pulsar-08` and `fam-paleontology-cambrian-09`.
2. **Grammar Stratum ($n = 12$ questions)**:
   - 6 items: Mandative Subjunctive (`fam-mood-subjunctive-08`)
   - 6 items: Participle Clauses (`fam-aspect-participle-09`)
   - Requirement: Exactly 1 defensible option and 3 unambiguously ungrammatical distractors with documented syntactic error codes.

---

## 4. Cryptographic Freeze Manifest

Prior to unsealing the confirmatory campaign, the uninspected holdout dataset package shall be committed with the following cryptographic manifest:

```json
{
  "holdout_protocol_version": "v1.0-confirmatory",
  "sealed_at": "2026-10-16T10:00:00Z",
  "status": "SEALED_UNINSPECTED",
  "item_count": 30,
  "quarantine_attestation": {
    "zero_leakage_to_generators": true,
    "zero_pre_tuning_against_evaluators": true,
    "human_gold_labels_sealed": true
  },
  "dataset_checksum_sha256": "PENDING_EXTERNAL_PANEL_ENCRYPTION"
}
```
