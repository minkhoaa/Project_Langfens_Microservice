# Langfens Generation Baseline — Native Agent Pipeline v4.0

**Scope:** KLTN RQ2 Multi-Agent Quality & Research Extension · **Status:** TARGET DESIGN / NOT SOURCE-VERIFIED · **Root directory:** `generation_baseline/`

This folder is the **source of truth for requirements, contracts, domain-specific agent execution, verification gates, 14 RG phases and 70 short sprints**. The agent workflow is documented **inside these files**, not delegated to third-party skills or slash commands. The Reading V2 handoff remains historical context; a new source audit establishes code reality.

## Start with one file

**Whole phase:** attach/reference `@generation_baseline/prompts/prompt-phase-00.md` and say `Execute RG00` (then RG01... after independent gates). The phase file tells the coding agent to work through five small sprints with tests and checkpoints.

**Single sprint:** attach/reference `@generation_baseline/prompts/sprints/prompt-sprint-03-01.md` and say `Execute RG03-S01`. This does only that sprint.

No specialized planning/execution skill, special CLI or external orchestration tool is required. The agent derives a small plan, implements, verifies and closes the **selected scope** using available ordinary coding tools.

## Navigation

1. [SOURCE_OF_TRUTH.md](SOURCE_OF_TRUTH.md) — normative precedence and immutable rules.
2. [MASTER_PROPOSAL.md](MASTER_PROPOSAL.md) — exact Reading/Grammar/A-B-C target and KLTN boundary.
3. [AGENT_PIPELINE.md](AGENT_PIPELINE.md) — built-in coding-agent pipeline, statuses, checkpoints, stop/resume and domain guardrails.
4. [PHASE_INDEX.md](PHASE_INDEX.md) — RG00–RG13 prerequisite graph.
5. [SPRINT_INDEX.md](SPRINT_INDEX.md) — all 70 micro-sprints.
6. [contracts/CONTRACT_REGISTRY.md](contracts/CONTRACT_REGISTRY.md) / [JSON_SCHEMAS.json](contracts/JSON_SCHEMAS.json) — target contracts, not proof of wire DTOs.
7. [verification/GATE_MATRIX.md](verification/GATE_MATRIX.md), [TEST_CATALOG.json](verification/TEST_CATALOG.json) — requirements and proof.
8. [research/RQ2_PROTOCOL.md](research/RQ2_PROTOCOL.md) — paired, frozen benchmark design.
9. [ACCEPTANCE_10_OF_10.md](ACCEPTANCE_10_OF_10.md) — evidence-backed, not perfection-in-every-LLM-response criteria.

## No automatic production changes

RG00 freezes requirements; RG01 audits actual source. Running a phase does not authorize push/deploy, production data migrations, student publication, unapproved paid provider campaigns or old-handoff cleanup. No phase gate starts as PASS. Source/test/DB/provider results remain NOT_RUN until independently executed.

## Baseline package self-check (offline only)

```bash
python3 generation_baseline/tools/verify_baseline.py
```

The package checker verifies 14 phase prompts, 70 sprint prompts, internal execution instructions, schema validity, references and 280 planned test descriptions. It is not a backend/database/LLM test.
