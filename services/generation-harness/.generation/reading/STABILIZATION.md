# Latest 13Q workflow stabilization — offline evidence

## Scope / provenance

Analyzed the latest matching 13Q parent session, **not** the older run in PERFORMANCE.md:

`.runtime/reading/sessions/2026-10-31T06-56-24-810Z_01a190be-c8ea-7626-88a7-24e2ca2dd610.jsonl`

SHA-256: `dc83aaa82e456cfe213d0cfc17e3ff26f05d3e1e00cf4930ca192e8f511dcb04`.

Read the parent, its matching 13 native child `run-0/session.jsonl` files, child metadata, saved reviews, and artifacts. Transcript mirrors and async notification mirrors were excluded from usage totals. All runtime evidence is local; reproducible artifact fixtures are under `test/fixtures/`.

Preserved the pre-existing dirty tree. No Core/SDK/Subagents package, contract, dependency, model or tool inventory changed. No new agent, tool, coordinator, orchestration loop or retry engine. No live provider requests, database operations, commits or pushes.

## Historical measurements (not an after benchmark)

Request at **06:57:38.203Z**, final reply at **07:50:03.250Z**: **52m25.047s**. Session creation was 06:56:24.810Z; that extra startup/user-input interval is not generation time.

| Recorded metric | Parent | Parent + 13 children |
| --- | ---: | ---: |
| Model response records | 40 | 376 |
| Request duration sum | 513.651 s | 3,094.361 s |
| Uncached input tokens | 223,543 | 1,510,018 |
| Output tokens | 60,747 | 353,325 |
| Cached input reads | 3,375,157 | 21,450,633 |
| Total recorded tokens | 3,659,447 | 23,313,976 |
| Tool calls / errors | 70 / 3 | 667 / 168 |
| Exact repeated calls within each session | 8 | 18 |
| Argument JSON bytes | 92,240 | 652,148 |
| Result text bytes | 455,286 | 3,764,734 |

Usage is provider-recorded repeated request usage, not unique context size. Durations are recorded requests, not isolated inference; child sums can overlap, and interrupted provider work is not necessarily fully represented. Child request duration sum: **2,580.710 s**; summed child message wall spans: **2,632.370 s**. Neither is a latency saving opportunity in its entirety. Parent latency median/p95/max: **8.840/36.025/75.049 s**. One parent compaction. First-tool-name acceptance across sessions: **82/101**, including UNVERIFIED, not semantic PASS.

Across the run: 99 evidence calls, 62 parity calls, 51 standalone Question validations, 19 Exam validations, 39 spec retrievals, 24 matching builders, 17 single-choice builders, 12 completion builders, 8 short-answer builders and 4 multiple-choice builders. Native subagent arguments alone transferred **69,507 bytes** in the parent, often restating entire role protocols and expected answers. These are byte measurements, not token estimates.

## Root causes and evidence

