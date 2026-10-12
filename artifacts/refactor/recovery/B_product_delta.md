# B_product_delta.md — per-file product-code behavior delta, VPS `04fdbd7` vs local `7a4d0e7`

> **CORRECTION NOTICE.** An earlier draft of this file compared against `56d060d` and concluded that `services/generation-service/app/**` was absent at the local base ("wholesale tree replacement"). **That was wrong.** `56d060d` is the *origin* ref, which is **5 commits behind** local `7a4d0e7`. Local `7a4d0e7` fully contains `app/**` (73 files) and is the **direct parent of `1ea298a`**. All comparisons below are redone against `7a4d0e7` itself.

## 0. Method and the corrected structural facts

```
$ git rev-parse 7a4d0e7   → 7a4d0e7503710d3b87c95e15831829552ba7be8d
$ git rev-parse 56d060d   → 56d060d45b2f55e6d1af03240e019c60084b1261
$ git merge-base --is-ancestor 56d060d 7a4d0e7  →  YES  (origin is behind local)
$ git rev-list --count 56d060d..7a4d0e7       →  5
$ git log -1 --format=%P 1ea298a              →  7a4d0e7503710d3b87c95e15831829552ba7be8d   (parent)
```

Local `7a4d0e7`'s 5 commits ahead of origin:

```
7a4d0e7 feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs
999dc94 docs(reading-paper): relocate spec to project root and update references
0d1a6c9 docs: add reading paper universal source ingestion spec to project root
323f152 feat(ai-service): implement universal source ingestion for multi-format sources and robust reasoning JSON parsing
32a2fc1 docs(reading-paper): add universal source ingestion specification for multi-format sources
```

`7a4d0e7` is a **peer** of `1ea298a` — both are "autonomous exam generation loop engine" work. `1ea298a`'s commit body describes G07-G09 engine-v2 completion, which is the *continuation* of what local `7a4d0e7` started ("phase 07 evaluators/repairs"). They are **not** a tree replacement.

### Actual `app/**` delta `7a4d0e7` → `04fdbd7`

```
files at 7a4d0e7 = 73      files at 04fdbd7 = 129
identical blobs : 31       <-- untouched by the incoming commits
changed blobs   : 42       <-- the real behavioral delta
added files     : 56
deleted files   :  0       <-- nothing removed
```

Aggregate including tests: `170 files changed, 61385 insertions(+), 901 deletions(-)` across `app/**`, `tests/**`, and `scripts/refactor/**`. Excluding vendored wheels.

`1ea298a` in isolation vs `7a4d0e7`: `34 files changed, 4552 insertions(+), 180 deletions(-)` on `app/**`.

### Engine-tree compatibility with the 18/18 campaign (verified by Main against live DB)

Main verified `git rev-parse 8deff37:services/generation-service/app` == `git rev-parse HEAD:services/generation-service/app` == `dc86e69ccc63b734d7b7384b684b0005beeb9b4b`. **The engine tree is byte-identical between the orphaned campaign commit `8deff37` and VPS HEAD `04fdbd7`**, so the 18/18 evidence is reusable for the engine even though the campaign's `gitSha` is not reachable.

---

## 1. The 42 changed files — behavioral delta (VPS behavior / local behavior / contract / chosen implementation)

Legend: **LOCAL-DIRTY** = local has an uncommitted edit to that exact file (from the 318-entry local status), so a three-way decision is required.

### 1.1 `app/config.py` — settings surface and cap-snapshot hashing

