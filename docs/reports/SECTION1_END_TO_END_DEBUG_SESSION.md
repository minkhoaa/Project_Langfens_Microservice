# Section 1 end-to-end debug session — BLOCKED, no new LIVE

## Disposition and implementation identity

**13/13 was not achieved.** The last real job remains **4/13 accepted**, with no Section/exam commit. This session made bounded corrective changes and completed offline investigation/verification; it did **not** certify the pipeline or submit a new job.

- Branch: `autonomous-generation`.
- Debug-session base HEAD: `2eef5c43846d9d1967707c873f36d404d1e561a8`.
- New implementation: **gated corrective candidate**, not a frozen release SHA. After the debug session, the owner explicitly requested a remote push. The commit containing this report records the candidate for review; this authorization does not override the red release/LIVE gates.
- Exact production patch SHA-256: `c46655b18d8863eac99675aea67aaf998043e54743cea5ff49786568ca732403` (SHA-256 of `git diff -- services/generation-service/app`). Per-file hashes, including tests, are in the verification manifest below.
- Historical LIVE implementation: `2da48d0a39289723830ea91d7451dfeac875357c`.
- Historical LIVE JobId: `2250820f-0ed9-42cb-80e8-70bcc38f2a7e`.
- Historical RunId: `run_2250820f0ed942cb80e870bcc38f2a7e`.
- New LIVE JobId/status: **NOT_RUN**. New MiniMax transport calls/tokens/cost: **0 / 0 / $0**.
- `LANGFENS_FULL_HANDOFF_2026-10-25.md` was not present anywhere in the checkout. Investigation used the actual current commits, saved snapshots, reports and code instead.

### Durable session outputs

- [`section1_session_verification.json`](../../reports/section1_session_verification.json): source hashes, final/intermediate suite counts, **every failing/skipped test name**, log hashes and red-test evidence references.
- [`section1_session_q5_replay.json`](../../reports/section1_session_q5_replay.json): fresh offline replay of all nine Q5 candidates and saved selected-item solver/adversary responses.
- [`section1_session_remaining_blockers.json`](../../reports/section1_session_remaining_blockers.json): actual parser/eligibility reproductions and explicitly labeled offline parent-budget doubles.

Original forensic inputs were not rewritten. No database was queried or modified in this session. Statements about historical PostgreSQL state below come from the saved durable extraction, **not a fresh database certification**.

## 1. Exact Q5 budget/evaluator/M3 trace

The actual rejecting authority was **BoundedLoopRuntime's local per-artifact admission**, not MiniMax billing or exhaustion of ReadingPaperWorker's whole-run allocation.

Persisted profile: `phase13-production-v1`, source `deploy/envs/loop-caps.env`, saved profile digest `ecc23288055c8b9719de9942316e43021d54c7d5fa4c32e658ae6632e702fd9b`.

| Authority/scope | Saved limit |
|---|---:|
| Standalone run | 1,200,000 tokens / 250 calls / 2,500 seconds |
| Durable section allocation | 380,000 tokens / 75 calls / 900 seconds |
| Local question artifact loop | **60,000 tokens / 15 calls / 300 seconds** |
| Generate / repair reservation | 15,000 / 15,000 tokens |
| Profile evaluate reservation | 10,000 tokens |
| Expensive StageExecutor adapter's selected reservation | **4,000 tokens** |
| Passage reservation in profile | 18,000 tokens; generic StageExecutor selection remains a separate defect |

The saved section allocation is distinct from the profile's legacy-section 800-second field and the unified wire policy's 100,000-token ceiling. These scopes must not be substituted for each other.

### Durable chronology (UTC, 2026-10-25)

| Event | Created | Local charged total after event | Actual Q5 provider tokens accumulated |
|---|---|---:|---:|
| V1 GENERATE wrapper; standalone candidate call | 13:40:48.435 / .454 | 15,000 | 2,442 |
| V1 solver and adversary, dispatched during structure callback | 13:41:04.593 / 13:41:10.852 | 15,000 | 6,624 |
| V1 blind adapter consumes cached results | after structure callback | 15,000 | 6,624 |
| REPAIR intended for V2; fails before M3 transport | 13:41:31.331 | **30,000** | 6,624 |
| V2 GENERATE wrapper and standalone candidate call | 13:41:31.387 / .405 | **45,000** | 9,073 |
| V2 solver and adversary | 13:41:47.707 / 13:41:52.867 | 45,000 | 13,256 |
| V3 GENERATE wrapper and candidate call | 13:42:03.585 / .601 | **60,000** | 15,721 |
| V3 solver and adversary, again early | 13:42:19.832 / 13:42:25.189 | 60,000 | **19,973** |
| V3 blind adapter requests its own reservation | terminal phase | **4,000 requested; rejected** | 19,973 |

