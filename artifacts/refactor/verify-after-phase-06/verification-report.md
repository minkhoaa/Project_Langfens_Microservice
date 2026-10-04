# Langfens Loop Engine V2 — Phase 06 Verification Report

**Document Version:** 1.0.0  
**Evaluated At:** 2026-10-01T04:49:55Z  
**Phase:** 06 — Bounded Loop Runtime và Issue Ledger  
**Gate:** G06  
**Status:** **BLOCKED**  
**Readiness for Phase 07:** **BLOCKED**  

---

## 1. Metadata và Môi trường Kiểm định

- **Git Commit SHA:** `999dc94f1c68102b1270690b3ba0d7e40117c788`
- **Tracked Diff Digest:** `e300ac21d94f244087586cddb36d88279df0ab363db26059b46fd453b9e3f196`
- **Untracked Workspace Digest:** `1292d4608d3c2fd29e66d564f120f0d13cee4a4c353a108a65a15494424fee90`
- **Engine / Policy / Schema Version:** `2.0.0`
- **Test Database:** PostgreSQL 16 on `localhost:5433`, database `exam_test_phase06` (isolated test database)
- **Exam Service Test Instance:** ASP.NET Core Kestrel HTTP/1.1 on `http://127.0.0.1:5098`
- **Evidence Bundle Directory:** `artifacts/refactor/verify-after-phase-06/`

---

## 2. Kiểm tra Kiến trúc và Implementation (P06-01 đến P06-08)

Toàn bộ 8 work packages đã được đối chiếu trực tiếp với mã nguồn thực tế và kiểm chứng bằng automated tests:

| Package | Tên | Trạng thái | Đường dẫn thực tế | Bằng chứng thực tế |
|---|---|---|---|---|
| **P06-01** | `LoopContext` | **IMPLEMENTED** | `services/generation-service/app/loop/context.py` | Chứa `run_id`, `scope`, `target_artifact_id`, `target_artifact_type`, `authority` (`AuthorityGrant` với lease owner, epoch, và cancellation check), `input_dependencies` (tuple `ArtifactRef`), `policy_version`, `budget_tracker` (`BudgetTracker`), `cursor` (`ResumeCursor`), `open_issues`. |
| **P06-02** | `LoopRuntime` | **IMPLEMENTED** | `services/generation-service/app/loop/runtime.py` | State machine rõ ràng với `LoopState` (INITIALIZED, DRAFTING, REPAIRING, EVALUATING, COMPLETED, FAILED, ABORTED). Cursor lưu trạng thái durable qua `LoopCursorCheckpointRequest` gửi đến `exam-service`. |
| **P06-03** | `LoopController` | **IMPLEMENTED** | `services/generation-service/app/loop/controller.py` | Quyết định typed: `PASS`, `REPAIR`, `REGENERATE`, `ESCALATE`, `FAIL`. Lý do cụ thể qua enum `LoopReason` (ACCEPTED, REPAIRABLE_DEFECTS, UNREPAIRABLE_DEFECTS, SOURCE_INSUFFICIENT, NO_PROGRESS, OSCILLATION, MAX_VERSIONS, CALL_CAP, TOKEN_CAP, WALL_TIME_CAP, STALE_DEPENDENCY, EVALUATOR_ERROR, MISSING_EVALUATOR, CANCELLED, LEASE_LOST, INVALID_OUTPUT, UNKNOWN_OUTCOME). Target scope và artifact ID được gán chính xác. |
| **P06-04** | `IssueLedgerManager` | **IMPLEMENTED** | `services/generation-service/app/loop/ledger.py` | Issue fingerprint qua SHA-256 (`code`, `scope`, `affected_refs`, `message`). Vòng đời: `OPEN`, `RESOLVED`, `SUPERSEDED`, `DEFERRED`, `SUPPRESSED`. Invariant: Không issue blocker nào bị tự động đóng do evaluator sau omit, soft score cao, hay PASS của evaluator không liên quan. |
| **P06-05** | `StepJournal` | **IMPLEMENTED** | `services/generation-service/app/loop/journal.py` | Mỗi side effect sinh `OperationIntent` với `request_hash`, token reservation, wall-time reservation. Nhận durable ACK từ persistence (`CheckpointAck`, `LoopCursorCheckpoint`). |
| **P06-06** | `Termination` | **IMPLEMENTED** | `services/generation-service/app/loop/policy.py`<br>`services/generation-service/app/loop/detectors.py` | Hard caps: calls, versions, repair attempts, tokens, wall-time. `StagnationDetector` phát hiện content hash không đổi giữa các repairs. `OscillationDetector` phát hiện chuỗi chu kỳ A→B→A hoặc lặp fingerprint sets. |
| **P06-07** | `DependencyValidator` | **IMPLEMENTED** | `services/generation-service/app/loop/dependencies.py` | Kiểm tra exact version & content hash của upstream dependencies. Tính transitive invalidation closure. Repair tạo immutable version mới, loại bỏ stale heads của descendants. |
| **P06-08** | `Capability Contracts` | **IMPLEMENTED** | `services/generation-service/app/loop/capabilities.py` | `GeneratorCapability`, `EvaluatorCapability`, `RepairerCapability` là Python Protocols. Runtime hoàn toàn không chứa vendor SDK, IELTS prompt, hay logic retry riêng ngoài generic loop. |

