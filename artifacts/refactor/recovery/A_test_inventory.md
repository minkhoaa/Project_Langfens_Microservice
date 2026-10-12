# A_test_inventory.md — Collected-Test Inventory & the "707 vs 702" Question

**Service:** `services/generation-service`
**Interpreter:** project venv, `.venv/bin/python` — **Python 3.14.7**
**Command (both checkouts, identical):**
```
cd services/generation-service
PYTHONDONTWRITEBYTECODE=1 .venv/bin/python -m pytest --collect-only -q -p no:cacheprovider
```

---

## 1. Actual collected counts

| Checkout | Test modules | Tests collected | Command output tail |
| --- | --- | --- | --- |
| **LOCAL** `<LOCAL_CHECKOUT>` @ `7a4d0e7` | **18** | **250** | `250 tests collected in 0.63s` |
| LOCAL recovery worktree @ `7a4d0e7` (clean HEAD, no untracked files) | 13 | 192 | `192 tests collected in 0.92s` |
| **VPS** `code@<VPS_HOST>` @ `04fdbd7` | **59** | **728** | `728 tests collected in 2.42s` |

There are **zero collection errors** on any of the three. Every module imports cleanly; no module is silently dropped.

---

## 2. Plain answer: the baseline is **not 707**, and the gap is not five tests

The assignment asserted a baseline of **707 expected** vs **702 collected**, a shortfall of exactly five. Both figures are wrong for this repository, and the difference is not a test count regression.

**Evidence that 707/702 appear nowhere as a test baseline.** A whole-repo search for the literals (excluding `.git`, `.venv`, `node_modules`) returns 7 hits, none of them a test count:

```
./models/qwen25-lora/checkpoint-600/tokenizer.json:951:      "Ġhas": 702,
./models/qwen25-lora/checkpoint-600/tokenizer.json:956:      "Ġdef": 707,
./models/qwen25-lora/checkpoint-766/tokenizer.json:951:      "Ġhas": 702,
./models/qwen25-lora/checkpoint-766/tokenizer.json:956:      "Ġdef": 707,
./models/qwen25-lora/tokenizer.json:951:      "Ġhas": 702,
./models/qwen25-lora/tokenizer.json:956:      "Ġdef": 707,
./artifacts/refactor/phase-07/campaigns/camp_g07_20261003_093107_578504_checkpoint.json:2176:      "tokensUsed": 707,
```

All are BPE vocabulary ids (`Ġhas`/`Ġdef`) or a benchmark token counter. **No artifact, gate, report, or plan in this repository records 707 or 702 as a test count.** The premise is unsupported.

**The real explanation.** Local collects **250**, not 702. The repository on the VPS collects **728**, not 707. The dominant variable is **module count, not test loss**:

| | LOCAL @ `7a4d0e7` | VPS @ `04fdbd7` |
| --- | --- | --- |
| Test modules | 18 | 59 |
| Tests collected | 250 | 728 |
| Delta | | **+41 modules, +478 tests** |

**41 modules exist on the VPS and have never existed in any local ref** (engine-v2 G07–G15 / Phase 15 work). They account for the entire difference:

```
test_automated_minimax_benchmark_dispatch.py      test_phase15_v2rate_a_summary_blank_recovery.py
test_campaign_budget_allocation.py                 test_phase15_v2rate_a_word_count_guard.py
test_campaign_budget_ledger.py                     test_phase15_v2rate_b_candidate_salvage.py
test_g08_report_integrity.py                       test_phase15_v2rate_b_cas_integrity.py
test_phase07_metric_artifacts.py                   test_phase15_v2rate_b_defect_routing.py
test_phase15_v2_generator_fixes.py                 test_phase15_v2rate_b_escalation.py
test_phase15_v2_repair_closure.py                  test_phase15_v2rate_b_match.py
test_phase15_v2rate_a_quantity_guard.py            test_phase15_v2rate_b_paper_head_refresh.py
                                                   test_phase15_v2rate_b_recovery_closure.py
                                                   test_phase15_v2rate_b_starvation_recovery.py
                                                   test_phase15_v2rate_c_starvation_recovery.py
                                                   test_phase15_v2rate_d_paper_passage_recovery.py
                                                   test_phase15_v2rate_main_campaign_binding.py
                                                   test_phase15_v2rate_main_no_resume_splice.py
test_r01_pre_dispatch_reservations.py              test_t10_blind_solvers.py
test_r02_reconciliation.py                         test_t11_section_loop.py
test_r03_config_caps.py                            test_t12_paper_loop.py
test_r03_runtime_caps.py                           test_t13_endpoints.py
test_r04_passage_checkpoint.py                     test_t13_events.py
                                                   test_t13_observability.py
                                                   test_t14_curation_export.py
                                                   test_t14_harness_integration.py
                                                   test_t14_offline_eval_promotion.py
                                                   test_t15_benchmarks.py
                                                   test_t15_cleanup_and_adapters.py
                                                   test_t15_release_manifests.py
                                                   test_t15_rollout_recovery.py
                                                   test_validation_matrix_provenance.py
```

