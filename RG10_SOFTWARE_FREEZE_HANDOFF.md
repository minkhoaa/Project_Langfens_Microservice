# RG10 Software Stabilization Freeze & Research Handoff

**Phase:** RG10 Phase Gate Closure & Research Handoff  
**Date:** 2026-10-16  
**Governing Documents:**  
- `generation_baseline/prompts/prompt-phase-10.md`  
- `generation_baseline/research/RQ2_PROTOCOL.md`  
- `generation_baseline/research/DATA_GOVERNANCE.md`  
- `generation_baseline/research/ANALYSIS_PLAN.md`  
- `generation_baseline/research/CONFIRMATORY_HOLDOUT_SPECIFICATION.md`  

**Overall Software Readiness:** **`READY`**  
**Overall Research Campaign Gate:** **`HOLD`** (Strictly maintain HOLD; do NOT execute final campaign or RG11 automatically)  

---

## 1. Executive Summary & Epistemic Separation

This document concludes the software stabilization phase of RG10. All software, evaluation contracts, isolation boundaries, dry-run campaign readiness checks, and external handoff materials have been fully implemented, verified, and locked.

### Three-Pillar Governance Status

| Pillar | Gate Verdict | Evidence & Operational Status |
|---|---|---|
| **SOFTWARE_READY** | **`PASS / READY`** | Evaluator v2.7 candidate is fully implemented with zero regressions across historical evaluators (v2.0–v2.6). Offline research suites pass deterministically: **330 Python RG10 tests**, **133 generation-service caps/loop tests**, **26 RG09 tests**, and **73 .NET attempt-service grader tests**. (The broader full generation-service suite ended `1125 passed, 33 skipped, 1 failed` where the single failure was `test_full_phase14_lifecycle_e2e` due to an offline PostgreSQL port 5433 integration dependency). Raw response preservation is verified (635 raw response files discovered across 8 directories, with schema verified on representative samples) and fail-closed uncertainty routing is evidenced. |
| **QUALITY_READY** | **`HOLD (CALIBRATION_ONLY; HOLDOUT_PENDING)`** | Evaluator v2.7 resolves all 4 diagnostic DEV defect classes. However, per repository rules and empirical research methodology: **in-sample calibration does not constitute independent confirmatory proof** and cannot declare a quality gate passed. Quality acceptance on post-freeze data remains on HOLD until the independent human holdout is curated and evaluated. |
| **RESEARCH_READY** | **`HOLD (BLOCKED_ON_EXTERNAL_PREREQUISITES)`** | **Blocked on external prerequisites:** Live provider quota returned `HTTP 429: Token Plan usage limit reached (2056)` (truthfully logged as `BLOCKED_EXTERNAL_QUOTA`). Confirmatory holdout ($N=30$) remains in `SPECIFICATION_PENDING_INDEPENDENT_CURATION` with all cryptographic seals strictly `null`. Human review panel remains uncontracted (`AWAITING_HUMAN_PANEL`). Zero synthetic scores or fake human ratings exist. |
| **OVERALL GATE VERDICT** | **`HOLD`** | **Do NOT start RG11 or the final A/B/C campaign.** Software is stabilized; hold until external quota is restored, confirmatory holdout is independently curated, and human expert panel data is gathered. |

---

## 2. Exact Git Provenance & Commit Traceability

- **Reported Base Commit:** `6432c1621270b0958d1307a1b839aff03abdfd7f` (*fix(evaluator): remediate DEV grammar defects in v2.7 and enforce holdout governance*)
- **Current HEAD Commit:** `32cb85e514f881aef8a5366ea43eb67422012eaa` (*fix(evaluator): refine base -eed lexeme filter and enforce QUALITY_READY HOLD*)
- **Commit Delta:** Exactly 1 commit ahead of reported base:
  - Constrained `-eed` bare infinitive exemption to closed base class (`need`, `feed`, `bleed`, `proceed`, `succeed`, `exceed`, `breed`, `speed`), rejecting past participle forms `freed`, `agreed`, `decreed`, `guaranteed`.
  - Added counterexample regressions in `test_rg10_v2_7_remediation.py`.
  - Enforced `QUALITY_READY: HOLD` across acceptance reports.
