# Langfens Harness

Independent Node.js harness with a native agent loop, terminal UI, JSON-lines RPC and Subagents delegation. Requires Node.js 22.19 or newer.

## Architecture

| Workspace | Purpose |
| --- | --- |
| `generation-harness-core` | Sessions, configuration, native extensions, TUI/RPC and four built-in tools: `read`, `bash`, `edit`, `write` |
| `generation-subagents` | Agent discovery, isolated child sessions, single/parallel delegation and native workflows |
| `generation-agent-core` | Agent loop, messages and tool execution |
| `generation-ai` | Provider/model APIs and streaming |
| `generation-telemetry` | Telemetry interfaces and in-memory instrumentation |
| `generation-tui` | Terminal rendering and components |
| `generation-codemode` | Optional sandboxed JavaScript execution |
| `generation-mcp` | Optional Model Context Protocol integration |

`scripts/run.mjs` launches the local Core bundle, native Subagents and the `/config` command extension. Auxiliary integrations are opt-in; they are not additional default Core tools. See [Subagents documentation](packages/generation-subagents/README.md) for delegation and configuration.

IELTS specifications and passive test vectors live in [`.generation/contracts/`](.generation/contracts/README.md). The independent [Reading extension](.generation/reading/README.md) is loaded by `npm run start:reading`; it selects a minimal Academic Reading author profile with seven native domain tools and two native review specialists, not a coordinator. Schema validity alone does not establish semantic correctness or consumer compatibility.

## Commands

Run from `services/generation-harness/`:

```sh
npm ci
npm run build
npm run typecheck
GENERATION_HARNESS_OFFLINE=1 npm test
GENERATION_HARNESS_OFFLINE=1 npm run smoke

npm run start:tui
npm run start:rpc
npm run start:reading
npm run config
npm run dev
```

Build creates both the SDK modules and the bundled CLI. `npm run dev` uses the TypeScript source entry. Dependency installation requires available packages or a populated local cache; the offline test flag is not an installation mechanism.

## Offline testing and safety

- Tests must use `GENERATION_HARNESS_OFFLINE=1` and the `test/offline.mjs` bootstrap, which removes ambient provider credentials and blocks external fetch, HTTP(S), TCP, TLS and WebSocket connections. Loopback mock servers remain permitted.
- AI test credentials are explicitly registered in-memory fixtures, not host credential files. Default AI test configuration excludes live-provider suites.
- Use disposable runtime directories for subprocess tests. Never import host credentials, refresh real tokens or run live inference as a test.
- The offline startup flag controls startup network operations; it is not a sandbox or a substitute for the test network guard.
- Offline/mock results do not authorize paid inference, database access, publication or deployment.

## Runtime isolation

Configuration, credentials, sessions, installed packages and scratch workspaces use `.runtime/`, or the directory selected by `GENERATION_HARNESS_RUNTIME_DIR`. The launcher invokes workspace-owned Core/Subagents entries and isolates their configuration from global Pi installations.

The shell tool retains the system `PATH` for local commands. Runtime path/configuration isolation is not a filesystem or process sandbox for tools or explicitly loaded extensions.

## Provider & Model Configuration

`npm run config` restores the standalone configuration TUI: F1 Resources, F2 Config, F3 Roles/Agents and F4 Tools. Use Tab to switch User/Project scope; resource toggles persist native filters without executing or installing resources. `/config` opens the same manager inside the harness. See [configuration usage](.generation/config/README.md) for CLI edits, variable metadata, paths and safety boundaries.

`npm run start:reading` uses separate `.runtime/reading/` state/workspace, a Reading system prompt and tool allowlist, and Reading-only native specialist discovery. It loads Reading/Subagents and `/config` explicitly, disables ambient coding context and project trust, and does not start generation automatically. Configure this profile's credentials/model in its own `/config`. Normal `npm start` keeps the existing coding profile and scratch workspace. See the [Reading guide](.generation/reading/README.md) for verification limits.

Provider credentials can be supplied through environment variables or configured interactively with `/login`. Local credentials are stored under `.runtime/agent/auth.json` in the default runtime.

| Provider | Environment variable |
| --- | --- |
| Anthropic | `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN` |
| OpenAI | `OPENAI_API_KEY` |
| Google Gemini | `GEMINI_API_KEY` |
| OpenRouter | `OPENROUTER_API_KEY` |
| DeepSeek | `DEEPSEEK_API_KEY` |
| Groq | `GROQ_API_KEY` |
| Amazon Bedrock | Standard AWS credentials, region or profile |
| Azure OpenAI | `AZURE_OPENAI_API_KEY` |
| Mistral | `MISTRAL_API_KEY` |
| xAI | `XAI_API_KEY` |

In the TUI, `/model` opens model selection; `/model <provider/model-id>` selects a specific model. Provider configuration is not permission to run paid inference.

## Limitations

- The default Core tool set is exactly `read`, `bash`, `edit`, `write`. Native Subagents registers its own delegation/supervision tools separately.
- Static model catalogs may remain available while startup network access is disabled.
- Clipboard support uses operating-system utilities or terminal OSC 52 fallbacks; native `.node` clipboard loading is disabled.

## Source and licenses

Original MIT license notices are retained in `LICENSE` and workspace license files. Subagents source attribution and per-file provenance are recorded in `packages/generation-subagents/UPSTREAM-PROVENANCE.json`; the original upstream README and version changelog remain reference documentation, not harness-specific runtime instructions.
