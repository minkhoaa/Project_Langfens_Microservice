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
- Reuse installed xUnit, AwesomeAssertions, and Moq where the affected project references them; do not add an alternative test framework for style alone.
- Unit tests must be deterministic and isolated from databases, live LLMs, and network services.
- Some exam fixtures reset schemas or delete persisted data. Phase02/Phase03 include hardcoded targets and Phase02 can overwrite environment configuration: a DSN override does not isolate the suite. Inspect each selected fixture, isolate every full-suite target from real data, and preserve existing database-test serialization.
- Cover consumer-visible scoring, boundaries, invariants, errors, and state transitions; do not test source strings, copied defaults, or mock echoes.

## 3. Python pytest Standards
- Configure `asyncio_mode = auto` in `pytest.ini`.
- Use `unittest.mock.AsyncMock` and `pytest.mark.asyncio` for async handlers:
  ```python
  @pytest.mark.asyncio
  async def test_groq_service_fallback_on_rate_limit(mocker):
      ...
  ```
- AI `tests/e2e` live tests also run without `--run-live` when endpoints are reachable; the flag bypasses reachability skipping, not an opt-in gate. Use `-m "not live"` for explicit offline exclusion. Do not assume generation-service supports that flag.
- Run each Python service from its own directory/environment; both expose a top-level `app` package.
- Ensure fixtures restore application state and external resources reliably.
- AI conftest stubs missing ML dependencies. Test doubles do not prove real inference, provider credentials, or container connectivity.

## 4. Verification Scope
- Use `/skill:langfens-verify` for repository commands and prerequisites.
- CI currently deploys without automated test stages; report exact locally exercised checks.
- Configuration-only changes require config parsing and native discovery smoke checks. Do not start Aspire, reset databases, invoke paid providers, or claim application tests passed for a configuration task.
