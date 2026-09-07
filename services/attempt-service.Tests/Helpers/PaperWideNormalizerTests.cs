using System;
using System.Collections.Generic;
using System.Text.Json;
using Shared.ExamDto.Contracts.Exam.InternalExamDto;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class PaperWideNormalizerTests
{
    private static InternalExamDto.InternalDeliveryQuestion MakeQuestion(Guid id, int idx) =>
        new()
        {
            Id = id,
            Idx = idx,
            Type = "MULTIPLE_CHOICE_SINGLE",
            Skill = "READING",
            Difficulty = 1,
            PromptMd = $"Question {idx}",
        };

    private static InternalExamDto.InternalDeliveryQuestionGroup MakeGroup(Guid id, int idx, int startIdx, int endIdx, params InternalExamDto.InternalDeliveryQuestion[] questions) =>
        new()
        {
            Id = id,
            Idx = idx,
            StartIdx = startIdx,
            EndIdx = endIdx,
            InstructionMd = $"Group {idx}",
            Questions = questions,
        };

    private static InternalExamDto.InternalDeliverySection MakeSection(Guid id, int idx, params InternalExamDto.InternalDeliveryQuestionGroup[] groups) =>
        new()
        {
            Id = id,
            Idx = idx,
            Title = $"Section {idx}",
            QuestionGroups = groups,
        };

    [Fact]
    public void Normalize_EmptyPaper_ReturnsEmpty()
    {
        var exam = new InternalExamDto.InternalDeliveryExam
        {
            Id = Guid.NewGuid(),
            Title = "Empty Exam",
            Sections = Array.Empty<InternalExamDto.InternalDeliverySection>(),
        };

        var result = PaperWideNormalizer.Normalize(exam);

        Assert.NotNull(result);
        Assert.Empty(result.Sections);
    }

    [Fact]
    public void Normalize_SingleSectionOneGroup_RenumbersCorrectly()
    {
        var q1 = MakeQuestion(Guid.NewGuid(), 0);
        var q2 = MakeQuestion(Guid.NewGuid(), 0);
        var q3 = MakeQuestion(Guid.NewGuid(), 0);
        var group = MakeGroup(Guid.NewGuid(), 1, 0, 0, q1, q2, q3);
        var section = MakeSection(Guid.NewGuid(), 1, group);

        var exam = new InternalExamDto.InternalDeliveryExam
        {
            Id = Guid.NewGuid(),
            Title = "Test Exam",
            Sections = new[] { section },
        };

        var result = PaperWideNormalizer.Normalize(exam);

        var resGroup = result.Sections[0].QuestionGroups[0];
        Assert.Equal(1, resGroup.StartIdx);
        Assert.Equal(3, resGroup.EndIdx);
        Assert.Equal(1, resGroup.Questions[0].Idx);
        Assert.Equal(2, resGroup.Questions[1].Idx);
        Assert.Equal(3, resGroup.Questions[2].Idx);
    }

    [Fact]
    public void Normalize_TwoSections_WorkedExampleFromSpec()
    {
        // Section 1: 7 questions (originally with reset/missing idx)
        var s1Questions = new List<InternalExamDto.InternalDeliveryQuestion>();
        for (int i = 0; i < 7; i++) s1Questions.Add(MakeQuestion(Guid.NewGuid(), 0));
        var g1 = MakeGroup(Guid.NewGuid(), 1, 1, 4, s1Questions.ToArray());
        var sec1 = MakeSection(Guid.NewGuid(), 1, g1);

        // Section 2: 6 questions (originally startIdx reset to 1)
        var s2Questions = new List<InternalExamDto.InternalDeliveryQuestion>();
        for (int i = 0; i < 6; i++) s2Questions.Add(MakeQuestion(Guid.NewGuid(), 0));
        var g2 = MakeGroup(Guid.NewGuid(), 1, 1, 6, s2Questions.ToArray());
        var sec2 = MakeSection(Guid.NewGuid(), 2, g2);

        var exam = new InternalExamDto.InternalDeliveryExam
        {
            Id = Guid.NewGuid(),
            Title = "IELTS Reading",
            Sections = new[] { sec1, sec2 },
        };

        var result = PaperWideNormalizer.Normalize(exam);

        // Section 1: 1..7
        var resG1 = result.Sections[0].QuestionGroups[0];
        Assert.Equal(1, resG1.StartIdx);
        Assert.Equal(7, resG1.EndIdx);
        for (int i = 0; i < 7; i++)
        {
            Assert.Equal(i + 1, resG1.Questions[i].Idx);
        }

        // Section 2: 8..13
        var resG2 = result.Sections[1].QuestionGroups[0];
        Assert.Equal(8, resG2.StartIdx);
        Assert.Equal(13, resG2.EndIdx);
        for (int i = 0; i < 6; i++)
        {
            Assert.Equal(8 + i, resG2.Questions[i].Idx);
        }
    }

    [Fact]
    public void Normalize_MultipleGroupsPerSection_ContinuousIndices()
    {
        var g1Qs = new[] { MakeQuestion(Guid.NewGuid(), 0), MakeQuestion(Guid.NewGuid(), 0), MakeQuestion(Guid.NewGuid(), 0) };
        var g2Qs = new[] { MakeQuestion(Guid.NewGuid(), 0), MakeQuestion(Guid.NewGuid(), 0) };
        var g1 = MakeGroup(Guid.NewGuid(), 1, 1, 1, g1Qs);
        var g2 = MakeGroup(Guid.NewGuid(), 2, 1, 1, g2Qs);
        var sec = MakeSection(Guid.NewGuid(), 1, g1, g2);

        var exam = new InternalExamDto.InternalDeliveryExam
        {
            Id = Guid.NewGuid(),
            Title = "Multi-Group",
            Sections = new[] { sec },
        };

        var result = PaperWideNormalizer.Normalize(exam);

        var resG1 = result.Sections[0].QuestionGroups[0];
        Assert.Equal(1, resG1.StartIdx);
        Assert.Equal(3, resG1.EndIdx);

        var resG2 = result.Sections[0].QuestionGroups[1];
        Assert.Equal(4, resG2.StartIdx);
        Assert.Equal(5, resG2.EndIdx);
    }

    [Fact]
    public void Normalize_OutOrderSectionIdx_SortsAndNumbersConsistently()
    {
        var sec2Qs = new[] { MakeQuestion(Guid.NewGuid(), 0), MakeQuestion(Guid.NewGuid(), 0) };
        var sec1Qs = new[] { MakeQuestion(Guid.NewGuid(), 0) };

        var sec2 = MakeSection(Guid.NewGuid(), 2, MakeGroup(Guid.NewGuid(), 1, 0, 0, sec2Qs));
        var sec1 = MakeSection(Guid.NewGuid(), 1, MakeGroup(Guid.NewGuid(), 1, 0, 0, sec1Qs));

        // Passed in reverse section order
        var exam = new InternalExamDto.InternalDeliveryExam
        {
            Id = Guid.NewGuid(),
            Title = "Reverse Section",
            Sections = new[] { sec2, sec1 },
        };

        var result = PaperWideNormalizer.Normalize(exam);

        // Section 1 should be processed first (gets question 1)
        Assert.Equal(1, result.Sections[0].Idx);
        Assert.Equal(1, result.Sections[0].QuestionGroups[0].StartIdx);
        Assert.Equal(1, result.Sections[0].QuestionGroups[0].EndIdx);

        // Section 2 should be processed second (gets questions 2, 3)
        Assert.Equal(2, result.Sections[1].Idx);
        Assert.Equal(2, result.Sections[1].QuestionGroups[0].StartIdx);
        Assert.Equal(3, result.Sections[1].QuestionGroups[0].EndIdx);
    }

    [Fact]
    public void NormalizeJsonElement_StandardPaper_RewritesIndicesPaperWide()
    {
        var json = """
        {
            "id": "01a07b03-abde-786b-8642-c79fe05a635d",
            "sections": [
                {
                    "idx": 1,
                    "questionGroups": [
                        {
                            "startIdx": 1,
                            "endIdx": 4,
                            "questions": [
                                { "id": "q1", "idx": 0 },
                                { "id": "q2", "idx": 0 },
                                { "id": "q3", "idx": 0 },
                                { "id": "q4", "idx": 0 },
                                { "id": "q5", "idx": 0 }
                            ]
                        }
                    ]
                },
                {
                    "idx": 2,
                    "questionGroups": [
                        {
                            "startIdx": 1,
                            "endIdx": 4,
                            "questions": [
                                { "id": "q6", "idx": 0 },
                                { "id": "q7", "idx": 0 },
                                { "id": "q8", "idx": 0 },
                                { "id": "q9", "idx": 0 },
                                { "id": "q10", "idx": 0 }
                            ]
                        }
                    ]
                }
            ]
        }
        """;

        using var doc = JsonDocument.Parse(json);
        var normalized = PaperWideNormalizer.NormalizeJsonElement(doc.RootElement);

        var sec1Group = normalized.GetProperty("sections")[0].GetProperty("questionGroups")[0];
        Assert.Equal(1, sec1Group.GetProperty("startIdx").GetInt32());
        Assert.Equal(5, sec1Group.GetProperty("endIdx").GetInt32());
        Assert.Equal(1, sec1Group.GetProperty("questions")[0].GetProperty("idx").GetInt32());
        Assert.Equal(5, sec1Group.GetProperty("questions")[4].GetProperty("idx").GetInt32());

        var sec2Group = normalized.GetProperty("sections")[1].GetProperty("questionGroups")[0];
        Assert.Equal(6, sec2Group.GetProperty("startIdx").GetInt32());
        Assert.Equal(10, sec2Group.GetProperty("endIdx").GetInt32());
        Assert.Equal(6, sec2Group.GetProperty("questions")[0].GetProperty("idx").GetInt32());
        Assert.Equal(10, sec2Group.GetProperty("questions")[4].GetProperty("idx").GetInt32());
    }

    [Fact]
    public void NormalizeJsonElement_LegacySectionWithoutGroups_SynthesizesImplicitGroup()
    {
        var json = """
        {
            "id": "legacy-exam",
            "sections": [
                {
                    "idx": 1,
                    "questions": [
                        { "id": "q1", "idx": 1 },
                        { "id": "q2", "idx": 2 },
                        { "id": "q3", "idx": 3 }
                    ]
                },
                {
                    "idx": 2,
                    "questions": [
                        { "id": "q4", "idx": 1 },
                        { "id": "q5", "idx": 2 }
                    ]
                }
            ]
        }
        """;

        using var doc = JsonDocument.Parse(json);
        var normalized = PaperWideNormalizer.NormalizeJsonElement(doc.RootElement);

        var sec1 = normalized.GetProperty("sections")[0];
        var sec1Group = sec1.GetProperty("questionGroups")[0];
        Assert.Equal(1, sec1Group.GetProperty("startIdx").GetInt32());
        Assert.Equal(3, sec1Group.GetProperty("endIdx").GetInt32());
        Assert.Equal(1, sec1Group.GetProperty("questions")[0].GetProperty("idx").GetInt32());
        Assert.Equal(3, sec1Group.GetProperty("questions")[2].GetProperty("idx").GetInt32());

        var sec2 = normalized.GetProperty("sections")[1];
        var sec2Group = sec2.GetProperty("questionGroups")[0];
        Assert.Equal(4, sec2Group.GetProperty("startIdx").GetInt32());
        Assert.Equal(5, sec2Group.GetProperty("endIdx").GetInt32());
        Assert.Equal(4, sec2Group.GetProperty("questions")[0].GetProperty("idx").GetInt32());
        Assert.Equal(5, sec2Group.GetProperty("questions")[1].GetProperty("idx").GetInt32());
    }
}
