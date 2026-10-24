using System.Text.Json;
using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum QuestionType
{
    TRUE_FALSE_NOT_GIVEN,
    YES_NO_NOT_GIVEN,
    SENTENCE_COMPLETION,
    SUMMARY_COMPLETION,
    SUMMARY_COMPLETION_BOX,
    MULTIPLE_CHOICE_SINGLE,
    MULTIPLE_CHOICE_MULTIPLE,
    MATCHING_HEADING,
    MATCHING_INFORMATION,
    MATCHING_FEATURES,
    MATCHING_ENDINGS,
    TABLE_COMPLETION,
    FLOW_CHART,
    DIAGRAM_LABEL,
    SHORT_ANSWER,
    NOTE_COMPLETION,
    FORM_COMPLETION,
    CLASSIFICATION,
    CHOOSING_TITLE,
    MULTIPLE_CHOICE_SINGLE_IMAGE,
    MAP_LABEL
}

public sealed record AbsenceAssessmentDto(
    [property: JsonPropertyName("assessmentId")] string AssessmentId,
    [property: JsonPropertyName("claimOrTopic")] string ClaimOrTopic,
    [property: JsonPropertyName("absenceReason")] string AbsenceReason,
    [property: JsonPropertyName("topicalContextSpan")] string? TopicalContextSpan,
    [property: JsonPropertyName("absenceConfirmed")] bool AbsenceConfirmed
);

public sealed record TopicalContextSpanDto(
    [property: JsonPropertyName("spanId")] string SpanId,
    [property: JsonPropertyName("sectionId")] int SectionId,
    [property: JsonPropertyName("startChar")] int StartChar,
    [property: JsonPropertyName("endChar")] int EndChar,
    [property: JsonPropertyName("snippet")] string Snippet
);

public abstract record BaseQuestionDto(
    [property: JsonPropertyName("questionNumber")] int QuestionNumber,
    [property: JsonPropertyName("explanation")] string Explanation,
    [property: JsonPropertyName("questionType")] QuestionType QuestionType
);

public sealed record TrueFalseNotGivenDto(
    int QuestionNumber,
    string Explanation,
    [property: JsonPropertyName("statement")] string Statement,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("evidenceQuote")] string? EvidenceQuote,
    [property: JsonPropertyName("absenceAssessment")] AbsenceAssessmentDto? AbsenceAssessment
) : BaseQuestionDto(QuestionNumber, Explanation, QuestionType.TRUE_FALSE_NOT_GIVEN);

public sealed record YesNoNotGivenDto(
    int QuestionNumber,
    string Explanation,
    [property: JsonPropertyName("statement")] string Statement,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("evidenceQuote")] string? EvidenceQuote,
    [property: JsonPropertyName("absenceAssessment")] AbsenceAssessmentDto? AbsenceAssessment
) : BaseQuestionDto(QuestionNumber, Explanation, QuestionType.YES_NO_NOT_GIVEN);

public sealed record MultipleChoiceSingleDto(
    int QuestionNumber,
    string Explanation,
    [property: JsonPropertyName("prompt")] string Prompt,
    [property: JsonPropertyName("options")] IReadOnlyList<string> Options,
    [property: JsonPropertyName("correctOption")] string CorrectOption,
    [property: JsonPropertyName("evidenceQuote")] string EvidenceQuote
) : BaseQuestionDto(QuestionNumber, Explanation, QuestionType.MULTIPLE_CHOICE_SINGLE);

public sealed record SentenceCompletionDto(
    int QuestionNumber,
    string Explanation,
    [property: JsonPropertyName("prompt")] string Prompt,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("evidenceQuote")] string EvidenceQuote
) : BaseQuestionDto(QuestionNumber, Explanation, QuestionType.SENTENCE_COMPLETION);

public sealed record SummaryCompletionDto(
    int QuestionNumber,
    string Explanation,
    [property: JsonPropertyName("prompt")] string Prompt,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("evidenceQuote")] string EvidenceQuote
) : BaseQuestionDto(QuestionNumber, Explanation, QuestionType.SUMMARY_COMPLETION);

public sealed record ShortAnswerDto(
    int QuestionNumber,
    string Explanation,
    [property: JsonPropertyName("prompt")] string Prompt,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("evidenceQuote")] string EvidenceQuote
) : BaseQuestionDto(QuestionNumber, Explanation, QuestionType.SHORT_ANSWER);

public sealed record QuestionGroupDto(
    [property: JsonPropertyName("groupId")] string GroupId,
    [property: JsonPropertyName("questionType")] QuestionType QuestionType,
    [property: JsonPropertyName("instructions")] string Instructions,
    [property: JsonPropertyName("questions")] IReadOnlyList<JsonElement> Questions,
    [property: JsonPropertyName("sharedContext")] string? SharedContext
);

public sealed record ReadingSectionDto(
    [property: JsonPropertyName("sectionId")] int SectionId,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("passage")] string Passage,
    [property: JsonPropertyName("wordCount")] int WordCount,
    [property: JsonPropertyName("groups")] IReadOnlyList<QuestionGroupDto> Groups
);

public sealed record ReadingPaperDto(
    [property: JsonPropertyName("paperId")] string PaperId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("sections")] IReadOnlyList<ReadingSectionDto> Sections,
    [property: JsonPropertyName("totalQuestions")] int TotalQuestions,
    [property: JsonPropertyName("totalWordCount")] int TotalWordCount
);
