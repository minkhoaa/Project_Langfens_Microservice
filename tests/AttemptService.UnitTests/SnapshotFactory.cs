namespace AttemptService.UnitTests;

internal static class SnapshotFactory
{
    public static InternalDeliveryExam CreateProtoExam(bool includeAnswers = true)
    {
        var examId = Guid.NewGuid();
        var sectionId = Guid.NewGuid();
        var questionId = Guid.NewGuid();

        var exam = new InternalDeliveryExam
        {
            Id = examId.ToString(),
            Title = "Sample Exam",
            Slug = "sample-exam",
            DurationMin = 20
        };

        var section = new InternalDeliverySection
        {
            Id = sectionId.ToString(),
            Title = "Section 1",
            InstructionsMd = "Do it",
            Idx = 1,
            AudioUrl = "https://example.com/audio.mp3",
            TranscriptMd = "Transcript"
        };

        var question = new InternalDeliveryQuestion
        {
            Id = questionId.ToString(),
            Idx = 1,
            Type = "MULTIPLE_CHOICE_SINGLE",
            Skill = "Reading",
            PromptMd = "What is correct?",
            Difficulty = 1
        };

        question.Options.Add(new InternalDeliveryOption
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 1,
            ContentMd = "Option A",
            IsCorrect = includeAnswers
        });
        question.Options.Add(new InternalDeliveryOption
        {
            Id = Guid.NewGuid().ToString(),
            Idx = 2,
            ContentMd = "Option B",
            IsCorrect = false
        });

        section.Questions.Add(question);
        exam.Sections.Add(section);
        return exam;
    }

    public static InternalExamDto.InternalDeliveryExam CreateDtoExam()
    {
        var examId = Guid.NewGuid();
        var sectionId = Guid.NewGuid();
        var questionId = Guid.NewGuid();
        return new InternalExamDto.InternalDeliveryExam
        {
            Id = examId,
            Slug = "dto-exam",
            Title = "DTO Exam",
            DescriptionMd = "desc",
            Category = "IELTS",
            Level = "B1",
            DurationMin = 15,
            Sections = new List<InternalExamDto.InternalDeliverySection>
            {
                new InternalExamDto.InternalDeliverySection
                {
                    Id = sectionId,
                    Idx = 1,
                    Title = "Section DTO",
                    InstructionsMd = "Read carefully",
                    AudioUrl = "https://example.com/audio.mp3",
                    TranscriptMd = "Transcript",
                    Questions = new List<InternalExamDto.InternalDeliveryQuestion>
                    {
                        new InternalExamDto.InternalDeliveryQuestion
                        {
                            Id = questionId,
                            Idx = 1,
                            Type = "MULTIPLE_CHOICE_SINGLE",
                            Skill = "Listening",
                            Difficulty = 1,
                            PromptMd = "DTO Question",
                            ExplanationMd = "Explained",
                            Options = new List<InternalExamDto.InternalDeliveryOption>
                            {
                                new InternalExamDto.InternalDeliveryOption
                                {
                                    Id = Guid.NewGuid(),
                                    Idx = 1,
                                    ContentMd = "Dto A",
                                    IsCorrect = true
                                },
                                new InternalExamDto.InternalDeliveryOption
                                {
                                    Id = Guid.NewGuid(),
                                    Idx = 2,
                                    ContentMd = "Dto B",
                                    IsCorrect = false
                                }
                            }
                        }
                    }
                }
            }
        };
    }
}
