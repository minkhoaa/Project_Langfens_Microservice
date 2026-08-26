using System.Text.Json;
using Google.Protobuf;
using Google.Protobuf.WellKnownTypes;
using Shared.Grpc.ExamInternal;
using Xunit;
using EnvelopeReader = global::attempt_service.Features.Helpers.QuestionEnvelopeReader;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Phase 3 gRPC wire-up: ensure <c>InternalDeliveryQuestion</c> still exposes
/// every legacy flat field AND can carry the SSOT discriminated-union
/// envelope. Backward compatibility is the primary invariant — old callers
/// MUST keep reading 9-13 unchanged while new callers can read 15.
/// </summary>
public class EnvelopeRoundtripTests
{
    private static InternalDeliveryQuestion BuildQuestion()
    {
        var q = new InternalDeliveryQuestion
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 1,
            Type = "multiple_choice_single",
            Skill = "reading",
            Difficulty = 2,
            PromptMd = "Pick the correct option.",
            ExplanationMd = "Because A is correct.",
        };
        q.Options.Add(new InternalDeliveryOption
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 1,
            ContentMd = "Option A",
            IsCorrect = true,
        });
        q.Options.Add(new InternalDeliveryOption
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 2,
            ContentMd = "Option B",
            IsCorrect = false,
        });
        q.CompletionAccepts.Add(new InternalCompletionAccept { BlankId = "b1" });
        q.CompletionAccepts[0].AcceptedTexts.Add("answer");
        q.MatchPairs.Add(new InternalMatchPair { PromptKey = "p1" });
        q.MatchPairs[0].AcceptedValues.Add("v1");
        q.OrderCorrects.Add("first");
        q.OrderCorrects.Add("second");
        q.ShortAnswerAcceptTexts.Add("alt");
        q.ShortAnswerAcceptRegex.Add("^foo$");
        q.FlowChartNodes.Add(new FlowChartNode { Key = "k1", Label = "K 1" });

        var payloadJson = "{\"prompt\":\"Pick the correct option.\",\"options\":[{\"id\":\"" + q.Options[0].Id + "\",\"idx\":1,\"isCorrect\":true}]}";
        var correctJson = "{\"type\":\"multiple_choice_single\",\"correctOptionIds\":[\"" + q.Options[0].Id + "\"]}";
        q.Envelope = new InternalDeliveryQuestionEnvelope
        {
            Type = "multiple_choice_single",
            Payload = JsonParser.Default.Parse<Struct>(payloadJson),
            CorrectAnswer = JsonParser.Default.Parse<Struct>(correctJson),
            Rubric = new Struct(),
        };
        return q;
    }

    [Fact]
    public void Legacy_fields_remain_populated_after_dual_emit()
    {
        var q = BuildQuestion();

        Assert.Equal(2, q.Options.Count);
        Assert.True(q.Options[0].HasIsCorrect);
        Assert.True(q.Options[0].IsCorrect);
        Assert.Single(q.CompletionAccepts);
        Assert.Equal("b1", q.CompletionAccepts[0].BlankId);
        Assert.Single(q.MatchPairs);
        Assert.Equal("p1", q.MatchPairs[0].PromptKey);
        Assert.Equal(new[] { "first", "second" }, q.OrderCorrects.ToArray());
        Assert.Equal(new[] { "alt" }, q.ShortAnswerAcceptTexts.ToArray());
        Assert.Equal(new[] { "^foo$" }, q.ShortAnswerAcceptRegex.ToArray());
        Assert.Single(q.FlowChartNodes);
        Assert.Equal("k1", q.FlowChartNodes[0].Key);
    }

    [Fact]
    public void Envelope_is_readable_and_carries_discriminator()
    {
        var q = BuildQuestion();
        Assert.NotNull(q.Envelope);
        Assert.Equal("multiple_choice_single", q.Envelope.Type);
        Assert.NotNull(q.Envelope.Payload);
        Assert.NotNull(q.Envelope.CorrectAnswer);
        Assert.NotNull(q.Envelope.Rubric);
    }

    [Fact]
    public void Envelope_helpers_expose_payload_and_correct_answer()
    {
        var q = BuildQuestion();
        Assert.True(EnvelopeReader.HasEnvelope(q));
        Assert.Equal("multiple_choice_single", EnvelopeReader.GetEnvelopeType(q));

        var payload = EnvelopeReader.TryGetEnvelopePayload(q);
        Assert.NotNull(payload);
        Assert.Equal(JsonValueKind.Object, payload!.Value.ValueKind);
        Assert.True(payload.Value.TryGetProperty("prompt", out var prompt));
        Assert.Equal("Pick the correct option.", prompt.GetString());

        var correct = EnvelopeReader.TryGetEnvelopeCorrectAnswer(q);
        Assert.NotNull(correct);
        Assert.True(correct!.Value.TryGetProperty("correctOptionIds", out var ids));
        Assert.Equal(JsonValueKind.Array, ids.ValueKind);
        Assert.Equal(1, ids.GetArrayLength());
    }

    [Fact]
    public void Envelope_helpers_return_null_when_envelope_absent()
    {
        var q = new InternalDeliveryQuestion
        {
            Id = Guid.NewGuid().ToString(),
            Type = "short_answer",
            PromptMd = "x",
        };
        Assert.False(EnvelopeReader.HasEnvelope(q));
        Assert.Null(EnvelopeReader.TryGetEnvelopePayload(q));
        Assert.Null(EnvelopeReader.TryGetEnvelopeCorrectAnswer(q));
    }
}
