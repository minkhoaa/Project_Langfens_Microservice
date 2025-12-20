-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T21:58:31.986175
-- Source: ielts-mentor.com
-- Title: GT Reading 36 Section 2 - Professional Credentials & How to Prepare for a Presentation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-36-section-2-professional-credentials-how-to-prepare-for-a-presentation
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-36-section-2-professional-credentials-how-to-prepare-for-a-presentation'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-36-section-2-professional-credentials-how-to-prepare-for-a-presentation';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-36-section-2-professional-credentials-how-to-prepare-for-a-presentation';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-36-section-2-professional-credentials-how-to-prepare-for-a-presentation';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-36-section-2-professional-credentials-how-to-prepare-for-a-presentation',
    'GT Reading 36 Section 2 - Professional Credentials & How to Prepare for a Presentation',
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
    'Reading Passage - GT Reading 36 Section 2 - Professional Credentials & How to Prepare for a Presentation',
    E'# Passage\n\n# Professional Credentials:Advice for Immigrants & How to Prepare for a Presentation\n\nThe first time your boss suggests that you formally present something to your department or a client, your reaction may be to panic. But remember that being asked to present is a compliment. Someone believes that you have valuable information to share with the group, and wants to listen to your ideas. You need to decide exactly what you will say during the allotted time. Condense your topic into one sentence. What do you want your audience to remember or learn from your talk? This is your ''big idea''. Remember that you are dealing with the short attention spans of individuals who tend to have many things on their minds. Think of three main points you want to make to support your overall topic. Develop a story to demonstrate each of those concepts. This could be something that happened to you or someone you know, or something you read in a newspaper or magazine. We have all heard the saying A picture is worth a thousand words. Think about how your presentation can be more interesting to watch. Props are a wonderful way to make your talk come alive. You could do something as simple as holding up a toy phone receiver when talking about customer service or putting on a hat to signal a different part of your talk. Think of a dynamic and unusual way to start your presentation. This might involve telling anecdotes that relate to your topic. Never begin with, Thank you for inviting me here to talk with you today! You will put your audience to sleep right away. Start off enthusiastically so they will listen with curiosity and interest. After your energetic introduction, identify yourself briefly and thank the audience for taking the time to listen to you. Plan your ending, and finish in a memorable way. Your listeners remember best what they hear at the beginning and end of a speech, so conclude with a game in which they can participate, or tell a humorous story and your audience will leave laughing. Don''t try to memorise your talk or read it word-for-word. It will sound stilted and boring, instead, practise your dynamic introduction and conclusion until you can deliver them effortlessly. If you do this you''ll feel a burst of confidence that will help you sail through the whole of the speech.\n\n• You should regard an invitation to speak as a 21 ............................. . • Express your main idea in a 22 ............................. . • Try using a 23 ............................. to support the major points you are making. • Add visual excitement to your talk by using 24 ............................. . • Express appreciation to your listeners for their 25 ............................. . • A 26 ............................. will get the audience to interact. • It is important to prepare well as this will increase your 27 ............................. .'
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
    'New arrivals to North America need to make sure that their academic qualifications or their _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["trade certificates"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    16,
    'SHORT_ANSWER',
    'READING',
    2,
    'A significant number of companies view',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["(formal) education"]}'::jsonb
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
    'People educated in North America may initially be offered a higher _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["salary (level)"]}'::jsonb
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
    '{"blank-q18": ["apprenticeship (training)"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    19,
    'SHORT_ANSWER',
    'READING',
    2,
    'Most of the effort to find work is spent trying to obtain',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["(job) interviews"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SHORT_ANSWER',
    'READING',
    2,
    'As more newcomers enter the workforce,',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["As more newcomers enter the workforce"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    21,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 21',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["compliment"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    22,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 22',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["sentence"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 23',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["story"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    24,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 24',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["props"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    25,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 25',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["time"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 26',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["game"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 27',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["confidence"]}'::jsonb
  );


END$$;


COMMIT;