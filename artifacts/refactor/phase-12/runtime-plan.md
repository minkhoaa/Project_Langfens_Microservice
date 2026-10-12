# Phase 12 runtime candidate plan — interim contract

This replaces the earlier speculative plan. It is not evidence of completed fixes or acceptance. Existing G11 artifacts/environment remain untouched; their faux-live report cannot be reused as live acceptance.

## Existing queue and authentication

- Route group: `/api/internal/reading-paper/checkpoints`, protected by `X-Internal-Service-Key` (`CheckpointService.cs:21`).
- `POST /campaigns`: `BenchmarkCampaignCreateRequest {campaignId, authorizationId, authorizedBy, corpusSha256, configSha256, budgetCapCalls, budgetCapTokens, budgetCapWallTimeSeconds}`. MiniMax benchmark caps must be explicit `-1` at campaign and child run; production stays 15/60000/300.
- `POST /campaigns/cases/provision`: current `BenchmarkCaseProvisionRequest {campaignId, caseId, claimId, leaseOwner}` (`Contracts/CheckpointContracts.cs:269-274`), handled by `BenchmarkCampaignService.ProvisionCaseAsync` (`BenchmarkCampaignService.cs:71-237`). It persists the existing campaign/run/job tables, not a second case store.
- Current blockers: provision creates `Job.Status="Running"`, a future one-hour lease, and `SourcesJson="[]"` (`BenchmarkCampaignService.cs:179-193`). `ReadingPaperWorker.RunOne` excludes benchmark topics and only claims Pending/expired Running (`ReadingPaperWorker.cs:37-49`); `Process` rejects empty sources (`ReadingPaperWorker.cs:145-151`). Removing the topic filter alone is insufficient.

## Planned request extension for A (not landed yet)

Extend the existing provision DTO with optional `workerInput: {topic, sources}`. `sources` uses the existing `ReadingSource` DTO, exactly three distinct verified sources for a full paper. With workerInput, provision pins engine `2.0.0`, immutable source inputs and benchmark profile in the existing run/job transaction and queues a Pending job with no execution lease. The worker alone claims execution, increments epoch and leases run+job. Generic provision without workerInput remains the existing direct capability used by earlier benchmark phases; it is not the G12 live acceptance path.

A creates the campaign, provisions the source-bearing queued case, and polls campaign + job/resume state. A must not write SourcesJson/SectionsJson/status by SQL, fabricate approvals, call Python section loops directly for G12, or call `/build-exam` to bypass the worker. Main will convey the landed DTO and readiness before any cost-bearing run.

## Actual-worker composition and finalizer

- Real class: `Features/ReadingPaper/ReadingPaperWorker.cs`, not Features/PaperGeneration.
- .NET `ReadingPaperAiClient.GeneratePaperV2Async` (`ReadingPaperAiClient.cs:79-106`) posts `PaperV2Request {blueprintRef, sectionRefs, runId, leaseOwner, epoch, title, paperId, engine}` to `api/v1/autogen/reading-paper/paper-v2`.
- Python router `PaperV2Request` (`app/router.py:79-87`) routes into `GenerationFacade.generate_paper_v2` and `PaperLoop`; Python only writes canonical artifacts/checkpoints via authenticated .NET persistence, never Exams.
- Fix worker engine selection to the persisted run engine only (`ReadingPaperWorker.cs:155-157`); remove prefix/all-run parent selection and redundant synthetic section/paper checkpoint bridge (`433-493`, `652-678`). Reload exact committed envelopes and their section-local question refs instead.
- `CheckpointService.BuildExamIdempotentAsync` (`1908-2003`) already saves the complete Exam/sections/groups/questions/options graph with run/job Completed in the same transaction. Preserve those mechanics; add independent canonical TargetRef/InputDependencyRefs freshness and exact authoritative graph checks, Draft-created/Completed outbox in that transaction, unique job→Exam and run→job identity, and authorized read-only Completed replay after lease release/expiry. Do not weaken the mutating authority validator.
- Keep existing independent heartbeat (`ReadingPaperWorker.cs:124-141`), add cancelVersion/lost-authority propagation during provider waits. No retries/accounting outside the shared gateway; ambiguous provider reservations stay charged.

## Python runtime fixes

Use actual `LoopPolicy.from_settings()`/`from_cap_snapshot()` and `EvaluatorRegistry.resolve_pipeline()` metadata, not invented policies/IDs. `app/loop/paper.py` currently hardcodes 25/150000/900 (`181-186`), creates random resume IDs (`209`), swallows authoritative resume errors (`253-264`), and accepts no-CRITICAL despite failed/missing evaluators (`285-303`). Replace these with pinned caps, deterministic identity and fail-closed required coverage. `PaperRepairerAdapter` is in this file; real repair route is `/paper-repair`, with `PaperRepairRequest {paperEnvelope,directive}` (`app/router.py:97-99`). Empty patches/preconditions must not be reported as completed repair.

## Known policy/capability evidence gaps

P12-02 `PaperCrossSectionEvaluator` (`app/evaluators/paper.py:295-397`) covers exact/shingle duplication, not semantic duplication. Existing question grounding/ambiguity evaluators are not a paper semantic duplicate evaluator. Inspect reusable gateway/relation policies; implement coverage without inventing a numeric threshold. Until implemented/exercised, semantic paper duplicate acceptance is unresolved.

The only discovered Validation Matrix is `docs/refactor/01-validation-matrix.md`, explicitly restored for G06–G10; no authentic G12 matrix/master-plan row has been found. Phase-12 prompt and output contract still require all P12/T12 invariants. Do not manufacture a row or promote a gate on missing policy evidence.

## Tests and isolation

Reuse `services/exam-service.Tests/AdminExamManualCrudTests.cs`; strengthen IResult-not-null checks to actual status/body, Draft exclusion, published student projection without answer/evidence, and real manual section/question/option consumers. Publish remains `PUT /api/admin/exam/update/{id}` with Published status (JWT Admin), not an internal-key pseudo-admin route. Do not add a second publish path.

READING_TEST_POSTGRES tests may DROP SCHEMA public. B will create a distinct B-only test database/port, serialize tests sharing it and prove identity before running. NEVER use A/G11 databases/ports. B records exact commands/native reports under `artifacts/refactor/phase-12/runtime-*`; A owns campaign/transport/final reports, Main owns verdict. No live campaign on mutable runtime code.
