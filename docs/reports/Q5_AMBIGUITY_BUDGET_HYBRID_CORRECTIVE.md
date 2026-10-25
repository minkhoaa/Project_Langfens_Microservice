# Q5 ambiguity, Hybrid routing and token reservation corrective

## Disposition — OFFLINE GATE BLOCKED; no new LIVE

Starting branch: `autonomous-generation`; verified starting HEAD: `391b8c5e227e0c4a8645a88596e70f0de3b78034`.

Gated corrective candidate implementation SHA: **`043b97d92665fe5860666e8f0e2b1c8e9cf8a541`**. This identifies the reviewed candidate, not an approved LIVE implementation.

**This is a forensic report and a gated corrective candidate, not a successful release or a live-quality certification.** Implementation stopped when the mandatory unified regression gate failed. No caps were increased, no Blueprint was changed, no historical job was resumed, and no new generation job was submitted. Candidate changes are retained for review, explicitly **not release-ready**.

Fresh verification:

| Gate | Result |
|---|---|
| New Q5 tests, including exact historical payloads | **27 passed** |
| Final targeted Q5 + Q1 + claim-provenance verification | **60 passed** |
| Unified relevant suites, from repository root | **13 failed, 270 passed, 16 skipped** |
| Same pre-existing suites at starting HEAD, with matching local env files/snapshots | **5 failed, 251 passed, 16 skipped** |
| Full generation suite, real TCP connections forbidden; real-PostgreSQL mutation module excluded | **120 failed, 1810 passed, 24 skipped** |
| `git diff --check` | PASS |
| Conditional LIVE / infrastructure preflight | **NOT_RUN** — offline gate failed |

All failing node IDs, including the full-suite failures, are recorded in [`reports/q5_corrective_offline_results.json`](../../reports/q5_corrective_offline_results.json). None are suppressed or counted as passes. The first service-directory invocation additionally encountered three root-relative historical fixture path errors; root-directory reruns above remove that invocation artifact. An initial full-suite attempt timed out at 180 seconds; the subsequent full run completed in 260.11 seconds. Full-suite fixture regeneration was reverted; no unrelated fixture changes are delivered.

## 1. Evidence and reproduction

Authoritative historical input:

- [`hybrid_13q_post_hardening_2250820f-0ed9-42cb-80e8-70bcc38f2a7e.json`](../../reports/hybrid_13q_post_hardening_2250820f-0ed9-42cb-80e8-70bcc38f2a7e.json).
- Historical implementation: `2da48d0a39289723830ea91d7451dfeac875357c`.
- Historical run: `run_2250820f0ed942cb80e870bcc38f2a7e`.
- Job: Failed; accepted questions: 4/13; section uncommitted.

Additional read-only extraction from the existing `benchmark-text-db`, using `BEGIN READ ONLY`:

- [`q5_corrective_durable_accounting.json`](../../reports/q5_corrective_durable_accounting.json): persisted run profile, cursors, all 100 operations, reservations, outcomes and parent IDs. No DB mutations or lease renewal were performed.
- [`q5_corrective_routing_evidence.txt`](../../reports/q5_corrective_routing_evidence.txt): actual generation-container warnings identifying the rejected M3 child grant.
- [`q5_corrective_job_reconciliation.json`](../../reports/q5_corrective_job_reconciliation.json): terminal job identities, saved submission marker and durable allocations.

Offline replay utility: [`scripts/replay_q5_corrective.py`](../../scripts/replay_q5_corrective.py). It invokes `_parse_single_candidate`, `_parse_candidate_payload`, `verify_question_claim_provenance`, `evaluate_question`, the production solver/adversary parsers, canonical answer comparison and adjudication. It never calls a provider. Results:

- [`q5_corrective_replay_before.json`](../../reports/q5_corrective_replay_before.json): starting-HEAD behavior, all nine candidates, raw payloads, exact evidence, competing claims, evaluator issues and selected-item solver/adversary output.
- [`q5_corrective_replay_after.json`](../../reports/q5_corrective_replay_after.json): corrective-candidate behavior on the same payloads.

```bash
services/generation-service/.venv/bin/python scripts/replay_q5_corrective.py \
  --output reports/q5_corrective_replay_after.json
PYTHONPATH="$PWD/services/generation-service" \
  services/generation-service/.venv/bin/python -m pytest -q \
  services/generation-service/tests/test_q5_corrective_gate.py \
  services/generation-service/tests/test_q5_budget_reconciliation.py
```

