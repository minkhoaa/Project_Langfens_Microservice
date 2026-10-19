using System;
using System.Collections.Generic;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

public class ExamPublicationValidatorTests
{
    private static Exam CreateValidExam()
    {
        var exam = new Exam
        {
            Id = Guid.NewGuid(),
            Title = "IELTS Reading Test",
            Status = ExamStatus.Draft,
            Sections = new List<ExamSection>()
        };

        var section = new ExamSection
        {
            Id = Guid.NewGuid(),
            ExamId = exam.Id,
            Idx = 1,
            Title = "Section 1",
            PassageMd = "Historical text about navigation.",
            Questions = new List<ExamQuestion>()
        };

        // 1. MCQ Single
        var q1 = new ExamQuestion
        {
            Id = Guid.NewGuid(),
            SectionId = section.Id,
            Idx = 1,
            Type = QuestionType.MultipleChoiceSingle,
            Skill = "READING",
            PromptMd = "What was the primary method of early navigation?",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), Idx = 1, ContentMd = "A. Celestial observation", IsCorrect = true },
                new() { Id = Guid.NewGuid(), Idx = 2, ContentMd = "B. Magnetic compass", IsCorrect = false },
                new() { Id = Guid.NewGuid(), Idx = 3, ContentMd = "C. Radio signals", IsCorrect = false },
                new() { Id = Guid.NewGuid(), Idx = 4, ContentMd = "D. Radar tracking", IsCorrect = false },
            }
        };

        // 2. Matching Heading
        var q2 = new ExamQuestion
        {
            Id = Guid.NewGuid(),
            SectionId = section.Id,
            Idx = 2,
            Type = QuestionType.MatchingHeading,
            Skill = "READING",
            PromptMd = "The reading passage has paragraphs 1–2.\n\n1. Paragraph 1\n2. Paragraph 2",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), Idx = 1, ContentMd = "i. Early coastal exploration", IsCorrect = false },
                new() { Id = Guid.NewGuid(), Idx = 2, ContentMd = "ii. Technological developments", IsCorrect = false },
                new() { Id = Guid.NewGuid(), Idx = 3, ContentMd = "iii. Trade routes expansion", IsCorrect = false },
            },
            MatchPairs = new Dictionary<string, string[]?>
            {
                ["1"] = new[] { "i", "Early coastal exploration" },
                ["2"] = new[] { "ii", "Technological developments" }
            }
        };

        // 3. Sentence Completion
        var q3 = new ExamQuestion
        {
            Id = Guid.NewGuid(),
            SectionId = section.Id,
            Idx = 3,
            Type = QuestionType.SentenceCompletion,
            Skill = "READING",
            PromptMd = "Early navigators tracked their positions using [3] across the horizon.",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                ["3"] = new[] { "star patterns", "constellations" }
            }
        };

        section.Questions.Add(q1);
        section.Questions.Add(q2);
        section.Questions.Add(q3);
        exam.Sections.Add(section);

        return exam;
    }

    [Fact]
    public void ValidExam_PassesPublicationValidation()
    {
        var exam = CreateValidExam();
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Empty(errors);
    }

    [Fact]
    public void ExamWithNoSections_IsRejected()
    {
        var exam = new Exam { Id = Guid.NewGuid(), Title = "Empty Exam", Sections = new List<ExamSection>() };
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("at least one section"));
    }

    [Fact]
    public void ExamWithVietnamesePrompt_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[0].PromptMd = "Đọc đoạn văn sau và chọn đáp án đúng.";
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("contains Vietnamese text"));
    }

    [Fact]
    public void McqSingle_WithMultipleCorrectOptions_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[0].Options[1].IsCorrect = true; // 2 correct
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("Must have exactly 1 correct option"));
    }

    [Fact]
    public void McqSingle_WithZeroCorrectOptions_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[0].Options[0].IsCorrect = false; // 0 correct
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("Must have exactly 1 correct option"));
    }

    [Fact]
    public void MatchingHeading_WithPlaceholderAnswerKey_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[1].MatchPairs!["1"] = new[] { "Item 1", "Paragraph 1" };
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("forbidden placeholder"));
    }

    [Fact]
    public void MatchingHeading_WithNonRomanNumeralKey_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[1].MatchPairs!["1"] = new[] { "A", "Early coastal exploration" };
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("must be a valid Roman numeral"));
    }

    [Fact]
    public void MatchingHeading_WithKeyNotInOptions_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[1].MatchPairs!["1"] = new[] { "iv", "Nonexistent heading" };
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("not in question options pool"));
    }

    [Fact]
    public void Completion_WithWordLimitExceeded_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[2].BlankAcceptTexts!["3"] = new[] { "this answer has more than three words" };
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("exceeds IELTS 3-word limit"));
    }

    [Fact]
    public void Completion_MissingBracketMarkerInPrompt_IsRejected()
    {
        var exam = CreateValidExam();
        exam.Sections[0].Questions[2].PromptMd = "Early navigators tracked their positions using stars.";
        var errors = ExamPublicationValidator.ValidateForPublication(exam);
        Assert.Contains(errors, e => e.Contains("missing marker [3]"));
    }

    // ---------- AdminQuestionService.ValidatePayload Tests ----------

    [Fact]
    public void AdminQuestionService_ValidatePayload_RejectsMatchingPlaceholder()
    {
        var pairs = new Dictionary<string, string[]?>
        {
            ["1"] = new[] { "Item 1", "Paragraph 1" }
        };
        var res = AdminQuestionService.ValidatePayload(
            QuestionType.MatchingHeading,
            "1. Paragraph 1",
            null,
            pairs,
            null,
            null);

        Assert.NotNull(res);
    }

    [Fact]
    public void AdminQuestionService_ValidatePayload_RejectsNonRomanMatchingHeading()
    {
        var pairs = new Dictionary<string, string[]?>
        {
            ["1"] = new[] { "A", "Some heading text" }
        };
        var res = AdminQuestionService.ValidatePayload(
            QuestionType.MatchingHeading,
            "1. Paragraph 1",
            null,
            pairs,
            null,
            null);

        Assert.NotNull(res);
    }

    [Fact]
    public void AdminQuestionService_ValidatePayload_RejectsExcessWordsInCompletion()
    {
        var blanks = new Dictionary<string, string[]?>
        {
            ["1"] = new[] { "four words long answer" }
        };
        var res = AdminQuestionService.ValidatePayload(
            QuestionType.SentenceCompletion,
            "The early discovery was [1].",
            blanks,
            null,
            null,
            null);

        Assert.NotNull(res);
    }
}