| | |
|---|---|
| **VPS `04fdbd7`** | `358967457aba1a8039179001de420850e6b16e20` (371 lines). Adds `cap_snapshot_json()` / `cap_snapshot_sha256()` (canonical `sort_keys=True, separators=(",",":"), ensure_ascii=False`, "shared with .NET's sorted, unescaped serializer"); loads **two** env files (`loop-caps.env` then `ai.env`); `model_config` gains `populate_by_name`, `allow_inf_nan=False`, `hide_input_in_errors=True`; adds `internal_api_key` with 4-way `AliasChoices`; versioned G06 profile fields (`loop_caps_profile_version`, `loop_caps_profile_source`); `benchmark_caps_mode`, `benchmark_monetary_cap_mode`; run-budget + benchmark-child caps; legacy/benchmark section caps; `provider_binding_snapshot()`. |
| **Local `7a4d0e7`** | `6fb2f732301995c4a4288a5942ff87140003cbe9` (~76 lines). Single env file (`ai.env`), no cap-snapshot hashing, no profile fields, no `internal_api_key`. `groq_model = "openai/gpt-oss-20b"`, `loop_generate_token_reservation = 2500`, `loop_evaluate_token_reservation = 1000`, `loop_repair_token_reservation = 1500`, `loop_operation_wall_reservation_seconds = 30.0`, `loop_max_wall_time_seconds: float = 300.0`. |
| **Contract** | G06 versioned runtime profile; canonical cap-snapshot hash must agree byte-for-byte with the .NET `CheckpointService` serializer; `.NET` worker cross-checks the JSON digest, version and source. |
| **Chosen** | **Take VPS wholesale.** *But local is **LOCAL-DIRTY** on this file — three-way required.* **Behavioral defaults to confirm before carrying:** `groq_model` 20b→120b; token reservations ×6 (generate), ×10 (evaluate), ×10 (repair); wall reservation 30→60. |

### 1.2 `app/repair/question.py` — pooled-candidate salvage gating (RC-6)

| | |
|---|---|
| **VPS** | `_try_apply_candidate` gates substitution on **self-prompt leakage**, **shared-stem leakage**, **sibling distinctness** in addition to verbatim + word-count. The sibling/stem helpers read the payload **live per call** so a blank repaired earlier in the same pass is visible to the next gate. No compliant pool member → `RepairJustificationError`. |
| **Local `7a4d0e7`** | Present but gated on verbatim + word count only. |
| **Contract** | RC-6: salvage was accepting candidates that violate anti-leakage and group-distinctness, assembling "recovered" Drafts from invalid candidates. Gates **strengthened, not relaxed**. |
| **Chosen** | **Take VPS.** *Local is **LOCAL-DIRTY** here.* **Must not be weakened.** |

### 1.3 `app/repair/question.py` / router — answer-semantics routing (RC-8)

| | |
|---|---|
| **VPS** | `AMBIGUOUS_ANSWER`, `BAD_DISTRACTOR`, `WORD_LIMIT_EXCEEDED` delegate to `QuestionItemRepairer` (demands passage-grounded evidence, fails closed). The `rephrase_duplicate_prompt` stem rewriter is gated on `DUPLICATE_CONTENT` only and made convergent. Unconditional `"(revised for distinct focus)"` append removed. |
| **Local** | `SectionRepairRouter.route_repair` classifies `AMBIGUOUS_ANSWER` as an item defect → `ITEM_RESELECT`, then `SectionSurgicalRepairer._repair_impl` runs the synonym rewriter on **every** routed item question. |
| **Contract** | RC-8: the rewriter cannot resolve ambiguity (a property of *what is asked*, not vocabulary) and accretes filler — `pass 3: "In particular, regarding this aspect, in particular, researchers noted that ..."`. The `NO_PROGRESS` verdict was truthful and is preserved; the defect was upstream. |
| **Chosen** | **Take VPS.** No case/seed/question-number branching. |

### 1.4 `app/loop/runtime.py` — strict-closure resync (RC-7)

| | |
|---|---|
| **VPS** | `_refresh_input_dependencies_from_res_state` + `_deps_resyncable_only`, wired at the single fresh-draft admission site. Artifact must still verify identity, type, version **and content hash**; parent ids must be **exactly** the declared set; same-version/different-hash **refused**; regressed version **refused**; only a non-stale accepted head with a **strictly higher** version adopted; re-validated against refreshed deps, fails closed on mismatch. |
| **Local** | Compares `parent_refs` against `context.input_dependencies` declared once at loop construction → false positive `INVALID_OUTPUT` when a sub-loop commits new versions. |
| **Contract** | RC-7. Reproduced: `id_match=True, type_match=True, ver_match=True, integrity=True, parent_match=False (art_parents=3, ctx_deps=3)`. **Two weaker predicates were rejected in review** precisely because they accepted same-version hash mutations and trusted arbitrary `res_state`. |
| **Chosen** | **Take VPS verbatim.** *Local is **LOCAL-DIRTY**.* Commit body: "truthfully rejected by the RC-7 guard, which must **NOT** be weakened". |

