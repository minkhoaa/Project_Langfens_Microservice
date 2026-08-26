using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;

namespace ExamService.Features.Validation;

public sealed class EnvelopeValidator
{
    private static readonly JsonSerializerOptions JsonOpts = new(JsonSerializerDefaults.Web);

    public EnvelopeValid Validate(JsonElement envelopeJson)
    {
        if (envelopeJson.ValueKind != JsonValueKind.Object)
                {
                throw new EnvelopeValidationException("envelope must be a JSON object");
        }

        // 1. Top-level discriminator (the wire "type" field)
        if (!envelopeJson.TryGetProperty("type", out var typeEl) || typeEl.ValueKind != JsonValueKind.String)
                {
                throw new EnvelopeValidationException("envelope.type missing or not a string");
        }

        var slug = typeEl.GetString()!;

        // 2. Payload JSON element (we re-serialize to drive the typed deserialization)
        if (!envelopeJson.TryGetProperty("payload", out var payloadEl))
                {
                throw new EnvelopeValidationException("envelope.payload missing");
        }

        // 3. Look up the typed payload record for this slug
        if (!QuestionSchemaAliases.PayloadByType.TryGetValue(slug, out var payloadType))
                {
                throw new EnvelopeValidationException($"unknown slug: '{slug}'");
        }

        // 4. Deserialize into the NSwag-generated typed record.
        object payload;
        try
        {
            payload = JsonSerializer.Deserialize(payloadEl.GetRawText(), payloadType, JsonOpts)
                      ?? throw new EnvelopeValidationException("payload deserialized to null");
        }
        catch (JsonException ex)
        {
            throw new EnvelopeValidationException($"payload JSON invalid: {ex.Message}");
        }

        // 5. Discriminator agreement check (Q2): payload.Type == envelope.type.
        // The generated `Type` property is typed as the per-slug enum with [JsonStringEnumConverter],
        // so after deserialization it is an enum value whose ToString() yields the slug
        // (e.g. `MultipleChoiceSinglePayloadType.MULTIPLE_CHOICE_SINGLE.ToString() == "MULTIPLE_CHOICE_SINGLE"`).
        var payloadTypeProp = payloadType.GetProperty("Type");
        var payloadTypeField = payloadTypeProp?.GetValue(payload)?.ToString();
        if (!string.Equals(slug, payloadTypeField, StringComparison.Ordinal))
                {
                throw new EnvelopeValidationException(
                    $"discriminator mismatch: envelope.type='{slug}' payload.type='{payloadTypeField}'");
        }

        // 6. NSwag-generated DataAnnotations on the typed payload record
        //    ([Required], [Range], [MinLength], [RegularExpression], ...).
        var ctx = new ValidationContext(payload);
        var errors = new List<ValidationResult>();
        if (!Validator.TryValidateObject(payload, ctx, errors, validateAllProperties: true))
                {
                throw new EnvelopeValidationException(errors);
        }

        return new EnvelopeValid(envelopeJson, (payload, payloadType));
    }
}

public sealed record EnvelopeValid(JsonElement Envelope, (object Payload, Type PayloadType) Typed);

public sealed class EnvelopeValidationException : Exception
{
    public IReadOnlyList<ValidationResult> Errors { get; }

    public EnvelopeValidationException(string msg) : base(msg)
    {
        Errors = Array.Empty<ValidationResult>();
    }

    public EnvelopeValidationException(IEnumerable<ValidationResult> errors)
        : base(BuildMessage(errors))
    {
        Errors = errors.ToList();
    }

    private static string BuildMessage(IEnumerable<ValidationResult> errors) =>
        "envelope failed validation: " + string.Join("; ", errors.Select(e =>
            $"{string.Join(",", e.MemberNames)}: {e.ErrorMessage}"));
}