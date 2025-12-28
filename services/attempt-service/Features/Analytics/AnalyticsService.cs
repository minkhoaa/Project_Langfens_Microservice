using attempt_service.Domain.Enums;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace attempt_service.Features.Analytics;

public interface IAnalyticsService
{
    Task<IResult> GetSummary(Guid userId, CancellationToken token);
    Task<IResult> GetScoreTrend(Guid userId, int days, CancellationToken token);
    Task<IResult> GetStrengthsWeaknesses(Guid userId, CancellationToken token);
    Task<IResult> GetRecentActivity(Guid userId, int limit, CancellationToken token);
    Task<IResult> GetWrongAnswers(Guid userId, string? skill, string? questionType, DateTime? fromDate, int page, int pageSize, CancellationToken token);
}

public class AnalyticsService(AttemptDbContext context) : IAnalyticsService
{
    public async Task<IResult> GetSummary(Guid userId, CancellationToken token)
    {
        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId && a.Status == AttemptStatus.Graded)
            .ToListAsync(token);

        if (attempts.Count == 0)
        {
            return Results.Ok(new ApiResultDto(true, "No data", new AnalyticsSummaryDto(0, 0, 0, 0, new())));
        }

        var totalStudyTimeMin = attempts.Sum(a => a.DurationSec) / 60;
        var avgScore = attempts.Where(a => a.ScaledScore.HasValue).Average(a => a.ScaledScore!.Value);

        // Calculate streak based on consecutive days with graded attempts
        var streak = CalculateStreak(attempts);

        // Group by exam to determine skill (using PaperJson or ExamId)
        // For simplicity, assume all are mixed - can enhance later
        var testsBySkill = new Dictionary<string, int>
        {
            ["READING"] = attempts.Count / 2,
            ["LISTENING"] = attempts.Count - attempts.Count / 2
        };

        var summary = new AnalyticsSummaryDto(
            attempts.Count,
            totalStudyTimeMin,
            Math.Round(avgScore, 1),
            streak,
            testsBySkill
        );

