# Exam Authority Handoff

## Summary of Changes

This handoff documents the cutover of `exam-service` ReadingPaper generation to the unified Python generation pipeline (`POST /api/v1/autogen/reading-paper/execute`), the hardening of `CheckpointService` with generic provenance validation, CAS optimistic concurrency guards, and policy hash propagation, as well as the parameterization of `ReadingPaperRules.Validate` for standalone sections.

---

## 1. ReadingPaperAiClient.cs
- **Added `ExecutePipelineAsync`**:
  ```csharp
  public async Task<PipelineResult> ExecutePipelineAsync(PipelineRequest request, CancellationToken ct)
      => await PostAsync<PipelineResult>("api/v1/autogen/reading-paper/execute", request, ct);
  ```
- **Added DTO records with exact camelCase JSON property aliases matching Python contracts**:
  - `SourceInput`: `sectionIndex`, `pmcid`, `title`, `url`, `license`, `content`, `doi`, `authors`
  - `GroupPolicyConfig`: `questionType`, `count`
  - `SectionPolicyConfig`: `index`, `startNumber`, `groups`, `minWords`, `maxWords`, `difficulty`, `editorialObjective`
  - `PinnedExecutionPolicy`: Full execution budget and threshold model matching Python's `PinnedExecutionPolicy` with factory `CreateDefault(provider)` and `ComputeHash()` producing canonical SHA-256 lower-hex digest byte-for-byte compatible with Python.
  - `PipelineRequest`: `runId`, `jobId`, `epoch`, `leaseOwner`, `topic`, `sources`, `sectionIndices`, `parallel`, `policy`, `finalize`
  - `PipelineResult`: `runId`, `status`, `sections`, `paper`, `examId`, `metrics`

---

## 2. ReadingPaperWorker.cs
- **Cut over section/paper loops**: Replaced lines 248–960 (the iterative 700-line section loop, question candidate loop, synthetic envelope generation, and inline paper loop) with a single call:
  ```csharp
  var pipelineResult = await ai.ExecutePipelineAsync(pipelineRequest, ct);
  ```
- **Sections Rehydration**: Extracted accepted sections from `pipelineResult.Sections` via `CheckpointService.ParseCanonicalV2Section(secEnv.Payload)`.
- **Retained Core Worker Responsibilities**:
  - Durable job claim via transactional CAS
  - Lease renewal via periodic `Heartbeat` loop (every 30s)
  - Cancellation token propagation and checks
  - Run binding and engine/budget profile resolution
  - Structured error logging and status transitions (`NeedsSources` on 422 `ReadingSourceUnavailableException`, `Failed` on errors)
  - Idempotent exam finalization via `CheckpointService.BuildExamIdempotentAsync`

---

## 3. CheckpointContracts.cs & CheckpointService.cs
- **Contracts Updated**:
  - `ResumeStateResult`: Added `[property: JsonPropertyName("policyHash")] string? PolicyHash = null`
  - `CheckpointCommitRequest`: Added `ExpectedHeadHash` and `ExpectedCursorRevision` optional CAS guard properties.
  - `DraftCheckpointRequest`: Added `ExpectedHeadHash` and `ExpectedCursorRevision` optional CAS guard properties.
- **CheckpointService.ResumeStateAsync**:
  - Retrieves `policyHash` from `ReadingPaperLoopCursor.StateJson`, falls back to operations' `ResultRefJson`, and defaults to canonical SHA-256 for the run's provider.
  - Populates `PolicyHash` on `ResumeStateResult`.
- **CommitCheckpointAsync & SaveDraftCheckpointAsync Guard Verification**:
  - If `request.ExpectedHeadHash` is provided, verifies that current accepted head hash matches, throwing `CheckpointValidationException(409)` on conflict before any write.
  - If `request.ExpectedCursorRevision` is provided, verifies that current cursor revision matches, throwing `CheckpointValidationException(409)` on conflict before any write.
