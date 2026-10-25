# Section 1 offline regression follow-up — BLOCKED

Follow-up to [`SECTION1_OFFLINE_BLOCKER_CLOSURE.md`](SECTION1_OFFLINE_BLOCKER_CLOSURE.md).

- Starting HEAD: `575c7d6c9d12eb43c26f7866ec3754cfb1673f5b`
- Focused source commit: `f7660a3a6a7ae99de7d7b3a5513712d492fe9c5d`
- Tested source: `f7660a3a6a7ae99de7d7b3a5513712d492fe9c5d`
- Final readiness verdict: **BLOCKED**
- LIVE/provider calls, deployment, publication, and shared-database operations: **none**.

## Reproduction and correction

The safe Python 3.14 suite reproduced 98 failures before the change. The previously unresolved `test_08_not_given_contradicted_by_passage_is_rejected` case showed a real evaluator gap: a positive assertion that bronze casting predated iron tools was not rejected against a passage explicitly saying there was “no evidence of bronze casting predating iron tools.” The production detector recognized several negation forms but did not recognize scoped “no evidence of/for” statements.

`services/generation-service/app/evaluators/semantic.py` now flags that pattern only when the candidate makes an affirmative existence assertion and at least two normalized substantive terms overlap the absent proposition. The existing end-to-end regression now passes. This does not infer or synthesize a correct FALSE answer; it rejects the invalid NOT_GIVEN classification.

## Verification

Commands ran from `services/generation-service/` with `tests/offline_support` on `PYTHONPATH`:

- Focused Section 1, authority, gateway, recovery and budget regressions plus the corrected contradiction case: **78 passed**.
- Full safe Python 3.14 suite, excluding the two PostgreSQL modules whose fixtures can target the shared exam database: **1,906 passed, 97 failed, 17 skipped** (4m03s). The prior matched report had 1,905 passed / 98 failed among 2,003 executed cases; this rerun did not use its seeded UUID run identity, so it is not claimed as an identical-identity baseline comparison. Seven skips differ because the PostgreSQL modules were explicitly excluded here.
- `git diff --check`: passed. The test-generated tracked `canonical_40_question_acceptance_bundle.json` was restored to its original committed bytes.

The 97 failures remain release blockers; their node IDs and recorded evidence are in the verification manifest. No tests were removed, skipped, xfailed or had expectations relaxed. Python 3.12 full-suite execution was not available in this continuation. The preceding verified report records 12 collection errors due to offline-missing `jsonschema` and `rpds` dependencies; no dependencies were fetched. The 3.12 targeted result in that report is historical, not a fresh run at this source SHA.

## PostgreSQL and recovery evidence

No target 13-question PostgreSQL acceptance or restart test was executed. A read-only Docker inspection confirmed the dedicated `langfens-closure-postgres` container has the `purpose=section1-offline-closure` label and `POSTGRES_DB=section1_closure`; this is environment identification only, not database or acceptance evidence. No exam-service integration fixtures were run because their guides warn about destructive/shared-database risks and this session did not establish an isolated, production-equivalent service boundary.

The focused in-memory recovery regressions passed, including fail-closed behavior for unresolved `UNKNOWN_OUTCOME`/`RESERVED` provider children. General typed durable recovery of orphan wrappers and known terminal child outcomes is still incomplete/unproven. There is no positive PostgreSQL recovery matrix, no competing-worker/epoch-fencing matrix at the target Section level, and no restart-survival or idempotent 13Q proof. Recovery remains **not accepted**; uncertain operations must stay blocked and must not be redispatched.

The earlier offline in-memory 13/13 and 78 evaluator result is unchanged historical evidence only; it is not durable PostgreSQL acceptance. Budget evidence remains deterministic/mock-only. Real provider usage and cost are **0 calls / 0 tokens / $0**; no actual target budget reconciliation was performed here.

## Files and remaining gates

Source change: `services/generation-service/app/evaluators/semantic.py` only. This follow-up report records the verification. No production database, immutable snapshot, submission marker, budget cap, provider route, or acceptance contract was changed.

Still required before any separately authorized LIVE consideration: adjudicate and resolve the remaining 97 suite failures; restore and run the complete Python 3.12 suite with already-approved offline dependencies; run relevant .NET/PostgreSQL contracts only against a proven disposable isolated database; complete actual PostgreSQL-backed 13Q acceptance, all 78 durable evaluator results, restart/re-entry proof, invalid-evidence rollback tests, and positive/negative durable recovery crash matrices; then freeze source and generate matching reproducible manifests. None of these gates is certified by this follow-up.

**Verdict: BLOCKED.**
