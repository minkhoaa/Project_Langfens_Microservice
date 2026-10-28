# Generation Subagents — Node.js-Native Runtime & Verification Boundary

**Authoritative, independently maintained Node.js-native package.**
The pinned upstream source has been cleaned of obsolete Pi metadata, external runtime
multiplexers (Herdr, Rex, remote SSH), external CLI adapters (Claude Code, Codex, Cursor),
and Bun/standalone executable fallbacks.

The package now operates strictly on standard Node.js APIs (`child_process`, `worker_threads`,
`fs`, `path`, etc.) with broad offline evidence across 254 package test files (3,504 tests;
3,491 pass, 0 fail, 13 skip), 4 differential tests against the upstream pin, 46 root harness tests,
and clean typecheck/build.

## Immutable reference and provenance

- Provenance pin: `nicobailon/pi-subagents`, commit **`312082429bda07714fe0fe7729fe8d4935de4c5a`** (v0.83.1), MIT, copyright Nico Bailon. Original license retained.
- Maintained repository: `minkhoaa/Project_Langfens_Microservice` under `services/generation-harness/packages/generation-subagents`.
- 312 active native source files retained and adapted in this package. 26 external-integration, multiplexer, protocol, and self-update files were intentionally excised.
- `UPSTREAM-PROVENANCE.json` records per-file original/adapted SHA-256 hashes, status ("removed" with reasons), and host adaptations.

## Scope exclusions (Intentionally removed upstream integrations)

The following components existed solely to support unwanted external execution environments and were removed to achieve a fully self-contained Node.js-native runtime:

1. **Remote SSH & Herdr multiplexer execution**:
   - `src/runs/shared/herdr-connection.ts` (SSH transport, shell quotation, remote execution)
   - `src/runs/shared/herdr-machine.ts` (Herdr saved-machine placement)
   - `src/runs/shared/herdr-pane-host.ts` (Herdr visible multiplexer pane host)
   - `src/runs/shared/herdr-pi-protocol.ts` (Herdr wire protocol over socket)
   - `src/runs/shared/herdr-placed-run.ts` (Herdr placed run management)
   - `src/runs/shared/local-machine-access.ts` (local pane multiplexer access)
   - `src/runs/shared/placed-run-owner.ts` (placed run lifecycle ownership)
   - `src/runs/shared/placement-host.ts` (allocation locks and host interfaces)
   - `src/extension/herdr-pi-bridge.ts` (in-pane bridge extension)
   - `src/integrations/herdr-status.ts` (Herdr status reporter bridge)
   - `src/inspectors/herdr/` (`actions.ts`, `client.ts`, `focus.ts`, `plugin.ts`, `project-panes.ts`)
   - `src/api/project-panes.ts` (public Herdr project pane API)

2. **Rex multiplexer execution**:
   - `src/runs/shared/rex-machine.ts` (Rex machine resolution)
   - `src/runs/shared/rex-pane-host.ts` (Rex pane host)

3. **External CLI adapters & legacy profiles**:
   - `src/runs/shared/claude-code-adapter.ts` (Claude Code CLI adapter)
   - `src/runs/shared/codex-exec-adapter.ts` (Codex CLI adapter)
   - `src/runs/shared/cursor-agent-adapter.ts` (Cursor CLI adapter)
   - `src/runs/shared/external-cli-runner.ts` (external CLI process execution)
   - `src/runs/shared/external-cli-contract.ts` (external CLI capability narrowing)
   - `src/runs/shared/external-cli-preflight.ts` (external CLI binary preflight)
   - `src/runs/shared/herdr-external-adapters.ts` (Herdr external execution adapter)
   - Agent profiles: `claude-code.md`, `claude-code-writer.md`, `codex-exec.md`, `codex-exec-writer.md`, `cursor-agent.md`, `cursor-agent-writer.md`

4. **Upstream self-update & runtime binaries**:
   - `src/extension/upgrade-notice.ts` (self-update notification / changelog fetch)
   - `src/runs/background/binary-bootstrap.ts` (compiled Bun Pi executable bootstrap)
   - Obsolete Bun/standalone Pi executable resolution (`resolveBunPiExecutable`, `isStandalonePiExecutable` in `pi-spawn.ts`)
   - Legacy Chord runtime aliases (`@earendil-works/chord`)

## Retained and verified Node.js-native capabilities

All core subagent orchestration capabilities remain fully functional on Node.js:

- **Native Child Sessions**: Standard Node.js execution through `child-session.ts`, independent model registries, child-only tools, definition-relative providers.
- **Detached Background Execution**: Long-running background runner (`async-execution.ts`, `subagent-runner.ts`), auto-drain, timeout evidence, stale-run reconciliation, parent disposal and launcher-exit survival.
- **Supervisor & Intercom**: Native supervisor channel, request/reply, inbox watching, and local intercom bridge.
- **Scripted Workflows & Concurrency**: Scripted workflows via `Worker` thread VM, parallel fanout, semaphore limits, keyed resume, revival links, and terminal receipts.
- **Worktrees & Repository Isolation**: Managed git worktrees, concurrent repository locking, allocation base ref preservation, patch capture, and manifest-backed cleanup plans.
- **Watchdog & Permissions**: Capability ceilings, agent allowlists, fail-closed permissions, and watchdog policies.
- **Local Terminal Inspectors**: Native terminal-based inspectors (`ghostty`, `tmux`) and dynamic inspector provider registration.
- **TUI & Observability**: Subagent fleet status, active capacity tracking, structured output rendering, and transcript inspection.
- **15 Clean Public Exports**: Packaged distribution verified via `test/package-install.test.mjs`.

## Test results summary

Executed strictly offline with loopback isolation (`GENERATION_HARNESS_OFFLINE=1`):

1. **Subagents Package Test Suite**:
   - Files: 254 test files (250 unit test files, 1 native-parity, 1 native-integration, 1 package-install, 1 test-specific helper).
   - Tests: **3,504 tests; 3,491 pass, 0 fail, 13 skip** (all 13 skips platform-gated: Windows `.cmd` wrappers, Windows symlink permissions, case-insensitive filesystem).
2. **Harness Differential Test Suite**:
   - Tests: **4 tests; 4 pass, 0 fail**.
   - Verified against external pinned upstream checkout (`312082429bda07714fe0fe7729fe8d4935de4c5a`): TS extension state (`1,1`), native ESM state (`1,2`), concurrent semaphore order, workflow VM execution.
3. **Root Harness Test Suite**:
   - Files: 7 test files (`branding`, `consolidation`, `isolation`, `runtime`, `subagents`, `tools`, `tui`).
   - Tests: **46 tests; 46 pass, 0 fail**.
4. **Clean Package Installation Test**:
   - Verified `npm pack --offline` creation, all 15 public subpaths, workflow script worker, and detached child process execution in an isolated directory (**PASS**).
5. **Full Workspace Typecheck and Build**:
   - `npm run typecheck`: **0 errors**.
   - `npm run build`: **0 errors** across all 8 workspace packages.
   - `dotnet build Project_Langfens_Microservice.sln`: **0 errors**.
