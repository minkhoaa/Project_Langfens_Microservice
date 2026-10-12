# Phase 15 — V2 Valid-Draft Rate Recovery: Root Causes, Fixes and Verification

Status: **IN PROGRESS** — this document is written during remediation and updated with final
campaign results. Gate G15 remains **BLOCKED**.

## 1. Starting point

Canonical campaign `camp_G15_c9750f53d6b5` (git SHA `56d060d`, pure MiniMax-Text-01, 0 Groq calls):
18 paired papers / 36 runs, **V2 valid-Draft 11/18 = 61.1%** against an approved threshold of
**>= 95%**.

On an 18-case campaign, >= 95% requires **18/18** valid Drafts (17/18 = 94.4%, which fails).

Seven V2 failures: cases **4, 8, 9, 13, 14, 16, 18**.

| Case | Seed | Failure signature |
|---|---|---|
| 4 | 101 | `Paper loop rejected paper: MAX_VERSIONS: 3 exact-target blockers` |
| 8 | 202 | slot Q20 `SCHEMA_VIOLATION: Question 20 answer cannot be empty or missing` x3 |
| 9 | 303 | `Passage generation failed in section 3: MAX_VERSIONS: 1 exact-target blockers` |
| 13 | 101 | identical to case 8 |
| 14 | 202 | identical to case 8 |
| 16 | 101 | identical to case 8 |
| 18 | 303 | identical to case 8 |

### Evidence that narrowed the diagnosis

- 5 of 6 source triples passed all three seeds; the Q20 failure is **not** source-specific.
- The same triple passes at one seed and fails at another (per-seed failures 101:3, 202:2, 303:2) —
  the failure is **stochastic model output**, not a deterministic content defect.
- Dispatch ledger for every Q20 failure: exactly three `gen_qpool_20_*` dispatches, then
  termination, with **slots Q21-Q26 never attempted**. The run died at the first blank.

## 2. Root causes and fixes

### RC-1 — Hybrid `blanks`+`candidates` payload discarded a model-supplied answer
**Classification:** implementation failure (generator).

`normalize_question_generation_payload(raw, keep_question_number=...)` deliberately preserves a
direct slot-matched candidate, but `generate_candidate_pool` then discarded the whole candidate list
whenever a `blanks` key was present:

```python
raw_candidates = [] if (isinstance(parsed, dict) and "blanks" in parsed) else (parsed.get("candidates", ...) ...)
```

The engine threw away a grounded, slot-matched answer the model had supplied.

**Fix:** retain the hybrid candidate and use it as a gated fallback, subject to the same
length / verbatim / anti-leakage / group-distinctness checks. Also fixed: `dropped_blank_reasons`
now clears entries when a repair succeeds, so the ledger no longer reports repaired blanks as
dropped. `QUESTION_PROMPT_VERSION` deliberately unchanged — no prompt contract was altered.

### RC-2 — The starvation fallback was dead code (primary Q20 defect)
**Classification:** implementation failure (loop).

When a SummaryCompletion slot produced no non-empty candidate, the fallback retried it as a plain
`SentenceCompletion` — but still passed `group_start_number=20, blank_count=7`. That widened the
prompt to "questions 20 to 26", which **invited a `blanks`-shaped group reply**, which RC-1's code
then zeroed. Probe against the real generator:

```
fallback, blanks-shaped reply     -> candidates: 0   (silent no-op)
fallback, candidates-shaped reply -> candidates: 1   ['forty-two core profiles']
```

So once a slot starved, recovery was impossible: three identical attempts, then the version cap.

**Fix:** omit `group_start_number`/`blank_count` from the fallback so it is a genuine single-cloze
request, and filter recovered answers against sibling answers already used in the same group (a
per-slot request never sees its siblings, so a recovered answer could collide with a sibling blank).

### RC-3 — No-progress was invisible to the detectors (attribution defect)
**Classification:** implementation failure (loop runtime).

Three defects compounded:
1. `StagnationDetector` keyed on whole-artifact `content_hash`, which was **reset on every
   generation**, so repeated regeneration was structurally invisible.
2. Real artifacts carry volatile fields (`tokensUsed`, `wallTimeUsedSeconds`, `candidateId`,
   `score`), so three semantically identical regenerations produced three different hashes.
3. `OscillationDetector.record_state` required the *next* state to differ
   (`hash_history[idx+1] != h_norm`), so three identical states could never satisfy it.

**Fix:** `normalized_outcome_fingerprint` strips volatile accounting fields;
`semantic_issue_identities` keys on `(code, scope, normalized message)` rather than
`Issue.fingerprint` (which binds `affected_refs` including the version, so the same defect looks
different at v1 and v2). Verified by execution: pre-fix the runtime recorded 6 distinct
fingerprints and terminated `MAX_VERSIONS`; post-fix it terminates `NO_PROGRESS` at the third
attempt.

