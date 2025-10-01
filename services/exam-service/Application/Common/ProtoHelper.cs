using Shared.Grpc.ExamInternal;

namespace exam_service.Application.Common;

public static class ProtoHelper
{
    public static InternalDeliveryExam MapToProto(Domains.Entities.Exam exam, bool showAnswers)
    {
        var exams = new InternalDeliveryExam()
        {
            Id = exam.Id,
            Category = exam.Category,
            DescriptionMd = exam.DescriptionMd ?? string.Empty,
            Level = exam.Level,
            Slug = exam.Slug,
            Title = exam.Title
        };
        foreach (var section in exams.Sections)
        {
            var sections = new InternalDeliverySection()
            {
                Id = section.Id,
                InstructionsMd = section.InstructionsMd ?? string.Empty,
                Idx = section.Idx,
                Title = section.Title ?? string.Empty,
            };
            foreach (var question in section.Questions)
            {
                var questions = new InternalDeliveryQuestion()
                {
                    Id = question.Id,
                    Idx = question.Idx,
                    ExplanationMd = question.ExplanationMd ?? string.Empty,
                    Difficulty = question.Difficulty,
                    PromptMd = question.PromptMd ?? string.Empty,
                    Skill = question.Skill ?? string.Empty,
                    Type = question.Type ?? string.Empty
                };
                foreach (var option in question.Options)
                {
                    var options = new InternalDeliveryOption()
                    {
                        Id = option.Id,
                        Idx = option.Idx,
                        ContentMd = option.ContentMd ?? string.Empty,
                    };
                    question.Options.Add(options);
                    
                }
                section.Questions.Add(questions);
            }
            exams.Sections.Add(sections);
        }
        return exams;
    }
}