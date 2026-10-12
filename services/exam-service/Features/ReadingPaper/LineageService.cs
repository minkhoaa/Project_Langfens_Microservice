using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace exam_service.Features.ReadingPaper;

/// <summary>
/// Phase 14: records durable lineage for Exam, Section, Passage, Question, Option
/// entities produced during Reading Paper generation.
/// </summary>
public static class LineageService
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false
    };

    public static string ComputeSha256(string content)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(content));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    public static string ComputeObjectHash<T>(T obj)
    {
        var json = JsonSerializer.Serialize(obj, JsonOpts);
        return ComputeSha256(json);
    }

    public static async Task RecordExamLineageAsync(
        ExamDbContext db,
        ReadingPaperRun run,
        ReadingPaperJob job,
        Exam exam,
        IReadOnlyList<ReadingGeneratedSection> generatedSections,
        CancellationToken ct = default)
    {
        var existingKeys = await db.ReadingPaperEntityLineages
            .Where(l => l.RunId == run.RunId)
            .Select(l => new { l.EntityType, l.EntityId })
            .ToListAsync(ct);

        var existingSet = existingKeys.Select(k => $"{k.EntityType}:{k.EntityId}").ToHashSet(StringComparer.Ordinal);

        var artifacts = await db.ReadingPaperArtifacts.AsNoTracking()
            .Where(a => a.RunId == run.RunId)
            .ToListAsync(ct);

        var paperArtifact = artifacts.FirstOrDefault(a => a.ArtifactType.Equals("ReadingPaper", StringComparison.OrdinalIgnoreCase));
        var sectionArtifacts = artifacts.Where(a => a.ArtifactType.Equals("Section", StringComparison.OrdinalIgnoreCase)).ToList();
        var passageArtifacts = artifacts.Where(a => a.ArtifactType.Equals("Passage", StringComparison.OrdinalIgnoreCase)).ToList();
        var questionArtifacts = artifacts.Where(a => a.ArtifactType.Equals("Question", StringComparison.OrdinalIgnoreCase)).ToList();

        var lineageList = new List<ReadingPaperEntityLineage>();
        var now = DateTime.UtcNow;

        // 1. Exam Lineage
        var examPayload = new
        {
            title = exam.Title,
            descriptionMd = exam.DescriptionMd,
            durationMin = exam.DurationMin,
            category = exam.Category,
            level = exam.Level,
            status = exam.Status
        };
        var examHash = paperArtifact?.ContentHash ?? ComputeObjectHash(examPayload);
        var examArtifactId = paperArtifact?.ArtifactId ?? $"paper_{run.RunId}";
        var examVersion = paperArtifact?.Version ?? 1;

        if (!existingSet.Contains($"EXAM:{exam.Id}"))
        {
            lineageList.Add(new ReadingPaperEntityLineage
            {
                RunId = run.RunId,
                ExamId = exam.Id,
                EntityType = "EXAM",
                EntityId = exam.Id.ToString(),
                ArtifactId = examArtifactId,
                ArtifactType = "ReadingPaper",
                ArtifactVersion = examVersion,
                ContentHash = examHash,
                ParentRefsJson = "[]",
                CreatedAt = now
            });
        }

        // 2. Sections, Passages, Questions, Options
        var sectionList = exam.Sections.OrderBy(s => s.Idx).ToList();
        for (var i = 0; i < sectionList.Count; i++)
        {
            var sec = sectionList[i];
            var secIdx = sec.Idx;

            // Match artifacts by index or artifact id
            var secArtifact = sectionArtifacts.FirstOrDefault(a =>
                a.ArtifactId.Equals($"art_section_{secIdx}", StringComparison.OrdinalIgnoreCase) ||
                a.ArtifactId.Equals($"section_{secIdx}", StringComparison.OrdinalIgnoreCase) ||
                a.ArtifactId.Equals($"art_section_s{secIdx}", StringComparison.OrdinalIgnoreCase) ||
                System.Text.RegularExpressions.Regex.IsMatch(a.ArtifactId, $@"(?:^|[_\-s]){secIdx}$", System.Text.RegularExpressions.RegexOptions.IgnoreCase))
                ?? (i < sectionArtifacts.Count ? sectionArtifacts[i] : null);

            var pasArtifact = passageArtifacts.FirstOrDefault(a =>
                a.ArtifactId.Equals($"art_passage_s{secIdx}", StringComparison.OrdinalIgnoreCase) ||
                a.ArtifactId.Equals($"art_passage_{secIdx}", StringComparison.OrdinalIgnoreCase) ||
                a.ArtifactId.Equals($"passage_{secIdx}", StringComparison.OrdinalIgnoreCase) ||
                System.Text.RegularExpressions.Regex.IsMatch(a.ArtifactId, $@"(?:^|[_\-s]){secIdx}$", System.Text.RegularExpressions.RegexOptions.IgnoreCase))
                ?? (i < passageArtifacts.Count ? passageArtifacts[i] : null);

            var secPayload = new
            {
                idx = sec.Idx,
                title = sec.Title,
                instructionsMd = sec.InstructionsMd,
                passageMd = sec.PassageMd,
                sourcePmcid = sec.SourcePmcid,
                sourceTitle = sec.SourceTitle,
                sourceAuthors = sec.SourceAuthors,
                sourceDoi = sec.SourceDoi,
                sourceUrl = sec.SourceUrl,
                sourceLicense = sec.SourceLicense
            };
            var secHash = secArtifact?.ContentHash ?? ComputeObjectHash(secPayload);
            var secArtifactId = secArtifact?.ArtifactId ?? $"section_{secIdx}";
            var secVersion = secArtifact?.Version ?? 1;

            if (!existingSet.Contains($"SECTION:{sec.Id}"))
            {
                lineageList.Add(new ReadingPaperEntityLineage
                {
                    RunId = run.RunId,
                    ExamId = exam.Id,
                    SectionId = sec.Id,
                    EntityType = "SECTION",
                    EntityId = sec.Id.ToString(),
                    ArtifactId = secArtifactId,
                    ArtifactType = "Section",
                    ArtifactVersion = secVersion,
                    ContentHash = secHash,
                    ParentRefsJson = JsonSerializer.Serialize(new[] { $"exam:{exam.Id}" }, JsonOpts),
                    CreatedAt = now
                });
            }

            // 3. Passage Lineage
            var passagePayload = new
            {
                sectionId = sec.Id,
                passageMd = sec.PassageMd,
                sourcePmcid = sec.SourcePmcid,
                sourceUrl = sec.SourceUrl
            };
            var pasHash = pasArtifact?.ContentHash ?? ComputeObjectHash(passagePayload);
            var pasArtifactId = pasArtifact?.ArtifactId ?? $"passage_{secIdx}";
            var pasVersion = pasArtifact?.Version ?? 1;
            var pasEntityId = $"{sec.Id}:passage";

            if (!existingSet.Contains($"PASSAGE:{pasEntityId}"))
            {
                lineageList.Add(new ReadingPaperEntityLineage
                {
                    RunId = run.RunId,
                    ExamId = exam.Id,
                    SectionId = sec.Id,
                    EntityType = "PASSAGE",
                    EntityId = pasEntityId,
                    ArtifactId = pasArtifactId,
                    ArtifactType = "Passage",
                    ArtifactVersion = pasVersion,
                    ContentHash = pasHash,
                    ParentRefsJson = JsonSerializer.Serialize(new[] { $"section:{sec.Id}" }, JsonOpts),
                    CreatedAt = now
                });
            }

            // 4. Questions & Options
            var questions = (sec.Questions.Count > 0 ? sec.Questions : sec.QuestionGroups.SelectMany(g => g.Questions)).OrderBy(q => q.Idx).ToList();
            foreach (var q in questions)
            {
                var qArtifact = questionArtifacts.FirstOrDefault(a =>
                    a.ArtifactId.Equals($"art_q_{q.Idx}", StringComparison.OrdinalIgnoreCase) ||
                    a.ArtifactId.Equals($"question_{q.Idx}", StringComparison.OrdinalIgnoreCase) ||
                    a.ArtifactId.Equals($"q_{q.Idx}", StringComparison.OrdinalIgnoreCase) ||
                    System.Text.RegularExpressions.Regex.IsMatch(a.ArtifactId, $@"(?:^|[_\-q]){q.Idx}$", System.Text.RegularExpressions.RegexOptions.IgnoreCase));
                var qPayload = new
                {
                    idx = q.Idx,
                    type = q.Type,
                    skill = q.Skill,
                    difficulty = q.Difficulty,
                    promptMd = q.PromptMd,
                    explanationMd = q.ExplanationMd,
                    blankAcceptTexts = q.BlankAcceptTexts,
                    matchPairs = q.MatchPairs,
                    orderCorrects = q.OrderCorrects,
                    shortAnswerAcceptTexts = q.ShortAnswerAcceptTexts
                };
                var qHash = qArtifact?.ContentHash ?? ComputeObjectHash(qPayload);
                var qArtifactId = qArtifact?.ArtifactId ?? $"question_{q.Idx}";
                var qVersion = qArtifact?.Version ?? 1;

                if (!existingSet.Contains($"QUESTION:{q.Id}"))
                {
                    lineageList.Add(new ReadingPaperEntityLineage
                    {
                        RunId = run.RunId,
                        ExamId = exam.Id,
                        SectionId = sec.Id,
                        QuestionId = q.Id,
                        EntityType = "QUESTION",
                        EntityId = q.Id.ToString(),
                        ArtifactId = qArtifactId,
                        ArtifactType = "Question",
                        ArtifactVersion = qVersion,
                        ContentHash = qHash,
                        ParentRefsJson = JsonSerializer.Serialize(new[] { $"section:{sec.Id}", $"passage:{pasEntityId}" }, JsonOpts),
                        CreatedAt = now
                    });
                }

                // 5. Options
                var options = q.Options.OrderBy(o => o.Idx).ToList();
                foreach (var opt in options)
                {
                    var optPayload = new
                    {
                        idx = opt.Idx,
                        contentMd = opt.ContentMd,
                        isCorrect = opt.IsCorrect
                    };
                    var optHash = ComputeObjectHash(optPayload);
                    var optArtifactId = $"option_{q.Idx}_{opt.Idx}";

                    if (!existingSet.Contains($"OPTION:{opt.Id}"))
                    {
                        lineageList.Add(new ReadingPaperEntityLineage
                        {
                            RunId = run.RunId,
                            ExamId = exam.Id,
                            SectionId = sec.Id,
                            QuestionId = q.Id,
                            OptionId = opt.Id,
                            EntityType = "OPTION",
                            EntityId = opt.Id.ToString(),
                            ArtifactId = optArtifactId,
                            ArtifactType = "Option",
                            ArtifactVersion = 1,
                            ContentHash = optHash,
                            ParentRefsJson = JsonSerializer.Serialize(new[] { $"question:{q.Id}" }, JsonOpts),
                            CreatedAt = now
                        });
                    }
                }
            }
        }

        if (lineageList.Count > 0)
        {
            db.ReadingPaperEntityLineages.AddRange(lineageList);
        }
    }
}
