# Standalone isolation audit

## Scope and entrypoints

Supported runtime boundary: `node scripts/run.mjs` (`npm start`), source mode `npm run dev`, or local npm bin `packages/coding-agent/bin/pi.mjs`. SDK consumers preload `scripts/register-runtime.mjs` **before** importing SDK modules. All of these use the workspace; no global `pi` command is required.

The launcher uses the current Node executable's absolute `process.execPath` and an absolute harness CLI path. The package's `bin.pi` points to the isolation wrapper, not directly to an uninitialized upstream CLI. Internal compiled CLI/RPC entries retain Pi behavior and require the isolated environment supplied by the boundary. Directly importing upstream SDK modules without the preload is not an isolated invocation.

This isolates configuration and package resolution, not arbitrary filesystem access. Trusted tools/extensions can still read files, run programs or call providers. Node processes honor `NODE_OPTIONS` **before** launcher JavaScript runs: callers must not supply untrusted preloads to the outer Node process. The launcher removes inherited preloads/module search overrides from the Pi child. Provider API-key environment variables are not a credential sandbox; tests use a credential-free environment and a separate network guard.

## Findings and changes

| Area | Before | Standalone behavior |
| --- | --- | --- |
| npm workspace | Seven internal package links were already local | Names/versions preserved; all workspace manifests and dependency entry resolutions checked against harness realpaths |
| Build resolution | Source aliases for dev, workspace dist for bundle | Preserved; no global module paths; no model catalog regeneration |
| CLI | npm start called raw compiled CLI; bin bypassed configuration isolation | Wrapper initializes runtime then launches absolute Node + local CLI; source launcher uses local source resolver |
| Agent configuration | Default `~/.pi/agent` | Explicit `PI_CODING_AGENT_DIR=<runtime>/agent` |
| Assets/package identity | `PI_PACKAGE_DIR` could be inherited from a host Pi | Always `<harness>/packages/coding-agent` |
| Sessions | Upstream defaults/inherited session directory; SDK defaults did not consult the CLI session variable | `PI_CODING_AGENT_SESSION_DIR=<runtime>/sessions` applies to both CLI and standalone SDK defaults; explicit CLI session flags retain upstream precedence |
| HOME/skills | User skills include `~/.agents`; context/skill discovery traversed ancestors | Private HOME/XDG directories; standalone ancestor discovery stops at the dedicated workspace (or child cwd if outside it) |
| Managed packages | User npm packages could fall back to `npm root -g` | Standalone mode never takes legacy global fallback; npm/git stores live in `<runtime>/packages`, linked from agentDir |
| RPC child | `spawn("node", ...)`, relative default CLI | `spawn(process.execPath, ...)`, absolute default CLI from this package |
| pi-subagents | External resolver can use host package discovery, binary override or PATH fallback | Pin `PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT`; remove inherited binary overrides; executable wrapper exists locally; POSIX PATH shim protects legacy `spawn("pi")` callers |
| Container | None | Multi-stage Node image; clean lockfile install/build; production deps; non-root user; no host mounts |

The four required variables are initialized together in `scripts/runtime.mjs` and inherited by real children. `PI_PACKAGE_DIR` is the **coding-agent code/assets root**, not the managed-package installation directory. Changing its meaning would break assets and metadata.

Runtime root defaults to `<harness>/.runtime`; the only root selector is `LANGFENS_HARNESS_RUNTIME_DIR`. The launcher intentionally does not accept the invoking host Pi's per-directory overrides. It preserves a nested child's cwd only if it is already inside this runtime. Explicit session/resource paths and extension code remain trusted operator inputs, not sandboxed capabilities.

The only lockfile change is `packages/coding-agent.bin.pi`: `dist/bundle/cli.js` → `bin/pi.mjs`. No dependency version, resolution, integrity, internal package name, agent loop or provider implementation changed. No extension was installed or added to dependencies.

## Offline verification

Run from this directory:

```sh
npm ci --ignore-scripts
npm run build:offline
npm run check
npm test

# Optional, read-only compatibility audit of an extension already available to the operator:
PI_SUBAGENTS_EXTENSION=/absolute/path/to/pi-subagents/bundle/index.js npm test

docker build -t langfens-harness:isolation-smoke .
npm run test:container
```

