# Phase 6 — FE autogen client

> **Plan file:** This is Phase 6 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 6.1: Add createQuestionBulk to adminApi.ts

**Files:**
- Modify: `langfens-fe-app/src/app/admin/_lib/adminApi.ts:75-87`

- [ ] **Step 1: Add new function**

After `createQuestion` function (line 78), add:

```ts
export async function createQuestionBulk(
  sectionId: string,
  questions: AdminQuestionUpsert[]
): Promise<{ created: { idx: number; id: string }[]; errors: { idx: number; message: string }[] }> {
  const res = await apisExam.post("/admin/question/bulk", { sectionId, questions });
  return res.data?.data;
}
```

- [ ] **Step 2: Verify typecheck**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
```

Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/adminApi.ts
git commit -m "feat(fe-admin): add createQuestionBulk adminApi client"
```

---

## Task 6.2: Add autogenClient.ts for 4 skills

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_lib/autogenClient.ts`

- [ ] **Step 1: Write `autogenClient.ts`**

```ts
const AI_SERVICE = process.env.NEXT_PUBLIC_AI_SERVICE_URL || "http://localhost:8092";

interface AutogenClientOptions {
  jwt?: string;
}

export async function autogenQuestions(
  req: {
    type: string;
    skill: "READING" | "LISTENING" | "WRITING" | "SPEAKING";
    passage: string;
    count: number;
    difficulty: number;
    extra_context?: string;
  },
  opts: AutogenClientOptions = {}
): Promise<{ questions: Record<string, unknown>[] }> {
  const res = await fetch(`${AI_SERVICE}/api/v1/autogen/questions`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(opts.jwt ? { Authorization: `Bearer ${opts.jwt}` } : {}),
    },
    credentials: "include",
    body: JSON.stringify(req),
  });
  if (!res.ok) throw new Error(`autogenQuestions failed: ${res.status} ${await res.text()}`);
  return res.json();
}

export async function autogenListeningExam(
  req: { topic: string; level: number; question_count: number },
  opts: AutogenClientOptions = {}
): Promise<{
  sections: Array<{
    idx: number;
    title: string;
    audio_script: string;
    questions: Record<string, unknown>[];
  }>;
}> {
  const res = await fetch(`${AI_SERVICE}/api/v1/autogen/listening-exam`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(opts.jwt ? { Authorization: `Bearer ${opts.jwt}` } : {}),
    },
    credentials: "include",
    body: JSON.stringify(req),
  });
  if (!res.ok) throw new Error(`autogenListeningExam failed: ${res.status}`);
  return res.json();
}

export async function autogenWritingTask(
  req: { task_type: "TASK_1" | "TASK_2"; topic: string; level: number },
  opts: AutogenClientOptions = {}
): Promise<{
  prompt: string;
  chart_description: string | null;
  chart_url: string | null;
  model_answers: string[];
  suggested_vocabulary: string[];
}> {
  const res = await fetch(`${AI_SERVICE}/api/v1/autogen/writing-task`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(opts.jwt ? { Authorization: `Bearer ${opts.jwt}` } : {}),
    },
    credentials: "include",
    body: JSON.stringify(req),
  });
  if (!res.ok) throw new Error(`autogenWritingTask failed: ${res.status}`);
  return res.json();
}

export async function autogenSpeakingScenario(
  req: { scenario_type: "PART_1" | "PART_2" | "PART_3" | "ROLEPLAY"; topic: string; level: number },
  opts: AutogenClientOptions = {}
): Promise<{
  slug: string;
  title: string;
  difficulty: string;
  ielts_part: string;
  context: string;
  user_role: string;
  agent_role: string;
  opening_prompt: string;
  target_vocabulary: string[];
  target_grammar: string[];
  suggested_topics: string[];
  duration_min: number;
  turn_count_target: number;
}> {
  const res = await fetch(`${AI_SERVICE}/api/v1/autogen/speaking-scenario`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(opts.jwt ? { Authorization: `Bearer ${opts.jwt}` } : {}),
    },
    credentials: "include",
    body: JSON.stringify(req),
  });
  if (!res.ok) throw new Error(`autogenSpeakingScenario failed: ${res.status}`);
  return res.json();
}
```

- [ ] **Step 2: Verify typecheck**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
```

Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/_lib/autogenClient.ts
git commit -m "feat(fe-admin): add autogenClient.ts for 4-skill auto-gen API"
```

---
