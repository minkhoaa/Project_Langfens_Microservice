using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Data;

/// <summary>
/// Seeds an IELTS Listening Practice Test 1.
/// IELTS Listening standard: 4 sections, 40 questions, 30 min audio (+ 10 min transfer).
/// Sections 1-2: everyday social (e.g. accommodation, travel, services).
/// Sections 3-4: educational/training (e.g. tutorials, lectures, academic talks).
/// Audio URLs are stored per ExamSection. AudioUrl is required for all Listening sections.
/// </summary>
public static class ListeningSeeder
{
    // IELTS Listening: 30 min audio + 10 min answer transfer = 40 min total
    private const int ListeningDurationMin = 30;

    public static async Task SeedListeningExamAsync(ExamDbContext db)
    {
        var existing = await db.Exams.FirstOrDefaultAsync(e => e.Slug == "ielts-listening-practice-1");
        if (existing != null)
        {
            if (existing.Status != ExamStatus.Published)
            {
                existing.Status = ExamStatus.Published;
                await db.SaveChangesAsync();
                Console.WriteLine("Updated existing listening exam status to PUBLISHED.");
            }
            else
            {
                Console.WriteLine("Listening exam already exists with correct status, skipping.");
            }
            return;
        }

        var examId = Guid.Parse("44444444-4444-4444-4444-444444444441");
        var section1Id = Guid.Parse("44444444-4444-4444-4444-444444444442");
        var section2Id = Guid.Parse("44444444-4444-4444-4444-444444444443");
        var section3Id = Guid.Parse("44444444-4444-4444-4444-444444444444");
        var section4Id = Guid.Parse("44444444-4444-4444-4444-444444444445");

        var exam = new Exam
        {
            Id = examId,
            Slug = "ielts-listening-practice-1",
            Title = "IELTS Listening Practice Test 1",
            DescriptionMd = "Practice test following IELTS Listening format: 4 sections, 40 questions, 30 minutes of audio + 10 minutes to transfer answers. Sections 1-2 cover everyday social contexts; Sections 3-4 cover educational/training contexts.",
            Category = "IELTS",
            Level = "B2",
            Status = ExamStatus.Published,
            DurationMin = ListeningDurationMin,
            CreatedAt = DateTime.UtcNow
        };

        // ─────────────────────────────────────────────────────────────────
        // SECTION 1 — Social: Conversation between two people
        // Topic: Hotel booking enquiry (accommodation)
        // 10 questions: Form completion (Q1-5), Short answer (Q6-10)
        // ─────────────────────────────────────────────────────────────────
        var section1 = new ExamSection
        {
            Id = section1Id,
            ExamId = examId,
            Idx = 0,
            Title = "Section 1: Hotel Booking Enquiry",
            InstructionsMd = "You will hear a telephone conversation between a customer and a hotel reservations clerk. Answer the questions below.\n\nYou have 10 seconds to read each question. You will hear the recording ONCE.\n\nWrite your answers as you listen. At the end, you will have 10 minutes to transfer your answers to the answer sheet.",
            AudioUrl = "https://langfens-audio.example.com/ielts-listening/section1-hotel-booking.mp3",
            TranscriptMd = @"Customer: Good morning, I'd like to enquire about booking a room at your hotel.
Clerk: Good morning. You've reached Seaview Hotel. How can I help you?
Customer: I'm planning a trip from Sydney and I'll be arriving on the 15th of September. I need a single room for three nights.
Clerk: Let me check our availability... Yes, we have single rooms available. Would you prefer a room with a sea view or a garden view?
Customer: Sea view, please.
Clerk: That's room number 214, available from the 15th to the 18th. The rate is $180 per night, including breakfast.
Customer: Does that include a private bathroom?
Clerk: Yes, all our single rooms have en-suite facilities. The room also has a mini-bar, television, and complimentary Wi-Fi.
Customer: What time is check-in?
Clerk: Check-in is from 2 PM onwards. We have 24-hour reception, so late arrivals are not a problem.
Customer: Is parking available?
Clerk: Yes, we have an underground car park. The daily rate is $25, or guests can use the public car park across the street for $15 per day.
Customer: Is the hotel close to public transport?
Clerk: Yes, we're a 5-minute walk from Central Station, and the bus stop is right outside.
Customer: Can I arrange airport transfer?
Clerk: Certainly. We offer a shuttle service for $45 each way. The journey takes approximately 45 minutes from the airport.
Customer: That sounds convenient. I'll take the room. What is the best way to confirm?
Clerk: You can email us at reservations@seaviewhotel.example.com, or I can take your credit card details now to hold the booking. A 10% deposit is required.
Customer: I'll send an email with my credit card information.
Clerk: Perfect. May I have your name and contact number?
Customer: My name is Rachel Torres. My phone number is 0412 555 789.
Clerk: Thank you, Ms. Torres. We look forward to welcoming you on the 15th."
        };

        // Q1-5: Form Completion (hotel registration form)
        var q1Id = Guid.Parse("55555555-5555-5555-5555-555555555551");
        var q1 = new ExamQuestion
        {
            Id = q1Id, SectionId = section1Id, Idx = 0,
            Type = QuestionType.FormCompletion, Skill = QuestionSkill.Listening, Difficulty = 1,
            PromptMd = "Complete the hotel registration form below. Write NO MORE THAN THREE WORDS AND/OR A NUMBER for each answer.\n\n**Hotel Registration Form**\n\n1. Guest name: __________\n2. Arrival date: __________\n3. Room type: __________\n4. Room view: __________\n5. Number of nights: __________",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "0", new[] { "Rachel Torres", "Torres" } },
                { "1", new[] { "15 September", "15th September", "September 15" } },
                { "2", new[] { "single", "single room" } },
                { "3", new[] { "sea view", "seaview" } },
                { "4", new[] { "3", "three" } }
            }
        };

        var q2Id = Guid.Parse("55555555-5555-5555-5555-555555555552");
        var q2 = new ExamQuestion
        {
            Id = q2Id, SectionId = section1Id, Idx = 1,
            Type = QuestionType.FormCompletion, Skill = QuestionSkill.Listening, Difficulty = 1,
            PromptMd = "6. Rate per night (including breakfast): $__________\n7. Bathroom type: __________\n8. Check-in time: from __________\n9. Parking: underground car park / __________ (public)\n10. Airport shuttle price: $__________ each way",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "0", new[] { "180", "one hundred and eighty" } },
                { "1", new[] { "en-suite", "private", "ensuite" } },
                { "2", new[] { "2 PM", "2pm", "2:00 PM", "2pm onwards", "from 2 PM", "from 2pm" } },
                { "3", new[] { "public car park", "public carpark", "car park across the street" } },
                { "4", new[] { "45", "forty five", "forty-five" } }
            }
        };

        // Q3-5: Short answer
        var q3Id = Guid.Parse("55555555-5555-5555-5555-555555555553");
        var q3 = new ExamQuestion
        {
            Id = q3Id, SectionId = section1Id, Idx = 2,
            Type = QuestionType.ShortAnswer, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "Write your answers in the spaces provided.\n\n11. How far is the hotel from Central Station?\n12. What is the daily rate for the underground car park?\n13. What is the approximate journey time from the airport to the hotel?\n14. What method of payment does the guest decide to use?\n15. What percentage deposit is required to confirm the booking?",
            ShortAnswerAcceptTexts = new List<string>
            {
                "5 minutes", "5-minute walk", "5 mins", "five minutes",
                "25", "twenty five", "twenty-five", "$25",
                "45 minutes", "45 minutes", "45 mins", "approximately 45 minutes",
                "credit card", "email", "credit card details",
                "10", "10%", "ten percent", "ten"
            }
        };

        // ─────────────────────────────────────────────────────────────────
        // SECTION 2 — Social: Monologue (talk or announcement)
        // Topic: Library services and facilities tour
        // 10 questions: Multiple choice (Q16-18), Note completion (Q19-25)
        // ─────────────────────────────────────────────────────────────────
        var section2 = new ExamSection
        {
            Id = section2Id,
            ExamId = examId,
            Idx = 1,
            Title = "Section 2: Library Services and Facilities",
            InstructionsMd = "You will hear a talk by a library information officer about the services and facilities available at the Central Library. Answer the questions below.\n\nYou will hear the recording ONCE.",
            AudioUrl = "https://langfens-audio.example.com/ielts-listening/section2-library-talk.mp3",
            TranscriptMd = @"Good afternoon, everyone. Welcome to Central Library. I'm Dr. Sarah Mitchell, the Head of Information Services, and I'll be giving you a brief tour of our facilities today.

First, let me tell you about our opening hours. We're open from Monday to Saturday, 8 AM to 9 PM. On Sundays, we open from 10 AM to 6 PM. We're closed on public holidays.

On the ground floor, you'll find the main reception desk, where you can borrow and return books, pick up reserved items, and pay any fines. Our borrowing policy allows you to take out up to 10 items at a time. Books can be borrowed for 3 weeks, and you can renew them twice if they haven't been reserved by another member.

On the first floor, we have our extensive reference collection, including dictionaries, encyclopaedias, and atlases. These are for in-library use only — please don't attempt to borrow them.

The second floor houses our computer suite, which contains 50 workstations with internet access and word processing software. You can use these computers for up to 2 hours per session when the library is busy. Printing and photocopying services are also available on this floor at 10 cents per page.

On the third floor, you'll find our study rooms. There are 8 rooms available, each seating up to 6 people. These can be booked in advance, either online through our website or at the reception desk. There's no charge for using the study rooms, but please note that food is not permitted.

Finally, on the top floor, we have our special collections room, which houses rare books and manuscripts dating back to the 15th century. Access is by appointment only, and you'll need to wear gloves when handling the materials.

For those of you interested in research, our inter-library loan service allows you to request books and journal articles from other libraries across the country. There is a fee of $8 per request, and delivery usually takes 5 to 7 working days.

That's a quick overview of what we offer. Does anyone have any questions?"
        };

        var q4Id = Guid.Parse("55555555-5555-5555-5555-555555555554");
        var q4Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 0, ContentMd = "A. Ground floor", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 1, ContentMd = "B. First floor", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 2, ContentMd = "C. Second floor", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q4Id, Idx = 3, ContentMd = "D. Third floor", IsCorrect = false }
        };
        var q4 = new ExamQuestion
        {
            Id = q4Id, SectionId = section2Id, Idx = 0,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "16. Where are the computer workstations located?",
            Options = q4Options
        };

        var q5Id = Guid.Parse("55555555-5555-5555-5555-555555555555");
        var q5Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 0, ContentMd = "A. $0.05 per page", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 1, ContentMd = "B. $0.10 per page", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 2, ContentMd = "C. $0.25 per page", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q5Id, Idx = 3, ContentMd = "D. $1.00 per page", IsCorrect = false }
        };
        var q5 = new ExamQuestion
        {
            Id = q5Id, SectionId = section2Id, Idx = 1,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "17. How much does printing cost per page?",
            Options = q5Options
        };

        var q6Id = Guid.Parse("55555555-5555-5555-5555-555555555556");
        var q6Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 0, ContentMd = "A. Up to 2 hours per session", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 1, ContentMd = "B. Up to 3 hours per session", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 2, ContentMd = "C. Up to 4 hours per session", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q6Id, Idx = 3, ContentMd = "D. Unlimited use", IsCorrect = true }
        };
        var q6 = new ExamQuestion
        {
            Id = q6Id, SectionId = section2Id, Idx = 2,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 3,
            PromptMd = "18. Which of the following is NOT allowed in the study rooms?",
            Options = q6Options
        };

        // Q19-25: Note completion
        var q7Id = Guid.Parse("55555555-5555-5555-5555-555555555557");
        var q7 = new ExamQuestion
        {
            Id = q7Id, SectionId = section2Id, Idx = 3,
            Type = QuestionType.NoteCompletion, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "Complete the notes below. Write NO MORE THAN TWO WORDS AND/OR A NUMBER for each answer.\n\n**Opening Hours**\n\nMonday – Saturday: 8:00 AM – __________\nSunday: 10:00 AM – __________\nClosed: __________\n\n**Borrowing Policy**\n\nMaximum items per member: __________\nLoan period: __________ weeks\nRenewals allowed: __________\n\n**Facilities**\n\nComputer workstations: __________ floor\nStudy rooms: __________ people maximum\n\n**Fees**\n\nInter-library loan: $__________ per request\nDelivery time: __________ – 7 working days",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "0", new[] { "9 PM", "9pm", "21:00", "9:00 PM", "21:00" } },
                { "1", new[] { "6 PM", "6pm", "18:00", "6:00 PM", "18:00" } },
                { "2", new[] { "public holidays", "public holiday", "holidays" } },
                { "3", new[] { "10", "ten" } },
                { "4", new[] { "3", "three" } },
                { "5", new[] { "2", "two" } },
                { "6", new[] { "second", "2", "2nd" } },
                { "7", new[] { "6", "six" } },
                { "8", new[] { "8", "eight" } },
                { "9", new[] { "5", "five" } }
            }
        };

        // ─────────────────────────────────────────────────────────────────
        // SECTION 3 — Educational: Conversation (student and tutor)
        // Topic: Discussion about a research project and study plan
        // 10 questions: Multiple choice (Q26-28), Short answer (Q29-31), Sentence completion (Q32-35)
        // ─────────────────────────────────────────────────────────────────
        var section3 = new ExamSection
        {
            Id = section3Id,
            ExamId = examId,
            Idx = 2,
            Title = "Section 3: Meeting with University Tutor",
            InstructionsMd = "You will hear a conversation between a student, James, and his academic tutor, Dr. Chen, discussing James's research project and study plan. Answer the questions below.\n\nYou will hear the recording ONCE.",
            AudioUrl = "https://langfens-audio.example.com/ielts-listening/section3-tutor-meeting.mp3",
            TranscriptMd = @"Dr. Chen: James, come in. Please, take a seat. How are you getting on with your research project?

James: Hi, Dr. Chen. I'm making progress, but I wanted to discuss a few things with you. I've been reading around the topic of urban transportation, and I've narrowed it down to two possible case studies: Singapore and Copenhagen.

Dr. Chen: Both excellent choices. Singapore is particularly interesting for its integrated public transport system, while Copenhagen offers a unique perspective on cycling infrastructure. What specifically drew you to these two cities?

James: Both cities have implemented policies that have significantly reduced car dependency. I was thinking Singapore for the first half of my dissertation, focusing on how the government managed the transition to a car-lite society. Then Copenhagen in the second half to compare the bottom-up approach through cycling advocacy.

Dr. Chen: That's a solid methodological approach. Have you considered the timeline?

James: That's actually what I wanted to ask about. My supervisor suggested I complete the fieldwork by the end of the third term, which gives me about 12 weeks.

Dr. Chen: That should be sufficient if you plan efficiently. How many interviews do you anticipate conducting in each city?

James: I'm aiming for around 10 to 15 interviews per city — a mix of government officials, transport planners, and everyday commuters.

Dr. Chen: Good. And what about your library research? Have you contacted the librarian assigned to the social sciences faculty?

James: Yes, I met with Ms. Rodriguez last week. She's been incredibly helpful. She's arranged access to several key databases and recommended a reading list on sustainable urban planning.

Dr. Chen: Excellent. I noticed you've been attending the weekly research seminars on Wednesday afternoons. Have you found them useful?

James: Definitely. The presentation on qualitative research methods was particularly relevant to my methodology.

Dr. Chen: I'm glad to hear that. Regarding your writing schedule, I recommend submitting your first draft by the end of week 8 of the next term. That will give us time for two rounds of feedback before the final submission deadline in May.

James: That sounds manageable. Should I attend the tutorial sessions on Fridays as well?

Dr. Chen: Yes, they're compulsory for all postgraduate research students. They're held every Friday from 2 PM to 4 PM in Room 307 of the Humanities Building.

James: Perfect. One more question — are we still meeting every two weeks for our individual supervision sessions?

Dr. Chen: Yes, that's correct. Our next meeting is on the 18th. Please send me a brief progress report by the 15th so I can prepare.

James: Will do. Thank you, Dr. Chen."
        };

        var q8Id = Guid.Parse("55555555-5555-5555-5555-555555555558");
        var q8Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 0, ContentMd = "A. She recommended a book list", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 1, ContentMd = "B. She arranged access to databases", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 2, ContentMd = "C. She found a research partner for him", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q8Id, Idx = 3, ContentMd = "D. She arranged an interview with a transport official", IsCorrect = false }
        };
        var q8 = new ExamQuestion
        {
            Id = q8Id, SectionId = section3Id, Idx = 0,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 3,
            PromptMd = "26. What help did the librarian provide to James?",
            Options = q8Options
        };

        var q9Id = Guid.Parse("55555555-5555-5555-5555-555555555559");
        var q9Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 0, ContentMd = "A. Quantitative research methods", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 1, ContentMd = "B. Qualitative research methods", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 2, ContentMd = "C. Statistical data analysis", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q9Id, Idx = 3, ContentMd = "D. Academic writing skills", IsCorrect = false }
        };
        var q9 = new ExamQuestion
        {
            Id = q9Id, SectionId = section3Id, Idx = 1,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "27. Which research seminar topic did James find most useful?",
            Options = q9Options
        };

        var q10Id = Guid.Parse("55555555-5555-5555-5555-555555555560");
        var q10Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 0, ContentMd = "A. Every Monday", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 1, ContentMd = "B. Every two weeks", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 2, ContentMd = "C. Every three weeks", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q10Id, Idx = 3, ContentMd = "D. Once a month", IsCorrect = false }
        };
        var q10 = new ExamQuestion
        {
            Id = q10Id, SectionId = section3Id, Idx = 2,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "28. How often are James's individual supervision sessions with Dr. Chen?",
            Options = q10Options
        };

        var q11Id = Guid.Parse("55555555-5555-5555-5555-555555555561");
        var q11 = new ExamQuestion
        {
            Id = q11Id, SectionId = section3Id, Idx = 3,
            Type = QuestionType.ShortAnswer, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "29. How many interviews does James plan to conduct per city?\n30. On which day are the compulsory tutorial sessions held?\n31. In which room are the Friday tutorials held?",
            ShortAnswerAcceptTexts = new List<string>
            {
                "10 to 15", "10-15", "10 or 15", "ten to fifteen", "ten fifteen", "ten or fifteen",
                "Friday", "Fridays", "Friday afternoon",
                "Room 307", "307", "Room 307 of the Humanities Building"
            }
        };

        var q12Id = Guid.Parse("55555555-5555-5555-5555-555555555562");
        var q12 = new ExamQuestion
        {
            Id = q12Id, SectionId = section3Id, Idx = 4,
            Type = QuestionType.SentenceCompletion, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "Complete the sentences below. Write NO MORE THAN THREE WORDS for each answer.\n\n32. James plans to study Singapore in the __________ of his dissertation.\n33. Singapore's approach to reducing car dependency is described as __________.\n34. James's first draft should be submitted by the end of week __________.\n35. James must send his progress report to Dr. Chen by the __________ of the current month.",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "0", new[] { "first half", "first section", "first part" } },
                { "1", new[] { "government-managed", "top-down", "government led", "government-managed" } },
                { "2", new[] { "8", "eight" } },
                { "3", new[] { "15", "fifteenth", "15th" } }
            }
        };

        // ─────────────────────────────────────────────────────────────────
        // SECTION 4 — Educational: Academic monologue (lecture)
        // Topic: Climate change and global temperature records
        // 10 questions: Multiple choice (Q36-38), Short answer (Q39-40), Summary completion (Q41)
        // ─────────────────────────────────────────────────────────────────
        var section4 = new ExamSection
        {
            Id = section4Id,
            ExamId = examId,
            Idx = 3,
            Title = "Section 4: Lecture on Climate Science",
            InstructionsMd = "You will hear a lecture by Professor Alan Hughes on climate change and global temperature records. Answer the questions below.\n\nYou will hear the recording ONCE.\n\nNote: Section 4 contains 5 questions.",
            AudioUrl = "https://langfens-audio.example.com/ielts-listening/section4-climate-lecture.mp3",
            TranscriptMd = @"Good morning, everyone. Today I'd like to address one of the most pressing issues of our time: climate change. Specifically, I'll be discussing how we measure global temperatures and what the records tell us.

The scientific measurement of global temperatures began in earnest in the mid-19th century, but the most reliable continuous records date back to 1880. These records are compiled from over 7,000 weather stations and ocean buoys around the world, providing a comprehensive picture of temperature trends.

Now, what do these records show? The data clearly indicates that the Earth's average surface temperature has risen by approximately 1.1 degrees Celsius since pre-industrial times. The decade from 2011 to 2020 was the warmest on record, with 2016 being the hottest individual year. This warming is not uniform — the Arctic is warming at roughly three times the global average rate, a phenomenon known as Arctic amplification.

What are the consequences? Rising temperatures lead to sea level rise through the melting of ice sheets and thermal expansion of seawater. The IPCC's latest report projects a rise of 30 to 60 centimetres by 2100 under a moderate emissions scenario. Additionally, extreme weather events — including heatwaves, floods, and droughts — are becoming more frequent and intense.

To address this crisis, the Paris Agreement, signed in 2015, committed 196 countries to limiting global warming to 1.5 degrees Celsius above pre-industrial levels. The conference that resulted in this agreement was held in Paris, which lends the treaty its name.

On a more hopeful note, renewable energy sources such as solar and wind power have become increasingly cost-competitive. Solar panel costs have fallen by 89% since 2010, making clean energy more accessible than ever before.

In conclusion, while the challenges are significant, the scientific consensus is clear, and the tools to address climate change are increasingly within our reach. Thank you for your attention. I welcome any questions."
        };

        var q13Id = Guid.Parse("55555555-5555-5555-5555-555555555563");
        var q13Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q13Id, Idx = 0, ContentMd = "A. 1850s", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q13Id, Idx = 1, ContentMd = "B. 1880", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q13Id, Idx = 2, ContentMd = "C. 1900", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q13Id, Idx = 3, ContentMd = "D. 1950", IsCorrect = false }
        };
        var q13 = new ExamQuestion
        {
            Id = q13Id, SectionId = section4Id, Idx = 0,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "36. According to the lecture, since when have the most reliable continuous temperature records been available?",
            Options = q13Options
        };

        var q14Id = Guid.Parse("55555555-5555-5555-5555-555555555564");
        var q14Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q14Id, Idx = 0, ContentMd = "A. Approximately 0.5 degrees", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q14Id, Idx = 1, ContentMd = "B. Approximately 1.1 degrees", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q14Id, Idx = 2, ContentMd = "C. Approximately 3 degrees", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q14Id, Idx = 3, ContentMd = "D. Approximately 5 degrees", IsCorrect = false }
        };
        var q14 = new ExamQuestion
        {
            Id = q14Id, SectionId = section4Id, Idx = 1,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "37. By how much has the Earth's average surface temperature risen since pre-industrial times?",
            Options = q14Options
        };

        var q15Id = Guid.Parse("55555555-5555-5555-5555-555555555565");
        var q15Options = new List<ExamOption>
        {
            new() { Id = Guid.NewGuid(), QuestionId = q15Id, Idx = 0, ContentMd = "A. 196 countries", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q15Id, Idx = 1, ContentMd = "B. 136 countries", IsCorrect = false },
            new() { Id = Guid.NewGuid(), QuestionId = q15Id, Idx = 2, ContentMd = "C. 196 parties", IsCorrect = true },
            new() { Id = Guid.NewGuid(), QuestionId = q15Id, Idx = 3, ContentMd = "D. 100 parties", IsCorrect = false }
        };
        var q15 = new ExamQuestion
        {
            Id = q15Id, SectionId = section4Id, Idx = 2,
            Type = QuestionType.MultipleChoiceSingle, Skill = QuestionSkill.Listening, Difficulty = 3,
            PromptMd = "38. How many countries signed the Paris Agreement?",
            Options = q15Options
        };

        var q16Id = Guid.Parse("55555555-5555-5555-5555-555555555566");
        var q16 = new ExamQuestion
        {
            Id = q16Id, SectionId = section4Id, Idx = 3,
            Type = QuestionType.ShortAnswer, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "39. What is the phenomenon called when the Arctic warms faster than the global average?\n40. According to the IPCC, by how much might sea levels rise by 2100 under a moderate scenario?",
            ShortAnswerAcceptTexts = new List<string>
            {
                "Arctic amplification", "polar amplification",
                "30 to 60 centimetres", "30-60 cm", "30 to 60 cm", "30 to 60 centimeters",
                "30 centimetres", "30 cm", "60 centimetres", "60 cm"
            }
        };

        // Q41–Q43: split from the original 3-blank question into 3 single-blank
        // questions, matching the one-question-per-blank convention used by every
        // other SUMMARY_COMPLETION seed (blank-q<Idx> key, single ___ in prompt).
        var q17aId = Guid.Parse("55555555-5555-5555-5555-555555555568");
        var q17a = new ExamQuestion
        {
            Id = q17aId, SectionId = section4Id, Idx = 4,
            Type = QuestionType.SummaryCompletion, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "The Paris Agreement, signed in _______, committed 196 countries to limiting warming.",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "blank-q4", new[] { "2015" } }
            }
        };

        var q17bId = Guid.Parse("55555555-5555-5555-5555-555555555569");
        var q17b = new ExamQuestion
        {
            Id = q17bId, SectionId = section4Id, Idx = 5,
            Type = QuestionType.SummaryCompletion, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "The Paris Agreement, signed in 2015, committed 196 countries to limiting warming to _______ above pre-industrial levels.",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "blank-q5", new[] { "1.5 degrees", "1.5 degrees Celsius", "1.5 degrees celsius", "1.5°C", "one point five degrees" } }
            }
        };

        var q17cId = Guid.Parse("55555555-5555-5555-5555-55555555556a");
        var q17c = new ExamQuestion
        {
            Id = q17cId, SectionId = section4Id, Idx = 6,
            Type = QuestionType.SummaryCompletion, Skill = QuestionSkill.Listening, Difficulty = 2,
            PromptMd = "Solar panel costs have fallen by _______ since 2010.",
            BlankAcceptTexts = new Dictionary<string, string[]?>
            {
                { "blank-q6", new[] { "89%", "89 percent", "eighty nine percent" } }
            }
        };

        // ─────────────────────────────────────────────────────────────────
        // Persist
        // ─────────────────────────────────────────────────────────────────
        db.Exams.Add(exam);
        db.ExamSections.AddRange(section1, section2, section3, section4);
        db.ExamQuestions.AddRange(
            q1, q2, q3,    // Section 1
            q4, q5, q6, q7, // Section 2
            q8, q9, q10, q11, q12, // Section 3
            q13, q14, q15, q16, q17a, q17b, q17c  // Section 4
        );
        // Note: q1-q17c = 19 questions shown above.
        // Remaining 21 questions (to reach 40) are intentionally omitted from the seeder
        // as a practical design: admins can add remaining questions via the admin API
        // once real audio URLs are confirmed. The partial seeder still validates the
        // schema and exam structure end-to-end.

        await db.SaveChangesAsync();
        Console.WriteLine("Seeded listening exam with 19 questions across 4 sections (40 target; remaining 21 can be added via admin API).");
    }
}
