# Micro-Sprint Plan: V2-S02 — Comprehensive 7-Source NCBI Verification, Provenance Tracing & Semantic Segmentation

**Sprint ID**: `V2-S02`  
**Parent Master Plan**: `generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md` (Approved Master Plan)  
**Document ID**: `PLAN-V2-S02-PMC-SEGMENTATION`  
**Status**: `PROPOSED_SPRINT_PLAN_CANDIDATE_AWAITING_USER_APPROVAL`  
**Approval Evidence**: `NONE_INVENTED` (Candidate sprint plan authored under V2-S02 preflight; awaiting explicit human review and sign-off; approval not invented per prompt mandate)  
**Governing Standard**: `generation_baseline/SOURCE_OF_TRUTH.md`  
**Prerequisite Sprint**: `V2-S01` (`PASS`, Verified 2026-10-19)  
**Repository**: `minkhoaa/Project_Langfens_Microservice`  
**Branch**: `autonomous-generation`  

---

## 1. Executive Context & Objectives

Sprint V2-S01 achieved formal gate closure (`PASS`), establishing an immutable quarantine for `final-v1.0` in `generation_baseline/verification/V1_QUARANTINE_MANIFEST.json` and confirming zero mutations across all 594 historical assets.

Under the approved master recovery plan (`generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`), **Sprint V2-S02** addresses the foundational defects of Reading task construction:
1. **Bibliographic Fabrication & License Ambiguity (DEF-DAT-01):** Historical policy records mapped PMCIDs to fabricated metadata and self-declared CC-BY claims without XML proof.
2. **Synthetic Text Padding (DEF-DAT-02):** Policy records repeated paragraphs 41–55 times to inflate word counts.
3. **Mid-Word Passage Cuts (DEF-DAT-04):** Arbitrary integer division (`len(full_text) // 4`) severed tokens mid-word in 75% of Reading tasks.

This micro-sprint establishes an authentic, scientifically grounded Reading corpus and segmentation architecture by:
1. Building `generation_baseline/tools/verify_and_ingest_pmc_sources.py` to verify all 7 candidate sources against live NCBI Entrez E-Utilities (`esummary.fcgi` and `efetch.fcgi`).
2. Admitting 4 in-repo candidate sources (`PMC13621526`, `PMC13604763`, `PMC13517498`, `PMC13407692`) only upon live verification of metadata, CC-BY-4.0 `<license-p>` XML tags, and text correspondence.
3. Retrieving 3 authentic open-access replacement PMC articles to replace fabricated records (`PMC8910002`, `PMC8910003`, `PMC8910005`) in non-medical scientific domains (Earth Systems, Clean Energy, Ancient/Applied Technology).
4. Generating `generation_baseline/verification/V2_SOURCE_PROVENANCE_LEDGER.json` with cryptographic SHA-256 digests of authoritative raw XML, clean extracted text, and transformation histories.
5. Implementing `SemanticSentenceSegmenter` (`services/generation-service/app/experiment/segmentation.py`) with regex boundary parsing, robust academic exception handling, pronominal antecedent preservation, and contract-derived 350–650 word bounds.
6. Establishing comprehensive acceptance test suites covering source authenticity, segmentation integrity, and calibrated anti-padding.

---

## 2. Invariants, Safety & Non-Goals

### 2.1 Inviolable Invariants
- **DO NOT IMPLEMENT UNTIL APPROVED:** No implementation code or test execution for V2-S02 shall commence until this sprint plan has received explicit user review and sign-off.
- **Zero In-Place Historical Mutations:** Quarantined V1 files (`services/generation-service/app/experiment/final_dataset.py`, `services/generation-service/tests/fixtures/policies/sources_eligible.json`, and `generation_baseline/.execution/RG10/*`) must remain strictly read-only and byte-for-byte identical.
- **Zero Provider Calls:** No calls to MiniMax, Ollama, OpenAI, or any foundation model provider during this sprint.
- **No Live Campaign Dispatches:** No task execution, evaluation loop dispatches, or campaign ledger generation.
- **No Confirmatory Holdout Unsealing:** Confirmatory holdout manifests and specifications remain strictly sealed.
- **Strictly Grounded Provenance:** No PMC source or open-access license is presumed certified a priori; all metadata and licenses must derive directly from authoritative NCBI XML responses.
- **Namespace Boundary:** All V2 source artifacts, segmentation logic, and test suites reside strictly in dedicated V2 files (`segmentation.py`, `V2_SOURCE_PROVENANCE_LEDGER.json`, `test_v2_*.py`).