This fixed **attribution only** — it did not rescue a paper.

### RC-4 — `max_versions` is one budget shared by generation and repair (case 9)
**Classification:** implementation failure (loop controller).

With production values (`max_versions=3`, `max_generated_versions=3`,
`max_repair_attempts_per_version=2`), a loop holding a repairer spends its budget as
**v1 generate + v2 repair + v3 repair** — so it performs exactly **one** generation and never
approaches `max_generated_versions`. Case 9's `MAX_VERSIONS: 1 exact-target blockers` is literally
all the content that section-3 passage ever produced. The paper loop appeared to get three
attempts only because its repairs were refused and fell back to regeneration.

**Fix:** in the blockers branch, when the decision would be REPAIR, the next version is the final
slot (`version + 1 >= max_versions`), and generation budget remains, redirect that single slot to
REGENERATE. A `repeat_signal` guard skips the redirect once the stagnation/oscillation detectors
report repeats, preserving correct `NO_PROGRESS` attribution. **No cap was raised** — the loop still
terminates within <= 3 versions.

### RC-6 — Pooled-candidate salvage applied answers that fail three other gates
**Classification:** implementation failure (repair). Found by owner B while re-tracing the
`SCHEMA_VIOLATION: Question N answer cannot be empty or missing` signature (cases 8, 13, 14, 16, 18).

`_try_apply_candidate` in `app/repair/question.py` substituted a member of the already-persisted
candidate pool to fill an empty answer, but gated that substitution on **verbatim grounding and word
count only**. Executed probe against the real repairer:

- a pool member whose own answer appeared in its own stem was accepted as a successful repair, and
  the very next evaluation re-flagged the same slot (`ANSWER_LEAKAGE`);
- a pool member duplicating a sibling blank's answer was accepted, violating the mutual-distinctness
  contract of a blank group.

So a "recovered" Draft was being assembled from candidates that violate anti-leakage and
group-distinctness. **The gate set was too small, not too large.**

**Fix:** added the two missing gates (self-prompt leakage, shared-stem leakage) plus sibling
distinctness to `_try_apply_candidate`. The two helpers that read siblings/stem read the payload
**per call** rather than from a pre-repair snapshot, so a blank repaired earlier in the same pass is
visible to the next one's gate. A pool with no compliant member still raises `RepairJustificationError`.
Gates strengthened, not relaxed.

### RC-7 — Strict closure compared against a stale dependency declaration (case 14)
**Classification:** implementation failure (runtime integrity check — a false positive).

Case 14's new signature, `INVALID_OUTPUT: capability returned wrong target/version/hash/parents`,
was **not** corruption. Reproduced exactly: `id_match=True, type_match=True, ver_match=True,
integrity=True, parent_match=False (art_parents=3, ctx_deps=3)` — same dependency count, different
versions. `_artifact_valid` compared the capability's `parent_refs` against `context.input_dependencies`,
which is declared **once at loop construction**; a repair that commits new versions of those
dependencies (the paper loop re-runs its question/section sub-loops, each committing its own head)
returns an artifact legitimately bound one version ahead of that snapshot.

**Fix (fail-closed, not a relaxation).** `_refresh_input_dependencies_from_res_state` +
`_deps_resyncable_only`, wired at the single fresh-draft admission site. For the resync to be reached
the artifact must still verify identity, type, version **and content hash**; its parent ids must be
**exactly** the declared set; a same-version/different-hash ref is an impossible immutable-chain
mutation and is **refused**; a regressed version is refused; only a non-stale accepted head with a
**strictly higher** version is adopted; and the artifact is then re-validated against the refreshed
deps and still fails closed on any mismatch. Two weaker drafts of the predicate were rejected during
review precisely because they accepted same-version hash mutations and trusted arbitrary `res_state`
records.

### RC-8 — The DUPLICATE_CONTENT synonym rewriter was applied to AMBIGUOUS_ANSWER
**Classification:** implementation failure (repair routing). Found live, not from artifacts.

A preflight run on the current tree (`bench_717ea80dcbf2a9d615224e01b04f6fc9`, case 1, seed 101 — a
case that **passes** in the canonical campaign) failed:

```
Question group acceptance failed: NO_PROGRESS: identical repair output     (x3 attempts)
```

`reading_paper_issues` showed the same two issues recurring on every attempt:
`AMBIGUOUS_ANSWER | QUESTION | OPEN | Question 20 prompt is ambiguous with conflicting interpretations`
(and Question 21).

`SectionRepairRouter.route_repair` classifies `AMBIGUOUS_ANSWER` as an item defect and routes it to
`ITEM_RESELECT`; `SectionSurgicalRepairer._repair_impl` then handled **every** routed item question with
`rephrase_duplicate_prompt` — a synonym-substitution rewriter written for `DUPLICATE_CONTENT`.
Ambiguity is a property of what the question *asks*, not of its vocabulary. Executed probe of the real
function shows it does not converge, it accretes filler:

