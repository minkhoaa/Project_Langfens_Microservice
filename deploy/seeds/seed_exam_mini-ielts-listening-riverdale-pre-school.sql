-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T20:25:02.803792
-- Source: mini-ielts.com
-- Title: Riverdale Pre-school
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-riverdale-pre-school
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-riverdale-pre-school'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-riverdale-pre-school';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-riverdale-pre-school';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-riverdale-pre-school';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-riverdale-pre-school',
    'Riverdale Pre-school',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://rnsfc.org/wp-content/uploads/2016/11/facility_01.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Riverdale Pre-school',
    E'**Questions 1-10:**  \nComplete the notes below.\n\nWrite **ONE WORD AND/OR A NUMBER** for each answer.',
    E'# Riverdale Pre-school\n\n**Example:** Children: 20 in a class\n\n## Classes\n- First group - Mrs. Oliver\n- Second group - Mrs. **1** _______\n\n## Hours & Days\n- Suzie will attend 3 days a week for a total of **2** _______ hours\n\n## Activities\n\n### Outside time\n- running, playing, or something quieter\n- just got a new piece of equipment\n- intend to make a **3** _______\n\n### Indoors\n- this year, **4** _______ activities are popular\n- they hear a **5** _______ every day\n\n## Fees\n- Now costs **6** _______ $ per term\n\n### Fees include:\n- a trip to a **7** _______ this year\n- chance to take home a **8** _______ every week\n\n## Do not forget\n- Put a **9** _______ in Suzie''s bag\n\n## Arrange a visit\n- phone number: **10** _______\n'
  ,
    'https://www.youtube.com/embed/https://www.dropbox.com/s/lyfdj8mxj7zm5dk/T3S1.mp3?dl=0?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Second group - Mrs. _______',
    '',
    '{"blank-q1": ["KEOGH"]}'::jsonb
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
    'Suzie will attend 3 days a week for a total of _______',
    '',
    '{"blank-q2": ["15"]}'::jsonb
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
    'intend to make a _______',
    '',
    '{"blank-q3": ["GARDEN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'this year, _______ activities are popular',
    '',
    '{"blank-q4": ["MUSIC"]}'::jsonb
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
    'they hear a _______ every day',
    '',
    '{"blank-q5": ["STORY"]}'::jsonb
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
    'Now costs _______ $ per term',
    '',
    '{"blank-q6": ["470"]}'::jsonb
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
    'a trip to a _______ this year',
    '',
    '{"blank-q7": ["FARM"]}'::jsonb
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
    'chance to take home a _______ every week',
    '',
    '{"blank-q8": ["TOY"]}'::jsonb
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
    'Put a _______ , in Suzie’s bag',
    '',
    '{"blank-q9": ["PILLOW"]}'::jsonb
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
    'Arrange a visit; phone number: _______',
    '',
    '{"blank-q10": ["0914638520"]}'::jsonb
  );


END$$;


COMMIT;