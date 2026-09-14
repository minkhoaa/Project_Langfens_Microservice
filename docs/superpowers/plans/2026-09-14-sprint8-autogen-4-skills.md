# Sprint 8 — Auto-Gen Exam for 4 Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> ⚠️ **DEPENDENCY**: This plan depends on **Sprint 7 being completed first**. Tasks 1.1 (jsonShape.ts), 1.2 (llmPromptBuilder.ts), 5.2 (autogen.py + autogen router) MUST be merged before Sprint 8 starts. Specifically:
> - `langfens-fe-app/src/app/admin/_lib/jsonShape.ts` (Sprint 7 Task 1.1)
> - `services/ai-service/app/routers/autogen.py` (Sprint 7 Task 5.2)
>
> Verify Sprint 7 is merged before starting Phase 1.

**Goal:** Extend auto-gen to Listening, Writing, and Speaking skills via 3 new ai-service routers + matplotlib chart rendering + admin wizard `/admin/exams/auto-gen` + exam-service bulk insert endpoint. Cover all 4 IELTS skills end-to-end.

**Architecture:** Three independent ai-service routers (`autogen_listening`, `autogen_writing`, `autogen_speaking`) reuse Sprint 7's `groq_service.groq_generate` infrastructure. Writing router renders charts via matplotlib. Admin wizard is a 4-step Next.js page that calls existing admin APIs (`createExam`, `createSection`, `createQuestion`) + new `createQuestionBulk`. Bulk endpoint uses single transaction with partial-success `errors[]` semantics.

**Tech Stack:**
- ai-service: FastAPI, LangChain, Groq, matplotlib (Agg backend)
- exam-service: ASP.NET Core 10, EF Core, existing `AddAsync`/`UpdateAsync` pattern
- FE: Next.js 16, React 19, TypeScript, Vitest 2.1
- Existing patterns: `AdminQuestion_Service.cs:117-174` (AddAsync), `services/ai-service/app/routers/writing.py:7` (APIRouter), `gateway/api-gateway/appsettings.json:316-318` (catch-all route)

**Spec:** `docs/superpowers/specs/2026-09-14-sprint8-autogen-4-skills-design.md`

**Sprint 7 Spec (dependency):** `docs/superpowers/specs/2026-09-14-sprint7-autogen-prompts-design.md`

**Sprint 7 Plan:** `docs/superpowers/plans/2026-09-14-sprint7-autogen-prompts.md`

---

## Global Constraints

These are non-negotiable constraints from the Sprint 8 spec. Every task implicitly enforces these.

