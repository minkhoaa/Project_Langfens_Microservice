using System.Text.Json;
using System.Text.Json.Nodes;
using attempt_service.Contracts.Attempt;
using attempt_service.Features.Helpers;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;
using SharedDto = Shared.ExamDto.Contracts.Exam.InternalExamDto.InternalExamDto;
using Normalizer = Shared.ExamDto.Contracts.Exam.InternalExamDto.PaperWideNormalizer;

namespace attempt_service.Tests.Helpers;

public class LegacySnapshotLifecycleTests
{
    private static readonly JsonSerializerOptions Web = new(JsonSerializerDefaults.Web);
    private static readonly string[] Families = ["single", "multiple", "completion", "label", "matching", "flow", "short"];

    public static IEnumerable<object[]> Cases()
    {
        foreach (var family in Families)
        foreach (var grouped in new[] { false, true })
        foreach (var state in new[] { "correct", "wrong", "empty", "clear", "partial" })
        {
            if (state == "partial" && family is "single" or "short") continue;
            yield return [family, grouped, state];
        }
    }

    [Theory]
    [MemberData(nameof(Cases))]
    public async Task Rest_snapshot_preserves_grading_keys_private_redaction_context_and_immutable_paper(
        string family, bool grouped, string state)
    {
        await using var fixture = await AttemptAnswerFixture.CreateLegacyRest();
        var root = await Paper(fixture);
        var section = root["sections"]![0]!;
        var question = section["questions"]![0]!;
        root["imageUrl"] = "https://example.invalid/cover.png";
        section["passageMd"] = "Public passage";
        section["instructionsMd"] = "Public instruction";
        section["audioUrl"] = "https://example.invalid/audio.mp3";
        section["transcriptMd"] = "Public transcript";
        question["idx"] = 7; // Stored legacy positions must not be rewritten.
        question["type"] = family switch
        {
            "single" => QuestionType.MultipleChoiceSingle,
            "multiple" => QuestionType.MultipleChoiceMultiple,
            "completion" => QuestionType.SentenceCompletion,
            "label" => QuestionType.DiagramLabel,
            "matching" => QuestionType.MatchingHeading,
            "flow" => QuestionType.FlowChart,
            _ => QuestionType.ShortAnswer
        };
        question["imageUrl"] = "https://example.invalid/question.png";
        question["explanationMd"] = "PRIVATE_EXPLANATION";
        question["modelAnswers"] = JsonSerializer.SerializeToNode(new[] { "PRIVATE_MODEL" });
        question["wordList"] = JsonSerializer.SerializeToNode(new[] { "Public word", "Public alternative" });
        question["options"]![0]!["imageUrl"] = "https://example.invalid/option.png";
        question["options"]![0]!["altText"] = "Public alternative text";
        var secondCorrect = Guid.NewGuid();
        if (family == "multiple") question["options"]!.AsArray().Add(JsonSerializer.SerializeToNode(new
        {
            id = secondCorrect, idx = 3, contentMd = "Public second choice", isCorrect = true
        }));
        question["blankAcceptTexts"] = JsonSerializer.SerializeToNode(family is "completion" or "label"
            ? new Dictionary<string, string[]> { ["2"] = ["PRIVATE_TEXT"] } : new());
        question["blankAcceptRegex"] = JsonSerializer.SerializeToNode(family is "completion" or "label"
            ? new Dictionary<string, string[]> { ["10"] = ["^PRIVATE_REGEX$"] } : new());
        question["matchPairs"] = JsonSerializer.SerializeToNode(family == "matching"
            ? new Dictionary<string, string[]> { ["2"] = ["A", "Public heading A"], ["10"] = ["B", "Public heading B"] } : new());
        question["orderCorrects"] = JsonSerializer.SerializeToNode(family == "flow" ? new[] { "step-b", "step-a" } : []);
        question["flowChartNodes"] = JsonSerializer.SerializeToNode(family == "flow"
            ? new[] { new { key = "step-a", label = "Public step A" }, new { key = "step-b", label = "Public step B" } } : []);
        question["shortAnswerAcceptTexts"] = JsonSerializer.SerializeToNode(family == "short" ? new[] { "PRIVATE_TEXT" } : []);
        question["shortAnswerAcceptRegex"] = JsonSerializer.SerializeToNode(family == "short" ? new[] { "^PRIVATE_REGEX$" } : []);
        if (grouped) Group(section);
        var raw = await Store(fixture, root);
        var examId = root["id"]!.GetValue<Guid>();
        var resumed = Data<AttemptStartResponse>(await fixture.Service.StartAttempt(new(examId), default));
        Assert.Equal(fixture.AttemptId, resumed.AttemptId);
        AssertPublic(resumed.Paper, fixture, family);

        AnswerItem Input(string mode)
        {
            List<Guid> options = [];
            string? text = null;
            if (mode != "empty")
            {
                if (family == "single") options = [mode == "correct" ? fixture.OptionId : fixture.WrongOptionId];
                else if (family == "multiple") options = mode == "correct" ? [secondCorrect, fixture.OptionId]
                    : mode == "partial" ? [fixture.OptionId] : [fixture.WrongOptionId];
                else text = family switch
                {
                    "completion" or "label" => mode == "correct" ? "{\"2\":\"PRIVATE_TEXT\",\"10\":\"PRIVATE_REGEX\"}"
                        : mode == "partial" ? "{\"2\":\"PRIVATE_TEXT\"}" : "{\"2\":\"wrong\",\"10\":\"wrong\"}",
                    "matching" => mode == "correct" ? "{\"2\":\"A\",\"10\":\"B\"}"
                        : mode == "partial" ? "{\"2\":\"A\"}" : "{\"2\":\"B\",\"10\":\"A\"}",
                    "flow" => mode == "correct" ? "[\"step-b\",\"step-a\"]"
                        : mode == "partial" ? "[\"step-b\"]" : "[\"step-a\",\"step-b\"]",
                    _ => mode == "correct" ? "PRIVATE_REGEX" : "wrong"
                };
            }
            return new(fixture.QuestionId, Guid.NewGuid(), options, text);
        }
        var answer = Input(state == "clear" ? "correct" : state);
        Assert.Equal(200, Status(await fixture.Service.Autosave(fixture.AttemptId, new([answer], null), default)));
        if (state == "clear")
        {
            answer = JsonSerializer.Deserialize<AnswerItem>(
                $"{{\"questionId\":\"{fixture.QuestionId}\",\"selectedOptionIds\":[],\"textAnswer\":null}}", Web)!;
            Assert.Equal(200, Status(await fixture.Service.Autosave(fixture.AttemptId, new([answer], null), default)));
        }
        AssertPublic(Data<AttemptGetResponse>(await fixture.Service.GetAttemptById(fixture.AttemptId, default)).Paper, fixture, family);
        Assert.Equal(200, Status(await fixture.Service.Submit(fixture.AttemptId, default)));
        var saved = await fixture.ReadAnswer();
        Assert.Equal(fixture.SectionId, saved.SectionId);
        Assert.Equal(state == "correct", saved.IsCorrect);
        Assert.Equal(state == "correct" ? 1m : 0m, saved.AwardedPoints); // No per-slot scoring.
        var result = Data<AttemptResultResponse>(await fixture.Service.GetResult(fixture.AttemptId, default));
        Assert.Equal(fixture.QuestionId, Assert.Single(result.Answers).QuestionId);
        Assert.Equal(1, result.Answers[0].Idx);
        Assert.Contains("PRIVATE_EXPLANATION", result.PaperWithAnswers.GetRawText());
        Assert.Equal(raw, (await fixture.Db.Attempts.AsNoTracking().SingleAsync()).PaperJson!.RootElement.GetRawText());
        Assert.Contains(fixture.Rag.Invocations, call => call.Method.Name == "ExplainAsync"
            && Equals(call.Arguments[1], fixture.SectionId) && Equals(call.Arguments[4], "Public passage"));
    }