Verified on Linux with Node 24:

- Clean lockfile install, bundled/unbundled build and TypeScript typecheck: PASS.
- Standard smoke suite: 14 PASS, 2 intentionally skipped external-extension checks.
- With explicitly selected pi-subagents 0.83.0 artifact: all 16 checks PASS, no skips. The executable resolver is extracted read-only into a disposable fixture, without importing the extension's host module graph. Both parent-CLI selection and SDK-host package-root fallback actually execute local `--version` commands. Existing optional extension-loading tests additionally check host aliases/startup on both RPC builds.
- Mandatory RPC child tests: real local Node children, both compiled entry variants, absolute entry/execPath assertions, extension host alias loading, and a PATH containing deliberately broken `node`/`pi` sentinels: PASS.
- Fake host settings, auth, extensions, `~/.pi/agent/skills`, `~/.agents/skills` and ancestor context/skills outside the workspace are ignored; global npm fallback is forbidden in standalone mode; SDK session persistence uses the dedicated session root: PASS.
- Workspace dependency entry realpaths stay below the harness; local npm executable points to the wrapper: PASS.
- Unbundled and bundled TUI PTY startup, session-start hook and empty-editor Ctrl-D exit: PASS. Source entrypoint help/startup: PASS.
- Docker clean build, lockfile byte identity after install/prune, non-root process, own HOME/config/session/package directories, RPC state response, and container TUI PTY startup/exit: 2 container tests PASS. Runs use `--network none`, no volume/config/dependency mounts.
- Network guard stays enabled for runtime/provider smoke tests; model turns use Pi's built-in faux provider. Production-launcher executable-only checks use `--version`; container probes cannot access the network. No LIVE inference, OAuth, paid provider run or model download was performed.

The pinned dependency set currently produces an npm audit warning for one high-severity vulnerability during installation. Dependencies were deliberately not updated or auto-fixed.

## Limits / next integration

- pi-subagents is **not shipped**. The resolver audit proves local executable selection and execution, not complete workflow/orchestration correctness or live provider quality.
- POSIX compatibility shim and Python PTY probes were verified on Linux; Windows has not been validated. Native platform source/assets remain intact.
- Docker builds need registry access to fetch the base image/npm dependencies. Runtime tests do not require network access. `--offline` alone is not a network sandbox.
- Image starts JSONL RPC on stdin/stdout and exits on EOF. It has no HTTP listener/health endpoint. A future Aspire container resource must keep stdin open/manage lifecycle or add a transport separately; there is no AppHost change in this task.
- No Admin Web, domain workflow, custom orchestration, deployment or publication was implemented.

## Task 1: source graph and removal-candidate audit (baseline 4e85dba)

This section records the *current source snapshot* before the harness refactor. “Active” means reachable from a shipped entrypoint or an exported SDK/resource surface; being absent from the default tool list does not make an SDK extension removable.

### Entrypoints and build/resource closure

| Entrypoint / surface | Source and resolution | Dependency/resource edges that must be audited before removal |
| --- | --- | --- |
| Installed command | `packages/coding-agent/bin/pi.mjs` -> `scripts/run.mjs` -> `scripts/runtime.mjs` -> `packages/coding-agent/dist/bundle/cli.js` | Runtime isolation setup, package CLI, bundle entries below; wrapper is the shipped executable. |
| Source development CLI | `npm run dev` -> `scripts/run.mjs --source` -> `packages/coding-agent/src/experimental/source-resolver.ts` -> `src/cli.ts` | Workspace source aliases and source resolver; not a package install/runtime fallback. |
| Public SDK | `packages/coding-agent/src/index.ts` -> `packages/coding-agent/src/main.ts` and re-exported session, runtime, tools, extensions and resource APIs | Public exports include session creation/runtime, extension and resource loaders, package manager, MCP and codemode extensions, image processing and TUI-facing types. Build entry is `dist/index.js`, with corresponding bundled `bundle/index.js`. |
| RPC child | `packages/coding-agent/src/rpc-entry.ts` -> `main.ts` -> RPC mode | Distinct unbundled `dist/rpc-entry.js` and bundle `dist/bundle/rpc-entry.js`; both need direct child/session tests. |
| Lazy and worker entries | `scripts/build-coding-agent-bundle.mjs` enumerates CLI/index/RPC, image resize worker, codemode worker, Bedrock stream and OAuth flows | Image resize worker is emitted beside its resolver; codemode worker is bundled separately as builtin-only source and serialized to an in-memory data URL; provider/OAuth entrypoints are emitted lazily. Missing any referenced lazy entry or asset breaks runtime behavior even if the main bundle builds. |
| Static assets | `packages/ai/src/providers/data/*` JSON and manifest; `packages/coding-agent/src/modes/interactive/theme/*.json`, image assets, HTML export template/CSS/JS and vendored HTML renderer | Copied by package build; consumed by model catalog, theme and image/resource discovery, and HTML session export. Keep audit coverage for generated asset copies. |

