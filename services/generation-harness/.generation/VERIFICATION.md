# Reading verification — current VS3 and retained VS1/VS2 evidence

**Latest: [Vertical Slice 3 full-paper verification](VERIFICATION-VS3.md).**
PASS: 3 Sections (13+13+14), 40 Questions/slots/scoring units, 11 native children,
40 correct / 0 incorrect / 0 ungradable, 40/40 points. Final offline checks:
Harness 76 passed; Subagents 3,491 passed (13 skipped); .NET 73 passed;
typechecks/build PASS. No final failures or architectural blockers.
Real IELTS semantic quality remains UNVERIFIED. No commits or pushes.

The VS1/VS2 reports below are retained historical evidence, not current paper scope.

# Vertical Slice 2 — Blind Boundary Security Fix & Multi-Group Section Verification

## Audit Result

- **PASS:** tested blind-input boundary through the dedicated child-only native extension (`.generation/reading/blind-guard.ts`). Direct private fields, tested nested/encoded payloads, malformed projections, unknown question types and pre-existing history are rejected before native model invocation. Only schema-valid student projection tasks and exact static public specification results are accepted.
- **PASS:** deterministic multi-group section acceptance criteria (13 questions, 3 question groups, 4 independent counts = 13/13/13/3).
- **FAIL:** 0 test failures across all executed suites.
- **BLOCKED:** none. No Core, SDK, Subagents, or backend modifications made.
- **UNVERIFIED:** authentic IELTS semantic question quality, live-model behavior, publication, and deployment remain strictly unverified (offline deterministic plumbing and mock tests only).

## Final direct verification (supersedes earlier review receipts)

The parent reproduced the `question.type` leak through an actual native child:
`type-bypass-before.log` records the model being invoked with a private type value.
The fix replaces permissive hand-written field checks with strict TypeBox public
schemas using the existing 19-type enum, positive integer indices, required fields,
and recursive string checks. There is no new runtime or coordinator.

The previous tool-result blacklist was replaced with exact allowlisting of the
existing `get_question_spec` result. A hostile test-only extension poisons an
actual tool result; the next native model call observes only a redacted error,
never the injected answer. Pre-existing transcript messages are refused at the
input boundary, not scanned heuristically for secret prose. Tests exercise
`AgentSessionRuntime.fork()` cancellation and a real `session.prompt()` against
pre-populated history. The foreground delegation API also rejects explicit
context, tool and system-prompt overrides before launch.

An offline domain TypeScript configuration now includes child-only sources outside
the auto-discovered `extensions/` directory. A regression invokes it, so a green
root typecheck cannot silently omit the blind guard. Original VS1 regressions remain.

Final commands all exited **0**; logs are local evidence under `/tmp/ielts-vs2-audit/`:

| Check | Evidence | Log |
| --- | --- | --- |
| Full typecheck | PASS | `direct-typecheck.log` |
| Child-only/domain typecheck | PASS | `domain-typecheck.log` |
| Full offline build | PASS | `direct-build.log` |
| Root harness, including 25 Reading tests | **71 passed, 0 failed** | `direct-test.log` |
| Native Subagents regressions | **3,491 passed, 0 failed, 13 skipped** | `direct-test.log` |
| Available .NET mock/pure tests, `--no-restore` | **73 passed, 0 failed** | `direct-dotnet-test.log` |
| Separate Reading run | **25 passed, 0 failed** | `direct-reading-test.log` |

The complete Section has **13 questions / 13 slots / 13 marks / 3 groups**; all
13 native blind answers are graded for a total of **13/13**. A separate section
variant has **13 questions / 14 slots / 13 marks / 3 groups** and verifies that a
partially correct two-slot Question scores zero. Persisted Section and evidence
JSON fixtures are checked against the exercised artifacts, preventing fixture drift.

Backend-compatible NEXT LINE whitespace conflicts and case-insensitive duplicate
option IDs are covered. Core/SDK/Subagents and all backend directories have no
tracked or untracked changes; `git diff --exit-code HEAD --` on those paths exited
0, and `git diff --check` passed. No commits or pushes were made. Unrelated existing
`matching-heading-demo.json` and `validate-fixture.mjs` were left untouched.

