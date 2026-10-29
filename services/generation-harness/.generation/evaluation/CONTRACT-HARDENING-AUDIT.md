# Corrected canonical contract audit and offline pilot decision

## Decision

**NO-GO for another gated offline pilot in this workspace.** Deterministic domain development/regression testing can continue offline; this is not authorization for live inference, student delivery, publication or production. Semantic pilot quality is **INSUFFICIENT_EVIDENCE**.

The remaining frozen-boundary failure is the **pre-existing**, untouched diff in `services/attempt-service/Features/Helpers/Grader.cs` and `services/attempt-service.Tests/Helpers/GraderCleanupTests.cs`. No automatic waiver, commit, reset or consumer patch was made. Separately, actual-.NET explanation leakage, insufficient service/role authorization, missing actual frontend round-trip evidence and incomplete mutation-level repair admission prevent a broader compatibility claim. Production readiness is **not declared**.

## Provenance and corrected conclusions

Inputs: unchanged canonical schema **1.0.0**, SHA-256 `6345070a86b3271bc2ae348a0afcb33c928b42a1b55346809cb566a21c6478c5`; current repository source; the available v2 proposal and bounded historical terminal capture. No standalone file titled “Canonical IELTS Contract Master Audit” was found in the inspected checkout. The proposal's historical findings/baselines are references to recheck, not execution instructions or current-runtime proof. No prior provider session was resumed or modified.

### 1. Matching Information reuse — corrected

Official IELTS Academic format instructions say that some paragraphs **may** be used more than once and that instructions identify permission. They do not require a repeated key in every exercise. Distinct keys with reuse permission are valid. Repeated keys without appropriate permission are diagnosed; headings/endings retain their own non-reuse rules. New canonical rules/test cases cover both permission without repetition and forbidden repetition.

### 2. Multi-answer MCQ marks — narrow proven statement, not a universal algorithm

Official Reading scoring says each correct answer receives one mark. Its published multi-answer example key pairs **1&2** and **3&4**, each “IN EITHER ORDER”. This supports multiple numbered answers/marks in that example. It does **not** establish an unrestricted rule that any electronic K-of-N selection containing 2/3 correct choices earns exactly two marks, regardless of extras, duplicates or selection-count violations. Withdraw the earlier unconditional “one mark per letter”/“2 of 3 always earns 2” assertion.

Current Langfens `MultipleChoiceGrader` is proven source/fixture behavior: exact UUID-set equality; partial set earns zero of the Question's one point. That is a platform scoring contract, not automatically a bug in every platform reference fixture. It cannot represent independently scored numbered multi-answer marks under the selected strict profile, so generation is **BLOCKED**, not silently converted. Official URLs, short excerpts and downloaded-byte hashes are in [official-ielts-recheck.json](evidence/official-ielts-recheck.json). These were read-only document GETs, not model/service calls; no tests fetch the web.

### 3. FLOW_CHART — no fabricated ingestion defect

The literal means **platform ordering**, with slug `orderCorrects` and no completion blank keys. Admin rejection of blank keys is consistent with that contract. Standard IELTS flow-chart **blank completion** is a different unsupported capability; changing semantics needs deliberate versioning/consumer authorization. No automatic relabeling to sentence completion was added.

The existing dirty .NET parser accepts lowercase `steps`/`labels`; the committed legacy JavaScript oracle still models case-sensitive `Steps`/`Labels`. Actual .NET and legacy JS were compared explicitly: this divergence is **PRE_EXISTING_DIRTY_CONSUMER_DIFF**, not a newly fixed consumer or parity PASS. Canonical answers use arrays. Flow normalization preserves word boundaries (`a-b` becomes `a b`, not `ab`); tests reject the earlier false-collision assumption.

### 4. ReadingSeeder startup/identity — source-confirmed risk, not a live DB finding

`services/exam-service/Program.cs` invokes `ReadingSeeder.SeedReadingExamAsync` at startup after migration. Its “idempotent/skipped when slug present” comment is contradicted by the implementation: find slug, delete existing exam, save, then recreate and save. `ExamDbContext` configures cascade deletes down to options. Fixed exam/section IDs and deterministic Question IDs do not stabilize options: option constructors repeatedly use `Guid.NewGuid()`.

