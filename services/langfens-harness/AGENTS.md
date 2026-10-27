# Langfens Harness

Node.js ESM/npm workspace subsystem. Read README.md and ISOLATION.md for setup, current graph, provenance and verification limits.

## Current map

- `packages/langfens-harness-core/src/`: native CLI/SDK, sessions, RPC, tools and extensions.
- `packages/{agent,ai,tui,telemetry,codemode,mcp}/`: local supporting implementations, all with Langfens package identities. Consolidation is in progress; do not force moves that break required behavior.
- `scripts/`: local Node launcher/environment/source resolution and deterministic build.
- `test/`: offline faux-provider, real-tool, RPC, isolation and PTY coverage.

## Commands

From this directory: `npm ci`, `npm run build`, `npm run typecheck`, `npm test`; `npm run dev` launches source; `npm start` launches compiled runtime. No native executable build is required. No catalog refresh/download during build.

## Boundaries

- Preserve the native agent loop/inference engine, four core tools, session/context management, local extensions and backend RPC.
- The operator authorizes native rebranding, removal of unnecessary upstream public APIs/integrations, and scoped service commits on the current branch. Do not edit/stage/commit unrelated existing changes, push, merge, publish or deploy.
- No global npm/runtime/config resolution, PATH executable fallback, host credentials/settings/skills/extensions, Bun dependency, custom workflow/skill/validator, or dependency upgrades.
- Keep exact retained third-party lockfile versions/resolutions/integrities. Preserve original LICENSE/copyright and third-party notices. Generated provider declarations/catalogs are pinned; do not regenerate from live sources.
- Edit source, not dist/node_modules. Audit static/dynamic imports, public exports, workers and assets before removing modules.
- Inference tests must use existing faux providers, temporary sterile credentials/session directories, and network guard, including child processes. Never call live/paid providers, log in, refresh operator credentials or download models.
- Exercise source and compiled paths and report PASS/FAIL/SKIP accurately. Startup/registration alone is not delegation execution evidence. Keep the Dockerfile consistent if retained, but do not build/publish/deploy containers without authorization.