---

## 3. Kết quả Kiểm định Bộ Test T06-01 đến T06-08

| Test ID | Tên Kịch Bản | Trạng thái | Test Functions Đã Chạy | Kết quả Quan Sát & Assertions |
|---|---|---|---|---|
| **T06-01** | Five decisions | **PASS** | `test_t06_01_decision_pass`<br>`test_t06_01_decision_repair`<br>`test_t06_repair_attempt_cap_reached`<br>`test_t06_01_decision_regenerate`<br>`test_t06_01_decision_escalate`<br>`test_t06_01_decision_fail`<br>`run_phase06_real_postgres_integration.py` | Kích hoạt đủ 5 quyết định. PASS chỉ khi đủ required evaluators, dependencies fresh và zero unresolved blockers. ESCALATE và FAIL không được accept vào PostgreSQL heads. Repair cap tại 2 attempts chuyển sang REGENERATE chính xác. |
| **T06-02** | No progress / Stagnation | **PASS** | `test_t06_02_stagnation_detection` | Repair trả content hash y hệt: Dù version number tăng, `StagnationDetector` đếm consecutive identical repairs. Đạt cap (2) thì dừng ngay với `NO_PROGRESS`, không gọi generator/repairer vô hạn. |
| **T06-03** | Oscillation & Termination | **PASS** | `test_t06_03_oscillation_detection`<br>`test_t06_property_finite_sequence_termination` | Phát hiện chu kỳ A→B→A và recurring issue fingerprints. Đổi issue ID không né được attempts/budget caps. Property test 81 combinatorial sequences chứng minh 100% kết thúc trong finite caps. |
| **T06-04** | Blocker invariant | **PASS** | `test_t06_04_blocker_invariant_never_masked_by_soft_score`<br>`test_t06_issue_omission_requires_explicit_evidence`<br>`test_t06_repair_omission_does_not_pass`<br>`test_t06_regenerate_omission_does_not_pass` | 1 CRITICAL blocker đi kèm soft score 0.99 vẫn ngăn cản quyết định PASS. Evaluator sau omit issue không làm issue biến mất; blocker vẫn OPEN trong ledger trừ khi có explicit PASS verification trên exact replacement ref. |
| **T06-05** | Evaluator failures | **PASS** | `test_t06_05_evaluator_error_fail_closed`<br>`test_t06_05_missing_required_evaluator`<br>`test_t06_05_evaluator_timeout_fail_closed`<br>`test_t06_05_evaluator_malformed_output_fail_closed`<br>`test_t06_05_evaluator_wrong_artifact_version_fail_closed`<br>`test_t06_05_optional_evaluator_skipped_with_policy_rationale` | Bao phủ toàn bộ các dạng lỗi evaluator: missing required evaluator, timeout (`asyncio.wait_for` quá hạn reservation), exception, malformed output (không phải `EvaluationResult`), và đánh giá sai artifact version (version mismatch). Hệ thống sinh issue CRITICAL (`EVALUATOR_UNAVAILABLE`) vào ledger, dừng loop với `EVALUATOR_ERROR` / `MISSING_EVALUATOR`, fail-closed, không bao giờ chuyển lỗi thành empty issues, score mặc định hoặc PASS. Khi evaluator tùy chọn (optional) bị bỏ qua theo policy, evaluator bắt buộc PASS cho phép chấp nhận artifact. |
| **T06-06** | Crash / Resume | **PASS** | `test_t06_06_durable_fault_state_1_post_grant_pre_generate`<br>`test_t06_06_durable_fault_state_2_post_draft_commit_pre_evaluate`<br>`test_t06_06_durable_fault_state_3_post_evaluate_pre_decision`<br>`test_t06_06_durable_fault_state_4_post_repair_draft_pre_reevaluate`<br>`test_t06_06_durable_fault_state_5_post_pass_commit`<br>`test_t06_06_crash_and_resume`<br>`test_budget_caps_exhaustion`<br>`T06_01_LoopCursor_SaveAndAdvance_RevisionIncrements`<br>`T06_02_LoopCursor_Conflict_ExpectedRevisionMismatch_Throws409`<br>`T06_03_LoopCursor_IdempotentReplay_SameRevisionAndPayload_ReturnsSuccess`<br>`run_phase06_real_postgres_integration.py` | Bơm process death tại 5 ranh giới durable: Sau grant, sau draft commit, sau evaluate reconcile, sau repair draft commit, và sau pass commit. Resumed runtime không lặp công việc đã commit (0 repeated calls), không reset budget, và fail-closed nếu gặp unacknowledged operation (UNKNOWN_OUTCOME). |
| **T06-07** | Dependency invalidation | **PASS** | `test_t06_07_stale_descendants_dependency_freshness`<br>`test_dependency_closure_invalidation`<br>`test_t06_persisted_descendant_invalidation_removes_heads`<br>`test_t06_parent_updated_during_evaluation_rejects_commit`<br>`test_t06_missing_parent_head_rejects_commit`<br>`T06_08_DependencyInvalidation_TransitiveClosure_RemovesDescendantHeads` | Cập nhật parent (passage) tự động invalidate toàn bộ descendants (questions, groups) theo transitive closure. Section không được PASS khi dependencies stale. Unrelated accepted refs giữ nguyên. |
| **T06-08** | Cancellation & Lease takeover | **PASS** | `test_t06_08_fenced_commit_rejects_stale_writer`<br>`test_t06_08_cancellation_before_accept`<br>`T06_04_LoopCursor_Fencing_StaleEpochOrRevokedLease_Throws409`<br>`run_phase06_real_postgres_integration.py` | Lease takeover (tăng epoch) hoặc cancellation (tăng cancel_version): Fenced commit và loop cursor update bị từ chối bằng HTTP 409 trên PostgreSQL thật. Accepted head không bị advance bởi stale worker. |

