w# Test Automation Report

Đây là runbook và báo cáo tổng hợp cho hệ thống test automation của project Langfens Microservice.

## 1. Tổng quan

- **Frameworks**: xUnit, FluentAssertions, Moq
- **Projects**: .NET 8 Minimal APIs, TypeScript (Frontend)
- **Coverage**: Unit, Integration
- **Infrastructure**: Testcontainers (Postgres, Redis), MockHttp

## 2. Cách chạy tests

### 2.1. Backend (.NET)

Chạy toàn bộ solution test:
```bash
dotnet test /home/khoa/RiderProjects/Project_Langfens_Microservice/tests/LangfensEnglish.Tests.sln
```

Chạy một project cụ thể:
```bash
dotnet test /home/khoa/RiderProjects/Project_Langfens_Microservice/tests/AuthService.UnitTests/AuthService.UnitTests.csproj
```

### 2.2. Frontend (TypeScript)

*Phần này sẽ được cập nhật sau khi cấu hình projct frontend.*

```bash
# Lệnh sẽ được thêm ở đây (ví dụ: npm test)
```

## 3. Cấu trúc Solution Tests

```
/tests
  /LangfensEnglish.Tests.Common  (Helpers, Fakes, Builders)
  /AuthService.UnitTests
  /EmailService.UnitTests
  (*Các project khác sẽ được thêm sau*)
  /LangfensEnglish.Tests.sln
  /TEST_AUTOMATION_REPORT.md      (File này)
  /TEST_COVERAGE.md
```

## 4. Requirement to Code Mapping

Bảng này được tạo ở **STEP 1 (DISCOVERY)** và sẽ được cập nhật liên tục.

| Requirement ID | Target Type                                               | Target Method(s)                                                                                             | Test Project(s)          | Level(s)             |
|----------------|-----------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|--------------------------|----------------------|
| **AU-001..017**  | `auth_service.Application.Auth.AuthService`               | `RegisterAsync`, `PasswordLoginAsync`, `RefreshAsync`, `LogoutAsync`, `GetCurrentUserAsync`, `ConfirmEmail`, `ResendEmail` | `AuthService.UnitTests`  | Unit                 |
| **OE-001..009**  | `auth_service.Infrastructure.Redis.RedisOtpStore`         | `Verify`, `CanResend`                                                                                        | `AuthService.UnitTests`  | Unit                 |
|                | `email_service.Features.Service.EmailSender`              | `SendOtpAsync`, `VerifyOtpAsync`                                                                             | `EmailService.UnitTests` | Unit                 |
|                | `email_service.Features.Worker.UserRegisteredSendOtpConsumer` | `Consume`                                                                                                    | `EmailService.UnitTests` | Unit (với TestHarness) |
| **EC-001..009**  | `exam_service.Application.Common.SlugHelper`              | *(pending discovery)*                                                                                        | `ExamService.UnitTests`  | Unit                 |
| ...            | *(pending discovery)*                                     | *(pending discovery)*                                                                                        | ...                      | ...                  |

---
*Báo cáo này được tạo và cập nhật tự động.*