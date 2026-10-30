# Remaining-bug verification checkpoint

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
