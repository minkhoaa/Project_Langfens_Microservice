using attempt_service.Domain.Enums;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace attempt_service.Features.Analytics;

public interface IRecommendationService
{
    Task<IResult> GetRecommendations(Guid userId, int limit, CancellationToken token);
}

public class RecommendationService(AttemptDbContext context, IExamGateway examGateway) : IRecommendationService
{
    public async Task<IResult> GetRecommendations(Guid userId, int limit, CancellationToken token)
    {
        limit = Math.Clamp(limit, 1, 10);
        
        // 1. Analyze user's weaknesses
        var weaknesses = await AnalyzeWeaknesses(userId, token);
        
        if (weaknesses.Count == 0)
        {
            return Results.Ok(new ApiResultDto(true, "No recommendations available yet. Complete some tests first.", 
                new RecommendationsDto(new List<RecommendationDto>())));
        }
        
        // 2. Get available exams from exam-service
        List<ExamListItem> availableExams;
        try
        {
            availableExams = await examGateway.GetExamListAsync(token);
        }
        catch
        {
            return Results.Ok(new ApiResultDto(false, "Could not fetch exam list", 
                new RecommendationsDto(new List<RecommendationDto>())));
        }
        
        // 3. Get user's completed exam IDs to avoid suggesting same exams
        var completedExamIds = await context.Attempts
            .Where(a => a.UserId == userId && a.Status == AttemptStatus.Graded)
            .Select(a => a.ExamId)
            .Distinct()
            .ToListAsync(token);
        
        // 4. Score and rank exams based on weaknesses
        var recommendations = new List<RecommendationDto>();
        
        foreach (var exam in availableExams)
        {
            // Skip already completed exams
            if (completedExamIds.Contains(exam.Id))
                continue;
                
            // Calculate relevance score based on matching weaknesses
            var matchingReasons = new List<string>();
            double relevanceScore = 0;
            
            // Check skill match
            foreach (var weakness in weaknesses.Where(w => w.Type == WeaknessType.Skill))
            {
                if (exam.Category?.ToUpper().Contains(weakness.Name.ToUpper()) == true ||
                    exam.Title?.ToUpper().Contains(weakness.Name.ToUpper()) == true)
                {
                    relevanceScore += weakness.Score;
                    matchingReasons.Add($"Cải thiện kỹ năng {weakness.Name}");
                }
            }
            
            // Check question type match (from exam description if available)
            foreach (var weakness in weaknesses.Where(w => w.Type == WeaknessType.QuestionType))
            {
                // Check if exam likely contains this question type
                if (ExamLikelyContainsQuestionType(exam, weakness.Name))
                {
                    relevanceScore += weakness.Score * 0.5;
                    matchingReasons.Add($"Luyện tập {FormatQuestionType(weakness.Name)}");
                }
            }
            
            if (matchingReasons.Count > 0 && relevanceScore > 0)
            {
                recommendations.Add(new RecommendationDto(
                    exam.Id,
                    exam.Title ?? "Untitled",
                    exam.Category ?? "READING",
                    matchingReasons.Take(2).ToList(),
                    (int)Math.Min(100, relevanceScore * 10),
                    exam.QuestionCount
                ));
            }
        }
        
        // 5. Sort by relevance and take top N
        var topRecommendations = recommendations
            .OrderByDescending(r => r.RelevanceScore)
            .Take(limit)
            .ToList();
        
        // If no specific matches, suggest general practice
        if (topRecommendations.Count == 0 && availableExams.Count > 0)
        {
            var notCompleted = availableExams.Where(e => !completedExamIds.Contains(e.Id)).Take(3);
            foreach (var exam in notCompleted)
            {
                topRecommendations.Add(new RecommendationDto(
                    exam.Id,
                    exam.Title ?? "Untitled",
                    exam.Category ?? "READING",
                    new List<string> { "Luyện tập tổng hợp" },
                    50,
                    exam.QuestionCount
                ));
            }
        }
        
        return Results.Ok(new ApiResultDto(true, "Recommendations fetched", 
            new RecommendationsDto(topRecommendations)));
    }
    
    private async Task<List<Weakness>> AnalyzeWeaknesses(Guid userId, CancellationToken token)
    {
        var weaknesses = new List<Weakness>();
        
        // Get attempts with answers
        var attempts = await context.Attempts
            .AsNoTracking()
            .Include(a => a.Answers)
            .Where(a => a.UserId == userId && a.Status == AttemptStatus.Graded)
            .OrderByDescending(a => a.SubmittedAt)
            .Take(20) // Analyze recent 20 attempts
            .ToListAsync(token);
        
        if (attempts.Count == 0) return weaknesses;
        
        // Analyze by skill
        var skillStats = new Dictionary<string, (int correct, int total)>();
        var questionTypeStats = new Dictionary<string, (int correct, int total)>();
        
        foreach (var attempt in attempts)
        {
            var paperInfo = ExtractPaperInfo(attempt.PaperJson);
            
            foreach (var answer in attempt.Answers.Where(a => a.IsCorrect.HasValue))
            {
                // Per skill
                var skill = paperInfo.Sections.GetValueOrDefault(answer.SectionId)?.Skill ?? "READING";
                if (!skillStats.ContainsKey(skill))
                    skillStats[skill] = (0, 0);
                var s = skillStats[skill];
                skillStats[skill] = (s.correct + (answer.IsCorrect == true ? 1 : 0), s.total + 1);
                
                // Per question type
                var qType = paperInfo.Questions.GetValueOrDefault(answer.QuestionId)?.Type ?? "UNKNOWN";
                if (!questionTypeStats.ContainsKey(qType))
                    questionTypeStats[qType] = (0, 0);
                var q = questionTypeStats[qType];
                questionTypeStats[qType] = (q.correct + (answer.IsCorrect == true ? 1 : 0), q.total + 1);
            }
        }
        
        // Calculate weaknesses (accuracy < 60%)
        foreach (var (skill, stats) in skillStats)
        {
            if (stats.total >= 5) // Minimum sample size
            {
                var accuracy = (double)stats.correct / stats.total;
                if (accuracy < 0.6)
                {
                    weaknesses.Add(new Weakness(WeaknessType.Skill, skill, 10 - accuracy * 10));
                }
            }
        }
        
        foreach (var (qType, stats) in questionTypeStats)
        {
            if (stats.total >= 3 && qType != "UNKNOWN")
            {
                var accuracy = (double)stats.correct / stats.total;
                if (accuracy < 0.6)
                {
                    weaknesses.Add(new Weakness(WeaknessType.QuestionType, qType, 8 - accuracy * 8));
                }
            }
        }
        
        return weaknesses.OrderByDescending(w => w.Score).ToList();
    }
    
