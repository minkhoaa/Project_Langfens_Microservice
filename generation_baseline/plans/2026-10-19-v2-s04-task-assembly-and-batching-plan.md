# Micro-Sprint Plan: V2-S04 — Isolated V2 Dataset Assembly & Deterministic Paired Batching

**Sprint ID**: `V2-S04`  
**Parent Master Plan**: `generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`  
**Document ID**: `PLAN-V2-S04-TASK-ASSEMBLY-AND-BATCHING`  
**Status**: `PLAN_CANDIDATE_AWAITING_USER_APPROVAL`  
**Approval Evidence**: `PENDING_DEDICATED_USER_SIGN_OFF` (Planning only; implementation strictly blocked until explicit, dedicated user approval)  
**Governing Standard**: `generation_baseline/SOURCE_OF_TRUTH.md`  
**Prerequisite Sprints**: `V2-S01` (`PASS`), `V2-S02` (`PASS`), `V2-S03` (`PASS`, engineering deliverables closed)  
**Repository**: `minkhoaa/Project_Langfens_Microservice`  
**Branch**: `autonomous-generation`  

---

## 1. Executive Context & Objectives

Following the successful execution and engineering closeout of **Sprint V2-S01** (Immutable V1 Quarantine), **Sprint V2-S02** (NCBI PMC Verification, Usable Word Counts & Semantic Segmentation), and **Sprint V2-S03** (Reference-Grounded Grammar RulePacks, Sub-Rule CEFR Taxonomy & Production Validator with tri-state `VALID`/`INVALID`/`INCONCLUSIVE` semantics), the Langfens generation research pipeline possesses fully authenticated upstream inputs for both Reading and Grammar domains.

Under the governing master recovery plan (`generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`), **Sprint V2-S04** addresses the assembly and batching failure modes identified during Day 2 audits:
1. **Mid-Word Character Cuts & Synthetic Padding in Task Inputs (DEF-DAT-02, DEF-DAT-04):** In historical dataset `final-v1.0`, tasks were generated via naive integer division (`len(full_text) // 4`), severing words mid-token in 75% of reading tasks and injecting synthetic repeated paragraphs.
2. **Cyclical Unbacked Grammar Task Generation (DEF-DAT-03):** Historical grammar tasks arbitrarily cycled difficulty levels (`B1 -> B2 -> C1`) without linguistic justification, using synthetic placeholder licenses (`synthetic_not_expert`) and internal URIs.
3. **Unchecked Cross-Split Contamination Risks (DEF-DAT-01):** Historical task assembly lacked deterministic cryptographic bindings to upstream PMC XML and descriptive reference records.

Sprint V2-S04 resolves these defects by implementing a dedicated, isolated V2 dataset registry and deterministic paired batching engine:
1. **Isolated V2 Namespace Implementation:** Authoring `services/generation-service/app/experiment/final_dataset_v2.py` in strict isolation from quarantined historical `final_dataset.py`, preserving historical immutability.
2. **28 Authenticated Reading Tasks:** Assembling exactly 28 single-passage Reading tasks ($7 \text{ sources} \times 4 \text{ semantic passages}$) bound to authentic NCBI PMC XML digests (`V2_SOURCE_PROVENANCE_LEDGER.json`), verified CC-BY-4.0 licenses, and abbreviation-aware 350–650-word passages.
3. **28 Grounded Grammar Tasks:** Assembling exactly 28 Grammar tasks ($7 \text{ RulePacks} \times 4 \text{ exercise variations}$) bound to descriptive reference works (`V2_GRAMMAR_PROVENANCE_LEDGER.json`), publisher `ALL_RIGHTS_RESERVED` provenance, and explicit sub-rule CEFR evidence tracking.
4. **56 Paired Experimental Units across Arms A/B/C (168 Arm Assignments):** Formulating the full experimental evaluation grid ($N=56$ paired units, 168 total assignments) with identical task stimuli across Arm A (Direct), Arm B (Self-Critique), and Arm C (Separated Repair Loop).
5. **Deterministic Batch Partitioning ($\le 5$ Items per Batch):** Partitioning tasks into exactly 12 batches of at most 5 items per batch ($\le 15$ arm assignments) conforming strictly to `FINAL_BATCH_RULES.md`, while preserving source-family clustering.
6. **Split Isolation & Anti-Leakage Verification:** Enforcing zero shared 10-word spans against DEV, CALIBRATION, HOLDOUT ($N=30$), G15 campaign, and quarantined V1 sources, rejecting invalid provenance without synthetic fallbacks.
7. **Dedicated V2 Dataset Eligibility Tool:** Authoring `generation_baseline/tools/check_v2_dataset_eligibility.py` as an executable CLI auditor for continuous integration.

