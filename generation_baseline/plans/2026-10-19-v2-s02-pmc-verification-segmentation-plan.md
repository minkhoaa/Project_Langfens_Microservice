# Micro-Sprint Plan: V2-S02 — Comprehensive 7-Source NCBI Verification, Provenance Tracing & Semantic Segmentation

**Sprint ID**: `V2-S02`  
**Parent Master Plan**: `generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`  
**Document ID**: `PLAN-V2-S02-PMC-SEGMENTATION`  
**Status**: `PROPOSED_SPRINT_PLAN_CANDIDATE_AWAITING_USER_APPROVAL`  
**Approval Evidence**: `NONE_INVENTED` (Candidate sprint plan authored under V2-S02 preflight; awaiting explicit human review and sign-off; previous V2-S01 sign-off applies solely to V2-S01 and does NOT authorize V2-S02 implementation)  
**Governing Standard**: `generation_baseline/SOURCE_OF_TRUTH.md`  
**Prerequisite Sprint**: `V2-S01` (`PASS`, Verified 2026-10-19)  
**Repository**: `minkhoaa/Project_Langfens_Microservice`  
**Branch**: `autonomous-generation`  

---

## 1. Executive Context & Objectives

Sprint V2-S01 achieved formal gate closure (`PASS`), establishing an immutable quarantine for `final-v1.0` in `generation_baseline/verification/V1_QUARANTINE_MANIFEST.json` and confirming zero mutations across all 594 historical assets.

Under the governing master recovery plan (`generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`), **Sprint V2-S02** addresses the foundational root causes of Reading task corruption identified during Day 2 audits:
1. **Bibliographic Fabrication & License Ambiguity (DEF-DAT-01):** Historical policy records mapped PMCIDs to fabricated metadata and self-declared CC-BY claims without XML proof.
2. **Synthetic Text Padding (DEF-DAT-02):** Policy records repeated paragraphs 41–55 times to inflate word counts.
3. **Mid-Word Passage Cuts (DEF-DAT-04):** Arbitrary integer division (`len(full_text) // 4`) severed tokens mid-word in 75% of Reading tasks.

This micro-sprint establishes an authentic, scientifically grounded Reading corpus and segmentation architecture through six core deliverables:
1. Building `generation_baseline/tools/verify_and_ingest_pmc_sources.py` to query live NCBI Entrez E-Utilities (`esummary.fcgi` and `efetch.fcgi`).
2. Validating source eligibility by **usable clean body word count** (capable of yielding independent 350–650-word passages without padding or clipping), rather than arbitrary character thresholds, without forcing every candidate to yield 4 passages.
3. Explicitly resolving the V1 source inheritance boundary: formally barring the 6 contaminated/fabricated V1 sources (`PMC8910001..6`) with strict zero-overlap invariants, while permitting inheritance of the 4 clean in-repo candidate sources (`PMC13621526`, `PMC13604763`, `PMC13517498`, `PMC13407692`) subject to live NCBI verification and cross-split disjointness.
4. Retrieving authentic replacement open-access PMC articles in non-medical scientific domains (Earth Systems, Clean Energy, Ancient/Applied Technology) to replace forbidden sources.
5. Replacing brittle exact XML-substring matching with **deterministic, auditable text correspondence verification**, recording canonical SHA-256 digests (`raw_xml_sha256`, `extracted_body_sha256`, `canonical_clean_text_sha256`), ordered cleaning transforms, and mismatch diagnostics in `generation_baseline/verification/V2_SOURCE_PROVENANCE_LEDGER.json`.
6. Implementing `SemanticSentenceSegmenter` (`services/generation-service/app/experiment/segmentation.py`) and a calibrated anti-padding test suite that rejects demonstrated synthetic padding and source copying while routing uncertain legitimate repetition to review with recorded evidence.

---

## 2. Invariants, Safety & Non-Goals

