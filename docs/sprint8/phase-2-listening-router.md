# Phase 2 — Listening router

> **Plan file:** This is Phase 2 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
