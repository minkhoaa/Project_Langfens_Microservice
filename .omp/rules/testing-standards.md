---
description: Testing standards for .NET (xUnit, AwesomeAssertions, Moq, WebApplicationFactory) and Python (pytest, pytest-asyncio, mocks).
globs:
  - "**/*Test*.cs"
  - "**/tests/**/*.py"
  - "**/test_*.py"
---

# Testing Standards & Quality Rules

## 1. Test-Driven Development (TDD) Workflow
- Follow Red-Green-Refactor strictly:
  1. Write failing unit/regression test demonstrating the requirement or bug.
  2. Implement minimal production code to pass the test.
  3. Refactor for readability, immutability, and performance.
- Strive for 80%+ test coverage across domain logic, scorers, and data converters.

## 2. .NET xUnit Standards
- Structure every test with the **Arrange-Act-Assert (AAA)** pattern.
- Descriptive test naming: `[MethodUnderTest]_[Scenario]_[ExpectedBehavior]`:
  ```csharp
  [Fact]
  public async Task GradeAsync_WithInvalidAnswerFormat_ReturnsZeroScoreAndDiagnostic()
  {
      // Arrange ...
      // Act ...
      // Assert ...
  }
  ```
- Use `FluentAssertions` or `AwesomeAssertions` for expressive assertion messages.
- Mock external services using `Moq` or `NSubstitute`; verify called contracts.
- Isolate unit tests: unit tests (e.g., `attempt-service.Tests`) must run offline without requiring running databases or network services.
- Integration tests requiring real infrastructure (e.g. `exam-service.Tests`) must clearly specify prerequisites (running PostgreSQL on port 5433).

## 3. Python pytest Standards
- Configure `asyncio_mode = auto` in `pytest.ini`.
- Use `unittest.mock.AsyncMock` and `pytest.mark.asyncio` for async handlers:
  ```python
  @pytest.mark.asyncio
  async def test_groq_service_fallback_on_rate_limit(mocker):
      ...
  ```
- Separate live integration / E2E tests using custom markers (e.g., `@pytest.mark.live` skipped unless explicitly requested with `--run-live`).
- Ensure mock fixtures cleanly restore application state in `finally` or teardown blocks.