---

## 4. Kiểm định Termination và Shared Budgets

Đã chạy kiểm tra property-based với 81 tổ hợp trạng thái capability (FAIL, PASS, ERROR × same, cycle, fixed) trong finite caps:
- **Tất cả 81 kịch bản** đều dừng bounded trong `LoopState.COMPLETED` hoặc `LoopState.FAILED`.
- **Versions Used:** luôn $\le 3$ (max_versions cap).
- **Calls Used:** luôn $\le 9$ (max_total_calls cap).
- **Tokens Consumed:** luôn $\le 12,000$ (max_total_tokens cap).
- **Restart Không Reset:** Budget counters (`callsUsed`, `tokensUsed`, `wallTimeUsedSeconds`) được lưu tại `ReadingPaperRun` và phục hồi cumulatively qua `resume_state`, ngăn ngừa việc replay vô hạn sau crash.

---

## 5. Kết quả Integration Test với PostgreSQL Thật

Chạy trực tiếp qua script `scripts/refactor/run_phase06_real_postgres_integration.py` kết nối tới ASP.NET Core `exam-service` và PostgreSQL `exam_test_phase06`:

### Quy trình Demo Thực Tế
1. **Khởi động dịch vụ:** ASP.NET Core `exam-service` chạy trên `http://127.0.0.1:5098`, kết nối tới PostgreSQL `exam_test_phase06`. Health endpoint `/health` trả 200 OK.
2. **Khởi tạo:** Tạo Job `4f501e55-55d9-4e4d-86ab-8741c4e4beaf` và Run `run_578b6b7a0233` với lease owner UUID `12e5ba89-5957-43ef-8f89-9c9af14c78f5` và epoch 1.
3. **Commit Upstream Fixture Lineage:**
   - Commit `source_pack:sp_demo` v1 (topic "Renewable Geothermal", 1200 từ).
   - Commit `evidence_graph:eg_demo` v1 với parent trỏ vào `source_pack:sp_demo`.
   - Commit `exam_blueprint:bp_demo` v1 với parent trỏ vào `evidence_graph:eg_demo`.
