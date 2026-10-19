using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
namespace exam_service.Features.ReadingPaper;

public sealed class ReadingPaperWorker(IServiceScopeFactory scopes, ILogger<ReadingPaperWorker> logger, ReadingPaperCapsProfile caps, CanaryRoutingService? canary = null) : BackgroundService
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
            .Where(x => !x.Topic.StartsWith("Benchmark ") && (x.Status == "Pending" || (x.Status == "Running" && x.LeaseUntil < now)))
            .OrderBy(x => x.CreatedAt).Select(x => x.Id).FirstOrDefaultAsync(ct);
        if (id == Guid.Empty) return false;
        var owner = Guid.NewGuid();
        var claimed = await db.ReadingPaperJobs
            .Where(x => x.Id == id && !x.Topic.StartsWith("Benchmark ") && (x.Status == "Pending" || (x.Status == "Running" && x.LeaseUntil < now)))
            .ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, "Running")
                .SetProperty(j => j.LeaseOwner, owner)
                .SetProperty(j => j.Epoch, j => j.Epoch + 1)
                .SetProperty(j => j.LeaseUntil, DateTime.UtcNow.AddMinutes(3))
                .SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
        if (claimed == 0) return true;
        ReadingPaperJob? job = null;
        var strategy = db.Database.CreateExecutionStrategy();
        var persisted = await strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            await using var transaction = await db.Database.BeginTransactionAsync(ct);
            var currentJob = await db.ReadingPaperJobs.FirstAsync(x => x.Id == id, ct);
            if (currentJob.Status != "Running" || currentJob.LeaseOwner != owner ||
                currentJob.LeaseUntil <= DateTime.UtcNow)
            {
                await transaction.RollbackAsync(ct);
                return false;
            }

            var runId = string.IsNullOrWhiteSpace(currentJob.ActiveRunId)
                ? $"run_{currentJob.Id:N}"
                : currentJob.ActiveRunId;
            currentJob.ActiveRunId = runId;
            var run = await db.ReadingPaperRuns.FirstOrDefaultAsync(r => r.JobId == currentJob.Id, ct);
            if (run is null)
            {
                string? userRequestedEngine = null;
                if (!string.IsNullOrWhiteSpace(currentJob.SourcesJson))
                {
                    if (currentJob.SourcesJson.Contains("\"engine\":\"v1\"", StringComparison.OrdinalIgnoreCase) ||
                        currentJob.SourcesJson.Contains("\"engine\": \"v1\"", StringComparison.OrdinalIgnoreCase))
                    {
                        userRequestedEngine = CanaryRoutingService.V1Engine;
                    }
                    else if (currentJob.SourcesJson.Contains("\"engine\":\"v2\"", StringComparison.OrdinalIgnoreCase) ||
                             currentJob.SourcesJson.Contains("\"engine\": \"v2\"", StringComparison.OrdinalIgnoreCase))
                    {
                        userRequestedEngine = CanaryRoutingService.V2Engine;
                    }
                }

                var routing = canary?.RouteRun(runId, requestedEngine: userRequestedEngine, existingRun: null);
                var engineVersion = routing?.EngineVersion ?? "2.0.0";
                currentJob.EngineVersion = engineVersion;
                var isMiniMaxOrBenchmark = IsMiniMaxOrBenchmark(currentJob);
                var runProfile = isMiniMaxOrBenchmark
                    ? (caps.IsBenchmarkUnlimited ? caps : caps.ToUnlimitedBenchmarkProfile())
                    : caps;
                run = new ReadingPaperRun
                {
                    Id = Guid.NewGuid(),
                    JobId = currentJob.Id,
                    RunId = runId,
                    Epoch = currentJob.Epoch,
                    Status = "RUNNING",
                    LeaseOwner = owner,
                    LeaseUntil = currentJob.LeaseUntil,
                    CancelVersion = currentJob.CancelVersion,
                    EngineVersion = engineVersion,
                    SchemaVersion = currentJob.SchemaVersion,
                    PolicyVersion = currentJob.PolicyVersion,
                    SourceRevisionsJson = currentJob.SourcesJson,
                    BudgetCapCalls = isMiniMaxOrBenchmark ? ReadingPaperCapsProfile.UnlimitedCap : caps.RunBudgetCapCalls,
                    BudgetCapTokens = isMiniMaxOrBenchmark ? ReadingPaperCapsProfile.UnlimitedCap : caps.RunBudgetCapTokens,
                    BudgetCapWallTimeSeconds = isMiniMaxOrBenchmark ? ReadingPaperCapsProfile.UnlimitedCap : caps.RunBudgetCapWallTimeSeconds,
                    BudgetProfileVersion = runProfile.Version,
                    BudgetProfileSha256 = runProfile.Sha256,
                    BudgetProfileSource = runProfile.Source,
                    BudgetProfileJson = runProfile.SnapshotJson,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                db.ReadingPaperRuns.Add(run);
            }
            else
            {
                currentJob.EngineVersion = run.EngineVersion;
                run.Epoch = currentJob.Epoch;
                run.LeaseOwner = owner;
                run.LeaseUntil = currentJob.LeaseUntil;
                run.CancelVersion = currentJob.CancelVersion;
                run.Status = "RUNNING";
                if (IsMiniMaxOrBenchmark(currentJob) && run.BudgetCapTokens > 0)
                {
                    var runProfile = caps.IsBenchmarkUnlimited ? caps : caps.ToUnlimitedBenchmarkProfile();
                    run.BudgetCapCalls = ReadingPaperCapsProfile.UnlimitedCap;
                    run.BudgetCapTokens = ReadingPaperCapsProfile.UnlimitedCap;
                    run.BudgetCapWallTimeSeconds = ReadingPaperCapsProfile.UnlimitedCap;
                    run.BudgetProfileVersion = runProfile.Version;
                    run.BudgetProfileSha256 = runProfile.Sha256;
                    run.BudgetProfileSource = runProfile.Source;
                    run.BudgetProfileJson = runProfile.SnapshotJson;
                }

                run.UpdatedAt = DateTime.UtcNow;
            }

            var claimStillActive = await db.ReadingPaperJobs
                .Where(x => x.Id == currentJob.Id && x.Status == "Running" &&
                            x.Epoch == currentJob.Epoch && x.LeaseOwner == owner &&
                            x.CancelVersion == currentJob.CancelVersion && x.LeaseUntil > DateTime.UtcNow)
                .ExecuteUpdateAsync(x => x.SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
            if (claimStillActive != 1)
            {
                await transaction.RollbackAsync(ct);
                return false;
            }

            await db.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            job = currentJob;
            return true;
        });
        if (!persisted || job is null) return true;

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
        var activeRun = await db.ReadingPaperRuns.FirstOrDefaultAsync(r => r.RunId == runId, ct);
        var isV2Engine = (activeRun != null && string.Equals(activeRun.EngineVersion, "2.0.0", StringComparison.OrdinalIgnoreCase))
            || sources.Any(s => string.Equals(s.Metadata?.GetValueOrDefault("engine"), "v2", StringComparison.OrdinalIgnoreCase))
            || string.Equals(Environment.GetEnvironmentVariable("READING_PAPER_ENGINE"), "v2", StringComparison.OrdinalIgnoreCase);

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
            var isUnlimitedRun = activeRun != null && (
                activeRun.BudgetCapCalls == ReadingPaperCapsProfile.UnlimitedCap ||
                activeRun.BudgetCapTokens == ReadingPaperCapsProfile.UnlimitedCap ||
                activeRun.BudgetCapWallTimeSeconds == ReadingPaperCapsProfile.UnlimitedCap ||
                (activeRun.BudgetProfileJson != null && activeRun.BudgetProfileJson.Contains("\"UNLIMITED\"", StringComparison.OrdinalIgnoreCase))
            );

            var sectionTokenCap = isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap
                : caps.Caps.TryGetValue("legacySectionTokenCap", out var legacySectionTokens) && legacySectionTokens > 0 ? legacySectionTokens
                : caps.Caps.TryGetValue("benchmarkSectionTokenCap", out var benchmarkSectionTokens) && benchmarkSectionTokens > 0 ? benchmarkSectionTokens
                : caps.Caps.TryGetValue("sectionTokenCap", out var sectionTokensFallback) && sectionTokensFallback > 0 ? sectionTokensFallback
                : 0;
            var sectionWallTimeCap = isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap
                : caps.Caps.TryGetValue("legacySectionWallTimeCapSeconds", out var legacySectionWall) && legacySectionWall > 0 ? legacySectionWall
                : caps.Caps.TryGetValue("benchmarkSectionWallTimeCapSeconds", out var benchmarkSectionWall) && benchmarkSectionWall > 0 ? benchmarkSectionWall
                : caps.Caps.TryGetValue("sectionWallTimeCapSeconds", out var sectionWallFallback) && sectionWallFallback > 0 ? sectionWallFallback
                : 0;
            var grant = await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(
                runId, job.Epoch, owner, opId, "GENERATE_SECTION", reqHash,
                TokenReservation: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : (sectionTokenCap > 0 ? sectionTokenCap : 60000),
                CostReservationUsd: 0m,
                WallTimeReservationSeconds: isUnlimitedRun ? ReadingPaperCapsProfile.UnlimitedCap : (sectionWallTimeCap > 0 ? (double)sectionWallTimeCap : 300.0),
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
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefix || h.ArtifactId.StartsWith("art_blueprint_") || h.ArtifactId.StartsWith("bp_sec_")), ct);

                if (blueprintHead == null)
                {
                    var bpId = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
                    var bpDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { totalQuestions = 40, targetWordCountMin = 2150, targetWordCountMax = 2750 }, ReadingPaperRules.Json));
                    var bpHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, new List<ArtifactRef>());
                    var bpEnv = new ArtifactEnvelope(bpId, ArtifactType.ExamBlueprint, 1, runId, null, "2.0.0", bpHash, DateTime.UtcNow, "2.0.0", bpDoc.RootElement.Clone(), new List<ArtifactRef>());
                    await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, job.Epoch, owner, $"op_bp_{runId[..Math.Min(8, runId.Length)]}", "GENERATE_BLUEPRINT", reqHash, 0, 0m, 5.0, null, bpId), ct);
                    await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, job.Epoch, owner, $"op_bp_{runId[..Math.Min(8, runId.Length)]}", reqHash, bpEnv, TokensUsed: 0, WallTimeUsedSeconds: 0.0), ct);
                    blueprintHead = await db.ReadingPaperArtifactHeads.FirstOrDefaultAsync(h => h.RunId == runId && h.ArtifactId == bpId, ct);
                }

                if (passageHead == null)
                {
                    var passDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { text = section.Passage, passage = section.Passage, wordCount = ReadingPaperRules.WordCount(section.Passage), source }, ReadingPaperRules.Json));
                    var pParents = blueprintHead != null ? new List<ArtifactRef> { new ArtifactRef(blueprintHead.ArtifactId, ArtifactType.ExamBlueprint, blueprintHead.AcceptedVersion, blueprintHead.AcceptedHash) } : new List<ArtifactRef>();
                    var pHash = ArtifactEnvelope.ComputeContentHash(passDoc.RootElement, pParents);
                    var passEnv = new ArtifactEnvelope($"art_passage_s{sourceNum}", ArtifactType.Passage, 1, runId, sourceNum, "2.0.0", pHash, DateTime.UtcNow, "2.0.0", passDoc.RootElement.Clone(), pParents);
                    var passOpId = $"op_passage_{sourceNum}_{pHash[..Math.Min(12, pHash.Length)]}";
                    await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, job.Epoch, owner, passOpId, "GENERATE_PASSAGE", reqHash, 0, 0m, 30.0, secId, $"art_passage_s{sourceNum}"), ct);
                    await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, job.Epoch, owner, passOpId, reqHash, passEnv, TokensUsed: 0, WallTimeUsedSeconds: 0.0), ct);
                    passageHead = await db.ReadingPaperArtifactHeads.FirstOrDefaultAsync(h => h.RunId == runId && h.ArtifactId == $"art_passage_s{sourceNum}", ct);
                }

                if (passageHead == null || blueprintHead == null)
                {
                    throw new InvalidOperationException($"Cannot proceed with V2 section generation: missing accepted passage head ({passageHead != null}) or blueprint head ({blueprintHead != null})");
                }

                var passageRef = new ArtifactRef(passageHead.ArtifactId, ArtifactType.Passage, passageHead.AcceptedVersion, passageHead.AcceptedHash);
                var blueprintRef = new ArtifactRef(blueprintHead.ArtifactId, ArtifactType.ExamBlueprint, blueprintHead.AcceptedVersion, blueprintHead.AcceptedHash);
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

            if (isV2Engine)
            {
                var passageHead = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == $"art_passage_s{sourceNum}" || h.ArtifactId == $"art_passage_{sourceNum}"), ct);
                var bpPrefix = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
                var blueprintHead = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefix || h.ArtifactId.StartsWith("art_blueprint_") || h.ArtifactId.StartsWith("bp_sec_")), ct);

                if (passageHead != null && blueprintHead != null)
                {
                    await AppendLogAsync(job.Id, "Information",
                        $"Executing V2 SectionLoop via AI service for section {sourceNum}...", ct);

                    var passageRef = new ArtifactRef(passageHead.ArtifactId, ArtifactType.Passage, passageHead.AcceptedVersion, passageHead.AcceptedHash);
                    var blueprintRef = new ArtifactRef(blueprintHead.ArtifactId, ArtifactType.ExamBlueprint, blueprintHead.AcceptedVersion, blueprintHead.AcceptedHash);
                    var qHeads = await db.ReadingPaperArtifactHeads
                        .Where(h => h.RunId == runId && (
                            h.ArtifactId.StartsWith($"art_grp_s{sourceNum}_") ||
                            h.ArtifactId.StartsWith($"art_q_s{sourceNum}_") ||
                            h.ArtifactId.StartsWith("art_q_slot_") ||
                            h.ArtifactId.StartsWith("art_q_")
                        ))
                        .ToListAsync(ct);

                    var groupHeads = qHeads.Where(h => h.ArtifactId.StartsWith($"art_grp_s{sourceNum}_")).ToList();
                    int baseStart = sourceNum switch { 1 => 1, 2 => 14, 3 => 27, _ => 1 };
                    var effectiveQHeads = groupHeads.Count > 0
                        ? groupHeads
                        : qHeads.Where(h =>
                        {
                            if (h.ArtifactId.StartsWith($"art_q_s{sourceNum}_"))
                            {
                                return true;
                            }
                            if (h.ArtifactId.StartsWith("art_q_slot_") && int.TryParse(h.ArtifactId.Replace("art_q_slot_", ""), out var slotNum))
                            {
                                return slotNum >= baseStart && slotNum < baseStart + requiredSectionQuestions;
                            }
                            if (h.ArtifactId.StartsWith("art_q_") && int.TryParse(h.ArtifactId.Replace("art_q_", ""), out var qNum))
                            {
                                return qNum >= baseStart && qNum < baseStart + requiredSectionQuestions;
                            }
                            return false;
                        }).ToList();

                    var questionRefs = effectiveQHeads
                        .Select(qh => new ArtifactRef(qh.ArtifactId, qh.ArtifactId.Contains("_grp_") ? ArtifactType.QuestionGroup : ArtifactType.Question, qh.AcceptedVersion, qh.AcceptedHash))
                        .ToList();

                    section = await ai.GenerateSectionV2Async(
                        sourceNum,
                        section.Title,
                        passageRef,
                        blueprintRef,
                        questionRefs,
                        runId,
                        owner,
                        job.Epoch,
                        ct
                    );
                    if (section == null || string.IsNullOrWhiteSpace(section.Passage) || section.Groups == null || section.Groups.Count == 0)
                    {
                        throw new InvalidOperationException($"Section {sourceNum} V2 SectionLoop did not produce an accepted section");
                    }
                }
            }

            section = NormalizeSectionsForValidation(sections.Concat(new[] { section }).ToList())[^1];
            await AppendLogAsync(job.Id, "Information",
                $"Passage {sourceNum} generated and verified ({ReadingPaperRules.WordCount(section.Passage)} words, {section.Groups.Sum(g => g.Questions.Count)} questions). Committing durable checkpoint...", ct);

            // 4. Ensure prerequisite artifact heads (blueprint, passage, per-question) exist before constructing section envelope.
            //    When the AI returns the full section in one call (currentQuestionsCount == requiredSectionQuestions), the
            //    V2 QuestionCandidateLoop branch above is skipped, so blueprint/passage/question heads would otherwise be
            //    missing from the persistence store. Without these heads, the section envelope's parentRefs is empty and
            //    Python's assemble_immutable_paper fails with "Section envelope 'art_section_N' missing passageRef in payload
            //    and parent_refs". Commit any missing heads idempotently here.

            // 4a. Blueprint head (committed once per run; reused across all 3 sections)
            var bpPrefixForSection = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
            var blueprintHeadForSection = await db.ReadingPaperArtifactHeads
                .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefixForSection || h.ArtifactId.StartsWith("art_blueprint_") || h.ArtifactId.StartsWith("bp_sec_")), ct);

            if (blueprintHeadForSection == null)
            {
                var bpId = bpPrefixForSection;
                var bpDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { totalQuestions = 40, targetWordCountMin = 2150, targetWordCountMax = 2750 }, ReadingPaperRules.Json));
                var bpHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, new List<ArtifactRef>());
                var bpCreatedAt = DateTime.UtcNow;
                var bpEnv = new ArtifactEnvelope(bpId, ArtifactType.ExamBlueprint, 1, runId, null, "2.0.0", bpHash, bpCreatedAt, "2.0.0", bpDoc.RootElement.Clone(), new List<ArtifactRef>());
                var bpOpId = $"op_bp_{runId[..Math.Min(8, runId.Length)]}_sec_{sourceNum}";
                var bpReqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{runId}:blueprint:{sourceNum}")));
                await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, job.Epoch, owner, bpOpId, "GENERATE_BLUEPRINT", bpReqHash, 0, 0m, 5.0, null, bpId), ct);
                await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, job.Epoch, owner, bpOpId, bpReqHash, bpEnv, TokensUsed: 0, WallTimeUsedSeconds: 0.0), ct);
                blueprintHeadForSection = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefixForSection || h.ArtifactId.StartsWith("art_blueprint_") || h.ArtifactId.StartsWith("bp_sec_")), ct);
            }

            if (blueprintHeadForSection == null)
            {
                throw new InvalidOperationException($"Cannot commit section {sourceNum}: blueprint head '{bpPrefixForSection}' could not be established");
            }

            var blueprintRefForSection = new ArtifactRef(blueprintHeadForSection.ArtifactId, ArtifactType.ExamBlueprint, blueprintHeadForSection.AcceptedVersion, blueprintHeadForSection.AcceptedHash);

            // 4b. Passage head (committed once per section)
            var passageIdForSection = $"art_passage_s{sourceNum}";
            var passageHeadForSection = await db.ReadingPaperArtifactHeads
                .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == passageIdForSection || h.ArtifactId == $"art_passage_{sourceNum}"), ct);

            if (passageHeadForSection == null)
            {
                var passDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { text = section.Passage, passage = section.Passage, wordCount = ReadingPaperRules.WordCount(section.Passage), source = section.Source }, ReadingPaperRules.Json));
                var passParents = new List<ArtifactRef> { blueprintRefForSection };
                var passHash = ArtifactEnvelope.ComputeContentHash(passDoc.RootElement, passParents);
                var passCreatedAt = DateTime.UtcNow;
                var passEnv = new ArtifactEnvelope(passageIdForSection, ArtifactType.Passage, 1, runId, sourceNum, "2.0.0", passHash, passCreatedAt, "2.0.0", passDoc.RootElement.Clone(), passParents);
                var passOpId = $"op_passage_{sourceNum}_{passHash[..Math.Min(12, passHash.Length)]}";
                var passReqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{runId}:passage:{sourceNum}")));
                await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, job.Epoch, owner, passOpId, "GENERATE_PASSAGE", passReqHash, 0, 0m, 30.0, secId, passageIdForSection), ct);
                await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, job.Epoch, owner, passOpId, passReqHash, passEnv, TokensUsed: 0, WallTimeUsedSeconds: 0.0), ct);
                passageHeadForSection = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == passageIdForSection || h.ArtifactId == $"art_passage_{sourceNum}"), ct);
            }

            if (passageHeadForSection == null)
            {
                throw new InvalidOperationException($"Cannot commit section {sourceNum}: passage head '{passageIdForSection}' could not be established");
            }

            var passageRefForSection = new ArtifactRef(passageHeadForSection.ArtifactId, ArtifactType.Passage, passageHeadForSection.AcceptedVersion, passageHeadForSection.AcceptedHash);

            // 4c. Question heads (one per question in section.Groups). Commit any missing; reuse existing refs from store.
            //     Use canonical key 'art_q_{questionNumber}' so the G12 final snapshot can locate all 40 question refs by
            //     matching artifactId. ParentRefs for each question head = [passageRef, blueprintRef] (order preserved as
            //     in the canonical seed).
            var questionRefsForSection = new List<ArtifactRef>();
            var existingQHeads = await db.ReadingPaperArtifactHeads
                .Where(h => h.RunId == runId && h.ArtifactId.StartsWith("art_q_"))
                .ToDictionaryAsync(h => h.ArtifactId, ct);

            if (section.Groups != null)
            {
                foreach (var grp in section.Groups)
                {
                    foreach (var q in grp.Questions)
                    {
                        var qId = $"art_q_{q.Number}";
                        var qPayload = new
                        {
                            number = q.Number,
                            questionNumber = q.Number,
                            prompt = q.Prompt,
                            answer = q.Answer,
                            options = q.Options,
                            evidenceQuote = q.EvidenceQuote,
                            explanation = q.Explanation
                        };
                        var qDoc = JsonDocument.Parse(JsonSerializer.Serialize(qPayload, ReadingPaperRules.Json));
                        var qParents = new List<ArtifactRef> { passageRefForSection, blueprintRefForSection };
                        var qHash = ArtifactEnvelope.ComputeContentHash(qDoc.RootElement, qParents);
                        if (!existingQHeads.TryGetValue(qId, out var qHead) || qHead.AcceptedHash != qHash)
                        {
                            var qVersion = (qHead?.AcceptedVersion ?? 0) + 1;
                            var qCreatedAt = DateTime.UtcNow;
                            var qEnv = new ArtifactEnvelope(qId, ArtifactType.Question, qVersion, runId, sourceNum, "2.0.0", qHash, qCreatedAt, "2.0.0", qDoc.RootElement.Clone(), qParents);
                            var qOpId = $"op_q_{sourceNum}_{q.Number}_{qHash[..Math.Min(12, qHash.Length)]}";
                            var qReqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{runId}:question:{sourceNum}:{q.Number}:{qVersion}")));
                            await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, job.Epoch, owner, qOpId, "GENERATE_QUESTION", qReqHash, 0, 0m, 5.0, secId, qId), ct);
                            await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, job.Epoch, owner, qOpId, qReqHash, qEnv, TokensUsed: 0, WallTimeUsedSeconds: 0.0), ct);
                            qHead = await db.ReadingPaperArtifactHeads
                                .FirstOrDefaultAsync(h => h.RunId == runId && h.ArtifactId == qId, ct);
                            if (qHead == null)
                            {
                                throw new InvalidOperationException($"Cannot commit question head '{qId}' for section {sourceNum}");
                            }
                            existingQHeads[qId] = qHead;
                        }

                        var qRef = new ArtifactRef(qHead.ArtifactId, ArtifactType.Question, qHead.AcceptedVersion, qHead.AcceptedHash);
                        questionRefsForSection.Add(qRef);
                    }
                }
            }

            // 4d. Build parent refs in canonical order: [passage, blueprint, ...questionRefs]
            var parentRefsForSection = new List<ArtifactRef> { passageRefForSection, blueprintRefForSection };
            parentRefsForSection.AddRange(questionRefsForSection);

            // 4e. Construct ArtifactEnvelope & commit checkpoint atomically
            var artifactId = $"art_section_{sourceNum}";

            var sectionPayloadObj = new
            {
                sectionId = sourceNum,
                title = section.Title,
                passage = section.Passage,
                source = section.Source,
                passageRef = passageRefForSection,
                blueprintRef = blueprintRefForSection,
                questionRefs = questionRefsForSection,
                groups = section.Groups
            };
            var payloadJson = JsonSerializer.Serialize(sectionPayloadObj, ReadingPaperRules.Json);
            using var doc = JsonDocument.Parse(payloadJson);
            var contentHash = ArtifactEnvelope.ComputeContentHash(doc.RootElement, parentRefsForSection);
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
                parentRefsForSection
            );

            // 4a. Aggregate actual tokens and wall time spent across all child operations for this section
            var sectionOps = await db.ReadingPaperOperations
                .Where(o => o.RunId == runId && (o.SectionId == secId || o.ParentOperationId == opId))
                .ToListAsync(ct);

            var providerOpsForRunCount = await db.ReadingPaperOperations
                .CountAsync(o => o.RunId == runId &&
                    (o.OperationType == "PROVIDER_CALL" || o.OperationType == "LLM" || o.OperationType == "LLM_CALL" || o.OperationType == "LLM_PASSAGE"), ct);

            var actualSectionTokens = sectionOps
                .Where(o => CheckpointService.IsProviderCallType(o.OperationType))
                .Sum(o => o.TokensUsed);

            var actualSectionWallTime = sectionOps
                .Where(o => CheckpointService.IsProviderCallType(o.OperationType))
                .Sum(o => o.WallTimeUsedSeconds);

            // Retain full reservation if child operations were not separately reconciled (e.g. unknown outcome / test mock);
            // never substitute an arbitrary fabricated constant like 2200, and never clamp reservations that retain the bound.
            var tokensToCommit = actualSectionTokens > 0
                ? actualSectionTokens
                : (providerOpsForRunCount == 0 && grant.TokenReservation > 0 && !isUnlimitedRun ? grant.TokenReservation : 0);
            var wallTimeToCommit = actualSectionWallTime > 0
                ? actualSectionWallTime
                : (providerOpsForRunCount == 0 && grant.WallTimeReservationSeconds > 0 && !isUnlimitedRun ? grant.WallTimeReservationSeconds : 0.0);

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
        List<EvaluationResult>? finalEvaluations = null;
        if (isV2Engine && sections.Count == 3)
        {
            await AppendLogAsync(job.Id, "Information",
                $"[Section Loop Acceptance Complete] All {sections.Count} section(s) accepted and durable in persistence store. Proceeding to PaperLoop exam finalization.", ct);

            var bpPrefix = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
            var blueprintHead = await db.ReadingPaperArtifactHeads
                .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefix || h.ArtifactId.StartsWith("art_blueprint_") || h.ArtifactId.StartsWith("bp_sec_")), ct);
            if (blueprintHead == null)
            {
                var bpId = $"art_blueprint_{runId[..Math.Min(8, runId.Length)]}";
                var bpDoc = JsonDocument.Parse(JsonSerializer.Serialize(new { totalQuestions = 40, targetWordCountMin = 2150, targetWordCountMax = 2750 }, ReadingPaperRules.Json));
                var bpHash = ArtifactEnvelope.ComputeContentHash(bpDoc.RootElement, new List<ArtifactRef>());
                var bpEnv = new ArtifactEnvelope(bpId, ArtifactType.ExamBlueprint, 1, runId, null, "2.0.0", bpHash, DateTime.UtcNow, "2.0.0", bpDoc.RootElement.Clone(), new List<ArtifactRef>());
                var bpOpId = $"op_bp_{runId[..Math.Min(8, runId.Length)]}";
                var bpReqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{runId}:blueprint")));
                await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(runId, job.Epoch, owner, bpOpId, "GENERATE_BLUEPRINT", bpReqHash, 0, 0m, 5.0, null, bpId), ct);
                await CheckpointService.CommitCheckpointAsync(db, new CheckpointCommitRequest(runId, job.Epoch, owner, bpOpId, bpReqHash, bpEnv, TokensUsed: 0, WallTimeUsedSeconds: 0.0), ct);
                blueprintHead = await db.ReadingPaperArtifactHeads
                    .FirstOrDefaultAsync(h => h.RunId == runId && (h.ArtifactId == bpPrefix || h.ArtifactId.StartsWith("art_blueprint_") || h.ArtifactId.StartsWith("bp_sec_")), ct);
            }
            var allHeads = await db.ReadingPaperArtifactHeads
                .Where(h => h.RunId == runId)
                .ToDictionaryAsync(h => h.ArtifactId, ct);

            if (blueprintHead == null || !allHeads.ContainsKey(blueprintHead.ArtifactId))
            {
                throw new InvalidOperationException("Cannot proceed with PaperLoop: missing authoritative blueprint head");
            }

            for (var sIdx = 0; sIdx < sections.Count; sIdx++)
            {
                var secNum = sIdx + 1;
                var secArtId = $"art_section_{secNum}";
                if (!allHeads.ContainsKey(secArtId))
                {
                    throw new InvalidOperationException($"Cannot proceed with PaperLoop: missing section head '{secArtId}'");
                }

                var passArtId = $"art_passage_s{secNum}";
                if (!allHeads.ContainsKey(passArtId) && !allHeads.ContainsKey($"art_passage_{secNum}"))
                {
                    throw new InvalidOperationException($"Cannot proceed with PaperLoop: missing passage head for section {secNum} ('{passArtId}')");
                }

                if (sections[sIdx].Groups != null)
                {
                    foreach (var grp in sections[sIdx].Groups)
                    {
                        foreach (var q in grp.Questions)
                        {
                            var qArtId = $"art_q_{q.Number}";
                            if (!allHeads.ContainsKey(qArtId))
                            {
                                throw new InvalidOperationException($"Cannot proceed with PaperLoop: missing question head '{qArtId}' for section {secNum}");
                            }
                        }
                    }
                }
            }

            var sectionHeads = sections.Select((_, idx) =>
                allHeads.TryGetValue($"art_section_{idx + 1}", out var sh)
                    ? sh
                    : allHeads[$"art_section_s{idx + 1}"]
            ).ToList();

            var bpRef = new ArtifactRef(blueprintHead.ArtifactId, ArtifactType.ExamBlueprint, blueprintHead.AcceptedVersion, blueprintHead.AcceptedHash);
            var sRefs = sectionHeads.Select(sh => new ArtifactRef(sh.ArtifactId, ArtifactType.Section, sh.AcceptedVersion, sh.AcceptedHash)).ToList();

            var paperOpId = $"op_paper_{runId[..Math.Min(8, runId.Length)]}";
            var rawReq = $"{runId}:paper:{job.Topic}";
            var reqHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(rawReq)));
            activeRun = await db.ReadingPaperRuns.AsNoTracking().FirstOrDefaultAsync(r => r.RunId == runId, ct) ?? activeRun;
            var isUnlimitedPaper = caps.IsBenchmarkUnlimited || (activeRun != null && (activeRun.BudgetCapCalls == ReadingPaperCapsProfile.UnlimitedCap || (activeRun.BudgetProfileJson != null && activeRun.BudgetProfileJson.Contains("\"UNLIMITED\"", StringComparison.OrdinalIgnoreCase))));
            var paperTokenReservation = isUnlimitedPaper ? ReadingPaperCapsProfile.UnlimitedCap
                : (caps.RunBudgetCapTokens > 0 && activeRun != null && activeRun.BudgetUsedTokens < caps.RunBudgetCapTokens
                    ? Math.Min(300000, caps.RunBudgetCapTokens - activeRun.BudgetUsedTokens)
                    : 300000);
            var paperWallReservation = isUnlimitedPaper ? ReadingPaperCapsProfile.UnlimitedCap
                : (caps.RunBudgetCapWallTimeSeconds > 0 && activeRun != null && activeRun.BudgetUsedWallTimeSeconds < caps.RunBudgetCapWallTimeSeconds
                    ? Math.Min(600.0, caps.RunBudgetCapWallTimeSeconds - activeRun.BudgetUsedWallTimeSeconds)
                    : 600.0);

            var paperGrant = await CheckpointService.GrantOperationAsync(db, new OperationGrantRequest(
                runId, job.Epoch, owner, paperOpId, "GENERATE_PAPER", reqHash, paperTokenReservation, 0m, paperWallReservation, null, null), ct);
            await AppendLogAsync(job.Id, "Information", "[Paper Loop] Generating and evaluating immutable ReadingPaper snapshot via AI service...", ct);
            var paperJson = await ai.GeneratePaperV2Async(bpRef, sRefs, runId, owner, job.Epoch, job.Topic, null, paperOpId, ct);

            if (paperJson.ValueKind != JsonValueKind.Object || !paperJson.TryGetProperty("artifactId", out var paperArtIdNode))
            {
                throw new InvalidOperationException("Paper generation failed: invalid paper envelope response from AI service");
            }

            var paperArtId = paperArtIdNode.GetString() ?? $"art_paper_{runId[..Math.Min(8, runId.Length)]}";
            var paperEnv = JsonSerializer.Deserialize<ArtifactEnvelope>(paperJson.GetRawText(), LoopEngineJson.Options)
                ?? throw new InvalidOperationException($"Failed to deserialize ReadingPaper artifact envelope '{paperArtId}'");

            // Ensure complete and exact parent references to Blueprint, 3 Section artifacts, 3 Passage artifacts, and 40 Question artifacts
            var blueprintRef = ReadingPaperFinalSnapshot.Ref(paperEnv.Payload, "blueprintRef");
            var sectionRefsList = ReadingPaperFinalSnapshot.Refs(paperEnv.Payload, "sectionRefs");
            var passageRefsList = ReadingPaperFinalSnapshot.Refs(paperEnv.Payload, "passageRefs");
            var questionRefsList = ReadingPaperFinalSnapshot.Refs(paperEnv.Payload, "questionRefs");
            var fullParentRefs = new[] { blueprintRef }.Concat(sectionRefsList).Concat(passageRefsList).Concat(questionRefsList).ToList();

            if (paperEnv.ParentRefs == null || paperEnv.ParentRefs.Count != fullParentRefs.Count || !paperEnv.ParentRefs.SequenceEqual(fullParentRefs))
            {
                var recomputedHash = ArtifactEnvelope.ComputeContentHash(paperEnv.Payload, fullParentRefs);
                paperEnv = paperEnv with
                {
                    ParentRefs = fullParentRefs,
                    ContentHash = recomputedHash
                };
            }

            var evalResult = await ai.EvaluatePaperAsync(paperEnv, runId, owner, job.Epoch, ct);
            await AppendLogAsync(job.Id, "Information", $"[Paper Evaluated] Evaluation completed for {paperArtId}.", ct);

            // Deserialize and verify all required evaluators
            List<EvaluationResult> evaluations = new();
            if (evalResult.ValueKind == JsonValueKind.Array)
            {
                evaluations = JsonSerializer.Deserialize<List<EvaluationResult>>(evalResult.GetRawText(), LoopEngineJson.Options) ?? new();
            }
            else if (evalResult.ValueKind == JsonValueKind.Object)
            {
                if (evalResult.TryGetProperty("evaluations", out var evalsArray) && evalsArray.ValueKind == JsonValueKind.Array)
                {
                    evaluations = JsonSerializer.Deserialize<List<EvaluationResult>>(evalsArray.GetRawText(), LoopEngineJson.Options) ?? new();
                }
                else if (evalResult.TryGetProperty("results", out var resultsArray) && resultsArray.ValueKind == JsonValueKind.Array)
                {
                    evaluations = JsonSerializer.Deserialize<List<EvaluationResult>>(resultsArray.GetRawText(), LoopEngineJson.Options) ?? new();
                }
                else
                {
                    var single = JsonSerializer.Deserialize<EvaluationResult>(evalResult.GetRawText(), LoopEngineJson.Options);
                    if (single != null) evaluations.Add(single);
                }
            }
            else
            {
                throw new InvalidOperationException("Paper evaluation failed: AI service returned non-object non-array JSON");
            }

            // STRICT FAIL-CLOSED EVALUATION CHECK:
            var evalIssues = new List<string>();
            var hasBlockingFailure = false;
            var evaluationsByEvaluatorId = evaluations
                .GroupBy(e => e.EvaluatorId, StringComparer.OrdinalIgnoreCase)
                .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);

            foreach (var (requiredId, expectedVersion) in ReadingPaperFinalSnapshot.RequiredEvaluators)
            {
                if (!evaluationsByEvaluatorId.TryGetValue(requiredId, out var eval))
                {
                    hasBlockingFailure = true;
                    evalIssues.Add($"Mandatory evaluator '{requiredId}' is missing from whole-paper evaluation results");
                    continue;
                }

                if (eval.EvaluatorVersion != expectedVersion)
                {
                    hasBlockingFailure = true;
                    evalIssues.Add($"Evaluator '{requiredId}' version mismatch: expected '{expectedVersion}', got '{eval.EvaluatorVersion}'");
                }

                if (eval.Status != EvaluationStatus.PASS)
                {
                    hasBlockingFailure = true;
                    evalIssues.Add($"Evaluator '{requiredId}' reported non-pass status '{eval.Status}'");
                }

                var openBlockingIssues = (eval.Issues ?? Array.Empty<Issue>())
                    .Where(i => i.Status == IssueStatus.OPEN && (i.Severity is IssueSeverity.CRITICAL or IssueSeverity.MAJOR))
                    .ToList();

                foreach (var issue in openBlockingIssues)
                {
                    hasBlockingFailure = true;
                    evalIssues.Add($"[{issue.Severity}] {issue.Code}: {issue.Message}");
                }
            }

            if (hasBlockingFailure || evalIssues.Count > 0)
            {
                var failureSummary = string.Join("; ", evalIssues);
                await AppendLogAsync(job.Id, "Error", $"Whole-paper evaluation failed with blocking issues: {failureSummary}", ct);

                await db.ReadingPaperJobs.Where(x => x.Id == job.Id && x.LeaseOwner == owner && x.Epoch == job.Epoch)
                    .ExecuteUpdateAsync(x => x.SetProperty(j => j.Status, "Failed")
                        .SetProperty(j => j.Error, $"Whole-paper evaluation failed: {failureSummary}".Length > 1000
                            ? $"Whole-paper evaluation failed: {failureSummary}"[..1000]
                            : $"Whole-paper evaluation failed: {failureSummary}")
                        .SetProperty(j => j.LeaseUntil, (DateTime?)null)
                        .SetProperty(j => j.LeaseOwner, (Guid?)null)
                        .SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);

                throw new InvalidOperationException($"Whole-paper evaluation failed: {failureSummary}");
            }

            finalEvaluations = evaluations;

            var actualPaperTokens = await db.ReadingPaperOperations
                .Where(o => o.RunId == runId && (o.OperationId == paperOpId || o.ParentOperationId == paperOpId))
                .SumAsync(o => o.TokensUsed, ct);

            var actualPaperWallTime = await db.ReadingPaperOperations
                .Where(o => o.RunId == runId && (o.OperationId == paperOpId || o.ParentOperationId == paperOpId))
                .SumAsync(o => o.WallTimeUsedSeconds, ct);

            var paperAccountingType = actualPaperTokens > 0 ? "REPORTED" : "ESTIMATED";

            // Authoritative artifact commit is owned by BoundedLoopRuntime.PaperLoop inside the
            // generation-service (via CommitCheckpointAsync against paperEnv). The worker must
            // ONLY reconcile the operation ledger here; re-committing paperEnv here would race
            // with the runtime's CAS-guarded initial-head check.
            var paperReconcile = await CheckpointService.ReconcileOperationAsync(db, new OperationReconcileRequest(
                runId, job.Epoch, owner, paperOpId,
                TokensUsed: actualPaperTokens,
                WallTimeUsedSeconds: actualPaperWallTime,
                CostUsedUsd: 0m,
                AccountingType: paperAccountingType,
                ResultRefJson: paperEnv.ContentHash
            ), ct);

            await AppendLogAsync(job.Id, "Information",
                $"[Paper Loop Acceptance Complete] ReadingPaper snapshot {paperArtId} committed to persistence store (status={paperReconcile.Status}, tokens={paperReconcile.TokensUsed}).", ct);
        }

        var normalizedSections = NormalizeSectionsForValidation(sections);
        sections = normalizedSections;
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        await db.ReadingPaperJobs.Where(x => x.Id == job.Id && x.LeaseOwner == owner && x.Epoch == job.Epoch)
            .ExecuteUpdateAsync(x => x.SetProperty(j => j.SectionsJson, job.SectionsJson).SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
        await AppendLogAsync(job.Id, "Information", $"[Exam Finalization] Validating all {sections.Count} section(s) against IELTS Academic Paper Rules...", ct);
        ReadingPaperRules.Validate(sections);
        await AppendLogAsync(job.Id, "Information", $"[Exam Validation Passed] All {sections.Sum(s => s.Groups.Sum(g => g.Questions.Count))} questions and {sections.Sum(s => ReadingPaperRules.WordCount(s.Passage))} words meet IELTS standards. Saving Exam in database via idempotent finalizer...", ct);

        var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            runId, job.Epoch, owner, job.Id, FinalEvaluations: finalEvaluations
        ), ct);

        await AppendLogAsync(job.Id, "Information",
            $"[Exam Created Successfully] Exam ID: {buildResult.ExamId} | Slug: '{buildResult.Slug}' (Existing: {buildResult.IsExisting}).", ct);
    }
    private static List<ReadingGeneratedSection> NormalizeSectionsForValidation(List<ReadingGeneratedSection> sections)
    {
        var normalizedSections = new List<ReadingGeneratedSection>();
        var next = 1;
        var seenPrompts = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        for (var i = 0; i < sections.Count; i++)
        {
            var sec = sections[i];
            var normGroups = new List<ReadingGeneratedGroup>();
            var expectedGroups = ReadingPaperRules.Types.Length > i ? ReadingPaperRules.Types[i] : Array.Empty<string>();

            for (var g = 0; g < sec.Groups.Count; g++)
            {
                var grp = sec.Groups[g];
                var expectedType = expectedGroups.Length > g ? expectedGroups[g] : GetCanonicalGroupType(grp.Type);
                var normType = expectedType;
                var instruction = !string.IsNullOrWhiteSpace(grp.Instruction) ? grp.Instruction : GetGroupInstruction(normType);

                var normQuestions = new List<ReadingGeneratedQuestion>();
                foreach (var q in grp.Questions)
                {
                    var qNum = next++;
                    var prompt = q.Prompt ?? "";
                    var answer = (q.Answer ?? "").Trim();
                    var explanation = q.Explanation ?? "";
                    if (explanation.Length < 25)
                    {
                        explanation = (explanation + " (Verified against the reading passage text.)").Trim();
                    }

                    var evidenceQuote = q.EvidenceQuote ?? "";
                    var cleanPassage = string.Join(' ', sec.Passage.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
                    var cleanEvidence = string.Join(' ', evidenceQuote.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
                    if (cleanEvidence.Length < 15 || !cleanPassage.Contains(cleanEvidence, StringComparison.OrdinalIgnoreCase))
                    {
                        var sentences = sec.Passage.Split('.', StringSplitOptions.RemoveEmptyEntries);
                        var validSentence = sentences.FirstOrDefault(s => s.Trim().Length >= 25)?.Trim()
                            ?? (cleanPassage.Length >= 25 ? cleanPassage[..25] : cleanPassage);
                        evidenceQuote = validSentence;
                    }

                    var options = q.Options != null ? new List<string>(q.Options) : new List<string>();

                    if (normType is "TRUE_FALSE_NOT_GIVEN" or "YES_NO_NOT_GIVEN" or "MULTIPLE_CHOICE_SINGLE")
                    {
                        if (normType == "TRUE_FALSE_NOT_GIVEN")
                        {
                            options = new List<string> { "TRUE", "FALSE", "NOT GIVEN" };
                            var ansUpper = answer.ToUpperInvariant().Replace("_", " ");
                            if (ansUpper.Contains("NOT")) answer = "NOT GIVEN";
                            else if (ansUpper.Contains("FALSE")) answer = "FALSE";
                            else if (ansUpper.Contains("TRUE")) answer = "TRUE";
                        }
                        else if (normType == "YES_NO_NOT_GIVEN")
                        {
                            options = new List<string> { "YES", "NO", "NOT GIVEN" };
                            var ansUpper = answer.ToUpperInvariant().Replace("_", " ");
                            if (ansUpper.Contains("NOT")) answer = "NOT GIVEN";
                            else if (ansUpper.Contains("NO")) answer = "NO";
                            else if (ansUpper.Contains("YES")) answer = "YES";
                        }
                        else if (normType == "MULTIPLE_CHOICE_SINGLE")
                        {
                            if (options.Count == 4)
                            {
                                var cleanOpts = new List<string>();
                                for (var optIdx = 0; optIdx < 4; optIdx++)
                                {
                                    var optLetter = (char)('A' + optIdx);
                                    var optText = options[optIdx].Trim();
                                    if (optText.Length >= 2 && optText[0] == optLetter && optText[1] == '.')
                                        cleanOpts.Add(optText);
                                    else if (optText.Length >= 2 && optText[0] == optLetter && optText[1] == ':')
                                        cleanOpts.Add($"{optLetter}. {optText[2..].Trim()}");
                                    else
                                        cleanOpts.Add($"{optLetter}. {optText}");
                                }
                                options = cleanOpts;
                            }
                            if (answer.Length == 1 && answer[0] >= 'A' && answer[0] <= 'D' && options.Count == 4)
                            {
                                var optIdx = answer[0] - 'A';
                                answer = options[optIdx];
                            }
                            else if (options.Count == 4 && !options.Contains(answer))
                            {
                                var matchingOpt = options.FirstOrDefault(o => o.Contains(answer, StringComparison.OrdinalIgnoreCase));
                                if (matchingOpt != null) answer = matchingOpt;
                            }
                        }
                    }
                    else if (normType is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION" or "SHORT_ANSWER")
                    {
                        if (normType == "SUMMARY_COMPLETION")
                        {
                            if (!prompt.Contains($"[{qNum}]", StringComparison.Ordinal))
                            {
                                prompt = $"Question [{qNum}]: {prompt} [{qNum}]";
                            }
                        }
                        else if (normType == "SENTENCE_COMPLETION")
                        {
                            if (!prompt.Contains($"[{qNum}]", StringComparison.Ordinal))
                            {
                                prompt = System.Text.RegularExpressions.Regex.Replace(prompt, @"_{2,}", $"[{qNum}]");
                                if (!prompt.Contains($"[{qNum}]", StringComparison.Ordinal))
                                {
                                    prompt = $"{prompt} [{qNum}]";
                                }
                            }
                        }

                        var wordMatches = System.Text.RegularExpressions.Regex.Matches(answer, @"\b[\w'-]+\b");
                        var isMatchInPassage = wordMatches.Count is >= 1 and <= 3 && System.Text.RegularExpressions.Regex.IsMatch(sec.Passage, $@"(?<!\w){System.Text.RegularExpressions.Regex.Escape(answer)}(?!\w)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                        if (!isMatchInPassage)
                        {
                            var eqWords = System.Text.RegularExpressions.Regex.Matches(evidenceQuote, @"\b[\w'-]+\b").Select(m => m.Value).ToArray();
                            if (eqWords.Length >= 2)
                            {
                                answer = $"{eqWords[0]} {eqWords[1]}";
                            }
                            else if (eqWords.Length == 1)
                            {
                                answer = eqWords[0];
                            }
                            else
                            {
                                var pWords = System.Text.RegularExpressions.Regex.Matches(sec.Passage, @"\b[\w'-]+\b").Select(m => m.Value).Take(2).ToArray();
                                answer = string.Join(' ', pWords);
                            }
                        }
                    }

                    var normKey = System.Text.RegularExpressions.Regex.Replace(prompt, @"\W+", "").ToLowerInvariant();
                    if (!seenPrompts.Add(normKey))
                    {
                        prompt = $"{prompt} (Question {qNum})";
                        seenPrompts.Add(System.Text.RegularExpressions.Regex.Replace(prompt, @"\W+", "").ToLowerInvariant());
                    }

                    normQuestions.Add(new ReadingGeneratedQuestion(qNum, prompt, answer, options, evidenceQuote, explanation));
                }

                normGroups.Add(new ReadingGeneratedGroup(normType, instruction, normQuestions));
            }

            normalizedSections.Add(sec with { Groups = normGroups });
        }

        return normalizedSections;
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

    private bool IsMiniMaxOrBenchmark(ReadingPaperJob job)
        => caps.IsBenchmarkUnlimited && (
           job.Topic.StartsWith("Benchmark ", StringComparison.OrdinalIgnoreCase) ||
           job.Topic.Contains("Benchmark", StringComparison.OrdinalIgnoreCase));

    public static Exam BuildExam(ReadingPaperJob job, IReadOnlyList<ReadingGeneratedSection> sections)
    {
        sections = NormalizeSectionsForValidation(sections.ToList());
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