- **Git Branch:** `autonomous-generation` (tracking `origin/autonomous-generation`)

---

## 3. Comprehensive Verification & Regression Results

All tests executed offline in the verified runtime environment (Python 3.10.12 / .NET 10.0; production container target: Python 3.12):

| Test Suite / Tool | Test File / Command | Count | Result | Key Invariants Verified |
|---|---|---|---|---|
| **RG10 Disjointness & Readiness** | `python3 -m pytest tests/test_rg10_corpus_disjointness_and_readiness.py` | 10 | **PASS** | Authoritative baseline loading, passage leakage detection (Jaccard $\ge 0.30$), ID collision check, family quarantine, 9-area dry run check. |
| **RG10 Full Test Suite** | `python3 -m pytest tests/test_rg10*.py` | 330 | **PASS** | Evaluator v2.7 remediation, v2.0–v2.6 historical isolation, terminal answer preservation, provider telemetry, blinded semantic judge, accounting integrity. |
| **RG09 Frozen Prerequisites** | `python3 -m pytest tests/test_rg09*.py` | 26 | **PASS** | Frozen task registry, blind review manager, preregistered analysis plan, provider freeze, immutable manifest builder. |
| **Caps & Loop Runtime** | `python3 -m pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py` | 133 | **PASS** | Loop budgets, R03/G06 invariants, bounded retry caps, timeout fail-closed semantics. |
| **Full Service Test Suite** | `python3 -m pytest` (working directory: `services/generation-service`) | 1,159 | **1,125 passed, 33 skipped, 1 failed** | Single failure in `test_t14_harness_integration.py` (`test_full_phase14_lifecycle_e2e`) due to offline PostgreSQL 5433 integration target. Per `skill://langfens-verify`: offline integration setup failure is not a code bug. |
| **.NET Graders** | `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj` | 73 | **PASS** | All IELTS question graders (`IQuestionGrader`, `IQuestionGraderRegistration`) purely deterministic and passing. |
| **Historical Forensic Replay** | `python3 generation_baseline/tools/replay_quality_dev_hardening.py` | 22 dispatches | **PASS** | 22/22 original dispatches consumed, 23,886 tokens, 4/15 pass rate deterministically replicated. |
| **Execution Metadata Audit** | `python3 generation_baseline/tools/check_execution_records.py --phase RG10` | 5 sprints | **VALIDATOR LIMITATION NOTED** | Validator `allowed` set expects standard status tokens; flags historical sprint status `S03: PASS_WITH_EXTERNAL_BLOCKER` in `RG10-S03.json`. Original historical record (`S01`: PASS, `S02`: PASS, `S03`: PASS_WITH_EXTERNAL_BLOCKER, `S04`: PASS, `S05`: PASS) in `.execution/RG10/RG10-S03.json` remains preserved untouched. |
| **Dry-Run Campaign Readiness** | `python3 generation_baseline/tools/check_campaign_readiness.py` | 9 areas | **PASS (READY/HOLD)** | Strictly 0 provider network calls made; 168 assignments verified against frozen ledger; 635 raw response files discovered and schema verified. |

---

## 4. Candidate Freeze Manifest

The following versions and artifacts are formally pinned as the candidate freeze:

- **Candidate Evaluator:** `neutral-eval-v2.7` implemented by `NeutralEvaluatorV2_7` in `services/generation-service/app/evaluators/independent.py`.
  - Remediates `INV-DEV-02` (inversion with `-ss` and closed-class `-eed` base verbs).
  - Remediates `CND-DEV-01` (inverted conditional prompt-constraint parsing).
  - Remediates `SUB-DEV-04` (mandative subjunctive multi-option distractor discrimination).
  - Remediates `SUB-DEV-05` (mandative subjunctive trigger expansion).
  - Strict backward compatibility: Preserves exact semantics of `NeutralEvaluator` (v2.0), `NeutralEvaluatorV2` (v2.1), `NeutralEvaluatorV2_2`, `NeutralEvaluatorV2_3`, `NeutralEvaluatorV2_4`, `NeutralEvaluatorV2_5`, and `NeutralEvaluatorV2_6`.
