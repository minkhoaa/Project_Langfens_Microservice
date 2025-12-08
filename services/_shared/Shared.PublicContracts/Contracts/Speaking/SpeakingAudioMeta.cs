using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Shared.ExamDto.Contracts.Speaking
{
    public sealed class SpeakingAudioMeta
    {
        public string AudioUrl { get; init; } = default!;
        public string? Format { get; init; }
        public double? DurationSec { get; init; }
        public long? Bytes { get; init; }
        public string? PublicId { get; init; }
    }

}