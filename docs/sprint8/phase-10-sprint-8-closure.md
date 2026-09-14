# Phase 10 — Sprint 8 closure

> **Plan file:** This is Phase 10 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 10.1: Full verification suite

**Files:**
- Create: `docs/sprint8/MANUAL_SMOKE.md` (verification log)

- [ ] **Step 1: BE build + test**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build
```

Expected: 76/76 tests passed (73 baseline + 3 new). Build 0 errors.

- [ ] **Step 2: FE typecheck + Vitest + build**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
npm run build
```

Expected: tsc exit 0. Vitest 106+ tests pass. Build 39+ pages.

- [ ] **Step 3: ai-service pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_listening_router.py tests/test_autogen_writing_router.py tests/test_autogen_speaking_router.py tests/test_matplotlib_chart.py -v
```

Expected: 14 tests passed (3+3+3+5).

- [ ] **Step 4: Run §12.2.1 extended Python lint**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
files = [
    'app/prompts/autogen.py',
    'app/prompts/autogen_templates.py',
    'app/prompts/autogen_data.py',
    'app/schemas/autogen.py',
    'app/routers/autogen.py',
    'app/prompts/autogen_listening.py',
    'app/prompts/autogen_writing.py',
    'app/prompts/autogen_speaking.py',
    'app/schemas/autogen_listening.py',
    'app/schemas/autogen_writing.py',
    'app/schemas/autogen_speaking.py',
    'app/routers/autogen_listening.py',
    'app/routers/autogen_writing.py',
    'app/routers/autogen_speaking.py',
    'app/services/matplotlib_chart.py',
]
all_clean = True
for f in files:
    with open(f) as fp:
        tree = ast.parse(fp.read())
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            if node.name.startswith('_'):
                continue
            if not node.returns:
                print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
                all_clean = False
            for arg in node.args.args:
                if arg.arg == 'self':
                    continue
                if not arg.annotation:
                    print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
                    all_clean = False
print('PYTHON_LINT_CLEAN' if all_clean else 'PYTHON_LINT_DIRTY')
"
```

Expected: `PYTHON_LINT_CLEAN`.

- [ ] **Step 5: Run §12.2.3 .NET nullable check**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | grep -E "warning CS" | grep -i "AdminQuestion\|BulkInsert"
```

Expected: no output.

- [ ] **Step 6: Manual smoke test**

Open admin UI:
1. Navigate to `/admin/exams/auto-gen`.
2. Step 1: pick each skill in turn.
3. Step 2: fill `topic="renewable energy"`, `level=6`.
4. Step 3: for each of 4 skills, click Generate → verify preview appears.
5. Record results in `docs/sprint8/MANUAL_SMOKE.md`.

- [ ] **Step 7: No untracked files**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git status -s | grep -v "^?" | head -5
```

Expected: empty.

- [ ] **Step 8: Branch check**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git branch --show-current
```

Expected: `refactor/sync-dotest-admin-renderer`.

- [ ] **Step 9: Commit verification log**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add -f docs/sprint8/MANUAL_SMOKE.md
git commit -m "docs(sprint8): close Sprint 8 with full verification scoreboard"
```

---
