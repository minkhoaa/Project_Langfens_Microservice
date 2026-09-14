# Sprint 8 — Auto-Gen Exam for 4 Skills (Reading / Listening / Writing / Speaking)

> **Status**: PROPOSED — awaiting user approval  
> **Author**: brainstorming session, 2026-09-14  
> **Branch target**: `refactor/sync-dotest-admin-renderer`  
> **Depends on**: Sprint 7 (server-proxy + jsonShape helper available)  
> **Effort estimate**: 25-33 hours (~4-5 working days, 1 dev)

---

## 1. Context

After Sprint 7 lands, the `AiAuthorModal` can auto-generate Reading questions for all 19 types via the new `ai-service` server-proxy. But IELTS has 4 skills. The user wants auto-gen for **all 4 skills**:

- **Reading** ✅ (covered by Sprint 7 + existing AiAuthorModal)
- **Listening** ❌ (no auto-gen; only text admin authoring)
- **Writing** ❌ (manual authoring only; `WritingExam.TaskText` typed by hand)
- **Speaking** ❌ (10 hand-curated JSON scenarios in `ai-service/app/data/scenarios/`, no auto-gen)

This sprint extends auto-gen to the remaining 3 skills + provides a unified admin wizard surface.

**Verified prewalk findings (2026-09-14):**

- `services/ai-service/app/routers/listening.py:1-11` already has `/v1/listening/explain-item` — pattern to mirror for `/v1/autogen/listening-exam`.
- `services/ai-service/app/data/scenarios/` contains 10 hand-curated JSON scenarios (e.g., `airport-help-desk.json` with `slug`, `title`, `difficulty`, `ielts_part`, `context`, `user_role`, `agent_role`, `opening_prompt`, `target_vocabulary`, etc.) — schema template for Sprint 8 output.
- `services/speaking-service/Domains/Entities/SpeakingExam.cs:9-55` defines `SpeakingExam` with only `TaskText` (no `CueCard`/`FollowUps` fields). Auto-gen output for Speaking goes to JSON file first → parsed into SpeakingExam fields.
- `services/writing-service/Domains/Entities/WritingExam.cs:9-55` defines `WritingExam` with `TaskText`, `ChartDescription` (Task 1 only), `ModelAnswers`, `ImageUrl`. Auto-gen output maps cleanly.
- `services/writing-service/Contracts/WritingDto.cs:14-19` defines `UpdateExamRequest` with `ChartDescription` — already supports the field we need.
- `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs:117-174` (`AddAsync`) shows the per-question insert path. Bulk insert reuses `ValidatePayload` per dto + adds single transaction.
- `gateway/api-gateway/appsettings.json:316-318` already routes `/api/admin/question/{**catch-all}` to `exam-cluster`. No new YARP work needed.
- `AppHost/Program.cs:48-50` already wires `aiService` + injects `AI_SERVICE_URL` into `writing.WithEnvironment(...)` and `speaking.WithEnvironment(...)`. New ai-service routers accessible via gateway.

---

## 2. Goals

1. **G1 — Listening auto-gen**: New `POST /api/v1/autogen/listening-exam` returns 4 sections (form/matching/MCQ/note completion) with audio script + question JSON. Admin uploads MP3 separately.
2. **G2 — Writing auto-gen**: New `POST /api/v1/autogen/writing-task` returns Task 1 (with matplotlib PNG chart) or Task 2 prompt + model answers.
3. **G3 — Speaking auto-gen**: New `POST /api/v1/autogen/speaking-scenario` returns Part 1/2/3 or Roleplay scenario JSON.
4. **G4 — Unified admin wizard**: New `/admin/exams/auto-gen` 4-step wizard covers all 4 skills.
5. **G5 — Bulk insert endpoint**: `POST /api/admin/question/bulk` for atomic multi-question insert with partial-success errors[] semantics.

## 3. Non-Goals

- Real TTS for Listening (placeholder `audioUrl` only; admin uploads MP3).
- DALL-E / image generation models for Writing (matplotlib is sufficient; admin can also re-upload).
- Real audio recording for Speaking roleplay scenarios (already in `speaking-service` runtime).
- Listening admin UI playback (already exists in `services/do-test`).
- Vocabulary service integration (could enrich prompts later; Sprint 9+).
- SSE streaming preview (optional; deferred if Sprint 8 over-runs).
- New question types or grader changes.
- Auth/role changes.

---

## 4. Architecture

### 4.1 ai-service routers (3 new + 1 shared)

