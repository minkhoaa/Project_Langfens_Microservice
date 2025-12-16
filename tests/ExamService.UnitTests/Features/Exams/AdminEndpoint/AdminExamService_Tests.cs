// Assuming a clean project setup.
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace ExamService.UnitTests.Features.Exams.AdminEndpoint
{
    public class AdminExamService_Tests : IDisposable
    {
        private readonly ExamDbContext _dbContext;
        private readonly AdminExamService _sut;

        public AdminExamService_Tests()
        {
            _dbContext = ExamContextFactory.CreateInMemory();
            _sut = new AdminExamService(_dbContext);
        }

        public void Dispose() => _dbContext.Dispose();

        public static IEnumerable<object[]> AddExamTestCases()
        {
            // EC-003
            yield return new object[] { "Happy Path", new DtoAdmin.AdminExamCreate("Title", "slug", "Desc", "CAT", "LVL", 60), 200, "Create successfully" };
            // yield return new object[] { "Zero Duration", new DtoAdmin.AdminExamCreate("Title", "slug", "Desc", "CAT", "LVL", 0), 200, "Create successfully" };
            // yield return new object[] { "Negative Duration", new DtoAdmin.AdminExamCreate("Title", "slug", "Desc", "CAT", "LVL", -10), 200, "Create successfully" };
            // yield return new object[] { "Null Description", new DtoAdmin.AdminExamCreate("Title", "slug", null, "CAT", "LVL", 60), 200, "Create successfully" };
            // yield return new object[] { "Null Category", new DtoAdmin.AdminExamCreate("Title", "slug", "Desc", null, "LVL", 60), 200, "Create successfully" };
        }

        [Theory(DisplayName = "EC-003: Add Exam - {0}")]
        [MemberData(nameof(AddExamTestCases))]
        public async Task AddAsync_ShouldHandleValidation(string caseName, DtoAdmin.AdminExamCreate dto, int expectedStatus, string expectedMessage)
        {
            // Act
            var result = await _sut.AddAsync(dto, CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            httpResult.StatusCode.Should().Be(expectedStatus);

            var valueResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = valueResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            apiResult.message.Should().Contain(expectedMessage);
        }

        public static IEnumerable<object[]> ListExamsTestCase()
        {
            var now = DateTime.UtcNow;
            var exams = Enumerable.Range(1, 20).Select(i => new Exam
            {
                Id = Guid.NewGuid(), Title = $"Exam {i}", Slug = $"slug-{i}", CreatedAt = now.AddDays(-i), UpdatedAt = i % 2 == 0 ? now.AddHours(-i) : null
            }).ToList();
            
            // EC-004
            for(var i = 0; i < 11; i++)
            {
                yield return new object[] { exams.Take(i).ToList() };
            }
        }
        
        [Theory(DisplayName = "EC-004: ListAllAsync should return all exams")]
        [MemberData(nameof(ListExamsTestCase))]
        public async Task ListAllAsync_ShouldReturnAllExams(List<Exam> examList)
        {
            // Arrange
            _dbContext.Exams.AddRange(examList);
            await _dbContext.SaveChangesAsync();

            // Act
            var result = await _sut.ListAllAsync(CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            httpResult.StatusCode.Should().Be(200);
            var valueResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = valueResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            var list = apiResult.data.Should().BeAssignableTo<IEnumerable<object>>().Subject;
            list.Count().Should().Be(examList.Count);
        }
    }
}