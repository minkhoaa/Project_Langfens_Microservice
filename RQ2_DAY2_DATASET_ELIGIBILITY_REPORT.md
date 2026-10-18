# RQ2 Day 2: Dataset Eligibility & Source Provenance Investigation Report

**Audit Target:** Benchmark Dataset Provenance, Text Integrity, Policy Fixture Auditing, and Grammatical Invariants  
**Evaluated At:** 2026-10-18  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Inspected Components:**
- `services/generation-service/app/experiment/final_dataset.py`
- `services/generation-service/tests/fixtures/policies/sources_eligible.json`
- `services/generation-service/tests/fixtures/corpus/sources/*.txt`
- `services/generation-service/app/contracts/research.py` (GrammarRulePack)
- Frozen campaign ledger `generation_baseline/.execution/RG10/campaign_ledger.json`

---

## 1. Executive Summary & Verdict

| Investigation Area | Audit Finding | Severity | Status |
|---|---|---|---|
| **Reading Source Metadata (PMC/DOI)** | Severe metadata mismatch: PMCIDs PMC8910001–8910006 point to medical/public-health literature in PubMed Central, but repository assigns fabricated titles, authors, and DOIs. | **CRITICAL** | **FAILED** |
| **Reading Text Authenticity & Padding** | `sources_eligible.json` contains synthetic padding: each article has only 2 distinct paragraphs, with paragraph 2 duplicated 41–55 times to inflate word count. | **CRITICAL** | **FAILED** |
| **FINAL Reading Task Assembly** | 12 of 28 frozen Reading tasks (`final-reading-017` to `028`) consume padded policy records, resulting in tasks containing 11+ repetitions of identical sentences. | **CRITICAL** | **FAILED** |
| **Passage Segmentation Boundaries** | Raw character division (`len(full_text) // 4`) splits text mid-word and mid-sentence in 21 of 28 Reading tasks. | **HIGH** | **FAILED** |
| **Grammar RulePack Provenance** | RulePacks are internally generated synthetic specifications (`license="synthetic_not_expert"`), not verified academic grammar corpora. | **MEDIUM** | **HOLD** |
| **Grammar CEFR Difficulty Alignment** | Task generator forcibly cycles CEFR difficulty (B1, B2, C1, B1), forcing C1 syntactic rules (Inversion, Clefts) to be mislabeled as B1. | **MEDIUM** | **HOLD** |

### Dataset Eligibility Verdict
$$\mathbf{DATASET\_READY: HOLD}$$

**Core Conclusion:**  
While all files match their local cryptographic SHA-256 hashes, **a valid SHA-256 is merely proof of persistence, not proof of authenticity or academic validity.** The frozen FINAL benchmark dataset suffers from fatal data-integrity defects: fabricated bibliographic records, synthetic paragraph duplication, mid-word passage truncation, and unvalidated grammar rule specifications.

Under research integrity rules, **the dataset CANNOT be used for authoritative RQ2 evaluation.** We recommend placing the dataset gate on **HOLD** and implementing a controlled, separately versioned replacement campaign (`RQ2_DATASET_V2`).

---

## 2. Reading Source Provenance Investigation (All 7 Families)

The benchmark defines 7 clean open-access Reading source families in `final_dataset.py`:
- 4 disk file sources (`PMC13621526.txt`, `PMC13604763.txt`, `PMC13517498.txt`, `PMC13407692.txt`)
- 3 policy article sources loaded from `sources_eligible.json` (`PMC8910002`, `PMC8910003`, `PMC8910005`)

### 2.1 Bibliographic Verification: Repository vs Authoritative NCBI Records

Independent query of NCBI PubMed Central (PMC) Entrez E-Utilities (`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pmc`) reveals total bibliographic divergence for all policy articles:

| PMCID | Repository Claimed Title & Topic | Authoritative NCBI PMC Title & Journal | Real PMC Authors & DOI | Discrepancy Classification |
|---|---|---|---|---|
| **PMC8910001** | *Trophic Interactions and Benthic Resilience in Tropical Coral Reefs*<br>(Marine Biology) | *Characterizing the Health of Older Rural Australians Attending Rural Events: Implications for Future Health Promotion Opportunities.*<br>(Int J Environ Res Public Health) | D. Terry et al.<br>DOI: 10.3390/ijerph19052802 | **COMPLETE FABRICATION** |
| **PMC8910002** | *Early Hydraulic Engineering in Mesopotamian Irrigation Networks*<br>(Ancient Technology; Prof. Arthur Pendelton) | *“Time Does Not Heal All Wounds”: Sexual Victimisation Is Associated with Depression, Anxiety, and PTSD in Old Age.*<br>(Int J Environ Res Public Health) | A. Nobels, G. Lemmens et al.<br>DOI: 10.3390/ijerph19052803 | **COMPLETE FABRICATION** |
| **PMC8910003** | *Pyrometallurgical and Hydrometallurgical Pathways for Lithium-Ion Battery Recycling*<br>(Materials Recycling; Klara Lindqvist) | *Understanding the Molecular Mechanisms of Succinic Semialdehyde Dehydrogenase Deficiency (SSADHD): Towards the Development of SSADH-Targeted Medicine.*<br>(Int J Mol Sci) | H. Lee, G. McGinty et al.<br>DOI: 10.3390/ijms23052451 | **COMPLETE FABRICATION** |
| **PMC8910004** | *Subglacial Hydrology and Basal Sliding Velocities in Greenland Ice Streams*<br>(Glaciology; Ingrid Haakon) | *Hexokinase 2 Inhibition and Biological Effects of BNBZ and Its Derivatives: The Influence of the Number and Arrangement of Hydroxyl Groups.*<br>(Int J Mol Sci) | Y. Wang et al.<br>DOI: 10.3390/ijms23052452 | **COMPLETE FABRICATION** |
| **PMC8910005** | *Cross-Linguistic Perspectives on Spatial Metaphors for Temporal Sequencing*<br>(Cognitive Linguistics; Dr. Miriam Al-Hashimi) | *Emerging Glycation-Based Therapeutics—Glyoxalase 1 Inducers and Glyoxalase 1 Inhibitors.*<br>(Int J Mol Sci) | N. Rabbani, P. J. Thornalley<br>DOI: 10.3390/ijms23052453 | **COMPLETE FABRICATION** |
| **PMC8910006** | *Cognitive Heuristics and Probability Distortions Under Systemic Financial Stress*<br>(Behavioral Economics; Prof. David Klein) | *The Effect of Low-intensity Aerobic Training Combined with Blood Flow Restriction on Maximal Strength, Muscle Mass, and Cycling Performance in a Cyclist with Knee Displacement.*<br>(Int J Environ Res Public Health) | K. Tanaka et al.<br>DOI: 10.3390/ijerph19052804 | **COMPLETE FABRICATION** |
| **PMC13621526** | *Controlled-Environment Plant Biology and LED Photoperiods* | *Tailoring LED spectra and cultivation systems enhances lettuce productivity and nutritional quality in vertical indoor farming.*<br>(BMC Plant Biol, 2026) | A. Aldiyab, H. Y. Dasgan et al.<br>DOI: 10.1186/s12870-026-09420-x | **AUTHENTIC MATCH** |
| **PMC13604763** | *Biomimetic Hydrophobic Surfaces and Interfacial Free Energy* | *Research Progress on Bioinspired Superhydrophobic Photothermal Anti-/Deicing Coatings.*<br>(Biomimetics, 2026) | Z. Cao, S. Wang<br>DOI: 10.3390/biomimetics11090617 | **AUTHENTIC MATCH** |
| **PMC13517498** | *Distributed Sensor Networks and Transformer District Monitoring* | *Anomaly Detection and Data Repair for Smart Meter Data in Smart Cities: A Comprehensive Review and Future Perspectives.*<br>(Sensors, 2026) | B. Zhang, G. Lin et al.<br>DOI: 10.3390/s26165122 | **AUTHENTIC MATCH** |
| **PMC13407692** | *Quantum Purification Fidelity under Symmetric Subspace Projections* | *Information-Theoretic Framework for Quantum State Purification and Error Correction via Symmetric Subspace Projection.*<br>(Entropy, 2026) | J. Tang, M. J. Wang<br>DOI: 10.3390/e28070726 | **AUTHENTIC MATCH** |

