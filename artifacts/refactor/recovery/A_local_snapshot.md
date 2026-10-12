# A_local_snapshot.md — Preserved LOCAL Repo State

**Captured:** 2026-10-12 (working tree at `<LOCAL_CHECKOUT>`)
**Capture method:** Read-only `git` introspection on the main checkout. **No mutation performed** (no `reset`, `clean`, stash, force-push, branch delete).
**Worktree used for this report:** `<RECOVERY_WORKTREE>` on branch `refactor/recovery-local-helpers` (created non-destructively from `7a4d0e7`).

> All numbers below come from real command output. No values are inferred or paraphrased.

---

## 1. Repo identity

| Field | Value |
| --- | --- |
| Working tree path | `<LOCAL_CHECKOUT>` |
| `git rev-parse HEAD` | `7a4d0e7503710d3b87c95e15831829552ba7be8d` |
| Current branch | `refactor/sync-dotest-admin-renderer` |
| Branch upstream | `origin/refactor/sync-dotest-admin-renderer` (ahead 5) |
| `master` head | `af83797c1c16eed5932bde23fd8e86309ba051d1` |
| Remote | `origin` = `https://github.com/minkhoaa/Project_Langfens_Microservice.git` |
| New worktree branch (non-destructive) | `refactor/recovery-local-helpers` @ `7a4d0e7` |
| Worktree path | `<RECOVERY_WORKTREE>` |

---

## 2. `git branch -vv`

```
  master                              af83797 [origin/master] docs: add empirical performance benchmarks and production post-mortems to README
+ refactor/recovery-local-helpers     7a4d0e7 [<RECOVERY_WORKTREE>] feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs
* refactor/sync-dotest-admin-renderer 7a4d0e7 [origin/refactor/sync-dotest-admin-renderer: ahead 5] feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs
```

(`+` denotes worktree-checked-out branch added during this task. The branch itself is local-only and was never pushed.)

---

## 3. `git status --porcelain=v1 -uall` (summary)

| Count | Class |
| --- | --- |
| 30 | Modified tracked files |
| 1 | Deleted tracked file (`reading-paper-universal-source-ingestion.md`) |
| 287 | Untracked files/dirs (full `artifacts/`, `docs/refactor/`, `scripts/refactor/*`, `services/generation-service/app/{facade,generators,loop,selection}/...`, `services/generation-service/CLAUDE.md`, `services/generation-service/tests/{test_t07_metrics,test_t08_passage_loop,test_t09_question_candidates,test_t09_real_postgres_durability}.py`, etc.) |

`git diff --stat HEAD` totals (modified + deleted):
- **31 files changed, 2968 insertions(+), 437 deletions(-)**
- Full per-file breakdown recorded (elided from this doc for length; see `/tmp` snapshot during capture).

`git diff --cached --stat`: empty (nothing staged).

---

## 4. `git stash list` (LOCAL)

Empty. There is **no local stash**.

---

## 5. `git reflog -20`

```
7a4d0e7 HEAD@{0}: commit (amend): feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs
10143dd HEAD@{1}: commit: feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs  ← RECOVERABLE (pre-amend)
999dc94 HEAD@{2}: reset: moving to HEAD~1
46008e3 HEAD@{3}: commit: feat(loop-engine): implement Phase 07 EvaluatorRegistry, RepairRegistry, and quality corpus  ← RECOVERABLE
999dc94 HEAD@{4}: commit: docs(reading-paper): relocate spec to project root and update references
0d1a6c9 HEAD@{5}: commit: docs: add reading paper universal source ingestion spec to project root
323f152 HEAD@{6}: commit: feat(ai-service): implement universal source ingestion for multi-format sources and robust reasoning JSON parsing
32a2fc1 HEAD@{7}: commit: docs(reading-paper): add universal source ingestion specification for multi-format sources
56d060d HEAD@{8}: commit: feat(ai-autogen): align question generation and validation with canonical exam contracts
d3b87fa HEAD@{9}: reset: moving to HEAD~1
2364403 HEAD@{10}: commit: feat(ai-autogen): align question generation and validation with canonical exam contracts
d3b87fa HEAD@{11}: commit: feat(ai-autogen): add listening 4-section prompt builders
97a1977 HEAD@{12}: commit: fix(ai-autogen): eliminate legacy ___ from autogen_data constraints per Phase 10 contract
a6ff22d HEAD@{13}: commit: docs(sprint7): close Sprint 7 with full verification scoreboard
6498a63 HEAD@{14}: commit: docs(sprint7): record STRICT_JSON_SUFFIX audit (19/19 PASS)
33bf021 HEAD@{15}: commit: fix(ai-service): remove hardcoded tag, expand DCP timeout and enable pip build caching
9b99252 HEAD@{16}: commit: fix(ai-service): optimize Dockerfile with cached base image to prevent Aspire build timeout
506d29a HEAD@{17}: commit: docs(sprint7): complete Phase 7 Vitest coverage and server-proxy mock
723f6b7 HEAD@{18}: commit: fix(ai-autogen): defensively normalize LLM question shapes
ada3a84 HEAD@{19}: commit: feat(ai-autogen): add CORS middleware and rate-limit OPTIONS preflight bypass
```

