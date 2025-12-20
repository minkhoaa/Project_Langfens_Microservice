-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T17:33:35.855790
-- Source: ielts-mentor.com
-- Title: GT Reading Test 13 Section 3 - Kormilda College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-test-13-section-3-kormilda-college
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-test-13-section-3-kormilda-college'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-test-13-section-3-kormilda-college';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-test-13-section-3-kormilda-college';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-test-13-section-3-kormilda-college';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-test-13-section-3-kormilda-college',
    'GT Reading Test 13 Section 3 - Kormilda College',
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
    'Reading Passage - GT Reading Test 13 Section 3 - Kormilda College',
    E'# Passage\n\n**Kormilda College**\n\n**Section A**\nKormilda College is a unique school situated near Darwin in Australia''s Northern Territory. For 20 years, to 1989, Kormilda College operated as a government-run, live-in school for high school Aboriginal students. In 1989 it was bought from the Government by two Christian church groups and since then it has expanded enormously, to include a day school as well as boarders (residential students) in Years 8-12. Although 320 pupils of the College''s total number are Aboriginal students, drawn mainly from isolated communities across the Northern Territory, Kormilda also has a waiting list of non–aboriginal students. With a current enrolment of 600, student numbers are expected to grow to 860 by 1999.\n\n**Section B**\nCentral to the mission of the school is the encouragement of individual excellence, which has resulted in programs designed especially for the student population. Specialist support programs allow traditional Aboriginal students, who are often second language users, to understand and succeed in the mainstream curriculum. A Gifted and Talented Program, including a special Aboriginal and Torres Strait Islander Tertiary Aspirations program, has been introduced, as has an Adaptive Education Unit. Moreover, in Years 11 and 12, students may choose to follow the standard Northern Territory Courses or those of the International Baccalaureate (I.B.).\n\n**Section C**\nTo provide appropriate pastoral care, as well as a suitable academic structure, three distinct sub-schools have been established:\n\n- **Pre-Secondary:** For Aboriginal and Torres Strait Islander students in Years 8-10 who are of secondary school age but have difficulties reading and writing.\n- **Supported Secondary:** For Aboriginal and Torres Strait Islander students who are of secondary school age and operating at secondary school year levels 8-12 who need specific second language literacy and numeracy support.\n- **Secondary:** For multi-cultural Years 8-12 students.\n\nStudents remain in their sub-schools for classes in the main subject areas of English, Maths, Social Education and Science. This arrangement takes into account both diverse levels of literacy and the styles of learning and cultural understandings appropriate to traditional Aboriginal second-language users.\n\n**Section D**\nTo aid the development of the Aboriginal Education program, a specialist curriculum Support Unit has been set up. One of its functions is to re-package school courses so that they can be taught in ways that suit the students. The education program offered to Aboriginal students uses an approach which begins with the students'' own experiences and gradually builds bi-cultural understanding.\n\nAnother project of the Support Unit has been the publication of several books, the most popular, Kormilda Capers. Focusing on experiences which have directly affected the lives of students at the College, and on ideas and issues which are of immediate interest to Aboriginal students, Kormilda Capers has earned enthusiastic support within and outside the school.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SHORT_ANSWER',
    'READING',
    2,
    'Kormilda College opened as a school in _______ (Write a NUMBER or DATE)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["1969"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SHORT_ANSWER',
    'READING',
    2,
    'At the time of writing there were _______ non-aboriginal students at Kormilda College. (600 total - 320 Aboriginal = ?)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["280"]}'::jsonb
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
    'Choose the best heading for Section B of the reading passage:',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Specialist teaching and teachers at Kormilda College', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Special Programmes at Kormilda College for Aboriginal students', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The new look Kormilda College', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Programmes at Kormilda College to promote individual excellence', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    29,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Diagram showing Kormilda College organization. First sub-school (29): _______ (for Years 8-10 students with reading/writing difficulties)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q29": ["PRE-SECONDARY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    30,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Second sub-school (30): _______ (for students needing specific literacy and numeracy support)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q30": ["SUPPORTED SECONDARY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    31,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Third sub-school (31): _______ (for multi-cultural Years 8-12 students)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q31": ["SECONDARY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    32,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Main subject areas include (32): _______, Maths, Social Education and Science',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q32": ["ENGLISH"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    33,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Main subject areas include: English, Maths, Social Education and (33): _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q33": ["SCIENCE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Kormilda College educates both Aboriginal and non-Aboriginal students.',
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
    35,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Some students travel from Arnhem Land to attend Kormilda College.',
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
    36,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Students must study both the International Baccalaureate and Northern Territory courses.',
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
    37,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Pre-Secondary School attracts the best teachers.',
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
    38,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The specialist curriculum Support Unit adapts school courses so the students can approach them more easily.',
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
    39,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'There are no oral traditional stories in Western communities.',
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
    40,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The school helps the students make connections between Aboriginal and non-Aboriginal cultures.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;