### 2.1 Inviolable Invariants
- **DO NOT IMPLEMENT UNTIL APPROVED:** No implementation code or test execution for V2-S02 shall commence until this sprint plan candidate has received explicit, dedicated user review and sign-off. Previous sign-off for Sprint V2-S01 applies solely to V2-S01 and does NOT constitute authorization for V2-S02.
- **Zero In-Place Historical Mutations:** Quarantined V1 files (`services/generation-service/app/experiment/final_dataset.py`, `services/generation-service/tests/fixtures/policies/sources_eligible.json`, and `generation_baseline/.execution/RG10/*`) must remain strictly read-only and byte-for-byte identical.
- **External Network Boundary:** External HTTPS requests to official NCBI Entrez E-Utilities APIs (`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/`) are explicitly PERMITTED for fetching authentic open-access article metadata (`esummary.fcgi`) and authoritative JATS XML full text (`efetch.fcgi`).
- **Zero Foundation Model Provider Calls:** All calls to MiniMax, OpenAI, Ollama, Anthropic, or any foundation model provider remain STRICTLY PROHIBITED.
- **No Live Campaign Dispatches:** No task generation, evaluation loop dispatches, or campaign ledger generation.
- **No Confirmatory Holdout Unsealing:** Confirmatory holdout manifests and specifications remain strictly sealed.
- **Strictly Grounded Provenance:** No PMC source or open-access license is presumed certified a priori; all metadata, licenses, and full texts must derive directly from authoritative NCBI responses. Never fabricate missing source evidence.
- **Namespace Boundary:** All V2 source artifacts, segmentation logic, and test suites reside strictly in dedicated V2 files (`segmentation.py`, `V2_SOURCE_PROVENANCE_LEDGER.json`, `test_v2_*.py`).

### 2.2 Exclusions & Non-Goals
- Grammar RulePacks and CEFR taxonomy alignment belong to **Sprint V2-S03**.
- Dataset task assembly (`final_dataset_v2.py`) and batching belong to **Sprint V2-S04**.
- Multi-agent AI pre-flight fixture audits belong to **Sprint V2-S05**.
- Cryptographic campaign sealing and ledger generation belong to **Sprint V2-S06**.

---

## 3. Comprehensive PMC Ingestion & Provenance Architecture

### 3.1 Usable Word Count Eligibility & Passage Yield Policy
Candidate sources must be validated based on **usable clean body word count**, replacing arbitrary character length thresholds (e.g. 5,000 characters):

1. **Usable Clean Word Count Standard:**
   - Raw character counts are inadequate due to varying markup density, formulas, and references.
   - Eligibility is evaluated on **clean, extracted, non-boilerplate body text** after removing front-matter, back-matter, tables, figures, formulas, and references.
2. **Passage Extraction Feasibility:**
   - A candidate source is eligible if and only if its clean body text naturally yields valid, coherent, non-overlapping 350–650-word semantic passages without artificial text padding, synthetic truncation, or sentence clipping.
   - If an article cannot produce independent 350–650-word passages satisfying boundary cleanliness and antecedent preservation, it must be **rejected or replaced**.
3. **No Forced Four-Passage Constraint:**
   - Candidate sources are **not forced** to yield exactly four passages.
   - Scientific articles vary naturally in length and narrative density. A source that cleanly yields 2 or 3 independent, high-quality passages meeting the 350–650 word bounds is admitted for those 2 or 3 passages.
   - The total benchmark requirement across the admitted pool of candidate sources is 28 Reading tasks (each with an independent passage). If candidate sources yield fewer than 4 passages each, additional authentic replacement PMC sources shall be retrieved and ingested to achieve the required 28 passages, rather than artificially forcing 4 passages out of a short text.

### 3.2 Explicit Source Boundary: Forbidden Quarantined Sources vs. Inherited Sources
To eliminate ambiguity and resolve contradictions regarding V1 overlap:

