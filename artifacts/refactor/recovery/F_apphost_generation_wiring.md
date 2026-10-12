# F — AppHost generation-service wiring restoration

- **Worktree:** `/home/khoa/Projects/langfens/recovery-wt-M`
- **Branch:** `refactor/recovery-integrate-g15`
- **Base HEAD:** `dc9f790` (parent `2fa30c3` ← `7844394` ← `04fdbd7`)
- **Authoritative source:** local commit `7a4d0e7` (`git show 7a4d0e7:AppHost/Program.cs`)
- **File changed:** `AppHost/Program.cs` (only), plus this report
- **Verification:** `dotnet build AppHost/AppHost.csproj -v q --nologo` → **Build succeeded, 0 Error(s), 22 Warning(s)**

---

## 1. The regression

The VPS-side commits (`04fdbd7` "feat(phase15): commit full Phase 15 remediation worktree",
carried forward unchanged through `7844394`, `2fa30c3`, `dc9f790`) silently dropped the entire
`generation-service` wiring from the Aspire AppHost.

Evidence:

```
$ git diff 7a4d0e7 04fdbd7 --stat -- AppHost/Program.cs
 AppHost/Program.cs | 14 ----------------
 1 file changed, 14 deletions(-)
```

14 deletions, 0 additions. The same 14 deletions are present at `dc9f790`
(`git diff 7a4d0e7 HEAD -- AppHost/Program.cs` is identical).

Four regions were removed:

| # | Location (at `7a4d0e7`) | What was removed |
|---|---|---|
| 1 | `AppHost/Program.cs` lines 73–82 | The whole `generationService` resource declaration (Aspire `AddDockerfile` + bind mount + uvicorn `--reload` args + `.WithComposeEnvFile("ai")`) |
| 2 | lines 139–141, after the `exam` project block | `exam.WithEnvironment("AI_SERVICE_URL", …)`, `exam.WithEnvironment("GENERATION_SERVICE_URL", generationService.GetEndpoint("http"))`, `exam.WaitFor(generationService)` |
| 3 | line 270, in the `gateway` builder chain | `.WithEnvironment("ReverseProxy__Clusters__generation-cluster__Destinations__d1__Address", generationService.GetEndpoint("http"))` |
| 4 | line 351, inside `AppHostExtensions.WithComposeEnvFile` | `key == "GENERATION_SERVICE_URL" ||` in the "don't override values AppHost injects" skip predicate |

**Scope of the regression is AppHost only.** Verified that both other consumers of
generation-service were untouched by the VPS commits:

- `deploy/compose.yaml` still declares the `generation-service` container and service.
- `gateway/api-gateway/appsettings.json` still declares the `generation-cluster` YARP cluster
  (`:626`, destination `http://generation-service:8080`) and the `generation-api` route (`:476`).

So after the regression the gateway and compose expected a generation-service that Aspire never
created. Consequences of the regressed state:

- `exam-service`'s `ReadingPaperAiClient` falls back past `GENERATION_SERVICE_URL` to
  `AI_SERVICE_URL` and then to `http://generation-service:8080`
  (`services/exam-service/Program.cs:51-55`). Neither resolves under AppHost — the first points at
  a service that does not implement `/api/v1/autogen/reading-paper/section`, the second at a DNS
  name that only exists on the compose network.
- The gateway's `generation-cluster` destination still pointed at the compose hostname
  `http://generation-service:8080` while the AppHost-allocated port went unused, so the
  `/api-generation/**` admin route was broken under Aspire.

## 2. The restoration

All four regions were restored **verbatim** from `7a4d0e7`, at their original positions and with
their original surrounding context. Whitespace fidelity was enforced by diffing the finished file
against the blob at `7a4d0e7`:

```
$ diff <(git show 7a4d0e7:AppHost/Program.cs) AppHost/Program.cs
139a140
> exam.WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-key-not-for-prod");
```

The restored file's content hash independently matches the pre-regression local snapshot recorded
in `artifacts/refactor/recovery/A_local_snapshot.md:136`:

```
$ sha256sum AppHost/Program.cs
4c20d3a3456766d835f70b22a988c49f2f07e044c71ed48c4ec1beb5522db783   AppHost/Program.cs
```

`A_local_snapshot.md` records the same value for the known-good local `AppHost/Program.cs`, so the
result is byte-identical to the intended pre-regression file (the snapshot evidently already
included the uncommitted dev-key line — see §3).

### Region 1 — resource declaration (restored at lines 73–81)

```csharp
// ── Generation Service (Python reading paper generator) ────────────────────
var generationService = builder.AddDockerfile("generation-service", "../", "services/generation-service/Dockerfile")
    .WithHttpEndpoint(targetPort: 8080, name: "http")
    .WithBindMount("../services/generation-service/app", "/app/app")
    .WithEntrypoint("uvicorn")
    .WithArgs("app.main:app", "--host", "0.0.0.0", "--port", "8080",
              "--reload", "--reload-dir", "/app/app")
    .WithComposeEnvFile("ai");
```

