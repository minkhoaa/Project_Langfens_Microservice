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
        var provider = sources.FirstOrDefault()?.Metadata?.GetValueOrDefault("provider")
            ?? Environment.GetEnvironmentVariable("READING_PAPER_LLM_PROVIDER")
            ?? Environment.GetEnvironmentVariable("LLM_PROVIDER")
            ?? "minimax";

        var isUnlimitedRun = activeRun != null && (
            activeRun.BudgetCapCalls == ReadingPaperCapsProfile.UnlimitedCap ||
            activeRun.BudgetCapTokens == ReadingPaperCapsProfile.UnlimitedCap ||
            activeRun.BudgetCapWallTimeSeconds == ReadingPaperCapsProfile.UnlimitedCap ||
            (activeRun.BudgetProfileJson != null && activeRun.BudgetProfileJson.Contains("\"UNLIMITED\"", StringComparison.OrdinalIgnoreCase))
        );

        var policy = PinnedExecutionPolicy.CreateDefault(provider);
        if (isUnlimitedRun)
        {
            policy = policy with
            {
                ProviderCallSeconds = 180.0,
                SectionWallSeconds = 900.0,
                SectionTokenCap = 100000,
                RunTokenCap = 300000,
                RunWallSeconds = 2700.0
            };
        }

        var sourceInputs = sources.Select((s, idx) => new SourceInput(
            SectionIndex: idx + 1,
            Pmcid: s.Pmcid,
            Title: s.Title,
            Url: s.Url,
            License: s.License,
            Content: s.Content,
            Doi: s.Doi,
            Authors: s.Authors
        )).ToList();

        var pipelineRequest = new PipelineRequest(
            RunId: runId,
            JobId: job.Id,
            Epoch: job.Epoch,
            LeaseOwner: owner,
            Topic: job.Topic,
            Sources: sourceInputs,
            SectionIndices: sourceInputs.Select(s => s.SectionIndex).ToList(),
            Parallel: false,
            Policy: policy,
            Finalize: true
        );

        await AppendLogAsync(job.Id, "Information",
            $"Executing unified ReadingGenerationPipeline via AI client for topic '{job.Topic}' ({sources.Count} sources)...", ct);

        var pipelineResult = await ai.ExecutePipelineAsync(pipelineRequest, ct);

        await AppendLogAsync(job.Id, "Information",
            $"Unified pipeline executed successfully. Status: {pipelineResult.Status}, Sections: {pipelineResult.Sections?.Count ?? 0}.", ct);

        if (pipelineResult.Sections != null && pipelineResult.Sections.Count > 0)
        {
            sections = pipelineResult.Sections
                .Select(secEnv => CheckpointService.ParseCanonicalV2Section(secEnv.Payload))
                .Where(s => s != null)
                .Select(s => s!)
                .ToList();
        }

        List<EvaluationResult>? finalEvaluations = null;

        var normalizedSections = NormalizeSectionsForValidation(sections);
        sections = normalizedSections;
        job.SectionsJson = JsonSerializer.Serialize(sections, ReadingPaperRules.Json);
        job.CompletedSections = sections.Count;
        await db.ReadingPaperJobs.Where(x => x.Id == job.Id && x.LeaseOwner == owner && x.Epoch == job.Epoch)
            .ExecuteUpdateAsync(x => x.SetProperty(j => j.SectionsJson, job.SectionsJson)
                .SetProperty(j => j.CompletedSections, job.CompletedSections)
                .SetProperty(j => j.UpdatedAt, DateTime.UtcNow), ct);
        await AppendLogAsync(job.Id, "Information", $"[Exam Finalization] Validating all {sections.Count} section(s) against IELTS Academic Paper Rules...", ct);
        ReadingPaperRules.Validate(sections);
        await AppendLogAsync(job.Id, "Information", $"[Exam Validation Passed] All {sections.Sum(s => s.Groups.Sum(g => g.Questions.Count))} questions and {sections.Sum(s => ReadingPaperRules.WordCount(s.Passage))} words meet IELTS standards. Saving Exam in database via idempotent finalizer...", ct);

        var buildResult = await CheckpointService.BuildExamIdempotentAsync(db, new BuildExamInternalRequest(
            runId, job.Epoch, owner, job.Id, FinalEvaluations: finalEvaluations
        ), ct);

        await AppendLogAsync(job.Id, "Information",
            $"[Exam Created Successfully] Exam ID: {buildResult.ExamId} | Slug: '{buildResult.Slug}' (Existing: {buildResult.IsExisting}).", ct);
    }
    public static List<ReadingGeneratedSection> NormalizeSectionsForValidation(List<ReadingGeneratedSection> sections)
    {
        var normalizedSections = new List<ReadingGeneratedSection>();
        var next = 1;
        var seenPrompts = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        for (var i = 0; i < sections.Count; i++)
        {
            var sec = sections[i];
            // Check if this matches legacy 2-group preset
            var isLegacyPreset = sections.Count <= ReadingPaperRules.Types.Length
                && sections.All(s => s.Groups.Count == 2);
            var expectedGroups = isLegacyPreset && ReadingPaperRules.Types.Length > i ? ReadingPaperRules.Types[i] : Array.Empty<string>();
            var normGroups = new List<ReadingGeneratedGroup>();

            for (var g = 0; g < sec.Groups.Count; g++)
            {
                var grp = sec.Groups[g];
                var normType = (isLegacyPreset && expectedGroups.Length > g) ? expectedGroups[g] : GetCanonicalGroupType(grp.Type);
                var instruction = !string.IsNullOrWhiteSpace(grp.Instruction) ? grp.Instruction : GetGroupInstruction(normType);

                var normQuestions = new List<ReadingGeneratedQuestion>();
                foreach (var q in grp.Questions)
                {
                    var qNum = next++;
                    var prompt = (q.Prompt ?? "").Trim();
                    var answer = (q.Answer ?? "").Trim();
                    var explanation = (q.Explanation ?? "").Trim();
                    if (string.IsNullOrWhiteSpace(explanation) || explanation.Length < 25 || IsGenericExplanation(explanation))
                    {
                        throw new InvalidOperationException($"Question {qNum} explanation '{explanation}' is missing, too short (< 25 characters), or a generic placeholder");
                    }

                    var evidenceQuote = (q.EvidenceQuote ?? "").Trim();
                    var cleanPassage = string.Join(' ', sec.Passage.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
                    var cleanEvidence = string.Join(' ', evidenceQuote.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
                    if (cleanEvidence.Length < 15 || !cleanPassage.Contains(cleanEvidence, StringComparison.OrdinalIgnoreCase))
                    {
                        throw new InvalidOperationException($"Question {qNum} evidence quote '{evidenceQuote}' is missing (< 15 characters) or not found in passage text");
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
                            throw new InvalidOperationException($"Question {qNum} completion answer '{answer}' is not a verbatim 1–3 word match in the passage");
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

    private static bool IsGenericExplanation(string explanation)
    {
        var trimmed = explanation.Trim();
        return string.Equals(trimmed, "Verified against the reading passage text.", StringComparison.OrdinalIgnoreCase)
            || string.Equals(trimmed, "(Verified against the reading passage text.)", StringComparison.OrdinalIgnoreCase)
            || string.Equals(trimmed, "Explanation based on the passage text.", StringComparison.OrdinalIgnoreCase)
            || string.Equals(trimmed, "No explanation provided.", StringComparison.OrdinalIgnoreCase)
            || string.Equals(trimmed, "Placeholder explanation text.", StringComparison.OrdinalIgnoreCase)
            || System.Text.RegularExpressions.Regex.IsMatch(trimmed, @"^Explanation for question\s+\d+\s+based on passage text\.$", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
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
        var norm = rawType.Replace("_", "").Replace(" ", "").Replace("-", "").ToUpperInvariant();
        return norm switch
        {
            "TRUEFALSENOTGIVEN" or "TFNG" => "TRUE_FALSE_NOT_GIVEN",
            "YESNONOTGIVEN" or "YNNG" => "YES_NO_NOT_GIVEN",
            "MULTIPLECHOICESINGLE" or "MCQ" or "MULTIPLECHOICE" => "MULTIPLE_CHOICE_SINGLE",
            "MULTIPLECHOICEMULTIPLE" => "MULTIPLE_CHOICE_MULTIPLE",
            "MULTIPLECHOICESINGLEIMAGE" => "MULTIPLE_CHOICE_SINGLE_IMAGE",
            "SENTENCECOMPLETION" => "SENTENCE_COMPLETION",
            "SUMMARYCOMPLETION" => "SUMMARY_COMPLETION",
            "SUMMARYCOMPLETIONBOX" or "SUMMARYBOX" => "SUMMARY_COMPLETION_BOX",
            "SHORTANSWER" => "SHORT_ANSWER",
            "MATCHINGHEADING" or "MATCHINGHEADINGS" => "MATCHING_HEADING",
            "MATCHINGINFORMATION" => "MATCHING_INFORMATION",
            "MATCHINGFEATURES" => "MATCHING_FEATURES",
            "MATCHINGENDINGS" or "MATCHINGSENTENCEENDINGS" => "MATCHING_ENDINGS",
            "TABLECOMPLETION" => "TABLE_COMPLETION",
            "FLOWCHART" or "FLOWCHARTCOMPLETION" => "FLOW_CHART",
            "DIAGRAMLABEL" or "DIAGRAMLABELING" => "DIAGRAM_LABEL",
            "MAPLABEL" => "MAP_LABEL",
            "NOTECOMPLETION" => "NOTE_COMPLETION",
            "FORMCOMPLETION" => "FORM_COMPLETION",
            "CLASSIFICATION" => "CLASSIFICATION",
            "CHOOSINGTITLE" or "CHOOSINGATITLE" => "CHOOSING_TITLE",
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
                InstructionsMd = $"Read the passage and answer questions {generated.Groups.SelectMany(g => g.Questions).Min(q => q.Number)}–{generated.Groups.SelectMany(g => g.Questions).Max(q => q.Number)}.",
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
                    var type = groupData.Type;
                    if (type is "SENTENCE_COMPLETION" or "SUMMARY_COMPLETION" or "TABLE_COMPLETION"
                        or "NOTE_COMPLETION" or "FORM_COMPLETION" or "SUMMARY_COMPLETION_BOX"
                        or "DIAGRAM_LABEL" or "FLOW_CHART" or "MAP_LABEL")
                    {
                        question.BlankAcceptTexts = new Dictionary<string, string[]?> { [item.Number.ToString()] = [item.Answer] };
                        if (item.Options.Count > 0)
                        {
                            question.Options = item.Options.Select((option, idx) => new ExamOption
                            {
                                Id = Guid.NewGuid(), Question = question, Idx = idx + 1,
                                ContentMd = option, IsCorrect = option == item.Answer || option.StartsWith(item.Answer + ".", StringComparison.OrdinalIgnoreCase)
                            }).ToList();
                        }
                    }
                    else if (type == "SHORT_ANSWER")
                    {
                        question.ShortAnswerAcceptTexts = [item.Answer];
                        question.BlankAcceptTexts = new Dictionary<string, string[]?> { [item.Number.ToString()] = [item.Answer] };
                    }
                    else if (type is "MATCHING_HEADING" or "MATCHING_INFORMATION" or "MATCHING_FEATURES"
                        or "MATCHING_ENDINGS" or "CLASSIFICATION")
                    {
                        var matchLabel = item.Options.FirstOrDefault(o => o.StartsWith(item.Answer + ".", StringComparison.OrdinalIgnoreCase) || o == item.Answer) ?? item.Answer;
                        question.MatchPairs = new Dictionary<string, string[]?>
                        {
                            [item.Number.ToString()] = [item.Answer, matchLabel]
                        };
                        if (item.Options.Count > 0)
                        {
                            question.Options = item.Options.Select((option, idx) => new ExamOption
                            {
                                Id = Guid.NewGuid(), Question = question, Idx = idx + 1,
                                ContentMd = option, IsCorrect = option == item.Answer || option.StartsWith(item.Answer + ".", StringComparison.OrdinalIgnoreCase)
                            }).ToList();
                        }
                    }
                    else if (type is "MULTIPLE_CHOICE_SINGLE" or "CHOOSING_TITLE" or "MULTIPLE_CHOICE_SINGLE_IMAGE")
                    {
                        question.Options = item.Options.Select((option, idx) => new ExamOption
                        {
                            Id = Guid.NewGuid(), Question = question, Idx = idx + 1,
                            ContentMd = option, IsCorrect = option == item.Answer || (item.Answer.Length == 1 && option.StartsWith($"{item.Answer}.", StringComparison.OrdinalIgnoreCase))
                        }).ToList();
                    }
                    else if (type == "MULTIPLE_CHOICE_MULTIPLE")
                    {
                        var correctTokens = item.Answer.Split([',', ';', ' '], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
                        question.Options = item.Options.Select((option, idx) => new ExamOption
                        {
                            Id = Guid.NewGuid(), Question = question, Idx = idx + 1,
                            ContentMd = option,
                            IsCorrect = correctTokens.Any(token => option == token || (token.Length == 1 && option.StartsWith($"{token}.", StringComparison.OrdinalIgnoreCase)))
                        }).ToList();
                    }
                    else
                    {
                        // Default choice / boolean options (TRUE_FALSE_NOT_GIVEN, YES_NO_NOT_GIVEN, etc.)
                        question.Options = item.Options.Select((option, idx) => new ExamOption
                        {
                            Id = Guid.NewGuid(), Question = question, Idx = idx + 1,
                            ContentMd = option, IsCorrect = option == item.Answer
                        }).ToList();
                    }
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