### 2.2 Exclusions & Non-Goals
- Grammar RulePacks and CEFR taxonomy alignment belong to **Sprint V2-S03**.
- Dataset task assembly (`final_dataset_v2.py`) and batching belong to **Sprint V2-S04**.
- Multi-agent AI pre-flight fixture audits belong to **Sprint V2-S05**.
- Cryptographic campaign sealing and ledger generation belong to **Sprint V2-S06**.

---

## 3. Comprehensive 7-Source PMC Ingestion & Provenance Architecture

### 3.1 Candidate Sources Inventory & Admission Criteria
All 7 sources must satisfy:
1. **Academic Field:** Non-medical STEM or humanities domain suitable for IELTS Academic Reading.
2. **License:** Verifiable Creative Commons Attribution 4.0 International (`CC-BY-4.0`) or equivalent open-access license embedded in the official PMC XML `<license-p>` element.
3. **Length:** Minimum 5,000 characters of clean extracted body text to allow 4 non-overlapping semantic sections of 350–650 words each without padding.
4. **Disjointness:** Zero lexical or topical overlap with DEV, CALIBRATION, HOLDOUT, G15, or quarantined V1 sources.

| Family ID | PMC Identifier | Document Topic & Academic Field | Target Journal Domain | Candidate Citation & Identifier | License Requirement | Verification State |
|---|---|---|---|---|---|---|
| `fam-v2-pmc-13621526` | `PMC13621526` | Controlled-Environment Plant Biology | *BMC Plant Biol*, 2026 | Aldiyab et al.<br>DOI: 10.1186/s12870-026-09420-x | Official EFetch XML `<license-p>` CC-BY-4.0 | In-repo candidate; requires live NCBI re-query and text correspondence proof in V2-S02. |
| `fam-v2-pmc-13604763` | `PMC13604763` | Biomimetic Hydrophobic Surfaces | *Biomimetics*, 2026 | Cao, Wang<br>DOI: 10.3390/biomimetics11090617 | Official EFetch XML `<license-p>` CC-BY-4.0 | In-repo candidate; requires live NCBI re-query and text correspondence proof in V2-S02. |
| `fam-v2-pmc-13517498` | `PMC13517498` | Distributed Sensor Networks | *Sensors*, 2026 | Zhang et al.<br>DOI: 10.3390/s26165122 | Official EFetch XML `<license-p>` CC-BY-4.0 | In-repo candidate; requires live NCBI re-query and text correspondence proof in V2-S02. |
| `fam-v2-pmc-13407692` | `PMC13407692` | Quantum State Purification | *Entropy*, 2026 | Tang, Wang<br>DOI: 10.3390/e28070726 | Official EFetch XML `<license-p>` CC-BY-4.0 | In-repo candidate; requires live NCBI re-query and text correspondence proof in V2-S02. |
| `fam-v2-rep-earth-01` | *Live NCBI Query* | Earth Systems & Physical Geography | Peer-reviewed OA journal | Authoritative NCBI ESummary record | Official EFetch XML `<license-p>` CC-BY-4.0 | Replacement for fabricated PMC8910002; full provenance ingestion required. |
| `fam-v2-rep-energy-02` | *Live NCBI Query* | Clean Energy & Environmental Engineering | Peer-reviewed OA journal | Authoritative NCBI ESummary record | Official EFetch XML `<license-p>` CC-BY-4.0 | Replacement for fabricated PMC8910003; full provenance ingestion required. |
| `fam-v2-rep-tech-03` | *Live NCBI Query* | Ancient Technology / Applied Engineering | Peer-reviewed OA journal | Authoritative NCBI ESummary record | Official EFetch XML `<license-p>` CC-BY-4.0 | Replacement for fabricated PMC8910005; full provenance ingestion required. |

### 3.2 NCBI Entrez E-Utilities Ingestion Tool (`verify_and_ingest_pmc_sources.py`)
Located at `generation_baseline/tools/verify_and_ingest_pmc_sources.py`, the ingestion tool implements:
1. **ESummary Query (`esummary.fcgi`):**
   - Retrieves official metadata: `title`, `authors`, `source` (journal), `pubdate`, `articleids` (DOI, PMCID).
   - Validates that PMCID matches official record and article is open access.
2. **EFetch Full-Text XML Retrieval (`efetch.fcgi`):**
   - Retrieves authoritative JATS XML full text (`db=pmc&id={pmcid}&retmode=xml`).
   - Computes canonical SHA-256 digest of raw downloaded XML (`raw_xml_sha256`).
3. **License Extraction & Validation:**
   - Parses `<permissions>` block in XML.
   - Extracts `<license>` attributes and child `<license-p>` text.
   - Asserts string pattern matching `Creative Commons Attribution` or `http://creativecommons.org/licenses/by/4.0/`.
