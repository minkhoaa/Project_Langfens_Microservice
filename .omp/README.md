# Langfens project engineering setup

This is a project overlay for the globally installed `ecc@ecc` plugin, not a
second ECC installation. It changes only `AGENTS.md` and `.omp/`. Existing custom
skill/agent identities and the `.omp/AGENTS.md` import are retained; no application
source, global settings, plugin cache, hooks, or active MCP definitions are changed.

## Stack evidence

| Repository evidence | Engineering implication |
|---|---|
| `AppHost/AppHost.csproj`, service/gateway csproj files | .NET 10; SDK-default C#; primary Aspire packages 13.3.2, EF Core/Npgsql 10.x, YARP |
| `AppHost/Program.cs`, shared Bootstrap/Grpc/PublicContracts projects | Dynamic endpoints, service-owned databases, shared auth/contracts, gRPC and MassTransit/RabbitMQ |
| Both Python Dockerfiles and requirements files | Python 3.12, FastAPI/Pydantic v2, HTTP provider clients; AI adds Whisper/PyTorch/LoRA dependencies |
| AI requirements/config/provider services | Groq/MiniMax/OpenAI-compatible inference, Ollama embeddings, Qdrant, Redis; Elasticsearch is the dictionary search engine |
| `services/attempt-service/Features/Helpers/Grader.cs` and registrations | String question types, actual grader interfaces, all-or-nothing scoring |
| `deploy/envs/loop-caps.env`, generation R03 tests | Versioned fail-closed caps and pinned resume snapshots; child and whole-paper budgets differ |
| Both .NET test projects and both Python pytest configurations | xUnit/Moq/AwesomeAssertions where referenced, WebApplicationFactory, pytest/pytest-asyncio; run Python suites separately |
| Exam database fixtures and `DatabaseTestCollection.cs` | Schema/data resets, including hardcoded or internally overridden targets; a DSN override is not suite isolation. Preserve existing DB-test serialization. |
| AI `tests/conftest.py` and `tests/e2e/conftest.py` | Optional ML stubs; live tests can run automatically when endpoints are reachable. `--run-live` bypasses reachability skipping; use `-m "not live"` for offline exclusion. |
| `.github/workflows/ci-cd.yaml`, `scripts/e2e` | Compose build/push/SSH deploy on `master`, no automated test stages; Python/Makefile E2E, not a frontend test stack |
| `scripts/sync_autogen_contract.py`, `generation_baseline/tools/verify_baseline.py` | Frontend mirror check needs a sibling checkout; baseline validator writes research evidence and must not run incidentally |

There is no frontend package/toolchain in this checkout. Existing unrelated
working changes, particularly generation research/evidence, are outside setup scope.

## DAILY inventory

DAILY means relevant routine guidance, not eager injection of every skill body.
OMP discovers metadata and reads skill bodies on demand.

- Global stack skills: `dotnet-patterns`, `csharp-testing`, `python-patterns`,
  `fastapi-patterns`, `python-testing`, `postgres-patterns`, `database-migrations`.
- Global contract/quality skills: `api-design`, `contract-first`, `error-handling`,
  `search-first`, `coding-standards`, `tdd-workflow`, `verification-loop`,
  `terminal-ops`, `security-review`.
- Local workflows: `langfens-aspire`, `langfens-grader`, `langfens-generation`,
  `langfens-service-setup`, and new `langfens-verify`; `skill-library` is the router.
- Local rules: four existing domain rules cover .NET, Python/AI, testing, and
  security. Sticky `.omp/RULES.md` retains source-integrity, ownership, dynamic
  endpoints, cap, verification, and no-unapproved-MCP invariants.
- Local agents: the existing `aspire-architect`, `grader-specialist`, and
  `generation-loop-expert` add repository-specific knowledge not supplied by
  generic ECC roles. Each autoloads its domain workflow; no extra agent is needed.

## LIBRARY inventory

Selected global skills remain available on demand for Redis, containers/deploy,
production safety, LLM budgets/latency/evals/inference, documentation, GitHub/Git,
architecture decisions, feature/fix/refactor workflows, and setup maintenance.
The exact authoritative selection is `skills.includeSkills` in `config.yml`;
`skill-library` groups the triggers. No skill bodies are copied from ECC.