No historical solver payload exists for the discarded TRUE/FALSE propositions. Their blind-solver/adversary cells are **NOT_RUN**, not inferred PASS. Reusing the NOT_GIVEN statement's solver answer for a different proposition would be invalid. Deterministic evaluation was replayed even for parser-discarded candidates solely to expose the exact rejection.

## 2. Historical Q5 candidate matrix

Immutable slot: Q5, `TRUE_FALSE_NOT_GIVEN`, Claim **11**, `isNotGivenTarget=false`.

Bound source claim:

> However, direct evidence for sustained iron production there remains limited (Okafor, 2002 ; Okafor & Phillips, 1992 ).

All nine candidates use the following accepted-passage span, as positive evidence for c0/c1 or **topical context only** for c2:

> While the Nsukka region in Nigeria is frequently cited as a major center for early ironworking, direct evidence for sustained production there remains limited.

Exact offsets: **[1020, 1179)**. The parser retained this entire verbatim span; the prior Q1 localizer did not shorten it. It spans the neighbouring Nsukka context and Claim 11's limitation, but contains the required limitation intact.

Competing Claim **10**:

> From east to west, the Nsukka region in Nigeria has long been considered a major center for early ironworking in sub-Saharan Africa.

For every raw Q5 span: bound ratio **7/11 = 0.636364**, Claim 10 ratio **7/13 = 0.538462**. The rejection is **not** deduced from those scores: the actual provenance call returns `CLAIM_PROVENANCE_MISMATCH` due to `marker_conflict=true`.

| V / candidate | Raw statement | Raw answer | Parser/provenance result at starting HEAD | Advisory penalty | Semantic replay at starting HEAD | Historical blind/adversary | Historical disposition |
|---|---|---|---|---:|---|---|---|
| V1 c0 | The Nsukka region in Nigeria is widely recognized as a major center for early ironworking with abundant direct evidence of sustained production. | FALSE | `CLAIM_PROVENANCE_MISMATCH`, Claim 10 entity conflict | 0 | FAIL: same provenance issue | NOT_RUN | Discarded before priority sorting; abundant vs limited is a genuine contradictory factual component |
| V1 c1 | The passage mentions that the Nsukka region in Nigeria has limited direct evidence for sustained iron production. | TRUE | `CLAIM_PROVENANCE_MISMATCH`, Claim 10 entity conflict | 0 | FAIL: same provenance issue | NOT_RUN | Discarded despite correctly paraphrasing Claim 11 |
| V1 c2 | The passage discusses the specific techniques used in iron smelting in the Nsukka region of Nigeria. | NOT_GIVEN | No parser rejection | 1 | PASS | Solver NG; adversary FALSE; `AMBIGUOUS_DEFECTIVE` | Sole surviving candidate; blocking `AMBIGUOUS_ANSWER` persisted |
| V2 c0 | The Nsukka region in Nigeria is frequently cited as a major center for early ironworking, with abundant direct evidence for sustained production. | FALSE | `CLAIM_PROVENANCE_MISMATCH`, Claim 10 entity conflict | 0 | FAIL: same provenance issue | NOT_RUN | Discarded before priority sorting |
| V2 c1 | The passage mentions that the Nsukka region in Nigeria has limited direct evidence for sustained iron production. | TRUE | `CLAIM_PROVENANCE_MISMATCH`, Claim 10 entity conflict | 0 | FAIL: same provenance issue | NOT_RUN | Discarded before priority sorting |
| V2 c2 | The passage provides information on the specific types of iron smelting techniques used in the Nsukka region. | NOT_GIVEN | No parser rejection | 1 | PASS | Solver NG; adversary FALSE; `AMBIGUOUS_DEFECTIVE` | Sole survivor; second `AMBIGUOUS_ANSWER` persisted |
| V3 c0 | The Nsukka region in Nigeria is frequently cited as a major center for early ironworking, with abundant direct evidence for sustained production. | FALSE | `CLAIM_PROVENANCE_MISMATCH`, Claim 10 entity conflict | 0 | FAIL: same provenance issue | NOT_RUN | Discarded |
| V3 c1 | The passage mentions that the Nsukka region in Nigeria has limited direct evidence for sustained iron production. | TRUE | `CLAIM_PROVENANCE_MISMATCH`, Claim 10 entity conflict | 0 | FAIL: same provenance issue | NOT_RUN | Discarded |
| V3 c2 | The passage discusses the specific dates when iron smelting began in the Nsukka region of Nigeria. | NOT_GIVEN | No parser rejection | 1 | PASS | Solver NG; adversary supplies two descriptive sentences rather than valid TFNG labels; offline old adjudicator: `AMBIGUOUS_DEFECTIVE` | Generated and provider-reviewed, but its final blind evaluation operation was never admitted/persisted: TOKEN_CAP |

