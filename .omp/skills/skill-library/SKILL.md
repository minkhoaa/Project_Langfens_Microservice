---
name: skill-library
description: Route Langfens work to selected global ECC skills, native project workflows, and useful specialist reviewers without copying the plugin.
---

# Langfens ECC router

The global `ecc@ecc` installation is the implementation source. Project
`.omp/config.yml` selects names; it does not install or copy ECC resources.
Skill bodies load on demand, not as always-on engineering rules.

## DAILY: core stack and quality

| Work | Global skills |
|---|---|
| .NET services, DI, async | `dotnet-patterns`, `csharp-testing` |
| Python / FastAPI | `python-patterns`, `fastapi-patterns`, `python-testing` |
| PostgreSQL changes | `postgres-patterns`, `database-migrations` |
| API boundaries / errors | `api-design`, `contract-first`, `error-handling` |
| Code quality and proof | `search-first`, `coding-standards`, `tdd-workflow`, `verification-loop`, `terminal-ops`, `security-review` |

Read only those matching the task. Generic ECC npm/TypeScript examples are not
Langfens commands; use the repository manifests and `/skill:langfens-verify`.

## Project workflows

- `langfens-aspire`: AppHost 13.3.2, dependencies, dynamic endpoints, YARP routing.
- `langfens-grader`: actual grader/registration signatures and all-or-nothing scores.
- `langfens-generation`: pinned runtime caps, durable authority, review, streaming.
- `langfens-service-setup`: service-owned contracts, persistence, deployment wiring.
- `langfens-verify`: focused offline checks, destructive test-DB guardrails, live prerequisites.

Preserved domain agents: `aspire-architect`, `grader-specialist`, and
`generation-loop-expert`. They autoload their corresponding local skill and
inherit the user's scope; they do not authorize source edits or live operations.

## LIBRARY: selected, task-triggered global skills

- Infrastructure: `redis-patterns`, `docker-patterns`, `deployment-patterns`,
  `production-audit`, `safety-guard`.
- LLM/RAG/inference: `cost-aware-llm-pipeline`, `latency-critical-systems`,
  `eval-harness`, `ai-regression-testing`, `prompt-optimizer`, `mle-workflow`.
- Coordination/review: `orch-add-feature`, `orch-change-feature`, `orch-fix-defect`,
  `orch-refine-code`, `team-agent-orchestration`, `agent-self-evaluation`.
- Docs/repository operations: `documentation-lookup`, `architecture-decision-records`,
  `git-workflow`, `github-ops`.
- Setup maintenance: `configure-ecc`, `agent-sort`, `skill-scout`,
  `workspace-surface-audit`, `security-scan`.

Available global reviewers include `code-reviewer`, `csharp-reviewer`,
`python-reviewer`, `fastapi-reviewer`, `database-reviewer`, `security-reviewer`,
`rag-pipeline-reviewer`, `mle-reviewer`, `pr-test-analyzer`, and
`silent-failure-hunter`. Use a specialist only where its scope adds value.

## Commands and excluded library

Selected global prompt templates: `/ecc:plan`, `/ecc:code-review`,
`/ecc:python-review`, `/ecc:fastapi-review`, `/ecc:test-coverage`,
`/ecc:refactor-clean`, `/ecc:update-docs`, `/ecc:update-codemaps`,
`/ecc:review-pr`, and `/ecc:ecc-guide`. Project entry points use
`/skill:langfens-*`; no redundant local command shims are needed.

Off-stack/global remainder stays installed but is excluded from this project's
skill discovery. Excluded skills are not addressable via `skill://` here; add a
needed name to the include list deliberately, retaining custom names and current
exclusions. No React/Next.js/frontend/mobile workflow is inferred from a sibling
checkout. Do not duplicate plugin bodies to make an excluded command visible.

See `.omp/README.md` for evidence, MCP recommendations, and OMP compatibility.
