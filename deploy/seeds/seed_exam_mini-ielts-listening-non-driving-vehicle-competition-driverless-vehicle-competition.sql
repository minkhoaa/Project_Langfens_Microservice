-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T22:52:50.987596
-- Source: mini-ielts.com
-- Title: Non-driving vehicle competition (Driverless vehicle competition)
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition',
    'Non-driving vehicle competition (Driverless vehicle competition)',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Non-driving vehicle competition (Driverless vehicle competition)',
    E'**Questions 1-3:**\n\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS** for each answer.\n\n---\n\n**Questions 4-6:**\n\nChoose the correct letter, **A**, **B** or **C**.\n\n---\n\n**Questions 7-10:**\n\nComplete the table below.\n\nWrite **ONE WORD ONLY** for each answer.',
    E'# Passage\n\n# Driverless Vehicle Competition - Listening Notes\n\n## Questions 1-3: Complete the sentences\n\n**Driverless vehicle competition**\n\n1. Undergraduates from both the engineering school and the _______ department can definitely take part in the project.\n\n2. The automated vehicles will have to avoid obstacles such as _______ .\n\n3. The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings.\n\n---\n\n## Questions 4-6: Multiple Choice\n\n4. The purpose of holding the race is to\n   - A. Interest students in careers in industry.\n   - B. Help provide finance for universities.\n   - C. Find useful new design features.\n\n5. The tutor says success will depend on\n   - A. The software design.\n   - B. Good, solid construction.\n   - C. Sophisticated mechanisms.\n\n6. This year''s competitors were surprised that the vehicles\n   - A. Were so easy to design.\n   - B. Were as successful as they were.\n   - C. Took such a short time to construct.\n\n---\n\n## Questions 7-10: Complete the table\n\n**Schedule**\n\n| Time | Activity |\n|------|----------|\n| Early May | Introductory _______ (7) about the project |\n| Late May | Essay giving information about relevant _______ (8) and experience |\n| June | Visit to a factory |\n| September | Workshop: discuss _______ (9), learn to use design package |\n| December | _______ (10) presentation |'
  ,
    'https://www.youtube.com/embed/Wtib4_RjRkM?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Undergraduates from both the engineering school and the _______ department can definitely take part in the project.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q1": ["computer science"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'The automated vehicles will have to avoid obstacles such as _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q2": ["rocks"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q3": ["video cameras"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The purpose of holding the race is to',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Interest students in careers in industry.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Help provide finance for universities.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Find useful new design features.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The tutor says success will depend on',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The software design.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Good, solid construction.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Sophisticated mechanisms.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'This year''s competitors were surprised that the vehicles',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Were so easy to design.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Were as successful as they were.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Took such a short time to construct.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Early May: Introductory _______ about the project',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["seminar"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Late May: Essay giving information about relevant _______ and experience',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q8": ["skills"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'September Workshop: discuss _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q9": ["ideas"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'December: _______ presentation',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q10": ["team"]}'::jsonb
  );


END$$;


COMMIT;