        return Results.Ok(new ApiResultDto(true, "Summary fetched", summary));
    }

    public async Task<IResult> GetScoreTrend(Guid userId, int days, CancellationToken token)
    {
        days = Math.Clamp(days, 7, 365);
        var startDate = DateTime.UtcNow.AddDays(-days);

        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId 
                && a.Status == AttemptStatus.Graded 
                && a.SubmittedAt >= startDate
                && a.ScaledScore.HasValue)
            .OrderBy(a => a.SubmittedAt)
            .ToListAsync(token);

        var groupedByDate = attempts
            .GroupBy(a => DateOnly.FromDateTime(a.SubmittedAt!.Value))
            .Select(g => new ScoreTrendPointDto(
                g.Key,
                Math.Round(g.Average(a => a.ScaledScore!.Value), 1),
                g.Count()
            ))
            .ToList();

        return Results.Ok(new ApiResultDto(true, "Score trend fetched", new ScoreTrendDto(groupedByDate)));
    }

    public async Task<IResult> GetStrengthsWeaknesses(Guid userId, CancellationToken token)
    {
        // Get all answers for user's graded attempts with PaperJson for question types
        var attempts = await context.Attempts
            .AsNoTracking()
            .Include(a => a.Answers)
            .Where(a => a.UserId == userId 
                && a.Status == AttemptStatus.Graded)
            .ToListAsync(token);

        var allAnswers = attempts.SelectMany(a => a.Answers).Where(a => a.IsCorrect.HasValue).ToList();

        if (allAnswers.Count == 0)
        {
            return Results.Ok(new ApiResultDto(true, "No data", new StrengthsWeaknessesDto(new(), new())));
        }

        // Build question type lookup from all PaperJson
        var questionTypes = new Dictionary<Guid, string>();
        foreach (var attempt in attempts)
        {
            ExtractQuestionTypes(attempt.PaperJson, questionTypes);
        }

        // Group by question type
        var byQuestionType = allAnswers
            .GroupBy(a => questionTypes.TryGetValue(a.QuestionId, out var type) ? type : "UNKNOWN")
            .Where(g => g.Key != "UNKNOWN")
            .Select(g => new QuestionTypeAccuracyDto(
                FormatQuestionType(g.Key),
                Math.Round((double)g.Count(a => a.IsCorrect == true) / g.Count() * 100, 1),
                g.Count(),
                g.Count(a => a.IsCorrect == true)
            ))
            .OrderByDescending(x => x.Accuracy)
            .ToList();

        var strengths = byQuestionType.Where(x => x.Accuracy >= 70).Take(3).ToList();
        var weaknesses = byQuestionType.Where(x => x.Accuracy < 60).OrderBy(x => x.Accuracy).Take(3).ToList();

        return Results.Ok(new ApiResultDto(true, "Strengths/weaknesses fetched", 
            new StrengthsWeaknessesDto(strengths, weaknesses)));
    }

    private static void ExtractQuestionTypes(System.Text.Json.JsonDocument? paperJson, Dictionary<Guid, string> questionTypes)
    {
        if (paperJson == null) return;
        try
        {
            if (paperJson.RootElement.TryGetProperty("sections", out var sections) && sections.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                foreach (var section in sections.EnumerateArray())
                {
                    // Extract from questionGroups
                    if (section.TryGetProperty("questionGroups", out var groupsEl) && groupsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                    {
                        foreach (var grp in groupsEl.EnumerateArray())
                        {
                            if (grp.TryGetProperty("questions", out var questionsEl) && questionsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                            {
                                foreach (var q in questionsEl.EnumerateArray())
                                {
                                    if (q.TryGetProperty("id", out var idEl) && Guid.TryParse(idEl.GetString(), out var qId))
                                    {
                                        var type = q.TryGetProperty("type", out var typeEl) ? typeEl.GetString() : null;
                                        if (!string.IsNullOrEmpty(type) && !questionTypes.ContainsKey(qId))
                                        {
                                            questionTypes[qId] = type;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }

    private static string FormatQuestionType(string type)
    {
        return type.Replace("_", " ") switch
        {
            "TRUE FALSE NOT GIVEN" => "True/False/Not Given",
            "YES NO NOT GIVEN" => "Yes/No/Not Given",
            "MATCHING HEADING" => "Matching Headings",
            "MATCHING FEATURES" => "Matching Features",
            "MATCHING INFORMATION" => "Matching Information",
            "SUMMARY COMPLETION" => "Summary Completion",
            "SENTENCE COMPLETION" => "Sentence Completion",
            "MCQ SINGLE" => "Multiple Choice",
            "MCQ MULTIPLE" => "Multiple Selection",
            "SHORT ANSWER" => "Short Answer",
            "TABLE COMPLETION" => "Table Completion",
            "MAP LABEL" => "Map Labelling",
            "DIAGRAM LABEL" => "Diagram Labelling",
            "AUDIO RESPONSE" => "Speaking (Ghi âm)",
            "WRITING TASK" => "Writing Task",
            "LONG TEXT" => "Writing (Viết)",
            var x => x
        };
    }

    private static void ExtractSectionNames(System.Text.Json.JsonDocument? paperJson, Dictionary<Guid, string> sectionNames)
    {
        if (paperJson == null) return;
        try
        {
            if (paperJson.RootElement.TryGetProperty("sections", out var sections) && sections.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                foreach (var section in sections.EnumerateArray())
                {
                    if (section.TryGetProperty("id", out var idEl) && section.TryGetProperty("title", out var titleEl))
                    {
                        if (Guid.TryParse(idEl.GetString(), out var sectionId))
                        {
                            var title = titleEl.GetString();
                            if (!string.IsNullOrEmpty(title) && !sectionNames.ContainsKey(sectionId))
                            {
                                sectionNames[sectionId] = title;
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }

    public async Task<IResult> GetRecentActivity(Guid userId, int limit, CancellationToken token)
    {
        limit = Math.Clamp(limit, 1, 50);

        var attempts = await context.Attempts
            .AsNoTracking()
            .Where(a => a.UserId == userId && a.Status == AttemptStatus.Graded)
            .OrderByDescending(a => a.SubmittedAt)
            .Take(limit)
            .ToListAsync(token);

        var activities = attempts.Select(a => new RecentActivityDto(
            "TEST",
            a.ExamId,
            ExtractExamTitle(a.PaperJson),
            a.ScaledScore,
            a.SubmittedAt ?? a.CreatedAt,
            a.DurationSec / 60
        )).ToList();

        return Results.Ok(new ApiResultDto(true, "Recent activities fetched", new RecentActivitiesDto(activities)));
    }

    private static string? ExtractExamTitle(System.Text.Json.JsonDocument? paperJson)
    {
        if (paperJson == null) return null;
        try
        {
            if (paperJson.RootElement.TryGetProperty("title", out var titleElement))
            {
                return titleElement.GetString();
            }
        }
        catch { }
        return null;
    }

    private static int CalculateStreak(List<Domain.Entities.Attempt> attempts)
    {
        if (attempts.Count == 0) return 0;

        var dates = attempts
            .Where(a => a.SubmittedAt.HasValue)
            .Select(a => DateOnly.FromDateTime(a.SubmittedAt!.Value))
            .Distinct()
            .OrderByDescending(d => d)
            .ToList();

        if (dates.Count == 0) return 0;

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (dates[0] < today.AddDays(-1)) return 0; // Streak broken

        int streak = 0;
        var expectedDate = dates[0];
        foreach (var date in dates)
        {
            if (date == expectedDate || date == expectedDate.AddDays(-1))
            {
                streak++;
                expectedDate = date.AddDays(-1);
            }
            else break;
        }

        return streak;
    }

    public async Task<IResult> GetWrongAnswers(Guid userId, string? skill, string? questionType, DateTime? fromDate, int page, int pageSize, CancellationToken token)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);
        fromDate ??= DateTime.UtcNow.AddMonths(-3);

        // Get attempts with answers
        var attemptsQuery = context.Attempts
            .AsNoTracking()
            .Include(a => a.Answers)
            .Where(a => a.UserId == userId 
                && a.Status == AttemptStatus.Graded
                && a.SubmittedAt >= fromDate);

        var attempts = await attemptsQuery.ToListAsync(token);

        // Build section/question info from PaperJson
        var wrongAnswers = new List<WrongAnswerDto>();
        
        foreach (var attempt in attempts)
        {
            var paperInfo = ExtractPaperInfo(attempt.PaperJson);
            
            foreach (var answer in attempt.Answers.Where(a => a.IsCorrect == false))
            {
                var questionInfo = paperInfo.Questions.GetValueOrDefault(answer.QuestionId);
                var sectionInfo = paperInfo.Sections.GetValueOrDefault(answer.SectionId);
                
                // Filter by skill if specified
                if (!string.IsNullOrEmpty(skill) && sectionInfo?.Skill?.ToUpper() != skill.ToUpper())
                    continue;
                
                // Filter by question type if specified
                if (!string.IsNullOrEmpty(questionType) && questionInfo?.Type?.ToUpper() != questionType.ToUpper())
                    continue;

                wrongAnswers.Add(new WrongAnswerDto(
                    answer.Id,
                    answer.QuestionId,
                    questionInfo?.Content ?? "Unknown question",
                    questionInfo?.Type ?? "UNKNOWN",
                    sectionInfo?.Skill ?? "READING",
                    sectionInfo?.Title ?? "Unknown section",
                    answer.TextAnswer ?? string.Join(", ", answer.SelectedOptionIds ?? new List<Guid>()),
                    questionInfo?.CorrectAnswer ?? "",
                    questionInfo?.Explanation,
                    attempt.SubmittedAt ?? attempt.CreatedAt,
                    attempt.ExamId,
                    attempt.Id
                ));
            }
        }

        // Sort by date descending and paginate
        var total = wrongAnswers.Count;
        var items = wrongAnswers
            .OrderByDescending(w => w.AttemptDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        // Group stats by question type
        var statsByType = wrongAnswers
            .GroupBy(w => w.QuestionType)
            .ToDictionary(g => g.Key, g => g.Count());

        return Results.Ok(new ApiResultDto(true, "Wrong answers fetched", new WrongAnswersResultDto(
            items,
            total,
            page,
            pageSize,
            statsByType
        )));
    }

    private record PaperInfo(
        Dictionary<Guid, SectionInfo> Sections,
        Dictionary<Guid, QuestionInfo> Questions
    );
    
    private record SectionInfo(string? Title, string? Skill);
    private record QuestionInfo(string? Content, string? Type, string? CorrectAnswer, string? Explanation);

    private static PaperInfo ExtractPaperInfo(System.Text.Json.JsonDocument? paperJson)
    {
        var sections = new Dictionary<Guid, SectionInfo>();
        var questions = new Dictionary<Guid, QuestionInfo>();
        
        if (paperJson == null) return new PaperInfo(sections, questions);
        
        try
        {
            if (paperJson.RootElement.TryGetProperty("sections", out var sectionsEl) && sectionsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                foreach (var section in sectionsEl.EnumerateArray())
                {
                    if (section.TryGetProperty("id", out var idEl) && Guid.TryParse(idEl.GetString(), out var sectionId))
                    {
                        var title = section.TryGetProperty("title", out var t) ? t.GetString() : null;
                        var skill = section.TryGetProperty("skill", out var s) ? s.GetString() : null;
                        sections[sectionId] = new SectionInfo(title, skill);

                        // Extract questions from questionGroups (new structure)
                        if (section.TryGetProperty("questionGroups", out var groupsEl) && groupsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                        {
                            foreach (var grp in groupsEl.EnumerateArray())
                            {
                                if (grp.TryGetProperty("questions", out var questionsEl) && questionsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                                {
                                    ExtractQuestionsFromArray(questionsEl, questions);
                                }
                            }
                        }
                        
                        // Also check direct questions array (old structure)
                        if (section.TryGetProperty("questions", out var directQuestionsEl) && directQuestionsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                        {
                            ExtractQuestionsFromArray(directQuestionsEl, questions);
                        }
                    }
                }
            }
        }
        catch { }
        
        return new PaperInfo(sections, questions);
    }

    private static void ExtractQuestionsFromArray(System.Text.Json.JsonElement questionsEl, Dictionary<Guid, QuestionInfo> questions)
    {
        foreach (var q in questionsEl.EnumerateArray())
        {
            if (q.TryGetProperty("id", out var qIdEl) && Guid.TryParse(qIdEl.GetString(), out var qId))
            {
                // Try multiple property names for content (camelCase and PascalCase)
                var content = TryGetString(q, "promptMd", "PromptMd", "content", "Content", "text", "Text");
                
                var type = TryGetString(q, "type", "Type");
                
                // Try to get correct answer from different fields
                var correctAnswer = TryGetString(q, "correctAnswer", "CorrectAnswer", "correctText", "CorrectText", "modelAnswer", "ModelAnswer");
                
                // Try blankAcceptTexts (for fill-in-blank, diagram label, table completion)
                // Format: {"blank-1": ["answer1", "answer2"], ...}
                if (string.IsNullOrEmpty(correctAnswer))
                {
                    correctAnswer = TryGetObjectMapValues(q, "blankAcceptTexts", "BlankAcceptTexts");
                }
                
                // Try completionAccepts (for sentence/summary completion)
                if (string.IsNullOrEmpty(correctAnswer))
                {
                    correctAnswer = TryGetCompletionAccepts(q);
                }
                
                // Try shortAnswerAcceptTexts
                if (string.IsNullOrEmpty(correctAnswer))
                {
                    correctAnswer = TryGetStringArrayJoined(q, " / ", "shortAnswerAcceptTexts", "ShortAnswerAcceptTexts");
                }
                
                // Try matchPairs (for matching questions)
                if (string.IsNullOrEmpty(correctAnswer))
                {
                    correctAnswer = TryGetMatchPairs(q);
                }
                
                // If no direct correct answer, try to find from options (MCQ)
                if (string.IsNullOrEmpty(correctAnswer))
                {
                    if (q.TryGetProperty("options", out var opts) && opts.ValueKind == System.Text.Json.JsonValueKind.Array)
                    {
                        var correctAnswers = new List<string>();
                        foreach (var opt in opts.EnumerateArray())
                        {
                            // Check both isCorrect and IsCorrect
                            var isCorrectProp = opt.TryGetProperty("isCorrect", out var ic1) ? ic1 
                                              : opt.TryGetProperty("IsCorrect", out var ic2) ? ic2 
                                              : default;
                            
                            if (isCorrectProp.ValueKind == System.Text.Json.JsonValueKind.True)
                            {
                                var label = TryGetString(opt, "label", "Label", "text", "Text", "contentMd", "ContentMd");
                                if (!string.IsNullOrEmpty(label))
                                {
                                    correctAnswers.Add(label);
                                }
                            }
                        }
                        if (correctAnswers.Count > 0)
                        {
                            correctAnswer = string.Join(", ", correctAnswers);
                        }
                    }
                }
                
                var explanation = TryGetString(q, "explanation", "Explanation", "explanationMd", "ExplanationMd");
                
                questions[qId] = new QuestionInfo(content, type, correctAnswer, explanation);
            }
        }
    }
    
    // For array properties like shortAnswerAcceptTexts: ["ans1", "ans2"]
    private static string? TryGetStringArrayJoined(System.Text.Json.JsonElement el, string separator, params string[] propNames)
    {
        foreach (var name in propNames)
        {
            if (el.TryGetProperty(name, out var prop) && prop.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                var items = new List<string>();
                foreach (var item in prop.EnumerateArray())
                {
                    if (item.ValueKind == System.Text.Json.JsonValueKind.String)
                    {
                        var val = item.GetString();
                        if (!string.IsNullOrEmpty(val)) items.Add(val);
                    }
                }
                if (items.Count > 0) return string.Join(separator, items);
            }
        }
        return null;
    }
    
    // For object/map properties like blankAcceptTexts: {"blank-1": ["ans1", "ans2"], "blank-2": ["ans3"]}
    private static string? TryGetObjectMapValues(System.Text.Json.JsonElement el, params string[] propNames)
    {
        foreach (var name in propNames)
        {
            if (el.TryGetProperty(name, out var prop) && prop.ValueKind == System.Text.Json.JsonValueKind.Object)
            {
                var answers = new List<string>();
                foreach (var kvp in prop.EnumerateObject())
                {
                    // Each value can be array of strings or single string
                    if (kvp.Value.ValueKind == System.Text.Json.JsonValueKind.Array)
                    {
                        var items = new List<string>();
                        foreach (var item in kvp.Value.EnumerateArray())
                        {
                            if (item.ValueKind == System.Text.Json.JsonValueKind.String)
                            {
                                var val = item.GetString();
                                if (!string.IsNullOrEmpty(val)) items.Add(val);
                            }
                        }
                        if (items.Count > 0)
                        {
                            // Join multiple valid answers with "/"
                            answers.Add(string.Join(" / ", items));
                        }
                    }
                    else if (kvp.Value.ValueKind == System.Text.Json.JsonValueKind.String)
                    {
                        var val = kvp.Value.GetString();
                        if (!string.IsNullOrEmpty(val)) answers.Add(val);
                    }
                }
                // For single question, usually just one entry
                if (answers.Count > 0) return string.Join("; ", answers);
            }
        }
        return null;
    }
    
    private static string? TryGetCompletionAccepts(System.Text.Json.JsonElement q)
    {
        // Protobuf format: completionAccepts: [{blankId: "blank-1", acceptedTexts: ["answer1"]}, ...]
        // JSON DTO format: completionAccepts: [{gapKey: "blank-1", acceptTexts: ["answer1"]}, ...]
        foreach (var name in new[] { "completionAccepts", "CompletionAccepts" })
        {
            if (q.TryGetProperty(name, out var accepts) && accepts.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                var answers = new List<string>();
                foreach (var gap in accepts.EnumerateArray())
                {
                    // Try protobuf format first (acceptedTexts), then fallback to DTO format (acceptTexts)
                    var texts = TryGetStringArrayJoined(gap, " / ", "acceptedTexts", "AcceptedTexts", "acceptTexts", "AcceptTexts");
                    if (!string.IsNullOrEmpty(texts))
                    {
                        answers.Add(texts);
                    }
                }
                if (answers.Count > 0) return string.Join("; ", answers);
            }
        }
        return null;
    }
    
    private static string? TryGetMatchPairs(System.Text.Json.JsonElement q)
    {
        foreach (var name in new[] { "matchPairs", "MatchPairs" })
        {
            if (!q.TryGetProperty(name, out var pairs)) continue;
            
            // Handle Object format: {"q1": ["A"], "q2": ["B", "C"]} - textArrayMap schema
            if (pairs.ValueKind == System.Text.Json.JsonValueKind.Object)
            {
                var answers = new List<string>();
                foreach (var kvp in pairs.EnumerateObject())
                {
                    if (kvp.Value.ValueKind == System.Text.Json.JsonValueKind.Array)
                    {
                        foreach (var item in kvp.Value.EnumerateArray())
                        {
                            if (item.ValueKind == System.Text.Json.JsonValueKind.String)
                            {
                                var val = item.GetString();
                                if (!string.IsNullOrEmpty(val)) answers.Add(val);
                            }
                        }
                    }
                    else if (kvp.Value.ValueKind == System.Text.Json.JsonValueKind.String)
                    {
                        var val = kvp.Value.GetString();
                        if (!string.IsNullOrEmpty(val)) answers.Add(val);
                    }
                }
                if (answers.Count > 0) return string.Join(", ", answers);
            }
            // Handle Array format: [{promptKey: "q1", acceptedValues: ["A","a"]}, ...] or [{correctKey: "A"}, ...]
            else if (pairs.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                var answers = new List<string>();
                foreach (var pair in pairs.EnumerateArray())
                {
                    // Try acceptedValues array first (actual data format)
                    if (pair.TryGetProperty("acceptedValues", out var acceptedVals) && 
                        acceptedVals.ValueKind == System.Text.Json.JsonValueKind.Array)
                    {
                        foreach (var item in acceptedVals.EnumerateArray())
                        {
                            if (item.ValueKind == System.Text.Json.JsonValueKind.String)
                            {
                                var val = item.GetString();
                                if (!string.IsNullOrEmpty(val))
                                {
                                    answers.Add(val);
                                    break; // Take first accepted value only
                                }
                            }
                        }
                    }
                    // Fall back to correctKey/answerKey
                    else
                    {
                        var correctKey = TryGetString(pair, "correctKey", "CorrectKey", "answerKey", "AnswerKey");
                        if (!string.IsNullOrEmpty(correctKey))
                        {
                            answers.Add(correctKey);
                        }
                    }
                }
                if (answers.Count > 0) return string.Join(", ", answers);
            }
        }
        return null;
    }

    private static string? TryGetString(System.Text.Json.JsonElement el, params string[] propNames)
    {
        foreach (var name in propNames)
        {
            if (el.TryGetProperty(name, out var prop) && prop.ValueKind == System.Text.Json.JsonValueKind.String)
            {
                return prop.GetString();
            }
        }
        return null;
    }
}
