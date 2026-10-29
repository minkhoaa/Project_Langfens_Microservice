# Resource-manager correction — offline verification

`npm run config` now opens **Global Resources**, not the preference panel. The tree groups native-discovered installed npm/git/local packages and top-level resources into Extensions, Skills, Prompts and Themes. It supports search, up/down/page navigation, checkbox persistence, Tab Global/Project scope switching, and F2 for the separate Settings panel. Project overrides cycle inheritance/load/unload and do not mutate user settings. Explicit CLI extensions are visibly fixed, not falsely toggleable. Missing/unresolved packages are searchable `[?]` entries and never installed by config.

Discovery uses the public native package resolver in a credential-free, isolated-HOME Node metadata worker. Filesystem read permissions are restricted to selected project/checkout/runtime; writing and child-process execution are not allowed. Native offline resolution skips missing packages. Resources/package scripts are never evaluated by the inspector. Configured enablement is not a claim about a running session's model context, successful extension loading or skill consumption.

## Focused result — PASS

Executed again after observing concurrent workspace changes:

```sh
GENERATION_HARNESS_OFFLINE=1 NODE_OPTIONS="--import=$PWD/test/offline.mjs" \
  node --test test/config.test.mjs test/config-resources.test.mjs
```

**26 passed, 0 failed, 0 skipped.** Log: `/tmp/langfens-config-resources-focused.log`. Its hash is archived in `../evaluation/evidence/config-resources-receipt.json`.

Coverage includes native four-type discovery without execution, npm/git/local manifests, scoped override cycles, exact filters, preserving version pins/other preferences, preserving disabled siblings when enabling one item from an empty allowlist, managed runtime symlinks, fixed CLI resources, all missing-package declarations remaining searchable, no host/global npm fallback or custom npm-command execution, auth/models non-access, filesystem escape blocking, native TUI lifecycle, filtering, scope/Settings switching, and narrow/resized rendering.

## Full-suite evidence — snapshot only, NOT current-workspace approval

The sequential launcher ran at `/tmp/langfens-config-resources-final-1/`:

- Typecheck, domain typecheck and build: exit 0.
- Harness suite: **130 passed, 0 failed, 0 skipped**.
- Retained Subagents: **3,491 passed, 0 failed, 13 skipped**; skips are not exercised coverage.
- Frozen/backend/AppHost/gateway diff/status checks: empty, exit 0.
- Whitespace: exit 0.

However, comparing **pre-test source hashes → runner receipt → current files** detected concurrent edits outside this resource-manager task to `package.json` and `test/reading.test.mjs`. The newer combined workspace/test selection was not what this full-suite run exercised. Those changes were preserved, not reverted. Config-source hashes remained stable and the 26 focused tests were rerun successfully.

Therefore current combined-workspace readiness is **UNCERTAIN / INSUFFICIENT_EVIDENCE**, not GO. The annotated receipt marks the reproducibility requirement UNCERTAIN so `readiness.mjs` reproduces that result; it does not silently reuse the runner's unconditional historical GO.

Evidence records:

- `../evaluation/evidence/config-resources-source-baseline.json`
- `../evaluation/evidence/config-resources-receipt.json`
- `../evaluation/evidence/config-resources-report.json`

The full raw receipt/logs remain in the explicit temporary logRoot; regenerate if removed. No frozen package was edited, no LIVE inference/model session was created, and no repository commit or push was made. No native `verify_evidence` approval or pilot/publication authorization follows from this UI or its tests.
