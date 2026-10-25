# Section 1 offline blocker closure — NOT_RELEASE_READY

**Decision: BLOCKED. No LIVE submission authorized or performed.**

- Base: `666cf72452d4bc3ea75a0a4a489ae7411a281000`, branch `autonomous-generation`.
- Tested implementation: **`63886d8341d396ed539709f8b1a6dea44dc125bf`**.
- This report and its manifests are a subsequent evidence-only commit; the implementation SHA above identifies the tested source.
- Historical real job remains **4/13**, no committed Section/exam. Do not resume it based on these results.
- Real MiniMax/provider calls, tokens and cost this session: **0 / 0 / $0**. No real generation endpoint submission, stack startup, deployment or publication.

Evidence:
- [`section1_offline_closure_verification.json`](../../reports/section1_offline_closure_verification.json): source hashes, exact suite counts, every failure/skip name, failure excerpts, baseline comparison and evidence hashes.
- [`section1_offline_closure_acceptance.json`](../../reports/section1_offline_closure_acceptance.json): thirteen head references/hashes, per-head evaluator results, stimuli and reconstructed budgets.

The checkout already contained an uncommitted corrective candidate when this session started. It was preserved, reviewed and independently verified, then extended with the newly reproduced projection, malformed-table, compatibility and retry-clock corrections. Historical investigation was not repeated.

## Corrections and proof

All paths below are under `services/generation-service/`, except the PostgreSQL contracts.

| Root cause | Production correction | Behavioral proof |
|---|---|---|
| Stage callbacks lost their authorized operation parent; SectionRunner supplied outer context | `app/stage_executor.py`, `app/section_runner.py`: forward callback-scoped GENERATE/EVALUATE/REPAIR context; solver/adversary consume it | `test_section1_blocker_closure.py::test_stage_callbacks_receive_own_authorized_parent_not_outer_context`; target 13Q test checks every physical operation's parent type and reference |
| Blind adapter selected historical 4k instead of saved profile's 10k | `app/stage_executor.py`: select existing `evaluate_token_reservation` | Same callback regression; `test_operation_parent_authority.py` historical 7,369/7,504 reservations; real PostgreSQL 10k and rejecting-4k contracts |
| Sequential child requests independently requested full parent wall | `app/providers/gateway.py`: bound each new child by remaining durable parent allocation and transport/queue deadline | Historical sequential solver/adversary and M3/Text-01 PostgreSQL contracts; finite gateway tests; timeout/UNKNOWN_OUTCOME regression |
| Deadline clamping changed the *derived start clock*, falsely preventing a known-format-error retry under a short grant | `app/providers/gateway.py`: retain original request start timestamp; support synchronous durable-client readers too | New retry-clock regression was observed red with `No remaining time for a provider attempt`, then green; existing passage/question/blind-composition tests also pass |
| Reconstruction counted wrappers instead of physical descendants; shared summary work could escape ownership | `app/loop/runtime.py`, `app/section_runner.py`: reconstruct physical calls once, tree-based wall/tokens; first requesting question owns shared summary transport | Shared-summary descendant reconstruction regression; all 13 question cursors show **3 calls / 5,182 tokens** |
| Completed known repair failure lacked an artifact/result after crash before fallback cursor | `app/loop/runtime.py`: persist/replay typed `CAPABILITY_FAILURE_V1`, bound to operation, request hash, artifact and target version | Crash-after-reconciliation regression accepts fallback V2 with exactly one repair invocation/grant |
| Candidate pool and repair discarded table/flow stimulus | `app/generators/question/{context,generator}.py`, `app/repair/question.py`: preserve supplied fields, replace them on new immutable versions, preserve omitted fields | Pool round trips and repair replace/preserve tests, including `stepIndex=0`; prior artifact remains unchanged |
| Canonical projection omitted row/column headers and flow index | `app/reading_evaluation.py`: include all fields in canonical core/digest | New table/flow projection mutation regressions: every stimulus-field change changes digest |
| A table item with no table stimulus could pass | `app/reading_evaluation.py`: mandatory structural failure without table context or both row/column headers | Real SectionRunner negative fixture cannot finalize; historical invalid golden table now explicitly fails |
| Citation-only Claim 6 scored quantitative suitability from publication years | `app/blueprint/claim_binding.py`: conservative citation/editorial syntax gate before suitability/binding | Saved Q7 text rejected; new Q7 binding chooses factual Claim 14; citation-only graph fails closed; old slot unchanged |

