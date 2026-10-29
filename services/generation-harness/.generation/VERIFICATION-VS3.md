# Vertical Slice 3 — full deterministic Reading paper

## Final status

| Check | Status | Evidence |
| --- | --- | --- |
| Exactly 3 Sections, 13 + 13 + 14 | PASS | Configurable fixture requirements; original VS2 Section unchanged |
| Questions / answer slots / independent scoring units | PASS | 40 / 40 / 40; 11 groups |
| All blind answers processed | PASS | 40 correct, 0 incorrect, 0 ungradable; 40 processed / 40 total; 40/40 points |
| Complete-paper validation / student projection | PASS | Native `validate_exam(complete:true)` and exact inspected projection |
| Independent per-Section evidence | PASS | 13 / 13 / 14 canonical spans, two isolated review children per Section |
| Seven native tool registrations and executions | PASS | Native loader, child transcripts and parent tool results |
| Four specialist roles / native child isolation | PASS | 11 actual fresh child sessions through Generation Subagents |
| VS1 / VS2 / all 19 type-level regressions | PASS | Existing Reading tests retained; 30 Reading tests including 5 VS3 tests |
| Root and Subagents typechecks; domain/child-only typecheck | PASS | Exit 0, `/tmp/langfens-vs3-typecheck.log` |
| Offline build | PASS | Exit 0, `/tmp/langfens-vs3-build.log` |
| Harness tests | PASS | 76 passed, 0 failed, 0 skipped |
| Subagents tests | PASS | 3,491 passed, 0 failed, 13 skipped (3,504 total) |
| Relevant .NET regressions | PASS | 73 passed, 0 failed, 0 skipped; no restore |
| Frozen Core / SDK / Subagents and backend source boundary | PASS | Scoped `git diff --exit-code` returned 0 and scoped status empty |
| Final failing tests | FAIL: none | All final verification commands exited 0 |
| Architectural blockers | BLOCKED: none | No frozen implementation changes needed |
| Actual IELTS semantic quality / live inference behavior | UNVERIFIED | Deterministic mocks only; no live inference or publication |

The 13 skipped Subagents tests are not claimed as exercised. Offline PASS is not
production IELTS acceptance, a live-provider result, or publication authorization.
No dependencies were installed, and no commits or pushes were made.

## Implemented boundary and artifacts

- `.generation/fixtures/blueprint-vs3.json` is the caller-configurable fixture
  blueprint, including section sizes and slot expectations. There is no new
  production question-type rotation.
- `.generation/fixtures/paper-vs3.mjs` constructs the deterministic paper, exact
  evidence and predetermined mock answers. Section 1 is deep-equal to the existing
  VS2 Section, including passage, groups, IDs, options and keys. Existing VS2
  evidence and answers are reused unchanged.
- Section 2 has Q14–17 matching headings, Q18–20 truth, Q21–23 summary completion,
  Q24–26 short answers. Its new passage concerns a seed archive.
- Section 3 has Q27–30 writer-view truth, Q31–34 matching information, Q35–37
  sentence completion, Q38–40 single choice. Its separate new passage concerns
  urban sound research. All passages and evidence quotations are distinct across
  Sections; each offset is interpreted only against its own canonical passage.
- Each matching/completion record contains exactly one keyed answer, so a single
  all-or-nothing Question never represents several independently marked answers.
- `validate_exam` adds optional `requirements.sectionScoringUnits` and
  `requirements.answerSlotCount`. VS3 supplies `[13,13,14]` and `40`; they are
  deliberately not universal production rules. The old 14+13+13 structural
  fixture still passes when these requirements are not supplied.
- `verify_evidence` adds an optional `sectionId` selector with `exam`. It validates
  paper-wide structure, then checks evidence and review coverage only against the
  selected canonical Section. A multi-Section exam without a selector still fails
  closed. Existing single-group/groups/single-Section behavior is retained.
- `inspect_delivery_projection` now also rejects known private markers/encodings
  in otherwise public canonical fields, aligning its PASS boundary with the
  existing blind-input guard. Keys are never added to student projections.
- The validator specialist is instructed to preserve caller requirements and use
  `complete:true` for a requested complete paper.

All domain changes stay under `.generation/`; test additions are in
`test/reading-vs3.mjs`, registered by the existing `test/reading.test.mjs` entry.
No coordinator, runtime, pipeline, retry controller or execution engine was added.

## Actual deterministic execution

The test invokes the existing native `executeSubagent` API, not stand-in child
objects:

1. Three isolated `reading-generator` children each receive only their own full
   passage and blueprint. Each invokes native specifications and group validation.
   Their actual returned groups populate the full canonical artifact.
2. One `question-validator` child receives that assembled artifact and caller
   requirements. It performs native complete-paper validation, question validation
   and student projection inspection. Its actual PASS projection is the next input.
3. One fresh `blind-solver` child receives only that exact full-paper projection.
   Its sole tool is the public deterministic `get_question_spec`. The mock returns
   exactly 40 unique question IDs; missing, duplicate and foreign IDs fail coverage
   assertions rather than silently being dropped.
4. Six `semantic-reviewer` children (two per Section) receive only their own
   passage/groups/private key/evidence, without blind output, other passages or
   earlier reviews. Reviewer labels are replaced with native lifecycle session IDs.
5. The existing parent native session invokes `verify_evidence` independently for
   each selected Section, then invokes `check_grading_parity` for every actual
   blind answer. Tests assert three evidence results and forty parity results in
   the parent session, not merely an expected tool-name list.
