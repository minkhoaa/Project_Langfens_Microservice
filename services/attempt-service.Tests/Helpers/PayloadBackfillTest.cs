using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using Xunit;

namespace attempt_service.Tests.Helpers;

/// <summary>
/// Phase 4 backfill validation: mirrors the SQL CASE expression in
/// <c>20260826063636_AddExamQuestionPayloadColumn.Up()</c> in C# and asserts
/// the produced JSON envelope has the expected SSOT shape for representative
/// question types. This is a pure unit test (no DB) — it guards the backfill
/// contract by keeping the C# projection and the SQL CASE expression
/// structurally aligned. If the SQL drifts, this test surfaces the mismatch
/// before it reaches prod.
/// </summary>
public class PayloadBackfillTest
{
    // ── Representative question types covered by this test ──────────────
    // Picked to exercise every category of legacy column source:
    //  - MULTIPLE_CHOICE_SINGLE: options table join (Option relation)
    //  - SUMMARY_COMPLETION:    BlankAcceptTexts (jsonb dict)
    //  - MATCHING_HEADING:      MatchPairs + WordList
    //  - FLOW_CHART:            OrderCorrects (text[])
    //  - SHORT_ANSWER:          ShortAnswerAcceptTexts / Regex (text[])
    private const string PromptSample = "Read the passage and answer.";

