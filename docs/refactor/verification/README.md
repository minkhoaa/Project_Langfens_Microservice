# Verification files

`test-manifest.json` liệt kê test IDs từ 16 phase và giữ trạng thái PLANNED. Đây là planning manifest, không phải results.

Copy `phase-gate.template.json` vào actual repo evidence directory, điền phase/gate, SHA/config/corpus và requiredTestIds từ manifest. `checks` có từng object gồm `testId`, `required`, `status`, `commandRef`, `evidencePaths`, `observed`, `expected`. `commands` ghi command/cwd/exitCode/start/end UTC. Secrets được redacted.

Runner do Phase 00 xây phải kiểm tra: required IDs đều có kết quả PASS, nonzero test count, evidence exists, commands có exit code đúng, không required skip, dependencies hợp SHA/config; required external tests có live report. Mọi failure/missing check chặn gate. Không dùng template này để tự stamp PASS.

Status conventions và test/quality thresholds nằm trong `01-validation-matrix.md`. Khi các phase sau thay shared schema/policy/runtime, rerun impacted predecessor checks và record updated SHA; old pass trên commit khác không tự chứng minh release mới.
