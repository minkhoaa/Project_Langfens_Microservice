// Rewriting all ExamService tests to use simple using statements and correct project references.
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.InternalEndpoint;
using exam_service.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;
using Shared.ExamDto.Contracts;
using Xunit;
using Section = exam_service.Domains.Entities.ExamSection;
using Question = exam_service.Domains.Entities.ExamQuestion;
using Option = exam_service.Domains.Entities.ExamOption;

namespace ExamService.UnitTests.Features.Exams.InternalEndpoint
{
    public class InternalExamService_Tests : IDisposable
    {
        private readonly ExamDbContext _dbContext;
        private readonly InternalExamService _sut;
        public InternalExamService_Tests()
        {
            _dbContext = ExamContextFactory.CreateInMemory();
            _sut = new InternalExamService(_dbContext);
        }

        public void Dispose() => _dbContext.Dispose();

        [Theory]
        [InlineData(true)]
        [InlineData(false)]
        public async Task GetByExamIdAsync_Should_Include_Or_Omit_Answers(bool showAnswer)
        {
            var exam = new Exam { Id = Guid.NewGuid(), Slug = "slug", Title = "Title", Sections = new List<Section> { new Section { Title = "Title", Questions = new List<Question> { new Question { Type = "T", Skill = "S", PromptMd = "P", Options = new List<Option> { new Option { ContentMd = "C", IsCorrect = true } } } } } } };
            _dbContext.Exams.Add(exam);
            await _dbContext.SaveChangesAsync();

            var result = await _sut.GetByExamIdAsync(exam.Id, CancellationToken.None, showAnswer);

            var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
            var valueResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = valueResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            var payload = apiResult.data.Should().BeAssignableTo<InternalExamDto.InternalDeliveryExam>().Subject;
            var option = payload.Sections.First().Questions.First().Options.First();
            (option.IsCorrect == true).Should().Be(showAnswer);
        }
    }
}
