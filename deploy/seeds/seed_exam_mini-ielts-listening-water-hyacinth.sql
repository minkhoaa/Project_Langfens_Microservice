-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T02:55:32.739749
-- Source: mini-ielts.com
-- Title: Water hyacinth
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-water-hyacinth
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-water-hyacinth'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-water-hyacinth';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-water-hyacinth';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-water-hyacinth';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-water-hyacinth',
    'Water hyacinth',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://pondinformer.com/wp-content/uploads/2019/08/water-hyacinth-care-facts-planting-1.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Water hyacinth',
    E'**Questions 1-2:**\nChoose **TWO** letters, **A-E**.\n\nWhich two problems are caused by water hyacinth?\n\n---\n\n**Questions 3-6:**\nChoose the correct letter, **A**, **B** or **C**.\n\n---\n\n**Questions 7-10:**\nWhat is the benefit of the cut down water hyacinth to each of the following aspects?\n\nChoose **FOUR** answers from the box and write the correct letter, **A-F** next to Questions 7-10.\n\n**Benefits of the cut-down water hyacinth:**\n- A. can reduce the effect of global warming\n- B. can be used as alternative energy resource\n- C. can make quick profits\n- D. can produce materials for plants to grow in\n- E. can be good for human health\n- F. can produce fertilizer',
    E'# Passage\n\n# Listening Test - Water Hyacinth\n\nThis is a listening practice test about the water hyacinth plant and its environmental impacts.\n\n**About the Audio:**\nThis test discusses the water hyacinth, an invasive aquatic plant originally from Latin America that has become a major problem in many waterways around the world.\n\n**Topics covered:**\n- Problems caused by water hyacinth (blocking waterways, affecting fishing and electricity)\n- Origin of water hyacinth and how it spread\n- Environmental impacts (nutrient loss, soil erosion)\n- Biological and mechanical solutions\n- Benefits of harvesting water hyacinth (alternative energy, plant materials, mushroom farming)\n\n**Instructions:**\nListen carefully to the audio recording and answer the questions below. The recording will only be played once.\n\n**Word Bank for Questions 7-10:**\nA. can reduce the effect of global warming\nB. can be used as alternative energy resource\nC. can make quick profits\nD. can produce materials for plants to grow in\nE. can be good for human health\nF. can produce fertilizer'
  ,
    'https://www.youtube.com/embed/JdWLY889K2o?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Problem caused by water hyacinth (1/2)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. plants and fish are poisoned', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Farmers cannot fish', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the dam''s structure is damaged', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Electricity production is affected.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. electricity production is affected.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Problem caused by water hyacinth (2/2)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. plants and fish are poisoned', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Farmers cannot fish', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the dam''s structure is damaged', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Electricity production is affected.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. electricity production is affected.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Where was water hyacinth originally from?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Latin America', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Europe', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What is the primary cause of the decrease in nutrients from the soil?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. soil erosion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. a change of rainfall', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. loss of trees', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'When will the biological solution bring risks to the environment?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. immediately', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. 6 months later', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. many years later', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does John say about the mechanical solution?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. ineffective', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dangerous', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. expensive', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'What is the benefit of the cut down water hyacinth to: dried water hyacinth',
    '',
    '{"feature-q7": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'What is the benefit of the cut down water hyacinth to: mushroom farmers',
    '',
    '{"feature-q8": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'What is the benefit of the cut down water hyacinth to: ?',
    '',
    '{"feature-q9": ["E", "E"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'What is the benefit of the cut down water hyacinth to: ?',
    '',
    '{"feature-q10": ["B", "B"]}'
  );


END$$;


COMMIT;