# Source traceability và assumptions register

## 1. Nguồn đầu vào

`exam-generation-architecture.md`, bản đính kèm ngày 30/09/2026. SHA-256: `f3544ab04c628750edabe38ffccb900d6b4f6156a0c488418b7a9ce731a61297`.

Tài liệu mô tả architecture; chưa kiểm chứng bằng repo. Plan sử dụng các business constraints, services và workflows được mô tả; không coi các câu “100% không hallucination” hay 3–5 phút là số liệu quality/SLA đã xác minh.

## 2. Mapping behavior → phase/test

| Ref | Mục trong nguồn | Behavior dùng làm baseline | Coverage V2 |
|---|---|---|---|
| SRC-01 | 1. Tổng quan | Next.js → YARP → .NET worker/PostgreSQL → Python | G00 inventory, G12 worker, G13 UI/API |
| SRC-02 | 2.1 router.py | 4 public routes, `/section` NDJSON | T00-01/02, T13-01/02 |
| SRC-03 | 2.1 extractor.py | Europe PMC CC-BY/CC0, min 600, universal ingestion/SSRF/excerpt | T04-01/02/06/08 |
| SRC-04 | 2.1 llm.py | MiniMax/Groq, thinking cleanup, JSON parsing, 429 retry | T03-01…08; new policies thay fixed 65s |
| SRC-05 | 2.2 phase 1 | 720–915 words, section styles, bounded extension | T08-01/04, blueprint policies |
| SRC-06 | 2.2 phase 2 | 5 fidelity issue types, revision fail-closed | T04-04/05, T07-07, T08-02/05 |
| SRC-07 | 2.2 phase 3 | 13/13/14, 6 types, exact answer/evidence, ≤3 words/numbers | T01-05/06, T05-01, T09-01/02/04 |
| SRC-08 | 2.2 phase 4 | Blind review + surgical replacement | T10-01…08, T11-02/04 |
| SRC-09 | 3. Flow 1 | Lease/heartbeat, checkpoint SectionsJson, Retry, NeedsSources | T02-03…06, T11-05/06, T12-05 |
| SRC-10 | 3. Flow 1 final | Overall 2150–2750, 40 questions, shingle/graph validation | T12-01…04/06/07 |
| SRC-11 | 3. Flow 1 Draft | Admin final editorial approval | T12-08, T15-04 |
| SRC-12 | 3. Flow 2 | Manual CRUD/media/Draft/Publish | T00-05, T13-08, T14-04, T15-08 |

## 3. Đề xuất mới cần ADR/repo validation

| Assumption/decision | Trạng thái | Chốt ở đâu |
|---|---|---|
| Exact paths/DTO/errors/stream schema | Chưa có repo | G00 |
| Pipeline behavior docs vs actual code | Có thể khác | G00 inventory và approved ADR |
| Canonical domain schema, NG exception, severity | Proposed | G01 |
| .NET owns durable artifacts qua checkpoint API | Proposed architectural default | G01 ADR, G02 DB/auth integration |
| Fencing epoch/CAS/outbox/operation reservation | Proposed reliability requirement | G02 |
| Unknown LLM outcome accounting | Proposed, provider capability dependent | G02–G03 |
| Active provider models/SDK/credential scope | Chưa xác minh; tên model cũ không pin V2 | G03 live smoke |
| Universal-source licensing rights workflow | Baseline chưa mô tả đầy đủ | G00, G04 |
| Stable offset code-point convention | Proposed cross-language contract | G01, G04 |
| Evidence extraction/entailment adequacy | New capability; quality unknown | G04, G07 benchmark |
| Heuristic difficulty/concentration/similarity limits | Chưa calibrated/chốt numeric values | G00–G01 policy, G05/G07 reports |
| Candidate pool/default attempt caps | Proposed, budget dependent | G03, G06, G09 |
| Paper evaluation/repair internal capability | New, cần .NET integration | G12 |
| Feedback tables/curation/export workflow | New | G14 |
| Quality/latency/cost thresholds, canary sample/window | Proposed release criteria | Freeze G00–G01, measure G15 |
| Legacy deletion exact paths/callers/in-flight runs | Chưa biết | G00 inventory, G15 evidence |

## 4. Các điểm không được suy đoán

Không tạo current-version IDs/schema names giả; không báo provider billing/model availability đã xác minh; không tự cho URL/text unknown-license là approved; không nói NG có positive evidence giống TRUE/FALSE; không suy ra same-model review là độc lập thống kê.

Không biến confidence score thành IELTS band/difficulty probability. Không hiểu artifact ack/replay là cloud LLM calls exactly-once. Không coi semantic audit là mathematical guarantee không hallucination. Không report phase PASS hoặc old files đã xóa khi chỉ có plan.

## 5. Scope exclusions

Không rewrite toàn exam-service/gateway/admin portal; không đổi Listening/Writing/Speaking generation; không tự huấn luyện/fine-tune model; không tự deploy candidate prompt từ production feedback. Manual exam flow được giữ và regression test; feedback capture chỉ additive.

Repo discovery có thể phát hiện thiếu protections/bugs so với tài liệu. Các điểm đó cần ticket và scope decision rõ ràng; không bỏ invariant để giữ một bug vì gọi là parity.
