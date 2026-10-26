using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Text.Json;
using exam_service.Domains.Entities;

namespace exam_service.Features.ReadingPaper;

// Execution policy and resource ceilings share one immutable, hash-bound snapshot.
// Historical runs without this carrier require explicit migration, never defaults.
public static class ReadingPaperExecutionSnapshot
{
    public static void Pin(ReadingPaperRun run, PinnedExecutionPolicy policy)
    {
        if (!ReadingPaperCapsProfile.IsValidSnapshot(run.BudgetProfileJson, run.BudgetProfileSha256))
            throw new InvalidOperationException("Cannot pin execution policy into an invalid resource snapshot");
        using var profile = JsonDocument.Parse(run.BudgetProfileJson);
        if (profile.RootElement.TryGetProperty("executionPolicy", out _) ||
            profile.RootElement.TryGetProperty("executionPolicyHash", out _))
            throw new InvalidOperationException("Execution policy is already pinned");
        Validate(policy);
        var fields = profile.RootElement.EnumerateObject().ToDictionary(p => p.Name, p => p.Value.Clone());
        fields["executionPolicy"] = JsonSerializer.SerializeToElement(policy, ReadingPaperRules.Json);
        fields["executionPolicyHash"] = JsonSerializer.SerializeToElement(policy.ComputeHash());
        run.BudgetProfileJson = Canonical(JsonSerializer.SerializeToElement(fields));
        run.BudgetProfileSha256 = Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(run.BudgetProfileJson)));
    }

    public static PinnedExecutionPolicy Read(ReadingPaperRun run)
    {
        try
        {
            if (!ReadingPaperCapsProfile.IsValidSnapshot(run.BudgetProfileJson, run.BudgetProfileSha256))
                throw new InvalidOperationException("Invalid pinned snapshot hash");
            using var profile = JsonDocument.Parse(run.BudgetProfileJson);
            var root = profile.RootElement;
            var wire = root.GetProperty("executionPolicy");
            var policy = wire.Deserialize<PinnedExecutionPolicy>(ReadingPaperRules.Json)
                ?? throw new InvalidOperationException("Missing pinned execution policy");
            Validate(policy);
            if (Canonical(wire) != Canonical(JsonSerializer.SerializeToElement(policy, ReadingPaperRules.Json)) ||
                root.GetProperty("executionPolicyHash").GetString() != policy.ComputeHash())
                throw new InvalidOperationException("Corrupt pinned execution policy or hash");
            return policy;
        }
        catch (Exception ex) when (ex is JsonException or KeyNotFoundException or ArgumentException)
        {
            throw new InvalidOperationException("Missing or corrupt pinned execution policy; explicit migration required", ex);
        }
    }

    private static void Validate(PinnedExecutionPolicy p)
    {
        if (string.IsNullOrWhiteSpace(p.Provider) || !p.RequireBlindSolver ||
            !double.IsFinite(p.ProviderCallSeconds) || p.ProviderCallSeconds is <= 0 or > 180 ||
            !double.IsFinite(p.SectionWallSeconds) || p.SectionWallSeconds is <= 0 or > 900 ||
            p.SectionTokenCap is <= 0 or > 100000 || p.RunTokenCap <= 0 ||
            !double.IsFinite(p.RunWallSeconds) || p.RunWallSeconds <= 0 ||
            p.MaxCandidates is <= 0 or > 20 || p.MaxRepairs is < 0 or > 10 ||
            p.MaxEvaluationsPerArtifact is <= 0 or > 32 || p.MaxDependencyDepth is <= 0 or > 8 ||
            p.MaxRecoveryAttempts is < 0 or > 10 || p.SourceMinWords <= 0 || p.MinVerifiedClaims <= 0 ||
            p.PaperMinWords <= 0 || p.PaperMaxWords < p.PaperMinWords || p.Sections is not { Count: > 0 })
            throw new InvalidOperationException("Invalid pinned execution policy");
        if (p.BlueprintMode == PinnedExecutionPolicy.Acceptance544 &&
            (p.Sections.Count != 1 || p.Sections[0].Index != 1 || p.Sections[0].StartNumber != 1 ||
             !p.Sections[0].Groups.Select(g => (g.QuestionType, g.Count)).SequenceEqual(new[] {
                 ("TRUE_FALSE_NOT_GIVEN", 5), ("TABLE_COMPLETION", 4), ("FLOW_CHART", 4) })))
            throw new InvalidOperationException("Acceptance policy requires exact Section 1 5/4/4 allocation");
        int? nextSection = null, nextQuestion = null;
        foreach (var s in p.Sections.OrderBy(s => s.Index))
        {
            if (s.Index is < 1 or > 3 || (nextSection != null && s.Index != nextSection) ||
                s.StartNumber is < 1 or > 40 || (nextQuestion != null && s.StartNumber != nextQuestion) ||
                s.MinWords <= 0 || s.MaxWords < s.MinWords || string.IsNullOrWhiteSpace(s.EditorialObjective) ||
                string.IsNullOrWhiteSpace(s.Difficulty) || s.Groups is not { Count: > 0 } ||
                s.Groups.Any(g => g.Count is <= 0 or > 40 || string.IsNullOrWhiteSpace(g.QuestionType)) ||
                s.StartNumber + s.Groups.Sum(g => (long)g.Count) - 1 > 40)
                throw new InvalidOperationException("Invalid pinned section allocation");
            nextSection = s.Index + 1;
            nextQuestion = s.StartNumber + s.Groups.Sum(g => g.Count);
        }
    }

    private static string Canonical(JsonElement element)
    {
        using var stream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(stream, new JsonWriterOptions { Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping }))
            Write(writer, element);
        return Encoding.UTF8.GetString(stream.ToArray());
    }

    private static void Write(Utf8JsonWriter writer, JsonElement element)
    {
        if (element.ValueKind == JsonValueKind.Object)
        {
            writer.WriteStartObject();
            foreach (var p in element.EnumerateObject().OrderBy(p => p.Name, StringComparer.Ordinal))
            { writer.WritePropertyName(p.Name); Write(writer, p.Value); }
            writer.WriteEndObject();
        }
        else if (element.ValueKind == JsonValueKind.Array)
        {
            writer.WriteStartArray();
            foreach (var item in element.EnumerateArray()) Write(writer, item);
            writer.WriteEndArray();
        }
        else if (element.ValueKind == JsonValueKind.Number && element.TryGetDouble(out var n) && n == Math.Truncate(n) && n >= long.MinValue && n < long.MaxValue)
            writer.WriteNumberValue((long)n);
        else element.WriteTo(writer);
    }
}
