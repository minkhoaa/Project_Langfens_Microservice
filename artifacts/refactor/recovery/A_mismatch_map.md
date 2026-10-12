# A_mismatch_map.md — LOCAL + HELPERS half

**Scope:** the LOCAL snapshot and the test-helper half of the cross-machine mismatch map. The VPS product-code half belongs to agent `VpsSnapshotProduct`; the coordinator merges both.
**Machine-readable form:** [`mismatch_map.json`](./mismatch_map.json) (same rows; validated JSON).

Host paths, the VPS address, the SSH key name, secrets, and DSNs are redacted to `<LOCAL_CHECKOUT>`, `<RECOVERY_WORKTREE>`, `<VPS_HOST>`, `<SSH_KEY>`, `<secret>`, `<postgres DSN, redacted>`.

---

## 1. Sanitized effective profile — LOCAL half

### 1a. `generation-service` settings — 41 fields, names + shapes only

No values emitted. Field names and declared types from `app/config.py` (sha256 `4a05b3dd…`).

| Group | Fields (type) |
| --- | --- |
| Runtime identity | `environment`(str), `port`(int) |
| Providers / credentials | `minimax_base_url`(str), `minimax_model`(str), `minimax_api_key`(str **secret**), `minimax_api_keys`(str **secret**), `groq_base_url`(str), `groq_model`(str), `groq_api_key`(str **secret**), `groq_api_keys`(str **secret**), `llm_provider_order`(str), `openalex_api_key`(str **secret**) |
| Loop caps | `loop_max_versions`(int), `loop_max_generated_versions`(int), `loop_max_repair_attempts_per_version`(int), `loop_max_total_repairs`(int), `loop_max_consecutive_no_progress`(int), `loop_max_oscillation_cycles`(int), `loop_max_total_calls`(int), `loop_max_total_tokens`(int), `loop_max_wall_time_seconds`(float), `loop_min_score_threshold`(float) |
| Reservations | `loop_generate_token_reservation`(int), `loop_evaluate_token_reservation`(int), `loop_repair_token_reservation`(int), `loop_operation_wall_reservation_seconds`(float) |
| Evaluators | `evaluator_deterministic_timeout_seconds`(float), `evaluator_semantic_timeout_seconds`(float), `evaluator_stage_timeout_seconds`(float), `evaluator_max_tokens_per_evaluation`(int) |
| Repair | `repair_timeout_seconds`(float), `repair_max_tokens_per_attempt`(int) |
| Evaluation cache | `evaluation_cache_enabled`(bool), `evaluation_cache_max_entries`(int) |
| Candidate search | `candidate_pool_limit_completion`(int), `candidate_pool_limit_tfng`(int), `candidate_pool_limit_mcq`(int), `candidate_pool_limit_summary`(int), `candidate_pool_limit_short_answer`(int), `candidate_max_search_depth`(int), `candidate_max_backtracking_steps`(int) |

Env-file keys present: `AI_SERVICE_ENV_FILE`, `GENERATION_SERVICE_ENV_FILE`. **Absent:** no `.env`, no `.env.example`, no `pyproject.toml`, no `setup.cfg` in `generation-service`.

### 1b. Test-harness profile

| Key | Value | Source |
| --- | --- | --- |
| `pytest.ini` `testpaths` | `tests` | `pytest.ini` sha256 `51ea33b6…` |
| `pytest.ini` `asyncio_mode` | `auto` | same |
| conftest | **absent** (no root, no `tests/`) | `ls` verified |
| Interpreter | Python **3.14.7** (project venv) | `.venv/bin/python --version` |
| Deps (names only) | `fastapi`, `uvicorn`, `pydantic`, `pydantic-settings`, `httpx`, `openai` | `requirements.txt` |
| Test modules / collected | 18 / **250** | `--collect-only -q` |

### 1c. Real-DB test env contract (shapes only)

`test_t09_real_postgres_durability.ensure_exam_service_running` sets: `ASPNETCORE_URLS`(`<url>`), `ConnectionStrings__exam-db`(`<postgres DSN, redacted>`), `EXAMSERVICE__INTERNAL__API__KEY`(`<secret>`), `JwtSettings__Issuer`(`<uri>`), `JwtSettings__Audience`(`<str>`), `JwtSettings__SignKey`(`<secret>`), `GENERATION_SERVICE_URL`(`<url>`). Plus a Docker container name for the exam DB and a `dotnet run` of `services/exam-service`.

**Machine-specific values intentionally not carried into shared code.** The coordinator should compare these shapes against the VPS half without importing either machine's credentials.

### 1d. Other behaviour-defining file hashes

| File | sha256 |
| --- | --- |
| `deploy/compose.yaml` | `0fdda68f11ef492ce5b2f63f1abca35af5d572fe10ce352ae3817a5d5e4c3979` |
| `AppHost/Program.cs` | `4c20d3a3456766d835f70b22a988c49f2f07e044c71ed48c4ec1beb5522db783` |

---

## 2. Test-file identity rows (LOCAL + HELPERS)

| Row | File | Symbol | Local blob | VPS stash base | Verdict |
| --- | --- | --- | --- | --- | --- |
| F1 | `test_t06_loop_runtime.py` | whole file | `497535a6…` | `497535a6…` | **IDENTICAL** |
| F2 | `test_t09_question_candidates.py` | whole file | `b20aec2f…` | `b20aec2f…` | **IDENTICAL** |
| F3 | `test_t08_passage_loop.py` | whole file | `8684c0b1…` | `58771b3f…` (**object unavailable on VPS**) | local variant |
| F4 | `test_t09_real_postgres_durability.py` | whole file | `6744e45a…` | `06879088…` | local variant |

---

## 3. Symbol rows — required contract → chosen implementation