Consequences supported by source: rerunning this seeder changes option identity; persisted references/saved selections can become stale; deletion and recreation are separate saves and may leave a gap if recreation fails. The existing helper determinism unit tests do not prove stable persisted option identities. No startup, seed, migration, query, schema cleanup or production DB operation was executed.

The source reference is 5 Sections/25 Questions/18 distinct types; SUMMARY_COMPLETION is absent despite the title/log claiming 19. These are **reference-fixture coverage/content defects**, not a requirement that this diagnostic fixture become a 3-section/40-mark Academic paper. Examples of source content issues remain: Q1's NOT-used stem contradicts its keyed list of materials used in the passage; Q2 keys True for wood-pulp invention despite the source passage describing different Cai Lun fibres and later wood-pulp manufacture. These are not claims about inaccessible current persisted private keys. Missing summary coverage is not a missing backend type.

### 5. Independent security blockers — retained with corrected authorization language

- **Student explanation leakage: CONFIRMED.** Actual `GrpcSnapshotSanitizer.Sanitize` leaves a private explanation sentinel in a student proto while removing accepted texts, without mutating the original. The new pure .NET fixture reproduces this. HTTP internal mapping also copies explanations even with `showAnswers=false`. Hiding DOM explanations is not transport redaction.
- **Authorization/isolation: source-confirmed risk.** Gateway exposes `/api/internal/{**catch-all}` without a route authorization policy, but the downstream delivery endpoint uses `.RequireAuthorization()`. Therefore “anonymous answer-key extraction through this route” was **overstated and is withdrawn**. The downstream handler accepts caller-controlled `showAnswers` with only generic authenticated access and no service/privileged-role check, making access by ordinary authenticated principals a distinct risk. gRPC has anonymous mapping/no service-key check; public network reachability is **not established** by that source fact. No live unauthorized request or key extraction was attempted.

## Implementation and per-type coverage

Only `.generation/` domain files and related harness tests were edited. Core, SDK, Subagents, frontend and backend source changes were not made. Existing consumer dirty diffs were byte-compared before/after; the canonical v1 JSON bytes were preserved.

See [IMPLEMENTATION-v1.md](../contracts/IMPLEMENTATION-v1.md) for exact interfaces. All seven original tool names remain, with additive canonical alternatives and strict legacy wire checks. Actual Draft 2020-12 definitions are executed; every normative semantic rule has a handler. Deterministic shape checks are implemented; rules requiring real passage judgment, rendered input reachability, asset licensing, UUID mapping or consumer execution explicitly return **UNVERIFIED/semantic uncertainty** rather than automatic truth. No schema-only frontend/.NET claim is made.

All rows below have positive/missing/wrong-type/foreign-key-family structural tests, deterministic or strict-profile negative semantic tests, and actual .NET correct/wrong/empty/cleared grading fixtures. “Candidate” is not verified frontend compatibility or IELTS semantic approval.

| Literal | Strict profile / principal limitation |
|---|---|
| MULTIPLE_CHOICE_SINGLE | Initial pilot candidate, one selection |
| MULTIPLE_CHOICE_MULTIPLE | BLOCKED: multiple slots, one all-or-nothing unit |
| TRUE_FALSE_NOT_GIVEN | Initial pilot candidate; fact/absence review remains unverified |
| YES_NO_NOT_GIVEN | Candidate; author-view/absence review remains unverified |
| MULTIPLE_CHOICE_SINGLE_IMAGE | Excluded by selected profile; media propagation/provenance unverified |
| SUMMARY_COMPLETION | Initial pilot candidate, exactly one explicit keyed blank |
| TABLE_COMPLETION | Candidate, one slot; real table rendering unverified |
| NOTE_COMPLETION | Candidate, one slot; note layout/reachability unverified |
| FORM_COMPLETION | Excluded by selected profile, not a universal IELTS prohibition claim |
| SENTENCE_COMPLETION | Candidate, one slot; grammar/semantics unverified |
| SHORT_ANSWER | Candidate; exactly one reachable actual input still needs consumer evidence |
| DIAGRAM_LABEL | Candidate, one slot; asset/callout alignment unverified |
| MAP_LABEL | Excluded by selected profile; no claim of missing backend literal |
| MATCHING_HEADING | BLOCKED for independent marks: v1 requires multi-target exercise |
| MATCHING_INFORMATION | Same slot conflict; reuse permission never demands repetition |
| MATCHING_FEATURES | Same slot conflict; explicit reuse policy and independent review |
| MATCHING_ENDINGS | Same slot conflict; ending reuse/grammar checks remain distinct |
| CLASSIFICATION | One-target candidate permitted; exact statement IDs, never minus one |
| FLOW_CHART | BLOCKED for Academic flow completion; valid platform ordering remains |

