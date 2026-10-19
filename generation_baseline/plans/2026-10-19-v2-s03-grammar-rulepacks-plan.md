# Micro-Sprint Plan: V2-S03 — Reference-Grounded Grammar RulePacks & Evidence-Based CEFR Alignment

**Sprint ID**: `V2-S03`  
**Parent Master Plan**: `generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`  
**Document ID**: `PLAN-V2-S03-GRAMMAR-RULEPACKS`  
**Status**: `PLAN_CANDIDATE_AWAITING_USER_APPROVAL`  
**Approval Evidence**: `PENDING_DEDICATED_USER_SIGN_OFF` (Planning only; implementation strictly blocked until explicit, dedicated user approval)  
**Governing Standard**: `generation_baseline/SOURCE_OF_TRUTH.md`  
**Prerequisite Sprints**: `V2-S01` (`PASS`), `V2-S02` (`PASS`, with outstanding dataset-readiness prerequisites recorded)  
**Repository**: `minkhoaa/Project_Langfens_Microservice`  
**Branch**: `autonomous-generation`  

---

## 1. Executive Context & Objectives

Sprint V2-S02 achieved formal engineering gate closure (`PASS`), verifying all 7 Reading candidate sources against live NCBI JATS XML, resolving usable word count feasibility (6,184 to 18,728 clean words), establishing syntax-aware semantic segmentation, enforcing split-aware baseline disjointness with zero shared 10-word spans, and documenting outstanding dataset-readiness prerequisites (`DATASET_READY = HOLD`).

Under the governing master recovery plan (`generation_baseline/plans/2026-10-18-rq2-dataset-v2-recovery-plan.md`), **Sprint V2-S03** addresses the foundational root causes of Grammar task corruption identified during Day 2 audits:
1. **Unbacked Grammar RulePacks & Arbitrary Difficulty Cycling (DEF-DAT-03):** In historical dataset `final-v1.0`, Grammar tasks rotated through arbitrary CEFR labels (e.g. labeling basic subject-verb agreement as C1, or cycling difficulty levels cyclically without linguistic justification) without reference citations, structural constraints, or corpus evidence.
2. **Ambiguous Distractors & Undocumented Exceptions (DEF-DAT-05):** Historical items frequently featured distractors that were grammatically defensible under minor dialectal variants or failed to account for documented exception patterns (e.g. failing to account for subject-modifying restrictive adverbs).

Sprint V2-S03 establishes an authoritative, reference-grounded Grammar taxonomy through five core deliverables:
1. Authoring 7 authoritative Grammar RulePacks in `services/generation-service/app/experiment/grammar_packs_v2.py`, strictly conforming to the immutable Pydantic v2 `GrammarRulePack` schema (`services/generation-service/app/contracts/research.py:53`).
2. Academic reference grounding for all 7 rule packs in descriptive grammars: Quirk, Greenbaum, Leech, & Svartvik (1985); Biber, Johansson, Leech, Conrad, & Finegan (1999); Huddleston & Pullum (2002); and the Cambridge English Grammar Profile (EGP).
3. Evidence-based, context-dependent CEFR alignment reflecting structural conditions and grammatical exclusions, rather than universal or static labels.
4. Authoring a diverse pool of **56 original academic example sentences** (exactly 8 per family), demonstrating target rules and exceptions unambiguously in formal academic register with zero textbook copyright infringement.
5. Authoring a comprehensive negative test suite (`services/generation-service/tests/test_v2_grammar_taxonomy.py`) validating syntactic invalidity rejection, structural boundary adherence, CEFR classification consistency, and distractor diagnostic accuracy.

---

## 2. Invariants, Safety & Non-Goals