```
                                    HISTORICAL V1 SOURCES
                                              │
                     ┌────────────────────────┴────────────────────────┐
                     ▼                                                 ▼
     ┌───────────────────────────────┐                 ┌───────────────────────────────┐
     │ 6 CONTAMINATED SOURCES        │                 │ 4 CLEAN IN-REPO CANDIDATES    │
     │ PMC8910001 .. PMC8910006      │                 │ PMC13621526, PMC13604763,     │
     │ Fabricated DOIs / 41-55x loop │                 │ PMC13517498, PMC13407692      │
     └───────────────┬───────────────┘                 └───────────────┬───────────────┘
                     │                                                 │
                     ▼                                                 ▼
     ┌───────────────────────────────┐                 ┌───────────────────────────────┐
     │ STRICT ZERO OVERLAP (FAIL)    │                 │ ELIGIBLE FOR V2 INHERITANCE   │
     │ - Zero reuse or reference     │                 │ IF AND ONLY IF:               │
     │ - Jaccard 3-gram < 0.10       │                 │ - Live NCBI metadata verified │
     │ - Excluded from all V2 tasks  │                 │ - CC-BY-4.0 XML tag proven    │
     └───────────────────────────────┘                 │ - Auditable text match passes │
                                                       │ - Cross-split disjointness OK │
                                                       └───────────────────────────────┘
```

1. **Permanently Quarantined & Forbidden Sources (`ZERO_TOLERANCE_FORBIDDEN`):**
   - Identifiers: `PMC8910001`, `PMC8910002`, `PMC8910003`, `PMC8910004`, `PMC8910005`, `PMC8910006`.
   - Rationale: These records are fundamentally compromised by bibliographic metadata fabrication (DEF-DAT-01) and synthetic paragraph duplication loops (DEF-DAT-02).
   - Invariant: **Strict zero reuse and zero lexical overlap.** Any candidate V2 text displaying verbatim spans $\ge 15$ words or 3-gram shingle Jaccard overlap $\ge 0.10$ against these 6 sources immediately fails validation. This rule is never bypassed.
2. **Candidate Inherited Sources (`ELIGIBLE_SUBJECT_TO_VERIFICATION`):**
   - Identifiers: `PMC13621526`, `PMC13604763`, `PMC13517498`, `PMC13407692`.
   - Rationale: In-repo files present in `tests/fixtures/corpus/sources/` that did not exhibit synthetic paragraph duplication in V1, but have no certified metadata or XML license on record.
   - Invariant: **No a priori presumption of validity.** These 4 sources may be inherited into V2 if and only if they pass live NCBI metadata query, XML `<license-p>` CC-BY-4.0 confirmation, deterministic text correspondence, and cross-split disjointness checks against DEV, CALIBRATION, HOLDOUT, and G15.
3. **Replacement Source Pool (`LIVE_NCBI_INGESTION`):**
   - Authentic replacement articles retrieved from NCBI to replace the 6 forbidden sources:
     - `fam-v2-rep-earth-01`: Earth Systems & Physical Geography (Peer-reviewed OA journal)
     - `fam-v2-rep-energy-02`: Clean Energy & Environmental Engineering (Peer-reviewed OA journal)
     - `fam-v2-rep-tech-03`: Ancient Technology / Applied Engineering (Peer-reviewed OA journal)
     - Additional replacement sources as determined by usable passage yields to achieve the 28-reading-task total.

### 3.3 Candidate Sources Ledger

