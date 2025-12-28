-- ============================================
-- IELTS Placement Test SQL
-- Updated: 2025-12-28
-- Proper IELTS-style with PassageMd and related questions
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data
DELETE FROM exam_question_groups WHERE "SectionId" IN (
  SELECT s."Id" FROM exam_sections s
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'english-placement-a2-c1-sample-01'
);
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'english-placement-a2-c1-sample-01'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'english-placement-a2-c1-sample-01';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'english-placement-a2-c1-sample-01';
DELETE FROM exams WHERE "Slug" = 'english-placement-a2-c1-sample-01';

DO $$
DECLARE
  exam_id uuid := 'c69a3e54-a7f1-40eb-ab69-1f50ca798267';
  sec_reading uuid := '7fb25cae-8211-4baa-a93c-e14ec55160e7';
  sec_listening uuid := '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d';
  sec_writing uuid := 'b1a5f019-d676-4a64-9a01-a2a504b110e0';
  sec_speaking uuid := 'd8e52f30-1a4b-4c3d-9e6a-7f9b0c1d2e3f';
  qid uuid;
BEGIN

  -- ============================================
  -- INSERT EXAM
  -- ============================================
  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'english-placement-a2-c1-sample-01',
    'English Placement Test A2–C1 – Sample 01',
    E'## English Placement Test (A2–C1)\n\nThis exam is designed to help estimate a learner''s level on the CEFR scale from **A2 to C1**.\n\n**Sections**\n1. Reading – 10 questions based on a passage about the history of coffee\n2. Listening – 8 multiple-choice questions\n3. Writing – 1 short essay task\n4. Speaking – 1 audio response task\n\nDifficulty increases gradually so you can separate lower-level and higher-level learners.',
    'PLACEMENT',
    'B1',
    'PUBLISHED',
    60,
    now()
  );

  -- ============================================
  -- SECTION 1: READING (with PassageMd)
  -- ============================================
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl","TranscriptMd")
  VALUES (
    sec_reading,
    exam_id,
    1,
    'Reading – The Story of Coffee',
    E'Read the passage below and answer Questions 1-10.\n\nFor Questions 1-5, choose TRUE, FALSE, or NOT GIVEN.\nFor Questions 6-10, complete the summary with ONE WORD ONLY from the passage.',
    E'## The Story of Coffee\n\n**A.** Coffee is one of the most popular beverages in the world today, with billions of cups consumed daily. However, few people know about its fascinating origins and the long journey it took to become a global phenomenon. The story of coffee begins in the ancient highlands of Ethiopia, where legend has it that a goat herder named Kaldi first discovered the energizing effects of coffee beans around 850 AD.\n\n**B.** According to the legend, Kaldi noticed that his goats became unusually energetic after eating the red berries from a particular bush. Curious about this discovery, he tried the berries himself and experienced a similar burst of energy. Kaldi shared his discovery with a local **monastery**, where monks found that the berries helped them stay awake during long hours of prayer. They began brewing a drink from the berries, creating one of the earliest forms of coffee.\n\n**C.** From Ethiopia, coffee spread to the **Arabian** Peninsula, where it was first cultivated and traded. By the 15th century, coffee was being grown in Yemen, and the port city of Mocha became a major center for the coffee trade. The drink quickly became popular throughout the Middle East, where coffee houses, known as **qahveh khaneh**, became important social gathering places. These establishments were centers of conversation, music, and intellectual discussion.\n\n**D.** European travelers to the Middle East first encountered coffee in the 17th century. Initially, some Europeans viewed the dark, bitter drink with suspicion. The **Pope** was even asked to ban coffee, but after tasting it himself, he reportedly gave it his **blessing** instead. Coffee houses soon spread across Europe, becoming popular meeting places for artists, writers, and businessmen. In England, they were sometimes called "penny universities" because for the price of a cup of coffee, one could engage in stimulating conversation and learn from others.\n\n**E.** The global spread of coffee cultivation began in earnest during the 18th century. The Dutch were among the first Europeans to grow coffee outside Arabia, establishing plantations in their **colonies** in Indonesia. The French introduced coffee to the Caribbean, while the Portuguese brought it to **Brazil**, which would eventually become the world''s largest coffee producer. Today, coffee is grown in tropical regions around the world, supporting millions of farmers and workers in what is known as the "coffee belt."\n\n**F.** Modern coffee culture has evolved significantly from its humble origins. Specialty coffee shops now offer countless varieties and brewing methods, from espresso and cappuccino to cold brew and pour-over. Despite these innovations, the fundamental appeal of coffee remains the same: its rich flavor, stimulating effects, and the social connections it helps create. Whether enjoyed in a busy city café or a quiet home kitchen, coffee continues to bring people together, just as it has for centuries.',
    NULL,
    NULL
  );

  -- Questions 1-5: TRUE/FALSE/NOT GIVEN
  qid := 'e781d97a-2e93-4268-9961-1d8c5ca8bc30';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_reading, 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 1, 
    'Kaldi was the first person to drink coffee.',
    E'**Answer: NOT GIVEN**\n\nThe passage says Kaldi discovered the energizing effects and tried the berries himself, but it doesn''t state he was the first person to ever drink coffee.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := '27a35c33-9de6-4e0e-83b7-df156760d719';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_reading, 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 1, 
    'Coffee was originally discovered in Yemen.',
    E'**Answer: FALSE**\n\nThe passage clearly states coffee originated in Ethiopia: "The story of coffee begins in the ancient highlands of Ethiopia."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := 'e1f49473-49e1-4fcb-937c-f9ab8a5b364f';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_reading, 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, 
    'Monks used coffee to help them stay awake for prayer.',
    E'**Answer: TRUE**\n\nParagraph B states: "monks found that the berries helped them stay awake during long hours of prayer."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := 'f0bc525f-76ed-4141-9071-21005b38855c';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_reading, 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, 
    'The Pope banned coffee when it was first introduced to Europe.',
    E'**Answer: FALSE**\n\nParagraph D states the Pope "gave it his blessing instead" after tasting coffee, contrary to expectations that he would ban it.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := '355c57e7-3f38-4947-aa21-e5eaad8a4d67';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_reading, 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, 
    'Brazil currently produces more coffee than any other country.',
    E'**Answer: TRUE**\n\nParagraph E states Brazil "would eventually become the world''s largest coffee producer."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  -- Questions 6-10: SUMMARY COMPLETION
  qid := '7c5343b4-dc7e-4e9c-9f24-c10597931551';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (qid, sec_reading, 6, 'SUMMARY_COMPLETION', 'READING', 2, 
    'Kaldi shared his discovery with a local _______, where monks began brewing the drink.',
    E'**Answer: MONASTERY**\n\nParagraph B: "Kaldi shared his discovery with a local monastery."',
    '{"blank-q6": ["monastery"]}'::jsonb
  );

  qid := 'a5929ff9-7bf8-4b3f-9b18-6e61434117e5';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (qid, sec_reading, 7, 'SUMMARY_COMPLETION', 'READING', 2, 
    'Coffee spread from Ethiopia to the _______ Peninsula.',
    E'**Answer: ARABIAN**\n\nParagraph C: "From Ethiopia, coffee spread to the Arabian Peninsula."',
    '{"blank-q7": ["Arabian"]}'::jsonb
  );

  qid := '5002728b-8c6d-4eb2-aa21-81a4086ee130';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (qid, sec_reading, 8, 'SUMMARY_COMPLETION', 'READING', 3, 
    'The Pope gave coffee his _______ instead of banning it.',
    E'**Answer: BLESSING**\n\nParagraph D: "he reportedly gave it his blessing instead."',
    '{"blank-q8": ["blessing"]}'::jsonb
  );

  qid := 'e77ae559-60bf-42a3-bf1b-c21c1661608c';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (qid, sec_reading, 9, 'SUMMARY_COMPLETION', 'READING', 3, 
    'The Dutch established coffee plantations in their _______ in Indonesia.',
    E'**Answer: COLONIES**\n\nParagraph E: "establishing plantations in their colonies in Indonesia."',
    '{"blank-q9": ["colonies"]}'::jsonb
  );

  qid := '5b24bdf9-241d-4e9f-8ee5-3b65a2ad02a3';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (qid, sec_reading, 10, 'SUMMARY_COMPLETION', 'READING', 3, 
    'The Portuguese brought coffee to _______, which became the largest producer.',
    E'**Answer: BRAZIL**\n\nParagraph E: "the Portuguese brought it to Brazil, which would eventually become the world''s largest coffee producer."',
    '{"blank-q10": ["Brazil"]}'::jsonb
  );

  -- Reading Question Groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec_reading, 1, 1, 5, E'## Questions 1-5\n\nDo the following statements agree with the information given in the passage?\n\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec_reading, 2, 6, 10, E'## Questions 6-10\n\nComplete the summary below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.');

  -- ============================================
  -- SECTION 2: LISTENING
  -- ============================================
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd","PassageMd")
  VALUES (
    sec_listening,
    exam_id,
    2,
    'Listening – Choosing an Online Course',
    E'You will listen to a conversation about choosing an online English course.\n\nAnswer questions 1-8. For each question, choose the best answer **A, B, C or D**.\n\nYou can read the questions before listening.',
    'https://www.youtube.com/embed/V2puNsehQHQ?enablejsapi=1',
    E'**Advisor:** Good morning, LanguageHub support, this is Maria. How can I help you?\n\n**Student:** Hi, I''m interested in your online English course. I work full-time, so I need something flexible.\n\n**Advisor:** Sure. Our standard course has three video lessons per week. Each video is about ten minutes long, and you can watch them whenever you like.\n\n**Student:** That sounds good. How long does the whole course last?\n\n**Advisor:** It''s a twelve-week programme. Most students study around four to five hours per week.\n\n**Student:** Okay. And what level is it? I''m somewhere between B1 and B2, I think.\n\n**Advisor:** We recommend the upper-intermediate group for you. It focuses on speaking in meetings and writing emails.\n\n**Student:** Great. Do I have to pay the full fee at once?\n\n**Advisor:** No, you can pay monthly. There''s also a discount if you pay for the whole course in advance.\n\n**Student:** Last question: will I have a teacher I can ask questions?\n\n**Advisor:** Yes. You''ll have a small group class on Zoom every Thursday evening, and you can message your teacher through the app.',
    E'## Listening Instructions\n\nYou will hear a conversation between a student and an advisor at LanguageHub about their online English course.\n\nListen carefully and answer the questions based on what you hear.'
  );

  -- Listening Questions
  qid := '5cf4f347-5f6a-4f77-8ef1-6bd243a1c029';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 1, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 1, 
    'Why does the student call LanguageHub?',
    E'The student says "I''m interested in your online English course" at the beginning of the conversation.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'To ask about an online English course', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'To complain about a late payment', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'To cancel a face-to-face class', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'To change the time of an exam', false);

  qid := '6e4ef191-f12b-4e16-a338-36988ae149af';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 2, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 1, 
    'How long is each video lesson?',
    E'The advisor says "Each video is about ten minutes long."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'About five minutes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'About ten minutes', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'About thirty minutes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'About one hour', false);

  qid := 'b6ff5dff-d336-49b7-ba3f-11e4fd15b6b7';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 3, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 2, 
    'How many weeks does the whole course last?',
    E'The advisor says "It''s a twelve-week programme."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Eight weeks', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Ten weeks', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Twelve weeks', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Sixteen weeks', false);

  qid := '4e7739a0-a2ad-4d3c-9f7a-9dd63a96ecf7';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 4, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 2, 
    'How many hours per week do most students study?',
    E'The advisor says "Most students study around four to five hours per week."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Around one to two hours', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Around two to three hours', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Around four to five hours', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Around eight to ten hours', false);

  qid := 'cdc75916-12b9-4dc9-8143-9ad7bd3bb223';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 5, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 3, 
    'What does the upper-intermediate group mainly focus on?',
    E'The advisor says "It focuses on speaking in meetings and writing emails."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Grammar for academic essays', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Speaking in meetings and writing emails', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Pronunciation for beginners', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Preparation for IELTS exam', false);

  qid := 'ba2b1c0e-2db0-4c86-b3f6-155c89aeb2ad';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 6, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 3, 
    'What does the advisor say about payment?',
    E'The advisor says "you can pay monthly" and "There''s also a discount if you pay for the whole course in advance."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Students must pay the full fee at once', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Students can only pay in cash at the office', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Students can pay monthly or pay in advance for a discount', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'The course is free for the first month', false);

  qid := '6ed2b20a-8628-4bbc-9117-de6e9ec53f25';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 7, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 4, 
    'When does the small group class on Zoom take place?',
    E'The advisor says "You''ll have a small group class on Zoom every Thursday evening."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Every Monday morning', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Every Wednesday afternoon', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Every Thursday evening', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Every Saturday afternoon', false);

  qid := 'f1a9675b-9386-4f2d-9bfb-9f7dd6e6c8cb';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (qid, sec_listening, 8, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 4, 
    'How can students contact their teacher outside the class?',
    E'The advisor says "you can message your teacher through the app."'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'By sending letters to the school', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'By messaging through the app', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'By calling the teacher''s home number', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'By visiting the office without an appointment', false);

  -- Listening Question Group
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec_listening, 1, 1, 8, E'## Questions 1-8\n\nChoose the correct answer **A, B, C or D**.\n\nListen to the conversation between a student and an advisor at LanguageHub about their online English course.');

  -- ============================================
  -- SECTION 3: WRITING
  -- ============================================
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
  VALUES (
    sec_writing,
    exam_id,
    3,
    'Writing – Short Essay',
    E'This writing task is used to check productive skills.\n\nWrite your answer in the text box. Recommended time: **15–20 minutes**.',
    NULL,
    NULL
  );

  qid := '4f7c3559-b77e-4d61-8b08-b9c5f8f769c3';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
  VALUES (
    qid,
    sec_writing,
    1,
    'SHORT_ANSWER',
    'WRITING',
    4,
    E'### Writing Task\n\nIn many cities and towns, more people are buying things online instead of in traditional shops.\n\nWrite **120–150 words** describing:\n- two advantages of shopping online, and\n- two disadvantages of shopping online.\n\nGive reasons for your ideas and include examples from your own experience.',
    NULL,
    ARRAY['.*']
  );

  -- ============================================
  -- SECTION 4: SPEAKING
  -- ============================================
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
  VALUES (
    sec_speaking,
    exam_id,
    4,
    'Speaking – Audio Response',
    E'In this section, you will answer a speaking question by recording your voice.\n\nYou have **2 minutes** to prepare and **2 minutes** to record your answer.\n\nSpeak clearly and try to use a variety of vocabulary and grammar structures.',
    NULL,
    NULL
  );

  qid := 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
  VALUES (
    qid,
    sec_speaking,
    1,
    'AUDIO_RESPONSE',
    'SPEAKING',
    3,
    E'### Speaking Task\n\n**Topic: Online Learning**\n\nMany people now prefer online learning to traditional classroom learning.\n\nPlease speak for **1-2 minutes** about:\n- **What are the advantages of online learning?**\n- **What are the disadvantages of online learning?**\n- **Which type of learning do you prefer and why?**\n\nYou may use your own experience to support your ideas.',
    NULL,
    ARRAY['.*']
  );

END$$;

COMMIT;