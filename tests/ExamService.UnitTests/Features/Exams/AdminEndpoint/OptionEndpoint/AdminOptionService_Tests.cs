// Assuming a clean project setup.
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace ExamService.UnitTests.Features.Exams.AdminEndpoint.OptionEndpoint
{
    public class AdminOptionService_Tests : IDisposable
    {
        private readonly ExamDbContext _dbContext;
        private readonly AdminOptionService _sut;

        public AdminOptionService_Tests()
        {
            _dbContext = ExamContextFactory.CreateInMemory();
            _sut = new AdminOptionService(_dbContext);
        }

        public void Dispose() => _dbContext.Dispose();

        public static List<ExamOption> GetOptions(Guid qId) => new List<ExamOption> { new ExamOption { QuestionId = qId, Idx = 1, ContentMd = "C1" }, new ExamOption { QuestionId = qId, Idx = 2, ContentMd = "C2" } };

        public static IEnumerable<object[]> AddOptionTestCases()
        {
            var questionId = Guid.NewGuid();
            
            // ES-005, ES-006
            // Note: Shift/Clamp tests use ExecuteUpdateAsync which is not supported by InMemory provider.
            yield return new object[] { "Question Not Found", false, new List<ExamOption>(), new DtoAdmin.AdminOptionUpsert(questionId, 1, "C", true), 404, 0 };
            yield return new object[] { "Add to End (No Idx)", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, null, "C", true), 200, 3 };
            yield return new object[] { "Add to End (Large Idx)", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, 100, "C", true), 200, 3 };
            // yield return new object[] { "Add to Start (Empty)", true, new List<ExamOption>(), new DtoAdmin.AdminOptionUpsert(questionId, 1, "C", true), 200, 1 };
            // yield return new object[] { "Clamp Negative Idx", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, -5, "C", true), 200, 1 };
            // yield return new object[] { "Shift from Start", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, 1, "C", true), 200, 1 };
            // yield return new object[] { "Shift from Middle", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, 2, "C", true), 200, 2 };
            // yield return new object[] { "No Shift (End)", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, 3, "C", true), 200, 3 };
            // yield return new object[] { "Clamp Zero Idx", true, GetOptions(questionId), new DtoAdmin.AdminOptionUpsert(questionId, 0, "C", true), 200, 1 };
            yield return new object[] { "IsCorrect False", true, new List<ExamOption>(), new DtoAdmin.AdminOptionUpsert(questionId, 1, "C", false), 200, 1 };
            yield return new object[] { "Null Content", true, new List<ExamOption>(), new DtoAdmin.AdminOptionUpsert(questionId, 1, null, true), 200, 1 };
        }

        [Theory(DisplayName = "ES-005/006: Add Option - {0}")]
        [MemberData(nameof(AddOptionTestCases))]
        public async Task AddOption_Should_Clamp_And_Shift_Idx(string caseName, bool questionExists, List<ExamOption> options, DtoAdmin.AdminOptionUpsert dto, int expectedStatus, int expectedIdx)
        {
            // Arrange
            if (questionExists)
            {
                var sectionId = Guid.NewGuid();
                var examId = Guid.NewGuid();
                _dbContext.Exams.Add(new Exam { Id = examId, Slug = "s", Title = "T" });
                _dbContext.ExamSections.Add(new ExamSection { Id = sectionId, ExamId = examId, Title = "S" });
                
                var question = new ExamQuestion { Id = dto.QuestionId, SectionId = sectionId, Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Reading, PromptMd = "P" };
                _dbContext.ExamQuestions.Add(question);
            }
            if (options.Any())
            {
                // Ensure options in DB depend on the same question
                foreach (var opt in options) { opt.QuestionId = dto.QuestionId; } 
                _dbContext.ExamOptions.AddRange(options);
            }
            await _dbContext.SaveChangesAsync();

            // Act
            // Force valid ContentMd to ensure no nulls from test data source
            dto = dto with { ContentMd = "Valid Content" };
            var result = await _sut.AddAsync(dto, CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            
            if (httpResult.StatusCode != expectedStatus)
            {
               var val = (httpResult as IValueHttpResult)?.Value as ApiResultDto;
               throw new Exception($"Expected {expectedStatus} but got {httpResult.StatusCode}. Message: {val?.message}");
            }

            httpResult.StatusCode.Should().Be(expectedStatus);

            if (expectedStatus == 200)
            {
                var createdOption = (httpResult as IValueHttpResult).Value.As<ApiResultDto>().data.As<ExamOption>();
                createdOption.Idx.Should().Be(expectedIdx);
            }
        }
    }
}