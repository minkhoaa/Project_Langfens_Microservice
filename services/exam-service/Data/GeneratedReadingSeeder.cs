using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Data;

/// <summary>
/// Seeds an IELTS Academic Reading Practice Test 2 ("ielts-reading-practice-2").
/// Source material: paraphrased from the Wikipedia article "Bioluminescence"
/// (https://en.wikipedia.org/wiki/Bioluminescence, CC-BY-SA). Factual claims
/// preserved; wording rewritten for IELTS register.
/// 13 questions across 3 passages, 5+ distinct question types.
/// Storage shapes follow docs/question-type-reports/classification.json:
///   - completion types use BlankAcceptTexts (numeric blankId '0','1',...)
///   - MATCHING_FEATURES uses blankId convention "feature-q{Idx}" (single pair per row)
///   - FLOW_CHART uses OrderCorrects with slug-like lowercase node keys
///     ("larva-stage" style) so LCS NormalizeNode round-trips
///   - CLASSIFICATION uses MatchPairs with value[0]=accepted letter
/// </summary>
public static class GeneratedReadingSeeder
{
    public static async Task SeedAsync(ExamDbContext db)
    {
        var existing = await db.Exams.FirstOrDefaultAsync(e => e.Slug == "ielts-reading-practice-2");
        if (existing != null)
        {
            Console.WriteLine("ielts-reading-practice-2 already exists, skipping.");
            return;
        }

        // ── Stable GUIDs (repeatable migrations) ───────────────────────────────────
        var examId = Guid.Parse("22222222-2222-2222-2222-222222222222");
        var s1Id   = Guid.Parse("32222222-2222-2222-2222-222222222221");
        var s2Id   = Guid.Parse("32222222-2222-2222-2222-222222222222");
        var s3Id   = Guid.Parse("32222222-2222-2222-2222-222222222223");

        var exam = new Exam
        {
            Id = examId,
            Slug = "ielts-reading-practice-2",
            Title = "IELTS Academic Reading Practice Test 2",
            DescriptionMd = "Practice test on the theme of living light. Includes multiple choice, true/false/not given, matching features, summary completion, classification, flow chart, matching information, short answer, and sentence completion.",
            Category = "IELTS",
            Level = "B2",
            Status = "PUBLISHED",
            DurationMin = 60,
            CreatedAt = DateTime.UtcNow
        };

        // ── Section 1 — passage + 5 questions ─────────────────────────────────────
        var section1 = new ExamSection
        {
            Id = s1Id,
            ExamId = examId,
            Idx = 0,
            Title = "Section 1: Living Light",
            InstructionsMd = "Read the passage and answer questions 1-5.",
            PassageMd =
                "Living Light\n\n" +
                "Bioluminescence is the emission of visible light by a living organism. It is one of the most " +
                "widespread forms of communication in nature and is found in an astonishing range of species, " +
                "from deep-sea fish and tiny plankton to glow-worms flickering in summer grass. Unlike the light " +
                "produced by a candle or an electric bulb, the glow of a living organism is the result of a " +
                "chemical reaction inside or on the surface of its cells.\n\n" +
                "The reaction typically involves a small molecule called luciferin and an enzyme known as " +
                "luciferase. When luciferin is oxidised in the presence of luciferase and, in most cases, " +
                "a supply of chemical energy, a photon of light is released. The colour of the light varies " +
                "between species. Most marine organisms glow blue or green because these wavelengths travel " +
                "farthest through seawater. A few terrestrial species, such as fireflies, can produce yellow " +
                "or even red light by using slightly different luciferin molecules.\n\n" +
                "For many animals the light serves a defensive purpose. Some deep-sea shrimp release a cloud " +
                "of luminous fluid to confuse a predator while they escape into the dark. Certain squid " +
                "counter-illuminate their undersides so that, viewed from below, their silhouette matches " +
                "the faint light filtering down from the surface. Other organisms use light to attract prey: " +
                "the anglerfish dangles a glowing lure in front of its mouth and waits for smaller fish to " +
                "wander within reach.\n\n" +
                "Light is also used for communication. Fireflies are the best-known example. Males fly " +
                "through the night air flashing species-specific patterns; females resting on the vegetation " +
                "reply with a single flash of their own. A male that recognises the correct timing and " +
                "rhythm of the female's response will land and mate. In some species, the female has lost " +
                "the ability to fly and sits on the ground as a glowing \"fireball\" to attract the males.\n\n" +
                "Not all bioluminescence comes from the animal itself. In certain fish and squid the light " +
                "organ is home to colonies of luminous bacteria. The host provides the bacteria with food " +
                "and shelter; the bacteria, in return, produce a continuous glow. The relationship is so " +
                "stable that some host species cannot produce light without their bacterial partners."
        };

        // ── Section 2 — passage + 5 questions ─────────────────────────────────────
        var section2 = new ExamSection
        {
            Id = s2Id,
            ExamId = examId,
            Idx = 1,
            Title = "Section 2: Lighting the Ocean",
            InstructionsMd = "Read the passage and answer questions 6-10.",
            PassageMd =
                "Lighting the Ocean\n\n" +
                "Until relatively recently, the deep ocean was thought to be a dark, largely featureless " +
                "place. The first photographs taken below one thousand metres, however, revealed something " +
                "unexpected: the water was full of glowing points. Researchers now estimate that between " +
                "eighty and ninety per cent of the organisms encountered below two hundred metres are " +
                "capable of producing light at some stage of their lives.\n\n" +
                "The darkness of the deep sea is the reason light is so useful there. Sunlight is absorbed " +
                "within the first few hundred metres of water, leaving the rest of the ocean in near " +
                "permanent night. Producing a flash of light is the only practical way to communicate, " +
                "lure prey, or repel a predator in this environment. A handful of species have therefore " +
                "evolved extremely complex light organs: movable shutters, coloured filters, and even " +
                "lenses that focus the beam.\n\n" +
                "A particularly striking example is the stoplight loosejaw fish. Its jaws contain two " +
                "separate light-producing regions: one glows red and the other green. Most deep-sea fish " +
                "cannot see red light, so the loosejaw can illuminate its prey with a beam that other " +
                "predators are blind to. The red light is produced by a unique fluorescent protein that " +
                "shifts the colour of a green internal flash into longer wavelengths.\n\n" +
                "Light production is metabolically expensive. A glowing animal must burn chemical fuel, " +
                "and fuel is scarce in the deep ocean. Many species therefore keep their displays short " +
                "and reserve them for important moments, such as a confrontation with a rival or the " +
                "arrival of a potential mate. Some researchers have measured a ten-fold increase in an " +
                "organism's oxygen consumption during a sustained flash.\n\n" +
                "Almost all deep-sea luminescence is blue or blue-green, which travels through seawater " +
                "with the least absorption. There are a few exceptions. The viperfish, for example, " +
                "produces light through bioluminescent photophores along its flanks, while the rare " +
                "scaly dragonfish has been observed producing both red and infrared flashes that assist " +
                "in locating prey in the deepest waters."
        };

        // ── Section 3 — passage + 3 questions ─────────────────────────────────────
        var section3 = new ExamSection
        {
            Id = s3Id,
            ExamId = examId,
            Idx = 2,
            Title = "Section 3: Glowing in the Lab",
            InstructionsMd = "Read the passage and answer questions 11-13.",
            PassageMd =
                "Glowing in the Lab\n\n" +
                "Bioluminescence is not only a curiosity of the natural world. Since the 1950s scientists " +
                "have exploited the luciferin-luciferase reaction as a sensitive research tool. The most " +
                "widely used system comes from the North American firefly, Photinus pyralis. In the " +
                "presence of adenosine triphosphate, or ATP, the firefly enzyme produces a brief flash of " +
                "yellow-green light.\n\n" +
                "Because the brightness of the flash is directly related to the amount of ATP present, " +
                "researchers can use the reaction to measure the chemical in any biological sample. ATP " +
                "is found in all living cells, so the test is routinely used to check whether a sample " +
                "contains live bacteria or to follow the growth of cells in culture. The assay is " +
                "sensitive enough to detect a few hundred bacterial cells in a single drop of liquid.\n\n" +
                "A second important application is genetic engineering. The gene for luciferase can be " +
                "spliced into the DNA of another organism. Whenever that target gene is switched on in " +
                "the host, the cell also produces luciferase, and the tissue glows. The intensity of " +
                "the glow, captured by a sensitive camera, then reports the activity of the target gene " +
                "in real time. This technique has become a cornerstone of modern molecular biology.\n\n" +
                "Medical researchers have extended the idea. Tumour cells in laboratory mice can be tagged " +
                "with a luciferase gene so that, after a suitable substrate is injected, the tumour itself " +
                "lights up. The progression of the disease and the effect of experimental drugs can then " +
                "be monitored non-invasively from outside the animal. Similar reporter systems are now used " +
                "to screen candidate antibiotics and to track infection in real time."
        };

        // ── Q1: TRUE_FALSE_NOT_GIVEN (single choice) ───────────────────────────────
        var q1Id = Guid.Parse("43333333-3333-3333-3333-333333333331");
        // IELTS TFNG convention: A=True, B=False, C=Not Given (matches ReadingSeeder q2/q5).
        var q1 = new ExamQuestion
        {
            Id = q1Id, SectionId = s1Id, Idx = 0,
            Type = QuestionType.TrueFalseNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "Fireflies use species-specific flashing patterns to find mates.",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 0, ContentMd = "A. True",      IsCorrect = true  },
                new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 1, ContentMd = "B. False",     IsCorrect = false },
                new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 2, ContentMd = "C. Not Given", IsCorrect = false }
            }
        };

        // ── Q2: MULTIPLE_CHOICE_SINGLE ──────────────────────────────────────────────
        var q2Id = Guid.Parse("43333333-3333-3333-3333-333333333332");
        var q2 = new ExamQuestion
        {
            Id = q2Id, SectionId = s1Id, Idx = 1,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 2,
            PromptMd = "Why do most marine organisms produce blue or green light rather than other colours?",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 0, ContentMd = "A. Their eyes are only sensitive to those wavelengths.", IsCorrect = false },
                new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 1, ContentMd = "B. Blue and green light travels farthest through seawater.", IsCorrect = true },
                new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 2, ContentMd = "C. Other colours would attract too many predators.", IsCorrect = false },
                new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 3, ContentMd = "D. Luciferin molecules in the sea are chemically restricted.", IsCorrect = false }
            }
        };

        // ── Q3: MATCHING_FEATURES (single pair per question, blankId="feature-q{Idx}") ─
        // Per classification.json matching-features.json edge cases + seedExample.code:
        // MatchPairs shape: {"feature-q1": ["A", "A. some text"]} where value[0] is the
        // accepted letter and value[1] is the human-readable label shown in review.
        var q3Id = Guid.Parse("43333333-3333-3333-3333-333333333333");
        var q3 = new ExamQuestion
        {
            Id = q3Id, SectionId = s1Id, Idx = 2,
            Type = QuestionType.MatchingFeatures, Skill = "READING", Difficulty = 3,
            PromptMd =
                "Match each function of light with the animal that uses it.\n\n" +
                "Functions:\n" +
                "A. escaping from a predator by releasing luminous fluid\n" +
                "B. hiding its silhouette from animals below\n" +
                "C. luring prey with a glowing bait\n" +
                "D. exchanging signals with a potential mate\n\n" +
                "feature-q1. Deep-sea shrimp",
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "feature-q1", new[] { "A", "A. escaping from a predator by releasing luminous fluid" } }
            }
        };
        var q4Id = Guid.Parse("43333333-3333-3333-3333-333333333334");
        var q4 = new ExamQuestion
        {
            Id = q4Id, SectionId = s1Id, Idx = 3,
            Type = QuestionType.MatchingFeatures, Skill = "READING", Difficulty = 3,
            PromptMd = "feature-q2. Certain squid",
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "feature-q2", new[] { "B", "B. hiding its silhouette from animals below" } }
            }
        };

        var q5Id = Guid.Parse("43333333-3333-3333-3333-333333333335");
         var q5 = new ExamQuestion
        {
            Id = q5Id, SectionId = s1Id, Idx = 4,
            Type = QuestionType.MatchingFeatures, Skill = "READING", Difficulty = 3,
            PromptMd = "feature-q3. Anglerfish",
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "feature-q3", new[] { "C", "C. luring prey with a glowing bait" } }
            }
        };

        // ── Q6: SUMMARY_COMPLETION (numeric blankIds '0','1','2') ───────────────────
        // Per classification.json summary-completion.json edgeCases:
        //   "BlankId conventions differ across seeders: ReadingSeeder SentenceCompletion
        //    q3 uses '0','1'; ListeningSeeder q17a/b/c use 'blank-q<Idx>'. Both accepted
        //    by CompletionGrader via dictionary lookup." — numeric is the convention used
        //    by ReadingSeeder for completion types (q10 FlowChart, q13 DiagramLabel).
        var q6Id = Guid.Parse("43333333-3333-3333-3333-333333333336");
        var q6 = new ExamQuestion
        {
            Id = q6Id, SectionId = s2Id, Idx = 0,
            Type = QuestionType.SummaryCompletion, Skill = "READING", Difficulty = 2,
            PromptMd =
                "Complete the summary using words from the passage. Write NO MORE THAN TWO WORDS for each answer.\n\n" +
                "Until the mid-twentieth century, the deep ocean was believed to be largely __________ (0). " +
                "The first photographs taken below one thousand metres revealed that the water was full of " +
                "__________ (1). Researchers now suggest that between 80 and 90 per cent of organisms living " +
                "below __________ (2) metres can produce light.",
            BlankAcceptTexts = new Dictionary<string, string[]>
            {
                { "0", new[] { "dark", "featureless" } },
                { "1", new[] { "glowing points", "glowing" } },
                { "2", new[] { "200", "two hundred" } }
            }
        };

        // ── Q7: MULTIPLE_CHOICE_MULTIPLE (more than one correct) ──────────────────
        var q7Id = Guid.Parse("43333333-3333-3333-3333-333333333337");
        var q7 = new ExamQuestion
        {
            Id = q7Id, SectionId = s2Id, Idx = 1,
            Type = QuestionType.MultipleChoiceMultiple, Skill = "READING", Difficulty = 3,
            PromptMd = "Which TWO reasons does the author give for the abundance of light production in the deep ocean?",
            Options = new List<ExamOption>
            {
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 0, ContentMd = "A. Sunlight is absorbed within the first few hundred metres of water.", IsCorrect = true  },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 1, ContentMd = "B. Cold temperatures make chemical reactions easier.",               IsCorrect = false },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 2, ContentMd = "C. Producing light is the only practical way to communicate or lure prey.", IsCorrect = true },
                new() { Id = Guid.NewGuid(), QuestionId = q7Id, Idx = 3, ContentMd = "D. Deep-sea organisms have larger eyes than shallow-water species.",   IsCorrect = false }
            }
        };

        // ── Q8: FLOW_CHART — OrderCorrects with slug-like lowercase keys ───────────
        // Per flow-chart.json: "Node key convention is slug-like lowercase ('warm-intake');
        // user-visible label can be any string. NormNode normalizes both sides...so a label
        // like 'Warm Intake' or 'warm_intake' still matches 'warm-intake'."
        // OrderCorrects MUST be the LCS answer key (not BlankAcceptTexts).
        var q8Id = Guid.Parse("43333333-3333-3333-3333-333333333338");
        var q8 = new ExamQuestion
        {
            Id = q8Id, SectionId = s2Id, Idx = 2,
            Type = QuestionType.FlowChart, Skill = "READING", Difficulty = 3,
            PromptMd =
                "The diagram below shows how a stoplight loosejaw produces red light.\n\n" +
                "[green-flash] → [fluorescent-protein] → [filter-shifts-wavelength] → [red-beam-output]\n\n" +
                "Arrange the four steps in the correct order. Click the boxes and drag to reorder.",
            OrderCorrects = new List<string>
            {
                "green-flash",
                "fluorescent-protein",
                "filter-shifts-wavelength",
                "red-beam-output"
            }
        };

        // ── Q9: MATCHING_INFORMATION (one MatchPairs entry per information item) ───
        var q9Id = Guid.Parse("43333333-3333-3333-3333-333333333339");
        var q9 = new ExamQuestion
        {
            Id = q9Id, SectionId = s2Id, Idx = 3,
            Type = QuestionType.MatchingInformation, Skill = "READING", Difficulty = 3,
            PromptMd = "match-q1. A description of the unique optical organs of the stoplight loosejaw.",
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "match-q1", new[] { "C", "Paragraph describing the stoplight loosejaw's jaw organs" } }
            }
        };

        var q10Id = Guid.Parse("43333333-3333-3333-3333-333333333341");
        var q10 = new ExamQuestion
        {
            Id = q10Id, SectionId = s2Id, Idx = 4,
             Type = QuestionType.MatchingInformation, Skill = "READING", Difficulty = 3,
            PromptMd = "match-q2. An explanation of why deep-sea displays are usually brief.",
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "match-q2", new[] { "D", "Paragraph on metabolic cost and short displays" } }
            }
        };

        // ── Q11: SHORT_ANSWER (one ExamQuestion, three accept texts) ───────────────
        // Per short-answer.json edgeCases: "Single TextAnswer only — multi-blank is NOT
        // supported by ShortAnswerGrader. ... ShortAnswerGrader treats them as OR-alternates
        // for a single answer; there is no multi-blank scoring."
        // => Three separate ExamQuestion rows so each scores independently.
        var q11Id = Guid.Parse("43333333-3333-3333-3333-333333333342");
        var q11 = new ExamQuestion
        {
            Id = q11Id, SectionId = s3Id, Idx = 0,
            Type = QuestionType.ShortAnswer, Skill = "READING", Difficulty = 2,
            PromptMd = "Question 11: Which species of firefly is the source of the most widely used laboratory luciferin-luciferase system?",
            ShortAnswerAcceptTexts = new List<string> { "Photinus pyralis", "photinus pyralis" }
        };

        var q12Id = Guid.Parse("43333333-3333-3333-3333-333333333343");
        var q12 = new ExamQuestion
        {
            Id = q12Id, SectionId = s3Id, Idx = 1,
            Type = QuestionType.ShortAnswer, Skill = "READING", Difficulty = 2,
            PromptMd = "Question 12: What chemical does the firefly luciferase reaction require in order to produce light?",
            ShortAnswerAcceptTexts = new List<string> { "ATP", "adenosine triphosphate" }
        };

        // ── Q13: SENTENCE_COMPLETION (two blanks, numeric blankIds '0','1') ─────────
        var q13Id = Guid.Parse("43333333-3333-3333-3333-333333333344");
        var q13 = new ExamQuestion
        {
            Id = q13Id, SectionId = s3Id, Idx = 2,
            Type = QuestionType.SentenceCompletion, Skill = "READING", Difficulty = 2,
            PromptMd =
                "Complete the sentences. Write NO MORE THAN THREE WORDS for each answer.\n\n" +
                "1. The luciferase test is sensitive enough to detect a few hundred __________ (0) in a single drop.\n" +
                "2. In medical research, tumour cells in mice can be tagged with a luciferase gene so that the tumour itself __________ (1) up.",
            BlankAcceptTexts = new Dictionary<string, string[]>
            {
                { "0", new[] { "bacterial cells", "bacteria", "cells" } },
                { "1", new[] { "lights", "lights up", "glows", "lights up" } }
            }
        };

        db.Exams.Add(exam);
        db.ExamSections.AddRange(section1, section2, section3);
        db.ExamQuestions.AddRange(q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13);

        await db.SaveChangesAsync();
        Console.WriteLine($"Seeded ielts-reading-practice-2 with 13 questions across 3 sections (exam id {examId}).");
    }
}