```
services/ai-service/app/routers/
├── autogen.py              (already created in Sprint 7)
├── autogen_listening.py    NEW — listening-exam
├── autogen_writing.py      NEW — writing-task
└── autogen_speaking.py     NEW — speaking-scenario

services/ai-service/app/prompts/
├── autogen.py              (shared — already created in Sprint 7)
├── autogen_listening.py    NEW
├── autogen_writing.py      NEW
└── autogen_speaking.py     NEW
```

Each router follows the same pattern (mirror `autogen.py` from Sprint 7):
1. Pydantic request schema validates inputs.
2. Resolve system prompt + user prompt from `prompts/autogen_<skill>.py`.
3. Call `groq_service.groq_generate(...)` with `expect_json=True`.
4. Return typed response.

### 4.2 Component map

```
┌────────────────────────────────────────────────────────────────────┐
│  FE (langfens-fe-app)                                              │
│                                                                    │
│  /admin/exams/auto-gen/page.tsx (NEW)                              │
│    Step 1: Skill picker (Reading/Listening/Writing/Speaking)       │
│    Step 2: Topic + level form                                      │
│    Step 3: Preview area                                            │
│    Step 4: Save action                                             │
│        ├─ Reading sub-tab → AiAuthorModal (existing)               │
│        ├─ Listening sub-tab → new ListeningSubTab                  │
│        ├─ Writing sub-tab → new WritingSubTab                      │
│        └─ Speaking sub-tab → new SpeakingSubTab                    │
│                                                                    │
│  autogenClient.ts (NEW)                                            │
│    autogenQuestions(type, ...) → POST /api/v1/autogen/questions    │
│    autogenListeningExam(topic, ...) → POST /api/v1/autogen/...     │
│    autogenWritingTask(taskType, ...) → POST /api/v1/autogen/...    │
│    autogenSpeakingScenario(scenarioType, ...) → POST /api/v1/...   │
│                                                                    │
│  adminApi.ts (EDIT)                                                │
│    createQuestionBulk(sectionId, dtos[]) → POST /api/admin/.../bulk│
└────────────────────────────────────────────────────────────────────┘
              │
              │ Gateway YARP
              ▼
┌────────────────────────────────────────────────────────────────────┐
│  ai-service                                                        │
│                                                                    │
│  /api/v1/autogen/listening-exam  → 4 sections + audio scripts      │
│  /api/v1/autogen/writing-task    → Task1+chart.png OR Task2 prompt │
│  /api/v1/autogen/speaking-scenario → roleplay JSON                 │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│  exam-service                                                      │
│                                                                    │
│  POST /api/admin/question/bulk (NEW)                               │
│    Body: { sectionId, questions: AdminQuestionUpsert[] }           │
│    Response: { created: Guid[], errors: [{ idx, message }] }       │
└────────────────────────────────────────────────────────────────────┘
```

### 4.3 Data flow — Listening auto-gen

1. Admin opens wizard → picks "Listening" → fills `topic="university enrollment"`, `level=6`, `count=30`.
2. Wizard calls `autogenClient.autogenListeningExam(topic, level, count)` → `POST /api/v1/autogen/listening-exam`.
3. ai-service router:
   - Iterates 4 sections (Section 1 form completion, Section 2 matching, Section 3 MCQ, Section 4 note completion).
   - For each section, calls `groq_service.groq_generate(SECTION_PROMPT, variables, expect_json=True)` with section-specific prompt.
   - Combines into one response: `{ sections: [{ idx, title, audio_script, questions: [...] }] }`.
4. Wizard renders preview: 4 collapsible sections, each with `<QuestionListEditor>`.
5. Admin edits fields inline (e.g. adjusts `audio_script`, fixes question stems).
6. Admin clicks Save → wizard:
   - Creates 1 `Exam` record via `adminApi.createExam({ title: "Auto-gen listening", skill: "LISTENING", ... })`.
   - Creates 4 `ExamSection` records via `adminApi.createSection(...)` (one per section).
   - For each section, calls `adminApi.createQuestionBulk(sectionId, questions[])`.
   - Sets `audioUrl` placeholder on each section (admin uploads MP3 later via existing `/api/upload` endpoint).

### 4.4 Data flow — Writing auto-gen