**Finding:** The 4 file sources in `tests/fixtures/corpus/sources/` correspond to genuine open-access scientific publications. However, all 6 records in `sources_eligible.json` are completely fabricated bibliographic entities that borrow real PMC identifiers belonging to unrelated medical and public health papers.

---

### 2.2 Text Duplication and Repetitive Padding in `sources_eligible.json`

Analysis of the substantive text in `sources_eligible.json` reveals artificial padding:

```
PMC8910001: Total Paragraphs = 42 | Unique Paragraphs = 2
  - Paragraph 1 (614 chars): Introductory discussion on coral reefs.
  - Paragraph 2 (129 chars): "Regular benthic photography and diver surveys provided consistent longitudinal measurements..."
  - Duplication Count: Paragraph 2 is repeated 41 consecutive times!

PMC8910002: Total Paragraphs = 42 | Unique Paragraphs = 2
  - Paragraph 1 (500 chars): Introductory discussion on Mesopotamian canals.
  - Paragraph 2 (123 chars): "Excavated cuneiform tablets detail administrative work quotas assigned to canal maintenance during low-water autumn months."
  - Duplication Count: Paragraph 2 is repeated 41 consecutive times!

PMC8910003: Total Paragraphs = 50 | Unique Paragraphs = 2
  - Paragraph 1 (586 chars): Introductory discussion on battery recycling.
  - Paragraph 2 (118 chars): "Analytical titration and mass spectrometry verify elemental purity throughout multi-stage solvent extraction circuits."
  - Duplication Count: Paragraph 2 is repeated 49 consecutive times!

PMC8910004: Total Paragraphs = 46 | Unique Paragraphs = 2
  - Paragraph 1 (530 chars): Introductory discussion on Greenland ice streams.
  - Paragraph 2 (112 chars): "Continuous GPS receivers and borehole pressure sensors recorded diurnal discharge and ice displacement dynamics."
  - Duplication Count: Paragraph 2 is repeated 45 consecutive times!

PMC8910005: Total Paragraphs = 44 | Unique Paragraphs = 2
  - Paragraph 1 (647 chars): Introductory discussion on spatial metaphors for time.
  - Paragraph 2 (130 chars): "Empirical reaction time datasets corroborate the hypothesis that linguistic framing subtly shapes non-linguistic temporal thought."
  - Duplication Count: Paragraph 2 is repeated 43 consecutive times!

PMC8910006: Total Paragraphs = 56 | Unique Paragraphs = 2
  - Paragraph 1 (618 chars): Introductory discussion on prospect theory.
  - Paragraph 2 (125 chars): "Controlled laboratory trading environments simulated endogenous shock propagation across interconnected participant networks."
  - Duplication Count: Paragraph 2 is repeated 55 consecutive times!
```

---

### 2.3 Contamination of Frozen FINAL Reading Tasks

In `services/generation-service/app/experiment/final_dataset.py`, the FINAL task builder consumes records from `sources_eligible.json`:
- `final-reading-017` to `020` consume `PMC8910002` (Mesopotamian Irrigation)
- `final-reading-021` to `024` consume `PMC8910003` (Battery Recycling)
- `final-reading-025` to `028` consume `PMC8910005` (Spatial Metaphors)

**Impact Analysis:**
- 12 out of 28 Reading tasks (**42.9% of the reading benchmark**) are built directly from these padded texts.
- For tasks corresponding to sections 2, 3, and 4 of each article, the input passage given to the model consists of **nothing but the single duplicated sentence repeated 11 to 14 times!**
- For example:
  - Task `final-reading-019`: Passage is 1,420 characters long and consists entirely of the sentence `"Excavated cuneiform tablets detail administrative work quotas assigned to canal maintenance during low-water autumn months."` repeated 11 times.
  - Task `final-reading-023`: Passage is 1,637 characters long and consists entirely of `"Analytical titration and mass spectrometry verify elemental purity throughout multi-stage solvent extraction circuits."` repeated 14 times.
  - Task `final-reading-027`: Passage is 1,598 characters long and consists entirely of `"Empirical reaction time datasets corroborate the hypothesis that linguistic framing subtly shapes non-linguistic mental timelines."` repeated 12 times.

