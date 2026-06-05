using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using Google.Protobuf;
using Google.Protobuf.Collections;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Shared.ExamDto.Contracts.Writing;
using Shared.Grpc.ExamInternal;
using Shared.PublicContracts.Events;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public interface IAttemptService
{
    Task<IResult> StartAttempt(AttemptStartRequest request, CancellationToken token);
    Task<IResult> GetAttemptById(Guid attemptId, CancellationToken token);
    Task<IResult> GetPreviousTurn(Guid examId, CancellationToken token);
    Task<IResult> Autosave(Guid attemptId, AutosaveRequest req, CancellationToken token);
    Task<IResult> Submit(Guid attemptId, CancellationToken token, List<AnswerItem>? submittedAnswers = null);
    Task<IResult> GetResult(Guid attemptId, CancellationToken token);
    Task<IResult> GetAttemptList(int page, int pageSize, string? status, Guid? examId, CancellationToken token);
    Task<IResult> GetAllAttempts(int page, int pageSize, string? status, Guid? examId, CancellationToken token);
    Task<IResult> GetLatestPlacement(CancellationToken token);
    Task<IResult> GetPlacementCompletionStatus(CancellationToken token);
    Task<IResult> GetNavigator(Guid attemptId, CancellationToken token);
    Task<IResult> ToggleFlag(Guid attemptId, Guid questionId, CancellationToken token);
}

