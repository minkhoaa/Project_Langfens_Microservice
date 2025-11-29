# UNIT TEST RULES FOR MICROSERVICES

## 1. SCOPE
Target: All classes ending in `Service.cs` or `Manager.cs` located inside folders named `*-service`.
Goal: Achieve >80% code coverage for Business Logic.

## 2. TECH STACK
- Framework: xUnit
- Mocking: Moq
- Data: Bogus
- Assertions: FluentAssertions

## 3. REQUIRED TEST STRUCTURE
Every test class must follow this exact template:

```csharp
using Xunit;
using Moq;
using FluentAssertions;
using Bogus;
// Add other usings...

namespace [OriginalNamespace].UnitTests;

public class [ServiceName]Tests
{
    // Mocks for ALL constructor dependencies
    private readonly Mock<IRepository> _mockRepo; // Example
    private readonly [ServiceName] _sut; // System Under Test
    private readonly Faker _faker;

    public [ServiceName]Tests()
    {
        _faker = new Faker();
        _mockRepo = new Mock<IRepository>();
        // Initialize other mocks...

        _sut = new [ServiceName](_mockRepo.Object);
    }

    [Fact]
    public async Task MethodName_Scenario_ExpectedResult()
    {
        // Arrange
        // Act
        // Assert
    }
}