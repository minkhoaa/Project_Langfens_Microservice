-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T09:21:50.114627
-- Source: mini-ielts.com
-- Title: Paper on Public Libraries
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-paper-on-public-libraries
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-paper-on-public-libraries'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-paper-on-public-libraries';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-paper-on-public-libraries';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-paper-on-public-libraries';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-paper-on-public-libraries',
    'Paper on Public Libraries',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766629305/ielts/paper-on-public-libraries_thum_3f4911577dd6.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Paper on Public Libraries',
    E'## Listening Test\n\nThis test has 10 questions in 2 parts:\n- **Questions 1-3:** Multiple Choice\n- **Questions 4-10:** Note Completion',
    E'# Listening Test - Paper on Public Libraries\n\nThis is a listening practice test about public libraries and how they have evolved with changes in society. Two students, Trudie and Stewart, are discussing their paper on public libraries.\n\n**Instructions:**\nYou will hear the recording ONCE only. Answer all questions based on what you hear in the audio.\n\n**About the Audio:**\nThis test includes multiple choice questions (Q1-3) about the students'' discussion on their paper topic and the role of libraries, followed by note completion questions (Q4-10) about possible research questions for studying a local library.\n\n**Question Topics:**\n- Main topic of the students'' paper\n- Advantages and disadvantages of digitalised books\n- Future of public libraries\n- Study questions for investigating a local library''s operations'
  ,
    'https://www.youtube.com/embed/CWsqhUlaLs4?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What will be the main topic of Trudie and Stewart''s paper?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. how public library services are organised in different countries', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. how changes in society are reflected in public libraries', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. how the funding of public libraries has changed', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'They agree that one disadvantage of free digitalised books is that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. they may take a long time to read.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. they can be difficult to read.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. they are generally old.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Stewart expects that in the future libraries will',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. maintain their traditional function.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. become centres for local communities.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. no longer contain any books.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    '• whether it has a _______ of its own',
    '',
    '{"blank-q4": ["BUDGET"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    '• how it’s affected by laws regarding all aspects of _______',
    '',
    '{"blank-q5": ["EMPLOYMENT"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    '• how the design needs to take the _______ of customers into account',
    '',
    '{"blank-q6": ["SAFETY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    '• what _______ is required in case of accidents',
    '',
    '{"blank-q7": ["INSURANCE"]}'::jsonb
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
    '• why a famous person’s _______ is located in the library',
    '',
    '{"blank-q8": ["DIARY"]}'::jsonb
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
    '• whether it has a _______ of local organisations',
    '',
    '{"blank-q9": ["DATABASE"]}'::jsonb
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
    '• how it’s different from a library in a _______',
    '',
    '{"blank-q10": ["MUSEUM"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 3, E'## Questions 1-3\n\nChoose the correct letter, **A**, **B** or **C**.\n\n### Paper on Public Libraries\n\n**1.** What will be the main topic of Trudie and Stewart''s paper?\n- **A** how public library services are organised in different countries\n- **B** how changes in society are reflected in public libraries\n- **C** how the funding of public libraries has changed\n\n**2.** They agree that one disadvantage of free digitalised books is that\n- **A** they may take a long time to read.\n- **B** they can be difficult to read.\n- **C** they are generally old.\n\n**3.** Stewart expects that in the future libraries will\n- **A** maintain their traditional function.\n- **B** become centres for local communities.\n- **C** no longer contain any books.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 4, 10, E'## Questions 4-10\n\nComplete the notes below.\n\nWrite **ONE WORD ONLY** for each answer.\n\n### Study of local library: possible questions\n\n- whether it has a **4** _______ of its own\n- its policy regarding noise of various kinds\n- how it''s affected by laws regarding all aspects of **5** _______\n- how the design needs to take the **6** _______ of customers into account\n- what **7** _______ is required in case of accidents\n- why a famous person''s **8** _______ is located in the library\n- whether it has a **9** _______ of local organisations\n- how it''s different from a library in a **10** _______');

END$$;


COMMIT;