1. Admin picks "Writing" → picks Task 1 or Task 2 → fills `topic`, `level`.
2. Wizard calls `autogenClient.autogenWritingTask(taskType, topic, level)`.
3. ai-service:
   - For Task 1: LLM generates `chart_description` (text). Server runs `matplotlib` to render PNG into `static/charts/<uuid>.png`. Response: `{ prompt, chart_description, chart_url: "/static/charts/<uuid>.png", model_answers, suggested_vocabulary }`.
   - For Task 2: LLM generates opinion prompt + model essay. Response: `{ prompt, chart_description: null, chart_url: null, model_answers, suggested_vocabulary }`.
4. Wizard renders preview with editable fields + chart image preview.
5. Save → `writing-service` admin endpoint: `POST /api/admin/writing/create` with the generated fields.

### 4.5 Data flow — Speaking auto-gen

1. Admin picks "Speaking" → picks Part 1/2/3 or Roleplay → fills `topic`, `level`.
2. Wizard calls `autogenClient.autogenSpeakingScenario(scenarioType, topic, level)`.
3. ai-service returns scenario JSON matching `data/scenarios/*.json` schema: `{ slug, title, difficulty, ielts_part, context, user_role, agent_role, opening_prompt, target_vocabulary, target_grammar, suggested_topics, duration_min, turn_count_target }`.
4. Wizard renders preview.
5. Save → 2 paths:
   - **JSON-first path**: write to `services/ai-service/app/data/scenarios/<slug>.json`. speaking-service loads via existing file-based mechanism (or new endpoint).
   - **DB path (preferred)**: parser converts JSON into `SpeakingExam` entity with `Title`, `TaskText` (concatenated opening+context), `ImageUrl` (placeholder). User chose "JSON first → validate → DB".

### 4.6 Wire contracts

**POST /api/v1/autogen/listening-exam**

```ts
// Request
{
  topic: string;        // e.g. "university enrollment"
  level: 1|2|3|4|5|6|7|8|9;
  question_count: 5..40;
}
// Response 200
{
  sections: [
    {
      idx: 1 | 2 | 3 | 4;
      title: string;
      audio_script: string;     // text only, ~1500 tokens
      questions: Record<string, unknown>[];   // 19-type-shaped
    }
  ]
}
```

**POST /api/v1/autogen/writing-task**

```ts
// Request
{
  task_type: "TASK_1" | "TASK_2";
  topic: string;
  level: 1..9;
}
// Response 200
{
  prompt: string;
  chart_description: string | null;     // TASK_1 only
  chart_url: string | null;             // TASK_1 only — served from ai-service static dir
  model_answers: string[];
  suggested_vocabulary: string[];
}
```

**POST /api/v1/autogen/speaking-scenario**

```ts
// Request
{
  scenario_type: "PART_1" | "PART_2" | "PART_3" | "ROLEPLAY";
  topic: string;
  level: 1..9;
}
// Response 200 — matches scenarios/*.json schema
{
  slug: string;
  title: string;
  difficulty: "BEGINNER" | "INTERMEDIATE" | "ADVANCED";
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
```

**POST /api/admin/question/bulk** (exam-service)

```ts
// Request
{
  sectionId: string;        // UUID
  questions: AdminQuestionUpsert[];
}
// Response 200 — partial success
{
  created: { idx: number; id: string }[];
  errors: { idx: number; message: string }[];
}
// Response 4xx — bad sectionId
{ detail: "Section not found" }
```

---

## 5. Component Design

### 5.1 ai-service shared module

Reuse Sprint 7's `app/prompts/autogen.py` for shared prompt-building infrastructure. Add per-skill prompt builders in `autogen_listening.py`, `autogen_writing.py`, `autogen_speaking.py`.

Each per-skill prompt module exports:

```python
def build_system_prompt(scenario_or_task: str, json_shape: str, constraints: list[str]) -> str: ...
def build_user_prompt(topic: str, level: int, count: int, extra: str = "") -> str: ...
```

### 5.2 ai-service listening router

`app/routers/autogen_listening.py`:

```python
from app.prompts.autogen_listening import SECTION_PROMPTS, build_user_prompt
from app.services.groq_service import groq_generate
from app.schemas.autogen_listening import ListeningExamRequest, ListeningExamResponse, Section

@router.post("/listening-exam", response_model=ListeningExamResponse)
async def autogen_listening_exam(req: ListeningExamRequest):
    sections = []
    for idx, section_def in enumerate(SECTION_PROMPTS, start=1):
        # Section 1: form completion; Section 2: matching; Section 3: MCQ; Section 4: note completion
        system_prompt = section_def["system_template"]
        user_prompt = build_user_prompt(req.topic, req.level, req.question_count // 4, idx)
        result = await groq_generate(
            prompt_template=user_prompt,
            variables={"system": system_prompt, "user": user_prompt},
            expect_json=True,
        )
        sections.append(Section(
            idx=idx,
            title=section_def["title"],
            audio_script=result.get("audio_script", ""),
            questions=result.get("questions", []),
        ))
    return ListeningExamResponse(sections=sections)
```