    public static IEnumerable<object[]> MalformedCases()
    {
        foreach (var proto in new[] { false, true })
        foreach (var error in new[] { "section-empty", "section-invalid", "section-duplicate", "question-empty", "question-invalid",
                     "question-duplicate", "option-empty", "option-duplicate", "questions-null", "options-null", "mixed-owner", "group-empty", "group-duplicate", "question-group-mismatch",
                     "question-section-mismatch", "id-case-alias", "questions-case-alias" })
            yield return [proto, error];
    }

    [Theory]
    [MemberData(nameof(MalformedCases))]
    public async Task Malformed_identity_and_collections_fail_all_lifecycle_paths_without_mutation(bool proto, string error)
    {
        await using var fixture = proto ? await AttemptAnswerFixture.Create(seedAnswer: false) : await AttemptAnswerFixture.CreateLegacyRest();
        var root = await Paper(fixture);
        var section = root["sections"]![0]!;
        var questions = proto ? section["questionGroups"]![0]!["questions"]! : section["questions"]!;
        var question = questions[0]!;
        question["explanationMd"] = "PRIVATE_MALFORMED_SENTINEL";
        if (error.StartsWith("group-") || error == "question-group-mismatch")
        {
            if (!proto) Group(section);
            questions = section["questionGroups"]![0]!["questions"]!;
            question = questions[0]!;
        }
        switch (error)
        {
            case "group-empty": section["questionGroups"]![0]!["id"] = Guid.Empty.ToString(); break;
            case "group-duplicate": section["questionGroups"]!.AsArray().Add(section["questionGroups"]![0]!.DeepClone()); break;
            case "question-group-mismatch": question["groupId"] = Guid.NewGuid().ToString(); break;
            case "question-section-mismatch": question["sectionId"] = Guid.NewGuid().ToString(); break;
            case "id-case-alias": question["ID"] = Guid.NewGuid().ToString(); break;
            case "questions-case-alias":
                if (proto) section["questionGroups"]![0]!["Questions"] = questions.DeepClone();
                else section["Questions"] = questions.DeepClone();
                break;
            case "section-empty": section["id"] = Guid.Empty.ToString(); break;
            case "section-invalid": section["id"] = "not-an-id"; break;
            case "section-duplicate": root["sections"]!.AsArray().Add(section.DeepClone()); break;
            case "question-empty": question["id"] = Guid.Empty.ToString(); break;
            case "question-invalid": question["id"] = "not-an-id"; break;
            case "question-duplicate": questions.AsArray().Add(question.DeepClone()); break;
            case "option-empty": question["options"]![0]!["id"] = Guid.Empty.ToString(); break;
            case "option-duplicate": question["options"]!.AsArray().Add(question["options"]![0]!.DeepClone()); break;
            case "questions-null":
                if (proto) section["questionGroups"]![0]!["questions"] = null;
                else section["questions"] = null;
                break;
            case "options-null": question["options"] = null; break;
            case "mixed-owner":
                if (proto) section["questions"] = questions.DeepClone();
                else Group(section, keepFlat: true);
                break;
        }
        var raw = await Store(fixture, root);
        var examId = root["id"]!.GetValue<Guid>();
        foreach (var result in new[] {
            await fixture.Service.StartAttempt(new(examId), default),
            await fixture.Service.GetAttemptById(fixture.AttemptId, default),
            await fixture.Service.Autosave(fixture.AttemptId, new([new(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null)], null), default),
            await fixture.Service.Submit(fixture.AttemptId, default)
        })
        {
            Assert.Equal(500, Status(result));
            Assert.DoesNotContain("PRIVATE_MALFORMED_SENTINEL", JsonSerializer.Serialize(((IValueHttpResult)result).Value));
        }
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
        var stored = await fixture.Db.Attempts.SingleAsync();
        Assert.Equal("STARTED", stored.Status);
        Assert.Equal(raw, stored.PaperJson!.RootElement.GetRawText());
        stored.Status = "GRADED"; // Exercise result parsing independently, not a production finalization.
        await fixture.Db.SaveChangesAsync();
        Assert.Equal(500, Status(await fixture.Service.GetResult(fixture.AttemptId, default)));
    }

