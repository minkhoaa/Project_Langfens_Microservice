// Assuming a clean project setup.
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace ExamService.UnitTests.Features.Exams.AdminEndpoint.QuestionEndpoint
{
    public class AdminQuestionService_Tests : IDisposable
    {
        private readonly ExamDbContext _dbContext;
        private readonly AdminQuestionService _sut;

        public AdminQuestionService_Tests()
        {
            _dbContext = ExamContextFactory.CreateInMemory();
            _sut = new AdminQuestionService(_dbContext);
        }

        public void Dispose() => _dbContext.Dispose();

        public static IEnumerable<object[]> AddQuestionTestCases()
        {
            var sectionId = Guid.NewGuid();
            var sectionWithAudio = new ExamSection { Id = sectionId, AudioUrl = "http://audio.com/a.mp3", Title = "Title" };
            var sectionWithoutAudio = new ExamSection { Id = sectionId, AudioUrl = " ", Title = "Title" };
            var baseDto = new DtoAdmin.AdminQuestionUpsert(sectionId, null, QuestionType.MultipleChoiceSingle, "Reading", 1, "Prompt", null, null, null, null, null, null, null);

            // ES-003, ES-004
            yield return new object[] { "Listening with no audio URL", sectionWithoutAudio, baseDto with { Skill = QuestionSkill.Listening }, 400, "missing audioUrl" };
            yield return new object[] { "Listening with audio URL", sectionWithAudio, baseDto with { Skill = QuestionSkill.Listening }, 200, "Created question successfully" };
            yield return new object[] { "Reading with no audio URL", sectionWithoutAudio, baseDto with { Skill = "Reading" }, 200, "Created question successfully" };
            yield return new object[] { "OrderCorrects cleanup", sectionWithAudio, baseDto with { OrderCorrects = new List<string> { "A", " ", "B", null } }, 200, "Created question successfully" };
            yield return new object[] { "ShortAnswerTexts cleanup", sectionWithAudio, baseDto with { ShortAnswerAcceptTexts = new List<string> { "One", null, "" } }, 200, "Created question successfully" };
            yield return new object[] { "ShortAnswerRegex cleanup", sectionWithAudio, baseDto with { ShortAnswerAcceptRegex = new List<string> { ".*", " " } }, 200, "Created question successfully" };
            yield return new object[] { "Section not found", null, baseDto, 400, "Not found section" };
            yield return new object[] { "Valid DTO", sectionWithAudio, baseDto, 200, "Created question successfully" };

        }

        [Theory(DisplayName = "ES-003/004: Add Question - {0}")]
        [MemberData(nameof(AddQuestionTestCases))]
        public async Task AddQuestion_ShouldHandleValidation(string caseName, ExamSection section, DtoAdmin.AdminQuestionUpsert dto, int expectedStatus, string expectedMessage)
        {
            // Arrange
            if (section != null)
            {
                _dbContext.ExamSections.Add(section);
                await _dbContext.SaveChangesAsync();
            }

            // Act
            var result = await _sut.AddAsync(CancellationToken.None, dto);
            
            // Assert
            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            httpResult.StatusCode.Should().Be(expectedStatus);
            var valueResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = valueResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            apiResult.message.Should().Contain(expectedMessage);
        }
    }
}