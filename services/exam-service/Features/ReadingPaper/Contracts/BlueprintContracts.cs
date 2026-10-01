using System.Text.Json.Serialization;

namespace exam_service.Features.ReadingPaper.Contracts;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum DifficultyLevel
{
    FOUNDATION,
    MODERATE,
    ADVANCED
}

public sealed record EvidenceGraphRef(
    [property: JsonPropertyName("graphId")] string GraphId,
    [property: JsonPropertyName("sourcePackId")] string SourcePackId,
    [property: JsonPropertyName("version")] string Version,
    [property: JsonPropertyName("contentHash")] string ContentHash,
    [property: JsonPropertyName("status")] string Status = "ACCEPTED",
    [property: JsonPropertyName("claimCount")] int ClaimCount = 0
);

public sealed record TargetDifficulty(
    [property: JsonPropertyName("level")] DifficultyLevel Level,
    [property: JsonPropertyName("rationale")] string Rationale,
    [property: JsonPropertyName("isCalibrated")] bool IsCalibrated = false
);

public sealed record QuestionSlot(
    [property: JsonPropertyName("questionNumber")] int QuestionNumber,
    [property: JsonPropertyName("sectionId")] int SectionId,
    [property: JsonPropertyName("groupIndex")] int GroupIndex,
    [property: JsonPropertyName("questionType")] QuestionType QuestionType,
    [property: JsonPropertyName("targetSkill")] string TargetSkill,
    [property: JsonPropertyName("targetDifficulty")] TargetDifficulty TargetDifficulty,
    [property: JsonPropertyName("claimRefIds")] List<string> ClaimRefIds,
    [property: JsonPropertyName("isNotGivenTarget")] bool IsNotGivenTarget = false,
    [property: JsonPropertyName("maxConcentrationPerParagraph")] int MaxConcentrationPerParagraph = 2
);

public sealed record PassageObjective(
    [property: JsonPropertyName("objectiveId")] string ObjectiveId,
    [property: JsonPropertyName("description")] string Description,
    [property: JsonPropertyName("mappedClaimIds")] List<string> MappedClaimIds,
    [property: JsonPropertyName("role")] string Role = "factual_foundation"
);

public sealed record BudgetAllocation(
    [property: JsonPropertyName("maxCandidatesPerSlot")] int MaxCandidatesPerSlot = 1,
    [property: JsonPropertyName("repairHeadroomCalls")] int RepairHeadroomCalls = 2,
    [property: JsonPropertyName("maxTokensAllocated")] int MaxTokensAllocated = 15000,
    [property: JsonPropertyName("costCapUsd")] double? CostCapUsd = null,
    [property: JsonPropertyName("parentReservationId")] string? ParentReservationId = null
);

public sealed record QuestionTypeAllocation(
    [property: JsonPropertyName("questionType")] QuestionType QuestionType,
    [property: JsonPropertyName("count")] int Count,
    [property: JsonPropertyName("startQuestionNumber")] int StartQuestionNumber,
    [property: JsonPropertyName("endQuestionNumber")] int EndQuestionNumber
);

public sealed record SectionBlueprint(
    [property: JsonPropertyName("sectionId")] int SectionId,
    [property: JsonPropertyName("topic")] string Topic,
    [property: JsonPropertyName("targetWordCount")] int TargetWordCount,
    [property: JsonPropertyName("evidenceGraphRef")] EvidenceGraphRef? EvidenceGraphRef,
    [property: JsonPropertyName("passageObjectives")] List<PassageObjective> PassageObjectives,
    [property: JsonPropertyName("questionAllocations")] List<QuestionTypeAllocation> QuestionAllocations,
    [property: JsonPropertyName("questionSlots")] List<QuestionSlot> QuestionSlots,
    [property: JsonPropertyName("budgetAllocation")] BudgetAllocation? BudgetAllocation,
    [property: JsonPropertyName("totalQuestions")] int TotalQuestions
);

public sealed record ExamBlueprint(
    [property: JsonPropertyName("blueprintId")] string BlueprintId,
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("policyVersion")] string PolicyVersion,
    [property: JsonPropertyName("schemaVersion")] string SchemaVersion,
    [property: JsonPropertyName("sections")] List<SectionBlueprint> Sections,
    [property: JsonPropertyName("totalQuestions")] int TotalQuestions,
    [property: JsonPropertyName("targetWordCountMin")] int TargetWordCountMin,
    [property: JsonPropertyName("targetWordCountMax")] int TargetWordCountMax,
    [property: JsonPropertyName("parentBudgetCapTokens")] int? ParentBudgetCapTokens,
    [property: JsonPropertyName("contentHash")] string? ContentHash,
    [property: JsonPropertyName("invalidatedDescendants")] bool InvalidatedDescendants,
    [property: JsonPropertyName("createdAt")] DateTime CreatedAt
);

