# B_mismatch_map.md — VPS + PRODUCT half

> **This is the VPS/PRODUCT half only.** The coordinator merges it with the LOCAL half (owned by `LocalSnapshotHelpers`) into one map. Where the two halves touch the same row, this file's `chosen` column is the **product-side recommendation**, not a final ruling.
>
> **Base refs:** local = `7a4d0e7`; VPS = `04fdbd7`; origin = `56d060d` (**5 commits behind `7a4d0e7` — NOT the local base**). All local comparisons are against `7a4d0e7` committed state **plus** the ~22 uncommitted dirty `app/**` files.
>
> **Redaction policy:** key names and value *shapes* only. No passwords, tokens, or full DSNs appear anywhere in this file.

---

## Part 1 — Product-code mismatches (VPS behavior / local behavior / required contract / chosen implementation)

### P-01 · `app/config.py` — settings surface & cap-snapshot hashing
| | |
|---|---|
| **VPS `04fdbd7`** | `35896745…` (371 ln). `cap_snapshot_json()` / `cap_snapshot_sha256()`; two env files (`loop-caps.env` then `ai.env`); `internal_api_key` w/ 4-way `AliasChoices`; versioned G06 profile fields; `benchmark_caps_mode`; run-budget + benchmark-child caps; `provider_binding_snapshot()` (excludes API keys by design). |
| **Local `7a4d0e7`** | `6fb2f732…` (~76 ln). Single env file; no cap hashing; no profile fields; no `internal_api_key`. `groq_model="openai/gpt-oss-20b"`; reservations 2500/1000/1500; wall 30.0. |
| **Contract** | G06 versioned profile; cap-snapshot hash must match .NET `CheckpointService` byte-for-byte. |
| **Chosen** | Take VPS wholesale — **but LOCAL-DIRTY, needs three-way.** Confirm intentional: `groq_model` 20b→120b, reservations ×6/×10/×10, wall 30→60. |

### P-02 · `app/repair/question.py` — pooled-candidate salvage gating (RC-6)
| | |
|---|---|
| **VPS** | Gates on self-prompt leakage + shared-stem leakage + sibling distinctness, read **live per call**; `RepairJustificationError` when no compliant member. |
| **Local** | Verbatim + word-count only. |
| **Contract** | RC-6 — gates **strengthened, never relaxed**. |
| **Chosen** | **Take VPS. MUST NOT weaken.** LOCAL-DIRTY → three-way. |

### P-03 · defect routing for answer-semantics codes (RC-8)
| | |
|---|---|
| **VPS** | `AMBIGUOUS_ANSWER`/`BAD_DISTRACTOR`/`WORD_LIMIT_EXCEEDED` → `QuestionItemRepairer`; stem rewriter gated to `DUPLICATE_CONTENT`, convergent; unconditional `"(revised for distinct focus)"` removed. |
| **Local** | Router sends `AMBIGUOUS_ANSWER` to `ITEM_RESELECT`, then runs the synonym rewriter on every routed item question. |
| **Contract** | RC-8 — rewriter accreted filler, mutated accepted text. |
| **Chosen** | **Take VPS.** LOCAL-DIRTY. |

### P-04 · `app/loop/runtime.py` — strict-closure resync (RC-7)
| | |
|---|---|
| **VPS** | `_refresh_input_dependencies_from_res_state` + `_deps_resyncable_only` at the single fresh-draft admission site; identity+type+version+**content hash** verified; parent ids must be exactly the declared set; same-version/different-hash and regressions **refused**; only strictly-higher non-stale head adopted. |
| **Local** | Compares against deps declared once at loop construction → false `INVALID_OUTPUT`. |
| **Contract** | RC-7. Two weaker predicates were already **rejected in review**. |
| **Chosen** | **Take VPS verbatim. MUST NOT weaken** ("truthfully rejected by the RC-7 guard"). LOCAL-DIRTY. |