## Security Fix: Fail-Closed Blind-Input Boundary

The previous characterization test ("blind direct native task currently admits a private answer key") characterized an unsafe task boundary where a direct `executeSubagent` call with private keys in the task string reached the model context. That defect has been resolved:

1. **Dedicated Child-Only Guard Native Extension (`.generation/reading/blind-guard.ts`):**
   - Configured strictly on `blind-solver` via `subagentOnlyExtensions: ../extensions/reading.ts, ../reading/blind-guard.ts` in `.generation/agents/blind-solver.md`.
   - Placed outside `.generation/extensions/` to prevent ambient discovery by `DefaultResourceLoader`. It is loaded only when `blind-solver` is launched as a child session.
   - Operates unconditionally when loaded, without fragile heuristics based on mutable system prompt tags or active tool rosters.
   - Total tool count remains strictly 7 (registered in `reading.ts`); `blind-guard.ts` registers zero tools. Specialist agent count remains strictly 4.
2. **Strict Canonical Student Projection JSON Requirement:**
   - The blind solver rejects all arbitrary plain-text tasks (e.g. `'Answer key: question 6 = aqueduct'`).
   - Only actual canonical student projection JSON is accepted (Exam, Section, QuestionGroup, or array of QuestionGroups).
   - Any unallowlisted property at any level (e.g. `isCorrect`, `blankAcceptTexts`, `modelAnswers`, `explanationMd`, `customKey`) causes immediate fail-closed rejection.
   - All string values are checked for synthetic private-key markers; `type` must be a member of the existing canonical enum, not an arbitrary string.
   - Positive integer indices, required fields and nonempty hierarchy arrays are enforced by TypeBox; malformed JSON and empty tasks fail closed.
3. **Pre-Model `input` & `before_agent_start` Interception:**
   - `api.on("input")`: Intercepts `session.prompt(task)` before any agent run starts. Returning `{ action: "handled" }` completely prevents run initiation, task transcript insertion, and model stream creation (`modelInvoked === false`, `result.status: "failed"`).
   - `api.on("before_agent_start")`: Aborts any run started via alternative trigger paths.
4. **Transcript Context Guard & Fork Cancellation:**
   - `api.on("input")` refuses sessions that already contain transcript messages. Context guards additionally require a single schema-valid user projection at the beginning of the transcript.
   - `api.on("session_before_fork")` unconditionally cancels session fork attempts (`{ cancel: true }`), verified through the actual native runtime fork operation.
5. **Tool Authorization & Result Sanitization:**
   - `api.on("tool_call")`: Authorizes strictly `get_question_spec`. All other tools (`read`, `bash`, `validate_exam`, etc.) are blocked with an error `toolResult`.
   - `api.on("tool_result")`: Accepts only the exact deterministic public result of `get_question_spec`; any other content, details or structured payload is replaced with `[BLIND_TOOL_RESULT_REDACTED]` and `isError: true`. This does not depend on recognizing particular private-key spellings.

## Threat Boundary and Trust Model

The blind boundary validates the public projection schema and restricts transcript and tool sources. It does not authenticate provenance: the caller must require PASS from `inspect_delivery_projection` and pass that exact projection, as the native integration tests do. It cannot prove that arbitrary natural-language text contains no answer hints or establish semantic IELTS quality.
- **Public Text Trust Boundary:** The student-visible passage and prompt texts are treated as untrusted student-facing data. The guard does not claim cryptographic steganography detection for arbitrary answers embedded organically in legitimate natural-language passage text (e.g. the historical occurrence of the word "aqueduct" in the Barbegal passage). It strictly detects and blocks synthetic private property names, private sentinels, encoded payloads, and unallowlisted structured fields.
- **Caller Override Boundary:** A caller using the project's supported agent definitions receives the enforced `blind-guard` extension automatically. If a hostile caller with in-process execution privileges programmatically replaces the `AgentDefinition` in `context.agents` to omit `subagentOnlyExtensions`, the harness runs without the guard. Within the native public ExtensionAPI facilities, this child-only configuration is the supported mechanism for per-agent lifecycle boundaries.