Exact ledger reason: `Budget exhausted: next reservation (4000) exceeds token cap (remaining: 0 of 60000)`; externally surfaced as `TOKEN_CAP: next reservation exceeds token cap`.

The four 15,000-token wrapper reservations (three generates and one failed repair) became phantom local charges. The standalone provider operations had null `ParentOperationId`; wrapper reconciliation found no children. The paid reviews ran early during the zero-token structure callback, and later expensive adapters only consumed the cached results. There is **no evidence of repeated paid dispatch caused by evaluator caching**: the saved operations show 25 unique provider calls overall, nine for Q5, with distinct V1–V3 statements.

| Q5 version | Generate reserved → actual | Solver reserved → actual | Adversary reserved → actual | Actual total |
|---|---:|---:|---:|---:|
| V1 | 5,759 → 2,442 | 7,369 → 1,923 | 7,504 → 2,259 | 6,624 |
| V2 | 5,759 → 2,449 | 7,375 → 1,923 | 7,510 → 2,260 | 6,632 |
| V3 | 5,759 → 2,465 | 7,368 → 1,918 | 7,503 → 2,334 | 6,717 |

Q5's provider reservation **sum over time** was 61,906, actual usage 19,973. This sum is not simultaneous outstanding usage. All 100 historical operations were COMPLETED in the saved extraction; none remained RESERVED/UNKNOWN_OUTCOME. The whole run's provider reservation sum was 181,668, versus 60,789 reported actual tokens. The rejected 4,000-token operation was never granted.

### Why M3 made zero calls

`AMBIGUOUS_ANSWER` was eligible. The issue passed through controller → StageRepAdapter → SectionRunner repair callback → QuestionItemRepairer → typed repair planner. PostgreSQL rejected the child grant because the parent section was **`"1"`**, but the child requested **`"section_1"`**. The saved container warnings prove this. The planner wrapped the grant error in `RepairJustificationError`; runtime recorded `REPAIR_INFEASIBLE`, then regenerated using Text-01.

There was **one failed Q5 repair operation**, not two successful repair cycles. V2/V3 were regenerations. The final-slot controller rule explains why V2's failure led to regeneration rather than a second repair. Existing HEAD already corrects exact section naming, but that does not prove the whole repair budget contract works.

## 2. Independent semantic adjudication and candidate selection

All nine candidates cite passage offsets **[1020,1179)**:

> While the Nsukka region in Nigeria is frequently cited as a major center for early ironworking, direct evidence for sustained production there remains limited.

For each version, the pool contains a FALSE candidate asserting abundant evidence, a TRUE candidate accurately stating limited evidence, and a NOT_GIVEN candidate about passage coverage of Nsukka techniques/dates. Bound Claim 11's overlap was 0.636364 versus neighbouring Claim 10's 0.538462, yet bibliography-derived entity markers caused the positive candidates' rejection. Existing HEAD's bibliography correction preserves those candidates; the new replay selects FALSE, or TRUE if FALSE is removed.

**No historical blind-solving output exists for those discarded positive propositions.** Their deterministic PASS is not independent blind acceptance and is not counted as a new accepted question.

For the selected historical candidates:

- **V1:** A limitation on sustained-production evidence does not contradict a claim about smelting-technique details. The adversary's citation is topical, not contradictory.
- **V2:** The alleged FALSE quote is not verbatim; the old parser salvaged a topical clause with no technique predicate.
- **V3:** Alternatives are descriptive prose, not valid TFNG labels.
- Nevertheless, the actual questions say what “the passage discusses/provides.” They are text-coverage statements, not sound factual NG propositions. Rejecting a bad adversary allegation does **not** validate their NG keys. All three still fail the mandatory semantic evaluator with `TFNG_BOUNDARY_CONFLICT` in the fresh replay.

The replay's isolated `KEY_CONFIRMED` cells are explicitly **not complete acceptance**: the mandatory semantic evaluator blocks the same items.

## 3. New minimal corrective changes and test-first evidence

