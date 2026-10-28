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