### 5.3 ai-service writing router + matplotlib

`app/routers/autogen_writing.py`:

```python
import uuid
import os
from app.services.matplotlib_chart import render_chart_png

@router.post("/writing-task", response_model=WritingTaskResponse)
async def autogen_writing_task(req: WritingTaskRequest):
    if req.task_type == "TASK_1":
        system_prompt = build_task1_system_prompt()
        user_prompt = build_task1_user_prompt(req.topic, req.level)
        result = await groq_generate(... expect_json=True ...)
        chart_desc = result.get("chart_description", "")
        # Render PNG
        chart_filename = f"{uuid.uuid4()}.png"
        chart_path = f"/app/static/charts/{chart_filename}"
        render_chart_png(chart_desc, chart_path)
        chart_url = f"/static/charts/{chart_filename}"
        return WritingTaskResponse(
            prompt=result.get("prompt", ""),
            chart_description=chart_desc,
            chart_url=chart_url,
            model_answers=result.get("model_answers", []),
            suggested_vocabulary=result.get("suggested_vocabulary", []),
        )
    # TASK_2 — no chart
    ...
```

`app/services/matplotlib_chart.py` (new):

```python
def render_chart_png(description: str, output_path: str) -> None:
    """Parse a chart description and render a matplotlib PNG.

    Supports: bar, line, pie, table, process. Description must include
    chart_type field. Falls back to table if parsing fails.
    """
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    # ... parse description, plt.bar/line/pie/etc, savefig ...
```

### 5.4 ai-service speaking router

`app/routers/autogen_speaking.py`:

```python
SCENARIO_TYPES = {
    "PART_1": (build_part1_prompt, "BEGINNER"),
    "PART_2": (build_part2_prompt, "INTERMEDIATE"),
    "PART_3": (build_part3_prompt, "ADVANCED"),
    "ROLEPLAY": (build_roleplay_prompt, "INTERMEDIATE"),
}

@router.post("/speaking-scenario", response_model=SpeakingScenarioResponse)
async def autogen_speaking_scenario(req: SpeakingScenarioRequest):
    prompt_builder, default_difficulty = SCENARIO_TYPES[req.scenario_type]
    system_prompt = prompt_builder(req.topic, req.level)
    user_prompt = build_user_prompt(req.topic, req.level)
    result = await groq_generate(..., expect_json=True)
    return SpeakingScenarioResponse(
        slug=slugify(result.get("title", req.topic)),
        title=result.get("title", req.topic),
        difficulty=result.get("difficulty", default_difficulty),
        ...
    )
```

### 5.5 exam-service bulk endpoint

`Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs` (EDIT — add new method):

```csharp
public async Task<IResult> BulkInsertAsync(
    CancellationToken token,
    [FromBody] BulkInsertRequest req)
{
    var section = await _context.ExamSections.AsNoTracking()
        .FirstOrDefaultAsync(s => s.Id == req.SectionId, token);
    if (section == null)
        return Results.BadRequest(new ApiResultDto(false, "Section not found", null!));

    var created = new List<object>();
    var errors = new List<object>();
    var maxIdx = await _context.ExamQuestions.AsNoTracking()
        .Where(q => q.SectionId == req.SectionId)
        .Select(q => (int?)q.Idx).MaxAsync(token) ?? 0;

    await using var tx = await _context.Database.BeginTransactionAsync(token);
    try
    {
        for (int i = 0; i < req.Questions.Count; i++)
        {
            var dto = req.Questions[i];
            var validationError = ValidatePayload(dto.Type, dto.BlankAcceptTexts,
                dto.MatchPairs, dto.OrderCorrects, dto.ShortAnswerAcceptTexts);
            if (validationError != null)
            {
                errors.Add(new { idx = i, message = validationError });
                continue;
            }
            var question = new ExamQuestion
            {
                SectionId = req.SectionId,
                Idx = maxIdx + i + 1,
                Type = dto.Type,
                Skill = dto.Skill,
                Difficulty = dto.Difficulty,
                PromptMd = dto.PromptMd,
                ExplanationMd = dto.ExplanationMd,
                ImageUrl = dto.ImageUrl,
                BlankAcceptTexts = dto.BlankAcceptTexts,
                BlankAcceptRegex = dto.BlankAcceptRegex,
                MatchPairs = dto.MatchPairs,
                OrderCorrects = dto.OrderCorrects?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList(),
                ShortAnswerAcceptTexts = dto.ShortAnswerAcceptTexts?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList(),
                ShortAnswerAcceptRegex = dto.ShortAnswerAcceptRegex?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList(),
            };
            _context.ExamQuestions.Add(question);
            created.Add(new { idx = i, id = question.Id });
        }
        await _context.SaveChangesAsync(token);
        await tx.CommitAsync(token);
        return Results.Ok(new ApiResultDto(true, "Bulk insert complete",
            new { created, errors }));
    }
    catch (Exception e)
    {
        await tx.RollbackAsync(token);
        return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
    }
}
```

