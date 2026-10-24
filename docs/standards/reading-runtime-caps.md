# Reading runtime cap contract (R03 / G06)

Applies to `services/generation-service` and `services/exam-service`; changing one side requires compatibility tests on both.

## Deployment and admission

- `deploy/envs/loop-caps.env` declares the shared versioned production resource-cap profile. Compose includes it for both services; AppHost loads it with `WithComposeEnvFile("loop-caps")`. Do not duplicate resource caps in `ai.env`.
- Python Settings loads the repository cap profile, then an explicit `GENERATION_SERVICE_ENV_FILE` (or compatibility `AI_SERVICE_ENV_FILE`) override; absent that override, it also loads `ai.env`. Process environment takes precedence over dotenv values.
- Production requires every resource cap and explicit profile version/source. Missing required values must fail closed, never fall back to development class defaults.
- Counts, token/byte limits and seconds are positive 32-bit integers on both runtimes. Reject fractional/nonfinite values and inconsistent child/parent allocations. `READING_PAPER_*` allocations map explicitly to Python Settings fields.
- Loop, whole-paper, legacy and benchmark-child budgets are distinct; never apply a child ceiling indiscriminately to a paper. `LoopPolicy.from_settings()` carries the effective profile into loop composition. Passage generation uses its declared reservation; question composition must not substitute its own child limits. Read actual deployment values instead of copying examples into defaults.

## Durable run compatibility

- New .NET runs persist the full profile JSON/version/source/SHA-256 and budget ceilings. Both runtimes serialize sorted-key canonical UTF-8 JSON for integrity checks.
- Before the first loop cursor, Python uses the run's original profile, not a changed deployment profile. Saved cursors preserve the full loop policy and counters; new configuration affects only new runs.
- Missing/corrupt historical snapshots require pause/migration, never reconstruction from the current environment.
- Retain cumulative accounting, finite repairs, cancellation and lease/epoch fencing across resumes; historical uncapped campaign approval is not permission to remove per-request or runtime safeguards.

## Implementation and verification entry points

- Python: `services/generation-service/app/config.py` and `app/loop/` within that service.
- .NET: `services/exam-service/Features/ReadingPaper/ReadingPaperCapsProfile.cs` and checkpoint/run persistence.
- Python regressions (from `services/generation-service` in its existing venv): `python -m pytest tests/test_r03_config_caps.py tests/test_r03_runtime_caps.py tests/test_t06_loop_runtime.py`.
- .NET cap tests: `services/exam-service.Tests/R03CapsProfileTests.cs`; read that test directory's `AGENTS.md` before execution.
- Simulation and real-PostgreSQL diagnostics do not certify live model quality or promote G06. Report those gates separately.