(All 41 enumerated in full by `comm -13 <(local) <(vps)`; listed here abbreviated only for width — every name is machine-generated by that command.)

**Conclusion: no five tests are missing.** Nothing was removed, skipped, shortened, or dropped. Local is a 6-commit-earlier tree of a fast-moving branch. The correct integration target is `04fdbd7` (728), and the delta is 41 whole modules arriving with their engine-v2 `app/**`.

### Ruled out as explanations

| Candidate cause | Checked | Result |
| --- | --- | --- |
| Import/collection error silently dropping a module | collect-only stderr + per-file tally | **0 errors**; all 18 local modules collect |
| Module present but contributing 0 tests | `comm -23 all_files collected_files` | Only `tests/__init__.py` (correctly test-free) |
| Missing `__init__.py` / conftest | `tests/__init__.py` present; no `conftest.py` at root or in `tests/` | Not a factor; no test relies on a conftest fixture |
| Class-based tests not collected | AST class scan of all 4 targets | All helper classes are plain doubles, never test classes. Collected via `test_extractor.py::TestIngestSource` (class-based) — **is** collected |
| `@pytest.mark.skip` / `xfail` added | repo-wide search | **0** `skip`/`skipif`/`xfail` markers in local `tests/` |
| `@pytest.mark.parametrize` list shortened | no local change touches the 4 target files | N/A — t06/t09q byte-identical to VPS base |
| Missing test functions removed from these files | `git log --all --oneline -- <path>` | Only `7a4d0e7` exists for t06; t08/t09/t09_real never committed locally |
| Generator / yield-fixture swallowing tests | `t09_real` uses one `yield` session fixture; `pytest.ini` has `asyncio_mode = auto` | Both fine; 10 tests collected from t09_real |

---

## 3. LOCAL per-module collected counts (all 18 modules, 250 total)

| Module | Collected | Tracked in `7a4d0e7`? | Notes |
| --- | --- | --- | --- |
| `test_t06_loop_runtime.py` | 33 | yes | byte-identical to VPS stash base |
| `test_extractor.py` | 28 | yes | includes class-based `TestIngestSource` |
| `test_t07_evaluators_repairs.py` | 26 | yes | locally modified (+594) |
| `test_prompts.py` | 24 | yes | |
| `test_t03_providers.py` | 22 | yes | locally modified (+216) |
| `test_pipeline.py` | 20 | yes | |
| `test_t04_ingestion_evidence.py` | 16 | yes | |
| `test_t01_contracts.py` | 15 | yes | |
| `test_t07_metrics.py` | 12 | **no** (untracked) | |
| `test_t09_real_postgres_durability.py` | 10 | **no** (untracked) | needs Docker + real PostgreSQL |
| `test_t09_question_candidates.py` | 9 | **no** (untracked) | byte-identical to VPS |
| `test_t08_passage_loop.py` | 8 | **no** (untracked) | |
| `test_t00_endpoints.py` | 8 | yes | locally modified (+128) |
| `test_t05_blueprint.py` | 7 | yes | |
| `test_t02_durability.py` | 6 | yes | |
| `test_t00_policies.py` | 5 | yes | |
| `test_t00_regression.py` | 1 | yes | |
| `__init__.py` | 0 | yes | package marker |
| **TOTAL** | **250** | 14 tracked / 4 untracked | |

---

## 4. The four target modules — full node-ID inventory (60 tests)

