# Remaining-bug verification checkpoint

## Automatic Reading Superpowers implementation

### Architecture and deliverables

Implemented a fully automatic, skill-driven IELTS Reading generation workflow using native Pi/Subagents capabilities without a custom coordinator, scheduler, or Core rewrites:

- **Four Minimal Skills** (`.generation/reading/skills/`):
  - `using-reading-superpowers`: Automatic entry upon any Reading generation request, orchestrating the 5-phase workflow (Passage Authoring -> Question Authoring -> Quality Review -> Targeted Repair -> Verification Gates) and enforcing completion criteria.
  - `reading-authoring`: Academic register and structural guidelines for passages; canonical builder usage (`create_*`), `get_question_spec`, and strict separation of student-facing content and answer keys.
  - `reading-quality-review`: Independent semantic verification of factual entailment, UTF-16 evidence spans, and answerability; independent IELTS Academic examination of task authenticity, difficulty progression, distractors, and scoring parity.
  - `reading-verification`: 6 completion gates checklist (structure, evidence, delivery projection, parity, reviews, artifact preservation), targeted repair routing to the responsible author without restarting successful stages, and fail-closed stop rules (max 2 repair rounds).
- **Four Specialized Native Agents** (`.generation/reading/agents/`):
  - `passage-author`: Authors authentic academic passages grounded in topic and section requirements; saves initial structure in `exam.json`.
  - `question-author`: Derives canonical questions from the established passage using native builders (`create_*`), validates exam structure.
  - `semantic-checker`: Fresh-context independent reviewer verifying factual entailment, UTF-16 evidence spans, and answerability.
  - `ielts-examiner`: Fresh-context independent examiner evaluating authentic task design, difficulty progression, distractors, and scoring parity.
- **Exam Designer Role** (`.generation/reading/SYSTEM.md`):
  - The parent agent acts as Exam Designer, orchestrating the specialized agents via native `subagent` calls.
  - Automatically executes `using-reading-superpowers` without manual skill commands.
  - Enforces sequence (passage authoring precedes question creation) and independent fresh-context reviews.
  - Routes targeted repair findings to the responsible author and revalidates without restarting successful stages.
- **CLI and Bootstrap Wiring** (`scripts/runtime.mjs`):
  - Automatically loads the 4 Reading skills via `--skill` flags into the parent context.
  - Seeds `settings.json` with `defaults.skills = [skillsDir]` and `defaults.subagents.agentScanDirs = [agentsDir]`.
  - Isolates Reading profile from ambient coding extensions, context files, and skills.
- **Verification Suite** (`.generation/reading/test/superpowers.test.mjs`):
  - Proves automatic entry, 4 skills registration, 4 agents discovery, and coding mode isolation.
  - Exercises full 13Q multi-agent workflow offline with mocked model responses.
  - Verifies rejection, targeted recovery, and revalidation without restarting passage authoring.
  - Verifies completion gates block publication and stop with `BLOCKED` when quality cannot be established.


## Minimal generation reliability patch (current)

### Evidence and fixes

Inspected `.runtime/sessions/2026-10-30T10-11-53-593Z_01a18c4b-6479-7614-87b0-62de4ec2c2b3.jsonl` plus the earlier `04-52-23-971Z` and `10-01-28-426Z` sessions. The main trace has 39 results across the four affected tools: spec 10 PASS/3 FAIL, Exam 0/9, Group 0/9, Question 0/8. All 39 reached domain execution: 10 PASS and 29 FAIL, not unknown-tool/native invocation failures. First observed domain call for each tool failed (0/4). Actual arguments include PascalCase type names, empty/stringified objects, `{item:...}` collections and quoted numeric/boolean fields. The seven declarations used empty property schemas `{}`. Code inspection also confirmed that the old Reading alias kept the default SWE prompt and repository CWD/context discovery. The main trace itself used an explicit Reading prompt; coding persona is therefore not established as its tool-failure cause. Missing schema guidance is a verified defect; live causal improvement is not established without another model run.

