# Langfens Harness

Standalone Node.js ESM backend harness. Run commands from this directory with Node >=22.19.0 and npm. The native agent loop, inference providers, sessions, RPC and local extension lifecycle are retained.

```sh
npm ci
npm run build
npm run typecheck
npm test
npm run dev
npm start -- --mode rpc --no-session
```

The local CLI is `langfens-harness` (no global executable). All dependencies are installed in this npm workspace. Configuration uses `.langfens` and `LANGFENS_HARNESS_*`; launching defaults to the private `.runtime/` directory, overridable with `LANGFENS_HARNESS_RUNTIME_DIR`. `bash` executes normal system commands: this is not a security sandbox. Offline startup disables automatic catalog/update activity, not arbitrary inference or tool networking.

## Migration status

Native package/CLI/config identity migration is in progress. The current dependency split is `langfens-harness-core -> langfens-agent-core, langfens-ai, langfens-tui, langfens-codemode, langfens-mcp`; `langfens-agent-core -> langfens-ai -> langfens-telemetry`. These are local source workspaces, not external runtime aliases. Core consolidation and the vendored local subagent extension follow the audited migration plan. Do not interpret extension startup as proof of successful delegation.

See [ISOLATION.md](ISOLATION.md) for baseline audit and actual checks. Test inference uses faux providers and a network guard; no live provider quality claim is made. Python 3 on Unix is needed only for PTY testing, not runtime.

## Attribution

Derived from [Pi 1.4.0](https://github.com/earendil-works/pi/tree/v1.4.0), commit `4a080252f06caf63a525d7873c5d94d3c23887e0`. Original MIT license and copyright are preserved verbatim in [LICENSE](LICENSE); third-party notices remain with their source. Branding changes do not remove attribution or license obligations.
