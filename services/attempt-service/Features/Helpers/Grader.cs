using System.Text.Json;
using System.Text.RegularExpressions;
using attempt_service.Domain.Entities;

namespace attempt_service.Features.Helpers;

public interface IQuestionGrader
{
    GradeResult Grade(AttemptAnswer answer, QuestionKey key);
}
// single choice grader
public sealed class SingleChoiceGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        var selection = answer.SelectedOptionIds ?? new List<int>();
        var correct = key.CorrectOptionIds ?? new HashSet<int>();
        bool ok = selection.Count == 1 && correct.Contains(selection[0]);
        return new GradeResult(ok ? key.QuestionPoints : 0, ok);
    }
}
public sealed class CompletionGrader : IQuestionGrader
{
    public GradeResult Grade(AttemptAnswer answer, QuestionKey key)
    {
        if (string.IsNullOrWhiteSpace(answer.TextAnswer))
            return new GradeResult(0, false);
        Dictionary<string, string>? map;
        try
        {
            map = JsonSerializer.Deserialize<Dictionary<string, string>>(answer.TextAnswer) ?? new();
        }
        catch
        {
            return new GradeResult(0, false, Feedback: "Malformed completion payload");
        }

        double get = 0, total = 0;
        foreach (var (blankId, accepted) in key.BlankAcceptTexts ?? new())
        {
            total += 1;
            map.TryGetValue(blankId, out var userVal);
            var norm = TextNorm.Normalize(userVal);
            bool matched = accepted is { Length: > 0 } 
                           && accepted.Any(x => TextNorm.Normalize(x) == norm);
            if (!matched && (key.BlankAcceptRegex?.TryGetValue(blankId, out var patterns) ?? false) &&
                patterns is { Length: > 0 })
            {
                if (patterns.Any(rx => Regex.IsMatch(userVal ?? "", rx, RegexOptions.IgnoreCase)))
                    matched = true; 
            }

            if (matched) get++; 
        }

        var score = (total > 0 ? get / total : 0) * key.QuestionPoints;
        return new GradeResult(score, score >= key.QuestionPoints - 1e-9);
    }
}