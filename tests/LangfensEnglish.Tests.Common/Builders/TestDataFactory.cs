extern alias examsvc;
extern alias coursesvc;

using coursesvc::course_service.Domains.Entities;
using examsvc::exam_service.Domains.Entities;
using Shared.ExamDto.Contracts.Course.Enums;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace LangfensEnglish.Tests.Common.Builders;

public static class TestDataFactory
{
    public static Exam CreateExam(
        string? slug = null,
        string? title = null,
        string? category = null,
        string? level = null,
        string status = ExamStatus.Published,
        int sectionCount = 1,
        int questionsPerSection = 1,
        int optionsPerQuestion = 1)
    {
        var exam = new Exam
        {
            Id = Guid.NewGuid(),
            Slug = slug ?? $"exam-{Guid.NewGuid():N}",
            Title = title ?? "Sample Exam",
            DescriptionMd = "Sample description",
            Category = category ?? ExamCategory.IELTS,
            Level = level ?? ExamLevel.B1,
            Status = status,
            DurationMin = 60,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        for (var s = 1; s <= sectionCount; s++)
        {
            var section = new ExamSection
            {
                Id = Guid.NewGuid(),
                ExamId = exam.Id,
                Exam = exam,
                Idx = s,
                Title = $"Section {s}",
                InstructionsMd = "Instructions"
            };

            for (var q = 1; q <= questionsPerSection; q++)
            {
                var question = new ExamQuestion
                {
                    Id = Guid.NewGuid(),
                    SectionId = section.Id,
                    Section = section,
                    Idx = q,
                    Type = QuestionType.MultipleChoiceSingle,
                    Skill = QuestionSkill.Reading,
                    Difficulty = 1,
                    PromptMd = $"Prompt {q}"
                };

                for (var o = 1; o <= optionsPerQuestion; o++)
                {
                    question.Options.Add(new ExamOption
                    {
                        Id = Guid.NewGuid(),
                        QuestionId = question.Id,
                        Question = question,
                        Idx = o,
                        ContentMd = $"Option {o}",
                        IsCorrect = o == 1
                    });
                }

                section.Questions.Add(question);
            }

            exam.Sections.Add(section);
        }

        return exam;
    }

    public static Course CreateCourse(
        string? slug = null,
        string? title = null,
        string? category = null,
        string? level = null,
        string? status = null,
        int lessons = 1)
    {
        var course = new Course
        {
            Id = Guid.NewGuid(),
            Slug = slug ?? $"course-{Guid.NewGuid():N}",
            Title = title ?? "Sample Course",
            DescriptionMd = "Course description",
            Category = category ?? CourseCategories.GENERAL_ENGLISH,
            Level = level ?? CourseLevel.B1,
            Status = status ?? CourseStatus.Published,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        for (var i = 1; i <= lessons; i++)
        {
            course.Lessons.Add(new Lesson
            {
                Id = Guid.NewGuid(),
                CourseId = course.Id,
                Course = course,
                Idx = i,
                Title = $"Lesson {i}",
                DurationMin = 30
            });
        }

        return course;
    }
}