### Internal package graph and dependency kinds

| Package / edge | Current evidence and kind | Removal candidate status |
| --- | --- | --- |
| `coding-agent -> agent` | `main.ts`, SDK/session/runtime, tool types and implementations import Agent interfaces/implementation; static runtime and type edges. | Required native agent/session loop; not a removal candidate. |
| `coding-agent -> ai` | CLI/model/session APIs and SDK use model/provider runtime; static runtime and type edges; provider data is a runtime asset. | Required native provider/model layer; not a removal candidate. |
| `coding-agent -> tui` | Rendering, keybindings, terminal capabilities, clipboard, extension/resource/session types; most rendering/capability imports are active runtime, while several API imports are type-only. TUI also includes optional native clipboard/terminal helpers and JS fallbacks. | Retain while current interactive/extension/tool rendering is kept; native helpers may be separable only after active imports and fallback behavior are proven. |
| `coding-agent -> codemode` | `extensions/codemode/{execute,tool,worker}.ts`; runtime sandbox, declarations/source grammar, and worker imports; public `index.ts` exports the codemode extension/types. | Active exported extension and worker edge, although not required for four default factories. Candidate only with explicit public API and SDK behavior decision. |
| `coding-agent -> mcp` | `extensions/mcp/{runtime,tools,resources,oauth}.ts` use MCP client runtime; OAuth/resources/tools have runtime imports and MCP auth includes types; public `index.ts` exposes extension and server types; `main.ts` lazily loads MCP CLI. | Active SDK/extension surface, even though default four-tool array does not require MCP. Not removable solely based on default CLI path. |
| `agent -> ai` | Agent interfaces/runtime use model types and APIs; active implementation and type dependency. | Required native agent. |
| `ai -> telemetry` | `ai/src/telemetry.ts` has active value imports (`createTypedMetrics`, `createTypedSpanStarter`, `defineTelemetrySchema`, no-op telemetry contexts/metrics); `ai/src/types.ts` also has a type-only `TelemetrySpan` edge. | Not type-only overall; telemetry implementation is an active import closure. |
| `coding-agent -> third-party direct dependencies` | Manifest pins include Photon image processing, shell/path/file/session/config/extension dependencies, QuickJS WASM, and TypeBox; use the manifests/lock for exact resolution and integrity. | Each must be checked against static and dynamic paths before pruning; Photon is dynamically loaded for image/clipboard handling and has wasm assets; QuickJS powers codemode. |

The current manifests are `packages/{agent,ai,codemode,coding-agent,mcp,telemetry,tui}/package.json`; their build inclusion, compiler aliases, package exports/files, and exact direct dependencies were inspected alongside their `tsconfig.build.json`. Transitive package lock identity evidence (package path, exact version, resolved URL, integrity) is in `/tmp/langfens-harness-lock-tuples-task1.tsv`; preserve this baseline for retained-entry comparisons. No dependency changes were made in Task 1.

### Additional direct edges and deletion cautions