```
pass 1: "In particular, researchers noted that ..."
pass 2: "Regarding this aspect, in particular, researchers noted that ..."
pass 3: "In particular, regarding this aspect, in particular, researchers noted that ..."
```

**The loop's `NO_PROGRESS` verdict was truthful and is preserved unchanged.** The defect was upstream:
the repairer was handed a defect it structurally cannot fix, and "fixing" it mutated accepted question
text for nothing. A secondary defect: an unconditional `"(revised for distinct focus)"` append forced a
version bump with no justification.

**Fix:** answer-semantics codes (`AMBIGUOUS_ANSWER`, `BAD_DISTRACTOR`, `WORD_LIMIT_EXCEEDED`) are
delegated to `QuestionItemRepairer`, which demands passage-grounded evidence and fails closed when none
exists. The stem rewriter is now gated on `DUPLICATE_CONTENT` only and made convergent. No
case/seed/question-number branching.

### RC-9 — Live provider credential exhausted on the route the engine uses
**Classification:** environment defect that blocked all live measurement (owner: MAIN).

`test_t03_08_live_provider_smoke_or_not_run_external` failed with:

```
HTTP 402 {'type': 'insufficient_balance_error', 'message': 'insufficient balance (1008)'}
```

Characterised by probing **both** MiniMax routes with the same key and model:

| Route | Result (old key) |
|---|---|
| `POST /v1/chat/completions` (the route `openai_compatible.py` uses) | **HTTP 402** |
| `POST /v1/text/chatcompletion_v2` (native) | HTTP 200 |

So the account was exhausted on the OpenAI-compatible route specifically, not globally — which is why
the native-route smoke looked healthy while every engine dispatch failed. Credential rotated; both routes
now return 200 and the smoke test passes. **Recorded because it invalidates any campaign attempted
under the old key**, not because it is an engine defect. API keys remain excluded from
`provider_binding_snapshot()` by design, so this rotation does not perturb campaign identity.

### RC-10 — Pre-existing CWD-relative fixture path (owner: MAIN)
`tests/test_t00_policies.py` resolved `artifacts/refactor/phase-00/fixtures` relative to the process
CWD, so the corpus replay failed whenever pytest ran from `services/generation-service`. Anchored to
`Path(__file__).resolve().parents[3]`, matching the convention used by sibling test modules. Now passes
from both CWDs.

### RC-11 — Rejected approach: mining the `evidenceQuote` (recorded deliberately)
An earlier attempt recovered an empty blank by mining a 1-3 word span out of the model's
`evidenceQuote`. It passed every mechanical gate (verbatim, length, non-leaking, distinct) and was
**semantically wrong**: resolving a "Researchers gathered [2]" cloze to "three salinity gradients"
when the quoted sentence said profiles were collected *across* those gradients.

The `evidenceQuote` identifies the source **sentence**, not which words fill that cloze. Mining a
span from it is **synthesis, not recovery**, and would have inflated the valid-Draft rate with wrong
questions. The path was reverted and is now pinned by a test asserting nothing is synthesised from
evidence text.

## 3. Harness and evidence-integrity defects found and fixed (owner: MAIN)

These were real defects in the measurement apparatus itself, not the engine.

1. **Campaign identity was under-bound.** `configSha256` hashed a hand-maintained 17-file allowlist
   that omitted `app/loop/controller.py`, `app/repair/question.py`, `app/repair/planner.py`,
   `app/loop/paper.py` and `app/generators/question/prompts.py` — precisely the files remediation
   changes. A campaign ID could stay constant across materially different engines. Now the entire
   `services/generation-service/app` tree (133 files, excluding `__pycache__`) plus the .NET
   checkpoint surface **and the measurement harness itself** participate in campaign identity.
2. **Worktree binding hashed directory markers instead of contents.** `git status --porcelain`
   collapses untracked directories, and the engine tree is entirely untracked, so the digest bound a
   marker rather than the code that produced the results. Now uses `--untracked-files=all`
   (1209 paths enumerated).
3. **Provider endpoint/model were neither hashed nor verified.** Loop caps alone do not identify a
   run; the report additionally hardcoded `"primaryModel": "MiniMax-Text-01"` without checking it.
   Added `settings.provider_binding_snapshot()` (non-secret: provider order, endpoint, model) into
   the hashed snapshot, and the report now records the **resolved** model. API keys are excluded.
4. **`evaluatorIssues` and `versionsCount` were hardcoded literals** in three of four case writers
   (`run_phase15_benchmarks.py` lines 1632/1854/2155), emitting `evaluatorIssues: []` and
   `versionsCount: 1` regardless of what happened. This made campaign records useless for
   distinguishing a correct semantic rejection from an engine defect — and is why the three
   "exact-target blockers" of case 4 could never be identified from existing artifacts. The live
   V2 and legacy writers now persist real issue codes, scopes and messages.
