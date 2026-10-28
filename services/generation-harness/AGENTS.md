# Langfens Generation Harness Rules

## Role & Architecture
Independent Node.js backend harness (`generation-harness`) for Langfens generation workflows.
Retained packages:
- `packages/generation-harness-core`: Core agent loop, session/context management, 4 built-in tools (`read`, `bash`, `edit`, `write`), TUI & RPC interface.
- `packages/generation-subagents`: Subagent execution, delegation, isolated child sessions, parallel execution, and workflows.
- Supporting SDK packages: `generation-agent-core`, `generation-ai`, `generation-codemode`, `generation-mcp`, `generation-telemetry`, `generation-tui`.

## Immutable Core Policy (FREEZE)
- **Immutable Packages**: All existing Core, SDK, and Subagents packages (`packages/*`) are immutable for IELTS generation work. Do not modify Core or Subagents packages.
- **Native Extension Boundary**: New domain code must be implemented exclusively via the public native ExtensionAPI (`ExtensionFactory`, `ExtensionAPI`) using `api.registerTool()`.
- **Domain Artifact Location**: IELTS agents, skills, prompts, and configurations belong strictly under `.generation/`.
- **No Custom Runtimes**: Do not introduce a new coordinator, custom agent loop, alternative runtime, scheduler, retry engine, or bespoke orchestration framework. Rely solely on the harness core and subagents workflow execution substrate.
- **No Contract Mutations**: Do not change backend service contracts (HTTP/gRPC/MassTransit) to accommodate generated IELTS artifacts.
- **Missing SDK Capability Policy**: If a required public SDK capability is missing or blocked, report an exact blocker rather than editing Core.
- **Git Restrictions**: No commits or pushes without explicit operator authorization.

## Commands
- Install: `npm ci`
- Build: `npm run build`
- Typecheck: `npm run typecheck`
- Test: `npm test`
- Interactive TUI: `npm run start:tui`
- Headless RPC: `npm run start:rpc`

## Boundaries & Isolation
- Do not introduce dependencies on global executables, global npm modules, or external directories.
- Default runtime state is under `.runtime` (or `GENERATION_HARNESS_RUNTIME_DIR`); use isolated test workspaces.
- Built-in tools are strictly restricted to `read`, `bash`, `edit`, and `write`.
- All tests must run strictly offline (`GENERATION_HARNESS_OFFLINE=1`). No live LLM or API calls.
- Do not perform global executable or credential discovery (`~/.pi/agent/auth.json`, `~/.config`, etc.) or live-provider testing.

## Test Safety & Network Isolation (CRITICAL)
- **Zero Global Credential Discovery**: Tests and test helpers must never read, write, or refresh credentials from host paths outside the repository.
- **Environment Sanitization**: Host provider API keys are purged during test bootstrap (`test/offline.mjs`).
- **Hard Network Guard**: `test/offline.mjs` enforces multi-layer interceptors for `globalThis.fetch`, `http.request`, `https.request`, `net.Socket.prototype.connect`, `tls.connect`, and `WebSocket`. Only local loopback connections are permitted for mock servers; external requests throw `[NetworkBlocked]`.
- **E2E Suite Exclusion**: Live provider suites are excluded by default.
