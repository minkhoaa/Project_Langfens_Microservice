# Phase 3 — Writing + matplotlib

> **Plan file:** This is Phase 3 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