### Diagnostics and repairs

TypeBox errors now include JSON pointers (individual missing fields included), expected constraints, actual shapes and repair guidance without echoing private values. Permissive drafts diagnose nulls/primitives/malformed options, prototype-like type names and invalid indices without exceptions, coercion or invented keys. Canonical inputs can likewise be incomplete and receive diagnostics.

Question validation tracks consecutive `(code,path)` signatures, stops no-progress immediately, caps repair submissions at two, preserves identity/membership/type and restores native validation receipts on session resume. Nonretryable blockers cannot be repaired automatically. **This enforces validation submissions only, not all artifact mutations.** Parent/child filesystem writes, group/exam checks, ID replacement and new sessions are not yet linked to a trusted original-question artifact hash. The existing native public hooks are used; no new loop/coordinator was introduced. Tamper-proof cross-session mutation admission remains **BLOCKED**, not claimed implemented.

### Pilot and actual .NET evidence

The original VS2 fixture was not edited. An explicit synthetic adapter supplies required v1 metadata, omits legacy modelAnswers and normalizes canonical truth-label case; it does not invent keys. It retains 5 TFNG, 4 one-slot summary and 4 single MCQ Questions: **13 Questions = 13 slots = 13 scoring units = 13 intended marks**, not a complete paper.

The pure test console references actual production `AnswerValidator` and grader classes. **134 cases** across all 19 types and the 13-item pilot check correct/wrong/empty/cleared and applicable partial answers; their JavaScript comparisons agree in that bounded corpus. The separate lowercase FLOW probe records a real disagreement. The privacy probe intentionally reproduces the existing leak; its test PASS means the defect was observed, **not that privacy passed**. No actual admin endpoint/key-builder/persistence or frontend-action round trip is claimed. NuGet sources are explicitly cleared; restore uses cached packages only. Existing backend unit tests: **76 passed**, no skips; cached dependency-resolution/vulnerability warnings are pre-existing, not fixes.

## Frontend versus backend capability findings

**Frontend (read-only source audit):** current checkout is revision `2d9fe94a54e65680eca56aafbe40e691018113da` plus existing dirty changes. The selected Reading route now uses `features/exam/contract`, `useExamSession` and `QuestionPanel`, not the historical deleted mapper. Withdraw the claim that this current source necessarily fails with missing `mapApiQuestionToUi`. Current QuestionRenderer dispatches all 19 families, including ShortAnswerCard; McqCard consumes option images/alt text; matching supports keyed targets and callbacks. The old blanket media/short-input/classification/card-route failure assertions are **not current verified defects**. Actual renderability, table/summary layout, restored/cleared answers, UUID joins and action-to-.NET scoring are still **UNVERIFIED** because no frontend execution or consumer modification was performed here. Dirty-source provenance prevents equating HEAD alone with tested code.

Read-only frontend anchors (SHA-256):
- ReadingScreen.tsx: `d7709fe24dcdff1aa79ce3c5e7c18ac2f3aec909155fb7981a699aef0f19447f`
- features/exam/contract.ts: `ff49377cfab33a731dff5507eb17e5c8614dee3ed0e2a87bf5be055b1053c46c`
- QuestionRenderer.tsx: `b8fdba627bc3ba8eff3a3641af5135dad48d1857541d18257b684b79b415f35b`
- McqCard.tsx: `c2dca7659f3de971c1db1a75ec27ae2c309a0a65b683f4ad453b96f046f8c381`

