# Langfens Harness

Independent Node.js backend harness and multi-agent execution subsystem for Langfens generation workflows.

## Safety Incident & Offline Test Hardening

### Historical Incident Disclosure
During prior development runs, invoking `GENERATION_HARNESS_OFFLINE=1 npm test -w generation-ai` failed to enforce offline execution. Specifically, `packages/ai/test/oauth.ts` contained global credential discovery logic (`AUTH_PATH = join(homedir(), ".pi", "agent", "auth.json")`) that automatically resolved ambient OAuth tokens on the developer workstation. Test files such as `stream.test.ts` and `context-overflow.test.ts` invoked `resolveApiKey()` at module scope, refreshed expired tokens against live OAuth endpoints, wrote updated credentials back to the user's home directory, and initiated live inference requests to OpenAI Codex endpoints. This resulted in live token usage and an eventual provider quota limit error.

Prior documentation claimed that all tests ran completely offline without live calls; that claim was inaccurate for those suites and has been corrected.

### Hardened Network Guard & Credential Isolation Architecture
To prevent recurrence, the following multi-layer security protections have been implemented:

1. **Hard Network Guard (`test/offline.mjs`)**:
   - Intercepts `globalThis.fetch`, `http.request`, `http.get`, `https.request`, `https.get`, `net.Socket.prototype.connect`, `tls.connect`, and `globalThis.WebSocket`.
   - Strictly validates destination IP/host targets against a loopback whitelist: `127.0.0.0/8`, `::1`, `::ffff:127.0.0.1`, `0.0.0.0`, and RFC 6761 `*.localhost`.
   - Bracketed and unbracketed IPv6 and IPv4 addresses with optional ports are parsed strictly; no arbitrary DNS resolution or hostname fallback is permitted.
   - Low-level `net.Socket.prototype.connect` and `tls.connect` unwrap nested argument arrays and fail closed on unrecognized targets.
   - Any external connection attempt is immediately blocked with `[NetworkBlocked]` without initiating TCP or TLS handshakes. Local loopback mock servers remain fully supported for testing.

2. **Environment Sanitization**:
   - `test/offline.mjs` purges all ambient host provider credentials (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `AWS_*`, `CLOUDFLARE_*`, `ZAI_*`, `ZAI_CODING_CN_API_KEY`, etc.) upon module initialization.

3. **Global Credential Discovery Elimination**:
   - `packages/ai/test/oauth.ts` has been rewritten to completely remove all filesystem reads/writes to `homedir()`, `~/.pi/`, or global configuration files.
   - `resolveApiKey()` returns only explicitly registered in-memory mock fixtures (`setFixtureApiKey`) or `undefined`. It never contacts remote servers or refreshes tokens.

4. **Default Live E2E Exclusion**:
   - In `packages/ai/vitest.config.ts`, live/e2e integration suites (`**/*e2e*.test.ts`, `**/*live*.test.ts`, `stream.test.ts`, `tokens.test.ts`, etc.) are excluded from default test runs.

5. **Disposable Test Subprocess Isolation**:
   - `RpcClient` respects `this.options.env.GENERATION_HARNESS_RUNTIME_DIR`, allowing tests to isolate subprocess state in temporary disposable directories instead of accessing real repository credentials.

## Architecture & Final Import Graph

