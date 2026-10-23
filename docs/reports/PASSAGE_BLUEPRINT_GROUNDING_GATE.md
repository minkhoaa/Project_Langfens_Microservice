# Langfens Autonomous Reading Engine — Passage–Blueprint Grounding Consistency Gate

**Document ID:** `REPORT-2026-10-23-PASSAGE-BLUEPRINT-GROUNDING-GATE`  
**Location:** `docs/reports/PASSAGE_BLUEPRINT_GROUNDING_GATE.md`  
**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Baseline Commit:** `fcac16826334b472d4f8fdc22f3bd179010d3476`  
**Verification Scope:** Offline Gate Enforcement, Candidate Extraction Hardening, and Diagnostic Verification  
**Authoritative Verdict:** **`PASSAGE_BLUEPRINT_GROUNDING: PASS`**  

---

## 1. Executive Summary & Authoritative Verdict

This report documents the resolution and verification of the source-to-passage grounding defect reproduced from the Hybrid Single-Section Live campaign (`REPORT-2026-10-23-HYBRID-SINGLE-SECTION-LIVE-VALIDATION`).

### 1.1 Core Defect and Mechanism
During live execution of Job `eefdea7e-ee1a-4b0c-8ce2-f7cfd1c317fb`, Stage 4 (Passage Synthesis) accepted an 880-word passage that omitted essential scientific claims bound to frozen Blueprint question slots (notably Claim 12 regarding the Jos Plateau in Nigeria, assigned to Question 2). Stage 5 (Question Generation) subsequently fell back to substituting the original source-pack claim text as `target_focus`, prompting `MiniMax-Text-01` to draft questions anchored to facts absent from the accepted passage. When candidate extraction strictly required verbatim evidence in the passage, candidate parsing failed with `ValueError`, halting generation fail-closed.

### 1.2 Engineering Solution
1. **Mandatory Passage–Blueprint Consistency Gate (Task 2):** Introduced `verify_passage_blueprint_grounding` and integrated it directly into `evaluate_passage` (`eval_passage_fidelity`). The evaluator verifies that every blueprint-bound question slot has verifiable support (exact verbatim alignment or independently verified semantic paraphrase) in the passage before passage acceptance. Unsupported slot mappings produce an explicit `PASSAGE_BLUEPRINT_ALIGNMENT` diagnostic, halting or triggering bounded passage repair before acceptance.
2. **Authoritative Candidate Extraction & Rejection Typing (Task 3):**
   - Treated the accepted passage as the sole authoritative answerable content.
   - Eliminated the fallback that replaced missing passage alignments with source claim text as `target_focus`.
   - Added deterministic preflight checks that halt before calling the LLM provider if a slot's claim lacks verified passage alignment.
   - Enhanced candidate pool selection to skip ungrounded quotes and select valid alternatives.
   - Provided bounded regeneration feedback on quote verbatim requirements.
   - Structured candidate rejections into 4 explicit, typed categories:
     1. `CLAIM_NOT_SUPPORTED_IN_PASSAGE`
     2. `QUOTE_NOT_VERBATIM`
     3. `CANDIDATE_DUPLICATE`
     4. `CANDIDATE_SCHEMA_INVALID`
     Prevented automatic conversion of candidate parsing defects into `AMBIGUOUS_ANSWER`.
3. **Preserved Hybrid Authority (Task 4):** Kept MiniMax-Text-01 for drafting and MiniMax-M3 strictly for surgical diagnostic repair planning under `BoundedLoopRuntime`.
4. **Comprehensive Offline Verification (Task 5):** Validated all 12 mandatory offline test scenarios (12/12 passed in 0.71s), alongside full regression suites (211/211 passed).
5. **Provider Accounting Audit (Task 6):** Audited the 6 recorded `PROVIDER_CALL` operations in `reports/hybrid_single_section_live_snapshot.json` totaling 19,065 tokens.

```text
================================================================================
FINAL VERDICT: PASSAGE_BLUEPRINT_GROUNDING: PASS
================================================================================
```

---

