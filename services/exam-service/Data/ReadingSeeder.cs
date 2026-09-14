using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using ExamService.Data;

namespace exam_service.Data;

public static class ReadingSeeder
{
    private const string ExamSlug = "ielts-reading-standard-test";

    /// <summary>
    /// Sprint 7 Phase 10: normalize legacy PromptMd placeholders to canonical [N].
    /// - "__________" → "[N]" where N matches the corresponding BlankAcceptTexts key
    /// - "[ N ]" → "[N]"
    /// - "blank-qN" → "[N]"
    /// Idempotent: running on canonical input is a no-op.
    /// </summary>
    private static string EnsurePromptFormat(
        string prompt,
        System.Collections.Generic.Dictionary<string, string[]?>? blankAccepts)
    {
        if (blankAccepts is not { Count: > 0 } || string.IsNullOrEmpty(prompt))
            return prompt;

        foreach (var key in blankAccepts.Keys)
        {
            var keyEscaped = System.Text.RegularExpressions.Regex.Escape(key);
            // Replace "[ N ]" or "blank-qN" with "[N]"
            prompt = System.Text.RegularExpressions.Regex.Replace(
                prompt, $@"\[ ?{keyEscaped} ?\]|blank-q{keyEscaped}", $"[{key}]");
            // Replace runs of 3+ underscores that immediately follow a question
            // number (e.g. "3. ______" → "3. [3]") when no [N] is present.
            var keyPattern = @"\b" + keyEscaped + @"\b\.?\s_{3,}";
            prompt = System.Text.RegularExpressions.Regex.Replace(prompt, keyPattern, "[" + key + "]");
        }
        return prompt;
    }