### Proven root cause of positive-candidate loss

Claim 11's discriminators included:

```text
entity:okafor, entity:phillips, number:1992, number:2002,
qualifier:limited, qualifier:sustained
```

The quote included:

```text
entity:nsukka, entity:nigeria, qualifier:limited, qualifier:sustained
```

The category-aware Q1 fix prevents qualifier/entity cross-category conflicts, but still treats bibliographic authors as factual entities. Missing `Okafor`/`Phillips` plus shared Claim 10 geography triggers a same-category entity conflict. The precise gate message misleadingly says the quote “primarily supports” Claim 10 even though Claim 11's score is higher.

Corrective candidate: remove author/year citation groups from **discriminator extraction only**; retain original claim text, provenance IDs, numerical factual dates, overlap thresholds and offsets. All six TRUE/FALSE candidates now pass provenance and all five deterministic evaluations. The pool chooses c0 FALSE for all three versions; TRUE wins when the FALSE candidate is absent. NOT_GIVEN target priorities are unchanged. No independent-solver PASS is claimed for these unreviewed positives.

## 3. Adversarial ambiguity and the invalid meta key

### V1

The FALSE alternative quotes the exact 1020..1179 span but supplies guessed offsets **285..389**. Old adversary parsing re-localizes the text to 1020..1179. Its rationale equates limited evidence of **sustained production** with absence of **smelting-technique details**. These are not the same proposition. A real quote about a topic does not demonstrate a contradiction about techniques.

### V2

The FALSE alternative submits a non-verbatim paraphrase (“The Nsukka ... but direct evidence ...”), offsets **307..404**. Old parsing salvages just the first topical clause at **1026..1114**, then stamps the alternative as grounded. That surviving clause contains no technique predicate and no contradictory proposition. The companion NG alternative cites the question itself rather than passage evidence and is unsupported.

### V3

The alternatives are prose descriptions, not TRUE/FALSE/NOT_GIVEN answers. Their supplied offsets **354..462** and **354..419** are wrong; old parsing finds exact substrings at **1026..1179** and **1026..1114** and accepts the prose as distinct answers. The entire diagnostic was computed while serving the structure callback; it is not a durable V3 blind-evaluator PASS/FAIL record.

### Solver citation defect

The historical solver returned NG on all three statements. The parser localized or salvaged actual text but retained the model's old offsets:

| Version | Old stored offsets | Retained exact text's real offsets |
|---|---|---|
| V1 | 220..340 | **1026..1114** |
| V2 | 283..347 | **2487..2599** |
| V3 | 366..434 | **2487..2599** |

The latter location is another Nsukka context occurrence in the passage. Corrective candidate stores the offsets of the **actual retained substring**, never the original guessed coordinates.

### Adjudication boundary

- Missing information is not a contradiction of a factual proposition.
- TRUE requires entailment; FALSE requires contradiction; NG requires neither.
- `isGroundedInPassage=true` and plausibility scores are not evidence authority.
- The corrective production adversary path receives the student-visible question, rejects invalid TFNG answer labels, disallows clause salvage for an invalid TFNG adversary quote, and checks alleged TRUE/FALSE support against the actual proposition using existing bounded semantic checks.
- Genuine competing contradictory dates remain blocking in regression tests; blind solving is not removed or answer-key-aware.

**Important:** the original statements are about what **the passage discusses/provides**, not direct factual claims about furnaces or dates. The unsupported-adversary finding does **not** validate their NG keys. The corrective semantic evaluator emits `TFNG_BOUNDARY_CONFLICT` for this coverage framing, and generation instructions demand direct factual propositions. “The passage states that X” attribution is not globally banned; no global TFNG answer distribution is changed.

