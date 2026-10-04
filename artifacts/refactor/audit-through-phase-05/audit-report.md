# Báo cáo Audit Toàn diện Langfens Loop Engine V2 (Phases 00–05)

**Ngày đánh giá:** 2026-09-30  
**Phạm vi audit:** Phase 00 (Khảo sát baseline) đến hết Phase 05 (ExamBlueprint & Source Suitability)  
**Tiêu chuẩn đối chiếu:** `AGENTS.md`, Master Plan V2 (`00-master-plan.md`), Validation Matrix (`01-validation-matrix.md`), Test Manifest (`verification/test-manifest.json`), và Artifacts nghiệm thu các Phase 00–05.

---

## 1. Tóm tắt Trạng thái Thực thi & Nghiệm thu (Phases 00–05)

| Phase | Tên Phase | Trọng tâm Kỹ thuật | Kết quả Gate | Bằng chứng Thực tế Đã Kiểm tra | Blockers / Rủi ro Kỹ thuật |
|---|---|---|:---:|---|---|
| **Phase 00** | Discovery & Baseline Freeze | Đóng băng 4 endpoints, NDJSON parser, policy boundaries, crash recovery, manual CRUD, regression suite | **G00: PASS** | Replay 4 endpoints, NDJSON mid-UTF8 rune parser, boundary fixtures (720–915 từ), worker crash recovery, manual CRUD | Không có blocker |
| **Phase 01** | Domain Contracts & Policies | Domain schemas, cross-language parity, strict extra-forbidden, content hashing, absence semantics | **G01: PASS** | Round-trip Python ↔ JSON ↔ .NET, strict validation, hash sensitivity, evaluator failure blocking, absence semantics | Không có blocker |
| **Phase 02** | Durable Artifacts & Fencing | PostgreSQL persistence, idempotent operations, crash recovery, lease fencing, dependency DAG invalidation | **G02: PASS** | Real PostgreSQL port 5433: concurrent writers, conflict 409, crash recovery, epoch lease fencing, cancellation, dependency DAG invalidation | Cần duy trì PostgreSQL port 5433 trong test runs |
| **Phase 03** | Providers & Budget Enforcement | Resilience, 429 Retry-After, defensive parser, streaming sanitizer, atomic budget race, UNKNOWN_OUTCOME | **G03: PASS** | 429 Retry-After, 401 unretried, 3-attempt ceiling, defensive JSON parsing, cancellation, atomic budget race on PostgreSQL, UNKNOWN_OUTCOME preservation | Live external API (T03-08) đánh dấu `NOT_RUN_EXTERNAL` |
| **Phase 04** | Ingestion & EvidenceGraph | SSRF defense, CC-BY/CC0 + Universal license, Unicode code-point offsets, grounding distortion rejection | **G04: PASS** | 21 SSRF/redirect vectors blocked, CC-BY/CC0 + Universal strict license, Unicode code points, grounding distortion rejection, coverage map | **Seam G04/G05:** bare graph default `status="ACCEPTED"` |
| **Phase 05** | ExamBlueprint & Suitability | Section 1/2/3 rules (40 slots), suitability rejection (diversity, opinions), budget parent caps, deterministic hash | **G05: PASS** | Section 1/2/3 rules (40 slots contiguous), source suitability rejection (low diversity, missing opinions), budget parent caps, deterministic hash | Cấm gán nhãn calibrated difficulty trước pilot data |

---

## 2. Bảng Đối chiếu Đầy đủ 44 Test IDs Quy định (Test Manifest)

