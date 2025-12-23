-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T04:08:21.491590
-- Source: mini-ielts.com
-- Title: A balanced diet
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-a-balanced-diet
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-a-balanced-diet'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-a-balanced-diet';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-a-balanced-diet';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-a-balanced-diet';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-a-balanced-diet',
    'A balanced diet',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766530817/ielts/balanced-diet_thumbpad_fd053a2fd95b.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - A balanced diet',
    E'**Questions 1-3:**\nCircle the correct answer.\n\n---\n\n**Questions 4-7:**\nComplete the notes.\nWrite **NO MORE THAN THREE WORDS** for each answer.\n\n---\n\n**Questions 8-9:**\nComplete the diagram by writing **NO MORE THAN THREE WORDS** in the boxes provided.',
    E'# A Balanced Diet\n\n## Questions 1-3: Multiple Choice\n\n**According to the first speaker:**\n\n**Question 1:** The focus of the lecture series is on...\n\n**Question 2:** The lecture will be given by...\n\n**According to the second speaker:**\n\n**Question 3:** This week''s lecture is on...\n\n---\n\n## Questions 4-7: Complete the Notes\n\n### A Balanced Diet\n\nA balanced diet will give you enough vitamins for normal daily living.\n\n- Vitamins in food can be lost through **4** _______\n\n**Types of vitamins:**\n- **(a)** Fat soluble vitamins are stored by the body.\n- **(b)** Water soluble vitamins - not stored, so you need a **5** _______\n\n**Getting enough vitamins:**\n- Eat **6** _______ of foods.\n- Buy plenty of vegetables and store them in **7** _______\n\n---\n\n## Questions 8-9: Complete the Diagram\n\nThe Food Pyramid shows what to eat for a balanced diet:\n\n- **Top (small portion):** Fats and sugars - **8** _______\n- **Bottom (large portion):** Bread, cereals, rice - **9** _______\n\n---\n\n## Food Pyramid Diagram (Questions 8-9)\n\n![Food Pyramid](https://res.cloudinary.com/df41zs8il/image/upload/v1766531059/ielts/diagram_9daad99f5edf.jpg)\n\nComplete the diagram by writing **NO MORE THAN THREE WORDS** in the boxes:\n\n- **8** _______ (Top of pyramid - Fats and sugars)\n- **9** _______ (Bottom of pyramid - Bread, cereals, rice)\n---\n\n## Diagram/Image for Questions 8-9\n\n![Questions 8-9](https://res.cloudinary.com/df41zs8il/image/upload/v1766531059/ielts/diagram_9daad99f5edf.jpg)\n'
  ,
    'https://www.youtube.com/embed/gdkw-8Dxhns?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The focus of the lecture series is on',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. organising work and study', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. maintaining a healthy lifestyle', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. coping with homesickness', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. settling in at university', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The lecture will be given by',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the president of the Union', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the campus doctor', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. a sports celebrity', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. a health expert', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'This week''s lecture is on',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. campus food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dieting', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. sensible eating', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. saving money', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Vitamins in food can be lost through _______',
    '',
    '{"blank-q4": ["cooking"]}'::jsonb
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
    'Water soluble vitamins - not stored, so you need a _______',
    '',
    '{"blank-q5": ["daily intake"]}'::jsonb
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
    'Getting enough vitamins: Eat _______ of foods.',
    '',
    '{"blank-q6": ["variety"]}'::jsonb
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
    'Buy plenty of vegetables and store them in _______',
    '',
    '{"blank-q7": ["the dark"]}'::jsonb
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
    'Top of food pyramid (Fats and sugars): _______',
    '',
    '{"blank-q8": ["eat in moderation"]}'::jsonb
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
    'Bottom of food pyramid (Bread, cereals, rice): _______',
    '',
    '{"blank-q9": ["eat lots"]}'::jsonb
  );


END$$;


COMMIT;