---

## 2. Invariants, Safety & Non-Goals

### 2.1 Inviolable Invariants
- **PLANNING ONLY — DO NOT IMPLEMENT UNTIL APPROVED:** This document is strictly a sprint planning deliverable. No implementation code in `final_dataset_v2.py` or test execution shall commence until this sprint plan candidate has received dedicated, explicit user review and sign-off. Sign-off for prior sprints does NOT constitute authorization for V2-S04 implementation.
- **Zero In-Place Historical Mutations:** Quarantined historical V1 assets (`services/generation-service/app/experiment/final_dataset.py`, `sources_eligible.json`, and all historical execution ledgers in `generation_baseline/.execution/RG10/*`) must remain strictly read-only and byte-for-byte identical.
- **Preserve Evaluator v2.7 & RQ2 Methodology:** Maintain complete isolation of neutral evaluator v2.7 (`NeutralEvaluatorV2_7`), prompt specifications for Arms A, B, and C, and established statistical resampling methodology (cluster-level bootstrap at `dataset_item_id`).
- **Zero Foundation Model Provider Calls:** All calls to MiniMax, OpenAI, Ollama, Anthropic, or any external foundation model API remain STRICTLY PROHIBITED during V2-S04.
- **No Live Campaign Dispatches:** Zero experimental dispatches, zero live loop executions, and zero campaign ledger generations. Campaign ledger generation belongs strictly to Sprint V2-S06.
- **Zero Holdout Gold Inspection:** Confirmatory holdout manifests (`CONFIRMATORY_HOLDOUT_MANIFEST.json`) and specifications remain strictly sealed.
- **No Synthetic Substitutions:** If any upstream source text, XML digest, or RulePack cannot be cryptographically verified against its ledger, the registry MUST fail closed with `ProvenanceValidationError`. Fabricating replacement passages or synthetic placeholders is prohibited.
- **Epistemic Disclosure & Oracle Separation:** Grammar validation in `grammar_validator_v2.py` is a structural screening tool, NOT a gold-standard oracle. Provisional CEFR levels remain marked `PROPOSED`, never misrepresented as `VERIFIED_EGP`.
- **Pillar Gate State Maintained:** `DATASET_READY = HOLD` remains strictly in effect throughout V2-S04. Promotion to `PASS` occurs only in Sprint V2-S06 after multi-agent pre-flight audit and human curation gates.

### 2.2 Exclusions & Non-Goals
- Multi-agent AI pre-flight fixture audits of the 56 input tasks belong to **Sprint V2-S05**.
- Preregistration amendment authoring, cryptographic campaign sealing, and `campaign_ledger.json` initialization belong to **Sprint V2-S06**.
- Live foundation model generation and experimental comparison belong to downstream execution phases following full dataset freeze.

---

## 3. Dataset Architecture: 28 Reading + 28 Grammar Tasks ($N=56$)

### 3.1 Isolated Namespace Design
Historical V1 dataset registry resides in `services/generation-service/app/experiment/final_dataset.py`.  
Sprint V2-S04 implements `FinalDatasetV2Registry` in a completely new, dedicated file:
`services/generation-service/app/experiment/final_dataset_v2.py`

```text
services/generation-service/app/experiment/
├── final_dataset.py          # [QUARANTINED V1] Immutable historical reference (read-only)
├── final_dataset_v2.py       # [V2-S04 ISOLATED] Production V2 dataset assembly & batching
├── grammar_packs_v2.py       # [V2-S03] 7 Authoritative Reference-Grounded RulePacks
├── grammar_validator_v2.py   # [V2-S03] Tri-state Syntactic Validator & Diagnostic Taxonomy
└── segmentation.py           # [V2-S02] Abbreviation-aware SemanticSentenceSegmenter
```

### 3.2 Reading Task Assembly: 28 Tasks across 7 Authenticated PMC Sources
Each of the 7 authenticated open-access candidate sources from Sprint V2-S02 yields exactly 4 non-overlapping, semantically complete passages (350–650 words each) segmented by `SemanticSentenceSegmenter`:

| Task ID Range | Candidate PMCID | Domain / Field | Target Journal | License | Word Count Range | Passage Partitioning |
|---|---|---|---|---|---|---|
| `final-v2-reading-001` .. `004` | `PMC13621526` | Controlled-Environment Plant Biology | *BMC Plant Biol*, 2026 | CC-BY-4.0 | 380–520 words | 4 distinct semantic sections |
| `final-v2-reading-005` .. `008` | `PMC13604763` | Biomimetic Hydrophobic Surfaces | *Biomimetics*, 2026 | CC-BY-4.0 | 410–560 words | 4 distinct semantic sections |
| `final-v2-reading-009` .. `012` | `PMC13517498` | Distributed Sensor Networks | *Sensors*, 2026 | CC-BY-4.0 | 390–540 words | 4 distinct semantic sections |
| `final-v2-reading-013` .. `016` | `PMC13407692` | Quantum State Purification | *Entropy*, 2026 | CC-BY-4.0 | 420–580 words | 4 distinct semantic sections |
| `final-v2-reading-017` .. `020` | `PMC13654891` | Earth Systems & Paleohydrology | OA Earth Science, 2026 | CC-BY-4.0 | 400–550 words | 4 distinct semantic sections |
| `final-v2-reading-021` .. `024` | `PMC13667678` | Clean Energy & Geothermal Storage | OA Applied Energy, 2026 | CC-BY-4.0 | 430–590 words | 4 distinct semantic sections |
| `final-v2-reading-025` .. `028` | `PMC13665993` | Ancient Water Engineering | OA Archaeological Science, 2026 | CC-BY-4.0 | 390–530 words | 4 distinct semantic sections |

**Reading Task Invariants:**
- **Zero Mid-Word Truncation:** Passages begin and end on full sentence boundaries.
- **Zero Synthetic Padding:** Each passage is an authentic, continuous excerpt from the clean article body; zero duplicated paragraphs.
- **Cryptographic Provenance:** Each task binds `SourceRef` containing:
  - `source_id`: `src-v2-reading-{pmcid}`
  - `source_family`: `fam-v2-pmc-{pmcid}`
  - `source_version`: `v2.0`
  - `source_sha256`: Authentic `canonical_clean_text_sha256` from `V2_SOURCE_PROVENANCE_LEDGER.json`
  - `license`: `"CC-BY-4.0"`
  - `provenance_uri`: `https://www.ncbi.nlm.nih.gov/pmc/articles/{pmcid}/`
- **Question Group Strata:** Balanced distribution of standalone question groups across tasks:
  `TFNG`, `MCQ_SINGLE`, `SENTENCE_COMPLETION`, `SUMMARY_COMPLETION`, `YNNG`, `SHORT_ANSWER`.
- **Target Question Count:** Exactly 4 questions requested per standalone passage (RQ2 preregistration bound).

### 3.3 Grammar Task Assembly: 28 Tasks across 7 Authoritative RulePacks
Each of the 7 reference-grounded Grammar RulePacks from Sprint V2-S03 yields exactly 4 distinct task variations targeting different sub-rules, exercise formats, and difficulty levels:

| Task ID Range | Family ID | Target Syntactic Construction | Reference Citation | Target Level | Sub-Rule Allocation across 4 Tasks | Exercise Formats |
|---|---|---|---|---|---|---|
| `final-v2-grammar-001` .. `004` | `fam-v2-grammar-inversion` | Negative & Restrictive Inversion | Quirk §18.24–39; H&P Ch. 11 §7 | `C1` | `INV-01`, `INV-02`, `INV-03`, `INV-01+02` | MCQ, Gap-Fill, Error-Correction, Rewrite |
| `final-v2-grammar-005` .. `008` | `fam-v2-grammar-conditionals` | Mixed & Inverted Conditionals | Quirk §14.23; H&P Ch. 8 §2 | `B2 / C1` | `COND-01`, `COND-02`, `COND-03`, `COND-01+03` | MCQ, Gap-Fill, Error-Correction, Rewrite |
| `final-v2-grammar-009` .. `012` | `fam-v2-grammar-clefts` | It-Clefts & Wh-Pseudo-Clefts | Biber §11.4; Quirk §18.25–32 | `C1` | `CLEFT-01`, `CLEFT-02`, `CLEFT-03`, `CLEFT-01+02` | MCQ, Gap-Fill, Error-Correction, Rewrite |
| `final-v2-grammar-013` .. `016` | `fam-v2-grammar-subjunctive` | Mandative & Formulaic Subjunctive | Quirk §3.58–62; H&P Ch. 3 §1.4 | `B2 / C1` | `SUBJ-01`*, `SUBJ-02`, `SUBJ-03`, `SUBJ-01+02`* | MCQ, Gap-Fill, Error-Correction, Rewrite |
| `final-v2-grammar-017` .. `020` | `fam-v2-grammar-participles` | Participle Clauses & Reduced Relatives | Quirk §15.56–62; Biber §9.4 | `B2` | `PART-01`, `PART-02`, `PART-03`, `PART-01+02` | MCQ, Gap-Fill, Error-Correction, Rewrite |
| `final-v2-grammar-021` .. `024` | `fam-v2-grammar-modals` | Past Speculation & Logical Deduction | Quirk §4.49–66; Murphy U27–29 | `B2` | `MOD-01`, `MOD-02`, `MOD-03`, `MOD-01+02` | MCQ, Gap-Fill, Error-Correction, Rewrite |
| `final-v2-grammar-025` .. `028` | `fam-v2-grammar-passives` | Impersonal & Reporting Passives | Quirk §16.64–68; Hewings U24 | `B1 / B2` | `PASS-01`*, `PASS-02`, `PASS-03`, `PASS-01+02`* | MCQ, Gap-Fill, Error-Correction, Rewrite |

