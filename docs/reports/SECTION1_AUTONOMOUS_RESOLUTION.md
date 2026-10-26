# Section 1 autonomous resolution: offline gates pass; Python 3.12 dependency gate remains blocked

**Tested source:** `12f17862cf6fccc106c8d3d82ee03458dfb8f3fe` (`autonomous-generation`).

No LIVE generation/provider requests, paid tokens, deployments or publication. Scripted provider results are workflow evidence, **not independent model-quality or LIVE acceptance**.

## Results

| Gate | Actual result |
|---|---|
| Python 3.14.8 guarded regression suite | **2,157 passed, 0 failed, 24 existing optional skips** |
| Python 3.12.15 offline execution with collection-error continuation | **2,101 passed, 0 failed, 24 existing optional skips, 12 collection errors** |
| Inspected .NET/PostgreSQL selection | **55 passed, 0 failed/skipped** for each of five crash scenarios; repeated cap tests are not distinct new cases |
| Fresh exam-host/generation processes after PostgreSQL restart | **1 passed** separately for the standard and repaired 13Q runs |
| Phase 14 real disposable-PostgreSQL producer | **1 passed**; Python subsequently replays its exact hash-checked exported event |
| PostgreSQL-backed Section 1 | **13/13 accepted heads, 78/78 current-head mandatory evaluator PASS, committed Section** in every positive scenario |

The Phase 14 replay input is preserved from the earlier isolated producer invocation (its recorded HEAD was `1a27aa4`, with uncommitted corrections). The real producer was independently rerun successfully at the final tested SHA; the archived pytest input was not silently replaced.

The broad Python command excludes only `test_t09_real_postgres_durability.py`, whose legacy autouse fixtures can target shared databases. Its exclusion is not counted as tested coverage. Actual current-pipeline PostgreSQL integration runs separately against the verified session-owned server. All skip names/reasons and collection-error names are recorded in the manifest/JUnit files. No new skip, xfail, deleted test gate or relaxed production validator was used to obtain these results.

The Python 3.12 run used `--continue-on-collection-errors` to finish every independent case. It is **not a full-suite PASS**: 56 schema-dependent cases could not collect. That run was at `2524ef5fc5aaaf25bb77e5ce34a511cbc7159137`; the subsequent commit changes only the separately invoked PostgreSQL driver, not production Python or collected pytest tests. Python 3.14 and all final PostgreSQL matrix/restart gates were rerun at the tested source above.

Evidence: [`verification.json`](../../reports/section1_autonomous_resolution/verification.json), [`postgres_acceptance.json`](../../reports/section1_autonomous_resolution/postgres_acceptance.json), and adjacent JUnit/TRX files. The manifest includes source/artifact hashes, exact failures/skips and database resource identity. Acceptance evidence was independently reconstructed from run-scoped PostgreSQL artifact rows and verified against immutable hashes, parent closure and evaluator target references.

## Investigation and corrections

The actual starting HEAD was `1a27aa4c`, not the historical `98216152`. Sixteen files were already modified. That work was preserved and tested, not reset. The first safe current-tree run reproduced **40 failures / 1,963 passes / 14 skips** with both legacy PostgreSQL modules excluded; a separate guarded R01 run reproduced three additional memory-contract failures. Historical 97-failure counts were not falsely attributed to this newer dirty checkout.

| Causal defect or demonstrated obsolete contract | Correction/proof |
|---|---|
| An initial custom-policy resume fabricated today's default policy hash; worker resume also reconstructed defaults and could replace the saved resource profile | Full execution policy/hash is pinned inside the existing canonical resource snapshot at all production run-creation sites. Resume reads that authority only; missing/corrupt policy requires explicit migration. Pinning cannot legitimize a corrupt resource hash. No schema migration or historical-row rewrite was performed. |
| Resume DTO omitted operation parent and section identities | Export both fields from PostgreSQL; integration compares every resumed operation against its durable row. |
| Default allocation creation increased saved ceilings with hardcoded floors | Honor the pinned values, including the 200-second passage and 800-second section limits. All persisted allocations must equal the approved shared profile. No global cap increase. |
| A completed evaluator operation could lack a separate evaluation row after crash | Recover its typed terminal result, bound to exact target/hash/parents/evaluator/version. Missing, malformed and conflicting outcomes remain rejected. |
| RESERVED GENERATE/EVALUATE/REPAIR wrappers stayed orphaned despite complete authoritative child responses | Rebuild only within an async-local replay-only scope. Gateway admits only the exact completed physical attempts and matching request hashes. New calls, unknown/missing responses and even swallowed dispatch errors stay fail-closed; wrapper uncertainty is not reconciled into fictitious zero-cost success. |
| Multiple evaluator diagnostics repeated the same M3/Text operation IDs after mutating the question | One regenerated candidate produces one immutable repair version, followed by mandatory evaluator reruns. Duplicate-diagnostic regression was observed red before correction. |
| Plural normalization missed the intended blinded uncertainty boundary | Preserve conservative singular/plural anchors; full semantic/calibration suites pass without editing frozen gold labels. |
| Fixtures lacked grants, durable methods, exact dependency parents or current claim bindings | Bring doubles and deterministic tasks into the verified production contracts. Preserve fencing, hash CAS, budget conservation and immutable old versions. |
| Retired stage endpoint tests expected removed routes and patched the wrong source seam | Assert retired routes remain 404 with zero dispatch; exercise current source ingestion/auth/provenance/license/SSRF controls via real code and controlled HTTP transport. |
| Tests relied on live credentials, external DNS, Git availability, missing historical campaign files or the working directory | Explicit live-smoke consent gate plus offline SDK transport tests; exact loopback-only CLI opt-in; controlled DNS (not a safety bypass); synthetic temporary campaign evidence with negative missing-evidence controls; controlled Git outputs; repository-anchored historical snapshot path. Historical meta-textual TFNG V3 remains rejected under the current factual-proposition contract. |

