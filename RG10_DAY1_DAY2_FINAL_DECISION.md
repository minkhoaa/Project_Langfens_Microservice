# RG10 Day 1 + Day 2 Final Audit Decision

**Date of Decision:** 2026-10-18  
**Audit Scope:** Software Freeze (Day 1), Dataset Eligibility & Provenance (Day 2), and AI Output Quality Review  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Commit SHA:** `69007c8d0860eba40b0274837699f89970a46303`  
**Governing Protocols:** `generation_baseline/research/RQ2_PROTOCOL.md`, `DATA_GOVERNANCE.md`, and `ANALYSIS_PLAN.md`  

---

## 1. Five-Pillar Decision Dashboard

To maintain strict scientific integrity and avoid concealing domain-specific failures behind an aggregated score, the audit establishes five distinct, non-fungible readiness pillars:

| Readiness Dimension | Audit Status | Governing Standard & Key Evidence |
|---|---|---|
| **1. SOFTWARE_READY** | **`PASS`** | • Full regression suite: **353 passed in 6.07s** across 24 test files.<br>• Pinned Evaluator: `neutral-eval-v2.7` (`NeutralEvaluatorV2_7`) isolated from v2.6/v2.5.<br>• Prompt digests verified for Arms A, B, C.<br>• 168 frozen assignments and fingerprints verified.<br>• 677/677 raw responses intact with full telemetry.<br>• 262 attempts reconciled: 0 silent drops, fail-closed accounting. |
| **2. DATASET_READY** | **`HOLD`** | • **CRITICAL DEFECT:** 6 policy records in `sources_eligible.json` borrow real medical PMCIDs (e.g. PMC8910005) but assign fabricated titles, authors, and DOIs.<br>• **CRITICAL DEFECT:** Policy texts contain synthetic padding (paragraph 2 repeated 41–55 times).<br>• **CRITICAL DEFECT:** 12 of 28 Reading tasks (`final-reading-017` to `028`) consume this padded text, presenting 11+ duplicate sentences.<br>• **HIGH DEFECT:** Character offset division (`len // 4`) splits 21 of 28 Reading passages mid-word.<br>• **MEDIUM DEFECT:** Grammar tasks cycle difficulty arbitrarily, mislabeling C1 inversion as B1. |
| **3. EXPLORATORY_OUTPUT_QUALITY** | **`PASS WITH CONDITIONS`**<br>*(86.3% Pass Rate)* | • Blind multi-agent AI review across all 51 terminal and live DEV items: **44 PASS, 5 FAIL, 2 UNCERTAIN**.<br>• Disentangled True Generation Defects (7 items) from Evaluator Defects (3 false rejections, 1 false acceptance).<br>• Identified cross-arm prompt collapse (11.8% question duplication).<br>• *Explicit Epistemic Disclosure:* `EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD`. |
| **4. INDEPENDENT_QUALITY_READY** | **`HOLD`** | • Confirmatory Holdout ($N=30$) remains `SPECIFICATION_PENDING_INDEPENDENT_CURATION` with null cryptographic seals.<br>• Human review panel is uncontracted and unpopulated (0 synthetic scores allowed).<br>• AI agent consensus cannot substitute for certified human gold. |
| **5. RESEARCH_READY** | **`HOLD`** | • Overall experimental dispatch is **BLOCKED**.<br>• Multiple blocking gates: Provider API quota exhausted (HTTP 429), unsealed holdout corpus, unpopulated human panel, and dataset provenance defects requiring controlled replacement (`RQ2_DATASET_V2`). |

$$\mathbf{OVERALL\ CAMPAIGN\ GATE:\ HOLD}$$

---

## 2. Summary of Confirmed Defects & Remediation Options

### 2.1 Confirmed Defects Matrix

