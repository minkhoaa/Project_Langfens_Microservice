# Generation service
FastAPI autonomous Reading generation: source ingestion → grounded passages/questions → independent evaluation/repair.

- `app/router.py` exposes authenticated `/v1/autogen/reading-paper` (also `/api/...`); `POST /execute` enters `ReadingGenerationPipeline` in `app/pipeline.py`.
- Do not restore legacy `/section`, provider/stage/demo generation entry points; one production pipeline owns execution.
- Router authentication requires `X-Internal-Service-Key`; preserve fail-closed configuration and SSRF/license checks in `app/ingestion/`.
- `app/stage_executor.py`, `app/loop/`, `app/providers/` and `app/persistence/` own durable stages, budgets, provider dispatch and checkpoint APIs.
- All authoritative state commits go through exam-service's authenticated APIs; never write its database directly or reconstruct accepted heads from local state.
- Preserve lease/epoch fences, operation idempotency, cancellation, dependency closure and content-hash-bound fresh evaluations. Ambiguous provider outcomes must not trigger blind retries.
- Caps/resume changes require `../../docs/standards/reading-runtime-caps.md`; pinned runs retain original profile/counters, never new deployment defaults.
- Keep provider pinning/no-fallback for pinned experiments, bounded repair and real usage accounting; do not turn failures into zero-cost successes.
- Solver views exclude proposed/generated/gold answers and verdicts; answer verification follows blinded solve. Gold is restricted to research scoring.
- Research output is never publishable; evaluator ablations cannot bypass auth, source licensing, hashes, closure or fencing.
- For research/contract changes, read the relevant sections of `../../generation_baseline/SOURCE_OF_TRUTH.md` and its linked contract/research docs; these are requirements, not proof of deployed wire formats.
- Strict full-paper constraints must not be imposed on smaller research units; preserve configured passage bounds and route-specific source restrictions.
- Use Pydantic v2 boundaries, async I/O and offload blocking work; preserve source provenance rather than manufacturing evidence.
- From this directory in its existing venv: `python -m pytest tests/`; choose focused suites first and inspect integration/provider fixtures before running them.
- Cap regressions: `tests/test_r03_config_caps.py`, `tests/test_r03_runtime_caps.py`, `tests/test_t06_loop_runtime.py`.
- Offline workflow PASS does not certify live quality or promote G06.