1. **Question record count was mistaken for independent IELTS marks.** At **07:05:12.259Z**, the first question-author's Exam report had **13 Questions / 26 slots / 13 scoring units**, overall UNVERIFIED. The designer's first matching repair reduced this to **18 slots**, not 13; the parent then announced structural PASS at **07:11:36.817Z**. At **07:11:17.067Z**, the canonical report already exposed 18 slots/13 units and IELTS_SCORING_CONFLICT. The domain deliberately warned rather than banning valid practice structures. A 13-mark pilot needed an explicit stricter acceptance qualifier, not changes to canonical scoring or builders.
2. **Designer-generated ownership instructions caused real hierarchy errors.** The **07:02:29.576Z** handoff demanded both full grouped Questions and the same flat section Questions. The author got **26 records / 52 slots** and SECTION_MEMBERSHIP_CONFLICT before removing the duplicate list. These were correct validator failures, not a validator bug. Guidance now explicitly requires one owner per Question.
3. **Typed argument failures were misdiagnosed as broken specialist tools.** There were **69 evidence errors**: 25 in semantic r3, 24 in semantic r5, 9 in the early matching repair, 11 in the r3 author. **68/69** failed calls supplied at least one offset as a string. Example: semantic r5 child `2c02a536-de20-4dbc-8405-bb2525e43efd`, **07:41:22.513Z**, call `call_2f9e50c33d0542b78cb6dc40`: `start:"374", end:"446"`. Its native result at **07:41:22.521Z** had contractHash=null and NATIVE_ARGUMENT_INVALID: the domain never ran. Parent numeric calls worked. No offline evidence establishes an upstream Core/provider serialization defect. The fix preserves rejection, adds exact offset-field diagnostics and directs deterministic numeric JSON/file references instead of shape sweeps.
4. **Native delegation misuse and infrastructure failures added work.** Initial passage child `d2d52b73...` failed with provider **500** at **07:01:05.127Z**, leaving passage.md; the next child completed only assembly rather than reauthoring the passage (appropriate reuse). The first semantic child `1f705b90...` exited 1 without domain tools. At **07:23:02.024Z**, the parent issued two sibling subagent calls in one turn; the examiner was rejected at **07:30:18.833Z**: “a subagent call is already in progress. Issue exactly ONE subagent call per turn.” A later standalone examiner launch repeated the handoff. The first native parallel pair also used bg_wait for **248.670 s** instead of native completion wake. Protocol now specifies one parallel call, explicit fresh contexts, native wakes and returned file-only output paths. Provider 500s are preserved as infrastructure blockers, not patched speculatively.
5. **Repairs and review churn exceeded the intended bound.** There were 2 passage children, 5 question-author children and 6 reviewer children (one reviewer failed). At **07:35:15.392Z**, the parent started another repair despite both r3 reports claiming no blockers, partly for cosmetic/dead-option preferences. At **07:38:28.874Z**, a further r4→r5 child restored word-limit lines removed in r4. The cited WORD_LIMIT_CONTEXT_UNAVAILABLE came from standalone validation without group instructions, not proof that the containing Exam lost its instruction. Existing Exam validation already checks inherited context. Instructions now count rollbacks in the two-material-repair bound, avoid cosmetic regeneration, and avoid triplicating unchanged builder/Question/Group/Exam checks.
6. **Repeated grading failures could not establish missing backend evidence.** All **62 parity calls failed**, many repeating local non-UUID identities. Final examiner `68e910de...` made **18** probes. Missing verified backend identities, actual .NET execution and answer-state round trips are shared limitations; changing Question content or repeatedly varying wire shapes cannot supply them. Existing role instructions are reinforced to report the limitation once without fabricating UUIDs.
7. **Reports existed, but “content PASS” was not defensible independent quality evidence.** Both final r5 reports carry the full correct artifact hash, but both status values are **UNVERIFIED**. Native metadata says `acceptance.status/evidenceStatus=attested`, not host-verified semantic evidence. The final semantic task at **07:40:38.695Z** supplied all expected keys, repeatedly saying answers “must be” specific values; final examiner instructions at **07:45:26.372Z** also dictated expected keys. Fresh context alone does not undo that priming. Semantic r5 had **24 failed evidence calls and zero successful native EVIDENCE_SPAN checks**; parent successes cannot replace independent specialist execution. Its report explicitly permits a defensible Not Given alternative for q07's most/every inference but labels it EDITORIAL. That is a material ambiguity, not evidence of quality PASS. New protocol requires neutral tasks, full hashes, reviewer/run/session provenance, per-item verdicts and actual toolCallIds/check outcomes cross-checked against native records. Missing, stale, primed or unverifiable evidence blocks **quality PASS**, not just publication.
8. **An offline test overstated what its faux provider proved.** The previous superpowers fixture emitted “verified and ready” for 13 records containing 15 slots and scripted PASS reviews that checked only one item. Its repair fixture did not save a repair (shared faux role counter skipped the n=0 branch) and used noncanonical uppercase truth labels. The revised tests exercise actual pilot rejection, actually persist/validate a targeted repair, and explicitly stop BLOCKED/UNVERIFIED instead of certifying faux semantic claims.

