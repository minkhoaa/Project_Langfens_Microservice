# Phase 4 — ai-service prompt module mirror

> **Plan file:** This is Phase 4 of Sprint 7. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 4.1: Create shared templates constants

**Files:**
- Create: `services/ai-service/app/prompts/autogen_templates.py`

**Interfaces:**
- Produces: 3 module-level string constants — `SYSTEM_PREFIX`, `STRICT_JSON_SUFFIX`, `USER_PROMPT_TEMPLATE`

- [ ] **Step 1: Verify Python version**

```bash
python3 --version
```

Expected: 3.10.x or higher.

- [ ] **Step 2: Write `autogen_templates.py`**

```python
"""Shared prompt template constants for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
Keep in sync manually OR via codegen (future Sprint 9).
"""
from __future__ import annotations

SYSTEM_PREFIX: str = """You are an IELTS content author. Generate {type} questions following the D5 spec.

Constraints (per type):
- {constraints}

Required JSON shape:
```
{jsonShape}
```
"""

STRICT_JSON_SUFFIX: str = """
Strict JSON mode:
- Output ONLY a single JSON array (one item per question).
- No prose, no markdown fences outside the JSON block, no explanation.
- Each item MUST match the jsonShape above exactly.
- difficulty MUST be an integer in [1, 5].
- If the JSON cannot be produced, output {"error": "reason"} instead."""


def build_user_prompt_template(qtype: str) -> str:
    """Build the user prompt template for a given question type.

    Args:
        qtype: QuestionType enum value (e.g. "MULTIPLE_CHOICE_SINGLE").

    Returns:
        The user prompt template with {passage}, {count}, {difficulty},
        {extra} placeholders.
    """
    extra_line: str = "\\nExtra context: {extra}\\n"
    return (
        "Source passage:\\n\"\"\"\\n{passage}\\n\"\"\"\\n\\n"
        f"Generate {{count}} {qtype} question(s) at difficulty {{difficulty}}.{extra_line}\\n\\n"
        "Output: a JSON array of {count} item(s)."
    )
```

- [ ] **Step 3: Verify Python syntax**

```bash
python3 -c "from app.prompts.autogen_templates import SYSTEM_PREFIX, STRICT_JSON_SUFFIX, build_user_prompt_template; print(len(SYSTEM_PREFIX), len(STRICT_JSON_SUFFIX))"
```

Expected: prints 2 integers > 100.

- [ ] **Step 4: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen_templates.py'
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

Expected: no output (clean).

- [ ] **Step 5: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/app/prompts/autogen_templates.py
git commit -m "feat(ai-autogen): add prompt template constants (Python mirror)"
```

---

## Task 4.2: Add Pydantic schemas

**Files:**
- Create: `services/ai-service/app/schemas/autogen.py`

**Interfaces:**
- Produces: `AutogenQuestionsRequest`, `AutogenQuestionsResponse` Pydantic models

- [ ] **Step 1: Write `autogen.py`**

```python
"""Pydantic schemas for /api/v1/autogen/* endpoints."""
from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, Field


class AutogenQuestionsRequest(BaseModel):
    type: str = Field(..., description="QuestionType enum value, e.g. 'MULTIPLE_CHOICE_SINGLE'")
    skill: str = Field(..., description="READING|LISTENING|WRITING|SPEAKING")
    passage: str = Field(..., min_length=1, description="Source passage / material")
    count: int = Field(..., ge=1, le=10, description="Number of questions to generate")
    difficulty: int = Field(..., ge=1, le=5, description="Difficulty 1-5")
    extra_context: Optional[str] = Field(default=None, description="Optional extra context")


class AutogenQuestionsResponse(BaseModel):
    questions: list[dict] = Field(..., description="List of generated question JSON objects")
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "from app.schemas.autogen import AutogenQuestionsRequest, AutogenQuestionsResponse; r = AutogenQuestionsRequest(type='MCQ', skill='READING', passage='test', count=1, difficulty=3); print(r.dict())"
```

Expected: prints dict with type, skill, passage, count, difficulty, extra_context.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/schemas/autogen.py'
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
git add services/ai-service/app/schemas/autogen.py
git commit -m "feat(ai-autogen): add Pydantic schemas for autogen endpoints"
```

---

## Task 4.3: Create prompt builder module

**Files:**
- Create: `services/ai-service/app/prompts/autogen.py`

**Interfaces:**
- Consumes: `SYSTEM_PREFIX`, `STRICT_JSON_SUFFIX`, `build_user_prompt_template` from Task 4.1
- Produces:
  - `build_system_prompt(qtype: str, json_shape: str, constraints: list[str]) -> str`
  - `build_user_prompt(qtype: str, passage: str, count: int, difficulty: int, extra: str = "") -> str`

- [ ] **Step 1: Write `autogen.py`**