4. **Body Text Cleaning & Normalization Pipeline:**
   - Strips front-matter boilerplate (`<front>`, abstract, author affiliations, keywords).
   - Strips back-matter (`<back>`, acknowledgments, references, author contributions).
   - Strips embedded tabular data (`<table>`, `<tabular>`), mathematical formulas (`<disp-formula>`, `<inline-formula>`), figure captions (`<fig>`, `<caption>`), and citation callouts.
   - Normalizes whitespace (collapsing multiple spaces and blank lines, preserving paragraph structure).
   - Computes canonical SHA-256 digest of clean text (`clean_text_sha256`).
5. **Text Correspondence Verification:**
   - For in-repo candidates (`PMC13621526`, etc.): Asserts that existing text on disk is an exact, unpadded substring of the official PMC body XML.
   - For replacement sources: Writes cleaned body text to `services/generation-service/tests/fixtures/corpus/sources/PMC{id}.txt`.
6. **Provenance Ledger Generation:**
   - Emits `generation_baseline/verification/V2_SOURCE_PROVENANCE_LEDGER.json` capturing:
     - `pmcid`, `doi`, `journal`, `publication_year`, `authors_list`
     - `license_type`, `license_url`, `license_p_verbatim`
     - `raw_xml_sha256`, `clean_text_sha256`, `clean_text_word_count`, `clean_text_char_count`
     - `transformation_history` (ordered list of cleaning passes)
     - `clustering_attributes` (broad domain, subfield, register)

---

## 4. Semantic Sentence- and Paragraph-Aware Segmentation Architecture

### 4.1 Specification of `SemanticSentenceSegmenter`
File: `services/generation-service/app/experiment/segmentation.py`

The segmenter addresses DEF-DAT-04 (mid-token slicing) by replacing integer division with grammar- and syntax-aware boundary parsing.

```
Raw Clean Text
     │
     ▼
┌────────────────────────────────────────────────────────┐
│ Paragraph Parser: Split on \n\n+, strip empty blocks    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Boundary Regex with Exception Lookbehind:              │
│ (?<=[.!?])\s+(?=[A-Z0-9"“'‘])                          │
│ Negative lookbehinds for:                              │
│ - Academic abbreviations: e.g., i.e., et al., etc.     │
│ - Titles & Honorifics: Dr., Prof., Fig., Vol., No.     │
│ - Decimal numerals: 3.14, 0.05, 1:5                    │
│ - Citation brackets: [1], [12-14], (Smith et al., 2020)│
│ - Chemical formulas & SI units: CO2, H2O, km, kg, kW   │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Chunk Accumulator & Window Packing:                    │
│ - Pack whole sentences into passages                   │
│ - Target word range: 350 to 650 words                  │
│ - Never split sentences mid-clause or mid-token        │
│ - Never pad with duplicated text                       │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Semantic Coherence & Discourse Validator:              │
│ - Check opening sentence for severed anaphora          │
│   (e.g., "This occurred...", "These findings...")      │
│ - Validate non-empty section topic heading             │
└────────────────────────────────────────────────────────┘
```

### 4.2 Research Preregistration Bounds vs Exam Policies
- **Production Exam Policy (`policies.py:31`):** Governs 3-section IELTS full-exam reading papers (720–915 words, 13–14 questions).
- **Research Reading Task Schema (`research.py:112`):** `task_type="READING_SINGLE_PASSAGE"`, 1–2 groups, 1–40 questions, leaving passage length unconstrained.
- **RQ2 Preregistration Decision (350–650 Words, 4 Questions):**
  - Empirically justified for 4 standalone IELTS reading questions (TFNG, MCQ, Sentence Completion).
  - Matches 450–850 token prompt context budget across experimental arms A, B, and C.
  - Matches natural 4-section partitioning of 2,000–3,500 word open-access PMC articles without artificial padding.

---

## 5. Calibrated Anti-Padding & Anti-Leakage Detection Architecture

File: `services/generation-service/tests/test_v2_anti_padding.py`

### 5.1 Within-Source Anti-Padding Criteria
1. **Consecutive Sentence Duplication (`FAIL`):** Any adjacent identical sentence ($Count > 0$) causes immediate test failure.
2. **Duplicate Paragraphs (`FAIL`):** Any paragraph appearing more than once ($Count > 1$) causes immediate test failure.
3. **Normalized Sentence Frequency (`FAIL`):** Any complete sentence ($\ge 6$ words) appearing more than once across the entire text ($Freq > 1$) causes immediate test failure.
4. **Multi-Word Verbatim Spans (`FAIL`):** Any identical substring $\ge 10$ words appearing in different paragraphs (excluding formal section titles) causes immediate test failure.
5. **Legitimate Terminology Exemption (`ALLOW`):** Technical compound nouns (e.g. *LED photoperiod*, *superhydrophobic surface*, *sensor network*) are permitted to recur naturally via Zipfian content-word frequency analysis.