Note: `Idx` is auto-derived from `maxIdx + i + 1` — no `Idx` collisions within the section.

`AdminQuestion_Handler.cs` (EDIT — add new handler):

```csharp
public static Task<IResult> BulkInsertHandler(
    [FromServices] IAdminQuestionService service,
    CancellationToken token,
    [FromBody] BulkInsertRequest req
) => service.BulkInsertAsync(token, req);
```

`AdminQuestionEndpoint.cs` (EDIT — add route):

```csharp
adminQuestion.MapPost("/bulk", AdminQuestionHandler.BulkInsertHandler)
    .RequireAuthorization(Roles.Admin);
```

### 5.6 FE wizard

`/admin/exams/auto-gen/page.tsx`:

```tsx
"use client";
import { useState } from "react";
import { ReadingSubTab } from "./_components/ReadingSubTab";
import { ListeningSubTab } from "./_components/ListeningSubTab";
import { WritingSubTab } from "./_components/WritingSubTab";
import { SpeakingSubTab } from "./_components/SpeakingSubTab";

export default function AutoGenWizardPage() {
  const [step, setStep] = useState(1);
  const [skill, setSkill] = useState<"reading"|"listening"|"writing"|"speaking">("reading");
  const [topic, setTopic] = useState("");
  const [level, setLevel] = useState(6);

  return (
    <div className="container">
      <StepIndicator step={step} totalSteps={4} />
      {step === 1 && <SkillPicker skill={skill} onChange={setSkill} />}
      {step === 2 && <TopicForm topic={topic} level={level} onTopic={setTopic} onLevel={setLevel} />}
      {step === 3 && (
        <>
          {skill === "reading" && <ReadingSubTab topic={topic} level={level} />}
          {skill === "listening" && <ListeningSubTab topic={topic} level={level} />}
          {skill === "writing" && <WritingSubTab topic={topic} level={level} />}
          {skill === "speaking" && <SpeakingSubTab topic={topic} level={level} />}
        </>
      )}
      {step === 4 && <SaveStep skill={skill} />}
      <NavButtons step={step} onPrev={() => setStep(s => s - 1)} onNext={() => setStep(s => s + 1)} />
    </div>
  );
}
```

Each sub-tab reuses existing admin APIs for save:
- **ReadingSubTab**: opens `AiAuthorModal` per question type, calls `createQuestionBulk` for save.
- **ListeningSubTab**: creates `Exam` + 4 `ExamSection` records, then `createQuestionBulk` per section.
- **WritingSubTab**: calls `writing-service` `POST /api/admin/writing/create`.
- **SpeakingSubTab**: writes JSON to `services/ai-service/app/data/scenarios/<slug>.json` via new `POST /api/v1/autogen/scenario/save` ai-service endpoint, OR calls `speaking-service` `POST /api/admin/speaking/create` with `TaskText` concatenation.

### 5.7 New FE file: `autogenClient.ts`

```ts
const AI_SERVICE = process.env.NEXT_PUBLIC_AI_SERVICE_URL || "http://localhost:8092";

export async function autogenQuestions(req: {
  type: string; skill: string; passage: string; count: number; difficulty: number;
  extra_context?: string;
}) {
  const res = await fetch(`${AI_SERVICE}/api/v1/autogen/questions`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify(req),
  });
  if (!res.ok) throw new Error(`autogen failed: ${res.status}`);
  return res.json() as Promise<{ questions: Record<string, unknown>[] }>;
}

export async function autogenListeningExam(req: {
  topic: string; level: number; question_count: number;
}) {
  // ...similar pattern...
}

export async function autogenWritingTask(req: {
  task_type: "TASK_1" | "TASK_2"; topic: string; level: number;
}) {
  // ...similar pattern...
}

export async function autogenSpeakingScenario(req: {
  scenario_type: "PART_1" | "PART_2" | "PART_3" | "ROLEPLAY"; topic: string; level: number;
}) {
  // ...similar pattern...
}
```

