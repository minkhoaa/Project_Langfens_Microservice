---
name: langfens-generation
description: Workflows for the IELTS reading paper generation loop, runtime caps verification (R03/G06), and streaming NDJSON endpoints.
---

# Autonomous Generation Pipeline Workflow

Use this skill when developing, testing, or diagnosing the IELTS reading paper generation service in `services/generation-service`.

## Pipeline Phases

```text
Source Text Ingestion (PMC, URL, HTML, Markdown)
        ↓
Phase 1: Passage Synthesis (720–915 words, authentic IELTS Academic style)
        ↓
Phase 2: Source Audit & Revision (strict fact-checking loop)
        ↓
Phase 3: Question Candidate Generation (6 canonical IELTS types)
        ↓
Phase 4: Adversarial Answer Review (independent solver validation)
        ↓
NDJSON Streaming Output to exam-service
```

## Runtime Caps (R03 / G06 Invariants)

Configuration lives in `deploy/envs/loop-caps.env`:
- Never run production paper generation with unbounded loops or missing caps.
- Caps must enforce:
  - Token limits: max 60,000 tokens per section loop child execution.
  - Timeout: max 300 seconds per generation phase.
  - Word count: strictly 720 to 915 words for reading passages.
- Run profiles are frozen with canonical UTF-8 JSON and verified via SHA-256 signatures.

## Running Tests

From `services/generation-service/`:
```bash
# Run unit tests (extractor, prompts, pipeline mocks)
pytest tests/test_extractor.py tests/test_prompts.py tests/test_pipeline.py

# Run caps and runtime invariant verification
pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py
```

## Streaming NDJSON Protocol

When invoking `POST /v1/autogen/reading-paper/section`:
- Header: `Accept: application/x-ndjson`
- Each newline-delimited JSON line contains generation events:
  - `{"type": "passage_token", "delta": "..."}`
  - `{"type": "phase_transition", "phase": "audit"}`
  - `{"type": "question_candidate", "item": {...}}`
  - `{"type": "complete", "result": {...}}`
- Workers in `exam-service` process stream chunks and persist state checkpoints.