# Vertical Slice 1 — offline audit and verification

## Result

- **PASS:** deterministic/native Vertical Slice 1 acceptance criteria.
- **FAIL:** no remaining failures in the executed suites.
- **BLOCKED:** no architectural or public-API blocker encountered.
- **UNVERIFIED:** real IELTS semantic quality, live-provider behavior, publication and deployment. None were attempted or authorized.

The existing uncommitted implementation was retained and hardened, not restarted.
No Core, SDK, Subagents or backend implementation was changed. No new runtime,
coordinator, workflow engine, retry mechanism, dependency, commit or push was added.

## Verification before changes

The original baseline passed typecheck and build, 55 root harness tests,
3,491 Subagents tests (13 skipped), and 73 existing .NET tests with `--no-restore`.
Those green suites did not prove the application entry point actually loaded
Reading resources or that semantic-review identities came from child sessions.

## Reproduced defects and fixes

1. **Actual application discovery:** launching the original `start:reading` from
   an isolated headless runtime selected the correct cwd but registered no IELTS
   tools. Core's project-trust gate suppressed project resources. The application
   script now passes the existing native `--approve` flag. The test launches the
   real npm script and bundled CLI under the existing network guard, verifies all
   seven tools, and resolves all four specialist configurations through public
   `resolveSubagentLaunchContract`. Explicit `--no-approve` still suppresses the
   tools and rejects project-agent preflight. Trust is for this run; use only a
   trusted checkout.
2. **Grading parity:** failing native-tool regressions exposed missing Guid text
   formats, incorrectly rejected null FLOW entries, inherited JavaScript dictionary
   properties, matching null/empty conflation, JavaScript/.NET whitespace
   differences, and floating-point blank-index sorting. Fixes are confined to
   `.generation/reading/{grading,contracts}.ts`. A temporary compiled C# probe
   invoked the existing backend graders directly and confirmed 14 edge-case
   results; the probe required neither restore nor backend source edits.
3. **Specialist isolation:** definitions now explicitly select fresh context,
   replacement prompts, no inherited project/global context or skills, no ambient
   extensions, and no supervisor/intercom tools. Native launch-contract preflight
   checks the effective configuration, not just markdown text. An actual blind
   child is also tested against unauthorized filesystem and private-tool calls.
4. **Artifact handoff:** the existing mocked test now consumes the generator's
   actual output in the validator, the validator's actual native projection in the
   blind solver, the blind answer in final parity, and two independent reviewer
   outputs in final evidence checks. Reviewer identities are bound to actual native
   lifecycle session IDs, not model claims. All five child transcripts are checked
   for the expected task and native IELTS tool results.

Authoritative grading references are `attempt-service/Features/Helpers/Grader.cs`
(SingleChoiceGrader, MatchingHeadingGrader, FlowChartGrader and
GraderScoring.SortedUnionKeys) and `GraderHelper.cs` (TextNorm, AnswerValidator).
Admin checks derive from exam-service's `AdminQuestion_Service.cs`; projection
and normalization references are identified in `README.md`.

## Acceptance evidence

| Requirement | Evidence |
| --- | --- |
| Native discovery and seven executable tools | Actual npm/RPC launch plus native mock-model tool calls; structured `details` must equal JSON content |
| All 19 question types | 57 native specification/validation/parity calls; shared C# constant and backend grader-family drift checks |
| Group-first hierarchy | Membership, duplicate IDs, local group/section indices and paper-wide question coverage regressions |
| Four independent counts | Individual-type counts, a 40-slot/one-unit group, and a complete 40-unit/three-group paper |
| Backend compatibility | Ingestion, completion JSON/newline order, matching values, exact choice sets, all-or-nothing marks, FLOW casing and ordering constraints |
| Blind answer-key isolation | Allowlisted projection across all 19 types, including nonempty choice options; actual child input/transcript and denied-tool checks |
| Mocked complete deterministic path | Five isolated native children; final structured report has four PASS checks and `ieltsQualityEstablished: false` |
| Immutable implementations | `git diff --exit-code` on all harness packages and the affected backend/shared directories returned 0; no untracked files there |