| Family ID | Candidate Identifier | Document Topic & Academic Field | Target Journal Domain | Candidate Citation & Identifier | License Evidence Requirement | V1 Overlap & Inheritance Classification |
|---|---|---|---|---|---|---|
| `fam-v2-pmc-13621526` | `PMC13621526` | Controlled-Environment Plant Biology | *BMC Plant Biol*, 2026 | Aldiyab et al.<br>DOI: 10.1186/s12870-026-09420-x | Official EFetch XML `<license-p>` CC-BY-4.0 | **Inherited Candidate:** Permitted subject to live NCBI query, XML license proof, text correspondence, and split disjointness. |
| `fam-v2-pmc-13604763` | `PMC13604763` | Biomimetic Hydrophobic Surfaces | *Biomimetics*, 2026 | Cao, Wang<br>DOI: 10.3390/biomimetics11090617 | Official EFetch XML `<license-p>` CC-BY-4.0 | **Inherited Candidate:** Permitted subject to live NCBI query, XML license proof, text correspondence, and split disjointness. |
| `fam-v2-pmc-13517498` | `PMC13517498` | Distributed Sensor Networks | *Sensors*, 2026 | Zhang et al.<br>DOI: 10.3390/s26165122 | Official EFetch XML `<license-p>` CC-BY-4.0 | **Inherited Candidate:** Permitted subject to live NCBI query, XML license proof, text correspondence, and split disjointness. |
| `fam-v2-pmc-13407692` | `PMC13407692` | Quantum State Purification | *Entropy*, 2026 | Tang, Wang<br>DOI: 10.3390/e28070726 | Official EFetch XML `<license-p>` CC-BY-4.0 | **Inherited Candidate:** Permitted subject to live NCBI query, XML license proof, text correspondence, and split disjointness. |
| `fam-v2-rep-earth-01` | *Live NCBI Query* | Earth Systems & Physical Geography | Peer-reviewed OA journal | Authoritative NCBI ESummary record | Official EFetch XML `<license-p>` CC-BY-4.0 | **Replacement Candidate:** Replaces forbidden PMC8910002; full provenance ingestion required. |
| `fam-v2-rep-energy-02` | *Live NCBI Query* | Clean Energy & Environmental Engineering | Peer-reviewed OA journal | Authoritative NCBI ESummary record | Official EFetch XML `<license-p>` CC-BY-4.0 | **Replacement Candidate:** Replaces forbidden PMC8910003; full provenance ingestion required. |
| `fam-v2-rep-tech-03` | *Live NCBI Query* | Ancient Technology / Applied Engineering | Peer-reviewed OA journal | Authoritative NCBI ESummary record | Official EFetch XML `<license-p>` CC-BY-4.0 | **Replacement Candidate:** Replaces forbidden PMC8910005; full provenance ingestion required. |

---

## 4. Deterministic Text Correspondence & Ingestion Architecture

### 4.1 Replacing Brittle Substring Matching
Exact raw character substring comparisons (`candidate_text in raw_xml`) fail due to standard XML markup features:
- XML entity encodings (`&amp;`, `&lt;`, `&gt;`, `&#x00A0;`).
- Tag boundaries (`<italic>`, `<bold>`, `<ext-link>`, `<xref>`).
- Formatting whitespace and newline conventions.
- Unicode normalization variations (NFC vs. NFD, smart quotes vs. ASCII quotes).

Sprint V2-S02 implements **Deterministic Auditable Text Correspondence Verification**:

```
Official PMC JATS XML                                   Candidate Disk Text
        │                                                        │
        ▼                                                        ▼
┌───────────────────────────────┐                        ┌───────────────────────────────┐
│ Extract <body> Node XML       │                        │ Strip Leading/Trailing WS     │
└──────────────┬────────────────┘                        └──────────────┬────────────────┘
               │                                                        │
               ▼                                                        ▼
┌───────────────────────────────┐                        ┌───────────────────────────────┐
│ Canonical XML Normalizer:     │                        │ Canonical Text Normalizer:    │
│ - Decode XML entities         │                        │ - Unicode NFC normalization   │
│ - Strip inline tags           │                        │ - Normalize smart quotes      │
│ - Remove figures/tables/math  │                        │ - Normalize whitespace        │
│ - Unicode NFC normalization   │                        │                               │
│ - Normalize whitespace        │                        │                               │
└──────────────┬────────────────┘                        └──────────────┬────────────────┘
               │                                                        │
               ▼                                                        ▼
       Canonical XML Body                                       Canonical Disk Body
               │                                                        │
               └───────────────────────┬────────────────────────────────┘
                                       │
                                       ▼
                       ┌───────────────────────────────┐
                       │ Auditable Alignment Engine:   │
                       │ - Token-level sequence match  │
                       │ - 100% Span coverage assert   │
                       │ - Zero unevidenced additions  │
                       │ - Emit mismatch diagnostics   │
                       └───────────────────────────────┘
```

### 4.2 Cryptographic Anchors & Ledger Schema
Tool `generation_baseline/tools/verify_and_ingest_pmc_sources.py` records complete provenance in `generation_baseline/verification/V2_SOURCE_PROVENANCE_LEDGER.json`:
1. **Bibliographic Identification:** `pmcid`, `doi`, `journal`, `publication_year`, `authors_list`, `article_title`.
2. **License Evidence:** `license_type` (`CC-BY-4.0`), `license_url`, `license_p_verbatim` (verbatim XML `<license-p>` text).
3. **Cryptographic Digests:**
   - `raw_xml_sha256`: SHA-256 digest of untouched downloaded JATS XML.
   - `extracted_body_sha256`: SHA-256 digest of the raw `<body>` element XML.
   - `canonical_clean_text_sha256`: SHA-256 digest of normalized extracted clean text.
   - `disk_fixture_sha256`: SHA-256 digest of the fixture file stored under `services/generation-service/tests/fixtures/corpus/sources/`.