4. **Passage Loop - Generation:** Generator sinh `passage_01` v1 với 950 từ (parent trỏ vào `exam_blueprint:bp_demo`).
5. **Passage Loop - Evaluation:** Evaluator phát hiện `SECTION_WORD_COUNT_OUT_OF_BOUNDS` (950 từ vượt quá giới hạn 915 từ). Ghi nhận issue CRITICAL vào ledger và DB. Trả FAIL.
6. **Passage Loop - Controller Decision:** Controller chọn `REPAIR` (reason: `REPAIRABLE_DEFECTS: 1 exact-target blockers`).
7. **Passage Loop - Repair:** Repairer cắt tỉa đoạn văn xuống 800 từ (trong khoảng 720–915 từ). Tạo `passage_01` v2.
8. **Passage Loop - Re-evaluation:** Evaluator đánh giá v2 đạt 800 từ. Trả PASS với `resolvedIssueFingerprints` chứa fingerprint của issue v1.
9. **Passage Loop - Acceptance:** Controller chọn `PASS`. Thực hiện `commit_checkpoint` thành công.
10. **Process Restart & Resume:** Khởi tạo instance `BoundedLoopRuntime` mới từ đầu cho cùng `run_id`. Resumed runtime gọi `resume_state`, nhận diện head v2 và fresh PASS evidence. Kết thúc ngay ở `COMPLETED` với **0 calls phát sinh thêm** (0 generator, 0 repairer, 0 evaluator).

### Xác minh Authoritative State trong PostgreSQL
- `reading_paper_artifacts`: Đúng 2 bản ghi bất biến cho `passage_01` (v1: 4790 bytes hash `dea97821cef24730a30a69fe0f0dcf3a616453e318d4ba56e08a53f7b07185c4`, v2: 4040 bytes hash `c89d571086d0d98986ab4e325db97d8c4d52d92c756822c1ea39659367e9dc6b`).
- `reading_paper_artifact_heads`: Trỏ chính xác vào version 2 với content hash `c89d571086d0d98986ab4e325db97d8c4d52d92c756822c1ea39659367e9dc6b`.
- `reading_paper_loop_cursors`: Revision đạt 8, lưu đầy đủ state JSON với `COMPLETED` state.
- `reading_paper_operations`: Đúng 8 operations hoàn thành: 4 CHECKPOINT_COMMIT, 1 GENERATE, 1 REPAIR, 2 EVALUATE.
- `reading_paper_artifact_dependencies`: Đúng 4 dependency edges được ghi nhận và kiểm chứng trong DB:
  * `passage_01` v2 $\rightarrow$ `exam_blueprint:bp_demo` v1
  * `passage_01` v1 $\rightarrow$ `exam_blueprint:bp_demo` v1
  * `exam_blueprint:bp_demo` v1 $\rightarrow$ `evidence_graph:eg_demo` v1
  * `evidence_graph:eg_demo` v1 $\rightarrow$ `source_pack:sp_demo` v1
- `reading_paper_issues`: Issue `SECTION_WORD_COUNT_OUT_OF_BOUNDS` được ghi nhận với severity `CRITICAL` và chuyển trạng thái thành `RESOLVED` trong PostgreSQL (đồng bộ 100% với in-memory ledger).
- `reading_paper_decisions`: Đúng 4 quyết định được ghi nhận trong DB: `source_pack:sp_demo` (PASS), `evidence_graph:eg_demo` (PASS), `exam_blueprint:bp_demo` (PASS), và `passage_01` v2 (PASS với reason code ACCEPTED).
- `reading_paper_runs`: Token consumption và call counts hạch toán đầy đủ trong DB (6000 tokens, 4 calls); kiểm chứng đẳng thức toán học nghiêm ngặt giữa trước và sau restart (pre-resume: calls=4, tokens=6000 == post-resume: calls=4, tokens=6000), chứng minh không bị reset về 0 và không bị gọi trùng lặp.
- `CheckpointAck`: Xác minh mã hóa cryptographic match chính xác giữa client và server (khớp runId, epoch, artifactId, version, contentHash, và server timestamp).