## Final executed commands

From `services/generation-harness`:

```sh
export GENERATION_HARNESS_OFFLINE=1
export NODE_OPTIONS="--import=$PWD/test/offline.mjs"
npm run typecheck
npm run build
npm test
```

All returned exit code 0. Root harness: **59 passed**, including **13 Reading
integration tests**. Subagents: **3,491 passed, 0 failed, 13 skipped**. Nine skips
require external SDK installations; four are platform/filesystem conditions.
They were not enabled through external discovery or installation.

From the repository root:

```sh
GENERATION_HARNESS_OFFLINE=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
  dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-restore
```

**73 passed, 0 failed, 0 skipped**, exit code 0. The Node network guard does not
instrument .NET; the suite was inspected for pure/mock behavior and run without
restore. Existing NU1603 runner-version and NU1903 Microsoft.OpenApi vulnerability
warnings remain unchanged; they are not fixed by domain-extension work.

Temporary local evidence is under `/tmp/ielts-vs1-audit/`: baseline and final
`typecheck`, `build`, `test` and `dotnet` logs, failing-regression logs,
`GradingProbe.cs`, `probe.rsp`, and `backend-probe.log`. These logs are local run
evidence, not portable build dependencies or committed artifacts.

## Deliberate limits

FLOW_CHART remains an ordering question with explicit warnings about standard
IELTS flow-completion incompatibility, forbidden ingestion labels, and
case-sensitive grading payloads. It is not silently converted into another type.
Regex-bearing parity fails closed with `PARITY_REGEX_UNSUPPORTED` rather than
claiming JavaScript/.NET regex equivalence. Generation artifacts are not HTTP
publication DTOs. Existing backend explanation/snapshot-redaction gaps are not
used as a blind-solver boundary; the extension builds a fresh allowlist instead.
Mocked reviews and matching evidence spans establish plumbing only, never real
IELTS quality or authorization for live inference or publication.

---

# Vertical Slice 2 — multi-group section verification

## Result

- **PASS:** deterministic/native Vertical Slice 2 acceptance criteria.
- **FAIL:** 0 test failures across all suites.
- **BLOCKED:** none. No Core, SDK, or Subagents packages modified.
- **UNVERIFIED:** authentic IELTS semantic question quality, live-model behavior, publication, and deployment remain strictly unverified.

## Delivered Artifacts & Architecture

1. **One Validated Academic Reading Section (13 Questions, 3 QuestionGroups):**
   - **Passage:** "The Roman Watermill Complex at Barbegal" (1,885 UTF-16 code units; 3 academic paragraphs on Roman hydraulic installations, excavations, and stone provenance).
   - **Group 1 (Questions 1–5):** `TRUE_FALSE_NOT_GIVEN` (startIdx: 1, endIdx: 5). Canonical three-choice set `["TRUE", "FALSE", "NOT GIVEN"]`, exactly one correct option.
   - **Group 2 (Questions 6–9):** `SUMMARY_COMPLETION` (startIdx: 6, endIdx: 9). Single blank per question, numbered markers `[6]..[9]` in prompt matching accepted text keys, single-word extraction.
   - **Group 3 (Questions 10–13):** `MULTIPLE_CHOICE_SINGLE` (startIdx: 10, endIdx: 13). Four distinct options (A–D), exactly one correct option, no distractor conflicts.
   - **Fixtures:** Persisted in `.generation/fixtures/section-vs2.json` (canonical Section/Exam) and `.generation/fixtures/evidence-vs2.json` (13 UTF-16 exact passage spans).
2. **Four Independent Counts:**
   - `questionCount`: 13
   - `answerSlotCount`: 13
   - `scoringUnitCount`: 13
   - `questionGroupCount`: 3
   - Returned consistently across `validate_exam`, `validate_group`, `inspect_delivery_projection`, and `verify_evidence`.