4. **Transformation History:** Ordered list of deterministic transformations applied (entity resolution, front/back matter stripping, figure/table removal, Unicode NFC normalization, whitespace normalization).
5. **Auditable Correspondence Report:**
   - `alignment_status`: `VERIFIED_EXACT_CORRESPONDENCE` or `VERIFICATION_FAILED`.
   - `token_correspondence_ratio`: Ratio of disk tokens found identically in canonical XML body (must be $1.0$).
   - `mismatch_diagnostics`: Detailed character/token difference logs and context traces if alignment fails.
6. **Integrity Rule:** **Never fabricate missing source evidence.** If an NCBI API call fails, if XML permissions lack CC-BY-4.0 text, or if text correspondence fails, the candidate is marked `REJECTED` with full error diagnostics, and replacement retrieval is triggered.

---

## 5. Semantic Sentence- and Paragraph-Aware Segmentation Architecture

### 5.1 Specification of `SemanticSentenceSegmenter`
File: `services/generation-service/app/experiment/segmentation.py`

The segmenter completely replaces V1 integer division (`len(full_text) // 4`) with syntax-aware boundary parsing:

1. **Paragraph & Sentence Boundary Detection:**
   - Lookbehind boundary regex: `(?<=[.!?])\s+(?=[A-Z0-9"“'‘])`.
   - Explicit negative exceptions preventing invalid splits on:
     - Academic abbreviations (`e.g.`, `i.e.`, `et al.`, `Fig.`, `Figs.`, `Ref.`, `Refs.`, `Dr.`, `Prof.`, `vs.`, `approx.`, `vol.`, `no.`).
     - Numeric decimals, ratios, and coordinates (`3.14`, `0.05`, `1:5`, `p < 0.01`).
     - Citation brackets (`[1]`, `[12, 13]`, `[14-16]`, `(Smith et al., 2020)`).
     - Chemical formulas, isotopes, and SI units (`CO2`, `H2O`, `Ca2+`, `km`, `kg`, `kW`, `ms`).
2. **Contract-Derived Length Boundaries (350–650 Words):**
   - Pack contiguous, whole sentences into passages targeting 350–650 words.
   - **Zero Mid-Token or Mid-Clause Cuts:** Sentences are never clipped mid-word, mid-phrase, or mid-clause.
   - **Zero Synthetic Padding:** Passages consist solely of naturally occurring prose. Text is never duplicated to satisfy minimum word limits.
3. **Discourse Integrity & Antecedent Preservation:**
   - Every passage begins at a natural paragraph boundary or topical introductory sentence.
   - **Severed Anaphora Check:** Opening sentences are validated against dangling anaphoric pronouns (`"This occurred..."`, `"These findings demonstrate..."`, `"Such mechanisms..."`) whose antecedent was severed in the preceding chunk.
   - Definitions and necessary referents remain intact within the same chunk.

---

## 6. Refined Anti-Padding & Anti-Leakage Detection Architecture

File: `services/generation-service/tests/test_v2_anti_padding.py`

Universal zero-repetition assumptions fail on legitimate repetitive structures in academic prose (e.g. restated experimental parameters, methodology descriptions, hypotheses re-evaluated in discussions). The anti-padding architecture is refined into three distinct operational tiers:

```
                               CANDIDATE SOURCE / PASSAGE TEXT
                                              │
         ┌────────────────────────────────────┼────────────────────────────────────┐
         ▼                                    ▼                                    ▼
┌───────────────────────────────┐    ┌───────────────────────────────┐    ┌───────────────────────────────┐
│ TIER 1: SYNTHETIC PADDING     │    │ TIER 2: UNCERTAIN REPETITION  │    │ TIER 3: LEGITIMATE DOMAIN     │
│ - Consecutive duplicate ¶     │    │ - Non-consecutive repeated    │    │ - Technical compound nouns    │
│ - Loop multiplication (DEF-02)│    │   clauses (>= 8 words)        │    │ - Domain terminology          │
│ - Single sentence repeated 3+ │    │ - Repeated protocol sentences │    │ - Named entities & variables  │
│ - Cross-source copy (>= 15 w) │    │ - Restated hypotheses         │    │ - Scientific apparatus terms  │
└──────────────┬────────────────┘    └──────────────┬────────────────┘    └──────────────┬────────────────┘
               │                                    │                                    │
               ▼                                    ▼                                    ▼
         REJECT / FAIL                       ROUTE TO REVIEW                          ALLOW
                                        (Record Evidence in JSON)
```

### 6.1 Tier 1: Demonstrated Synthetic Padding & Source Copying (`FAIL / REJECT`)
1. **Consecutive Duplicate Paragraphs ($Count > 0$):** Any adjacent identical paragraph immediately fails.
2. **Synthetic Multiplication Loops ($Count > 1$):** Any paragraph repeated multiple times across the article (the exact defect of DEF-DAT-02) immediately fails.
3. **High-Density Verbatim Sentence Repetition ($Count \ge 3$):** Any complete sentence repeated 3 or more times within a single passage immediately fails.
4. **Verbatim Cross-Source Copying ($\ge 15$ Words):** Any verbatim sequence of $\ge 15$ words shared between distinct candidate sources immediately fails.

### 6.2 Tier 2: Uncertain Legitimate Text Repetition (`MANUAL_REVIEW_REQUIRED`)
1. **Non-Consecutive Clause Matches ($\ge 8$ Words):** Repetitions of substantive phrases between 8 and 14 words that may reflect legitimate scientific restatements (e.g. experimental protocols, standard measurement conditions) trigger review triage.
2. **Near-Duplicate Paragraphs ($0.15 \le \text{Jaccard 3-gram} \le 0.40$):** Paragraphs with moderate shingle overlap are flagged with recorded evidence.
3. **Evidence-Based Review Logging:** The validator emits a structured JSON record (`generation_baseline/verification/PADDING_REVIEW_TRIAGE.json`) capturing:
   - Text span, word count, character offset, and occurrence frequency.
   - Surrounding paragraph context for each occurrence.
   - Evaluated linguistic category (protocol repetition, hypothesis restatement, rhetorical parallelism).
   - Review disposition (`PENDING_REVIEW`, `APPROVED_LEGITIMATE`, or `REJECTED_DEFECTIVE`).

### 6.3 Tier 3: Legitimate Scientific & Lexical Repetition (`ALLOW`)
1. **Domain Terminology & Technical Nouns:** Technical compounds (e.g. *LED photoperiod*, *superhydrophobic surface*, *sensor network topology*, *quantum state purification*) naturally recur throughout scientific papers and are permitted.
2. **POS Content-Word Filtering:** The validator uses Zipfian frequency analysis and POS tagging to distinguish legitimate technical keyword recurrence from verbatim narrative padding.

### 6.4 Cross-Split Disjointness
1. **Forbidden Historical Sources:** Jaccard 3-gram overlap against `PMC8910001..PMC8910006` must be $< 0.10$ with 0 verbatim spans $\ge 15$ words.
2. **Existing Research Splits:** Jaccard 3-gram overlap against DEV, CALIBRATION, HOLDOUT, and G15 splits must be $< 0.10$.

---

## 7. Implementation Steps & Work Breakdown