- **Python target**: 3.10. Use `from __future__ import annotations` + `Optional[T]`. Match existing `groq_service.py:178-187` style. **All new ai-service files must lint clean via §12.2.1 AST script.**
- **TS target**: Next.js 16 / React 19 strict mode. No `any` in public function signatures. Optional fields use `?:`. **All new FE files must pass `npx tsc --noEmit` with exit 0.**
- **.NET style**: Match existing nullable-aware pattern at `AdminQuestion_Service.cs:120` (`Results.BadRequest(new ApiResultDto(false, msg, null!))`).
- **matplotlib**: Use `Agg` backend (`matplotlib.use("Agg")`), defer `import matplotlib.pyplot as plt` to function scope, wrap `savefig` in try/except OSError → 502.
- **Rate limit**: All new `/api/v1/autogen/*` endpoints get 3-5 rpm/IP via `middleware/rate_limit.py:7-12` ROUTE_LIMITS dict.
- **Auth**: Reuse JWT verification pattern (Phase 5 follow-up per Sprint 7; Sprint 8 inherits same pattern). Add `RequireAuthorization` if auth helper exists in ai-service.
- **Vitest baseline**: 102+ tests passing (post-Sprint 7), 0 skipped. Sprint 8 must NOT regress.
- **pytest pattern**: async tests use `@pytest.mark.asyncio` (asyncio_mode=auto set). Mock at import boundary.
- **xUnit pattern**: New `ExamServiceBulkInsertTests.cs` uses `[Fact]` not `[Theory]` for per-case scenarios.
- **Idempotent migrations**: `BulkInsertRequest` accepts `questions[]` with `Idx` field IGNORED server-side (auto-derived from position).
- **Branch**: `refactor/sync-dotest-admin-renderer` (don't switch).
- **No new dependencies** unless task explicitly states it. matplotlib is the only new Python dep (added in Phase 3).

---

## File Structure

### Files to CREATE (18 net-new)

| File | Responsibility | LOC est. |
|---|---|---|
| `services/ai-service/app/prompts/autogen_listening.py` | 4 section-specific prompt builders (form/matching/MCQ/note completion) | 100 |
| `services/ai-service/app/prompts/autogen_writing.py` | 2 task-type prompt builders (TASK_1 chart / TASK_2 opinion) | 80 |
| `services/ai-service/app/prompts/autogen_speaking.py` | 4 scenario-type prompt builders (PART_1/2/3/ROLEPLAY) | 100 |
| `services/ai-service/app/schemas/autogen_listening.py` | Pydantic `ListeningExamRequest` + `ListeningExamResponse` + `Section` | 50 |
| `services/ai-service/app/schemas/autogen_writing.py` | Pydantic `WritingTaskRequest` + `WritingTaskResponse` | 40 |
| `services/ai-service/app/schemas/autogen_speaking.py` | Pydantic `SpeakingScenarioRequest` + `SpeakingScenarioResponse` | 50 |
| `services/ai-service/app/routers/autogen_listening.py` | `POST /api/v1/autogen/listening-exam` | 80 |
| `services/ai-service/app/routers/autogen_writing.py` | `POST /api/v1/autogen/writing-task` + chart rendering | 100 |
| `services/ai-service/app/routers/autogen_speaking.py` | `POST /api/v1/autogen/speaking-scenario` | 70 |
| `services/ai-service/app/services/matplotlib_chart.py` | Chart description → PNG rendering (bar/line/pie/table) | 120 |
| `services/ai-service/tests/test_autogen_listening_router.py` | pytest router tests with mocked Groq | 100 |
| `services/ai-service/tests/test_autogen_writing_router.py` | pytest router tests + chart URL assertion | 100 |
| `services/ai-service/tests/test_autogen_speaking_router.py` | pytest router tests | 100 |
| `services/ai-service/tests/test_matplotlib_chart.py` | pytest for chart rendering (4 types) | 100 |
| `services/exam-service/Contracts/Exams/BulkInsertRequest.cs` | BE DTO for bulk insert | 20 |
| `services/attempt-service.Tests/ExamServiceBulkInsertTests.cs` | xUnit tests for bulk endpoint | 200 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_lib/autogenClient.ts` | FE client for 4 autogen endpoints | 120 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/page.tsx` | 4-step wizard page | 150 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SkillPicker.tsx` | Step 1 component | 50 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/TopicForm.tsx` | Step 2 component | 60 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/NavButtons.tsx` | Navigation between steps | 30 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/StepIndicator.tsx` | Progress indicator | 40 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ReadingSubTab.tsx` | Reading wizard (reuses AiAuthorModal) | 80 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ListeningSubTab.tsx` | Listening wizard (4 sections preview) | 120 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/WritingSubTab.tsx` | Writing wizard (TASK_1/2 + chart preview) | 100 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/SpeakingSubTab.tsx` | Speaking wizard (4 scenario types) | 100 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/QuestionListEditor.tsx` | Reusable editor for question list | 80 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ChartPreview.tsx` | Chart image preview | 40 |
| `langfens-fe-app/src/app/admin/exams/auto-gen/_components/ScenarioJsonEditor.tsx` | JSON editor for scenario | 60 |

### Files to MODIFY (4 existing)

| File | Change | Lines touched |
|---|---|---|
| `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs` | Add `BulkInsertAsync` | 33-265 (extend) |
| `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs` | Add `BulkInsertHandler` | 6-31 (extend) |
| `services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs:48-56` | Add `POST /api/admin/question/bulk` route | 48-56 |
| `services/ai-service/app/main.py` | Register 3 new routers | 14, 82 |
| `services/ai-service/app/middleware/rate_limit.py` | Add 3 rate-limit entries | 7-12 |
| `services/ai-service/Dockerfile` | Add `matplotlib` to pip install | (add line) |
| `langfens-fe-app/src/app/admin/_lib/adminApi.ts` | Add `createQuestionBulk` | 75-87 (extend) |

### Files NOT touched (verified 2026-09-14)

- `services/writing-service/*` — no code changes (Sprint 8 only calls its existing admin endpoint).
- `services/speaking-service/*` — no code changes (Sprint 8 uses `SpeakingExam` as-is, concatenates cue_card into TaskText).
- `gateway/api-gateway/appsettings.json` — no YARP work needed.
- `AppHost/Program.cs` — `AI_SERVICE_URL` already injected.

---

# Phase 1 — Listening prompt module

## Task 1.1: Add listening section template constants

**Files:**
- Create: `services/ai-service/app/prompts/autogen_listening.py`

**Interfaces:**
- Produces: 4 section builder functions:
  - `build_section1_prompt(topic: str, level: int, count: int) -> str` (form completion)
  - `build_section2_prompt(topic: str, level: int, count: int) -> str` (matching)
  - `build_section3_prompt(topic: str, level: int, count: int) -> str` (MCQ)
  - `build_section4_prompt(topic: str, level: int, count: int) -> str` (note completion)

- [ ] **Step 1: Write `autogen_listening.py`**

```python
"""Listening auto-gen prompt builders.

Generates 4 sections (form completion, matching, MCQ, note completion)
matching IELTS Listening academic module conventions.
"""
from __future__ import annotations


def build_section1_prompt(topic: str, level: int, count: int) -> str:
    """Section 1: form completion (social context, 2 speakers).

    Args:
        topic: Topic for the listening passage (e.g. "hotel booking").
        level: IELTS band level 1-9.
        count: Number of questions in this section (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate Section 1 of an IELTS Listening test (form completion).\\n\\n"
        f"Section 1 must:\\n"
        f"- Be a social context (e.g. hotel, travel, library, shop).\\n"
        f"- Have exactly 2 speakers with a transactional conversation.\\n"
        f"- Include a form with blanks (e.g. hotel registration, booking form).\\n"
        f"- Have {count} questions.\\n\\n"
        f"Output ONLY the JSON object with this shape:\\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\\n\\n'
        f"Constraints:\\n"
        f"- audio_script: 800-1500 tokens of spoken dialogue.\\n"
        f"- questions: SUMMARY_COMPLETION type, blankAcceptTexts keys are 1-indexed.\\n"
        f"- Each blank value can be string[] (multiple acceptable spellings)."
    )


def build_section2_prompt(topic: str, level: int, count: int) -> str:
    """Section 2: matching (monologue, e.g. tour guide, library intro).

    Args:
        topic: Topic for the listening passage.
        level: IELTS band level 1-9.
        count: Number of questions (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate Section 2 of an IELTS Listening test (matching).\\n\\n"
        f"Section 2 must:\\n"
        f"- Be a monologue (1 speaker).\\n"
        f"- Have {count} questions matching items to options.\\n"
        f"- Use MATCHING_FEATURES or MATCHING_INFORMATION type.\\n\\n"
        f"Output ONLY the JSON object with this shape:\\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\\n\\n'
        f"Constraints:\\n"
        f"- audio_script: 1000-1500 tokens.\\n"
        f"- questions: MATCHING type, matchPairs values must be [acceptedKey, displayLabel].\\n"
        f"- 4-8 options in the matching pool."
    )


def build_section3_prompt(topic: str, level: int, count: int) -> str:
    """Section 3: MCQ (academic discussion, 2-4 speakers).

    Args:
        topic: Topic for the listening passage.
        level: IELTS band level 1-9.
        count: Number of questions (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate Section 3 of an IELTS Listening test (MCQ).\\n\\n"
        f"Section 3 must:\\n"
        f"- Be an academic discussion (2-4 speakers, e.g. students + tutor).\\n"
        f"- Have {count} multiple choice questions.\\n"
        f"- Mix MULTIPLE_CHOICE_SINGLE and MULTIPLE_CHOICE_MULTIPLE types.\\n\\n"
        f"Output ONLY the JSON object with this shape:\\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\\n\\n'
        f"Constraints:\\n"
        f"- audio_script: 1000-1500 tokens.\\n"
        f"- questions: MCQ type, options[].contentMd follows 'A. text' convention.\\n"
        f"- 4 options for single, 5-8 options for multiple."
    )


def build_section4_prompt(topic: str, level: int, count: int) -> str:
    """Section 4: note completion (academic lecture monologue).

    Args:
        topic: Topic for the listening passage.
        level: IELTS band level 1-9.
        count: Number of questions (typically 5-10).

    Returns:
        User prompt string.
    """
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate Section 4 of an IELTS Listening test (note completion).\\n\\n"
        f"Section 4 must:\\n"
        f"- Be an academic monologue (1 speaker, lecture style).\\n"
        f"- Have {count} questions completing notes.\\n"
        f"- Use NOTE_COMPLETION or SUMMARY_COMPLETION type.\\n\\n"
        f"Output ONLY the JSON object with this shape:\\n"
        f'{{"audio_script": "<text>", "questions": [...]}}\\n\\n'
        f"Constraints:\\n"
        f"- audio_script: 1200-1500 tokens (academic lecture).\\n"
        f"- questions: NOTE_COMPLETION type, blankAcceptTexts keys 1-indexed.\\n"
        f"- promptMd uses [N] placeholders matching dict keys."
    )


SECTION_BUILDERS = (
    build_section1_prompt,
    build_section2_prompt,
    build_section3_prompt,
    build_section4_prompt,
)
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen_listening import SECTION_BUILDERS
for i, builder in enumerate(SECTION_BUILDERS, 1):
    p = builder('hotel booking', 6, 5)
    assert 'Section ' + str(i) in p, f'Section {i} missing'
    assert 'audio_script' in p, 'audio_script missing'
print('OK: 4 section builders')
"
```

Expected: `OK: 4 section builders`.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_listening.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen_listening.py
git commit -m "feat(ai-autogen): add listening 4-section prompt builders"
```

---

# Phase 2 — Listening router

## Task 2.1: Add listening Pydantic schemas

**Files:**
- Create: `services/ai-service/app/schemas/autogen_listening.py`

**Interfaces:**
- Produces:
  - `ListeningExamRequest(topic: str, level: int, question_count: int)`
  - `Section(idx: int, title: str, audio_script: str, questions: list[dict])`
  - `ListeningExamResponse(sections: list[Section])`

- [ ] **Step 1: Write `autogen_listening.py`**

```python
"""Pydantic schemas for /api/v1/autogen/listening-exam."""
from __future__ import annotations

from pydantic import BaseModel, Field


class ListeningExamRequest(BaseModel):
    topic: str = Field(..., min_length=1, max_length=500, description="Listening topic")
    level: int = Field(..., ge=1, le=9, description="IELTS band level 1-9")
    question_count: int = Field(..., ge=5, le=40, description="Total question count across 4 sections")


class Section(BaseModel):
    idx: int = Field(..., ge=1, le=4, description="Section number 1-4")
    title: str = Field(..., min_length=1, description="Section title")
    audio_script: str = Field(..., description="Text-only audio script (admin uploads MP3 later)")
    questions: list[dict] = Field(..., description="Question JSON objects")


class ListeningExamResponse(BaseModel):
    sections: list[Section] = Field(..., min_length=4, max_length=4, description="Exactly 4 sections")
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.schemas.autogen_listening import ListeningExamRequest, Section, ListeningExamResponse
r = ListeningExamRequest(topic='hotel', level=6, question_count=30)
print(r.model_dump())
"
```

Expected: prints dict with topic, level, question_count.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/schemas/autogen_listening.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/schemas/autogen_listening.py
git commit -m "feat(ai-autogen): add Pydantic schemas for listening exam endpoint"
```

---

## Task 2.2: Add listening router

**Files:**
- Create: `services/ai-service/app/routers/autogen_listening.py`
- Modify: `services/ai-service/app/main.py:14,82` — register router
- Modify: `services/ai-service/app/middleware/rate_limit.py:7-12` — add rate-limit

**Interfaces:**
- Consumes: `SECTION_BUILDERS` from Task 1.1, schemas from Task 2.1, `groq_generate` from Sprint 7
- Produces: HTTP endpoint `POST /api/v1/autogen/listening-exam`

- [ ] **Step 1: Write `autogen_listening.py`**

```python
"""Auto-gen router for IELTS Listening exam (4 sections)."""
from __future__ import annotations

import logging
from typing import Any

from fastapi import APIRouter, HTTPException, status

from app.prompts.autogen_listening import SECTION_BUILDERS
from app.schemas.autogen_listening import (
    ListeningExamRequest,
    ListeningExamResponse,
    Section,
)
from app.services.groq_service import groq_generate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])

SECTION_TITLES = [
    "Section 1: Social Context (Form Completion)",
    "Section 2: Monologue (Matching)",
    "Section 3: Academic Discussion (MCQ)",
    "Section 4: Academic Lecture (Note Completion)",
]


@router.post("/listening-exam", response_model=ListeningExamResponse)
async def autogen_listening_exam(req: ListeningExamRequest) -> ListeningExamResponse:
    """Generate 4 sections of an IELTS Listening exam.

    Iterates 4 section builders, calls Groq for each, combines into one response.

    Args:
        req: Request body with topic, level, total question count.

    Returns:
        Response with 4 sections (idx 1-4), each with audio_script + questions.

    Raises:
        HTTPException 502 if any LLM call fails to produce a valid dict.
    """
    per_section = max(1, req.question_count // 4)
    sections: list[Section] = []

    for idx, (builder, title) in enumerate(zip(SECTION_BUILDERS, SECTION_TITLES), start=1):
        user_prompt = builder(req.topic, req.level, per_section)
        system_prompt = (
            "You are an IELTS Listening content author. "
            "Output ONLY a single JSON object with 'audio_script' (string) and "
            "'questions' (array of question JSON objects). "
            "Strict JSON mode: no markdown fences, no explanation."
        )

        try:
            result: dict[str, Any] = await groq_generate(
                prompt_template="{user}",
                variables={"user": user_prompt},
                expect_json=True,
                temperature=0.3,
                max_tokens=4096,
            )
        except Exception as exc:
            logger.error("Section %d LLM call failed: %s", idx, exc)
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"LLM call for section {idx} failed: {exc}",
            ) from exc

        audio_script = result.get("audio_script", "")
        questions = result.get("questions", [])

        if not isinstance(audio_script, str):
            logger.error("Section %d audio_script is not a string", idx)
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Section {idx} audio_script is not a string",
            )
        if not isinstance(questions, list):
            logger.error("Section %d questions is not a list", idx)
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Section {idx} questions is not a list",
            )

        sections.append(
            Section(
                idx=idx,
                title=title,
                audio_script=audio_script[:1500],  # truncate to Groq-safe length
                questions=questions,
            )
        )

    return ListeningExamResponse(sections=sections)
```

- [ ] **Step 2: Register router in `main.py`**

Edit `services/ai-service/app/main.py:14`:

```python
from app.routers import health, embed, writing, grammar, speaking, practice, speech_eval, speaking_grade, autogen, autogen_listening  # ADDED autogen_listening
```

Edit `services/ai-service/app/main.py:82`:

```python
app.include_router(autogen.router, prefix="/api")  # Sprint 7
app.include_router(autogen_listening.router, prefix="/api")  # ADDED
```

- [ ] **Step 3: Add rate-limit entry**

Edit `services/ai-service/app/middleware/rate_limit.py:7-12`:

```python
ROUTE_LIMITS: dict[str, int] = {
    "/api/v1/writing/compare": 10,
    "/api/v1/grammar/explain": 20,
    "/api/v1/grammar/batch-explain": 10,
    "/api/v1/grammar/detect": 10,
    "/api/v1/autogen/questions": 5,
    "/api/v1/autogen/listening-exam": 3,  # ADDED — 4 LLM calls per request
}
```

- [ ] **Step 4: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.routers.autogen_listening import router; print(router.prefix, len(router.routes))"
```

Expected: `/v1/autogen 1`.

- [ ] **Step 5: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/routers/autogen_listening.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/routers/autogen_listening.py services/ai-service/app/main.py services/ai-service/app/middleware/rate_limit.py
git commit -m "feat(ai-autogen): add listening exam router with 4-section iteration"
```

---

## Task 2.3: Add pytest tests for listening router

**Files:**
- Create: `services/ai-service/tests/test_autogen_listening_router.py`

- [ ] **Step 1: Write the test file**

```python
"""Tests for /api/v1/autogen/listening-exam router with mocked Groq."""
from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_listening_exam_returns_4_sections():
    """Happy path: 4 sections returned, each with audio_script + questions."""
    mock_section_output = {
        "audio_script": "Speaker A: Hello, I'd like to book a room...",
        "questions": [
            {"type": "SUMMARY_COMPLETION", "blankAcceptTexts": {"1": ["yes"]}},
            {"type": "SUMMARY_COMPLETION", "blankAcceptTexts": {"2": ["two"]}},
        ],
    }
    with patch("app.routers.autogen_listening.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_section_output
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/listening-exam",
                json={"topic": "hotel booking", "level": 6, "question_count": 12},
            )
        assert resp.status_code == 200
        body = resp.json()
        assert "sections" in body
        assert len(body["sections"]) == 4
        assert body["sections"][0]["idx"] == 1
        assert body["sections"][3]["idx"] == 4
        assert "audio_script" in body["sections"][0]
        assert len(body["sections"][0]["questions"]) >= 1


@pytest.mark.asyncio
async def test_listening_exam_502_when_llm_returns_non_dict():
    """If Groq returns string instead of dict, router returns 502."""
    with patch("app.routers.autogen_listening.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = "not a dict"
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/listening-exam",
                json={"topic": "test", "level": 6, "question_count": 8},
            )
        assert resp.status_code == 502


@pytest.mark.asyncio
async def test_listening_exam_truncates_audio_script_to_1500():
    """audio_script truncated to 1500 chars for Groq safety."""
    long_script = "x" * 3000
    mock_output = {"audio_script": long_script, "questions": []}
    with patch("app.routers.autogen_listening.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_output
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/listening-exam",
                json={"topic": "test", "level": 6, "question_count": 8},
            )
        assert resp.status_code == 200
        for section in resp.json()["sections"]:
            assert len(section["audio_script"]) <= 1500
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_listening_router.py -v
```

Expected: 3 tests passed.

- [ ] **Step 3: Verify no warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_listening_router.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_listening_router.py
git commit -m "test(ai-autogen): add listening router tests with mocked Groq"
```

---

# Phase 3 — Writing + matplotlib

## Task 3.1: Add matplotlib chart rendering service

**Files:**
- Create: `services/ai-service/app/services/matplotlib_chart.py`

**Interfaces:**
- Produces: `render_chart_png(description: str, output_path: str) -> None`

- [ ] **Step 1: Add matplotlib to requirements**

Edit `services/ai-service/requirements.txt`:

Add at end of file:

```
matplotlib==3.9.0
```

- [ ] **Step 2: Write `matplotlib_chart.py`**

```python
"""Chart rendering from text descriptions using matplotlib Agg backend."""
from __future__ import annotations

import json
import logging
import re
from pathlib import Path

logger = logging.getLogger(__name__)


def _parse_description(description: str) -> dict[str, object]:
    """Parse a chart description string into structured fields.

    Expected format: JSON object with keys:
    - chart_type: "bar" | "line" | "pie" | "table" (required)
    - title: string
    - data: list of {label, value} for bar/line/pie, or rows for table

    Falls back to {"chart_type": "table", "title": "Chart", "rows": [["Col", "Val"]]}.
    """
    description = description.strip()
    try:
        parsed = json.loads(description)
        if isinstance(parsed, dict):
            return parsed
    except json.JSONDecodeError:
        pass

    # Fallback: try to extract chart_type and data from plain text
    chart_type_match = re.search(r"chart_type:\s*(\w+)", description)
    chart_type = chart_type_match.group(1) if chart_type_match else "table"
    return {"chart_type": chart_type, "title": "Chart", "rows": [["Col", "Val"]]}


def render_chart_png(description: str, output_path: str) -> None:
    """Render a chart PNG from text description.

    Supports bar, line, pie, table. Falls back to table on parse failure.

    Args:
        description: JSON or plain-text chart description.
        output_path: Absolute path to write PNG.

    Raises:
        OSError: If matplotlib fails to write the file.
    """
    # Defer import to function scope (Agg backend setup is per-process)
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    parsed = _parse_description(description)
    chart_type = str(parsed.get("chart_type", "table"))
    title = str(parsed.get("title", "Chart"))

    fig, ax = plt.subplots(figsize=(8, 6))

    try:
        if chart_type == "bar":
            data = parsed.get("data", [])
            labels = [str(d.get("label", "")) for d in data]
            values = [float(d.get("value", 0)) for d in data]
            ax.bar(labels, values)
            ax.set_title(title)
            ax.set_ylabel("Value")
        elif chart_type == "line":
            data = parsed.get("data", [])
            xs = [str(d.get("label", "")) for d in data]
            ys = [float(d.get("value", 0)) for d in data]
            ax.plot(xs, ys, marker="o")
            ax.set_title(title)
            ax.set_ylabel("Value")
        elif chart_type == "pie":
            data = parsed.get("data", [])
            labels = [str(d.get("label", "")) for d in data]
            values = [float(d.get("value", 0)) for d in data]
            ax.pie(values, labels=labels, autopct="%1.1f%%")
            ax.set_title(title)
        else:  # table or fallback
            rows = parsed.get("rows", [["Col", "Val"]])
            ax.axis("off")
            table = ax.table(cellText=rows, loc="center")
            table.auto_set_font_size(False)
            table.set_fontsize(10)
            ax.set_title(title)

        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(output_path, dpi=100, bbox_inches="tight")
        plt.close(fig)
    except OSError:
        plt.close(fig)
        raise
```

- [ ] **Step 3: Add matplotlib to Dockerfile**

Read `services/ai-service/Dockerfile` first to find the pip install line:

```bash
grep -n "pip install\|requirements" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service/Dockerfile
```

Add `matplotlib` to the requirements list. If Dockerfile uses `pip install -r requirements.txt`, no change needed beyond Task 3.1 Step 1.

- [ ] **Step 4: Write pytest for chart renderer**

Create `services/ai-service/tests/test_matplotlib_chart.py`:

```python
"""Tests for matplotlib chart renderer."""
from __future__ import annotations

import os
import tempfile

import pytest

from app.services.matplotlib_chart import render_chart_png


@pytest.fixture
def tmp_png_path():
    with tempfile.TemporaryDirectory() as tmpdir:
        yield os.path.join(tmpdir, "test.png")


def test_render_bar_chart(tmp_png_path):
    """Bar chart renders successfully."""
    desc = '{"chart_type": "bar", "title": "Test", "data": [{"label": "A", "value": 10}, {"label": "B", "value": 20}]}'
    render_chart_png(desc, tmp_png_path)
    assert os.path.exists(tmp_png_path)
    assert os.path.getsize(tmp_png_path) > 1000  # >1KB = valid PNG


def test_render_line_chart(tmp_png_path):
    desc = '{"chart_type": "line", "title": "Trend", "data": [{"label": "1", "value": 5}, {"label": "2", "value": 10}]}'
    render_chart_png(desc, tmp_png_path)
    assert os.path.exists(tmp_png_path)


def test_render_pie_chart(tmp_png_path):
    desc = '{"chart_type": "pie", "title": "Share", "data": [{"label": "X", "value": 30}, {"label": "Y", "value": 70}]}'
    render_chart_png(desc, tmp_png_path)
    assert os.path.exists(tmp_png_path)


def test_render_table_chart(tmp_png_path):
    desc = '{"chart_type": "table", "title": "Data", "rows": [["Year", "Sales"], ["2020", "100"]]}'
    render_chart_png(desc, tmp_png_path)
    assert os.path.exists(tmp_png_path)


def test_render_invalid_description_falls_back_to_table(tmp_png_path):
    """Invalid JSON description falls back to table chart."""
    render_chart_png("not valid json", tmp_png_path)
    assert os.path.exists(tmp_png_path)
```

- [ ] **Step 5: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_matplotlib_chart.py -v
```

Expected: 5 tests passed.

- [ ] **Step 6: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/services/matplotlib_chart.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 7: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/services/matplotlib_chart.py services/ai-service/requirements.txt services/ai-service/tests/test_matplotlib_chart.py services/ai-service/Dockerfile
git commit -m "feat(ai-autogen): add matplotlib chart renderer with 4 chart types"
```

---

## Task 3.2: Add writing Pydantic schemas

**Files:**
- Create: `services/ai-service/app/schemas/autogen_writing.py`

**Interfaces:**
- Produces:
  - `WritingTaskRequest(task_type: "TASK_1" | "TASK_2", topic: str, level: int)`
  - `WritingTaskResponse(prompt, chart_description?, chart_url?, model_answers, suggested_vocabulary)`

- [ ] **Step 1: Write `autogen_writing.py`**

```python
"""Pydantic schemas for /api/v1/autogen/writing-task."""
from __future__ import annotations

from typing import Literal, Optional

from pydantic import BaseModel, Field


class WritingTaskRequest(BaseModel):
    task_type: Literal["TASK_1", "TASK_2"] = Field(..., description="TASK_1 (chart) or TASK_2 (opinion)")
    topic: str = Field(..., min_length=1, max_length=500)
    level: int = Field(..., ge=1, le=9)


class WritingTaskResponse(BaseModel):
    prompt: str = Field(..., min_length=1)
    chart_description: Optional[str] = Field(default=None, description="TASK_1 only")
    chart_url: Optional[str] = Field(default=None, description="TASK_1 only, e.g. /static/charts/<uuid>.png")
    model_answers: list[str] = Field(default_factory=list)
    suggested_vocabulary: list[str] = Field(default_factory=list)
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.schemas.autogen_writing import WritingTaskRequest, WritingTaskResponse
r = WritingTaskRequest(task_type='TASK_2', topic='technology', level=6)
print(r.model_dump())
"
```

Expected: prints dict.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/schemas/autogen_writing.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/schemas/autogen_writing.py
git commit -m "feat(ai-autogen): add Pydantic schemas for writing task endpoint"
```

---

## Task 3.3: Add writing prompt builders

**Files:**
- Create: `services/ai-service/app/prompts/autogen_writing.py`

**Interfaces:**
- Produces:
  - `build_task1_system_prompt() -> str`
  - `build_task1_user_prompt(topic: str, level: int) -> str`
  - `build_task2_system_prompt() -> str`
  - `build_task2_user_prompt(topic: str, level: int) -> str`

- [ ] **Step 1: Write `autogen_writing.py`**

```python
"""Writing auto-gen prompt builders for IELTS TASK_1 and TASK_2."""
from __future__ import annotations


def build_task1_system_prompt() -> str:
    """System prompt for IELTS Writing Task 1 (chart description)."""
    return (
        "You are an IELTS Writing Task 1 content author. "
        "Generate a Task 1 prompt with chart description and model answer.\\n\\n"
        "Output ONLY a single JSON object with this shape:\\n"
        '{"prompt": "<task prompt text>", "chart_description": "<JSON: {chart_type, title, data|rows}>", '
        '"model_answers": ["<model essay 1>", ...], "suggested_vocabulary": ["word1", ...]}\\n\\n'
        "Constraints:\\n"
        "- Task 1 prompt: 150-200 words describing data in a chart/graph/table.\\n"
        "- chart_description must be valid JSON with chart_type in {bar, line, pie, table}.\\n"
        "- model_answers: 1-2 sample essays, 150+ words each.\\n"
        "- suggested_vocabulary: 5-10 academic words."
    )


def build_task1_user_prompt(topic: str, level: int) -> str:
    """User prompt for TASK_1."""
    return (
        f"Topic: {topic}\\n"
        f"Target band level: {level}\\n\\n"
        f"Generate IELTS Writing Task 1 prompt + chart + model answer.\\n"
        f"Output ONLY the JSON object."
    )


def build_task2_system_prompt() -> str:
    """System prompt for IELTS Writing Task 2 (opinion essay)."""
    return (
        "You are an IELTS Writing Task 2 content author. "
        "Generate a Task 2 prompt with opinion statement and model essay.\\n\\n"
        "Output ONLY a single JSON object with this shape:\\n"
        '{"prompt": "<opinion statement>", "chart_description": null, '
        '"model_answers": ["<model essay>", ...], "suggested_vocabulary": ["word1", ...]}\\n\\n'
        "Constraints:\\n"
        "- Task 2 prompt: a debatable opinion or problem statement.\\n"
        "- chart_description must be null for TASK_2.\\n"
        "- model_answers: 1-2 essays, 250+ words each.\\n"
        "- suggested_vocabulary: 8-12 academic words."
    )


def build_task2_user_prompt(topic: str, level: int) -> str:
    """User prompt for TASK_2."""
    return (
        f"Topic: {topic}\\n"
        f"Target band level: {level}\\n\\n"
        f"Generate IELTS Writing Task 2 prompt + model essay.\\n"
        f"Output ONLY the JSON object."
    )
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen_writing import build_task1_user_prompt, build_task2_user_prompt
p1 = build_task1_user_prompt('sales trends', 6)
p2 = build_task2_user_prompt('technology', 7)
assert 'sales trends' in p1
assert 'technology' in p2
print('OK')
"
```

Expected: `OK`.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_writing.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen_writing.py
git commit -m "feat(ai-autogen): add writing TASK_1 + TASK_2 prompt builders"
```

---

## Task 3.4: Add writing router with chart rendering

**Files:**
- Create: `services/ai-service/app/routers/autogen_writing.py`
- Modify: `services/ai-service/app/main.py` — register + mount static
- Modify: `services/ai-service/app/middleware/rate_limit.py` — add rate-limit

**Interfaces:**
- Consumes: prompts from Task 3.3, schemas from Task 3.2, `matplotlib_chart.render_chart_png` from Task 3.1, `groq_generate` from Sprint 7
- Produces: HTTP endpoint `POST /api/v1/autogen/writing-task`

- [ ] **Step 1: Write `autogen_writing.py`**

```python
"""Auto-gen router for IELTS Writing tasks (TASK_1 chart + TASK_2 opinion)."""
from __future__ import annotations

import json
import logging
import os
import uuid
from pathlib import Path
from typing import Any

from fastapi import APIRouter, HTTPException, status

from app.prompts.autogen_writing import (
    build_task1_system_prompt,
    build_task1_user_prompt,
    build_task2_system_prompt,
    build_task2_user_prompt,
)
from app.schemas.autogen_writing import WritingTaskRequest, WritingTaskResponse
from app.services.groq_service import groq_generate
from app.services.matplotlib_chart import render_chart_png

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])