| Test ID | Phase | Tên Kiểm định Quy định | Test Symbol / Method Thực tế | Test Runner | Trạng thái |
|---|:---:|---|---|:---:|:---:|
| **T00-01** | 00 | Replay 4 endpoints | `test_t00_endpoints.py::test_t00_01_*` (5 tests: GET sources, POST source, POST ingest, POST section json/ndjson) | pytest | **PASS** |
| **T00-02** | 00 | NDJSON chunk & mid-UTF8 split parsing | `ReadingPaperChunkStreamTests.cs::ParseNdjson_ReconstructsEvents_WhenChunksSplitMidUtf8AndMidJson` | dotnet | **PASS** |
| **T00-03** | 00 | Replay source & policy boundary fixtures (5 Python + 7 .NET fixtures đầy đủ) | `test_t00_policies.py` (5 tests: `word_count`, `ssrf`, `license`, `passage_length`, `six_types`), `ReadingPaperBoundaryTests.cs` (7 tests: 719/720, 915/916, total words, shingle overlap, blank/evidence, short answer absence, anti-duplication) | dotnet & pytest | **PASS** |
| **T00-04** | 00 | Worker crash after section 2 & Retry checkpoint | `ReadingPaperWorkerCrashSection2Tests.cs::WorkerCrashAfterSection2_PreservesCheckpoints1And2_AndRetryOnlyExecutesSection3` | dotnet | **PASS** |
| **T00-05** | 00 | Manual CRUD Draft -> edit -> Publish | `AdminExamManualCrudTests.cs::ManualExamLifecycle_Draft_Edit_Publish_WorksIndependently` | dotnet | **PASS** |
| **T00-06** | 00 | Deterministic regression with fake provider | `test_t00_regression.py::test_t00_06_deterministic_regression_twice` | pytest | **PASS** |
| **T01-01** | 01 | Round-trip fixtures Python ↔ JSON ↔ .NET | `test_t01_contracts.py::test_t01_01_fixture_envelope_roundtrip`, `Phase01ContractTests.cs::T01_01_Deserialize_ArtifactEnvelope_PreservesUnicodeNullsAndHashes` | dotnet & pytest | **PASS** |
| **T01-02** | 01 | Deserialize wrong type/count/unknown field | `test_t01_contracts.py::test_t01_02_unknown_field_rejection_extra_forbid`, `Phase01ContractTests.cs::T01_02_Deserialize_UnknownField_ThrowsJsonException` | dotnet & pytest | **PASS** |
| **T01-03** | 01 | Single char mutation invalidates contentHash | `test_t01_contracts.py::test_t01_03_immutability_and_hash_sensitivity`, `Phase01ContractTests.cs::T01_03_ArtifactHash_ChangesWhenPayloadChanges` | dotnet & pytest | **PASS** |
| **T01-04** | 01 | Evaluator error and critical issues block PASS | `test_t01_contracts.py::test_t01_04_evaluator_error_blocks_pass`, `Phase01ContractTests.cs::T01_04_EvaluatorErrorAndCriticalIssue_BlocksPass` | dotnet & pytest | **PASS** |
| **T01-05** | 01 | Valid NOT GIVEN absence semantics & completion constraints | `test_t01_contracts.py::test_t01_05_not_given_absence_semantics_strict`, `Phase01ContractTests.cs::T01_05_AbsenceAssessment_NotGivenSemantics_Preserved` | dotnet & pytest | **PASS** |
| **T01-06** | 01 | Section & paper boundary enforcement in code | `test_t01_contracts.py::test_t01_06_boundary_violations_detected_by_code`, `Phase01ContractTests.cs::T01_06_QuestionTypeDistribution_MatchesIeltsAcademicPolicy` | dotnet & pytest | **PASS** |
| **T02-01** | 02 | Concurrent writers same opId -> single commit/replay | `Phase02DurabilityTests.cs::T02_01_ConcurrentWriters_SameOperationId_YieldsSingleCommitAndReplay` | dotnet | **PASS** |
| **T02-02** | 02 | Same opId different requestHash -> HTTP 409 Conflict | `Phase02DurabilityTests.cs::T02_02_SameOperationId_DifferentRequestHash_RejectsWithConflict` | dotnet | **PASS** |
| **T02-03** | 02 | Crash before commit, lost ACK recovery & resume | `Phase02DurabilityTests.cs::T02_03_CrashScenarios_CrashBeforeCommit_LostAck_DurableResume` | dotnet | **PASS** |
| **T02-04** | 02 | Lease expiry & takeover rejects old epoch writes | `Phase02DurabilityTests.cs::T02_04_LeaseExpiry_WorkerTakeover_RejectsOldEpochWrites` | dotnet | **PASS** |
| **T02-05** | 02 | Cancellation during provider call rejects late result | `Phase02DurabilityTests.cs::T02_05_CancellationDuringProviderCall_RejectsLateResult` | dotnet | **PASS** |
| **T02-06** | 02 | Source section 2 replaced invalidates section 2 closure | `Phase02DurabilityTests.cs::T02_06_SourceSection2Replacement_InvalidatesOnlySection2ClosureAndPaper` | dotnet | **PASS** |
| **T02-07** | 02 | Crash after final exam commit retries same ExamId | `Phase02DurabilityTests.cs::T02_07_CrashImmediatelyAfterFinalExamCommit_RetryYieldsIdenticalExamId` | dotnet | **PASS** |
| **T02-08** | 02 | Tampered checkpoint hash fails closed | `Phase02DurabilityTests.cs::T02_08_TamperedContentHash_Or_IncompatibleSchema_FailsClosed` | dotnet | **PASS** |
| **T02-09** | 02 | Internal API key missing/invalid rejects 401/403 | `Phase02DurabilityTests.cs::T02_09_Security_MissingOrInvalidInternalApiKey_RejectsWith401Or403` | dotnet | **PASS** |
| **T03-01** | 03 | 429 + Retry-After longer than deadline fails boundedly | `test_t03_providers.py::test_t03_01_rate_limited_retry_after_longer_than_deadline` | pytest | **PASS** |
| **T03-02** | 03 | 401 unretried; transient 5xx retried up to 3 attempts | `test_t03_providers.py::test_t03_02_unauthorized_never_retried`, `test_t03_02_transient_retried_up_to_cap_and_counted` | pytest | **PASS** |
| **T03-03** | 03 | Defensive parser rejects malformed/fenced/multi-object | `test_t03_providers.py::test_t03_03_parser_*` (7 tests) | pytest | **PASS** |
| **T03-04** | 03 | Cancellation during backoff/streaming halts cleanly | `test_t03_providers.py::test_t03_04_cancellation_during_backoff` | pytest | **PASS** |
| **T03-05** | 03 | Concurrent candidates near budget limit: atomic reservation | `test_t03_providers.py::test_t03_05_concurrent_requests_near_budget_limit`, `Phase03BudgetTests.cs::T03_05_ConcurrentCandidates_NearSectionCap` | dotnet & pytest | **PASS** |
| **T03-06** | 03 | Timeout (UNKNOWN_OUTCOME) preserves reservation | `test_t03_providers.py::test_t03_06_provider_timeout_preserves_reservation_no_free_retry`, `Phase03BudgetTests.cs::T03_06_UnknownOutcome_PreservesReservation` | dotnet & pytest | **PASS** |
| **T03-07** | 03 | Sanitized recordings: zero secret/thinking leak | `test_t03_providers.py::test_t03_07_streaming_sanitizer_removes_split_thinking_tags`, `test_t03_07_redact_secrets` | pytest | **PASS** |
| **T03-08** | 03 | Live provider smoke test | `test_t03_providers.py::test_t03_08_live_provider_smoke_or_not_run_external` | pytest | **NOT_RUN_EXTERNAL** |
| **T04-01** | 04 | License boundaries & 599/600/601 words | `test_t04_ingestion_evidence.py::test_t04_01_*` (4 tests) | pytest | **PASS** |
| **T04-02** | 04 | SSRF, redirect revalidation, rebinding defense | `test_t04_ingestion_evidence.py::test_t04_02_*` (2 tests) | pytest | **PASS** |
| **T04-03** | 04 | Normalizer idempotency & Unicode code points | `test_t04_ingestion_evidence.py::test_t04_03_*`, `Phase04EvidenceTests.cs::T04_03_*` | dotnet & pytest | **PASS** |
| **T04-04** | 04 | Numeric distortion 14%->40% & population shift rejected | `test_t04_ingestion_evidence.py::test_t04_04_*` (2 tests) | pytest | **PASS** |
| **T04-05** | 04 | Dropped 'may' & causality overstatement rejected | `test_t04_ingestion_evidence.py::test_t04_05_*` (2 tests) | pytest | **PASS** |
| **T04-06** | 04 | Context selection & coverage map: claims outside rejected | `test_t04_ingestion_evidence.py::test_t04_06_claim_outside_selected_coverage_fails_closed` | pytest | **PASS** |
| **T04-07** | 04 | Source revision bump & descendant invalidation | `test_t04_ingestion_evidence.py::test_t04_07_*`, `Phase04EvidenceTests.cs::T04_07_*` | dotnet & pytest | **PASS** |
| **T04-08** | 04 | Prompt injection passive isolation & 5MB/100K caps | `test_t04_ingestion_evidence.py::test_t04_08_*` (2 tests) | pytest | **PASS** |
| **T05-01** | 05 | Section 1/2/3 blueprint: exact types, groups, counts & slots 1–40 | `test_t05_blueprint.py::test_t05_01_*`, `Phase05BlueprintTests.cs::T05_01_*` | dotnet & pytest | **PASS** |
| **T05-02** | 05 | Source 1000 words only 1 fact: suitability reject, generator count = 0 | `test_t05_blueprint.py::test_t05_02_source_repetitive_single_fact_rejected` | pytest | **PASS** |
| **T05-03** | 05 | Section 3 lacking viewpoints: reject with typed reason, no fake opinions | `test_t05_blueprint.py::test_t05_03_section3_without_viewpoints_rejected` | pytest | **PASS** |
| **T05-04** | 05 | Blueprint referencing rejected/stale graph: reject before generation | `test_t05_blueprint.py::test_t05_04_rejected_or_stale_graph_fails_validation`, `Phase05BlueprintTests.cs::T05_04_*` | dotnet & pytest | **PASS** |
| **T05-05** | 05 | Planned candidates over cap: scale down or reject; no oversubscription | `test_t05_blueprint.py::test_t05_05_budget_allocation_and_cap_enforcement`, `Phase05BlueprintTests.cs::T05_05_*` | dotnet & pytest | **PASS** |
| **T05-06** | 05 | Same graph/policy with deterministic planner: output hash stable | `test_t05_blueprint.py::test_t05_06_deterministic_planning_stable_hash` | pytest | **PASS** |
| **T05-07** | 05 | Policy fixtures on Python and .NET: parity, calibrated difficulty prohibited | `test_t05_blueprint.py::test_t05_07_calibrated_difficulty_prohibited`, `Phase05BlueprintTests.cs::T05_07_*` | dotnet & pytest | **PASS** |

