# IELTS Academic Reading — offline vertical slices 1–3

See [VERIFICATION.md](VERIFICATION.md) for the baseline audit, reproduced defects,
final test evidence and explicit PASS/FAIL/BLOCKED/UNVERIFIED scope.

## Discovery and launch

From `services/generation-harness`, run:

```sh
GENERATION_HARNESS_OFFLINE=1 npm run start:reading -- --mode rpc
# Equivalent: node scripts/run.mjs --reading --approve --mode rpc
```

`start:reading` creates a UUID workspace under `.runtime/reading-runs/`, selects
an IELTS author/editor role, and passes native `--approve` for its linked immutable
domain resources **for this run**. Run only from a trusted checkout. The real
per-run `.generation` root retains native discovery of the seven tools and four
specialists without putting the model at repository cwd. `--no-approve` still
leaves project tools unloaded; the explicit workspace guard remains installed.
The four built-ins remain available with workspace-scoped filesystem guards;
bash executes only a small read-only command language with the configured verified
Bubblewrap capability (`config/reading.json`, overridable using `--reading-bwrap`),
otherwise calls are denied. Authoring/test now accepts natural tasks and selected
file snapshots in per-child folders. Independent tasks use `workflow:"parallel"`;
ordered/parallel JSON plans use `workflow:"reading.plan"` or files in workflows/,
expanded on the native workflow substrate. Strict-blind is an explicit profile;
key debugging needs an operator-issued grant and a separate NON_BLIND child.
Use `/reading-new` for a fresh native session AND folder; native `/new` cannot
change cwd through the frozen public API. See the isolation guide for exact limits. Approved inputs are copied
using `--reading-input`. See [READING-ISOLATION.md](READING-ISOLATION.md) for layout,
permissions, revision/diagnostic retention and exact unsupported security cases.
The default Development launcher still uses `.runtime/workspace`; Development
`--cwd .` is not isolated Reading Mode. Native child-only extension paths resolve
relative to each agent file. The integration test launches the
actual npm entry point under the network guard, checks the seven registrations,
and resolves all four agents through the public native launch-contract preflight.
Model tool calls and child sessions separately exercise registration and invocation.

No providers, credentials, backend endpoints, publication, coordinator, retry
engine or replacement runtime are added. Choose models through the existing
harness configuration; offline tests use only the in-memory faux provider.
Run `npm run config` for the Global Resources manager (Tab: Project; Space:
toggle; F2: Settings), or `npm run config -- --scope project` to start with
`.generation/settings.json` resource overrides.
See [config/README.md](config/README.md) for model/endpoint settings and scopes.
This panel never creates a model session or authorizes a live run.

## Native tools

Every tool uses strict TypeBox schemas, rejects extra properties, and returns
JSON in `content` with the same structured object in `details`. Results contain
`status: PASS|FAIL` and diagnostics `{code,severity,path,message}`. Warnings do
not turn backend-compatible data into FAIL. The public `prepareArguments` hook
rejects malformed inputs with `INPUT_SCHEMA_INVALID` before the native runtime's
normal scalar coercion. No frozen SDK changes are needed.

| Tool | Input | Purpose |
| --- | --- | --- |
| `get_question_spec` | `type` | Family, required keys, wire answer format and IELTS limitations for each of the 19 shared types |
| `validate_question` | `question` | Prompt, options, private keys, completion markers and admin-ingestion constraints |
| `validate_group` | `group` | Exact index coverage, question membership and key completeness |
| `validate_exam` | `exam, complete, requirements?` | Full hierarchy, ownership, paper-wide indices; complete papers require 40 independent units and three Academic sections; optional `sectionScoringUnits` and `answerSlotCount` are caller-specific, not production policy |
| `verify_evidence` | `passageMd?, group?, groups?, exam?, sectionId?, evidence, blindSolverId, semanticReviews` | Exact UTF-16 quotation offsets, coverage and independently identified review inputs; exactly one target: single group, groups, or one canonical exam section; not entailment verification |
| `check_grading_parity` | `question, cases[{id,answer,expectedCorrect}]` | Source-derived backend results versus caller-supplied IELTS expectations; selection-ingestion errors are separate diagnostics |
| `inspect_delivery_projection` | `exam, projectionJson?` | Allowlisted, normalized student projection; optionally reject supplied JSON that leaks private fields or differs from it |

