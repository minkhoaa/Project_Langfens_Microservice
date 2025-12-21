-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T12:21:50.017421
-- Source: ielts-mentor.com
-- Title: GT Reading 4 Section 3 - The Penny Black
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-4-section-3-the-penny-black
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-4-section-3-the-penny-black',
    'GT Reading 4 Section 3 - The Penny Black',
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
    'Reading Passage - GT Reading 4 Section 3 - The Penny Black',
    E'**Questions 28-30:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 31-34:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 35-40:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\nVibhu Khurana6 years 6 monthsI also wrote "A".ReplyQuote\n\nVibhu Khurana6 years 6 monthsI also wrote "A".ReplyQuote\n\nVibhu Khurana6 years 6 monthsI also wrote "A".ReplyQuote\n\nAnurag6 years 6 monthsSorry, I meant the reverse. It should be ''D'', not ''A''.ReplyQuote\n\nAnurag6 years 6 monthsSorry, I meant the reverse. It should be ''D'', not ''A''.ReplyQuote\n\nAnurag6 years 6 monthsSorry, I meant the reverse. It should be ''D'', not ''A''.ReplyQuote\n\nM6 years 4 months... Lord Lichfield spoke for an establishment not convinced...ReplyQuote\n\nM6 years 4 months... Lord Lichfield spoke for an establishment not convinced...ReplyQuote\n\nM6 years 4 months... Lord Lichfield spoke for an establishment not convinced...ReplyQuote\n\nRamandeep Singh Phull8 years 3 monthsNonguyensaid :Please give me the evidence of ''C'' please."It considers national treasures so that researchers can scrutinise them without handling the originals"ReplyQuote'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'One of the characteristics of the postal service before the 1840s was that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. postmen were employed by various organisations.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. letters were restricted to a certain length.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. distance affected the price of postage.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. the price of delivery kept going up.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Letter writers in the 1830s A. were not responsible for the cost of delivery. B. tried to fit more than one letter into an envelope. C. could only send letters to people living in cities. D. knew all letters were automatically read by postal staff.',
    'Choose the correct answer.',
    '{"info-q29": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'What does the text say about Hill in the 1830s? A. He was the first person to express concern about the postal system. B. He considered it would be more efficient for mail to be delivered by rail. C. He felt that postal service reform was necessary for commercial development. D. His plan received support from all the important figures of the day.',
    'Choose the correct answer.',
    '{"info-q30": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_FEATURES',
    'READING',
    2,
    'His inspiration came from a particular picture.',
    'Choose the correct answer.',
    '{"feature-q31": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He claimed that the postal system would lead to the spread of information.',
    'Choose the correct answer.',
    '{"feature-q32": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He organised the creation of the first stamp.',
    'Choose the correct answer.',
    '{"feature-q33": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He expressed doubts about the plans to change the postal service.',
    'Choose the correct answer.',
    '{"feature-q34": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    35,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 35',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q35": ["Treasury"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 36',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q36": ["coin"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 37',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q37": ["stars"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 38',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q38": ["Britain"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 39',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q39": ["........................"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 40',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q40": ["colour"]}'::jsonb
  );


END$$;


COMMIT;