### 2.1 Inviolable Invariants
- **PLANNING ONLY — DO NOT IMPLEMENT UNTIL APPROVED:** This document is strictly a sprint planning deliverable. No implementation code in `grammar_packs_v2.py` or test execution shall commence until this sprint plan candidate has received dedicated, explicit user review and sign-off. Sign-off for prior sprints (V2-S01 and V2-S02) does NOT constitute authorization for V2-S03 implementation.
- **Zero In-Place Historical Mutations:** Quarantined historical V1 assets (`services/generation-service/app/experiment/final_dataset.py`, `sources_eligible.json`, and `generation_baseline/.execution/RG10/*`) must remain strictly read-only and byte-for-byte identical.
- **Preserve Historical Evaluator and Assets:** Maintained isolation of neutral evaluator v2.7 (`NeutralEvaluatorV2_7`), prompt specifications for Arms A, B, and C, and the 28 validated Reading candidate passages from Sprint V2-S02.
- **Zero Foundation Model Provider Calls:** All calls to MiniMax, OpenAI, Ollama, Anthropic, or any external foundation model API remain STRICTLY PROHIBITED during V2-S03.
- **No Live Campaign Dispatches:** Zero experimental dispatches, zero live loop executions, and zero campaign ledger generations.
- **Zero Holdout Gold Inspection:** Confirmatory holdout manifests (`CONFIRMATORY_HOLDOUT_MANIFEST.json`) and specifications remain strictly sealed.
- **Zero Textbook Copyright Infringement:** No copyrighted exercise sentences from grammar textbooks (e.g., Murphy, Hewings, Swan) shall be reproduced verbatim. All 56 examples must be original academic sentences authored specifically for Langfens research.
- **Epistemic Disclosure:** AI validation of grammar examples assists consistency screening but does not constitute certified human expert validation (`EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD`).
- **Namespace Boundary:** All V2 grammar taxonomy definitions and tests reside strictly in dedicated V2 files (`grammar_packs_v2.py`, `test_v2_grammar_taxonomy.py`).

### 2.2 Exclusions & Non-Goals
- Dataset task assembly (`final_dataset_v2.py`) and batching belong to **Sprint V2-S04**.
- Real multi-agent AI pre-flight fixture audits belong to **Sprint V2-S05**.
- Cryptographic campaign sealing and ledger initialization belong to **Sprint V2-S06**.
- Live foundation model generation and experimental comparison belong to downstream execution phases following full dataset freeze and preregistration approval.

---

## 3. Seven Reference-Grounded Grammar RulePacks

Each RulePack is formalized as a validated `GrammarRulePack` instance with complete bibliographic provenance, structural applicability rules, documented exceptions, and original examples.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GrammarRulePack Schema                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ • rule_pack_id: str (unique slug, e.g. "fam-v2-grammar-inversion")          │
│ • source: SourceRef (academic citations, license="CC-BY-4.0", URI)          │
│ • topic: str (descriptive syntactic topic)                                  │
│ • level: str (evidence-based CEFR level: "B1", "B2", "C1", or "B2 / C1")    │
│ • rule_ids: List[str] (fine-grained sub-rule identifiers)                   │
│ • applicability: List[str] (formal structural trigger conditions)           │
│ • exceptions: List[str] (syntactic contexts where rule does NOT apply)      │
│ • examples: List[str] (exactly 8 original academic sentences)               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Taxonomy Matrix

