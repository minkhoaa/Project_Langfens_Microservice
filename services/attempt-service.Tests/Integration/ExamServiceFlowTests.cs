using Google.Protobuf;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Shared.Grpc.ExamInternal;
using Xunit;

namespace attempt_service.Tests.Integration;

/// <summary>
/// Integration tests for the attempt-service ↔ exam-service wire: the
/// <see cref="attempt_service.Features.Attempt.ExamGateway"/> is the only
/// outbound dependency attempt-service has on exam-service, and these
/// tests pin its contract end-to-end. A mock gRPC client returns a fully
/// populated <see cref="InternalDeliveryExam"/> (Sections → QuestionGroups
/// → Questions → <see cref="InternalDeliveryQuestionEnvelope"/>) that
/// mirrors what exam-service emits after the admin POST that lives in
/// exam-service. The gateway's job is to flatten the answer key into a
/// <c>Dictionary&lt;questionId, json&gt;</c> that the rest of
/// <c>AttemptFlow</c> consumes. These tests exercise that path directly
/// without spinning up a real exam-service, so they run as part of
/// <c>dotnet test</c> with no infrastructure.
/// </summary>
public sealed class ExamServiceFlowTests
{
    /// <summary>Stubs the gRPC client so the captured outbound request
    /// (<c>GetInternalExamRequest</c>) and the response
    /// <see cref="InternalDeliveryExam"/> can be observed by the test.</summary>
    private static (Mock<ExamInternal.ExamInternalClient> client,
                    Func<GetInternalExamRequest?> captured)
        StubClient(Func<GetInternalExamRequest, InternalDeliveryExam> respond)
    {
        var holder = new GetInternalExamRequestHolder();
        var mock = new Mock<ExamInternal.ExamInternalClient>();
        mock.Setup(c => c.GetInternalExamAsync(
                It.IsAny<GetInternalExamRequest>(),
                It.IsAny<Metadata>(),
                It.IsAny<DateTime?>(),
                It.IsAny<CancellationToken>()))
            .Returns((GetInternalExamRequest req, Metadata _, DateTime? _, CancellationToken _) =>
            {
                holder.Request = req;
                return GrpcCallWrapper.Success(respond(req));
            });
        return (mock, () => holder.Request);
    }

    private static InternalDeliveryQuestion MakeQuestionWithEnvelope(
        string id, string typeSlug, string correctJson)
    {
        return new InternalDeliveryQuestion
        {
            Id = id,
            Idx = 0,
            Type = typeSlug,
            Envelope = new InternalDeliveryQuestionEnvelope
            {
                Type = typeSlug,
                CorrectAnswer = Struct.Parser.ParseJson(correctJson),
            },
        };
    }

    private static attempt_service.Features.Attempt.ExamGateway BuildGateway(
        Mock<ExamInternal.ExamInternalClient> mock)
    {
        return new attempt_service.Features.Attempt.ExamGateway(
            mock.Object, NullLogger<attempt_service.Features.Attempt.ExamGateway>.Instance);
    }

