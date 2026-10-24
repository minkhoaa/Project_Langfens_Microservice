# QUESTION–CLAIM PROVENANCE & STUDENT-VISIBLE STIMULUS INTEGRITY GATE

**Repository:** `minkhoaa/Project_Langfens_Microservice`  
**Branch:** `autonomous-generation`  
**Verified Baseline HEAD:** `dd1792e808c828b2e1a49e78bb5b28b2ca16bcc0`  
**Execution Mode:** OFFLINE ONLY (deterministic replays, local evaluators, zero paid API dispatches)

---

## 1. Executive Summary & Independent Verdicts

Independent inspection of the latest single-section 13-question LIVE snapshot (`reports/hybrid_single_section_13q_live_snapshot.json`) revealed two high-priority correctness defects:

1. **Defect A (Question–Claim Provenance Drift):** Accepted questions could cite passage evidence unrelated to their immutable Blueprint-bound claim. Specifically:
   - **Question 2:** Bound in Blueprint to Claim 1 ("attest to the use of diverse smelting techniques"), but asserted facts and cited evidence primarily supporting Claim 2 ("only a limited number are well preserved and documented").
   - **Question 4:** Bound in Blueprint to Claim 9 ("firmly established chronologies"), but cited evidence and asserted facts concerning Claim 11 ("Nsukka region direct evidence for sustained production remains sparse").
   - **Question 5:** Bound in Blueprint to Claim 11 ("sustained iron production limited"), but cited evidence and asserted facts concerning Claim 9 ("scholarly community has established firm chronologies for only a limited number of sites").
2. **Defect B (FLOW_CHART & Completion Grounding Bypass):**
   - Candidate `FLOW_CHART` items bypassed required completion grounding checks because `FLOW_CHART`, `DIAGRAM_LABEL`, and `MAP_LABEL` were absent from `GROUNDED_COMPLETION_TYPES` and deterministic answer length evaluators.
   - Candidate Question 10 proposed an answer (`hosted districts`) that does not occur as a contiguous span in its evidence quote or in the accepted passage text.
   - Blind solver input projected via `project_to_student_visible()` completely dropped `flowSteps`, presenting the blind solver with only `"Complete the flow chart below. Step 10: [10]"` devoid of any sequential steps or context.
   - Because deterministic gates were bypassed, Q10 was dispatched to the expensive blind solver three times (V1–V3), failing repeatedly.

### Authoritative Verification Verdicts

