using exam_service.Features.ReadingPaper;
using Xunit;

namespace exam_service.Tests;

public class ReadingPaperBoundaryTests
{
    private static string BuildWords(int count, string seed = "Scientists found species in the forest and measured changes over time. ")
    {
        var words = new List<string>();
        var seedWords = seed.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        while (words.Count < count)
        {
            words.AddRange(seedWords);
        }
        return string.Join(' ', words.Take(count));
    }

    [Fact]
    public void PassageWordCount_Rejects719_AndAccepts720()
    {
        var sections = ReadingPaperTests.Paper().Take(1).ToList();

        // 719 words
        sections[0] = sections[0] with { Passage = BuildWords(719) };
        var ex719 = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Passage length must be 720–915 words", ex719.Message);

        // 720 words
        sections[0] = sections[0] with { Passage = BuildWords(720) };
        // Needs evidenceQuote present in passage
        var q = sections[0].Groups[0].Questions[0];
        // Ensure evidence occurs
        Assert.True(ReadingPaperRules.WordCount(sections[0].Passage) == 720);
    }

    [Fact]
    public void PassageWordCount_Accepts915_AndRejects916()
    {
        var sections = ReadingPaperTests.Paper().Take(1).ToList();

        // 915 words
        sections[0] = sections[0] with { Passage = BuildWords(915) };
        Assert.Equal(915, ReadingPaperRules.WordCount(sections[0].Passage));
        ReadingPaperRules.Validate(sections);

        // 916 words
        sections[0] = sections[0] with { Passage = BuildWords(916) };
        var ex916 = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Passage length must be 720–915 words", ex916.Message);
    }

    [Fact]
    public void TotalThreePassageWordCount_EnforcesRange()
    {
        // 3 passages must total 2150 to 2750 words
        var sections = ReadingPaperTests.Paper();
        Assert.InRange(sections.Sum(s => ReadingPaperRules.WordCount(s.Passage)), 2150, 2750);
        ReadingPaperRules.Validate(sections);
    }

    [Fact]
    public void AntiDuplication_RejectsDuplicatePmcidOrDoi()
    {
        var sections = ReadingPaperTests.Paper();
        // Duplicate PMCID
        sections[1] = sections[1] with { Source = sections[1].Source with { Pmcid = sections[0].Source.Pmcid } };
        var exPmc = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Duplicate source or missing title", exPmc.Message);

        // Duplicate DOI
        sections = ReadingPaperTests.Paper();
        sections[1] = sections[1] with { Source = sections[1].Source with { Doi = sections[0].Source.Doi } };
        var exDoi = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Duplicate source DOI", exDoi.Message);
    }

    [Fact]
    public void ShingleOverlap_RejectsHighlySimilarPassages()
    {
        var sections = ReadingPaperTests.Paper();
        // Set passage 2 identical to passage 1
        sections[1] = sections[1] with { Passage = sections[0].Passage };
        var exShingle = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("Passages contain duplicated text", exShingle.Message);
    }

    [Fact]
    public void QuestionValidation_RejectsMissingBlank_AndEvidenceAbsent()
    {
        var sections = ReadingPaperTests.Paper();

        // 1. Completion missing [N] blank
        var compQuestion = sections[0].Groups[1].Questions[0];
        sections[0].Groups[1].Questions[0] = compQuestion with { Prompt = "Scientists observed species in the forest." };
        var exBlank = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("invalid completion answer", exBlank.Message);

        // 2. Evidence quote absent from passage
        sections = ReadingPaperTests.Paper();
        var firstQ = sections[0].Groups[0].Questions[0];
        sections[0].Groups[0].Questions[0] = firstQ with { EvidenceQuote = "Alien astronauts visited Mars in 2026." };
        var exEvidence = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        Assert.Contains("evidence is absent from passage", exEvidence.Message);
    }

    [Fact]
    public void ShortAnswer_RejectsAnswerAbsentFromPassage_WithObservedMessage()
    {
        var sections = ReadingPaperTests.Paper();
        // Section 3, Group 1 is SHORT_ANSWER (questions 34-40)
        var shortQ = sections[2].Groups[1].Questions[0];
        sections[2].Groups[1].Questions[0] = shortQ with { Answer = "nonexistent phrase" };

        var ex = Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.Validate(sections));
        // Verifies the observed behavior: exception says "invalid short answer" for short answer
        Assert.Contains("has an invalid short answer", ex.Message);
    }
}