- MCP and codemode are not merely type declarations: their SDK-facing extension implementations and workers are imported or lazily invoked by the current CLI and exported from `src/index.ts`.
- `src/core/extensions/types.ts`, `loader.ts`, `runner.ts`, `virtual-modules.ts`, key-id schemas/bindings, resource loader and settings manager refer to TUI public types and/or runtime APIs. Loader aliases and virtual-module registration are extension compatibility edges, including historical host aliases.
- Themes are loaded by interactive mode/theme initialization; `src/index.ts` exposes theme-related/session APIs. Theme JSON and the prompt image asset are copied by the build.
- Package manager is active in `main.ts` (`handlePackageCommand`, cleanup) and `core/package-manager.ts` (public `DefaultPackageManager`); managed package resolution/install behavior is used by extension/resource loading. It cannot be removed based on package-command usage alone.
- Telemetry module is used by AI stream/runtime instrumentation even when telemetry reporting is disabled/no-op; the telemetry dependency is not a dead leaf.
- Image processing includes `utils/image-resize.ts`, `image-resize-worker.ts`, image-convert, clipboard-image and lazily loaded Photon/wasm. The bundle script explicitly emits the worker and Photon is a direct manifest dependency.
- Terminal support includes `@earendil-works/pi-tui` runtime capability/render APIs and package `native/{linux,darwin,win32}` sources/prebuilds; not every native helper is mandatory for the headless RPC path. Confirm import reachability and JS fallback separately before pruning any native module/assets.
- The current generated model catalog/data, HTML export template/vendor JS, terminal themes and image assets have independent build-copy/runtime resolution paths, and are not proven dead by source entrypoint greps.

### Behavioral baseline coverage and evidence

`test/runtime.test.mjs` exercises provider catalogs, real Agent tool execution and another turn through Pi's faux stream, SDK session persistence/restore/branch/context edit/compaction, TUI/theme rendering, QuickJS/worker execution, both compiled CLI/RPC children, and optional external extension load/startup. `test/isolation.test.mjs` covers launcher/config/resource/workspace isolation, local real RPC children and TUI PTY startup. The new `test/tools.test.mjs` directly exercises all four `createCodingTools(cwd)` factories, real UTF-8/CRLF file write/read/edit/read, Unix shell output, offset/limit continuation, line truncation, missing-file error propagation and the existing local PNG image path. These are characterization tests of existing behavior, not new APIs.

Baseline command `npm run build && npm run typecheck && npm test` ran before adding `test/tools.test.mjs`: build PASS, typecheck PASS, smoke suite 14 checks PASS and 2 optional external-extension checks SKIP (not 14 runtime inner checks plus the new test). The new characterization command `node --import ./test/environment.mjs --test test/tools.test.mjs` passes 1 check with no skip. Its initial execution found two test-assumption issues (trailing newline counts as a line; tiny synthetic PNG wasn't valid for the existing processor); the fixture was corrected to match observed behavior without changing tool implementation.

### Pinned subagent source audit (one-time input only)

The selected global package source is `/home/khoa/.pi/agent/npm/node_modules/pi-subagents`, metadata version `0.83.0`, license MIT; source was read-only inspected and not imported/copied/modified in Task 1. `package.json` SHA-256 is `753e66504724d74e12dd02ba324744dbe3a9a5073dc5ffdf22c0154ebf36b7e8`; LICENSE SHA-256 is `2d20dfacd9742706e564470dc77438608a1e54b0ed46959f080709389209093c`; individual source-file hashes and deterministic aggregate evidence are in `/tmp/langfens-harness-subagents-src-hashes-task1.txt` and `/tmp/langfens-harness-subagents-aggregate-task1.txt` (aggregate SHA-256 `7fa0b6a86d21cee918ac59427055b2d99d38393e934fc62c4b5d821c805f48f1`). The executor's `runs/foreground/execution.js:runSingleAttempt` assembles the native child launch; `runs/shared/child-session.js:openSession` creates a child `ModelRuntime`/resource loader/session, inherits registered providers through `parentProviderRegistry`, calls native `createAgentSession`, then binds extensions. `runs/foreground/subagent-executor.js:runSinglePath` handles the single foreground call; `runs/background/subagent-runner.js:runSingleStepWithTimeout` and its sequential runner path handle sequential steps. Final inline output is assembled from native child messages via `getFinalOutput`, with configured file output resolved in `runs/foreground/execution.js` through `resolveSingleOutput(options.outputPath, ...)`, recorded as `result.savedOutputPath`/`result.finalOutput`, and optional artifact output written to `artifactPathsResult.outputPath`. These audited paths are not evidence of product-grade execution; later task tests must execute the native sessions. This is not evidence of product-grade delegation acceptance; Task 5 must prove native execution with faux providers. No global extension loading or source mutation occurred.
