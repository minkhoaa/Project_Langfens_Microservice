# Substrate audit (current local working tree)

Classification describes the existing Node.js harness, not permission to remove a public capability. No inference or remote service was used.

| Component | Classification | Evidence and decision |
| --- | --- | --- |
| Core, agent, AI, telemetry, TUI, subagents | REQUIRED | Core imports agent, AI and TUI; AI imports telemetry. Core exports the SDK and implements TUI/RPC and extension loading. Subagents supplies child execution and workflows. Retained. |
| Codemode and QuickJS | OPTIONAL; removal BLOCKED | `generation-harness-core/src/index.ts` publicly exports `createCodemodeExtension`; `extensions/codemode` imports `generation-codemode`, whose worker uses `quickjs-wasi`. Core `config.ts` resolves its WASM and `scripts/build-coding-agent-bundle.mjs` builds a dedicated worker. Removing it changes SDK and opt-in CLI behavior and requires coordinated Core/build changes. Retained. |
| MCP and tool-search | OPTIONAL; removal BLOCKED | Core exports both factories in `src/index.ts`. MCP imports `generation-mcp` and the tool-search name; codemode also imports the search ranker. Removing them changes SDK/auxiliary behavior and requires Core changes. Retained. |
| llama.cpp | OPTIONAL; removal BLOCKED | `extensions/index.ts` registers it for auxiliary mode; `extensions/llama` implements provider and command, and interactive mode handles its model selection. Removing it changes opt-in behavior and needs Core changes. Retained; not contacted. |
| Auxiliary extensions | OPTIONAL | `src/main.ts` selects them with `--auxiliary` or `GENERATION_HARNESS_AUXILIARY`; default `builtInExtensions` is empty. Disabled by default does not mean unavailable. |
| Pi package aliases | BLOCKED for wholesale removal | No `@earendil-works/*` runtime imports found in package source; historical changelog/provenance references remain. `generation-subagents/test/differential.test.mjs` deliberately aliases upstream packages for an optional local-checkout comparison. Retained as test/provenance, not a runtime dependency. |
| Herdr/Rex/SSH and external CLI | BLOCKED for wholesale removal | Native async launch explicitly rejects remote machines and external CLI (`runs/background/async-execution.ts`); `agents/agent-management.ts` rejects external CLI and keeps configuration/reporting. Shared public types and workflow receipt validation still describe placements; external-job is a distinct supported provider API. Deleting these representations would alter validation, persistence or public contracts. Retained; remote execution not verified. |
| Build outputs | REQUIRED for respective targets | Core manifest exposes unbundled SDK exports and bundled RPC entry; `scripts/run.mjs` launches the bundle and the bundler emits separate workers. Both are generated artifacts, not proven redundant. |
| Root dev dependencies removed in pre-existing local edits | REMOVABLE as direct root declarations | `@anthropic-ai/sandbox-runtime`, `@biomejs/biome`, `@biomejs/wasm-nodejs`, `husky`, `pnpm`, and `yaml` were removed from root `package.json`; `yaml` remains owned by consumers. Core's redundant dev `marked` declaration was also removed; TUI owns `marked` and HTML export has vendored assets. Lockfile was already updated. No additional dependency or file was removed in this audit. |

## Capability and verification comparison

The starting point for this audit was an already modified working tree, not a clean pre-cleanup run. The above retained components have the same source/build registrations before and after this audit; no Core or runtime code was changed here. This is a source-level comparison, not a measured clean-baseline regression result. The existing local changes also redirect the Core package test script to the root suite, gate Bun discovery behind `ENABLE_BUN_TESTS=1`, and increase one branding test timeout; the Bun gate skips three Bun cases by default. Preserve these facts when comparing coverage.

Offline checks on the current tree (network guard preloaded, npm offline):
- `npm run typecheck` and `npm run build`: passed.
- `npm test`: root 46 passed; subagents 3,491 passed, 13 skipped, 0 failed. Native fixture tests cover registration/custom-tool execution, foreground, parallel, background, recovery and nested delegation; workflow and supervision also have offline suites. These are mocked/local execution, not live inference.
- Workspace tests: telemetry 47 passed; TUI passed (dot reporter); codemode 223 passed, 3 skipped; MCP 45 passed; agent 92 passed; AI 1,329 passed, 30 skipped (live suites excluded).
- `npm ci --offline --ignore-scripts` passed in a disposable directory containing workspace manifests and lockfile. The subagents package-install test additionally packs and loads the package with local workspace peers. This is not a normal lifecycle-enabled clean install.
- Differential upstream comparison was not run: it requires a separately supplied pinned checkout. No baseline test run before the pre-existing cleanup is available.

No structural Core changes were needed for the changes made during this audit. Removal of any retained optional subsystem would require the explicit Core/public-export/build changes described above and is not behavior-preserving under the current contract.