public sealed record BlueprintIssue(
    [property: JsonPropertyName("code")] string Code,
    [property: JsonPropertyName("severity")] string Severity,
    [property: JsonPropertyName("message")] string Message,
    [property: JsonPropertyName("field")] string Field
);

public static class BlueprintValidator
{
    public const string PolicyVersion = "v2.0.0";
    public const int SectionMinWords = 720;
    public const int SectionMaxWords = 915;
    public const int PaperMinWords = 2150;
    public const int PaperMaxWords = 2750;
    public const int TotalPaperQuestions = 40;

    public static List<BlueprintIssue> ValidateBlueprint(ExamBlueprint blueprint)
    {
        var issues = new List<BlueprintIssue>();

        // 1. Total questions
        if (blueprint.TotalQuestions != TotalPaperQuestions)
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_INVALID_TOTAL_QUESTIONS",
                "BLOCKING",
                $"ExamBlueprint total questions is {blueprint.TotalQuestions}; expected {TotalPaperQuestions}.",
                "totalQuestions"
            ));
        }

        // 2. Section count and IDs
        var sections = blueprint.Sections ?? new List<SectionBlueprint>();
        if (sections.Count != 3)
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_INVALID_SECTION_COUNT",
                "BLOCKING",
                $"ExamBlueprint has {sections.Count} sections; expected exactly 3.",
                "sections"
            ));
        }

        var secIds = sections.Select(s => s.SectionId).OrderBy(id => id).ToList();
        if (!secIds.SequenceEqual(new[] { 1, 2, 3 }))
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_INVALID_SECTION_IDS",
                "BLOCKING",
                $"Sections must be exactly [1, 2, 3]; got [{string.Join(", ", secIds)}].",
                "sections"
            ));
        }

        // 3. Target words
        if (blueprint.TargetWordCountMin < PaperMinWords)
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_WORD_COUNT_MIN_TOO_LOW",
                "BLOCKING",
                $"targetWordCountMin {blueprint.TargetWordCountMin} < {PaperMinWords}.",
                "targetWordCountMin"
            ));
        }
        if (blueprint.TargetWordCountMax > PaperMaxWords)
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_WORD_COUNT_MAX_TOO_HIGH",
                "BLOCKING",
                $"targetWordCountMax {blueprint.TargetWordCountMax} > {PaperMaxWords}.",
                "targetWordCountMax"
            ));
        }

        // 4. Slots contiguous 1..40
        var allSlots = sections.SelectMany(s => s.QuestionSlots ?? new List<QuestionSlot>()).ToList();
        var slotNumbers = allSlots.Select(s => s.QuestionNumber).OrderBy(n => n).ToList();
        var expectedNumbers = Enumerable.Range(1, 40).ToList();

        if (!slotNumbers.SequenceEqual(expectedNumbers))
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_SLOTS_NOT_CONTIGUOUS_1_TO_40",
                "BLOCKING",
                "Question slots must be contiguous 1..40 without missing or duplicate numbers.",
                "questionSlots"
            ));
        }

        // 5. Section-specific checks
        var totalPlannedTokens = 0;
        foreach (var sec in sections)
        {
            if (sec.TargetWordCount < SectionMinWords || sec.TargetWordCount > SectionMaxWords)
            {
                issues.Add(new BlueprintIssue(
                    "BLUEPRINT_SECTION_WORD_COUNT_OUT_OF_RANGE",
                    "BLOCKING",
                    $"Section {sec.SectionId} target word count {sec.TargetWordCount} not in [{SectionMinWords}, {SectionMaxWords}].",
                    $"sections[{sec.SectionId}].targetWordCount"
                ));
            }

            if (sec.EvidenceGraphRef == null)
            {
                issues.Add(new BlueprintIssue(
                    "BLUEPRINT_MISSING_GRAPH_REF",
                    "BLOCKING",
                    $"Section {sec.SectionId} is missing evidenceGraphRef.",
                    $"sections[{sec.SectionId}].evidenceGraphRef"
                ));
            }
            else
            {
                if (sec.EvidenceGraphRef.Status != "ACCEPTED")
                {
                    issues.Add(new BlueprintIssue(
                        "BLUEPRINT_GRAPH_REF_NOT_ACCEPTED",
                        "BLOCKING",
                        $"Section {sec.SectionId} references EvidenceGraph with status '{sec.EvidenceGraphRef.Status}'; must be ACCEPTED.",
                        $"sections[{sec.SectionId}].evidenceGraphRef.status"
                    ));
                }
                if (string.IsNullOrWhiteSpace(sec.EvidenceGraphRef.ContentHash))
                {
                    issues.Add(new BlueprintIssue(
                        "BLUEPRINT_GRAPH_REF_EMPTY_HASH",
                        "BLOCKING",
                        $"Section {sec.SectionId} EvidenceGraph ref has empty contentHash.",
                        $"sections[{sec.SectionId}].evidenceGraphRef.contentHash"
                    ));
                }
            }

            var slots = sec.QuestionSlots ?? new List<QuestionSlot>();
            // Group checks
            if (sec.SectionId == 1)
            {
                ValidateGroup(sec.SectionId, slots, 0, QuestionType.TRUE_FALSE_NOT_GIVEN, 7, 1, 7, issues);
                ValidateGroup(sec.SectionId, slots, 1, QuestionType.SENTENCE_COMPLETION, 6, 8, 13, issues);
            }
            else if (sec.SectionId == 2)
            {
                ValidateGroup(sec.SectionId, slots, 0, QuestionType.MULTIPLE_CHOICE_SINGLE, 6, 14, 19, issues);
                ValidateGroup(sec.SectionId, slots, 1, QuestionType.SUMMARY_COMPLETION, 7, 20, 26, issues);
            }
            else if (sec.SectionId == 3)
            {
                ValidateGroup(sec.SectionId, slots, 0, QuestionType.YES_NO_NOT_GIVEN, 7, 27, 33, issues);
                ValidateGroup(sec.SectionId, slots, 1, QuestionType.SHORT_ANSWER, 7, 34, 40, issues);
            }

            if (sec.BudgetAllocation != null)
            {
                totalPlannedTokens += sec.BudgetAllocation.MaxTokensAllocated;
                if (sec.BudgetAllocation.MaxCandidatesPerSlot > 3)
                {
                    issues.Add(new BlueprintIssue(
                        "BLUEPRINT_CANDIDATE_ALLOCATION_EXCEEDS_CAP",
                        "BLOCKING",
                        $"Section {sec.SectionId} allocated {sec.BudgetAllocation.MaxCandidatesPerSlot} candidates per slot (cap is 3).",
                        $"sections[{sec.SectionId}].budgetAllocation.maxCandidatesPerSlot"
                    ));
                }
            }
        }

        if (blueprint.ParentBudgetCapTokens.HasValue && totalPlannedTokens > blueprint.ParentBudgetCapTokens.Value)
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_BUDGET_EXCEEDS_PARENT_CAP",
                "BLOCKING",
                $"Total planned tokens {totalPlannedTokens} exceeds parent cap {blueprint.ParentBudgetCapTokens.Value}.",
                "parentBudgetCapTokens"
            ));
        }

        return issues;
    }

    private static void ValidateGroup(
        int sectionId,
        List<QuestionSlot> slots,
        int groupIndex,
        QuestionType expectedType,
        int expectedCount,
        int startQ,
        int endQ,
        List<BlueprintIssue> issues)
    {
        var grpSlots = slots.Where(s => s.GroupIndex == groupIndex).ToList();
        if (grpSlots.Count != expectedCount)
        {
            issues.Add(new BlueprintIssue(
                "BLUEPRINT_GROUP_COUNT_MISMATCH",
                "BLOCKING",
                $"Section {sectionId} Group {groupIndex} has {grpSlots.Count} slots; expected {expectedCount}.",
                $"sections[{sectionId}].questionSlots"
            ));
        }

        foreach (var slot in grpSlots)
        {
            if (slot.QuestionType != expectedType)
            {
                issues.Add(new BlueprintIssue(
                    "BLUEPRINT_SLOT_TYPE_MISMATCH",
                    "BLOCKING",
                    $"Question {slot.QuestionNumber} in Section {sectionId} has type {slot.QuestionType}; expected {expectedType}.",
                    $"sections[{sectionId}].questionSlots[{slot.QuestionNumber}].questionType"
                ));
            }

            if (slot.TargetDifficulty.IsCalibrated)
            {
                issues.Add(new BlueprintIssue(
                    "BLUEPRINT_CALIBRATED_DIFFICULTY_PROHIBITED",
                    "BLOCKING",
                    $"Question {slot.QuestionNumber} claims calibrated difficulty. Pre-pilot calibrated difficulty is prohibited.",
                    $"sections[{sectionId}].questionSlots[{slot.QuestionNumber}].targetDifficulty.isCalibrated"
                ));
            }

            if (string.IsNullOrWhiteSpace(slot.TargetDifficulty.Rationale))
            {
                issues.Add(new BlueprintIssue(
                    "BLUEPRINT_DIFFICULTY_RATIONALE_MISSING",
                    "BLOCKING",
                    $"Question {slot.QuestionNumber} lacks targetDifficulty rationale.",
                    $"sections[{sectionId}].questionSlots[{slot.QuestionNumber}].targetDifficulty.rationale"
                ));
            }
        }
    }
}