    public static async Task SeedReadingExamAsync(ExamDbContext db)
    {
        // Always recreate: delete existing exam (cascade deletes sections/questions/options)
        var existing = await db.Exams.FirstOrDefaultAsync(e => e.Slug == ExamSlug);
        if (existing != null)
        {
            db.Exams.Remove(existing);
            await db.SaveChangesAsync();
            Console.WriteLine($"Deleted existing exam '{ExamSlug}', recreating...");
        }

        var examId = Guid.Parse("11111111-1111-1111-1111-111111111111");

        var exam = new Exam
        {
            Id = examId,
            Slug = ExamSlug,
            Title = "IELTS Academic Reading — Standard Test (19 Types)",
            DescriptionMd = "Complete exam covering all 19 IELTS Reading question types. Use this as the authoritative seed for platform testing and development.",
            Category = "IELTS",
            Level = "B2",
            Status = ExamStatus.Published,
            DurationMin = 60,
            CreatedAt = DateTime.UtcNow
        };

        // ── Section 1: The Origins of Paper ─────────────────────────────────
        var s1Id = Guid.Parse("11111111-1111-1111-1111-111111111101");
        var s1Passage = @"The Origins of Paper

The invention of paper marked one of the most significant technological advances in human history. Before paper, people wrote on clay tablets, papyrus, parchment, and bamboo strips. Each material had serious limitations in terms of cost, durability, and ease of use.

The earliest form of paper was developed in China around 105 CE during the Han Dynasty. Cai Lun, a court official, is traditionally credited with inventing the papermaking process. He created sheets by pressing together rags, hemp, and fishnets into a fibrous mat. The resulting material was lightweight, smooth, and far cheaper than existing alternatives.

The secret of papermaking spread slowly westward. Arab armies captured Chinese papermakers during battles along the Silk Road in the 8th century, and production centres soon emerged in Samarkand, Baghdad, and Damascus. By the 12th century, papermaking had reached Europe, where it gradually replaced the expensive vellum made from animal skins.

Medieval European paper was initially of lower quality than its Chinese counterpart. Early mills used linen and cotton rags, which produced a rough surface unsuitable for fine writing. The introduction of the Fourdrinier machine in the early 19th century transformed the industry by automating the entire production process. This machine could produce paper continuously from wood pulp rather than relying on the slow手工 method of pressing fibres by hand.

The shift from rags to wood pulp created new challenges. Wood-based paper degrades faster than cotton paper and becomes acidic over time, causing the familiar brown crumble of old newsprint. Modern archivists now use deacidification processes to extend the lifespan of important documents. Today, paper is produced from a variety of fibres including bamboo, wheat straw, and recycled materials, each offering different qualities of durability and texture.";

        var section1 = new ExamSection
        {
            Id = s1Id,
            ExamId = examId,
            Idx = 1,
            Title = "Section 1: The Origins of Paper",
            InstructionsMd = "Write your answers in boxes 1–5 on your answer sheet.",
            PassageMd = s1Passage
        };

        // Q1: MultipleChoiceSingle
        var q1Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s1q1");
        var q1Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 1, ContentMd = "A. Papyrus and parchment", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 2, ContentMd = "B. Clay tablets and bamboo", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 3, ContentMd = "C. Papyrus, parchment, clay tablets and bamboo", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 4, ContentMd = "D. Animal skins and wood", IsCorrect = false }
        };
        var q1 = new ExamQuestion
        {
            Id = q1Id, SectionId = s1Id, Idx = 1,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 2,
            PromptMd = "Before the invention of paper, which of the following materials was NOT commonly used for writing?",
            Options = q1Options
        };

        // Q2: TrueFalseNotGiven
        var q2Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s1q2");
        var q2Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 1, ContentMd = "True", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 2, ContentMd = "False", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 3, ContentMd = "Not Given", IsCorrect = false }
        };
        var q2 = new ExamQuestion
        {
            Id = q2Id, SectionId = s1Id, Idx = 2,
            Type = QuestionType.TrueFalseNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "Cai Lun was the first person to produce paper from wood pulp.",
            Options = q2Options
        };

        // Q3: SentenceCompletion
        var q3Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s1q3");
        var q3 = new ExamQuestion
        {
            Id = q3Id, SectionId = s1Id, Idx = 3,
            Type = QuestionType.SentenceCompletion, Skill = "READING", Difficulty = 2,
            PromptMd = "Complete the sentences.\nWrite ONE OR TWO WORDS from the passage for each answer.\n\n3. The earliest paper was produced in China during the [3] Dynasty.\n4. Arab armies acquired papermaking knowledge after defeating Chinese soldiers along the [4] in the 8th century.\n5. The Fourdrinier machine enabled paper to be made continuously from [5] rather than by hand.",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "3", new[] { "Han" } },
                { "4", new[] { "Silk Road" } },
                { "5", new[] { "wood pulp" } }
            }
        };

        // Q4: TableCompletion
        var q4Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s1q4");
        var q4 = new ExamQuestion
        {
            Id = q4Id, SectionId = s1Id, Idx = 4,
            Type = QuestionType.TableCompletion, Skill = "READING", Difficulty = 3,
            PromptMd = @"Complete the table below.
Write ONE OR TWO WORDS from the passage for each answer.

| Period | Region | Raw Material Used | Quality Issues |
|--------|--------|-------------------|----------------|
| 8th–12th century | Arab world and Europe | [6] | Lower quality than Chinese |
| Early 19th century | Europe | Wood pulp | [7] |",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "6", new[] { "linen and cotton rags", "cotton", "linen and cotton" } },
                { "7", new[] { "acidic", "degrades fast", "becomes acidic", "faster degradation" } }
            }
        };

        // Q5: SentenceCompletion (reclassified from FlowChart — prompt is fill-in-blanks only,
        // no reorder; OrderCorrects was null, only BlankAcceptTexts used. FlowChart semantics
        // require reorderable steps + per-step text, which Q5 lacks.)
        var q5Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s1q5");
        var q5 = new ExamQuestion
        {
            Id = q5Id, SectionId = s1Id, Idx = 5,
            Type = QuestionType.SentenceCompletion, Skill = "READING", Difficulty = 2,
            PromptMd = @"Complete the flow chart showing the papermaking process described in the passage.
Write ONE OR TWO WORDS from the passage for each answer.

Process:
1. Collect raw materials such as rags, hemp and fishnets
2. [8] the fibres in water
3. Press the fibres into a [9]
4. Dry the resulting [10] in the sun",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "8", new[] { "soak", "soaking", "break down" } },
                { "9", new[] { "mat", "fibrous mat" } },
                { "10", new[] { "sheet", "paper sheet" } }
            }
        };

        // ── Section 2: The Role of Museums ───────────────────────────────────
        var s2Id = Guid.Parse("11111111-1111-1111-1111-111111111102");
        var s2Passage = @"The Role of Museums

Museums have evolved far beyond their traditional role as repositories of artefacts. Today's museums serve as dynamic community spaces where education, entertainment, and social interaction intersect. This transformation has raised important questions about what museums should preserve and how they should engage with an increasingly diverse audience.

The commercial pressures facing many museums have led to a phenomenon known as 'blockbuster' exhibitions. These spectacular shows — often featuring famous works borrowed from international collections — draw enormous crowds and generate substantial revenue through ticket sales and merchandise. Critics argue that this focus on popular appeal comes at the expense of deeper educational mission. Smaller institutions, unable to afford such spectacles, risk becoming irrelevant in the competition for visitors and funding.

At the same time, technology is reshaping the museum experience. Interactive displays, augmented reality, and personalised audio guides allow visitors to explore collections at their own pace and according to their own interests. Some museums have begun lending digital artefacts to other institutions, raising questions about the nature of the object itself. When a museum shares a high-resolution image of a painting online, does the copy diminish the value of the original?

