-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T20:19:59.839351
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
    'https://storage.icograms.com/templates/preview/supermarket-zones.png',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Different Types of Supermarket Layout',
    E'**Questions 1-6:**  \nComplete the table below.\n\nWrite **NO MORE THAN THREE WORDS** for each answer.\n\n---\n\n**Questions 7-10:**  \nWhich types of products are placed in each location in supermarkets?\n\nChoose **FOUR** answers from the box and write the correct letter, **A-F**.',
    E'# Different Types of Supermarket Layout\n\n## Questions 1-6: Complete the table below\n\n### Grid Layout\n- **Description:** parallel aisles\n- **Advantages:** \n  - efficient use of floor space\n  - Controls **1** _______\n- **Disadvantages:**\n  - Uninteresting layout\n  - Shoppers can **2** _______ through their shopping\n\n### Free-form Layout\n- **Description:** **3** _______ organization\n- **Disadvantages:**\n  - customers need more **4** _______ to find products\n  - poor use of space, so less **5** _______\n\n### Boutique Layout\n- **Description:** Displays arranged around a food specialty\n- **Advantages:**\n  - separates space into **6** _______\n  - creates attractive image\n- **Disadvantages:**\n  - poor use of space\n\n---\n\n## Questions 7-10: Which types of products are placed in each location?\n\n**Types of Products:**\n- **A** more expensive products\n- **B** most profitable products\n- **C** products reduced in price\n- **D** products aimed at children\n- **E** products requiring careful selection\n- **F** slow-moving products\n\n**Locations:**\n- **7** quieter areas → _______\n- **8** end of aisles → _______\n- **9** middle shelves → _______\n- **10** lower shelves → _______\n'
  ,
    'https://www.youtube.com/embed/DLQWAu2kt_4?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Grid layout: Controls **1** _______',
    '',
    '{"blank-q1": ["TRAFFIC FLOWS"]}'::jsonb
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
    '• Shoppers can _______ Through their shopping',
    '',
    '{"blank-q2": ["RUSH"]}'::jsonb
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
    'Free-form layout: **3** _______ organization',
    '',
    '{"blank-q3": ["RANDOM"]}'::jsonb
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
    '• customers need more _______ to find products',
    '',
    '{"blank-q4": ["TIME"]}'::jsonb
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
    'less _______',
    '',
    '{"blank-q5": ["COST EFFECTIVE"]}'::jsonb
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
    'into _______',
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
    'lower shelves',
    '',
    '{"info-q10": ["B", "b"]}'
  );


END$$;


COMMIT;