On isolated corrected adjudication the historical NG solver matches its key and the unsupported adversary is rejected. The **full question remains blocked by the mandatory semantic evaluator**. This distinction is explicit in the after-replay JSON; isolated `KEY_CONFIRMED` is not six-evaluator acceptance.

## 4. Exact Hybrid routing trace

1. `BlindSolverEvaluator` creates V1 issue `iss_eval_bsa_261f137dccd4`, V2 issue `iss_eval_bsa_9f9a5cd2487f`.
2. Both are `AMBIGUOUS_ANSWER`, `CRITICAL`, `QUESTION`, `OPEN`; affected refs are exact Q5 versions/hashes. Evidence/proposedRepair are null. Fingerprints: `0d8e2aa94654699d5167bfb6914062a2e8b7d37e1af2de3ea8103118cab19ee8` and `5f23aa290ecf87a0eda0e6485c44f9ac9f324c3c7a73621aaecb51a9b2b5d466`.
3. `IssueLedger` retains these exact issue identities; controller allows repair because AMBIGUOUS_ANSWER is eligible and a repairer exists.
4. `StageExecutor.StageRepAdapter` forwards original issues and durable repair intent to the SectionRunner callback. `enable_hybrid_repair` is effective; the actual planner attempt proves this, not just a default setting.
5. `QuestionItemRepairer` enters the Hybrid branch, resolves authority, and calls the typed `RepairPlanningCapability`. It does not choose local modification first for this issue.
6. `ProviderGateway` asks PostgreSQL for a child grant. **Parent section = `"1"`; M3 child section = `"section_1"`.** PostgreSQL exact-scope validation refuses it before transport dispatch.
7. The planner wraps the budget-authority error in `RepairJustificationError`. Runtime records `REPAIR_INFEASIBLE`, reconciles the failed parent to zero provider tokens, and falls back to generation.
8. The failed REPAIR took **0.0186 seconds**, produced **no repaired artifact**, and made **zero M3 transport calls**. V2 is Text-01 **regeneration**, not successful M3 repair.
9. V2 still fails. The controller redirects the last immutable version slot to regeneration; therefore there is no second Q5 REPAIR operation. V3 changes the topic from techniques to dates, retaining the same problematic meta-framing.

This disproves the prior report's “no eligible semantic/adversarial repair required” explanation and its count of two Q5 repair cycles. There was **one failed Q5 repair operation**, followed by two regenerations.

Corrective candidate preserves the exact parent's section ID for both M3 planning and constrained Text-01 generation. M3 is still a typed diagnostic planner, Text-01 still generates content, claim references remain immutable, and neither planner nor transport directly changes an answer key. The new exact-scope transport test passes. **Wider repair suites fail**, however, because several older doubles expect allocation aliases rather than canonical artifact IDs; this remains a blocking compatibility gate, not waived as “just tests.”

## 5. Token reservation forensics

### Authoritative profile and scopes

Persisted profile:

```text
profileVersion: phase13-production-v1
profileSource: deploy/envs/loop-caps.env
SHA256: ecc23288055c8b9719de9942316e43021d54c7d5fa4c32e658ae6632e702fd9b
benchmarkMode / benchmarkMonetaryCapMode: LIMITED / LIMITED
```

| Scope / authority | Tokens | Calls | Wall seconds | Meaning |
|---|---:|---:|---:|---|
| ReadingPaperWorker persisted standalone run | **1,200,000** | **250** | **2500** | Actual paper/run authority |
| PostgreSQL section `1` | **380,000** | **75** | **900** | Durable allocation (wall minimum applies) |
| PostgreSQL `passage_1` | 80,000 | 10 | 400 | Passage allocation |
| PostgreSQL `questions_1` | 200,000 | 50 | 400 | Questions allocation |
| PostgreSQL `solver_1` | 50,000 | 6 | 150 | Separate allocation; not the Q5 failure |
| PostgreSQL `review_1` | 50,000 | 6 | 150 | Separate allocation |
| BoundedLoopRuntime **per artifact**, restored from persisted profile | **60,000** | **15** | **300** | Actual failing Q5 local cap |
| Worker unified wire policy | section 100,000 / run 300,000 | separate pinned policy | section 900 / run 2700 | Not substituted for persisted profile by StageExecutor |
| Benchmark child profile | 60,000 | 15 | 300 | Not authority for this standalone run |
| Benchmark section profile | 20,000 | 5 | 100 | Not selected |

