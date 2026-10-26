# Offline gates closed after operator-authorized online dependency retrieval

**Tested implementation SHA:** `70bd31440f32a249c0cd0cefe31e749e2c950b39` (`autonomous-generation`). **Decision:** `READY_FOR_SEPARATELY_AUTHORIZED_LIVE_ACCEPTANCE`. This is not authorization to run LIVE; no provider calls, deployment, or publication occurred.

## Fixes

- Declared `jsonschema>=4.26.0` in generation-service development requirements. Installed genuine `rpds-py 2026.9.1` CPython 3.12 wheel (`cp312`, manylinux x86_64; SHA-256 `addeda51556dac7c1a2f14cda62db8b621cd12afba3091d03a96c72932387eab`). Verified its native `HashTrieMap` import in CPython 3.12.15. The wheel is retained in the ignored local `services/generation-service/wheels/` cache; it is not vendored into Git.
- Upgraded Microsoft.OpenApi to 2.7.5, OpenTelemetry exporter/API to 1.15.3, Pkcs to 10.0.14, and MessagePack to 2.5.307. Removed the unused AutoMapper DI package after confirming there were no source references.

## Final verification

- **Python 3.12.15 isolated environment:** 2,157 passed, 0 failed, 0 collection errors, 24 existing skips.
- **Python 3.14.8:** 2,157 passed, 0 failed, 24 existing skips. Both runtimes had identical 2,181 test IDs, pass/skip outcomes, and skip reasons. The only excluded module is the unsafe legacy shared-DB `test_t09_real_postgres_durability.py`; its applicable pipeline/recovery gate was run separately against the owned PostgreSQL resource.
- **.NET 10:** full solution build succeeded with 0 errors. Current solution-wide NuGet audit reports no vulnerable packages.
- **PostgreSQL recovery matrix at the tested SHA:** accepted, generation, evaluation, repair, and finalization boundaries each passed 55/55 .NET tests; each produced 13 accepted heads and 78/78 mandatory evaluator PASS results, with zero unresolved successful-path operations. Accepted and repaired runs both survived database restart and fresh host/driver re-entry without new transport calls. The isolated PostgreSQL volume was preserved.
- The 24 skips are existing optional skips. No tests were removed, skipped, or weakened to obtain these results.

Exact JUnit/TRX hashes, package versions, fixture hash, resource identity and per-boundary acceptance details are in [`online_release_verification_70bd314.json`](../../reports/section1_autonomous_resolution/online_release_verification_70bd314.json). Detailed root-cause/fix history is in [`DEBUG_BLOCKED.md`](DEBUG_BLOCKED.md).
