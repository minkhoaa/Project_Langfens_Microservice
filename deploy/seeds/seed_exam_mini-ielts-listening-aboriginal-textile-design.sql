-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T19:55:01.757652
-- Source: mini-ielts.com
-- Title: Aboriginal Textile Design
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-aboriginal-textile-design
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-aboriginal-textile-design'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-aboriginal-textile-design';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-aboriginal-textile-design';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-aboriginal-textile-design';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-aboriginal-textile-design',
    'Aboriginal Textile Design',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTRw95IwFpV5ROcfn5wgMPY_WRhITuQuGNQfA&usqp=CAU',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Aboriginal Textile Design',
    E'**Questions 1-10:**  \nComplete the notes below.\n\nWrite **ONE WORD ONLY** for each answer.',
    E'# Aboriginal Textile Design\n\n## Ernabella Arts Centre\n\nArtists produce craft and learn new techniques\n\n- Initially, artists produced rugs made from **1** _______\n- Later artists made batik and screen-printed fabrics\n\n## Tiwi Designs\n\n- Early designs included **2** _______ images\n- Designs are linked to traditional beliefs, e.g. some designs are believed to bring **3** _______\n\n## Jimmy Pike\n\n- Inspired by the Australian landscape, especially the **4** _______\n- Started creating art when he was in **5** _______\n- His textiles were used to make **6** _______\n\n## Bronwyn Bancroft\n\n- Her work is a modern look at **7** _______ and nature\n- 1995 - painted a successful Aboriginal athlete''s jeans with lizards and a **8** _______\n- 2001 - designed a ''Journey of a Nation'' parade outfit with part of a **9** _______ on it\n\n## Copyright Issues\n\nExploiting Aboriginal imagery affects the artists and the cultural group, e.g. ''The **10** _______ Case''\n'
  ,
    'https://www.youtube.com/embed/HWFi1uW5qO0?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Initially, artists produced rugs made from _______',
    '',
    '{"blank-q1": ["WOOL"]}'::jsonb
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
    'Early designs included _______ images',
    '',
    '{"blank-q2": ["BIRD"]}'::jsonb
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
    'Designs are linked to traditional beliefs, e.g. some designs are believed to bring _______',
    '',
    '{"blank-q3": ["RAIN"]}'::jsonb
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
    'Inspired by the Australian landscape, especially the _______',
    '',
    '{"blank-q4": ["DESERT"]}'::jsonb
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
    'Started creating art when he was in _______',
    '',
    '{"blank-q5": ["PRISON"]}'::jsonb
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
    'His textiles were used to make _______',
    '',
    '{"blank-q6": ["CLOTHING"]}'::jsonb
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
    'Her work is a modern look at _______ and nature',
    '',
    '{"blank-q7": ["FAMILY"]}'::jsonb
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
    '1995 - painted a successful Aboriginal athlete''s jeans with lizards and a _______',
    '',
    '{"blank-q8": ["RAINBOW"]}'::jsonb
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
    '2001 - designed a ''Journey of a Nation'' parade outfit with part of a _______ on it',
    '',
    '{"blank-q9": ["SNAKE"]}'::jsonb
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
    'e.g. ''The _______ Case''',
    '',
    '{"blank-q10": ["CARPET"]}'::jsonb
  );


END$$;


COMMIT;