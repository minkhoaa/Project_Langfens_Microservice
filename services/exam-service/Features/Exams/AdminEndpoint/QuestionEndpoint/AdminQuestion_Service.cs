using System;
using System.Security.Claims;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using System.Collections.Generic;

namespace exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;

public interface IAdminQuestionService
{
    public Task<IResult> AddAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpsert dto
    );

    public Task<IResult> UpdateAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpdate dto,
        [FromRoute] Guid id
    );

    public Task<IResult> DeleteAsync(
        CancellationToken token,
        [FromRoute] Guid id);

    Task<IResult> GetBySectionIdAsync(Guid sectionId, CancellationToken token);
}

public class AdminQuestionService : IAdminQuestionService
{
    private readonly ExamDbContext _context;
    private readonly IConfiguration _config;
    private readonly IHttpContextAccessor? _httpContextAccessor;

    public AdminQuestionService(ExamDbContext context, IConfiguration config, IHttpContextAccessor? httpContextAccessor = null)
    {
        _context = context;
        _config = config;
        _httpContextAccessor = httpContextAccessor;
    }

    private (string editorId, string editorRole, string? idempotencyKey, string[]? reasons, string? comment) GetContextMetadata()
    {
        var httpContext = _httpContextAccessor?.HttpContext;
        var user = httpContext?.User;
        var editorId = user?.FindFirstValue("sub") ?? user?.FindFirstValue(ClaimTypes.NameIdentifier) ?? "admin";
        var editorRole = user?.FindFirstValue("role") ?? user?.FindFirstValue(ClaimTypes.Role) ?? "ADMIN";
        var idempotencyKey = httpContext?.Request.Headers["Idempotency-Key"].FirstOrDefault()
                          ?? httpContext?.Request.Headers["X-Idempotency-Key"].FirstOrDefault();
        var reasonsHeader = httpContext?.Request.Headers["X-Feedback-Reasons"].FirstOrDefault();
        var reasons = !string.IsNullOrWhiteSpace(reasonsHeader)
            ? reasonsHeader.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            : null;
        var comment = httpContext?.Request.Headers["X-Feedback-Comment"].FirstOrDefault();
        return (editorId, editorRole, idempotencyKey, reasons, comment);
    }

    internal static IResult? ValidatePayload(
        string type,
        string? promptMd,
        Dictionary<string, string[]?>? blankAcceptTexts,
        Dictionary<string, string[]?>? matchPairs,
        IEnumerable<string>? orderCorrects,
        IEnumerable<string>? shortAnswerAcceptTexts,
        IConfiguration? config = null)
    {
        var forbiddenPlaceholders = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "item 1", "item 2", "paragraph 1", "paragraph 2", "option a", "option b", "tbd", "n/a", "placeholder", "unknown"
        };
        bool HasText(IEnumerable<string?>? seq) => seq?.Any(x => !string.IsNullOrWhiteSpace(x)) ?? false;
        bool DictNonEmpty(Dictionary<string, string[]?>? d) =>
            d != null && d.Count > 0 && d.Values.Any(v => v != null && v.Length > 0 && v.Any(s => !string.IsNullOrWhiteSpace(s)));

