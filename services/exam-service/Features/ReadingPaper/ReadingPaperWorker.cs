using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
namespace exam_service.Features.ReadingPaper;

public sealed class ReadingPaperWorker(IServiceScopeFactory scopes, ILogger<ReadingPaperWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var found = await RunOne(stoppingToken);
                if (!found) await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested) { break; }
            catch (Exception ex)
            {
                logger.LogError(ex, "Reading paper worker loop failed");
                await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
            }
        }
    }

    private async Task<bool> RunOne(CancellationToken ct)
    {
        using var scope = scopes.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var now = DateTime.UtcNow;
        var id = await db.ReadingPaperJobs.AsNoTracking()
            .Where(x => x.Status == "Pending" || (x.Status == "Running" && x.LeaseUntil < now))
            .OrderBy(x => x.CreatedAt).Select(x => x.Id).FirstOrDefaultAsync(ct);
        if (id == Guid.Empty) return false;
        var owner = Guid.NewGuid();
        var claimed = await db.ReadingPaperJobs
            .Where(x => x.Id == id && (x.Status == "Pending" || (x.Status == "Running" && x.LeaseUntil < now)))
            .ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, "Running")
                .SetProperty(j => j.LeaseOwner, owner)
                .SetProperty(j => j.Epoch, j => j.Epoch + 1)
                .SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddMinutes(3))
                .SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
        if (claimed == 0) return true;
        var job = await db.ReadingPaperJobs.FirstAsync(x => x.Id == id, ct);

        // Ensure ReadingPaperRun is stable across epochs for this job
        var runId = string.IsNullOrWhiteSpace(job.ActiveRunId) ? $"run_{job.Id:N}" : job.ActiveRunId;
        job.ActiveRunId = runId;
        var run = await db.ReadingPaperRuns.FirstOrDefaultAsync(r => r.JobId == job.Id, ct);
        if (run == null)
        {
            run = new ReadingPaperRun
            {
                Id = Guid.NewGuid(),
                JobId = job.Id,
                RunId = runId,
                Epoch = job.Epoch,
                Status = "RUNNING",
                LeaseOwner = owner,
                LeaseUntil = job.LeaseUntil,
                CancelVersion = job.CancelVersion,
                EngineVersion = job.EngineVersion,
                SchemaVersion = job.SchemaVersion,
                PolicyVersion = job.PolicyVersion,
                SourceRevisionsJson = job.SourcesJson,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            db.ReadingPaperRuns.Add(run);
        }
        else
        {
            run.Epoch = job.Epoch;
            run.LeaseOwner = owner;
            run.LeaseUntil = job.LeaseUntil;
            run.Status = "RUNNING";
            run.UpdatedAt = DateTime.UtcNow;
        }
        await db.SaveChangesAsync(ct);

        await AppendLogAsync(id, "Information",
            $"Worker claimed job for topic '{job.Topic}' with {JsonSerializer.Deserialize<List<ReadingSource>>(job.SourcesJson, ReadingPaperRules.Json)?.Count ?? 0} source(s) [Epoch {job.Epoch}].", ct);
        using var heartbeatCancel = CancellationTokenSource.CreateLinkedTokenSource(ct);
        var heartbeat = Heartbeat(id, owner, job.Epoch, heartbeatCancel.Token);
        try
        {
            var ai = scope.ServiceProvider.GetRequiredService<ReadingPaperAiClient>();
            await Process(db, ai, job, owner, ct);
        }
        catch (OperationCanceledException) when (ct.IsCancellationRequested) { throw; }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Reading paper job {JobId} stopped", id);
            await AppendLogAsync(id, "Error", $"Generation failed: {ex}", ct);
            var status = ex is ReadingSourceUnavailableException ? "NeedsSources" : "Failed";
            await db.ReadingPaperJobs.Where(x => x.Id == id && x.LeaseOwner == owner && x.Epoch == job.Epoch)
                .ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, status)
                    .SetProperty(j => j.Error, ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message)
                    .SetProperty(j => j.LeaseUntil, (DateTime?)null)
                    .SetProperty(j => j.LeaseOwner, (Guid?)null)
                    .SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
        }
        finally
        {
            heartbeatCancel.Cancel();
            try { await heartbeat; }
            catch (OperationCanceledException) { }
            catch (Exception ex) { logger.LogWarning(ex, "Reading paper lease heartbeat stopped for {JobId}", id); }
        }
        return true;
    }

    private async Task Heartbeat(Guid id, Guid owner, int epoch, CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromSeconds(30), ct);
            using var scope = scopes.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            var count = await db.ReadingPaperJobs.Where(x => x.Id == id && x.LeaseOwner == owner && x.Epoch == epoch && x.Status == "Running")
                .ExecuteUpdateAsync(x => x.SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddMinutes(3)), ct);
            if (count == 0) break;

            await db.ReadingPaperRuns.Where(r => r.JobId == id && r.Epoch == epoch && r.LeaseOwner == owner)
                .ExecuteUpdateAsync(x => x.SetProperty(r => r.LeaseUntil, DateTime.UtcNow.AddMinutes(3)), ct);
        }
    }

    private async Task Process(ExamDbContext db, ReadingPaperAiClient ai, ReadingPaperJob job,
        Guid owner, CancellationToken ct)
    {
        var sources = JsonSerializer.Deserialize<List<ReadingSource>>(job.SourcesJson, ReadingPaperRules.Json) ?? [];
        var sections = JsonSerializer.Deserialize<List<ReadingGeneratedSection>>(job.SectionsJson, ReadingPaperRules.Json) ?? [];
        if (sources.Count is < 1 or > 3
            || sources.Select(x => x.Pmcid).Distinct(StringComparer.OrdinalIgnoreCase).Count() != sources.Count)
            throw new ReadingSourceUnavailableException("Select one to three distinct verified sources");
        if (sections.Count != job.CompletedSections)
            throw new InvalidOperationException("Job checkpoint is inconsistent");
        await AppendLogAsync(job.Id, "Information",
            $"Generation started for {sources.Count} selected source(s); {sections.Count} section checkpoint(s) already complete.", ct);
        var runId = job.ActiveRunId ?? $"run_{job.Id:N}";
        for (var i = sections.Count; i < sources.Count; i++)
        {
            var sourceNum = i + 1;
            var source = sources[i];
            var sourceHash = ReadingPaperEndpoints.ComputeSourceHash(source);

            // 1. Deterministic request hash & grant acquisition before provider call
            var rawReq = $"{runId}:{sourceNum}:{source.Pmcid}:{sourceHash}";
            var reqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(rawReq)));
            var opId = $"op_{runId}_sec_{sourceNum}_{sourceHash[..12]}";

            await AppendLogAsync(job.Id, "Information",
                $"Acquiring durable operation grant for passage {sourceNum}/{sources.Count} ({source.Pmcid}: {source.Title})...", ct);

            var secId = $"section_{sourceNum}";
            var grant = await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(
                runId, job.Epoch, owner, opId, "GENERATE_SECTION", reqHash,
                TokenReservation: 15000,
                CostReservationUsd: 0m,
                WallTimeReservationSeconds: 240.0,
                SectionId: secId,
                ArtifactId: null
            ), ct);

            await AppendLogAsync(job.Id, "Information",
                $"Durable operation grant acquired: {grant.OperationId} (Reservation: {grant.TokenReservation} tokens, Replay: {grant.IsReplay}).", ct);

            // 2. Invoke provider I/O with fault recording
            ReadingGeneratedSection section;
            try
            {
                var provider = source.Metadata?.GetValueOrDefault("provider");
                section = await ai.GenerateSectionAsync(job.Topic, sourceNum, source,
                    (level, message) => AppendLogAsync(job.Id, level, $"AI service: {message}", ct), ct, provider,
                    runId, job.Epoch, owner, opId);
            }
            catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or TimeoutException)
            {
                await CheckpointService.RecordUnknownOutcomeAsync(db, new UnknownOutcomeRequest(
                    runId, job.Epoch, owner, opId, ex.Message
                ), ct);
                throw;
            }

            // 3. Verify source identity and license
            if (!section.Source.Pmcid.Equals(source.Pmcid, StringComparison.OrdinalIgnoreCase)
                || section.Source.License != source.License
                || (source.Doi is not null && section.Source.Doi != source.Doi))
            {
                throw new ReadingSourceUnavailableException("Source identity or license changed");
            }

            // 3b. V2 QuestionCandidateLoop Integration: If V2 is active and questions are decoupled
            var activeRun = await db.ReadingPaperRuns.FirstOrDefaultAsync(r => r.RunId == runId, ct);
            var isV2Engine = (activeRun != null && string.Equals(activeRun.EngineVersion, "2.0.0", StringComparison.OrdinalIgnoreCase))
                || string.Equals(source.Metadata?.GetValueOrDefault("engine"), "v2", StringComparison.OrdinalIgnoreCase)
                || string.Equals(Environment.GetEnvironmentVariable("READING_PAPER_ENGINE"), "v2", StringComparison.OrdinalIgnoreCase);

            var requiredSectionQuestions = sourceNum switch { 1 => 13, 2 => 13, 3 => 14, _ => 13 };
            var currentQuestionsCount = section.Groups?.Sum(g => g.Questions.Count) ?? 0;

            if (isV2Engine && currentQuestionsCount < requiredSectionQuestions)
            {
                await AppendLogAsync(job.Id, "Information",
                    $"Executing V2 QuestionCandidateLoop via AI service for section {sourceNum} (current: {currentQuestionsCount}/{requiredSectionQuestions} questions)...", ct);

                var passageHead = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == $"art_passage_s{sourceNum}" || h.ArtifactId == $"art_passage_{sourceNum}"), ct);
                var bpPrefix = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
                var blueprintHead = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefix || h.ArtifactId.StartsWith("art_blueprint_")), ct);
                var passageRef = passageHead != null
                    ? new ArtifactRef(passageHead.ArtifactId, ArtifactType.Passage, passageHead.AcceptedVersion, passageHead.AcceptedHash)
                    : new ArtifactRef($"art_passage_s{sourceNum}", ArtifactType.Passage, 1, "0000000000000000000000000000000000000000000000000000000000000000");
                var blueprintRef = blueprintHead != null
                    ? new ArtifactRef(blueprintHead.ArtifactId, ArtifactType.ExamBlueprint, blueprintHead.AcceptedVersion, blueprintHead.AcceptedHash)
                    : new ArtifactRef($"art_blueprint_{runId[..8]}", ArtifactType.ExamBlueprint, 1, "0000000000000000000000000000000000000000000000000000000000000000");

                // Determine missing question slot indices
                var existingNums = section.Groups?.SelectMany(g => g.Questions).Select(q => q.Number).ToHashSet() ?? new HashSet<int>();
                var baseStart = sourceNum switch { 1 => 1, 2 => 14, 3 => 27, _ => 1 };
                var missingSlots = new List<object>();
                for (var qNum = baseStart; qNum < baseStart + requiredSectionQuestions; qNum++)
                {
                    if (!existingNums.Contains(qNum))
                    {
                        var slotType = (sourceNum, qNum - baseStart) switch
                        {
                            (1, < 7) => "TrueFalseNotGiven",
                            (1, _) => "SentenceCompletion",
                            (2, < 6) => "MultipleChoiceSingle",
                            (2, _) => "SummaryCompletion",
                            (3, < 7) => "YesNoNotGiven",
                            (3, _) => "ShortAnswer",
                            _ => "SentenceCompletion"
                        };
                        missingSlots.Add(new { number = qNum, type = slotType });
                    }
                }

                var qResult = await ai.GenerateQuestionsAsync(
                    passageRef, blueprintRef, missingSlots.Count > 0 ? missingSlots : null, runId, owner, job.Epoch, sourceNum, ct);

                if (qResult.Questions != null && qResult.Questions.Count > 0)
                {
                    var extractedQuestions = new List<(int Number, string CanonicalType, ReadingGeneratedQuestion Question)>();
                    foreach (var kv in qResult.Questions)
                    {
                        if (kv.Value is JsonElement qEl)
                        {
                            if (qEl.TryGetProperty("payload", out var pNode) && pNode.TryGetProperty("questions", out var qArray) && qArray.ValueKind == JsonValueKind.Array)
                            {
                                foreach (var item in qArray.EnumerateArray())
                                {
                                    var num = item.TryGetProperty("questionNumber", out var nP) ? nP.GetInt32() : 1;
                                    var rawType = item.TryGetProperty("questionType", out var tP) ? tP.GetString() ?? "TrueFalseNotGiven" : "TrueFalseNotGiven";
                                    var cType = GetCanonicalGroupType(rawType);
                                    var prompt = item.TryGetProperty("prompt", out var pP) ? pP.GetString() ?? "" : "";
                                    var answer = item.TryGetProperty("answer", out var aP) ? aP.GetString() ?? "" : "";
                                    var quote = item.TryGetProperty("evidenceQuote", out var eqP) ? eqP.GetString() ?? "" : "";
                                    var expl = item.TryGetProperty("explanation", out var expP) ? expP.GetString() ?? "" : "";
                                    var opts = new List<string>();
                                    if (item.TryGetProperty("options", out var optNode) && optNode.ValueKind == JsonValueKind.Array)
                                    {
                                        foreach (var o in optNode.EnumerateArray())
                                        {
                                            if (o.ValueKind == JsonValueKind.String) opts.Add(o.GetString() ?? "");
                                            else if (o.TryGetProperty("text", out var tText)) opts.Add(tText.GetString() ?? "");
                                            else opts.Add(o.ToString());
                                        }
                                    }
                                    extractedQuestions.Add((num, cType, new ReadingGeneratedQuestion(num, prompt, answer, opts, quote, expl)));
                                }
                            }
                            else
                            {
                                var num = int.TryParse(kv.Key, out var parsedNum) ? parsedNum : 1;
                                var rawType = qEl.TryGetProperty("questionType", out var tProp) ? tProp.GetString() ?? "TrueFalseNotGiven" : "TrueFalseNotGiven";
                                var cType = GetCanonicalGroupType(rawType);
                                var prompt = qEl.TryGetProperty("prompt", out var pProp) ? pProp.GetString() ?? "" : "";
                                var answer = qEl.TryGetProperty("answer", out var aProp) ? aProp.GetString() ?? "" : "";
                                var quote = qEl.TryGetProperty("evidenceQuote", out var eqP) ? eqP.GetString() ?? "" : "";
                                var expl = qEl.TryGetProperty("explanation", out var expP) ? expP.GetString() ?? "" : "";
                                var opts = new List<string>();
                                if (qEl.TryGetProperty("options", out var optNode) && optNode.ValueKind == JsonValueKind.Array)
                                {
                                    foreach (var o in optNode.EnumerateArray())
                                    {
                                        if (o.ValueKind == JsonValueKind.String) opts.Add(o.GetString() ?? "");
                                        else if (o.TryGetProperty("text", out var tText)) opts.Add(tText.GetString() ?? "");
                                        else opts.Add(o.ToString());
                                    }
                                }
                                extractedQuestions.Add((num, cType, new ReadingGeneratedQuestion(num, prompt, answer, opts, quote, expl)));
                            }
                        }
                    }
                    // Deduplicate newly extracted questions by Number
                    var distinctQuestions = extractedQuestions
                        .GroupBy(x => x.Number)
                        .Select(g => g.First())
                        .ToList();

                    // Merge with any pre-existing questions
                    if (section.Groups != null && section.Groups.Count > 0)
                    {
                        foreach (var existingGrp in section.Groups)
                        {
                            foreach (var eq in existingGrp.Questions)
                            {
                                if (!distinctQuestions.Any(x => x.Number == eq.Number))
                                {
                                    distinctQuestions.Add((eq.Number, GetCanonicalGroupType(existingGrp.Type), eq));
                                }
                            }
                        }
                    }

                    distinctQuestions = distinctQuestions.OrderBy(x => x.Number).ToList();

                    if (distinctQuestions.Count > 0)
                    {
                        var newGroups = new List<ReadingGeneratedGroup>();
                        var currentType = "";
                        var currentGroupQuestions = new List<ReadingGeneratedQuestion>();

                        foreach (var item in distinctQuestions)
                        {
                            if (!string.Equals(currentType, item.CanonicalType, StringComparison.OrdinalIgnoreCase) && currentGroupQuestions.Count > 0)
                            {
                                newGroups.Add(new ReadingGeneratedGroup(currentType, GetGroupInstruction(currentType), currentGroupQuestions));
                                currentGroupQuestions = new List<ReadingGeneratedQuestion>();
                            }
                            currentType = item.CanonicalType;
                            currentGroupQuestions.Add(item.Question);
                        }
                        if (currentGroupQuestions.Count > 0)
                        {
                            newGroups.Add(new ReadingGeneratedGroup(currentType, GetGroupInstruction(currentType), currentGroupQuestions));
                        }
                        section = section with { Groups = newGroups };
                    }
                }
            }

            if (isV2Engine && (section.Groups == null || section.Groups.Sum(g => g.Questions.Count) < requiredSectionQuestions))
            {
                throw new InvalidOperationException(
                    $"Section {sourceNum} question generation incomplete: expected {requiredSectionQuestions} questions, got {section.Groups?.Sum(g => g.Questions.Count) ?? 0}");
            }

            await AppendLogAsync(job.Id, "Information",
                $"Passage {sourceNum} generated and verified ({ReadingPaperRules.WordCount(section.Passage)} words, {section.Groups.Sum(g => g.Questions.Count)} questions). Committing durable checkpoint...", ct);

            // 4. Construct ArtifactEnvelope & commit checkpoint atomically
            var payloadJson = JsonSerializer.Serialize(section, ReadingPaperRules.Json);
            using var doc = JsonDocument.Parse(payloadJson);
            var artifactId = $"art_section_{sourceNum}";
            var contentHash = ArtifactEnvelope.ComputeContentHash(doc.RootElement, new List<ArtifactRef>());

            var sectionEnvelope = new ArtifactEnvelope(
                artifactId,
                ArtifactType.Section,
                1,
                runId,
                sourceNum,
                "2.0.0",
                contentHash,
                DateTime.UtcNow,
                "2.0.0",
                doc.RootElement.Clone(),
                new List<ArtifactRef>()
            );

            // 4a. Aggregate actual tokens and wall time spent across all child operations for this section
            var actualSectionTokens = await db.ReadingPaperOperations
                .Where(o => o.RunId == runId && (o.OperationId == opId || o.ParentOperationId == opId))
                .SumAsync(o => o.TokensUsed, ct);

            var actualSectionWallTime = await db.ReadingPaperOperations
                .Where(o => o.RunId == runId && (o.OperationId == opId || o.ParentOperationId == opId))
                .SumAsync(o => o.WallTimeUsedSeconds, ct);
            // Retain full reservation if child operations were not separately reconciled (e.g. unknown outcome / test mock);
            // never substitute an arbitrary fabricated constant like 2200.
            var tokensToCommit = actualSectionTokens > 0 ? actualSectionTokens : grant.TokenReservation;
            var wallTimeToCommit = actualSectionWallTime > 0 ? actualSectionWallTime : grant.WallTimeReservationSeconds;

            var ack = await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(
                runId, job.Epoch, owner, opId, reqHash, sectionEnvelope,
                TokensUsed: tokensToCommit,
                WallTimeUsedSeconds: wallTimeToCommit
            ), ct);

            // Advance local in-memory progress ONLY after durable ACK is received
            sections.Add(section);
            var completed = sections.Count;
            await AppendLogAsync(job.Id, "Information",
                $"Passage {sourceNum} durable checkpoint acknowledged ({ack.ArtifactId} v{ack.Version}, Hash: {ack.ContentHash[..8]}...). Progress: {completed}/{sources.Count}.", ct);
        }

        await AppendLogAsync(job.Id, "Information", $"[Exam Finalization] Validating all {sections.Count} section(s) against IELTS Academic Paper Rules...", ct);
        ReadingPaperRules.Validate(sections);
        await AppendLogAsync(job.Id, "Information", $"[Exam Validation Passed] All {sections.Sum(s => s.Groups.Sum(g => g.Questions.Count))} questions and {sections.Sum(s => ReadingPaperRules.WordCount(s.Passage))} words meet IELTS standards. Saving Exam in database via idempotent finalizer...", ct);

        var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            runId, job.Epoch, owner, job.Id
        ), ct);

        await AppendLogAsync(job.Id, "Information",
            $"[Exam Created Successfully] Exam ID: {buildResult.ExamId} | Slug: '{buildResult.Slug}' (Existing: {buildResult.IsExisting}).", ct);
    }

    private async Task AppendLogAsync(Guid id, string level, string message, CancellationToken ct)
    {
        var line = JsonSerializer.Serialize(new ReadingPaperLog(DateTime.UtcNow, level, message), ReadingPaperRules.Json);
        try
        {
            using var scope = scopes.CreateScope();
            var logDb = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
            await logDb.ReadingPaperJobs.Where(x => x.Id == id)
                .ExecuteUpdateAsync(update => update
                    .SetProperty(x => x.Logs, x => x.Logs + line + "\n")
                    .SetProperty(x => x.UpdatedAt, DateTime.UtcNow), ct);
        }
        catch (OperationCanceledException) when (ct.IsCancellationRequested) { throw; }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Could not append generation log for job {JobId}", id);
        }
    }

    private static string SerializeLog(string level, string message)
        => JsonSerializer.Serialize(new ReadingPaperLog(DateTime.UtcNow, level, message), ReadingPaperRules.Json) + "\n";

    private static async Task ConfirmLease(ExamDbContext db, Guid id, Guid owner, int epoch, CancellationToken ct)
    {
        var updated = await db.ReadingPaperJobs.Where(x => x.Id == id && x.LeaseOwner == owner && x.Epoch == epoch && x.Status == "Running")
            .ExecuteUpdateAsync(x => x.SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddMinutes(3)), ct);
        if (updated != 1) throw new InvalidOperationException("Job lease was lost");
    }

    private static string GetCanonicalGroupType(string rawType)
    {
        var norm = rawType.Replace("_", "").Replace(" ", "").ToUpperInvariant();
        return norm switch
        {
            "TRUEFALSENOTGIVEN" or "TFNG" => "TRUE_FALSE_NOT_GIVEN",
            "YESNONOTGIVEN" or "YNNG" => "YES_NO_NOT_GIVEN",
            "MULTIPLECHOICESINGLE" or "MCQ" or "MULTIPLECHOICE" => "MULTIPLE_CHOICE_SINGLE",
            "SENTENCECOMPLETION" => "SENTENCE_COMPLETION",
            "SUMMARYCOMPLETION" => "SUMMARY_COMPLETION",
            "SHORTANSWER" => "SHORT_ANSWER",
            _ => rawType.ToUpperInvariant()
        };
    }

    private static string GetGroupInstruction(string groupType) => groupType switch
    {
        "TRUE_FALSE_NOT_GIVEN" => "Do the following statements agree with the information given in the reading passage?",
        "YES_NO_NOT_GIVEN" => "Do the following statements agree with the views/claims of the writer in the reading passage?",
        "MULTIPLE_CHOICE_SINGLE" => "Choose the correct letter, A, B, C or D.",
        "SENTENCE_COMPLETION" => "Complete the sentences below. Choose NO MORE THAN THREE WORDS from the passage for each answer.",
        "SUMMARY_COMPLETION" => "Complete the summary below. Choose NO MORE THAN TWO WORDS from the passage for each answer.",
        "SHORT_ANSWER" => "Answer the questions below. Choose NO MORE THAN THREE WORDS from the passage for each answer.",
        _ => "Answer the questions below according to the reading passage."
    };

    public static Exam BuildExam(ReadingPaperJob job, IReadOnlyList<ReadingGeneratedSection> sections)
    {
        ReadingPaperRules.Validate(sections);
        var exam = new Exam
        {
            Id = Guid.NewGuid(), Slug = $"reading-{job.Id:N}",
            Title = sections.Count == 3
                ? $"IELTS Academic Reading: {job.Topic}"
                : $"IELTS Academic Reading Practice ({sections.Count} passage{(sections.Count == 1 ? "" : "s")}): {job.Topic}",
            DescriptionMd = "AI-assisted draft generated from open scientific articles. Review passages, answers and source attribution before publishing.",
            Category = "IELTS", Level = "B2", Status = ExamStatus.Draft, DurationMin = 20 * sections.Count,
            CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
        };
        for (var i = 0; i < sections.Count; i++)
        {
            var generated = sections[i];
            var section = new ExamSection
            {
                Id = Guid.NewGuid(), Exam = exam, Idx = i + 1,
                Title = generated.Title,
                PassageMd = generated.Passage + $"\n\nSource adapted from: {generated.Source.Authors ?? "Article authors"}, "
                    + $"{generated.Source.Title}. {generated.Source.Url}. License: {generated.Source.License}.",
                InstructionsMd = $"Read the passage and answer questions {1 + ReadingPaperRules.Counts.Take(i).Sum(c => c.Sum())}–{ReadingPaperRules.Counts.Take(i + 1).Sum(c => c.Sum())}.",
                SourcePmcid = generated.Source.Pmcid, SourceTitle = generated.Source.Title,
                SourceAuthors = generated.Source.Authors,
                SourceDoi = generated.Source.Doi, SourceUrl = generated.Source.Url,
                SourceLicense = generated.Source.License
            };
            foreach (var (groupData, groupIndex) in generated.Groups.Select((g, idx) => (g, idx)))
            {
                var group = new ExamQuestionGroup
                {
                    Id = Guid.NewGuid(), Section = section, Idx = groupIndex + 1,
                    StartIdx = groupData.Questions[0].Number, EndIdx = groupData.Questions[^1].Number,
                    InstructionMd = groupData.Instruction
                };
                foreach (var item in groupData.Questions)
                {
                    var question = new ExamQuestion
                    {
                        Id = Guid.NewGuid(), Section = section, Group = group, Idx = item.Number,
                        Type = groupData.Type, Skill = "READING", Difficulty = i + 1,
                        PromptMd = item.Prompt, ExplanationMd = item.Explanation + "\n\nEvidence: “" + item.EvidenceQuote + "”"
                    };
                    if (groupData.Type is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION")
                        question.BlankAcceptTexts = new Dictionary<string, string[]?> { [item.Number.ToString()] = [item.Answer] };
                    else if (groupData.Type == "SHORT_ANSWER")
                        question.ShortAnswerAcceptTexts = [item.Answer];
                    else
                        question.Options = item.Options.Select((option, idx) => new ExamOption
                        {
                            Id = Guid.NewGuid(), Question = question, Idx = idx + 1,
                            ContentMd = option, IsCorrect = option == item.Answer
                        }).ToList();
                    group.Questions.Add(question);
                    section.Questions.Add(question);
                }
                section.QuestionGroups.Add(group);
            }
            exam.Sections.Add(section);
        }
        return exam;
    }
}