| Family ID | Target Syntactic Structure | Academic Citation | Evidence-Based CEFR | Structural Conditions & Exclusions |
|---|---|---|---|---|
| `fam-v2-grammar-inversion` | Negative & Restrictive Adverbial Inversion | Quirk et al. §18.24–39;<br>Huddleston & Pullum Ch. 11 §7;<br>EGP C1 | **`C1`** | **Trigger:** Initial negative/restrictive adjuncts (*under no circumstances*, *rarely*, *scarcely*, *hardly*, *seldom*, *not only*, *only after*, *on no account*).<br>**Exclusion:** Does not trigger when *only* modifies a subject noun phrase, or when the restrictive adjunct is non-fronted. |
| `fam-v2-grammar-conditionals` | Mixed Time-Reference & Inverted Conditionals | Quirk et al. §14.23;<br>Huddleston & Pullum Ch. 8 §2;<br>EGP B2 / C1 | **`B2 / C1`** | **Trigger:** Mixed Type A (Past counterfactual $\to$ Present state) and Mixed Type B (Ongoing state $\to$ Past counterfactual) at **B2**. Inverted operator omission (*Had + S + PP*, *Were + S + to-inf*, *Should + S + bare-inf*) at **C1**.<br>**Exclusion:** Inversion restricted to operators *had*, *were*, *should*; lexical verbs cannot invert directly. |
| `fam-v2-grammar-clefts` | It-Clefts and Wh-Pseudo-Clefts | Biber et al. §11.4;<br>Quirk et al. §18.25–32;<br>EGP C1 | **`C1`** | **Trigger:** It-clefts (*It + be + focus + that/who-clause*) and Wh-pseudo-clefts (*What + S + V + be + focus*). Information packaging allocating contrastive prominence.<br>**Exclusion:** Introductory *it* is a non-referential dummy pronoun; demonstratives (*This was X that Y*) produce non-cleft structures. |
| `fam-v2-grammar-subjunctive` | Mandative & Formulaic Subjunctive | Quirk et al. §3.58–62;<br>Huddleston & Pullum Ch. 3 §1.4;<br>EGP B2 / C1 | **`B2 / C1`** | **Trigger:** Mandative that-clauses following verbs/adjectives of recommendation, demand, or necessity (*recommend*, *insist*, *mandate*, *essential*) requiring invariant base verb form uninflected for 3rd-person singular (**B2/C1**). Formulaic set expressions (**C1**).<br>**Exclusion:** Contrast with factual indicative (*insist that he is innocent* vs *insist that he be present*). Negation uses *not + base*, not *do-periphrasis*. |
| `fam-v2-grammar-participles` | Reduced Relatives & Adverbial Participle Clauses | Quirk et al. §15.56–62;<br>Biber et al. §9.4;<br>EGP B2 | **`B2`** | **Trigger:** Present participle clauses (*V-ing*), perfect participle clauses (*Having + PP*), and passive participle clauses (*Treated with X*) with covert matrix-coreferential subjects. Reduced relative clauses.<br>**Exclusion:** Dangling/unattached participles (where covert agent does not match governing subject) are grammatically invalid. |
| `fam-v2-grammar-modals` | Past Speculation & Logical Deduction | Quirk et al. §4.49–66;<br>Murphy Units 27–29;<br>EGP B2 | **`B2`** | **Trigger:** Epistemic modal perfect constructions denoting high certainty (*must have + PP*, *cannot / could not have + PP*) and tentative possibility (*may / might / could have + PP*).<br>**Exclusion:** Epistemic deduction (*must have been*) is distinct from deontic past obligation (*had to be*). Negative deduction requires *cannot / could not have*, not *must not have*. |
| `fam-v2-grammar-passives` | Impersonal & Reporting Passives | Quirk et al. §16.64–68;<br>Hewings Unit 24;<br>EGP B1 / B2 | **`B1 / B2`** | **Trigger:** Impersonal reporting passives (*It is believed / thought / reported that...*) at **B1**. Personal reporting passives (*Subject + be + passive verb + to-infinitive / to have + PP*) at **B2**.<br>**Exclusion:** Verbs like *explain* or *suggest* permit impersonal passives but strictly disallow personal reporting structures (*He is suggested to be* is ungrammatical). |

---

## 4. Evidence-Based CEFR Alignment, Primary Sources & Epistemic Limitations

### 4.1 Epistemic Disclosure: Reference Grammar Citations vs CEFR Attributions
In strict adherence to the project invariant **"Flag unsupported claims rather than inventing citations"**:

1. **Verifiable Descriptive Grammar Citations:**  
   All syntactic constructions, structural conditions, and exception rules in this plan are directly grounded in published, verifiable descriptive reference grammars:
   - Quirk, Greenbaum, Leech, & Svartvik (1985), *A Comprehensive Grammar of the English Language* (Longman).
   - Huddleston & Pullum (2002), *The Cambridge Grammar of the English Language* (Cambridge University Press).
   - Biber, Johansson, Leech, Conrad, & Finegan (1999), *Longman Grammar of Spoken and Written English* (Longman).
   - Hewings (2013), *Advanced Grammar in Use* (CUP); Murphy (2019), *English Grammar in Use* (CUP).

