using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using exam_service.Domains.Entities;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;

public static class ExamPublicationValidator
{
    private static readonly Regex VietnameseRegex = new(
        @"[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]",
        RegexOptions.Compiled);

    private static readonly HashSet<string> ForbiddenPlaceholders = new(StringComparer.OrdinalIgnoreCase)
    {
        "item 1", "item 2", "paragraph 1", "paragraph 2", "option a", "option b", "tbd", "n/a", "placeholder", "unknown"
    };

    public static List<string> ValidateForPublication(Domains.Entities.Exam exam)
    {
        var errors = new List<string>();

        if (exam.Sections == null || exam.Sections.Count == 0)
        {
            errors.Add("Exam must contain at least one section.");
            return errors;
        }

        var allQuestions = exam.Sections
            .SelectMany(s => s.Questions ?? Enumerable.Empty<ExamQuestion>())
            .ToList();

        if (allQuestions.Count == 0)
        {
            errors.Add("Exam must contain at least one question.");
            return errors;
        }

        foreach (var q in allQuestions)
        {
            var qRef = $"Q{q.Idx} ({q.Type})";

            if (string.IsNullOrWhiteSpace(q.PromptMd))
            {
                errors.Add($"{qRef}: PromptMd cannot be empty.");
            }
            else if (VietnameseRegex.IsMatch(q.PromptMd))
            {
                errors.Add($"{qRef}: PromptMd contains Vietnamese text; IELTS content must be in English.");
            }

            if (!string.IsNullOrWhiteSpace(q.ExplanationMd) && VietnameseRegex.IsMatch(q.ExplanationMd))
            {
                errors.Add($"{qRef}: ExplanationMd contains Vietnamese text; IELTS content must be in English.");
            }

            switch (q.Type)
            {
                case QuestionType.MultipleChoiceSingle:
                case QuestionType.MultipleChoiceSingleImage:
                {
                    var opts = q.Options ?? new List<ExamOption>();
                    if (opts.Count < 2)
                    {
                        errors.Add($"{qRef}: Must have at least 2 options.");
                    }
                    var correctCount = opts.Count(o => o.IsCorrect);
                    if (correctCount != 1)
                    {
                        errors.Add($"{qRef}: Must have exactly 1 correct option; found {correctCount}.");
                    }
                    if (q.Type == QuestionType.MultipleChoiceSingleImage)
                    {
                        var hasImg = !string.IsNullOrWhiteSpace(q.ImageUrl) || opts.Any(o => !string.IsNullOrWhiteSpace(o.ImageUrl));
                        if (!hasImg)
                        {
                            errors.Add($"{qRef}: Requires ImageUrl on question or options.");
                        }
                    }
                    break;
                }

                case QuestionType.MultipleChoiceMultiple:
                {
                    var opts = q.Options ?? new List<ExamOption>();
                    if (opts.Count < 3)
                    {
                        errors.Add($"{qRef}: Must have at least 3 options.");
                    }
                    var correctCount = opts.Count(o => o.IsCorrect);
                    if (correctCount < 2)
                    {
                        errors.Add($"{qRef}: Must have at least 2 correct options; found {correctCount}.");
                    }
                    break;
                }

                case QuestionType.TrueFalseNotGiven:
                case QuestionType.YesNoNotGiven:
                {
                    var opts = q.Options ?? new List<ExamOption>();
                    if (opts.Count != 3)
                    {
                        errors.Add($"{qRef}: Must have exactly 3 options; found {opts.Count}.");
                    }
                    var correctCount = opts.Count(o => o.IsCorrect);
                    if (correctCount != 1)
                    {
                        errors.Add($"{qRef}: Must have exactly 1 correct option; found {correctCount}.");
                    }
                    break;
                }

                case QuestionType.SummaryCompletion:
                case QuestionType.TableCompletion:
                case QuestionType.NoteCompletion:
                case QuestionType.FormCompletion:
                case QuestionType.SentenceCompletion:
                case QuestionType.DiagramLabel:
                case QuestionType.MapLabel:
                {
                    if (q.BlankAcceptTexts == null || q.BlankAcceptTexts.Count == 0)
                    {
                        errors.Add($"{qRef}: BlankAcceptTexts cannot be empty.");
                    }
                    else
                    {
                        var isDiagramOrMapWithSpec = (q.Type is QuestionType.DiagramLabel or QuestionType.MapLabel) &&
                            !string.IsNullOrEmpty(q.PromptMd) &&
                            Regex.IsMatch(q.PromptMd, @"\[(Diagram|Map):\s*[^\]]+\]");

                        foreach (var (blankKey, accepted) in q.BlankAcceptTexts)
                        {
                            if (accepted == null || accepted.Length == 0 || accepted.All(string.IsNullOrWhiteSpace))
                            {
                                errors.Add($"{qRef}: Blank [{blankKey}] has no accepted answers.");
                            }
                            else
                            {
                                foreach (var ans in accepted.Where(a => !string.IsNullOrWhiteSpace(a)))
                                {
                                    if (ForbiddenPlaceholders.Contains(ans.Trim()))
                                    {
                                        errors.Add($"{qRef}: Blank [{blankKey}] answer '{ans}' is a forbidden placeholder.");
                                    }
                                    var wordCount = ans.Trim().Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries).Length;
                                    if (wordCount > 3)
                                    {
                                        errors.Add($"{qRef}: Blank [{blankKey}] answer '{ans}' exceeds IELTS 3-word limit ({wordCount} words).");
                                    }
                                }
                            }

                            if (!isDiagramOrMapWithSpec && !string.IsNullOrEmpty(q.PromptMd) && !q.PromptMd.Contains($"[{blankKey}]"))
                            {
                                errors.Add($"{qRef}: PromptMd missing marker [{blankKey}].");
                            }
                        }
                    }

                    if (q.Type is QuestionType.DiagramLabel or QuestionType.MapLabel && string.IsNullOrWhiteSpace(q.ImageUrl))
                    {
                        errors.Add($"{qRef}: ImageUrl is required.");
                    }
                    break;
                }

                case QuestionType.ShortAnswer:
                {
                    if (q.ShortAnswerAcceptTexts == null || q.ShortAnswerAcceptTexts.Count == 0 || q.ShortAnswerAcceptTexts.All(string.IsNullOrWhiteSpace))
                    {
                        errors.Add($"{qRef}: ShortAnswerAcceptTexts cannot be empty.");
                    }
                    else
                    {
                        foreach (var ans in q.ShortAnswerAcceptTexts.Where(a => !string.IsNullOrWhiteSpace(a)))
                        {
                            if (ForbiddenPlaceholders.Contains(ans.Trim()))
                            {
                                errors.Add($"{qRef}: Answer '{ans}' is a forbidden placeholder.");
                            }
                            var wordCount = ans.Trim().Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries).Length;
                            if (wordCount > 3)
                            {
                                errors.Add($"{qRef}: Answer '{ans}' exceeds IELTS 3-word limit ({wordCount} words).");
                            }
                        }
                    }
                    break;
                }

                case QuestionType.MatchingHeading:
                case QuestionType.MatchingInformation:
                case QuestionType.MatchingFeatures:
                case QuestionType.MatchingEndings:
                case QuestionType.Classification:
                {
                    if (q.MatchPairs == null || q.MatchPairs.Count == 0)
                    {
                        errors.Add($"{qRef}: MatchPairs cannot be empty.");
                    }
                    else
                    {
                        var optKeys = (q.Options ?? new List<ExamOption>())
                            .Select(o => {
                                var m = Regex.Match(o.ContentMd ?? "", @"^([a-zA-Z0-9ivxlcdmIVXLCDM]+)[\.\)]");
                                return m.Success ? m.Groups[1].Value.ToLowerInvariant() : "";
                            })
                            .Where(k => !string.IsNullOrEmpty(k))
                            .ToHashSet();

                        foreach (var (tKey, val) in q.MatchPairs)
                        {
                            if (val == null || val.Length < 1 || string.IsNullOrWhiteSpace(val[0]))
                            {
                                errors.Add($"{qRef}: Target '{tKey}' has empty gradingKey.");
                                continue;
                            }

                            var gradingKey = val[0]!.Trim().ToLowerInvariant();
                            if (ForbiddenPlaceholders.Contains(gradingKey))
                            {
                                errors.Add($"{qRef}: Target '{tKey}' gradingKey '{val[0]}' is a forbidden placeholder.");
                            }

                            if (q.Type == QuestionType.MatchingHeading)
                            {
                                if (!Regex.IsMatch(gradingKey, @"^[ivxlcdm]+$"))
                                {
                                    errors.Add($"{qRef}: Target '{tKey}' gradingKey '{val[0]}' must be a valid Roman numeral.");
                                }
                            }

                            if (val.Length >= 2 && !string.IsNullOrWhiteSpace(val[1]))
                            {
                                if (ForbiddenPlaceholders.Contains(val[1]!.Trim()))
                                {
                                    errors.Add($"{qRef}: Target '{tKey}' displayLabel '{val[1]}' is a forbidden placeholder.");
                                }
                            }

                            if (optKeys.Count > 0 && !optKeys.Contains(gradingKey))
                            {
                                errors.Add($"{qRef}: Target '{tKey}' gradingKey '{val[0]}' is not in question options pool.");
                            }
                        }
                    }
                    break;
                }

                case QuestionType.FlowChart:
                {
                    if (q.OrderCorrects == null || q.OrderCorrects.Count < 2)
                    {
                        errors.Add($"{qRef}: OrderCorrects must contain at least 2 steps.");
                    }
                    else
                    {
                        foreach (var slug in q.OrderCorrects)
                        {
                            if (string.IsNullOrWhiteSpace(slug) || !Regex.IsMatch(slug, @"^[a-z0-9]+(?:-[a-z0-9]+)*$"))
                            {
                                errors.Add($"{qRef}: OrderCorrects slug '{slug}' is invalid.");
                            }
                        }
                        if (q.OrderCorrects.Distinct(StringComparer.OrdinalIgnoreCase).Count() != q.OrderCorrects.Count)
                        {
                            errors.Add($"{qRef}: OrderCorrects contains duplicate steps.");
                        }
                    }
                    break;
                }
            }
        }

        return errors;
    }
}
