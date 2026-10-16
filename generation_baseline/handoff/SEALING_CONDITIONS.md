# Explicit Conditions for Marking Confirmatory Holdout Corpus SEALED

**Phase:** RG10 Confirmatory Research Freeze  
**Document:** Cryptographic Sealing Criteria & Gate Policy  
**Governing Document:** `generation_baseline/research/CONFIRMATORY_HOLDOUT_SPECIFICATION.md`  

---

## 1. Governance Principle: Holdout Status Remains PENDING

Until all seven conditions specified in this protocol are verified by the independent repository auditor, the status of the confirmatory holdout corpus in `CONFIRMATORY_HOLDOUT_MANIFEST.json` must remain:

```json
"status": "SPECIFICATION_PENDING_INDEPENDENT_CURATION"
```

All cryptographic seal fields (`reading_corpus_sha256`, `grammar_rule_packs_sha256`, `manifest_integrity_sha256`) and all security attestation signatures must remain strictly `null`. It is a critical research violation to pre-compute hashes over placeholder templates, generate synthetic items, or populate dummy curator signatures.

---

## 2. The Seven Mandatory Sealing Conditions

Transitioning the manifest status to `"SEALED_UNINSPECTED"` requires meeting every one of the following seven conditions without exception:

### Condition 1: Verified Independent Human Provenance (No Synthetic Data)
- 100% of the 30 holdout items must originate from human experts on the contracted external review panel.
- Zero items, passages, stems, distractors, or answer keys may be produced, edited, or paraphrased using Large Language Models or automated generation scripts.
- Each item must include documented human curation sign-off and scholarly source citations.

### Condition 2: Complete Source Provenance & Lawful Licensing
- All source texts must trace to peer-reviewed scholarly journals, university press monographs, or authoritative reference grammars.
- Licensing status must be explicitly confirmed under Creative Commons (CC-BY, CC0), Public Domain, or documented academic research fair use.
- The `SOURCE_PROVENANCE_AND_LICENSING_CHECKLIST.md` must be completed and signed by the curation panel lead.

### Condition 3: Source-Family Isolation & Empirical Leakage Clearance
- Reading source texts must originate exclusively from `fam-astrophysics-pulsar-08` and `fam-paleontology-cambrian-09`.
- Grammar items must originate exclusively from `fam-mood-subjunctive-08` and `fam-aspect-participle-09`.
- The verification script `check_corpus_disjointness.py` must pass with:
  - Zero `item_id` collisions against any historical split.
  - Zero `source_family_id` collisions against DEV and calibration splits.
  - Maximum 3-gram shingle Jaccard similarity $< 0.30$ against all development and calibration passages (verifying zero exact or near-duplicate leakage).

### Condition 4: Exact Stratification & Balance Quota Compliance
- **Reading Stratum ($n = 18$ questions):**
  - Exactly 9 items from `fam-astrophysics-pulsar-08`.
  - Exactly 9 items from `fam-paleontology-cambrian-09`.
  - Exactly 6 `TRUE` items (with verbatim citation spans).
  - Exactly 6 `FALSE` items (with verbatim contradiction spans).
  - Exactly 6 `NOT GIVEN` items.
  - Passages conform strictly to the 720–915 word length bound.
- **Grammar Stratum ($n = 12$ questions):**
  - Exactly 6 items from `fam-mood-subjunctive-08` (Mandative Subjunctive).
  - Exactly 6 items from `fam-aspect-participle-09` (Reduced Participle Clauses).
  - Exactly 1 defensible key and 3 syntactically flawed distractors with error codes per MCQ.

### Condition 5: Deterministic Cryptographic Digest Computation
- Curated JSON files must be canonicalized using UTF-8 encoding, NFKC normalization, sorted keys, and compact separators `(',', ':')`:
  - `generation_baseline/holdout/reading_corpus.json`
  - `generation_baseline/holdout/grammar_rule_packs.json`
- SHA-256 digests must be computed using `verify_corpus_hashes.py` and inserted into the manifest.

### Condition 6: External Panel Lead Attestation
- The external panel lead must execute a cryptographically verifiable attestation (PGP signature or certified academic institutional email verification) confirming:
  - Zero developer inspection of curated content prior to freeze.
  - Zero tuning against prompts or evaluators.
  - Full adherence to the non-synthetic curation standard.
- The attestation metadata is recorded in `security_attestations` in `CONFIRMATORY_HOLDOUT_MANIFEST.json`.

### Condition 7: Dedicated Post-Freeze Reliability Role Affirmation
- The panel and repository auditor must reaffirm that the 30-item Judge Holdout corpus is reserved exclusively for post-freeze evaluator reliability assessment (measuring post-freeze FRR, FAR, and abstention rate).
- It is strictly forbidden to use the holdout corpus for threshold tuning, heuristic calibration, prompt revisions, or model selection.
- The 30-item Judge Holdout must not be conflated with the 150–240 assignment RQ2 benchmark tasks (`FINAL_EVAL`).

---

## 3. Sealing Execution Protocol

Only when Conditions 1 through 7 are satisfied:
1. Populate `CONFIRMATORY_HOLDOUT_MANIFEST.json` with computed SHA-256 hashes and attestation signatures.
2. Update `"status": "SEALED_UNINSPECTED"`.
3. Compute `manifest_integrity_sha256` over the finalized manifest.
4. Execute git commit locking the sealed holdout files:
   ```bash
   git add generation_baseline/research/CONFIRMATORY_HOLDOUT_MANIFEST.json generation_baseline/holdout/
   git commit -m "research(freeze): seal confirmatory holdout manifest with external panel attestation"
   ```
5. Do NOT unseal or execute evaluations until the final campaign unsealing milestone is reached.