Five ownership-boundary corrections are retained in the working tree:

1. **No TypeError-triggered redispatch** — StageExecutor binds the callback signature before invocation. An internal TypeError after a side effect can no longer trigger an unscoped second repair call. Red reproduction observed two invocations; regression now observes one, with modern and legacy signatures covered.
2. **Unresolved-provider callback fence** — runtime checks durable provider outcomes before further admission, after draft/repair callbacks, and before evaluator reconciliation. A returned artifact/PASS or a caught repair exception cannot hide RESERVED/UNKNOWN_OUTCOME transport work. Parent reservations are not reconciled to free zero usage. Tests cover generation, evaluation, repair, both unresolved statuses and unrelated-artifact isolation.
3. **Conservative estimated-usage accounting** — local reconstruction refunds only completed REPORTED/RECONCILED provider usage. ESTIMATED, unknown and missing accounting types retain at least the reservation, matching durable refund authority. Nine cases include zero, nonzero, breach and rebuild boundaries.
4. **Narrower bibliographic stripping** — recognize author/comma/year citation syntax instead of deleting every parenthesis containing a capitalized word and year. New controls preserve `(Nsukka in 2002)`, ordinary place/date facts and quantities while retaining Q5's author/year correction. Syntactically ambiguous names in citation-shaped parentheses remain a limitation; no general NLP disambiguation is claimed.
5. **Adversary uncertainty is not clean agreement** — distinguish supported/unsupported/unresolved evidence relations. Incomplete lexical detection no longer discards genuine “never” or paraphrased contradictions. NG filtering only refutes literal whole-passage presence here; approximate overlap cannot discard a legitimate NG challenge such as wood versus charcoal. Unresolved independent reviews remain blocking. This may increase rejection/repair demand; it does not manufacture acceptance.

Each correction had an observed failing test before the corresponding implementation. Final review found a false-positive NG filter in the first tri-state implementation; a new wood/charcoal red test reproduced it, then the filter was narrowed. No change was made to generated keys, validator count, provenance thresholds, blueprint bindings, provider model roles, limits or publication authority.

### Recovery limitation — do not overclaim

The new uncertainty fence records **terminal UNKNOWN_OUTCOME failure**, not an automatically resumable pause. It preserves the wrapper reservation. Reconciling the child alone does not produce a missing wrapper artifact/result or authorize replay; the new restart test confirms that entry remains blocked. Parent disposition and a typed recovery/manual cursor-migration procedure are still required. Do not reset a cursor, synthesize a repaired artifact, or rerun uncertain paid work as a workaround.

## 4. Remaining demonstrated blockers

**These are blockers, not completed fixes.** Further unreviewed budget expansion or broad semantic refactoring was not bundled into the candidate.

### A. Provider authorization is still incomplete

- Selective question evaluation now orders dispatch correctly, but StageExecutor does not forward the evaluation intent/context. SectionRunner still supplies the outer RunContext, so solver/adversary requests remain standalone rather than constrained children of EVALUATE.
- Simply adding the parent ID is insufficient: the current **4,000-token** evaluation parent cannot admit the historical **7,369-token** conservative solver reservation. First-call reservation shortfall: **3,369**. After V1 solver actual usage, admitting the adversary requires **1,923 + 7,504 = 9,427**, a **5,427** gap relative to that parent. The persisted evaluation profile is 10,000; selecting/partitioning that existing authority needs explicit production-equivalent tests, not a higher paper cap.
- Hybrid REPAIR parent wall is 60 seconds. After even five seconds of M3 work, Text-01's independent 60-second request exceeds the parent: **5 + 60 > 60**. Sequential children need remaining-parent wall authority. Offline modeled grant checks reproduce both rejections; they are not live PostgreSQL tests.
- Physical calls are counted differently by wrapper admission versus restart reconstruction. Shared summary generation uses a different artifact ID without a parent and can escape per-question reconstruction. These are source-traced, independently reviewed gaps, not newly certified behavior.
- A crash after known failed-repair reconciliation but before the fallback cursor checkpoint can leave a completed repair operation without a corresponding artifact. Typed failure replay remains unimplemented.

### B. Q6–Q13 have concrete downstream content/repair blockers

Production `build_pool_from_raw_candidates` drops **flowSteps/stepIndex** and **tableContext/rowHeader/colHeader**. The one-off reproduction uses the real candidate builder; retained stimulus fields are empty. The repair application path also does not replace those fields. Initial SectionRunner parser/projection tests do not exercise that seam.