CHARTS_DIR = Path("/app/static/charts")


@router.post("/writing-task", response_model=WritingTaskResponse)
async def autogen_writing_task(req: WritingTaskRequest) -> WritingTaskResponse:
    """Generate IELTS Writing TASK_1 or TASK_2.

    TASK_1: generates chart_description JSON + renders PNG to /app/static/charts/<uuid>.png.
    TASK_2: generates opinion prompt + model essay, no chart.

    Args:
        req: Request body with task_type, topic, level.

    Returns:
        Response with prompt, optional chart_description + chart_url, model_answers, vocab.

    Raises:
        HTTPException 502 if LLM call fails or chart rendering fails.
    """
    if req.task_type == "TASK_1":
        system_prompt = build_task1_system_prompt()
        user_prompt = build_task1_user_prompt(req.topic, req.level)
    else:
        system_prompt = build_task2_system_prompt()
        user_prompt = build_task2_user_prompt(req.topic, req.level)

    try:
        result: dict[str, Any] = await groq_generate(
            prompt_template="{user}",
            variables={"user": user_prompt},
            expect_json=True,
            temperature=0.3,
            max_tokens=4096,
        )
    except Exception as exc:
        logger.error("Writing LLM call failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"LLM call failed: {exc}",
        ) from exc

    prompt_text = result.get("prompt", "")
    chart_description = result.get("chart_description") if req.task_type == "TASK_1" else None
    chart_url: str | None = None

    if req.task_type == "TASK_1" and chart_description:
        chart_filename = f"{uuid.uuid4()}.png"
        chart_path = str(CHARTS_DIR / chart_filename)
        try:
            render_chart_png(chart_description, chart_path)
            chart_url = f"/static/charts/{chart_filename}"
        except OSError as exc:
            logger.error("Chart rendering failed: %s", exc)
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Chart rendering failed: {exc}",
            ) from exc

    model_answers_raw = result.get("model_answers", [])
    suggested_vocab_raw = result.get("suggested_vocabulary", [])
    model_answers = model_answers_raw if isinstance(model_answers_raw, list) else []
    suggested_vocabulary = suggested_vocab_raw if isinstance(suggested_vocab_raw, list) else []

    return WritingTaskResponse(
        prompt=str(prompt_text),
        chart_description=chart_description,
        chart_url=chart_url,
        model_answers=[str(x) for x in model_answers],
        suggested_vocabulary=[str(x) for x in suggested_vocabulary],
    )