*\*Sub-rules marked with asterisk carry explicit curator adjudication flags recorded in `V2_GRAMMAR_PROVENANCE_LEDGER.json` (`SUBJ-01` and `PASS-01`).*

**Grammar Task Invariants:**
- **Evidence-Based Leveling:** Tasks adopt the documented CEFR level from the RulePack; no arbitrary cyclic rotation.
- **Provisional CEFR Marking:** All CEFR annotations carry `cefr_evidence_status="PROPOSED_PENDING_PRIMARY_EGP_ENTRY_ID"` or `PROPOSED_FLAGGED_FOR_CURATOR_ADJUDICATION`. Never assert `VERIFIED_EGP`.
- **Authentic Publisher Rights:** `SourceRef.license` records `"ALL_RIGHTS_RESERVED"` matching publisher copyright.
- **RulePack Fingerprint Binding:** Each task binds `GrammarRulePack` with authentic `rulepack_content_sha256` matching `RULE_PACK_CONTENT_SHA256` and the provenance ledger.
- **Structural Screening Integration:** Grammar validator is integrated strictly for automated syntax screening; validation output records `epistemic_disclosure` stating automated screening is not certified human judgment.

---

## 4. Paired Experimental Units & Tri-Arm Evaluation Grid

### 4.1 Paired Unit of Assignment
Under `generation_baseline/research/RQ2_PROTOCOL.md`, the fundamental experimental unit is the paired task item (`dataset_item_id`).  
Each paired task item is evaluated across three identical experimental configurations:
- **Arm A (Direct Generation):** Single-step foundation model execution without self-critique.
- **Arm B (Self-Critique Revision):** Iterative same-model critique and repair.
- **Arm C (Separated Validation & Repair Loop):** Autonomous multi-agent review with bounded candidate salvage.

### 4.2 Assignment Grid Cardinality ($N=168$)
$$\text{Total Paired Units } = 28\ (\text{Reading}) + 28\ (\text{Grammar}) = 56\ \text{items}$$
$$\text{Total Arm Assignments } = 56 \times 3\ (\text{Arms A, B, C}) = 168\ \text{assignments}$$

Every assignment carries a stable, immutable identifier:
- Reading: `final-v2-reading-{001..028}-{A|B|C}` (84 assignments)
- Grammar: `final-v2-grammar-{001..028}-{A|B|C}` (84 assignments)

### 4.3 Prompt and Model Version Pinning
All 168 assignments share frozen experimental configurations:
- `foundation_model_id`: Designated foundation model identifier (frozen across all arms).
- `prompt_versions`:
  - Arm A: `v2.1`
  - Arm B: `v2.2`
  - Arm C: `v3.0`
- `rubric_version`: `rubric-qgeval-v2.0`
- `evaluator_version`: Neutral Evaluator v2.7 (`NeutralEvaluatorV2_7`)

---

## 5. Deterministic Paired Batching Architecture ($\le 5$ Items per Batch)

### 5.1 Normative Batch Constraints (`FINAL_BATCH_RULES.md`)
1. **Batch Cardinality Ceiling:** Exactly $\le 5$ paired task items per batch.
2. **Assignment Ceiling:** At 3 arms per item, each batch contains at most $5 \times 3 = 15$ arm assignments.
3. **No Cross-Domain Mixing:** Reading and Grammar tasks are never combined within the same batch.
4. **Source-Family Preservation:** Items derived from the same source family are placed in the same batch to preserve clustering attributes for downstream variance estimation.
5. **Deterministic Ordering:** Items and assignments are sorted canonically by `(domain, family_id, item_index, arm)`.

### 5.2 The 12-Batch Partitioning Matrix

