# Repository instruction audit

## Scope and recovery

- Audited the working tree at Git HEAD `dd1792e` using tracked paths, non-ignored untracked paths, instruction reads, documentation headings/hashes, inbound-reference searches and targeted source/manifests/workflow reads. Large documentation families were classified by role and tooling references, not loaded wholesale.
- Initial working tree: 209 existing tracked Markdown files, including three generated model cards excluded from instruction cleanup. No non-ignored untracked Markdown existed. Ignored benchmark output, caches, dependencies, build output, model artifacts and backups were not cleanup targets.
- Existing root-guide edits, the root legacy-guide deletion, `.omp/` deletions and two unrelated untracked crawler/seed files predated this task. They were not reverted or attributed to this migration. Relevant safety rules from deleted guides were inspected read-only through Git.
- Every file deleted by this task matched its committed content and had a Git recovery path; each migrated guide had a replacement before removal.
- No ancestor instruction files were found from `/` through the repository's parent, nor standalone global instruction files at the standard Pi agent root. Harness-supplied global instructions remain in effect. No global settings, extensions, installed skills or Superpowers resources were modified.

## Classification of the initial Markdown inventory

| Class | Files/family | Decision |
| --- | --- | --- |
| MIGRATE | Root agent guide | Rebuild as a 28-line navigation/invariant guide; nested instructions are explicitly read on demand. |
| MIGRATE → REMOVE | AppHost and all 12 service legacy guides (13 files) | Keep verified unique rules in local `AGENTS.md`; eliminate tool branding, port tables, repeated commands, generic tutorials and stale paths. |
| REMOVE | Root duplicate of [blueprint recovery report](reports/AUTONOMOUS_BLUEPRINT_RECOVERY_REPORT.md) | Byte-identical SHA-256 `0738e059b9b5600dba1273e1b52386763b42556e03126f7c67803fbd0cf01fdf`; no inbound tracked references before deletion. Canonical report retained. |
| KEEP | 12 root technical documents, including README, metrics, acceptance/reconciliation and RG10/RQ2 reports | User onboarding and distinct historical evidence. Correct obvious README service/database counts, setup and endpoint assumptions; do not promote historical claims to current guarantees. |
| KEEP | 28 existing `docs/` files | Architecture, crawler contract, reports, and Superpowers plans/specs retain technical and historical value. |
| KEEP | 140 `generation_baseline/` Markdown files | Requirements, contracts, research governance, prompts, provenance/licensing, handoffs and verification evidence. Source/tests and the package validator reference them. They are on-demand task specifications, not startup instructions. |
| KEEP | Eight `reports/` files | Distinct flow audits, architecture and handoffs; no byte-identical duplicates identified. |
| KEEP | `deploy/seeds/README.md`, `scripts/e2e/README.md`, `services/speaking-service/README.md` | Seed operation notes, E2E prerequisites and unique manual transcription probes. |
| EXCLUDE / preserve | Three model README/model cards | Generated model/checkpoint metadata; not agent instructions. |

The KEEP rows cover 191 existing repository-owned technical documents. Apart from targeted README corrections, they remain unchanged. Pre-existing missing `.omp/` Markdown and the already deleted root legacy guide were not new cleanup deletions.

## Verified corrections and constraints retained

- Dictionary lookup uses PostgreSQL `pg_trgm`, not an active Elasticsearch indexer. The repository has 12 domain services and nine AppHost databases.
- Exam has a real test project. Its schema-reset fixtures are destructive; Phase02/03 contain fixed database targets and Phase02 overwrites connection environment. A DSN override is not isolation.
- AI live tests may run without `--run-live` when endpoints are reachable; explicit offline selection is `-m "not live"`. Missing ML dependencies may be mocked.
- Generation now uses a single authenticated `/execute` pipeline, not legacy `/section` routes. Python commits authoritative state only through exam-service APIs.
- Speaking consumers receive grading requests, call AI over HTTP and publish correlated responses; Python is not a broker consumer for that path.
- Shared question types are string constants. Graders retain singleton registration, deterministic normalization and all-or-nothing points.
- Preserved service ownership, internal auth/header distinctions, source licensing/SSRF checks, blind-solver/gold separation, research non-publication, hash-bound evaluation, fencing/idempotency and explicit provider/budget accounting.
- Full cap-profile admission/resume details are retained in [reading-runtime-caps.md](standards/reading-runtime-caps.md), outside startup context.
- Only two Python comments/docstrings changed to repair references to removed guides; AST comparison excluding the module docstring confirmed no behavioral changes.

## Validation and context size

- All 12 services have local guides; AppHost, gateway, shared contracts and destructive exam tests have justified guides. Attempt tests use the owning service guide rather than another instruction layer.
- All 17 guides meet the line targets: root 28 lines; nested guides 11–19 lines. Literal source/doc references and build/test project paths were checked against the working tree.
- No repository-owned legacy guide remains. The remaining source comment about a sibling frontend checkout's legacy guide is an external reference, not a dangling reference to a file deleted here.
- Existing baseline package checker: **2015/2015 checks passed** in a temporary copy with its linked JSON templates and root handoff preserved. This avoids rewriting its tracked validation report. An initial incomplete temp-copy attempt failed on omitted link targets; the faithful-copy rerun passed.
- `git diff --check` passed. No application builds, database tests, service startup, dependency installs, paid calls or external-provider validation were performed.
- Measured file bytes: initial working-tree root 2,867 → 2,482; initial root plus 13 scoped legacy guides 56,137 → 24,595 across the 17 new/rebuilt guides. This is file-size evidence, **not a measurement of Pi startup context**.
- Approximate token estimates use UTF-8 bytes / 4, rounded up (tokenizer-dependent): root about 621; complete guide set about 6,150. Only root is needed for root startup; relevant nested guides are loaded when work requires them.
- Historical technical documents may still contain environment-specific endpoints, old test counts or target-design claims. They were retained as evidence, not silently rewritten into current runtime authority; implementation/live behavior must still be verified for the selected task.