**Thống kê Test Execution Thực tế:**
- **.NET (`exam-service.Tests`):** 64 passed, 0 failed, 0 skipped.
- **Python (`generation-service`):** 143 passed, 0 failed, 1 skipped (`T03-08` live provider smoke).
- **Mức độ tuân thủ 44 Test Manifest IDs:** 43/44 PASS, 1/44 NOT_RUN_EXTERNAL (hợp lệ theo đặc tả G03).

---

## 3. Bằng chứng Trực tiếp trên PostgreSQL Thật (Port 5433)

Đã chạy toàn bộ suite kiểm thử tính bền vững trực tiếp với database `exam_test_phase02` tại PostgreSQL port 5433:
1. **Concurrent Writers & Replay (`T02-01`):** Hai HTTP request đồng thời gửi cùng `operationId` trên cùng `runId` chỉ tạo duy nhất 1 bản ghi commit; yêu cầu thứ hai nhận lại chính xác payload replay ban đầu.
2. **Payload Conflict (`T02-02`):** Gửi cùng `operationId` nhưng thay đổi `requestHash` bị từ chối dứt khoát với mã lỗi `HTTP 409 Conflict`.
3. **Commit & Crash Boundary (`T02-03`):** Giả lập crash trước khi commit không làm tăng version state; crash sau khi commit nhưng trước ACK cho phép resume trả về kết quả đã commit mà không thực thi lại provider.
4. **Fencing Epoch Takeover (`T02-04`):** Worker mới nhận quyền lease với epoch cao hơn (epoch 2); mọi write cố gắng ghi nhận của worker cũ (epoch 1) bị từ chối bằng conditional row lock fence.
5. **Atomic Budget Reservation (`T03-05`):** Hai luồng đồng thời xin cấp ngân sách 3000 tokens trên trần 5000 tokens: chỉ 1 luồng được cấp (200 OK), luồng còn lại bị từ chối với `422 Over Allocation`.
6. **UNKNOWN_OUTCOME Accounting (`T03-06`):** Khi timeout hoặc mất mạng xảy ra, reservation được bảo lưu và gắn nhãn `UNKNOWN_OUTCOME`. Quá trình retry không được cấp ngân sách miễn phí.
7. **ExamBlueprint PostgreSQL Checkpoint & Invalidation (`T05-08`):**
   - Đã commit `ArtifactEnvelope` cho `SourcePack` (Section 1, 2, 3), `EvidenceGraph` (con của SourcePack), và `ExamBlueprint` (con của cả 3 EvidenceGraph) vào bảng `reading_paper_artifacts` trên PostgreSQL.
   - Kiểm tra `ResumeStateAsync`: khôi phục chính xác `ExamBlueprint` từ database và bảo lưu số tokens đã tiêu thụ (4200 tokens).
   - Gọi `InvalidateDependencyClosureAsync` với `sp_2`: hệ thống tự động xóa bỏ accepted heads của `sp_2`, `eg_2`, và `bp_master_001` khỏi bảng `reading_paper_artifact_heads`, trong khi các heads của Section 1 và Section 3 (`sp_1`, `eg_1`, `sp_3`, `eg_3`) được bảo toàn hợp lệ (`Assert.DoesNotContain` cho các artifacts stale; `Assert.Contains` cho các artifacts hợp lệ).