public class AttemptService(
    AttemptDbContext context,
    IExamGateway gateway,
    IUserContext user,
    IAnswerKeyBuilder answerKeyBuilder,
    IIndexBuilder indexBuilder,
    IAnswerValidator answerValidator,
    IPlacementWorkflow placementWorkflow,
    IPublishEndpoint publishEndpoint,
IQuestionGraderFactory questionGraderFactory
) : IAttemptService
{
    public async Task<IResult> StartAttempt(
        AttemptStartRequest request,
        CancellationToken token
    )
    {
        var userId = user.UserId;
        // using GRPC for internal communication
        var existedStartedAttempt = await context.Attempts.AsNoTracking().Where(attempt =>
            attempt.ExamId == request.ExamId
            && attempt.Status == AttemptStatus.Started
            && attempt.UserId == userId).FirstOrDefaultAsync(token);
        if (existedStartedAttempt != null)
        {
            if (existedStartedAttempt.PaperJson is null)
                return Results.BadRequest(
                    new ApiResultDto(false, "Stored snapshot is empty", null!)
                );
            try
            {
                var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
                var parsed =
                    parser.Parse<InternalDeliveryExam>(existedStartedAttempt.PaperJson.RootElement.GetRawText());
                var safeJson = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(parsed!));
                var safeEl = JsonDocument.Parse(safeJson!).RootElement.Clone();
                var deadline = existedStartedAttempt.StartedAt.AddSeconds(existedStartedAttempt.DurationSec);
                var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                    new AttemptStartResponse(
                        existedStartedAttempt.Id,
                        safeEl,
                        existedStartedAttempt.StartedAt,
                        existedStartedAttempt.DurationSec,
                        timeLeft
                        )
                ));
            }
            catch
            {
                try
                {
                    var dto = existedStartedAttempt.PaperJson.RootElement
                        .Deserialize<InternalExamDto.InternalDeliveryExam>(new JsonSerializerOptions
                        { PropertyNameCaseInsensitive = true });
                    if (dto == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));
                    using var sanitized =
                        JsonSerializer.SerializeToDocument(dto, new JsonSerializerOptions(JsonSerializerDefaults.Web));
                    var safeEl = sanitized.RootElement.Clone();

                    //time left
                    var deadline = existedStartedAttempt.StartedAt.AddSeconds(existedStartedAttempt.DurationSec);
                    var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        new AttemptStartResponse(
                            existedStartedAttempt.Id,
                            safeEl,
                            existedStartedAttempt.StartedAt,
                            existedStartedAttempt.DurationSec,
                            timeLeft
                            )
                    ));
                }
                catch
                {
                    return Results.Ok(new ApiResultDto(true, "Continue your previous attempt",
                        existedStartedAttempt.PaperJson.RootElement.Clone()));
                }
            }
        }

        var snapShot = await gateway.GetExamSnapshotAsync(request.ExamId, token);
        var json = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(snapShot));
        using var doc = JsonDocument.Parse(json!);
        var safeElement = doc.RootElement.Clone();
        var attempt = new Domain.Entities.Attempt
        {
            UserId = userId,
            ExamId = request.ExamId,
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow,
            DurationSec = snapShot.DurationMin * 60,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(snapShot)!)
        };
        context.Attempts.Add(attempt);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(
            true, "Success",
            new AttemptStartResponse(attempt.Id, safeElement,
                attempt.StartedAt,
                attempt.DurationSec,
                (int)Math.Max(0, (attempt.StartedAt.AddSeconds(attempt.DurationSec) - DateTime.UtcNow).TotalSeconds)
            )));
    }
    public async Task<IResult> GetPreviousTurn(Guid examId, CancellationToken token)
    {
        var userId = user.UserId;
        var previousTurn = await context.Attempts.AsNoTracking()
                            .Where(k => k.UserId == userId && k.ExamId == examId
                            && (k.Status == AttemptStatus.Started || k.Status == AttemptStatus.InProgress)
                            ).Select(k => new { attemptId = k.Id, k.CreatedAt, k.Status }).FirstOrDefaultAsync(token);
        if (previousTurn == null)
            return Results.NotFound();
        return Results.Ok(new ApiResultDto(true, "Continue your previous", previousTurn));
    }
    public async Task<IResult> GetAttemptById(
        Guid attemptId,
        CancellationToken token)
    {
        var userId = user.UserId;

        var attempts = await context.Attempts.AsNoTracking()
            .Where(x => x.Id == attemptId && x.UserId == userId)
            .FirstOrDefaultAsync(token);
        // validate attempt
        if (attempts == null)
            return Results.NotFound(new ApiResultDto(false, "Not found", null!));
        if (attempts.PaperJson is null)
            return Results.NotFound(new ApiResultDto(false, "Not found snapshot", null!));
        try
        {
            // Parse snapshot đã lưu -> sanitize -> serialize lại thành JsonDocument
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            var parsed = parser.Parse<InternalDeliveryExam>(attempts.PaperJson.RootElement.GetRawText());
            var jsonFormatted = JsonFormatter.Default!.Format(GrpcSnapshotSanitizer.Sanitize(parsed!));
            using var doc = JsonDocument.Parse(jsonFormatted!);
            var safeEl = doc.RootElement.Clone();

            var answer = await context.AttemptAnswers.AsNoTracking()
                .Where(x => x.AttemptId == attempts.Id)
                .Select(x => new AnswerItem(x.QuestionId, x.SectionId, x.SelectedOptionIds, x.TextAnswer))
                .ToListAsync(token);
            var deadline = attempts.StartedAt.AddSeconds(attempts.DurationSec);
            var timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
            return Results.Ok(new ApiResultDto(true, "Success", new AttemptGetResponse(
                attempts.Id,
                attempts.Status,
                safeEl,
                answer,
                attempts.StartedAt,
                timeLeftSec
            )));
        }
        catch
        {
            try
            {
                var dto = attempts.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                );
                if (dto == null) return Results.NotFound(new ApiResultDto(false, "NOt found snapshot", null!));
                var sanitized = InternalExamDto.SnapshotSanitizer.Sanitize(dto);
                using var doc = JsonSerializer.SerializeToDocument(sanitized);
                var safeEl = doc.RootElement.Clone();
                var answer = await context.AttemptAnswers.AsNoTracking()
                    .Where(x => x.AttemptId == attempts.Id)
                    .Select(x => new AnswerItem(
                        x.QuestionId,
                        x.SectionId,
                        x.SelectedOptionIds,
                        x.TextAnswer
                    )).ToListAsync(token);
                var deadline = attempts.StartedAt.AddSeconds(attempts.DurationSec);
                var timeLeft = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
                return Results.Ok(new ApiResultDto(true, "Success", new
                    AttemptGetResponse(attempts.Id, attempts.Status, safeEl, answer, attempts.StartedAt, timeLeft)
                ));
            }
            catch (Exception e)
            {
                return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
            }
        }
    }

    public async Task<IResult> Autosave(
        Guid attemptId,
        AutosaveRequest req,
        CancellationToken token)
    {
        var userId = user.UserId;
        var attempt = await context.Attempts.FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId,
            cancellationToken: token);
        if (attempt == null)
            return Results.NotFound(new ApiResultDto(false, "Not found existed attempt", null!));
        var deadline = attempt.StartedAt.AddSeconds(attempt.DurationSec);
        var timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        if (timeLeftSec <= 0)
        {
            if (attempt.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                attempt.Status = AttemptStatus.Expired;
                await context.SaveChangesAsync(token);
            }

            return Results.Conflict(new ApiResultDto(false, "Expired", null!));
        }

        if (attempt.Status is AttemptStatus.Submitted or AttemptStatus.Graded)
            return Results.Conflict(new ApiResultDto(false, "Attempt is already submitted", null!));
        if (attempt.PaperJson is null)
            return Results.Problem("Snapshot missing", statusCode: StatusCodes.Status500InternalServerError);

        //parse ra dto tiện cho việc autosave 
        Dictionary<Guid, QMeta> index;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            var proto = parser.Parse<InternalDeliveryExam>(attempt.PaperJson.RootElement.GetRawText()) ??
                        new InternalDeliveryExam();
            index = indexBuilder.BuildIndexFromProto(proto);
        }
        catch
        {
            var dto = attempt.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (dto == null)
                return Results.Problem("Bad snapshot scheme", statusCode: StatusCodes.Status500InternalServerError);
            index = indexBuilder.BuildIndexFromDto(dto);
        }

        // lay incoming answer
        var incoming = req.Answers ?? new List<AnswerItem>();
        if (incoming.Count == 0)
            return Results.Ok(new ApiResultDto(true, "No changes", null!));
        var rejected = new List<string>();
        // validate incoming answer, check loi
        if (index.Count == 0)
            return Results.Problem("Snapshot index is empty", statusCode: StatusCodes.Status500InternalServerError);
        foreach (var ans in incoming)
        {
            var err = answerValidator.Validate(ans, index);
            if (err != null) rejected.Add(err);
        }

        if (rejected.Count > 0)
            return Results.UnprocessableEntity(new ApiResultDto(false, "Invalid payload", rejected));

        // lay list question id cua incoming answer
        var incomingQuestionIds = incoming.Select(x => x.QuestionId).Distinct().ToHashSet();
        // lay thong tin nhung answer da co trong db
        var existedAnswer = await context.AttemptAnswers
            .Where(x => x.AttemptId == attemptId && incomingQuestionIds.Contains(x.QuestionId))
            .ToDictionaryAsync(x => x.QuestionId, token);
        var saved = 0;
        var skipped = 0;
        foreach (var eachIncomingAnswer in incoming)
        {
            // neu chua co trong db, them moi
            var meta = index[eachIncomingAnswer.QuestionId];
            if (!existedAnswer.TryGetValue(eachIncomingAnswer.QuestionId,
                    out var eachExistedAnswer))
            {
                eachExistedAnswer = new AttemptAnswer
                {
                    AttemptId = attemptId,
                    SectionId = meta.SectionId,
                    QuestionId = eachIncomingAnswer.QuestionId
                };
                context.AttemptAnswers.Add(eachExistedAnswer);
                existedAnswer[eachIncomingAnswer.QuestionId] = eachExistedAnswer;
            }

            var changed = false;
            if (eachIncomingAnswer.SelectedOptionIds is not null)
            {
                var newList = eachIncomingAnswer.SelectedOptionIds.Count == 0
                    ? new List<Guid>()
                    : eachIncomingAnswer.SelectedOptionIds.Distinct().OrderBy(x => x).ToList();
                var oldList = (eachExistedAnswer.SelectedOptionIds
                               ?? new List<Guid>()).OrderBy(x => x).ToList();
                if (!oldList.SequenceEqual(newList))
                {
                    eachExistedAnswer.SelectedOptionIds = newList;
                    changed = true;
                }
            }

            if (eachIncomingAnswer.TextAnswer is not null)
            {
                if (!string.Equals(eachExistedAnswer.TextAnswer, eachIncomingAnswer.TextAnswer,
                        StringComparison.Ordinal))
                {
                    eachExistedAnswer.TextAnswer = eachIncomingAnswer.TextAnswer;
                    changed = true;
                }
            }

            if (changed)
            {
                eachExistedAnswer.IsCorrect = null!;
                eachExistedAnswer.AwardedPoints = null!;
                eachExistedAnswer.SectionId = meta.SectionId;
                saved++;
            }
            else
            {
                skipped++;
            }
        }

        if (attempt.Status is AttemptStatus.Started)
            attempt.Status = AttemptStatus.InProgress;
        attempt.UpdatedAt = DateTime.UtcNow;
        await context.SaveChangesAsync(token);
        timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        return Results.Ok(new ApiResultDto(true, "Autosaved", new
        {
            savedItem = saved,
            skippedItem = skipped,
            rejected,
            timeLeftSec,
            updateAt = attempt.UpdatedAt
        }));

    }

    public async Task<IResult> Submit(Guid attemptId, CancellationToken token, List<AnswerItem>? submittedAnswers = null)
    {
        var userId = user.UserId;
        var existedAttempt =
            await context.Attempts.Include(a => a.Answers).FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId, token);
        if (existedAttempt == null)
            return Results.NotFound(new ApiResultDto(false, "Not found existed attempt", null!));
        if (existedAttempt.PaperJson is null)
            return Results.Problem("Snapshot is missing", statusCode: StatusCodes.Status500InternalServerError);
        var deadline = existedAttempt.StartedAt.AddSeconds(existedAttempt.DurationSec);

        // Defensive fallback: if the FE sent answers inline in the submit body
        // (because the autosave debounce hadn't fired yet, for example), persist
        // them now so the grader has the user's actual selections.
        if (submittedAnswers is { Count: > 0 })
        {
            Dictionary<Guid, QMeta>? submitIndex = null;
            foreach (var ans in submittedAnswers)
            {
                if (ans.QuestionId == Guid.Empty) continue;
                if (submitIndex is null)
                {
                    submitIndex = indexBuilder.BuildIndexFromProto(
                        new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!)
                            .Parse<InternalDeliveryExam>(existedAttempt.PaperJson.RootElement.GetRawText()));
                }
                var sectionId = ans.SectionId ?? Guid.Empty;
                if (sectionId == Guid.Empty && submitIndex.TryGetValue(ans.QuestionId, out var m))
                    sectionId = m.SectionId;
                var existing = existedAttempt.Answers.FirstOrDefault(a => a.QuestionId == ans.QuestionId);
                if (existing is null)
                {
                    existedAttempt.Answers.Add(new AttemptAnswer
                    {
                        AttemptId = attemptId,
                        QuestionId = ans.QuestionId,
                        SectionId = sectionId,
                        SelectedOptionIds = ans.SelectedOptionIds,
                        TextAnswer = ans.TextAnswer,
                    });
                }
                else
                {
                    if (ans.SelectedOptionIds is not null)
                        existing.SelectedOptionIds = ans.SelectedOptionIds;
                    if (ans.TextAnswer is not null)
                        existing.TextAnswer = ans.TextAnswer;
                }
            }
        }
        var timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
        var isExpired = timeLeftSec <= 0;
        

        if (existedAttempt.Status is AttemptStatus.Submitted or AttemptStatus.Graded)
        {
            return Results.Ok(new ApiResultDto(true, "Already submitted", new
            {
                attemptId = existedAttempt.Id,
                status = existedAttempt.Status,
                finishedAt = existedAttempt.SubmittedAt
            }));
        }

        InternalDeliveryExam? proto = null;
        InternalExamDto.InternalDeliveryExam? dto = null;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            proto = parser.Parse<InternalDeliveryExam>(existedAttempt.PaperJson.RootElement.GetRawText());

        }
        catch
        {
            dto = existedAttempt.PaperJson.RootElement
                .Deserialize<InternalExamDto.InternalDeliveryExam>(
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (dto is null)
                return Results.Problem("Bad snapshot",
                    statusCode: StatusCodes.Status500InternalServerError);
        }

        Dictionary<Guid, QMeta> index;
        AnswerKeyCompiled compiled;
        if (proto is not null)
        {
            index = indexBuilder.BuildIndexFromProto(proto);
            compiled = answerKeyBuilder.FromProto(proto);
        }
        else
        {
            index = indexBuilder.BuildIndexFromDto(dto!);
            compiled = answerKeyBuilder.FromDto(dto!);
        }

        if (index.Count == 0 || compiled.Keys.Count == 0)
            return Results.Problem("Snapshot index/keys empty",
                statusCode: StatusCodes.Status500InternalServerError);
        await using var transaction = await context.Database.BeginTransactionAsync(token);
        try
        {
            // Use the navigation collection (existedAttempt.Answers) instead of
            // re-fetching from the DB: the inline-submit path above adds new
            // AttemptAnswers here in-memory, and they aren't in the DB until
            // SaveChangesAsync runs at the bottom of this transaction. A fresh
            // `.ToListAsync()` would skip them and the "ensure all questions
            // have an answer" loop below would insert blank rows over the top
            // of the user's submission.
            var answers = existedAttempt.Answers.ToList();
            decimal awardedTotal = 0m;
            int correctCount = 0;
            int manualCount = 0;
            foreach (var ans in answers)
            {
                if (!index.TryGetValue(ans.QuestionId, out var meta)) continue;
                if (!compiled.Keys.TryGetValue(ans.QuestionId, out var key)) continue;
                IQuestionGrader grader;
                try
                {
                    grader = questionGraderFactory.Resolve(meta.Type);
                }
                catch (Exception e)
                {
                    throw new Exception(e.Message);
                }
                var result = grader.Grade(ans, key);
                ans.AwardedPoints = result.AwardedPoints;
                ans.IsCorrect = result.IsCorrect;
                if (result.NeedsManualReview) manualCount++;
                awardedTotal += result.AwardedPoints;
                if (result.IsCorrect ?? false) correctCount++;
            }

            var answeredIds = answers.Select(x => x.QuestionId).ToHashSet();
            foreach (var questionId in compiled.Keys.Keys)
                if (!answeredIds.Contains(questionId))
                    context.AttemptAnswers.Add(new AttemptAnswer
                    {
                        AttemptId = attemptId,
                        QuestionId = questionId,
                        SectionId = index[questionId].SectionId,
                        AwardedPoints = 0,

                        IsCorrect = false
                    });
            existedAttempt.Status = (manualCount == 0) ? AttemptStatus.Graded : AttemptStatus.Submitted;
            existedAttempt.SubmittedAt = DateTime.UtcNow;
            existedAttempt.GradedAt = (manualCount == 0) ? DateTime.UtcNow : existedAttempt.GradedAt;
            existedAttempt.RawScore = awardedTotal;
            existedAttempt.ScaledScore = compiled.TotalPoints <= 0
                ? 0m
                : Math.Round((awardedTotal / compiled.TotalPoints) * 100m, 2);

            var examCategory = proto?.Category ?? dto?.Category ?? "";
            var isPlacement = string.Equals(examCategory, ExamCategory.PLACEMENT, StringComparison.OrdinalIgnoreCase);
            var skillByQuestion = new Dictionary<Guid, string>();
            Guid? writingQid = null;
            string? writingTask = null;
            Guid? speakingQid = null;
            string? speakingTask = null;
            if (proto != null)
            {
                foreach (var section in proto.Sections ?? new RepeatedField<InternalDeliverySection>())
                    foreach (var question in section.QuestionGroups.SelectMany(g => g.Questions))
                    {
                        var qid = Guid.Parse(question.Id);
                        skillByQuestion[qid] = question.Skill ?? "";
                        if (writingQid == null && string.Equals(question.Skill,
                        QuestionSkill.Writing, StringComparison.OrdinalIgnoreCase))
                        {
                            writingQid = qid;
                            writingTask = !string.IsNullOrWhiteSpace(question.PromptMd) ? question.PromptMd
                                : question.ExplanationMd ?? section.InstructionsMd ?? string.Empty;
                        }
                        if (speakingQid == null && string.Equals(question.Skill, QuestionSkill.Speaking,
                            StringComparison.OrdinalIgnoreCase))
                        {
                            speakingQid = qid;
                            speakingTask = !string.IsNullOrWhiteSpace(question.PromptMd) ? question.PromptMd
                                    : question.ExplanationMd ?? section.InstructionsMd ?? string.Empty;
                        }
                    }

            }
            else if (dto != null)
            {
                foreach (var section in dto.Sections ?? Array.Empty<InternalExamDto.InternalDeliverySection>())
                    foreach (var question in section.QuestionGroups.SelectMany(g => g.Questions))
                    {
                        var qid = question.Id;
                        skillByQuestion[question.Id] = question.Skill ?? "";
                        if (writingQid == null && string.Equals(question.Skill,
                        QuestionSkill.Writing, StringComparison.OrdinalIgnoreCase))
                        {
                            writingQid = qid;
                            writingTask = !string.IsNullOrWhiteSpace(question.PromptMd) ? question.PromptMd
                                : question.ExplanationMd ?? section.InstructionsMd ?? string.Empty;
                        }
                        if (speakingQid == null && string.Equals(question.Skill, QuestionSkill.Speaking,
                          StringComparison.OrdinalIgnoreCase))
                        {
                            speakingQid = qid;
                            speakingTask = !string.IsNullOrWhiteSpace(question.PromptMd) ? question.PromptMd
                                    : question.ExplanationMd ?? section.InstructionsMd ?? string.Empty;
                        }
                    }

            }
            int CountCorrect(string skill) => existedAttempt.Answers.Count(a => a.IsCorrect == true
                && skillByQuestion.TryGetValue(a.QuestionId, out var sk)
                && string.Equals(skill, sk, StringComparison.OrdinalIgnoreCase)
            );
            string? writingAnswer = null;
            if (writingQid.HasValue)
            {
                writingAnswer = existedAttempt.Answers
                    .Where(a => a.QuestionId == writingQid.Value)
                    .Select(a => a.TextAnswer)
                    .FirstOrDefault();
            }

            string? speakingAnswerJson = null;
            if (speakingQid.HasValue)
            {
                speakingAnswerJson = existedAttempt.Answers
                    .Where(a => a.QuestionId == speakingQid.Value)
                    .Select(a => a.TextAnswer)
                    .FirstOrDefault();
            }

            var readingCorrect = CountCorrect(QuestionSkill.Reading);
            var listeningCorrect = CountCorrect(QuestionSkill.Listening);
            var totalReading = skillByQuestion.Count(k => k.Value.Equals(QuestionSkill.Reading, StringComparison.OrdinalIgnoreCase));
            var totalListening = skillByQuestion.Count(k => k.Value.Equals(QuestionSkill.Listening, StringComparison.OrdinalIgnoreCase));

            if (isPlacement)
            {
                await placementWorkflow.OnPlacementSubmittedAsync(
                    existedAttempt.Id,
                    writingQid, writingTask,
                    writingAnswer, speakingQid,
                    speakingTask, speakingAnswerJson, listeningCorrect,
                    totalListening, readingCorrect, totalReading, token);
            }

            await context.SaveChangesAsync(token);
            await transaction.CommitAsync(token);
            deadline = existedAttempt.StartedAt.AddSeconds(existedAttempt.DurationSec);
            timeLeftSec = (int)Math.Max(0, (deadline - DateTime.UtcNow).TotalSeconds);
            var timeUsedSec = (int)(existedAttempt.SubmittedAt!.Value - existedAttempt.StartedAt).TotalSeconds;



            var message = isExpired ? "Auto-submitted (time expired)" : "Submitted";
            
            // Publish gamification event
            await publishEndpoint.Publish(new AttemptCompletedEvent(
                userId,
                existedAttempt.Id,
                "READING", // Default skill for now
                correctCount
            ), token);
            
            return Results.Ok(new ApiResultDto(true, message, new
            {
                attemptId = existedAttempt.Id,
                status = existedAttempt.Status,
                finishedAt = existedAttempt.SubmittedAt,
                timeUsedSec,
                timeLeftSec,
                awardedTotal,
                correctCount,
                totalPoints = compiled.TotalPoints,
                needsManualReview = manualCount,
                isExpired
            }));

        }
        catch (Exception e)
        {
            await transaction.RollbackAsync(token);
            return Results.Problem($"Errors while grading: {e.Message}", statusCode: 500);
        }
    }

    public async Task<IResult> GetResult(Guid attemptId, CancellationToken token)
    {
        var userId = user.UserId;

        var existedAttempt = await context.Attempts.AsNoTracking()
            .Include(attempt => attempt.Answers)
            .FirstOrDefaultAsync(attempt => attempt.Id == attemptId && attempt.UserId == userId, token);
        if (existedAttempt == null)
            return Results.NotFound(new ApiResultDto(false, "Not found", null!));
        if (existedAttempt.PaperJson is null)
            return Results.NotFound(new ApiResultDto(false, "Snapshot is missing", null!));
        if (existedAttempt.Status is not (AttemptStatus.Submitted or AttemptStatus.Graded))
            return Results.Conflict(new ApiResultDto(false, "Attempt not submitted", null!));

        InternalDeliveryExam? proto = null;
        InternalExamDto.InternalDeliveryExam? dto = null;
        JsonElement fullSnapshot;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            proto = parser.Parse<InternalDeliveryExam>(existedAttempt.PaperJson.RootElement.GetRawText());
            var fullJson = JsonFormatter.Default!.Format(proto!);
            using var fullDoc = JsonDocument.Parse(fullJson!);
            fullSnapshot = fullDoc.RootElement.Clone();
        }
        catch
        {
            dto = existedAttempt.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (dto == null)
                return Results.Problem("Snapshot is bad", statusCode: StatusCodes.Status500InternalServerError);
            using var fullDoc = JsonSerializer.SerializeToDocument(dto);
            fullSnapshot = fullDoc.RootElement.Clone();
        }

        // build lại theo question id và thông tin trong snapshot 
        var compiled = proto is not null
            ? answerKeyBuilder.FromProto(proto)
            : answerKeyBuilder.FromDto(dto!);

        // Build per-question index (with option content) for rendering selected answer texts
        var index = proto is not null
            ? indexBuilder.BuildIndexFromProto(proto)
            : indexBuilder.BuildIndexFromDto(dto!);

        // Build skill map cho từng câu hỏi (READING/LISTENING/WRITING/...)
        var skillByQuestion = new Dictionary<Guid, string>();
        // Build Idx map for ordering answers
        var questionIdxMap = new Dictionary<Guid, int>();

        if (proto is not null)
        {
            foreach (var section in proto.Sections ?? new RepeatedField<InternalDeliverySection>())
            {
                foreach (var question in section.QuestionGroups.SelectMany(g => g.Questions))
                {
                    var qid = Guid.Parse(question.Id);
                    skillByQuestion[qid] = question.Skill ?? "";
                    questionIdxMap[qid] = question.Idx;
                }
            }
        }
        else if (dto is not null)
        {
            foreach (var section in dto.Sections ?? Array.Empty<InternalExamDto.InternalDeliverySection>())
            {
                foreach (var question in section.QuestionGroups.SelectMany(g => g.Questions))
                {
                    skillByQuestion[question.Id] = question.Skill ?? "";
                    questionIdxMap[question.Id] = question.Idx;
                }
            }
        }


        var awardedPoints = existedAttempt.Answers.Sum(x => x.AwardedPoints ?? 0);
        int correctCount = existedAttempt.Answers.Count(x => x.IsCorrect == true);
        var totalScore = compiled.TotalPoints;
        int totalQuestion = compiled.Keys.Count;
        var totalTime = existedAttempt.SubmittedAt - existedAttempt.StartedAt;

        // sẽ set sau tuỳ loại đề (placement / non-placement)
        decimal? ieltsBand = null;

        string examCategory = proto?.Category ?? dto?.Category ?? "";
        bool isPlacement = string.Equals(examCategory, ExamCategory.PLACEMENT, StringComparison.OrdinalIgnoreCase);


        PlacementResult? placementResult;
        string? placementLevel = null;
        decimal? placementBand = null;
        int? listeningCorrect = null;
        int? readingCorrect = null;
        decimal? writingBand = null;
        decimal? speakingBand = null;
        WritingGradeDto? writingGrade = null;
        SpeakingGradeDto? speakingGrade = null;
        if (isPlacement)
        {
            placementResult = await context.PlacementResults.AsNoTracking()
                .Where(x => x.AttemptId == attemptId)
                .OrderByDescending(x => x.CreatedAt)
                .FirstOrDefaultAsync(token);

            if (placementResult == null)
                return Results.NotFound(new ApiResultDto(false, "Latest placement result not found", null!));
            placementLevel = placementResult.Level;
            placementBand = placementResult.Band;
            listeningCorrect = placementResult.ListeningCorrect;
            readingCorrect = placementResult.ReadingCorrect;
            writingBand = placementResult.WritingBand;
            speakingBand = placementResult.SpeakingBand;
            correctCount = placementResult.TotalCorrect;
            totalQuestion = placementResult.ReadingTotal + placementResult.ListeningTotal;

            ieltsBand = placementBand;
            
            // Deserialize grade JSONs to typed DTOs
            if (!string.IsNullOrEmpty(placementResult.WritingGradeJson))
            {
                try
                {
                    writingGrade = System.Text.Json.JsonSerializer.Deserialize<WritingGradeDto>(
                        placementResult.WritingGradeJson,
                        new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                }
                catch { /* ignore parse errors */ }
            }
            if (!string.IsNullOrEmpty(placementResult.SpeakingGradeJson))
            {
                try
                {
                    speakingGrade = System.Text.Json.JsonSerializer.Deserialize<SpeakingGradeDto>(
                        placementResult.SpeakingGradeJson,
                        new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                }
                catch { /* ignore parse errors */ }
            }
        }
        else
        {
            // Non-placement: tính band theo READING-only hoặc LISTENING-only
            int readingCorrectOnly = existedAttempt.Answers.Count(a =>
                a.IsCorrect == true &&
                skillByQuestion.TryGetValue(a.QuestionId, out var sk) &&
                string.Equals(sk, QuestionSkill.Reading, StringComparison.OrdinalIgnoreCase));

            int totalReadingOnly = skillByQuestion.Count(k =>
                string.Equals(k.Value, QuestionSkill.Reading, StringComparison.OrdinalIgnoreCase));

            int listeningCorrectOnly = existedAttempt.Answers.Count(a =>
                a.IsCorrect == true &&
                skillByQuestion.TryGetValue(a.QuestionId, out var sk) &&
                string.Equals(sk, QuestionSkill.Listening, StringComparison.OrdinalIgnoreCase));

            int totalListeningOnly = skillByQuestion.Count(k =>
                string.Equals(k.Value, QuestionSkill.Listening, StringComparison.OrdinalIgnoreCase));

            if (totalReadingOnly > 0)
            {
                ieltsBand = IeltsBandConverter.FromAcademicReadingScaled(readingCorrectOnly, totalReadingOnly);
            }
            else if (totalListeningOnly > 0)
            {
                ieltsBand = IeltsBandConverter.FromAcademicListeningScaled(listeningCorrectOnly, totalListeningOnly);
            }
            else
            {
                ieltsBand = 0m;
            }
        }



        // Use stored ScaledScore if available; otherwise compute percentage (0..100)
        var scorePct = existedAttempt.ScaledScore ??
                       (totalScore <= 0 ? 0m : Math.Round((awardedPoints / totalScore) * 100m, 2));

        static bool IsNotBlank(string? s) => !string.IsNullOrWhiteSpace(s);

        // For matching questions, resolve a grading value (e.g. "viii") to the
        // full option content (e.g. "viii. The Spread of Coffee") so the
        // selectedText and correctText columns display in the same format.
        static string? ResolveMatchingText(string? value, QMeta? meta)
        {
            if (meta is null || string.IsNullOrWhiteSpace(value)) return null;
            var text = value.Trim();
            return meta.OptionIds
                .Select(o => o.content)
                .FirstOrDefault(c =>
                    !string.IsNullOrEmpty(c) &&
                    (c.StartsWith(text + ".", StringComparison.OrdinalIgnoreCase) ||
                     c.StartsWith(text + " ", StringComparison.OrdinalIgnoreCase) ||
                     c.Equals(text, StringComparison.OrdinalIgnoreCase)));
        }

        string? BuildCorrectText(Guid questionId)
        {
            if (!compiled.Keys.TryGetValue(questionId, out var key)) return null;
            index.TryGetValue(questionId, out var qMeta);
            if (key.CorrectOptionIds is { Count: > 0 })
            {
                var texts = key.CorrectOptionIds.Select(t => t.content)
                    .Where(IsNotBlank)
                    .ToList();
                if (texts.Count > 0) return string.Join(", ", texts);
            }

            if (key.BlankAcceptTexts is { Count: > 0 } || key.BlankAcceptRegex is { Count: > 0 })
            {
                var blanks = new List<string>();
                var blankIds = (key.BlankAcceptTexts?.Keys ?? Enumerable.Empty<string>())
                    .Union(key.BlankAcceptRegex?.Keys ?? Enumerable.Empty<string>(), StringComparer.OrdinalIgnoreCase);
                foreach (var blankId in blankIds)
                {
                    string[]? acceptTexts = null;
                    string[]? acceptRegex = null;
                    if (key.BlankAcceptTexts != null)
                        key.BlankAcceptTexts.TryGetValue(blankId, out acceptTexts);
                    if (key.BlankAcceptRegex != null)
                        key.BlankAcceptRegex.TryGetValue(blankId, out acceptRegex);
                    var parts = new List<string>();
                    if (acceptTexts is { Length: > 0 }) parts.AddRange(acceptTexts.Where(IsNotBlank));
                    if (acceptRegex is { Length: > 0 })
                        parts.AddRange(acceptRegex.Where(IsNotBlank).Select(r => $"/{r}/"));
                    if (parts.Count > 0) blanks.Add($"{blankId}: {string.Join(" | ", parts)}");
                }

                if (blanks.Count > 0) return string.Join("; ", blanks);
            }

            if (key.MatchPairs is { Count: > 0 })
            {
                // MATCHING_HEADING: render each pair's accepted value as the full
                // option content so it matches the user's selected answer format.
                // Convention: pair.Value[0] = grading key, pair.Value[1..] = display
                // text. The display text is the last non-empty entry; if absent we
                // fall back to looking up the option content via the question index.
                var resolved = new List<string>();
                foreach (var (_, values) in key.MatchPairs)
                {
                    if (values is not { Length: > 0 }) continue;
                    var display = values.Where(IsNotBlank).LastOrDefault();
                    if (display is null) continue;
                    if (qMeta is not null)
                    {
                        var resolved2 = ResolveMatchingText(display, qMeta);
                        if (resolved2 is not null) display = resolved2;
                    }
                    resolved.Add(display);
                }
                if (resolved.Count > 0) return string.Join("; ",
                    resolved.Distinct(StringComparer.OrdinalIgnoreCase));
            }

            if (key.OrderCorrects is { Count: > 0 })
            {
                var seq = key.OrderCorrects.Where(IsNotBlank).ToList();
                if (seq.Count > 0) return string.Join(" -> ", seq);
            }

            if (key.ShortAnswerAcceptTexts is { Count: > 0 })
            {
                var texts = key.ShortAnswerAcceptTexts.Where(IsNotBlank).ToList();
                if (texts.Count > 0) return string.Join(" / ", texts);
            }

            if (key.ShortAnswerAcceptRegex is { Count: > 0 })
            {
                var texts = key.ShortAnswerAcceptRegex.Where(IsNotBlank).Select(r => $"/{r}/").ToList();
                if (texts.Count > 0) return string.Join(" / ", texts);
            }

            return null;
        }

        return Results.Ok(new ApiResultDto(true, "Success",
                new AttemptResultResponse(
                    attemptId,
                    existedAttempt.Status,
                    existedAttempt.SubmittedAt,
                    totalTime,
                    existedAttempt.GradedAt,
                    existedAttempt.RawScore ?? 0m,
                    scorePct,
                    correctCount,
                    totalQuestion,
                    fullSnapshot,
                    existedAttempt.Answers.Select(x =>
                    {
                        string? selectedText;
                        var correctText = BuildCorrectText(x.QuestionId);

                        if (x.SelectedOptionIds is { Count: > 0 } && index.TryGetValue(x.QuestionId, out var meta))
                        {
                            var lookup = meta.OptionIds.ToDictionary(t => t.id, t => t.content);
                            var selectedTexts = x.SelectedOptionIds
                                .Where(id => lookup.ContainsKey(id))
                                .Select(id => lookup[id])
                                .Where(IsNotBlank)
                                .ToList();
                            selectedText = selectedTexts.Count > 0 ? string.Join(", ", selectedTexts) : null;
                        }
                        else if (IsNotBlank(x.TextAnswer) && index.TryGetValue(x.QuestionId, out var questionMeta))
                        {
                            // For MATCHING_HEADING the user picks a roman ("viii")
                            // from the dropdown. Resolve it to the full option text
                            // so selectedText and correctText display in the same
                            // format ("viii. The Spread of Coffee").
                            var textAnswer = x.TextAnswer!.Trim();
                            selectedText = ResolveMatchingText(textAnswer, questionMeta) ?? textAnswer;
                        }
                        else
                        {
                            selectedText = IsNotBlank(x.TextAnswer) ? x.TextAnswer : null;
                        }

                        return new ResultAnswerItem(
                            x.QuestionId,
                            x.SectionId,
                            questionIdxMap.TryGetValue(x.QuestionId, out var idx) ? idx : 0,
                            x.SelectedOptionIds,
                            x.TextAnswer,
                            x.IsCorrect,
                            selectedText,
                            correctText
                        );
                    })
                    .OrderBy(a => a.Idx)
                    .ToList(),
                    ieltsBand ?? 0m,
                    placementLevel,
                    placementBand,
                    readingCorrect,
                    listeningCorrect,
                    writingBand,
                    speakingBand,
                    writingGrade,
                    speakingGrade
                    )
            )
        );
    }

    public async Task<IResult> GetAttemptList(int page, int pageSize, string? status, Guid? examId, CancellationToken token)
    {
        var userId = user.UserId;
        page = page <= 0 ? 1 : page;
        pageSize = pageSize <= 0 ? 10 : Math.Min(pageSize, 100);
        var listAttempt = context.Attempts.AsNoTracking()
            .Where(x => x.UserId == userId);
        listAttempt = ApplyFilters(listAttempt, status, examId, out var statusError);
        if (statusError != null)
            return statusError;

        return await BuildAttemptListResponse(listAttempt, page, pageSize, token, "Success");
    }

    public async Task<IResult> GetAllAttempts(int page, int pageSize, string? status, Guid? examId, CancellationToken token)
    {
        page = page <= 0 ? 1 : page;
        pageSize = pageSize <= 0 ? 10 : Math.Min(pageSize, 100);
        var listAttempt = context.Attempts.AsNoTracking();
        listAttempt = ApplyFilters(listAttempt, status, examId, out var statusError);
        if (statusError != null)
            return statusError;

        return await BuildAttemptListResponse(listAttempt, page, pageSize, token, "Fetched attempts");
    }

    private IQueryable<Domain.Entities.Attempt> ApplyFilters(
        IQueryable<Domain.Entities.Attempt> query,
        string? status,
        Guid? examId,
        out IResult? errorResult)
    {
        errorResult = null;
        if (!string.IsNullOrEmpty(status))
        {
            var s = status.Trim().ToUpperInvariant();
            var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                AttemptStatus.Started,
                AttemptStatus.InProgress,
                AttemptStatus.Submitted,
                AttemptStatus.Graded,
                AttemptStatus.Expired,
                AttemptStatus.Cancelled
            };
            if (!allowed.Contains(s))
            {
                errorResult = Results.BadRequest(new ApiResultDto(false, $"Invalid status '{status}'", null!));
                return query;
            }
            query = query.Where(x => x.Status == s);
        }

        if (examId.HasValue)
            query = query.Where(x => x.ExamId == examId.Value);

        return query;
    }

    private async Task<IResult> BuildAttemptListResponse(
        IQueryable<Domain.Entities.Attempt> query,
        int page,
        int pageSize,
        CancellationToken token,
        string successMessage)
    {
        var rows = await query.OrderByDescending(x => x.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new
            {
                x.Id,
                x.ExamId,
                x.Status,
                x.StartedAt,
                x.SubmittedAt,
                x.GradedAt,
                x.DurationSec,
                x.RawScore,
                x.ScaledScore,
                x.PaperJson
            })
            .ToListAsync(token);
        var now = DateTime.UtcNow;

        var items = rows.Select(x =>
        {
            int? timeLeft = null;
            if (x.Status is AttemptStatus.Started or AttemptStatus.InProgress)
            {
                var deadline = x.StartedAt.AddSeconds(x.DurationSec);
                timeLeft = (int)Math.Max(0, (deadline - now).TotalSeconds);
            }
            string? title = null;
            try
            {
                if (x.PaperJson != null && x.PaperJson.RootElement.TryGetProperty("title", out var t))
                    title = t.GetString();
            }
            catch { }
            return new AttemptListItem(x.Id, x.ExamId, x.Status, x.StartedAt, x.SubmittedAt, x.ScaledScore,
                x.ScaledScore.HasValue ? IeltsBandConverter.FromScaledPercent(x.ScaledScore.Value) : null, title);
        }).ToList();

        return Results.Ok(new ApiResultDto(true, successMessage, items));
    }

    public async Task<IResult> GetPlacementCompletionStatus(CancellationToken token)
    {
        var userId = user.UserId;
        var latestPlacement = await context.PlacementResults.AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(k => k.UpdatedAt)
            .Select(k => new
            {
                k.Id,
                k.UserId,
                k.ExamId,
                k.AttemptId,
                k.Level,
                k.Band,
                k.CreatedAt,
                k.UpdatedAt
            }).FirstOrDefaultAsync(token);

        if (latestPlacement != null)
        {
            var attempt = await context.Attempts.AsNoTracking()
                .Where(a => a.Id == latestPlacement.AttemptId)
                .Select(a => new
                {
                    a.Status,
                    a.StartedAt,
                    a.SubmittedAt,
                    a.GradedAt
                }).FirstOrDefaultAsync(token);

            var completed = attempt?.Status is AttemptStatus.Submitted or AttemptStatus.Graded || attempt == null;
            var response = new PlacementCompletionResponse(
                completed,
                latestPlacement.AttemptId,
                latestPlacement.ExamId,
                attempt?.Status,
                attempt?.StartedAt,
                attempt?.SubmittedAt,
                attempt?.GradedAt,
                latestPlacement.Level,
                latestPlacement.Band,
                latestPlacement.CreatedAt,
                latestPlacement.UpdatedAt);
            var message = completed ? "Placement test completed" : "Placement test not completed";
            return Results.Ok(new ApiResultDto(true, message, response));
        }

        var submittedAttempts = await context.Attempts.AsNoTracking()
            .Where(a => a.UserId == userId &&
                        (a.Status == AttemptStatus.Submitted || a.Status == AttemptStatus.Graded))
            .OrderByDescending(a => a.SubmittedAt ?? a.UpdatedAt)
            .Select(a => new
            {
                a.Id,
                a.ExamId,
                a.Status,
                a.StartedAt,
                a.SubmittedAt,
                a.GradedAt,
                a.PaperJson
            })
            .ToListAsync(token);

        foreach (var attempt in submittedAttempts)
        {
            var category = TryGetExamCategory(attempt.PaperJson);
            if (!string.Equals(category, ExamCategory.PLACEMENT, StringComparison.OrdinalIgnoreCase))
                continue;

            var response = new PlacementCompletionResponse(
                true,
                attempt.Id,
                attempt.ExamId,
                attempt.Status,
                attempt.StartedAt,
                attempt.SubmittedAt,
                attempt.GradedAt,
                null,
                null,
                attempt.SubmittedAt ?? attempt.StartedAt,
                attempt.GradedAt ?? attempt.SubmittedAt ?? attempt.StartedAt);
            return Results.Ok(new ApiResultDto(true, "Placement test completed", response));
        }

        return Results.Ok(new ApiResultDto(true, "Placement test not completed", null!));
    }

    public async Task<IResult> GetLatestPlacement(CancellationToken token)
    {
        var userId = user.UserId;
        var placementEntity = await context.PlacementResults.AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(k => k.UpdatedAt)
            .FirstOrDefaultAsync(token);
        
        if (placementEntity == null)
            return Results.NotFound(new ApiResultDto(false, "Not found any placement", null!));
        
        // Deserialize JSON grades to typed DTOs
        WritingGradeDto? writingGrade = null;
        SpeakingGradeDto? speakingGrade = null;
        
        if (!string.IsNullOrEmpty(placementEntity.WritingGradeJson))
        {
            try
            {
                writingGrade = System.Text.Json.JsonSerializer.Deserialize<WritingGradeDto>(
                    placementEntity.WritingGradeJson,
                    new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch { /* ignore parse errors */ }
        }
        
        if (!string.IsNullOrEmpty(placementEntity.SpeakingGradeJson))
        {
            try
            {
                speakingGrade = System.Text.Json.JsonSerializer.Deserialize<SpeakingGradeDto>(
                    placementEntity.SpeakingGradeJson,
                    new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch { /* ignore parse errors */ }
        }
        
        var placement = new PlacementResultResponse(
            placementEntity.Id,
            placementEntity.UserId,
            placementEntity.ExamId,
            placementEntity.AttemptId,
            placementEntity.ReadingCorrect,
            placementEntity.ReadingTotal,
            placementEntity.ListeningCorrect,
            placementEntity.ListeningTotal,
            placementEntity.WritingBand,
            placementEntity.SpeakingBand,
            placementEntity.TotalCorrect,
            placementEntity.Level,
            placementEntity.Band,
            placementEntity.CreatedAt,
            placementEntity.UpdatedAt,
            writingGrade,
            speakingGrade
        );
        
        return Results.Ok(new ApiResultDto(true, "Latest placement evaluation", placement));
    }

    public async Task<IResult> GetNavigator(Guid attemptId, CancellationToken token)
    {
        var userId = user.UserId;
        var attempt = await context.Attempts.AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == attemptId && x.UserId == userId, token);
        if (attempt == null)
            return Results.NotFound(new ApiResultDto(false, "Attempt not found", null!));

        // Parse PaperJson to get question IDs and indices
        var questionMeta = new List<(Guid QuestionId, int Idx)>();
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default.WithIgnoreUnknownFields(true));
            var proto = parser.Parse<InternalDeliveryExam>(attempt.PaperJson!.RootElement.GetRawText());
            foreach (var section in proto.Sections ?? new RepeatedField<InternalDeliverySection>())
            {
                foreach (var group in section.QuestionGroups ?? new RepeatedField<InternalDeliveryQuestionGroup>())
                {
                    foreach (var q in group.Questions ?? new RepeatedField<InternalDeliveryQuestion>())
                    {
                        questionMeta.Add((Guid.Parse(q.Id), (int)q.Idx));
                    }
                }
            }
        }
        catch
        {
            var dto = attempt.PaperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (dto != null)
            {
                foreach (var section in dto.Sections ?? Array.Empty<InternalExamDto.InternalDeliverySection>())
                {
                    foreach (var group in section.QuestionGroups ?? Array.Empty<InternalExamDto.InternalDeliveryQuestionGroup>())
                    {
                        foreach (var q in group.Questions ?? Array.Empty<InternalExamDto.InternalDeliveryQuestion>())
                        {
                            questionMeta.Add((q.Id, q.Idx));
                        }
                    }
                }
            }
        }

        if (questionMeta.Count == 0)
            return Results.Ok(new ApiResultDto(true, "No questions", new NavigatorResponse(0, 0, new List<NavigatorEntry>())));

        var questionIds = questionMeta.Select(q => q.QuestionId).ToList();

        // Get answered status from AttemptAnswers
        var answeredMap = await context.AttemptAnswers
            .Where(a => a.AttemptId == attemptId && questionIds.Contains(a.QuestionId))
            .ToDictionaryAsync(a => a.QuestionId, a =>
                (a.SelectedOptionIds != null && a.SelectedOptionIds.Count > 0) || !string.IsNullOrEmpty(a.TextAnswer),
                token);

        // Get flagged status from QuestionBookmarks
        var flaggedMap = await context.QuestionBookmarks
            .Where(b => b.UserId == userId && questionIds.Contains(b.QuestionId))
            .ToDictionaryAsync(b => b.QuestionId, b => true, token);

        var totalQuestions = questionMeta.Count;
        var answeredCount = answeredMap.Count(kv => kv.Value);

        var questions = questionMeta.Select(q => new NavigatorEntry(
            q.QuestionId,
            q.Idx,
            answeredMap.TryGetValue(q.QuestionId, out var answered) && answered,
            flaggedMap.TryGetValue(q.QuestionId, out var flagged) && flagged
        )).OrderBy(q => q.Idx).ToList();

        return Results.Ok(new ApiResultDto(true, "Navigator fetched", new NavigatorResponse(totalQuestions, answeredCount, questions)));
    }

    public async Task<IResult> ToggleFlag(Guid attemptId, Guid questionId, CancellationToken token)
    {
        var userId = user.UserId;

        // Verify attempt belongs to user
        var attemptExists = await context.Attempts
            .AnyAsync(x => x.Id == attemptId && x.UserId == userId, token);
        if (!attemptExists)
            return Results.NotFound(new ApiResultDto(false, "Attempt not found", null!));

        var bookmark = await context.QuestionBookmarks
            .FirstOrDefaultAsync(b => b.UserId == userId && b.QuestionId == questionId, token);

        if (bookmark != null)
        {
            context.QuestionBookmarks.Remove(bookmark);
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Flag removed", new { flagged = false }));
        }
        else
        {
            var newBookmark = new QuestionBookmark
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                QuestionId = questionId,
                AttemptId = attemptId,
                CreatedAt = DateTime.UtcNow
            };
            context.QuestionBookmarks.Add(newBookmark);
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Flag added", new { flagged = true }));
        }
    }

    private static string? TryGetExamCategory(JsonDocument? paperJson)
    {
        if (paperJson == null) return null;
        try
        {
            var parser = new JsonParser(JsonParser.Settings.Default!.WithIgnoreUnknownFields(true)!);
            var proto = parser.Parse<InternalDeliveryExam>(paperJson.RootElement.GetRawText());
            return proto?.Category;
        }
        catch
        {
            try
            {
                var dto = paperJson.RootElement.Deserialize<InternalExamDto.InternalDeliveryExam>(
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                );
                return dto?.Category;
            }
            catch
            {
                return null;
            }
        }
    }

}
