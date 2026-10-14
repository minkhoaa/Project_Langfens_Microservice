# Native agent execution protocol — domain-owned, no third-party skill

This document defines the workflow **inside these prompts**. It uses the coding agent's ordinary repository, search, editor, shell and test capabilities only; no external workflow/skill, plugin, orchestration framework or special slash command is required. AI generation providers, database and libraries already part of Langfens remain product dependencies, not agent workflow dependencies.

## Execution targets

- **Phase entry:** Open `prompts/prompt-phase-XX.md`. The agent owns only RGXX and its five numbered micro-sprints. Complete each sprint separately with evidence; phase-level checks and closure are allowed only after all mandatory sprint gates PASS. This may occur across sessions using persisted state. Never launch the next phase implicitly.
- **Sprint entry:** Open `prompts/sprints/prompt-sprint-XX-YY.md`. Scope is just that sprint and its applicable regression boundary. Do not start sibling sprints.
- The target baseline is NOT the verified source state. RG01/a fresh audit provides current file mappings; never invent routes, entity names, tests, model quota or deployed services.

## Autonomous internal pipeline (applies to every phase and sprint)

**0 — Orient / establish truth.** Read applicable AGENTS.md and root instructions; inspect branch/HEAD, dirty/untracked work, env availability and existing status. Read Source of Truth, parent phase, active sprint, normative contract and relevant verification records. Identify inherited clean tests vs pre-existing failures. Do not reset or overwrite unrelated work.

**1 — Bound / derive a tiny plan internally.** For the current sprint, write a short checkable task slice (≤4 implementation substeps), target files by real paths, risks, required positive/negative/edge/regression tests and an explicit stop rule. Store this brief plan in the local sprint record. Planning is embedded, not a separate skill/phase or a giant multi-phase plan.

**2 — Implement the smallest justified change.** First reuse audited existing modules/contracts. For executable code, add or identify a failing focused regression that demonstrates the absent expected behavior, then change the owner layer minimally and confirm the test. For document/audit/data steps, validate the relevant artifact instead; do not force fake red tests. Never edit immutable results to force PASS, and never weaken production invariants for research.

**3 — Verify by risk level.** Run focused positive + meaningful negative, edge and applicable regression checks. Contract changes: cross-language DTO/schema/ACL tests. Durable changes: DB/worker/idempotency and hash/closure proofs. Research changes: frozen dataset, no leakage, valid denominators, evidence hashes. Report actual command/test names, exit codes, fixture IDs, environment and observed results. Mock-only tests do not certify live behavior.

**4 — Checkpoint honestly.** Record status, exact source SHA/worktree, touched files, contract/dataset/prompt/rubric hashes, test evidence, unresolved risks, and next safe resume point under `generation_baseline/.execution/RGXX/`. Persist references without secrets or private/raw student/LLM data. `PASS` requires all mandatory checks; otherwise `BLOCKED`, `FAILED`, `PARTIAL` or `NOT_RUN` with reasons.

**5 — Close scope.** Sprint gate PASS requires observed behavior plus risk-based regression proof. Phase PASS requires all five sprint PASS records, matched source/config provenance and phase-level integration/security/research verification. Emit a concise report of changed files, tests, status and known limitations. Stop on unresolved blockers; do not silently substitute an easier test, switch models, drop failed runs, change frozen tasks or claim work completed elsewhere.

## Domain-specific safety and resource boundaries

- **Reading V2:** strict 3×40, six groups, passage length, source provenance, accepted heads, lease/epoch fencing, current hash-bound closure and atomic Draft persist remain authoritative. Section-level research mode must not alter production full-paper acceptance.
- **Grammar:** retrieved rules are evidence, not independently checked question gold. Blind solving is answer-free, alternatives/ambiguous distractors must be challenged, and expert gold is reserved for research scoring.
- **Independent evaluation:** config labels, in-loop PASS and ground-truth must never enter blinded judge views. For failed runs, retain output availability separately from execution status; count every frozen assignment.
- **Experiments:** A/B/C get paired inputs and a common independent rubric. Calibration, evaluator holdout and FINAL_EVAL never mix. C does not have to win; report cost/quality latency and uncertainty truthfully.
- **State/publishing:** Research artifacts cannot become production published snapshots. Turning off optional semantic stages for ablation never disables authorization, content hash, dependencies, durable checkpoints, lease/fencing or real usage accounting.
- **Operational authorization:** Prompt scope alone does not authorize pushing, deploying, publishing, destructive DB changes, modifying live infrastructure or running expensive live provider campaigns. Missing external permissions/resources -> `BLOCKED` with non-destructive evidence.

## Execution records (machine-checkable, not a substitute for code/test proof)

For each sprint write `generation_baseline/.execution/RGXX/RGXX-SYY.json` following [Sprint status example](templates/SPRINT_STATUS_TEMPLATE.json); add redacted links to test output. A phase status lives in `generation_baseline/.execution/RGXX/PHASE_STATUS.json` using [Phase status example](templates/PHASE_STATUS_TEMPLATE.json). `.execution/` is excluded from package manifests and should not be committed unless explicitly sanitized for audit. Use `tools/check_execution_records.py --phase RGXX` to validate record structure and gate consistency; it cannot independently certify true test results.

## Stop and resume

- At each sprint boundary preserve a durable state record. Resume from the first non-PASS sprint **only after verifying** recorded SHA, dependency status and actual artifact/test presence; stale checkpoints require revalidation, not unquestioned trust.
- If source is absent, offline-only checks cannot satisfy RG01 implementation audits. If external benchmark work is unapproved, freeze/prepare permissible artifacts and mark actual execution BLOCKED.
- Ambiguous compatibility decisions and frozen-research modifications require explicit decision records rather than guesses.
