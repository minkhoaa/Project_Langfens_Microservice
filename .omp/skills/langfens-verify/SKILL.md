---
name: langfens-verify
description: "Select safe Langfens verification by changed surface: OMP discovery, .NET graders, disposable PostgreSQL integration, Python AI/generation, and optional live E2E."
---

# Langfens verification workflow

Use global `verification-loop` for the review sequence and `tdd-workflow` for code
changes, but substitute the actual commands below for generic npm/TypeScript
examples. Verify only what changed, then widen as warranted. Never install a
formatter, test dependency, MCP server, or hook implicitly.

## Configuration-only changes

Run from repository root with the installed OMP CLI:

```bash
omp config get skills.includeSkills --json
omp config get task.disabledAgents --json
omp config get disabledExtensions --json
omp read skill://langfens-verify
omp read skill://dotnet-patterns
```

Additionally parse local YAML/JSON/frontmatter, verify the `.omp/AGENTS.md`
relative import resolves to root `AGENTS.md`, and confirm active `.omp/mcp.json`
stays empty. Inspect rules/context in an initialized OMP session: standalone
`omp read rule://...` has no active rule snapshot in OMP 18.11.0. Inspect command
discovery with RPC `get_available_commands` without a model prompt or connecting
any recommended MCP. Check selected `/ecc:*` and `/skill:langfens-*` entry points
are present and excluded ECC commands are absent. No application tests or
service startup are needed.

## .NET changes

Requires .NET 10 SDK and restored project packages. From repository root:

```bash
dotnet build Project_Langfens_Microservice.sln
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj
```

For exam/consumer changes, inspect each selected fixture's connection and cleanup
path. Some fixtures run `DROP SCHEMA ... CASCADE` or delete persisted test data.
Some honor `READING_TEST_POSTGRES` / `ConnectionStrings__exam-db`, but
`Phase02DurabilityTests` and `Phase03BudgetTests` hardcode targets, and a Phase02
test overwrites the connection environment internally. **Setting an override is
not whole-suite isolation.** Prefer fixture-specific fully-qualified filters
after inspecting the target. Run the full command below only when every hardcoded
and overridden fixture target resolves to approved disposable test infrastructure,
isolated from all real data. Never target shared or production databases.

```bash
dotnet test services/exam-service.Tests/exam-service.Tests.csproj
```

Use focused fully-qualified filters during red/green development, then run the
affected suite. Do not treat integration setup failures as evidence of a code bug.

## Python changes

Both services use the top-level package `app`; run them in separate service-local
environments and working directories. Container runtime evidence is Python 3.12.
Use the service's `requirements.txt` and `requirements-dev.txt` when an approved
environment setup is necessary; do not install the AI ML stack for configuration work.

Working directory `services/generation-service`:

```bash
python -m pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py
python -m pytest
```

Working directory `services/ai-service`:

```bash
python -m pytest -m "not live"
```

AI fixtures stub missing ML packages, so an offline pass is not proof of actual
Whisper/LoRA inference or provider connectivity. Live tests in AI `tests/e2e` can
run without `--run-live` if AI/Ollama endpoints are reachable. That flag only
bypasses the reachability skip; it is not an opt-in gate. Keep `-m "not live"`
for offline execution. Run live checks only with explicit scope, configured
services/models/credentials, and approval of potential provider charges. Do not
apply that flag to generation-service or run both suites together from repo root.

## Cross-checks and smoke proof

- `python scripts/sync_autogen_contract.py --check` is read-only but requires the
  sibling `langfens-fe-app` checkout (or explicit `--frontend` target). Omission is
  a prerequisite gap, not proof of contract drift. Without `--check`, it writes
  the sibling checkout; do not run that mode without scope.
- `scripts/ci/check_prompt_format.sh` includes an optional live database query
  against a hardcoded container name. Inspect it first; a source-only PASS or a
  skipped live branch is not database verification. It is not an installed hook.
- `generation_baseline/tools/verify_baseline.py` writes a validation report even
  though its checks are offline. Do not run it during configuration work or
  overwrite user research evidence without explicit scope.
- `scripts/e2e` contains Python/Makefile service flows, not Playwright UI tests.
  Read its README and configuration before live execution.
- Significant application changes require an actual route/CLI/worker smoke
  scenario using discovered endpoints. Tests alone do not prove integration.

Report exact command, working directory, observed result, and unexercised live
paths. CI currently builds/pushes/deploys on `master` without `dotnet test` or
`pytest`; deployment success is not a test or coverage result. Do not claim an
80% coverage target was measured unless a real coverage run produced it.
