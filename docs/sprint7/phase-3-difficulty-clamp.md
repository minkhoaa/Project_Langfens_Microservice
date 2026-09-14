# Phase 3 — Difficulty clamp

> **Plan file:** This is Phase 3 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 3.1: Clamp difficulty in AiAuthorModal

**Files:**
- Modify: `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx:72`

**Interfaces:**
- Consumes: existing `obj.difficulty`, `typeMeta.defaultDifficulty`
- Produces: clamped `Difficulty` field in `enriched` array

- [ ] **Step 1: Locate the line**

```bash
grep -n "Difficulty: Number(obj.difficulty" langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx
```

Expected: 1 match at line ~72.

- [ ] **Step 2: Replace with clamped version**

Before:
```ts
Difficulty: Number(obj.difficulty ?? typeMeta.defaultDifficulty),
```

After:
```ts
Difficulty: Math.max(1, Math.min(5, Number(obj.difficulty ?? typeMeta.defaultDifficulty))),
```

- [ ] **Step 3: Verify typecheck + Vitest still pass**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
```

Expected: tsc exits 0. Vitest: 25 tests still pass.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/\[id\]/_components/AiAuthorModal.tsx
git commit -m "fix(fe-admin): clamp LLM-supplied difficulty to [1, 5]"
```

---
