# Langfens Agent Prompt Pack V2

Bộ prompt thực thi mới cho toàn bộ Phase 00–15. Mỗi phase có prompt implementation/remediation và prompt independent verification. Các prompt yêu cầu agent thực hiện vòng reproduce → fix → verify → sửa findings → kiểm lại, sử dụng long-running sessions/subagents khi khả dụng và giao đầu ra chuẩn.

Đây là prompt pack, không phải báo cáo rằng Langfens code hoặc gates đã PASS. Plan gốc, policy và Validation Matrix được giữ làm source of truth.

## Dùng ngay ở trạng thái hiện tại

1. Đặt folder `langfens-agent-prompts-v2` trong `docs/refactor/` của repository thật, cạnh plan gốc nếu phù hợp. Giữ nguyên plan, evidence và dirty changes đã có.
2. Nếu muốn agent tự điều phối tới cuối scope: copy prompt trong `01-ORCHESTRATOR-PROMPT.md`. Prompt khám phá trạng thái, ưu tiên xử lý G07/G08 hiện tại và reuse foundation evidence còn hợp lệ.
3. Nếu chỉ muốn sửa và hoàn tất G07/G08 trước: dùng `02-G07-G08-RECOVERY-PROMPT.md`, sau đó supervisor có thể tiếp tục Phase09–15 khi prerequisites đạt.
4. Nếu muốn tự giao từng phase: dùng hai phần implementation và verify trong file `phases/phase-NN-*.md`. Để cả pack trong repo để agent đọc hợp đồng chung; không chỉ copy một phần rồi bỏ mất contract/plan inputs.
5. Dùng `04-FINAL-VERIFICATION-PROMPT.md` trên candidate cuối. Independent reviewer giao findings về supervisor để sửa/retest, không kết thúc bằng một report lỗi chưa có hướng xử lý.

`PROMPTS-ALL.md` là bản ghép đầy đủ để tìm/copy một file. Các file riêng là nguồn; không sửa bản ghép độc lập rồi gây lệch.

## Những điểm thay đổi trong execution

| Vấn đề | Yêu cầu mới |
|---|---|
| Verify rồi kết thúc với BLOCKED | Reproduce, assign owner, implement fix, reviewer recheck; blocker còn lại có concrete remedy |
| Chỉ isolated interfaces/unit tests | Actual service composition/entrypoint, semantic coverage, fault/integration và accepted-output assertions |
| Chạy tác vụ dài nhưng không quản lý | Session/campaign IDs, poll/await, logs/exit codes, checkpoint/resume, no phantom background |
| Chia agents tùy tiện | File ownership, non-overlapping writes, independent review, isolated DB/resources và supervisor integration |
| Mọi thiếu sót gọi external | Tách bugs, implementation NOT_RUN, invalid corpus và genuine external prerequisites |
| PASS dựa code cũ/HEAD | HEAD + dirty/untracked hashes + config/corpus versions và impacted revalidation |
| Tăng retries/caps để đạt | Giữ versioned hard limits, required checks/thresholds; sửa root cause |

## Báo cáo phase chưa đạt cần gì

Finding ID và severity, repro command, expected/observed, root cause, fix đã thử, test result, remaining code/config/data work, exact missing external input nếu có, next command và owner. Agent phải hoàn tất phần có thể xử lý trước khi handoff.

Long-running không có nghĩa chạy vô hạn: supervise tiến độ, đổi hypothesis khi không tiến triển, tôn trọng caps/budget/quyền/platform và lưu resumable checkpoint khi bị giới hạn. Same-model subagents cho review chéo quy trình, không phải bằng chứng reviewers/model outputs độc lập thống kê.

## Trạng thái xuất phát từ báo cáo đã nhận

G07 còn upstream quality blocker; G08 được báo chưa có generator/prompts/tests và tồn tại false-PASS paths ở grounding. MiniMax transport smoke đã PASS ở snapshot báo cáo. Agent phải kiểm lại current code trước hành động, không suy đoán thiếu credential hoặc áp dụng máy móc findings đã được sửa.

Chính sách mặc định cho toàn bộ các phase:
- **Live Benchmark tự động:** Mọi live benchmark bắt buộc tự động khởi chạy và resume bằng provider MiniMax đã cấu hình; loại bỏ phê duyệt thủ công của operator, authorization-file, phê duyệt campaign budget và các trạng thái chờ PENDING_AUTHORIZATION.
- **Unlimited Caps cho MiniMax Benchmarks:** Vô hiệu hóa toàn bộ call, token, monetary và wall-time caps do ứng dụng áp đặt cho MiniMax BENCHMARKS ở cả campaign và child-run level (cấu hình explicit unlimited; cấm fallback về 15 calls / 60k tokens / 300s). Profile production và các provider khác giữ nguyên.
- **Bảo toàn guardrails & truthful accounting:** Giữ nguyên xác thực service, CAS/fencing, cancellation, truthful usage accounting, checkpoints, idempotent resume, bounded retries và per-request output/context limits; tôn trọng giới hạn thực tế từ phía provider.
- **Tách biệt phục hồi cục bộ và gate:** R05 durability trên PostgreSQL thật có thể PASS độc lập trong khi G09 vẫn giữ nợ chất lượng upstream/live-quality (G07/G08 prerequisites); tuyệt đối không promote gate chỉ vì đã gỡ bỏ rào cản phê duyệt.
- **Mặc định toàn hệ thống:** Chính sách này áp dụng mặc định cho tất cả các phase còn lại, ngăn quy trình phê duyệt thủ công xuất hiện lại.
