# RG10 Final Campaign Readiness Audit Report (Dry-Run Only)

**Report ID:** `rg10-campaign-readiness-dryrun-v1.0`  
**Evaluated At:** `2026-10-16T19:00:00Z`  
**Software Commit SHA:** `798bf9ef614e393f2324fdd3344f535e9d74ee50`  
**Evaluation Mode:** `STRICTLY_DRY_RUN_NO_PROVIDER_CALLS`  
**Overall Software Readiness:** **`READY`**  
**Overall Campaign Gate:** **`HOLD`**  

---

## 1. Executive Summary & Readiness Pillars

| Area / Pillar | Audit Status | Evidence & Invariant Findings |
|---|---|---|
| **1. Dataset Identity & Hashes** | **`VERIFIED`** | 56 total tasks (28 Reading, 28 Grammar). Combined source SHA: `09db897c54fbdc05...`. Source family quarantine: True. Holdout status: `SPECIFICATION_PENDING_INDEPENDENT_CURATION` (seals null: True). |
| **2. Version Pinning** | **`VERIFIED`** | Pinned Evaluator: `neutral-eval-v2.7` (`NeutralEvaluatorV2_7`). Rubric: `rubric-qgeval-v2.7`. Model: `minimax/MiniMax-Text-01`. Arms: ['A', 'B', 'C']. Prompts: A=v2.1-baseline, B=v2.2-grounded, C=v3.0-adversarial. |
| **3. Roster & Denominators** | **`VERIFIED`** | Frozen assignment count: $N = 168$ (84 Reading, 84 Grammar; 56/arm). Judge Holdout denominator: $N = 30$ (18 Reading, 12 Grammar), strictly separate from campaign. |
| **4. Provider Quota Status** | **`BLOCKED`** | **Zero network calls made** (`live_network_calls_made = 0`). Prior verified status: `BLOCKED_EXTERNAL_QUOTA` (`HTTP 429: Token Plan usage limit reached (2056)`). Availability not asserted in dry run. |
| **5. Human Panel Readiness** | **`HOLD`** | Status: `AWAITING_HUMAN_PANEL`. Blind review forms and curator instructions available. Panel ratings not yet submitted (synthetic scores: UNVERIFIED). |
| **6. Raw Response Preservation** | **`VERIFIED`** | 635 records across 8 dirs. Telemetry verified: ['latency_ms', 'prompt_sha256', 'provider_request_id', 'raw_text_sha256', 'tokens', 'tokens_prompt_completion_total']. |
| **7. Failure Accounting** | **`VERIFIED`** | Fail-closed on UNCERTAIN, timeout, rate-limit, missing output. Zero silent drops. Evaluator UNCERTAIN supported. |
| **8. Statistical Analysis Plan** | **`VERIFIED`** | Preregistered primary endpoint: `independent_final_PASS / all_assigned`. Resampling unit: `dataset_item_id`. Paired contrasts: ['C_minus_A', 'C_minus_B'] (95% CI). Methods verified on disk: ['primary_endpoint: independent_final_PASS / all_assigned', 'resampling_unit: dataset_item_id', 'paired_contrasts: C-A and C-B', 'bootstrap_95ci: paired bootstrap', 'fail_closed: UNCERTAIN/timeout as non-PASS']. |

---

## 2. External Blockers

The campaign remains on **`HOLD`** pending external prerequisites:
- **BLOCKER:** Provider API quota returned HTTP 429 Token Plan usage limit reached (status: BLOCKED_EXTERNAL_QUOTA).
- **BLOCKER:** Confirmatory holdout corpus (N=30) remains SPECIFICATION_PENDING_INDEPENDENT_CURATION with null cryptographic seals.
- **BLOCKER:** Qualified human review panel is uncontracted/unpopulated (status: AWAITING_HUMAN_PANEL; zero synthetic scores).

---

## 3. Clear Actionable Criteria to Resume Research Campaign

- 1. External provider quota replenished and confirmed operational.
- 2. Independent human panel delivers 30-item holdout passing check_corpus_disjointness.py.
- 3. Cryptographic SHA-256 seals generated and signed by panel lead into CONFIRMATORY_HOLDOUT_MANIFEST.json.
- 4. Human review panel onboarded to score blinded evaluation package.