### 5.8 New FE function: `adminApi.createQuestionBulk`

```ts
export async function createQuestionBulk(
  sectionId: string,
  questions: AdminQuestionUpsert[]
): Promise<{ created: { idx: number; id: string }[]; errors: { idx: number; message: string }[] }> {
  const res = await apisExam.post("/admin/question/bulk", { sectionId, questions });
  return res.data?.data;
}
```

---

## 6. Phase Plan

Sprint 8 is decomposed into **10 small phases**. Phases 1-4 build the 3 ai-service routers (parallel-able). Phase 5 adds the BE bulk endpoint. Phases 6-9 build the FE wizard per skill. Phase 10 closes.

### Phase 1 — ai-service shared listening prompt module

**Files**:
- Create `services/ai-service/app/prompts/autogen_listening.py` — 4 section-specific prompt builders
- Create `services/ai-service/app/prompts/autogen_listening_templates.py` — system prefixes + section definitions

**Acceptance**:
- `pytest services/ai-service/tests/test_autogen_listening_prompts.py` passes (snapshot per section).
- 4 sections defined: Section 1 form completion, Section 2 matching, Section 3 MCQ, Section 4 note completion.

**Commit**: `feat(ai-autogen): add listening prompt module`

### Phase 2 — ai-service listening router

**Files**:
- Create `services/ai-service/app/routers/autogen_listening.py`
- Create `services/ai-service/app/schemas/autogen_listening.py` (Pydantic request/response)
- Create `services/ai-service/tests/test_autogen_listening_router.py` (mock groq_generate)
- Edit `services/ai-service/app/main.py:14,82` — add router
- Edit `services/ai-service/app/middleware/rate_limit.py:7-12` — add `/api/v1/autogen/listening-exam: 3` (3 rpm/IP — 4 sections = 4 LLM calls)

**Acceptance**:
- `pytest test_autogen_listening_router.py` passes.
- Manual: `curl -X POST http://localhost:8092/api/v1/autogen/listening-exam -H "Authorization: Bearer <jwt>"` returns 200 with 4 sections.
- 4th request within 60s from same IP → 429.

**Commit**: `feat(ai-autogen): add listening exam router`

### Phase 3 — ai-service writing prompt + matplotlib

**Files**:
- Create `services/ai-service/app/prompts/autogen_writing.py`
- Create `services/ai-service/app/services/matplotlib_chart.py` — chart rendering
- Edit `services/ai-service/Dockerfile` — add `matplotlib` to pip install
- Edit `services/ai-service/app/main.py` — mount static dir for `/static/charts/`
- Create `services/ai-service/tests/test_matplotlib_chart.py`

**Acceptance**:
- `pytest test_matplotlib_chart.py` passes (renders bar/line/pie/table/process charts).
- `curl http://localhost:8092/static/charts/test.png` returns 200 with image/png.

**Commit**: `feat(ai-autogen): add matplotlib chart rendering`

### Phase 4 — ai-service writing router

**Files**:
- Create `services/ai-service/app/routers/autogen_writing.py`
- Create `services/ai-service/app/schemas/autogen_writing.py`
- Create `services/ai-service/tests/test_autogen_writing_router.py`
- Edit `services/ai-service/app/main.py` — add router
- Edit `services/ai-service/app/middleware/rate_limit.py` — add `/api/v1/autogen/writing-task: 10`

**Acceptance**:
- `pytest test_autogen_writing_router.py` passes.
- TASK_1 returns `{ chart_url: "/static/charts/<uuid>.png" }` and the PNG is fetchable.
- TASK_2 returns `{ chart_url: null }`.

**Commit**: `feat(ai-autogen): add writing task router`

### Phase 5 — ai-service speaking router

**Files**:
- Create `services/ai-service/app/prompts/autogen_speaking.py` — 4 scenario-type prompt builders
- Create `services/ai-service/app/routers/autogen_speaking.py`
- Create `services/ai-service/app/schemas/autogen_speaking.py`
- Create `services/ai-service/tests/test_autogen_speaking_router.py`
- Edit `services/ai-service/app/main.py` — add router
- Edit `services/ai-service/app/middleware/rate_limit.py` — add `/api/v1/autogen/speaking-scenario: 10`

