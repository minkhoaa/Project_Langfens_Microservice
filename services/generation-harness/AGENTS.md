# Langfens Generation Harness Rules

## Role & Architecture
Independent Node.js backend harness (`generation-harness`) for Langfens generation workflows.
Workspaces:
- `packages/generation-harness-core`: Core agent loop, session/context management, 4 built-in tools (`read`, `bash`, `edit`, `write`), TUI & RPC interface.
- `packages/generation-subagents`: Subagent execution, delegation, isolated child sessions, and sequential execution.
- Supporting packages: `generation-agent-core`, `generation-ai`, `generation-codemode`, `generation-mcp`, `generation-telemetry`, `generation-tui`.

## Commands
- Install: `npm ci`
- Build: `npm run build`
- Typecheck: `npm run typecheck`
- Test: `npm test`
- Interactive TUI: `npm run start:tui`
- Headless RPC: `npm run start:rpc`

## Boundaries & Isolation
- Do not introduce dependencies on global executables, global npm modules, or external directories.
- All runtime configurations, sessions, and workspaces must resolve through the local Langfens/generation runtime (`.runtime`).
- Built-in tools are strictly restricted to `read`, `bash`, `edit`, and `write`.
- All tests must run offline (`GENERATION_HARNESS_OFFLINE=1`). No live LLM calls.