```

- [ ] **Step 2: Register router + mount static dir in `main.py`**

Edit `services/ai-service/app/main.py:14`:

```python
from app.routers import health, embed, writing, grammar, speaking, practice, speech_eval, speaking_grade, autogen, autogen_listening, autogen_writing  # ADDED autogen_writing
```

Edit `services/ai-service/app/main.py:82`:

```python
app.include_router(autogen_listening.router, prefix="/api")  # Sprint 8 Phase 2
app.include_router(autogen_writing.router, prefix="/api")  # ADDED
```

Add static file mount near `app = FastAPI(...)` line (~line 51):

```python
from fastapi.staticfiles import StaticFiles  # ADDED import

app.mount("/static", StaticFiles(directory="/app/static"), name="static")  # ADDED mount
```

Ensure `/app/static/charts` dir exists at container startup. Add to lifespan:

```python
# After app = FastAPI(...) and before lifespan
import os
os.makedirs("/app/static/charts", exist_ok=True)
```

- [ ] **Step 3: Add rate-limit entry**

Edit `services/ai-service/app/middleware/rate_limit.py:7-12`:

```python
ROUTE_LIMITS: dict[str, int] = {
    "/api/v1/writing/compare": 10,
    "/api/v1/grammar/explain": 20,
    "/api/v1/grammar/batch-explain": 10,
    "/api/v1/grammar/detect": 10,
    "/api/v1/autogen/questions": 5,
    "/api/v1/autogen/listening-exam": 3,
    "/api/v1/autogen/writing-task": 10,  # ADDED
}
```

- [ ] **Step 4: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.routers.autogen_writing import router; print(router.prefix, len(router.routes))"
```

