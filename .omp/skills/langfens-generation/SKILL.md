---
name: langfens-generation
description: Develop Langfens generation-service with pinned R03/G06 caps, durable run authority, independent review, and consumer-compatible JSON/NDJSON contracts.
---

# Langfens generation workflow

Use for `services/generation-service`, its exam-service consumer, and runtime
budget changes. Reuse global `fastapi-patterns`, `python-testing`, and
`cost-aware-llm-pipeline`. Use `generation-loop-expert` for substantial loop work.

## Trace the real execution path

Read `app/router.py`, `app/facade.py`, the affected generators/evaluators/repair,
and `app/loop/`. Inspect `app/pipeline.py` when the affected route still uses it;
do not assume all requests execute one fixed four-phase pipeline.

- Internal routes are under `/v1/autogen/reading-paper` (also mounted with `/api`).
- Boundary models carry run IDs, lease owners, epochs, and artifact references.
- Routes require `X-Internal-Service-Key`; keys come from environment/configuration.
- Follow the relevant router's actual JSON or NDJSON contract and the
  exam-service consumer. Never invent event names from illustrative examples.
- Preserve independent answer review, authoritative artifact references/hashes,
  terminal failure outcomes, cancellation, and bounded retries already in scope.
- Ingestion must retain SSRF defenses and distinguish source/network failures
  from valid generated content.

## R03 / G06 runtime profile

`deploy/envs/loop-caps.env` governs approved deployment caps. Current loop and
benchmark-child ceilings are **15 calls / 60,000 tokens / 300 seconds**. They are
not universal limits for whole-paper runs or legacy/benchmark section stages;
read each named budget from the profile. Preserve configured 720–915 passage
word bounds and per-operation reservations.

Production configuration fails closed for missing or invalid required settings.
Each run pins its canonical sorted-JSON profile plus SHA-256 digest at creation.
A restart must keep that snapshot and accumulated counters, not rebind an
in-flight run to a wider deployment environment. Missing authoritative snapshots
must fail before model dispatch. Never loosen caps merely to make a test pass.

`generation_baseline/` is a separate target/research package. Its `RGxx` gates
are not the runtime G06 cap profile and do not prove shipped behavior. Read its
source-of-truth and evidence policy when the user explicitly requests that work;
preserve existing execution records and uncommitted evidence.

## Deterministic verification

Working directory: `services/generation-service`, with service dependencies and
`requirements-dev.txt` available in a service-local environment:

```bash
python -m pytest tests/test_extractor.py tests/test_prompts.py tests/test_pipeline.py
python -m pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py
```

Run the full service suite after focused checks for a code change. For cap
changes, also run relevant `R03CapsProfileTests` in `services/exam-service.Tests`
after inspecting fixture/database prerequisites. Do not invoke paid/live LLMs
without explicit scope. See `/skill:langfens-verify` for broader checks.
