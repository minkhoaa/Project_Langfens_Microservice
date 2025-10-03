using Shared.Grpc.ExamInternal;

namespace exam_service.Application.Common;

public static class ProtoHelper
{
    public static InternalDeliveryExam MapToProto(Domains.Entities.Exam exam, bool showAnswers)
{
    var proto = new InternalDeliveryExam
    {
        Id = exam.Id,
        Category = exam.Category,
        DescriptionMd = exam.DescriptionMd ?? string.Empty,
        Level = exam.Level,
        Slug = exam.Slug,
        Title = exam.Title,
        // Nếu proto có DurationMin/DurationSec, nhớ map luôn:
        DurationMin = exam.DurationMin // ví dụ, tùy schema của bạn
    };

    // Duyệt TỪ domain -> TỚI proto
    foreach (var sec in exam.Sections.OrderBy(s => s.Idx))
    {
        var pSec = new InternalDeliverySection
        {
            Id = sec.Id,
            InstructionsMd = sec.InstructionsMd ?? string.Empty,
            Idx = sec.Idx,
            Title = sec.Title ?? string.Empty,
        };

        foreach (var q in sec.Questions.OrderBy(q => q.Idx))
        {
            var pQ = new InternalDeliveryQuestion
            {
                Id = q.Id,
                Idx = q.Idx,
                ExplanationMd = showAnswers ? (q.ExplanationMd ?? string.Empty) : string.Empty,
                Difficulty = q.Difficulty,
                PromptMd = q.PromptMd ?? string.Empty,
                Skill = q.Skill ?? string.Empty,
                Type = q.Type ?? string.Empty
            };

            foreach (var opt in q.Options.OrderBy(o => o.Idx))
            {
                var pOpt = new InternalDeliveryOption
                {
                    Id = opt.Id,
                    Idx = opt.Idx,
                    ContentMd = opt.ContentMd ?? string.Empty,
                    // Nếu schema có cờ đáp án đúng và bạn muốn ẩn khi !showAnswers:
                    // IsCorrect = showAnswers ? opt.IsCorrect : false
                };
                pQ.Options.Add(pOpt);     // ✅ add vào proto-question
            }

            pSec.Questions.Add(pQ);       // ✅ add vào proto-section
        }

        proto.Sections.Add(pSec);         // ✅ add vào proto-exam
    }

    return proto;
}

}