| Step | Action | Target Files | Verification Method |
|---|---|---|---|
| **Step 1: Preflight Verification** | Verify V2-S01 gate status is `PASS`; confirm zero mutations to historical V1 files and RG10 execution ledgers. | `V1_QUARANTINE_MANIFEST.json`, `verify_v1_quarantine.py` | `python3 generation_baseline/tools/verify_v1_quarantine.py` |
| **Step 2: PMC Ingestion & Correspondence Tool** | Implement automated NCBI ESummary/EFetch ingestion tool with XML license validation, deterministic text canonicalization, and auditable alignment matching. | `generation_baseline/tools/verify_and_ingest_pmc_sources.py` | Tool unit tests; test XML canonicalization and alignment diagnostics |
| **Step 3: Source Verification & Provenance Ledger** | Query live NCBI APIs for 4 in-repo candidates and replacement candidates; verify usable word counts; generate `V2_SOURCE_PROVENANCE_LEDGER.json`. | `generation_baseline/verification/V2_SOURCE_PROVENANCE_LEDGER.json`, `services/generation-service/tests/fixtures/corpus/sources/PMC*.txt` | `python3 generation_baseline/tools/verify_and_ingest_pmc_sources.py --verify-all` |
| **Step 4: Semantic Sentence Segmenter** | Implement `SemanticSentenceSegmenter` with boundary regex, academic exception handling, antecedent checks, and contract-derived 350–650 word bounds. | `services/generation-service/app/experiment/segmentation.py` | Unit tests for abbreviations, decimals, citations, and sentence integrity |
| **Step 5: Acceptance Test Authoring** | Author comprehensive test suites for source authenticity, segmentation integrity, calibrated anti-padding, and cross-split disjointness. | `services/generation-service/tests/test_v2_source_authenticity.py`<br>`services/generation-service/tests/test_v2_passage_segmentation.py`<br>`services/generation-service/tests/test_v2_anti_padding.py` | `pytest services/generation-service/tests/test_v2_*.py -v` |
| **Step 6: Full Verification & Report** | Re-run full test suites (RG10 regression, package checks, V1 quarantine, new V2 tests); author V2-S02 verification report. | `generation_baseline/verification/V2_S02_IMPLEMENTATION_AND_VERIFICATION_REPORT.md` | `pytest tests/test_rg10_*.py && python3 generation_baseline/tools/verify_baseline.py` |

---

## 8. Acceptance Gates & Exit Criteria

Sprint V2-S02 shall achieve gate closure (`PASS`) if and only if all of the following criteria are satisfied:
- [ ] **Gate 1 (Provenance Authenticity):** All candidate sources have verified records in `V2_SOURCE_PROVENANCE_LEDGER.json` with authentic PMCIDs, DOIs, journal citations, and verbatim `<license-p>` CC-BY-4.0 text derived from live NCBI XML. Zero missing evidence fabricated.
- [ ] **Gate 2 (Deterministic Text Correspondence):** Clean disk text corresponds 100% to canonicalized official PMC XML body text with documented, deterministic transformation passes and zero unevidenced additions.
- [ ] **Gate 3 (Usable Word Count & Feasibility):** Every admitted source provides sufficient usable body word count to produce independent 350–650-word passages without padding or clipping. No source is forced to yield 4 passages.
- [ ] **Gate 4 (V1 Overlap Resolution):** 100% zero overlap against forbidden quarantined sources (`PMC8910001..6`). The 4 inherited sources pass full NCBI and disjointness verification.
- [ ] **Gate 5 (Boundary Cleanliness):** `SemanticSentenceSegmenter` parses 100% of sentences at valid linguistic boundaries, with zero mid-word, mid-phrase, or mid-clause truncations across all candidate texts.
- [ ] **Gate 6 (Passage Length Contracts):** All segmented passages strictly conform to the 350–650 word range with intact pronominal antecedents and zero synthetic padding.
- [ ] **Gate 7 (Calibrated Anti-Padding):** `test_v2_anti_padding.py` confirms zero consecutive duplicate paragraphs, zero paragraph loops, and zero cross-source copying. Any uncertain non-consecutive repetitions are routed to `PADDING_REVIEW_TRIAGE.json` with recorded evidence.
- [ ] **Gate 8 (Cross-Split Disjointness):** Jaccard 3-gram shingle overlap against DEV, CALIBRATION, HOLDOUT, G15, and forbidden V1 sources is strictly $< 0.10$.
- [ ] **Gate 9 (Zero Historical Regression):** Full RG10 regression suite passes (353/353 tests), baseline package checks pass (2015/2015 checks), and V1 quarantine manifest confirms 0 mutations across 594 historical files.
- [ ] **Gate 10 (Safety & Provider Invariants):** 0 MiniMax API calls, 0 foundation model generation calls, 0 live research dispatches, and 0 holdout inspections.