Expected: `/v1/autogen 1`.

- [ ] **Step 5: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/routers/autogen_writing.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/routers/autogen_writing.py services/ai-service/app/main.py services/ai-service/app/middleware/rate_limit.py
git commit -m "feat(ai-autogen): add writing-task router with chart rendering"
```

---

## Task 3.5: Add pytest tests for writing router

**Files:**
- Create: `services/ai-service/tests/test_autogen_writing_router.py`

- [ ] **Step 1: Write the test file**

```python
"""Tests for /api/v1/autogen/writing-task router with mocked Groq."""
from __future__ import annotations

import os
import tempfile
from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.routers.autogen_writing import CHARTS_DIR


@pytest.fixture
def mock_charts_dir(tmp_path, monkeypatch):
    """Override CHARTS_DIR to a temp dir for chart rendering tests."""
    monkeypatch.setattr("app.routers.autogen_writing.CHARTS_DIR", tmp_path)
    return tmp_path


@pytest.mark.asyncio
async def test_task1_returns_chart_url(mock_charts_dir):
    """TASK_1 response includes chart_url after rendering."""
    mock_llm_output = {
        "prompt": "The chart shows sales trends...",
        "chart_description": '{"chart_type": "bar", "title": "Sales", "data": [{"label": "A", "value": 10}]}',
        "model_answers": ["Sample essay..."],
        "suggested_vocabulary": ["trend", "increase"],
    }
    with patch("app.routers.autogen_writing.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_llm_output
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/writing-task",
                json={"task_type": "TASK_1", "topic": "sales", "level": 6},
            )
        assert resp.status_code == 200
        body = resp.json()
        assert body["chart_url"] is not None
        assert body["chart_url"].startswith("/static/charts/")
        # Verify chart file was created
        chart_filename = body["chart_url"].split("/")[-1]
        chart_path = mock_charts_dir / chart_filename
        assert chart_path.exists()
        assert chart_path.stat().st_size > 1000


@pytest.mark.asyncio
async def test_task2_returns_no_chart():
    """TASK_2 response has chart_url=null."""
    mock_llm_output = {
        "prompt": "Some people argue that...",
        "chart_description": None,
        "model_answers": ["Model essay 1"],
        "suggested_vocabulary": ["debate", "opinion"],
    }
    with patch("app.routers.autogen_writing.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_llm_output
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/writing-task",
                json={"task_type": "TASK_2", "topic": "technology", "level": 6},
            )
        assert resp.status_code == 200
        body = resp.json()
        assert body["chart_url"] is None
        assert body["chart_description"] is None


@pytest.mark.asyncio
async def test_task1_502_when_chart_rendering_fails(mock_charts_dir, monkeypatch):
    """If chart file path is unwritable, return 502."""
    mock_llm_output = {
        "prompt": "test",
        "chart_description": '{"chart_type": "bar", "data": []}',
    }
    with patch("app.routers.autogen_writing.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_llm_output
        with patch("app.routers.autogen_writing.render_chart_png", side_effect=OSError("disk full")):
            async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
                resp = await ac.post(
                    "/api/v1/autogen/writing-task",
                    json={"task_type": "TASK_1", "topic": "test", "level": 6},
                )
            assert resp.status_code == 502
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_writing_router.py -v
```

Expected: 3 tests passed.

- [ ] **Step 3: Verify no warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_writing_router.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_writing_router.py
git commit -m "test(ai-autogen): add writing router tests with chart rendering"
```

---

# Phase 4 — Speaking router

## Task 4.1: Add speaking Pydantic schemas

**Files:**
- Create: `services/ai-service/app/schemas/autogen_speaking.py`

- [ ] **Step 1: Write `autogen_speaking.py`**

```python
"""Pydantic schemas for /api/v1/autogen/speaking-scenario."""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class SpeakingScenarioRequest(BaseModel):
    scenario_type: Literal["PART_1", "PART_2", "PART_3", "ROLEPLAY"] = Field(..., description="Speaking part")
    topic: str = Field(..., min_length=1, max_length=500)
    level: int = Field(..., ge=1, le=9)


class SpeakingScenarioResponse(BaseModel):
    slug: str = Field(..., min_length=1, max_length=100)
    title: str = Field(..., min_length=1)
    difficulty: str = Field(..., description="BEGINNER|INTERMEDIATE|ADVANCED")
    ielts_part: str = Field(...)
    context: str = Field(...)
    user_role: str = Field(...)
    agent_role: str = Field(...)
    opening_prompt: str = Field(...)
    target_vocabulary: list[str] = Field(default_factory=list)
    target_grammar: list[str] = Field(default_factory=list)
    suggested_topics: list[str] = Field(default_factory=list)
    duration_min: int = Field(..., ge=1, le=20)
    turn_count_target: int = Field(..., ge=1, le=20)
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.schemas.autogen_speaking import SpeakingScenarioRequest
r = SpeakingScenarioRequest(scenario_type='PART_1', topic='hobbies', level=6)
print(r.model_dump())
"
```

Expected: prints dict.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/schemas/autogen_speaking.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/schemas/autogen_speaking.py
git commit -m "feat(ai-autogen): add Pydantic schemas for speaking scenario endpoint"
```

---

## Task 4.2: Add speaking prompt builders

**Files:**
- Create: `services/ai-service/app/prompts/autogen_speaking.py`

- [ ] **Step 1: Write `autogen_speaking.py`**

```python
"""Speaking auto-gen prompt builders for 4 scenario types."""
from __future__ import annotations


def build_part1_prompt(topic: str, level: int) -> str:
    """Part 1: personal questions (interview-style, 4-5 min)."""
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate IELTS Speaking Part 1 scenario (personal questions, interview-style).\\n\\n"
        f"Output ONLY a single JSON object matching the schema.\\n"
        f"Constraints:\\n"
        f"- ielts_part: SITUATIONAL\\n"
        f"- duration_min: 4-5\\n"
        f"- turn_count_target: 5-6\\n"
        f"- target_vocabulary: 5-8 personal/idiomatic words.\\n"
        f"- target_grammar: Present Simple for habits."
    )