5. **Failed case rows could be overwritten by a later retry.** The harness rewrites
   `case_NN_*.json` in place. Prior attempts are now archived to `cases/attempts/` tagged with their
   outcome before any write, so no failure can disappear behind a successful retry.
6. **`--no-resume` did not reach the durable resume path (found while launching the acceptance
   campaign; owner: MAIN).** The campaign id is derived from the corpus+config hash, so two
   invocations against an *unchanged* engine legitimately derive the SAME id — and
   `reading_paper_runs` keys on `(BenchmarkCampaignId, BenchmarkCaseId)` with a UNIQUE index.
   `run_v2_paper_benchmark_case`'s `should_resume` predicate consulted `rerun_failed` but **never the
   `resume` flag**, so `--no-resume` governed only the on-disk case-file cache while the PostgreSQL
   branch would reactivate the earlier invocation's `COMPLETED` run.

   Consequence: the acceptance campaign would have silently **spliced the 7-case diagnostic replay's
   successful rows** into its own results for cases 4, 8, 9, 13, 14, 16 and 18 — presenting replayed
   work as a fresh 18-case run. Detected before the run reached those cases and the run was killed.

   Two fixes, both required:
   - `resume` is now a parameter of `run_v2_paper_benchmark_case`, gates `should_resume`, and is
     forwarded at the call site.
   - `--campaign-tag` disambiguates successive acceptance attempts. Two runs against an unchanged
     engine can no longer collide on `(campaignId, caseId)`. The corpus/config hashes remain pinned in
     `engineBinding`, so the measurement stays fully bound.

   The legacy leg was audited for the same defect and is **not** affected: it always provisions fresh,
   falling back to an `_attN` case id on conflict.

   Pinned by `tests/test_phase15_v2rate_main_no_resume_splice.py` (6 tests). Verified RED against the
   real pre-fix harness source, then GREEN.

## 4. Focused regression tests added

| File | Tests | Pins |
|---|---|---|
| `tests/test_phase15_v2rate_a_summary_blank_recovery.py` | 9 | hybrid candidate retention; fail-closed without model evidence; anti-leakage; sibling isolation |
| `tests/test_phase15_v2rate_c_starvation_recovery.py` | 7 | starved slot is **served**; fail-closed with nothing usable; no synthesis from evidence text; group-distinctness on recovered answers |
| `tests/test_phase15_v2rate_d_paper_passage_recovery.py` | 9 | final-slot repair→regenerate redirect; passage recovers within budget; **no version cap raised**; repair-locality before/after hashes |
| `tests/test_phase15_v2rate_b_recovery_closure.py` | — | repair closure / CAS / idempotency |
| `tests/test_phase15_v2rate_main_campaign_binding.py` | 12 | engine-surface coverage; worktree digest; provider binding; attempt archival |

`tests/test_phase15_v2_generator_fixes.py` — three assertions that encoded the starvation defect
were updated to the fail-closed expectation; all slot-isolation assertions retained.

## 5. Test-suite state

| Milestone | Failed | Passed | Skipped |
|---|---|---|---|
| Baseline before any remediation | 11 | 556 | 42 |
| After RC-1..RC-4 | 7 | 609 | 42 |
| After RC-6..RC-10 | 6 | 636 | 42 |
| After RC-12..RC-15 | 6 | 684 | 42 |
| After RC-16..RC-17 (current tree) | **6** | **701** | 42 |

All five failures originally assigned to the repair/loop workstream
(`test_t06_05_evaluator_timeout_fail_closed`, four `test_t11_section_loop` tests) are **green**.

The 6 remaining failures are all stale-artifact issues that the acceptance campaign and the handoff
manifest regeneration resolve. None is engine-related:

| Failure | Cause | Resolved by |
|---|---|---|
| `test_t15_benchmarks.py` (4) | report holds an 11-case partial campaign (`assert 11 >= 18`) | the acceptance campaign |
| `test_t15_release_manifests.py::test_t15_01_...` | manifest hash drift on files changed after the freeze | manifest regeneration at handoff |
| `test_phase15_v2rate_main_campaign_binding.py::test_report_binds_results_to_worktree_and_engine_surface` | stale pre-campaign report lacks `engineBinding` | the acceptance campaign |

Two failures that were *not* stale artifacts are now **fixed at source** rather than waived:
`test_t03_08_live_provider_smoke_or_not_run_external` (RC-9, credential exhausted on the engine's
route) and `test_t00_03_questions_corpus_all_six_types` (RC-10, CWD-relative fixture path).

### RED→GREEN verification of RC-6/7/8 (Main, independent)

Each production fix was reverted **individually** with its tests left in place, to confirm the tests
actually fail without the fix rather than merely passing with it:

| Reverted fix | Test file | RED result |
|---|---|---|
| RC-7 CAS resync disabled | `test_phase15_v2rate_b_cas_integrity.py` | 1 failed — `an artifact strictly closed against the live accepted head must not be called unverifiable; got INVALID_OUTPUT` |
| RC-8 routing delegation stubbed | `test_phase15_v2rate_b_defect_routing.py` | 3 failed — `DID NOT RAISE RepairJustificationError` x2, rewriter non-convergence |
| RC-6 salvage gates removed | `test_phase15_v2rate_b_candidate_salvage.py` | 3 failed — leaking candidate accepted (`assert 'core profiles' == 'salinity gradients'`), `DID NOT RAISE` x2 |

All fixes then restored byte-identical (verified by diff against backup) and the three files pass 26/26.
No verification stub markers remain in the tree.

**No gate was weakened to achieve this.** `deploy/envs/loop-caps.env` is unchanged
(`da9f7fc617fc704157e2da649f02f28e82975f583d59d9e6834efd95353030c7`) and `LoopPolicy()` still yields
`max_versions=3, max_generated_versions=3, max_repair_attempts_per_version=2, max_total_repairs=5,
max_consecutive_no_progress=2, max_oscillation_cycles=2` — identical to the approved production profile.

## 6. Diagnostic replay results

Campaign `camp_G15_eef49d5aff21`, live `MiniMax-Text-01`, 7 paired cases, seeds and source triples
unchanged. **7/7 previously-failing V2 cases now produce valid Drafts, all persisted as exams.**

| Case | Seed | Prior signature | Now | Dispatches | Persisted exam |
|---|---|---|---|---|---|
| 4 | 101 | `MAX_VERSIONS: 3 exact-target blockers` | ACCEPTED | 17 | `a79f9e7c…` |
| 8 | 202 | `Q20 SCHEMA_VIOLATION: answer empty` x3 | ACCEPTED | 17 | `8069c998…` |
| 9 | 303 | `MAX_VERSIONS: 1 exact-target blockers` (section 3 passage) | ACCEPTED | 9 | `086dd774…` |
| 13 | 101 | `Q20 SCHEMA_VIOLATION` x3 | ACCEPTED | 9 | `d9c8bd2a…` |
| 14 | 202 | `INVALID_OUTPUT: capability returned wrong target/version/hash/parents` | ACCEPTED | 9 | `ed945e0a…` |
| 16 | 101 | `Q20 SCHEMA_VIOLATION` x3 | ACCEPTED | 9 | `63a8cb7e…` |
| 18 | 303 | `Q20 SCHEMA_VIOLATION` x3 | ACCEPTED | 10 | `5d2cb949…` |

`validationMatrix.validDraftRate.v2 = 1.0` on this set (`target >= 0.95`, `passed: true`).
Campaign `configSha256 = 0015b6f4719c51b4…` bound to **133** engine-surface files.

Paired ratios on the same run: V2/legacy P95 latency **0.614x** (≤ 1.5x), median tokens **0.208x**
(≤ 2.0x), fidelity must-reject **100%**, semantic blocking recall **100%**.

Two notes on honesty of this evidence:

1. This is a **DIAGNOSTIC replay of the seven known failures**, not the acceptance campaign. Seven
   cases chosen *because* they failed is a biased sample and cannot establish the 18-case rate. It
   demonstrates the specific defects are repaired, nothing more.
2. The legacy leg failed 5 of 7 on this run (0.286). Those failures are genuine legacy-engine
   behaviour, recorded rather than hidden.

Note the run log shows transient provider format errors (`Malformed JSON syntax`, retried by the
gateway) and solver backtracking fallbacks. Both are the engine's own bounded-recovery paths
working as designed; neither suppressed an issue code.

## 7. Legacy baseline: reuse or rerun

**Decision: rerun the legacy leg. The existing legacy rows cannot be reused.**

The plan permits reuse only if the relevant engine, shared code, model, configuration and environment
bindings remain compatible. Checked rather than assumed:

| Binding | Verdict | Evidence |
|---|---|---|
| Legacy engine surface | **compatible** | AST import-closure of the legacy leg's entry points (`app.pipeline`, `app.prompts`, `app.extractor`, `app.llm`) spans **161 modules** and contains **none** of `app.loop.runtime`, `app.loop.paper`, `app.repair.section`, `app.repair.question` — every module RC-6/7/8 changed. The legacy engine cannot execute the changed code. |
| Model | compatible | `MiniMax-Text-01` on `https://api.minimaxi.chat/v1`, unchanged. |
| Caps / policy | compatible | `loop-caps.env` hash `da9f7fc6…` unchanged; `LoopPolicy()` identical to the approved profile. |
| Worktree / campaign identity | **incompatible** | The canonical campaign `camp_G15_c9750f53d6b5` predates the `engineBinding` field entirely — its report has **no `engineBinding` at all** (`has engineBinding: False`), so it cannot be tied to any worktree. Its legacy rows also carry hardcoded `versionsCount: 1` / `evaluatorIssues: []` from the writer defect recorded in §3 item 4, so they are not faithful records. |
| Environment | **incompatible** | Legacy rows were produced under the credential that is now exhausted on the engine's route (RC-9). |