$$\begin{array}{c|c|c|c|c|c}
\hline
\textbf{Batch ID} & \textbf{Domain} & \textbf{Item IDs} & \textbf{Source Families} & \textbf{Items} & \textbf{Assignments} \\
\hline
\text{batch-v2-reading-01} & \text{READING} & \text{reading-001 .. 004, reading-005} & \text{PMC13621526 (4), PMC13604763 (1)} & 5 & 15 \\
\text{batch-v2-reading-02} & \text{READING} & \text{reading-006 .. 008, reading-009 .. 010} & \text{PMC13604763 (3), PMC13517498 (2)} & 5 & 15 \\
\text{batch-v2-reading-03} & \text{READING} & \text{reading-011 .. 012, reading-013 .. 015} & \text{PMC13517498 (2), PMC13407692 (3)} & 5 & 15 \\
\text{batch-v2-reading-04} & \text{READING} & \text{reading-016, reading-017 .. 020} & \text{PMC13407692 (1), PMC13654891 (4)} & 5 & 15 \\
\text{batch-v2-reading-05} & \text{READING} & \text{reading-021 .. 024, reading-025} & \text{PMC13667678 (4), PMC13665993 (1)} & 5 & 15 \\
\text{batch-v2-reading-06} & \text{READING} & \text{reading-026 .. 028} & \text{PMC13665993 (3)} & 3 & 9 \\
\hline
\text{batch-v2-grammar-01} & \text{GRAMMAR} & \text{grammar-001 .. 004, grammar-005} & \text{Inversion (4), Conditionals (1)} & 5 & 15 \\
\text{batch-v2-grammar-02} & \text{GRAMMAR} & \text{grammar-006 .. 008, grammar-009 .. 010} & \text{Conditionals (3), Clefts (2)} & 5 & 15 \\
\text{batch-v2-grammar-03} & \text{GRAMMAR} & \text{grammar-011 .. 012, grammar-013 .. 015} & \text{Clefts (2), Subjunctive (3)} & 5 & 15 \\
\text{batch-v2-grammar-04} & \text{GRAMMAR} & \text{grammar-016, grammar-017 .. 020} & \text{Subjunctive (1), Participles (4)} & 5 & 15 \\
\text{batch-v2-grammar-05} & \text{GRAMMAR} & \text{grammar-021 .. 024, grammar-025} & \text{Modals (4), Passives (1)} & 5 & 15 \\
\text{batch-v2-grammar-06} & \text{GRAMMAR} & \text{grammar-026 .. 028} & \text{Passives (3)} & 3 & 9 \\
\hline
\textbf{Total (12 Batches)} & & \mathbf{56\ \text{Tasks}} & \mathbf{14\ \text{Families (7 R + 7 G)}} & \mathbf{56} & \mathbf{168} \\
\hline
\end{array}$$

*Batching Invariant Verification:*
- Max items in any batch: $\max(5, 5, 5, 5, 5, 3) = 5 \le 5$ items.
- Max arm assignments in any batch: $5 \times 3 = 15 \le 15$ assignments.
- Zero batch mixes Reading and Grammar tasks.
- Exactly 12 batches total.

---

## 6. Split Isolation, Deduplication & Anti-Contamination Enforcements

### 6.1 Forbidden Baseline Families & Permitted V1 Exception
Sprint V2-S04 enforces strict baseline disjointness:
- **Forbidden Source Families:** Complete exclusion of all DEV, CALIBRATION, HOLDOUT ($N=30$), G15 campaign, and quarantined fabricated V1 sources (`PMC8910001..6`).
- **Permitted V1 Source Inheritance Exception:** The 4 verified clean candidate sources inherited from V1 (`PMC13621526`, `PMC13604763`, `PMC13517498`, `PMC13407692`) are explicitly admitted per the approved V2 master plan, having satisfied live NCBI JATS XML correspondence and split disjointness.
- **Zero Cross-Split Overlap:** Exactly 0 shared 10-word spans against all 93 baseline passages across DEV, CALIBRATION, HOLDOUT, and G15. Max Jaccard 3-gram overlap must be $\le 0.005$ (well below the $0.10$ ceiling).

### 6.2 Fail-Closed Provenance Validation
`final_dataset_v2.py` implements fail-closed validation:
```python
class ProvenanceValidationError(RuntimeError):
    """Raised when task provenance cannot be cryptographically verified against upstream ledgers."""
```
- Reading: Fails closed if passage text SHA-256 does not match canonical slice in `V2_SOURCE_PROVENANCE_LEDGER.json`, or if XML license is not CC-BY-4.0.
- Grammar: Fails closed if RulePack content SHA-256 does not match `V2_GRAMMAR_PROVENANCE_LEDGER.json`, or if reference work ISBN is missing.
- Zero Synthetic Substitutions: Never fall back to synthetic text, dummy strings, or placeholder IDs.

---

## 7. Dedicated V2 Tooling: `check_v2_dataset_eligibility.py`