Applicable operation limits:

- Generate reservation **15,000**; repair reservation **15,000**.
- Evaluate profile reservation **10,000**, but expensive StageExecutor adapter estimate limits each applicable reservation to **4,000**. Deterministic adapters reserve **0**.
- Passage reservation configured **18,000**; StageExecutor historically selected the generic generate reservation (15,000). Historical passage provider reservation was **16,726**, standalone, actual **9,178**. This reservation-selector discrepancy is documented, not widened here.
- Operation wall reservation **60s**; evaluator semantic timeout **30s**; evaluator stage timeout **60s**; repair timeout **30s**; repair max response tokens **3000**; evaluator max **4000**; configured passage generate max **2500**. Some unified content requests independently specify their output maxima (passage 4096; question 2048); these are not the local hard cap.

`ProviderGateway` obtains conservative prompt-plus-output reservations and reconciles real usage to PostgreSQL. The local loop and PostgreSQL are distinct scopes. **60,789 whole-run provider tokens may legitimately exceed a 60,000 per-artifact cap**; total Q5 provider usage was only **19,973**.

### Exact Q5 arithmetic at failure

| Event | Local tokens before | Reservation | Local tokens after completion | Q5 provider tokens accumulated |
|---|---:|---:|---:|---:|
| Generate V1 | 0 | 15,000 | **15,000** (not reconciled locally) | 2,442 |
| V1 structure callback dispatches solver + adversary early | 15,000 | 0 for structure | 15,000 | **6,624** |
| V1 blind evaluation adapter consumes cached result | 15,000 | 4,000 | 15,000 (4,000 removed; result usage null) | 6,624 |
| Failed REPAIR for V2 | 15,000 | 15,000 | **30,000** (zero-usage durable reconciliation did not refund local reservation) | 6,624 |
| Generate V2 | 30,000 | 15,000 | **45,000** | 9,073 |
| V2 structure callback solver + adversary | 45,000 | 0 for structure | 45,000 | **13,256** |
| V2 blind evaluation adapter | 45,000 | 4,000 | 45,000 | 13,256 |
| Generate V3, final-slot regeneration | 45,000 | 15,000 | **60,000** | 15,721 |
| V3 structure callback solver + adversary | 60,000 | 0 for structure | 60,000 | **19,973** |
| V3 blind evaluation reservation | **60,000** | **4,000 requested** | **REJECTED**: 64,000 > 60,000 | 19,973 |

Final ledger message: `Budget exhausted: next reservation (4000) exceeds token cap (remaining: 0 of 60000)`.

Actual provider reservations / reconciliations:

| V | Generate reserved → used | Solver reserved → used | Adversary reserved → used | Version used total | Whole-run used before version |
|---|---|---|---|---:|---:|
| 1 | 5759 → 2442 | 7369 → 1923 | 7504 → 2259 | **6624** | **40816** |
| 2 | 5759 → 2449 | 7375 → 1923 | 7510 → 2260 | **6632** | **47440** |
| 3 | 5759 → 2465 | 7368 → 1918 | 7503 → 2334 | **6717** | **54072** |

At the final rejected reservation: whole-run provider use **60,789**; run-token headroom **1,139,211** before prospective provider reservations; Q5 actual-token headroom relative to its local cap **40,027**; erroneous local headroom **0**. No rejected 4,000-token operation was granted. All 100 persisted operations were COMPLETED, with **no outstanding RESERVED or UNKNOWN_OUTCOME operations**. Failed M3 grant created no paid operation to refund.

### Root cause and accounting correction candidate

Production generation/solver/adversary callbacks used the outer RunContext and emitted standalone provider operations, with no parentOperationId. Draft reconciliation looked only for children, found none, saved parent tokens=0 but left its local 15,000 reservation charged. Failed-repair reconciliation similarly saved zero in PostgreSQL without adjusting the local tracker. Evaluator callbacks did the opposite: all paid reviews ran during the first zero-token structure adapter; later expensive adapters consumed cached results and reconciled zero.

There is **no evidence of provider double billing** in this run: 25 unique provider calls total 60,789 tokens; all non-provider operations used zero. The defect is local phantom reservations plus locally omitted standalone provider usage, not repeated paid dispatch of identical cached evaluations. V1–V3 have different student statements and legitimately distinct operation IDs.

