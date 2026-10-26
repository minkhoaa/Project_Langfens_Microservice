using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;

namespace exam_service.Features.ReadingPaper;

public static class ReadingPaperAcceptanceContract
{
    private static string Family(int n) => n <= 5 ? "TRUE_FALSE_NOT_GIVEN" : n <= 9 ? "TABLE_COMPLETION" : "FLOW_CHART";

    // Defense at the persistence boundary: an evaluator PASS is not authority to
    // substitute a different acceptance contract or strip a table/flow stimulus.
    public static void Validate(ReadingPaperRun run, ArtifactEnvelope artifact)
    {
        try { ValidateCore(run, artifact); }
        catch (Exception ex) when (ex is KeyNotFoundException or InvalidOperationException or JsonException or IndexOutOfRangeException)
        { throw new CheckpointValidationException(422, "Malformed pinned acceptance artifact: " + ex.Message); }
    }

    private static void ValidateCore(ReadingPaperRun run, ArtifactEnvelope artifact)
    {
        using var snapshot = JsonDocument.Parse(run.BudgetProfileJson);
        if (!snapshot.RootElement.TryGetProperty("executionPolicy", out var wire) ||
            !wire.TryGetProperty("blueprintMode", out var mode) || mode.GetString() != PinnedExecutionPolicy.Acceptance544) return;
        var policy = ReadingPaperExecutionSnapshot.Read(run);
        var payload = artifact.Payload;
        void Require(bool condition)
        {
            if (!condition) throw new CheckpointValidationException(422, "Artifact violates pinned 5/4/4 acceptance contract");
        }
        bool Text(JsonElement item, string name) => item.TryGetProperty(name, out var value) &&
            value.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(value.GetString());
        void Question(JsonElement question)
        {
            Require(question.TryGetProperty("questionNumber", out var number) && number.TryGetInt32(out _));
            var n = question.GetProperty("questionNumber").GetInt32();
            Require(n is >= 1 and <= 13 && question.TryGetProperty("questionType", out var family) && family.GetString() == Family(n));
            if (n is >= 6 and <= 9) Require(Text(question, "tableContext") && Text(question, "rowHeader") && Text(question, "colHeader"));
            if (n >= 10)
            {
                Require(question.TryGetProperty("flowSteps", out var steps) && steps.ValueKind == JsonValueKind.Array && steps.GetArrayLength() >= 2);
                Require(question.TryGetProperty("stepIndex", out var index) && index.TryGetInt32(out var step) && step >= 0 && step < steps.GetArrayLength());
                var selected = steps[question.GetProperty("stepIndex").GetInt32()];
                Require(selected.ValueKind == JsonValueKind.String && selected.GetString()!.Contains($"[{n}]", StringComparison.Ordinal));
            }
        }
        if (artifact.ArtifactType == ArtifactType.ExamBlueprint)
        {
            Require(payload.TryGetProperty("metadata", out var metadata) && metadata.TryGetProperty("policyHash", out var hash) && hash.GetString() == policy.ComputeHash());
            var sections = payload.GetProperty("sections");
            Require(sections.GetArrayLength() == 1);
            var slots = sections[0].GetProperty("questionSlots").EnumerateArray().ToArray();
            Require(slots.Length == 13);
            for (var i = 0; i < slots.Length; i++)
                Require(slots[i].GetProperty("questionNumber").GetInt32() == i + 1 && slots[i].GetProperty("questionType").GetString() == Family(i + 1));
            var claims = slots.SelectMany(s => s.GetProperty("claimRefIds").EnumerateArray().Select(c => c.GetString())).ToArray();
            Require(claims.Length == 13 && claims.All(c => !string.IsNullOrWhiteSpace(c)) && claims.Distinct().Count() == 13);
        }
        if (artifact.ArtifactType == ArtifactType.Question) Question(payload);
        if (artifact.ArtifactType == ArtifactType.Section)
        {
            var groups = payload.GetProperty("groups").EnumerateArray().ToArray();
            Require(groups.Length == 3);
            var questions = groups.SelectMany(g => g.GetProperty("questions").EnumerateArray()).ToArray();
            Require(questions.Length == 13);
            for (var i = 0; i < questions.Length; i++)
            {
                Require(questions[i].GetProperty("questionNumber").GetInt32() == i + 1);
                Question(questions[i]);
            }
            for (var i = 0; i < groups.Length; i++)
                Require(groups[i].GetProperty("questionType").GetString() == Family(i == 0 ? 1 : i == 1 ? 6 : 10) &&
                    groups[i].GetProperty("questions").GetArrayLength() == (i == 0 ? 5 : 4));
        }
    }
}