The actual saved Blueprint binds **Q7**, not Q6, to Claim 6:

> , Alpern, 2005 ; Holl, 2009 ; Killick, 2004 ; Robion-Brunner, 2018 ), which we will not revisit here.

The production eligibility function returns **true**, suitability **4.0**, because citation years count as quantitative detail. This is not a substantive metallurgy fact for table completion. It is upstream claim-quality debt, not an observed Q7 LIVE provider failure. A new graph/blueprint must exclude citation-only fragments before binding; historical immutable artifacts must not be changed.

### C. Mandatory regression/preflight readiness

The Python suite is red, including caps, repair compatibility, old endpoint contracts, research fixtures and strict semantic expectations. Failure names are preserved, not waived as “just mocks.” Existing Hybrid doubles reject canonical artifact IDs before reaching their intended scenario; aligning doubles with the real grant contract requires dedicated contract tests rather than restoring allocation aliases in production.

The runner preflight also prints hard-coded `UnlimitedCap (-1)` and 180-second dispatch claims instead of establishing the selected saved profile. Source inspection found this stale diagnostic; this session did not treat that prose as runtime authority.

### Budget policy conclusion

The historical Q5 TOKEN_CAP is **not evidence that the approved run/section cap must rise**. Historical mean question-version usage is 6,451.375 tokens, giving an illustrative one-pass 13-question total of ~93,046 including passage. That is not a reservation proof, a retry allowance or quality evidence. No cap was increased. The immediate shortfalls are operation hierarchy/child reservation and wall scheduling defects. A policy adjustment, if later needed, must explicitly name the selected immutable profile and be separately authorized with workload evidence.

## 5. Fresh offline verification

The existing service venv is **Python 3.14.8**, not the project's stated 3.12 target. Compatibility on 3.12 was not verified.

Final suites used a session-local guard denying TCP connections and Docker/psql/dotnet subprocess capability. The real PostgreSQL durability module was excluded. Tests that launch nested .NET suites could not execute them. No .NET/exam test was run, and no service/volume/marker was reset. A test-generated canonical 40Q fixture was restored to its original tracked bytes; no fixture rewrite is delivered.

| Gate | Result | Evidence boundary |
|---|---|---|
| Final corrective/Q1/provenance/production-shaped Hybrid/runtime and both 19-family suites | **202 passed** | Final source bytes; includes added regression controls |
| Expanded unified gate | **13 failed / 458 passed / 10 skipped** | Intermediate before final NG adjustment/additional case; not presented as final full verification |
| Final full Python suite | **122 failed / 1,837 passed / 24 skipped** | Final source bytes, 237.54 seconds, guarded; unsafe DB module excluded |
| Earlier full run in this session | 121 failed / 1,837 passed / 24 skipped | Retained intermediate result; not substituted for final result |
| Fresh Q5 V1–V3 replay | Nine candidates replayed | Deterministic positives pass; authored meta NG candidates remain blocked; positives have no independent paid review |
| Complete offline Section 1 fixture | Passed in final full suite | Existing `test_section_standalone_generation[1-1-13-expected_types0]`; **mock provider, legacy preset TFNG/sentence completion**, not the target table/flow blueprint or LIVE |
| Runtime/fencing/section suites | Included | Per-test results in manifest; not a claim that every test passed |
| `git diff --check` | PASS | Whitespace only; not release readiness |
| Read-only LIVE preflight / `--start-stack` | **NOT_RUN** | Offline/budget gates failed; no tested release SHA to deploy/freeze |
| New LIVE submission | **NOT_RUN** | Mandatory conditions unmet; preserved marker also prevents accidental submission |

All 120 failure names from the prior saved full-suite report occur again. Two additional final failure names are preserved:

- `test_t14_harness_integration.py::test_full_phase14_lifecycle_e2e`: the external-service guard refuses its nested `.NET` launch. This is unexecuted external coverage, not a product PASS.
- `unified/test_content_generation_correctness_gates.py::test_gate_4b_mcq_duplicate_options_rejected`: stopped earlier at wrong-claim provenance. An isolated current follow-up also failed. A matched run-identity comparison using a clean **HEAD app extracted outside the worktree** and current app reproduces the same failure on both (`1ec19aa8-...` identity). This establishes a pre-existing fixture/binding sensitivity for that identity, not permission to hide the final failure.