The corrective candidate rebuilds local provider-backed token usage from durable per-artifact operation trees, counts aggregate parents/children once, retains unknown/unreconciled reservations, and reuses this accounting on restart and after callbacks. New tests rebuild historical Q5 from 60,000 to **19,973**, preserve an added 7,500-token unknown reservation, and do not double-count a 500-token aggregate/child pair. Durable records and grant authority are never rewritten or bypassed.

StageExecutor now supports selective evaluator callbacks. Production SectionRunner returns cheap checks without invoking solving until the expensive evaluator has its own reservation. Its deterministic fail-closed path still blocks invalid items before provider calls. Six mandatory evaluator IDs and hash/dependency binding remain required. Generic legacy callbacks retain their batched contract; broader adapter-contract tests remain necessary before certification.

### Can the existing policy support 13 questions?

Observed generation+solver+adversary totals over eight question versions: **51,611 tokens** (60,789 minus passage 9,178), average **6,451.375/version**. A no-repair 13-question estimate is **93,045.875 tokens including passage**, **40 provider calls**, roughly **440 seconds** scaling the historical job's 275.19-second elapsed time over 25 calls to 40 calls. This fits the durable 380k/75-call/900s section policy, and only narrowly fits the separate 100k wire-policy token ceiling if that ceiling were the selected authority. This is an estimate, not a successful 13-question proof; it does not price or assume M3 recovery success.

Thus the observed provider cost is **not intrinsically incompatible with the approved durable budgets**. The historical cap failure is not evidence that a paper cap must be raised. Nevertheless **BUDGET_READINESS: BLOCKED**: accounting/reservation regressions and wider repair compatibility remain unresolved in the mandatory gate. There is no legitimate LIVE authorization from a projection alone. A future decision must specify the intended immutable profile/section/wire hierarchy and authorize an evidence-backed reservation contract; it must not silently expand caps or enable unlimited mode. No cap expansion is requested or implemented by this deliverable.

## 6. Minimal corrective candidate and test gate

Files changed:

- `app/reading_evaluation.py`: bibliographic discriminator exclusion; meta-coverage TFNG semantic blocker.
- `app/solvers/tfng.py`: narrow meta-framing and adversarial proposition checks.
- `app/solvers/adversary.py`, `app/evaluators/solver.py`: student-visible proposition context and unsupported-alternative rejection.
- `app/solvers/solver.py`: exact offsets after quote localization.
- `app/generators/question/prompts.py`: factual TFNG generation constraints, no distribution changes.
- `app/repair/question.py`, `app/generators/question/generator.py`: exact parent section identity; canonical planner artifact ID.
- `app/loop/runtime.py`: provider-backed local reconciliation and unknown-safe operation-tree accounting.
- `app/stage_executor.py`, `app/section_runner.py`: defer paid solving until its evaluator reservation.

No changes to Blueprint generation/bindings, evaluator count, PostgreSQL schema/idempotency, publication, caps, generator/planner model roles, or runtime version/repair limits.

Test-first evidence: initial Q5 corrective file **19 failures** against starting code; targeted accounting mutation rerun also failed against original runtime. After candidate changes, **27/27 new cases pass**. This does not override the red unified gate.

| Mandatory area | Evidence / result |
|---|---|
| Q5 V1–V3 parser/evaluator replay | PASS as offline reproduction, nine candidates; no invented blind output for positives |
| Bound-Claim-11 TRUE/FALSE selection | New parametrized tests PASS |
| NG entailment/contradiction boundary | Unsupported FALSE vs absent factual predicate rejected; malformed meta NG keys blocked; **historical wider lineage test FAIL** |
| Unsupported adversary evidence | Exact historical adversary payloads rejected by new production parser context |
| Genuine ambiguity | Conflicting 600/700 BCE evidence remains blocking |
| Eligible typed M3 path | Exact-section mocked transport test PASS; **broader repair compatibility suites FAIL** |
| Ineligible issues / Hybrid disabled | Existing production-integration suite passes in relevant gate |
| Constraints reach Text-01; no direct key edit | New typed-transport and existing production-integration tests PASS |
| Reservation/reconciliation/restart | New historical accounting tests PASS; **R01/R03 cap tests FAIL** |
| Q1 local evidence and historical Q2/Q4/Q5/Q10 provenance | Existing focused provenance tests pass; wrong claims/non-verbatim completion remain rejected |
| No duplicate dispatch/billing on replay | New accepted-stage replay test and existing production replay coverage pass |
| StageExecutor → BoundedLoopRuntime | New accounting/selective-evaluation and existing production-shaped integration tests pass, not an all-green unified gate |