### 5.2 Cross-Source & Cross-Split Anti-Leakage Criteria
1. **Cross-Source Overlap (`FAIL`):** Verbatim spans $\ge 15$ words shared between any two candidate sources cause immediate failure.
2. **Cross-Split Disjointness (`FAIL`):** 3-gram shingle Jaccard overlap against DEV (`fam-botany-*`, `fam-oceanography-*`), CALIBRATION (`fam-marine-01`, `fam-energy-01`, `fam-agri-01`), HOLDOUT (`fam-astrophysics-pulsar-08`, `fam-paleontology-cambrian-09`), G15, or quarantined V1 sources must be strictly $< 0.10$.

---

## 6. Implementation Steps & Work Breakdown

| Step | Action | Target Files | Verification Method |
|---|---|---|---|
| **Step 1: Preflight Verification** | Verify V2-S01 gate status is `PASS`; confirm zero mutations to historical V1 files. | `V1_QUARANTINE_MANIFEST.json`, `verify_v1_quarantine.py` | `python3 generation_baseline/tools/verify_v1_quarantine.py` |
| **Step 2: PMC Ingestion Tool** | Implement automated NCBI ESummary/EFetch ingestion tool with XML license validation and text extraction. | `generation_baseline/tools/verify_and_ingest_pmc_sources.py` | Unit tests for parser; CLI smoke run against NCBI APIs |
| **Step 3: Source Verification & Provenance Ledger** | Verify 4 in-repo sources; fetch 3 replacement sources; generate `V2_SOURCE_PROVENANCE_LEDGER.json`. | `generation_baseline/verification/V2_SOURCE_PROVENANCE_LEDGER.json`, `services/generation-service/tests/fixtures/corpus/sources/PMC*.txt` | `python3 generation_baseline/tools/verify_and_ingest_pmc_sources.py --verify-all` |
| **Step 4: Semantic Sentence Segmenter** | Implement `SemanticSentenceSegmenter` with boundary regex, exception lookbehind, antecedent preservation, and 350–650 word bounds. | `services/generation-service/app/experiment/segmentation.py` | Unit tests on boundary edge cases |
| **Step 5: Acceptance Test Authoring** | Author comprehensive test suites for source authenticity, segmentation, and anti-padding. | `services/generation-service/tests/test_v2_source_authenticity.py`<br>`services/generation-service/tests/test_v2_passage_segmentation.py`<br>`services/generation-service/tests/test_v2_anti_padding.py` | `pytest services/generation-service/tests/test_v2_*.py -v` |
| **Step 6: Full Verification & Report** | Re-run full test suites (RG10 regression, package checks, V1 quarantine, new V2 tests); author V2-S02 verification report. | `generation_baseline/verification/V2_S02_IMPLEMENTATION_AND_VERIFICATION_REPORT.md` | `pytest tests/test_rg10_*.py && python3 generation_baseline/tools/verify_baseline.py` |

---

## 7. Acceptance Gates & Exit Criteria

Sprint V2-S02 shall achieve gate closure (`PASS`) if and only if all of the following criteria are satisfied:
- [ ] **Gate 1 (Provenance Authenticity):** All 7 sources have verified records in `V2_SOURCE_PROVENANCE_LEDGER.json` with authentic PMCIDs, DOIs, journal citations, and verbatim `<license-p>` CC-BY-4.0 text from authoritative NCBI XML.
- [ ] **Gate 2 (Text Correspondence):** Clean disk text for all 7 sources corresponds exactly to official PMC XML body text with documented, deterministic transformation passes.
- [ ] **Gate 3 (Boundary Cleanliness):** `SemanticSentenceSegmenter` parses 100% of sentences at valid linguistic boundaries, with zero mid-word or mid-clause truncations across all candidate texts.
- [ ] **Gate 4 (Passage Length Contracts):** All segmented passages strictly conform to the 350–650 word preregistration range without artificial padding or sentence clipping.
- [ ] **Gate 5 (Zero Padding):** `test_v2_anti_padding.py` confirms 0 consecutive repeated sentences, 0 duplicate paragraphs, and normalized sentence frequency $\le 1$ across all 7 sources.
- [ ] **Gate 6 (Cross-Split Disjointness):** Jaccard 3-gram shingle overlap against DEV, CALIBRATION, HOLDOUT, G15, and quarantined V1 sources is strictly $< 0.10$.
- [ ] **Gate 7 (Zero Historical Regression):** Full RG10 regression suite passes (353/353 tests), baseline package checks pass (2015/2015 checks), and V1 quarantine manifest confirms 0 mutations across 594 historical files.
- [ ] **Gate 8 (Safety Invariants):** 0 MiniMax API calls, 0 live research dispatches, 0 holdout inspections.
