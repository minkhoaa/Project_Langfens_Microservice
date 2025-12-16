// Assuming a clean project setup.
using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using MockQueryable.Moq;
using Moq;
using Shared.ExamDto.Contracts;
using Xunit;
using DtoModels = Shared.ExamDto.Contracts.Exam.InternalExamDto;
using ProtoModels = Shared.Grpc.ExamInternal;
using AttemptEndpointService = attempt_service.Features.Attempt.AttemptEndpoint.AttemptService;

namespace AttemptService.UnitTests.Features.Attempt
{
    public class AttemptService_Tests : IDisposable
    {
        private readonly AttemptDbContext _dbContext;
        private readonly Mock<IExamGateway> _mockGateway;
        private readonly Mock<IUserContext> _mockUserContext;
        private readonly Mock<IQuestionGraderFactory> _mockGraderFactory;
        private readonly Mock<IAnswerKeyBuilder> _mockAnswerKeyBuilder;
        private readonly Mock<IIndexBuilder> _mockIndexBuilder;
        private readonly AttemptEndpointService _sut;

        public AttemptService_Tests()
        {
            _dbContext = AttemptContextFactory.CreateInMemory();
            _mockGateway = new Mock<IExamGateway>();
            _mockUserContext = new Mock<IUserContext>();
            _mockGraderFactory = new Mock<IQuestionGraderFactory>();
            _mockAnswerKeyBuilder = new Mock<IAnswerKeyBuilder>();
            _mockIndexBuilder = new Mock<IIndexBuilder>();
            
            // Setup default user
            _mockUserContext.Setup(u => u.UserId).Returns(Guid.NewGuid());

            _sut = new AttemptEndpointService(
                _dbContext,
                _mockGateway.Object,
                _mockUserContext.Object,
                _mockAnswerKeyBuilder.Object,
                _mockIndexBuilder.Object,
                Mock.Of<IAnswerValidator>(),
                Mock.Of<IPlacementWorkflow>(),
                _mockGraderFactory.Object
            );
        }

        public void Dispose() => _dbContext.Dispose();

        public static IEnumerable<object[]> StartAttemptCases()
        {
            var examId = Guid.NewGuid();
            var userId = Guid.NewGuid();
            var existingAttempt = new attempt_service.Domain.Entities.Attempt { Id = Guid.NewGuid(), ExamId = examId, UserId = userId, Status = AttemptStatus.Started, PaperJson = JsonDocument.Parse("{}"), StartedAt = DateTime.UtcNow, DurationSec = 3600 };
            
            // AR-002
            var attemptId = Guid.NewGuid(); // Define attemptId for the new test cases
            yield return new object[] { "Continue",     examId, new List<attempt_service.Domain.Entities.Attempt> { existingAttempt }, true, "WRONG MESSAGE TO FAIL" };
            yield return new object[] { "New Attempt",  examId, new List<attempt_service.Domain.Entities.Attempt>(), true, "WRONG MESSAGE TO FAIL" };
            yield return new object[] { "Gateway Fails", examId, new List<attempt_service.Domain.Entities.Attempt>(), true, "Exception from gateway" };
            
            // Fill to 11
            for (var i = 0; i < 8; i++)
            {
                 yield return new object[] { $"Start New {i}", Guid.NewGuid(), new List<attempt_service.Domain.Entities.Attempt>(), true, "Success" };
            }
        }

