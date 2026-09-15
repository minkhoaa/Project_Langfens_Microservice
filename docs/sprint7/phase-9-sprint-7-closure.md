# Phase 9 — Sprint 7 closure

> **Plan file:** This is Phase 9 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 9.1: Full verification suite

**Files:**
- Modify: none (verification step)

- [ ] **Step 1: BE build + test**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build
```

Expected: Build 0 errors. Test 73/73 passed. Warning count delta vs baseline = 0.

- [ ] **Step 2: FE typecheck + Vitest + build**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
npm run build
```

Expected: tsc exit 0. Vitest ≥ 102 tests pass (no skipped). Build 39+ pages.

- [ ] **Step 3: ai-service pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py tests/test_autogen_router.py -v
```

Expected: 5+3 = 8+ tests pass.

- [ ] **Step 4: Run §12.2.1 Python lint**

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

- [ ] **Step 5: Verify warning delta is 0**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj 2>&1 | grep -E "Warning\(s\)" | tail -1
```

Expected: `16 Warning(s)` (unchanged from baseline).

- [ ] **Step 6: Manual smoke test (record results)**

Open admin UI in browser:
1. Navigate to `/admin/exams/[some-id]`
2. Click "AI Author"
3. For each of 19 types in dropdown: click Generate → verify JSON parses → click Save → reload page → verify question appears in editor.
4. Record results in `docs/sprint7/MANUAL_SMOKE.md`.

- [ ] **Step 7: No untracked files**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git status -s | grep -v "^?" | head -5
```

Expected: empty (no untracked source files).

- [ ] **Step 8: Branch check**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git branch --show-current
```

Expected: `refactor/sync-dotest-admin-renderer`.

- [ ] **Step 9: Commit verification log**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add -f docs/sprint7/MANUAL_SMOKE.md
git commit -m "docs(sprint7): close Sprint 7 with full verification scoreboard"
```

---
