-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:30:39.081090
-- Source: ielts-mentor.com
-- Title: GT Reading 33 Section 2 - Mountain biking & Classified Ads
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-33-section-2-mountain-biking-classified-ads
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-33-section-2-mountain-biking-classified-ads'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-33-section-2-mountain-biking-classified-ads';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-33-section-2-mountain-biking-classified-ads';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-33-section-2-mountain-biking-classified-ads';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-33-section-2-mountain-biking-classified-ads',
    'GT Reading 33 Section 2 - Mountain biking & Classified Ads',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - GT Reading 33 Section 2 - Mountain biking & Classified Ads',
    E'# Passage\n\nGT Reading Test 33 Section 2 - Mountain biking & Classified Ads\nDetails\nLast Updated: Wednesday, 18 May 2022 22:18\nWritten by IELTS Mentor\nHits: 42151\nGT Reading Mock Test 33:\n|\nSection 1\n|\nSection 2\n|\nSection 3\n|\nSection 2: Questions 15-27\nRead the text below and answers to the questions\n15-27\non your answer sheet.\nYou should take around\n20 minutes\nto complete this task.\nGT Reading:\n"Mountain biking - Canada is calling!"\n&\n"Classified Ads - A useful job-seeking resource"\nRead the passage below and answer\nQuestions 15-20\n.\nMountain biking?\nCanada is calling!\nExperience the best summer adventure ever!\n12 mountain biking adventures throughout Canada\nAt Zenith Biking we have been exceeding mountain bikers’ expectations since our founding in 1988 in Ottawa, Canada.  Over the years we have expanded our operations to cover other Canadian cities including Montreal and Toronto. Currently, with a base of over 100 experienced staff, we are your first choice for mountain biking!\nFor the past five years our international network, comprising offices in four continents, has been organising Canadian mountain biking adventures for bikers around the world.  Annually, an average of 3000 clients enjoy an unforgettable biking experience throughout Canada.  Should you be interested in extending your adventure to other countries, our extensive Inter-country Zenith Network can organise additional connections for you. Obtaining a visa for entry into some countries can be a time-consuming and frustrating process however at Zenith, our experienced team will assist you in obtaining your visa least amount of time.\nAt Zenith we have our own accommodation facilities for bikers, in Ottawa and Toronto. Accommodation fees are reasonable and depend on the size and the location of the room chosen. The most economical option is our 8-bed dorms.\nSummer Experience, 2012:\nFees for this adventure include:\n•  Return air-ticket from London to Toronto (excluding onward travel in\nCanada\n)\n•  Bikers’ kit (consisting of apparel, headgear and energy food)\n•  Direct transfer to\nMeet & Greet\ncamp from airport\n•  Bikers workshop for beginners to advanced by our experienced staff\n•  Extensive directory of\nCanadian Hills\nand Mountains\n•  Zenith Biking 24-hour help and support phone service\n•  24-hour emergency medical assistance.\nEligibility:\nParticipants must:\n•  be at least 18 years old\n•  be in excellent physical condition\n•  have at least a basic level of mountain biking competence\n•  be excited about the experience of a lifetime!\nJoin the Zenith Bikers’ Forum (ZBF)\nOnce you book with us for any biking experience, you will automatically become a member of the Zenith Bikers’ Forum (ZBF).  Based on the many requests we received from our clients we formally launched the ZBF 3 years ago.  On the ZBF you can ask and have answered any biking-related questions you may have.  Our website also has a chat-room.  You are encouraged to submit your ideas, questions and suggestions and they will be quickly answered by past clients and staff.\nQuestions 15 – 20\nComplete the summary below with a word taken from the passage.\nUse\nNO MORE THAN THREE WORDS AND/OR A NUMBER\nfor each answer.\nWrite your answers in boxes\n15-20\non your answer sheet. The first one has been done for you.\nZenith Biking began in 1988 in the city of\n…Ottawa...\nand provides biking adventures in several\n(15)\n.…  .\nExperienced Zenith staff provide assistance for bikers worldwide via an\n(\n16)\n...….. .  Not all of Zenith’s 3000 annual clients mountain bike in Canada – the Inter-country Zenith Network can organise connections to\n(17)\n…..….\nIn Ottawa and Toronto, Zenith Accommodation is available and room rates are based on\n(18)\n…….…… .  The Summer Experience 2012 offers several exciting options including air-ticket, transport and 24-hour emergency service.\nThe Zenith Bikers’ Forum began\n(19)\n……..…. and helps paying customers by answering all biking-related questions.  Customers can also find answers to their questions in the\n(20)\n…….……. .\nRead the text below and answer\nQuestions 21-27\n.\nCLASSIFIED ADS – A USEFUL JOB-SEEKING RESOURCE\nIn their search for employment, increasing numbers of job seekers are once again turning to the help-wanted classified ads in their local newspapers. For some time this popular resource slumped as the heavily trafficked internet job sites became widely regarded as offering greater numbers of employment opportunities. In many cases, this is a valid assumption. A local newspaper focuses on positions vacant in a specific town or region, whereas the online job site will typically contain advertisements for the whole country and possibly even overseas.\nIf you are seeking work in your neighborhood, and do not wish to drive a long distance or move, the local, classified ads in your newspaper may be a viable option. Recent canvassing has revealed that some local and regional employers don’t always post their position vacant ads on the major websites. Many prefer to advertise closer to home and to hire locally in order to avoid having to pay relocation costs.\nOften it is not necessary to purchase the newspapers, as these publications are widely available in libraries, coffee shops and even some waiting rooms. In addition, online newspaper editions, which contain the help-wanted ads, are now widely available and have contributed to the popularity of this form of advertising. These ads are usually searchable by date, category, keyword and location, making them competitive with the larger career and employment agencies found on the Internet.\nWhether you apply for a job through a large, on-line employment agency or via a classified ad in a newspaper the same strategy is valid. First of all, read the ad carefully and do your best to answer the following questions:\n•\nAm I the type of person the employer is looking for – do I have the essential skills and experience?\n•\nWith whom would I be working – a group of people, one person or would I work independently?\n•\nWhat other talents and experience can I include in my application?\n•\nWhat opportunities and experiences might be available in this position that would be advantageous to my career?\n•\nDo I have the skills to negotiate the challenges and problems of the position? (For example: working with much older employees or a woman working in an office full of men.)\nImportantly, try to find a way to stand out from the other applicants. Remember, whether you are responding to a positions vacant advertisement from an internet agency or a newspaper, your goal is to secure the interview before you stand a chance of being hired for the job.\nQuestions 21 - 27\nDo the following statements agree with the information given in the text?\nIn boxes\n21-27\non your answer sheet, write\nTRUE\nif the statement agrees with the information given in the text.\nFALSE\nif the statement contradicts the information in the text.\nNOT GIVEN\nif there is no information on this in the text. 22.\nOn-line job sites list more vacancies than job sites in newspapers. 24.\nTo avoid paying for moving expenses, employers advertise locally. 26.\nAn application should mention additional, relevant work experience. Click the button to Show/ Hide Answers\nAnswer: international network\n17. other countries\n18. size and location\n19. 3 years ago NOT GIVEN FALSE FALSE FALSE\nShow/ Hide Answers\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\nRating 2.88 (17 Votes)\nGT Reading\nPrev\nNext\nName\nPreview\nSend\nReset\nCancel\nRSS\n×\nReport\nReport\nClose'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    15,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 15',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["Canadian cities"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    16,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 16',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["international network"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    17,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 17',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["other countries"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    18,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 18',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["size and location"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    19,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Question 19',
    'Choose the correct answer.',
    '{"info-q19": ["3 YEARS AGO", "3 years ago"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 20',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["Chat-room"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    21,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Classified ads have become more popular due to increases in unemployment.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    22,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'On-line job sites list more vacancies than job sites in newspapers.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    23,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Internet job sites are recommended for local employment positions.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    24,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'To avoid paying for moving expenses, employers advertise locally.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    25,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Compared with jobs online, jobs in newspapers require a slightly different approach.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    26,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'An application should mention additional, relevant work experience.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'When answering a positions vacant ad, the first aim is to be hired.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;