```text
services/generation-harness/
├── packages/
│   ├── generation-harness-core/       # Core orchestrator, session/context, tools, original-style TUI & RPC
│   │   ├── src/
│   │   │   ├── agent/                 # Agent loop re-exports
│   │   │   ├── ai/                    # AI abstraction re-exports
│   │   │   ├── cli/                   # CLI arguments and minimal startup UI
│   │   │   ├── core/                  # Session, model runtime, tools (read, bash, edit, write)
│   │   │   ├── extensions/            # MCP, codemode, llama, tool-search extensions
│   │   │   ├── modes/                 # Original-style TUI (interactive-mode.ts), print-mode, rpc-mode
│   │   │   ├── runtime/               # Isolated runtime paths & environment (.runtime)
│   │   │   ├── tools/                 # 4 core tools: read, bash, edit, write
│   │   │   └── tui/                   # TUI re-exports & helpers
│   │   └── package.json
│   ├── generation-subagents/          # Single-agent & chained multi-agent delegation extension
│   │   ├── src/
│   │   │   ├── agents/                # Agent definitions & discovery
│   │   │   ├── runs/                  # Isolated child session execution & delegation
│   │   │   └── shared/                # Output parsing & token usage aggregation
│   │   └── package.json
│   ├── agent/                         # generation-agent-core: Agent event loop, message reduction, tool execution
│   ├── ai/                            # generation-ai: Multi-provider LLM abstraction, stream parsing, prompt cache
│   ├── codemode/                      # generation-codemode: Sandboxed JavaScript execution via QuickJS WASI
│   ├── mcp/                           # generation-mcp: Model Context Protocol client & transports
│   ├── telemetry/                     # generation-telemetry: In-memory span instrumentation & metrics
│   └── tui/                           # generation-tui: Terminal differential rendering, text measurement, ANSI
├── scripts/
│   ├── build-coding-agent-bundle.mjs  # Release esbuild bundler for harness core
│   ├── run.mjs                        # Subsystem launcher (bundled or --source)
│   ├── runtime.mjs                    # Environment isolation & path containment
│   └── smoke.mjs                      # Minimal runtime export & protocol smoke tests
├── test/                              # 38 node:test offline harness integration tests
├── package.json                       # Root workspace manifest (ESM only)
├── package-lock.json                  # Pruned lockfile (canvas native installer removed, 0 surviving drift)
├── tsconfig.json                      # Workspace TypeScript configuration
└── LICENSE                            # Preserved upstream MIT License (Mario Zechner)
```

### Dependency Graph

```text
generation-harness (root CLI & launcher)
 ├── generation-harness-core
 │    ├── generation-agent-core
 │    │    └── generation-ai
 │    │         └── generation-telemetry
 │    ├── generation-ai
 │    │    └── generation-telemetry
 │    ├── generation-codemode
 │    ├── generation-mcp
 │    └── generation-tui
 └── generation-subagents (peer: generation-harness-core, typebox)
```

## Module Retentions & Dependency Justifications

All 8 workspaces are retained with specific runtime requirements:

| Workspace Package | Status | Dependency Reason |
| :--- | :--- | :--- |
| `generation-harness-core` | Retained | Main application package: Full original terminal UI (viewport docking, multi-line editor, differential renderer, status reporter), headless JSON-RPC mode, session management, 4 built-in tools (`read`, `bash`, `edit`, `write`), and CLI entrypoints. |
| `generation-subagents` | Retained | Multi-agent delegation package: isolated child sessions, sequential agent chaining, and tool loop delegation. |
| `generation-agent-core` | Retained | Core agent loop: message reduction, turn execution, tool resolution, and streaming agent events. |
| `generation-ai` | Retained | Native LLM inference engine: multi-provider API abstractions (Anthropic, Bedrock, OpenAI, Gemini, etc.), streaming delta parsers, and prompt caching. |
| `generation-telemetry` | Retained | Direct dependency of `generation-ai`: required by `packages/ai/src/types.ts` and `src/telemetry.ts` for telemetry spans (`TelemetrySpan`), in-memory telemetry context (`InMemoryTelemetryContext`), and stream instrumentation. |
| `generation-mcp` | Retained | Optional SDK compatibility: preserved Model Context Protocol client capability (`createMcpExtension`, `extensions/mcp/*`, standalone `mcp` CLI command); opt-in only, not auto-registered in minimal CLI by default. |
| `generation-codemode` | Retained | Optional SDK compatibility: preserved sandboxed script execution capability (`createCodemodeExtension`, `extensions/codemode/*`, QuickJS WASI worker); opt-in only, not auto-registered in minimal CLI by default. |
| `generation-tui` | Retained | Direct dependency of `generation-harness-core`: required for terminal UI components, layout nodes (`Container`, `Box`, `Text`, `Spacer`, `Editor`), ANSI visual width calculations, markdown rendering, and tool output formatters. |