## 2. Task 1 — Offline Failure Reproduction & Forensic Audit

Using the committed forensic snapshot `reports/hybrid_single_section_live_snapshot.json`, the exact execution graph was reconstructed:

### 2.1 Reconstructed Artifact Graph
- **SourcePack:** `source:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb:1` (Europe PMC `PMC13654891`, 10,524 words, CC BY 4.0).
- **EvidenceGraph:** `evidence:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb:1` containing **16 verified atomic claims**.
- **ExamBlueprint:** `blueprint:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb` allocating **13 question slots** across Section 1.
- **Passage:** `passage:run_eefdea7eee1a4b0c8ce2f7cfd1c317fb:1` (880 words, content hash `0c7bb316...`).
- **Claim Alignments:** Exactly **6 exact passage claim alignments** recorded (`claim:..:1:1` through `claim:..:1:6`).

### 2.2 Question Slot Mapping Audit

| Question | Blueprint Bound Claim | Claim Topic / Entity | In Accepted Passage? | Alignment Status |
|---|---|---|---|---|
| **Q01** | `claim:...:1:2` | Preservation & dating scarcity | **YES** (Verbatim) | **Exact Alignment (1 of 6)** |
| **Q02** | `claim:...:1:12` | **Jos Plateau bloomery furnaces (600 BCE, Junius 2023)** | **NO** (0 occurrences) | **ABSENT (Genuine Semantic Failure)** |
| **Q03** | `claim:...:1:1` | Early iron production in West Africa | **YES** (Verbatim) | **Exact Alignment (NOT_GIVEN Topical Anchor)** |
| **Q04** | `claim:...:1:9` | Limited established chronologies | **NO** (Exact text absent) | Semantic paraphrase present ("only a few are precisely dated") |
| **Q05** | `claim:...:1:6` | Historiographical references (Alpern, Killick) | **YES** (Verbatim) | **Exact Alignment (3 of 6)** |
| **Q06** | `claim:...:1:14` | Douroula (Burkina Faso) & Dekpassanware (Togo) | **NO** (0 occurrences) | **ABSENT (Genuine Semantic Failure)** |
| **Q07** | `claim:...:1:11` | Nsukka sustained production evidence (Okafor) | **NO** (Exact text absent) | Partial mention of Nsukka; Okafor absent |
| **Q08** | `claim:...:1:4` | Evolution of technical practices & raw materials | **YES** (Verbatim) | **Exact Alignment (4 of 6)** |
| **Q09** | `claim:...:1:3` | Rarity of long-term chronological sequences | **YES** (Verbatim) | **Exact Alignment (5 of 6)** |
| **Q10** | `claim:...:1:13` | Termit Massif in Niger | **NO** (Exact text absent) | Semantic mention of Termit Massif |
| **Q11** | `claim:...:1:7` | Early iron production districts (1st millennium BCE) | **NO** (Exact text absent) | **Grounded Paraphrase** (Supported semantically) |
| **Q12** | `claim:...:1:1` | First millennium BCE diverse techniques | **YES** (Verbatim) | **Exact Alignment (6 of 6)** |
| **Q13** | `claim:...:1:11` | Nsukka sustained production evidence | **NO** (Exact text absent) | Partial mention |

### 2.3 Exact Alignment vs Genuine Semantic Failure
1. **6 Exact Alignments:** Claims 1, 2, 3, 4, 5, and 6 were copied into the passage paragraphs.
2. **Genuine Semantic Coverage Failures:**
   - **Claim 12 (Jos Plateau, assigned to Q2):** Neither "Jos", "Plateau", nor "Junius" appears in `passage_text` (0 occurrences). This is a total semantic absence.
   - **Claim 14 (Burkina Faso / Togo, assigned to Q6):** Neither "Burkina", "Faso", "Douroula", "Togo", nor "Dekpassanware" appears (0 occurrences).
3. **Grounded Paraphrases:**
   - **Claim 7 (assigned to Q11):** The passage states: *"The emergence and development of iron metallurgy in sub-Saharan West Africa represent a critical chapter in the region's technological history, with evidence of diverse smelting techniques dating back to the first millennium BCE... with ongoing research identifying several early production districts..."* Substantive grounding ratio is high without negation or polarity conflict.