- `scripts/runtime.mjs`: select Reading using native CLI flags, separate `<runtime>/reading/` state/workspace and native settings seeded once. No project trust/context/skill/ambient extension discovery; explicit Subagents, Reading and config extensions remain. Default coding launch is unchanged.
- `SYSTEM.md`, `settings.json`, `agents/{semantic-checker,ielts-examiner}.md`: minimal author rules, no SWE builtins, native advertised specialists with fresh contexts, replace prompts, no inherited coding context and explicitly loaded Reading tools. Both review findings must be preserved; no workflow/coordinator or sandbox claim.
- `tools.ts`: shallow JSON types plus compact wire-shape descriptions (no duplicate canonical schema). Typed native argument errors retain sanitized actionable `NATIVE_ARGUMENT_INVALID` reports and state that no domain validator ran. Dependency ERROR explicitly says no verdict was produced. Existing canonical diagnostics and native error fallback remain intact.
- `question.ts`: explicit UNVERIFIED `IELTS_SCORING_CONFLICT` diagnostic for multi-slot/all-or-nothing scoring; no backend or canonical changes.
- `test/reliability.test.mjs`, existing native/config-restoration tests: trace-derived regressions, preparation/domain/infrastructure distinctions, array compatibility, unsupported readiness-field rejection, both actual CLI profiles, native discovery, child permissions/history, and finite 13Q authoring/review simulation. README files document startup and limits.

### Offline execution and measurements

- Re-executed `npm test`: harness **87 passed**; Reading **124 passed**; Subagents **3491 passed / 13 skipped**. Agent core: **99 passed**. Build, root/Reading typechecks, smoke and diff check passed. The focused suite was rerun after adding earlier trace variants. No Core/Subagents package changes.
- The real `npm run start:reading -- ... --mode json -p ...` launch wrote a disposable 13Q artifact and invoked Question (13), Group and Exam validators, specs, evidence, projection and grading tools. Native `subagent` discovery listed only the IELTS roles; both ran in fresh foreground native sessions with distinct tool allowlists and without parent history. Native RPC startup and `/config` also passed. Planted workspace coding instructions, SWE agents and an ambient extension were not loaded by Reading. Actual `npm start` execution verified the coding prompt/tools and absence of Reading tools. No compat-agent substitute was used for the CLI simulation.
- Simulation: **22/22 first-attempt Reading calls** accepted without FAIL/ERROR (**1 PASS, 21 UNVERIFIED**), **28/28 total tool calls**, **31 faux provider requests**, no retries. All Reading reports carried the pinned canonical hash, and every validator invocation included a canonical STRUCTURE PASS. Independent scripted review findings were retained and the final verdict was **NOT READY**. Repeated items/tiny passage intentionally prevent a quality-success claim. This is execution-path evidence, not a live model reliability or semantic-review score; it is not comparable as an A/B model experiment with the trace's 0/4 first attempts.
- Finite benchmark (five warmups/twenty samples, HEAD tool declarations loaded via a disposable module hook vs current tools; domain code held constant): seven serialized definitions **4350 → 6921 bytes** (+2571). Registration still performs **zero** contract/vector/source reads or schema compiles. First and concurrent-first use each read/parse the canonical contract once. Local warm Question median 0.0963 → 0.1239 ms; 100Q Exam 4.4181 → 4.9183 ms; single-process samples are noisy diagnostics, not a performance or real-model reliability claim. Actual Reading parent declarations: 11673 bytes / prompt 2745 bytes; semantic child 4622 / 4376; examiner child 4591 / 4448 (native runtime adds child boundary instructions).
- Logs: `/tmp/langfens-reliability-{tests,focused,agent-tests,typecheck,build,smoke}.log`, `/tmp/langfens-reliability-overhead-{before,after}.json`. Test artifacts use disposable directories and are removed; pre-existing `.generation/artifacts/` is untouched.

### Remaining UNVERIFIED

No live provider calls were made. Real-model first-attempt reliability, authoring quality, specialist judgments and compliance with readiness rules remain unverified; prompts do not enforce arbitrary model prose. Actual .NET grading/normalization, frontend lifecycle and deployment compatibility remain source-only/unverified. No Reading-specific live TUI/provider or detached-child inference was tested; CLI JSON/RPC startup and foreground native execution were tested. Fresh context and tool permissions are not OS sandboxing or blind solving. No publication, deployment, credentials migration, commits or pushes.

## Implemented

