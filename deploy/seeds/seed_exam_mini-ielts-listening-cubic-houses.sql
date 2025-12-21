-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T22:35:07.235501
-- Source: mini-ielts.com
-- Title: Cubic houses
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-cubic-houses
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-cubic-houses'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-cubic-houses';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-cubic-houses';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-cubic-houses';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-cubic-houses',
    'Cubic houses',
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
    'Listening Test - Cubic houses',
    E'**Questions 1-10:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'# Passage\n\n# Cube Houses - Listening Notes\n\n## Background Information\n\nAfter World War II, local urban planners wanted to redevelop and revive the city.\n\nAltogether, the Cube Houses can function as a _______ (1)\n\nEach Cube building is in the shape of a _______ (2)\n\nThe Cube Houses sit on top of a _______ (3) for pedestrians to the central city.\n\nDuring construction, the work was temporarily discontinued because the designer faced the problem of _______ (4)\n\n---\n\n## Design Features of the Cube Houses\n\nUnderneath the houses, there are three pillars made of _______ (5)\n\nA new building is situated between a warehouse and a _______ (6) of architecture.\n\nIt is a three-storey building.\n\nThe ground floor is an entrance.\n\nBoth the lower level and the top level of each house are in the shape of a _______ (7)\n\nThe first floor has a living room and an open kitchen.\n\nThe medium level has a bathroom and two bedrooms.\n\nThe top floor is sometimes used as a small _______ (8)\n\n---\n\n## Living in the Cube Houses\n\nThere is a nearby market _______ (9) across the square from the Cube Houses.\n\nFor guests, two advantages of the house are its convenient _______ (10) and reasonable price.',
    'https://www.youtube.com/embed/6bLp6k8O0_M?enablejsapi=1'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Altogether, the Cube Houses can function as a _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q1": ["village"]}'::jsonb
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
    'Each Cube building is in the shape of a _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q2": ["tree"]}'::jsonb
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
    'The Cube Houses sit on top of a _______ for pedestrians to the central city.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q3": ["bridge"]}'::jsonb
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
    'During construction, the work was temporarily discontinued because the designer faced the problem of _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["finance"]}'::jsonb
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
    'Underneath the houses, there are three pillars made of _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q5": ["concrete"]}'::jsonb
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
    'A new building is situated between a warehouse and a _______ , of architecture.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": ["school"]}'::jsonb
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
    'Both the lower level and the top level of each house are in the shape of a _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["triangle"]}'::jsonb
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
    'The top floor is sometimes used as a small _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q8": ["garden"]}'::jsonb
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
    'There is a nearby market _______ across the square from the Cube Houses.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q9": ["hall"]}'::jsonb
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
    'For guests, two advantages of the house are its convenient _______ and reasonable price.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q10": ["location"]}'::jsonb
  );


END$$;


COMMIT;