Sprint V2-S04 authors `generation_baseline/tools/check_v2_dataset_eligibility.py` as an offline CLI validation utility:
```bash
python3 generation_baseline/tools/check_v2_dataset_eligibility.py --verify-all
```
The tool validates:
1. Exact cardinality: 28 Reading + 28 Grammar tasks ($N=56$), 168 arm assignments.
2. Exact batch partitioning: 12 batches, $\le 5$ items per batch, zero domain mixing.
3. Cryptographic integrity: All 56 tasks verified against upstream provenance ledgers (`V2_SOURCE_PROVENANCE_LEDGER.json` and `V2_GRAMMAR_PROVENANCE_LEDGER.json`).
4. Passage word counts: All 28 Reading passages strictly within 350–650 words.
5. Grammar integrity: All 28 Grammar tasks link to valid RulePacks with provisional CEFR annotations.
6. Baseline disjointness: 0 shared 10-word spans against baseline splits.
7. Emits structured report: `generation_baseline/verification/V2_DATASET_ELIGIBILITY_REPORT.json`.

---

## 8. Verification & Acceptance Testing Architecture

Sprint V2-S04 authors `services/generation-service/tests/test_v2_final_dataset.py` comprising five test tiers:

```
┌────────────────────────────────────────────────────────────────────────┐
│             test_v2_final_dataset.py Acceptance Suite                 │
├────────────────────────────────┬───────────────────────────────────────┤
│ Tier 1: Cardinality & Schema   │ 56 tasks (28 R + 28 G), 168 arm       │
│         Contract Conformance   │ assignments, Pydantic v2 schemas      │
├────────────────────────────────┼───────────────────────────────────────┤
│ Tier 2: Provenance Binding &   │ XML/RulePack digest matching, CC-BY   │
│         Anti-Synthetic Defense │ and All Rights Reserved enforcement   │
├────────────────────────────────┼───────────────────────────────────────┤
│ Tier 3: Deterministic Paired   │ Exactly 12 batches, <=5 items/batch,  │
│         Batching Integrity     │ paired ID preservation across A/B/C   │
├────────────────────────────────┼───────────────────────────────────────┤
│ Tier 4: Split Isolation &      │ Zero shared 10-word spans against     │
│         Baseline Disjointness  │ DEV/CAL/HOLD/G15, family exclusivity  │
├────────────────────────────────┼───────────────────────────────────────┤
│ Tier 5: Idempotency &          │ Bit-for-bit SHA-256 reproducibility  │
│         Reproducibility        │ across independent registry builds    │
└────────────────────────────────┴───────────────────────────────────────┘
```

### Planned Test Suite Breakdown (22 Acceptance Tests):
1. **Tier 1 (Schema & Cardinality):**
   - `test_v2_dataset_total_cardinality_is_exact_56`: Exactly 28 Reading + 28 Grammar tasks.
   - `test_v2_reading_tasks_schema_and_length_bounds`: All 28 reading tasks satisfy `ReadingTask` schema and 350–650 word bounds.
   - `test_v2_grammar_tasks_schema_and_rulepack_binding`: All 28 grammar tasks satisfy `GrammarTask` schema and bind valid `GrammarRulePack`.
   - `test_v2_paired_assignment_grid_cardinality_168`: Exactly 168 assignments across Arms A, B, and C.
   - `test_v2_assignment_identities_are_stable_and_paired`: Arm A, B, and C assignments share identical `dataset_item_id`.
2. **Tier 2 (Provenance Binding & Anti-Synthetic Defense):**
   - `test_v2_reading_tasks_provenance_matches_s02_ledger`: Every reading task binds authentic PMC XML digests from `V2_SOURCE_PROVENANCE_LEDGER.json`.
   - `test_v2_grammar_tasks_provenance_matches_s03_ledger`: Every grammar task binds authentic RulePack content digests from `V2_GRAMMAR_PROVENANCE_LEDGER.json`.
   - `test_v2_provenance_validation_fails_closed_on_tampered_digest`: Injected hash mismatch raises `ProvenanceValidationError`.
   - `test_v2_provenance_validation_rejects_synthetic_license`: Injected `"synthetic_not_expert"` license is rejected.
   - `test_v2_grammar_cefr_status_retains_provisional_marking`: Every grammar task retains `cefr_evidence_status="PROPOSED..."`.
3. **Tier 3 (Deterministic Paired Batching):**
   - `test_v2_batch_count_is_exact_12`: Exactly 12 batches formed.
   - `test_v2_batch_cardinality_ceiling_max_5_items`: No batch contains $>5$ items ($>15$ assignments).
   - `test_v2_batch_domain_isolation_no_mixing`: Zero batches combine Reading and Grammar tasks.
   - `test_v2_source_family_clustering_preserved_in_batches`: Same-family tasks appear in adjacent batch slots.
   - `test_v2_batch_deterministic_ordering`: Batch sorting is deterministic and order-invariant.