Evaluating AI question generation on an input passage of 12 identical repeated sentences produces invalid, degenerate questions and is academically indefensible.

---

### 2.4 Passage Segmentation Boundary Defects (Character Offset Division)

In `final_dataset.py` (lines 320–326):
```python
segment_length = len(full_text) // 4
for sec_idx in range(4):
    start = sec_idx * segment_length
    end = (sec_idx + 1) * segment_length if sec_idx < 3 else len(full_text)
    passage_text = full_text[start:end].strip()
```

Because `segment_length` is computed by integer character division without word or sentence boundary awareness:
- **21 out of 28 Reading passages (75.0%)** start or end mid-word or without terminal punctuation.
- Concrete Examples of Truncation:
  - `final-reading-001` (sec 1) ends with: `"]. Based on wavelength, light is classified a"` (mid-word: `classified as`)
  - `final-reading-002` (sec 2) begins with: `"s ultraviolet, visible, or infrared; within t"` and ends with `"oduction, and compact architecture in leafy v"`
  - `final-reading-003` (sec 3) begins with: `"egetables such as lettuce [24, 31, 35, 36]. B"` and ends with `"opriate selection of light source, spectral q"`
  - `final-reading-004` (sec 4) begins with: `"uality, and intensity directly affects growth"`
  - `final-reading-005` (sec 1) ends with: `"etric data presented in Figure 1 were retriev"`
  - `final-reading-006` (sec 2) begins with: `"ed from the Web of Science Core Collection us"` and ends with `"hitectures on certain butterfly wings not onl"`
  - `final-reading-007` (sec 3) begins with: `"y exhibit superhydrophobic characteristics, b"`
  - `final-reading-010` (sec 2) ends with: `"ibution networks and may lead to further misj"`
  - `final-reading-011` (sec 3) begins with: `"udgments and economic losses [44]."`
  - `final-reading-013` (sec 1) ends with: `"cientific problem in advancing near-term quan"`
  - `final-reading-014` (sec 2) begins with: `"tum computing toward practical utility."`

Input passages cut mid-word break IELTS passage validity and trigger artificial model hallucinations or grammar defects.

---

## 3. Grammar RulePack Provenance & Difficulty Invariant Analysis

The benchmark defines 7 Grammar rule families in `GRAMMAR_FAMILIES_METADATA`:
1. `fam-grammar-inversion-final`: Negative and Limiting Adverbial Inversion (C1)
2. `fam-grammar-conditionals-final`: Mixed and Inverted Conditional Structures (B2)
3. `fam-grammar-clefts-final`: Cleft Sentences for Focus and Emphasis (C1)
4. `fam-grammar-subjunctive-final`: Mandative and Formulaic Subjunctive Clauses (B2)
5. `fam-grammar-participles-final`: Reduced Relative and Adverbial Participle Clauses (B1)
6. `fam-grammar-modals-final`: Past Speculation and Deduction with Modal Auxiliaries (B2)
7. `fam-grammar-passives-final`: Impersonal and Reporting Passive Constructions (B1)

### 3.1 Synthetic Provenance & Absence of External Validation
- In `final_dataset.py`, lines 397–398:
  - `license = "synthetic_not_expert"`
  - `provenance_uri = f"https://langfens.internal/research/grammar/{rule_pack_id}"`
- **Finding:** The Grammar RulePacks are not sourced from established academic grammar references (such as the *Longman Grammar of Spoken and Written English*, *The Cambridge Grammar of the English Language*, or *A Comprehensive Grammar of the English Language*). They are internal, hand-crafted synthetic specifications.

### 3.2 CEFR Level Mismatch via Arbitrary Difficulty Cycling
In `final_dataset.py` (lines 386–387):
```python
difficulty_cycle = ["B1", "B2", "C1"]
...
difficulty = difficulty_cycle[(item_idx - 1) % len(difficulty_cycle)]
```
Across the 28 Grammar tasks, `item_idx` increments sequentially from 1 to 28, cycling `["B1", "B2", "C1"]`:
- For `fam-grammar-inversion-final` (linguistically C1):
  - Task 1 (`final-grammar-001`): Assigned difficulty **`B1`**
  - Task 2 (`final-grammar-002`): Assigned difficulty **`B2`**
  - Task 3 (`final-grammar-003`): Assigned difficulty **`C1`**
  - Task 4 (`final-grammar-004`): Assigned difficulty **`B1`**
