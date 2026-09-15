# Phase 1 — Listening prompt module

> **Plan file:** This is Phase 1 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

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
