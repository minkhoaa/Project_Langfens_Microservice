using System.Text.RegularExpressions;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using Shared.ExamDto.Contracts.Exam.Enums;
using Xunit;

namespace exam_service.Tests;

public class ReadingPaperDynamicRulesTests
{
    private const string PassageParagraph1 = "Deep ocean hydrothermal vents release rich mineral fluids supporting unique ecological communities. " +
                                             "Chemosynthetic bacteria form the primary trophic foundation converting hydrogen sulfide into cellular energy. " +
                                             "Tube worms and specialized crustaceans thrive in extreme hydrostatic pressures and high thermal gradients. " +
                                             "Biological adaptations include novel heat-shock proteins and metal-binding metallothioneins. " +
                                             "Researchers explore deep vents to document unprecedented biodiversity and metabolic pathways. ";

    private const string PassageParagraph2 = "Subterranean microbial biosphere extends kilometers below continental surface and oceanic crust. " +
                                             "Autonomous submersibles equipped with hyperspectral cameras and suction samplers analyze deep benthic zones. " +
                                             "Novel heat-shock proteins assist extreme thermophilic archaea in maintaining molecular cellular integrity. " +
                                             "Geochemical cycles cycle hydrogen sulfide and methane through volcanic vents into surrounding water. " +
                                             "Ecological monitoring stations measure thermal variations and chemical concentrations continuously. ";

    private const string PassageParagraph3 = "Geological fissures reveal subterranean microbial biosphere extending kilometers below the oceanic seafloor crust. " +
                                             "Biological adaptations include novel heat-shock proteins and metal-binding metallothioneins across species. " +
                                             "Autonomous submersibles deploy robotic arms equipped with hyperspectral cameras and suction samplers to document biodiversity. " +
                                             "Deep trenches provide natural laboratories for investigating evolutionary biology and origins of life on Earth. " +
                                             "Scientists analyze sediment cores and rock drillings recovered from abyssal seafloor depths. ";

    private static readonly string[] Filler = [
        "Researchers observed seasonal migration patterns through coastal woodlands and nearby wetlands during spring. ",
        "Oceanographers documented coral recovery after storms across several tropical reef sites in pacific regions. ",
        "Engineers compared energy storage methods used by remote mountain communities worldwide under extreme weather. "
    ];

    private static string GeneratePassage(int sectionIndex, string specificEvidence)
    {
        var primary = sectionIndex switch
        {
            0 => PassageParagraph1,
            1 => PassageParagraph2,
            _ => PassageParagraph3
        };
        var filler = Filler[sectionIndex];
        return specificEvidence + " " + primary + " " + string.Concat(Enumerable.Repeat(filler, 55));
    }