Museums also grapple with the ethical complexities of their collections. Objects taken fromcolonised territories during the 19th and 20th centuries present an ongoing challenge. While some institutions have begun repatriating artefacts to their countries of origin, others argue that universal museums serve humanity best by keeping diverse collections together under one roof. This debate is far from resolved.

In response to these pressures, many museums have redefined their role as community anchors. Outreach programmes, language classes, and job training sessions have become standard offerings at institutions seeking to serve as more than tourist destinations. The most successful museums are those that manage to balance their preservation mandate with genuine community engagement.";

        var section2 = new ExamSection
        {
            Id = s2Id,
            ExamId = examId,
            Idx = 2,
            Title = "Section 2: The Role of Museums",
            InstructionsMd = "Each statement below is followed by seven possible answers. Write the correct letter A–G on your answer sheet.",
            PassageMd = s2Passage
        };

        // Q6: MatchingHeading — match 5 paragraphs to 7 heading options
        // Paragraphs: 1=evolution of museums, 2=blockbuster exhibitions, 3=technology, 4=ethical complexities/repatriation, 5=community anchors
        // Headings pool (i–vii): i=museum evolution, ii=blockbuster model, iii=technology reshaping, iv=ethical debate, v=community role, vi=tourist vs locals, vii=funding pressures
        var q6Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s2q1");
        var q6 = new ExamQuestion
        {
            Id = q6Id, SectionId = s2Id, Idx = 1,
            Type = QuestionType.MatchingHeading, Skill = "READING", Difficulty = 3,
            PromptMd = @"The reading passage has five paragraphs, 1–5.
Choose the correct heading for each paragraph from the list of headings below.

List of Headings
i.  How museum purposes have changed over time
ii.  The economic model of major international exhibitions
iii.  Digital technology and its effect on visitor experience
iv.  Disputes over the ownership of cultural artefacts
v.  Museums as neighbourhood service centres
vi.  The difference between local visitors and tourists
vii. Funding challenges for smaller cultural institutions",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 1, ContentMd = "i. How museum purposes have changed over time" },
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 2, ContentMd = "ii. The economic model of major international exhibitions" },
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 3, ContentMd = "iii. Digital technology and its effect on visitor experience" },
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 4, ContentMd = "iv. Disputes over the ownership of cultural artefacts" },
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 5, ContentMd = "v. Museums as neighbourhood service centres" },
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 6, ContentMd = "vi. The difference between local visitors and tourists" },
                new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 7, ContentMd = "vii. Funding challenges for smaller cultural institutions" }
            },
            // Paragraph 1 → i, Paragraph 2 → ii, Paragraph 3 → iii, Paragraph 4 → iv, Paragraph 5 → v
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "1", new[] { "i", "How museum purposes have changed over time" } },
                { "2", new[] { "ii", "The economic model of major international exhibitions" } },
                { "3", new[] { "iii", "Digital technology and its effect on visitor experience" } },
                { "4", new[] { "iv", "Disputes over the ownership of cultural artefacts" } },
                { "5", new[] { "v", "Museums as neighbourhood service centres" } }
            }
        };

        // Q7: MatchingInformation — match statements to paragraphs A-E
        // Passage paragraphs: A=intro/evolution, B=blockbuster, C=technology, D=ethical/repatriation, E=community
        var q7Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s2q2");
        var q7 = new ExamQuestion
        {
            Id = q7Id, SectionId = s2Id, Idx = 2,
            Type = QuestionType.MatchingInformation, Skill = "READING", Difficulty = 3,
            PromptMd = @"The reading passage has five paragraphs, A–E.
Which paragraph contains the following information?

Note: Each paragraph letter may be used more than once. Four of the results will be used.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 1, ContentMd = "A. Paragraph A" },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 2, ContentMd = "B. Paragraph B" },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 3, ContentMd = "C. Paragraph C" },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 4, ContentMd = "D. Paragraph D" },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 5, ContentMd = "E. Paragraph E" }
            },
            // 1→blockbuster commercial model (B), 2→technology digital lending (C), 3→repatriation ethics (D), 4→community outreach (E)
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "1", new[] { "B", "Commercial pressures and blockbuster exhibitions" } },
                { "2", new[] { "C", "Technology reshaping the museum experience" } },
                { "3", new[] { "D", "Ethical complexities of colonial-era collections" } },
                { "4", new[] { "E", "Community outreach and social programmes" } }
            }
        };

        // Q8: YesNoNotGiven
        var q8Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s2q3");
        var q8Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 1, ContentMd = "Yes", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 2, ContentMd = "No", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 3, ContentMd = "Not Given", IsCorrect = false }
        };
        var q8 = new ExamQuestion
        {
            Id = q8Id, SectionId = s2Id, Idx = 3,
            Type = QuestionType.YesNoNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "All museums are now required to return objects taken during the colonial period.",
            Options = q8Options
        };

        // Q9: MatchingFeatures
        // Items: 1=blockbuster exhibitions, 2=digital technology, 3=repatriation debates, 4=community programmes
        // Features A–E: A=generates income, B=raises ethical questions, C=includes non-cultural activities, D=involves international loans, E=uses digital tools
        var q9Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s2q4");
        var q9 = new ExamQuestion
        {
            Id = q9Id, SectionId = s2Id, Idx = 4,
            Type = QuestionType.MatchingFeatures, Skill = "READING", Difficulty = 3,
            PromptMd = @"Each statement below lists characteristics of a museum initiative.
Match each initiative (1–4) with the correct feature (A–E).
Note: Two statements will NOT be matched.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 1, ContentMd = "A. Generates significant income" },
                new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 2, ContentMd = "B. Raises ethical questions about ownership" },
                new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 3, ContentMd = "C. Includes non-cultural activities such as language classes" },
                new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 4, ContentMd = "D. Involves borrowing objects from other countries" },
                new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 5, ContentMd = "E. Makes use of digital devices and software" }
            },
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "1", new[] { "A", "Blockbuster exhibitions" } },
                { "2", new[] { "E", "Digital technology" } },
                { "3", new[] { "B", "Repatriation debates" } },
                { "4", new[] { "C", "Community programmes" } }
            }
        };

        // Q10: MatchingEndings
        // Beginnings 1–4 matched to endings A–F
        var q10Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s2q5");
        var q10 = new ExamQuestion
        {
            Id = q10Id, SectionId = s2Id, Idx = 5,
            Type = QuestionType.MatchingEndings, Skill = "READING", Difficulty = 3,
            PromptMd = @"Complete each sentence with the correct ending, A–F.
Write the correct letter on your answer sheet.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 1, ContentMd = "A. …the crowds they draw can overshadow the museum's educational mission" },
                new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 2, ContentMd = "B. …raise questions about what it means to 'possess' a work of art" },
                new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 3, ContentMd = "C. …which can then be used to support the institution's core activities" },
                new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 4, ContentMd = "D. …a responsibility to serve the local community beyond tourism" },
                new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 5, ContentMd = "E. …the digital version has been shared freely with other institutions" },
                new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 6, ContentMd = "F. …which can only be resolved through international agreements" }
            },
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "1", new[] { "A", "While blockbuster exhibitions attract large numbers of visitors…" } },
                { "2", new[] { "B", "When a museum shares a high-resolution digital image online…" } },
                { "3", new[] { "C", "Revenue from commercial activities can be reinvested…" } },
                { "4", new[] { "D", "Modern museums increasingly see themselves as having…" } }
            }
        };

        // ── Section 3: Urban Farming Revolution (existing passage, improved) ─
        var s3Id = Guid.Parse("11111111-1111-1111-1111-111111111103");
        var s3Passage = @"Urban Farming Revolution