## Activation / native capability verification

- The actual parent read using-reading-superpowers at **06:57:41.493Z**, then the other three skills at **06:57:43.844Z**. However, the user message already contained the invoked skill. This run does **not** prove autonomous skill activation from a plain generation request.
- All 13 child metadata files identify the expected specialist and the correct two role-specific skills: authoring+verification for authors; quality-review+verification for reviewers. All four profiles replace coding context, disable inherited global/project/skill context and default fresh. Direct launches explicitly requested fresh; native CLI regressions exercise fresh child contexts, allowlists and coding-mode isolation offline.
- Specialists actually executed native builders/checks; not every required check succeeded. Semantic's attempted grading tool was unavailable under its allowlist, as intended. No custom scheduler or new execution substrate is warranted.
- Config/CLI tests establish discovery and scripted skill loading, **not autonomous model behavior or blind filesystem isolation**. Full-context forks are not used to “optimize” away independent review.

## Minimal changes

Paths relative to `.generation/reading/` unless stated:

- `support.ts`, `domain.ts`, `tools.ts`, `hierarchy.ts`: optional boolean **pilot:true** on existing validate_exam; require complete=true, exact embedded nonblank passages, 13 Questions/slots/units and one slot/unit per Question. Unsupported multi-target matching, Choose TWO/multiple selection, multi-blank and ordering structures fail this qualifier; ordinary canonical practice validation/builders remain unchanged. Canonical hierarchy/structure claims stay separate from pilot policy rejection. No coercion. Offset wire errors now identify `/evidence/start` and `/evidence/end` (including arrays).
- `SYSTEM.md`, existing `agents/{question-author,semantic-checker,ielts-examiner}.md`, four existing `skills/*/SKILL.md`: scoring preflight, neutral/verifiable independent review, one native parallel call, compact persisted outputs, deterministic numeric evidence, explicit stop bounds and context-aware validation.
- `bench/artifact-replay.mjs`: extend the existing finite offline replay to recorded evidence calls, not a generation coordinator.
- `test/stabilization.test.mjs`, `test/superpowers.test.mjs`, `test/fixtures/*`: focused native regressions, frozen exports/evidence and accurately labeled r2 scoring reconstruction. Tests never execute historical scripts.
- `README.md`, this report: qualifier usage, measured evidence and limits. Pre-existing work elsewhere in the dirty tree was not attributed to this change.

## Artifact replay / before-after evidence

The final r5 **exam.json is unchanged**, SHA-256 `a5b092d9219a5a43d922b087bb0cca8036f4ad4c2278d54cbd17d2d1bd94e5f3`. It includes the passage in `sections[0].passageMd` and canonical private answer fields. Native Exam traversal checks all contained Questions and Groups: **13 STRUCTURE PASS checks, hierarchy PASS, 4 groups, 13 Questions/slots/scoring units, PILOT_13_MARKS PASS**. Overall status remains UNVERIFIED for semantic/consumer evidence. The frozen regression copy is `test/fixtures/pilot-r5.json`; the original handoff remains `.runtime/reading/workspace/run-01/exam.json`.

| Saved artifact | Ordinary canonical check | New explicit pilot gate |
| --- | --- | --- |
| Older Rewetting export, missing passage | hierarchy/structure PASS, 13 slots/units; overall UNVERIFIED | FAIL: PILOT_PASSAGE_REQUIRED |
| Retained r2 builder's scoring reconstruction | hierarchy/structure PASS, 18 slots/13 units; overall UNVERIFIED | FAIL: PILOT_MARK_COUNT + PILOT_UNSUPPORTED_SCORING_STRUCTURE |
| Byte-identical r5 | hierarchy/structure PASS, 13 slots/units; overall UNVERIFIED | Mechanical PASS; quality still UNVERIFIED |