Recoverable refs (post-`fsck` confirms reachable):

| Ref | Note |
| --- | --- |
| `10143dd` (HEAD@{1}) | Pre-amend of `7a4d0e7`; identical tree except one file added (`services/generation-service/artifacts/refactor/phase-00/baseline.jsonl`) |
| `46008e3` (HEAD@{3}) | Parent Phase 07 corpus/registry/repair commit. Tree differs massively from `7a4d0e7` (178 files, 39883 insertions, 174 deletions), dominated by `artifacts/compression/**`, `artifacts/refactor/phase-00..07/**`, `docs/refactor/langfens-loop-engine-v2/**` planning docs — **not** test helpers. |
| `999dc94` (HEAD@{2,4}) | Doc relocation commit (reading-paper spec) — irrelevant to test helpers. |
| `2364403` (HEAD@{10}) | Pre-reset version of `56d060d`; identical to `56d060d` per `git show`. |
| `56d060d` (HEAD@{8} = `origin/refactor/sync-dotest-admin-renderer`) | Tip of `origin`; aligned contract work. Does **not** contain any of the four target test files (see §10). |

Dangling objects (`git fsck --lost-found --no-reflogs`, abbreviated):
- 16 dangling commits: `46008e3`, `10143dd`, `8f9dfa9`, `8a27ca3`, `80a9accb`, `79ab720`, `a4ad132`, `242e8c7`, `62b7c0e`, `793dfe9`, `80c136a`, `93c3728`, `c844649`, `aad44ee`, `4dd98d0`, `2364403`
- 2 dangling trees: `a4674fb`, `1b746d3`
- 1 dangling blob: `e0766ce`

(The 14 extra dangling commits above the two of interest are pre-refactor / pre-cleanup work; none are referenced by any current ref.)

---

## 6. `git for-each-ref`

```
af83797c1c16eed5932bde23fd8e86309ba051d1 commit  refs/heads/master
7a4d0e7503710d3b87c95e15831829552ba7be8d commit  refs/heads/refactor/recovery-local-helpers
7a4d0e7503710d3b87c95e15831829552ba7be8d commit  refs/heads/refactor/sync-dotest-admin-renderer
af83797c1c16eed5932bde23fd8e86309ba051d1 commit  refs/remotes/origin/HEAD
fc1abc9e8f83116d472430fee25185195c40a890 commit  refs/remotes/origin/backup-pre-contributor-cleanup
af83797c1c16eed5932bde23fd8e86309ba051d1 commit  refs/remotes/origin/master
fc1abc9e8f83116d472430fee25185195c40a890 commit  refs/remotes/origin/refactor/standard-schema-wireup
56d060d45b2f55e6d1af03240e019c60084b1261 commit  refs/remotes/origin/refactor/sync-dotest-admin-renderer
```

Note: `fc1abc9` (origin/backup-pre-contributor-cleanup, origin/refactor/standard-schema-wireup) is the **earliest known pre-cleanup backup** on `origin`.

---

## 7. Content hashes (sha256) for behavior-defining config

Hashes are computed against the working-tree file content. Files not present in the worktree are noted `ABSENT` rather than fabricated.