As global populations continue to urbanize, a quiet revolution is transforming how cities produce food. Vertical farms, once a sci-fi fantasy, are now a commercial reality in metropolitan areas from Singapore to Detroit.

The concept is straightforward: grow crops in stacked layers indoors under controlled conditions. LED lights simulate sunlight, while hydroponic systems deliver nutrients directly to plant roots. Climate control maintains optimal temperature and humidity year-round, eliminating seasonal constraints.

Singapore leads the world in vertical farming adoption. Sky Greens, the country's pioneering company, produces over 500 kilograms of vegetables daily from its 9-metre-tall towers. The facility uses 95 percent less water than traditional farming and operates entirely on renewable energy. Despite higher production costs, vertically farmed vegetables command premium prices in upscale supermarkets.

The technology has spread to unlikely locations. A former textile factory in Detroit now houses Green City Farms, employing 50 workers and producing 200 varieties of leafy greens. The operation runs 24 hours per day across three shifts, maximising use of expensive LED infrastructure.

In Japan, spread of vertical farms accelerated after the 2011 earthquake demonstrated the vulnerability of traditional supply chains. Spread Co., a major Japanese seed company, now operates 18 indoor farms across the country.

Critics point to significant limitations. Vertical farming consumes enormous amounts of electricity, making it carbon-intensive unless powered by renewables. The energy cost can represent up to 50 percent of total production expenses. Additionally, only certain crops are economically viable. Leafy greens, herbs, and some fruits thrive in controlled environments, but staple crops like wheat, rice, and corn remain impractical.";

        var section3 = new ExamSection
        {
            Id = s3Id,
            ExamId = examId,
            Idx = 3,
            Title = "Section 3: Urban Farming Revolution",
            InstructionsMd = "Complete the diagram below. Write NO MORE THAN TWO WORDS from the passage for each answer.",
            PassageMd = s3Passage
        };

        // Q11: DiagramLabel
        var q11Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s3q1");
        var q11 = new ExamQuestion
        {
            Id = q11Id, SectionId = s3Id, Idx = 1,
            Type = QuestionType.DiagramLabel, Skill = "READING", Difficulty = 2,
            PromptMd = "Label the diagram using words from the passage.\n\n[Diagram: Vertical Farm System — showing stacked growing shelves, LED lights, hydroponic pipes, and a climate control panel]",
            ImageUrl = "https://placehold.co/600x400/png?text=Vertical+Farm+System",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "1", new[] { "LED lights", "LED" } },
                { "2", new[] { "hydroponic pipes", "hydroponic system", "hydroponics" } },
                { "3", new[] { "climate control", "climate control panel" } },
                { "4", new[] { "stacked layers", "stacked growing shelves", "growing shelves" } }
            }
        };

        // Q12: FlowChart — vertical farm process steps in chronological order.
        // Real FLOW_CHART semantics (LCS-style step ordering, not fill-in-blanks).
        var q12Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s3q2");
        var q12 = new ExamQuestion
        {
            Id = q12Id, SectionId = s3Id, Idx = 2,
            Type = QuestionType.FlowChart, Skill = "READING", Difficulty = 2,
            PromptMd = @"Look at the four steps of the vertical farming process below and put them in the correct chronological order.

Available steps:
A. LED lights simulate natural sunlight
B. Sensors monitor plant health in real time
C. Hydroponic systems deliver nutrients to plant roots
D. Workers harvest and package the produce for supermarkets

Arrange steps in the correct chronological order:",
            OrderCorrects = new List<string>
            {
                "led-lights-simulate-natural-sunlight",
                "hydroponic-systems-deliver-nutrients",
                "sensors-monitor-plant-health",
                "workers-harvest-and-package"
            }
        };

        // Q13-15: ShortAnswer
        var q13Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s3q3");
        var q13 = new ExamQuestion
        {
            Id = q13Id, SectionId = s3Id, Idx = 3,
            Type = QuestionType.ShortAnswer, Skill = "READING", Difficulty = 2,
            PromptMd = "What city was home to Green City Farms, a former textile factory converted into a vertical farm?",
            ShortAnswerAcceptTexts = new List<string> { "Detroit" }
        };

        var q14Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s3q4");
        var q14 = new ExamQuestion
        {
            Id = q14Id, SectionId = s3Id, Idx = 4,
            Type = QuestionType.ShortAnswer, Skill = "READING", Difficulty = 2,
            PromptMd = "What proportion of total production expenses can energy costs represent in vertical farming?",
            ShortAnswerAcceptTexts = new List<string> { "50 percent", "50%", "fifty percent", "half" }
        };

        var q15Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s3q5");
        var q15 = new ExamQuestion
        {
            Id = q15Id, SectionId = s3Id, Idx = 5,
            Type = QuestionType.ShortAnswer, Skill = "READING", Difficulty = 2,
            PromptMd = "How many indoor farms does Spread Co. operate in Japan?",
            ShortAnswerAcceptTexts = new List<string> { "18", "eighteen" }
        };

        // Q16: MultipleChoiceSingle
        var q16Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s3q6");
        var q16Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q16Id, Idx = 1, ContentMd = "A. Staple crops like wheat and rice cannot be grown economically", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q16Id, Idx = 2, ContentMd = "B. LED lights are too expensive for commercial use", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q16Id, Idx = 3, ContentMd = "C. Hydroponic systems require constant human supervision", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q16Id, Idx = 4, ContentMd = "D. Vertical farms can only produce leafy greens", IsCorrect = false }
        };
        var q16 = new ExamQuestion
        {
            Id = q16Id, SectionId = s3Id, Idx = 6,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 3,
            PromptMd = "According to the passage, which of the following is a stated limitation of vertical farming?",
            Options = q16Options
        };

        // ── Section 4: Remote Work Revolution ────────────────────────────────
        var s4Id = Guid.Parse("11111111-1111-1111-1111-111111111104");
        var s4Passage = @"Remote Work Revolution