The full baseline was not rerun fresh; matching historical failure names does not prove absence of all regressions. Every final failure/skip is listed in the manifest.

## 6. Historical question scorecard — corrected from the actual saved Blueprint

**This is the last real job, not this session's new acceptance.** Earlier prose reports misstate Q6–Q13 bindings. The table below uses the saved ExamBlueprint payload directly.

| Q | Family | Bound claim suffix | Historical result | Accepted version / mandatory evaluator evidence |
|---:|---|---:|---|---|
| 1 | TFNG | 2 | ACCEPTED | V1, six saved PASS results |
| 2 | TFNG | 12 | ACCEPTED | V1, six saved PASS results |
| 3 | TFNG | 1 | ACCEPTED | V2, six saved PASS results |
| 4 | TFNG | 9 | ACCEPTED | V1, six saved PASS results |
| 5 | TFNG | 11 | REJECTED / TOKEN_CAP | No accepted head; V1/V2 ambiguity, V3 blind reservation rejected |
| 6 | TABLE_COMPLETION | **14** | NOT_REACHED | None |
| 7 | TABLE_COMPLETION | **6** | NOT_REACHED | None; citation-only binding identified offline |
| 8 | TABLE_COMPLETION | **7** | NOT_REACHED | None |
| 9 | TABLE_COMPLETION | **10** | NOT_REACHED | None |
| 10 | FLOW_CHART | 3 | NOT_REACHED | None |
| 11 | FLOW_CHART | 13 | NOT_REACHED | None |
| 12 | FLOW_CHART | **2** | NOT_REACHED | None |
| 13 | FLOW_CHART | **1** | NOT_REACHED | None |

Historical passage: **858 words**, saved word-count/fidelity/semantic PASS, V1 hash `00a833141f49cdd402341f0b595dc1c58bb04a1517cd0a7bd0ae1259db09fc15`.

Historical section/finalization: **not committed**, ExamId null, eight saved accepted heads (source, evidence, blueprint, passage, Q1–Q4). The saved job is Failed; the saved run row's RUNNING status is a known inconsistency, not authority to resume it.

Historical billing: **25 Text-01 / 0 M3 calls**, 53,252 prompt + 7,537 completion = **60,789 reported tokens**. Estimated cost **$0.0189411** at the snapshot's rates; actual billed invoice unavailable. No new paid MiniMax execution occurred here.

Submission marker SHA-256 stayed `d5c402709df3ca84714717c65dd50922b5d39e222080ad520b80bb3b7ecaa532`. It was never reset or removed. No historical job was relaunched.

## 7. Evidence classification and smallest justified next action

**Independently verified this session:** current HEAD/worktree, saved Q5 arithmetic/operation ordering, actual Blueprint bindings, exact candidate replay, red/green tests, full final test results, production stimulus-field loss and citation-fragment eligibility. The budget-grant reproductions are explicitly **offline doubles** checked against the parent predicates in `CheckpointService.cs`, not actual grants from a current DB.

**Agent-reported and then source-reviewed:** missing evaluator parent propagation, repair wall sharing, physical-call count mismatch, summary-group attribution and failed-repair crash gap. Two read-only reviewers independently audited semantics and budget/recovery seams. Their assessments did not authorize execution or certify tests. Final review identified the NG false-positive defect; the parent reproduced and corrected it, with fresh tests.

**Unresolved:** current deployed runtime/container identity and credentials, current PostgreSQL heads/grants, real paid behavior of preserved Q5 positives, target table/flow 13Q completion, typed unknown/known-failure recovery, full clean regression and Python 3.12 compatibility.

**Next action:** remain offline. Introduce an immutable operation-scoped callback authority for actual provider dispatch, with shared remaining token/wall/call admission under the existing pinned profile; test SectionRunner → StageExecutor → gateway against production-equivalent parent checks, including both solver calls and M3→Text-01 sequencing, retries and crash/restart. Then fix the proven table/flow repair transport and citation-only claim eligibility before creating a new blueprint. Reconcile the named red gates. Only after all mandatory gates pass should an owner-approved immutable SHA and an approved, non-resetting submission-marker procedure be considered for exactly one new LIVE attempt.

**Final verdict: BLOCKED_NO_NEW_LIVE; historical 4/13; no validator bypass or artificial acceptance.**