| Defect ID | Component | Severity | Description | Scope / Affected Items |
|---|---|---|---|---|
| **DEF-DAT-01** | `sources_eligible.json` | **CRITICAL** | Bibliographic fabrication: Real medical PMCIDs (PMC8910001–8910006) mapped to synthetic topics/authors/DOIs. | 6 policy records in fixture |
| **DEF-DAT-02** | `sources_eligible.json` | **CRITICAL** | Synthetic text padding: Single paragraph repeated 41 to 55 consecutive times to inflate word count. | All 6 records in fixture |
| **DEF-DAT-03** | `final_dataset.py` | **CRITICAL** | Task assembly contamination: 12 Reading tasks constructed from repetitive padded text. | `final-reading-017` to `028` (42.9% of reading benchmark) |
| **DEF-DAT-04** | `final_dataset.py` | **HIGH** | Mid-word passage segmentation: Integer division `len(full_text) // 4` creates unnatural sentence boundaries. | 21 of 28 Reading tasks (75.0%) |
| **DEF-DAT-05** | `final_dataset.py` | **MEDIUM** | Grammar difficulty mislabeling: Modulo difficulty cycling assigns B1 to C1 negative inversion and clefts. | 14 of 28 Grammar tasks |
| **DEF-GEN-01** | Generator Arm C | **HIGH** | Circular question stem and missing correct key (`audit_idx: 15`). | `dev-grammar-inversion-06__arm_C__att1` Q2 |
| **DEF-GEN-02** | Generator Arm C | **HIGH** | Missing option labels (`A)`, `B)`, etc.) and multiple defensible keys (`audit_idx: 50, 51`). | `dev-grammar-cleft-03__arm_C` Q1 & Q2 |
| **DEF-GEN-03** | Generator Arm C | **MEDIUM** | Physical dimensional error: "depths exceeding 200 atmospheres" (`audit_idx: 8`). | `dev-reading-volcanism-06__arm_C__att1` Q2 |
| **DEF-EVA-01** | Evaluator v2.6 | **MEDIUM** | Regex failure on negation via "preventing", rejecting valid model FALSE answer (`audit_idx: 3`). | `dev-reading-volcanism-06__arm_A__att1` Q3 |

---

## 3. Remediation Strategy: Controlled Replacement Campaign (`RQ2_DATASET_V2`)

**Rule of Pre-Registration:** Under scientific change-control principles, we **DO NOT** silently rewrite passages, alter existing fixture files, or mutate frozen ledger hashes in-place. Such action would destroy historical auditability.

Instead, remediation must follow a controlled, versioned protocol:

1. **Quarantine Existing FINAL Dataset:**
   - Designate dataset version `final-v1.0` as `QUARANTINED_PROVENANCE_DEFECT`.
   - Freeze all current artifacts in `generation_baseline/` as immutable historical evidence.

2. **Construct `RQ2_DATASET_V2`:**
   - **Authentic Reading Passages:** Select 3 genuine, CC-BY-4.0 open-access PMC articles from diverse non-medical fields (e.g., Earth systems, history of technology, renewable energy).
   - **Sentence-Boundary Chunking:** Segment passages using natural sentence boundaries (`(?<=[.!?])\s+`) targeting 1,200–1,500 characters, ensuring 0 mid-word cuts.
   - **Curated Grammar RulePacks:** Source grammar specifications from academic reference corpora (Quirk et al., Biber et al.), align CEFR difficulty strictly with grammatical structure, and expand example pools to 6–10 items per family.

3. **Separate Versioned Registration:**
   - Implement `services/generation-service/app/experiment/final_dataset_v2.py`.
   - Generate new canonical fingerprints and ledger under `generation_baseline/.execution/RQ2_V2/`.
   - Submit `RQ2_V2` for independent verification before any live generation dispatches.

---

## 4. Final Actionable Gates to Resume Live Research

The campaign remains on **`HOLD`** and cannot dispatch MiniMax API calls, final A/B/C experiments, or RG11 until the following four conditions are met:

1. **Provider Quota Replenishment:**
   - External provider quota confirmed operational without HTTP 429 rate-limiting.
2. **Dataset Replacement (`RQ2_DATASET_V2`):**
   - Implementation and verification of clean, authentic PMC reading sources and expert-curated grammar rule packs.
3. **Confirmatory Holdout Sealing:**
   - Independent human curation of the 30-item holdout corpus and generation of cryptographic SHA-256 seals in `CONFIRMATORY_HOLDOUT_MANIFEST.json`.
4. **Human Review Panel Onboarding:**
   - Onboarding of qualified human reviewers to score the blinded evaluation package.