**Backend/transport:** actual all-or-nothing scoring and explanation leakage remain independently demonstrated. Current proto has option media fields but lacks wordList; current admin DTO lacks WordList/GroupId. Missing raw question group_id alone does **not** prove lost grouping: the proto nests Questions in QuestionGroups. No flattened-field absence is promoted into a rendering defect without adapter evidence. New word-bank artifacts remain BLOCKED for that transport. Actual service authorization, persisted identity mapping and source seeder risks are separate from domain schema correctness.

## Historical metrics and bounded replay

Count unique `(native session ID, tool-call ID)` records. Repeated calls mean identical tool name + stable-key-order arguments. Within-session repeats and pooled structural repeats have different scopes; neither proves an actual repair or duplicate paid charge.

| Corpus | Results | Schema failures | Within-session repeats | Pooled structural repeats |
|---|---:|---:|---:|---:|
| Historical audit values quoted in proposal, raw bounded snapshot unavailable | 204 | 166 | 52 | 60 |
| New read-only snapshot of three available early child sessions | 232 | 176 | 57 | 66 |
| Eight available later-workspace session logs | 250 | 145 | 29 | 40 |
| Controlled native faux replay in this patch | 8 | 3 (2 outer-schema errors + 1 returned draft diagnostic) | 2 | 2 |

The proposal separately quoted **51 later schema errors**; that bounded historical denominator is not reconstructible as the same snapshot from the broader available later logs. Do not relabel 145 as a regression from 51 or infer savings from mismatched corpora. Hash/path/byte manifests are [contract-early-traces.json](evidence/contract-early-traces.json) and [contract-later-traces.json](evidence/contract-later-traces.json). Original session files were read only. The controlled replay deliberately contains repeated errors to prove diagnostic/termination behavior; it is not an optimized/live A/B experiment. New inference-token or monetary savings: **NOT MEASURED**.

## Verification, failure classification and gates

Reproducible final launcher receipt/logs: [contract-hardening-complete-20261029/receipt.json](evidence/contract-hardening-complete-20261029/receipt.json). Earlier attempts are retained, not overwritten. Commands run under the harness offline bootstrap; .NET uses no remote feeds/service startup.

- Root/workspace typecheck, domain typecheck, build: PASS.
- `npm test`: 160 harness tests passed; Subagents 3,491 passed / 13 skipped / 0 failed. Skips are not claimed as covered.
- Related contract/hardening/native-replay/actual-.NET tests: 42 passed.
- `node --import ./test/offline.mjs --test test/reading*.mjs`: 127 passed / 0 failed, covering VS1–VS4 plus related tests (the glob also includes the VS3 registration utility file). Retain logs/receipts; these counts are not semantic-quality claims.
- Existing .NET unit tests: 76 passed.
- Frozen backend gate: **FAIL, pre-existing dirty consumer changes**, launcher exit **2 / NO-GO**. Frozen-status and final whitespace commands are not reached after fail-fast; separately executed checks are reported separately, not fabricated as launcher PASS.
- One new integration regression was found during development: added public-spec metadata did not match the strict-blind static-result allowlist, causing two tests to fail. The metadata change was removed, not the guard weakened. Both regressions pass in subsequent runs; they are not classified as pre-existing.
- No pre-existing VS1–VS4 deterministic test failure was reproduced. Existing unverified consumer gaps and the frozen diff are not mislabeled as failing domain schemas.

### Required gates before another offline pilot

1. Owner-approved reconciliation of the two existing backend dirty files; frozen gate must actually pass. This task cannot commit/reset/patch them.
2. Explicitly settle whether the pilot requires mutation-level, cross-session question repair admission; if yes, implement/verify the remaining domain workspace gate. No ID-reset budget bypass may be counted as bounded repair evidence.
3. Freeze the three-type canonical pilot, exact schema/consumer revisions and hash-bound fixtures. Do not enable broader matching/media/regex/flow capabilities from structural PASS.
4. Preserve independent human/semantic review and uncertainty/adjudication requirements. A deterministic offline GO would still not authorize paid/live inference.
5. For student-facing or combined compatibility claims, separately authorize and verify privacy/auth fixes plus actual frontend actions/submissions/clear/restore → actual .NET grading. Source inspection or a schema receipt cannot substitute.

**Final status: domain regression evidence PASS; gated offline pilot NO-GO; semantic quality INSUFFICIENT_EVIDENCE; production readiness NOT DECLARED.**