Note: the two blank lines between `.WithComposeEnvFile("ai");` and the `// ── Postgres servers`
comment were part of the original file and are preserved.

### Region 2 — `exam` project wiring (restored at lines 139–143)

```csharp
exam.WithEnvironment("AI_SERVICE_URL", aiService.GetEndpoint("http"));
exam.WithEnvironment("GENERATION_SERVICE_URL", generationService.GetEndpoint("http"));
exam.WaitFor(generationService);
```

plus the one deliberate addition described in §3.

### Region 3 — gateway YARP override (restored at line 271)

```csharp
.WithEnvironment("ReverseProxy__Clusters__generation-cluster__Destinations__d1__Address", generationService.GetEndpoint("http"))
```

### Region 4 — compose-env skip predicate (restored at line 352)

```csharp
                key == "AI_SERVICE_URL" ||
                key == "GENERATION_SERVICE_URL" ||
                key == "REDIS_HOST" ||
```

**Which predicate was this?** It is the skip predicate inside
`AppHostExtensions.WithComposeEnvFile` — the same one the root `CLAUDE.md` describes as
"keys AppHost injects dynamically". It is *not* a separate allowlist; there is only one such
predicate in the file. Without this entry, a `GENERATION_SERVICE_URL` line present in
`deploy/envs/ai.env` would be written by `WithComposeEnvFile` and then clobbered by (or clobber)
the explicit `WithEnvironment` call — the resource-graph value would win only by ordering luck.
Restored verbatim; the adjacent `<summary>` doc comment was left exactly as it is at `7a4d0e7`
(it enumerates the skip list imprecisely there and did so before the regression too — not part of
this fix).

## 3. The `EXAMSERVICE__INTERNAL__API__KEY` decision

**Decision: added.** The commit contains

```csharp
exam.WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-key-not-for-prod");
```

placed at line 140, immediately before the restored `AI_SERVICE_URL` / `GENERATION_SERVICE_URL`
wiring and directly after the `exam` `AddProject(...)` builder chain, mirroring the ordering in
the local working tree.

### Provenance — read this before accepting the line

**This line exists only in the local working tree
(`/home/khoa/Projects/langfens/Project_Langfens_Microservice/AppHost/Program.cs:140`). It is
present in *neither* committed branch.** Verified:

```
$ git show 7a4d0e7:AppHost/Program.cs | grep -c 'exam.WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY"'
0
$ git show 04fdbd7:AppHost/Program.cs | grep -c 'exam.WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY"'
0
```

It was **not** removed by the VPS regression — it never existed in a commit to remove. It is
carried-forward uncommitted local work, not a recovery. A reviewer may accept or reject it on that
basis; the four restored regions stand on their own without it.

### Justification for adding it anyway

- **It is not what breaks attempt-service.** The variable is *already* set on `attempt`
  (line 232: `.WithEnvironment("EXAMSERVICE__INTERNAL__API__KEY", "dev-internal-key-not-for-prod")`)
  and that line is present at **both** `7a4d0e7` and `dc9f790` — untouched by the regression.
  `services/attempt-service/Program.cs:59-60` throws
  `InvalidOperationException("EXAMSERVICE__INTERNAL__API__KEY is required")` without it, and the
  AppHost already satisfies that on the `attempt` resource. So restoring the four regions alone
  leaves attempt-service working.
- **The `exam` copy is therefore a redundant dev-only default, not a fix.** It is harmless
  (Aspire sets it per-resource; the value is only read by attempt-service) and it matches the
  user's uncommitted working state, so omitting it would silently diverge the recovery worktree
  from the local checkout the user is actually running. That is the whole of the argument for it:
  **parity with local dev, not repair.**
- **The value is a self-describing placeholder.** `dev-internal-key-not-for-prod` is the same
  literal already committed for `attempt`; it is not a credential, is not copied into any other
  file, and is the same value the skip predicate protects from being overridden by an env file.
- **Risk of keeping it:** it is one more dev secret-shaped literal in the AppHost graph. If the
  reviewer prefers the recovery commit to carry *only* recovered content, dropping this one line
  leaves a file byte-identical to `7a4d0e7` and still builds. This is a one-line revert either way.

Recommendation: **keep it** for local-dev parity, and treat it as a separately reviewable item from
the four recovered regions.

## 4. Coherence checks

