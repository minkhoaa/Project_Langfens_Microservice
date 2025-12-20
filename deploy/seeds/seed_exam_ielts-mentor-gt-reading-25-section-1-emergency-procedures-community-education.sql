-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T01:37:54.371915
-- Source: ielts-mentor.com
-- Title: GT Reading 25 Section 1 - Emergency Procedures & Community Education
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-25-section-1-emergency-procedures-community-education
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-25-section-1-emergency-procedures-community-education'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-25-section-1-emergency-procedures-community-education';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-25-section-1-emergency-procedures-community-education';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-25-section-1-emergency-procedures-community-education';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-25-section-1-emergency-procedures-community-education',
    'GT Reading 25 Section 1 - Emergency Procedures & Community Education',
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
    'Reading Passage - GT Reading 25 Section 1 - Emergency Procedures & Community Education',
    E'**Questions 1-8:** Complete the sentences below.\nChoose **NO MORE THAN THREE WORDS** from the text for each answer.\n\n**Questions 9-14:** Do the following statements agree with the information given in the text?\nWrite **TRUE** if the statement agrees with the information.\nWrite **FALSE** if the statement contradicts the information.\nWrite **NOT GIVEN** if there is no information on this.\n\n---\n\n# Emergency Procedures\n\n**Revised July 2011**\n\nThis applies to all persons on the school campus.\n\nIn cases of emergency (e.g. fire), find the nearest teacher who will: send a messenger at full speed to the Office OR inform the Office via phone ext. 99.\n\n## PROCEDURE FOR EVACUATION\n\n1. Warning of an emergency evacuation will be marked by a number of short bell rings. (In the event of a power failure, this may be a hand-held bell or siren.)\n\n2. All class work will cease immediately.\n\n3. Students will leave their bags, books and other possessions where they are.\n\n4. Teachers will take the class rolls.\n\n5. Classes will vacate the premises using the nearest staircase. If these stairs are inaccessible, use the nearest alternative staircase. Do not use the lifts. Do not run.\n\n6. Each class, under the teacher''s supervision, will move in a brisk, orderly fashion to the paved quadrangle area adjacent to the car park.\n\n7. All support staff will do the same.\n\n8. The Marshalling Supervisor, Ms Randall, will be wearing a red cap and she will be waiting there with the master timetable and staff list in her possession.\n\n9. Students assemble in the quad with their teacher at the time of evacuation. The teacher will do a head count and check the roll.\n\n10. Each teacher sends a student to the Supervisor to report whether all students have been accounted for. After checking, students will sit down (in the event of rain or wet pavement they may remain standing).\n\n11. The Supervisor will inform the Office when all staff and students have been accounted for.\n\n12. All students, teaching staff and support personnel remain in the evacuation area until the All Clear signal is given.\n\n13. The All Clear will be a long bell ring or three blasts on the siren.\n\n14. Students will return to class in an orderly manner under teacher guidance.\n\n15. In the event of an emergency occurring during lunch or breaks, students are to assemble in their home-room groups in the quad and await their home-room teacher.\n\n---\n\n# Community Education - SHORT COURSES: BUSINESS\n\n**Business Basics**\nGain foundation knowledge for employment in an accounts position with bookkeeping and business basics through to intermediate level; suitable for anyone requiring knowledge from the ground up.\n- Code: B/ED011\n- Date: 16th or 24th April, 9am–4pm\n- Cost: $420\n\n**Bookkeeping**\nThis course will provide students with a comprehensive understanding of bookkeeping and a great deal of hands-on experience.\n- Code: B/ED020\n- Date: 19th April, 9am–2.30pm (one session only so advance bookings essential)\n- Cost: $250\n\n**New Enterprise Module**\nUnderstand company structures, tax rates, deductions, employer obligations, profit and loss statements, GST and budgeting for tax.\n- Code: B/ED030\n- Date: 15th or 27th May, 6pm–9pm\n- Cost: $105\n\n**Social Networking – the Latest Marketing Tool**\nThis broad overview gives you the opportunity to analyse what web technologies are available and how they can benefit your organisation.\n- Code: B/ED033\n- Date: 1st or 8th or 15th June, 6pm–9pm\n- Cost: $95\n\n**Communication**\nTake the fear out of talking to large gatherings of people. Gain the public-speaking experience that will empower you with better communication skills and confidence.\n- Code: B/ED401\n- Date: 12th or 13th or 14th July, 6pm–9pm\n- Cost: $90\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '1. Warning of an emergency evacuation will be marked by a number of short bell rings. (In the event of a power failure, this may be a hand-held bell or siren.) _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q1": ["Send a messenger"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '2. All class work will cease immediately _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q2": ["Short bell rings"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '3. Students will leave their bags, books and other possessions where they are _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q3": ["Searest staircase"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '4. Teachers will take the class rolls _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["Quadrangle"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '5. Classes will vacate the premises using the nearest staircase. If these stairs are inaccessible, use the nearest alternative staircase. Do not use the lifts. Do not run _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q5": ["Support staff"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '6. Each class, under the teacher’s supervision, will move in a brisk, orderly fashion to the paved quadrangle area adjacent to the car park _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": ["The roll"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '7. All support staff will do the same _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["All clear signal"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '8. The Marshalling Supervisor, Ms Randall, will be wearing a red cap and she will be waiting there with the master timetable and staff list in her possession _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q8": ["Home-room groups"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Students assemble in the quad with their teacher at the time of evacuation. The teacher will do a head count and check the roll.',
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
    10,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Each teacher sends a student to the Supervisor to report whether all students have been accounted for. After checking, students will sit down (in the event of rain or wet pavement they may remain...',
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
    11,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Supervisor will inform the Office when all staff and students have been accounted for.',
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
    12,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'All students, teaching staff and support personnel remain in the evacuation area until the All Clear signal is given.',
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
    13,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The All Clear will be a long bell ring or three blasts on the siren.',
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
    14,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Students will return to class in an orderly manner under teacher guidance.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;