The original mutable r2 file/backup was deleted by the historical author; reconstruction uses its retained, inspected builder in a selected disposable temp directory, with r5 passage/metadata and complete=true. It is **not** represented as a byte-identical r2 snapshot. See fixture README for exact provenance.

Same final r5 evidence replay through the native tool path with in-memory faux credentials:

| Metric | Historical r5 semantic inputs | Saved numeric span references |
| --- | ---: | ---: |
| Calls / failed calls | 24 / 24 | 13 / 0 |
| EVIDENCE_SPAN PASS checks | 0 | 16 across 13 Questions |
| Argument JSON bytes | 9,008 | 6,110 |
| Result text bytes | 19,958 | 66,119 |
| Provider tokens / child launches | 0 / 0 | 0 / 0 |

Both inputs use the patched boundary; “before” means recorded malformed inputs, **not** old-source execution or a new provider run. Larger successful reports are expected. The saved evidence is author working material: exact spans (including NOT GIVEN context) do not prove entailment, absence, independent review or IELTS quality. Single offline timings are deliberately not a latency-improvement claim. No live before/after latency, token savings, autonomous call reduction or quality improvement has been measured.

## Verification

Red-green: the initial three focused regressions failed for missing pilot support and generic offset diagnostics before the implementation, then passed. Additional fixture/native-replay regressions preserve the observed failures.

Fresh final verification (GENERATION_HARNESS_OFFLINE=1):

- `npm test`: root **87/87 PASS**; Reading **146/146 PASS**; Subagents **3,491 PASS, 13 skipped**, zero failures across all three suites.
- Focused stabilization regressions: **5/5 PASS**, including the actual malformed-call replay and all three saved papers.
- `npm run typecheck`: PASS, including Subagents; the Reading suite also executes its own TypeScript check.
- `git diff --check`: PASS.

An intermediate repair-fixture run failed on canonical truth-label casing; correcting the fixture to True/False/Not Given made the real saved repair structurally valid. No validator was relaxed. Offline PASS is not IELTS-quality evidence.

Reproduce from `services/generation-harness/` (all imports use the repository offline network/credential guard):

```sh
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/native-trace.mjs \
  .runtime/reading/sessions/2026-10-31T06-56-24-810Z_01a190be-c8ea-7626-88a7-24e2ca2dd610.jsonl
GENERATION_HARNESS_OFFLINE=1 node .generation/reading/bench/artifact-replay.mjs --evidence \
  .runtime/reading/sessions/2026-10-31T06-56-24-810Z_01a190be-c8ea-7626-88a7-24e2ca2dd610/2c02a536-de20-4dbc-8405-bb2525e43efd/run-0/session.jsonl \
  .runtime/reading/workspace/run-01/exam.json .runtime/reading/workspace/run-01/evidence.json
GENERATION_HARNESS_OFFLINE=1 node --import ./test/offline.mjs --test .generation/reading/test/stabilization.test.mjs
GENERATION_HARNESS_OFFLINE=1 npm test
GENERATION_HARNESS_OFFLINE=1 npm run typecheck
git diff --check
```

## Remaining blockers

- **No quality PASS.** r5 needs genuinely independent, neutral, successful Semantic Checker and IELTS Examiner reports. q07's alternative-answer risk must be resolved as a material issue; the old reports cannot be relabeled PASS. No live review/repair was authorized here.
- No verified backend UUID map, actual .NET scoring/normalization or answer-state round-trip evidence; no publication/delivery certification.
- Pilot mechanics are enforced when **pilot:true** is invoked. Ordinary practice support is intentionally preserved; the profile instructs pilot invocation. Skill activation, neutral handoffs, transcript audit and repair bounds remain model-directed policies, not a new hidden runtime/quality coordinator. Offline scripted tests cannot prove future provider compliance or stop arbitrary unsupported free-text claims.
- Automatic skill invocation from an unadorned real request, provider-side malformed-argument origin, live after tokens/latency and autonomous review counts remain unmeasured. No speculative Core/provider optimization was applied.