| Check | Result |
|---|---|
| `generationService` declared before every use | **Pass.** Declared line 74; first use line 142 (`exam.WithEnvironment("GENERATION_SERVICE_URL", …)`). `AddProject`/`AddDockerfile` for exam (line 133) and the gateway builder (line 246) both follow the declaration, and `examService.GetEndpoint`/`gateway` are declared after line 74. |
| `exam.WaitFor(generationService)` present | **Pass.** Line 143. |
| `exam.WithEnvironment("GENERATION_SERVICE_URL", …)` present | **Pass.** Line 142. |
| YARP override key matches the gateway's real cluster name | **Pass.** Key is `ReverseProxy__Clusters__generation-cluster__Destinations__d1__Address`; `gateway/api-gateway/appsettings.json` declares `"generation-cluster"` at `:626` with `"Address": "http://generation-service:8080"`, referenced by routes at `:459` (`ClusterId`) and `:477` (`generation-api` → `Path: /api-generation/{**catch-all}`, `PathRemovePrefix: /api-generation`). Exact match, no rename needed. |
| `generationService` is referenced by the gateway, not by another resource | **Pass.** Same `generation-cluster` override pattern as `ai-cluster` etc. |
| Consumers of the injected env var | **Pass.** `services/exam-service/Program.cs:51-55` reads `GENERATION_SERVICE_URL` for `ReadingPaperAiClient`; `services/attempt-service/Program.cs:68-74` reads `AI_SERVICE_URL`. |
| Compose-env skip predicate needs `GENERATION_SERVICE_URL` | **Pass** — this *is* the `WithComposeEnvFile` skip predicate (there is no second allowlist). Verified `deploy/envs/` currently contains only `loop-caps.env`, and no env file there defines `GENERATION_SERVICE_URL` or `EXAMSERVICE__INTERNAL__API__KEY`, so restoring the entry changes no behaviour today; it protects the invariant if such a key is ever added to an env file. |
| Consistency sweep across the repo | **Pass.** `GENERATION_SERVICE_URL` / `generation-cluster` / `generation-service` occurrences were grepped repo-wide. Every runtime consumer is covered: AppHost (4 sites), gateway `appsettings.json`, compose, `exam-service`. `artifacts/compression/03_app_host_and_runtime_topology.md:88-90,131` already documents this exact AppHost wiring and is now accurate again. |

### Noted, deliberately not changed (out of scope)

`AppHost/CLAUDE.md:98-105` lists the `WithComposeEnvFile` skip keys and does **not** mention
`GENERATION_SERVICE_URL`, and `AppHost/CLAUDE.md` has no entry for the `generation-service`
container in its resource table. The root `CLAUDE.md` has the same omission. These documents were
already out of date at `7a4d0e7` (they predate the generation-service split), so this is
pre-existing doc drift rather than part of the regression, and both files are outside this task's
allowed scope. Flagging for a follow-up doc pass; the code and the
`artifacts/compression/` documentation already agree.

## 5. Build result

```
$ cd /home/khoa/Projects/langfens/recovery-wt-M
$ dotnet build AppHost/AppHost.csproj -v q --nologo

Build succeeded.
    22 Warning(s)
    0 Error(s)

Time Elapsed 00:00:01.60
```

**0 errors.** Only the AppHost project was built; the solution was not built and Aspire was not
started, per scope.

All 22 warnings are pre-existing NuGet package-audit advisories and are unrelated to this change —
they were emitted for the same reason before the edit:

- `NU1902` (moderate) × 19 — `MessagePack` 2.5.192:
  `GHSA-2f33-pr97-265q`, `GHSA-2x83-8g95-xh59`, `GHSA-cj9g-3mj2-g8vv`, `GHSA-cxmj-83gh-fp49`,
  `GHSA-q2h6-ghwm-5qm8`, `GHSA-qhmf-xw27-6rqr`, `GHSA-v72x-2h86-7f8m`, `GHSA-w567-gjr2-hm5j`,
  `GHSA-wfr3-xj75-pfwh`
- `NU1903` (high) × 3 — `MessagePack` 2.5.192:
  `GHSA-hv8m-jj95-wg3x`, `GHSA-vh6j-jc39-fggf`

No C# compiler warnings (`CS****`) were produced.

## 6. Test coverage

`AppHost` has no test project — the two .NET test projects in the repo are
`services/attempt-service.Tests` and `services/exam-service.Tests`, and a repo-wide grep found no
test asserting on the contents of `AppHost/Program.cs`. The compile is therefore the complete
available verification for this file. Neither test project was run: neither references AppHost, and
the assignment explicitly scopes verification to the AppHost build.

## 7. Change inventory

```
$ git diff --numstat -- AppHost/Program.cs
15	0	AppHost/Program.cs

$ git status --short
 M AppHost/Program.cs
 M artifacts/refactor/phase-07/local-dev-test-confusion-matrices.json
```

- `AppHost/Program.cs` — **15 insertions, 0 deletions.** Of those, 14 restore the exact lines the
  VPS regression deleted; the 15th is the deliberate `EXAMSERVICE__INTERNAL__API__KEY` addition
  described in §3.
- `artifacts/refactor/phase-07/local-dev-test-confusion-matrices.json` was **already** modified
  before this task began (pre-existing uncommitted work in the worktree). It is **not** part of
  this change and was deliberately **not** staged. Only `AppHost/Program.cs` and this report are
  committed.

One commit on top of `dc9f790`. No amend, no rebase, no reset, no force-push, no branch deletion.
The main checkout `Project_Langfens_Microservice` and worktrees A/B/C were read-only inputs and
were not modified.