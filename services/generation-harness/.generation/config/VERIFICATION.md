# Configuration follow-up — offline verification

Implemented `npm run config` using public native `SettingsManager` and `generation-tui` components. No agent/model runtime is created. Scope user defaults to `.runtime/agent/settings.json`; project overrides remain under `.generation/settings.json`. Native schema validation, atomic writes, limited editable preferences, `--show`, `--paths`, `--validate`, `--set` and `--unset` are supported. Endpoint sampling uses the existing native `models.json` format with a versioned example, not a new provider runtime.

The frozen Core's blocked resource-oriented CLI `config` remains blocked. Its private selector is not imported; this does not claim feature parity with Pi's resource/package config UI. Authentication, endpoints and models are not discovered or probed by the configuration command. Normal native model selection/login remain separate user actions, not performed here.

## Executed

```sh
cd services/generation-harness
node .generation/evaluation/run-offline.mjs /tmp/langfens-config-offline-final-1
```

- Root/Subagents and domain typechecks: PASS.
- Build: PASS, sequentially before tests.
- Harness: **113 passed, 0 failed, 0 skipped**, including 9 new config tests.
- Retained Subagents: **3,491 passed, 0 failed, 13 skipped**. Skips are not claimed as exercised.
- Frozen packages, backend, AppHost and gateway: tracked diff and untracked status empty.
- Whitespace: PASS.
- Snapshot readiness: GO for offline preparation only; semantic pilot/advancement evidence remains insufficient. No live authorization follows from settings changes.

**Post-run concurrency observation:** the final source-hash comparison detected an external concurrent edit to `.generation/extensions/reading.ts` after the full suite and receipt were captured. That edit was not made or reverted by this configuration task. Consequently the full-suite PASS/readiness GO above applies only to the hashed snapshot, **not the current combined workspace**. Current combined-workspace readiness is UNCERTAIN / INSUFFICIENT_EVIDENCE until its new source state is tested. All configuration-source hashes still matched the receipt at the check; the 9 focused config tests were rerun afterward and passed again, and whitespace passed.

Tests cover native user/project merge, preserving unrelated settings, invalid types and unsafe keys, private file permissions, symlink rejection, no-TTY read-only behavior, credential/catalog non-access, native settings-list editing, narrow rendering, and actual native TUI lifecycle with a virtual terminal. Existing leakage/context/UNCERTAIN/native-tool regressions remain passing.

Evidence: `../evaluation/evidence/config-followup-receipt.json` and `config-followup-report.json`, with command/source/log hashes. Raw logs are at the explicit temporary logRoot in the receipt; rerun if unavailable. Earlier `offline-readiness.json` remains a historical snapshot from before this configuration follow-up, not a current-source hash assertion.

No LIVE inference, repository commit/push, backend change, frozen-package change, coordinator or generation pipeline was added.