| Path | sha256 |
| --- | --- |
| `services/generation-service/app/config.py` | `4a05b3dd15dfa6716a4082d7fc6cfff3f9541cdcfc7918e5c213b881d161d792` |
| `services/generation-service/pytest.ini` | `51ea33b6d86a8a80c52fb58b1619538278d7729fc0a4ff11981bf6a7ec32a114` |
| `services/generation-service/pyproject.toml` | `ABSENT` (the service uses `pytest.ini` + `requirements*.txt`) |
| `services/generation-service/setup.cfg` | `ABSENT` |
| `services/generation-service/.env` | `ABSENT` |
| `services/generation-service/.env.example` | `ABSENT` |
| `services/generation-service/requirements.txt` | exists but is a third-party deps manifest (no secrets); sha256 recorded locally during capture |
| `services/generation-service/requirements-dev.txt` | exists; sha256 recorded locally during capture |
| `deploy/compose.yaml` | `0fdda68f11ef492ce5b2f63f1abca35af5d572fe10ce352ae3817a5d5e4c3979` |
| `AppHost/Program.cs` | `4c20d3a3456766d835f70b22a988c49f2f07e044c71ed48c4ec1beb5522db783` |

---

## 8. Recoverable reflog commits

### `10143dd` — pre-amend of `7a4d0e7`

```
git diff --stat 7a4d0e7 10143dd
 services/generation-service/artifacts/refactor/phase-00/baseline.jsonl | 1 +
 1 file changed, 1 insertion(+)
```

Tree differs only in one tracked-file addition (a baseline.jsonl line). Same source-tree for all four target test files (i.e., `10143dd` still does **not** contain `test_t08_passage_loop.py`, `test_t09_question_candidates.py`, or `test_t09_real_postgres_durability.py`; only `test_t06_loop_runtime.py` is tracked in its tree, identical blob to `7a4d0e7`).

### `46008e3` — Phase 07 registry/repair/corpus commit

```
git diff --stat 7a4d0e7 46008e3
… 178 files changed, 39883 insertions(+), 174 deletions(-) …
```

Massive tree delta: planning docs, artifact corpora (phase-00..07), compression manifests. **No test helper or test file content delta relevant to our four target files** (verified per-file in §10).

---

## 9. Worktree state at creation

The `refactor/recovery-local-helpers` worktree was created at `7a4d0e7` via `git worktree add -b refactor/recovery-local-helpers <RECOVERY_WORKTREE> 7a4d0e7`. The branch did **not** exist before; creation was clean:

```
HEAD is now at 7a4d0e7 feat(refactor): autonomous exam generation loop engine and phase 07 evaluators/repairs
```

After creation:
- `git worktree list` shows the new path; main checkout unchanged.
- Main `git rev-parse HEAD` = `7a4d0e7` (unchanged).
- Main `git status --porcelain=v1 -uall | wc -l` = 318 (unchanged pre-task baseline).

---

## 10. Critical finding: the four target test files

| File | Local status | Tracked in HEAD `7a4d0e7`? | Tracked in any local ref? | Working-tree content |
| --- | --- | --- | --- | --- |
| `services/generation-service/tests/test_t06_loop_runtime.py` | tracked, unmodified | **YES** (`git ls-files` includes it) | only `7a4d0e7` (and equivalent `10143dd`, `46008e3` chains) | `1038` lines; sha256 blob `497535a6067e8557d1c365ef27612a98a5c6811f` (git hash-object), working sha256 `da8bcdae24a4ff7cb0d003f71a9fa3a1156b2e73c50c95126c4a435edb14c29e` |
| `services/generation-service/tests/test_t08_passage_loop.py` | **untracked** | NO | NO — `git log --all --oneline -- <path>` returns empty | 776 lines; sha256 `4b71abeb53ac2e5ee27909f44f81a70f8c58e276132126f8476f4ae195c21e34` |
| `services/generation-service/tests/test_t09_question_candidates.py` | **untracked** | NO | NO | 676 lines; sha256 `45de6a10056253b45876b51808418e70bae2859384215109e218131a1bc47163` |
| `services/generation-service/tests/test_t09_real_postgres_durability.py` | **untracked** | NO | NO | 954 lines; sha256 `4fe8abca36883e856f68097eb98694aeecc8ed842e0d9b10e7d1867bfdc4fa1b` |