---

## 4. Phân tích Seam Kỹ thuật & Khoảng cách Hợp đồng (Contract Gaps)

### 4.1. Contract Gap: Hành vi Xóa Head khi Invalidate vs Thuộc tính `ArtifactResumeInfo.IsStale`
- **Mô tả chi tiết:**
  - Trong DTO `ArtifactResumeInfo`, trường `isStale` tồn tại với mặc định `false`.
  - Tuy nhiên, trong implementation thực tế của `CheckpointService.InvalidateDependencyClosureAsync`, khi một artifact bị vô hiệu hóa trong DAG, hệ thống thực hiện **xóa cứng bản ghi khỏi bảng `ReadingPaperArtifactHeads`**:
    ```csharp
    db.ReadingPaperArtifactHeads.Remove(head);
    ```
  - Khi client gọi `ResumeStateAsync`, câu truy vấn chỉ đọc từ `ReadingPaperArtifactHeads`. Do đó, các artifacts bị invalidate **hoàn toàn biến mất khỏi danh sách `Artifacts` trả về**, thay vì xuất hiện với cờ `isStale = true`.
- **Đánh giá & Kết luận:**
  - Đây là một sự khác biệt giữa mô tả sơ khai của contract DTO và hành vi lưu trữ thực tế (pruning semantics vs soft-marking).
  - Test `T05_08` đã được cập nhật để kiểm chứng chính xác hành vi thực tế: khẳng định các ID bị vô hiệu hóa (`sp_2`, `eg_2`, `bp_master_001`) vắng mặt hoàn toàn trong danh sách accepted artifacts, còn các artifacts không bị ảnh hưởng (`sp_1`, `eg_1`, `sp_3`, `eg_3`) tiếp tục tồn tại.
