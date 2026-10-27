# generation-harness creation

Independent Node.js backend harness and multi-agent execution subsystem for Langfens generation workflows.

## Architecture

```text
services/generation-harness/
├── packages/
│   ├── generation-harness-core/       # Core agent loop, session/context, tools, TUI & RPC
│   │   ├── src/
│   │   │   ├── agent/                 # Agent loop & events
│   │   │   ├── ai/                    # Multi-provider LLM abstraction
│   │   │   ├── runtime/               # Isolated runtime paths & environment
│   │   │   ├── session/               # Session & context management
│   │   │   ├── rpc/                   # Headless JSON-lines RPC mode
│   │   │   ├── tools/                 # Built-in tools: read, bash, edit, write
│   │   │   └── tui/                   # Minimal development/testing Terminal UI
│   │   └── package.json
│   ├── generation-subagents/          # Single-agent & chained multi-agent delegation
│   │   ├── src/
│   │   └── package.json
│   ├── agent/                         # generation-agent-core
│   ├── ai/                            # generation-ai
│   ├── codemode/                      # generation-codemode
│   ├── mcp/                           # generation-mcp
│   ├── telemetry/                     # generation-telemetry
│   └── tui/                           # generation-tui
├── package.json
├── package-lock.json
├── tsconfig.json
└── README.md
```

## Features

- **Native Architecture**: All workspace packages, CLI entrypoints, runtime paths, and configuration environments operate under the `generation` namespace.
- **Minimal Core Tools**: Four core tools registered natively: `read`, `bash`, `edit`, `write`.
- **Local Subagents**: Independent, sequential execution with isolated child sessions, model overrides, progress tracking, and local core SDK binding.
- **Minimal TUI & Headless RPC**: Interactive terminal interface and headless JSON-lines RPC mode for backend integration.
- **Node.js/npm Workspaces Only**: ESM, Node.js scripts, no native compilation requirements, no Bun runtime.

## Commands

```bash
# Install dependencies cleanly
npm ci

# Build all packages offline
npm run build

# Typecheck source code & subagents
npm run typecheck

# Run test suite
npm test

# Run smoke tests
npm run smoke

# Start interactive TUI
npm run start:tui

# Start headless RPC
npm run start:rpc

# Run development mode against source
npm run dev
```

## Attribution & License

Original upstream codebase by Mario Zechner and Nico Bailon (MIT License). Attributions and licenses are preserved in respective packages and `LICENSE` files.
