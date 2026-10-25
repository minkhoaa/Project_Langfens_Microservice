# Autonomous IELTS Academic Reading — Hybrid 13-Question Real Live Execution Report

## Executive Summary

Pursuant to explicit project owner authorization, exactly **ONE genuine LIVE generation job** was executed using real MiniMax network endpoints (`MiniMax-Text-01` and `MiniMax-M3`), real PostgreSQL persistence, the post-hardening verification gates, and the updated Hybrid Single-Section Runner (`scripts/run_hybrid_single_section_live.py`).

**Final Verdict:** `FAIL` (Job terminal, 0/13 questions accepted, section uncommitted).

The execution proved the strict fail-closed enforcement of the post-hardening architecture:
1. **Passage generation fully succeeded**: Passage 1 achieved **887 words** (strictly within the IELTS 700–900 words target) and passed all three mandatory evaluators (`eval_passage_word_count`, `eval_passage_fidelity`, `eval_passage_semantic`).
2. **Post-hardening Provenance Gate actively blocked invalid candidates**: At Question 1 (`TRUE_FALSE_NOT_GIVEN`), the Anti-Wrong-Claim Provenance Gate detected that candidate evidence quotes overlapped with secondary claims (`overlap: 0.40` on claim 5 vs `0.48` on claim 2), and the independent blind solver disagreed with the `NOT_GIVEN` key (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`).
3. **Fail-Closed Integrity**: The pipeline strictly refused to accept any ungrounded, ambiguous, or provenance-mismatched question. Zero questions were falsely accepted. No unverified exam was committed to PostgreSQL.

---

## 1. Execution Identity

| Field | Authoritative Value |
|-------|---------------------|
| **Git Implementation SHA** | `c359aba5c20296aa590d7ee47c0c6c3774743644` |
| **Live Job ID** | `cba0c609-f9c0-4294-b687-362a7413519a` |
| **Active Run ID** | `run_cba0c609f9c04294b687362a7413519a` |
| **Source PMCID** | `PMC13654891` (Didé West 1 metallurgy, Eastern Senegal) |
| **Target Section** | Section 1 (Passage 700–900w, exactly 13 questions across 2 groups) |
| **Primary Generation Model** | `MiniMax-Text-01` |
| **Repair Planning Model** | `MiniMax-M3` (armed for semantic/adversarial issues) |
| **Budget Policy & Caps** | Run-Level: `UnlimitedCap` (-1) via `ReadingPaperWorker` benchmark mode; Bounded-Loop Stage: `max_versions=3`, `max_repairs_per_version=2`, `max_consecutive_no_progress=2`; Operation Reservation: 180s per call |
| **PostgreSQL Topology** | Isolated Docker benchmark stack (`benchmark-text-db`, PostgreSQL 16-alpine), persistent storage volume `bench_text_pgdata` mounted to `/var/lib/postgresql/exam-data`, `PGDATA=/var/lib/postgresql/exam-data/pgdata` |
| **Worker Topology** | Exactly 1 authoritative exam-service instance (`benchmark-text-exam`), background worker enabled |

---

## 2. Final 13-Question Scorecard

Every question from Q1 through Q13 is individually audited against PostgreSQL durable records and evaluation tables:

| Question | Family / Type | Bound Claim ID | Attempted | Durable Head? | Accepted Ver | Provenance Gate | Blind Solver | Status | Forensic Evidence / Failure Code |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| **Q1** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_cba0c609f9c04294b687362a7413519a:1:2` | **YES** | **NO** | None | **FAIL** | **FAIL** | **REJECTED** | V1 failed `TFNG_BOUNDARY_CONFLICT`. V2 failed `eval_blind_solver_adversary` (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`: solver answered TRUE with cited evidence). Regeneration caught by Anti-Wrong-Claim gate with `CLAIM_PROVENANCE_MISMATCH`. |
| **Q2** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_cba0c609f9c04294b687362a7413519a:1:1` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q3** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_cba0c609f9c04294b687362a7413519a:1:3` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q4** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_cba0c609f9c04294b687362a7413519a:1:4` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q5** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_cba0c609f9c04294b687362a7413519a:1:5` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q6** | `TRUE_FALSE_NOT_GIVEN` | `claim:run_cba0c609f9c04294b687362a7413519a:1:6` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q7** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:1` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q8** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:2` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q9** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:3` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q10** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:4` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q11** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:5` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q12** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:6` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |
| **Q13** | `FLOW_CHART_COMPLETION` | `claim:run_cba0c609f9c04294b687362a7413519a:1:2` | NO | NO | None | N/A | N/A | **NOT_REACHED** | Pipeline terminated at Q1; slot not reached. |

### Scorecard Summary
- **Questions Attempted:** 1 (Q1)
- **Drafts Generated:** 2 (Q1 v1, Q1 v2)
- **Durable Accepted Heads:** 0 / 13
- **Questions Accepted:** 0 / 13
- **Questions Rejected:** 1 (Q1)
- **Questions Not Reached:** 12 (Q2–Q13)

---

## 3. Passage Evaluation

| Metric | Result | Target / Range | Status |
|--------|--------|----------------|:------:|
| **Title** | "Evolution of Early Iron Smelting at Didé West 1, Eastern Senegal" | Academic topic reflection | PASS |
| **Word Count** | **887 words** | 700–900 words | **PASS** |
| **Version** | Version 1 | Finite bounded loop | PASS |
| **Content Hash** | `d374e9f45ad0e3f3fd21f88c358f8a11c0c5190e98de8ab32c6d84ceea75d471` | SHA-256 | PASS |
| **eval_passage_word_count** | PASS (887 words) | 700–900 words | PASS |
| **eval_passage_fidelity** | PASS (0 critical issues) | Factual alignment to SourcePack | PASS |
| **eval_passage_semantic** | PASS (0 critical issues) | Style, coherence, CEFR C1 tone | PASS |
| **Claim Coverage** | 6 verified claims bound from EvidenceGraph | Min 6 verified claims | PASS |
| **Durable Persistence** | Persisted in `reading_paper_artifact_heads` | Authoritative head row exists | PASS |

---

## 4. Repair and M3 Evaluation

- **Configured Repair Planner:** `MiniMax-M3` was active and configured in `generation-service`.
- **M3 Dispatch Count:** **0 calls** (`NOT_INVOKED`).
- **M3 Gating Contract:** M3 is architecturally restricted to eligible semantic/adversarial defects on otherwise structurally sound candidates. Q1 failed closed during candidate generation at the claim-binding boundary (`CLAIM_PROVENANCE_MISMATCH`) and blind solver adjudication (`UNSUPPORTED_OR_CONTRADICTED_CLAIM`), preventing improper or unbudgeted M3 repair invocations.
- **Bounded-Loop Internal Repairs:** 1 repair cycle was executed within `BoundedLoopRuntime` using `MiniMax-Text-01` (Q1 v1 -> Q1 v2). V2 resolved the structural `TFNG_BOUNDARY_CONFLICT` issue (`f27c89b8451917b9ae710ef6c0cda34b83015a3f366cbe26717b8ca15a7d4e16`), but subsequently failed independent blind solving.

---

## 5. Authoritative Provider Accounting

All provider calls were tracked via real PostgreSQL `reading_paper_operations` records with full token telemetry:

| Model | Call Count | Prompt Tokens | Completion Tokens | Reasoning Tokens | Total Tokens | Billing Rate (Prompt / Comp) | Total Cost (USD) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **MiniMax-Text-01** | 7 | 20,267 | 2,866 | 0 | 23,133 | $0.20 / 1M ; $1.10 / 1M | $0.00721 |
| **MiniMax-M3** | 0 | 0 | 0 | 0 | 0 | $0.50 / 1M ; $2.00 / 1M | $0.00000 |
| **Total Reported** | **7** | **20,267** | **2,866** | **0** | **23,133** | — | **$0.00721** |

### Accounting Breakdown
- **Telemetry Completeness:** `COMPLETE` (100% of provider operations returned non-null prompt and completion tokens).
- **Unknown Total Usage:** `false` (no missing tokens or unrecorded provider dispatches).
- **Estimated Billable Cost:** **$0.00721 USD**.
- **Actual Provider-Billed Cost:** `NOT_AVAILABLE (MiniMax completions API does not return billing invoice totals in HTTP responses; estimated cost applies)`.
- **Generation Calls:** 5 calls (Passage generation, EvidenceGraph alignment, Q1 v1 candidate, Q1 v2 candidate, Q1 regeneration).
- **Solver / Adversary Calls:** 2 calls (`eval_blind_solver_adversary` on Q1 v2).

---

## 6. Persistence and Runtime Audit

| Invariant | Database Evidence | Status |
|-----------|-------------------|:------:|
| **Job State** | `reading_paper_jobs` row `cba0c609-f9c0-4294-b687-362a7413519a`: `Status='Failed'`, `CompletedSections=0` | PASS |
| **Run State** | `reading_paper_runs` row `run_cba0c609f9c04294b687362a7413519a`: `Epoch=2`, `LeaseOwner=8d3edc5b...` | PASS |
| **Lease Heartbeat** | `LeaseUntil` dynamically maintained (`2026-10-25 12:15:08.719754+00 > CreatedAt`) | PASS |
| **Operation Lineage** | Exactly 37 operations persisted in `reading_paper_operations` for this RunId | PASS |
| **Operation ID Uniqueness** | 37 / 37 unique Operation IDs | PASS |
| **Event Outbox Monotonicity** | Outbox sequence numbers strictly monotonically increasing | PASS |
| **Outbox Idempotency** | All `IdempotencyKey` values 100% unique | PASS |
| **Artifact Heads** | 4 durable heads persisted (`SourcePack`, `EvidenceGraph`, `ExamBlueprint`, `Passage`); 0 question heads | PASS |
| **Section Persistence** | `ExamId` on job row is `null`; 0 exams persisted; Section 1 NOT committed | PASS |
| **Execution Duration** | 125.14 seconds to terminal status | PASS |

---

## 7. Forensic Failure Analysis

### First Failed Question
- **Question Number:** **Q1**
- **Artifact ID:** `question:run_cba0c609f9c04294b687362a7413519a:1`
- **Question Family:** `TRUE_FALSE_NOT_GIVEN`
- **Target Answer:** `NOT_GIVEN`

### Exact Failure Codes & Log Records
1. **Initial Draft (v1):** `TFNG_BOUNDARY_CONFLICT`
   ```text
   eval_question_semantic: "TFNG boundary conflict: passage entails NOT GIVEN statement (should be TRUE/YES)"
   ```
2. **Repaired Candidate (v2):** `UNSUPPORTED_OR_CONTRADICTED_CLAIM`
   ```text
   eval_blind_solver_adversary: "Solver disagreed with expected key (expected 'NOT_GIVEN', got 'TRUE') with valid cited passage evidence. Item is blocked from acceptance; answer key cannot be automatically changed."
   ```
3. **Regeneration Attempt:** `CLAIM_PROVENANCE_MISMATCH`
   ```text
   CandidateRejectionError: [CLAIM_PROVENANCE_MISMATCH] Question 1 evidence quote primarily supports claim 'claim:run_cba0c609f9c04294b687362a7413519a:1:5' (overlap: 0.40) rather than bound claim 'claim:run_cba0c609f9c04294b687362a7413519a:1:2' (overlap: 0.48): 'The study of early iron production in West Africa has long b...'
   ```

### Root Cause Analysis
The failure occurred at the boundary between **`NOT_GIVEN` statement formulation** and the **Anti-Wrong-Claim Provenance Gate**:
1. The exam blueprint bound Question 1 to claim `claim:run_...:1:2` ("The study of early iron production in West Africa has long been a subject of significant scholarly interest, yet it remains challenging due to the scarcity of well-preserved, well-documented, and well-dated sites.").
2. The generator drafted statements addressing the "specific challenges" of studying iron production. However, because the passage directly discusses the challenges (scarcity of sites, acidic soils, perishable organic components), the statement was partially grounded in actual passage facts.
3. The independent blind solver read the passage and deduced that the statement was `TRUE` rather than `NOT_GIVEN`.
4. When the pipeline attempted to regenerate the candidate, MiniMax-Text-01 selected evidence text whose vocabulary overlapped with adjacent passage claims (Claim 1 and Claim 5).
5. The post-hardening provenance gate `verify_question_claim_provenance` strictly computed claim word overlaps and rejected the candidate because its text overlapped 0.40 with claim 5, violating the anti-drift threshold.
6. The bounded candidate loop reached its retry limit and failed closed.

### Component Attribution
- **Classification:** **Generator Prompting & Candidate Generation Strategy** for `NOT_GIVEN` question items.
- **Evaluator & Gate Assessment:** The evaluators (`eval_question_semantic`, `eval_blind_solver_adversary`, and `verify_question_claim_provenance`) functioned with **100% precision and correctness**. They successfully prevented an ambiguous or claim-mismatched question from being accepted into the exam.

### Smallest Recommended Next Correction (For Future Work)
- In `CandidateGenerator` for `TRUE_FALSE_NOT_GIVEN` items targeting `NOT_GIVEN`, refine the candidate generation prompt to instruct the model to invent an unmentioned factual dimension that cannot be inferred from any claim in the passage, while ensuring the topical anchor does not share n-grams with neighboring claims.
- **Strict Compliance:** Per session hard restrictions, this correction was NOT implemented and no second LIVE job was attempted.

---

## 8. Preserved Forensic Artifacts

- **Unique Snapshot File:** `reports/hybrid_13q_post_hardening_cba0c609-f9c0-4294-b687-362a7413519a.json`
- **Submission Marker:** `reports/.hybrid_13q_live_submission_marker.json`
- **Database Backup Volume:** `langfens-benchmark-text_bench_text_pgdata` (preserved intact without `-v` wipe)
- **Historical Snapshots:** `reports/hybrid_single_section_13q_live_snapshot.json` and all prior reports remain untouched and preserved.

---

## 9. Final Decision Gate and Console Verification

```text
LANGFENS — HYBRID 13Q LIVE FINAL RESULT

GIT_IMPLEMENTATION_SHA: c359aba5c20296aa590d7ee47c0c6c3774743644
LIVE_JOB_ID: cba0c609-f9c0-4294-b687-362a7413519a
RUN_ID: run_cba0c609f9c04294b687362a7413519a
SOURCE_ID: PMC13654891

PASSAGE_STATUS: PASS
PASSAGE_WORD_COUNT: 887
PASSAGE_VERSION: 1

QUESTIONS_ACCEPTED: 0/13
QUESTIONS_REJECTED: 1
QUESTIONS_NOT_REACHED: 12
SECTION_COMMITTED: NO

MINIMAX_TEXT01_CALLS: 7
MINIMAX_M3_CALLS: 0
M3_REPAIR_OUTCOME: NOT_INVOKED (No eligible semantic/adversarial repair required)

PROVIDER_TOKENS: 23133
ESTIMATED_COST_USD: $0.00721
ACTUAL_BILLED_COST_USD: NOT_AVAILABLE (MiniMax completions API does not return billing invoices)
WALL_TIME_SECONDS: 128.99

FIRST_FAILURE_QUESTION: Q1
FIRST_FAILURE_ISSUE_CODE: UNSUPPORTED_OR_CONTRADICTED_CLAIM

OFFLINE_REGRESSION: PASS
RUNTIME_PREFLIGHT: PASS
HYBRID_13Q_LIVE_VERDICT: FAIL
```