The shift to remote work, accelerated by global pandemic restrictions, has fundamentally altered the relationship between employees and their employers. While proponents praise the flexibility and reduced commuting time, critics point to the blurring of work-life boundaries and the mental health toll of prolonged isolation.

A landmark study conducted across 16 countries found that 74 percent of remote workers reported higher job satisfaction compared to their office-bound counterparts. However, the same study revealed that 58 percent struggled to switch off from work at the end of the day, leading to a phenomenon researchers call ' presenteeism' — being physically present at home but psychologically still at work.

Technology companies have led the way in developing tools to support distributed teams. Virtual whiteboards, cloud-based document collaboration, and AI-powered scheduling assistants have become standard features of the remote work toolkit. Some organisations have introduced 'digital-free' hours, mandating that no meetings or messages be sent during designated periods to protect employee downtime.

Not all sectors have adapted equally. Construction, healthcare, and manufacturing require physical presence, limiting remote work options in these industries. Within knowledge work, significant disparities exist between senior employees who built professional networks before the pandemic and newcomers who lack established relationships for collaboration and mentorship.

The future of remote work may lie in hybrid models that combine the best of both worlds. Companies experimenting with four-day work weeks report productivity gains of up to 40 percent, attributed partly to reduced fatigue and partly to increased autonomy. As organisations continue to refine their approaches, the challenge remains: how to maintain culture, creativity, and connection without requiring daily physical co-location.";

        var section4 = new ExamSection
        {
            Id = s4Id,
            ExamId = examId,
            Idx = 4,
            Title = "Section 4: Remote Work Revolution",
            InstructionsMd = "Choose THREE letters, A–F. Write the correct letters on your answer sheet.",
            PassageMd = s4Passage
        };

        // Q17: MultipleChoiceMultiple — choose THREE from A-F
        var q17Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s4q1");
        var q17Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q17Id, Idx = 1, ContentMd = "A. Increased job satisfaction", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q17Id, Idx = 2, ContentMd = "B. Reduced commuting time", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q17Id, Idx = 3, ContentMd = "C. Higher salaries", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q17Id, Idx = 4, ContentMd = "D. Improved work-life balance", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q17Id, Idx = 5, ContentMd = "E. Better access to mentorship", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q17Id, Idx = 6, ContentMd = "F. Reduced presenteeism", IsCorrect = false }
        };
        var q17 = new ExamQuestion
        {
            Id = q17Id, SectionId = s4Id, Idx = 1,
            Type = QuestionType.MultipleChoiceMultiple, Skill = "READING", Difficulty = 3,
            PromptMd = "Which THREE of the following benefits of remote work are mentioned in the passage?",
            Options = q17Options
        };

        // Q18: NoteCompletion
        var q18Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s4q2");
        var q18 = new ExamQuestion
        {
            Id = q18Id, SectionId = s4Id, Idx = 2,
            Type = QuestionType.NoteCompletion, Skill = "READING", Difficulty = 2,
            PromptMd = @"Complete the notes below.
Write ONE OR TWO WORDS from the passage for each answer.

Remote Work: Key Findings

• Study covered [18] countries
• [19] percent of remote workers felt more satisfied with their jobs
• 58 percent experienced [20] — difficulty disconnecting after work hours
• Some companies introduced [21]-free hours to protect employee downtime
• Four-day work weeks can increase productivity by up to [22] percent",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "18", new[] { "16", "sixteen" } },
                { "19", new[] { "74" } },
                { "20", new[] { "presenteeism" } },
                { "21", new[] { "digital" } },
                { "22", new[] { "40", "forty" } }
            }
        };

        // Q19: YesNoNotGiven
        var q19Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s4q3");
        var q19Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q19Id, Idx = 1, ContentMd = "Yes", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q19Id, Idx = 2, ContentMd = "No", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q19Id, Idx = 3, ContentMd = "Not Given", IsCorrect = false }
        };
        var q19 = new ExamQuestion
        {
            Id = q19Id, SectionId = s4Id, Idx = 3,
            Type = QuestionType.YesNoNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "All industries have been able to adopt remote work to the same degree.",
            Options = q19Options
        };

        // Q20: MatchingFeatures
        // Items: 1=remote workers, 2=technology companies, 3=hybrid/four-day week advocates
        // Features A–E: A=developed digital collaboration tools, B=reduced working hours, C=mandated downtime policies, D=reported higher satisfaction, E=struggled with boundaries
        var q20Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s4q4");
        var q20 = new ExamQuestion
        {
            Id = q20Id, SectionId = s4Id, Idx = 4,
            Type = QuestionType.MatchingFeatures, Skill = "READING", Difficulty = 3,
            PromptMd = @"Match each group (1–3) with the correct feature (A–E).
Note: Two features will NOT be used.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q20Id, Idx = 1, ContentMd = "A. Developed digital tools for distributed teams" },
                new() { Id = Guid.NewGuid(), QuestionId = q20Id, Idx = 2, ContentMd = "B. Reported up to 40% productivity gains" },
                new() { Id = Guid.NewGuid(), QuestionId = q20Id, Idx = 3, ContentMd = "C. Mandated no-meeting periods for staff" },
                new() { Id = Guid.NewGuid(), QuestionId = q20Id, Idx = 4, ContentMd = "D. Higher job satisfaction than office workers" },
                new() { Id = Guid.NewGuid(), QuestionId = q20Id, Idx = 5, ContentMd = "E. Struggled to stop working at the end of the day" }
            },
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "1", new[] { "D", "Remote workers" } },
                { "2", new[] { "A", "Technology companies" } },
                { "3", new[] { "B", "Four-day work week companies" } }
            }
        };

        // ── Section 5: The Library of Alexandria ─────────────────────────────
        var s5Id = Guid.Parse("11111111-1111-1111-1111-111111111105");
        var s5Passage = @"The Library of Alexandria