### 1.5 `app/loop/policy.py` + `controller.py` — scope-aware escalation (RC-13)

| | |
|---|---|
| **VPS** | `LoopPolicy.escalates(code, scope)`; `scope_recoverable_escalate_codes = {EVIDENCE_MISSING: {QUESTION}}`. QUESTION-scoped regenerates; SOURCE/PASSAGE/SECTION/EVIDENCE still escalate; `SOURCE_INSUFFICIENT` escalates at any scope. Verified by execution. |
| **Local** | `decide` escalates on code alone: `if any(i.code in self.policy.escalate_codes for i in blockers): ESCALATE`. |
| **Contract** | RC-13: one slot's non-verbatim answer escalated the whole paper. `EVIDENCE_MISSING` was **not** removed from `escalate_codes` — that would fail open on real source problems. |
| **Chosen** | **Take VPS.** *Local is **LOCAL-DIRTY** on `loop/policy.py` and `loop/controller.py`.* |

### 1.6 `app/loop/detectors.py` + `runtime.py` — no-progress attribution (RC-3, RC-4)

| | |
|---|---|
| **VPS** | `normalized_outcome_fingerprint` strips volatile accounting fields (`tokensUsed`, `wallTimeUsedSeconds`, `candidateId`, `score`); `semantic_issue_identities` keys on `(code, scope, normalized message)` not `Issue.fingerprint`. In the blockers branch, when the decision would be REPAIR and `version + 1 >= max_versions` while generation budget remains, that single slot redirects to REGENERATE, with a `repeat_signal` guard so the detectors' repeats still drive `NO_PROGRESS`. |
| **Local** | `StagnationDetector` keys on whole-artifact `content_hash` reset on every generation; `OscillationDetector.record_state` requires the *next* state to differ. |
| **Contract** | RC-3 pre-fix: 6 distinct fingerprints then `MAX_VERSIONS`; post-fix `NO_PROGRESS` at the third attempt. RC-4: a loop holding a repairer spends its budget as v1 generate + v2 repair + v3 repair, so it performs exactly **one** generation. **No cap raised** — still ≤ 3 versions. |
| **Chosen** | **Take VPS.** |

### 1.7 `app/loop/paper.py` (NEW, 0 local equivalent) — first-draft live head (RC-17)

| | |
|---|---|
| **VPS pre-fix** | `app/loop/paper.py:138` → `sections_to_use = self._resolve_current_sections(context) if version > 1 else self.section_envelopes` |
| **VPS post-fix** | Every parent resolved to the ACCEPTED HEAD from `resume_state` at assembly time, for **every** version, keyed on a canonical section id with fallback to the envelope's own id. |
| **Local** | **File does not exist at `7a4d0e7`** (it is in the 56 added files). |
| **Contract** | RC-17: the v1 draft — precisely the artifact case 13 failed on — was assembled from the pre-loop snapshot. Reproduced: `version=1 -> {art_section_s2: 1}` (case 13), `version=2 -> {art_section_s2: 3}`. Invariants: pure READ of `resume_state`, never touches the commit path (CAS/fencing untouched); still a NEW version (immutability); repeated assembly yields identical content hash (idempotency); ten explicit fail-closed branches. Caps unchanged `3/3/2/5`. |
| **Chosen** | **Take VPS (new file).** |

### 1.8 `app/contracts/policies.py` — verbatim matcher (RC-12) + canonical `count_words`

