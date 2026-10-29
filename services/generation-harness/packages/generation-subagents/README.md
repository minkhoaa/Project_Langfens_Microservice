# generation-subagents

Native Generation Harness adaptation of **Pi Subagents 0.83.1**, pinned to
[`312082429bda07714fe0fe7729fe8d4935de4c5a`](https://github.com/nicobailon/pi-subagents/tree/312082429bda07714fe0fe7729fe8d4935de4c5a).
MIT, copyright Nico Bailon. See `LICENSE` and `UPSTREAM-PROVENANCE.json`
for source attribution and per-file provenance. A source pin alone does not
establish behavioral parity.

## Native entry point

The package's default extension registers the native delegation runtime.
Load `generation-subagents` through
Generation Harness's existing native extension/resource APIs. Its manifest supplies
`dist/index.js`, packaged skills, and prompt templates. There is no global Pi,
global npm package, external source checkout, separate coordinator, or replacement
agent loop dependency.

Ask naturally for authorized delegation: "Use reviewer to review this diff", "Run
parallel reviewers", "Run this in the background", or "Show the subagent fleet".
The native tool API includes:

```js
subagent({ agent: "worker", task: "Implement the approved change" })
subagent({ workflow: "parallel", args: { tasks: [
  { agent: "reviewer", task: "Review correctness" },
  { agent: "reviewer", task: "Review tests" }
] } })
subagent({ action: "status", id: "run-id" })
subagent({ action: "stop", id: "run-id" })
```

The upstream defaults are retained: async delegation, activation through
`subagents_enable` where appropriate, model-only orchestration tools, scoped
permissions, structured workflow admission, supervision, run artifacts, and native
completion delivery. A headless session without a client UI intentionally drains
background work before settling; an RPC/TUI client can return while children run.
`bg_wait` supports explicit waiting where the native notification path is absent.

Builtins include worker, scout, reviewer, oracle, delegate, researcher,
evidence-auditor, and optional external CLI profiles. Research roles still require
their declared child tools/providers; unavailable tools fail closed. Optional CLI
profiles resolve executables from the runtime's `bin` directory, not a host-global
installation. Do not run live providers or external CLIs as an offline test.

## Generation scopes and SDK compatibility

- Configuration, installed packages, run storage, and default sessions use the
  existing `.runtime` paths selected by `generation-harness-core/runtime`.
- Project resources use `.generation/`; explicit agent-relative extension paths
  resolve from their definition file. Tool names and extension-path entries are
  normalized by the pinned native child tool plan.
- Core retains exactly four default builtins. Explicitly selected `grep`, `find`
  and `ls` are supplied as child-only tools through Core's existing public native
  definition factories. The parent default loadout is unchanged.
- Children load providers before resolving models. Foreground provider registries
  are isolated, with unclaimed parent providers inherited rather than shared.
- Native resource reload isolates transformed extension factories. Node's native
  ESM module map still retains `.mjs` module state; the pinned implementation has
  the same boundary on this host. Use differential tests before relying on
  stronger independence guarantees.

The existing named programmatic APIs (`executeSubagent`, `discoverAgents`, and
`createSubagentExtension({ agents })`) retain their Generation result/input
contracts through `src/compat`, using the same native child factory. The default
extension and exported upstream API subpaths use the complete native runtime.

## Reference

- [Agents, tools, extensions, permissions and private skills](docs/agents.md)
- [Models and thinking](docs/models.md)
- [Workflows, worktrees and supervisor coordination](docs/workflows.md)
- [Configuration and activation](docs/configuration.md)
- [Management and lifecycle tools](docs/tool-reference.md)
- [Fleet, inspectors and artifacts](docs/observability.md)
- [Missions and durable schedules](docs/missions.md)
- [Watchdog](docs/watchdog.md)
- [Public extension APIs, adapters and integrations](docs/extension-api.md)

## Offline validation

From the harness root: `npm run typecheck`, `npm run build`, `npm test`, with
`GENERATION_HARNESS_OFFLINE=1`. The subagents suite supplies isolated runtime/HOME
fixtures, mock providers, local processes, and the harness network guard.

Differential validation additionally requires an explicit external temporary
checkout at the pinned SHA (never downloaded by the test):

```sh
GENERATION_HARNESS_OFFLINE=1 \
GENERATION_SUBAGENTS_UPSTREAM_CHECKOUT=/path/to/pinned/temporary/checkout \
npm run test:differential -w generation-subagents
```