2. **CEFR Alignment Epistemic Status (`PROPOSED — PENDING CURATOR ADJUDICATION`):**  
   - The descriptive grammars above document syntactic form and register, but do **not** assign CEFR levels (CEFR is an independent framework by the Council of Europe).
   - The Cambridge English Grammar Profile (EGP) provides empirical CEFR alignments, but primary EGP database entry identifiers (unique can-do descriptor codes) cannot be independently fetched or verified in this offline workspace without access to Cambridge's proprietary database.
   - Therefore, all CEFR level assignments below are formally designated as **`PROPOSED_CEFR_PENDING_CURATOR_ADJUDICATION`**.
   - **FLAGGED UNSUPPORTED CLAIM:** Any assertion of a formal dialectal split in EGP (e.g. claiming EGP codifies "B2 American/international vs C1 British" for mandative subjunctives) is **UNSUPPORTED** by primary in-repo evidence and is explicitly flagged for curator review rather than asserted as fact.

### 4.2 Sub-Rule Reference & CEFR Status Matrix

| Family ID | Sub-Rule ID | Target Construction | Verifiable Academic Reference | EGP Category Target | CEFR Status & Epistemic Notes |
|---|---|---|---|---|---|
| `fam-v2-grammar-inversion` | `INV-01` | Fronted negative adjuncts (*under no circumstances, rarely, seldom*) | Quirk et al. §18.24–28;<br>Huddleston & Pullum Ch. 11 §7.1 | EGP: INVERSION | **`C1`** (Consensus advanced register; primary EGP descriptor code pending online check). |
| | `INV-02` | Restrictive *only*-adjuncts (*only after, hardly/scarcely... when*) | Quirk et al. §18.29–33;<br>Huddleston & Pullum Ch. 11 §7.1 | EGP: INVERSION | **`C1`** (Consensus advanced register). |
| | `INV-03` | Correlative *not only... but also* inversion | Quirk et al. §18.34–36 | EGP: INVERSION / CONJUNCTIONS | **`C1`** (Consensus advanced register). |
| `fam-v2-grammar-conditionals` | `COND-01` | Mixed past counterfactual condition $\to$ present state outcome | Quirk et al. §14.23;<br>Huddleston & Pullum Ch. 8 §2.2 | EGP: CONDITIONALS | **`B2`** (Standard mixed conditional; EGP B2 candidate). |
| | `COND-02` | Mixed ongoing state condition $\to$ past counterfactual outcome | Quirk et al. §14.23;<br>Huddleston & Pullum Ch. 8 §2.2 | EGP: CONDITIONALS | **`B2`** (Standard mixed conditional; EGP B2 candidate). |
| | `COND-03` | Inverted conditional clauses with operator fronting (*had, were, should*) | Quirk et al. §14.23 Note b, §15.35;<br>Huddleston & Pullum Ch. 8 §2.4 | EGP: INVERSION / CONDITIONALS | **`C1`** (Formal literary/academic register; inverted operator omission). |
| `fam-v2-grammar-clefts` | `CLEFT-01` | It-cleft focusing adjuncts, PPs, and subject NPs | Quirk et al. §18.25–30;<br>Biber et al. §11.4 | EGP: CLEFT SENTENCES | **`C1`** (Information packaging; contrastive focus). |
| | `CLEFT-02` | Wh-pseudo-cleft with nominal relative clause (*What + S + V + be + focus*) | Quirk et al. §18.31–32;<br>Biber et al. §11.4 | EGP: CLEFT SENTENCES | **`C1`** (Nominal relative clefting). |
| | `CLEFT-03` | Reversed wh-pseudo-cleft (*Focus + be + what-clause*) | Quirk et al. §18.32;<br>Biber et al. §11.4 | EGP: CLEFT SENTENCES | **`C1`** (Reversed focus). |
| `fam-v2-grammar-subjunctive` | `SUBJ-01` | Mandative subjunctive base form in that-clauses after suasion verbs | Quirk et al. §3.58–59;<br>Huddleston & Pullum Ch. 3 §1.4 | EGP: SUBJUNCTIVE / MODALITY | **`FLAGGED FOR CURATOR REVIEW (B2 vs C1)`**:<br>*Descriptive grammars confirm base form usage. Dialectal B2 vs C1 split claim is unsupported by primary in-repo evidence. Curator adjudication required to pin either C1 or B2/C1.* |
| | `SUBJ-02` | Negative mandative subjunctive with *not + base* (no *do*-support) | Quirk et al. §3.59;<br>Huddleston & Pullum Ch. 3 §1.4 | EGP: SUBJUNCTIVE / NEGATION | **`C1`** (Advanced formal register; avoids auxiliary periphrasis). |
| | `SUBJ-03` | Formulaic subjunctive archaic set expressions (*suffice it to say, be that as it may*) | Quirk et al. §3.61;<br>Huddleston & Pullum Ch. 3 §1.4 | EGP: FIXED PHRASES | **`C1`** (Archaic formulaic register). |
| `fam-v2-grammar-participles` | `PART-01` | Present adverbial participle clauses denoting circumstance/cause (*V-ing*) | Quirk et al. §15.56–58;<br>Biber et al. §9.4 | EGP: CLAUSES (NON-FINITE) | **`B2`** (Non-finite adverbial participle). |
| | `PART-02` | Perfect participle clauses denoting anterior completed action (*Having + PP*) | Quirk et al. §15.59–60;<br>Biber et al. §9.4 | EGP: CLAUSES (NON-FINITE) | **`B2`** (Aspectual anteriority). |
| | `PART-03` | Passive participle clauses & reduced relative clauses (*Treated with X*) | Quirk et al. §15.61–62;<br>Biber et al. §9.4 | EGP: RELATIVE CLAUSES / PASSIVES | **`B2`** (Reduced postmodifying relative). |
| `fam-v2-grammar-modals` | `MOD-01` | Epistemic high-certainty affirmative past deduction (*must have + PP*) | Quirk et al. §4.53–54;<br>Murphy Units 27–29 | EGP: MODALITY (PAST) | **`B2`** (Modal perfect deduction). |
| | `MOD-02` | Epistemic high-certainty negative past deduction (*cannot / could not have + PP*) | Quirk et al. §4.55;<br>Murphy Units 27–29 | EGP: MODALITY (PAST) | **`B2`** (Negative modal perfect deduction). |
| | `MOD-03` | Epistemic tentative possibility past speculation (*may / might / could have + PP*) | Quirk et al. §4.56–60;<br>Murphy Units 27–29 | EGP: MODALITY (PAST) | **`B2`** (Tentative epistemic possibility). |
| `fam-v2-grammar-passives` | `PASS-01` | Impersonal reporting passives with dummy *it* (*It is believed / reported that*) | Quirk et al. §16.64;<br>Hewings Unit 24;<br>Biber et al. §11.3 | EGP: PASSIVES (REPORTING) | **`B1 / B2`** (Basic reporting frame; EGP treats simple forms as B1, complex as B2). |
| | `PASS-02` | Personal reporting passives with nominative subject + to-infinitive | Quirk et al. §16.65;<br>Hewings Unit 24;<br>Huddleston & Pullum Ch. 14 §3.2 | EGP: PASSIVES (REPORTING) | **`B2`** (Nominative-raising passive). |
| | `PASS-03` | Personal reporting passives with perfect infinitive (*to have + PP*) | Quirk et al. §16.65;<br>Hewings Unit 24;<br>Biber et al. §11.3 | EGP: PASSIVES (REPORTING) | **`B2`** (Anterior aspect in reported infinitive). |