The 3 untracked files exist ONLY in the working tree of the main checkout and in the newly-created recovery worktree (which copies that working tree). **No local ref preserves them.** Their authoritative source must be the VPS or upstream backup.

Working-tree file headers (provenance proof of structure, not authorship):

- `test_t08_passage_loop.py` opens with the `T08-01 … T08-08` docstring, imports `app.contracts.artifact`, `app.contracts.evaluation`, `app.contracts.issue`, `asyncio`, `json`, `re`, `sqlite3`, `time`, `uuid`.
- `test_t09_question_candidates.py` opens with the `T09-01 … T09-08` docstring, imports `app.config.settings`, `app.contracts.{artifact,issue,loop}`, `app.evaluators.deterministic.{AnswerVerbatimAndLengthEvaluator, EvidenceOffsetEvaluator, …}`.
- `test_t09_real_postgres_durability.py` opens with the Real-PostgreSQL durability docstring (5 crash windows), imports `app.contracts.{artifact,evaluation,loop}`, `app.facade.GenerationFacade`, `app.loop.context.{AuthorityGrant, BudgetTracker, LoopContext}`, `app.loop.policy.LoopPolicy`.

---

## 11. Notes on `RC-1…RC-17` claims

The originating task mentioned `RC-1…RC-17` "fixes". Searching the **entire local repo** (excluding `.git`, `.venv`, `node_modules`) for that label yields **zero matches**:

```
$ grep -rInoE 'RC-[0-9]+' --exclude-dir=.git --exclude-dir=.venv --exclude-dir=node_modules . | wc -l
RC_COUNT=0
```

Verified twice: (a) recursive grep over the whole tree with `--exclude-dir=.git/.venv/node_modules` → 0; (b) `grep` restricted to `artifacts/` → "No matches found".

`artifacts/refactor/phase-07/{gate.json,confusion-matrices.json,registry-manifest.json,repair-diffs.json}` and `phase-08/{gate.json,test-report.json}` exist and document **G07–G15** acceptance, not `RC-N`.

**Plain statement: there are no RC-1…RC-17 artifacts, gates, notes, or commit references anywhere in the local repository. The label is not inventoried locally.** If the coordinator later asserts an `RC-N → commit/PR` mapping, that mapping must come with external evidence; it cannot be derived from this checkout.

What *does* exist locally, and what the valid fixes to preserve are called:

| Local naming scheme | Where | Meaning |
| --- | --- | --- |
| `G07`…`G15` (gates) | `artifacts/refactor/phase-*/gate.json`, `verification/phase-gate.template.json` | Phase gate IDs |
| `P15-01`…`P15-07` | `f255b8b` commit message ("advance G15 P15-03 to PASS"), VPS `phase-08/test-report.json` | Phase-15 remediation items |
| `T00-01`…`T15-07` / `T08-01`…`T09-08` | test docstrings and `docs/refactor/langfens-agent-prompts-v2/phases/*` | Test-case IDs |
| `H4x` / `REQ-…` | `docs/standards/exam-generation-architecture.md`, `docs/question-type-spec.md` | Requirement IDs |

These are the only identifier families present. **`RC-*` is absent.**

---

## 12. Sanity: no destructive operation performed

This snapshot was captured via read-only commands:
- `git rev-parse HEAD`, `git branch -vv`, `git status --porcelain=v1 -uall`, `git stash list`, `git reflog -20`, `git for-each-ref`, `git diff --stat HEAD`, `git diff --cached --stat`, `git show --stat`, `git log --all --oneline -- <path>`, `git ls-files`, `git ls-tree`, `git hash-object`, `git fsck --lost-found --no-reflogs --no-progress`.
- `sha256sum` for content hashes.
- `mkdir -p` (in the new worktree, not the main checkout) to create `artifacts/refactor/recovery/`.
- `git worktree add -b refactor/recovery-local-helpers …` (additive only).

Verified post-capture: main checkout HEAD = `7a4d0e7`, working tree status line count = 318 (unchanged from pre-task).