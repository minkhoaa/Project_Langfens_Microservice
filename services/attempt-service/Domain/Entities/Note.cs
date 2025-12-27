using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace attempt_service.Domain.Entities;

public class Note
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [Required] 
    public Guid UserId { get; set; }
    
    /// <summary>
    /// Optional - links note to an attempt
    /// </summary>
    public Guid? AttemptId { get; set; }
    
    /// <summary>
    /// Optional - links note to a specific section within an attempt
    /// </summary>
    public Guid? SectionId { get; set; }
    
    /// <summary>
    /// The text that was selected/highlighted when creating the note
    /// </summary>
    [MaxLength(1000)]
    public string? SelectedText { get; set; }
    
    /// <summary>
    /// The note content
    /// </summary>
    [Required]
    [MaxLength(5000)]
    public string Content { get; set; } = "";
    
    [Required] 
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    [Required] 
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