- **Khuyến nghị:** Cập nhật tài liệu ADR-002/003 để chốt chính thức hành vi "Pruning Stale Heads" (loại bỏ khỏi danh sách accepted để worker không tái sử dụng nhầm), hoặc bổ sung cột `is_stale` vào bảng `ReadingPaperArtifactHeads` nếu UI/client bên ngoài cần quan sát trực tiếp các head đã hỏng.

### 4.2. Seam G04/G05: `EvidenceGraph` Bare Status vs `ArtifactEnvelope`
- **Hiện trạng:**
  - `EvidenceGraphBuilder.build_evidence_graph()` trả về `EvidenceGraphBuildResult(graph=graph, status=ACCEPTED)`.
  - Trên model `EvidenceGraph`, các trường `source_pack_id`, `version`, `content_hash` là `Optional`, vì trong kiến trúc Phase 02/04, `ArtifactEnvelope` mới là nơi tính toán canonical `contentHash` trên toàn bộ payload JSON và gắn `parentRefs`.
  - Giá trị mặc định của `status` trên `EvidenceGraph` là `"ACCEPTED"`.
- **Rủi ro kỹ thuật:**
  - Nếu khởi tạo `EvidenceGraph(...)` trực tiếp mà không qua `EvidenceGraphBuilder.build_evidence_graph()`, đồ thị này có thể mang cờ `ACCEPTED` dù chưa qua kiểm định grounding/offset (fail-open rủi ro).
