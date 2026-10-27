# langfens-harness

Minimal Node.js/TypeScript runtime vendored from Pi v1.4.0, commit `4a080252f06caf63a525d7873c5d94d3c23887e0`. This directory is an npm workspace project, not a .NET service. Read `README.md` for setup and provenance.

## Runtime map

- `packages/agent/src/`: execution loop, tools, agent state, steering and cancellation.
- `packages/ai/src/`: providers, streaming, models and authentication.
- `packages/coding-agent/src/`: CLI/SDK, sessions/context, compaction, RPC, extensions and interactive mode.
- `packages/tui/src/` and `packages/tui/native/`: terminal components and platform support.
- `packages/{telemetry,codemode,mcp}/src/`: required supporting runtimes.
- `scripts/build-coding-agent-bundle.mjs`: Node bundle builder, including lazy entries/workers.
- `scripts/{run,runtime,register-runtime}.mjs`: standalone CLI/SDK isolation boundary; do not bypass it for host invocations.
- `test/runtime.test.mjs`, `test/isolation.test.mjs`: offline runtime/config/child/TUI checks; `test/offline.mjs`: network guard.
- `Dockerfile`, `test/container.test.mjs`: independent Node image and no-network/no-mount container probes; see `ISOLATION.md`.

Dependency closure: `coding-agent -> agent, ai, codemode, mcp, tui`; `agent -> ai`; `ai -> telemetry`.

## Commands

Run from `services/langfens-harness/`:

```sh
npm ci --ignore-scripts
npm run dev
npm run dev -- --mode rpc --no-session
npm run build:offline
npm run check
npm test
npm run test:isolation
npm start -- --offline
npm start -- --offline --mode rpc --no-session
```

`npm run dev` runs TypeScript source through the upstream source resolver; `npm start` runs compiled output. Both use the local isolation launcher, enable offline mode and work inside `.runtime/workspace` by default. Set `LANGFENS_HARNESS_RUNTIME_DIR` to relocate runtime state; never use the host's Pi directories. Neither command watches/hot reloads.

Container validation (explicit local build, never publish/deploy): `docker build -t langfens-harness:isolation-smoke . && npm run test:container`. Python 3 on Unix is required for PTY smoke tests.

After runtime/build changes, run build, typecheck and smoke tests. For documentation-only changes, check paths and commands; a runtime rebuild is not required. Do not run native rebuilds unless the affected platform code requires them.

For an already installed extension: `PI_SUBAGENTS_EXTENSION=/absolute/path/to/pi-subagents/bundle/index.js npm test`. Otherwise the external-extension loading/resolver checks are skipped. Mandatory local RPC child spawning and TUI checks still run. Do not install the extension automatically.

## Change boundaries

- Preserve Pi Core behavior, package names, public exports/types, provider support and pi-subagents compatibility unless explicitly asked to change them.
- Protect SDK session creation, session branching/context/compaction, RPC framing/events, extension loading/host aliases, lifecycle hooks, TUI components and worker entrypoints.
- Audit manifests, static/dynamic imports, asset paths and build scripts before deleting files or packages. Absence from one entrypoint is not proof that an exported API is unused.
- Keep runtime assets: pinned provider JSON and `.manifest.json`, themes, native prebuilds/sources, workers, HTML-export templates/vendor assets, and `packages/coding-agent/docs/codemode.md`.
- Keep dependency versions pinned. Do not add, upgrade or downgrade dependencies without authorization. Update `package-lock.json` only for an authorized manifest/workspace change; check that retained dependency versions/resolutions/integrities do not drift.
- Do not edit `packages/ai/src/models.generated.ts` or generated provider declarations directly. Catalog updates require an explicit task and a reproducible source; never silently refresh live catalogs during builds.
- Use asset helpers in `packages/coding-agent/src/config.ts`; preserve lazy-import and worker resolution for bundled and unbundled Node execution.
- Edit source/configuration, not `dist/` or `node_modules/`. Follow existing TypeScript conventions, use erasable syntax, and keep changes scoped. Do not add a framework or refactor unrelated modules.
- Do not create/install skills, extensions, plugins, workflows or orchestration systems, or wire Docker/Aspire/Admin Web, unless explicitly requested.
- Retain the upstream MIT notice in `README.md` and existing third-party copyright/license notices.

## Verification safety

- No live inference, paid provider calls, OAuth login/refresh campaigns or model downloads without explicit approval.
- Use Pi's existing faux stream/provider and temporary directories for tests. Never use operator credentials, real session stores or project configuration as test fixtures.
- Keep the smoke-test network guard enabled. CLI `--offline` alone does not block inference or sandbox tools/extensions.
- Test both bundled and unbundled paths when changing RPC, extension loading, assets or worker resolution. Exercise TUI locally without submitting model prompts when interactive behavior changes.
- Report skipped checks and compatibility limits. Extension loading/startup is not proof of successful child execution, workflow execution or live model quality.
- Do not modify unrelated Langfens services, deployment configuration or other users' changes. Do not commit or deploy unless asked.