Eight additional root-directory failures relative to matched starting HEAD:

1. `test_tfng_semantic_contract_and_m3_repair.py::test_01_reproduce_q4_v1_v2_v3_lineage_and_calibration` — historical meta-coverage statement expected clean acceptance, now blocked.
2. `test_passage_blueprint_grounding_gate.py::test_11_existing_hybrid_m3_repair_path_continues_for_genuine_semantic_failures`.
3. `test_hybrid_offline_replays.py::test_replay_ambiguous_answer_repaired_via_m3_plan`.
4. Same file: `test_replay_duplicate_prompt_repaired_via_regenerate_distinct`.
5. Same file: `test_replay_not_given_semantic_disagreement_repaired_via_m3`.
6. Same file: `test_comparative_baseline_blind_repair_vs_m3_assisted_repair`.
7. `test_hybrid_question_repair_integration.py::test_semantic_adversary_issue_invokes_m3_and_regenerates_with_text01`.
8. Same file: `test_m3_planning_failure_fails_closed_without_uncontrolled_retries`.

Items 2–8 encounter old allocation doubles rejecting canonical planner artifact IDs (`art_q_slot_*`); item 8 consequently does not reach its intended plan-contract assertion. These are **not waived** and no further implementation/test adaptation was made after the stop gate.

Five failures also reproduced at starting HEAD with matching snapshots/env:

- R01 retry-memory, three-attempts-memory and reasoning-memory scenarios in `test_r01_prompt_retry_admission_and_unknown_replay`.
- `test_r03_configured_token_cap_bounds_admission`.
- `test_r03_call_cap_admission_uses_run_profile`.

The full-suite 120 failures are not all attributed to this patch; only the bounded matched baseline above was compared. Complete failure names are in the results JSON. Full-suite TCP was denied via a temporary `sitecustomize.py` guard; real-PostgreSQL durability tests were excluded to preserve existing databases, not represented as passing. No .NET/exam tests were run, and the existing exam/generation services were not restarted.

## 7. Historical Q1–Q13 evidence and usage

This table describes **the historical final LIVE**, not a new run or a replayed acceptance.

| Q | Type | Claim | Historical accepted version | Evaluator evidence / outcome |
|---:|---|---:|---:|---|
| 1 | TFNG | 2 | 1 | TRUE; only a few adequately preserved/documented/dated smelting sites; exact span 193..407; all six persisted PASS |
| 2 | TFNG | 12 | 1 | TRUE; Jos Plateau around 600 BCE; exact span 5517..5658; all six persisted PASS |
| 3 | TFNG | 1 | 2 | NG; advanced furnace structures; topical context 0..192; all six persisted PASS on V2; failed M3 grant followed by Text-01 regeneration, not M3 recovery |
| 4 | TFNG | 9 | 1 | TRUE; limited firmly established chronologies; exact span 5660..5797; all six persisted PASS |
| 5 | TFNG | 11 | — | V1/V2 AMBIGUOUS_ANSWER; V3 final blind operation reservation rejected; no accepted head |
| 6 | TABLE_COMPLETION | 6 | — | NOT_REACHED |
| 7 | TABLE_COMPLETION | 14 | — | NOT_REACHED |
| 8 | TABLE_COMPLETION | 16 | — | NOT_REACHED |
| 9 | TABLE_COMPLETION | 5 | — | NOT_REACHED |
| 10 | FLOW_CHART | 3 | — | NOT_REACHED; separate historical non-verbatim regression remains blocked |
| 11 | FLOW_CHART | 13 | — | NOT_REACHED |
| 12 | FLOW_CHART | 7 | — | NOT_REACHED |
| 13 | FLOW_CHART | 2 | — | NOT_REACHED |

Historical passage: accepted V1, 858 words; no section/exam commit. Eight accepted artifact heads (source, evidence, blueprint, passage, Q1–Q4). Accepted historical head status is not a new certification of all historical TFNG phrasing.

