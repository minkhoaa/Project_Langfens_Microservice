# Phase 8 — Listening/Writing/Speaking sub-tabs

> **Plan file:** This is Phase 8 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 8.1: Add reusable QuestionListEditor

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/QuestionListEditor.tsx`

- [ ] **Step 1: Write `QuestionListEditor.tsx`**

```tsx
"use client";

interface QuestionListEditorProps {
  questions: Record<string, unknown>[];
  onChange: (questions: Record<string, unknown>[]) => void;
}

export function QuestionListEditor({ questions, onChange }: QuestionListEditorProps) {
  return (
    <div className="space-y-2" data-testid="question-list-editor">
      <div className="text-sm text-slate-600">{questions.length} question(s) generated</div>
      <pre className="bg-slate-50 p-4 rounded text-xs overflow-auto max-h-96">
        {JSON.stringify(questions, null, 2)}
      </pre>
      <div className="text-xs text-slate-500">
        Edit JSON above to customize questions before save.
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/_components/QuestionListEditor.tsx
git commit -m "feat(fe-admin): add QuestionListEditor reusable component"
```

---

## Task 8.2: Add ListeningSubTab

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ListeningSubTab.tsx`

- [ ] **Step 1: Write `ListeningSubTab.tsx`**

```tsx
"use client";

import { useState } from "react";

interface Section {
  idx: number;
  title: string;
  audio_script: string;
  questions: Record<string, unknown>[];
}

interface ListeningSubTabProps {
  topic: string;
  level: number;
}

export function ListeningSubTab({ topic, level }: ListeningSubTabProps) {
  const [sections, setSections] = useState<Section[]>([]);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleGenerate = async () => {
    setError(null);
    setGenerating(true);
    try {
      const { autogenListeningExam } = await import("../_lib/autogenClient");
      const result = await autogenListeningExam({ topic, level, question_count: 30 });
      setSections(result.sections);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Generation failed");
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div className="space-y-4" data-testid="listening-subtab">
      <button
        type="button"
        onClick={handleGenerate}
        disabled={generating || !topic.trim()}
        className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
      >
        {generating ? "Generating 4 sections..." : "Generate Listening Exam"}
      </button>
      {error && <div className="text-red-600">{error}</div>}
      {sections.length > 0 && (
        <div className="space-y-4">
          {sections.map((section) => (
            <details key={section.idx} className="border rounded p-4">
              <summary className="font-semibold cursor-pointer">
                Section {section.idx}: {section.title}
              </summary>
              <div className="mt-2 space-y-2">
                <div className="text-sm">
                  <strong>Audio script:</strong>{" "}
                  <span className="text-slate-600">{section.audio_script.length} chars (placeholder, upload MP3 later)</span>
                </div>
                <pre className="bg-slate-50 p-2 rounded text-xs overflow-auto max-h-48">
                  {JSON.stringify(section.questions, null, 2)}
                </pre>
              </div>
            </details>
          ))}
        </div>
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
git add src/app/admin/exams/auto-gen/_components/ListeningSubTab.tsx
git commit -m "feat(fe-admin): add ListeningSubTab (4-section preview + audio script placeholder)"
```

---

## Task 8.3: Add ChartPreview component

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ChartPreview.tsx`

- [ ] **Step 1: Write `ChartPreview.tsx`**

```tsx
"use client";

interface ChartPreviewProps {
  chartUrl: string | null;
  chartDescription: string | null;
}

export function ChartPreview({ chartUrl, chartDescription }: ChartPreviewProps) {
  if (!chartUrl) {
    return <div className="text-sm text-slate-500">No chart for this task.</div>;
  }
  return (
    <div className="space-y-2" data-testid="chart-preview">
      <img src={chartUrl} alt="Task 1 chart" className="max-w-full rounded border" />
      {chartDescription && (
        <details>
          <summary className="text-sm text-slate-600 cursor-pointer">
            Chart description (JSON)
          </summary>
          <pre className="bg-slate-50 p-2 rounded text-xs overflow-auto">
            {chartDescription}
          </pre>
        </details>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/_components/ChartPreview.tsx
git commit -m "feat(fe-admin): add ChartPreview component for writing Task 1"
```

---

## Task 8.4: Add WritingSubTab

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/WritingSubTab.tsx`

- [ ] **Step 1: Write `WritingSubTab.tsx`**

```tsx
"use client";

import { useState } from "react";
import { ChartPreview } from "./ChartPreview";

interface WritingTask {
  prompt: string;
  chart_description: string | null;
  chart_url: string | null;
  model_answers: string[];
  suggested_vocabulary: string[];
}

interface WritingSubTabProps {
  topic: string;
  level: number;
}

export function WritingSubTab({ topic, level }: WritingSubTabProps) {
  const [taskType, setTaskType] = useState<"TASK_1" | "TASK_2">("TASK_2");
  const [result, setResult] = useState<WritingTask | null>(null);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleGenerate = async () => {
    setError(null);
    setGenerating(true);
    try {
      const { autogenWritingTask } = await import("../_lib/autogenClient");
      const r = await autogenWritingTask({ task_type: taskType, topic, level });
      setResult(r);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Generation failed");
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div className="space-y-4" data-testid="writing-subtab">
      <div className="flex gap-2">
        <select
          value={taskType}
          onChange={(e) => setTaskType(e.target.value as "TASK_1" | "TASK_2")}
          className="px-3 py-2 border rounded"
        >
          <option value="TASK_1">Task 1 (chart)</option>
          <option value="TASK_2">Task 2 (opinion)</option>
        </select>
        <button
          type="button"
          onClick={handleGenerate}
          disabled={generating || !topic.trim()}
          className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
        >
          {generating ? "Generating..." : "Generate"}
        </button>
      </div>
      {error && <div className="text-red-600">{error}</div>}
      {result && (
        <div className="space-y-3">
          <ChartPreview chartUrl={result.chart_url} chartDescription={result.chart_description} />
          <div>
            <strong>Prompt:</strong>
            <p className="text-sm mt-1 p-2 bg-slate-50 rounded">{result.prompt}</p>
          </div>
          <div>
            <strong>Model answers:</strong>
            <ul className="list-disc pl-6 text-sm mt-1">
              {result.model_answers.map((a, i) => (
                <li key={i}>{a}</li>
              ))}
            </ul>
          </div>
          <div>
            <strong>Vocabulary:</strong>{" "}
            <span className="text-sm">{result.suggested_vocabulary.join(", ")}</span>
          </div>
        </div>
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
git add src/app/admin/exams/auto-gen/_components/WritingSubTab.tsx
git commit -m "feat(fe-admin): add WritingSubTab with TASK_1/TASK_2 + ChartPreview"
```

---

## Task 8.5: Add ScenarioJsonEditor

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ScenarioJsonEditor.tsx`

- [ ] **Step 1: Write `ScenarioJsonEditor.tsx`**

```tsx
"use client";

interface ScenarioJsonEditorProps {
  scenario: Record<string, unknown> | null;
}

export function ScenarioJsonEditor({ scenario }: ScenarioJsonEditorProps) {
  if (!scenario) return null;
  return (
    <details className="border rounded p-4" data-testid="scenario-json-editor">
      <summary className="font-semibold cursor-pointer">Scenario JSON</summary>
      <pre className="mt-2 bg-slate-50 p-2 rounded text-xs overflow-auto max-h-96">
        {JSON.stringify(scenario, null, 2)}
      </pre>
    </details>
  );
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/_components/ScenarioJsonEditor.tsx
git commit -m "feat(fe-admin): add ScenarioJsonEditor for speaking scenarios"
```

---

## Task 8.6: Add SpeakingSubTab

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SpeakingSubTab.tsx`

- [ ] **Step 1: Write `SpeakingSubTab.tsx`**

```tsx
"use client";

import { useState } from "react";
import { ScenarioJsonEditor } from "./ScenarioJsonEditor";

type ScenarioType = "PART_1" | "PART_2" | "PART_3" | "ROLEPLAY";

interface SpeakingScenario {
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
}

interface SpeakingSubTabProps {
  topic: string;
  level: number;
}

export function SpeakingSubTab({ topic, level }: SpeakingSubTabProps) {
  const [scenarioType, setScenarioType] = useState<ScenarioType>("PART_1");
  const [result, setResult] = useState<SpeakingScenario | null>(null);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleGenerate = async () => {
    setError(null);
    setGenerating(true);
    try {
      const { autogenSpeakingScenario } = await import("../_lib/autogenClient");
      const r = await autogenSpeakingScenario({ scenario_type: scenarioType, topic, level });
      setResult(r);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Generation failed");
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div className="space-y-4" data-testid="speaking-subtab">
      <div className="flex gap-2">
        <select
          value={scenarioType}
          onChange={(e) => setScenarioType(e.target.value as ScenarioType)}
          className="px-3 py-2 border rounded"
        >
          <option value="PART_1">Part 1 (interview)</option>
          <option value="PART_2">Part 2 (cue card)</option>
          <option value="PART_3">Part 3 (discussion)</option>
          <option value="ROLEPLAY">Roleplay</option>
        </select>
        <button
          type="button"
          onClick={handleGenerate}
          disabled={generating || !topic.trim()}
          className="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
        >
          {generating ? "Generating..." : "Generate"}
        </button>
      </div>
      {error && <div className="text-red-600">{error}</div>}
      {result && (
        <div className="space-y-3">
          <div>
            <h3 className="font-semibold">{result.title}</h3>
            <div className="text-sm text-slate-600">
              {result.difficulty} · {result.ielts_part} · {result.duration_min} min · {result.turn_count_target} turns
            </div>
          </div>
          <div>
            <strong>Context:</strong>
            <p className="text-sm mt-1 p-2 bg-slate-50 rounded">{result.context}</p>
          </div>
          <div>
            <strong>Opening:</strong>
            <p className="text-sm mt-1 p-2 bg-slate-50 rounded">{result.opening_prompt}</p>
          </div>
          <ScenarioJsonEditor scenario={result} />
        </div>
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
git add src/app/admin/exams/auto-gen/_components/SpeakingSubTab.tsx
git commit -m "feat(fe-admin): add SpeakingSubTab with 4 scenario types"
```

---

## Task 8.7: Wire all 4 sub-tabs into wizard page

**Files:**
- Modify: `langfens-fe-app/src/app/admin/exams/auto-gen/page.tsx`

- [ ] **Step 1: Add imports + conditional rendering**

Edit `page.tsx` to add 3 new sub-tab imports and 3 conditional renders:

```tsx
"use client";

import { useState } from "react";
import { StepIndicator } from "./_components/StepIndicator";
import { SkillPicker } from "./_components/SkillPicker";
import { TopicForm } from "./_components/TopicForm";
import { NavButtons } from "./_components/NavButtons";
import { ReadingSubTab } from "./_components/ReadingSubTab";
import { ListeningSubTab } from "./_components/ListeningSubTab";
import { WritingSubTab } from "./_components/WritingSubTab";
import { SpeakingSubTab } from "./_components/SpeakingSubTab";

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
      {step === 3 && skill === "reading" && <ReadingSubTab topic={topic} level={level} sectionId="placeholder" />}
      {step === 3 && skill === "listening" && <ListeningSubTab topic={topic} level={level} />}
      {step === 3 && skill === "writing" && <WritingSubTab topic={topic} level={level} />}
      {step === 3 && skill === "speaking" && <SpeakingSubTab topic={topic} level={level} />}
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
git commit -m "feat(fe-admin): wire Listening/Writing/Speaking sub-tabs into wizard"
```

---