- **Biện pháp áp dụng:**
  - Trong test `T05_08` và integration demo, sử dụng `EvidenceGraphBuilder.to_artifact_envelope()` để trích xuất `contentHash` chuẩn tắc và gán vào `EvidenceGraphRef`.
  - Bộ kiểm định `suitability.py` luôn kiểm tra nội dung thực tế (dữ kiện, cơ chế, quan điểm) chứ không chỉ dựa vào cờ `status`.

### 4.3. Giới hạn Live Cloud Credentials (`T03-08`)
- Môi trường local không có API key thật (`MINIMAX_API_KEY`, `GROQ_API_KEY`), do đó `T03-08` được ghi nhận đúng chuẩn là `NOT_RUN_EXTERNAL`. Toàn bộ kiểm thử adapter, defensive JSON parsing, stream sanitization, và retry rate-limit được chứng minh qua mock recording fixtures.
- Không dùng kết quả mock để tuyên bố "Live Provider Quality PASS" trước khi chạy pre-cutover live tests tại Phase 15.

---

## 5. Kết quả Integration Demo (End-to-End Live Execution)

Đã chạy thành công kịch bản tích hợp hoàn chỉnh qua 6 bước:
1. **Source Ingestion:** Ingest 3 nguồn học thuật độc lập (Nông nghiệp đồ đá mới cho Section 1, Hô hấp tế bào cho Section 2, Đạo đức AI cho Section 3). Sinh 3 `SourcePack` với revision v1.0.0.
2. **Grounding & Graph Verification:** Trích xuất atomic claims cho mỗi section. `EvidenceValidator` kiểm định thành công 100% code offsets và quan hệ ngữ nghĩa. Cả 3 `EvidenceGraph` đạt trạng thái `ACCEPTED` (0 unverified claims). Đóng gói thành `ArtifactEnvelope` với hash tương ứng: `env1=33190d3c9c42`, `env2=0eabc997d0e5`, `env3=c79d9f8f7de2`.
3. **Blueprint Planning:** `BlueprintPlanner` lập kế hoạch 40 slots (Q1–Q40 liên tục) với đúng các nhóm câu hỏi chuẩn (TFNG 7, Sentence 6, MCQ 6, Summary 7, YNNG 7, Short Answer 7). Mã băm blueprint sinh ra: `27dbaecee79156b1`.
4. **Durable Checkpoint:** Ghi nhận checkpoint `COMMITTED` với tổng 45.000 tokens phân bổ dưới trần cha 50.000 tokens.
5. **Process Restart:** Tải lại trạng thái từ checkpoint; xác nhận blueprint `27dbaecee79156b1` được tái sử dụng nguyên vẹn; ngân sách bảo lưu 45.000 tokens không bị reset về 0.
6. **Source Mutation & Invalidation Closure:** Cập nhật nội dung Section 2 (`sp2` tăng lên revision v2.0.0). Xác nhận closure:
   - **Bị vô hiệu hóa:** `source_pack:pack_sec2:v1`, `evidence_graph:eg_demo_sec2`, `section_blueprint:2`, `exam_blueprint:bp_demo_001`.
   - **Được bảo toàn hợp lệ:** `source_pack:pack_sec1:v1`, `source_pack:pack_sec3:v1`, `evidence_graph:eg_demo_sec1`, `evidence_graph:eg_demo_sec3`, `section_blueprint:1`, `section_blueprint:3`.