- **P1-01**: admin create/update accepts and persists optional `GroupId`/`WordList`; rejects missing/cross-section groups before mutation. Null clears these optional fields on update. No schema migration needed. Public HTTP, internal HTTP and protobuf share `ExamDeliveryLayout`: explicit membership wins; only rows without GroupId may use unambiguous legacy bounds. Ambiguous/unassigned rows survive once in a synthetic group; source entities are not renumbered/mutated.
- **P1-03**: public projection strips composed/repeated Markdown quote/list/heading prefixes before checking explicit private annotations. Safe generic Answer(s) directions remain allowed; detected payloads never appear in diagnostics/results. This is finite annotation screening, not semantic privacy proof.
- **P1-11**: legacy `List of Headings` without a colon is accepted while complete bank equality remains enforced. Existing colon presentation, including inline headers, is retained.
- **P1-12**: published public REST adds `flowChartNodes` with key/label only. Key-sorted bank output is independent of solution sequence; internal/protobuf banks use the same ordering policy. No private grading fields are added to public delivery.
- **P2-08**: Which TWO/THREE/numeric count forms participate in multiple-selection cardinality checks and ambiguity detection.
- Source fingerprints refreshed against the working tree (base revision identified separately); canonical schema unchanged. Canonical-vs-backend null-clearing divergence is documented rather than changing the canonical contract.

## P1-06 / authorized minimal SDK exception

The operator explicitly authorized a scoped Core patch for this session. Added optional `formatPreparationError(error,args)` to the public tool types and preserved it through both tool-definition adapters. The existing preparation catch can now retain sanitized text/details/structuredContent while forcing `isError:true`; rejection still skips execution and does not re-enter hooks. Ordinary tools and missing/undefined/throwing formatters retain the original text-only error. No loop rewrite, validation relaxation, new runtime or package dependency.

Reading opts in using its existing argument checker. Regression tests cover preparation and schema-validation exceptions, forced error status, formatter fallback, sequential/parallel native loops, both adapter directions, and factory/explicit/discovery extension loading. Latest offline results: **99 agent-core tests passed**, root harness **87 passed**, Reading **121 passed**, Subagents **3491 passed / 13 skipped**; build/typecheck/smoke and diff check passed. Logs: `/tmp/langfens-p106-*.log`. Transcript structuredContent retention and OS sandboxing remain outside this patch.

## P1-02 / integration gate

Existing legacy lifecycle regression cases remain green. An additional offline producer-to-consumer gate maps a real exam entity with stale group bounds through `ProtoHelper`, persists the resulting snapshot, then exercises attempt resume, public redaction, autosave, Submit, grading, result and snapshot immutability. Public/internal TestServer delivery is also compared with protobuf membership and paper-wide indices. All stores are explicitly disposable InMemory databases; no service startup migrations, real databases or providers are involved.

A subsequent source-only Luna review reported one public flat-question compatibility finding. Parent verification against base HEAD rejected it as a false positive: the unchanged exam-service normalizer already cleared flat questions before returning the old endpoint response. No additional actionable finding was reported. Luna did not independently run tests, and has not reviewed the later P1-06 patch. Offline integration success is not live PostgreSQL/frontend/provider evidence or permission to deploy.

## Earlier backend-phase offline checks (before P1-06)

- `dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-restore`: **273 passed**, 0 failed.
- Reading tests (including strict TypeScript check and fingerprint drift check): **120 passed**, 0 failed.
- Harness build and root typecheck: **PASS**.
- Full offline `npm test`: root harness **86 passed**; Reading **120 passed**; Subagents **3491 passed, 13 skipped**, 0 failed.
- Smoke with `--import ./test/offline.mjs`: **PASS**.
- Finite offline overhead benchmark: **PASS**; 5 warmups / 20 samples, declaration bytes 4350, zero contract/vector/source reads or schema compiles at registration; one contract read/parse at first use (including concurrent first use). Timing is local diagnostic evidence only.
- `git diff --check`: **PASS**.

Logs for this session are under `/tmp/langfens-bugfix-*.log`; benchmark output is `/tmp/langfens-bugfix-overhead.json`. Existing NuGet vulnerability/version, nullable, deprecated TestServer and analyzer warnings remain; they are not caused or resolved by these bug repairs.

## Unchanged exclusions

P1-06 is now repaired under the explicit session-only SDK exception described above; the repository-wide freeze policy was not rewritten. P0-01 remains excluded/current all-or-nothing scoring policy. P1-04 remains unresolved: controlled disposable probes confirmed that absolute/parent-relative/symlink reads and bash can access outside CWD; this patch does not add an OS sandbox. P1-07/P2-01/P2-02/P2-06 were classified as NOT_BUG under the reviewed configuration/canonical/legacy policies and measured declaration budget, and remain untouched. No commit, push, deployment, production mutation or live/paid inference was performed.