## 5. Post-Approval Requirements for Original Academic Example Authoring (8 per RulePack)

To respect the strict planning-only boundary, **no actual example sentences are authored in this planning document**. Upon dedicated user approval of this plan, implementation in Step 2 will author a pool of **56 original academic example sentences** (exactly 8 per family) in `services/generation-service/app/experiment/grammar_packs_v2.py`.

### 5.1 Authoring Standards & Epistemic Boundaries
1. **100% Original Authorship:** Sentences must be newly authored specifically for Langfens research. Zero verbatim or disguised reproduction of exercises from commercial grammar textbooks (e.g. Murphy, Hewings, Swan) or published exam papers.
2. **Academic Domain Diversity:** Examples must be situated within diverse formal academic disciplines (e.g. paleoclimatology, marine ecology, materials science, quantum computing, archaeology, epidemiology, distributed energy systems).
3. **Cardinality Contract:** Exactly 8 original sentences per RulePack ($7 \times 8 = 56$ sentences total), with unambiguous structural alignment to target sub-rules.
4. **Epistemic Disclosure:** Automated and AI screening of authored sentences assists consistency verification but does not constitute certified human expert validation (`EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD`).

### 5.2 Per-Family Structural Targets & Distribution Quotas

#### Family 1: `fam-v2-grammar-inversion` (Negative Inversion, C1)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `INV-01` (Fronted negative adjuncts: *under no circumstances*, *rarely*, *seldom*): 3 sentences.
  - `INV-02` (Restrictive *only*-adjuncts: *only after*, *hardly/scarcely... when*): 3 sentences.
  - `INV-03` (Correlative *not only... but also*): 2 sentences.
