# Confirmatory Holdout Protocol and Freeze Specification (RG10 Phase E)

**Status:** SPECIFICATION_PENDING_INDEPENDENT_CURATION  
**Date:** 2026-10-16  
**Governing Standard:** `generation_baseline/research/DATA_GOVERNANCE.md` & `RQ2_PROTOCOL.md`  

---

## 1. Purpose and Independence Invariants

To eliminate evaluation leakage and circular prompt/evaluator tuning, confirmatory hypothesis testing for the final research paper (RQ1 / RQ2) requires an uninspected, independently curated holdout corpus.

### Inviolable Governance Rules
1. **Uninspected Labels:** Neither developers, prompts, generators, nor evaluators may open, inspect, or tune against holdout items during development.
2. **Source-Family Isolation & Leakage Checks:** Holdout passages and rule packs must originate from quarantined, distinct source families completely isolated from any development or calibration source families. Passages and items must pass exact and near-duplicate leakage checks (e.g. 3-gram shingle Jaccard similarity < 0.3) against all development and calibration texts (replacing impossible zero-lexical-overlap rules with rigorous source-family isolation and empirical shingle leakage bounds).
3. **Single-Flight Evaluation:** Confirmatory evaluation is executed exactly once upon research freeze unsealing. Multiple evaluation runs with retrospective prompt or heuristic adjustments are strictly forbidden.
4. **Cryptographic Sealing Prerequisites:** The dataset item IDs, canonical content hashes, source provenance, and curator attestations must be provided by an external panel before cryptographic SHA-256 seals are generated. All seals remain `null` until real curated content is hashed.
5. **Synthetic Data Prohibition:** Under no circumstances may developers or automated pipelines generate synthetic holdout items and label them as independently curated. All holdout items must originate exclusively from verified external human panel sources.
6. **Corpus Separation & Role Clarification:** The 30-item Judge Holdout corpus specified herein serves exclusively for post-freeze evaluator reliability assessment (measuring post-freeze False Rejection Rate [FRR], False Acceptance Rate [FAR], and abstention rate). It is strictly forbidden to use the judge holdout for additional threshold tuning, parameter optimization, or heuristic calibration. Furthermore, the 30-item Judge Holdout is distinct from, and cannot substitute for or overlap with, the 25–40 paired benchmark tasks per domain (150–240 arm assignments) required for RQ2 hypothesis testing (`FINAL_EVAL`).

---

## 2. Source-Family Disjointness Matrix

The following source families are strictly reserved for the Confirmatory Judge Holdout and are quarantined from all DEV and calibration pipelines:

| Domain | Reserved Source Family ID | Topic / Structure | Quarantined From | Status |
|---|---|---|---|---|
| **READING** | `fam-astrophysics-pulsar-08` | Millisecond Pulsar Magnetospheres & Relativistic Plasma | All DEV (`fam-botany-*`, `fam-oceanography-*`) | **RESERVED_QUARANTINED** |
| **READING** | `fam-paleontology-cambrian-09` | Burgess Shale Arthropod Radiation & Taphonomy | All DEV & Calibration splits | **RESERVED_QUARANTINED** |
| **GRAMMAR** | `fam-mood-subjunctive-08` | Mandative Subjunctive in Legal/Formal Registers | All DEV (`fam-linguistics-*`, `fam-syntax-*`) | **RESERVED_QUARANTINED** |
| **GRAMMAR** | `fam-aspect-participle-09` | Reduced Participle Clauses and Adverbial Qualification | All DEV & Calibration splits | **RESERVED_QUARANTINED** |

### Historical Holdout De-registration Disclosure
- `JUDGE_HOLDOUT_CORPUS` (historical 5-item split): Formally **`RETIRED`** as of 2026-10-16 due to prior inspection during v2.1 baseline audits.
- `FRESH_JUDGE_HOLDOUT_CORPUS_V2` (historical 5-item split): Formally designated **`INSPECTED_EXPLORATORY`** due to inspection during DEV calibration. It is ineligible for confirmatory freeze.

---

## 3. Holdout Stratification and Item Quota

The Confirmatory Judge Holdout corpus shall consist of exactly $N = 30$ balanced paired evaluation units:

1. **Reading Stratum ($n = 18$ questions)**:
   - 6 items: Strict Factual Entailment (TRUE)
   - 6 items: Explicit Factual Contradiction (FALSE)
   - 6 items: Unmentioned Topical Assertions (NOT GIVEN)
   - Balanced across both `fam-astrophysics-pulsar-08` and `fam-paleontology-cambrian-09`.
2. **Grammar Stratum ($n = 12$ questions)**:
   - 6 items: Mandative Subjunctive (`fam-mood-subjunctive-08`)
   - 6 items: Participle Clauses (`fam-aspect-participle-09`)
   - Requirement: Exactly 1 defensible option and 3 unambiguously ungrammatical distractors with documented syntactic error codes.

### Separation from RQ2 Experimental Corpus
- **Judge Holdout ($N = 30$ questions):** Post-freeze measurement of evaluator reliability, False Rejection Rate (FRR), False Acceptance Rate (FAR), and abstention rate. It is strictly designated for post-freeze reliability assessment, NOT for additional threshold tuning, parameter adjustment, prompt engineering, or heuristic fitting.
- **RQ2 Benchmark Tasks ($N = 25\text{--}40$ tasks per domain):** 25–40 Reading passages (with 1–2 question groups) and 25–40 Grammar rule sets evaluated across Arm A, Arm B, and Arm C ($N_{\text{total}} = 150\text{--}240$ arm-slot assignments) for research question hypothesis testing.

---

## 4. Pre-Sealing Protocol & Sealing Procedure

Sealing has **not** occurred. Before the holdout package can be cryptographically sealed, the independent curation panel must complete the following mandatory steps:

1. **External Human Curation:** The independent curation panel curates 30 items complying with the stratification quotas above.
2. **Item-Level Identification & Provenance:** Each curated item is assigned a permanent identifier (`curated_item_id`) and documented with source text citations, publication provenance, and analytical annotations.
3. **Canonical Serialization & Checksums:** Content is canonicalized (UTF-8, NFKC, deterministic key ordering) and cryptographic SHA-256 digests are computed:
   - `reading_corpus_sha256`
   - `grammar_rule_packs_sha256`
   - `manifest_integrity_sha256`
4. **Curator Attestation:** An authorized independent panel lead executes a signed attestation confirming zero developer inspection, zero prompt/evaluator tuning leakage, and verified provenance.
5. **Sealing Execution:** Only upon completion of steps 1–4 are cryptographic hashes committed to `CONFIRMATORY_HOLDOUT_MANIFEST.json` and status transitioned to `SEALED_UNINSPECTED`. Until that external event, all cryptographic seal fields remain `null`.