        IResult? Reject(string msg) => Results.BadRequest(new ApiResultDto(false, msg, null!));
        switch (type)
        {
            case QuestionType.MultipleChoiceSingle:
            case QuestionType.MultipleChoiceSingleImage:
            case QuestionType.MultipleChoiceMultiple:
            case QuestionType.TrueFalseNotGiven:
            case QuestionType.YesNoNotGiven:
                if (DictNonEmpty(blankAcceptTexts)) return Reject($"{type}: BlankAcceptTexts must be empty.");
                if (DictNonEmpty(matchPairs))       return Reject($"{type}: MatchPairs must be empty.");
                if (HasText(orderCorrects))         return Reject($"{type}: OrderCorrects must be empty.");
                if (HasText(shortAnswerAcceptTexts))return Reject($"{type}: ShortAnswerAcceptTexts must be empty.");
                break;

            case QuestionType.SummaryCompletion:
            case QuestionType.TableCompletion:
            case QuestionType.NoteCompletion:
            case QuestionType.FormCompletion:
            case QuestionType.SentenceCompletion:
            case QuestionType.DiagramLabel:
            case QuestionType.MapLabel:
                if (!DictNonEmpty(blankAcceptTexts)) return Reject($"{type}: BlankAcceptTexts is required (non-empty dict).");
                if (DictNonEmpty(matchPairs))        return Reject($"{type}: MatchPairs must be empty.");
                if (HasText(orderCorrects))          return Reject($"{type}: OrderCorrects must be empty.");
                if (HasText(shortAnswerAcceptTexts)) return Reject($"{type}: ShortAnswerAcceptTexts must be empty.");
                if (blankAcceptTexts != null)
                {
                    foreach (var (bKey, vals) in blankAcceptTexts)
                    {
                        if (vals != null)
                        {
                            foreach (var val in vals.Where(v => !string.IsNullOrWhiteSpace(v)))
                            {
                                if (forbiddenPlaceholders.Contains(val.Trim()))
                                    return Reject($"{type}: Blank [{bKey}] answer '{val}' cannot be a placeholder.");
                                var wordCount = val.Trim().Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries).Length;
                                if (wordCount > 3)
                                    return Reject($"{type}: Blank [{bKey}] answer '{val}' exceeds IELTS 3-word limit ({wordCount} words).");
                            }
                        }
                    }
                }
                if (blankAcceptTexts != null && !string.IsNullOrEmpty(promptMd) &&
                    !((type == QuestionType.DiagramLabel || type == QuestionType.MapLabel) &&
                      System.Text.RegularExpressions.Regex.IsMatch(promptMd, @"\[(Diagram|Map):\s*[^\]]+\]")))
                {
                    var inPrompt = new HashSet<string>();
                    foreach (System.Text.RegularExpressions.Match m in
                             System.Text.RegularExpressions.Regex.Matches(promptMd, @"\[(\d+)\]"))
                    {
                        inPrompt.Add(m.Groups[1].Value);
                    }
                    var missing = blankAcceptTexts.Keys.Where(k => !inPrompt.Contains(k)).ToList();
                    if (missing.Count > 0)
                    {
                        var enforce = config?.GetValue<bool>("Langfens:PromptFormatEnforce") ?? true;
                        var msg = $"{type}: PromptMd is missing [N] markers for BlankAcceptTexts keys [{string.Join(",", missing)}]. Use [1], [2], … format.";
                        if (enforce) return Reject(msg);
                        Console.WriteLine($"[PROMPT-FORMAT-VIOLATION] {msg}");
                    }
                }
                break;