- **ImportCheckpointAsync Generic Provenance Validation**:
  - Removed hardcoded `art_passage_s2` v2 branch (lines 1572–1582) with static SHA-256 string.
  - Replaced with generic provenance validation:
    - If artifact version matches source run version, verifies exact `ContentHash` equality.
    - If derived version (`Version > sourceVersion`), verifies source run contains a valid predecessor version with non-empty content hash.
    - Binds the imported artifact, predecessor (if missing), and accepted head to destination run.
- **ParseCanonicalV2Section**: Changed accessibility from `private static` to `public static` to support section envelope payload rehydration.

---

## 4. ReadingPaperModels.cs
- **Parameterized `ReadingPaperRules.Validate`**:
  - Added overload `Validate(ReadingGeneratedSection section, int sectionNumber = 1, int? startingQuestionNumber = null)`.
  - Added optional parameters to `Validate(IReadOnlyList<ReadingGeneratedSection> sections, int? startingSectionNumber = null, int? startingQuestionNumber = null)`.
  - Auto-detects standalone section number (S1, S2, S3) from the initial question number (Q1..13 -> S1, Q14..26 -> S2, Q27..40 -> S3) when a single section is provided.
  - Gates continuity-1-based and group-type-mismatch checks to the target section(s), allowing S2 (Q14–26) and S3 (Q27–40) to validate standalone without error, while fully preserving full 3-section IELTS rules.

---

## 5. ReadingPaperTests.cs
Added comprehensive unit and integration tests:
1. `Validate_StandaloneSection2_SucceedsWithoutContinuousOneBasedErrors`: Validates Section 2 (Q14–26, MCQ + Summary Completion) standalone.
2. `Validate_StandaloneSection3_SucceedsWithoutContinuousOneBasedErrors`: Validates Section 3 (Q27–40, YNNG + Short Answer) standalone.
3. `Validate_StandaloneSection2_ExplicitStartingSection_Succeeds`: Validates Section 2 with explicit `startingSectionNumber: 2`.
4. `Validate_StandaloneSection2_WrongStartingNumber_Throws`: Asserts mismatch when starting number does not match expected Q14 start.
5. `PinnedExecutionPolicy_CreateDefault_GeneratesStable64HexHash`: Asserts policy hash is 64 hex characters, deterministic, and stable.
6. `PipelineRequest_Serialization_ContainsRequiredWireFields`: Asserts camelCase serialization of `PipelineRequest` wire fields.
7. `ExecutePipelineAsync_PostsToExecuteEndpoint_ReturnsAcceptedResult`: Verifies `ReadingPaperAiClient.ExecutePipelineAsync` posts to `/api/v1/autogen/reading-paper/execute` with valid request body and parses result.
8. `ResumeStateResult_IncludesPolicyHash_RoundTripsJson`: Verifies `PolicyHash` property round-trips via JSON.
9. `CheckpointCommitRequest_IncludesExpectedGuards_RoundTripsJson`: Verifies `ExpectedHeadHash` and `ExpectedCursorRevision` on commit request.
10. `DraftCheckpointRequest_IncludesExpectedGuards_RoundTripsJson`: Verifies `ExpectedHeadHash` and `ExpectedCursorRevision` on draft request.
11. `ParseCanonicalV2Section_ExtractsReadingGeneratedSectionFromPayload`: Verifies `CheckpointService.ParseCanonicalV2Section` parses section envelope payload into domain model.

---

## 6. Verification Commands for Main Agent

Run these commands during integrated verification:

```bash
# 1. Build exam-service
dotnet build services/exam-service/exam-service.csproj

# 2. Build test project
dotnet build services/exam-service.Tests/exam-service.Tests.csproj

# 3. Run ReadingPaper unit tests
dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~ReadingPaperTests"

# 4. Run Checkpoint integration tests
dotnet test services/exam-service.Tests/exam-service.Tests.csproj --filter "FullyQualifiedName~Phase02DurabilityTests"
```
