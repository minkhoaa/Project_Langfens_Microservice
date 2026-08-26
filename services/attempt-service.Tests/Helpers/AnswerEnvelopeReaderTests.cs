using attempt_service.Features.Helpers;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Locks <see cref="AnswerEnvelopeReader"/>: round-trip every slug's sample
/// JSON through the reader and confirm the resulting <c>TypedRecord</c> is
/// the expected concrete record with the discriminator field populated.
/// </summary>
public sealed class AnswerEnvelopeReaderTests
{
    private readonly AnswerEnvelopeReader _reader = new();

    public static IEnumerable<object[]> AllSlugs => new[]
    {
        new object[] { "MULTIPLE_CHOICE_SINGLE",      """{"type":"MULTIPLE_CHOICE_SINGLE","correctOptionId":"opt_1"}""" },
        new object[] { "MULTIPLE_CHOICE_SINGLE_IMAGE","""{"type":"MULTIPLE_CHOICE_SINGLE_IMAGE","correctOptionId":"img_1"}""" },
        new object[] { "MULTIPLE_CHOICE_MULTIPLE",    """{"type":"MULTIPLE_CHOICE_MULTIPLE","correctOptionIds":["a"],"scoring":"all-or-nothing"}""" },
        new object[] { "TRUE_FALSE_NOT_GIVEN",        """{"type":"TRUE_FALSE_NOT_GIVEN","choice":"TRUE"}""" },
        new object[] { "YES_NO_NOT_GIVEN",            """{"type":"YES_NO_NOT_GIVEN","choice":"YES"}""" },
        new object[] { "SUMMARY_COMPLETION",          """{"type":"SUMMARY_COMPLETION","answers":{"1":["a"]}}""" },
        new object[] { "TABLE_COMPLETION",            """{"type":"TABLE_COMPLETION","answers":{"r1":["a"]}}""" },
        new object[] { "NOTE_COMPLETION",             """{"type":"NOTE_COMPLETION","answers":{"n1":["a"]}}""" },
        new object[] { "FORM_COMPLETION",             """{"type":"FORM_COMPLETION","answers":{"f1":["a"]}}""" },
        new object[] { "SENTENCE_COMPLETION",         """{"type":"SENTENCE_COMPLETION","acceptedTexts":["a"]}""" },
        new object[] { "SHORT_ANSWER",                """{"type":"SHORT_ANSWER","acceptedTexts":["a"]}""" },
        new object[] { "AUDIO_RESPONSE",              """{"type":"AUDIO_RESPONSE","acceptedTranscriptions":["a"]}""" },
        new object[] { "DIAGRAM_LABEL",               """{"type":"DIAGRAM_LABEL","answers":{"A":["a"]}}""" },
        new object[] { "MAP_LABEL",                   """{"type":"MAP_LABEL","answers":{"n":["a"]}}""" },
        new object[] { "MATCHING_HEADING",            """{"type":"MATCHING_HEADING","pairs":[{"paragraphId":"p1","headingId":"h1"}],"scoring":"all-or-nothing"}""" },
        new object[] { "MATCHING_INFORMATION",        """{"type":"MATCHING_INFORMATION","pairs":[{"questionId":"q1","paragraphId":"a"}],"scoring":"proportional"}""" },
        new object[] { "MATCHING_FEATURES",           """{"type":"MATCHING_FEATURES","pairs":[{"itemId":"i1","featureId":"f1"}],"scoring":"afi"}""" },
        new object[] { "MATCHING_ENDINGS",            """{"type":"MATCHING_ENDINGS","pairs":[{"beginId":"b1","endId":"e1"}],"scoring":"all-or-nothing"}""" },
        new object[] { "CLASSIFICATION",              """{"type":"CLASSIFICATION","pairs":[{"itemId":"i1","categoryId":"c1"}],"scoring":"proportional"}""" },
        new object[] { "FLOW_CHART",                  """{"type":"FLOW_CHART","order":["a","b"],"scoring":"lcs"}""" },
        new object[] { "FLOW_CHART_COMPLETION",       """{"type":"FLOW_CHART_COMPLETION","order":["a","b"],"gapAnswers":{"n1":{"acceptedTexts":["x"]}}}""" },
    };

    [Theory]
    [MemberData(nameof(AllSlugs))]
    public void Roundtrip_resolves_alias_and_populates_type(string slug, string json)
    {
        var envelope = _reader.Read(json, slug);
        Assert.Equal(slug, envelope.Type);
        Assert.Equal(json, envelope.RawJson);
        Assert.NotNull(envelope.TypedRecord);
        // Verify the typed record is the registered CLR type for this slug.
        Assert.True(QuestionSchemaAliases.AnswerByType.TryGetValue(slug, out var expectedType));
        Assert.IsType(expectedType!, envelope.TypedRecord);
    }

    [Fact]
    public void Unknown_slug_throws()
    {
        Assert.Throws<UnknownQuestionTypeException>(
            () => _reader.Read("""{"type":"FOO_BAR"}""", "FOO_BAR"));
    }

    [Fact]
    public void Malformed_json_throws_for_string_list()
    {
        // FLOW_CHART deserialises the correct answer as a string list.
        // Junk JSON should produce either an exception OR a typed record with
        // an empty Order; verify the alias resolves without crashing.
        Assert.ThrowsAny<Exception>(
            () => _reader.Read("not-json", "FLOW_CHART"));
    }
}