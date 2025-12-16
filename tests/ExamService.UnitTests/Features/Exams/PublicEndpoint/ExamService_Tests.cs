// Assuming a clean project setup.

using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using ExamSection = exam_service.Domains.Entities.ExamSection;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using PublicExamService = exam_service.Features.Exams.PublicEndpoint.ExamService;
using Xunit;

namespace ExamService.UnitTests.Features.Exams.PublicEndpoint
{

    public class PublicExamService_Tests : IDisposable
    {
        private readonly ExamDbContext _dbContext;
        private readonly exam_service.Features.Exams.PublicEndpoint.ExamService _sut;

        public PublicExamService_Tests()
        {
            _dbContext = ExamContextFactory.CreateInMemory();
            _sut = new exam_service.Features.Exams.PublicEndpoint.ExamService(_dbContext);
        }

        public void Dispose()
        {
            _dbContext.Dispose();
        }

        private static List<Exam> GetSeedExams()
        {
            return Enumerable.Range(1, 20).Select(i => new Exam
            {
                Id = Guid.NewGuid(),
                Title = $"Exam {i}",
                Slug = $"slug-{i}",
                Category = i % 3 == 0 ? "IELTS" : "TOEIC",
                Level = i % 2 == 0 ? "B2" : "C1",
                Status = i <= 15 ? ExamStatus.Published : ExamStatus.Draft, // 15 published exams
                UpdatedAt = DateTime.UtcNow.AddHours(-i)
            }).ToList();
        }

        public static IEnumerable<object[]> ListPublishedTestCases()
        {
            // EC-005
            yield return new object[] { null, null, 1, 10, 10 }; // Case 1: No filters, page 1
            yield return new object[] { null, null, 2, 10, 5 };  // Case 2: No filters, page 2
            yield return new object[] { "IELTS", null, 1, 10, 5 }; // Case 3: Filter by category
            yield return new object[] { null, "B2", 1, 10, 7 };  // Case 4: Filter by level
            yield return new object[] { "IELTS", "B2", 1, 10, 2 }; // Case 5: Filter by category and level
            yield return new object[] { "VSTEP", null, 1, 10, 0 }; // Case 6: No match category
            yield return new object[] { null, "A1", 1, 10, 0 };    // Case 7: No match level
            yield return new object[] { null, null, 1, 5, 5 };  // Case 8: Page size 5
            yield return new object[] { null, null, 3, 5, 5 };  // Case 9: Page 3, size 5
            yield return new object[] { "TOEIC", "C1", 1, 10, 5 }; // Case 10
            yield return new object[] { "IELTS", "C1", 1, 10, 3 }; // Case 11: Filter by category and level (C1)
        }

        [Theory(DisplayName = "EC-005: List Published Exams")]
        [MemberData(nameof(ListPublishedTestCases))]
        public async Task ListPublishedAsync_ShouldFilterAndPaginate(string category, string level, int page, int pageSize, int expectedCount)
        {
            // Arrange
            var exams = GetSeedExams();
            _dbContext.Exams.AddRange(exams);
            await _dbContext.SaveChangesAsync();

            // Act
            var result = await _sut.ListPublishedAsync(category, level, page, pageSize, CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            httpResult.StatusCode.Should().Be(200);
            var valueResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = valueResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            var list = apiResult.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>().Subject;
            list.Count().Should().Be(expectedCount);
        }

        public static IEnumerable<object[]> GetBySlugTestCases()
        {
            // EC-006
            var fullExam = new Exam { Slug = "full-exam", Title = "Full Exam", Status = ExamStatus.Published, Sections = new List<ExamSection> { new ExamSection { Idx = 1, Title = "Section 1" } } };
            yield return new object[] { "full-exam", new List<Exam> { fullExam }, 200, false };
            yield return new object[] { "non-existent-slug", new List<Exam>(), 404, true };
            yield return new object[] { "draft-exam", new List<Exam> { new Exam { Slug = "draft-exam", Title = "Draft Exam", Status = ExamStatus.Draft } }, 200, false };
            for (int i = 0; i < 8; i++) // Generate 8 more cases
            {
                var slug = $"test-slug-{i}";
                yield return new object[] { slug, new List<Exam> { new Exam { Slug = slug, Title = $"Exam {i}", Status = ExamStatus.Published } }, 200, false };
            }
            yield return new object[] { "archived-exam", new List<Exam> { new Exam { Slug = "archived-exam", Title = "Archived Exam", Status = ExamStatus.Archived } }, 200, false };
        }

        [Theory(DisplayName = "EC-006: Get Exam by Slug")]
        [MemberData(nameof(GetBySlugTestCases))]
        public async Task GetBySlugAsync_ShouldReturnCorrectExam(string slug, List<Exam> exams, int expectedStatus, bool expectNull)
        {
            // Arrange
            _dbContext.Exams.AddRange(exams);
            await _dbContext.SaveChangesAsync();

            // Act
            var result = await _sut.GetBySlugAsync(slug, CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            httpResult.StatusCode.Should().Be(expectedStatus);
            var valueResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = valueResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            (apiResult.data is null).Should().Be(expectNull);
        }
    }
}