Schemas and executable specifications are in `reading/contracts.ts`. This is a
canonical **generation artifact**, not an HTTP upsert DTO: identifiers establish
membership; a future publisher must resolve persisted UUIDs and supply the
backend's required exam/skill/difficulty metadata. There is no publisher here.
Canonical naming uses backend `idx`, not the preliminary extension's `index`.

Hierarchy: Exam → Sections → QuestionGroups → Questions → Options. Question IDs
and group IDs are paper-wide unique. Section/group indices are local; question
indices cover the whole paper. Bounds refer to question indices, not slots.
Validation rejects invalid paper numbering; the student projection demonstrates
the backend's sorted paper-wide renumbering without mutating the artifact.

Counts are separate: `questionCount`, `answerSlotCount`, `scoringUnitCount`,
`questionGroupCount`. Every Question is **one** all-or-nothing independent
scoring unit. Two correct MC selections, several matching pairs, several blanks
or several ordered nodes do not become several independent marks. A 40-slot
single Question is not a complete Reading paper.

### Evidence verification target modes (`verify_evidence`)

`verify_evidence` accepts exactly one target mode; supplying multiple targets emits `TARGET_AMBIGUOUS` and omitting targets emits `TARGET_MISSING`:
1. **Single Group mode (`group`):** Requires `passageMd`. Validates the single QuestionGroup and checks span quotations against `passageMd`.
2. **Multiple Groups mode (`groups`):** Requires `passageMd`. Validates each QuestionGroup and checks cross-group structural consistency (shared `sectionId`, unique group/question/option IDs, 1..N group index ordering, and consecutive non-overlapping range bounds).
3. **Bound Exam mode (`exam`, optional `sectionId`):** Runs `validateExam(exam, false)` on the complete canonical artifact, then verifies only the selected Section's question IDs and passage. A single-section exam may omit `sectionId`; a multi-section exam must select one, otherwise `EVIDENCE_MULTI_SECTION_UNSUPPORTED`. Unknown selectors fail with `EVIDENCE_SECTION_UNKNOWN`; a selector without `exam` fails with `EVIDENCE_SECTION_TARGET_INVALID`. External `passageMd` must equal the selected canonical passage (`PASSAGE_MISMATCH`); corrupted passages and foreign-section spans fail with `EVIDENCE_SPAN_MISMATCH`. Review coverage must equal exactly that Section's questions. Call independently for each Section; no paper-wide evidence coordinator exists.

## Backend reference and deliberate limits

Authoritative sources (no changes made):

- `../_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs`
- `../_shared/Shared.PublicContracts/Contracts/Exam/InternalExamDto/`
- `../exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs`
- `../exam-service/Features/Exams/InternalEndpoint/InternalExam_Service.cs`
- `../attempt-service/Features/Helpers/{Grader,GraderHelper,QuestionGraderRegistration}.cs`

The shared enum names are pinned in the specifications; a test compares all 19
against the C# constants and checks grader registrations. Deterministic fixtures
exercise every specification, question validation, correct grading and missing
answers through native model tool calls, not direct function stubs.

Important distinctions:

- Completion ingestion needs accepted **texts**, even if grading has regexes.
  Numeric blank-key union ordering, JSON maps and newline positional fallback
  mirror the backend. Extra positional answers are ignored there.
- MC single supports UUID/content text fallbacks, including .NET Guid N/D/B/P/X
  text forms; multi requires exact set equality, ignoring duplicate selections.
  Attempt ingestion still rejects unknown option IDs and too many single-choice
  selections. Dictionary lookups use own properties, so left keys such as
  `constructor` cannot resolve to JavaScript prototype members.
- Matching ingestion uses `[gradingKey, displayText]`. Grading actually accepts
  **every** array value, including display text; JSON values are not trimmed.