    [Fact]
    public async Task GetCorrectAnswersAsync_flattens_sections_groups_questions_into_id_to_json_map()
    {
        // Arrange — three questions across one section / two groups, each
        // with a correct-answer envelope. Mirrors the post-admin-POST
        // shape that exam-service emits.
        var q1 = Guid.NewGuid();
        var q2 = Guid.NewGuid();
        var q3 = Guid.NewGuid();
        var section = new InternalDeliverySection
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 0,
            Title = "Section A",
        };
        section.QuestionGroups.Add(new InternalDeliveryQuestionGroup
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 0,
            StartIdx = 0,
            EndIdx = 1,
            Questions =
            {
                MakeQuestionWithEnvelope(q1.ToString(), "MULTIPLE_CHOICE_SINGLE", """{"correctOptionId":"a"}"""),
                MakeQuestionWithEnvelope(q2.ToString(), "TRUE_FALSE_NOT_GIVEN", """{"correctAnswer":true}"""),
            },
        });
        section.QuestionGroups.Add(new InternalDeliveryQuestionGroup
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 1,
            StartIdx = 2,
            EndIdx = 2,
            Questions =
            {
                MakeQuestionWithEnvelope(q3.ToString(), "SHORT_ANSWER", """{"acceptedAnswers":["paris"]}"""),
            },
        });
        var examId = Guid.NewGuid();
        var exam = new InternalDeliveryExam
        {
            Id = examId.ToString(),
            Slug = "ielts-reading-test-1",
            Title = "IELTS Reading Test 1",
            Category = "READING",
            Level = "B1",
            DurationMin = 60,
        };
        exam.Sections.Add(section);

        var (client, captured) = StubClient(_ => exam);
        var gw = BuildGateway(client);

        // Act
        var map = await gw.GetCorrectAnswersAsync(examId, showAnswers: true, CancellationToken.None);

        // Assert — one entry per question, ids are Guids, json values are
        // the Struct->JSON projection (contains the original keys).
        Assert.Equal(3, map.Count);
        Assert.True(map.ContainsKey(q1));
        Assert.True(map.ContainsKey(q2));
        Assert.True(map.ContainsKey(q3));
        Assert.Contains("\"correctOptionId\"", map[q1]);
        Assert.Contains("\"correctAnswer\"", map[q2]);
        Assert.Contains("paris", map[q3]);
        Assert.Equal(examId.ToString(), captured()!.ExamId);
        Assert.True(captured()!.ShowAnswers);
    }

    [Fact]
    public async Task GetCorrectAnswersAsync_skips_questions_with_empty_correct_answer_when_showAnswers_false()
    {
        // Arrange — admin POST's envelope was sanitized (showAnswers=false
        // means exam-service leaves correct_answer as an empty Struct).
        // The gateway must not surface empty entries; showAnswers=true
        // populates them.
        var q1 = Guid.NewGuid();
        var q2 = Guid.NewGuid();
        var section = new InternalDeliverySection
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 0,
            Title = "Section A",
        };
        section.QuestionGroups.Add(new InternalDeliveryQuestionGroup
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 0,
            StartIdx = 0,
            EndIdx = 1,
            Questions =
            {
                // q1 has an empty correct_answer (sanitized output).
                MakeQuestionWithEnvelope(q1.ToString(), "MULTIPLE_CHOICE_SINGLE", "{}"),
                // q2 has the real correct_answer.
                MakeQuestionWithEnvelope(q2.ToString(), "MULTIPLE_CHOICE_SINGLE", """{"correctOptionId":"b"}"""),
            },
        });
        var examId = Guid.NewGuid();
        var exam = new InternalDeliveryExam { Id = examId.ToString(), Slug = "x", Title = "y" };
        exam.Sections.Add(section);

        var (client, _) = StubClient(_ => exam);
        var gw = BuildGateway(client);

        // Act
        var map = await gw.GetCorrectAnswersAsync(examId, showAnswers: false, CancellationToken.None);

        // Assert — only the populated envelope surfaces; the sanitized
        // empty Struct is dropped (mirrors exam-service's ProtoHelper contract).
        Assert.Single(map);
        Assert.True(map.ContainsKey(q2));
        Assert.False(map.ContainsKey(q1));
    }

    [Fact]
    public async Task GetPaperJsonAsync_returns_paper_with_questions_keyed_by_section()
    {
        // Arrange — section with one question group containing one
        // question; envelope carries type + payload + correctAnswer.
        var sectionId = Guid.NewGuid();
        var questionId = Guid.NewGuid();
        var examId = Guid.NewGuid();
        var section = new InternalDeliverySection
        {
            Id = sectionId.ToString(),
            Idx = 0,
            Title = "Section A",
            InstructionsMd = "Read the passage.",
            PassageMd = "Lorem ipsum.",
        };
        section.QuestionGroups.Add(new InternalDeliveryQuestionGroup
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 0,
            StartIdx = 0,
            EndIdx = 0,
            InstructionMd = "Choose A, B, or C.",
            Questions =
            {
                new InternalDeliveryQuestion
                {
                    Id = questionId.ToString(),
                    Idx = 0,
                    Type = "multiple_choice_single",
                    Skill = "READING",
                    Envelope = new InternalDeliveryQuestionEnvelope
                    {
                        Type = "MULTIPLE_CHOICE_SINGLE",
                        Payload = Struct.Parser.ParseJson("""{"prompt":"Pick one","options":[{"id":"a","text":"A"},{"id":"b","text":"B"}]}"""),
                        CorrectAnswer = Struct.Parser.ParseJson("""{"correctOptionId":"a"}"""),
                    },
                },
            },
        });
        var exam = new InternalDeliveryExam
        {
            Id = examId.ToString(),
            Slug = "paper-test",
            Title = "Paper Test",
            Category = "READING",
            Level = "B1",
            DurationMin = 60,
        };
        exam.Sections.Add(section);

        var (client, _) = StubClient(_ => exam);
        var gw = BuildGateway(client);

        // Act
        var paper = await gw.GetPaperJsonAsync(examId, CancellationToken.None);

        // Assert — paper shape matches what AttemptFlow.SubmitAsync iterates.
        Assert.Equal(examId, paper.Id);
        Assert.Single(paper.Sections);
        var s = paper.Sections[0];
        Assert.Equal(sectionId, s.Id);
        Assert.Equal("Section A", s.Title);
        Assert.Equal("Read the passage.", s.PassageMd);
        Assert.Single(s.Questions);
        var q = s.Questions[0];
        Assert.Equal(questionId, q.Id);
        Assert.Equal("MULTIPLE_CHOICE_SINGLE", q.Type);
        Assert.Equal("READING", q.Skill);
        Assert.NotNull(q.CorrectAnswer);
        Assert.Equal(JsonValueKind.Object, q.CorrectAnswer!.Value.ValueKind);
    }
}

/// <summary>Mutable holder used by <c>Moq.Callback</c> so the captured
/// request survives past the lambda's stack frame.</summary>
internal sealed class GetInternalExamRequestHolder
{
    public GetInternalExamRequest? Request { get; set; }
}

/// <summary>Wraps a proto return value in the AsyncUnaryCall&lt;T&gt&gt;
/// shape that gRPC-generated client methods return. Success-path only —
/// sufficient for the correctness checks in
/// <see cref="ExamServiceFlowTests"/>.</summary>
internal static class GrpcCallWrapper
{
    public static AsyncUnaryCall<T> Success<T>(T value) where T : class
    {
        return new AsyncUnaryCall<T>(
            Task.FromResult(value),
            Task.FromResult(new Metadata()),
            () => Status.DefaultSuccess,
            () => new Metadata(),
            () => { });
    }
}