6. Native complete-paper and exact projection checks pass again on the assembled
   artifact. Persisted disposable child transcripts assert exact handoffs, fresh
   histories, distinct session IDs, native tool results and absence of private
   annotation values in the blind task/context/transcript.

Predetermined faux-provider outputs are intentionally controlled by the test;
this proves native execution, coverage, grading and isolation plumbing, **not**
that a real model generated or independently solved valid IELTS questions.

Final emitted acceptance receipt (abbreviated):

```json
{
  "status": "PASS",
  "mocked": true,
  "semanticQuality": "UNVERIFIED",
  "nativeChildSessionCount": 11,
  "questionCount": 40,
  "answerSlotCount": 40,
  "scoringUnitCount": 40,
  "questionGroupCount": 11,
  "grading": {
    "correct": 40, "incorrect": 0, "ungradable": 0,
    "processed": 40, "total": 40,
    "awardedPoints": 40, "possiblePoints": 40
  },
  "completePaper": "PASS",
  "studentProjection": "PASS"
}
```

## Negative and compatibility evidence

- Missing/duplicated Questions, paper-wide numbering collisions and section,
  group, question and option ID collisions fail deterministic validation.
- Wrong group/Section membership and incomplete papers fail.
- A 39-Question / 40-slot artifact fails independent-unit counts. A 40-Question /
  41-slot artifact fails the caller's slot requirement.
- Invalid choice, matching and completion keys fail. Foreign-Section selected
  option IDs fail ingestion and award zero.
- Foreign evidence IDs, foreign quotations relabelled with local IDs, replaced
  canonical passages, mismatched external passages, missing evidence, foreign
  review coverage and non-independent reviewer IDs all fail.
- Raw, base64, percent-encoded and hex private annotations across Sections, and
  private fields copied into public projections, are rejected before blind model
  invocation. The refusal result does not reproduce the private task data.
- Existing hostile-tool-output redaction, fork cancellation, context override and
  pre-existing-history regressions remain PASS. Arbitrary unmarked natural-language
  answer hints and claimed review provenance cannot be cryptographically proved
  absent/authentic by these structural checks.
- A full forty-answer mixed grading run reports **38 correct, 1 incorrect,
  1 ungradable, 38/40 points**. Wrong-but-gradable answers remain incorrect even
  when they disagree with supplied parity expectations; parity FAIL is distinct
  from inability to grade. Unsupported .NET regex is ungradable, never simulated
  with JavaScript regex. Another forty-answer run with an invalid choice key
  reports **39 correct, 0 incorrect, 1 ungradable, 39/40 points**.
- FLOW_CHART remains backend ordering, explicitly incompatible with standard IELTS
  flow-chart blank completion. No FLOW_CHART item was forced into this paper.
  All 19 shared types remain covered by the existing type-level native tests.

## Reproduce offline

Run sequentially from `services/generation-harness` (build replaces `dist` files
used by child-session tests, so do not overlap build and tests):

```sh
export GENERATION_HARNESS_OFFLINE=1
export NODE_OPTIONS="--import=$PWD/test/offline.mjs"
npm run typecheck
./node_modules/.bin/tsc --noEmit --project .generation/tsconfig.json
npm run build
npm test
# Focused VS3 rerun; five tests, real isolated mock-model children:
node --test --test-name-pattern='VS3' test/reading.test.mjs
```

The final sequential run exited 0 throughout. Logs:
`/tmp/langfens-vs3-typecheck.log`, `/tmp/langfens-vs3-build.log`,
`/tmp/langfens-vs3-tests.log`. The focused run also emits the full acceptance
receipt. Child sessions/runtime directories are disposable and removed by test
cleanup; no repository/shared databases or persistent production sessions are used.
The pre-existing bootstrap purges provider credentials and blocks external network
access. No live inference or external requests were made.

An initial overlapping build/test invocation produced a transient
`ERR_MODULE_NOT_FOUND` for Subagents' `dist/api/preflight.js` while the build was
replacing `dist`. No product fix was made for that invocation mistake. Running
verification sequentially resolved it; the complete final sequential run is the
acceptance evidence above.

From the repository root, after inspecting the mock/pure-helper .NET fixtures
(no DB target or cleanup; explainer HTTP clients use in-memory mock handlers):

```sh
GENERATION_HARNESS_OFFLINE=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
  DOTNET_CLI_WORKLOAD_UPDATE_NOTIFY_DISABLE=true \
  dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-restore

git diff --exit-code -- services/generation-harness/packages \
  services/attempt-service services/attempt-service.Tests \
  services/exam-service services/_shared
git status --porcelain --untracked-files=all -- services/generation-harness/packages \
  services/attempt-service services/attempt-service.Tests \
  services/exam-service services/_shared
git diff --check
```

.NET exited 0; `/tmp/langfens-vs3-dotnet.log` records **73 passed**. The Node network
guard does not instrument .NET; the inspected suite uses pure helpers/mocks, and
`--no-restore` avoids package retrieval. Existing warnings remain: NU1603
(xunit.runner.visualstudio version fallback) and NU1903 (Microsoft.OpenApi 2.4.1
vulnerability). They were not addressed outside this approved boundary.

Scoped source diff exited 0, scoped status was empty, and `git diff --check`
passed. The pre-existing uncommitted VS2 artifacts and regressions are retained.