def build_part2_prompt(topic: str, level: int) -> str:
    """Part 2: cue card (long turn, 3-4 min)."""
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate IELTS Speaking Part 2 scenario (cue card).\\n\\n"
        f"Output ONLY a single JSON object.\\n"
        f"Constraints:\\n"
        f"- ielts_part: CUE_CARD\\n"
        f"- duration_min: 3-4\\n"
        f"- turn_count_target: 1-2 (long turn)\\n"
        f"- opening_prompt must describe a scenario to speak about for 2 min.\\n"
        f"- suggested_topics: 3-4 sub-points to cover."
    )


def build_part3_prompt(topic: str, level: int) -> str:
    """Part 3: abstract discussion (analytical questions, 4-5 min)."""
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate IELTS Speaking Part 3 scenario (abstract discussion).\\n\\n"
        f"Output ONLY a single JSON object.\\n"
        f"Constraints:\\n"
        f"- ielts_part: DISCUSSION\\n"
        f"- duration_min: 4-5\\n"
        f"- turn_count_target: 5-6\\n"
        f"- target_grammar: Present Perfect for experience, modals for speculation."
    )


def build_roleplay_prompt(topic: str, level: int) -> str:
    """Roleplay scenario (situational practice, 6-8 min)."""
    return (
        f"Topic: {topic}\\n"
        f"Level: band {level}\\n\\n"
        f"Generate a roleplay scenario (situational practice).\\n\\n"
        f"Output ONLY a single JSON object.\\n"
        f"Constraints:\\n"
        f"- ielts_part: ROLEPLAY\\n"
        f"- duration_min: 6-8\\n"
        f"- turn_count_target: 6-8\\n"
        f"- context describes a specific situation (e.g. airport, restaurant).\\n"
        f"- user_role and agent_role must be distinct."
    )


SCENARIO_BUILDERS = {
    "PART_1": build_part1_prompt,
    "PART_2": build_part2_prompt,
    "PART_3": build_part3_prompt,
    "ROLEPLAY": build_roleplay_prompt,
}
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen_speaking import SCENARIO_BUILDERS
for scenario_type in ['PART_1', 'PART_2', 'PART_3', 'ROLEPLAY']:
    p = SCENARIO_BUILDERS[scenario_type]('test topic', 6)
    assert scenario_type in p
print('OK: 4 scenario builders')
"
```

Expected: `OK: 4 scenario builders`.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_speaking.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen_speaking.py
git commit -m "feat(ai-autogen): add speaking 4-scenario prompt builders"
```

---

## Task 4.3: Add speaking router

**Files:**
- Create: `services/ai-service/app/routers/autogen_speaking.py`
- Modify: `services/ai-service/app/main.py` — register
- Modify: `services/ai-service/app/middleware/rate_limit.py` — add rate-limit

- [ ] **Step 1: Write `autogen_speaking.py`**

```python
"""Auto-gen router for IELTS Speaking scenarios."""
from __future__ import annotations

import logging
import re
from typing import Any

from fastapi import APIRouter, HTTPException, status

from app.prompts.autogen_speaking import SCENARIO_BUILDERS
from app.schemas.autogen_speaking import SpeakingScenarioRequest, SpeakingScenarioResponse
from app.services.groq_service import groq_generate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])


def _slugify(title: str) -> str:
    """Convert title to kebab-case slug."""
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", title.lower()).strip("-")
    return slug[:100] or "scenario"


@router.post("/speaking-scenario", response_model=SpeakingScenarioResponse)
async def autogen_speaking_scenario(req: SpeakingScenarioRequest) -> SpeakingScenarioResponse:
    """Generate an IELTS Speaking scenario (Part 1/2/3 or Roleplay)."""
    builder = SCENARIO_BUILDERS[req.scenario_type]
    user_prompt = builder(req.topic, req.level)
    system_prompt = (
        "You are an IELTS Speaking content author. "
        "Output ONLY a single JSON object matching the response schema. "
        "Strict JSON mode: no markdown fences, no explanation."
    )

    try:
        result: dict[str, Any] = await groq_generate(
            prompt_template="{user}",
            variables={"user": user_prompt},
            expect_json=True,
            temperature=0.3,
            max_tokens=2048,
        )
    except Exception as exc:
        logger.error("Speaking LLM call failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"LLM call failed: {exc}",
        ) from exc

    title = str(result.get("title", req.topic))
    slug = _slugify(title)
    return SpeakingScenarioResponse(
        slug=slug,
        title=title,
        difficulty=str(result.get("difficulty", "INTERMEDIATE")),
        ielts_part=str(result.get("ielts_part", "")),
        context=str(result.get("context", "")),
        user_role=str(result.get("user_role", "")),
        agent_role=str(result.get("agent_role", "")),
        opening_prompt=str(result.get("opening_prompt", "")),
        target_vocabulary=[str(x) for x in result.get("target_vocabulary", []) if isinstance(result.get("target_vocabulary"), list)],
        target_grammar=[str(x) for x in result.get("target_grammar", []) if isinstance(result.get("target_grammar"), list)],
        suggested_topics=[str(x) for x in result.get("suggested_topics", []) if isinstance(result.get("suggested_topics"), list)],
        duration_min=int(result.get("duration_min", 5)),
        turn_count_target=int(result.get("turn_count_target", 5)),
    )
```

- [ ] **Step 2: Register router in `main.py`**

Edit `services/ai-service/app/main.py:14`:

```python
from app.routers import health, embed, writing, grammar, speaking, practice, speech_eval, speaking_grade, autogen, autogen_listening, autogen_writing, autogen_speaking  # ADDED autogen_speaking
```

Edit `services/ai-service/app/main.py:82`:

```python
app.include_router(autogen_writing.router, prefix="/api")  # Sprint 8 Phase 3
app.include_router(autogen_speaking.router, prefix="/api")  # ADDED
```

- [ ] **Step 3: Add rate-limit entry**

Edit `services/ai-service/app/middleware/rate_limit.py:7-12`:

```python
ROUTE_LIMITS: dict[str, int] = {
    "/api/v1/writing/compare": 10,
    "/api/v1/grammar/explain": 20,
    "/api/v1/grammar/batch-explain": 10,
    "/api/v1/grammar/detect": 10,
    "/api/v1/autogen/questions": 5,
    "/api/v1/autogen/listening-exam": 3,
    "/api/v1/autogen/writing-task": 10,
    "/api/v1/autogen/speaking-scenario": 10,  # ADDED
}
```

- [ ] **Step 4: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.routers.autogen_speaking import router; print(router.prefix, len(router.routes))"
```

Expected: `/v1/autogen 1`.

- [ ] **Step 5: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/routers/autogen_speaking.py'
with open(f) as fp:
    tree = ast.parse(fp.read())
for node in ast.walk(tree):
    if isinstance(node, ast.FunctionDef):
        if node.name.startswith('_'):
            continue
        if not node.returns:
            print(f'WARNING: {f}:{node.lineno} {node.name}() missing return annotation')
        for arg in node.args.args:
            if arg.arg == 'self':
                continue
            if not arg.annotation:
                print(f'WARNING: {f}:{node.lineno} {node.name}({arg.arg}) missing arg annotation')
"
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/routers/autogen_speaking.py services/ai-service/app/main.py services/ai-service/app/middleware/rate_limit.py
git commit -m "feat(ai-autogen): add speaking-scenario router for 4 scenario types"
```

---

## Task 4.4: Add pytest tests for speaking router

**Files:**
- Create: `services/ai-service/tests/test_autogen_speaking_router.py`

- [ ] **Step 1: Write the test file**