### P-05 · `app/loop/policy.py` / `controller.py` — scope-aware escalation (RC-13)
| | |
|---|---|
| **VPS** | `escalates(code, scope)`; `scope_recoverable_escalate_codes = {EVIDENCE_MISSING: {QUESTION}}`; `SOURCE_INSUFFICIENT` escalates at any scope. |
| **Local** | Escalates on code alone. |
| **Contract** | RC-13. `EVIDENCE_MISSING` **kept** in `escalate_codes`. |
| **Chosen** | **Take VPS.** LOCAL-DIRTY. |

### P-06 · `app/loop/detectors.py` + `runtime.py` — no-progress attribution & final-slot redirect (RC-3, RC-4)
| | |
|---|---|
| **VPS** | `normalized_outcome_fingerprint` strips volatile fields; `semantic_issue_identities` keys `(code, scope, normalized msg)`; final-slot REPAIR→REGENERATE redirect with `repeat_signal` guard. |
| **Local** | Hash reset each generation; oscillation requires next-state difference. |
| **Contract** | RC-3/RC-4. **No cap raised** (still ≤3 versions). |
| **Chosen** | **Take VPS.** |

### P-07 · `app/loop/paper.py` *(new file)* — first-draft live head (RC-17)
| | |
|---|---|
| **VPS** | All parents resolved to ACCEPTED HEAD from `resume_state` at assembly time, every version, canonical-id w/ fallback. |
| **Local** | File **absent**. |
| **Contract** | RC-17 — v1 draft built from pre-loop snapshot (case 13). 10 fail-closed branches; CAS untouched; idempotent. |
| **Chosen** | **Take VPS (new).** |

### P-08 · `app/contracts/policies.py` — verbatim matcher boundary (RC-12)
| | |
|---|---|
| **VPS** | Trailing boundary only when answer ends in token-continuation char; punctuation-terminated → `(?!\w)`. Single `_TOKEN_CONTINUATION` constant. |
| **Local** | Unconditional trailing guard. |
| **Contract** | RC-12 fuzz: **120 widened / 0 narrowed**; partial-word rejection preserved. |
| **Chosen** | **Take VPS.** LOCAL-DIRTY. Only place grounding is scoped-narrower; fuzz-bounded. |

### P-09 · `app/generators/passage/{generator,prompts}.py` *(new)* — deterministic guards (RC-14, RC-16)
| | |
|---|---|
| **VPS** | Numeric guard (`(?<![\w.])(\d{2,4})(?!\w\|\.\d)`), 1 bounded re-ask; word-count band from `PASSAGE_*_WORDS` (not overridable context), 1 bounded re-ask, **never clamp**. |
| **Local** | Prompt rule only; generator returned whatever the model produced. |
| **Contract** | RC-14/RC-16 — "stated but never checked". |
| **Chosen** | **Take VPS (new files).** |

### P-10 · `AppHost/Program.cs` — net-zero
| | |
|---|---|
| **VPS `04fdbd7`** | `cba010e8…` — **byte-identical to `7a4d0e7` and `56d060d`**. `1ea298a` +1 line, `04fdbd7` −15 lines. |
| **Local** | LOCAL-DIRTY — the **sole** non-base variant. |
| **Chosen** | **VPS contributes nothing.** Keep local's edit; do not take VPS. |

### P-11 · remaining 42-changed-file blast radius
`contracts/{__init__,artifact,evaluation,event,issue}.py`, `evaluators/{__init__,base,deterministic,registry,semantic}.py`, `evidence/{extractor,graph}.py`, `extractor.py`, `ingestion/source_pack.py`, `llm.py`, `main.py`, `persistence/{client,models}.py`, `pipeline.py`, `prompts.py`, `providers/*` (10), `repair/{__init__,base,passage,planner}.py`, `router.py` — carries RC-1 (hybrid blanks/candidates) and RC-2 (starvation fallback).
**Chosen: take VPS.** 21 of these are LOCAL-DIRTY → three-way required.

### P-12 · 56 added `app/**` files
New subsystems: paper/section/solver contracts; per-scope sub-loops; looped repair; new evaluator families; events (buffer/outbox/replay); curation; observability (accounting/redaction/tracing); offline_eval; promotion; solvers; selection; generator packages; facade.
**Chosen: take VPS (all).** None exist at `7a4d0e7`.

