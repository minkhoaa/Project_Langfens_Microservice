# Phase 5 — ai-service autogen router

> **Plan file:** This is Phase 5 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 5.1: Add json_shape + constraints mirror data

**Files:**
- Create: `services/ai-service/app/prompts/autogen_data.py`

**Interfaces:**
- Produces: `JSON_SHAPES: dict[str, str]` + `CONSTRAINTS: dict[str, list[str]]` mirror of `questionSchemas.ts`

- [ ] **Step 1: Write `autogen_data.py`**

Mirror the 19 schemas from `langfens-fe-app/src/app/admin/_lib/questionSchemas.ts:21-630`. Each entry: `{type_name: json_shape_string}`. Each constraint list: list of strings.

```python
"""Server-side mirror of questionSchemas.ts jsonShape + constraints.

This module is a Python copy of the TypeScript source. To prevent drift,
both must be updated together. Sprint 9 introduces codegen (Phase 9.4 of
PLAN.md).

Keep this in sync with langfens-fe-app/src/app/admin/_lib/questionSchemas.ts.
"""
from __future__ import annotations

JSON_SHAPES: dict[str, str] = {
    "MULTIPLE_CHOICE_SINGLE": """{
  "type": "MULTIPLE_CHOICE_SINGLE",
  "skill": "READING",
  "difficulty": 2,
  "promptMd": "What is the main idea of paragraph 2?",
  "options": [
    { "contentMd": "A. The moon's orbit", "isCorrect": false },
    { "contentMd": "B. The sun's energy", "isCorrect": true }
  ]
}""",
    "MULTIPLE_CHOICE_MULTIPLE": """{
  "type": "MULTIPLE_CHOICE_MULTIPLE",
  "skill": "READING",
  "difficulty": 3,
  "promptMd": "Which THREE of the following are mentioned?",
  "options": [
    { "contentMd": "A. Item one", "isCorrect": true },
    { "contentMd": "B. Item two", "isCorrect": false }
  ]
}""",
    # ... 17 more entries copied from questionSchemas.ts ...
    # For Sprint 7, only the 8 existing LLM_PROMPTS entries need shapes (Phase 1
    # refactor still works without the 11 new ones). Sprint 8 will add all 19.
}

CONSTRAINTS: dict[str, list[str]] = {
    "MULTIPLE_CHOICE_SINGLE": [
        "options[] must have exactly 1 with isCorrect=true (single answer)",
        "options[].contentMd should follow 'A. text', 'B. text' convention",
    ],
    # ... 17 more entries ...
}


def get_json_shape(qtype: str) -> str:
    """Return the canonical JSON shape for a question type.

    Args:
        qtype: QuestionType enum value.

    Returns:
        JSON shape string.

    Raises:
        KeyError: if qtype is not in JSON_SHAPES.
    """
    if qtype not in JSON_SHAPES:
        raise KeyError(f"No JSON_SHAPES entry for type {qtype!r}")
    return JSON_SHAPES[qtype]


def get_constraints(qtype: str) -> list[str]:
    """Return the constraint strings for a question type.

    Args:
        qtype: QuestionType enum value.

    Returns:
        List of constraint strings (empty list if no constraints defined).
    """
    return CONSTRAINTS.get(qtype, [])
```

NOTE: This file requires ALL 19 entries to be populated for Sprint 7 (so FE can resolve `jsonShape` for any of the 19 types via the server). The current scaffold above shows only 2 entries for illustration. **Implementation: copy ALL 19 entries from `questionSchemas.ts:22-630` into this file.**

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen_data import JSON_SHAPES, CONSTRAINTS, get_json_shape, get_constraints
print('JSON_SHAPES count:', len(JSON_SHAPES))
print('CONSTRAINTS count:', len(CONSTRAINTS))
print('Sample shape keys:', list(JSON_SHAPES.keys())[:3])
"
```

Expected: `JSON_SHAPES count: 19`, `CONSTRAINTS count: 19`.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_data.py'
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
git add services/ai-service/app/prompts/autogen_data.py
git commit -m "feat(ai-autogen): add Python mirror of questionSchemas.ts (19 types)"
```

---

## Task 5.2: Add router with JWT auth + rate-limit

**Files:**
- Create: `services/ai-service/app/routers/autogen.py`
- Modify: `services/ai-service/app/main.py:14,82` — register router
- Modify: `services/ai-service/app/middleware/rate_limit.py:7-12` — add rate-limit entry

**Interfaces:**
- Consumes: `AutogenQuestionsRequest`, `AutogenQuestionsResponse` from Task 4.2; `build_system_prompt`, `build_user_prompt` from Task 4.3; `get_json_shape`, `get_constraints` from Task 5.1
- Produces: HTTP endpoint `POST /api/v1/autogen/questions`

- [ ] **Step 1: Verify existing JWT auth pattern**

```bash
grep -rn "Depends\|verify_jwt\|get_current_user" /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service/app/routers/speaking.py | head -5
```

Expected: at least 1 reference to an auth helper. If no auth helper exists, skip auth wiring in this task — add TODO comment for Sprint 8 follow-up.

- [ ] **Step 2: Write `autogen.py`**