The Library of Alexandria, founded in the 3rd century BCE in the Egyptian city of Alexandria, was the largest and most significant library of the ancient world. Conceived by Demetrius of Phalerum and patronised by the Ptolemaic dynasty, it aimed to collect all the knowledge of humanity under one roof.

At its peak, the library contained an estimated 400,000 scrolls, including works by Homer, Plato, Aristotle, and thousands of other authors. Scholars from across the Mediterranean basin travelled to Alexandria to study, debate, and copy texts. The library was not merely a repository — it was a living research university, housing laboratories, botanical gardens, and astronomical observatories.

The precise causes of the library's destruction remain one of history's most debated questions. The popular myth that Julius Caesar burned the library during his siege of Alexandria in 48 BCE is now largely dismissed by historians. While Caesar's forces did set fire to ships in the harbour, causing some damage, the library appears to have survived this incident largely intact. The gradual decline over subsequent centuries was more likely caused by funding cuts, political instability, and the gradual loss of scholarly patronage rather than a single catastrophic event.

Modern reconstruction efforts have attracted significant international interest. The Bibliotheca Alexandrina, inaugurated in 2002 near the site of the ancient library, combines traditional architecture with state-of-the-art technology. Its collection of eight million titles makes it one of the largest libraries in the world. The new library serves as both a memorial to the ancient institution and a symbol of Egypt's commitment to scholarship and cultural preservation.";

        var section5 = new ExamSection
        {
            Id = s5Id,
            ExamId = examId,
            Idx = 5,
            Title = "Section 5: The Library of Alexandria",
            InstructionsMd = "Label the map below. Write ONE OR TWO WORDS from the passage for each answer.",
            PassageMd = s5Passage
        };

        // Q21: MapLabel
        var q21Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s5q1");
        var q21 = new ExamQuestion
        {
            Id = q21Id, SectionId = s5Id, Idx = 1,
            Type = QuestionType.MapLabel, Skill = "READING", Difficulty = 2,
            PromptMd = "The map below shows the ancient city of Alexandria. Label the locations [21] to [24] using information from the passage.\n\n[Map: Ancient Alexandria — showing coastline, harbour, city centre, and outer districts]",
            ImageUrl = "https://placehold.co/600x400/png?text=Ancient+Alexandria+Map",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "21", new[] { "Library of Alexandria", "the library", "ancient library" } },
                { "22", new[] { "harbour", "port", " harbour" } },
                { "23", new[] { "city centre", "centre", "city" } },
                { "24", new[] { "Museion", "research university", "observatories" } }
            }
        };

        // Q22: MatchingEndings
        // Q22: MatchingEndings
        var q22Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s5q2");
        var q22 = new ExamQuestion
        {
            Id = q22Id, SectionId = s5Id, Idx = 2,
            Type = QuestionType.MatchingEndings, Skill = "READING", Difficulty = 3,
            PromptMd = @"Complete each sentence with the correct ending, A–F.
Write the correct letter on your answer sheet.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q22Id, Idx = 1, ContentMd = "A. …400,000 scrolls containing works by the greatest authors of antiquity" },
                new() { Id = Guid.NewGuid(), QuestionId = q22Id, Idx = 2, ContentMd = "B. …laboratories, botanical gardens and observatories" },
                new() { Id = Guid.NewGuid(), QuestionId = q22Id, Idx = 3, ContentMd = "C. …funding cuts, political instability and loss of patronage" },
                new() { Id = Guid.NewGuid(), QuestionId = q22Id, Idx = 4, ContentMd = "D. …8 million titles, making it one of the world's largest" },
                new() { Id = Guid.NewGuid(), QuestionId = q22Id, Idx = 5, ContentMd = "E. …the Bibliotheca Alexandrina was built nearby" },
                new() { Id = Guid.NewGuid(), QuestionId = q22Id, Idx = 6, ContentMd = "F. …reconstructed using its original architectural plans" }
            },
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "1", new[] { "A", "The ancient library held…" } },
                { "2", new[] { "B", "Alongside books, the institution housed…" } },
                { "3", new[] { "C", "The library's decline was caused by…" } },
                { "4", new[] { "D", "The modern Bibliotheca Alexandrina now contains…" } }
            }
        };

        // Q23: Classification
        // Categories: A = cause of destruction debate, B = features of the ancient library, C = modern reconstruction, D = scholars' activities
        // Statements 1–5
        var q23Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s5q3");
        var q23 = new ExamQuestion
        {
            Id = q23Id, SectionId = s5Id, Idx = 3,
            Type = QuestionType.Classification, Skill = "READING", Difficulty = 3,
            PromptMd = @"Classify the following statements as referring to:
A — the debate over what caused the library's destruction
B — the features of the ancient library itself
C — the modern reconstruction efforts
D — the activities of scholars who worked there

23. Funding cuts and political instability were more likely causes than a single fire.
24. The new library combines contemporary design with historic symbolism.
25. Scholars travelled from across the Mediterranean to study and copy texts.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q23Id, Idx = 1, ContentMd = "A. The debate over what caused the library's destruction" },
                new() { Id = Guid.NewGuid(), QuestionId = q23Id, Idx = 2, ContentMd = "B. The features of the ancient library itself" },
                new() { Id = Guid.NewGuid(), QuestionId = q23Id, Idx = 3, ContentMd = "C. The modern reconstruction efforts" },
                new() { Id = Guid.NewGuid(), QuestionId = q23Id, Idx = 4, ContentMd = "D. The activities of scholars who worked there" }
            },
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "23", new[] { "A" } },
                { "24", new[] { "C" } },
                { "25", new[] { "D" } }
            }
        };

        // Q24: FormCompletion
        var q24Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s5q4");
        var q24 = new ExamQuestion
        {
            Id = q24Id, SectionId = s5Id, Idx = 4,
            Type = QuestionType.FormCompletion, Skill = "READING", Difficulty = 2,
            PromptMd = @"Complete the form below.
Write ONE OR TWO WORDS from the passage for each answer.

LIBRARY OF ALEXANDRIA — INFORMATION SHEET

Founded: [26] century BCE
Location: Alexandria, Egypt
Supported by: [27] dynasty
Purpose: Collect all human knowledge in one place
Peak collection: [28] scrolls
Modern successor: [29] (opened 2002)
Modern collection size: [30] titles",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "26", new[] { "3rd", "third" } },
                { "27", new[] { "Ptolemaic" } },
                { "28", new[] { "400,000" } },
                { "29", new[] { "Bibliotheca Alexandrina" } },
                { "30", new[] { "8 million", "eight million" } }
            }
        };

        // Q25: MultipleChoiceSingleImage — image-based MCQ about the library reconstruction
        var q25Id = SeederHelpers.CreateDeterministicGuid(ExamSlug, "s5q5");
        var q25Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q25Id, Idx = 1, ContentMd = "A. It was built using the original ancient architectural plans", ImageUrl = "https://placehold.co/200x150/png?text=A", AltText = "Option A", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q25Id, Idx = 2, ContentMd = "B. It combines modern architecture with references to the ancient library", ImageUrl = "https://placehold.co/200x150/png?text=B", AltText = "Option B", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q25Id, Idx = 3, ContentMd = "C. It is the largest library ever built in human history", ImageUrl = "https://placehold.co/200x150/png?text=C", AltText = "Option C", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q25Id, Idx = 4, ContentMd = "D. It houses the original scrolls recovered from the ancient site", ImageUrl = "https://placehold.co/200x150/png?text=D", AltText = "Option D", IsCorrect = false }
        };
        var q25 = new ExamQuestion
        {
            Id = q25Id, SectionId = s5Id, Idx = 5,
            Type = QuestionType.MultipleChoiceSingleImage, Skill = "READING", Difficulty = 2,
            PromptMd = "Which image correctly describes the modern Bibliotheca Alexandrina?",
            Options = q25Options
        };
// ── Persist ───────────────────────────────────────────────────────────
        db.Exams.Add(exam);
        await db.SaveChangesAsync(); // persist exam first so FK constraint is satisfied
        db.ExamSections.AddRange(section1, section2, section3, section4, section5);
        db.ExamQuestions.AddRange(
            // Section 1
            q1, q2, q3, q4, q5,
            // Section 2
            q6, q7, q8, q9, q10,
            // Section 3
            q11, q12, q13, q14, q15, q16,
            // Section 4
            q17, q18, q19, q20,
            // Section 5
            q21, q22, q23, q24, q25
        );

        await db.SaveChangesAsync();
        Console.WriteLine("Seeded IELTS Reading Standard Test: 5 sections, 25 questions, 19 types covered.");
    }
}
