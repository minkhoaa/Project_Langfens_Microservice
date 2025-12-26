namespace Shared.ExamDto.Contracts.Exam.Enums;

public static class QuestionType
{
	public const string MultipleChoiceSingle = "MULTIPLE_CHOICE_SINGLE";
	public const string MultipleChoiceMultiple = "MULTIPLE_CHOICE_MULTIPLE";
	public const string TrueFalseNotGiven = "TRUE_FALSE_NOT_GIVEN";
	public const string YesNoNotGiven = "YES_NO_NOT_GIVEN";
	public const string MultipleChoiceSingleImage = "MULTIPLE_CHOICE_SINGLE_IMAGE";

	// Completion / short-answer
	public const string SummaryCompletion = "SUMMARY_COMPLETION";
	public const string TableCompletion = "TABLE_COMPLETION";
	public const string NoteCompletion = "NOTE_COMPLETION";
	public const string FormCompletion = "FORM_COMPLETION";
	public const string SentenceCompletion = "SENTENCE_COMPLETION";
	public const string ShortAnswer = "SHORT_ANSWER";
	public const string AudioResponse = "AUDIO_RESPONSE";

	public const string DiagramLabel = "DIAGRAM_LABEL";
	public const string MapLabel = "MAP_LABEL";

	// Matching / ordering
	public const string MatchingHeading = "MATCHING_HEADING";
	public const string MatchingInformation = "MATCHING_INFORMATION";
	public const string MatchingFeatures = "MATCHING_FEATURES";
	public const string MatchingEndings = "MATCHING_ENDINGS";
	public const string Classification = "CLASSIFICATION";

	public const string FlowChart = "FLOW_CHART";
}
