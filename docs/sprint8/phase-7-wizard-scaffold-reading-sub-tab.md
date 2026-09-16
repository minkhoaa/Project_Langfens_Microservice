# Phase 7 — Wizard scaffold + Reading sub-tab

> **Plan file:** This is Phase 7 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 7.1: Add wizard step components

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/StepIndicator.tsx`
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SkillPicker.tsx`
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/TopicForm.tsx`
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/NavButtons.tsx`

- [ ] **Step 1: Write `StepIndicator.tsx`**

```tsx
"use client";

interface StepIndicatorProps {
  step: number;
  totalSteps: number;
}

export function StepIndicator({ step, totalSteps }: StepIndicatorProps) {
  return (
    <div className="flex items-center gap-2 mb-6" data-testid="step-indicator">
      {Array.from({ length: totalSteps }).map((_, i) => (
        <div
          key={i}
          className={`flex-1 h-2 rounded ${
            i + 1 <= step ? "bg-blue-500" : "bg-slate-300"
          }`}
        />
      ))}
    </div>
  );
}
```

- [ ] **Step 2: Write `SkillPicker.tsx`**

```tsx
"use client";

interface SkillPickerProps {
  skill: "reading" | "listening" | "writing" | "speaking";
  onChange: (skill: "reading" | "listening" | "writing" | "speaking") => void;
}

export function SkillPicker({ skill, onChange }: SkillPickerProps) {
  const skills: Array<"reading" | "listening" | "writing" | "speaking"> = [
    "reading",
    "listening",
    "writing",
    "speaking",
  ];
  return (
    <div className="grid grid-cols-2 gap-4" data-testid="skill-picker">
      {skills.map((s) => (
        <button
          key={s}
          type="button"
          onClick={() => onChange(s)}
          className={`p-4 rounded-lg border-2 ${
            skill === s
              ? "border-blue-500 bg-blue-50 text-blue-900"
              : "border-slate-300 bg-white text-slate-700"
          }`}
        >
          {s.charAt(0).toUpperCase() + s.slice(1)}
        </button>
      ))}
    </div>
  );
}
```

- [ ] **Step 3: Write `TopicForm.tsx`**

```tsx
"use client";

interface TopicFormProps {
  topic: string;
  level: number;
  onTopic: (topic: string) => void;
  onLevel: (level: number) => void;
}

export function TopicForm({ topic, level, onTopic, onLevel }: TopicFormProps) {
  return (
    <div className="space-y-4" data-testid="topic-form">
      <div>
        <label htmlFor="topic" className="block text-sm font-medium mb-1">
          Topic
        </label>
        <input
          id="topic"
          type="text"
          value={topic}
          onChange={(e) => onTopic(e.target.value)}
          placeholder="e.g. renewable energy"
          className="w-full px-3 py-2 border border-slate-300 rounded"
        />
      </div>
      <div>
        <label htmlFor="level" className="block text-sm font-medium mb-1">
          Band Level (1-9)
        </label>
        <input
          id="level"
          type="number"
          min={1}
          max={9}
          value={level}
          onChange={(e) => onLevel(Number(e.target.value))}
          className="w-full px-3 py-2 border border-slate-300 rounded"
        />
      </div>
    </div>
  );
}
```

- [ ] **Step 4: Write `NavButtons.tsx`**

```tsx
"use client";

interface NavButtonsProps {
  step: number;
  totalSteps: number;
  onPrev: () => void;
  onNext: () => void;
  canNext: boolean;
}

export function NavButtons({ step, totalSteps, onPrev, onNext, canNext }: NavButtonsProps) {
  return (
    <div className="flex justify-between mt-6">
      <button
        type="button"
        onClick={onPrev}
        disabled={step === 1}
        className="px-4 py-2 rounded bg-slate-200 text-slate-700 disabled:opacity-50"
      >
        Previous
      </button>
      <button
        type="button"
        onClick={onNext}
        disabled={!canNext || step === totalSteps}
        className="px-4 py-2 rounded bg-blue-500 text-white disabled:opacity-50"
      >
        Next
      </button>
    </div>
  );
}
```

- [ ] **Step 5: Verify typecheck**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
```

Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/_components/StepIndicator.tsx src/app/admin/exams/auto-gen/_components/SkillPicker.tsx src/app/admin/exams/auto-gen/_components/TopicForm.tsx src/app/admin/exams/auto-gen/_components/NavButtons.tsx
git commit -m "feat(fe-admin): add wizard step components (indicator/picker/form/nav)"
```

