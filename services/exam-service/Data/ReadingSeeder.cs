using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Data;

public static class ReadingSeeder
{
    public static async Task SeedReadingExamAsync(ExamDbContext db)
    {
        var existing = await db.Exams.FirstOrDefaultAsync(e => e.Slug == "ielts-reading-practice-1");
        if (existing != null)
        {
            // Update status if needed (was seeded with wrong case previously)
            if (existing.Status != ExamStatus.Published)
            {
                existing.Status = ExamStatus.Published;
                await db.SaveChangesAsync();
                Console.WriteLine("Updated existing reading exam status to PUBLISHED.");
            }
            else
            {
                Console.WriteLine("Reading exam already exists with correct status, skipping.");
            }
            return;
        }

        var examId = Guid.Parse("11111111-1111-1111-1111-111111111111");
        var section1Id = Guid.Parse("22222222-2222-2222-2222-222222222221");
        var section2Id = Guid.Parse("22222222-2222-2222-2222-222222222222");
        var section3Id = Guid.Parse("22222222-2222-2222-2222-222222222223");

        var exam = new Exam
        {
            Id = examId,
            Slug = "ielts-reading-practice-1",
            Title = "IELTS Academic Reading Practice Test 1",
            DescriptionMd = "Practice test featuring various reading question types: multiple choice, true/false/not given, matching headings, and sentence completion.",
            Category = "IELTS",
            Level = "B2",
            Status = "PUBLISHED",
            DurationMin = 60,
            CreatedAt = DateTime.UtcNow
        };

        var section1 = new ExamSection
        {
            Id = section1Id,
            ExamId = examId,
            Idx = 0,
            Title = "Section 1: Water in the Desert",
            InstructionsMd = "Read the passage and answer the questions.",
            PassageMd = "Water in the Desert\n\n" +
                "The Atacama Desert in Chile is one of the driest places on Earth. Some areas receive less than 1mm of rainfall per year. Yet despite this extreme aridity, human settlements have thrived here for centuries. How do people survive in such a harsh environment?\n\n" +
                "The answer lies in a remarkable fog harvesting technique developed by the indigenous Chungungo community. Every morning, massive clouds roll in from the Pacific Ocean, bringing moisture to the coastal cliffs. The Chungungo people built elaborate systems of vertical nets made from polypropylene. These nets, stretching up to 12 meters high, capture the fog droplets as the mist passes through. Water trickles down into collection channels and is stored in underground tanks.\n\n" +
                "Each net can collect up to 18 liters of water per day. A single community with 50 nets can gather approximately 900 liters daily, enough to sustain agricultural activities and domestic use. The water quality is exceptional, with natural filtration through the net fibers removing impurities and bacteria.\n\n" +
                "This ancient technique has gained renewed attention from scientists and engineers worldwide. In 1993, a severe drought prompted the Chilean government to partner with the Chungungo community to expand fog harvesting operations. Today, over 300 nets are operational, providing water to more than 1,000 residents across three villages.\n\n" +
                "The success of the Atacama project has inspired similar initiatives in Peru, Ecuador, and South Africa. However, experts caution that fog harvesting is not a universal solution. It requires specific geographical conditions: coastal mountains that force moisture-laden clouds upward, consistent fog patterns, and community cooperation for maintenance.\n\n" +
                "Interestingly, the polypropylene nets were originally developed for agricultural purposes in Israel. The material's durability and UV resistance make it ideal for long-term outdoor use. Researchers are now experimenting with bamboo alternatives to reduce costs and environmental impact.\n\n" +
                "Despite its successes, the fog harvesting system faces challenges. Climate change is altering fog patterns in some regions, making predictions difficult. Maintenance requires regular cleaning of the nets to prevent algae buildup, which can reduce efficiency by up to 40 percent."
        };

        var section2 = new ExamSection
        {
            Id = section2Id,
            ExamId = examId,
            Idx = 1,
            Title = "Section 2: The Science of Music",
            InstructionsMd = "Read the passage and complete the sentences.",
            PassageMd = "The Science of Music\n\n" +
                "Music has been part of human culture for thousands of years, but only recently have scientists begun to understand why it affects us so profoundly. Researchers at the University of Melbourne have discovered that listening to music triggers the release of dopamine, the same chemical associated with eating chocolate or winning money.\n\n" +
                "The study involved 250 participants who listened to their favorite pieces of music while undergoing brain scans. The results showed that intense emotional responses to music occurred in the same brain regions that respond to other pleasurable stimuli. This explains why chills or shivers sometimes accompany particularly moving musical passages.\n\n" +
                "Dr. Sarah Chen, lead researcher on the project, explains that music activates the nucleus accumbens, a structure that manages decision-making and emotional responses. Simultaneously, the cerebral cortex lights up as it processes the complex auditory information. This dual activation creates the powerful sensation of being moved by sound.\n\n" +
                "The research has practical applications for treating depression and anxiety. Music therapy has been used in hospitals for decades, but this study provides scientific backing for the approach. Patients who listened to preferred music showed significantly lower cortisol levels, indicating reduced stress. Even passive listening, where patients simply had music playing in the background, produced measurable benefits.\n\n" +
                "However, not all music affects people equally. Cultural background plays a crucial role in determining what sounds pleasant. Western classical music may move one person to tears while another remains completely indifferent. The brain's auditory cortex needs to develop specific neural pathways through exposure to recognize patterns and harmonies.\n\n" +
                "Musical training appears to strengthen these pathways. Musicians typically have more gray matter in their auditory cortices and demonstrate superior temporal processing abilities. This may explain why trained musicians often excel at learning languages, which also require sophisticated sound pattern recognition.\n\n" +
                "The commercial implications are significant. Streaming services now use neuroscience research to optimize playlists for different activities. Concentration-enhancing playlists feature music with moderate complexity and consistent rhythm, while exercise playlists incorporate higher tempo tracks with strong bass lines to boost motivation."
        };

        var section3 = new ExamSection
        {
            Id = section3Id,
            ExamId = examId,
            Idx = 2,
            Title = "Section 3: Urban Farming Revolution",
            InstructionsMd = "Complete the flow chart below using information from the passage.",
            PassageMd = "Urban Farming Revolution\n\n" +
                "As global populations continue to urbanize, a quiet revolution is transforming how cities produce food. Vertical farms, once a sci-fi fantasy, are now a commercial reality in metropolitan areas from Singapore to Detroit.\n\n" +
                "The concept is straightforward: grow crops in stacked layers indoors under controlled conditions. LED lights simulate sunlight, while hydroponic systems deliver nutrients directly to plant roots. Climate control maintains optimal temperature and humidity year-round, eliminating seasonal constraints.\n\n" +
                "Singapore leads the world in vertical farming adoption. Sky Greens, the country's pioneering company, produces over 500 kilograms of vegetables daily from its 9-meter-tall towers. The facility uses 95 percent less water than traditional farming and operates entirely on renewable energy. Despite higher production costs, vertically farmed vegetables command premium prices in upscale supermarkets.\n\n" +
                "The technology has spread to unlikely locations. A former textile factory in Detroit now houses Green City Farms, employing 50 workers and producing 200 varieties of leafy greens. The operation runs 24 hours per day across three shifts, maximizing use of expensive LED infrastructure.\n\n" +
                "In Japan, spread of vertical farms accelerated after the 2011 earthquake demonstrated the vulnerability of traditional supply chains. Spread Co., a major Japanese seed company, now operates 18 indoor farms across the country. Their products include over 40 varieties of lettuce, herbs, and edible flowers.\n\n" +
                "Critics point to significant limitations. Vertical farming consumes enormous amounts of electricity, making it carbon-intensive unless powered by renewables. The energy cost can represent up to 50 percent of total production expenses. Additionally, only certain crops are economically viable. Leafy greens, herbs, and some fruits thrive in controlled environments, but staple crops like wheat, rice, and corn remain impractical.\n\n" +
                "The industry continues to evolve rapidly. Researchers at MIT have developed sensor networks that monitor plant health in real-time, adjusting light spectrum and nutrient delivery automatically. Machine learning algorithms predict optimal harvest times, reducing waste. Some facilities now produce mushrooms, which require minimal light and grow rapidly in stacked substrates."
        };

        // Q1: Multiple Choice
        var q1Id = Guid.Parse("33333333-3333-3333-3333-333333333331");
        var q1Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 0, ContentMd = "A. 10 liters", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 1, ContentMd = "B. 18 liters", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 2, ContentMd = "C. 50 liters", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q1Id, Idx = 3, ContentMd = "D. 900 liters", IsCorrect = false }
        };
        var q1 = new ExamQuestion
        {
            Id = q1Id, SectionId = section1Id, Idx = 0,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 2,
            PromptMd = "According to the passage, the fog harvesting nets can collect up to how many liters per day per net?",
            Options = q1Options
        };

        // Q2: True/False/Not Given
        var q2Id = Guid.Parse("33333333-3333-3333-3333-333333333332");
        var q2Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 0, ContentMd = "A. True", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 1, ContentMd = "B. False", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q2Id, Idx = 2, ContentMd = "C. Not Given", IsCorrect = false }
        };
        var q2 = new ExamQuestion
        {
            Id = q2Id, SectionId = section1Id, Idx = 1,
            Type = QuestionType.TrueFalseNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "The polypropylene nets were originally invented in Chile.",
            Options = q2Options
        };

        // Q3: Sentence Completion
        var q3Id = Guid.Parse("33333333-3333-3333-3333-333333333333");
        var q3 = new ExamQuestion
        {
            Id = q3Id, SectionId = section1Id, Idx = 2,
            Type = QuestionType.SentenceCompletion, Skill = "READING", Difficulty = 2,
            PromptMd = "Fill in the blanks:\n1. The nets are made from __________ and can reach heights of 12 meters.\n2. The collected water is stored in __________ tanks.",
            BlankAcceptTexts = new Dictionary<string, string[]>
            {
                { "0", new[] { "polypropylene", "polypropylene nets" } },
                { "1", new[] { "underground", "underground tanks" } }
            }
        };

        // Q4: Multiple Choice
        var q4Id = Guid.Parse("33333333-3333-3333-3333-333333333334");
        var q4Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 0, ContentMd = "A. Nets are too expensive to maintain", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 1, ContentMd = "B. Algae buildup can reduce efficiency by up to 40%", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 2, ContentMd = "C. Communities refuse to participate in maintenance", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 3, ContentMd = "D. The nets only work during certain months", IsCorrect = false }
        };
        var q4 = new ExamQuestion
        {
            Id = q4Id, SectionId = section1Id, Idx = 3,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 3,
            PromptMd = "What is mentioned as a potential problem with the fog harvesting system?",
            Options = q4Options
        };

        // Q5: True/False/Not Given
        var q5Id = Guid.Parse("33333333-3333-3333-3333-333333333335");
        var q5Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 0, ContentMd = "A. True", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 1, ContentMd = "B. False", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 2, ContentMd = "C. Not Given", IsCorrect = false }
        };
        var q5 = new ExamQuestion
        {
            Id = q5Id, SectionId = section1Id, Idx = 4,
            Type = QuestionType.TrueFalseNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "The Chilean government began collaborating with the Chungungo community in 1993.",
            Options = q5Options
        };

        // Q6: Classification (Matching Headings)
        var q6Id = Guid.Parse("33333333-3333-3333-3333-333333333336");
        var q6 = new ExamQuestion
        {
            Id = q6Id, SectionId = section2Id, Idx = 0,
            Type = QuestionType.Classification, Skill = "READING", Difficulty = 3,
            PromptMd = "Classify the following as referring to:\nA. dopamine research\nB. cultural factors\nC. musical training\n\n1. Instrumental musicians typically have more gray matter in their auditory cortices.\n2. What one person considers beautiful music, another may find completely uninteresting.\n3. The brain shows similar activity patterns when listening to music and eating chocolate.",
            MatchPairs = new Dictionary<string, string[]?>
            {
                { "0", new[] { "C" } },
                { "1", new[] { "B" } },
                { "2", new[] { "A" } }
            }
        };

        // Q7: Sentence Completion
        var q7Id = Guid.Parse("33333333-3333-3333-3333-333333333337");
        var q7 = new ExamQuestion
        {
            Id = q7Id, SectionId = section2Id, Idx = 1,
            Type = QuestionType.SentenceCompletion, Skill = "READING", Difficulty = 2,
            PromptMd = "Complete the sentences:\n1. Listening to preferred music significantly reduces __________ levels.\n2. The brain structure that manages emotional responses is called the __________.",
            BlankAcceptTexts = new Dictionary<string, string[]>
            {
                { "0", new[] { "cortisol" } },
                { "1", new[] { "nucleus accumbens" } }
            }
        };

        // Q8: Multiple Choice
        var q8Id = Guid.Parse("33333333-3333-3333-3333-333333333338");
        var q8Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 0, ContentMd = "A. They practice language while reading sheet music", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 1, ContentMd = "B. Musical training strengthens the brain's sound pattern recognition", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 2, ContentMd = "C. Music contains embedded linguistic information", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 3, ContentMd = "D. Musicians have higher overall IQ scores", IsCorrect = false }
        };
        var q8 = new ExamQuestion
        {
            Id = q8Id, SectionId = section2Id, Idx = 2,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 2,
            PromptMd = "According to the passage, why might musicians be better at learning languages?",
            Options = q8Options
        };

        // Q9: Yes/No/Not Given
        var q9Id = Guid.Parse("33333333-3333-3333-3333-333333333339");
        var q9Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 0, ContentMd = "A. Yes", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 1, ContentMd = "B. No", IsCorrect = false }
        };
        var q9 = new ExamQuestion
        {
            Id = q9Id, SectionId = section2Id, Idx = 3,
            Type = QuestionType.YesNoNotGiven, Skill = "READING", Difficulty = 2,
            PromptMd = "Concentration-enhancing playlists typically feature music with moderate complexity.",
            Options = q9Options
        };

        // Q10: Flow Chart Completion
        var q10Id = Guid.Parse("33333333-3333-3333-3333-333333333341");
        var q10 = new ExamQuestion
        {
            Id = q10Id, SectionId = section3Id, Idx = 0,
            Type = QuestionType.FlowChartCompletion, Skill = "READING", Difficulty = 3,
            PromptMd = "Complete the flow chart:\n1. Plant seeds in __________\n2. Install LED lights to simulate __________\n3. Use __________ to deliver nutrients\n4. Maintain optimal __________ and humidity\n5. Harvest and package for __________",
            BlankAcceptTexts = new Dictionary<string, string[]>
            {
                { "0", new[] { "stacked layers", "layers" } },
                { "1", new[] { "sunlight" } },
                { "2", new[] { "hydroponic systems", "hydroponics" } },
                { "3", new[] { "temperature" } },
                { "4", new[] { "supermarkets", "sale" } }
            }
        };

        // Q11: Short Answer
        var q11Id = Guid.Parse("33333333-3333-3333-3333-333333333342");
        var q11 = new ExamQuestion
        {
            Id = q11Id, SectionId = section3Id, Idx = 1,
            Type = QuestionType.ShortAnswer, Skill = "READING", Difficulty = 2,
            PromptMd = "1. What company pioneered vertical farming in Singapore?\n2. How many vertical farms does Spread Co. operate in Japan?\n3. In which city was a former textile factory converted into a vertical farm?",
            ShortAnswerAcceptTexts = new List<string> { "Sky Greens", "18", "Detroit" }
        };

        // Q12: Multiple Choice
        var q12Id = Guid.Parse("33333333-3333-3333-3333-333333333343");
        var q12Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q12Id, Idx = 0, ContentMd = "A. Staple crops like wheat and rice cannot be grown economically", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q12Id, Idx = 1, ContentMd = "B. LED lights are too expensive for commercial use", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q12Id, Idx = 2, ContentMd = "C. Hydroponic systems require constant supervision", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q12Id, Idx = 3, ContentMd = "D. Vertical farms can only produce leafy greens", IsCorrect = false }
        };
        var q12 = new ExamQuestion
        {
            Id = q12Id, SectionId = section3Id, Idx = 2,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", Difficulty = 3,
            PromptMd = "What limitation of vertical farming is mentioned in the passage?",
            Options = q12Options
        };

        // Q13: Diagram Label
        var q13Id = Guid.Parse("33333333-3333-3333-3333-333333333344");
        var q13 = new ExamQuestion
        {
            Id = q13Id, SectionId = section3Id, Idx = 3,
            Type = QuestionType.DiagramLabel, Skill = "READING", Difficulty = 2,
            PromptMd = "Label the diagram using no more than three words from the passage.\n[Diagram: LED system, Water system, Climate control, Harvest area]",
            BlankAcceptTexts = new Dictionary<string, string[]>
            {
                { "0", new[] { "LED lights", "LED" } },
                { "1", new[] { "hydroponic system", "hydroponics" } },
                { "2", new[] { "climate control" } },
                { "3", new[] { "harvest", "harvest area" } }
            }
        };

        db.Exams.Add(exam);
        db.ExamSections.AddRange(section1, section2, section3);
        db.ExamQuestions.AddRange(q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13);

        await db.SaveChangesAsync();
        Console.WriteLine("Seeded reading exam with 13 questions across 3 sections.");
    }
}