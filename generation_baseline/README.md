# Langfens — Generation Research Source of Truth

**Edition:** 3.0 | **State:** TARGET SPECIFICATION; actual code/research evidence NOT VERIFIED | **Date:** 2026-10-14

This **single directory** is the authoritative *requirements baseline* for Langfens's **Multi-Agent Quality & Research Extension** (KLTN RQ2). It is not a replacement application repository and does not assert that any uninspected implementation exists.

## One command, one specification target

Full phase requirement:

```text
/brainstorming @generation_baseline/prompts/prompt-phase-00.md
```

Single micro-sprint requirement:

```text
/brainstorming @generation_baseline/prompts/sprints/prompt-sprint-00-01.md
```

`/brainstorming` owns its own planning, execution, verification and closure behavior. **These Markdown files only declare WHAT is required and how correctness is objectively determined.** They contain no competing execution/playbook/skill instructions. Use the command only if the installed `/brainstorming` skill actually supports `@file` references.

## Authoritative reading map

1. [SOURCE_OF_TRUTH.md](SOURCE_OF_TRUTH.md) — authority, nonnegotiable safety/compatibility rules and precedence.
2. [MASTER_PROPOSAL.md](MASTER_PROPOSAL.md) — problem statement, RQ2 scope, target end state and flows.
3. [ACCEPTANCE_10_OF_10.md](ACCEPTANCE_10_OF_10.md) — evidence-backed definition of 10/10 and closure.
4. [PHASE_INDEX.md](PHASE_INDEX.md) — 14 dependency-bound phases.
5. [SPRINT_INDEX.md](SPRINT_INDEX.md) — 70 independent, bounded requirements.
6. [contracts/CONTRACT_REGISTRY.md](contracts/CONTRACT_REGISTRY.md) + [contracts/JSON_SCHEMAS.json](contracts/JSON_SCHEMAS.json) — normative data semantics and **illustrative target schema**; adapt to audited actual DTOs.
7. [verification/GATE_MATRIX.md](verification/GATE_MATRIX.md) + [verification/TEST_CATALOG.json](verification/TEST_CATALOG.json) — evidence-based acceptance requirements.
8. [research/RQ2_PROTOCOL.md](research/RQ2_PROTOCOL.md) — frozen benchmark design and measurement rules.

## Boundaries

- Historical Reading V2 (G00–G15) is **reported accepted** under three live full Reading papers, 120 questions manually/semantically reviewed; it is not newly reverified in this package.
- New RG00–RG13 gates are **new work**, not reruns of historical gates. Source Audit RG01 decides what is already present and can be reused.
- Source of truth must remain rooted at `generation_baseline/`. No autonomous deletion/cleanup of old repo documents is implied.
- KLTN **title remains unchanged**. RQ1 Speaking/phoneme research is separate. Production canary/rollback has historical UNVERIFIED status unless independently executed in a separately authorized operational scope.
- All 14 phase specs and 70 sprint specs define requirements only. They do not specify how any tool/agent should plan or work.

## Package verification

```bash
python3 generation_baseline/tools/verify_baseline.py
```

This checks the **package itself** (counts, references, schema and requirements); it does not execute .NET, Python, PostgreSQL, provider calls or research campaigns. See `verification/PACKAGE_VALIDATION_REPORT.json` for the offline results.