            case QuestionType.ShortAnswer:
                if (!HasText(shortAnswerAcceptTexts)) return Reject($"{type}: ShortAnswerAcceptTexts is required (non-empty list).");
                if (shortAnswerAcceptTexts != null)
                {
                    foreach (var val in shortAnswerAcceptTexts.Where(v => !string.IsNullOrWhiteSpace(v)))
                    {
                        if (forbiddenPlaceholders.Contains(val.Trim()))
                            return Reject($"{type}: Short answer '{val}' cannot be a placeholder.");
                        var wordCount = val.Trim().Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries).Length;
                        if (wordCount > 3)
                            return Reject($"{type}: Short answer '{val}' exceeds IELTS 3-word limit ({wordCount} words).");
                    }
                }
                if (DictNonEmpty(blankAcceptTexts))   return Reject($"{type}: BlankAcceptTexts must be empty.");
                if (DictNonEmpty(matchPairs))         return Reject($"{type}: MatchPairs must be empty.");
                if (HasText(orderCorrects))           return Reject($"{type}: OrderCorrects must be empty.");
                break;

            case QuestionType.MatchingHeading:
            case QuestionType.MatchingInformation:
            case QuestionType.MatchingFeatures:
            case QuestionType.MatchingEndings:
            case QuestionType.Classification:
                if (!DictNonEmpty(matchPairs))        return Reject($"{type}: MatchPairs is required (non-empty dict).");
                if (matchPairs != null)
                {
                    foreach (var kv in matchPairs)
                    {
                        var minLength = type == QuestionType.Classification ? 1 : 2;
                        if (kv.Value == null || kv.Value.Length < minLength || string.IsNullOrWhiteSpace(kv.Value[0]))
                        {
                            var expectedFormat = minLength == 1 ? "[acceptedKey]" : "[acceptedKey, displayLabel]";
                            return Reject($"{type}: MatchPairs[{kv.Key}] must have {expectedFormat}.");
                        }
                        if (forbiddenPlaceholders.Contains(kv.Value[0]!.Trim()))
                        {
                            return Reject($"{type}: MatchPairs[{kv.Key}][0] gradingKey '{kv.Value[0]}' cannot be a placeholder.");
                        }
                        if (kv.Value.Length >= 2 && !string.IsNullOrWhiteSpace(kv.Value[1]) && forbiddenPlaceholders.Contains(kv.Value[1]!.Trim()))
                        {
                            return Reject($"{type}: MatchPairs[{kv.Key}][1] displayLabel '{kv.Value[1]}' cannot be a placeholder.");
                        }
                        if (type == QuestionType.MatchingHeading && !System.Text.RegularExpressions.Regex.IsMatch(kv.Value[0]!.Trim(), @"^[ivxlcdm]+$", System.Text.RegularExpressions.RegexOptions.IgnoreCase))
                        {
                            return Reject($"{type}: MatchPairs[{kv.Key}][0] '{kv.Value[0]}' must be a valid Roman numeral (e.g. i, ii, iii).");
                        }
                    }

                    if (!string.IsNullOrEmpty(promptMd))
                    {
                        var inPrompt = new HashSet<string>();
                        foreach (System.Text.RegularExpressions.Match m in
                                 System.Text.RegularExpressions.Regex.Matches(promptMd, @"(?m)^\s*(\d+)[\.\)]\s+"))
                        {
                            inPrompt.Add(m.Groups[1].Value);
                        }

                        if (type == QuestionType.MatchingHeading)
                        {
                            var paraMatch = System.Text.RegularExpressions.Regex.Match(
                                promptMd,
                                @"(?i)(?:five|six|seven|eight|nine|ten|\d+)\s+paragraphs[,\s]+(?:1[–-](\d+)|([A-Z])[–-]([A-Z]))");
                            if (paraMatch.Success && paraMatch.Groups[1].Success)
                            {
                                var total = int.Parse(paraMatch.Groups[1].Value);
                                for (int i = 1; i <= total; i++) inPrompt.Add(i.ToString());
                            }
                        }

                        var missing = matchPairs.Keys.Where(k => !inPrompt.Contains(k)).ToList();
                        if (missing.Count > 0)
                        {
                            var enforce = config?.GetValue<bool>("Langfens:PromptFormatEnforce") ?? true;
                            var msg = $"{type}: PromptMd must contain numbered items (1., 2., …) matching MatchPairs keys [{string.Join(",", missing)}].";
                            if (enforce) return Reject(msg);
                            Console.WriteLine($"[PROMPT-FORMAT-VIOLATION] {msg}");
                        }
                    }
                }
                if (DictNonEmpty(blankAcceptTexts))   return Reject($"{type}: BlankAcceptTexts must be empty.");
                if (HasText(orderCorrects))           return Reject($"{type}: OrderCorrects must be empty.");
                if (HasText(shortAnswerAcceptTexts))  return Reject($"{type}: ShortAnswerAcceptTexts must be empty.");
                break;

            case QuestionType.FlowChart:
                if (!HasText(orderCorrects)) return Reject($"{type}: OrderCorrects is required (non-empty list).");
                if (orderCorrects != null)
                    foreach (var k in orderCorrects)
                        if (!System.Text.RegularExpressions.Regex.IsMatch(k ?? "", "^[a-z0-9]+(?:-[a-z0-9]+)*$"))
                            return Reject($"{type}: OrderCorrects key '{k}' must match ^[a-z0-9]+(?:-[a-z0-9]+)*$.");
                if (DictNonEmpty(blankAcceptTexts))   return Reject($"{type}: BlankAcceptTexts must be empty.");
                if (DictNonEmpty(matchPairs))         return Reject($"{type}: MatchPairs must be empty.");
                if (HasText(shortAnswerAcceptTexts)) return Reject($"{type}: ShortAnswerAcceptTexts must be empty.");
                break;
        }
        return null;
    }

    public async Task<IResult> AddAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpsert dto
    )
    {
        var section = await _context.ExamSections.AsNoTracking().FirstOrDefaultAsync(x => x.Id == dto.SectionId, token);
        if (section == null)
            return Results.NotFound(new ApiResultDto(false, "Section not found", null!));

        var validationError = ValidatePayload(
            dto.Type, dto.PromptMd, dto.BlankAcceptTexts, dto.MatchPairs,
            dto.OrderCorrects, dto.ShortAnswerAcceptTexts, _config);
        if (validationError != null) return validationError;

        var orderCorrects = dto.OrderCorrects?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
        var shortTexts = dto.ShortAnswerAcceptTexts?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
        var shortRegex = dto.ShortAnswerAcceptRegex?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();

        var meta = GetContextMetadata();

        var strategy = _context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await _context.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await _context.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Add question successfully (Idempotent replay)", null!));
                }
            }

            var question = new ExamQuestion
            {
                SectionId = dto.SectionId,
                Idx = dto.Idx ?? 1,
                Type = dto.Type,
                Skill = dto.Skill,
                Difficulty = dto.Difficulty,
                PromptMd = dto.PromptMd,
                ExplanationMd = dto.ExplanationMd,
                ImageUrl = dto.ImageUrl,
                BlankAcceptTexts = dto.BlankAcceptTexts,
                BlankAcceptRegex = dto.BlankAcceptRegex,
                MatchPairs = dto.MatchPairs,
                OrderCorrects = orderCorrects,
                ShortAnswerAcceptTexts = shortTexts,
                ShortAnswerAcceptRegex = shortRegex
            };

            _context.ExamQuestions.Add(question);
            await _context.SaveChangesAsync(token);
            await FeedbackService.RecordQuestionAddAsync(_context, question, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            await _context.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Add question successfully", question));
        });
    }

    public async Task<IResult> UpdateAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpdate dto,
        [FromRoute] Guid id
    )
    {
        var requiresAudio = string.Equals(dto.Skill, QuestionSkill.Listening, StringComparison.OrdinalIgnoreCase);
        if (requiresAudio)
        {
            var section = await _context.ExamSections.AsNoTracking()
                .Where(x => x.Id == dto.SectionId)
                .Select(x => new { x.AudioUrl })
                .FirstOrDefaultAsync(token);
            if (section == null)
                return Results.BadRequest(new ApiResultDto(false, "Not found section", null!));
            if (string.IsNullOrWhiteSpace(section.AudioUrl))
                return Results.BadRequest(new ApiResultDto(false, "Listening section is missing audioUrl", null!));
        }

        var validationError = ValidatePayload(
            dto.Type, dto.PromptMd, dto.BlankAcceptTexts, dto.MatchPairs,
            dto.OrderCorrects, dto.ShortAnswerAcceptTexts, _config);
        if (validationError != null) return validationError;

        var orderCorrects = dto.OrderCorrects?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
        var shortTexts = dto.ShortAnswerAcceptTexts?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
        var shortRegex = dto.ShortAnswerAcceptRegex?.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();

        var meta = GetContextMetadata();

        var strategy = _context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await _context.Database.BeginTransactionAsync(token);

            // 1. Check idempotency BEFORE mutation
            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await _context.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Updated 1 row (Idempotent replay)", null!));
                }
            }

            // 2. Capture before state inside transaction
            var before = await _context.ExamQuestions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, token);
            if (before == null)
                return Results.NotFound(new ApiResultDto(false, "Question not found", null!));

            var question = await _context.ExamQuestions.FirstOrDefaultAsync(x => x.Id == id, token);
            if (question == null)
                return Results.NotFound(new ApiResultDto(false, "Question not found", null!));

            question.SectionId = dto.SectionId;
            question.Idx = dto.Idx ?? question.Idx;
            question.Type = dto.Type;
            question.Skill = dto.Skill;
            question.Difficulty = dto.Difficulty;
            question.PromptMd = dto.PromptMd;
            question.ExplanationMd = dto.ExplanationMd;
            question.ImageUrl = dto.ImageUrl;
            question.BlankAcceptTexts = dto.BlankAcceptTexts;
            question.BlankAcceptRegex = dto.BlankAcceptRegex;
            question.MatchPairs = dto.MatchPairs;
            question.OrderCorrects = orderCorrects;
            question.ShortAnswerAcceptTexts = shortTexts;
            question.ShortAnswerAcceptRegex = shortRegex;

            await _context.SaveChangesAsync(token);
            await FeedbackService.RecordQuestionEditAsync(_context, before, question, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            await _context.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Updated 1 row", null!));
        });
    }

    public async Task<IResult> DeleteAsync(
        CancellationToken token,
        [FromRoute] Guid id)
    {
        var meta = GetContextMetadata();

        var strategy = _context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await _context.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await _context.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Deleted (Idempotent replay)", null!));
                }
            }

            var before = await _context.ExamQuestions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, token);
            if (before == null)
                return Results.Ok(new ApiResultDto(true, "Deleted 0", null!));

            await FeedbackService.RecordQuestionDeleteAsync(_context, before, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            var affectedRow = await _context.ExamQuestions.Where(x => x.Id == id).ExecuteDeleteAsync(token);
            await _context.SaveChangesAsync(token);
            await tx.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {affectedRow}", null!));
        });
    }

    public async Task<IResult> GetBySectionIdAsync(Guid sectionId, CancellationToken token)
    {
        var questions = await _context.ExamQuestions.AsNoTracking()
            .Where(x => x.SectionId == sectionId)
            .OrderBy(x => x.Idx)
            .Select(x => new
            {
                x.Id,
                x.SectionId,
                x.GroupId,
                x.Idx,
                x.Type,
                x.Skill,
                x.Difficulty,
                x.PromptMd,
                x.ExplanationMd,
                x.ImageUrl,
                x.BlankAcceptTexts,
                x.BlankAcceptRegex,
                x.MatchPairs,
                x.OrderCorrects,
                x.ShortAnswerAcceptTexts,
                x.ShortAnswerAcceptRegex
            })
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched questions by section id", questions));
    }
}
