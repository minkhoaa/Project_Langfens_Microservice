-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T09:10:29.926282
-- Source: mini-ielts.com
-- Title: Different Types of Supermarket Layout
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-different-types-of-supermarket-layout
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-different-types-of-supermarket-layout'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-different-types-of-supermarket-layout';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-different-types-of-supermarket-layout';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-different-types-of-supermarket-layout';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-different-types-of-supermarket-layout',
    'Different Types of Supermarket Layout',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766628356/ielts/supermarket-zones_306852eb3c54.png',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Different Types of Supermarket Layout',
    E'## Listening Test\n\nThis test has 10 questions in 2 parts:\n- **Questions 1-6:** Table Completion\n- **Questions 7-10:** Matching Information',
    E'# Listening Test - Different Types of Supermarket Layout\n\nThis is a listening practice test about different types of supermarket layout and product placement strategies. Listen carefully to the audio recording and answer the questions below.\n\n**Instructions:**\nYou will hear the recording ONCE only. Answer all questions based on what you hear in the audio.\n\n**About the Audio:**\nThis test includes table completion questions (Q1-6) and matching questions (Q7-10) about supermarket layouts and product placement. Pay close attention to the speakers'' discussions about grid, free-form, and boutique layouts, as well as where different types of products are typically placed in supermarkets.\n\n**Question Topics:**\n- Complete a table about different supermarket layout types\n- Match product types to their typical locations in supermarkets'
  ,
    'https://www.youtube.com/embed/DLQWAu2kt_4?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Grid layout - Controls _______',
    '',
    '{"blank-q1": ["TRAFFIC FLOWS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Grid layout - Shoppers can _______ through their shopping',
    '',
    '{"blank-q2": ["RUSH"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Free-form layout - Description: _______ organization',
    '',
    '{"blank-q3": ["RANDOM"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Free-form layout - Customers need more _______ to find products',
    '',
    '{"blank-q4": ["TIME"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Free-form layout - Less _______',
    '',
    '{"blank-q5": ["COST EFFECTIVE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Boutique layout - Separates space into _______',
    '',
    '{"blank-q6": ["SMALL AREAS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'quieter areas',
    '',
    '{"info-q7": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'end of aisles',
    '',
    '{"info-q8": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'middle shelves',
    '',
    '{"info-q9": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'near the entrance',
    '',
    '{"info-q10": ["B", "b"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 6, E'## Questions 1-6\n\nComplete the table below.\n\nWrite **NO MORE THAN THREE WORDS** for each answer.\n\n### Different Types of Supermarket Layout\n\n**Grid Layout**\n- Description: parallel aisles\n- Advantages: efficient use of floor space, Controls **1** _______\n- Disadvantages: Uninteresting layout, Shoppers can **2** _______ through their shopping\n\n**Free-form Layout**\n- Description: **3** _______ organization\n- Advantages: customers need more **4** _______ to find products\n- Disadvantages: poor use of space, so less **5** _______\n\n**Boutique Layout**\n- Description: Displays arranged around a food specialty\n- Advantages: separates space into **6** _______, creates attractive image\n- Disadvantages: poor use of space');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 7, 10, E'## Questions 7-10\n\nWhich types of products are placed in each location in supermarkets?\n\nChoose **FOUR** answers from the box and write the correct letter, **A-F**.\n\n### Types of Products:\n- **A** more expensive products\n- **B** most profitable products\n- **C** products reduced in price\n- **D** products aimed at children\n- **E** products requiring careful selection\n- **F** slow-moving products\n\n**Locations:**\n- **7** quieter areas: _______\n- **8** end of aisles: _______\n- **9** middle shelves: _______\n- **10** near the entrance: _______');

END$$;


COMMIT;