Relevant global agents include architecture/planning, `tdd-guide`, `code-reviewer`,
`csharp-reviewer`, `python-reviewer`, `fastapi-reviewer`, `database-reviewer`,
`security-reviewer`, `pr-test-analyzer`, `rag-pipeline-reviewer`, `mle-reviewer`,
`performance-optimizer`, documentation, simplification, and failure/type review.
`task.disabledAgents` retains existing exclusions and suppresses additional
frontend/browser-only, off-language, network-appliance, and unrelated operator roles.
It does not copy or override the remaining agents or select a model provider.

Selected global command templates (OMP namespacing is significant):

- `/ecc:plan`, `/ecc:code-review`, `/ecc:python-review`, `/ecc:fastapi-review`
- `/ecc:test-coverage`, `/ecc:refactor-clean`, `/ecc:review-pr`
- `/ecc:update-docs`, `/ecc:update-codemaps`, `/ecc:ecc-guide`

All other ECC command templates are excluded with exact `disabledExtensions`
IDs. Feature/fix/refactor workflow skills remain available through `/skill:*`
instead of redundant command shims. Other plugins/custom commands are untouched.
Off-stack skills remain installed globally but are excluded here; they cannot be
read via `skill://` until deliberately included. Re-evaluate filters when ECC is
upgraded: newly added command/agent names are not covered by old exact deny lists.

## Applied overlay and preservation

- `config.yml` adds a stack-matched skill include list, preserves the previous
  skill exclusions and disabled agents, and narrows ECC command templates.
- Original local skills/agents retain their names. Incorrect fixed ports,
  placeholder credentials, fake grader APIs/partial-credit guidance, invented
  NDJSON examples, and outdated runtime claims were corrected, not preserved as
  executable advice.
- `.omp/AGENTS.md` continues importing root instructions without duplicating them.
- `.omp/mcp.json` stays empty. Recommendations remain in a non-discovered filename.
- No `.claude` install, global ECC copy, symlink into a versioned cache, package
  installation, hook, formatter, or background service is added.

## MCP recommendations — approval required

All five definitions in `mcp.recommended.json` are disabled, schema-valid
**examples**, not a loaded manifest. Do not copy/enable them automatically.