The engine-surface check alone would have permitted reuse; the **evidence-binding** check does not. A
legacy row that cannot be tied to a worktree, was written by an instrument emitting hardcoded fields,
and was measured under a retired credential cannot serve as a comparison baseline. The comparison
leg is therefore rerun inside the fresh campaign rather than inherited.

### RC-12 — Verbatim matcher rejected a span that was present (case 16)
**Classification:** implementation failure — **false positive**, not a semantic rejection.

`match_verbatim_in_passage` (`app/contracts/policies.py`) built one unconditional pattern:

    (?<![\w'-]) + re.escape(answer) + (?![\w'-])

The trailing guard treats `-` as a token continuation. So when the answer's **own last character is
punctuation**, the span is already self-delimited, yet a successor hyphen still vetoed it. Case 16's
answer `mutant huntingtin (mHTT)` is present verbatim in

    ...HD is driven by mutant huntingtin (mHTT)-related cellular and synaptic dysfunction...

but was rejected. The identical answer matched when the passage continued with a space instead of a
hyphen. Executed probe on the pre-fix function:

    False  'mutant huntingtin (mHTT)'  <- "...(mHTT)-related cellular…"
    True   'mutant huntingtin (mHTT)'  <- "...(mHTT) dysfunction…"

Because it was a false positive it then escalated — see RC-13 — and killed an otherwise valid paper.

**Fix:** the trailing boundary is required only when the ANSWER itself ends in a token-continuation
character (word char, apostrophe or hyphen). When the answer ends in punctuation the span is delimited
by its own final character, so only a successor word character could turn it into a prefix of a longer
word and the guard relaxes to `(?!\w)`. The leading guard is unchanged. A single `_TOKEN_CONTINUATION`
constant is the source of truth for both boundary regexes and the self-delimited test.

**Grounding cannot be weakened by this change:** a differential fuzz of old vs new over 2,160
(answer, separator, successor) combinations showed **120 widened, 0 narrowed**, and every widening is a
punctuation-terminated answer. Word-ending answers are never more permissive.

### RC-13 — Escalation was scope-blind: one slot's answer killed the whole paper
**Classification:** implementation failure (loop routing).

`EVIDENCE_MISSING` sits in `LoopPolicy.escalate_codes`, and `LoopController.decide` escalated on the
**code alone**:

    if any(i.code in self.policy.escalate_codes for i in blockers): ESCALATE

So a single slot's non-verbatim completion answer escalated the entire paper to "source/evidence
requires editorial or source review". Confirmed for case 16: the only open issue was

    EVIDENCE_MISSING | QUESTION | Question 9 completion answer '…' does not appear as a full-token verbatim span

— a per-slot generation defect, exactly the class the regeneration path already recovers.

**Fix:** `LoopPolicy.escalates(code, scope)` makes escalation scope-aware via
`scope_recoverable_escalate_codes = {EVIDENCE_MISSING: {QUESTION}}`. A QUESTION-scoped evidence defect
regenerates; **every unlisted scope still escalates**, so genuine source insufficiency is unaffected.
Verified by execution:

    QUESTION-scoped EVIDENCE_MISSING escalates: False
    SOURCE/PASSAGE/SECTION/EVIDENCE-scoped EVIDENCE_MISSING escalates: True
    SOURCE_INSUFFICIENT (any scope) escalates: True

`EVIDENCE_MISSING` was **not** removed from `escalate_codes` — that would have failed open on real
source problems.

### RC-14 — The quantity rule was unenforceable at generation time (case 13)
**Classification:** implementation failure (generator), on top of a genuine model violation.

The prompt rule already existed and is explicit (`app/generators/passage/prompts.py`):

> "NEVER introduce unmeasured outcomes, invented quantities, inferred calendar years, or outside
> facts. Every number, percentage, or year in the passage MUST appear verbatim in <source_material>."

`PassageGenerator.generate()` returned whatever the model produced and relied entirely on downstream
evaluators to catch violations. The invariant was stated but never checked, so a single invented year
consumed a full immutable version slot and left no budget for grounded regeneration.

**Fix:** a deterministic parse guard in `app/generators/passage/generator.py`. Source and passage
numeric tokens are extracted with the same helper; any passage token whose digit string is absent from
the source is invented. When the guard fires the generator re-asks **once** with the offending tokens
named, bounded by `QUANTITY_GUARD_MAX_RETRIES = 1`. That is a generator-internal bound, not a loop
policy cap — no `max_versions` / `max_generated_versions` / `max_total_repairs` value was touched.
Boundaries ignore digits inside identifiers (`H1N1`, `S2`, `academicword42`, `Fig.2`) so gene names and
accession codes are never misreported as invented quantities.