Format: **symbol → local behaviour → required contract → chosen implementation**.

| # | Symbol | Local behaviour | Required contract | Chosen implementation |
| --- | --- | --- | --- | --- |
| 1 | `test_t06::DurableStore` | defined L136, 13 methods | `BoundedLoopRuntime.save_loop_cursor`; 409 fencing via `CheckpointApiError` | **KEEP UNCHANGED** (byte-identical to VPS base) |
| 2 | `test_t06::artifact`, `::context`, `::setup` | defined L33/L41/L323 | construct `LoopContext`, `LoopPolicy`, `BoundedLoopRuntime` | **KEEP UNCHANGED** |
| 3 | `test_t08::DurableStoreFake` | defined L73, 15 methods | fakes `CheckpointClient` for `PassageLoop` | **KEEP UNCHANGED** — shared with F-row t09q |
| 4 | `test_t08::_generate_academic_passage` | defined L271 | builds a style-conformant passage fixture | **KEEP UNCHANGED** |
| 5 | `test_t09q::make_test_refs` | defined L66 | builds `ArtifactRef` tuples | **KEEP UNCHANGED** (byte-identical) |
| 6 | `test_t09q` ← `tests.test_t08_passage_loop.DurableStoreFake` | cross-module import at L63, resolves | must expose the 15-method surface | **KEEP** — note the coupling: t08 and t09q must move together |
| 7 | `test_t09r::ensure_exam_service_running` | session `autouse` fixture L46; **raises** `RuntimeError` if exam-service unhealthy in 20s | real exam-service + real PostgreSQL | **KEEP UNCHANGED** — loud failure is correct |
| 8 | `test_t09r::get_exam_db_container` / `run_psql` / `seed_real_job_and_run` / `setup_upstream_and_precommitted_questions` | defined L99/103/108/142 | seed `reading_paper_jobs` / `reading_paper_runs` rows | **KEEP UNCHANGED** |
| 9 | `simulated_run_profile` (VPS) | absent | needs pinned-budget profile consumer fields | **REJECT** — no local consumer; `app/` has no `budgetProfile` |
| 10 | `policy_for_profile` (VPS) | absent | reads `budgetCap*` keys | **REJECT** — orphaned on this branch |
| 11 | `DurableStore(..., run_profile=…)` + `run_profile_sha256` (VPS) | absent | `LoopPolicy.from_settings().cap_profile_snapshot` | **REJECT** — attribute does not exist (`app/loop/policy.py:86` has `from_settings` only) |
| 12 | `resume_state(..., budgetProfile*)` (VPS) | absent | `ArtifactResumeInfo.budgetProfileJson/Sha256/Version/Source` | **REJECT** — `app/persistence/models.py` has none |
| 13 | `_default_cap_snapshot()` (VPS) | absent | `LoopPolicy.from_settings().cap_profile_snapshot` | **REJECT** — same missing attribute |
| 14 | `DurableStoreFake(..., cap_profile=…)` (VPS) | absent | same | **REJECT** — would also break the t09q consumer |
| 15 | `SQLiteCheckpointSimulation = DurableStoreFake` (VPS) | absent | an importer of the historical name | **REJECT** — 0 local importers; the stash comment's "several loop test modules" claim is false here |
| 16 | t08 evaluations dict key change (VPS) | key includes `run_id` | changes `resume_state()` output | **REJECT** — semantic change to a shared double |
| 17 | `is_service_available()` / `is_docker_postgres_available()` + module `skipif` (VPS) | absent | adds skip guards | **REJECT — coverage weakening.** Forbidden by contract item 6 |

---

## 4. Code rows (LOCAL product drift, for the VPS/product half)

| # | Location | Local behaviour | Required contract | Chosen implementation |
| --- | --- | --- | --- | --- |
| C1 | `app/loop/runtime.py` (uncommitted, +85/−27) | may save a loop cursor whose `lastOperationId` is not `COMPLETED` | cursor referencing an unacked op ⇒ 409 | **NO TEST CHANGE.** The double is right; fix the product code. 10 tests fail with `HTTP 409: cursor has no durable operation ack` |
| C2 | `app/loop/runtime.py` + `app/loop/passage.py` | resume returns 2 artifacts, test expects 3 | `test_t08_08` asserts 3 | **NO TEST CHANGE.** Relaxing 3→2 deletes a durability assertion |
| C3 | `app/providers/**` | live provider returns HTTP 402 `insufficient_balance_error` | — | **NO TEST CHANGE.** Credential/environment issue |
| C4 | `app/loop/policy.py`, `app/persistence/models.py` | no `cap_profile_snapshot`, no `budgetProfile*` | VPS engine-v2 R03/G06 | Out of local scope; arrives with the 6 VPS commits + their `app/**` |

---

## 5. Merge guidance

- **Target:** `04fdbd7`. **Expected post-merge collected: 728** (not 707 — see `A_test_inventory.md`).
- **Land the 6 VPS commits with their engine-v2 `app/**` as one unit.** A test-file-only cherry-pick breaks 50 currently-collecting tests.
- **Keep `test_t06` and `test_t09_question_candidates` byte-identical.** They are already canonical; the merge must not touch them.
- **Move `test_t08` and `test_t09_question_candidates` together** (cross-module `DurableStoreFake` dependency).
- **Do not** relax the cursor-ack 409 or the `t08_08` artifact count to clear the 16 current failures.
- **No `RC-1…RC-17` artifacts exist locally** (`grep -rInoE 'RC-[0-9]+'` → 0). Identifier families that do exist: `G07..G15`, `P15-01..P15-07`, `T00-01..T15-07`, `H4x`/`REQ-`. Any RC-N→commit mapping must come with external evidence.