using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;

// Pure stdin/stdout fixture adapter. No service host, DI, HTTP, database, credentials or AI.
if (args.Contains("--privacy-probe"))
{
    var q = new Shared.Grpc.ExamInternal.InternalDeliveryQuestion { ExplanationMd = "PRIVATE-EXPLANATION-SENTINEL" };
    var blank = new Shared.Grpc.ExamInternal.InternalCompletionAccept { BlankId = "1" };
    blank.AcceptedTexts.Add("PRIVATE-ANSWER-SENTINEL"); q.CompletionAccepts.Add(blank);
    var group = new Shared.Grpc.ExamInternal.InternalDeliveryQuestionGroup(); group.Questions.Add(q);
    var sec = new Shared.Grpc.ExamInternal.InternalDeliverySection(); sec.QuestionGroups.Add(group);
    var exam = new Shared.Grpc.ExamInternal.InternalDeliveryExam(); exam.Sections.Add(sec);
    var student = GrpcSnapshotSanitizer.Sanitize(exam).Sections[0].QuestionGroups[0].Questions[0];
    Console.WriteLine(JsonSerializer.Serialize(new { explanationLeaked = student.ExplanationMd == q.ExplanationMd, acceptedValuesRemoved = student.CompletionAccepts[0].AcceptedTexts.Count == 0, originalUnchanged = q.CompletionAccepts[0].AcceptedTexts.Count == 1 }));
    return;
}
using var doc = JsonDocument.Parse(Console.In.ReadToEnd());
var output = new List<object>();
var section = Guid.Parse("11111111-0000-0000-0000-000000000001");
foreach (var item in doc.RootElement.EnumerateArray())
{
    var q = item.GetProperty("question");
    var answer = item.GetProperty("answer");
    var id = q.GetProperty("id").GetGuid();
    var type = q.GetProperty("type").GetString()!;
    var options = q.GetProperty("options").EnumerateArray().ToArray();
    Dictionary<string, string[]?>? Map(string name) => q.TryGetProperty(name, out var value)
        ? value.EnumerateObject().ToDictionary(p => p.Name, p => (string[]?)p.Value.EnumerateArray().Select(x => x.GetString()!).ToArray()) : null;
    List<string>? List(string name) => q.TryGetProperty(name, out var value) ? value.EnumerateArray().Select(x => x.GetString()!).ToList() : null;
    var key = new QuestionKey(id, type, 1m,
        options.Where(o => o.GetProperty("isCorrect").GetBoolean()).Select(o => (o.GetProperty("id").GetGuid(), o.GetProperty("contentMd").GetString()!)).ToHashSet(),
        Map("blankAcceptTexts"), Map("blankAcceptRegex"), Map("matchPairs"), List("orderCorrects"), List("shortAnswerAcceptTexts"), List("shortAnswerAcceptRegex"));
    var selected = answer.TryGetProperty("selectedOptionIds", out var selections) ? selections.EnumerateArray().Select(x => x.GetGuid()).ToList() : new List<Guid>();
    var text = answer.TryGetProperty("textAnswer", out var raw) ? raw.GetString() : null;
    var index = new Dictionary<Guid, QMeta> { [id] = new(section, type, options.Select(o => (o.GetProperty("id").GetGuid(), o.GetProperty("contentMd").GetString()!)).ToHashSet()) };
    var validation = new AnswerValidator().Validate(new AnswerItem(id, section, selected, text), index);
    IQuestionGrader grader = type switch {
        "MULTIPLE_CHOICE_SINGLE" or "MULTIPLE_CHOICE_SINGLE_IMAGE" or "TRUE_FALSE_NOT_GIVEN" or "YES_NO_NOT_GIVEN" => new SingleChoiceGrader(),
        "MULTIPLE_CHOICE_MULTIPLE" => new MultipleChoiceGrader(),
        "MATCHING_HEADING" or "MATCHING_INFORMATION" or "MATCHING_FEATURES" or "MATCHING_ENDINGS" or "CLASSIFICATION" => new MatchingHeadingGrader(),
        "FLOW_CHART" => new FlowChartGrader(),
        "SHORT_ANSWER" => new ShortAnswerGrader(),
        "DIAGRAM_LABEL" or "MAP_LABEL" => new LabelGrader(),
        "SUMMARY_COMPLETION" or "TABLE_COMPLETION" or "NOTE_COMPLETION" or "FORM_COMPLETION" or "SENTENCE_COMPLETION" => new CompletionGrader(),
        _ => throw new InvalidOperationException($"Unknown type {type}")
    };
    var result = grader.Grade(new AttemptAnswer { QuestionId = id, SectionId = section, SelectedOptionIds = selected, TextAnswer = text }, key);
    output.Add(new { id = item.GetProperty("id").GetString(), validation, awardedPoints = result.AwardedPoints, isCorrect = result.IsCorrect });
}
Console.WriteLine(JsonSerializer.Serialize(output));
