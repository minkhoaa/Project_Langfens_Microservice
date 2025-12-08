using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Shared.ExamDto.Contracts.Speaking
{
    public record SpeakingGradingRequestMessage(
        Guid AttemptId,
        Guid UserId,
        Guid? QuestionId,
        string Skill,         // QuestionSkill.Speaking
        string? Prompt,
        string AudioUrl,
        string? Format,
        int? Duration,
        long? Bytes,
        string? PublicId
    );
}
