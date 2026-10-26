# Blocked-gate debugging follow-up

Debug performed from `809090a` without provider calls, dependency downloads, LIVE requests, deployments or publication. This report separates the Python runtime blocker from NuGet advisories discovered by a solution-wide audit.

## Root cause: Python 3.12 collection

Reproduced with a cached Python 3.12 image, `--network none`, and the actual pure-Python dependencies/native-extension directory mounted read-only. Import trace:

`jsonschema 4.26.0` → `referencing 0.37.0` → `from rpds import ...` → `rpds/__init__.py` → `ModuleNotFoundError: No module named 'rpds.rpds'`.

The `rpds` package present in the mounted CPython 3.14 environment contains `rpds.cpython-314-x86_64-linux-gnu.so`; CPython 3.12 cannot load it. Cache inspection found no CPython 3.12 `rpds-py` wheel or source distribution, and no local Cargo source/build closure. This is an external artifact prerequisite, not a failing validator or production defect. Provide a genuine CPython 3.12 Linux x86_64 wheel satisfying `rpds-py>=0.25.0`, or the source plus complete offline Rust/PyO3 dependencies. Then install in an isolated Python 3.12 environment and rerun the full suite. The recorded 2,101-pass/12-collection-error run remains non-green; no tests were omitted to disguise it.

## NuGet advisories: fixes with verified local artifacts

A NuGet vulnerability database was already cached locally. Its affected ranges and locally cached package artifacts established these single-change hypotheses:

- Microsoft.OpenApi GHSA-v5pm-xwqc-g5wc includes `[2.0.0-preview.11, 2.7.4]`; cached 2.7.5 is outside the affected range. Swashbuckle 10.1.7 requests Microsoft.OpenApi 2.4.1, and all affected services reference `Shared.Bootstrap`. Added a direct 2.7.5 reference in `services/_shared/Shared.Bootstrap/Shared.Bootstrap.csproj`.
- OpenTelemetry exporter GHSA-4625-4j76-fww9 includes `[1.8.0, 1.15.2]`; OpenTelemetry.Api GHSA-g94r-2vxg-569j includes versions below 1.15.3. Cached OpenTelemetry exporter 1.15.3 depends on OpenTelemetry 1.15.3/API 1.15.3. Updated the exporter reference in `services/_shared/Shared.ServiceDefaults/Shared.ServiceDefaults.csproj` to 1.15.3.

The solution restored from the local NuGet package cache only. The affected packages now resolve to Microsoft.OpenApi 2.7.5, exporter 1.15.3 and API 1.15.3. The solution-wide audit no longer reports those three advisories. Full solution build passed (0 errors). Current-tree Section 1 PostgreSQL integration plus policy/operation authority contracts passed: 13 passed, 0 failed. This is a dependency fix, not a claim of a full repeated 13Q crash/restart matrix.

## Broader solution audit: remaining security blockers

The solution-wide audit exposed independent findings beyond the originally named Microsoft.OpenApi/OpenTelemetry advisories:

- Email service: System.Security.Cryptography.Pkcs 10.0.0, GHSA-846f-f764-76mx and GHSA-2fmv-rv2c-59x7; cached advisory range includes `[10.0.0, 10.0.12]`. No fixed Pkcs package (greater than 10.0.12) was available in the local NuGet cache; no upgrade attempted.
- Writing service: AutoMapper 12.0.1, GHSA-rvv3-g6hj-g44x; cached range marks all versions below 15.1.1 affected. No fixed AutoMapper artifact was available locally; no upgrade attempted.
- AppHost: MessagePack 2.5.192 had multiple audit findings. The local advisory cache marks the reported older ranges affected through 2.5.301, and 2.5.302 was available, so AppHost now pins 2.5.302. A subsequent solution audit still reports GHSA-qhrr-8q5h-9q3h at 2.5.302; that advisory's range/fixed version is absent from the inspected local vulnerability database. Do not treat this pin as clean. Obtain trusted current advisory data and a fixed offline package before resolving it.

Existing Swagger paths are registered via `UseSwagger`/`UseSwaggerUI`; route exposure/auth depends on each service's runtime configuration and remains an operational review item. OpenTelemetry instrumentation is registered, but the shared exporter-registration method currently does nothing; the vulnerable exporter was a dependency finding, and the package upgrade removes it from the affected range. No LIVE telemetry credentials were used.

## Online-authorized follow-through — resolved at `70bd314`

After the operator authorized online dependency retrieval, the following focused changes were made and tested:

- Added `jsonschema>=4.26.0` to `requirements-dev.txt`, making the schema-test dependency explicit. Installed the genuine `rpds-py 2026.9.1` CPython 3.12 wheel from PyPI; SHA-256 `addeda51556dac7c1a2f14cda62db8b621cd12afba3091d03a96c72932387eab`. The full isolated Python 3.12.15 environment installed from `requirements-dev.txt` and passed without using host CPython 3.14 packages. The local ignored wheel cache now also has this verified wheel.
- Updated `System.Security.Cryptography.Pkcs` to 10.0.14 (patched beyond 10.0.12); updated `MessagePack` to 2.5.307 (patched beyond 2.5.303); removed the unused AutoMapper DI package after repository-wide usage search found no source references. Microsoft.OpenApi 2.7.5 and OpenTelemetry exporter/API 1.15.3 remain on fixed versions.
- NuGet's online advisory audit after restore reports **no vulnerable packages** in any solution project.

Verification at implementation SHA `70bd31440f32a249c0cd0cefe31e749e2c950b39`:

- Python 3.12.15 isolated venv: **2,157 passed, 0 failed, 0 collection errors, 24 existing skips**.
- Python 3.14.8: **2,157 passed, 0 failed, 24 existing skips**. The same 2,181 test IDs and pass/skip outcomes occurred in both runtimes.
- Full .NET solution build: **0 errors**. NuGet audit: no vulnerable packages.
- Five PostgreSQL crash boundaries (accepted, generation, evaluation, repair, finalization): **55/55 .NET tests passed per boundary**; each produced 13 accepted heads, 78/78 mandatory evaluator PASS, and zero unresolved successful operations. Standard runs used 40 scripted calls/68,366 mock tokens; repair used 42/70,366. Fresh-host/database restart verification passed for accepted and repair; no redispatch occurred.
- All Python suites exclude only the unsafe legacy `test_t09_real_postgres_durability.py` module; the isolated real PostgreSQL pipeline and recovery contracts are separately exercised above. The 24 skips are the existing optional skips, not newly added skips.

The original “blocked” findings above describe the state before online authorization. The release blockers addressed here are resolved. Full manifests and JUnit/TRX evidence are in `reports/section1_autonomous_resolution/online_release_verification_70bd314.json` and adjacent `*online*70bd314*` files. No provider/LIVE calls, deployment or publication occurred. The separately authorized LIVE acceptance remains a separate operator decision.
