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
