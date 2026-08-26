using System.Net.Http.Json;
using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Attempt;

/// <summary>
/// Fire-and-forget RAG explainer (spec §4.6). For each AttemptAnswer on
/// READING/LISTENING skills, POSTs the learner question + answer + options
/// to ai-service and writes the explanation envelope into
/// <see cref="AttemptAnswer.RagFeedbackJson"/>. The total wall-clock budget
/// is 3 seconds (enforced by <c>AttemptFlow.SafeRagAsync</c>'s
/// <c>WaitAsync(TimeSpan.FromSeconds(3))</c>); each per-item call is capped
/// at 2 seconds so the outer timeout cancels any stragglers cleanly.
/// </summary>
public sealed class RagExplainer(
    AttemptDbContext db,
    IHttpClientFactory httpFactory,
    ILogger<RagExplainer> log)
{
    private const string ReadingPath = "/api/v1/reading/explain-item";
    private const string ListeningPath = "/api/v1/listening/explain-item";
    private static readonly TimeSpan PerCallTimeout = TimeSpan.FromSeconds(2);

    public async Task<bool> ExplainAsync(Guid attemptId, Guid examId)
    {
        var attempt = await db.Attempts
            .Include(a => a.Answers)
            .FirstOrDefaultAsync(a => a.Id == attemptId);

        if (attempt is null)
        {
            log.LogDebug("Attempt {AttemptId} not found; skipping RAG.", attemptId);
            return false;
        }

        // Build questionId → (skill, question, passage|transcript) map from PaperJson.
        // Attempt entity has no Skill property; per-question skill lives on
        // PaperQuestion.Skill, and passage/transcript live on PaperSection.
        var ctxByQuestion = new Dictionary<Guid, RagContext>();
        PaperJson? paper;
        try
        {
            paper = JsonSerializer.Deserialize<PaperJson>(
                attempt.PaperJson.RootElement.GetRawText(),
                new JsonSerializerOptions(JsonSerializerDefaults.Web));
        }
        catch (JsonException ex)
        {
            log.LogWarning(ex, "PaperJson malformed for attempt {AttemptId}; skipping RAG.", attemptId);
            return false;
        }

        if (paper is not null)
        {
            foreach (var section in paper.Sections)
            {
                var passage = section.PassageMd ?? "";
                var transcript = section.TranscriptMd ?? "";
                IEnumerable<PaperQuestion> questions =
                    section.QuestionGroups.SelectMany(g => g.Questions)
                        .Concat(section.Questions);
                foreach (var q in questions)
                {
                    var ctxText = string.IsNullOrEmpty(q.Skill) || q.Skill == "READING"
                        ? passage
                        : transcript;
                    ctxByQuestion[q.Id] = new RagContext(
                        q.Skill ?? "",
                        ctxText,
                        ExtractQuestionText(q));
                }
            }
        }

        var candidates = attempt.Answers
            .Where(a => a.IsCorrect.HasValue
                && ctxByQuestion.TryGetValue(a.QuestionId, out var c)
                && (c.Skill == "READING" || c.Skill == "LISTENING"))
            .ToList();

        if (candidates.Count == 0)
        {
            log.LogDebug("No graded READING/LISTENING answers for attempt {AttemptId}; skipping RAG.", attemptId);
            return false;
        }

        var http = httpFactory.CreateClient("ai-service");
        bool any = false;

        foreach (var answer in candidates)
        {
            var ctx = ctxByQuestion[answer.QuestionId];
            var path = ctx.Skill == "READING" ? ReadingPath : ListeningPath;

            var payload = new
            {
                item_id = answer.QuestionId.ToString(),
                passage_text = ctx.Skill == "READING" ? ctx.PassageOrTranscript : "",
                transcript = ctx.Skill == "LISTENING" ? ctx.PassageOrTranscript : "",
                question = ctx.Question,
                question_type = "MCQ",
                options = Array.Empty<string>(),
                user_answer = answer.AnswerJson.RootElement.GetRawText(),
                correct_answer = "",
                language = "en-GB",
            };

            try
            {
                using var cts = new CancellationTokenSource(PerCallTimeout);
                var resp = await http.PostAsJsonAsync(path, payload, cts.Token);
                if (!resp.IsSuccessStatusCode)
                {
                    log.LogWarning("ai-service {Path} → {Status} for question {QuestionId}",
                        path, (int)resp.StatusCode, answer.QuestionId);
                    continue;
                }

                var envelope = await resp.Content.ReadFromJsonAsync<RagFeedbackEnvelope>(cts.Token);
                if (envelope is null) continue;

                answer.RagFeedbackJson = JsonDocument.Parse(JsonSerializer.Serialize(envelope));
                any = true;
            }
            catch (OperationCanceledException)
            {
                log.LogWarning("ai-service {Path} timed out for question {QuestionId}",
                    path, answer.QuestionId);
            }
            catch (Exception ex)
            {
                log.LogWarning(ex, "ai-service {Path} failed for question {QuestionId}",
                    path, answer.QuestionId);
            }
        }

        if (any) await db.SaveChangesAsync();
        return any;
    }

    private static string ExtractQuestionText(PaperQuestion q)
    {
        // Best-effort: each question type has a different payload shape. We
        // surface the raw JSON; ai-service tolerates this for SHORT_ANSWER,
        // and the prompt text lives in the section's PassageMd for READING.
        return q.Payload.ValueKind == JsonValueKind.Object
            ? q.Payload.GetRawText()
            : "";
    }

    private sealed record RagContext(
        string Skill,
        string PassageOrTranscript,
        string Question);

    private sealed record RagFeedbackEnvelope(
        string item_id,
        string domain,
        double? overall_band,
        IReadOnlyList<RagCriterionScore> criteria,
        IReadOnlyList<RagEvidence> evidence,
        IReadOnlyList<RagSuggestion> suggestions,
        string raw_llm_json);

    private sealed record RagCriterionScore(
        string name,
        double band,
        string comment,
        IReadOnlyList<string> evidence_ids);

    private sealed record RagEvidence(
        string id,
        string text,
        string source,
        double relevance);
    private sealed record RagSuggestion(
        string text,
        string target);
}