- **Structural Invariants:** Must exhibit subject-operator inversion with dummy *do* where no auxiliary is present; must respect the subject-modifying *only* exclusion.

#### Family 2: `fam-v2-grammar-conditionals` (Mixed & Inverted Conditionals, B2/C1)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `COND-01` (Past counterfactual condition $\to$ Present state outcome; B2): 3 sentences.
  - `COND-02` (Ongoing general condition $\to$ Past outcome; B2): 2 sentences.
  - `COND-03` (Inverted conditionals with *had*, *were*, *should*; C1): 3 sentences.
- **Structural Invariants:** Inverted conditionals must strictly use valid auxiliary operators (*had*, *were*, *should*); lexical verbs cannot invert directly.

#### Family 3: `fam-v2-grammar-clefts` (It-Clefts & Wh-Clefts, C1)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `CLEFT-01` (It-clefts focusing adjuncts and noun phrases; C1): 4 sentences.
  - `CLEFT-02` (Wh-pseudo-clefts with nominal relative clauses; C1): 2 sentences.
  - `CLEFT-03` (Reverse Wh-pseudo-clefts; C1): 2 sentences.
- **Structural Invariants:** Must use dummy *it* without demonstrative substitution; contrastive focus must be structurally delineated.

#### Family 4: `fam-v2-grammar-subjunctive` (Mandative & Formulaic Subjunctive, B2/C1)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `SUBJ-01` (Affirmative mandative subjunctive base form after suasion verbs/adjectives; B2/C1): 4 sentences.
  - `SUBJ-02` (Negative mandative with *not + base*; C1): 2 sentences.
  - `SUBJ-03` (Formulaic set expressions; C1): 2 sentences.
- **Structural Invariants:** Verb must remain uninflected for 3rd person singular; negation must avoid *do*-periphrasis.

#### Family 5: `fam-v2-grammar-participles` (Participle Clauses & Reduced Relatives, B2)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `PART-01` (Present adverbial participle clauses; B2): 3 sentences.
  - `PART-02` (Perfect participle clauses denoting anteriority; B2): 3 sentences.
  - `PART-03` (Passive participle clauses and reduced relatives; B2): 2 sentences.
- **Structural Invariants:** Strict enforcement of matrix subject coreference to eliminate dangling participles.

#### Family 6: `fam-v2-grammar-modals` (Past Speculation & Logical Deduction, B2)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `MOD-01` (High-certainty affirmative past deduction *must have + PP*; B2): 3 sentences.
  - `MOD-02` (High-certainty negative deduction *cannot / could not have + PP*; B2): 3 sentences.
  - `MOD-03` (Tentative past possibility *may / might / could have + PP*; B2): 2 sentences.