| | |
|---|---|
| **VPS** | `match_verbatim_in_passage` trailing boundary `(?<![\w'-])…(?![\w'-])` → required only when the ANSWER ends in a token-continuation char; punctuation-terminated answers relax to `(?!\w)`. Single `_TOKEN_CONTINUATION` constant is source of truth for both boundary regexes and the self-delimited test. |
| **Local** | Unconditional trailing guard. |
| **Contract** | RC-12 false positive: `'mutant huntingtin (mHTT)'` **is** present in `…mutant huntingtin (mHTT)-related cellular and synaptic dysfunction…` but rejected. Differential fuzz over 2160 `(answer, separator, successor)` combinations: **120 widened, 0 narrowed**, every widening a punctuation-terminated answer. Partial-word rejection preserved. |
| **Chosen** | **Take VPS.** *Local is **LOCAL-DIRTY**.* This is the one place grounding is scoped-narrower; it is fuzz-bounded. |

### 1.9 `app/generators/passage/generator.py` + `prompts.py` (NEW) — deterministic guards (RC-14, RC-16)

| | |
|---|---|
| **VPS** | Numeric guard: extract source+passage numeric tokens with the same helper; any passage digit string absent from source is invented → re-ask **once** (`QUANTITY_GUARD_MAX_RETRIES = 1`) naming offending tokens. Regex `(?<![\w.])(\d{2,4})(?!\w\|\.\d)` — a period continues a token only when a digit follows, never at sentence end; digits inside identifiers (`H1N1`, `S2`, `academicword42`, `Fig.2`) are ignored. Word-count band guard reads `PASSAGE_MIN_WORDS`/`PASSAGE_MAX_WORDS` (**not** caller-overridable `context.target_*`), measures via `_measure_passage_words` (thin alias over canonical `count_words`), re-asks **once** (`WORD_COUNT_GUARD_MAX_RETRIES = 1`), **never truncates, pads, clips or clamps**. |
| **Local** | Prompt rule exists but `PassageGenerator.generate()` returned whatever the model produced and relied on downstream evaluators. |
| **Contract** | RC-14: a single invented year consumed a full immutable version slot. Measured drift 921/673/660/682/691 vs required [720,915]; case 15 died on a 682-word passage, 38 short of the floor. Guard bounds are **generator-internal**, not loop-policy caps. Pinned by a test building a context claiming [600,2000] and asserting the guard still fires at 720. |
| **Chosen** | **Take VPS (new files).** |

### 1.10 Remaining changed files (no single dominant behavior, all in the RC-1…RC-17 blast radius)

`contracts/{__init__,artifact,evaluation,event,issue}.py`, `evaluators/{__init__,base,deterministic,registry,semantic}.py`, `evidence/{extractor,graph}.py`, `extractor.py`, `ingestion/source_pack.py`, `llm.py`, `main.py`, `persistence/{client,models}.py`, `pipeline.py`, `prompts.py`, `providers/*` (10 files), `repair/{__init__,base,passage,planner}.py`, `router.py`.

RC-1 (hybrid `blanks`+`candidates` payload discarding a model-supplied answer → retain as gated fallback; `dropped_blank_reasons` clears on repair success; `QUESTION_PROMPT_VERSION` deliberately unchanged) and RC-2 (starvation fallback passed `group_start_number=20, blank_count=7`, widening the prompt to "questions 20 to 26" and inviting a `blanks`-shaped reply RC-1 then zeroed → omit both from the fallback; filter recovered answers against siblings already used in the same group) both land here.

**Chosen: take VPS.** Of these 42, the ones local has **uncommitted** edits to are: `config.py`, `contracts/evaluation.py`, `evaluators/{__init__,base,deterministic,registry,semantic}.py`, `evidence/extractor.py`, `loop/{context,runtime}.py`, `persistence/{client,models}.py`, `providers/adapters/{groq,minimax,openai_compatible}.py`, `providers/{gateway,parser}.py`, `repair/{passage,planner,question}.py`, `router.py` — **21 files needing three-way reconciliation**. `AppHost/Program.cs`, `scripts/refactor/generate_phase07_{corpus,gate}.py`, `services/exam-service/Features/ReadingPaper/*.cs`, and a deleted `reading-paper-universal-source-ingestion.md` are outside `app/**` and also LOCAL-DIRTY.

## 2. The 56 added files — new subsystems