4. **Tier 4 (Split Isolation & Anti-Leakage):**
   - `test_v2_disjointness_rejects_forbidden_baseline_families`: Tasks referencing DEV/CAL/HOLD/G15 families raise `SourceFamilyOverlapError`.
   - `test_v2_reading_passages_zero_shared_10_word_spans_with_baseline`: Zero 10-word overlap against all 93 baseline passages.
   - `test_v2_reading_passages_permitted_v1_inheritance_isolated`: Inherited PMC sources verified free of baseline leakage.
   - `test_v2_anti_padding_within_and_across_tasks`: Zero repeated paragraphs within or across assembled tasks.
5. **Tier 5 (Idempotency & Reproducibility):**
   - `test_v2_registry_build_is_deterministic_and_idempotent`: Multiple instantiations produce identical task lists and hashes.
   - `test_v2_dataset_assembly_ledger_hash_integrity`: Output matches `V2_DATASET_ASSEMBLY_LEDGER.json`.
   - `test_v2_historical_v1_assets_remain_unmutated`: `final_dataset.py` and RG10 execution files remain byte-for-byte identical.

---

## 9. Implementation Steps & Work Breakdown (Post-Approval Execution)

Upon receiving explicit, dedicated user approval, Sprint V2-S04 executes across five structured steps:

### Step 1: Implement Dedicated CLI Tool (`check_v2_dataset_eligibility.py`)
- Author `generation_baseline/tools/check_v2_dataset_eligibility.py`.
- Implement CLI arguments `--verify-all`, `--check-batches`, `--check-provenance`, and `--check-disjointness`.
- Integrate upstream ledger verification and baseline n-gram overlap scanning.

### Step 2: Implement Isolated Registry (`final_dataset_v2.py`)
- Author `services/generation-service/app/experiment/final_dataset_v2.py`.
- Define `FinalDatasetV2Registry`, `ProvenanceValidationError`, and `SourceFamilyOverlapError`.
- Implement `build_reading_tasks()`: Loads 7 authenticated PMC articles from `sources_v2`, segments using `SemanticSentenceSegmenter`, generates 28 tasks with verified `SourceRef`.
- Implement `build_grammar_tasks()`: Loads 7 RulePacks from `grammar_packs_v2.py`, generates 28 tasks binding `rulepack_content_sha256` and provisional CEFR status.
- Implement `build_paired_assignments()`: Creates 168 assignments ($56 \times 3$) using `PairedAssignmentManager`.
- Implement `partition_batches()`: Formulates 12 batches of $\le 5$ items conforming to `FINAL_BATCH_RULES.md`.

### Step 3: Implement Comprehensive Test Suite (`test_v2_final_dataset.py`)
- Author `services/generation-service/tests/test_v2_final_dataset.py` covering all 22 acceptance tests across Tiers 1–5.
- Verify positive, negative, boundary, leakage, and idempotency paths.

### Step 4: Author Cryptographic Dataset Assembly Ledger
- Author `generation_baseline/verification/V2_DATASET_ASSEMBLY_LEDGER.json` capturing:
  - Canonical SHA-256 for all 56 tasks, 168 assignments, and 12 batches.
  - Complete provenance chains binding S02 PMC XML and S03 descriptive reference records.
  - Epistemic governance disclaimers (`DATASET_READY = HOLD`).

### Step 5: Verification Suite Execution & Closeout Report
- Execute dedicated V2 acceptance suites:
  `cd services/generation-service && python3 -m pytest tests/test_v2_final_dataset.py -v`
  `cd services/generation-service && python3 -m pytest tests/test_v2_*.py -v`
- Execute historical RG10 freeze regression suite:
  `cd services/generation-service && python3 -m pytest tests/test_rg10_*.py`
- Execute offline package and quarantine integrity checks:
  `python3 generation_baseline/tools/verify_v1_quarantine.py`
  `python3 generation_baseline/tools/verify_baseline.py`
  `python3 generation_baseline/tools/check_v2_dataset_eligibility.py --verify-all`
- Author `generation_baseline/verification/V2_S04_IMPLEMENTATION_AND_VERIFICATION_REPORT.md`.

---

## 10. Acceptance Gates & Exit Criteria

Sprint V2-S04 shall achieve gate closure (`PASS`) if and only if all of the following 8 acceptance gates are satisfied:

- [ ] **Gate 1 (Namespace & Historical Isolation):** `final_dataset_v2.py` resides strictly in dedicated V2 namespace; historical `final_dataset.py` and all 594 files in `V1_QUARANTINE_MANIFEST.json` remain byte-for-byte identical (0 mutations).
- [ ] **Gate 2 (Exact Task Cardinality):** Exactly 28 Reading + 28 Grammar paired tasks ($N=56$) are assembled, strictly conforming to Pydantic v2 schemas (`ReadingTask`, `GrammarTask`, `PairedTaskFixture`).
- [ ] **Gate 3 (Cryptographic Provenance Binding):** Every Reading task binds verified PMC XML digests from `V2_SOURCE_PROVENANCE_LEDGER.json`; every Grammar task binds verified RulePack digests from `V2_GRAMMAR_PROVENANCE_LEDGER.json`. Zero synthetic substitutions or fake licenses.
- [ ] **Gate 4 (Reading Passage Feasibility):** All 28 reading passages satisfy the 350–650 word range, begin on natural paragraph/sentence boundaries, and contain zero mid-word cuts or synthetic text duplication.
- [ ] **Gate 5 (Grammar CEFR & Epistemic Grounding):** All 28 grammar tasks preserve sub-rule reference citations, mark provisional CEFR levels as `PROPOSED`, and integrate the grammar validator strictly as a structural screening tool.
- [ ] **Gate 6 (Deterministic Paired Batching):** Exactly 168 arm assignments are partitioned into exactly 12 batches of $\le 5$ items ($\le 15$ assignments per batch) with zero cross-domain mixing, conforming to `FINAL_BATCH_RULES.md`.
- [ ] **Gate 7 (Split Isolation & Zero Leakage):** Automated disjointness scan confirms zero shared 10-word spans against DEV, CALIBRATION, HOLDOUT, G15, and quarantined V1 sources.
- [ ] **Gate 8 (Historical Regression & Safety Invariants):** 100% pass rate on all V2 tests, 353/353 pass rate on RG10 regression suite, 2,015/2,015 offline package checks passing; 0 MiniMax API calls, 0 live campaign dispatches, and 0 holdout inspections.

---

## 11. Rollback & Remediation Steps

If any acceptance gate fails during post-approval implementation:
1. **Source/Provenance Mismatch:** Revert affected task assembly definitions in `final_dataset_v2.py` without mutating upstream S02 or S03 ledgers. Re-query `verify_and_ingest_pmc_sources.py` or inspect `grammar_packs_v2.py`.
2. **Segmentation Boundary Failure:** If any reading passage falls outside 350–650 words, re-tune segment boundary cuts in `SemanticSentenceSegmenter` without duplicating text.
3. **Disjointness Collision:** If any passage shares $\ge 10$ words with baseline splits, flag the specific span, discard the candidate segment, and advance to the next compliant paragraph in the clean article text.
4. **Git Rollback Procedure:**
   ```bash
   # Discard uncommitted changes in final_dataset_v2.py and tests
   git checkout -- services/generation-service/app/experiment/final_dataset_v2.py
   git checkout -- services/generation-service/tests/test_v2_final_dataset.py
   git checkout -- generation_baseline/tools/check_v2_dataset_eligibility.py
   git status -s
   ```
5. **Historical Contamination Recovery:** If `verify_v1_quarantine.py` flags any mutation, immediately restore the quarantined asset from git index:
   ```bash
   git checkout -- services/generation-service/app/experiment/final_dataset.py
   git checkout -- generation_baseline/.execution/RG10/
   ```

---

## 12. Outstanding Blockers & Handoff Boundary

### 12.1 Outstanding Dataset-Readiness Prerequisites (`DATASET_READY = HOLD`)
Sprint V2-S04 plan preparation does NOT lift the `DATASET_READY = HOLD` state. The following prerequisites remain open:
1. **Prerequisite 1 (Reading Lexical Triage Adjudication):** Authorized human curator adjudication of all 5 reading lexical findings in `PADDING_REVIEW_TRIAGE.json` (currently `REVIEW_REQUIRED`).
2. **Prerequisite 2 (Grammar CEFR & EGP Adjudication):** Authorized human curator adjudication of provisional Cambridge EGP descriptor IDs and flagged sub-rules (`SUBJ-01` and `PASS-01`).
3. **Prerequisite 3 (Institutional Rights Review):** Formal institutional sign-off on fair-use compliance memorandum.
4. **Prerequisite 4 (Multi-Agent Audit - V2-S05):** Multi-agent pre-flight inspection across all 56 input tasks.
5. **Prerequisite 5 (Campaign Sealing - V2-S06):** Independent human curation of holdout ($N=30$) and cryptographic sealing of the 168-assignment campaign ledger.

### 12.2 Handoff Boundary

$$\mathbf{SPRINT\ V2-S04\ STATUS:\ PLAN\ CANDIDATE\ AWAITING\ USER\ APPROVAL}$$

**Execution stops here.** Sprint V2-S04 is strictly in planning-only status. Implementation code (`final_dataset_v2.py`), CLI tooling, and test execution shall NOT commence until explicit, dedicated user approval is granted for this sprint plan candidate.