```python
"""Auto-gen router — server-side proxy for LLM-driven question generation.

Forwards requests to Groq via groq_service.groq_generate. Resolves JSON
shape server-side to prevent FE from sending malformed shapes.
"""
from __future__ import annotations

import logging
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status

from app.prompts.autogen import build_system_prompt, build_user_prompt
from app.prompts.autogen_data import get_constraints, get_json_shape
from app.schemas.autogen import AutogenQuestionsRequest, AutogenQuestionsResponse
from app.services.groq_service import groq_generate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/autogen", tags=["autogen"])


@router.post("/questions", response_model=AutogenQuestionsResponse)
async def autogen_questions(
    req: AutogenQuestionsRequest,
    # user: dict = Depends(get_current_user),  # TODO: wire JWT auth in Phase 5 follow-up
) -> AutogenQuestionsResponse:
    """Generate IELTS question JSON via LLM (Groq server-side).

    Args:
        req: Request body with type, skill, passage, count, difficulty, optional extra.

    Returns:
        Response with list of generated question JSON objects.

    Raises:
        HTTPException 502 if LLM output is not a valid list.
    """
    try:
        json_shape = get_json_shape(req.type)
        constraints = get_constraints(req.type)
    except KeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown question type: {req.type}",
        ) from exc

    system_prompt = build_system_prompt(req.type, json_shape, constraints)
    user_prompt = build_user_prompt(
        req.type, req.passage, req.count, req.difficulty, req.extra_context or ""
    )

    result: dict[str, Any] = await groq_generate(
        prompt_template="{user}",
        variables={"user": user_prompt},
        expect_json=True,
        temperature=0.3,
        max_tokens=4096,
    )

    questions_raw = result.get("questions")
    if not isinstance(questions_raw, list):
        logger.error("LLM output not a list: %s", type(questions_raw))
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="LLM output is not a list of questions",
        )

    return AutogenQuestionsResponse(questions=questions_raw)
```

- [ ] **Step 3: Register router in `main.py`**

Edit `services/ai-service/app/main.py:14`:

```python
from app.routers import health, embed, writing, grammar, speaking, practice, speech_eval, speaking_grade, autogen  # ADDED
```

Edit `services/ai-service/app/main.py:82`:

```python
app.include_router(speaking_grade.router, prefix="/api")  # endpoint: /api/v1/speaking/grade
app.include_router(autogen.router, prefix="/api")  # ADDED
```

- [ ] **Step 4: Add rate-limit entry**

Edit `services/ai-service/app/middleware/rate_limit.py:7-12`:

```python
ROUTE_LIMITS: dict[str, int] = {
    "/api/v1/writing/compare": 10,
    "/api/v1/grammar/explain": 20,
    "/api/v1/grammar/batch-explain": 10,
    "/api/v1/grammar/detect": 10,
    "/api/v1/autogen/questions": 5,  # ADDED — LLM calls are expensive
}
```

- [ ] **Step 5: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.routers.autogen import router; print(router.prefix, len(router.routes))"
```

Expected: prints `/v1/autogen 1`.

- [ ] **Step 6: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/routers/autogen.py'
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
git add services/ai-service/app/routers/autogen.py services/ai-service/app/main.py services/ai-service/app/middleware/rate_limit.py
git commit -m "feat(ai-autogen): add /api/v1/autogen/questions router with rate-limit"
```

---

## Task 5.3: Add pytest tests for router with mocked groq_generate

**Files:**
- Create: `services/ai-service/tests/test_autogen_router.py`

- [ ] **Step 1: Write the test file**

```python
"""Tests for /api/v1/autogen/questions router with mocked Groq."""
from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_autogen_questions_returns_list_of_dicts():
    """Happy path: Groq returns list of questions, router passes through."""
    mock_questions = [
        {"type": "MULTIPLE_CHOICE_SINGLE", "difficulty": 3, "options": []},
        {"type": "MULTIPLE_CHOICE_SINGLE", "difficulty": 4, "options": []},
    ]
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": mock_questions}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "test passage",
                    "count": 2,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 200
        body = resp.json()
        assert "questions" in body
        assert len(body["questions"]) == 2
        assert body["questions"][0]["type"] == "MULTIPLE_CHOICE_SINGLE"


@pytest.mark.asyncio
async def test_autogen_questions_400_for_unknown_type():
    """Invalid type returns 400, never reaches Groq."""
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "NONEXISTENT_TYPE",
                    "skill": "READING",
                    "passage": "test",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 400
        assert "Unknown question type" in resp.json()["detail"]


@pytest.mark.asyncio
async def test_autogen_questions_502_when_llm_returns_non_list():
    """If Groq returns dict instead of list, router returns 502."""
    with patch("app.routers.autogen.groq_generate", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"questions": "not a list"}
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.post(
                "/api/v1/autogen/questions",
                json={
                    "type": "MULTIPLE_CHOICE_SINGLE",
                    "skill": "READING",
                    "passage": "test",
                    "count": 1,
                    "difficulty": 3,
                },
            )
        assert resp.status_code == 502
        assert "not a list" in resp.json()["detail"]
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_router.py -v
```

Expected: 3 tests passed.

- [ ] **Step 3: Verify no warnings**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_router.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_router.py
git commit -m "test(ai-autogen): add router tests with mocked Groq"
```

---