**Acceptance**:
- `pytest test_autogen_speaking_router.py` passes.
- 4 scenario types: PART_1, PART_2, PART_3, ROLEPLAY.
- Response matches `data/scenarios/*.json` schema.

**Commit**: `feat(ai-autogen): add speaking scenario router`

### Phase 6 — exam-service bulk insert endpoint

**Files**:
- Edit `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs` — add `BulkInsertAsync`
- Edit `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs` — add `BulkInsertHandler`
- Edit `services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs:48-56` — add `POST /api/admin/question/bulk`
- Create `services/exam-service/Contracts/Exams/BulkInsertRequest.cs`
- Add xUnit test in `services/attempt-service.Tests/ExamServiceBulkInsertTests.cs`

**Acceptance**:
- `dotnet test services/attempt-service.Tests` passes (existing 73 + new tests).
- Manual: `curl -X POST .../api/admin/question/bulk` with 5 valid dtos → 5 created; 1 invalid + 4 valid → 4 created + 1 error.
- `Idx` collision check: 2 dtos with same `Idx` → both succeed (Idxs auto-derived from position).

**Commit**: `feat(exam): bulk insert endpoint with partial-success semantics`

### Phase 7 — FE autogen client

**Files**:
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_lib/autogenClient.ts`
- Edit `langfens-fe-app/src/app/admin/_lib/adminApi.ts` — add `createQuestionBulk`

**Acceptance**:
- `npx tsc --noEmit` exits 0.
- All 4 client functions type-check.

**Commit**: `feat(fe-llm): add autogen client for 4 skills + bulk question API`

### Phase 8 — FE wizard scaffold + Reading sub-tab

**Files**:
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/page.tsx`
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ReadingSubTab.tsx`
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_components/{SkillPicker,TopicForm,NavButtons,StepIndicator}.tsx`

**Acceptance**:
- `npm run build` exits 0.
- Manual: navigate to `/admin/exams/auto-gen` → wizard renders 4 steps → Reading sub-tab reuses AiAuthorModal flow.

**Commit**: `feat(fe-admin): auto-gen wizard scaffold + Reading sub-tab`

### Phase 9 — FE wizard Listening + Writing + Speaking sub-tabs

**Files**:
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ListeningSubTab.tsx`
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_components/WritingSubTab.tsx`
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SpeakingSubTab.tsx`
- Create `langfens-fe-app/src/app/admin/exams/auto-gen/_components/{QuestionListEditor,ChartPreview,ScenarioJsonEditor}.tsx`

**Acceptance**:
- `npm run build` exits 0.
- Manual smoke: each of Listening/Writing/Speaking sub-tabs renders preview, allows editing, saves via correct admin endpoint.

**Commit**: `feat(fe-admin): auto-gen wizard Listening/Writing/Speaking sub-tabs`

### Phase 10 — Sprint 8 closure

**Files**:
- `docs/sprint8/PLAN.md` — mark all phases DONE
- `HANDOFF_SPRINT8.md` — record Sprint 9 input (TTS, chart image gen, more scenario templates)

**Acceptance**:
- All 10 phase commits landed.
- `dotnet test services/attempt-service.Tests` — 73+ tests pass.
- `npm run test` — 44+ tests pass.
- `npm run build` exits 0.
- `pytest services/ai-service/tests/test_autogen_*.py` all green.
- Manual: full wizard flow for all 4 skills.
- No untracked files.

**Commit**: `docs(sprint8): close Sprint 8 with full verification scoreboard`

---

## 7. Risks & Mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | Listening Section 4 LLM output exceeds Groq 8k context | Medium | Medium | Section 4 prompt says "academic monologue ~1500 tokens"; truncate `audio_script` server-side before returning |
| R2 | matplotlib chart rendering fails on edge-case descriptions | Medium | Medium | Fallback to simple table chart if parse fails; Phase 3 test covers 5 chart types |
| R3 | Bulk insert bypasses per-question `Idx` uniqueness | High | High | `Idx` auto-derived from position (`maxIdx + i + 1`); no caller-supplied `Idx` accepted |
| R4 | Wizard state lost on page reload | Medium | Low | `sessionStorage` draft; clear on save or cancel |
| R5 | Speaking scenario parser doesn't fit `SpeakingExam` schema | Medium | Medium | Phase 9 includes JSON→DB parser with snapshot tests; falls back to JSON-only storage if entity mapping fails |
| R6 | ai-service router auth not enforced (anonymous LLM calls) | Medium | High | Phase 5 of Sprint 7 already adds JWT auth; Sprint 8 routers inherit the same middleware |
| R7 | Listening 4 sections × LLM call = 4× latency | High | Low | Show section-by-section progress; allow section regeneration individually |
| R8 | matplotlib Docker image grows too large | Low | Low | matplotlib base is ~50MB; acceptable for ai-service image |
| R9 | Bulk insert fails halfway, leaves partial state | Medium | Medium | Single transaction wraps all inserts; rollback on exception. `created[]`/`errors[]` semantics only valid for per-row validation failures, not DB errors |
| R10 | Speaking admin create endpoint doesn't accept TaskText-only (no cue_card field) | High | Medium | Sprint 8 uses `SpeakingExam.Title` + `TaskText` (concatenated) + `ImageUrl` placeholder. CueCard-specific persistence deferred to Sprint 9 |

---

## 8. Acceptance Criteria

1. `pytest services/ai-service/tests/test_autogen_*.py` all green (3 routers × 4-5 tests each = ~15 tests).
2. Live: each of the 4 endpoints (`/api/v1/autogen/questions`, `/listening-exam`, `/writing-task`, `/speaking-scenario`) returns 200 with valid JSON for representative inputs.
3. `dotnet test services/attempt-service.Tests` — 73/73 + bulk insert tests pass.
4. `npm run test` — 44+ Vitest tests pass (Sprint 7 baseline + any new wizard tests).
5. `npm run build` exits 0.
6. `curl -X POST http://localhost:8092/api/v1/autogen/listening-exam` returns 4 sections × 5-10 questions each.
7. `curl -X POST http://localhost:8092/api/v1/autogen/writing-task` with `task_type=TASK_1` returns `chart_url` that fetches a valid PNG.
8. `curl -X POST http://localhost:8092/api/v1/autogen/speaking-scenario` returns JSON matching `data/scenarios/*.json` schema.
9. Manual: admin opens `/admin/exams/auto-gen`, picks each of 4 skills, fills topic="renewable energy" + level=6, clicks Generate → preview appears → edits → saves → result queryable via existing read endpoints.
10. `POST /api/admin/question/bulk` inserts 5 questions atomically; partial-failure (1 invalid + 4 valid) returns 200 with `errors[]` array of length 1.
11. No untracked files left in working tree.
12. Branch remains `refactor/sync-dotest-admin-renderer`.