    private static bool ExamLikelyContainsQuestionType(ExamListItem exam, string questionType)
    {
        // Heuristic based on exam category and common patterns
        var category = exam.Category?.ToUpper() ?? "";
        var title = exam.Title?.ToUpper() ?? "";
        
        return questionType.ToUpper() switch
        {
            "TRUE_FALSE_NOT_GIVEN" => category.Contains("READING"),
            "YES_NO_NOT_GIVEN" => category.Contains("READING"),
            "MATCHING_HEADING" => category.Contains("READING"),
            "MATCHING_FEATURES" => category.Contains("READING") || category.Contains("LISTENING"),
            "SUMMARY_COMPLETION" => category.Contains("READING") || category.Contains("LISTENING"),
            "MCQ_SINGLE" => true, // Common in all
            "MCQ_MULTIPLE" => true,
            "SHORT_ANSWER" => category.Contains("READING") || category.Contains("LISTENING"),
            "TABLE_COMPLETION" => category.Contains("LISTENING"),
            "MAP_LABEL" => category.Contains("LISTENING"),
            "DIAGRAM_LABEL" => category.Contains("READING"),
            _ => false
        };
    }
    
    private static string FormatQuestionType(string type)
    {
        return type.Replace("_", " ").ToLower() switch
        {
            "true false not given" => "True/False/Not Given",
            "yes no not given" => "Yes/No/Not Given",
            "matching heading" => "Matching Headings",
            "matching features" => "Matching Features",
            "summary completion" => "Summary Completion",
            "mcq single" => "Multiple Choice",
            "mcq multiple" => "Multiple Selection",
            "short answer" => "Short Answer",
            "table completion" => "Table Completion",
            "map label" => "Map Labelling",
            "diagram label" => "Diagram Labelling",
            var x => x
        };
    }
    
    private record Weakness(WeaknessType Type, string Name, double Score);
    private enum WeaknessType { Skill, QuestionType }
    
    private record SectionInfo(string? Title, string? Skill);
    private record QuestionInfo(string? Content, string? Type);
    
    private record PaperInfo(
        Dictionary<Guid, SectionInfo> Sections,
        Dictionary<Guid, QuestionInfo> Questions
    );
    
    private static PaperInfo ExtractPaperInfo(System.Text.Json.JsonDocument? paperJson)
    {
        var sections = new Dictionary<Guid, SectionInfo>();
        var questions = new Dictionary<Guid, QuestionInfo>();
        
        if (paperJson == null) return new PaperInfo(sections, questions);
        
        try
        {
            if (paperJson.RootElement.TryGetProperty("sections", out var sectionsEl) && 
                sectionsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
            {
                foreach (var section in sectionsEl.EnumerateArray())
                {
                    if (section.TryGetProperty("id", out var idEl) && Guid.TryParse(idEl.GetString(), out var sectionId))
                    {
                        var title = section.TryGetProperty("title", out var t) ? t.GetString() : null;
                        var skill = section.TryGetProperty("skill", out var s) ? s.GetString() : null;
                        sections[sectionId] = new SectionInfo(title, skill);

                        // Extract from questionGroups
                        if (section.TryGetProperty("questionGroups", out var groupsEl) && 
                            groupsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                        {
                            foreach (var grp in groupsEl.EnumerateArray())
                            {
                                if (grp.TryGetProperty("questions", out var questionsEl) && 
                                    questionsEl.ValueKind == System.Text.Json.JsonValueKind.Array)
                                {
                                    foreach (var q in questionsEl.EnumerateArray())
                                    {
                                        if (q.TryGetProperty("id", out var qIdEl) && 
                                            Guid.TryParse(qIdEl.GetString(), out var qId))
                                        {
                                            var type = q.TryGetProperty("type", out var tp) ? tp.GetString() : null;
                                            var content = q.TryGetProperty("promptMd", out var c) ? c.GetString() : null;
                                            questions[qId] = new QuestionInfo(content, type);
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
        
        return new PaperInfo(sections, questions);
    }
}

// DTOs
public record RecommendationsDto(List<RecommendationDto> Recommendations);

public record RecommendationDto(
    Guid ExamId,
    string Title,
    string Category,
    List<string> Reasons,
    int RelevanceScore,
    int QuestionCount
);