### Bơm Lỗi (Fault Injection) trên PostgreSQL Thật
- **Fault A (Stale Epoch Fencing):** Commit checkpoint với epoch 0 (trong khi DB là 1) bị từ chối với HTTP 409 (`Epoch fencing violation`).
- **Fault B (Job Cancellation Fencing):** Cập nhật `CancelVersion` trong DB; ghi cursor checkpoint muộn bị từ chối với HTTP 409 (`Run or Job has been cancelled`). Head trong PostgreSQL giữ nguyên tại version 2.
- **Fault C (Toàn bộ 5 Ranh giới Crash Recovery trên PostgreSQL Thật):**
  * *Window 1 (Post-grant pre-generate):* Operation được lưu `RESERVED` trong DB, tiến trình chết trước khi sinh draft. Resumed runtime nhận diện `UNKNOWN_OUTCOME`, kết thúc fail-closed với **0 generator calls**.
  * *Window 2 (Post-draft-commit pre-evaluate):* Draft v1 đã lưu trong DB và cursor ở `EVALUATING`. Resumed runtime tái sử dụng draft v1 từ DB, tiến hành đánh giá mà **không gọi generator (0 calls)**.
  * *Window 3 (Post-evaluate pre-decision):* Evaluation được reconcile trong DB. Resumed runtime tái sử dụng kết quả đánh giá trong DB mà **không gọi evaluator (0 calls)** hay generator.
  * *Window 4 (Post-repair-draft pre-reevaluate):* Repair draft v2 đã lưu trong DB. Resumed runtime tái sử dụng draft v2 mà **không gọi lại repairer (0 calls)**.
  * *Window 5 (Post-CAS-accepted-commit pre-cursor-ACK):* Commit checkpoint đã cập nhật CAS head lên v1 trong DB, tiến trình chết trước khi client lưu cursor ACK. Resumed runtime phát hiện accepted head trong DB, hoàn tất phiên làm việc mà **không sinh lại hay commit lại (0 generator calls)**.
---

## 6. Kết quả Regression Phases 00–06 (52 Test IDs)

Toàn bộ 52 test IDs từ Phase 00 đến Phase 06 đã được kiểm tra và ánh xạ đầy đủ:

- **Phase 00 (Discovery & Baseline):** T00-01 đến T00-06 — **6/6 PASS**
- **Phase 01 (Contracts & Policies):** T01-01 đến T01-06 — **6/6 PASS**
- **Phase 02 (Durable Checkpoints & Fencing):** T02-01 đến T02-09 — **9/9 PASS**
- **Phase 03 (Providers & Shared Budget):** T03-01 đến T03-08 — **7 PASS, 1 NOT_RUN_EXTERNAL** (T03-08 yêu cầu live cloud model credentials)
- **Phase 04 (Ingestion & EvidenceGraph):** T04-01 đến T04-08 — **8/8 PASS**
- **Phase 05 (Blueprint & Suitability):** T05-01 đến T05-07 — **7/7 PASS**
- **Phase 06 (Loop Runtime & Issue Ledger):** T06-01 đến T06-08 — **8/8 PASS**

**Tổng hợp:** **51 PASS, 1 NOT_RUN_EXTERNAL, 0 FAIL** trên tổng số 52 test IDs.

### Chi tiết Test Suites Đã Chạy:
- **.NET Suite (`dotnet test`):** **74 passed, 0 failed, 0 skipped** (Bao gồm 8 test durability mới trong `Phase06DurabilityTests.cs`).
- **Pytest Suite (`pytest`):** **176 passed, 0 failed, 1 skipped (total 177)** (`test_t03_provider_parity_live_smoke` là `NOT_RUN_EXTERNAL`).

---

## 7. Các Lỗi Đã Phát Hiện và Khắc Phục (Bug Fixes)

Trong quá trình verification, đã phát hiện và sửa chữa 8 lỗi kỹ thuật, contract và test coverage:

1. **DTO Parity Gap (`wallTimeReservationSeconds`):**
   - *Nguyên nhân:* C# `OperationGrantResult` đã bổ sung `wallTimeReservationSeconds`, nhưng model Python `OperationGrantResult` trong `app/persistence/models.py` thiếu trường này. Do `extra="forbid"`, Pydantic báo lỗi `extra_forbidden`.
   - *Khắc phục:* Bổ sung `wallTimeReservationSeconds: float = 60.0` vào `OperationGrantResult` trong `models.py`.