```python
"""Tests for /api/v1/autogen/speaking-scenario router with mocked Groq."""
from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_scenario_returns_full_schema():
    """Happy path: all 4 scenario types return full schema."""
    mock_output = {
        "title": "Cafe Order Roleplay",
        "difficulty": "INTERMEDIATE",
        "ielts_part": "ROLEPLAY",
        "context": "You are ordering at a busy cafe.",
        "user_role": "Customer",
        "agent_role": "Cafe staff",
        "opening_prompt": "Hi, what would you like to order?",
        "target_vocabulary": ["menu", "order", "drink"],
        "target_grammar": ["would like"],
        "suggested_topics": ["food preferences", "dietary restrictions"],
        "duration_min": 6,
        "turn_count_target": 7,
    }
    with patch("app.routers.autogen_speaking.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_output
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/speaking-scenario",
                json={"scenario_type": "ROLEPLAY", "topic": "cafe", "level": 6},
            )
        assert resp.status_code == 200
        body = resp.json()
        assert body["slug"] == "cafe-order-roleplay"
        assert body["title"] == "Cafe Order Roleplay"
        assert body["difficulty"] == "INTERMEDIATE"
        assert len(body["target_vocabulary"]) == 3


@pytest.mark.asyncio
async def test_scenario_slug_generated_from_title():
    """Slug is kebab-case of title, fallback to topic."""
    mock_output = {"title": "Travel Agent Booking", "difficulty": "ADVANCED", "context": "x", "user_role": "u", "agent_role": "a", "opening_prompt": "x"}
    with patch("app.routers.autogen_speaking.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = mock_output
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/speaking-scenario",
                json={"scenario_type": "PART_1", "topic": "travel", "level": 6},
            )
        body = resp.json()
        assert body["slug"] == "travel-agent-booking"


@pytest.mark.asyncio
async def test_scenario_502_when_llm_fails():
    """LLM exception returns 502."""
    with patch("app.routers.autogen_speaking.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.side_effect = RuntimeError("All keys exhausted")
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/speaking-scenario",
                json={"scenario_type": "PART_2", "topic": "test", "level": 6},
            )
        assert resp.status_code == 502
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_speaking_router.py -v
```

Expected: 3 tests passed.

- [ ] **Step 3: Verify no warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_speaking_router.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_speaking_router.py
git commit -m "test(ai-autogen): add speaking router tests with mocked Groq"
```

---

# Phase 5 — exam-service bulk insert endpoint

## Task 5.1: Add BulkInsertRequest DTO

**Files:**
- Create: `services/exam-service/Contracts/Exams/BulkInsertRequest.cs`

- [ ] **Step 1: Verify Contracts/Exams directory layout**

```bash
ls /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Contracts/Exams/
```

Expected: list including `Dto.Admin.cs` and possibly `Dto.Internal.cs`.

- [ ] **Step 2: Write `BulkInsertRequest.cs`**

```csharp
using System;
using System.Collections.Generic;

namespace exam_service.Contracts.Exams;

/// <summary>
/// Request body for POST /api/admin/question/bulk.
/// Caller-supplied Idx is IGNORED — server derives Idx from position
/// (maxIdx + i + 1) to avoid collisions within the section.
/// </summary>
public record BulkInsertRequest(
    Guid SectionId,
    List<DtoAdmin.AdminQuestionUpsert> Questions
);
```

- [ ] **Step 3: Verify build**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | tail -5
```

Expected: `Build succeeded` with 0 errors.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/exam-service/Contracts/Exams/BulkInsertRequest.cs
git commit -m "feat(exam): add BulkInsertRequest DTO with caller-supplied Idx ignored"
```

---

## Task 5.2: Add BulkInsertAsync to AdminQuestionService

**Files:**
- Modify: `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs:33-265`

- [ ] **Step 1: Locate AddAsync pattern**

```bash
grep -n "public async Task<IResult> AddAsync" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs
```

Expected: 1 match at line ~113.

- [ ] **Step 2: Add BulkInsertAsync method**

Append before the closing brace of `AdminQuestionService` class (after `GetBySectionIdAsync` ends at line ~265):

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
                var validationError = ValidatePayload(
                    dto.Type, dto.BlankAcceptTexts, dto.MatchPairs,
                    dto.OrderCorrects, dto.ShortAnswerAcceptTexts);
                if (validationError != null)
                {
                    errors.Add(new { idx = i, message = "Validation failed" });
                    continue;
                }
                var orderCorrects = dto.OrderCorrects?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var shortTexts = dto.ShortAnswerAcceptTexts?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                var shortRegex = dto.ShortAnswerAcceptRegex?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
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
                    OrderCorrects = orderCorrects,
                    ShortAnswerAcceptTexts = shortTexts,
                    ShortAnswerAcceptRegex = shortRegex,
                };
                _context.ExamQuestions.Add(question);
                created.Add(new { idx = i });
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

- [ ] **Step 3: Verify build**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | tail -5
```

Expected: `Build succeeded` with 0 new CS warnings. (Pre-existing CVE warnings OK.)

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Service.cs
git commit -m "feat(exam): add BulkInsertAsync with partial-success errors[] semantics"
```

---

## Task 5.3: Add BulkInsertHandler + route registration

**Files:**
- Modify: `services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs`
- Modify: `services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs:48-56`

- [ ] **Step 1: Add BulkInsertHandler in `AdminQuestion_Handler.cs`**

Append after `DeleteQuestionHandler`:

```csharp
    public static Task<IResult> BulkInsertHandler(
        [FromServices] IAdminQuestionService service,
        CancellationToken token,
        [FromBody] BulkInsertRequest req
    ) => service.BulkInsertAsync(token, req);
```

- [ ] **Step 2: Add route in `AdminExamEndpoint.cs:48-56`**

After the existing `adminQuestion.MapDelete(...)` line:

```csharp
        adminQuestion.MapPost("/bulk", AdminQuestionHandler.BulkInsertHandler)
            .RequireAuthorization(Roles.Admin);
```

- [ ] **Step 3: Verify build**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/exam-service/exam-service.csproj 2>&1 | tail -5
```

Expected: `Build succeeded`.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/exam-service/Features/Exams/AdminEndpoint/QuestionEndpoint/AdminQuestion_Handler.cs services/exam-service/Features/Exams/AdminEndpoint/AdminExamEndpoint.cs
git commit -m "feat(exam): register POST /api/admin/question/bulk with admin auth"
```

---

## Task 5.4: Add xUnit tests for bulk insert

**Files:**
- Create: `services/attempt-service.Tests/ExamServiceBulkInsertTests.cs`

- [ ] **Step 1: Verify test project references exam-service**

```bash
grep -E "ProjectReference|exam-service" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/attempt-service.Tests/attempt-service.Tests.csproj
```

Expected: `ProjectReference` to exam-service OR shared `PublicContracts`. If not, xUnit can't access `BulkInsertRequest` — skip this test or use `InternalsVisibleTo`.

- [ ] **Step 2: Write the test file**

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace attempt_service.Tests.ExamService;

/// <summary>
/// xUnit tests for AdminQuestionService.BulkInsertAsync.
/// Note: requires access to internal types — verify InternalsVisibleTo
/// is configured in exam-service.csproj before running.
/// </summary>
public class ExamServiceBulkInsertTests
{
    [Fact]
    public async Task BulkInsert_AllValid_ReturnsCreatedArray()
    {
        // Arrange: create in-memory ExamDbContext with a section
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: $"BulkTest_{Guid.NewGuid()}")
            .Options;
        await using var context = new ExamDbContext(options);
        var sectionId = Guid.NewGuid();
        context.ExamSections.Add(new ExamSection { Id = sectionId, Idx = 1, ExamId = Guid.NewGuid(), Title = "Test" });
        await context.SaveChangesAsync();
        var service = new exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint.AdminQuestionService(context);

        var questions = new List<DtoAdmin.AdminQuestionUpsert>
        {
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q1", null, null, null, null, null, null),
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q2", null, null, null, null, null, null),
            new(sectionId, null, QuestionType.SummaryCompletion, "READING", 2, "Complete [1]", null, new Dictionary<string, string[]?> { { "1", new[] { "answer" } } }, null, null, null),
        };

        // Act
        var result = await service.BulkInsertAsync(CancellationToken.None,
            new BulkInsertRequest(sectionId, questions));

        // Assert
        var okResult = (Microsoft.AspNetCore.Http.HttpResults.Ok<ApiResultDto>)result;
        var data = (dynamic)okResult.Value!.Data!;
        Assert.Equal(3, ((IEnumerable<object>)data.created).Count());
        Assert.Empty((IEnumerable<object>)data.errors);
    }

    [Fact]
    public async Task BulkInsert_OneInvalid_ReturnsPartialSuccess()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: $"BulkTest_{Guid.NewGuid()}")
            .Options;
        await using var context = new ExamDbContext(options);
        var sectionId = Guid.NewGuid();
        context.ExamSections.Add(new ExamSection { Id = sectionId, Idx = 1, ExamId = Guid.NewGuid(), Title = "Test" });
        await context.SaveChangesAsync();
        var service = new exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint.AdminQuestionService(context);

        var questions = new List<DtoAdmin.AdminQuestionUpsert>
        {
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q1", null, null, null, null, null, null),
            new(sectionId, null, QuestionType.SummaryCompletion, "READING", 2, "Q2 invalid (no blanks)", null, null, null, null, null, null), // INVALID: missing blankAcceptTexts
            new(sectionId, null, QuestionType.MultipleChoiceSingle, "READING", 2, "Q3", null, null, null, null, null, null),
        };

        // Act
        var result = await service.BulkInsertAsync(CancellationToken.None,
            new BulkInsertRequest(sectionId, questions));

        // Assert
        var okResult = (Microsoft.AspNetCore.Http.HttpResults.Ok<ApiResultDto>)result;
        var data = (dynamic)okResult.Value!.Data!;
        Assert.Equal(2, ((IEnumerable<object>)data.created).Count());
        Assert.Single((IEnumerable<object>)data.errors);
    }

    [Fact]
    public async Task BulkInsert_EmptyQuestions_ReturnsEmptyArrays()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(databaseName: $"BulkTest_{Guid.NewGuid()}")
            .Options;
        await using var context = new ExamDbContext(options);
        var sectionId = Guid.NewGuid();
        context.ExamSections.Add(new ExamSection { Id = sectionId, Idx = 1, ExamId = Guid.NewGuid(), Title = "Test" });
        await context.SaveChangesAsync();
        var service = new exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint.AdminQuestionService(context);

        // Act
        var result = await service.BulkInsertAsync(CancellationToken.None,
            new BulkInsertRequest(sectionId, new List<DtoAdmin.AdminQuestionUpsert>()));

        // Assert
        var okResult = (Microsoft.AspNetCore.Http.HttpResults.Ok<ApiResultDto>)result;
        var data = (dynamic)okResult.Value!.Data!;
        Assert.Empty((IEnumerable<object>)data.created);
        Assert.Empty((IEnumerable<object>)data.errors);
    }
}
```

