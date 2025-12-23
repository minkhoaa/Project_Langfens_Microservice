-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T05:58:56.729986
-- Source: mini-ielts.com
-- Title: Fiddy Working Heritage Farm
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-fiddy-working-heritage-farm
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-fiddy-working-heritage-farm',
    'Fiddy Working Heritage Farm',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766530670/ielts/listening-test-1-label-map_186689a6f18b.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Fiddy Working Heritage Farm',
    E'**Questions 1-4:** Complete the notes below. Write ONE WORD for each answer.\n\n**Questions 5-10:** Label the map below. Write the correct letter, A-I.',
    E'# Fiddy Working Heritage Farm\n\nWelcome to Fiddy Working Heritage Farm! This historic farm offers a unique experience for visitors of all ages. Before exploring, please note our important guidelines.\n\n## Questions 1-4: Complete the notes below\n\nWrite ONE WORD for each answer.\n\n### Advice about visiting the farm\n\n**Safety Guidelines for Visitors:**\n\nVisitors should:\n- take care not to harm any **1** _______ (the farm has many animals that need protection)\n- not touch any **2** _______ (equipment may be dangerous or fragile)\n- wear **3** _______ (appropriate footwear is essential for the terrain)\n- not bring **4** _______ into the farm, with certain exceptions (only guide dogs allowed)\n\n---\n\n## Questions 5-10: Label the map below\n\nWrite the correct letter A-I, next to Questions 5-10.\n\nThe map shows the layout of Fiddy Working Heritage Farm, including various buildings, attractions, and facilities available to visitors during their tour.\n\n![Farm Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766530670/ielts/listening-test-1-label-map_186689a6f18b.jpg)\n\n**Map Key:**\n- Letters A-I mark different locations on the farm\n- Match each place name with its correct location\n'
  ,
    'https://www.youtube.com/embed/IXfa58mHqMM?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'take care not to harm any _______',
    '',
    '{"blank-q1": ["animal"]}'::jsonb
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
    'not touch any _______',
    '',
    '{"blank-q2": ["tool"]}'::jsonb
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
    'wear _______',
    '',
    '{"blank-q3": ["shoes"]}'::jsonb
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
    'not bring _______ into the farm, with certain exceptions',
    '',
    '{"blank-q4": ["dog"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Scarecrow',
    '',
    '{"info-q5": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Maze',
    '',
    '{"info-q6": ["G", "g"]}'
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
    'Cafe',
    '',
    '{"info-q7": ["D", "d"]}'
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
    'Black Barn',
    '',
    '{"info-q8": ["H", "h"]}'
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
    'Covered picnic area',
    '',
    '{"info-q9": ["C", "c"]}'
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
    'Fiddy House',
    '',
    '{"info-q10": ["A", "a"]}'
  );


END$$;


COMMIT;