## Original Terminal UI Restoration & Architecture

1. **Faithful Original Architecture Restored**:
   - Restored and adapted original UI architecture from `/home/khoa/Projects/rea/pi/pi` (commit `b3a29f1111114fac696e2cfcd65acdb382a6ed5e` under MIT License).
   - Core interactive modules:
     - `chat-viewport.ts`: Fullscreen transcript (`ScrollView`) with fixed docking layout for messages, status, editor, and footer.
     - `tui-renderer.ts`: Composition root supporting both inline (`TuiMainScreen`) and fullscreen alternate-screen (`TuiAltScreen`) renderers with stable proxy reference.
     - `program-status-reporter.ts`: Terminal OSC 7501 status reporter (`working`, `blocked`, `done`, `idle`).
     - `interactive-mode.ts`: Rich multi-turn orchestration, multiline editing, history navigation, model/session selectors, streaming deltas, tool execution displays, and subagent progress reporting.
     - `components/harness-logo.ts`: Clean text title header (`Langfens Harness v1.4.0`) following original layout without misaligning half-block ANSI art.
   - Removed obsolete `MinimalTui` readline scaffold.
2. **Disabled Upstream Remote Services & Strict Offline Decoupling**:
   - Pruned remote bug report upload (`bug-report.ts`, `bug-report-upload.ts`); slash command `/bug` displays local diagnostics path (`.runtime/agent/generation-harness-debug.log`).
   - Pruned remote session share (`session-share.ts`); local HTML/JSON export preserved via `/export`.
   - Pruned Radius upstream accounts and MCP servers (`radius.ts`, `radius-login-selector.ts`).
   - Pruned remote version checks and telemetry pings (`version-check.ts`, `report-install`).
   - Pruned upstream easter eggs (`armin.ts`, `easter-egg-3d.ts`, `earendil-announcement.ts`, `clankolas.png`).
3. **Bun Release & Build Files**:
   - Removed `packages/generation-harness-core/src/bun/` completely.
   - Removed Bun detection runtime branches from `config.ts`, `provider-env.ts`, `identity.ts`, and `package-manager.ts`.
4. **Native Prebuild Addons**:
   - Removed `.node` prebuild binaries for Darwin, Linux, and Windows; runtime uses CLI-based clipboard integration fallbacks.

## Commands

```bash
# Clean all workspace builds
npm run clean

# Install dependencies using clean lockfile (0 drift)
npm ci

# Build all packages offline (including unbundled + esbuild bundle)
npm run build

# Typecheck source code & subagents
npm run typecheck

# Run offline node:test harness integration tests (38 tests)
npm test

# Run runtime export and protocol smoke tests
npm run smoke

# Start original-style interactive Terminal UI
npm run start:tui

# Start headless JSON-lines RPC mode
npm run start:rpc

# Run development mode directly against TypeScript sources
npm run dev
```

## Provider & Model Configuration

The harness resolves provider credentials from standard environment variables or stores them locally in `.runtime/agent/auth.json` via the `/login` interactive command.

### Supported Provider Environment Variables
- **Anthropic**: `ANTHROPIC_API_KEY` (or `ANTHROPIC_AUTH_TOKEN`)
- **OpenAI**: `OPENAI_API_KEY`
- **Google Gemini**: `GEMINI_API_KEY`
- **OpenRouter**: `OPENROUTER_API_KEY`
- **DeepSeek**: `DEEPSEEK_API_KEY`
- **Groq**: `GROQ_API_KEY`
- **Amazon Bedrock**: standard AWS environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, or `AWS_PROFILE`)
- **Azure OpenAI**: `AZURE_OPENAI_API_KEY`
- **Mistral**: `MISTRAL_API_KEY`
- **xAI**: `XAI_API_KEY`

