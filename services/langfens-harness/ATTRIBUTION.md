# Source attribution and vendoring record

## Core

Derived from Pi 1.4.0, commit `4a080252f06caf63a525d7873c5d94d3c23887e0`, https://github.com/earendil-works/pi/tree/v1.4.0 . Copyright (c) 2025 Mario Zechner; MIT notice preserved verbatim in root `LICENSE` and core `LICENSE`. Existing third-party license/copyright notices remain with retained source.

The native agent loop, inference/streaming, session/context and tool implementations are retained rather than reconstructed. Package identity/import/path changes are local adaptations, not a dependency on an upstream installation.

## Subagents

Fixed source input: pi-subagents **0.83.0**, https://github.com/nicobailon/pi-subagents . Copyright (c) 2026 Nico Bailon; the original MIT notice is preserved verbatim in `packages/langfens-subagents/LICENSE`. Input was a fixed installed source distribution, not a floating branch. No runtime resolution reads that installation.

- `agents/frontmatter.js` and its declaration were copied from the pinned distribution. Only JS type annotations were added; parser behavior is retained and its implementation is checked with checkJs.
- `runs/shared/harness-spawn.ts` adapts authoritative host-root/manifest/entry selection from `runs/shared/pi-spawn.js` and `loadHostPiCodingAgent` in `runs/shared/child-session.js`. Global/package-manager/PATH retries, binary overrides and unrelated runners are removed.
- `runs/shared/child-session.ts` adapts `createDefaultChildSessionFactory`: existing local SDK loader, settings/resource/session managers, native createAgentSession/bindExtensions and abort/shutdown/disposal. Conversation state is independent; configured native provider runtime may be shared without global cwd/env patches.
- `runs/foreground/execution.ts` adapts the native runSingleAttempt/runSync lifecycle: session prompt/subscription, tool/text progress, abort forwarding, terminal status/output/usage and cleanup. Actual inference/tool iteration remains inside the preserved core engine.
- `runs/foreground/subagent-executor.ts` adapts single/ordered delegation and the sequential runner previous-output substitution/result-collection path. It is deliberately a narrow adapter, not a new workflow language, scheduler or orchestration framework.
- `shared/output.ts` adapts output/error filtering from `shared/utils.js`. Acceptance-validator/CLI footer heuristics are removed; final native text blocks and usage are returned without inventing child success. The usage representation is the retained core's native Usage shape.

These files are **adaptations**, not a claim that the full upstream execution files were copied unchanged. Missions, panes/worktrees, remote/external CLI adapters, scripted workflows, acceptance validators, skills/presets/installers and durable background jobs were not imported: they are not dependencies of the required fresh local single/ordered native-session path.

### Fixed input SHA-256 identities

| Source file | SHA-256 |
| --- | --- |
| `package.json` | `753e66504724d74e12dd02ba324744dbe3a9a5073dc5ffdf22c0154ebf36b7e8` |
| `LICENSE` | `2d20dfacd9742706e564470dc77438608a1e54b0ed46959f080709389209093c` |
| `src/agents/frontmatter.js` | `24349037cc51b294fcf37d8bc616f5a8b80b24e3a494a340b552c4b3b81df385` |
| `src/agents/frontmatter.d.ts` | `ccb4094a11313eb904c32d8dc70befd74ff3f3d632287b26cd5965c0f8765584` |
| `src/runs/shared/child-session.js` | `440d0135f201f2f7bc94e33ec1aec4b10a425f743f6b0ca73dacd8d5aaabc682` |
| `src/runs/shared/pi-spawn.js` | `c54cf1dcb464bf9bbcd100300ee501a8904f60dda69618cb483595371c9f854e` |
| `src/runs/foreground/execution.js` | `8df32fe40f1c8a129348dad260333dd186849817a087939619a617c2115a212e` |
| `src/runs/background/subagent-runner.js` | `7783189b5fcedf1e3dfa68193a17ac88732d2bcb53b5af9e600df68382fd2907` |
| `src/shared/utils.js` | `418d828632d39a9540bae9f13e2f3554104c5392a22edf6c495c506e78c66a8e` |
