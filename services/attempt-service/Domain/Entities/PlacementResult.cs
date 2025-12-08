using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.VisualBasic;

namespace attempt_service.Domain.Entities
{
    public class PlacementResult
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid ExamId { get; set; }
        public Guid AttemptId { get; set; }


        public int ReadingCorrect { get; set; }
        public int ReadingTotal { get; set; }
        public int ListeningCorrect { get; set; }
        public int ListeningTotal { get; set; }
        public decimal? WritingBand { get; set; }
        public decimal? SpeakingBand { get; set; }
        public int TotalCorrect { get; set; }
        public string Level { get; set; } = default!;
        public decimal Band { get; set; } = default!;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public Attempt Attempt { get; set; } = default!;
    }
}