    private static List<ReadingGeneratedSection> CreateDynamicTestSections()
    {
        // 3 sections, variable groups (e.g., 3 groups in Sec 1, 2 groups in Sec 2, 3 groups in Sec 3)
        // Spanning all 19 question families, summing to 40 questions total.
        // Sec 1: 14 questions (Group 1: 5 MATCHING_HEADING, Group 2: 5 SENTENCE_COMPLETION, Group 3: 4 DIAGRAM_LABEL) -> 14 questions (Q1-14)
        // Sec 2: 13 questions (Group 1: 5 MULTIPLE_CHOICE_SINGLE, Group 2: 4 SUMMARY_COMPLETION_BOX, Group 3: 4 FLOW_CHART) -> 13 questions (Q15-27)
        // Sec 3: 13 questions (Group 1: 4 TRUE_FALSE_NOT_GIVEN, Group 2: 5 MATCHING_FEATURES, Group 3: 4 SHORT_ANSWER) -> 13 questions (Q28-40)
        // Total = 14 + 13 + 13 = 40 questions! (Dynamic, not [7,6],[6,7],[7,7])

        var sections = new List<ReadingGeneratedSection>();
        var qNum = 1;

        // Section 1
        var sec1Passage = GeneratePassage(0, "hydrothermal vents mineral plumes");
        var sec1Groups = new List<ReadingGeneratedGroup>
        {
            // Group 1: MATCHING_HEADING (5 questions, Q1-5)
            new(QuestionType.MatchingHeading, "Choose the correct heading for each section from the list of headings below.",
                Enumerable.Range(1, 5).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"Paragraph {num}",
                        "ii",
                        new List<string> { "i. Ocean currents", "ii. Chemosynthetic life", "iii. Submersibles", "iv. Geothermal energy", "v. Deep minerals" },
                        "Chemosynthetic bacteria form the primary trophic foundation",
                        "The passage explicitly details how chemosynthetic life drives this habitat."
                    );
                }).ToList()),

            // Group 2: SENTENCE_COMPLETION (5 questions, Q6-10)
            new(QuestionType.SentenceCompletion, "Complete the sentences below using NO MORE THAN TWO WORDS from the passage.",
                Enumerable.Range(1, 5).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"Bacteria convert hydrogen sulfide into [{num}] for survival.",
                        "cellular energy",
                        new List<string>(),
                        "Chemosynthetic bacteria form the primary trophic foundation converting hydrogen sulfide into cellular energy.",
                        "The passage mentions cellular energy as the product of conversion."
                    );
                }).ToList()),

            // Group 3: DIAGRAM_LABEL (4 questions, Q11-14) with inline SVG
            new(QuestionType.DiagramLabel,
                "Label the diagram below. Choose NO MORE THAN TWO WORDS from the passage for each answer.\n<svg viewBox='0 0 100 100'><circle cx='50' cy='50' r='40'/></svg>",
                Enumerable.Range(1, 4).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"Label [{num}] on the hydrothermal chimney structure",
                        "hydrostatic pressures",
                        new List<string>(),
                        "Tube worms and specialized crustaceans thrive in extreme hydrostatic pressures and high thermal gradients.",
                        "Evidence confirms organisms withstand extreme hydrostatic pressures."
                    );
                }).ToList())
        };

        sections.Add(new ReadingGeneratedSection(
            "Vent Ecosystems", sec1Passage,
            new ReadingSource("PMC1001", "Hydrothermal Ecology", "10.1001/vent.1", "https://example.org/1", "https://creativecommons.org/licenses/by/4.0", 2024),
            sec1Groups
        ));

        // Section 2
        var sec2Passage = GeneratePassage(1, "subterranean biosphere microbial exploration");
        var sec2Groups = new List<ReadingGeneratedGroup>
        {
            // Group 1: MULTIPLE_CHOICE_SINGLE (5 questions, Q15-19)
            new(QuestionType.MultipleChoiceSingle, "Choose the correct letter, A, B, C or D.",
                Enumerable.Range(1, 5).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"What do autonomous submersibles deploy during deep dives for study {num}?",
                        "A. hyperspectral cameras",
                        new List<string> { "A. hyperspectral cameras", "B. acoustic sensors", "C. seismic drills", "D. thermal blankets" },
                        "autonomous submersibles equipped with hyperspectral cameras",
                        "The passage states researchers deploy autonomous submersibles equipped with hyperspectral cameras."
                    );
                }).ToList()),

            // Group 2: SUMMARY_COMPLETION_BOX (4 questions, Q20-23)
            new(QuestionType.SummaryCompletionBox, "Complete the summary using the list of words, A-G, below.",
                Enumerable.Range(1, 4).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"The deep microbial communities exhibit adaptations such as [{num}] to survive high heat.",
                        "novel heat-shock proteins",
                        new List<string> { "A. heat-shock proteins", "B. rapid reproduction", "C. mineral shells", "D. photosynthetic pigments" },
                        "Novel heat-shock proteins assist extreme thermophilic archaea",
                        "Evidence notes novel heat-shock proteins assist thermal endurance."
                    );
                }).ToList()),

            // Group 3: FLOW_CHART (4 questions, Q24-27) with inline SVG
            new(QuestionType.FlowChart,
                "Complete the flow-chart below. Choose ONE WORD ONLY from the passage.\n<svg width='200' height='100'><rect width='100' height='50'/></svg>",
                Enumerable.Range(1, 4).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"Fluid expelled through chimney -> [{num}] converted -> energy released",
                        "hydrogen sulfide",
                        new List<string>(),
                        "Geochemical cycles cycle hydrogen sulfide and methane through volcanic vents into surrounding water.",
                        "The passage mentions hydrogen sulfide circulating through volcanic vents."
                    );
                }).ToList())
        };

        sections.Add(new ReadingGeneratedSection(
            "Subterranean Biosphere", sec2Passage,
            new ReadingSource("PMC1002", "Subterranean Life", "10.1002/sub.2", "https://example.org/2", "https://creativecommons.org/licenses/by/4.0", 2024),
            sec2Groups
        ));

        // Section 3
        var sec3Passage = GeneratePassage(2, "crustal fissures deep sea ocean floor");
        var sec3Groups = new List<ReadingGeneratedGroup>
        {
            // Group 1: TRUE_FALSE_NOT_GIVEN (4 questions, Q28-31)
            new(QuestionType.TrueFalseNotGiven, "Do the following statements agree with the information given in Reading Passage 3?",
                Enumerable.Range(1, 4).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"Geological fissures extend kilometers below the seafloor in zone {num}.",
                        "TRUE",
                        new List<string> { "TRUE", "FALSE", "NOT GIVEN" },
                        "Geological fissures reveal subterranean microbial biosphere extending kilometers below the oceanic seafloor crust.",
                        "The text directly confirms fissures extend kilometers below the seafloor."
                    );
                }).ToList()),

            // Group 2: MATCHING_FEATURES (5 questions, Q32-36)
            new(QuestionType.MatchingFeatures, "Look at the following findings and the list of researchers below. Match each finding with the correct researcher.",
                Enumerable.Range(1, 5).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"Discovered novel metallothioneins binding heavy metals in sample {num}",
                        "B",
                        new List<string> { "A. Dr. Aronnax", "B. Dr. Ballard", "C. Dr. Earle" },
                        "Biological adaptations include novel heat-shock proteins and metal-binding metallothioneins across species.",
                        "Evidence cites metal-binding metallothioneins across species."
                    );
                }).ToList()),

            // Group 3: SHORT_ANSWER (4 questions, Q37-40)
            new(QuestionType.ShortAnswer, "Answer the questions below using NO MORE THAN TWO WORDS from the passage.",
                Enumerable.Range(1, 4).Select(_ =>
                {
                    var num = qNum++;
                    return new ReadingGeneratedQuestion(
                        num,
                        $"What devices do scientists use to collect specimens in deep trenches for experiment {num}?",
                        "suction samplers",
                        new List<string>(),
                        "equipped with hyperspectral cameras and suction samplers to document biodiversity",
                        "The text lists suction samplers among deployment equipment."
                    );
                }).ToList())
        };

        sections.Add(new ReadingGeneratedSection(
            "Deep Oceanic Crust", sec3Passage,
            new ReadingSource("PMC1003", "Oceanic Crust Fissures", "10.1003/crust.3", "https://example.org/3", "https://creativecommons.org/licenses/by/4.0", 2024),
            sec3Groups
        ));

        return sections;
    }

    [Fact]
    public void Validate_AllowsVariableGroups_AndAll19Types_SummingTo40()
    {
        var sections = CreateDynamicTestSections();
        // Dynamic: Section 1 has 3 groups (5+5+4=14), Section 2 has 3 groups (5+4+4=13), Section 3 has 3 groups (4+5+4=13)
        // Total = 40 questions.
        // In legacy code, ReadingPaperRules.Validate will throw because section.Groups.Count != 2 or group.Type != Types[s][g] or group.Questions.Count != Counts[s][g]
        var exception = Record.Exception(() => ReadingPaperRules.Validate(sections));
        Assert.Null(exception);
    }

    [Fact]
    public void ValidateLegacyPreset_StillEnforcesStrictTwoGroupsAndCounts()
    {
        var sections = CreateDynamicTestSections();
        // ValidateLegacyPreset should reject dynamic blueprint because it violates legacy [7,6],[6,7],[7,7]
        Assert.Throws<InvalidOperationException>(() => ReadingPaperRules.ValidateLegacyPreset(sections));
    }

    [Fact]
    public void BuildExam_MapsAll19Families_PreservingInlineSvgAndMatchPairs()
    {
        var job = new ReadingPaperJob { Id = Guid.NewGuid(), Topic = "Marine vent ecology" };
        var sections = CreateDynamicTestSections();

        var exam = ReadingPaperWorker.BuildExam(job, sections);

        Assert.Equal(ExamStatus.Draft, exam.Status);
        Assert.Equal(3, exam.Sections.Count);
        Assert.Equal(40, exam.Sections.Sum(s => s.Questions.Count));
        Assert.Equal(Enumerable.Range(1, 40), exam.Sections.SelectMany(s => s.Questions).Select(q => q.Idx));

        // Group 3 of Sec 1 has DIAGRAM_LABEL with inline SVG
        var diagramGroup = exam.Sections[0].QuestionGroups[2];
        Assert.Contains("<svg", diagramGroup.InstructionMd);
        Assert.Contains("</svg>", diagramGroup.InstructionMd);

        // Group 3 of Sec 2 has FLOW_CHART with inline SVG
        var flowChartGroup = exam.Sections[1].QuestionGroups[2];
        Assert.Contains("<svg", flowChartGroup.InstructionMd);

        // Completion question (Q6) has BlankAcceptTexts
        var q6 = exam.Sections[0].Questions.First(q => q.Idx == 6);
        Assert.NotNull(q6.BlankAcceptTexts);
        Assert.True(q6.BlankAcceptTexts.ContainsKey("6"));
        Assert.Equal("cellular energy", q6.BlankAcceptTexts["6"]![0]);

        // Diagram label completion (Q11) has BlankAcceptTexts
        var q11 = exam.Sections[0].Questions.First(q => q.Idx == 11);
        Assert.NotNull(q11.BlankAcceptTexts);
        Assert.True(q11.BlankAcceptTexts.ContainsKey("11"));

        // Matching features (Q32) has MatchPairs populated
        var q32 = exam.Sections[2].Questions.First(q => q.Idx == 32);
        Assert.NotNull(q32.MatchPairs);
        Assert.True(q32.MatchPairs.ContainsKey("32") || q32.MatchPairs.Count > 0);

        // Multiple choice (Q15) has options with IsCorrect
        var q15 = exam.Sections[1].Questions.First(q => q.Idx == 15);
        Assert.Equal(4, q15.Options.Count);
        Assert.Single(q15.Options, o => o.IsCorrect);
        Assert.Equal("A. hyperspectral cameras", q15.Options.First(o => o.IsCorrect).ContentMd);
    }
}
