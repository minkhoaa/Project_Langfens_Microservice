namespace exam_service.Data;


public enum ExamStatus {Draft = 0, Published = 1, Archived = 2};
public enum QuestionSkill {Reading, Listening, Writing, Speaking};
public enum QuestionType
{
    MULTIPLE_CHOICE_SINGLE,
    TRUE_FALSE_NOT_GIVEN,
    YES_NO_NOT_GIVEN,
    SUMMARY_COMPLETION,
    TABLE_COMPLETION,
    NOTE_COMPLETION,
    DIAGRAM_LABEL,
    MAP_LABEL,
    MULTIPLE_CHOICE_SINGLE_IMAGE,
    MATCHING_HEADING,
    FLOW_CHART
}