**Defect found during Main's review of that fix:** the guard's right boundary excluded *any* following
period, so a quantity at the end of a sentence was never extracted:

    _extract_numeric_tokens("collected in 2005.")  -> []      # 2005 lost
    _extract_numeric_tokens("collected in 2005")   -> ['2005']

That caused false negatives (an invented quantity at a sentence end went uncaught) **and** false
positives — a passage quantity was reported as invented merely because the SOURCE happened to state it
at a sentence end, spending a regeneration retry on a non-defect. Fixed to
`(?<![\w.])(\d{2,4})(?!\w|\.\d)`: a period continues a token only when a digit follows (decimals,
`Fig.2`), never when it ends a sentence. The left boundary keeps `.` so the `5` of `3.5` is not read as
standalone. Verified RED against the original pattern, GREEN after; two regression tests added.

### RC-15 — Six loop/paper tests shared fixed `/tmp` SQLite paths
`test_t11_05/06/07` and `test_t12_05/06/07` + `test_t12_facade_bench` each opened a **hard-coded**
`/tmp/*.db`. A stale file, or a handle still open from an interrupted run, leaked into a later run —
producing an intermittent `test_t11_07` failure that appeared only in full-suite runs and passed 3/3 in
isolation. Each path is now unique per invocation (`uuid4().hex`). The DB must still survive across the
`SectionLoop` instances inside a test to simulate a process restart, so uniqueness has to be per test,
not per loop.

## 8. Acceptance campaign

### Run 1 — `camp_G15_d2c833c1c04f` (superseded)

18 paired papers / 36 runs, live `MiniMax-Text-01`, `--no-resume --campaign-tag acceptance-2026-10-12-a`.
Fresh IDs verified: **zero run-ID overlap** with the diagnostic replay (`camp_G15_eef49d5aff21`).

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| V2 valid-Draft rate | **16/18 = 88.9%** | >= 95% (18/18) | **FAIL** |
| Legacy valid-Draft rate | 9/18 = 50% | — | reference only |
| V2 P95 latency / legacy | 0.699x | <= 1.5x | PASS |
| Median tokens / legacy | 0.242x | <= 2.0x | PASS |
| Fidelity must-reject | 100% | 100% | PASS |
| Semantic blocking recall | 100% | >= 95% | PASS |

Rate moved **11/18 (61.1%) -> 16/18 (88.9%)**. The two remaining failures are different in kind:

| Case | Seed | Signature | Classification |
|---|---|---|---|
| 16 | 101 | `SOURCE_INSUFFICIENT ... Question 9 completion answer 'mutant huntingtin (mHTT)' does not appear as a full-token verbatim span in passage` | **implementation failure** — false positive. The answer IS present verbatim; `match_verbatim_in_passage` rejects it only because the answer ends in `)` and the passage continues `-related`. The false positive then escalated the whole paper (`EVIDENCE_MISSING` is scope-blind in `escalate_codes`). |
| 13 | 101 | `Passage generation failed in section 1: MAX_VERSIONS: 2 unresolved blockers or repair cap` | **correct semantic rejection.** The passage asserted "the first transiting exoplanet in 1999"; `1999` occurs **0 times** in that run's SourcePack. The evaluator refused unsupported content, and the repairer correctly declined to mutate the passage (`No evidence-backed transformation could be applied`). |

Both are addressed in RC-12 / RC-13 below. No failed row was replaced by a selected retry: the report
records all 18 cases and all 36 runs, `failedRunsCount=11`, `incompleteRunsCount=0`.

### Run 2 — `camp_G15_dde0f9bd38d4` (superseded)

Same 18 cases, same seeds, same source triples, `--no-resume --campaign-tag acceptance-2026-10-12-b`.
Zero run-ID overlap with **both** prior campaigns (verified by SQL self-join across campaigns: 0).

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| V2 valid-Draft rate | **16/18 = 88.9%** | >= 95% (18/18) | **FAIL** |
| Legacy valid-Draft rate | 12/18 = 66.7% | — | reference only |
| V2 P95 latency / legacy | 0.584x | <= 1.5x | PASS |
| Median tokens / legacy | 0.227x | <= 2.0x | PASS |
| Fidelity must-reject | 100% | 100% | PASS |
| Semantic blocking recall | 100% | >= 95% | PASS |

The rate did not move, but **the failing set changed**, which is the informative part:

| Case | Run 1 | Run 2 | Classification |
|---|---|---|---|
| 16 | FAIL (`EVIDENCE_MISSING` on `'mutant huntingtin (mHTT)'`) | **PASS** | RC-12 + RC-13 confirmed fixed on live data |
| 13 | FAIL (`MAX_VERSIONS`, invented `'1999'`) | FAIL (`INVALID_OUTPUT`, stale section refs) | new defect surfaced once the quantity guard stopped consuming the version budget |
| 15 | PASS | FAIL (`MAX_VERSIONS`, passage 682 words) | new defect surfaced; **systematic word-count drift** |

Run 2 also shows the V2/legacy valid-Draft gap widening in our favour (V2 88.9% vs legacy 66.7%).

Two new root causes, both confirmed from raw evidence and delegated: the paper loop assembling its
`parentRefs` from **stale** section heads (`art_section_2` v1 while the accepted head is v3 — truthfully
rejected by the RC-7 guard, which must NOT be weakened), and **systematic passage word-count drift**
(921, 673, 660, 682, 691 across live runs against the required [720, 915], despite an explicit prompt
rule — the same "stated but never checked" pattern as the quantity rule in RC-14).

`failedRunsCount=8`, `incompleteRunsCount=0`, all 36 runs recorded. No failed row was replaced by a
selected retry.

### RC-16 — Systematic passage word-count drift burned version slots (case 15)
**Classification:** implementation failure (generator), the same "stated but never checked" pattern as RC-14.

`app/generators/passage/prompts.py` already states the band — "Word count MUST be between 720 and 915
words (target 780-840)" — but `PassageGenerator.generate()` called the provider once and returned
whatever came back. Measured passages this session: **921, 673, 660, 682, 691** against the required
[720, 915]. Case 15 died holding a single OPEN blocker: `Passage word count 682 is outside permitted
bounds` — 38 words short of the floor. A purely mechanical defect consumed the whole paper.

Drift direction measured by the owner: **undershoot in 4 of 5 readings** (673/47, 660/60, 682/38,
691/29) and a single overshoot (921/6).

**Fix:** a word-count band guard mirroring the quantity guard. The draft is measured with
`_measure_passage_words`, a thin alias over the canonical `count_words` from `app/contracts/policies.py`
— deliberately no second tokenizer, because a private rule could disagree with the validator at a
boundary and silently move the band. Out-of-band drafts are re-asked **once**
(`WORD_COUNT_GUARD_MAX_RETRIES = 1`) through the existing length-feedback seam, naming the measured
count and the exact deficit/overshoot. **Never truncate, pad, clip or clamp** — a draft still out of
band after the bounded retry is returned unchanged and the validators fail it closed.

The band is read from `PASSAGE_MIN_WORDS` / `PASSAGE_MAX_WORDS`, **not** from
`context.target_min_words` / `target_max_words`: those are caller-overridable, so binding to them would
let an overridden context widen the checked band while the validator still rejected at 720/915 —
silently switching the guard off. Pinned by a test that builds a context claiming [600, 2000] and
asserts the guard still fires against 720.

### RC-17 — The paper's first draft was assembled from the pre-loop snapshot (case 13)
**Classification:** implementation failure (producer side). The `INVALID_OUTPUT` was **truthful** — a
paper naming `art_section_2` v1 while the accepted head is v3 IS a backward chain reference — and
RC-7's `_deps_resyncable_only` must keep refusing it. The defect was that the paper was BUILT that way.

`app/loop/paper.py:138` (pre-fix):

    sections_to_use = self._resolve_current_sections(context) if version > 1 else self.section_envelopes

The live-head resolution was gated on `version > 1`, so the **first draft** — precisely the artifact
this campaign failed on — was assembled from the snapshot captured before the section sub-loops ran.
Reproduced against the fixture: with a section head at v3 and the caller snapshot at v1,
`version=1 -> {art_section_s2: 1}` (case 13 exactly), `version=2 -> {art_section_s2: 3}`.

A second defect sat next to it: the head lookup keyed on `sec.artifact_id`, so when the snapshot used
a different id convention from the persisted chain the lookup **silently missed** and kept the stale
envelope. This run genuinely contains both `art_section_2` and `art_section_s1` artifacts.

**Fix:** every parent the paper binds is resolved to the ACCEPTED HEAD from `resume_state` at assembly
time, for **every** version, keyed on a canonical section id with fallback to the envelope's own id.
Both sides of the strict-closure check — `PaperLoop.run`'s declared `input_dependencies` and the
generator's assembly — now read the same head, so they cannot disagree by construction.

Invariants preserved: the refresh is a pure READ (`resume_state`) and never touches the commit path, so
CAS/fencing is untouched; the paper is still emitted as a NEW version (immutability); repeated assembly
yields an identical content hash (idempotency); ten explicit fail-closed branches cover a stale-only
record, a regressed head, a same-version-different-hash head, an unresolvable head and an unreadable
envelope; `_deps_resyncable_only` is untouched. Caps unchanged: `3 / 3 / 2 / 5`.

## 9. Final campaign results and gate status

Pending.