2. **JSON Alias Serialization Mismatch:**
   - *Nguyên nhân:* `CheckpointClient` trong `client.py` gọi `request.model_dump(mode="json")` mà không có `by_alias=True`. Kết quả là các trường gửi sang C# có dạng snake_case (`content_hash`, `parent_refs`) thay vì camelCase (`contentHash`, `parentRefs`).
   - *Khắc phục:* Cập nhật tất cả các lời gọi `model_dump` trong `client.py` thành `request.model_dump(mode="json", by_alias=True)`.

3. **Loop Runtime Scoping Bug trong `_restore`:**
   - *Nguyên nhân:* Tại `runtime.py:147`, kiểm tra `elif self._operations or self._drafts or self._accepted_head:` sử dụng toàn bộ operations của run thay vì lọc theo `target_artifact_id`. Khi một run đã có operations từ artifact trước (như Blueprint), artifact tiếp theo (Passage) bị lỗi `Durable work exists without a pinned loop cursor`.
   - *Khắc phục:* Lọc `self._operations` theo `target_artifact_id` hoặc tiền tố `loop:{run_id}:{target_artifact_id}:`.

4. **Cryptographic Content Hash Parity with Unsorted Payload Keys:**
   - *Nguyên nhân:* Python `compute_content_hash` sử dụng `canonical_json_dump` (sắp xếp khóa payload theo bảng chữ cái), trong khi C# `ComputeContentHash` sử dụng `System.Text.Json` với `JsonElement` giữ nguyên thứ tự khóa nhận được qua HTTP. Khi payload có từ 2 khóa trở lên không theo thứ tự alphabet, hash sinh ra bị lệch.
   - *Khắc phục:* Cập nhật `ArtifactContracts.cs` để sắp xếp đệ quy các thuộc tính của `JsonElement` bằng `WriteCanonicalElement` với `StringComparer.Ordinal`, đảm bảo hash 100% đồng nhất giữa C# và Python bất kể thứ tự khóa khi serialize.

5. **Issue Resolution Persistence Gap (`reading_paper_issues`):**
   - *Nguyên nhân:* Khi evaluation trên v2 pass, `result.resolved_issue_fingerprints` chỉ cập nhật trong in-memory `IssueLedgerManager`. Python `OperationReconcileRequest` thiếu `resolvedFingerprints` và C# `ReconcileOperationAsync`/`CommitCheckpointAsync` chỉ kiểm tra request mà không kiểm tra fingerprints từ `evalResult`. Dẫn đến row trong PostgreSQL vẫn ở trạng thái `OPEN`.
   - *Khắc phục:* Bổ sung `resolvedFingerprints` vào Python model, truyền `result.resolved_issue_fingerprints` khi reconcile, và cập nhật `CheckpointService.cs` để chuyển `reading_paper_issues` sang `RESOLVED`.

6. **Bổ sung Test Suite .NET cho Phase 06:**
   - *Khắc phục:* Đã bổ sung `services/exam-service.Tests/Phase06DurabilityTests.cs` gồm 8 test xUnit bao phủ `LoopCursorService`, `ResumeStateAsync`, authority fencing và dependency invalidation trên PostgreSQL thật.

7. **Bổ sung 4 Failure Mode Tests cho T06-05:**
   - *Khắc phục:* Bổ sung các test functions cho timeout, malformed output, wrong artifact version, và optional evaluator skipping vào `services/generation-service/tests/test_t06_loop_runtime.py`.

8. **Bổ sung Ca Kiểm Định Multi-Evaluator Soft Scores Cao Không Che Mờ Critical Blocker (T06-04):**
   - *Khắc phục:* Bổ sung test case chạy đồng thời 2 evaluators trả soft scores rất cao (0.99 và 0.95) cùng 1 evaluator trả critical issue (0.92, SCHEMA_VIOLATION). Điểm trung bình đạt 0.953 > 0.80, nhưng runtime vẫn kết thúc FAIL, chứng minh blocker invariant được bảo toàn tuyệt đối.
---

## 8. Các Giới Hạn và Blocker Còn Lại