- **Candidate Rubric:** `rubric-qgeval-v2.7` (4 dimensions: Grounding/Rule Conformance, Answerability/Uniqueness, Distractor Quality, Linguistic Clarity/Register).
- **Candidate Foundation Model:** `minimax/MiniMax-Text-01` (pinned for both generation and review).
- **Candidate Prompt Version Map:**
  - Arm A (Direct Generation): `v2.1-baseline`
  - Arm B (Self-Critique & Bounded Revision): `v2.2-grounded`
  - Arm C (Multi-Agent Decomposition & Repair Loop): `v3.0-adversarial`
- **Frozen Task Assignment Roster:** Exactly $N = 168$ assignments generated from 28 Reading tasks and 28 Grammar tasks across Arms A, B, and C (56 assignments per arm), matching `campaign_ledger.json` with 0 mismatches.
- **Separate Confirmatory Judge Holdout:** Exactly $N = 30$ evaluation items (18 Reading, 12 Grammar), strictly segregated from the 168 experimental campaign assignments.

---

## 5. Research Governance Audit & Invariants

1. **Confirmatory Holdout Status Remains PENDING:**  
   `CONFIRMATORY_HOLDOUT_MANIFEST.json` status remains `SPECIFICATION_PENDING_INDEPENDENT_CURATION`.
2. **Cryptographic Seals Remain Null:**  
   `reading_corpus_sha256: null`, `grammar_rule_packs_sha256: null`, `manifest_integrity_sha256: null`. All curator attestations remain `null`. No pre-computed seals or dummy signatures exist.
3. **Sound Leakage Standard Adopted:**  
   The impossible "zero lexical, topical, or morphological overlap" requirement has been formally replaced with **strict source-family quarantine** and **empirical exact/near-duplicate leakage bounds** (3-gram shingle Jaccard similarity $< 0.30$).
4. **Dedicated Role of Judge Holdout:**  
   The 30-item Judge Holdout is designated exclusively for **post-freeze evaluator reliability assessment** (measuring post-freeze False Rejection Rate [FRR], False Acceptance Rate [FAR], and abstention rate). It is strictly forbidden to use the holdout for threshold tuning, prompt engineering, or heuristic calibration.
5. **No Synthetic Data Generation:**  
   All holdout templates are schema-only with `[CURATOR: SUPPLY VERIFIED VALUE]` placeholders. Zero synthetic items have been generated or presented as human-curated data.

---

## 6. External Handoff Package

The following actionable documents and tools have been prepared for independent panel onboarding:

1. **Curator Instructions & Schema Templates:**  
   `generation_baseline/handoff/CURATOR_INSTRUCTIONS_AND_ITEM_TEMPLATE.md`  
   Provides human curators with exact requirements, length bounds (720–915 words), balance quotas (6 TRUE, 6 FALSE, 6 NOT GIVEN), evidence span specifications, and schema-only templates without fabricated citations.
2. **Source Provenance & Licensing Checklist:**  
   `generation_baseline/handoff/SOURCE_PROVENANCE_AND_LICENSING_CHECKLIST.md`  
   Defines the verification protocol for reserved source families (`fam-astrophysics-pulsar-08`, `fam-paleontology-cambrian-09`, `fam-mood-subjunctive-08`, `fam-aspect-participle-09`), Creative Commons/Open Access licensing, and non-synthetic panel attestation.
3. **Standardized Blind Annotation Forms:**  
   `generation_baseline/handoff/BLIND_ANNOTATION_FORMS.md`  
   Standardized evaluation forms for Annotator 1, Annotator 2, and Adjudicator for Reading (TFNG) and Grammar (MCQ) without exposure to system prompts, configuration arms, or suggested answer keys.