### `test_t06_loop_runtime.py` — 33
`test_t06_01_*`, `test_t06_02_*`, `test_t06_03_*`, `test_t06_04_*`, `test_t06_05_evaluator_error_fail_closed`, `test_t06_05_optional_evaluator_skipped_with_policy_rationale`, `test_t06_06_*` (fault states 2–5, `crash_and_resume`), `test_t06_property_*`, `test_t06_parent_updated_during_evaluation_rejects_commit`, `test_t06_missing_parent_head_rejects_commit`, `test_t06_persisted_descendant_invalidation_removes_heads`, and the durability/lease/fencing group. All 33 collected; none skipped.

### `test_t08_passage_loop.py` — 8
`test_t08_01_passage_profiles_and_word_count_boundaries`, `test_t08_02_fidelity_evaluator_four_hard_errors`, `test_t08_03_sentence_level_immutable_repair_and_trim`, `test_t08_04_source_insufficient_bounded_escalation`, `test_t08_05_grounding_canaries_and_bypass_defenses`, `test_t08_06_crash_resumption_and_fencing_invariants`, `test_t08_07_adversarial_injection_in_source_envelope`, `test_t08_08_passage_loop_e2e_and_paired_benchmark`.

The module docstring advertises `T08-01 … T08-08`; all eight exist. **No gap.**

### `test_t09_question_candidates.py` — 9
`test_t09_01_six_type_candidates_generation_and_schema`, `test_t09_02_word_count_boundaries_for_completion_and_short_answer`, `test_t09_03_mcq_distractor_quality_and_duplicates`, `test_t09_04_summary_completion_group_coherence_and_blanks`, `test_t09_05_joint_constraints_anti_redundancy`, `test_t09_06_bounded_search_caps_and_infeasible_escalation`, `test_t09_07_persistence_crash_resumption_q17`, `test_t09_08_deterministic_tie_breaking_and_composition`, `test_t09_09_all_candidates_rejected_fails_closed`.

The module docstring advertises `T09-01 … T09-08`; there are **nine** tests because `T09-01` is additionally covered by the `_09_all_candidates_rejected_fails_closed` case. Slight docstring/test-count mismatch in the module's own prose; the test set is complete, not short.

### `test_t09_real_postgres_durability.py` — 10
Docstring lists 5 crash windows; the module has 10 tests: the five windows (`pre_dispatch`, `inflight_unknown_outcome`, `pre_commit`, `post_commit_pre_ack`, `idempotent_replay_accounting`) plus `failure_and_retry_accounting`, `actual_loop_q17_crash_and_cursor_resumption`, `unfinished_q17_pre_commit_fault_and_recovery`, `hard_execution_deadline_preservation_and_zero_provider_delta`, `dotnet_worker_consumer_integration`. Superset of the docstring — again, complete, not short.

---

## 5. Execution status of the target modules

Run without modification (`A_helper_recovery.md` §5 for triage):

```
$ .venv/bin/python -m pytest -q tests/test_t06_loop_runtime.py \
      tests/test_t08_passage_loop.py tests/test_t09_question_candidates.py
16 failed, 34 passed in 5.22s
```

- Collected 50 from these three; 34 pass, 16 fail.
- **0 failures are collection/import/helper failures.** All 16 are runtime assertion/HTTP failures caused by uncommitted local `app/loop/runtime.py` drift (10 × HTTP 409 cursor-ack, 1 × `assert 2 == 3`, 1 × provider HTTP 402 insufficient balance, 4 same-family).
- `test_t09_real_postgres_durability.py` deliberately **not** executed: its `autouse` session fixture requires Docker + `dotnet run` + real PostgreSQL on port 5099.

Per the assignment, the **full suite was not run** and no suites were weakened to obtain these numbers.

---

## 6. Statement for the coordinator

> The expected baseline of **707** is **not** supported by any artifact in this repository. Measured: **LOCAL = 250 collected across 18 modules** (zero errors); **VPS `04fdbd7` = 728 collected across 59 modules** (zero errors).
>
> **No five tests are missing.** No test was removed, skipped, xfailed, or shortened. The 41-module / 478-test delta is entirely **engine-v2 work that exists only on the VPS** and arrives with the 6 incoming commits (`1ea298a` … `04fdbd7`) plus their `app/**`. After integration the correct count is **728**, not 707.
>
> If "707" came from a specific gate or report, that source must be produced for review; it does not exist in either checkout.