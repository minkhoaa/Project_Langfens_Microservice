using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Features.Attempt.AttemptEndpoint;
using attempt_service.Features.Helpers;
using Google.Protobuf;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.Grpc.ExamInternal;
using Xunit;
using Dto = Shared.ExamDto.Contracts.Exam.InternalExamDto.InternalExamDto;

namespace attempt_service.Tests.Helpers;

public class AttemptSnapshotPrivacyTests
{
    [Fact]
    public async Task Start_resume_and_get_redact_private_explanation_and_leave_full_grading_snapshot_unchanged()
    {
        await using var db = new OfflineAttemptDbContext();
        var paper = exam_service.Application.Common.ProtoHelper.MapToProto(ExamServiceTestHost.Paper(), true);
        var gateway = new Mock<IExamGateway>();
        gateway.Setup(g => g.GetExamSnapshotAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>())).ReturnsAsync(paper);
        var service = Service(db, gateway.Object);
        AssertSafe(await service.StartAttempt(new(Guid.NewGuid()), default));
        var attempt = await db.Attempts.SingleAsync();
        var full = attempt.PaperJson!.RootElement.GetRawText();
        Assert.Contains("private-explanation", full);
        Assert.Contains("private-blank", full);
        AssertSafe(await service.StartAttempt(new(attempt.ExamId), default));
        AssertSafe(await service.GetAttemptById(attempt.Id, default));
        Assert.Equal(full, (await db.Attempts.AsNoTracking().SingleAsync()).PaperJson!.RootElement.GetRawText());
        Assert.Equal("private-explanation", paper.Sections[0].QuestionGroups[0].Questions[0].ExplanationMd);
        Assert.True(paper.Sections[0].QuestionGroups[0].Questions[0].Options[0].IsCorrect);
    }

    [Fact]
    public async Task Legacy_rest_fallback_redacts_models_and_keys_without_mutating_saved_snapshot()
    {
        await using var db = new OfflineAttemptDbContext();
        var paper = new Dto.InternalDeliveryExam
        {
            Id = Guid.NewGuid(), Title = "Public title",
            Sections = [new Dto.InternalDeliverySection
            {
                Id = Guid.NewGuid(),
                QuestionGroups = [new Dto.InternalDeliveryQuestionGroup
                {
                    Id = Guid.NewGuid(),
                    Questions = [new Dto.InternalDeliveryQuestion
                    {
                        Id = Guid.NewGuid(), PromptMd = "Public prompt", ExplanationMd = "private-explanation",
                        ModelAnswers = ["private-model"],
                        Options = [new Dto.InternalDeliveryOption { Id = Guid.NewGuid(), IsCorrect = true }],
                        BlankAcceptTexts = new Dictionary<string, string[]?> { ["1"] = ["private-blank"] }
                    }]
                }]
            }]
        };
        // Legacy JSON with a duplicate scalar is accepted by System.Text.Json,
        // but rejected by protobuf; exercise the real REST fallback branch.
        var json = JsonSerializer.Serialize(paper).Replace("\"title\":\"Public title\"", "\"title\":\"old\",\"title\":\"Public title\"");
        var parser = new JsonParser(JsonParser.Settings.Default.WithIgnoreUnknownFields(true));
        Assert.Throws<InvalidProtocolBufferException>(() => parser.Parse<InternalDeliveryExam>(json));
        var attempt = new attempt_service.Domain.Entities.Attempt
        {
            Id = Guid.NewGuid(), UserId = UserId, ExamId = paper.Id, DurationSec = 3600, PaperJson = JsonDocument.Parse(json)
        };
        db.Attempts.Add(attempt);
        await db.SaveChangesAsync();
        var service = Service(db, Mock.Of<IExamGateway>());
        AssertSafe(await service.StartAttempt(new(paper.Id), default));
        AssertSafe(await service.GetAttemptById(attempt.Id, default));
        Assert.Equal(json, (await db.Attempts.AsNoTracking().SingleAsync()).PaperJson!.RootElement.GetRawText());
        Assert.Equal("private-model", paper.Sections[0].QuestionGroups[0].Questions[0].ModelAnswers![0]);
    }

    [Fact]
    public async Task Unreadable_resume_snapshot_fails_closed_instead_of_returning_raw_json()
    {
        await using var db = new OfflineAttemptDbContext();
        var attempt = new attempt_service.Domain.Entities.Attempt
        {
            Id = Guid.NewGuid(), UserId = UserId, ExamId = Guid.NewGuid(),
            PaperJson = JsonDocument.Parse("{\"sections\":\"private-unreadable-snapshot\"}")
        };
        db.Attempts.Add(attempt);
        await db.SaveChangesAsync();
        var result = await Service(db, Mock.Of<IExamGateway>()).StartAttempt(new(attempt.ExamId), default);
        Assert.Equal(500, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.DoesNotContain("private-", JsonSerializer.Serialize(Assert.IsAssignableFrom<IValueHttpResult>(result).Value));
    }

    private static readonly Guid UserId = Guid.NewGuid();

    private static AttemptService Service(OfflineAttemptDbContext db, IExamGateway gateway)
    {
        var user = new Mock<IUserContext>();
        user.SetupGet(u => u.UserId).Returns(UserId);
        return new AttemptService(db, gateway, user.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }

    private static void AssertSafe(IResult result)
    {
        var response = Assert.IsType<ApiResultDto>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.True(response.isSuccess);
        var json = JsonSerializer.Serialize(response.data);
        Assert.Contains("Public", json);
        Assert.DoesNotContain("private-", json);
    }
}
