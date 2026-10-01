using System.Text.Json;
using System.Text.RegularExpressions;

namespace exam_service.Features.ReadingPaper;

public sealed record ReadingSource(string Pmcid, string Title, string? Doi, string Url,
    string License, int WordCount, string? Authors = null, string? OpenAlexId = null, string? TopicId = null,
    string? SourceType = null, Dictionary<string, string>? Metadata = null,
    string? Content = null, string? ContentPreview = null);
public sealed record ReadingPaperLog(DateTime Timestamp, string Level, string Message);
public sealed record ReadingSearchResult(List<ReadingSource> Sources, List<string> SelectedPmcids, string? Message);
public sealed record ReadingJobRequest(string Topic, List<string>? Pmcids = null, List<ReadingSource>? Sources = null, string? Provider = null);
public sealed record IngestSourceRequest(string Payload, string Type = "auto", string? Title = null, string? Url = null, string? Authors = null, string? License = null);
public sealed record ReadingGeneratedQuestion(int Number, string Prompt, string Answer,
    List<string> Options, string EvidenceQuote, string Explanation);
public sealed record ReadingGeneratedGroup(string Type, string Instruction, List<ReadingGeneratedQuestion> Questions);
public sealed record ReadingGeneratedSection(string Title, string Passage, ReadingSource Source,
    List<ReadingGeneratedGroup> Groups);

public static class ReadingPaperRules
{
    public static readonly int[][] Counts = [[7, 6], [6, 7], [7, 7]];
    public static readonly string[][] Types = [
        ["TRUE_FALSE_NOT_GIVEN", "SENTENCE_COMPLETION"],
        ["MULTIPLE_CHOICE_SINGLE", "SUMMARY_COMPLETION"],
        ["YES_NO_NOT_GIVEN", "SHORT_ANSWER"]];
    private static readonly Regex Words = new(@"\b[\w'-]+\b", RegexOptions.Compiled);
    public static int WordCount(string text) => Words.Matches(text).Count;

    public static void Validate(IReadOnlyList<ReadingGeneratedSection> sections)
    {
        if (sections.Count is < 1 or > 3) throw new InvalidOperationException("Expected one to three passages");
        var seenSources = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var seenDois = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var seenPrompts = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var passageShingles = new List<HashSet<string>>();
        var next = 1;
        var totalWords = 0;
        for (var i = 0; i < sections.Count; i++)
        {
            var section = sections[i];
            if (!seenSources.Add(section.Source.Pmcid) || string.IsNullOrWhiteSpace(section.Title))
                throw new InvalidOperationException("Duplicate source or missing title");
            if (!string.IsNullOrWhiteSpace(section.Source.Doi) && !seenDois.Add(section.Source.Doi))
                throw new InvalidOperationException("Duplicate source DOI");
            var count = Words.Matches(section.Passage).Count;
            if (count < 720 || count > 915) throw new InvalidOperationException("Passage length must be 720–915 words");
            var shingles = Shingles(section.Passage);
            if (passageShingles.Any(previous => previous.Intersect(shingles).Count() > 0.45 * previous.Union(shingles).Count()))
                throw new InvalidOperationException("Passages contain duplicated text");
            passageShingles.Add(shingles);
            totalWords += count;
            if (section.Groups.Count != 2) throw new InvalidOperationException("Expected two groups per passage");
            for (var g = 0; g < 2; g++)
            {
                var group = section.Groups[g];
                if (group.Type != Types[i][g] || group.Questions.Count != Counts[i][g]
                    || string.IsNullOrWhiteSpace(group.Instruction))
                    throw new InvalidOperationException("Invalid group type, count or instruction");
                foreach (var q in group.Questions)
                {
                    if (q.Number != next) throw new InvalidOperationException("Question numbers must be continuous");
                    if (string.IsNullOrWhiteSpace(q.Prompt) || string.IsNullOrWhiteSpace(q.Answer)
                        || q.Explanation.Length < 25 || q.EvidenceQuote.Length < 15)
                        throw new InvalidOperationException($"Question {next} lacks an answer, explanation or evidence");
                    var passageText = string.Join(' ', section.Passage.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
                    var evidenceText = string.Join(' ', q.EvidenceQuote.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
                    if (!passageText.Contains(evidenceText, StringComparison.OrdinalIgnoreCase))
                        throw new InvalidOperationException($"Question {next} evidence is absent from passage");
                    if (!seenPrompts.Add(Regex.Replace(q.Prompt, @"\W+", "").ToLowerInvariant()))
                        throw new InvalidOperationException("Duplicate question prompt");
                    if (group.Type is "TRUE_FALSE_NOT_GIVEN" or "YES_NO_NOT_GIVEN" or "MULTIPLE_CHOICE_SINGLE")
                    {
                        var expected = group.Type == "MULTIPLE_CHOICE_SINGLE" ? 4 : 3;
                        if (q.Options.Count != expected || q.Options.Distinct(StringComparer.OrdinalIgnoreCase).Count() != expected
                            || q.Options.Count(o => o == q.Answer) != 1)
                            throw new InvalidOperationException($"Question {next} has invalid options or answer");
                        var fixedOptions = group.Type == "TRUE_FALSE_NOT_GIVEN" ? new[] { "TRUE", "FALSE", "NOT GIVEN" }
                            : group.Type == "YES_NO_NOT_GIVEN" ? ["YES", "NO", "NOT GIVEN"] : null;
                        if (fixedOptions is not null && !q.Options.SequenceEqual(fixedOptions))
                            throw new InvalidOperationException($"Question {next} has invalid judgement options");
                        if (group.Type == "MULTIPLE_CHOICE_SINGLE"
                            && !q.Options.Select((option, idx) => option.StartsWith($"{(char)('A' + idx)}.", StringComparison.Ordinal))
                                .All(valid => valid))
                            throw new InvalidOperationException($"Question {next} needs A–D options");
                    }
                    else if ((group.Type is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION"
                              && !q.Prompt.Contains($"[{next}]", StringComparison.Ordinal))
                             || Words.Matches(q.Answer).Count is < 1 or > 3
                             || !Regex.IsMatch(section.Passage, $@"(?<!\w){Regex.Escape(q.Answer)}(?!\w)", RegexOptions.IgnoreCase))
                        throw new InvalidOperationException($"Question {next} has an invalid completion answer");
                    next++;
                }
            }
        }
        var expectedQuestions = Counts.Take(sections.Count).Sum(counts => counts.Sum());
        if (next != expectedQuestions + 1)
            throw new InvalidOperationException($"Paper must have {expectedQuestions} scored items");
        if (sections.Count == 3 && (totalWords is < 2150 or > 2750))
            throw new InvalidOperationException("A three-passage paper must have 2150–2750 passage words");
    }

    public static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    private static HashSet<string> Shingles(string passage)
    {
        var words = Words.Matches(passage.ToLowerInvariant()).Select(m => m.Value).ToArray();
        return Enumerable.Range(0, Math.Max(0, words.Length - 4))
            .Select(i => string.Join(' ', words.Skip(i).Take(5)))
            .ToHashSet(StringComparer.Ordinal);
    }
}
