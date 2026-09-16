# Phase 4 — Speaking router

> **Plan file:** This is Phase 4 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