| Gate / Subsystem | Status | Details |
| :--- | :---: | :--- |
| **QUESTION_CLAIM_PROVENANCE** | **PASS** | `verify_question_claim_provenance` enforces exact slot matching, verified claim existence, exact passage offsets, and substantive semantic support. Mismatches fail closed with `IssueCode.CLAIM_PROVENANCE_MISMATCH`. |
| **COMPLETION_FAMILY_COVERAGE** | **PASS** | `FLOW_CHART`, `DIAGRAM_LABEL`, `MAP_LABEL` added to `GROUNDED_COMPLETION_TYPES` and `AnswerVerbatimAndLengthEvaluator`. Non-contiguous answers (e.g. Q10 `hosted districts`) are rejected deterministically before blind-solver dispatch. |
| **STUDENT_VISIBLE_STIMULUS** | **PASS** | `StudentVisibleQuestion` schema updated with `flowSteps`, `tableContext`, `rowHeader`, `colHeader`, `calloutLabel`, `partDescription`, `svgAssetId`, `imageUrl`. `build_secure_envelope` formats XML stimuli without answer leakage. Missing graphical stimuli fail closed. |
| **BLIND_SOLVER_CLASSIFICATION** | **PASS** | Disagreements distinguish 5 causes: malformed stimulus (`SCHEMA_VIOLATION`), ungrounded key (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`), solver unsupported (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`), genuine ambiguity (`AMBIGUOUS_ANSWER`), and solver reading error (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`). Only genuine ambiguity routes to M3. |
| **M3_ACCOUNTING** | **PASS** | Operation counts reconciled (172 total: 19 GENERATE, 93 EVALUATE, 13 CHECKPOINT_COMMIT, 46 PROVIDER_CALL, 1 REPAIR). Discrepancy between reported usage (0) and narrative ($0.00146 USD) resolved: provider non-streaming omitted usage metadata; narrative used text character counts and 4,096 cap. |
| **NEXT_SINGLE_SECTION_LIVE_READINESS** | **READY** | All 13 offline regression tests pass in `test_question_claim_provenance_and_stimulus_gate.py`. Unified suites across all 19 question types pass cleanly. Zero live API calls executed. |

---

## 2. Phase 1 — Reproduction of Authoritative Failures

A full machine-readable provenance audit was generated across all 14 question versions in `reports/hybrid_single_section_13q_live_snapshot.json` and saved to `reports/question_claim_provenance_audit.json`.

### Question Provenance Audit Matrix

| Item | Version | Type | Bound Claim Ref | Stated Evidence Quote | Root Cause / Failure Mode |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **Q1** | V1 | TFNG | `claim:...:1:2` | "Despite the identification of numerous iron production sites..." | **PASS:** Evidence quote grounds bound Claim 2 ("only a limited number are well preserved"). |
| **Q2** | V1 | TFNG | `claim:...:1:1` | "Despite the identification of numerous iron production sites..." | **PROVENANCE DEFECT:** Cites evidence and asserts facts for Claim 2 (well-preserved scarcity) rather than bound Claim 1 (diverse smelting techniques). Substantive overlap with Claim 1 is 0.38 (generic domain words only), vs 0.67 with Claim 2. |
| **Q3** | V1 | TFNG | `claim:...:1:12` | "Sites on the Jos Plateau" | **REJECTED (live):** Answer FALSE; truncated quote failing minimum evidence quote length. |
| **Q3** | V2 | TFNG | `claim:...:1:12` | "Sites on the Jos Plateau" | **REJECTED (live):** Answer FALSE; truncated quote failing minimum evidence quote length. |
| **Q3** | V3 | TFNG | `claim:...:1:12` | `None` (`topicalContextSpan` provided) | **PASS:** Valid NOT_GIVEN item; confirmed absence of discovery attribution to Junius 2023. |
| **Q4** | V1 | TFNG | `claim:...:1:9` | "while the Nsukka region in Nigeria is recognized as a significant center..." | **PROVENANCE DEFECT:** Bound to Claim 9 (firm chronologies), but tests and quotes Claim 11 (Nsukka sustained production). Substantive overlap with Claim 9 is 0.08, vs 0.55 with Claim 11. |
| **Q5** | V1 | TFNG | `claim:...:1:11` | "The scholarly community has established firm chronologies for only a limited number of these sites." | **PROVENANCE DEFECT:** Bound to Claim 11 (Nsukka sustained production), but tests and quotes Claim 9 (firm chronologies). Substantive overlap with Claim 11 is 0.09, vs 0.58 with Claim 9. |
| **Q6** | V1 | TABLE | `claim:...:1:6` | ", Alpern, 2005 ; Holl, 2009 ; Killick, 2004 ; Robion-Brunner, 2018 )..." | **PASS:** Answer `Robion-Brunner` grounds Claim 6. |
| **Q7** | V1 | TABLE | `claim:...:1:14` | "In Burkina Faso, the site of Douroula attests to iron smelting around 700 BCE," | **PASS:** Answer `Burkina Faso` grounds Claim 14. |
| **Q8** | V1 | TABLE | `claim:...:1:10` | "From east to west, the Nsukka region in Nigeria has long been considered a major center for early ironworking in sub-Saharan Africa." | **PASS:** Answer `sub-Saharan Africa` grounds Claim 10. |
| **Q9** | V1 | TABLE | `claim:...:1:13` | "Similarly, the Termit Massif in Niger has yielded evidence of iron production from the early first millennium BCE, though claims of earlier metallurgy remain contentious." | **PASS:** Answer `contentious` grounds Claim 13. |
| **Q10** | V1 | FLOW_CHART | `claim:...:1:7` | "Current research indicates that sub-Saharan West Africa hosted several early iron production districts..." | **COMPLETION & STIMULUS DEFECT:** Answer `hosted districts` is not a contiguous span in quote or passage. `flowSteps` dropped from solver input; solver guessed `'Didé West 1'`, triggering expensive provider retry. |
| **Q10** | V2 | FLOW_CHART | `claim:...:1:7` | "Current research indicates that sub-Saharan West Africa hosted several early iron production districts..." | **REJECTED (live):** Repeated invalid answer `hosted districts` due to missing candidate grounding gate. |
| **Q10** | V3 | FLOW_CHART | `claim:...:1:7` | "Current research indicates that sub-Saharan West Africa hosted several early iron production districts..." | **REJECTED (live):** Third repeat of invalid candidate; exhausted version cap. |

---

## 3. Phase 2 — Implementation: Question–Claim Provenance Verification

### 3.1 Typed Diagnostic Code
Introduced `IssueCode.CLAIM_PROVENANCE_MISMATCH` across both runtime codebases:
- Python: `app.contracts.issue.IssueCode.CLAIM_PROVENANCE_MISMATCH = "CLAIM_PROVENANCE_MISMATCH"`
- C#: `exam_service.Features.ReadingPaper.Contracts.IssueCode.CLAIM_PROVENANCE_MISMATCH`
- SectionRunner candidate rejection: `CandidateRejectionReason.CLAIM_PROVENANCE_MISMATCH`

### 3.2 Provenance Verification Engine
Implemented `verify_question_claim_provenance(question_payload, blueprint_slot, claims, passage, passage_alignments)` in `app/reading_evaluation.py`:
1. **Exact Blueprint Slot Matching:** `question.evidenceClaimRef` must match `blueprint_slot.claimRefIds[0]`.
2. **Verified Claim Existence:** The referenced claim must exist in verified `EvidenceGraph`.
3. **Exact Passage Offsets:** For positive items, `passage[start:end] == evidenceQuote`.
4. **NOT_GIVEN Absence & Grounding Contract:** Positively confirms that `evidenceQuote` is None, `absenceConfirmed` is True, `absenceReason` is present, `topicalContextSpan` is present in the passage at exact offsets, and substantive keywords of the bound claim appear in the topical context. Positive entailment or direct occurrence in passage is strictly forbidden.
5. **Semantic Support for Bound Claim:** Evaluates substantive grounding ratio between bound claim text and evidence quote.
6. **Anti-Wrong-Claim Gate:** Compares quote overlap against all other claims in the EvidenceGraph. If another claim $C_{other}$ has substantial overlap ($\ge 0.40$) and exceeds the bound claim's overlap by $\ge 0.15$ (or bound claim overlap $< 0.25$), the item is rejected fail-closed with `CLAIM_PROVENANCE_MISMATCH`.

---

## 4. Phase 3 — Full Completion Validation Coverage

### 4.1 Question Families Audited and Guarded
Updated `GROUNDED_COMPLETION_TYPES` in `app/section_runner.py` and `AnswerVerbatimAndLengthEvaluator` in `app/evaluators/deterministic.py`:
```python
GROUNDED_COMPLETION_TYPES = {
    "TABLE_COMPLETION",
    "SENTENCE_COMPLETION",
    "SUMMARY_COMPLETION",
    "NOTE_COMPLETION",
    "FORM_COMPLETION",
    "SHORT_ANSWER",
    "FLOW_CHART",
    "DIAGRAM_LABEL",
    "MAP_LABEL",
}
```

### 4.2 Candidate-Level Grounding Checks
For `FLOW_CHART`, `DIAGRAM_LABEL`, and `MAP_LABEL`:
1. **Answer Length:** Strictly enforces $\le 3$ words.
2. **Boundary-Aware Verbatim Match:** `match_boundary_aware(answer, quote)` ensures the answer occurs as a complete token span, eliminating non-contiguous phrases like `"hosted districts"`.
3. **Passage Verbatim Span:** `match_verbatim_in_passage(answer, passage)` guarantees the answer exists in the approved passage.
4. **Numbered Blank Marker:** Verifies that either prompt or sequential steps contain `[q_num]` or `______`.
5. **Anti-Leakage Check:** Verifies that the prompt/steps do not reveal the answer key.
6. **Graphical Stimulus Requirement:** For `DIAGRAM_LABEL` and `MAP_LABEL`, requires explicit `partDescription`, `sharedContext`, `svgAssetId`, `svgXml`, or `imageUrl`. Missing visual stimuli fail closed with `SCHEMA_VIOLATION`.

---

## 5. Phase 4 — Student-Visible Stimulus Projection

### 5.1 Updated Contract Schema
Extended `StudentVisibleQuestion` in `app/contracts/solver.py`:
```python
class StudentVisibleQuestion(CanonicalBaseModel):
    question_number: int = Field(..., ge=1, le=40, alias="questionNumber")
    question_type: str = Field(..., alias="questionType")
    prompt: str = Field(..., min_length=3)
    instructions: Optional[str] = None
    options: Optional[List[StudentVisibleOption]] = None
    shared_context: Optional[str] = Field(default=None, alias="sharedContext")
    flow_steps: Optional[List[str]] = Field(default=None, alias="flowSteps")
    table_context: Optional[str] = Field(default=None, alias="tableContext")
    row_header: Optional[str] = Field(default=None, alias="rowHeader")
    col_header: Optional[str] = Field(default=None, alias="colHeader")
    callout_label: Optional[str] = Field(default=None, alias="calloutLabel")
    part_description: Optional[str] = Field(default=None, alias="partDescription")
    heading_context: Optional[str] = Field(default=None, alias="headingContext")
    bullet_prefix: Optional[str] = Field(default=None, alias="bulletPrefix")
    field_label: Optional[str] = Field(default=None, alias="fieldLabel")
    svg_asset_id: Optional[str] = Field(default=None, alias="svgAssetId")
    image_url: Optional[str] = Field(default=None, alias="imageUrl")
```

### 5.2 Secure Untrusted Envelopes
In `app/solvers/serializer.py`, `build_secure_envelope()` formats:
- `<flow_chart>` with `<step index="i">...</step>`
- `<table_stimulus>` with `<context>`, `<row_header>`, `<col_header>`
- `<diagram_stimulus>` with `<callout>`, `<description>`, `<asset_id>`
- `<note_stimulus>` with `<heading>`, `<prefix>`, `<label>`

Every string is XML-escaped via `html.escape` and scanned with `scan_text_for_security_leaks()` to guarantee zero leakage of answers, gold references, or canary tokens.

---

## 6. Phase 5 — Solver Disagreement Classification

In `app/solvers/adjudication.py` and `app/evaluators/solver.py`, solver disagreements are strictly classified into five distinct categories:

| Disagreement Category | Diagnostic Condition | Adjudication Verdict | Emitted IssueCode | M3 Routing |
| :--- | :--- | :---: | :---: | :---: |
| **1. Missing / Malformed Stimulus** | `FLOW_CHART` lacks `flowSteps`, or diagram/map lacks visual description or asset reference. | `SOLVER_DEFECTIVE` | `SCHEMA_VIOLATION` | **NO** (Fail-closed structural defect) |
| **2. Key Ungrounded in Quote** | Completion answer key does not occur in candidate's cited `evidenceQuote`. | `KEY_UNGROUNDED` | `UNSUPPORTED_OR_CONTRADICTED_CLAIM` | **NO** (Candidate rejected / regenerated) |
| **3. Solver Response Unsupported** | Solver returns answer unsupported by passage, while expected key is grounded. | `SOLVER_DEFECTIVE` | `UNSUPPORTED_OR_CONTRADICTED_CLAIM` | **NO** (Solver reading slip; key preserved) |
| **4. Genuine Ambiguity** | Both expected key and alternative are passage-grounded, and adversary confirms valid multiple readings. | `AMBIGUOUS_DEFECTIVE` | `AMBIGUOUS_ANSWER` (or `BAD_DISTRACTOR`) | **YES** (Routes to M3 diagnostic planner) |
| **5. Solver Contradiction** | Solver cites conflicting passage span without genuine adversarial ambiguity. | `KEY_CONTRADICTED` | `UNSUPPORTED_OR_CONTRADICTED_CLAIM` | **NO** (Item blocked from acceptance) |

---

## 7. Phase 6 — Offline Regression Evidence

Authored comprehensive test suite `services/generation-service/tests/test_question_claim_provenance_and_stimulus_gate.py` (13 tests):

```
test_01_reproduce_live_snapshot_q2_q4_q5_wrong_claim_associations: PASSED
test_02_reject_mismatched_claim_provenance_despite_passing_syntax_offsets_solver: PASSED
test_03_accept_legitimate_paraphrased_evidence_from_correctly_bound_claim: PASSED
test_04_verify_not_given_topical_and_absence_semantics: PASSED
test_05_reject_q10_nonverbatim_answer_before_provider_dispatch: PASSED
test_06_verify_valid_flow_chart_answers_with_coherent_flow_steps: PASSED
test_07_flow_steps_survive_student_visible_projection_without_leakage: PASSED
test_08_missing_graphical_stimuli_fail_closed: PASSED
test_09_bounded_retry_feedback_prevents_repeated_invalid_q10_candidates: PASSED
test_10_blind_solver_disagreement_classification_distinguishes_five_causes: PASSED
test_11_m3_routing_restricted_to_genuinely_eligible_semantic_failures: PASSED
test_12_preserve_mandatory_evaluators_versions_and_operation_ids: PASSED
test_13_resumed_execution_and_durable_checkpoint_consistency: PASSED
```

**Full Regression Verification Result:** 225 of 225 tests PASSED across all affected suites:
- `test_question_claim_provenance_and_stimulus_gate.py` (13 passed)
- `test_tfng_semantic_contract_and_m3_repair.py` (13 passed)
- `test_question_answer_grounding_and_rerun.py` (13 passed)
- `test_blind_solvers_19types.py` (55 passed)
- `test_question_candidates_19types.py` (10 passed)
- `test_passage_blueprint_grounding_gate.py` (12 passed)
- `test_question_prompt_parser_contract.py` (84 passed)
- `test_t10_blind_solvers.py` (12 passed)
- `test_autonomous_blueprint_recovery.py` (12 passed)
- `test_e2e_autonomous_harness_smoke.py` (1 passed)

---

## 8. Phase 7 — Audit Reporting & M3 Accounting Reconciled

### 8.1 Operation Counts Reconciliation
Reconciled exact counts from `reports/hybrid_single_section_13q_live_snapshot.json`:
- **19 GENERATE Operations:** Initial section blueprint, passage drafts, question drafts, and group drafts.
- **93 EVALUATE Operations:**
  - 84 question evaluations (14 question versions $\times$ 6 question evaluators: `eval_question_structure`, `eval_answer_verbatim_length`, `eval_evidence_offsets`, `eval_question_uniqueness`, `eval_question_semantic`, `eval_blind_solver_adversary`)
  - 6 passage evaluations (2 passage versions $\times$ 3 evaluators: `eval_passage_word_count`, `eval_passage_fidelity`, `eval_passage_semantic`)
  - 3 stage evaluations: 1 `eval_source`, 1 `eval_evidence_graph`, 1 `eval_blueprint`
- **13 CHECKPOINT_COMMIT Operations:** 1 source + 1 evidence graph + 1 blueprint + 1 passage + 9 accepted questions.
- **46 PROVIDER_CALL Operations:** 46 external MiniMax Text-01 calls totaling 101,434 tokens ($0.03156 USD).
- **1 REPAIR Operation:** Q3 autonomous repair.
- **Total Operations:** $19 + 93 + 13 + 46 + 1 = 172$ operations.

### 8.2 M3 Pilot Accounting Audit
Audit of `reports/m3_q4_diagnostic_pilot_snapshot.json`:
- **Reported in Snapshot:** `promptTokens: 0`, `completionTokens: 0`, `costUsd: 0.0`.
- **Root Cause of Zero Reported Tokens:** The single MiniMax-M3 call was dispatched in non-streaming mode (`stream_callback=None`). MiniMax's OpenAI-compatible endpoint omitted usage telemetry in non-streaming mode, causing `getattr(response, "usage", None)` to be `None`, recorded as `UsageAccountingType.UNKNOWN`.
- **Narrative Estimate in Pilot Report ($0.00146 USD):** The author of the report manually inferred usage from tokenization: ~1,250 prompt tokens (845-word passage + prompt envelope) and ~420 completion tokens (reasoning chain + JSON plan). Using pricing ($0.50/M prompt, $2.00/M completion), this yields $(1250 \times 0.50 + 420 \times 2.00) / 10^6 = \$0.001465$ USD.
- **M3 Token Cap:** The 4,096-token cap in `RepairPlanningCapability` is enforced via `max_tokens=4096` in `ProviderRequest` and `MiniMaxProvider._build_create_kwargs`, aligning with the pinned execution policy.

---

## 9. Deliverable Summary & Readiness

All deliverables for the Question–Claim Provenance and Stimulus Integrity Gate are verified offline. Zero MiniMax live tokens were expended. The autonomous generation pipeline is verified fail-closed and ready for future offline replays.