| Recommendation | Scope and prerequisite |
|---|---|
| [Context7](https://github.com/upstash/context7) (`context7-docs`) | Version-specific .NET/Aspire/FastAPI/library docs. Official remote endpoint is `https://mcp.context7.com/mcp`; approve any authentication and external query disclosure. Vendor docs remain the fallback. |
| [GitHub MCP](https://github.com/github/github-mcp-server) (`github`) | Optional PR/issue/Actions inspection if native OMP GitHub tools or `gh` are insufficient. Approve repository-scoped read access; no automatic PR writes, reviews, or workflow dispatch. |
| [Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp) (`postgres-exam`, `postgres-attempt`) | Only for a justified schema/EXPLAIN investigation. Two distinct service-owned read-only roles/DSNs; `--access-mode=restricted` plus real database permissions. No schema changes, migrations, or cross-service joins. |
| [Official Qdrant MCP](https://github.com/qdrant/mcp-server-qdrant) (`qdrant`) | Optional semantic retrieval bridge, not a general collection-admin tool. `QDRANT_READ_ONLY=true`, least-privilege key, approved collection, and matching embedding model/dimensions/payload schema required. Defaults must not be aimed at Langfens BGE-M3 collections blindly. Qdrant REST itself is not MCP. |

For stdio examples, approve and explicitly install a reviewed pinned release in
an isolated environment, then bind the approved executable (prefer an absolute
path). Bare executable names intentionally do not download packages at startup.
Endpoint/DSN/key/collection/model values are named environment indirections, not
credentials or fixed host ports. Resolve infrastructure addresses from the
running deployment. OMP substitutes a bare env name only when it is set;
otherwise it passes the name literally, so validate every required variable
before approved activation. Do not echo their values into logs.

Before activation, approve server/version, transport, target data scope,
credentials, and external disclosures; only then add the selected definition to
`.omp/mcp.json`. Keep secrets in process environment/profile credential storage,
not tracked config. `enabled: false` is not a universal deny switch because an
existing user `enabledServers` list can override it; the separate non-discovered
recommendation file is the primary protection. No server connection is tested
or claimed by this setup.

Filesystem, shell, Git, and browser MCPs are not proposed: OMP already supplies
these capabilities, and this repository has no local browser UI to automate.

## OMP discovery and compatibility

Run OMP from repository root. Native project settings, regular rule directories,
and commands are cwd-scoped; launching inside a service directory does not load
the root project settings automatically. Keep the agent at the root and set
command working directories for per-service tests.

- Verified baseline: OMP 18.11.0, global user-scoped `ecc@ecc` 2.2.3. No reinstall
  is necessary. Project arrays replace, rather than append to, lower-layer arrays.
- Native `.omp/AGENTS.md` wins same-depth context discovery and expands its
  `@../AGENTS.md` import. Sticky rules survive long sessions. Ordinary rule
  `globs` are advisory metadata; they do not enforce editing policy.
- `/skill:<name>` is the native project workflow entry point. Global plugin
  commands are `/ecc:<name>`, not unprefixed `/plan`/`/code-review`.
- ECC Claude-dialect agent model aliases are not portable model selectors; OMP
  discards them for that dialect and uses native model resolution. Local agents
  intentionally inherit routing rather than hardcoding a model.
- ECC's setup wizard has Claude/Codex/Kimi routes, not an OMP installer mode.
  Claude `settings.json` permission syntax, four hook-profile choices, and shell
  lifecycle `hooks.json` automation are **not configured as native OMP hooks**.
  Native automation requires separately reviewed JS/TS extensions; none is added.
- ECC's nested `rules/common`, `rules/csharp`, and `rules/python` are not registered
  by OMP's Claude marketplace rule discovery. Native project rules and selected
  global language skills supply the relevant guidance; there is no fake
  `rules.paths`/`agents.include` setting or copied global rule tree.
- Claude hookify/instinct/session tooling, external multi-model/PM2 runners, and
  off-stack commands are not advertised as working integrations. Selected
  Markdown commands are prompt templates, not enforcement or proof that every
  Claude-specific example/tool name works verbatim. Follow project rules and
  native tools, not generic npm/Playwright examples.
- `omp read skill://...` performs real skill discovery. A standalone
  `omp read rule://...` has no session rule snapshot in this OMP build and reports
  no rules; rule discovery must be checked in an initialized session instead.

Use `/reload-plugins` to refresh skills/commands/agents. Use `/new`, `/clear`, or a
fresh session for context/rule changes; a fresh root-launched session applies the
whole overlay together. No global plugin lifecycle change is required.

## Verification

Use `/skill:langfens-verify`. Configuration checks must parse YAML/JSON/frontmatter,
validate MCP examples without connecting, inspect actual runtime context/rules,
and query RPC `get_available_commands` without a model prompt. Check that local
workflow names and selected namespaced ECC commands are present and excluded
commands are absent. Hash comparisons against the pre-setup inventory establish
that application files, research evidence, and global configuration are unchanged.
Application tests, inference, Docker startup, database integration, deployment,
and recommended MCP connectivity are intentionally outside configuration proof.

### Recorded setup checks

- OMP 18.11.0 CLI reports the existing global user-scoped ECC 2.2.3 install.
- Duplicate-aware YAML/frontmatter validation passed for project settings, all
  six local skills, all three agents/autoload targets, and four domain rules.
  Both MCP JSON files passed the official OMP draft-2020-12 schema.
- A fresh RPC session returned successful `get_state` and
  `get_available_commands` responses, exited zero, and sent no model prompt.
  Its actual system-prompt blocks contained the expanded project context,
  sticky invariants, and all four domain rule entries.
- Runtime discovery exposed 42 global plus six local skills, exactly the ten
  selected ECC commands, and the three domain agents; an excluded network agent
  was absent. Direct CLI reads resolved a global .NET skill and the local
  verification skill from their original locations.
- Pre/post SHA-256 comparisons preserved all 1,211 inventoried existing files
  outside `AGENTS.md`/`.omp`, including user research changes, plus global OMP
  settings and the plugin registry. The original context bridge and empty
  active MCP manifest were byte-identical. The throwaway runtime probe was removed.
- Final review corrections explicitly distinguish hardcoded exam fixture targets
  from environment overrides and live-test reachability from a true opt-in gate.