- FLOW_CHART ingestion requires lowercase slug order keys and forbids labels,
  although the grader supports labels. Default case-sensitive JSON parsing uses
  `Steps`/`Labels`; lowercase `steps`/`labels` from the backend comment fails.
  Use the array format for compatible ordering. This is not standard IELTS
  flow-chart completion; warnings and specification metadata say so.
- Text normalization follows existing backend behavior, including its compound
  number lookahead quirks and .NET whitespace (U+0085 is whitespace; BOM is not),
  rather than silently "fixing" it. Completion indices use exact Int64 ordering
  with ordinal fallback, not floating-point or locale sorting. FLOW filters null
  and empty sequence entries as the backend does.
- Exact .NET regex equivalence is **not** claimed. Regex-bearing keys return
  `PARITY_REGEX_UNSUPPORTED`/FAIL rather than applying JavaScript regex rules or
  reporting speculative parity. Text-only keys drive this slice.
- Canonical checks deliberately strengthen admin validation (for example,
  options, image presence, complete marker coverage, nonempty labels). Codes
  beginning `INGESTION_` identify rules from admin ingestion, not all canonical
  policy. PASS is not a promise that a generation artifact is an HTTP payload.
- Internal HTTP delivery exposes `ExplanationMd` even with answers hidden, and
  the shared snapshot sanitizer does not remove every private annotation.
  The extension does **not** trust either as a blind-solver boundary. It builds
  a fresh allowlisted projection, omitting all keys, explanations, model answers,
  evidence and reviews. Supplied projections must omit private fields entirely,
  including null/empty fields. FLOW node labels are public; their delivery order
  is not treated as an answer order (the backend shuffles them).

## Native specialists and blind isolation

`reading-generator`, `question-validator`, `blind-solver`, `semantic-reviewer`
remain the four native markdown definitions. Their original narrow tool lists
remain the legacy VS fixture baseline. Reading launches add native project agent
overrides for scoped read/write/edit (guarded bash on non-solvers) and a required
child policy. Every authoring child gets its own actual cwd/input snapshots/output
folder and fresh context, without parent/global context, skills, ambient extensions
or supervisor/intercom tools. Strict-blind explicitly narrows the solver back to
get_question_spec; default authoring is flexible and content blindness UNVERIFIED.
Never fork/resume a key-exposed child and call it blind. See
[READING-ISOLATION.md](READING-ISOLATION.md) for file-task/model/output/cwd options,
operator-approved debug, frozen original answers and fresh strict rechecks.

**Strict-blind/legacy fixture boundary:** strict projection input is enforced
fail-closed by `.generation/reading/blind-guard.ts`. Legacy definitions load it
through subagentOnlyExtensions; scoped Reading children install it only for the
explicit strict-blind profile. Flexible authoring does not impose this schema
or silently count as independent blind validation. Native child policy keeps
file scopes separate regardless of content profile.
Direct `executeSubagent` calls with private artifact fields, plain-text tasks,
malformed projections, unknown question types, or tested smuggled/encoded markers
are rejected before model invocation. The guard requires strict public projection
JSON and a fresh transcript, and only allows exact static `get_question_spec` results.
Native tests exercise runtime fork cancellation, pre-existing-history rejection,
and poisoned-tool-output redaction. Schema validity does not attest provenance or
absence of arbitrary natural-language answer hints: callers must pass the exact
PASS projection. See `VERIFICATION.md` for evidence and the trust boundary.

Before blind delegation, call `inspect_delivery_projection`, require PASS, and
send **only** its `projection` as the child task. Never fork a key-bearing
session or pass generator/validator output directly. The blind solver can request
public type specifications but has no tool to read keys or the filesystem.
Semantic reviewers receive separate passage/group/key/evidence inputs, not the
blind answer or another review. Bind reviewer identities to actual native child
session IDs from lifecycle results before `verify_evidence`; do not trust a
model's claimed reviewer label. Identity checks are structural metadata checks,
not cryptographic proof of independence.