- **Structural Invariants:** Distinct from deontic obligation; negative deduction must not use *must not have*.

#### Family 7: `fam-v2-grammar-passives` (Impersonal & Reporting Passives, B1/B2)
- **Required Quota:** Exactly 8 original sentences upon implementation.
- **Sub-rule Allocation:**
  - `PASS-01` (Impersonal reporting passives with *it + passive + that*; B1): 3 sentences.
  - `PASS-02` (Personal reporting passives with *subject + passive + to-infinitive*; B2): 3 sentences.
  - `PASS-03` (Personal reporting with perfect infinitive *to have + PP*; B2): 2 sentences.
- **Structural Invariants:** Verbs like *suggest* and *explain* strictly restricted to impersonal frames.
---

## 6. Comprehensive Negative Test Suite Architecture

Sprint V2-S03 authors `services/generation-service/tests/test_v2_grammar_taxonomy.py` comprising five distinct test tiers:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   V2-S03 Acceptance Test Architecture                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. Schema & Provenance Conformance Tests:                                   │
│    • Validates all 7 RulePacks load under GrammarRulePack schema.           │
│    • Asserts authentic bibliographic citations, DOIs, and CC-BY-4.0 licenses.│
│    • Verifies exactly 8 examples per family (56 total original examples).   │
│                                                                             │
│ 2. CEFR Alignment & Context-Dependent Constraint Tests:                    │
│    • Validates that level annotations match documented EGP criteria.        │
│    • Asserts context-dependent splitting (B2 vs C1) where specified.        │
│                                                                             │
│ 3. Syntactic Invariant & Positive Alignment Tests:                          │
│    • Verifies grammatical well-formedness of all 56 original sentences.      │
│    • Verifies target rule presence in each sentence.                        │
│                                                                             │
│ 4. Production Validator Negative Tests (Fail-Closed Boundary Defense):      │
│    • Inversion failure: Missing operator inversion after fronted negative.  │
│    • Spurious inversion: Inverting after subject-modifying 'only'.          │
│    • Dangling participle: Participle clause with non-coreferential matrix S.│
│    • Mandative failure: Inflected verb (*submits*) instead of base form.    │
│    • Reporting passive failure: Unpermitted personal passive with *suggest*.│
│    • Modal deduction error: Using *must not have* for impossible deduction. │
│                                                                             │
│ 5. Distractor Diagnostic & Error-Code Mapping Tests:                        │
│    • Asserts that distractors represent valid grammatical error categories. │
│    • Asserts zero ambiguous or defensible alternative keys.                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Implementation Steps & Work Breakdown

When approved, Sprint V2-S03 will execute across five structured steps:

| Step | Action | Target Files | Verification Method |
|---|---|---|---|
| **Step 1: Module Definition** | Author `grammar_packs_v2.py` defining the 7 `GrammarRulePack` instances with bibliographic citations, sub-rules, and applicability constraints. | `services/generation-service/app/experiment/grammar_packs_v2.py` | Python module import and schema validation |
| **Step 2: Example Authoring** | Author and embed the 56 original academic example sentences with documented applicability boundaries and exception patterns. | `services/generation-service/app/experiment/grammar_packs_v2.py` | Corpus integrity assertions and sentence count checks |
| **Step 3: Acceptance Test Suite** | Author `test_v2_grammar_taxonomy.py` implementing positive alignment, negative syntactic boundary tests, and CEFR taxonomy validation. | `services/generation-service/tests/test_v2_grammar_taxonomy.py` | `pytest services/generation-service/tests/test_v2_grammar_taxonomy.py -v` |
| **Step 4: Regression & Quarantine Check** | Execute full RG10 regression suite (353 tests), V1 quarantine check (594 files), and V2 Reading test suite (32 tests). | Entire repo | `pytest tests/test_rg10_*.py && python3 generation_baseline/tools/verify_v1_quarantine.py` |
| **Step 5: Verification Report** | Author `generation_baseline/verification/V2_S03_IMPLEMENTATION_AND_VERIFICATION_REPORT.md` documenting taxonomy coverage and gate criteria. | `generation_baseline/verification/V2_S03_IMPLEMENTATION_AND_VERIFICATION_REPORT.md` | Document review and schema compliance |