---

## 3. Root Cause Investigation

```text
[Stage 2: EvidenceGraph]
   Extracted 16 verified scientific claims (including Claim 12: Jos Plateau)
           │
           ▼
[Stage 3: ExamBlueprint]
   Allocated 13 question slots (Q2 bound to Claim 12)
           │
           ▼
[Stage 4: Passage Synthesis]
   MiniMax-Text-01 generated 880-word passage focusing on Falémé Valley.
   Omitted Jos Plateau (Nigeria) and Douroula (Burkina Faso).
   evaluate_passage ONLY checked:
     - Word count (880 in [720, 915]) -> PASS
     - Extant alignments truthful -> PASS
     - Every paragraph has >= 1 alignment -> PASS
   CRITICAL GAP: Passage evaluators NEVER checked Blueprint slot coverage!
   Passage committed and accepted (V1).
           │
           ▼
[Stage 5: Question Generation - Question 2]
   aligned_claim_map lacked Claim 12.
   section_runner.py fell back: target_focus = claims_map[claim_id]["text"] (Source text)
   MiniMax prompted with source claim: "Sites on the Jos Plateau..."
   MiniMax generated candidate: quote = "Sites on the Jos Plateau, dated to aroun"
   _parse_single_candidate checked passage.find(quote) -> returned -1.
   Raised ValueError: "Question 2 evidence quote ... is not found in passage"
   Loop recorded GENERATE@1: CAPABILITY_FAILURE (ValueError) -> Clean halt fail-closed.
```

---

## 4. Task 2 — Implementation of Passage–Blueprint Consistency Gate

### 4.1 Gate Architecture & Evaluator Integration
Added `verify_passage_blueprint_grounding` and wired it directly into `evaluate_passage` (`eval_passage_fidelity`) in `services/generation-service/app/reading_evaluation.py`.

```python
def verify_passage_blueprint_grounding(
    passage: str,
    alignments: Sequence[Mapping[str, Any]],
    claims: Mapping[str, Any],
    slots: Sequence[Mapping[str, Any]],
    source_text: str = "",
) -> list[Problem]:
```

**Consistency Verification Invariants:**
1. **Positive-Evidence Questions:**
   - Checks declared alignments (`claimAlignments`) in passage.
   - Checks exact verbatim match of claim text.
   - Checks independently verified semantic alignment via grounded paraphrases:
     - Substantive grounding ratio $\ge 0.60$ (`compute_substantive_grounding_ratio`).
     - Negation polarity conflict check (`detect_negation_polarity_conflict` must be False).
     - Comparison inversion check (`detect_comparison_inversion` must be False).
     - Number alteration check (no invented quantities).
   - If unsupported: appends `(IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT, f"Question slot {q_num} bound claim '{cid}' lacks verifiable support in passage")`.
2. **NOT_GIVEN Questions:**
   - Preserves absence contract without fabricating positive evidence.
   - Verifies relevant topical context (key entities or substantive topic words) exists in the passage.
   - Verifies passage-wide absence of the specific asserted fact.
   - If topical context is missing: appends `(IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT, f"Question slot {q_num} (NOT_GIVEN) lacks relevant topical context in passage")`.

### 4.2 Bounded Passage Repair & Regeneration
In `services/generation-service/app/section_runner.py`:
- Registered `repair_passage_stage` callback in `executor.execute` for `ArtifactType.PASSAGE`.
- When `PASSAGE_BLUEPRINT_ALIGNMENT` issues are reported, `repair_passage_stage` identifies missing blueprint claims and attempts to integrate them into the passage if the resulting length remains $\le \text{config.max\_words}$.
- If word limit bounds or version caps are reached, it raises `RepairExecutionError` and fails closed with the explicit `PASSAGE_BLUEPRINT_ALIGNMENT` diagnostic.
- Blueprint claim bindings remain strictly immutable (no silent claim rotation).

---

