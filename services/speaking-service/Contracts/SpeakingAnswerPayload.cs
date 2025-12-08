namespace speaking_service.Contracts
{
    public class SpeakingAnswerPayload
    {
        public Guid RecordingId { get; set; }
        public string Provider { get; set; } = default!;
        public string BlobKey { get; set; } = default!;
        public string? Url { get; set; }
        public string MimeType { get; set; } = default!;
        public long SizeBytes { get; set; }
        public double? DurationSec { get; set; }
    }

}