    [Fact]
    public async Task Legacy_normalizer_output_is_readable_and_private_flat_sanitizer_is_defensive()
    {
        await using var fixture = await AttemptAnswerFixture.CreateLegacyRest();
        var root = await Paper(fixture);
        root["sections"]![0]!["questions"]![0]!["modelAnswers"] = JsonSerializer.SerializeToNode(new[] { "PRIVATE_MODEL" });
        using var doc = JsonDocument.Parse(root.ToJsonString());
        var normalized = Normalizer.NormalizeJsonElement(doc.RootElement);
        Assert.False(normalized.GetProperty("sections")[0].TryGetProperty("questions", out _));
        Assert.Equal(fixture.QuestionId, AttemptSnapshotReader.Read(normalized).Dto!.Sections[0].QuestionGroups[0].Questions[0].Id);
        var sanitized = SharedDto.SnapshotSanitizer.Sanitize(doc.RootElement.Deserialize<SharedDto.InternalDeliveryExam>()!);
        Assert.DoesNotContain("PRIVATE_MODEL", JsonSerializer.Serialize(sanitized));
        Assert.Contains("PRIVATE_MODEL", doc.RootElement.GetRawText());
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task Proto_key_arrays_cannot_be_silently_discarded_by_rest_adapter(bool grouped)
    {
        await using var fixture = await AttemptAnswerFixture.CreateLegacyRest();
        var root = await Paper(fixture);
        var section = root["sections"]![0]!;
        var question = section["questions"]![0]!;
        question["type"] = QuestionType.SentenceCompletion;
        question["completionAccepts"] = JsonSerializer.SerializeToNode(new[] { new { blankId = "2", acceptedTexts = new[] { "PRIVATE_KEY" } } });
        if (grouped)
        {
            question["blankAcceptTexts"] = new JsonObject { ["10"] = new JsonArray("OTHER_PRIVATE_KEY") };
            Group(section);
        }
        await Store(fixture, root);
        Assert.Equal(500, Status(await fixture.Service.Submit(fixture.AttemptId, default)));
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
    }

    [Fact]
    public async Task Normalized_current_proto_remains_proto_without_duplicate_bounds_and_retains_keys()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var root = await Paper(fixture);
        var question = root["sections"]![0]!["questionGroups"]![0]!["questions"]!;
        question[0]!["type"] = QuestionType.SentenceCompletion;
        question[0]!["completionAccepts"] = JsonSerializer.SerializeToNode(new[] { new { blankId = "2", acceptedTexts = new[] { "PRIVATE_KEY" } } });
        using var doc = JsonDocument.Parse(root.ToJsonString());
        var normalized = Normalizer.NormalizeJsonElement(doc.RootElement);
        Assert.Equal(1, normalized.GetProperty("sections")[0].GetProperty("questionGroups")[0]
            .EnumerateObject().Count(property => property.NameEquals("startIdx")));
        var parsed = AttemptSnapshotReader.Read(normalized);
        Assert.Equal("PRIVATE_KEY", parsed.Proto!.Sections[0].QuestionGroups[0].Questions[0].CompletionAccepts[0].AcceptedTexts[0]);
    }