---

## 9. Effort Estimate

| Phase | Effort | Notes |
|---|---|---|
| 1 — Listening prompts | 2 h | 4 section templates |
| 2 — Listening router | 2 h | Router + tests + rate-limit |
| 3 — Writing + matplotlib | 3 h | Docker + chart renderer + tests |
| 4 — Writing router | 2 h | Router + chart URL serving |
| 5 — Speaking router | 2 h | 4 scenario templates + router |
| 6 — Bulk insert | 3 h | Service + handler + tests |
| 7 — FE client | 1 h | 4 client functions + adminApi edit |
| 8 — Wizard scaffold | 3 h | Page + Reading sub-tab + components |
| 9 — 3 sub-tabs | 5 h | Listening (largest), Writing, Speaking |
| 10 — Closure | 2 h | Verification + docs |
| **Total** | **~25 h** | **~4-5 working days** |

---

## 10. Open Questions

1. **Speaking auto-gen storage**: User chose "JSON first → validate → DB". Which DB mapping? SpeakingExam has no `CueCard` field. **Default**: Concatenate cue_card + follow_ups into `TaskText`. Sprint 9 adds a `CueCard` field via DB migration.
2. **Bulk insert transaction scope**: Single tx wrapping all 5 inserts (per R9 above) OR per-row commit? **Default**: single transaction for atomicity; per-row validation errors don't abort tx.
3. **matplotlib chart types**: bar/line/pie/table/process — should we support all 5 or just 3? **Default**: 4 (bar/line/pie/table); process deferred.
4. **Listening audio script length**: 1500 tokens max per section, 4 sections = 6000 tokens output. Within Groq 8k limit? **Default**: yes, with truncation safety.

---

## 11. Out of Scope (deferred to Sprint 9+)

- Real TTS audio generation (ElevenLabs API, faster-whisper TTS mode).
- DALL-E / image generation models for Writing Task 1.
- Chart types beyond bar/line/pie/table.
- Speaking `CueCard` field on `SpeakingExam` entity (DB migration).
- SSE streaming preview.
- Bulk insert rollback UX (Phase 6 ships per-row errors[], not row-level rollback).

---

**Spec status**: ready for user review. Awaiting explicit approval before any implementation.