| Group | Files | Behavior |
|---|---|---|
| Paper/section/solver contracts | `contracts/{paper,section,solver}.py` | Canonical V2 paper/section/solver envelopes |
| Section & paper sub-loops | `loop/{paper,passage,question,section}.py` | Per-section/per-question sub-loops that commit their own heads (this is what made RC-7 necessary) |
| Looped repair | `repair/{paper,section}.py` | Scope-targeted repair for paper/section artifacts |
| New evaluators | `evaluators/{coverage,metrics,paper,section,solver}.py` | Coverage + paper/section/solver evaluator families |
| Events | `events/{__init__,buffer,envelope,outbox,replay,stream,taxonomy}.py` | Durable event buffer/outbox/replay with taxonomy |
| Curation | `curation/{__init__,curation,export,partitioning}.py` | Corpus partitioning + export for offline eval |
| Observability | `observability/{__init__,accounting,dashboard,metrics,redaction,tracing}.py` | Token/cost accounting, redaction, tracing |
| Offline eval | `offline_eval/{__init__,comparison,runner}.py` | Replay comparison runner |
| Promotion | `promotion/{__init__,promotion,registry}.py` | In-flight run version isolation (`P15-06`) |
| Solvers | `solvers/{__init__,adjudication,adversary,cache,comparison,diversity,prompts,serializer,solver}.py` | Blind/adversarial solver stack |
| Selection | `selection/selector.py` | Candidate selection |
| Generators pkg | `generators/{__init__,passage/*,question/*}.py` | Passage/question generator packages |
| Facade | `facade.py` | `GenerationFacade` routing canonical ingestion + V2 SectionLoop |

**Chosen: take VPS (all 56).** None exist at `7a4d0e7`.

## 3. `f56a097` — BaseEvaluator regression test

| | |
|---|---|
| **VPS** | `services/generation-service/tests/test_t07_evaluators_repairs.py` `+40/-0`, one regression test pinning BaseEvaluator auto-resolution of shared code issues. |
| **Local** | `test_t07_evaluators_repairs.py` is **LOCAL-DIRTY** (also gains `+770/-…` from `7a4d0e7`→`04fdbd7`). |
| **Contract** | Pins evaluator behavior. |
| **Classification** | **BEHAVIOR-PRESERVING against local** — test-only, no product-code conflict. |

## 4. `e96f71b` harness `scripts/refactor/run_phase15_benchmarks.py` (+3168 lines) — measurement integrity

| Behavior | Contract | Chosen |
|---|---|---|
| `--no-resume` reaches the PostgreSQL durable path: `resume` is a parameter of `run_v2_paper_benchmark_case`, gates `should_resume`, forwarded at the call site | §3.6: previously governed only the on-disk cache while the PG branch would reactivate an earlier invocation's `COMPLETED` run | **Take VPS.** Pinned by `tests/test_phase15_v2rate_main_no_resume_splice.py` (6 tests), RED-verified against real pre-fix source. **Main's live-DB SQL self-join (`COUNT(*) = 0` run-ID overlap across all prior campaigns) empirically confirms this fix held.** |
| `--campaign-tag` disambiguates `(campaignId, caseId)` | Prevents collision on the UNIQUE index | **Take VPS** |
| Campaign identity = whole `app/` tree (133 files, excl `__pycache__`) + .NET checkpoint surface + the harness itself | §3.1: prior 17-file allowlist omitted `loop/controller.py`, `repair/question.py`, `repair/planner.py`, `loop/paper.py`, `generators/question/prompts.py` — exactly the files remediation changes | **Take VPS** |
| Worktree digest via `git status --untracked-files=all` (1209 paths) | §3.2: `--porcelain` collapses untracked dirs; the engine tree is entirely untracked so the digest bound a marker | **Take VPS** |
| `evaluatorIssues`/`versionsCount` persisted truthfully (were hardcoded literals at 3 of 4 case writers) | §3.4 | **Take VPS** |
| Failed rows archived to `cases/attempts/` before in-place rewrite | §3.5 | **Take VPS.** *(Note: no `cases/attempts/` directory is present in the committed tree — see `B_g15_audit.md`.)* |

Harness DB target (confirmed by Main live): `PGPORT=5433`, `resolvedDatabase exam_test_phase15`, user `exam`, target `ISOLATED_STAGING_TEST`.

