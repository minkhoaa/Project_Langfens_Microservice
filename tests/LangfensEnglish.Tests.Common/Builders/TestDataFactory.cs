extern alias examsvc;
extern alias coursesvc;
extern alias vocsvc;

using examsvc::exam_service.Domains.Entities;
using coursesvc::course_service.Domains.Entities;
using vocsvc::vocabulary_service.Domains.Entities;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.ExamDto.Contracts.Course.Enums;
using Shared.ExamDto.Contracts.FlashCard;

namespace LangfensEnglish.Tests.Common.Builders;

/// <summary>
/// Lightweight factory helpers to build entities/requests for unit tests without duplicating boilerplate.
/// </summary>
public static class TestDataFactory
{
    public static Exam CreateExam(
        Guid? id = null,
        string? slug = null,
        string? category = null,
        string? level = null,
        string status = ExamStatus.Published,
        int sectionCount = 0,
        int questionsPerSection = 0,
        int optionsPerQuestion = 0)
    {
        var examId = id ?? Guid.NewGuid();
        var generatedExamSlug = slug ?? $"exam-{Guid.NewGuid():N}".Substring(0, 8);
        var exam = new Exam
        {
            Id = examId,
            Slug = generatedExamSlug,
            Title = "Sample Exam",
            Category = category ?? ExamCategory.IELTS,
            Level = level ?? ExamLevel.B1,
            Status = status,
            DurationMin = 60,
            UpdatedAt = DateTime.UtcNow
        };

        for (var si = 0; si < sectionCount; si++)
        {
            var sectionId = Guid.NewGuid();
            var section = new ExamSection
            {
                Id = sectionId,
                ExamId = examId,
                Idx = si + 1,
                Title = $"Section {si + 1}",
                InstructionsMd = "Do it carefully",
                Questions = new List<ExamQuestion>()
            };

            for (var qi = 0; qi < questionsPerSection; qi++)
            {
                var qId = Guid.NewGuid();
                var question = new ExamQuestion
                {
                    Id = qId,
                    SectionId = sectionId,
                    Idx = qi + 1,
                    Type = "multiple_choice",
                    Skill = QuestionSkill.Listening,
                    Difficulty = 2,
                    PromptMd = $"Q{qi + 1}",
                    Options = new List<ExamOption>()
                };

                for (var oi = 0; oi < optionsPerQuestion; oi++)
                {
                    question.Options.Add(new ExamOption
                    {
                        Id = Guid.NewGuid(),
                        QuestionId = qId,
                        Idx = oi + 1,
                        ContentMd = $"Option {oi + 1}"
                    });
                }

                section.Questions.Add(question);
            }

            exam.Sections.Add(section);
        }

        return exam;
    }

    public static Course CreateCourse(
        Guid? id = null,
        string? slug = null,
        string? category = null,
        string? level = null,
        string status = "DRAFT",
        int lessons = 0)
    {
        var courseId = id ?? Guid.NewGuid();
        var generatedCourseSlug = slug ?? $"course-{Guid.NewGuid():N}".Substring(0, 8);
        var course = new Course
        {
            Id = courseId,
            Slug = generatedCourseSlug,
            Title = "Sample Course",
            DescriptionMd = "Desc",
            Category = category ?? CourseCategories.GENERAL_ENGLISH,
            Level = level ?? CourseLevel.B1,
            Status = status,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            Lessons = new List<Lesson>()
        };

        for (var i = 0; i < lessons; i++)
        {
            course.Lessons.Add(new Lesson
            {
                Id = Guid.NewGuid(),
                CourseId = courseId,
                Idx = i + 1,
                Title = $"Lesson {i + 1}",
                ContentMd = "Content",
                DurationMin = 5
            });
        }

        return course;
    }

    public static Deck CreateDeck(
        Guid? id = null,
        string? slug = null,
        string? status = "PUBLISHED",
        string? category = "general",
        int cards = 0)
    {
        var deckId = id ?? Guid.NewGuid();
        var generatedDeckSlug = slug ?? $"deck-{Guid.NewGuid():N}".Substring(0, 8);
        var deck = new Deck
        {
            Id = deckId,
            Slug = generatedDeckSlug,
            Title = "Deck title",
            DescriptionMd = "Desc",
            Category = category,
            Status = status,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            Cards = new List<Card>()
        };

        for (var i = 0; i < cards; i++)
        {
            deck.Cards.Add(new Card
            {
                Id = Guid.NewGuid(),
                DeckId = deckId,
                Idx = i + 1,
                FrontMd = $"Front {i + 1}",
                BackMd = $"Back {i + 1}",
                HintMd = $"Hint {i + 1}"
            });
        }

        return deck;
    }

    public static Enrollment CreateEnrollment(Guid courseId, Guid userId, string status = "ACTIVE")
        => new()
        {
            Id = Guid.NewGuid(),
            CourseId = courseId,
            UserId = userId,
            EnrolledAt = DateTime.UtcNow,
            Status = status
        };

    public static UserDeck CreateUserDeck(Guid deckId, Guid userId, string status = "ACTIVE")
        => new()
        {
            Id = Guid.NewGuid(),
            DeckId = deckId,
            UserId = userId,
            Status = status,
            SubscribeAt = DateTime.UtcNow
        };
}