1. **CONFIG_BLOCKER — Cấu hình Production Hard Caps chưa được chốt:**
   - *Yêu cầu kiểm định:* "Đọc limits đã chốt trong config. Nếu còn thiếu limit bắt buộc, ghi blocker; không tự coi defaults trong plan là production configuration đã xác nhận."
   - *Thực trạng code:* Các giới hạn runtime bắt buộc (`max_versions: 3`, `max_generated_versions: 3`, `max_repair_attempts_per_version: 2`, `max_total_repairs: 5`, `max_consecutive_no_progress: 2`, `max_oscillation_cycles: 2`, `max_total_calls: 15`, `max_total_tokens: 60,000`, `max_wall_time_seconds: 300.0`, `generate_token_reservation: 2500`, `repair_token_reservation: 1500`, `evaluate_token_reservation: 1000`) hiện chỉ là các giá trị mặc định được hardcode trên class `LoopPolicy` (`services/generation-service/app/loop/policy.py`). Chúng hoàn toàn vắng mặt trong cấu hình production `Settings` (`services/generation-service/app/config.py`) cũng như các file biến môi trường triển khai (`deploy/envs/*.env`).
   - *Hệ quả:* Hệ thống chưa có cấu hình production chính thức được xác nhận/chốt cho runtime caps; việc giả định các giá trị mặc định trong plan là cấu hình production đã được phê duyệt bị cấm rõ ràng theo chỉ thị nghiệm thu.
   - *Tác động Gate:* Đây là **BLOCKER** trực tiếp khiến Gate G06 phải mang trạng thái **BLOCKED** và Phase 07 mang trạng thái **BLOCKED** cho đến khi các giới hạn này được đưa vào `Settings` / file cấu hình chính thức.

2. **External Model Smoke Check (T03-08):**
   - `T03-08` duy trì trạng thái `NOT_RUN_EXTERNAL` do môi trường local không cấu hình live provider API keys. Toàn bộ logic adapter, defensive parsing và budget tracking đã pass 100% qua mock/recording fixtures.

---

## 9. Danh mục Hồ sơ Kiểm định (Artifacts Directory)

Tại `artifacts/refactor/verify-after-phase-06/`:
- `verification-report.md`: Báo cáo nghiệm thu chi tiết đầy đủ.
- `gate.json`: Báo cáo đánh giá Gate G06.
- `test-mapping.json`: Bảng ánh xạ chi tiết 52 test IDs từ Phase 00–06.
- `commands.jsonl`: Nhật ký lệnh thực tế kèm cwd, exitCode, duration, testCounts (đã redact secrets).
- `real-postgres-integration-report.json`: Kết quả demo integration và fault injection trên PostgreSQL thật.
- `test-results.trx`: Báo cáo kết quả 74 test .NET.
- `pytest-results.xml`: Báo cáo kết quả 177 test Python (176 passed, 1 skipped).
- `fault-traces.jsonl`: Dấu vết chi tiết các ca bơm lỗi (5 durable crash states + lease/cancellation fencing).
- `journal-traces.jsonl`: Dấu vết step journal của runtime.
- `artifact-refs-and-budget-snapshots.json`: Snapshots version transitions, content hashes, và budget tracker.
- `cap-enforcement-report.json`: Báo cáo kiểm định các giới hạn hard caps.
- `state-coverage-report.json`: Độ bao phủ các chuyển dịch trạng thái của state machine.

---

## 10. Kết Luận Cuối Cùng

- **Kết luận Gate G06:** **BLOCKED**  
  *Lý do:* Mặc dù toàn bộ 8/8 bài test T06-01..08 và 51/52 test IDs toàn dự án đã PASS về mặt thuật toán và độ bền transactional trên PostgreSQL thật, Gate G06 vẫn phải nhận kết luận **BLOCKED** theo đúng chỉ thị nghiệm thu: các giới hạn bắt buộc (caps) của runtime chưa được chốt/khai báo trong cấu hình production (`Settings`/config), mà mới chỉ tồn tại dưới dạng class defaults trong plan. Không được tự ý coi defaults là cấu hình production đã xác nhận.

- **Readiness cho Phase 07 (Evaluator & Repair Registries):** **BLOCKED**  
  *Lý do:* Cần bổ sung và chốt cấu hình chính thức cho các runtime caps trong `Settings` (`app/config.py` và `deploy/envs/`) trước khi cho phép Phase 07 tiến hành dựa trên các ngưỡng giới hạn production được phê chuẩn.
