# Harness configuration UI

Restored from repository commit `0106f6d` (removed in `93d585a`), adapted to the current native harness and Reading extension. No Core/SDK/Subagents files, old Reading workflow, `--approve`, fixed Question quotas or automatic agent roster were restored.

From `services/generation-harness/`:

```sh
npm run start:reading                   # native TUI + Reading + /config
npm run start:reading -- --mode rpc     # same extensions, RPC mode
npm run config                         # standalone configuration TUI; no model call
npm run config -- --local               # Project scope first
npm run config -- --settings            # preferences panel directly
npm run config -- --show                # JSON summary (safe without a TTY)
npm run config -- --resources           # native resource inventory, without executing it
npm run config -- --paths
npm run config -- --validate            # settings only, no credential/model catalog read
```

Within the harness use `/config`, `/config local`, `/config full` or `/config creds`. It is a native extension command, not a model tool. Default `npm start` retains its scratch CWD and gains the config command only; `start:reading` uses the harness project CWD and explicitly loads the existing Reading extension. An explicit `--cwd` overrides that CWD; `--no-extensions` disables launcher extensions. Native project trust remains in effect; the alias never auto-approves a project or starts inference.

## Controls

- **F1 Resources:** extensions, skills, prompts and themes. Search, arrows, Space/Enter to toggle; Tab switches User/Project scope. Project overrides cycle inherit/load/unload.
- **F2 Config:** provider/model, thinking, theme, transport, compaction, cache warming, retry and terminal preferences. Enter edits; text input owns its keystrokes. Credential storage and injected provider-variable names appear as metadata, not secret values.
- **F3 Roles & Agents:** current capability descriptions and native-discovered agents. No fabricated generator/blind-solver definitions or forced workflow.
- **F4 Tools:** declarations for core, foreground native delegation and Reading capabilities. Inside `/config`, the current native session's registered/active tools are also shown. Standalone inventory is availability information, not a running-session audit.
- Esc returns to resources/closes. Mouse and tab-navigation shortcuts are retained from the historical UI.

## Settings and credentials

- Project overrides: `.generation/settings.json` (created only on an explicit edit).
- Isolated user settings: `.runtime/agent/settings.json`.
- Provider keys: `.runtime/agent/auth.json`; only provider/type metadata is displayed.
- Custom provider/model endpoints: `.runtime/agent/models.json`; see `models.example.json` for a placeholder-only example, which is not loaded automatically.
- `GENERATION_HARNESS_RUNTIME_DIR` selects a different runtime. `/config` launched through the launcher retains the harness configuration root even when its working CWD differs.

```sh
npm run config -- --set defaultProvider YOUR_PROVIDER
npm run config -- --set defaultModel YOUR_EXACT_MODEL_ID
npm run config -- --set defaultThinkingLevel high
npm run config -- --scope project --set retry.enabled false
npm run config -- --unset defaultModel
```

For credentials prefer native `/login` or injected provider environment variables. Historical `--set-key PROVIDER KEY` / `--unset-key PROVIDER` are retained for compatibility; command-line keys may enter shell history/process listings. Key writes are local, mode-0600 atomic replacements; symlink escapes/corrupt credential files fail rather than silently overwrite them. Do not use real keys in tests. Config never imports global Pi credentials or syncs host keys.

Native resource discovery runs in a sanitized, filesystem-permission-bounded metadata worker, with no network, installation, child execution, resource imports or model/session creation. Changing settings affects a later native launch/reload. Local runtime separation is not filesystem isolation, consumer compatibility, IELTS quality or permission for paid inference/production operations.

## Verification

```sh
GENERATION_HARNESS_OFFLINE=1 node --test test/config.test.mjs test/config-resources.test.mjs test/config-restoration.test.mjs
GENERATION_HARNESS_OFFLINE=1 npm test
GENERATION_HARNESS_OFFLINE=1 node --test .generation/reading/test/*.test.mjs
```

Fixtures use disposable project/runtime directories, synthetic credentials, the existing offline guard and native virtual-terminal/SDK/RPC paths. No global credential discovery, real-provider test or production mutation is required.