```python
"""Prompt builders for autogen endpoints.

Mirror of langfens-fe-app/src/app/admin/_lib/llmPromptBuilder.ts.
"""
from __future__ import annotations

from app.prompts.autogen_templates import (
    STRICT_JSON_SUFFIX,
    SYSTEM_PREFIX,
    build_user_prompt_template,
)


def build_system_prompt(qtype: str, json_shape: str, constraints: list[str]) -> str:
    """Build the system prompt for a given question type.

    Args:
        qtype: QuestionType enum value.
        json_shape: The canonical JSON shape string from questionSchemas.ts.
        constraints: List of constraint strings for this type.

    Returns:
        Complete system prompt (prefix + jsonShape + suffix).
    """
    return (
        SYSTEM_PREFIX
        .replace("{type}", qtype)
        .replace("{constraints}", "\\n- ".join(constraints))
        .replace("{jsonShape}", json_shape)
        + STRICT_JSON_SUFFIX
    )


def build_user_prompt(
    qtype: str,
    passage: str,
    count: int,
    difficulty: int,
    extra: str = "",
) -> str:
    """Build the user prompt for a given question type.

    Args:
        qtype: QuestionType enum value.
        passage: Source passage / material.
        count: Number of questions to generate (1-10).
        difficulty: Difficulty 1-5.
        extra: Optional extra context.

    Returns:
        Formatted user prompt string.
    """
    template = build_user_prompt_template(qtype)
    extra_line: str = f"\\nExtra context: {extra}\\n" if extra else ""
    return (
        template
        .replace("{passage}", passage)
        .replace("{count}", str(count))
        .replace("{difficulty}", str(difficulty))
        .replace("{extra}", extra)
        + (extra_line if extra else "")
    )
```

- [ ] **Step 2: Verify Python syntax**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
from app.prompts.autogen import build_system_prompt, build_user_prompt
s = build_system_prompt('MULTIPLE_CHOICE_SINGLE', '{\"type\":\"X\"}', ['options ≥ 2'])
u = build_user_prompt('MULTIPLE_CHOICE_SINGLE', 'passage text', 3, 3)
print('System length:', len(s))
print('User length:', len(u))
print('User contains passage:', 'passage text' in u)
"
```

Expected: 3 lines printed, all > 0.

- [ ] **Step 3: Run §12.2.1 lint script**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
python3 -c "
import ast
f = 'app/prompts/autogen.py'
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
git add services/ai-service/app/prompts/autogen.py
git commit -m "feat(ai-autogen): add prompt builder module"
```

---

## Task 4.4: Add pytest snapshot tests for prompt builder

**Files:**
- Create: `services/ai-service/tests/test_autogen_prompts.py`

- [ ] **Step 1: Write the test file**

```python
"""Snapshot tests for autogen prompt builders.

These tests ensure the prompt builder produces stable output across refactors.
Update snapshots only when prompt changes are intentional.
"""
from __future__ import annotations

import pytest

from app.prompts.autogen import build_system_prompt, build_user_prompt


@pytest.mark.parametrize(
    "qtype,json_shape,constraints",
    [
        ("MULTIPLE_CHOICE_SINGLE", '{"type":"X","options":[]}', ["options ≥ 2"]),
        ("SUMMARY_COMPLETION", '{"type":"X","blankAcceptTexts":{}}', ["blankAcceptTexts ≥ 1"]),
        ("FLOW_CHART", '{"type":"X","orderCorrects":[]}', ["orderCorrects ≥ 2"]),
    ],
)
def test_build_system_prompt_includes_required_sections(qtype, json_shape, constraints):
    prompt = build_system_prompt(qtype, json_shape, constraints)
    assert qtype in prompt
    assert json_shape in prompt
    assert "Strict JSON mode" in prompt
    assert "Output ONLY a single JSON array" in prompt


def test_build_system_prompt_includes_constraints():
    constraints = ["MCQ must have ≥ 2 options", "Exactly 1 isCorrect=true"]
    prompt = build_system_prompt("MULTIPLE_CHOICE_SINGLE", "{}", constraints)
    assert "MCQ must have ≥ 2 options" in prompt
    assert "Exactly 1 isCorrect=true" in prompt


def test_build_user_prompt_includes_passage_count_difficulty():
    prompt = build_user_prompt("MULTIPLE_CHOICE_SINGLE", "source text here", 3, 4)
    assert "source text here" in prompt
    assert "Generate 3 MULTIPLE_CHOICE_SINGLE question(s)" in prompt
    assert "at difficulty 4" in prompt


def test_build_user_prompt_includes_optional_extra():
    prompt = build_user_prompt(
        "MULTIPLE_CHOICE_SINGLE", "passage", 2, 3, extra="academic register"
    )
    assert "Extra context: academic register" in prompt


def test_build_user_prompt_omits_extra_when_empty():
    prompt = build_user_prompt("MULTIPLE_CHOICE_SINGLE", "passage", 2, 3)
    assert "Extra context" not in prompt
```

- [ ] **Step 2: Run pytest**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py -v
```

Expected: 5+ tests passed.

- [ ] **Step 3: Verify no DeprecationWarning**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice/services/ai-service
PYTHONPATH=. pytest tests/test_autogen_prompts.py -v 2>&1 | grep -iE "warning|deprecat"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/Project_Langfens_Microservice
git add services/ai-service/tests/test_autogen_prompts.py
git commit -m "test(ai-autogen): add pytest snapshot tests for prompt builder"
```

---
