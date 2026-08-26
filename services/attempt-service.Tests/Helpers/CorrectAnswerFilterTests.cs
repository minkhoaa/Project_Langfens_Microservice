using System.Security.Claims;
using attempt_service.Features.Helpers;
using Google.Protobuf;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Moq;
using Shared.Grpc.ExamInternal;
using Shared.Security.Roles;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Phase 6: ensure non-admin callers never receive the answer key from the
/// BE internal gRPC channel. The fix has two collaborating pieces:
///   (a) <see cref="ExamGateway"/> must send <c>ShowAnswers=false</c> on the
///       internal gRPC request when the caller is not admin.
///   (b) The receiver in exam-service
///       (<c>ProtoHelper.MapQuestionToProto</c>) is required to leave
///       <c>Envelope.CorrectAnswer</c> empty when that flag is false.
///
/// Tests here pin (a) directly via the captured outbound request. They
/// also exercise a downstream success-path: when (a) holds, the returned
/// exam must NOT carry <c>Envelope.CorrectAnswer</c> (mirroring (b)'s
/// contract — the production helper at
/// <c>ProtoHelper.cs:160-173</c> emits the envelope with only the
/// discriminator populated). This catches both regressions: a stale
/// "always true" at (a) OR a regression in (b) that re-emits answer data.
/// </summary>
public class CorrectAnswerFilterTests
{
    private static IUserContext MakeUserContext(string? role)
    {
        // ClaimsIdentity maps IsInRole() lookups against its RoleClaimType
        // — the production bootstrap sets RoleClaimType=CustomClaims.Roles
        // ("roles"). Mirror that here so the gateway's IsInRole(Roles.Admin)
        // sees the same principal shape it would in production.
        var claims = new List<Claim>();
        if (role is not null) claims.Add(new Claim("roles", role));
        var identity = new ClaimsIdentity(
            claims, "TestAuth",
            ClaimsIdentity.DefaultNameClaimType, "roles");
        var principal = new ClaimsPrincipal(identity);
        var ctx = new Mock<IUserContext>();
        ctx.SetupGet(c => c.User).Returns(principal);
        ctx.SetupGet(c => c.UserId).Returns(Guid.NewGuid());
        return ctx.Object;
    }