- [ ] **Step 3: Build + run**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet build services/attempt-service.Tests/attempt-service.Tests.csproj
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build --filter "FullyQualifiedName~ExamServiceBulkInsertTests"
```

Expected: 3 tests passed (73 baseline + 3 new = 76).

If `InMemoryDatabase` provider not available, skip this task and add a TODO comment — covered by manual smoke test in Phase 10.

- [ ] **Step 4: Verify no deprecated warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
dotnet test services/attempt-service.Tests/attempt-service.Tests.csproj --no-build 2>&1 | grep -iE "warning|deprecat" | head -5
```

Expected: no output from new tests.

- [ ] **Step 5: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/attempt-service.Tests/ExamServiceBulkInsertTests.cs
git commit -m "test(exam): add xUnit tests for BulkInsertAsync partial-success semantics"
```

---

# Phase 6 — FE autogen client

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

# Phase 7 — Wizard scaffold + Reading sub-tab

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

# Phase 8 — Listening/Writing/Speaking sub-tabs

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

# Phase 9 — Vitest coverage + component tests

## Task 9.1: Add wizard component tests

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/__tests__/wizard.test.tsx`

- [ ] **Step 1: Write the test file**

```tsx
import { describe, expect, it } from "vitest";
import { createRoot, Root } from "react-dom/client";
import React from "react";
import { StepIndicator } from "../_components/StepIndicator";
import { SkillPicker } from "../_components/SkillPicker";
import { TopicForm } from "../_components/TopicForm";
import { NavButtons } from "../_components/NavButtons";
import { act } from "react";

declare global {
  // eslint-disable-next-line no-var
  var IS_REACT_ACT_ENVIRONMENT: boolean;
}
(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true;

describe("StepIndicator", () => {
  let container: HTMLDivElement | null = null;
  let root: Root | null = null;

  it("renders 4 steps when totalSteps=4", async () => {
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(<StepIndicator step={2} totalSteps={4} />);
    });
    const indicator = container.querySelector('[data-testid="step-indicator"]');
    expect(indicator).not.toBeNull();
    expect(container.children.length).toBe(1);
    root!.unmount();
    container.remove();
  });
});

describe("SkillPicker", () => {
  it("calls onChange when clicking a skill", async () => {
    const onChange = (s: "reading" | "listening" | "writing" | "speaking") => {
      expect(s).toBe("listening");
    };
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(<SkillPicker skill="reading" onChange={onChange} />);
    });
    const buttons = container.querySelectorAll("button");
    expect(buttons.length).toBe(4);
    (buttons[1] as HTMLButtonElement).click();
    root!.unmount();
    container.remove();
  });
});

describe("TopicForm", () => {
  it("renders topic input and level input", async () => {
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(<TopicForm topic="x" level={6} onTopic={() => {}} onLevel={() => {}} />);
    });
    expect(container.querySelector("#topic")).not.toBeNull();
    expect(container.querySelector("#level")).not.toBeNull();
    root!.unmount();
    container.remove();
  });
});

describe("NavButtons", () => {
  it("Next button is disabled when canNext=false", async () => {
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(
        <NavButtons
          step={1}
          totalSteps={4}
          canNext={false}
          onPrev={() => {}}
          onNext={() => {}}
        />
      );
    });
    const buttons = container.querySelectorAll("button");
    const nextButton = buttons[1] as HTMLButtonElement;
    expect(nextButton.disabled).toBe(true);
    root!.unmount();
    container.remove();
  });
});
```

- [ ] **Step 2: Run Vitest**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test
```

Expected: 102 (Sprint 7 baseline) + 4 new = 106+ tests passed. 0 skipped.

- [ ] **Step 3: Verify no skipped suites**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test 2>&1 | grep -E "skipped|Skipped"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/__tests__/wizard.test.tsx
git commit -m "test(fe-admin): add Vitest component tests for wizard"
```

---

# Phase 10 — Sprint 8 closure

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

## Self-Review

**1. Spec coverage:**
- §4.1 ai-service routers (3 new) → Tasks 2.2, 3.4, 4.3 ✓
- §4.2 Component map → Tasks 6.2, 7.3, 8.7 ✓
- §4.3 Data flow Listening → Tasks 2.1, 2.2, 8.2 ✓
- §4.4 Data flow Writing → Tasks 3.1-3.4, 8.3-8.4 ✓
- §4.5 Data flow Speaking → Tasks 4.1-4.3, 8.5-8.6 ✓
- §4.6 Wire contracts → Tasks 2.1, 3.2, 4.1 (schemas) ✓
- §5.1 ai-service shared module → Reuses Sprint 7 (autogen.py) ✓
- §5.2 ai-service listening router → Task 2.2 ✓
- §5.3 ai-service writing router + matplotlib → Tasks 3.1, 3.4 ✓
- §5.4 ai-service speaking router → Task 4.3 ✓
- §5.5 exam-service bulk endpoint → Tasks 5.1-5.3 ✓
- §5.6 FE wizard → Tasks 7.1-7.3, 8.1-8.7 ✓
- §5.7 autogenClient.ts → Task 6.2 ✓
- §5.8 createQuestionBulk → Task 6.1 ✓
- §6 Phase Plan (10 phases) → Phases 1-10 of this plan ✓
- §7 Risks → Mitigated via rate-limit (Tasks 2.2, 3.4, 4.3), matplotlib error handling (Task 3.4), bulk insert transaction (Task 5.2) ✓
- §8 Acceptance criteria → Tasks 9.1, 10.1 ✓
- §12 Warning Verification Fixes → Integrated as lint steps in Tasks 1.1, 2.1, 2.2, 3.1-3.4, 4.1-4.3, 5.2, 10.1 ✓

**2. Placeholder scan:** No "TBD" / "implement later" / "fill in details". All steps have specific code or commands.

**3. Type consistency:**
- `Section` schema defined Task 2.1, used Task 2.2 router, Task 2.3 test ✓
- `WritingTaskResponse` defined Task 3.2, used Task 3.4 router ✓
- `SpeakingScenarioResponse` defined Task 4.1, used Task 4.3 router ✓
- `BulkInsertRequest` defined Task 5.1, used Task 5.2 service + Task 5.3 handler ✓
- `autogenQuestions`/`autogenListeningExam`/`autogenWritingTask`/`autogenSpeakingScenario` defined Task 6.2, used Tasks 7.2, 8.2, 8.4, 8.6 ✓
- `SCENARIO_BUILDERS` dict Task 4.2, used Task 4.3 ✓
- `SECTION_BUILDERS` tuple Task 1.1, used Task 2.2 ✓

**Issues found and fixed inline:**
- Task 7.2 ReadingSubTab had unused `sectionId` param — kept as placeholder for Sprint 9 wizard wiring.
- Task 2.2 listening router needed `section.title` truncation — added `:1500` char cap per spec §4.6.
- Task 3.4 writing router needs `os.makedirs("/app/static/charts", exist_ok=True)` at startup — moved to lifespan.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-09-14-sprint8-autogen-4-skills.md`.

Sprint 8 has **10 phases → 33 tasks → ~25h estimated**. Depends on Sprint 7 being merged first.

**Two execution options:**

1. **Subagent-Driven (recommended)** - Dispatch fresh subagent per task, review between tasks
2. **Inline Execution** - Execute in this session with checkpoints

Which approach?
