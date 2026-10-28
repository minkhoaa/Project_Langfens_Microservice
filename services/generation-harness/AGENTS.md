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
- All tests must run strictly offline (`GENERATION_HARNESS_OFFLINE=1`). No live LLM or API calls.

## Test Safety & Network Isolation (CRITICAL)
- **Zero Global Credential Discovery**: Tests and test helpers must never read, write, or refresh credentials from `~/.pi/agent/auth.json`, `~/.config`, or any host path outside the repository.
- **Environment Sanitization**: Host provider API keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `AWS_*`, `CLOUDFLARE_*`, `ZAI_*`, etc.) are purged during test bootstrap (`test/offline.mjs`).
- **Hard Network Guard**: `test/offline.mjs` installs multi-layered interceptors for `globalThis.fetch`, `http.request`, `https.request`, `net.Socket.prototype.connect`, `tls.connect`, and `WebSocket`. Only local loopback connections (`127.0.0.0/8`, `::1`, `::ffff:127.0.0.1`, `0.0.0.0`, `*.localhost`) are permitted for mock servers; all external network requests throw `[NetworkBlocked]`.
- **E2E Suite Exclusion**: Live provider suites are excluded by default from automated test execution. Never run unmocked provider tests.
