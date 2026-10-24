# Generation service
FastAPI grounded Reading generation/evaluation/repair; `app/router.py` → `ReadingGenerationPipeline` in `app/pipeline.py`.

- Production executes only `/v1/autogen/reading-paper/execute` (also `/api/...`); do not revive legacy stage/provider/demo routes.
- `X-Internal-Service-Key` auth fails closed; preserve ingestion SSRF protection, licensing and source provenance.
- `app/stage_executor.py`, `app/loop/`, `app/providers/`, `app/persistence/` own durable execution; authoritative commits/accepted heads come only from exam-service APIs.
- Retain lease/epoch/CAS fencing, idempotency, cancellation and fresh content-hash-bound evaluations/dependency closure. Unknown provider outcomes require reconciliation, not blind redispatch.
- `deploy/envs/loop-caps.env` is shared with exam; settings then load `GENERATION_SERVICE_ENV_FILE` (legacy `AI_SERVICE_ENV_FILE`) or `ai.env`; process env wins.
- Production caps require explicit profile/version/source and positive 32-bit integer limits; distinguish loop/paper/legacy/benchmark-child budgets and passage reservations.
- Resume uses the saved profile/policy/counters, even before the first cursor; missing/corrupt snapshots pause for migration, never adopt current defaults.
- Preserve pinned-model/no-fallback behavior, bounded repair and real usage (unknown is not zero); unresolved BLOCKING issues prevent acceptance.
- Solver views exclude proposed/generated/gold answers and verdicts; verification follows blind solve. Gold is research-only; task invalidity blocks acceptance regardless of prose quality.
- Research can never publish; ablations cannot bypass auth/license/hash/closure/fencing. Admin publication and student redaction belong to exam-service.
- Strict full papers have 3 sections/40 continuous questions; smaller research units and configured passage bounds remain distinct. PMC's CC-BY/CC0 and ≥600-word rule is route-specific.
- For research/evaluator/contract work also read `../../generation_baseline/AGENTS.md`; preserve research/grammar tooling independently of the production pipeline.
- Local venv: `python -m pytest tests/` (inspect provider/integration fixtures first; prefer focused offline suites).
- Cap regressions: `python -m pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py`; also verify exam's `R03CapsProfileTests` with its test guide.
