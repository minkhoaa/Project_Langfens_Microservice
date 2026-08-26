using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;

namespace ExamService.Domains.Entities;

public sealed class ExamQuestion
{
    public Guid Id { get; set; }

    public Guid SectionId { get; set; }

    public Guid? GroupId { get; set; }

    public int Idx { get; set; }

    /// <summary>
    /// READING | LISTENING — denormalized from <c>payload.skill</c> per spec §2.1.
    /// Lets the FE pre-filter sections without unpacking every <c>Payload</c>.
    /// </summary>
    [Required]
    public string Skill { get; set; } = "";

    /// <summary>
    /// Full SSOT question payload verbatim from <c>docs/schemas/&lt;type&gt;.schema.json</c>.
    /// Carries id, skill, difficulty, promptMd, explanationMd, schemaVersion, uiHints,
    /// provenance (writeOnly) and per-type fields. See spec §2.1 + §3.2.
    /// </summary>
    [Required]
    [Column(TypeName = "jsonb")]
    public JsonDocument Payload { get; set; } = null!;

    /// <summary>
    /// Full SSOT correct-answer payload verbatim (e.g.
    /// <c>MultipleChoiceSingleAnswer.CorrectOptionId</c>,
    /// <c>FlowChartAnswer.{Order, Scoring}</c>,
    /// <c>CompletionAnswer.Answers</c>). See spec §2.1 + §3.2.
    /// </summary>
    [Required]
    [Column(TypeName = "jsonb")]
    public JsonDocument CorrectAnswer { get; set; } = null!;

    /// <summary>
    /// Mirrors <c>payload.schemaVersion</c>; defaults to <c>"1.0.0"</c>.
    /// </summary>
    public string SchemaVersion { get; set; } = "1.0.0";

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public ExamSection Section { get; set; } = null!;
    public ExamQuestionGroup? Group { get; set; }
}