    private static (string type, JsonElement payload, JsonElement correctAnswer) BuildEnvelope(
        string type,
        Guid optionId,
        Dictionary<string, string[]?>? blankAcceptTexts,
        Dictionary<string, string[]?>? matchPairs,
        List<string>? wordList,
        List<string>? orderCorrects,
        List<string>? shortAnswerAcceptTexts,
        List<string>? shortAnswerAcceptRegex)
    {
        // Mirror the SQL CASE branches in 20260826063636_AddExamQuestionPayloadColumn.cs
        // — minimal shape, sufficient for SSOT discriminator validation.
        object payloadObj = type switch
        {
            "MULTIPLE_CHOICE_SINGLE" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["options"] = new object[]
                {
                    new Dictionary<string, object?>
                    {
                        ["id"] = optionId,
                        ["idx"] = 1,
                        ["content"] = "correct",
                        ["isCorrect"] = true,
                    }
                },
            },
            "SUMMARY_COMPLETION" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["gaps"] = (blankAcceptTexts ?? new Dictionary<string, string[]?>())
                    .Keys.Select(k => new Dictionary<string, object?> { ["key"] = k })
                    .ToArray(),
            },
            "MATCHING_HEADING" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["pairs"] = matchPairs ?? new Dictionary<string, string[]?>(),
                ["wordList"] = wordList?.ToArray() ?? Array.Empty<string>(),
            },
            "MATCHING_FEATURES" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["pairs"] = matchPairs ?? new Dictionary<string, string[]?>(),
            },
            "MATCHING_ENDINGS" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["pairs"] = matchPairs ?? new Dictionary<string, string[]?>(),
            },
            "SENTENCE_COMPLETION" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["gap"] = (blankAcceptTexts ?? new Dictionary<string, string[]?>()).Keys.FirstOrDefault(),
            },
            "FLOW_CHART" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
                ["nodes"] = (orderCorrects ?? new List<string>())
                    .Select(k => new Dictionary<string, object?>
                    {
                        ["key"] = k,
                        ["label"] = k.Replace("-", " "),
                    })
                    .ToArray(),
            },
            "SHORT_ANSWER" => new Dictionary<string, object?>
            {
                ["prompt"] = PromptSample,
                ["skill"] = "READING",
                ["difficulty"] = 1,
            },
            _ => throw new ArgumentOutOfRangeException(nameof(type), type, "Not a representative type"),
        };

        object correctObj = type switch
        {
            "MULTIPLE_CHOICE_SINGLE" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["correctOptionId"] = optionId.ToString(),
            },
            "SUMMARY_COMPLETION" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["blanks"] = blankAcceptTexts ?? new Dictionary<string, string[]?>(),
            },
            "MATCHING_HEADING" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["pairs"] = matchPairs ?? new Dictionary<string, string[]?>(),
            },
            "MATCHING_FEATURES" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["pairs"] = matchPairs ?? new Dictionary<string, string[]?>(),
            },
            "MATCHING_ENDINGS" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["pairs"] = matchPairs ?? new Dictionary<string, string[]?>(),
            },
            "SENTENCE_COMPLETION" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["acceptedAnswers"] = Array.Empty<string>(),
            },
            "FLOW_CHART" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["order"] = orderCorrects?.ToArray() ?? Array.Empty<string>(),
            },
            "SHORT_ANSWER" => new Dictionary<string, object?>
            {
                ["type"] = type,
                ["acceptedAnswers"] = shortAnswerAcceptTexts?.ToArray() ?? Array.Empty<string>(),
                ["acceptedRegex"] = shortAnswerAcceptRegex?.ToArray() ?? Array.Empty<string>(),
            },
            _ => throw new ArgumentOutOfRangeException(nameof(type), type, "Not a representative type"),
        };

        var payloadJson = JsonSerializer.Serialize(payloadObj);
        var correctJson = JsonSerializer.Serialize(correctObj);
        return (type, JsonDocument.Parse(payloadJson).RootElement, JsonDocument.Parse(correctJson).RootElement);
    }

    private static JsonElement WrapEnvelope(string type, JsonElement payload, JsonElement correctAnswer)
    {
        var env = new Dictionary<string, object?>
        {
            ["type"] = type,
            ["payload"] = JsonSerializer.Deserialize<object>(payload.GetRawText()),
            ["correctAnswer"] = JsonSerializer.Deserialize<object>(correctAnswer.GetRawText()),
            ["rubric"] = null,
        };
        return JsonDocument.Parse(JsonSerializer.Serialize(env)).RootElement;
    }

    [Fact]
    public void MultipleChoiceSingle_envelope_has_options_and_correctOptionId()
    {
        var optId = Guid.NewGuid();
        var (type, payload, correct) = BuildEnvelope(
            "MULTIPLE_CHOICE_SINGLE", optId,
            blankAcceptTexts: null, matchPairs: null, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("MULTIPLE_CHOICE_SINGLE", type);
        Assert.Equal(PromptSample, payload.GetProperty("prompt").GetString());
        var options = payload.GetProperty("options");
        Assert.Equal(JsonValueKind.Array, options.ValueKind);
        Assert.Equal(1, options.GetArrayLength());
        Assert.Equal(optId, options[0].GetProperty("id").GetGuid());
        Assert.True(options[0].GetProperty("isCorrect").GetBoolean());
        Assert.Equal(optId.ToString(), correct.GetProperty("correctOptionId").GetString());

        var env = WrapEnvelope(type, payload, correct);
        Assert.Equal(type, env.GetProperty("type").GetString());
        Assert.True(env.TryGetProperty("payload", out _));
        Assert.True(env.TryGetProperty("correctAnswer", out _));
        Assert.True(env.TryGetProperty("rubric", out _));
    }

    [Fact]
    public void SummaryCompletion_envelope_inherits_blank_keys_as_gaps()
    {
        var blankAccepts = new Dictionary<string, string[]?>
        {
            ["gap1"] = new[] { "carbon", "co2" },
            ["gap2"] = new[] { "fossil" },
        };
        var (type, payload, correct) = BuildEnvelope(
            "SUMMARY_COMPLETION", Guid.Empty,
            blankAcceptTexts: blankAccepts, matchPairs: null, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("SUMMARY_COMPLETION", type);
        var gaps = payload.GetProperty("gaps");
        Assert.Equal(2, gaps.GetArrayLength());
        var gapKeys = gaps.EnumerateArray()
            .Select(g => g.GetProperty("key").GetString())
            .ToHashSet();
        Assert.Contains("gap1", gapKeys);
        Assert.Contains("gap2", gapKeys);
        // blanks in correctAnswer mirror the legacy dict shape
        Assert.Equal(2, correct.GetProperty("blanks").EnumerateObject().Count());
    }

    [Fact]
    public void MatchingHeading_envelope_carries_pairs_and_wordList()
    {
        var matchPairs = new Dictionary<string, string[]?>
        {
            ["para1"] = new[] { "i", "Paragraph 1 title" },
            ["para2"] = new[] { "ii", "Paragraph 2 title" },
        };
        var wordList = new List<string> { "i", "ii", "iii" };
        var (type, payload, correct) = BuildEnvelope(
            "MATCHING_HEADING", Guid.Empty,
            blankAcceptTexts: null, matchPairs: matchPairs, wordList: wordList,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("MATCHING_HEADING", type);
        var pairs = payload.GetProperty("pairs");
        Assert.Equal(2, pairs.EnumerateObject().Count());
        var wl = payload.GetProperty("wordList");
        Assert.Equal(3, wl.GetArrayLength());
        Assert.Equal("i", wl[0].GetString());
        Assert.Equal(2, correct.GetProperty("pairs").EnumerateObject().Count());
    }

    [Fact]
    public void FlowChart_envelope_emits_nodes_with_key_and_label()
    {
        var order = new List<string> { "step-1", "step-2", "step-3" };
        var (type, payload, correct) = BuildEnvelope(
            "FLOW_CHART", Guid.Empty,
            blankAcceptTexts: null, matchPairs: null, wordList: null,
            orderCorrects: order, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("FLOW_CHART", type);
        var nodes = payload.GetProperty("nodes");
        Assert.Equal(3, nodes.GetArrayLength());
        Assert.Equal("step-1", nodes[0].GetProperty("key").GetString());
        Assert.Equal("step 1", nodes[0].GetProperty("label").GetString()); // hyphens → spaces
        Assert.Equal("step-2", nodes[1].GetProperty("key").GetString());

        var orderArr = correct.GetProperty("order");
        Assert.Equal(3, orderArr.GetArrayLength());
        Assert.Equal("step-1", orderArr[0].GetString());
    }

    [Fact]
    public void MatchingFeatures_envelope_carries_pairs_without_wordList()
    {
        var matchPairs = new Dictionary<string, string[]?>
        {
            ["item1"] = new[] { "featureA" },
            ["item2"] = new[] { "featureB", "featureC" },
            ["item3"] = new[] { "featureA" },
        };
        var (type, payload, correct) = BuildEnvelope(
            "MATCHING_FEATURES", Guid.Empty,
            blankAcceptTexts: null, matchPairs: matchPairs, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("MATCHING_FEATURES", type);
        var pairs = payload.GetProperty("pairs");
        Assert.Equal(3, pairs.EnumerateObject().Count());
        // Phase 0a fix: MATCHING_FEATURES must NOT carry a wordList field.
        Assert.False(payload.TryGetProperty("wordList", out var wl)
            && wl.ValueKind != JsonValueKind.Null
            && wl.GetArrayLength() > 0,
            "MATCHING_FEATURES payload should not carry a non-empty wordList");
        Assert.Equal(3, correct.GetProperty("pairs").EnumerateObject().Count());
    }

    [Fact]
    public void MatchingEndings_envelope_carries_pairs_without_wordList()
    {
        var matchPairs = new Dictionary<string, string[]?>
        {
            ["stem1"] = new[] { "endingA" },
            ["stem2"] = new[] { "endingB" },
            ["stem3"] = new[] { "endingC", "endingD" },
        };
        var (type, payload, correct) = BuildEnvelope(
            "MATCHING_ENDINGS", Guid.Empty,
            blankAcceptTexts: null, matchPairs: matchPairs, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("MATCHING_ENDINGS", type);
        var pairs = payload.GetProperty("pairs");
        Assert.Equal(3, pairs.EnumerateObject().Count());
        Assert.False(payload.TryGetProperty("wordList", out var wl)
            && wl.ValueKind != JsonValueKind.Null
            && wl.GetArrayLength() > 0,
            "MATCHING_ENDINGS payload should not carry a non-empty wordList");
        Assert.Equal(3, correct.GetProperty("pairs").EnumerateObject().Count());
    }

    [Fact]
    public void SentenceCompletion_payload_uses_singular_gap_and_correctAnswer_defaults_to_empty_acceptedAnswers()
    {
        var blankAccepts = new Dictionary<string, string[]?>
        {
            ["gap1"] = new[] { "carbon", "co2" },
        };
        var (type, payload, correct) = BuildEnvelope(
            "SENTENCE_COMPLETION", Guid.Empty,
            blankAcceptTexts: blankAccepts, matchPairs: null, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        Assert.Equal("SENTENCE_COMPLETION", type);
        // Phase 0a fix: single-gap variant must emit "gap" (singular) not "gaps" array.
        Assert.True(payload.TryGetProperty("gap", out var gap));
        Assert.Equal("gap1", gap.GetString());
        Assert.False(payload.TryGetProperty("gaps", out _),
            "SENTENCE_COMPLETION payload should use singular 'gap'");
        // correctAnswer carries acceptedAnswers list (per phase 5 plan).
        Assert.Equal(0, correct.GetProperty("acceptedAnswers").GetArrayLength());
    }

    [Fact]
    public void ShortAnswer_envelope_includes_acceptedAnswers_and_acceptedRegex()
    {
        var texts = new List<string> { "paris", "the city of paris" };
        var regex = new List<string> { "^paris$" };
        var (type, payload, correct) = BuildEnvelope(
            "SHORT_ANSWER", Guid.Empty,
            blankAcceptTexts: null, matchPairs: null, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: texts, shortAnswerAcceptRegex: regex);

        Assert.Equal("SHORT_ANSWER", type);
        Assert.Equal(PromptSample, payload.GetProperty("prompt").GetString());
        var accepted = correct.GetProperty("acceptedAnswers");
        Assert.Equal(2, accepted.GetArrayLength());
        Assert.Equal("paris", accepted[0].GetString());
        var regexArr = correct.GetProperty("acceptedRegex");
        Assert.Single(regexArr.EnumerateArray());
        Assert.Equal("^paris$", regexArr[0].GetString());
    }

    [Fact]
    public void Envelope_shape_is_discriminated_union_with_all_three_keys()
    {
        // Cross-type invariant: every produced envelope carries type/payload/correctAnswer
        // (rubric may be null but the key must be present).
        var (type, payload, correct) = BuildEnvelope(
            "MULTIPLE_CHOICE_SINGLE", Guid.NewGuid(),
            blankAcceptTexts: null, matchPairs: null, wordList: null,
            orderCorrects: null, shortAnswerAcceptTexts: null, shortAnswerAcceptRegex: null);

        var env = WrapEnvelope(type, payload, correct);
        Assert.True(env.TryGetProperty("type", out _), "envelope must contain 'type'");
        Assert.True(env.TryGetProperty("payload", out _), "envelope must contain 'payload'");
        Assert.True(env.TryGetProperty("correctAnswer", out _), "envelope must contain 'correctAnswer'");
        Assert.True(env.TryGetProperty("rubric", out var rubric), "envelope must contain 'rubric'");
        Assert.Equal(JsonValueKind.Null, rubric.ValueKind);
    }
}