## 5. `4477819` / `f255b8b` / `04fdbd7` — product-code delta

- `4477819`: **artifacts only** (`artifacts/refactor/phase-15/**`). No product code.
- `f255b8b`: **artifacts only** — `gate.json` (+130), `release-manifest.json` (+124). No product code.
- `04fdbd7`: for the two files its own body names, blobs are **unchanged** from `f255b8b`:
  ```
  scripts/refactor/run_phase15_benchmarks.py  @f255b8b = @04fdbd7 = 2a8027db214879fb8174315778f44ff347faae4f
  services/generation-service/app/config.py  @f255b8b = @04fdbd7 = 358967457aba1a8039179001de420850e6b16e20
  ```
  Its substantive diff is 489 files / +51396 / −125 under `artifacts/**`, plus `AppHost/Program.cs` (−15) and `.gitignore` (+1).

### 5.1 `AppHost/Program.cs` — generation-service wiring REMOVED (corrected)

**This is NOT net-zero against the correct base `7a4d0e7`.** Blobs:

```
7a4d0e7 : 22061362ac8ed2fbe717af3ee59a869f3e8c982b   (local base — HAS generation-service wiring)
1ea298a : b8015a394cab64810b7fa8be1f7709eb8a62b065
f255b8b : b8015a394cab64810b7fa8be1f7709eb8a62b065
04fdbd7 : cba010e84717516c757790bd24b3467241f9db39   (identical to origin 56d060d)
56d060d : cba010e84717516c757790bd24b3467241f9db39
```

`git diff 7a4d0e7 04fdbd7 -- AppHost/Program.cs` → **`14 deletions(-)`**, removing:

```csharp
// ── Generation Service (Python reading paper generator) ────────────────────
var generationService = builder.AddDockerfile("generation-service", "../", "services/generation-service/Dockerfile")
    .WithHttpEndpoint(targetPort: 8080, name: "http")
    .WithBindMount("../services/generation-service/app", "/app/app")
    .WithEntrypoint("uvicorn")
    .WithArgs("app.main:app", "--host", "0.0.0.0", "--port", "8080",
              "--reload", "--reload-dir", "/app/app")
    .WithComposeEnvFile("ai");
…
exam.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));
exam.WithEnvironment("GENERATION_SERVICE_URL", generationService.GetEndpoint("http"));
exam.WaitFor(generationService);
```

`04fdbd7` reverts this file to the **origin** version, i.e. it **drops the generation-service from the Aspire resource graph** and removes the exam-service wiring that points at it. The earlier `-15` figure counted only the `1ea298a`→`04fdbd7` step and is not the delta vs the local base.

**Chosen: KEEP LOCAL for this file — do NOT take VPS.** Taking the VPS version would silently remove generation-service from local dev orchestration. This is a deliberate decision for the coordinator, not an automatic merge. Local is additionally **LOCAL-DIRTY** here.

### 5.2 Self-declared open defect (verbatim from `04fdbd7` body)

> "test_t06/test_t08/test_t09 shared helpers were reconstructed after a rebase overwrote the untracked originals; the suite on this branch is **72 failed / 630 passed**, of which ~26 are environmental (exam-service not on :5099, docker exec unavailable). **Recover the original helper files rather than reconstructing further.**"

Contradicted by `v2rate-root-cause-and-fix-log.md` §5 which claims at the current tree **6 failed / 701 passed / 42 skipped**. **Main independently verified neither number is a real baseline:** `707` = 701 passed + 6 failed from the fix-log milestone table (`v2rate-root-cause-and-fix-log.md:300`), and `702` appears only as a passage word-count in `logs/generation-service.log:103454`. Measured collection counts: **local 250 tests / 18 modules; VPS `04fdbd7` 728 tests / 59 modules. Post-merge target = 728.**

## 6. VPS uncommitted working-tree edits (in no commit; NOT in the recovery worktree)

Both captured verbatim in `B_commit_lineage.md` §6. Neither is product code.

### 6.1 `tests/test_t06_loop_runtime.py` (64-line diff) — **TEST HELPER, OWNED BY THE LOCAL-SIDE AGENT**