No global caps, provider model roles, required evaluator list, claim-local grounding rules, answer-span checks or immutable historical artifacts were relaxed. Unknown/estimated usage is not converted into a zero-token refund.

### Honest fixture updates

The test transport previously detected “summary” inside a table JSON example and returned a sentence/summary candidate for a table request. `tests/unified/mock_fixtures.py` now reads the explicit requested-family directive. Tests invoking standalone repair now grant the parent they reference; production parent validation was not removed.

The original 19-family golden manifest remains unchanged. A separate `table_completion_stimulus_v2.json` adds the missing table, keeping its passage, evidence and answer. The golden suite exercises v2 **and** verifies rejection of the historical stimulus-free item. No test was deleted, skipped, xfailed or weakened to manufacture green results.

## Budget reconciliation

Historical Q5 facts are retained from the saved forensic report; the new arithmetic below is separately tested, not a new Q5 provider replay.

| Boundary | Before | Verified offline result |
|---|---|---|
| Historical Q5 local tokens | 60,000 wrapper charges vs 19,973 actual | Parent/child authority and descendant accounting corrected; no claim of rerunning the historical paid job |
| Solver admission | 4,000 parent rejects 7,369 reservation | Existing **10,000** profile authority admits it; 4k still rejects before transport |
| Solver completion | Reservation 7,369 | Reported 1,923; unused **5,446** can fund subsequent work |
| Adversary admission | Cannot fit old 4k authority | 1,923 + 7,504 = **9,427**, leaving **573** parent headroom |
| Completed evaluation | Wrapper/child accounting inconsistent | **4,182 tokens / 2 physical calls / 11 wall seconds** in PostgreSQL; no extra wrapper token charge |
| M3 → Text-01 | 5 used + fresh 60 requested exceeds parent 60 | Fresh 60 rejected **422**; remaining **55** admitted. PostgreSQL example finishes at **865 tokens / 2 calls / 11 seconds** |
| Estimated/unknown usage | Unsafe refund would permit next child | Next child remains rejected; timeout preserves 7,369 and UNKNOWN_OUTCOME across restart; no redispatch |
| Terminal replay | Risk of duplicate settlement | Identical reconciliation is idempotent; conflicting terminal usage rejects **409** |

Target fixture totals: **40 scripted transports**, reservation sum over time **273,975** (not concurrent outstanding allocation), **68,366 reported mock tokens**. Thirteen question cursors each reconstruct **5,182 tokens / 3 physical calls**. No operations remain RESERVED/UNKNOWN_OUTCOME in the positive fixture. Real paid usage is zero.

## Content and offline Section 1 acceptance

The new fixture uses the actual requested family allocation:

- **Q1–Q5:** TRUE_FALSE_NOT_GIVEN, including TRUE, FALSE and factual NOT_GIVEN propositions.
- **Q6–Q9:** TABLE_COMPLETION with table context, row and column headers.
- **Q10–Q13:** FLOW_CHART with full steps and step index.

It executes real source/evidence/blueprint stages, SectionRunner, StageExecutor, gateway, parsers, mandatory validators, cursor/operation accounting and Section assembly. Transport responses are deterministic. Blind answers are authored independently of the generated-key lookup; no expected key is serialized to the solver.

Result: **13/13 in-memory accepted question heads**, **78/78 mandatory question evaluator PASS results**, accepted Section V1. All stimuli survive both question heads and Section payload. Re-entering accepted orchestration makes **zero additional transports**. Negative budget, missing evidence, malformed table and independent-disagreement cases cannot finalize. Separate integration regressions cover M3 repair, immutable replacement and crash/unknown-outcome behavior.

**Important limitation:** this is **not** a complete PostgreSQL-backed 13Q acceptance test. Seven PostgreSQL grant/reconciliation cases are separate from the in-memory thirteen-head fixture. The mandatory production-equivalent 13Q durability gate remains **NOT SATISFIED**. No provider-quality or LIVE-success claim follows from mocked 13/13.

Q7's historical citation-only claim is no longer eligible before new binding. Historical Q1 claim-locality, Q5 semantic/adversary/budget, Q9 local-answer grounding and Q10 flow/verbatim defects retain passing regressions. Both 19-family suites pass in the Python 3.12 targeted gate.