---

## Task 7.2: Add ReadingSubTab

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ReadingSubTab.tsx`

- [ ] **Step 1: Write `ReadingSubTab.tsx`**

```tsx
"use client";

import { useState } from "react";
import { QuestionType } from "@/app/admin/_lib/types";

interface ReadingSubTabProps {
  topic: string;
  level: number;
  sectionId: string;
}

export function ReadingSubTab({ topic, level, sectionId }: ReadingSubTabProps) {
  const [type, setType] = useState<string>(QuestionType.MultipleChoiceSingle);
  const [count, setCount] = useState<number>(5);
  const [questions, setQuestions] = useState<Record<string, unknown>[]>([]);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const allTypes = Object.values(QuestionType);

  const handleGenerate = async () => {
    setError(null);
    setGenerating(true);
    try {
      const { autogenQuestions } = await import("../_lib/autogenClient");
      const result = await autogenQuestions({
        type,
        skill: "READING",
        passage: topic,
        count,
        difficulty: level,
      });
      setQuestions(result.questions);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Generation failed");
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div className="space-y-4" data-testid="reading-subtab">
      <div className="flex gap-2">
        <select
          value={type}
          onChange={(e) => setType(e.target.value)}
          className="px-3 py-2 border rounded"
        >
          {allTypes.map((t) => (
            <option key={t} value={t}>
              {t}
            </option>
          ))}
        </select>
        <input
          type="number"
          min={1}
          max={10}
          value={count}
          onChange={(e) => setCount(Number(e.target.value))}
          className="w-20 px-3 py-2 border rounded"
        />
        <button
          type="button"
          onClick={handleGenerate}
          disabled={generating}
          className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
        >
          {generating ? "Generating..." : "Generate"}
        </button>
      </div>
      {error && <div className="text-red-600">{error}</div>}
      {questions.length > 0 && (
        <pre className="bg-slate-50 p-4 rounded text-xs overflow-auto">
          {JSON.stringify(questions, null, 2)}
        </pre>
      )}
    </div>
  );
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
git add src/app/admin/exams/auto-gen/_components/ReadingSubTab.tsx
git commit -m "feat(fe-admin): add ReadingSubTab (autogen for 19 reading types)"
```

---

## Task 7.3: Add wizard page

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/page.tsx`

- [ ] **Step 1: Write `page.tsx`**

```tsx
"use client";

import { useState } from "react";
import { StepIndicator } from "./_components/StepIndicator";
import { SkillPicker } from "./_components/SkillPicker";
import { TopicForm } from "./_components/TopicForm";
import { NavButtons } from "./_components/NavButtons";
import { ReadingSubTab } from "./_components/ReadingSubTab";

type Skill = "reading" | "listening" | "writing" | "speaking";

export default function AutoGenWizardPage() {
  const [step, setStep] = useState(1);
  const [skill, setSkill] = useState<Skill>("reading");
  const [topic, setTopic] = useState("");
  const [level, setLevel] = useState(6);

  const canNext =
    (step === 1 && skill !== undefined) ||
    (step === 2 && topic.trim().length > 0 && level >= 1 && level <= 9);

  return (
    <div className="container mx-auto p-6 max-w-3xl" data-testid="auto-gen-wizard">
      <h1 className="text-2xl font-bold mb-4">Auto-Generate Exam</h1>
      <StepIndicator step={step} totalSteps={4} />
      {step === 1 && <SkillPicker skill={skill} onChange={setSkill} />}
      {step === 2 && (
        <TopicForm topic={topic} level={level} onTopic={setTopic} onLevel={setLevel} />
      )}
      {step === 3 && skill === "reading" && (
        <ReadingSubTab topic={topic} level={level} sectionId="placeholder" />
      )}
      {step === 4 && (
        <div className="text-slate-600">Step 4 (Save): handled by sub-tabs. Navigate back and edit preview.</div>
      )}
      <NavButtons
        step={step}
        totalSteps={4}
        canNext={canNext}
        onPrev={() => setStep((s) => Math.max(1, s - 1))}
        onNext={() => setStep((s) => Math.min(4, s + 1))}
      />
    </div>
  );
}
```

- [ ] **Step 2: Verify typecheck + build**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npx tsc --noEmit
npm run build
```

Expected: tsc exit 0. Build succeeds.

- [ ] **Step 3: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/page.tsx
git commit -m "feat(fe-admin): add /admin/exams/auto-gen 4-step wizard with Reading sub-tab"
```

---