| VPS working tree | Local `7a4d0e7` committed |
|---|---|
| `simulated_run_profile(policy)` returns full cap snapshot `{caps, profileVersion, profileSource}` built from `LoopPolicy.RESOURCE_CAP_FIELDS` with int coercion (wall-time floats coerced, not `300.0`) | 1038 lines; bare-budget shape |
| `policy_for_profile` → `LoopPolicy.from_cap_snapshot(profile, **overrides).model_copy(update={"required_evaluator_ids": …})` | manual `LoopPolicy(**caps)` |
| `DurableStore.__init__` stores `run_profile` **verbatim** | folds a bare budget into a base policy snapshot |

Contract: `from_cap_snapshot` rejects anything else ("Pinned cap profile lacks required runtime caps"); the runtime refuses to resume a run without one; tests widen via `profile["caps"][...]`. `stash@{0}` also carries `test_t08_passage_loop.py` and `test_t09_real_postgres_durability.py` changes.

### 6.2 `artifacts/refactor/phase-07/local-dev-test-confusion-matrices.json`

`metricEngineVersion 2.3.0 → 2.3.1`, `metricEngineHash e71b3c0e247f8430 → 96d2ba2c214fd39a`, refreshed confusion distribution (`semanticFalsePositives 0→2`, `operationalRejectionsOfValid 20→10`, `totalValidRejected 20→12`, `falseRejectionRate 0.0→0.0333`, `totalValidRejectedRate 0.333→0.2`, per-type `tn 10→9 / fp 0→1` on two types).

**Conflict with a sibling artifact:** `release-manifest.json` at HEAD declares `metricEngineVersion 2.3.1` / `metricEngineHash a958e94e77341398` — same version, **different hash**. The matrix was regenerated after the manifest freeze. Do not adopt silently.

## 7. Carry-forward summary

| # | Change | Classification | Action |
|---|---|---|---|
| 1 | 42 changed `app/**` files (RC-1…RC-17 blast radius) | **SUPERSEDES** (21 also LOCAL-DIRTY) | Take VPS; three-way the 21 dirty ones |
| 2 | 56 added `app/**` files | **ADDED** (no local equivalent) | Take VPS |
| 3 | 0 deleted files | — | Nothing to carry |
| 4 | `f56a097` BaseEvaluator regression test | **BEHAVIOR-PRESERVING** | Test-only; reconcile with LOCAL agent |
| 5 | RC-6 salvage gates / RC-8 routing / RC-7 fail-closed resync / RC-13 scope escalation | **MUST NOT be weakened** | Take VPS verbatim |
| 6 | RC-3/RC-4 fingerprints + final-slot redirect | **SUPERSEDES**, no cap raised | Take VPS |
| 7 | RC-17 first-draft live head | **SUPERSEDES** | Take VPS (new file) |
| 8 | RC-12 punctuation-boundary relaxation | **SUPERSEDES**, fuzz-bounded (120 widened / 0 narrowed) | Take VPS |
| 9 | RC-14/RC-16 generator guards | **SUPERSEDES**, one bounded re-ask each | Take VPS (new files) |
| 10 | Harness integrity suite | **SUPERSEDES**, empirically confirmed by Main's SQL self-join | Take VPS |
| 11 | config defaults (`groq_model` 20b→120b, reservations ×6/×10/×10, wall 30→60) | **REVIEW** | Confirm intent before carrying |
| 12 | `AppHost/Program.cs` net-zero | **CONFLICT (net-zero)** | VPS contributes nothing; local's dirty edit is sole non-base variant |
| 13 | VPS uncommitted `test_t06` helpers | **TEST HELPER — other agent** | Hand off verbatim |
| 14 | VPS uncommitted phase-07 matrices | **uncommitted artifact** | Do not adopt; hash mismatch vs release-manifest |

## 8. Commits created by this agent

**None.** Branch `refactor/recovery-vps-product` was created pointing at the existing VPS HEAD `04fdbd714eb4d9c71b6cf2d0a7985dea83286e4d`. No product-code edit was made — this deliverable is analysis only. The six `artifacts/refactor/recovery/*` files are written as untracked files inside the worktree, deliberately uncommitted so the coordinator can review before anything lands.