4. **Adjudication & Consensus Workflow:**  
   `generation_baseline/handoff/ADJUDICATION_WORKFLOW.md`  
   Defines automatic disagreement triggers (key divergence, verdict divergence, score delta $\ge 2$), Chief Adjudicator binding resolution, and Cohen's $\kappa$ / Gwet's $AC_1$ agreement calculation.
5. **Hash Verification Tool:**  
   `generation_baseline/tools/verify_corpus_hashes.py`  
   CLI tool for computing and verifying canonical SHA-256 digests over submitted JSON files (`reading_corpus.json`, `grammar_rule_packs.json`, `item_metadata.json`).
6. **Corpus Eligibility & Disjointness Tool:**  
   `generation_baseline/tools/check_corpus_disjointness.py`  
   Authoritative gate tool verifying 100% source-family quarantine, item-ID collision prevention, passage near-duplicate leakage bounds ($< 0.30$ Jaccard), and quota balance.
7. **Explicit Sealing Conditions:**  
   `generation_baseline/handoff/SEALING_CONDITIONS.md`  
   Details the 7 mandatory conditions required to transition manifest status to `SEALED_UNINSPECTED`.
8. **Dry-Run Campaign Readiness Tool:**  
   `generation_baseline/tools/check_campaign_readiness.py`  
   Offline readiness auditor evaluating all 9 research areas with zero live provider network calls.

---

## 7. External Blockers

Execution of the final research campaign is blocked on three external factors outside the software workspace:

1. **Provider API Quota:**  
   The external MiniMax provider account reached its plan limit (`HTTP 429: Token Plan usage limit reached (2056)`). Quota must be replenished before live dispatches can resume.
2. **Independent Holdout Curation:**  
   The 30-item Judge Holdout corpus must be curated by external human subject-matter experts and verified via `check_corpus_disjointness.py`.
3. **Qualified Human Panel Onboarding:**  
   Qualified human annotators (CEFR C2 / IELTS 8.5+ with 3+ years EAP experience) must be contracted to perform blind dual-annotation and adjudication.

---

## 8. Clear Actionable Criteria to Resume Final Research

To resume final confirmatory campaign execution:

1. **Replenish Provider Quota:** Restore MiniMax API plan balance and verify endpoint availability.
2. **Receive Curated Holdout Corpus:** Place curated files in `generation_baseline/holdout/` (`reading_corpus.json`, `grammar_rule_packs.json`, `item_metadata.json`).
3. **Pass Disjointness & Eligibility Audit:**  
   ```bash
   python3 generation_baseline/tools/check_corpus_disjointness.py --holdout-dir generation_baseline/holdout
   ```
   Must return `status: "AUDITED_ELIGIBLE"` with `eligible_for_sealing: true`.
4. **Compute SHA-256 Hashes & Seal Manifest:**  
   ```bash
   python3 generation_baseline/tools/verify_corpus_hashes.py --holdout-dir generation_baseline/holdout --manifest generation_baseline/research/CONFIRMATORY_HOLDOUT_MANIFEST.json
   ```
   Insert computed SHA-256 digests and panel lead signature into `CONFIRMATORY_HOLDOUT_MANIFEST.json`, and update status to `"SEALED_UNINSPECTED"`.
5. **Execute Dry-Run Readiness Check:**  
   ```bash
   python3 generation_baseline/tools/check_campaign_readiness.py
   ```
6. **Proceed with Authorized Live Campaign:** Execute only under explicit user authorization in bounded $\le 5$-item batches using `run_campaign.py`.

---

## 9. Gate Declaration

**SOFTWARE FREEZE:** **`CANDIDATE_FREEZE_LOCKED`**  
**OVERALL RG10 STATUS:** **`HOLD`**  
**NEXT ACTION:** Await external human curation submission, panel onboarding, and quota restoration. **Do NOT begin RG11 or the final A/B/C campaign.**