### P-13 · harness `scripts/refactor/run_phase15_benchmarks.py` (+3168)
Anti-splice + identity + truthful-field integrity (see `B_product_delta.md` §4).
**Chosen: take VPS.** Empirically confirmed by Main's live-DB SQL self-join.

---

## Part 2 — Environment / config mismatches (sanitized; shapes only)

### E-01 · `deploy/envs/loop-caps.env` — **present on VPS, ABSENT locally**
| | |
|---|---|
| **VPS** | 68 keys. Includes `LOOP_CAPS_PROFILE_VERSION`, `LOOP_CAPS_PROFILE_SOURCE`, `LOOP_MAX_RESPONSE_BYTES`, `PASSAGE_GENERATE_*`, `READING_PAPER_RUN_BUDGET_MAX_*`, `BENCHMARK_CHILD_RUN_MAX_*`, and full `READING_PAPER_{LEGACY,BENCHMARK}_{SECTION,PASSAGE,QUESTIONS,SOLVER,REVIEW}_{TOKEN,CALL,WALL}_CAP*` families. |
| **Local** | **Absent.** All caps came from `ai.env` + `config.py` defaults. |
| **Contract** | G06 versioned profile; `config.py` `_env_files` loads this file first when present. |
| **Chosen** | **Carry the file forward.** *Values:* fix-log asserts hash `da9f7fc6…` unchanged from the approved profile — **verify after merge, do not trust the doc.** Redacted: key names only. |

### E-02 · `deploy/envs/ai.env` — 32 keys VPS vs **45** local; all 14 `LOOP_*` keys moved out
| | |
|---|---|
| **VPS** | **32** keys. **Only-VPS:** `CORS_ALLOWED_ORIGINS`. **Does NOT contain** any `LOOP_*` key (moved to `loop-caps.env`). |
| **Local** | **45** keys. **Only-Local (14):** `LOOP_MAX_VERSIONS`, `LOOP_MAX_GENERATED_VERSIONS`, `LOOP_MAX_REPAIR_ATTEMPTS_PER_VERSION`, `LOOP_MAX_TOTAL_REPAIRS`, `LOOP_MAX_CONSECUTIVE_NO_PROGRESS`, `LOOP_MAX_OSCILLATION_CYCLES`, `LOOP_MAX_TOTAL_CALLS`, `LOOP_MAX_TOTAL_TOKENS`, `LOOP_MAX_WALL_TIME_SECONDS`, `LOOP_GENERATE_TOKEN_RESERVATION`, `LOOP_EVALUATE_TOKEN_RESERVATION`, `LOOP_REPAIR_TOKEN_RESERVATION`, `LOOP_OPERATION_WALL_RESERVATION_SECONDS`, `LOOP_MIN_SCORE_THRESHOLD`. |
| **Shared** | 31 keys (all `EVALUATOR_*`, `REPAIR_*`, `EVALUATION_CACHE_*`, and the Qdrant/Redis/MiniMax/Groq/Cerebras/Gemini keys). |
| **Chosen** | **Verify on migration that `loop-caps.env` carries all 14 `LOOP_*` keys.** VPS `loop-caps.env` holds the caps keys, but **`LOOP_MIN_SCORE_THRESHOLD` is a score threshold, not a cap** — confirm it is not lost. Do **not** copy `CORS_ALLOWED_ORIGINS` into local. |

### E-03 · service env files — computed key-set comparison (CORRECTED)
**An earlier draft asserted "identical key sets" from similar counts. That was wrong.** Actual key-name sets, computed with `grep -oE "^[A-Z_]+=" | sort` on both machines:

| File | VPS keys | Local keys | Shared | Only-VPS | Only-Local |
|---|---|---|---|---|---|
| `exam.env` | 3 | 2 | 2 | `CORS_ALLOWED_ORIGINS` | — |
| `auth.env` | 11 | 10 | 10 | `CORS_ALLOWED_ORIGINS` | — |
| `gateway.env` | 2 | 2 | 2 | — | — |
| `attempt.env` | 14 | 13 | 13 | `CORS_ALLOWED_ORIGINS` | — |
| `vocabulary.env` | 11 | 11 | 11 | — | — |
| `writing.env` | 14 | 14 | 14 | — | — |
| `speaking.env` | 17 | 17 | 17 | — | — |
| `dictionary.env` | 5 | 4 | 4 | `CORS_ALLOWED_ORIGINS` | — |
| `gamification.env` | 8 | 7 | 7 | `CORS_ALLOWED_ORIGINS` | — |
| `course.env` | 3 | 2 | 2 | `CORS_ALLOWED_ORIGINS` | — |
| `email.env` | 17 | 16 | 16 | `CORS_ALLOWED_ORIGINS` | — |
| `frontend.env` | 3 | 2 | 2 | `CORS_ALLOWED_ORIGINS` | — |

**Single systematic one-sided key: `CORS_ALLOWED_ORIGINS` is present on the VPS in 10 files and absent locally in every one.** This is the production CORS allowlist — a real deployment concern, deliberately absent from local dev. It must **not** be copied into local env files, and must not be committed.

**No key exists locally-only in any service file** except in `ai.env` (see E-02). **Chosen: no action for the shared keys; treat `CORS_ALLOWED_ORIGINS` as VPS-only deployment config, never merge it.**

### E-04 · provider model defaults (behavioral)
| Key | VPS default | Local `7a4d0e7` default | Chosen |
|---|---|---|---|
| `groq_model` | `openai/gpt-oss-120b` | `openai/gpt-oss-20b` | **Confirm intent** before carrying |
| `minimax_model` | `MiniMax-Text-01` | `MiniMax-Text-01` | match |
| `minimax_base_url` / `groq_base_url` | identical | identical | match |
| `llm_provider_order` | `minimax,groq` | `minimax,groq` | match |

### E-05 · loop reservations (behavioral, ×6/×10/×10)
| Key | VPS | Local | Chosen |
|---|---|---|---|
| `loop_generate_token_reservation` | `15000` | `2500` | **Confirm intent** |
| `loop_evaluate_token_reservation` | `10000` | `1000` | **Confirm intent** |
| `loop_repair_token_reservation` | `15000` | `1500` | **Confirm intent** |
| `loop_operation_wall_reservation_seconds` | `60` | `30.0` | **Confirm intent** |
| `loop_max_wall_time_seconds` | `int 300` | `float 300.0` | **Int coercion is required** by `from_cap_snapshot` — VPS is correct |

### E-06 · benchmark DB target (harness-defined, isolated)
`PGPORT`=`5433` · `PG_BENCHMARK_DB`/`exam_test_phase15` · target class `ISOLATED_STAGING_TEST` · `FORBIDDEN_PROD_DBS` includes **`exam-db`**, `auth-db`, `attempt-db`, and 6 more. DSN shape: `Host=<h>;Port=<p>;Database=<db>;Username=<role>;Password=<REDACTED>`.
**Chosen: carry forward unchanged.** It is the isolation guarantee; do **not** point it at a production DB name.

### E-07 · ports
VPS compose-local host ports: `exam-db 5433`, `auth-db 5434`, `attempt-db 5435`, `writing-db 5440`, `speaking-db 5441`, `dictionary-db 5443`, `gamification-db 5444`, `course-db 5446`, `vocabulary-db 5987`.
**Chosen: no action** (matches repo port table). Observed live: `5432`(unrelated `dcp`), `5433`, `5434` listening; `5435` **not** listening.

### E-08 · deploy/compose.yaml
VPS `eefc6efb…` (488 ln) vs origin `77c248ea…`. `compose.local.yaml` VPS `734cb2e7…` (518 ln).
**Chosen: take VPS.** NOTE `stash@{0}` contains a **−18-line** change to `compose.yaml` and **−15** to `AppHost/Program.cs` and **−2** to `compose.local.yaml` — that stash is pre-HEAD residue from the abandoned rebase; **do not apply it.**

---

## Part 3 — Test-helper mismatches (product-side observations; the LOCAL agent owns the fix)