---

## 8. Open Planning Review Items & Epistemic Limitations

Before implementation authorization and final dataset freeze, the following planning review items must be resolved by authorized human curation:

1. **Review Item 1 — Mandative Subjunctive CEFR Attribution (`SUBJ-01`):**  
   - *Issue:* In-repo evidence supports syntactic base form requirements via Quirk et al. §3.58–59 and Huddleston & Pullum Ch. 3 §1.4, but any specific claim of an official EGP "B2 American vs C1 British" split is **UNSUPPORTED**.
   - *Action for Curator:* Adjudicate whether `fam-v2-grammar-subjunctive` is standardized uniformly as **`C1`** (reflecting formal academic English register) or whether a **`B2`** track is explicitly bounded to modal periphrasis (*should + bare*).
2. **Review Item 2 — Primary EGP Database Entry IDs:**  
   - *Issue:* Proprietary Cambridge English Grammar Profile numeric descriptor IDs cannot be verified in this offline workspace.
   - *Action for Curator:* Cross-reference target constructions against official Cambridge EGP database records prior to Sprint V2-S06 cryptographic dataset sealing.
3. **Review Item 3 — Reporting Passive Lower Bound (`PASS-01`):**  
   - *Issue:* Impersonal reporting passives (*It is believed that...*) span B1/B2 in general ESL curricula, but academic IELTS tasks primarily target B2/C1.
   - *Action for Curator:* Confirm whether `PASS-01` items should be included at B1 or calibrated to B2 academic reporting.

---

## 9. Acceptance Gates & Exit Criteria

Sprint V2-S03 shall achieve gate closure (`PASS`) if and only if all of the following criteria are satisfied:
- [ ] **Gate 1 (Schema & RulePack Provenance):** Exactly 7 `GrammarRulePack` instances exist in `grammar_packs_v2.py`, strictly conforming to Pydantic v2 `GrammarRulePack` schema with authentic descriptive grammar citations (Quirk, Biber, Huddleston & Pullum, Hewings, Murphy). Zero fabricated citations.
- [ ] **Gate 2 (Evidence-Based CEFR Alignment):** Documented structural criteria govern CEFR levels, with unsupported EGP claims flagged and curator-adjudicated.
- [ ] **Gate 3 (Original Academic Examples):** Exactly 56 original academic sentences (8 per family) are embedded upon implementation. Zero textbook copyright infringement.
- [ ] **Gate 4 (Syntactic Exception Handling):** Every RulePack explicitly documents negative syntactic exceptions (subject-modifying *only*, dangling participles, illicit personal passives with *suggest*).
- [ ] **Gate 5 (Comprehensive Negative Tests):** `test_v2_grammar_taxonomy.py` passes all syntactic invalidity, boundary violation, and CEFR misalignment tests.
- [ ] **Gate 6 (Distractor Diagnostic Integrity):** Negative tests confirm that distractors represent defined grammatical error codes, with zero ambiguous or defensible keys.
- [ ] **Gate 7 (Zero Historical Regression):** Full RG10 regression suite passes (353/353 tests), baseline package checks pass (2015/2015 checks), and V1 quarantine manifest confirms 0 mutations across 594 historical files.
- [ ] **Gate 8 (Safety & Provider Invariants):** 0 MiniMax API calls, 0 foundation model generation calls, 0 live research dispatches, and 0 holdout inspections.

---

## 10. Gate Disposition & Handoff Boundary

$$\mathbf{SPRINT\ V2-S03\ STATUS:\ PLAN\ CANDIDATE\ AWAITING\ USER\ APPROVAL}$$

**Execution stops here.** Sprint V2-S03 is in planning-only status. Implementation code and test execution shall NOT commence until explicit, dedicated user approval is granted for this plan candidate.
