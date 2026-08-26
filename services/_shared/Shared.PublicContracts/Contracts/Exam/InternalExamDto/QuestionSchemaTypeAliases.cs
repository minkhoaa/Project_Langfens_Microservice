// Phase 2 type aliases re-exporting the SSOT-derived NSwag-generated
// `*Payload`, `*Answer`, and `Envelope_<Variant>` records under the legacy
// `Shared.ExamDto.Contracts.Exam.InternalExamDto` namespace so existing
// consumers can opt in incrementally without rewiring every call site.
//
// Wire-format caveat: the generated types use the polymorphic
// `QuestionEnvelope` discriminator (one `type` field) and per-type
// `payload` / `correctAnswer` properties. The legacy `InternalDelivery*`
// records use a flat shape with `string Type`, `IReadOnlyDictionary<...>`
// and `IReadOnlyList<...>` for blanks/match-pairs/etc. The two wire
// shapes are NOT interchangeable; a consumer that switches to the
// generated types must also rewrite the deserialisation path. See
// `services/attempt-service/Features/Helpers/BuildQuestionIdSet.cs` for
// the planned migration in Phase 2.5.
using Shared.PublicContracts.Generated;

namespace Shared.ExamDto.Contracts.Exam.InternalExamDto;

/// <summary>
/// Lookup tables mapping canonical question-type slugs to their generated
/// payload, answer, and envelope CLR types. Useful when a consumer wants to
/// resolve `q.Type` to the corresponding generated record class for
/// polymorphic deserialisation.
/// </summary>
public static class QuestionSchemaAliases
{
    /// <summary>Variant envelope types — only types with cross-reference `superRefine` rules get a dedicated CLR record.</summary>
    public static readonly System.Collections.Generic.IReadOnlyDictionary<string, System.Type> EnvelopeByType =
        new System.Collections.Generic.Dictionary<string, System.Type>(System.StringComparer.Ordinal)
        {
            ["FLOW_CHART"] = typeof(Envelope_FlowChart),
            ["FLOW_CHART_COMPLETION"] = typeof(Envelope_FlowChartCompletion),
            ["MULTIPLE_CHOICE_MULTIPLE"] = typeof(Envelope_MultipleChoiceMultiple),
            ["MATCHING_HEADING"] = typeof(Envelope_MatchingHeading),
            ["MATCHING_INFORMATION"] = typeof(Envelope_MatchingInformation),
        };

    /// <summary>Per-type payload aliases — every canonical slug has a matching `*Payload` record.</summary>
    public static readonly System.Collections.Generic.IReadOnlyDictionary<string, System.Type> PayloadByType =
        new System.Collections.Generic.Dictionary<string, System.Type>(System.StringComparer.Ordinal)
        {
            ["MULTIPLE_CHOICE_SINGLE"] = typeof(MultipleChoiceSinglePayload),
            ["MULTIPLE_CHOICE_SINGLE_IMAGE"] = typeof(MultipleChoiceSingleImagePayload),
            ["MULTIPLE_CHOICE_MULTIPLE"] = typeof(MultipleChoiceMultiplePayload),
            ["TRUE_FALSE_NOT_GIVEN"] = typeof(TrueFalseNotGivenPayload),
            ["YES_NO_NOT_GIVEN"] = typeof(YesNoNotGivenPayload),
            ["SUMMARY_COMPLETION"] = typeof(SummaryCompletionPayload),
            ["TABLE_COMPLETION"] = typeof(TableCompletionPayload),
            ["NOTE_COMPLETION"] = typeof(NoteCompletionPayload),
            ["FORM_COMPLETION"] = typeof(FormCompletionPayload),
            ["SENTENCE_COMPLETION"] = typeof(SentenceCompletionPayload),
            ["SHORT_ANSWER"] = typeof(ShortAnswerPayload),
            ["AUDIO_RESPONSE"] = typeof(AudioResponsePayload),
            ["DIAGRAM_LABEL"] = typeof(DiagramLabelPayload),
            ["MAP_LABEL"] = typeof(MapLabelPayload),
            ["MATCHING_HEADING"] = typeof(MatchingHeadingPayload),
            ["MATCHING_INFORMATION"] = typeof(MatchingInformationPayload),
            ["MATCHING_FEATURES"] = typeof(MatchingFeaturesPayload),
            ["MATCHING_ENDINGS"] = typeof(MatchingEndingsPayload),
            ["CLASSIFICATION"] = typeof(ClassificationPayload),
            ["FLOW_CHART"] = typeof(FlowChartPayload),
            ["FLOW_CHART_COMPLETION"] = typeof(FlowChartCompletionPayload),
        };

    /// <summary>Per-type answer aliases — every canonical slug has a matching `*Answer` record.</summary>
    public static readonly System.Collections.Generic.IReadOnlyDictionary<string, System.Type> AnswerByType =
        new System.Collections.Generic.Dictionary<string, System.Type>(System.StringComparer.Ordinal)
        {
            ["MULTIPLE_CHOICE_SINGLE"] = typeof(MultipleChoiceSingleAnswer),
            ["MULTIPLE_CHOICE_SINGLE_IMAGE"] = typeof(MultipleChoiceSingleImageAnswer),
            ["MULTIPLE_CHOICE_MULTIPLE"] = typeof(MultipleChoiceMultipleAnswer),
            ["TRUE_FALSE_NOT_GIVEN"] = typeof(TrueFalseNotGivenAnswer),
            ["YES_NO_NOT_GIVEN"] = typeof(YesNoNotGivenAnswer),
            ["SUMMARY_COMPLETION"] = typeof(SummaryCompletionAnswer),
            ["TABLE_COMPLETION"] = typeof(TableCompletionAnswer),
            ["NOTE_COMPLETION"] = typeof(NoteCompletionAnswer),
            ["FORM_COMPLETION"] = typeof(FormCompletionAnswer),
            ["SENTENCE_COMPLETION"] = typeof(SentenceCompletionAnswer),
            ["SHORT_ANSWER"] = typeof(ShortAnswerAnswer),
            ["AUDIO_RESPONSE"] = typeof(AudioResponseAnswer),
            ["DIAGRAM_LABEL"] = typeof(DiagramLabelAnswer),
            ["MAP_LABEL"] = typeof(MapLabelAnswer),
            ["MATCHING_HEADING"] = typeof(MatchingHeadingAnswer),
            ["MATCHING_INFORMATION"] = typeof(MatchingInformationAnswer),
            ["MATCHING_FEATURES"] = typeof(MatchingFeaturesAnswer),
            ["MATCHING_ENDINGS"] = typeof(MatchingEndingsAnswer),
            ["CLASSIFICATION"] = typeof(ClassificationAnswer),
            ["FLOW_CHART"] = typeof(FlowChartAnswer),
            ["FLOW_CHART_COMPLETION"] = typeof(FlowChartCompletionAnswer),
        };
}