### Local Credential Management & Model Selection
In interactive TUI mode (`npm run start:tui`):
- Run `/login` to configure OAuth or API key credentials interactively; credentials are saved strictly to the isolated local directory (`.runtime/agent/auth.json`).
- Run `/model` to open the model selector overlay and browse available models across configured providers.
- Run `/model <provider/model-id>` (e.g. `/model anthropic/claude-3-5-sonnet`) to switch to a specific model directly.

## Runtime and Provenance

- **Vendored Baseline**: Source code baseline approved from repository commit `2b7a5991c5fffa58b9309bd76549dd9994c0950b`.
- **TUI Restoration Provenance**: Faithful UI architecture and components adapted from repository commit `b3a29f1111114fac696e2cfcd65acdb382a6ed5e` under MIT License.
- **Upstream Revision Status**: The upstream remote git revision is unverified; local vendored source bytes and licenses are the single source of truth.
- **Licenses Preserved**: Original MIT license bytes and copyright notices are strictly preserved in `LICENSE` and workspace manifests with zero modifications.
- **Runtime Isolation**: Harness configuration, credentials, sessions, package links, and scratch workspaces resolve locally under `.runtime/` (or via `GENERATION_HARNESS_RUNTIME_DIR`). Shell commands inherit the user's system `PATH` to access local utilities (e.g. `ls`, `git`).
- **Node.js ESM Only**: Clean Node.js 22+ ESM implementation. No Bun binary dependencies, no native C++ node-gyp builds. The unused `canvas` dev dependency and its native installer graph (`prebuild-install`, `node-addon-api`, etc.) have been pruned; all surviving third-party packages maintain exact version, resolved URL, and integrity hashes unchanged.
- **Strict Offline Test Execution**: Harness tests and workspace tests enforce `GENERATION_HARNESS_OFFLINE=1` through the hardened multi-layer network guard in `test/offline.mjs`.

## Verification & PASS/FAIL Evidence

| Check / Command | Result | Summary |
| :--- | :--- | :--- |
| `npm run clean` | **PASS** | Cleaned `dist` across all 8 workspaces. |
| `npm ci` | **PASS** | Verified clean install from pruned `package-lock.json` (canvas native build graph pruned, 0 surviving third-party drift). |
| `npm run build` | **PASS** | Successfully built all 8 workspaces + core esbuild bundle (76 files, 8.6 MiB). |
| `npm run typecheck` | **PASS** | Zero type errors across `langfens-harness` and `generation-subagents`. |
| `npm test` (root tests) | **PASS** | 38 integration tests passed (branding, isolation, tools, runtime, subagents, consolidation, TUI with virtual terminal). |
| `npm run smoke` | **PASS** | Verified core module exports, CLI binaries, headless RPC, and launcher scripts. |
| `npm test -w generation-telemetry` | **PASS** | 6 test files, 47 tests passed. |
| `npm test -w generation-tui` | **PASS** | 53 test files, all tests passed. |
| `npm test -w generation-codemode` | **PASS** | 6 test files, 226 tests passed. |
| `npm test -w generation-mcp` | **PASS** | 5 test files, 45 tests passed. |
| `npm test -w generation-agent-core` | **PASS** | 4 test files, 92 tests passed. |
| `npm test -w generation-ai` | **PASS** | 139 test files passed, 7 skipped, 0 failed; 1329 tests passed, 30 skipped. |

## Actual Limitations

1. **Catalog Refresh Is Independent of Inference**: `--offline` disables startup network operations such as catalog refresh; it does not remove static native model catalogs. Offline test commands use faux providers and do not contact remote endpoints.
2. **Built-in Tool Scope**: Built-in agent tools are strictly limited to `read`, `bash`, `edit`, and `write`. Ancillary tools (`find`, `grep`, `ls`) are retained as library functions, but are not exposed as default agent tools.
3. **Native Clipboard Fallback**: Native `.node` loading is disabled. Clipboard operations use supported operating-system CLI utilities (`pbcopy`, `wl-clipboard`, `xclip`, `xsel`, `clip.exe`, PowerShell) or ANSI OSC 52 terminal escape codes.
