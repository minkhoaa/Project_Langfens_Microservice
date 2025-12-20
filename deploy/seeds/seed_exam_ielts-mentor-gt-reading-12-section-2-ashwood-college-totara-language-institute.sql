-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:49:54.159727
-- Source: ielts-mentor.com
-- Title: GT Reading 12 Section 2 - Ashwood College & Totara Language Institute
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-12-section-2-ashwood-college-totara-language-institute
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-12-section-2-ashwood-college-totara-language-institute'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-12-section-2-ashwood-college-totara-language-institute';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-12-section-2-ashwood-college-totara-language-institute';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-12-section-2-ashwood-college-totara-language-institute';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-12-section-2-ashwood-college-totara-language-institute',
    'GT Reading 12 Section 2 - Ashwood College & Totara Language Institute',
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
    'Reading Passage - GT Reading 12 Section 2 - Ashwood College & Totara Language Institute',
    E'# Passage\n\n# THE TOTARA LANGUAGE INSTITUTE NEW ZEALAND\n\nDeposit/payment: 1. Your enrolment form must be accompanied by the course deposit of £100 or, if you are booking accommodation through the school, your course and accommodation deposit of £200 2. Any balance of course and accommodation fees must be paid in full by the first day of your course. 3. All bank charges incurred in sending money to Ashwood College must be paid by the student. 4. Deposits and payments are non-refundable and non-transferable. 5. A charge of £20 will be made for any changes made to the bookings.\n\nConditions: Timetable: Each hour consists of 50 minutes'' tuition and a 10-minute break. Public and School Holidays: There is no reduction in the fee where a course includes a Public Holiday, except for two weeks at Christmas. Age: The above centres of Ashwood College do not accept students under 16 years of age. Attendance: Students are expected to attend regularly and on time. Students forfeit tuition if they arrive late, are absent or leave before the course ends. Student Holidays: Students on long courses, except examination preparation courses, may take a holiday of one week every 12 weeks without losing their course fee for this period. Location and Time of Course: Ashwood College has two all-year centres and a summer centre in Midhaven. Before entry to the school, students must take an entry test to determine the level of class they enter. We cannot guarantee the time or location of a student''s course although every attempt is made to place students in the centre and at the time of their choice.\n\nSUMMARY With local students by applying for a room in the ......20...... Places are available here even for students enrolled on the minimum length course of ......21....... Class sizes for each course range from ......22...... students and all the class teachers are well qualified; many of them teach on graduate programmes in areas such as applied linguistics. As a member of the Language Institute, you will automatically be able to join the ......23...... . Hamilton can offer students a wide range of social activities. The city itself lies on either side of the ......24...... which results in some very ......25...... views and enjoyable walks in the gardens. The Institute employs an activities coordinator who can help you organise your free time and you may also wish to make use of this service for planning your ......26...... when you leave New Zealand. Remember that a student permit is not valid when you have finished your studies.\n\nThe Totara Language Institute is part of the University of Waikato in the city of Hamilton, in New Zealand’s North Island. Intensive English classes are taught in four-week blocks throughout the year and students may enrol for as many blocks as they wish. Classes are for 5 hours each day, Monday to Friday, and include preparation for several international English language examinations. All the courses are taught by highly qualified teachers, many of whom also teach on Language Institute graduate programmes in second language teaching and applied linguistics. Classes are small, usually from 10-12 students with a maximum number of 15, and normally contain a mix of students from a wide range of countries. Students who study English at the Language Institute become international members of the Waikato Students’ Union. The option is available to move on to university study if students meet the English language and academic entry levels for their choice of programme. The Language Institute provides student support, welfare and activities services. Students are met at Auckland airport on arrival and accommodation is provided with local families or in University Halls of Residence with New Zealand students. Hamilton, one of New Zealand’s fastest growing cities, is ideally located for a wide range of leisure and cultural activities. The Waikato river, the longest river in New Zealand, flows through the centre of the city, providing a picturesque and park-like setting of riverside walks and gardens. The Waikato region is a diverse agricultural area, rich in historic sites, arts and crafts, hot springs, native forests, mountains and rivers. Within easy reach is an unspoilt coastline; the wild and rugged west coast beaches famous for surfing, and the more peaceful east coast resorts are only a short drive from Hamilton. Further afield the mountains of the central North Island, 3 hours’ drive away, provide superb ski facilities in winter and hiking country in summer. The Language Institute activities coordinator can assist students to arrange any sport and leisure activities. Assistance is also available for ongoing travel arrangements for students. Students on a visitor visa or work permit may study for a maximum of 3 months. Courses of longer duration require a student permit which is issued for the length of study only.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n14. Overseas students must pay a deposit when they apply for a course at the college.',
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
    15,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n15. Outstanding fees are payable by the end of the first week of the course.',
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
    16,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n16. Classes are organised according to ability level.',
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
    17,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n17. There is a break between each lesson.',
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
    18,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n18. Students may change courses at any time during the term.',
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
    19,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n19. Any student is permitted to take a week’s holiday during a 12-week course. Deposit/payment:',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'minutes on Questions _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["(University) Halls of Residence"]}'::jsonb
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
    '{"blank-q21": ["4 weeks"]}'::jsonb
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
    '{"blank-q22": ["10 to 15"]}'::jsonb
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
    '{"blank-q23": ["(Waikato) Students\u2019 Union"]}'::jsonb
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
    '{"blank-q24": ["(Waikato) river"]}'::jsonb
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
    '{"blank-q25": ["picturesque"]}'::jsonb
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
    '{"blank-q26": ["(ongoing) travel (arrangements)"]}'::jsonb
  );


END$$;


COMMIT;