| ID | VPS | Local | Chosen |
|---|---|---|---|
| T-01 | `tests/test_t06_loop_runtime.py` **uncommitted** on VPS: `simulated_run_profile` → `{caps, profileVersion, profileSource}` from `LoopPolicy.RESOURCE_CAP_FIELDS` w/ int coercion; `policy_for_profile` → `LoopPolicy.from_cap_snapshot(...).model_copy(...)`; `DurableStore` stores profile verbatim | 1038 ln, bare-budget shape | **HAND OFF verbatim** to LOCAL agent. `from_cap_snapshot` rejects anything else. |
| T-02 | `test_t08_passage_loop.py`, `test_t09_real_postgres_durability.py` present in `stash@{0}` (+40, +35) | — | LOCAL agent owns |
| T-03 | `04fdbd7` body: **72 failed / 630 passed**; fix-log §5: **6 failed / 701 passed / 42 skipped** | — | **Both wrong as baselines.** Main verified: `707` = 701+6 from the milestone table; `702` is a passage word-count in `logs/generation-service.log:103454`. **Measured: local 250 tests/18 modules; VPS 728/59. Post-merge target = 728.** |
| T-04 | `test_t07_evaluators_repairs.py` +40 (`f56a097`) and +770 over the range | LOCAL-DIRTY same file | **BEHAVIOR-PRESERVING** test-only addition; reconcile with LOCAL agent |

---

## Part 4 — Evidence mismatches (detail in `B_g15_audit.md`)

| ID | Mismatch | Chosen |
|---|---|---|
| D-01 | `gate.json` @HEAD reverted by `04fdbd7` to `11/18` BLOCKED while `release-manifest.json` (unchanged, same commit) says 18/18 PASS | **DO NOT reuse either as the G15 verdict.** Coordinator must reconcile. |
| D-02 | 5 narrative docs added by `04fdbd7` describe only `camp_G15_c9750f53d6b5` (`snapshot-manifest.json` cites it **82×**, 0× the acceptance campaign) | **Supersede** with the acceptance campaign's report before any release claim |
| D-03 | `v2rate-root-cause-and-fix-log.md` §9 = `Pending.`; header `Status: IN PROGRESS` | Fill or explicitly mark superseded |
| D-04 | Campaign report binds orphaned `8deff37`; nested `worktree.gitHead`=`56d060d`; tree **dirty** at 1438 paths | **Evidence still reusable** — engine tree is byte-identical to HEAD (`dc86e69c…`, verified by Main) |
| D-05 | `benchmarkReportSha256 601fe865…` identical in both gate revisions ⇒ not recomputed for the new campaign | Recompute if re-baselining |
| D-06 | `release-manifest.metricEngineHash a958e94e…` vs uncommitted VPS matrix `2.3.1/96d2ba2c…` | Regenerate manifests after merging matrix refresh |
| D-07 | canary (`14/14`) + rollback (`5/5`) evidence bound to `exam_test_phase14_lineage` @ `56d060d`, dated 2026-10-09/10 | **PENDING for the current candidate** — predates remediation |
| D-08 | `camp_G15_855da04e41ba` has 48 rows vs 36 expected | **Observation only**; does not affect `022943e248ec`. Do not block. |
| D-09 | No `cases/attempts/` directory in tree despite the archival feature | Cosmetic; the 8 FAILED rows **were** retained in Postgres (Main) |

---

## Splice & compatibility conclusions (product side)

- **Replay-row splicing: PASS.** Six independent checks (C1–C6) — 0 byte-dupes, 36/36 unique ids, 18/18 unique input tuples, 0 cross-campaign overlap (filesystem **and** live-DB SQL self-join `COUNT(*)=0`), 1013 dispatch events with 0 fingerprint collisions, 8 FAILED rows retained in Postgres.
- **Engine-tree compatible:** `8deff37:app == HEAD:app == dc86e69c…` (Main) ⇒ 18/18 evidence is reusable for the current engine.
- **G15 remains BLOCKED:** `G12` BLOCKED; `P15-04`/`T15-06` BLOCKED_ON_PRODUCTION_OBSERVATION; `T15-07`/`P15-07` BLOCKED_PARTIAL_CONTAINER_REHEARSAL.

## Commits created by this agent

**None.** Branch `refactor/recovery-vps-product` points at the existing VPS HEAD `04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d`. The six files in this directory are **untracked and uncommitted** in the worktree for coordinator review.