- For `fam-grammar-clefts-final` (linguistically C1):
  - Task 9 (`final-grammar-009`): Assigned difficulty **`B1`**
- For `fam-grammar-passives-final` (linguistically B1):
  - Task 27 (`final-grammar-027`): Assigned difficulty **`C1`**

**Defect:** Syntactic structures of high complexity (negative inversion, inverted conditionals, it-clefts) are arbitrarily labeled as B1, while elementary reporting passives are labeled as C1. This introduces systematic difficulty distortion into the benchmark.

### 3.3 Rulepack Example Scarcity & Duplication
Each Grammar family contains exactly **2 examples**. Across all 4 task variants in each family (e.g., `final-grammar-001` through `004`), the exact same 2 examples are repeatedly passed to the model prompts. In DEV experiments, models frequently copy vocabulary and sentence structures directly from these two examples, producing repetitive test items.

---

## 4. Remediation Plan: Controlled Replacement Campaign (`RQ2_DATASET_V2`)

Because the current frozen dataset fails core scientific eligibility criteria, it cannot be run as-is. Under the pre-registration protocol, modifying existing files or recalculating hashes in-place would violate change-control immutability.

We propose a formal, auditable replacement campaign:

### Step 1: Quarantine Current FINAL Dataset
- Mark dataset version `final-v1.0` as `QUARANTINED_PROVENANCE_DEFECT`.
- Retain all current fixtures and hashes in `generation_baseline/` as immutable historical records.

### Step 2: Assemble Authentic Open-Access Corpus (`RQ2_DATASET_V2`)
- **Reading Passages:**
  1. Replace the 3 policy sources (`PMC8910002`, `PMC8910003`, `PMC8910005`) with 3 genuine, verified open-access CC-BY-4.0 PMC full-text articles (e.g., select clean articles from Earth sciences, history of science, or economics from PubMed Central).
  2. Implement **sentence-boundary-aware segmentation**: chunk passages at natural sentence boundaries (`nltk.sent_tokenize` or regex boundary detection `(?<=[.!?])\s+`) targeting 1,200–1,500 characters, ensuring no text begins or ends mid-word.
- **Grammar RulePacks:**
  1. Source grammar rules and examples from authoritative reference corpora (e.g., Cambridge English Grammar in Use, CEFR Level descriptors).
  2. Align difficulty tags strictly with grammatical taxonomy (e.g., Inversion = C1, Mixed Conditionals = B2/C1, Passives = B1/B2).
  3. Expand example pools to 6–10 diverse examples per family to prevent prompting collapse and verbatim copying.

### Step 3: Register and Version Replacement Campaign
- Create `services/generation-service/app/experiment/final_dataset_v2.py`.
- Formally generate new canonical task fingerprints and ledger under `generation_baseline/.execution/RQ2_V2/`.
- Present revised dataset to human panel and research auditor before unblocking execution.

---

## 5. Final Dataset Decision Summary

| Metric | Target / Standard | Observed Benchmark Value | Compliance |
|---|---|---|---|
| Authentic Bibliographic Provenance | 100% Verified PMC/DOI | 4/7 Authentic (57.1%), 3/7 Fabricated (42.9%) | **FAIL** |
| Substantive Passage Repetition | 0% Unnatural Duplication | 12/28 Reading Tasks (42.9%) contain 11+ repetitions | **FAIL** |
| Sentence Boundary Cleanliness | 100% Clean Sentence Boundaries | 21/28 Tasks (75.0%) cut mid-word | **FAIL** |
| Grammar Difficulty Alignment | 100% CEFR Taxonomy Match | Arbitrary modulo cycling creates C1/B1 inversion conflicts | **HOLD** |

**Overall Gate Status:**
$$\mathbf{DATASET\_READY = HOLD}$$
$$\mathbf{RESEARCH\_READY = HOLD}$$
*(Campaign blocked pending implementation and audit of `RQ2_DATASET_V2`)*