## Exact verification and baseline comparison

| Gate | Passed | Failed | Skipped / unavailable |
|---|---:|---:|---:|
| Python **3.12.15** targeted production/offline gate | **293** | **0** | **0** |
| Python 3.12 historical Q9/local-answer supplement, disjoint from above | **13** | **0** | **0** |
| Python **3.14.8**, final full safe suite | **1,905** | **98** | **24** |
| Clean `666cf724`, matched Python 3.14 safe suite | **1,861** | **98** | **24** |
| .NET 10 selected contracts, including real disposable PostgreSQL | **48** | **0** | **0** |
| Of those .NET cases: PostgreSQL operation authority | **7** | **0** | **0** |
| Of those .NET cases: cap-profile contracts | **41** | **0** | **0** |
| Python 3.12 full suite | — | — | **12 collection errors: missing offline jsonschema/rpds dependencies** |

The final full Python run adds **44 passing tests**, with **the same 98 failing names and the same 24 skipped names** as the matched baseline. There is no newly failing shared test. This does not turn the 98 failures into passes or prove their expectations are obsolete.

The historical **122 failed / 1,837 passed / 24 skipped** result was **not reproduced exactly**. The complete historical environment/run identity/asset state cannot be reconstructed from its manifest. A fresh clean-baseline comparison was performed instead, using identical current settings, fixtures and SHA256(nodeid)-seeded UUID streams. Baseline Git provenance reads used repository object history against the isolated baseline work tree; the preliminary archive-only provenance discrepancy was corrected before the final comparison.

Current failure triage: **38 source-reviewed outdated-contract/fixture cases**, **19 environment-limited cases**, and **41 pre-existing failures still requiring product-versus-contract adjudication**. None is waived. Exact names and concise assertion/exception evidence are in the JSON manifest. Remaining examples include runtime cap expectations, missing historical snapshot paths, incomplete StageExecutor persistence doubles, retired endpoint tests, uncertain-retry contracts, semantic/research calibration expectations and claim-binding-sensitive correctness fixtures.

Python 3.12 and 3.14 pass the exercised targeted behavior; **full cross-version equivalence is not established**. The real-PostgreSQL Python module was explicitly excluded because its auto-discovery/autouse fixtures are unsafe against shared databases. Optional PostgreSQL cases remain reported skipped under the guard, not counted as tested. .NET was run only with the inspected filter; never the destructive full project.

Offline safeguards: committed TCP-denying test guard; Docker/psql/dotnet probes disabled inside broad Python suites; cached Python 3.12 image with `--network none --pull=never`; explicit isolated PostgreSQL DSN constrained to `127.0.0.1:55449/section1_closure`. Shared/dev/production databases were not reset or queried. Build succeeds with existing NuGet security-advisory warnings.

## Remaining mandatory blockers and decision

1. **Full deterministic regression is red:** 98 failures remain; 41 still need contract/product adjudication. Historical count reproduction is incomplete.
2. **Full Python 3.12 gate unavailable:** supply compatible offline jsonschema/rpds dependencies, then execute the complete suite.
3. **PostgreSQL-backed target 13Q finalization has not run.** In-memory heads plus separate grant tests are not equivalent evidence.
4. **General typed UNKNOWN_OUTCOME/orphan-wrapper recovery remains incomplete.** Known failed-repair recovery is fixed, but uncertain children still require explicit reconciliation and parent disposition. Do not reset cursors, synthesize missing artifacts or replay uncertain paid work.
5. Full PostgreSQL wrapper-crash/recovery and real provider/queue/overhead timing matrices remain unverified. Remaining-wall checks establish durable allocation sharing, not provider reliability.
6. Claim eligibility is a conservative syntax gate, not general semantic verification of every possible non-factual/bibliographic fragment.
7. Existing dependency security advisories remain. No deployment or dependency campaign is authorized here.

Submission marker SHA-256 remains **`d5c402709df3ca84714717c65dd50922b5d39e222080ad520b80bb3b7ecaa532`**. Historical reports/snapshots and the original golden fixture were preserved; the test-generated canonical 40Q bundle was restored to its tracked bytes.

**Final verdict: BLOCKED / NOT_RELEASE_READY.** No `READY_FOR_AUTHORIZED_LIVE` declaration, LIVE attempt, publication or uncertain paid-operation replay is authorized by this work.