## 5. Task 3 — Correction of Question Candidate Extraction

### 5.1 Authoritative Content & Preflight Fencing
1. **No Source-Pack Substitution:** Removed `claims_map[claim_id]["text"]` fallback for `target_focus`. In `section_runner.py`, `target_focus` is strictly `aligned_claim_map[claim_id]["passageQuote"]`.
2. **Deterministic Preflight Gate:** Before dispatching question candidate generation, `SectionRunner` verifies that `claim_id in aligned_claim_map` for positive slots. If missing, it immediately raises:
   ```python
   CandidateRejectionError(
       CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
       f"Question slot {q_num} bound claim '{claim_id}' has no verified alignment in the accepted passage. Fail-closed: question generation cannot target claims absent from the passage."
   )
   ```
   Zero provider calls are dispatched on ungrounded slots.

### 5.2 Structured Candidate Rejection Typing
Replaced generic string-based `ValueError` exceptions with `CandidateRejectionError` inheriting from `ValueError`:

```python
class CandidateRejectionReason(str, Enum):
    CLAIM_NOT_SUPPORTED_IN_PASSAGE = "CLAIM_NOT_SUPPORTED_IN_PASSAGE"
    QUOTE_NOT_VERBATIM = "QUOTE_NOT_VERBATIM"
    CANDIDATE_DUPLICATE = "CANDIDATE_DUPLICATE"
    CANDIDATE_SCHEMA_INVALID = "CANDIDATE_SCHEMA_INVALID"

class CandidateRejectionError(ValueError):
    def __init__(self, reason: CandidateRejectionReason, message: str):
        super().__init__(f"[{reason.value}] {message}")
        self.reason = reason
        self.message = message
```

### 5.3 Candidate Pool Selection & Regeneration Feedback
- **Candidate Pool Selection:** In `_parse_candidate_payload`, if Candidate 0 has an ungrounded quote, it is skipped with `QUOTE_NOT_VERBATIM`. If Candidate 1 in the pool has a valid verbatim quote in the passage, Candidate 1 is parsed and accepted.
- **Bounded Regeneration Feedback:** On attempt 1 failure due to `QUOTE_NOT_VERBATIM`, attempt 2 includes explicit prompt feedback:
  *"Your previous candidate's evidenceQuote was not found verbatim in the passage text. Target Focus Span: '{target_focus}'. You MUST extract evidenceQuote as an EXACT, UNALTERED, VERBATIM substring from the passage text above."*
- **No Masquerading as Ambiguity:** Ungrounded candidate quotes are never routed to M3 as `AMBIGUOUS_ANSWER`. M3 is reserved strictly for genuine semantic failures on accepted candidate artifacts.

---

## 6. Task 4 — Preservation of Hybrid Authority

| Invariant | Implementation Mechanism | Status |
|---|---|---|
| **Drafting Authority** | `MiniMax-Text-01` exclusively for passage synthesis and question candidate generation | **PRESERVED** |
| **Repair Authority** | `MiniMax-M3` strictly restricted to surgical diagnostic repair planning (`Capability.PLAN_REPAIR`) | **PRESERVED** |
| **Loop Authority** | `BoundedLoopRuntime` governs all state transitions, version increments, and checkpoint commits | **PRESERVED** |
| **Evaluation Authority** | Deterministic evaluators (`eval_passage_fidelity`, `eval_evidence_offsets`, etc.) | **PRESERVED** |
| **Resource Caps** | Zero budget enlargement; zero unbounded retries; strict `max_versions` and call limits | **PRESERVED** |

---

## 7. Task 5 — Targeted Offline Test Suite Results

A dedicated authoritative offline test suite was authored in `services/generation-service/tests/test_passage_blueprint_grounding_gate.py` verifying all 12 required scenarios:

```bash
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/test_passage_blueprint_grounding_gate.py -v
============================= test session starts ==============================
collected 12 items

tests/test_passage_blueprint_grounding_gate.py::test_01_passage_with_all_required_claims_supported PASSED [  8%]
tests/test_passage_blueprint_grounding_gate.py::test_02_source_claim_valid_but_absent_from_passage PASSED [ 16%]
tests/test_passage_blueprint_grounding_gate.py::test_03_claim_semantically_supported_through_grounded_paraphrase PASSED [ 25%]
tests/test_passage_blueprint_grounding_gate.py::test_04_valid_source_quote_absent_from_passage_is_rejected PASSED [ 33%]
tests/test_passage_blueprint_grounding_gate.py::test_05_candidate_pool_skips_invalid_quotes_and_selects_valid_candidate PASSED [ 41%]
tests/test_passage_blueprint_grounding_gate.py::test_06_no_viable_candidate_fails_within_existing_bounds PASSED [ 50%]
tests/test_passage_blueprint_grounding_gate.py::test_07_missing_claim_coverage_fails_before_expensive_question_inference PASSED [ 58%]
tests/test_passage_blueprint_grounding_gate.py::test_08_not_given_absence_requirements_remain_intact PASSED [ 66%]
tests/test_passage_blueprint_grounding_gate.py::test_09_blueprint_and_accepted_artifact_hashes_remain_immutable PASSED [ 75%]
tests/test_passage_blueprint_grounding_gate.py::test_10_stage_executor_checkpoint_restart_behavior PASSED [ 83%]
tests/test_passage_blueprint_grounding_gate.py::test_11_existing_hybrid_m3_repair_path_continues_for_genuine_semantic_failures PASSED [ 91%]
tests/test_passage_blueprint_grounding_gate.py::test_12_no_extra_minimax_calls_dispatched_on_deterministic_preflight_failures PASSED [100%]

============================== 12 passed in 0.71s ==============================
```

### 7.1 Full Regression Suite Results

```bash
# 1. Full Hybrid, Repair, Evaluator, and Grounding Suites (211/211 passed)
$ services/generation-service/.venv/bin/pytest \
    services/generation-service/tests/test_passage_blueprint_grounding_gate.py \
    services/generation-service/tests/test_hybrid*.py \
    services/generation-service/tests/test_repair*.py \
    services/generation-service/tests/test_phase15*.py \
    services/generation-service/tests/test_t07_evaluators_repairs.py -q
211 passed in 3.39s

# 2. Unified Reading Pipeline Suite (114/114 passed)
$ services/generation-service/.venv/bin/pytest services/generation-service/tests/unified/ -q
114 passed in 170.01s (0:02:50)

# 3. .NET Attempt Service Grader Suite (125/125 passed)
$ dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
Passed!  - Failed: 0, Passed: 125, Skipped: 0, Total: 125, Duration: 81 ms
```

---

## 8. Task 6 — Audit of Provider Calls vs Operations

An audit was conducted comparing the forensic snapshot `reports/hybrid_single_section_live_snapshot.json` with the published report `HYBRID_SINGLE_SECTION_LIVE_VALIDATION.md`:

### 8.1 Empirical Reconciliation

| Metric | Committed Forensic Snapshot | Previously Published Report | Reconciliation Audit Findings |
|---|---|---|---|
| **Total Operations in Log** | **29 operations** | 29 operations | Exact match |
| **`GENERATE` Operations** | 6 operations | 4 operations | Report excluded source/blueprint generator ops |
| **`EVALUATE` Operations** | 12 operations | 12 operations | Exact match |
| **`CHECKPOINT_COMMIT` Operations** | 5 operations | 4 operations | Report excluded source commit op |
| **`PROVIDER_CALL` Operations** | **Exactly 6 rows** | **Reported "7" in text** | **Report calculation error** (rows summed to 6, text stated 7) |
| **Prompt Tokens** | 16,752 tokens | 16,752 tokens | Exact match |
| **Completion Tokens** | 2,313 tokens | 2,313 tokens | Exact match |
| **Total Billable Tokens** | **19,065 tokens** | **19,065 tokens** | Exact match |
| **Estimated Cost** | **$0.00589 USD** | **$0.00589 USD** | Exact match |

### 8.2 Breakdown of the 6 Authoritative Provider Calls