    [Fact]
    public async Task Missing_flow_key_keeps_manual_review_semantics()
    {
        await using var fixture = await AttemptAnswerFixture.CreateLegacyRest();
        var root = await Paper(fixture);
        root["sections"]![0]!["questions"]![0]!["type"] = QuestionType.FlowChart;
        var raw = await Store(fixture, root);
        Assert.Equal(200, Status(await fixture.Service.Submit(fixture.AttemptId, default)));
        var saved = await fixture.ReadAnswer();
        Assert.Null(saved.IsCorrect);
        Assert.Equal(0m, saved.AwardedPoints);
        var attempt = await fixture.Db.Attempts.AsNoTracking().SingleAsync();
        Assert.Equal("SUBMITTED", attempt.Status);
        Assert.Equal(raw, attempt.PaperJson!.RootElement.GetRawText());
    }

    [Theory]
    [InlineData("wordList")]
    [InlineData("modelAnswers")]
    public async Task Grouped_rest_only_metadata_is_not_silently_lost_to_proto(string field)
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var root = await Paper(fixture);
        root["sections"]![0]!["questionGroups"]![0]!["questions"]![0]![field] = new JsonArray("VALUE");
        using var doc = JsonDocument.Parse(root.ToJsonString());
        var question = AttemptSnapshotReader.Read(doc.RootElement).Dto!.Sections[0].QuestionGroups[0].Questions[0];
        Assert.Equal("VALUE", (field == "wordList" ? question.WordList : question.ModelAnswers)![0]);
    }

    private static void AssertPublic(JsonElement paper, AttemptAnswerFixture fixture, string family)
    {
        Assert.DoesNotContain("PRIVATE_", paper.GetRawText());
        Assert.Equal("https://example.invalid/cover.png", paper.GetProperty("imageUrl").GetString());
        var section = paper.GetProperty("sections")[0];
        Assert.Equal(fixture.SectionId, section.GetProperty("id").GetGuid());
        Assert.Equal("Public passage", section.GetProperty("passageMd").GetString());
        Assert.Equal("Public instruction", section.GetProperty("instructionsMd").GetString());
        Assert.Equal("Public transcript", section.GetProperty("transcriptMd").GetString());
        Assert.Equal("https://example.invalid/audio.mp3", section.GetProperty("audioUrl").GetString());
        var group = Assert.Single(section.GetProperty("questionGroups").EnumerateArray());
        var question = Assert.Single(group.GetProperty("questions").EnumerateArray());
        Assert.Equal(fixture.QuestionId, question.GetProperty("id").GetGuid());
        Assert.Equal(1, question.GetProperty("idx").GetInt32());
        Assert.Equal(1, group.GetProperty("startIdx").GetInt32());
        Assert.Equal(1, group.GetProperty("endIdx").GetInt32());
        Assert.Equal("Public word", question.GetProperty("wordList")[0].GetString());
        Assert.Equal("https://example.invalid/question.png", question.GetProperty("imageUrl").GetString());
        Assert.Equal("https://example.invalid/option.png", question.GetProperty("options")[0].GetProperty("imageUrl").GetString());
        Assert.Equal("Public alternative text", question.GetProperty("options")[0].GetProperty("altText").GetString());
        Assert.All(question.GetProperty("options").EnumerateArray(), option => Assert.Equal(JsonValueKind.Null, option.GetProperty("isCorrect").ValueKind));
        Assert.All(question.GetProperty("matchPairs").EnumerateObject(), pair => Assert.Equal(0, pair.Value.GetArrayLength()));
        Assert.Equal(0, question.GetProperty("orderCorrects").GetArrayLength());
        if (family == "flow") Assert.Equal("step-a", question.GetProperty("flowChartNodes")[0].GetProperty("key").GetString());
    }

    private static int? Status(IResult result) => Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode;
    private static T Data<T>(IResult result)
    {
        Assert.Equal(200, Status(result));
        return Assert.IsType<T>(Assert.IsType<ApiResultDto>(((IValueHttpResult)result).Value).data);
    }
    private static async Task<JsonNode> Paper(AttemptAnswerFixture fixture) => JsonNode.Parse(
        (await fixture.Db.Attempts.SingleAsync()).PaperJson!.RootElement.GetRawText())!;
    private static async Task<string> Store(AttemptAnswerFixture fixture, JsonNode root)
    {
        var raw = root.ToJsonString();
        using var doc = JsonDocument.Parse(raw);
        (await fixture.Db.Attempts.SingleAsync()).PaperJson = doc;
        await fixture.Db.SaveChangesAsync();
        fixture.Db.ChangeTracker.Clear();
        return raw;
    }
    private static void Group(JsonNode section, bool keepFlat = false)
    {
        section["questionGroups"] = new JsonArray(new JsonObject
        {
            ["id"] = Guid.NewGuid().ToString(), ["idx"] = 1, ["startIdx"] = 7, ["endIdx"] = 7,
            ["instructionMd"] = "Public group instruction", ["questions"] = section["questions"]!.DeepClone()
        });
        if (!keepFlat) section.AsObject().Remove("questions");
    }
}