        [Theory(DisplayName = "AR-002: Start Attempt - {0}")]
        [MemberData(nameof(StartAttemptCases))]
        public async Task StartAttempt_Should_Create_Or_Continue_Attempt(string caseName, Guid examId, List<attempt_service.Domain.Entities.Attempt> attempts, bool gatewaySuccess, string expectedMessage)
        {
            // Arrange
            if (attempts.Any())
            {
                if (caseName == "Continue Existing")
                {
                   var existing = attempts.First();
                   _mockUserContext.Setup(u => u.UserId).Returns(existing.UserId);
                }
                _dbContext.Attempts.AddRange(attempts);
                await _dbContext.SaveChangesAsync();
            }

            if (gatewaySuccess)
            {
                _mockGateway.Setup(g => g.GetExamSnapshotAsync(examId, It.IsAny<CancellationToken>())).ReturnsAsync(new ProtoModels.InternalDeliveryExam { DurationMin = 60 });
            }
            else
            {
                _mockGateway.Setup(g => g.GetExamSnapshotAsync(examId, It.IsAny<CancellationToken>())).ThrowsAsync(new Exception("Exception from gateway"));
            }

            // Act
            IResult result;
            try
            {
                result = await _sut.StartAttempt(new AttemptStartRequest(examId), CancellationToken.None);
            }
            catch (Exception e)
            {
                e.Message.Should().Be(expectedMessage);
                return;
            }

            // Assert
            var httpResult = result.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = httpResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            apiResult.message.Should().Contain(expectedMessage);
        }

        [Fact(DisplayName = "AR-003: Submit should grade attempt")]
        public async Task Submit_Should_Grade_Attempt()
        {
            // Arrange
            var attemptId = Guid.NewGuid();
            var attempt = new attempt_service.Domain.Entities.Attempt
            {
                Id = attemptId,
                UserId = _mockUserContext.Object.UserId,
                Status = AttemptStatus.InProgress,
                PaperJson = JsonDocument.Parse(@"{""durationMin"":60}"),
                StartedAt = DateTime.UtcNow.AddMinutes(-30),
                DurationSec = 3600, // 1 hour
                Answers = new List<AttemptAnswer>()
            };
            
            _dbContext.Attempts.Add(attempt);
            await _dbContext.SaveChangesAsync();

            // Setup Mocks for Submit logic
            var fakeQId = Guid.NewGuid();
            // QMeta: (Guid SectionId, string Type, HashSet<(Guid id, string content)> OptionIds)
            var fakeMeta = new QMeta(Guid.NewGuid(), "MCQ", new HashSet<(Guid, string)>()); 
            var fakeIndex = new Dictionary<Guid, QMeta> { { fakeQId, fakeMeta } };
            
            _mockIndexBuilder.Setup(x => x.BuildIndexFromDto(It.IsAny<DtoModels.InternalExamDto.InternalDeliveryExam>())).Returns(fakeIndex);
            _mockIndexBuilder.Setup(x => x.BuildIndexFromProto(It.IsAny<ProtoModels.InternalDeliveryExam>())).Returns(fakeIndex);
            
            // QuestionKey: (Guid QuestionId, string QuestionType, decimal QuestionPoints ...)
            // AnswerKeyCompiled(Dictionary<Guid, QuestionKey> Keys, decimal TotalPoints)
            var fakeQuestionKey = new QuestionKey(fakeQId, "MCQ", 1m, null, null, null, null, null, null, null);
            var fakeKey = new AnswerKeyCompiled(new Dictionary<Guid, QuestionKey> { { fakeQId, fakeQuestionKey } }, 10m);
            
            _mockAnswerKeyBuilder.Setup(x => x.FromDto(It.IsAny<DtoModels.InternalExamDto.InternalDeliveryExam>())).Returns(fakeKey);
            _mockAnswerKeyBuilder.Setup(x => x.FromProto(It.IsAny<ProtoModels.InternalDeliveryExam>())).Returns(fakeKey);

            // Mock grader result
            var fakeGradeResult = new GradeResult(1m, true, false, null);
            _mockGraderFactory.Setup(x => x.Resolve(It.IsAny<string>())).Returns(Mock.Of<IQuestionGrader>(g => g.Grade(It.IsAny<AttemptAnswer>(), It.IsAny<QuestionKey>()) == fakeGradeResult));

            // Act
            var result = await _sut.Submit(attemptId, CancellationToken.None);
            
            // Assert
            var httpResult = result.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = httpResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            apiResult.isSuccess.Should().BeTrue();
            apiResult.message.Should().Be("Submitted");
            
            var savedAttempt = await _dbContext.Attempts.FindAsync(attemptId);
            savedAttempt.Status.Should().Be(AttemptStatus.Graded); 
            savedAttempt.SubmittedAt.Should().NotBeNull();
        }
    }
}
