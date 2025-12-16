// Assuming a clean project setup.
using exam_service.Application.Common;
using exam_service.Domains.Entities;
using FluentAssertions;
using Xunit;
using Shared.Grpc.ExamInternal;
using Section = exam_service.Domains.Entities.ExamSection;
using Question = exam_service.Domains.Entities.ExamQuestion;
using Option = exam_service.Domains.Entities.ExamOption;

namespace ExamService.UnitTests.Application.Common
{
    public class ProtoHelper_Tests
    {
        private static Exam CreateTestExam() => new Exam
        {
            Slug = "slug", Title = "Title", Category = "C", Level = "L",
            Sections = new List<Section>
            {
                new Section
                {
                    Questions = new List<Question>
                    {
                        new Question
                        {
                            ExplanationMd = "Explanation text",
                            OrderCorrects = new List<string> { "B", "A", "C", "A" },
                            Options = new List<Option> { new Option { IsCorrect = true } }
                        }
                    }
                }
            }
        };

        public static IEnumerable<object[]> MapToProtoCases()
        {
            // ES-008
            var exam = CreateTestExam();
            for (var i = 0; i < 11; i++)
            {
                // Alternate showing answers to test both paths
                yield return new object[] { exam, i % 2 == 0 };
            }
        }

        [Theory(DisplayName = "ES-008: MapToProto should handle 'showAnswers' flag")]
        [MemberData(nameof(MapToProtoCases))]
        public void MapToProto_Should_Conditionally_Map_Answers(Exam exam, bool showAnswers)
        {
            // Act
            var result = ProtoHelper.MapToProto(exam, showAnswers);

            // Assert
            var protoQuestion = result.Sections[0].Questions[0];
            var protoOption = protoQuestion.Options[0];

            if (showAnswers)
            {
                protoQuestion.ExplanationMd.Should().Be("Explanation text");
                protoOption.IsCorrect.Should().Be(true);
            }
            else
            {
                protoQuestion.ExplanationMd.Should().BeEmpty();
                protoOption.IsCorrect.Should().Be(false);
            }
        }

        [Fact(DisplayName = "ES-009: BuildFlowChartNodes should create unique, shuffled nodes")]
        public void BuildFlowChartNodes_Should_Create_Unique_Nodes()
        {
            // This tests the private BuildFlowChartNodes method indirectly via MapToProto
            // Arrange
            var exam = CreateTestExam();
            var question = exam.Sections[0].Questions[0];
            
            // Act
            var result = ProtoHelper.MapToProto(exam, true);

            // Assert
            var protoQuestion = result.Sections.First().Questions.First();
            protoQuestion.FlowChartNodes.Should().NotBeNull();
            // Should be unique
            protoQuestion.FlowChartNodes.Count.Should().Be(3);
            protoQuestion.FlowChartNodes.Select(n => n.Key).Should().BeEquivalentTo("A", "B", "C");
            // Order should be random, so we don't assert order.
        }
    }
}