The mocked integration test uses five actual isolated children: generator,
validator, blind solver and two independent semantic reviewers, with persistent
disposable transcripts and native IELTS tool execution. The validator consumes
the actual generator output; the blind child receives only the validator's native
projection result; final grading consumes the blind output and evidence checks
consume both reviewer outputs with their native session IDs. Tests assert these
handoffs in the actual child transcripts. They check the blind model's input and
transcript for leaked private values and denied filesystem/private-tool access,
check independent histories and emit a structured PASS/FAIL report for the slice. The generator and
semantic judgments are mocked: `ieltsQualityEstablished` remains false. Matching
quotations, supplied review approval and grading agreement do not establish real
IELTS question quality or authorize live runs or publication.

## Complete offline Section fixture

`fixtures/section-vs2.json` and `fixtures/evidence-vs2.json` provide one Section
with three QuestionGroups (5 truth items, 4 completion items and 4 single-choice
items). Counts are **13 Questions / 13 answer slots / 13 scoring units / 3 groups**.
The native mock scenario hands off all 13 blind answers, grades **13/13**, and
checks every evidence span against the canonical passage. Fixture drift and a
13-question/14-slot all-or-nothing scoring variant are regression-tested.
Semantic quality remains **UNVERIFIED**; this is not a 40-question paper.

## Complete deterministic paper (VS3)

`fixtures/blueprint-vs3.json` configures the fixture, not a production rotation.
`fixtures/paper-vs3.mjs` constructs its canonical paper, exact per-Section evidence
and predetermined mock answers. Section 1 is unchanged VS2, including IDs and keys.

| Section | Questions | Groups |
| --- | --- | --- |
| 1, Barbegal | Q1–13 | Existing VS2 truth / summary / single choice |
| 2, Alder Valley seed archive | Q14–26 | 4 matching headings / 3 truth / 3 summary / 3 short answer |
| 3, urban sound | Q27–40 | 4 writer-view truth / 4 matching information / 3 sentence completion / 3 single choice |

There are **40 Questions / 40 answer slots / 40 independent scoring units / 11
groups**. Matching and completion records each contain only one answer. The fixture
passes `requirements: {sectionScoringUnits:[13,13,14], answerSlotCount:40}` to
`validate_exam`; other distributions remain possible without these requirements.
A regression changes a blueprint type to demonstrate configuration, rather than
installing a fixed rotation.

`test/reading-vs3.mjs`, registered by `test/reading.test.mjs`, uses the existing
native Subagents API to execute 3 generators, 1 complete-paper validator, 1 blind
solver and 6 independent reviewers in **11 fresh native child sessions**. Actual
outputs feed subsequent inputs, and persisted transcripts assert the handoffs.
Each Section's evidence is checked against its selected canonical passage with
reviewer IDs bound to native session IDs. All 40 blind answers are processed by
native parity calls: **40 correct, 0 incorrect, 0 ungradable, 40/40 points**.
Mixed cases exercise the separate incorrect/ungradable counters and reject invalid
keys; malformed answer coverage cannot silently disappear from totals.

Negative regressions cover cross-Section ID collisions, foreign answers and spans,
private annotations/encodings, contaminated passages/reviews, incomplete papers,
and 40 slots representing only 39 marks. Private markers in public canonical
content now also fail projection inspection before blind delegation. Existing
blind-guard tests continue verifying hostile tool-output redaction, fork denial,
and inherited-history rejection. Arbitrary unmarked natural-language hints cannot
be proved absent. All model outputs, including blind solves, are deterministic
mocks: real IELTS semantic quality remains **UNVERIFIED**.

## Offline verification

```sh
export GENERATION_HARNESS_OFFLINE=1
export NODE_OPTIONS="--import=$PWD/test/offline.mjs"
npm run typecheck
# Includes domain-only/child-only sources not discovered as ambient extensions:
./node_modules/.bin/tsc --noEmit --project .generation/tsconfig.json
npm run build
# Run after build completes: build replaces dist files used by native child tests.
npm test
# Read-only/mock .NET regressions, no restore, no databases:
dotnet test ../attempt-service.Tests/attempt-service.Tests.csproj --no-restore
```

`test/offline.mjs` strips provider credentials and blocks external networking.
Tests use isolated temporary agent/session/runtime directories, in-memory
credentials and the faux model only. The .NET suite uses mocks/pure helpers and
is inspected separately; the Node network guard does not instrument .NET.