| Historical job | Text-01 calls | M3 calls | Prompt | Completion | Provider tokens | Estimated USD |
|---|---:|---:|---:|---:|---:|---:|
| Final LIVE `2250820f-...` | **25** | **0** | **53,252** | **7,537** | **60,789** | **0.0189411** |
| Preliminary `8b291275-...` | **4** | **0** | **11,827** | **1,498** | **13,325** | **0.0040132** |

Rates used are the saved snapshot's Text-01 estimates: $0.20/M prompt, $1.10/M completion. These are **not invoices**; actual billed cost is unavailable. M3 had no completed billable calls. No new LIVE provider usage or cost exists for this corrective task. The final job's first unrecovered failure is Q5 `TOKEN_CAP`; prior evaluator findings and failed repair are preserved, not hidden by that terminal reason.

## 8. Preliminary job and marker reconciliation

The separate `8b291275-3e39-4ec0-96fc-899f8dd43d54` snapshot is a real **preliminary paid execution**, created 13:25:23 UTC, terminal Failed 13:26:43 UTC, implementation `242cfda72965aa90529ba30c508073b9c1d8e49f`. It accepted passage but zero questions. Q1 terminated `EVALUATOR_ERROR`: blind-evaluator error output omitted exact dependency refs; the durable error reports expected passage/blueprint refs but received `[]`. It is not the reported final 13-question LIVE, and its four calls/cost must not be erased or merged invisibly into the final job's 25 calls.

The later final job was created 13:38:09 UTC and failed 13:42:44 UTC under `2da48d0...`. PostgreSQL read-only reconciliation confirms both job rows Failed and **zero Pending/Running jobs**. The persistent submission marker is TERMINAL and points to `2250820f-...`; it was not reset. The final run row itself still says RUNNING despite its failed job and failed Q5 cursor; this is a saved run/job status inconsistency, not authorization to resume it. No historical job was relaunched and no second/new job was submitted.

## 9. Mandatory verdict — current corrective execution only

Historical 4/13 and historical costs above must not be read as a new LIVE result. All LIVE fields below are NOT_RUN because the mandatory offline gate failed. Implementation identity is the **gated corrective candidate commit**, not a LIVE-frozen/approved implementation (resolve from this report's implementation commit in git; no self-referential report hash is claimed).

```text
LANGFENS — Q5 CORRECTIVE GATE

Q5_CANDIDATE_SELECTION: PASS_OFFLINE (positive candidates preserved; no paid independent replay for them)
ADVERSARY_AMBIGUITY_VALIDITY: HISTORICAL_ALTERNATIVES_UNSUPPORTED; META_KEYS_STILL_BLOCKED
M3_ROUTING: DEFECT_REPRODUCED; TARGETED_PATH_PASS; UNIFIED_COMPATIBILITY_BLOCKED
TOKEN_ACCOUNTING: PHANTOM_RESERVATIONS_PROVEN; TARGETED_RECONCILIATION_PASS; CAP_GATE_BLOCKED
BUDGET_READINESS: BLOCKED
OFFLINE_REGRESSION: FAIL (13 failed / 270 passed / 16 skipped; full suite also red)
RUNTIME_PREFLIGHT: NOT_RUN

IMPLEMENTATION_SHA: 043b97d92665fe5860666e8f0e2b1c8e9cf8a541
LIVE_JOB_ID: NOT_RUN
RUN_ID: NOT_RUN

PASSAGE_STATUS: NOT_RUN
QUESTIONS_ACCEPTED: NOT_RUN
QUESTIONS_REJECTED: NOT_RUN
QUESTIONS_NOT_REACHED: NOT_RUN
SECTION_COMMITTED: NOT_RUN

TEXT01_CALLS: NOT_RUN
M3_CALLS: NOT_RUN
M3_RECOVERY_OUTCOME: NOT_RUN
PROVIDER_TOKENS: NOT_RUN
ESTIMATED_COST_USD: NOT_RUN

FIRST_FAILURE: MANDATORY_OFFLINE_REGRESSION_GATE
ROOT_CAUSE: BIBLIOGRAPHIC_ENTITY_CONFLICT; TOPIC_ONLY_ADVERSARY_EVIDENCE; M3_PARENT_SCOPE_MISMATCH; LOCAL_PHANTOM_RESERVATIONS
FINAL_VERDICT: BLOCKED_NO_LIVE; CORRECTIVE_CANDIDATE_NOT_RELEASE_READY
```