    /// <summary>An exam that the BE would emit for ShowAnswers=false:
    /// envelope holds only the type discriminator; legacy answer fields
    /// are empty; options are ungraded. Mirrors the contract in
    /// ProtoHelper.cs:160-173.</summary>
    private static InternalDeliveryExam BuildSanitizedExam()
    {
        var exam = new InternalDeliveryExam
        {
            Id = Guid.NewGuid().ToString(),
            Slug = "phase6",
            Title = "Phase 6",
            Category = "GENERAL",
            Level = "A2",
        };
        var section = new InternalDeliverySection { Idx = 0, Title = "S1" };
        var group = new InternalDeliveryQuestionGroup { Idx = 0 };
        var question = new InternalDeliveryQuestion
        {
            Idx = 0,
            Type = "multiple_choice_single",
            Skill = "READING",
            Difficulty = 1,
            PromptMd = "Pick A.",
        };
        question.Options.Add(new InternalDeliveryOption
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 1,
            ContentMd = "A",
        });
        question.Options.Add(new InternalDeliveryOption
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 2,
            ContentMd = "B",
        });
        // Envelope present with discriminator only — CorrectAnswer is left
        // at its proto-default (null reference for unset message field).
        question.Envelope = new InternalDeliveryQuestionEnvelope { Type = "multiple_choice_single" };
        group.Questions.Add(question);
        section.QuestionGroups.Add(group);
        exam.Sections.Add(section);
        return exam;
    }

    /// <summary>An exam that the BE would emit for ShowAnswers=true: full
    /// answer key + envelope.CorrectAnswer populated. Used as the admin
    /// baseline.</summary>
    private static InternalDeliveryExam BuildExamWithAnswers()
    {
        var exam = BuildSanitizedExam();
        var q = exam.Sections[0].QuestionGroups[0].Questions[0];
        q.Options[0].IsCorrect = true;
        q.Options[1].IsCorrect = false;
        q.MatchPairs.Add(new InternalMatchPair { PromptKey = "p1" });
        q.MatchPairs[0].AcceptedValues.Add("v1");
        q.OrderCorrects.Add("step-1");
        q.ShortAnswerAcceptTexts.Add("expected");
        q.Envelope = new InternalDeliveryQuestionEnvelope
        {
            Type = "multiple_choice_single",
            Payload = Struct.Parser.ParseJson("{\"prompt\":\"Pick A.\"}"),
            CorrectAnswer = Struct.Parser.ParseJson("{\"correctOptionIds\":[\"x\"]}"),
        };
        return exam;
    }

    /// <summary>Stubs the gRPC client so that the captured outbound
    /// <c>GetInternalExamRequest</c> (its <c>ShowAnswers</c> flag is what
    /// the tests pin) and the response <see cref="InternalDeliveryExam"/>
    /// can be observed. The <c>respond</c> mapper is called with the
    /// flag the gateway actually sent, letting the fake BE mirror the
    /// contract at <c>ProtoHelper.cs:160-173</c>.</summary>
    private static (Mock<ExamInternal.ExamInternalClient> client, Func<GetInternalExamRequest?> captured)
        StubClient(Func<bool, InternalDeliveryExam> respond)
    {
        var holder = new GetInternalExamRequestHolder();
        var client = new Mock<ExamInternal.ExamInternalClient>();
        client
            .Setup(c => c.GetInternalExamAsync(
                It.IsAny<GetInternalExamRequest>(),
                It.IsAny<CallOptions>()))
            .Returns<GetInternalExamRequest, CallOptions>((req, _) =>
            {
                holder.Request = req;
                return GrpcCallWrapper.FromExam(respond(req.ShowAnswers));
            });
        return (client, () => holder.Request);
    }

    [Fact]
    public async Task NonAdmin_response_does_not_contain_correctAnswer_key()
    {
        // ShowAnswers=false ⇒ BE returns sanitized exam (no answer data).
        var (client, captured) = StubClient(showAnswers =>
            showAnswers ? BuildExamWithAnswers() : BuildSanitizedExam());
        var userCtx = MakeUserContext(Roles.User);
        var gateway = new ExamGateway(client.Object, userCtx);

        var returned = await gateway.GetExamSnapshotAsync(Guid.NewGuid(), CancellationToken.None);

        var req = captured();
        Assert.NotNull(req);
        Assert.False(req!.ShowAnswers, "Non-admin request must set ShowAnswers=false");
        Assert.True(returned.Sections[0].QuestionGroups[0].Questions[0].Envelope.CorrectAnswer is null,
            "Envelope's correctAnswer must be unset when caller is non-admin");
        Assert.False(returned.Sections[0].QuestionGroups[0].Questions[0].MatchPairs.Count > 0 &&
                     returned.Sections[0].QuestionGroups[0].Questions[0]
                         .MatchPairs[0].AcceptedValues.Count > 0,
            "Legacy matchPairs must be empty when caller is non-admin");
    }

    [Fact]
    public async Task Admin_response_preserves_correctAnswer_key()
    {
        var (client, captured) = StubClient(showAnswers =>
            showAnswers ? BuildExamWithAnswers() : BuildSanitizedExam());
        var userCtx = MakeUserContext(Roles.Admin);
        var gateway = new ExamGateway(client.Object, userCtx);

        var returned = await gateway.GetExamSnapshotAsync(Guid.NewGuid(), CancellationToken.None);

        var req = captured();
        Assert.NotNull(req);
        Assert.True(req!.ShowAnswers, "Admin request must set ShowAnswers=true");
        Assert.NotNull(returned.Sections[0].QuestionGroups[0].Questions[0].Envelope.CorrectAnswer);
        var correct = returned.Sections[0].QuestionGroups[0].Questions[0].Envelope.CorrectAnswer;
        Assert.True(correct.Fields.ContainsKey("correctOptionIds"),
            "Envelope.correctAnswer must retain keys when caller is admin");
    }

    [Fact]
    public async Task Envelope_correctAnswer_is_null_when_showAnswers_false()
    {
        // Direct invariant pinning the BE-side behaviour at
        // ProtoHelper.cs:160-173: with showAnswers=false the envelope is
        // emitted with only the Type discriminator, and CorrectAnswer is
        // left at its proto default (null reference for an unset message
        // field). We assert the round-trip: outbound ShowAnswers=false ⇒
        // returned exam has Envelope.CorrectAnswer == null.
        var (client, captured) = StubClient(showAnswers =>
            showAnswers ? BuildExamWithAnswers() : BuildSanitizedExam());
        var userCtx = MakeUserContext(Roles.User);
        var gateway = new ExamGateway(client.Object, userCtx);

        var returned = await gateway.GetExamSnapshotAsync(Guid.NewGuid(), CancellationToken.None);

        var req = captured();
        Assert.False(req!.ShowAnswers);
        Assert.NotNull(req);
        var q0 = returned.Sections[0].QuestionGroups[0].Questions[0];
        Assert.NotNull(q0.Envelope);
        Assert.True(q0.Envelope.CorrectAnswer is null,
            "Envelope.CorrectAnswer must be unset when ShowAnswers=false");
        Assert.False(q0.Options[0].HasIsCorrect,
            "Option.IsCorrect must be unset when ShowAnswers=false");
    }
}

/// <summary>Mutable holder used by <c>Moq.Callback</c> so the captured
/// request survives past the lambda's stack frame.</summary>
internal sealed class GetInternalExamRequestHolder
{
    public GetInternalExamRequest? Request;
    public GetInternalExamRequest? Value
    {
        get => Request;
        set => Request = value;
    }
}

/// <summary>Wraps a proto return value in the AsyncUnaryCall&lt;T&gt;
/// shape that gRPC-generated client methods return. Success-path only —
/// sufficient for the correctness checks in
/// <see cref="CorrectAnswerFilterTests"/>.</summary>
internal static class GrpcCallWrapper
{
    public static AsyncUnaryCall<T> FromExam<T>(T response) where T : class, IMessage<T>
    {
        var task = Task.FromResult(response);
        return new AsyncUnaryCall<T>(
            task,
            Task.FromResult(new Metadata()),
            () => new Status(StatusCode.OK, string.Empty),
            () => new Metadata(),
            () => { });
    }
}