## Reproduced Defects, Target Modes & Hardening

1. **Explicit Target Mode Disambiguation in `verify_evidence`:**
   - Precedence-guessing between `group`, `groups`, and `exam` is removed. Exactly one target is required.
   - Supplying multiple targets fails closed with `TARGET_AMBIGUOUS`.
   - Supplying zero targets fails closed with `TARGET_MISSING`.
2. **Bound Canonical Section Passage in `exam` Mode:**
   - When `exam` is provided, `verify_evidence` invokes `validateExam(exam, false)`.
   - Spans are verified against `exam.sections[0].passageMd` (the actual canonical section passage).
   - If an external `passageMd` is supplied that differs from `exam.sections[0].passageMd`, `PASSAGE_MISMATCH` is emitted.
   - If `exam.sections[0].passageMd` is replaced or corrupted, span checks fail closed with `EVIDENCE_SPAN_MISMATCH` even if spans matched an external passage.
   - Exams with multiple sections fail closed with `EVIDENCE_MULTI_SECTION_UNSUPPORTED` (multi-section evidence verification is outside single-section scope).
3. **Cross-Group Consistency in `groups` Mode:**
   - Validates each group via `validateGroup`.
   - Enforces shared `sectionId` across all groups (`GROUP_SECTION_MEMBERSHIP`).
   - Enforces unique group IDs (`GROUP_DUPLICATE`), unique question IDs (`QUESTION_DUPLICATE`), and unique option IDs (`OPTION_DUPLICATE`).
   - Enforces 1..N group index ordering (`GROUP_INDEX_ORDER`) and contiguous non-overlapping bounds (`SECTION_GROUP_RANGE_CONTINUITY`).
4. **Answer-Key Integrity vs Legitimate Duplicates:**
   - Distractor conflicting with keyed option text fails with `DISTRACTOR_KEY_CONFLICT` (for single and multiple choice).
   - Duplicate option text between distractors fails with `OPTION_CONTENT_DUPLICATE`.
   - Duplicate flow nodes in key fail with `FLOW_NODE_DUPLICATE`.
   - Duplicate blank markers in prompt fail with `BLANK_MARKER_DUPLICATE`.
   - *Legitimate identical text on independent questions* (e.g. Q6 and Q8 both accepting "aqueduct", or Q1 and Q3 both having answer "FALSE") passes validation with status `PASS`.
5. **Complete 13-Answer Blind Solver Handoff & Isolation:**
   - Full passage sent to `reading-generator` (not truncated).
   - Blind solver child receives only the allowlisted student projection from `question-validator`.
   - Blind solver child returns all 13 answers across all 3 groups. Exact unique questionId coverage is verified.
   - Native parity grades all 13 questions against the blind child's answers: total awardedPoints: **13**.
   - Zero-score cases verified: missing answers (`{}`) score 0; incorrect answers score 0.
   - Cross-group option contamination verified: submitting an option ID from a different group's question fails closed with `ANSWER_SELECTION_INVALID` and scores 0.
   - Blind child's task and transcript omit private artifact fields and secret sentinels. Public type-specification prose may name key fields but contains no generated key values.
   - Reviewer identities bound strictly to native lifecycle session IDs (`results[0].sessionId`).
   - Final `verify_evidence` uses bound `exam` mode.

## VS2 Executed Commands

From `services/generation-harness`:

```sh
export GENERATION_HARNESS_OFFLINE=1
export NODE_OPTIONS="--import=$PWD/test/offline.mjs"
npm run typecheck
npm run build
npm test
```

All returned exit code 0. Final root harness: **71 passed, 0 failed, 0 skipped** (including **25 Reading tests**). Subagents: **3,491 passed, 0 failed, 13 skipped**. The final direct verification table above records the current logs. Also run `./node_modules/.bin/tsc --noEmit --project .generation/tsconfig.json` for all domain sources, including child-only extensions.

From the repository root:

```sh
GENERATION_HARNESS_OFFLINE=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
  dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-restore
```

**73 passed, 0 failed, 0 skipped**, exit code 0.
