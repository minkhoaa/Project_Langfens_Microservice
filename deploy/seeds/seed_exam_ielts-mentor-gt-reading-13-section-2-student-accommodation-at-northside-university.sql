-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T17:10:51.589937
-- Source: ielts-mentor.com
-- Title: GT Reading 13 Section 2 - Student Accommodation at Northside University
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-13-section-2-student-accommodation-at-northside-university
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-13-section-2-student-accommodation-at-northside-university'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-13-section-2-student-accommodation-at-northside-university';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-13-section-2-student-accommodation-at-northside-university';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-13-section-2-student-accommodation-at-northside-university';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-13-section-2-student-accommodation-at-northside-university',
    'GT Reading 13 Section 2 - Student Accommodation at Northside University',
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
    'Reading Passage - GT Reading 13 Section 2 - Student Accommodation at Northside University',
    E'# Passage\n\n**STUDENT ACCOMMODATION AT NORTHSIDE UNIVERSITY**\n\nSituated about 20km from the city centre, Northside University is not easy to get to by public transport. However, students have several different alternatives for accommodation on or near the University campus.\n\nFirstly, the University has several residential colleges; Burnside College, Boronia College and Helen Turner College. Each of these colleges provides a single fully furnished room with shared bathroom facilities, and meals. Burnside College is the most expensive, with 1996 fees ranging from $154 – $165 per week. However, each student room is equipped with a private telephone and voice-mailing facilities, and within the next few months, college students will have access to E-MAIL, On-Line library, INTERNET and AARNET via a network with the University. Boronia College has similar room facilities but does not offer the same computer access. It also offers only 17 meals per week, compared to Burnside''s 21. Fees vary from $147- $ 157 per week. Helen Turner College is a college exclusively for women, with similar fees to Boronia College. To attend classes, students have a short walk from the residential Colleges to the main University campus.\n\nThe University also provides 23 self-contained furnished townhouses. These townhouses have either 3, 4 or 6 bedrooms each and student residents are expected to be studying full-time. Rents in 1996 ranged from $54 per week for a room in a six bedroom flat to $68.50 per week for a room in a three-bedroom house. Students wanting to live in university housing should apply to the university housing officer in August of the previous year, as it is in high demand. Smoking is banned in University housing.\n\nOff campus, there are many flats, townhouses and houses for rent in the local area. These can be found by looking in the local newspaper under ACCOMMODATION, or by checking notices pinned up on the boards around the university. There are always students advertising for housemates and you can even add a notice of your own to the board. However, even sharing accommodation with others can be expensive; tenants are usually required to pay a rental bond, rent in advance, and telephone/electricity/gas bills in addition to food bills. Be sure that you know what you will be required to pay before you enter into any written agreement.\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    16,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The University Residential Colleges provide',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. a place to live and regular classes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. regular classes only', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. a place to live only', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    17,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Smoking is',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. allowed in University housing', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. not allowed in University housing', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. allowed only in certain areas in University housing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    18,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'University townhouses are available for',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. full-time students only', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. part-time students only', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. all students', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    19,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Accommodation in the area surrounding the university is',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. scarce', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. plentiful', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. scarce and expensive', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'A student living in a 3-bedroom University townhouse would pay _______ per week for a room',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["$68.50"]}'::jsonb
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
    'in comparison, the cheapest accommodation available at Burnside College is _______ per week',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["$154"]}'::jsonb
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
    'The fee charged at Burnside College includes _______ meals per week',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["21"]}'::jsonb
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
    'but at Boronia College only _______ meals per week are included in the fee',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["17"]}'::jsonb
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
    'Helen Turner College has a similar fee structure to _______ College',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["BORONIA"]}'::jsonb
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
    'but only _______ may live there',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["WOMEN"]}'::jsonb
  );


END$$;


COMMIT;