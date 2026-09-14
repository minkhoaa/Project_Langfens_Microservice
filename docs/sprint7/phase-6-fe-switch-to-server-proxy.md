# Phase 6 — FE switch to server-proxy

> **Plan file:** This is Phase 6 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 6.1: Add server-proxy provider to aiConfig.ts

**Files:**
- Modify: `langfens-fe-app/src/app/admin/_lib/aiConfig.ts:1-87`

- [ ] **Step 1: Rewrite `aiConfig.ts`**

```ts
export type AiProvider = "server-proxy" | "anthropic" | "openai" | "google";

export interface AiConfig {
  provider: AiProvider;
  apiKey: string;
  model: string;
  endpoint: string;
  maxTokens: number;
}

export const DEFAULT_AI_CONFIG: AiConfig = {
  provider: (process.env.NEXT_PUBLIC_AI_PROVIDER as AiProvider) || "server-proxy",
  apiKey: process.env.NEXT_PUBLIC_AI_API_KEY || "",
  model: process.env.NEXT_PUBLIC_AI_MODEL || "",
  endpoint:
    process.env.NEXT_PUBLIC_AI_SERVICE_URL ||
    process.env.NEXT_PUBLIC_AI_ENDPOINT ||
    "http://localhost:8092",
  maxTokens: 4096,
};

export function isAiConfigured(cfg: AiConfig): boolean {
  if (cfg.provider === "server-proxy") return Boolean(cfg.endpoint);
  return Boolean(cfg.apiKey);
}

export async function callAi(
  cfg: AiConfig,
  systemPrompt: string,
  userPrompt: string,
  context?: { type: string; skill: string; count: number; difficulty: number }
): Promise<string> {
  if (cfg.provider === "server-proxy") {
    if (!cfg.endpoint) {
      throw new Error("Server-proxy endpoint not configured. Set NEXT_PUBLIC_AI_SERVICE_URL.");
    }
    const res = await fetch(`${cfg.endpoint}/api/v1/autogen/questions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({
        type: context?.type ?? "MULTIPLE_CHOICE_SINGLE",
        skill: context?.skill ?? "READING",
        passage: userPrompt,
        count: context?.count ?? 1,
        difficulty: context?.difficulty ?? 3,
        extra_context: systemPrompt,
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`ai-service ${res.status}: ${err}`);
    }
    const data = await res.json();
    return JSON.stringify(data.questions ?? []);
  }

  if (cfg.provider === "anthropic") {
    const res = await fetch(cfg.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": cfg.apiKey,
        "anthropic-version": "2023-06-01",
        "anthropic-dangerous-direct-browser-access": "true",
      },
      body: JSON.stringify({
        model: cfg.model,
        max_tokens: cfg.maxTokens,
        system: systemPrompt,
        messages: [{ role: "user", content: userPrompt }],
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Anthropic API ${res.status}: ${err}`);
    }
    const data = await res.json();
    return data?.content?.[0]?.text || "";
  }

  if (cfg.provider === "openai") {
    const res = await fetch(cfg.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${cfg.apiKey}`,
      },
      body: JSON.stringify({
        model: cfg.model,
        max_tokens: cfg.maxTokens,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt }],
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`OpenAI API ${res.status}: ${err}`);
    }
    const data = await res.json();
    return data?.choices?.[0]?.message?.content || "";
  }

  throw new Error(`Unsupported AI provider: ${cfg.provider}`);
}

export function tryParseLlmJson(text: string): unknown[] | null {
  const trimmed = text.trim();
  if (!trimmed) return null;
  const withoutFences = trimmed
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/```\s*$/, "")
    .trim();
  const tryParse = (s: string): unknown | null => {
    try {
      return JSON.parse(s);
    } catch {
      return null;
    }
  };
  let parsed = tryParse(withoutFences);
  if (parsed == null) {
    const match = withoutFences.match(/(\[[\s\S]*\]|\{[\s\S]*\})/);
    if (match) parsed = tryParse(match[1]);
  }
  if (parsed == null) return null;
  return Array.isArray(parsed) ? parsed : [parsed];
}
```

- [ ] **Step 2: Verify typecheck**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
```

Expected: exit 0.

- [ ] **Step 3: Verify Vitest still passes**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test
```

Expected: 25 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/_lib/aiConfig.ts
git commit -m "feat(fe-llm): add server-proxy provider, default for new sessions"
```

---

## Task 6.2: Wire AiAuthorModal to new callAi signature

**Files:**
- Modify: `langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx:60`

**Interfaces:**
- Consumes: `callAi` from Task 6.1 with new 4th-arg `context`

- [ ] **Step 1: Locate the callAi call**

```bash
grep -n "callAi(config, prompt.system, userPrompt)" langfens-fe-app/src/app/admin/exams/[id]/_components/AiAuthorModal.tsx
```

Expected: 1 match.

- [ ] **Step 2: Update to pass context**

Before:
```ts
const text = await callAi(config, prompt.system, userPrompt);
```

After:
```ts
const text = await callAi(config, prompt.system, userPrompt, {
  type,
  skill: "READING",
  count,
  difficulty: Number(typeMeta.defaultDifficulty),
});
```

- [ ] **Step 3: Verify typecheck + Vitest**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run test
```

Expected: tsc exits 0. Vitest: 25 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/\[id\]/_components/AiAuthorModal.tsx
git commit -m "feat(fe-admin): wire AiAuthorModal to server-proxy callAi context"
```

---