1. `op:run_...:passage:1:1` (MiniMax-Text-01): 8,467 tokens (7,373 prompt + 1,094 completion), 31.67s.
2. `op:run_...:question:1:1_1` (MiniMax-Text-01): 2,148 tokens (1,815 prompt + 333 completion), 12.81s.
3. `op_solve_run_..._question:...:1_1` (MiniMax-Text-01): 1,941 tokens (1,806 prompt + 135 completion), 4.70s.
4. `op_adv_run_..._question:...:1_1` (MiniMax-Text-01): 1,964 tokens (1,890 prompt + 74 completion), 3.38s.
5. `op:run_...:question:2:1_1` (MiniMax-Text-01): 2,171 tokens (1,852 prompt + 319 completion), 10.75s.
6. `op:run_...:question:2:1_1_att2` (MiniMax-Text-01): 2,374 tokens (2,016 prompt + 358 completion), 12.74s.
- **Repair Planning Calls (MiniMax-M3):** Exactly 0 calls (Candidate generation failed during extraction before repair planning was reached).

*Audit Conclusion:* The previously reported "7 calls" was a typographical summation mistake ($1+1+1+1+1+1=6$, erroneously written as 7). Exactly 6 provider operations took place, consuming exactly 19,065 tokens. Zero missing or phantom provider operations exist.

---

## 9. Checkpoint Lineage & State Invariants

- **Idempotency & Replay:** Replaying completed stages returns identical content hashes without re-invoking generator or repairer functions.
- **Fenced Epochs & Leases:** Epoch checks and lease validations execute prior to stage drafting, aborting gracefully if ownership is revoked.
- **Cryptographic Lineage:** Every passage and question envelope verifies SHA-256 content hashes and binds to parent references (`parent_refs`).

---

## 10. Changed Code Manifest

| File | Changes |
|---|---|
| `services/generation-service/app/contracts/issue.py` | Added `PASSAGE_BLUEPRINT_ALIGNMENT = "PASSAGE_BLUEPRINT_ALIGNMENT"` to `IssueCode`. |
| `services/generation-service/app/validation/models.py` | Added `ERR_PASSAGE_BLUEPRINT_ALIGNMENT` to validation `IssueCode`. |
| `services/generation-service/app/loop/policy.py` | Added `IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT` to `allow_repair_codes`. |
| `services/generation-service/app/reading_generation.py` | Enhanced `align_claims_to_passage` to support exact matches, clause matches, and independently verified semantic paraphrases. |
| `services/generation-service/app/reading_evaluation.py` | Added `verify_passage_blueprint_grounding`; updated `evaluate_passage` to validate blueprint slot coverage and produce `PASSAGE_BLUEPRINT_ALIGNMENT` issues on omission. |
| `services/generation-service/app/section_runner.py` | Defined `CandidateRejectionReason` and `CandidateRejectionError`; enforced passage-blueprint grounding in `generate_passage`; added `repair_passage_stage` bounded repair; eliminated source claim text fallback for `target_focus`; added deterministic preflight checks; added bounded quote verbatim regeneration feedback. |
| `services/generation-service/tests/test_passage_blueprint_grounding_gate.py` | Authored 12 offline verification tests covering all Task 5 requirements. |
| `docs/reports/PASSAGE_BLUEPRINT_GROUNDING_GATE.md` | Authoritative engineering forensic report and verdict. |

---

## 11. Final Verified SHA & Execution Authority

- **Repository:** `minkhoaa/Project_Langfens_Microservice`
- **Branch:** `autonomous-generation`
- **Baseline Commit:** `fcac16826334b472d4f8fdc22f3bd179010d3476`
- **Verified Commit:** `4b6af4ff769ad454a4529bf1b73485c5091a5b42`
- **Mode:** OFFLINE ONLY
- **Live Provider Calls Dispatched:** Exactly 0

---

## Final Verdict

```text
================================================================================
PASSAGE_BLUEPRINT_GROUNDING: PASS
================================================================================
```
*All offline verifications passed. Zero live network calls dispatched. Autonomous generation halted cleanly per directive.*