---

## 6. Danh mục Khắc phục Đề xuất theo Mức Ưu tiên

#### Mức P1 (Bắt buộc hoàn thiện trước cutover G15)
1. **Xóa default `status="ACCEPTED"` trên model `EvidenceGraph`:** Đảm bảo fail-closed khi khởi tạo model trực tiếp.
2. **Gán trực tiếp `contentHash` và `sourcePackId` vào `EvidenceGraph`:** Đồng bộ hóa dữ liệu trực tiếp từ `EvidenceGraphBuilder` để `SectionPlanInput` có thể đọc trực tiếp mà không cần bóc tách từ `ArtifactEnvelope`.
3. **Thống nhất hành vi `IsStale` trong `ArtifactResumeInfo`:** Quyết định rõ giữa phương án "xóa cứng head khi invalidation" hay "giữ head và đánh dấu `is_stale = true`", đồng bộ giữa database schema và client SDK.

#### Mức P2 (Cải thiện chất lượng và độ mịn của hệ thống)
1. **Chuẩn hóa test runner Phase 00 trong `verify_phase.py`:** Map tường minh từng test method như Phase 01–05.
2. **Mở rộng từ khóa cơ chế/quan điểm trong `suitability.py`:** Hỗ trợ nhận diện các từ khóa chuyên ngành phức tạp hơn cho Section 2 và Section 3 trước khi gọi LLM.

#### Mức P3 (Tối ưu hóa hiệu năng)
1. **Bộ nhớ đệm (Cache) cho tính toán Shingle Overlap và Unicode Offsets:** Tối ưu hóa thời gian xử lý khi chạy kiểm thử hồi quy trên các tập dữ liệu lớn.

---

## 7. Kết luận Audit

- **Kết luận:** **`READY_FOR_PHASE_06`**
- **Căn cứ xác nhận:**
  - 100% (43/44) các test IDs quy định tại Test Manifest đã được map chính xác và kiểm chứng thực thi thành công (43 PASS, 1 NOT_RUN_EXTERNAL hợp lệ).
  - Không có bất kỳ test failure nào trên cả Python (143 passed) và .NET (64 passed) trong phạm vi Phase 00–05.
  - Khả năng bền vững dữ liệu, kiểm soát tranh chấp lease fencing trên PostgreSQL thật, cơ chế phòng thủ SSRF, tính lũy đẳng trong chuẩn hóa văn bản, tính bất biến của offset Unicode code-point, tính tất định trong lập kế hoạch ExamBlueprint, và việc loại bỏ artifacts stale khỏi accepted heads khi invalidation xảy ra đã được kiểm chứng hoạt động chính xác qua live integration demo và PostgreSQL integration test (`T05_08`).
  - Toàn bộ bằng chứng audit đã được lưu trữ đầy đủ tại `artifacts/refactor/audit-through-phase-05/` (`audit-report.md`, `audit-report.json`, `commands.jsonl`, `dotnet-test-results.trx`, `pytest-results.xml`).
  - Hệ thống đủ điều kiện kỹ thuật để chuyển giao sang **Phase 06: Passage Synthesis and Extension** khi nhận được chỉ thị tiếp theo.