## PostgreSQL and recovery proof

The actual `ReadingGenerationPipeline` executes SourcePack → EvidenceGraph → Blueprint → Passage → Question → Section through real checkpoint HTTP endpoints and `CheckpointService`/PostgreSQL. The test host excludes production startup seeders/workers/brokers. The transport is scripted; the blueprint is authored at a pre-evaluation generator seam, never by mutating an accepted artifact. All normal validators and acceptance commits execute.

Five positive paths crash at:

1. accepted Q5 commit before its ACK;
2. GENERATE physical response committed, wrapper still RESERVED;
3. both EVALUATE child responses committed, wrapper still RESERVED;
4. M3 plan and Text-01 repair response committed, REPAIR wrapper still RESERVED;
5. Section finalization committed before its ACK.

Every path reaches 13 accepted questions and 78 fresh current-head PASS results with zero unresolved successful-path operations. Standard paths have **40 unique physical mock calls / 68,366 reported mock tokens**; the real M3/repair path has **42 / 70,366**, Q5 V2, one repair, and preserved immutable V1. Restart/re-entry introduces no new transport operation. All TABLE_COMPLETION headers/context, FLOW_CHART steps/index and TFNG answers survive persistence. Per-question standard accounting is 3 physical calls / 5,182 tokens; repaired Q5 is 5 / 7,182.

Separate negative cases prove insufficient admission, UNKNOWN_OUTCOME retention/no redispatch, stale-epoch grant/reconciliation rejection after actual lease takeover, and exactly one successful concurrent near-cap parent grant. Negative and failed investigative runs deliberately retain reservations/uncertainty in the disposable database; **zero unresolved refers to the successful paths, not every historical test run**.

A database container restart followed by fresh .NET host and generation processes reconstructs identical heads, operations, cursors, evaluations, dependencies and counters for both standard and repaired runs. Snapshot queries use explicit ordering; PostgreSQL row order is not treated as an invariant.

## Reproduction

From repository root, with existing offline dependencies:

```bash
python services/generation-service/tests/offline_support/run_section1_postgres.py \
  --create --evidence-dir "$HOME/.cache/section1-proof"
# The command prints the new labelled resource name. Reuse it explicitly:
python services/generation-service/tests/offline_support/run_section1_postgres.py \
  --resource <printed-resource> --evidence-dir "$HOME/.cache/section1-repair-proof" --crash-boundary repair
# Other boundaries: accepted, generation, evaluation, finalization.
docker restart <printed-resource>
python services/generation-service/tests/offline_support/run_section1_postgres.py \
  --resource <printed-resource> --evidence-dir "$HOME/.cache/section1-proof" --verify-restart
```

The runner requires exact matching container/network/volume ownership labels, an internal-only network, the dedicated database and explicit resolved endpoint before migrations. It never drops a schema, uses a shared server, invokes AppHost, downloads dependencies or cleans historical volumes. Cached PostgreSQL image only; .NET uses `--no-restore`.

For broad pytest, run from `services/generation-service` with `PYTHONPATH="$PWD/tests/offline_support:$PWD"`, `RUN_LIVE_PROVIDER_SMOKE=0`, and `PHASE14_OUTBOX_EVENT_FILE` set to the exported event (a copy is included in this evidence directory):

```bash
.venv/bin/python -m pytest tests/ --ignore=tests/test_t09_real_postgres_durability.py \
  -q --tb=short -o junit_family=legacy
```

Python 3.12 used cached image `eea0685d6d99`, `--pull=never --network none`, its native runtime dependencies, appended read-only host pure-Python pytest/schema packages, and `-p pytest_asyncio.plugin`. The only schema blocker is the incompatible/missing native `rpds` extension, not permission to omit or stub validators.

## Remaining external prerequisite and limits

**Irreducible offline prerequisite:** supply a genuine CPython 3.12-compatible `rpds-py` wheel/native extension, or the complete rpds/PyO3 offline source/build closure. The local `jsonschema`/`referencing` code imports `rpds.rpds`; only a CPython 3.14 extension is available. Inspection of local environments/caches and 115 cached AI/generation images found no compatible artifact. Existing Rust tools without their source/dependency closure cannot build it offline. No network installation or validator substitution was attempted. Every currently executable deterministic case is green; the twelve collection errors are retained as failures of the full target-runtime gate.

Existing NuGet Microsoft.OpenApi/OpenTelemetry security advisories remain reported, not remediated through unauthorized dependency downloads. The full destructive exam test project was not run. No historical production job was resumed and no migration of an existing job/policy snapshot is authorized by these tests.

Source commits: `66c1af8` (generation/recovery/regression corrections), `2524ef5` (policy authority, lineage and PostgreSQL integration), `12f1786` (concurrent parent admission proof). The initially dirty, test-generated `canonical_40_question_acceptance_bundle.json` was neither committed nor reset; historical reports/snapshots remain intact.

**Decision:** offline deterministic and PostgreSQL 13Q gates pass as scoped above; full Python 3.12 regression remains blocked on the exact offline native dependency. No production-ready/LIVE-quality declaration follows.
